USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Company_Import]    Script Date: 01/10/2014 13:21:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Company_Import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Company_Import]
GO

USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Company_Import]    Script Date: 01/10/2014 13:21:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Company_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL,
	@Debug BIT = 0
)
AS
/*

EXEC Company_Import NULL, 1

** ObjectName:	Company_Import
** DescriptiON:	Insert/Update Company FROM ONyx Company table into MSCRM CONtactBase 
**
** RevisiON History
** --------------------------------------------------------------------------
** Date				Name			DescriptiON
** --------------------------------------------------------------------------
** 2012-09-24		BriAND			Initial CreatiON
** 2012-10-09		BriAND			Link record to parent; fill in county; add primary phONe type 
** 2012-11-13		GBS.PRogers		Added required fields
*/

BEGIN	
	DECLARE	@Success		BIT,
				@RowId			UNIQUEIDENTIFIER,
				@ErrorId		NVARCHAR(50),
				@ErrorMessage	NVARCHAR(2000),
				@RowsProcessed	INT,
				@ReturnCode BIT = 1
	
	BEGIN TRY
		--Declare Variables
		DECLARE	
				@DefaultUoMScheduleId				NVARCHAR(255),
				@OrganizatiONId						NVARCHAR(255),
				@DefaultUoMId						NVARCHAR(255),
				@PriceLevelId						NVARCHAR(255),
				@CreatedBy							NVARCHAR(255),
				@ModifiedBy							NVARCHAR(255),
				@ExchangeRate						NVARCHAR(255),
				@OwningBusinessUnit					NVARCHAR(255),
				@TransactiONCurrencyId				NVARCHAR(255),
				@OwnerIdType						INT,
				@UnassignedTeam						NVARCHAR(255),
				@UnassignedTeamINC					UNIQUEIDENTIFIER,
				@UnassignedTeamLTD					UNIQUEIDENTIFIER,
				@StartDateTime						NVARCHAR(20),
				@EndDateTime						NVARCHAR(20),
				@DebugMessage						NVARCHAR(255),
				@AdminUser							UniqueIdentifier,
				@dtCurrent							DATETIME,
				@LastRunDate						DATETIME 

		--Get DEFAULT values
		SELECT	@DefaultUoMScheduleId				= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMScheduleId'),
				@OrganizatiONId						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'OrganizatiONId'),
				@DefaultUoMId						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMid'),
				@PriceLevelId						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'PriceLevelId'),
				@CreatedBy							= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'CreatedBy'),
				@ModifiedBy							= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'ModifiedBy'),
				@ExchangeRate						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'ExchangeRate'),
				@OwningBusinessUnit					= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'OwningBusinessUnit'),
				@TransactiONCurrencyId				= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'TransactiONCurrencyId'),
				@OwnerIdType						= NULL,--9, --CONtacts are owned by Teams
				@UnassignedTeam						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeam'),
				@UnassignedTeamINC					= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamINC'),
				@UnassignedTeamLTD					= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.[dbo].Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamLTD')
				--@AdminUser							= (SELECT gbs_value FROM CRM_SystemParameterExtensionBase WHERE gbs_name like 'CRMAdminUserId'),
				@dtCurrent                          = Getdate(),            
				--@LastRunDate                        = (SELECT CONVERT(DATETIME,ISNULL(gbs_value,'1990-01-01')) FROM CRM_SystemParameterExtensionBase WHERE gbs_name = 'LastRunDate')
				@AdminUser = 'B202779B-A678-E311-93F3-005056A37B31' 
				,@LastRunDate = '1990-01-01'

		--
		IF OBJECT_ID('tempdb..#CompanyPricing') IS NOT NULL
				DROP TABLE #CompanyPricing
			
		CREATE TABLE #CompanyPricing (DestinationLabel NVARCHAR(255), DestinationValue nvarchar(255), SourceValue INT)
		INSERT INTO #CompanyPricing 
			VALUES 
('Advantage Healthcare Net','B1FB2ABF-6D66-E311-93F2-005056A37B31',101432)	,
('All Health Group Purchasing','B3FB2ABF-6D66-E311-93F2-005056A37B31',101433)	,
('Amerinet','B5FB2ABF-6D66-E311-93F2-005056A37B31',101434)	,
('Associated Purchasing Services','B7FB2ABF-6D66-E311-93F2-005056A37B31',101435)	,
('Beverly','B9FB2ABF-6D66-E311-93F2-005056A37B31',101429)	,
('Catholic Materials Management Alliance','BBFB2ABF-6D66-E311-93F2-005056A37B31',101437)	,
('CHAMPS Management Services','BDFB2ABF-6D66-E311-93F2-005056A37B31',101438)	,
('Columbia HCA','BFFB2ABF-6D66-E311-93F2-005056A37B31',101430)	,
('Department of Veterans Affairs','C1FB2ABF-6D66-E311-93F2-005056A37B31',101439)	,
('Direct Medical Equipment and Supplies','C3FB2ABF-6D66-E311-93F2-005056A37B31',101440)	,
('FR-APHP','C5FB2ABF-6D66-E311-93F2-005056A37B31',102646)	,
('FR-CAC','C7FB2ABF-6D66-E311-93F2-005056A37B31',102648)	,
('FR-CACIC','C9FB2ABF-6D66-E311-93F2-005056A37B31',102969)	,
('FR-CAHP','CBFB2ABF-6D66-E311-93F2-005056A37B31',102970)	,
('FR-CLINEA','CDFB2ABF-6D66-E311-93F2-005056A37B31',102971)	,
('FR-COS','CFFB2ABF-6D66-E311-93F2-005056A37B31',102972)	,
('FR-Générale de Santé','D1FB2ABF-6D66-E311-93F2-005056A37B31',102647)	,
('FR-HCL','D3FB2ABF-6D66-E311-93F2-005056A37B31',102645)	,
('FR-HELPEVIA','D5FB2ABF-6D66-E311-93F2-005056A37B31',102973)	,
('FR-KORIAN','D7FB2ABF-6D66-E311-93F2-005056A37B31',103269)	,
('FR-LADAPT','D9FB2ABF-6D66-E311-93F2-005056A37B31',102974)	,
('FR-ORPEA','DBFB2ABF-6D66-E311-93F2-005056A37B31',102975)	,
('FR-REPOTEL','DDFB2ABF-6D66-E311-93F2-005056A37B31',102976)	,
('FR-UGECAM','DFFB2ABF-6D66-E311-93F2-005056A37B31',102977)	,
('FR-VITALIA','E1FB2ABF-6D66-E311-93F2-005056A37B31',102978)	,
('GNYHA Ventures','E3FB2ABF-6D66-E311-93F2-005056A37B31',101441)	,
('GSA','E5FB2ABF-6D66-E311-93F2-005056A37B31',101682)	,
('Health Affiliated Services','E7FB2ABF-6D66-E311-93F2-005056A37B31',101442)	,
('Health Services Corp of America','E9FB2ABF-6D66-E311-93F2-005056A37B31',101443)	,
('Healthcare Group Purchasing','EBFB2ABF-6D66-E311-93F2-005056A37B31',101444)	,
('Healthcare Purchasing Partners','EDFB2ABF-6D66-E311-93F2-005056A37B31',101445)	,
('Hospital Central Services Corp','EFFB2ABF-6D66-E311-93F2-005056A37B31',101446)	,
('Hospital Council Shared Plus','F1FB2ABF-6D66-E311-93F2-005056A37B31',101447)	,
('Hospital Purchasing Service','F3FB2ABF-6D66-E311-93F2-005056A37B31',101448)	,
('Hospital Shared Services','F5FB2ABF-6D66-E311-93F2-005056A37B31',101449)	,
('HSNE Inc.','F7FB2ABF-6D66-E311-93F2-005056A37B31',101450)	,
('Intermountain Healthcare','F9FB2ABF-6D66-E311-93F2-005056A37B31',101451)	,
('Joint Purchasing Corporation','FBFB2ABF-6D66-E311-93F2-005056A37B31',101452)	,
('Kaiser Permanente','FDFB2ABF-6D66-E311-93F2-005056A37B31',101458)	,
('Magnet','FFFB2ABF-6D66-E311-93F2-005056A37B31',101453)	,
('MedEcon Services Inc.','01FC2ABF-6D66-E311-93F2-005056A37B31',101454)	,
('Multisource','03FC2ABF-6D66-E311-93F2-005056A37B31',101455)	,
('New Jersey Hospital Association','05FC2ABF-6D66-E311-93F2-005056A37B31',101456)	,
('None','07FC2ABF-6D66-E311-93F2-005056A37B31',101428)	,
('Other','09FC2ABF-6D66-E311-93F2-005056A37B31',101427)	,
('Owen Healthcare','0BFC2ABF-6D66-E311-93F2-005056A37B31',101457)	,
('Premier','0DFC2ABF-6D66-E311-93F2-005056A37B31',101431)	,
('Primenet','0FFC2ABF-6D66-E311-93F2-005056A37B31',101459)	,
('Purchase Connection','11FC2ABF-6D66-E311-93F2-005056A37B31',101460)	,
('Shared Service Healthcare','13FC2ABF-6D66-E311-93F2-005056A37B31',101461)	,
('SSM - Diversified Health Services','15FC2ABF-6D66-E311-93F2-005056A37B31',101462)	,
('Tenet Buypower','17FC2ABF-6D66-E311-93F2-005056A37B31',101463)	,
('Texas Hospital Association','19FC2ABF-6D66-E311-93F2-005056A37B31',101464)	,
('University HealthSystem Consortium (UHC)','1BFC2ABF-6D66-E311-93F2-005056A37B31',101465)	,
('Vector Health Systems','1DFC2ABF-6D66-E311-93F2-005056A37B31',101467)	,
('VHA Inc.','1FFC2ABF-6D66-E311-93F2-005056A37B31',101466)	



		IF OBJECT_ID ('tempdb..#FacilityType') IS NOT NULL
			DROP TABLE #FacilityType
		CREATE TABLE #FacilityType (DestinationLable NVARCHAR(225), DestinationValue INT, SourceValue INT)
		INSERT INTO #FacilityType
			VALUES
				('Accident & Emergency',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102325),
				('Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101424),
				('Ambulance Service',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','EMS','Active'),102624),
				('Anaesthetics',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102326),
				('Anesthesiology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102327),
				('BioMed',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102328),
				('Assisted Living',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Nursing Home','Active'),102329),
				('Cardiology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101561),
				('CardioThoracic',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102330),
				('Central Supply',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102331),
				('Continence Clinic',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Clinic','Active'),102332),
				('Critical Care Unit',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102333),
				('Day Surgery',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Surgical Center','Active'),102334),
				('Dermatology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102335),
				('Diagnostic Centre',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102336),
				('Dialysis',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102798),
				('DOD',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Military','Active'),102614),
				('EAU',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102337),
				('Elderly Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Nursing Home','Active'),102338),
				('Emergency Room (ER)',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102339),
				('EMT/Paramedics',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','EMS','Active'),102625),
				('Endocrinology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102340),
				('Family Practice',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102341),
				('Fire Department',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','EMS','Active'),102623),
				('Gastroenterology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102342),
				('Geriatrics- Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102343),
				('Geriatrics – Primary Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102344),
				('Gynaecology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102345),
				('Gyneacology & Obstetrics',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102346),
				('Gynecology - Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102347),
				('Gynecology – Primary Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102348),
				('Haematology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102349),
				('HDU',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102350),
				('Health Care Centers',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102351),
				('Home Health',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Nursing Home','Active'),101580),
				('Hospice',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospice ','Active'),102352),
				('ICU (Intensive Care Unit)',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102353),
				('ICU/Recovery Room',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102354),
				('Indian - Health',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102615),
				('Individual (6300)',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102355),
				('Infection',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102356),
				('Infection Control',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101574),
				('Inpatient Rehab',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101562),
				('Internal Medicine – Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102357),
				('Internal Medicine – Primary Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102358),
				('Labor & Delivery',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102359),
				('Life Flight',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','EMS','Active'),102622),
				('Materials Management',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101579),
				('MAU',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102360),
				('Medical Unit',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102361),
				('MedSurg',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102362),
				('Nephrology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102363),
				('Neurology - Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102364),
				('Neurology – Primary Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102365),
				('Neurosurgery',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102366),
				('Nursing Home',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Nursing Home','Active'),102367),
				('Obstetrics – Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102368),
				('Obstetrics – Primary Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102369),
				('Occupational Therapy',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102370),
				('Oncology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101572),
				('Opthalmology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102371),
				('OR',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102372),
				('Oral Surgery',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102373),
				('Orthopaedics',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102374),
				('Orthopedics',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102375),
				('Osteopathy',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102376),
				('Other - Distributor',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Distributor','Active'),102377),
				('Outpatient Clinic',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Clinic','Active'),102378),
				('Outpatient Rehab',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101563),
				('Outpatient Surgery',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Surgical Center','Active'),102379),
				('PACU',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101854),
				('Paediatrics',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102380),
				('Pain Management',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102381),
				('Palliative Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102382),
				('Pediatrics',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102383),
				('Physiatrists',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102384),
				('Physical Therapy',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101768),
				('Primary Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102319),
				('Private',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102320),
				('Psych',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102385),
				('Purchasing',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101565),
				('Radiology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101586),
				('R&D',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102386),
				('Recovery/Recovery Room',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102387),
				('Rehabilitation Centre',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102322),
				('Rehab Department',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102388),
				('SIM-Center',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','SIM - Center','Active'),102930),
				('Skilled Nursing',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102389),
				('Stroke & Rehab',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102390),
				('Sub Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102391),
				('Surgery',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Surgical Center','Active'),101577),
				('Surgical Recovery',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102392),
				('Surgical Unit',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102393),
				('Telemetry',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102394),
				('Thoracic Medicine',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102395),
				('Transitional Care Unit',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102396),
				('Transplant',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102397),
				('Urodynamic',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),101583),
				('Uro Gyn',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102398),
				('Uro-gynaecology',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102399),
				('Urology - Acute',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102400),
				('Urology – Primary Care',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102401),
				('Urologist – Private Practice',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Private/General Practice','Active'),102402),
				('Uro-therapy',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102403),
				('VA',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),101941),
				('VA – CBOC',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Clinic','Active'),102968),
				('Women’s Health',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','VA','Active'),102404),
				('Women’s Unit',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102405),
				('Veteran Home',[CRM_Staging].[dbo].[tsf_GetOptionSetId]('vth_buildingtype','Account','Hospital','Active'),102617)
				
		
		--Populate the staging table that stores the Country translation between Onyx and CRM values.
		EXEC PopulateCountryTranslation @LogId, @Debug
		
		--Populate the staging table that stores the Region/State translation between Onyx and CRM values.
		EXEC PopulateRegionStateTranslation @LogId, @Debug
		
		/*------------------- Run Sproc Logic ------------------*/
		
		--Clear out the staging table		
		IF (@Debug = 1)
		BEGIN
			SELECT @StartDateTime = CONVERT(NVARCHAR(20), GETDATE()),
					@DebugMessage = 'Inserting into CRM_Staging.Company started. ' + @StartDateTime
			
			RAISERROR (@DebugMessage, 0, 1) WITH NOWAIT
		END
		
		TRUNCATE TABLE CRM_Staging.[dbo].Company		
		
		INSERT INTO CRM_Staging.[dbo].Company(
			 AccountId
			,AccountCategoryCode
			,address1_AddressTypeCode
			,Address1_County
			,Address1_Fax
			,Address1_Latitude
			,Address1_LONgitude
			,Address1_PostOfficeBox
			,Address1_PrimaryCONtactName
			,Address1_TelephONe2
			,Address1_TelephONe3
			,Address1_UPSZONe
			,Address1_UTCOffset
			,Address1_AddressId
			,Address1_City
			,Address1_Country
			,Address1_FreightTermsCode
			,Address1_Line1
			,Address1_Line2
			,Address1_Line3
			,Address1_Name
			,Address1_PostalCode
			,Address1_ShippingMethodCode
			,Address1_StateOrProvince
			,Address1_TelephONe1
			--,TerritoryId --NOT NEEDED IN CRM
			,DefaultPriceLevelId
			,CustomerSizeCode
			,PreferredCONtactMethodCode
			,CustomerTypeCode
			,AccountRatingCode
			,IndustryCode
			--,TerritoryCode --NOT NEEDED IN CRM
			,AccountClassificatiONCode
			,BusinessTypeCode
			,OwningBusinessUnit
			,OwnerId
			,OwnerIdType
			,OriginatingLeadId
			,PaymentTermsCode
			,ShippingMethodCode
			,PrimaryCONtactId
			,ONyx_PrimaryCONtactId
			,ParticipatesInWorkflow
			,Name
			,AccountNumber
			,Revenue
			,OwningTeam
			,OwningUser
			,Revenue_Base
			,NumberOfEmployees
			,Description
			,SIC
			,OwnershipCode
			,MarketCap
			,MarketCap_Base
			,SharesOutstANDing
			,TickerSymbol
			,StockExchange
			,WebSiteURL
			,FtpSiteURL
			,EMailAddress1
			,EMailAddress2
			,EMailAddress3
			,DONotPhONe
			,DONotFax
			,TelephONe1
			,DONotEMail
			,TelephONe2
			,Fax
			,TelephONe3
			,DONotPostalMail
			,DONotBulkEMail
			,DONotBulkPostalMail
			,CreditLimit
			,CreditLimit_Base
			,CreditONHold
			,IsPrivate
			,CreatedON
			,CreatedBy
			,ModifiedON
			,ModifiedBy
			,ParentAccountId
			,ONyx_ParentCompanyId
			,Aging30
			,Aging30_Base
			,StateCode
			,Aging60
			,Aging60_Base
			,StatusCode
			,Aging90
			,Aging90_Base
			,PreferredAppointmentDayCode
			,PreferredSystemUserId
			,PreferredAppointmentTimeCode
			,Merged
			,DONotSENDMM
			,MasterId
			,LastUsedInCampaign
			,PreferredServiceId
			,PreferredEquipmentId
			,ExchangeRate
			,UTCCONversiONTimeZONeCode
			,OverriddenCreatedON
			,TimeZONeRuleVersiONNumber
			,ImportSequenceNumber
			,TransactiONCurrencyId
			,YomiName
			,vth_BedCount
			--,vth_BudgetRequest --REMOVED FROM CRM
			,vth_Country
			,vth_Duns
			,vth_ExportStatus
			,vth_FiscalYear
			--,vth_GPOId --REMOVED FROM CRM
			,vth_LastExportReview
			--,vth_MarketSectorId --REMOVED FROM CRM
			,vth_PrimaryPhONe
			,vth_Source
			,vth_Subtype
			,vth_TaxExempt
			,vth_TaxId
			--,vth_territoryId --NOT NEEDED IN CRM
			-- ,vth_Tier1GoldStar--REMOVED FROM CRM
			,vth_UseAsReference
			,vth_Valid
			,vth_CreditStatus
			,vth_ExpiratiON
			--,vth_EIN --REMOVED FROM CRM
			,vth_PreferredCarrier
			,vth_CarrierAccountNumber
			,vth_ServicePartner
			,RowActiON
			,vth_buildingtype
			,vth_pricing
			,vth_state
		)
		SELECT
			 AccountId = NEWID()
			,AccountCategoryCode = NULL --default is NULL
			,Address1_AddressTypeCode = CASE(C.iAddressTypeId)
											WHEN 100136
												THEN 3
											WHEN 101
												THEN 1
											ELSE 2
										END
			,Address1_County = LTRIM(RTRIM(C.vchUser1))
			,Address1_Fax = NULL
			,Address1_Latitude = NULL
			,Address1_LONgitude = NULL
			,Address1_PostOfficeBox = NULL
			,Address1_PrimaryCONtactName = NULL
			,Address1_TelephONe2 = NULL
			,Address1_TelephONe3 = NULL
			,Address1_UPSZONe = NULL
			,Address1_UTCOffset = NULL
			,Address1_AddressId = NULL
			,Address1_City = LTRIM(RTRIM(C.vchCity))
			,Address1_Country = LTRIM(RTRIM(CT.CountryDesc))--LTRIM(RTRIM(CO.chCountryDesc))
			,Address1_FreightTermsCode = NULL
			,Address1_Line1 = LTRIM(RTRIM(C.vchAddress1))
			,Address1_Line2 = LTRIM(RTRIM(C.vchAddress2))
			,Address1_Line3 = LTRIM(RTRIM(C.vchAddress3))
			,Address1_Name = CASE
								WHEN 
									C.iAddressTypeId = 100136 THEN 'Main'
								WHEN 
									C.iAddressTypeId = 101 THEN 'Billing'
								ELSE 'Shipping'
							 END
			,Address1_PostalCode = (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(C.vchPostCode)),CO.chPostCodeMask))
			,Address1_ShippingMethodCode = NULL
			,Address1_StateOrProvince = RST.RegionStateDesc --(RTRIM(R.chRegiONName)) --LTRIM(RTRIM(C.chRegiONCode))
			,Address1_TelephONe1 = NULL
			--,TerritoryId = NULL --NOT NEEDED IN CRM
			,DefaultPriceLevelId = NULL
			,CustomerSizeCode = NULL
			,PreferredCONtactMethodCode = 1
			,CustomerTypeCode = NULL
			,AccountRatingCode = NULL
			,IndustryCode = NULL
			--,TerritoryCode = LTRIM(RTRIM(RD1.vchParameterDesc)) --NOT NEEDED IN CRM
			,AccountClassificatiONCode = NULL
			,BusinessTypeCode = CASE(C.iCompanyTypeCode)
									WHEN 101519 --Association
										THEN 1 --Customer
									WHEN 102309 --Charity
										THEN 1 --Customer
									WHEN 102310 --Consultancy
										THEN 1	--Customer
									WHEN 100316 --Consulting
										THEN 1	--Customer
									WHEN 100325 --Customer
										THEN 1	--Customer
									WHEN 327	--Distributor
										THEN 999990000	--Distributor
									WHEN 102311	--Distributor
										THEN 999990000	--Distributor
									WHEN 102045 --DU Employee
										THEN 999990004 --Verathon
									WHEN 102902 --Inactive DU Employee
										THEN 999990004	--Verathon
									WHEN 102903 --Inactive DU Employee
										THEN 999990004	--Verathon
									WHEN 299	--Lead
										THEN 999990001	--Lead
									WHEN 102616 --Leasing Company
										THEN 999990002	--Leasing Company
									WHEN 100131 --Partner
										THEN 999990003	--Partner
									WHEN 101520 --PR
										THEN 999990003 --Partner
									WHEN 168	--Vendor	
										THEN 999990005 --Vendor
								--	WHEN 100286 THEN ????????? Competitor		
								END
			,OwningBusinessUnit = NULL /*CASE
				WHEN T.TeamId is  NULL 	
					THEN (SELECT [dbo].fn_GetBUOfIndeterminateTeams(C.chUpdateBy))
					ELSE T.BusinessUnitId
				EnD*/
			,OwnerId =NULL /*CASE
				WHEN T.TeamId is  NULL 	
					THEN (SELECT [dbo].fn_GetBUOfIndeterminateTeams(C.chUpdateBy)) 
						 
					ELSE T.TeamId
					END*/
			,OwnerIdType = 9
			,OriginatingLeadId = NULL
			,PaymentTermsCode =CASE(CVW.Terms_Description)
										WHEN 'Due Upon Receipt,' 
											THEN 100000003
										WHEN 'Net 30 Days,' 
											THEN 1
										WHEN 'Net 45 Days,' 
											THEN 3
										WHEN 'Net 60 Days GFT,' 
											THEN 4
										WHEN 'Net 90 Days GFT,' 
											THEN 100000004
										WHEN 'Prepaid,' 
											THEN 100000005
										WHEN 'Prepay,' 
											THEN 100000005
									END-- NULL
			,ShippingMethodCode = NULL
			,PrimaryCONtactId = NULL
			,ONyx_PrimaryCONtactId = C.iPrimaryCONtactId
			,ParticipatesInWorkflow = NULL
			,Name = LTRIM(RTRIM(C.vchCompanyName))
			,AccountNumber = C.iCompanyId
			,Revenue = NULL
			,OwningTeam = NULL
			,OwningUser = NULL
			,Revenue_Base = NULL
			,NumberOfEmployees = NULL
			,[Description] = NULL
			,SIC = C.iSICCode
			,OwnershipCode = NULL
			,MarketCap = NULL
			,MarketCap_Base = NULL
			,SharesOutstANDing = NULL
			,TickerSymbol = NULL
			,StockExchange = NULL
			,WebSiteURL = left(LTRIM(RTRIM(C.vchURL)), 100)
			,FtpSiteURL = NULL
			,EMailAddress1 = left(LTRIM(RTRIM(C.vchEmailAddress)), 100)
			,EMailAddress2 = NULL
			,EMailAddress3 = NULL
			,DONotPhONe = 0
			,DONotFax = 0
			,TelephONe1 = (CASE 
								WHEN 
									C.iPhONeTypeId = 100136 
								THEN 
									(SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(C.vchPhONeNumber)),CO.chPhoneMask)) 
								ELSE 
									(SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP1.vchPhONeNumber)),CO.chPhoneMask)) 
						   END)
			,DONotEMail = 0
			,TelephONe2 = (CASE 
								WHEN 
									C.iPhONeTypeId = 102308 
								THEN 
									(SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(C.vchPhONeNumber)),CO.chPhoneMask)) 
								ELSE
									(SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP2.vchPhONeNumber)),Co.chPhoneMask)) 
						   END)
			,Fax = (CASE
						 WHEN 
							c.iPhONeTypeId = 115 
						 THEN 
							(SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(C.vchPhONeNumber)),CO.chPhoneMask)) 
						 ELSE 
							(SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP3.vchPhONeNumber)),CO.chPhoneMask))
					 END)
			,TelephONe3 = NULL
			,DONotPostalMail = 0
			,DONotBulkEMail = 0
			,DONotBulkPostalMail = NULL
			,CreditLimit =LTRIM(STR(CVW.CREDIT_LIMIT,10,2))
			,CreditLimit_Base = NULL
			,CreditONHold = 0
			,IsPrivate = C.bPrivate
			,CreatedON = c.dtInsertDate--(SELECT crmtestdb.DM1_MSCRM.dbo.fn_LocalTimeToUTC(C.dtInsertDate))
			,CreatedBy = CASE 
							WHEN ISU.SystemUserId IS NULL
								THEN @AdminUser
							ELSE ISU.SystemUserId
						  END
			,ModifiedON = c.dtUpdateDate--(SELECT crmtestdb.DM1_MSCRM.dbo.fn_LocalTimeToUTC(C.dtUpdateDate))
			,ModifiedBy = CASE 
							WHEN SU.SystemUserId IS NULL 
								THEN @AdminUser
							ELSE SU.SystemUserId
						  END
			,ParentAccountId = NULL --must be NULL. If you try to insert an account that has not been created it throws an error.
			,ONyx_ParentCompanyId = C.iParentId
			,Aging30 = NULL
			,Aging30_Base = NULL
			,StateCode = 0
			,Aging60 = NULL
			,Aging60_Base = NULL
			,StatusCode = 1
			,Aging90 = NULL
			,Aging90_Base = NULL
			,PreferredAppointmentDayCode = NULL
			,PreferredSystemUserId = NULL
			,PreferredAppointmentTimeCode = NULL
			,Merged = NULL
			,DONotSENDMM = CASE(C.bPrivate)
								WHEN 1
									THEN 1
								ELSE 0
							END
			,MasterId = NULL
			,LastUsedInCampaign = NULL
			,PreferredServiceId = NULL
			,PreferredEquipmentId = NULL
			,ExchangeRate = NULL
			,UTCCONversiONTimeZONeCode = NULL
			,OverriddenCreatedON = NULL
			,TimeZONeRuleVersiONNumber = NULL
			,ImportSequenceNumber = NULL
			,TransactiONCurrencyId = NULL /*CASE
				WHEN T.TeamId is  NULL 	
					THEN (SELECT [DBO].fn_GetCurrOfIndeterminateTeams(C.chUpdateBy))
					ELSE T.TransactionCurrencyId
				EnD*/
			,YomiName = C.vchCompanyName
			,vth_BedCount = CASE (CAST(CF.txFamilyDetail AS NVARCHAR(MAX))) --C.iFamilyId
								WHEN
									'1-10' 
										THEN 999990001 -- 1-10
								WHEN
									'11-50' 
										THEN 999990011 -- 11-50
								WHEN
									'51-100' 
										THEN 999990051 -- 51-100
								WHEN
									'101-250' 
										THEN 999990101 -- 101-250
								WHEN
									'251-500' 
										THEN 999990251 --251-500
								WHEN
									'501-1000' 
										THEN 999991501 --501-1000
								WHEN	
									'>1000' 
										THEN 999991000 -->1000
								WHEN
									'N/A' 
										THEN 999990000 -- N/A
							END			 
			--,vth_BudgetRequest = LTRIM(RTRIM(RD4.vchParameterDesc)) --LTRIM(RTRIM(C.vchUser4)) -- REMOVED FROM CRM
			,vth_Country = CT.DestinationValue 
			,vth_Duns = LTRIM(RTRIM(C.vchDunnsNumber))
			,vth_ExportStatus = (CASE 
									WHEN 
										RD2.iParameterId = 101410 
											THEN 999990001 --ON-Hold
									WHEN 
										RD2.iParameterId = 102927 
											THEN 999990002 --Cleared
									ELSE
									NULL
								END)
								
			,vth_FiscalYear =  CASE(LTRIM(RTRIM(C.vchUser5))) --LTRIM(RTRIM(RD5.vchParameterDesc))
								  WHEN 101507 --January
									  THEN 999990000 --January
								  WHEN 101508 -- February
									  THEN 999990001 --February
								  WHEN 101509 --March
									  THEN 999990002 --March
								  WHEN 101510 --April
									  THEN 999990003 --April
								  WHEN 101511 --May
									  THEN 999990004 --May
								  WHEN 101512 --June
									  THEN 999990005 --June
								  WHEN 101513 --July
									  THEN 999990006 --July
								  WHEN 101514 --August
									  THEN 999990007 --August
								  WHEN 101515 --Spetember
									  THEN 999990008 --September 
								  WHEN 101516 --October
									  THEN 999990009 --October
								  WHEN 101517 --November
									  THEN 999990010 --Noveber
								  WHEN 101518 --December
									  THEN 999990011 --December
								  ELSE NULL
							  END
			--,vth_GPOId = NULL --C.iSICCode --REMOVED FROM CRM
			,vth_LastExportReview = (CASE 
										WHEN 
											ISDATE(LTRIM(RTRIM(C.vchUser8))) = 1 
												THEN LTRIM(RTRIM(C.vchUser8)) 
										ELSE NULL 
									  END)
									   
			--,vth_MarketSectorId = NULL --C.iMarketSector --REMOVED FROM CRM
			,vth_PrimaryPhONe =(CASE(C.iPhONeTypeId) 
									WHEN 100136 --Main
										THEN 999990000 --Main 
									WHEN 115 -- Fax
										THEN 999990001	-- Fax
									WHEN 102308	--Toll Free
										THEN 999990002	--Toll Free
								END)--LTRIM(RTRIM(C.vchPhONeNumber))
								
			,vth_Source = CASE(C.iSourceId)
							 WHEN 102406 --Ad
								THEN 999990000 --Ad
							 WHEN 102407 -- Clientele
								THEN 999990004 --Direct Insert 
							 WHEN 102037 --Database
								THEN 999990004 --Direct Insert
							 WHEN 102408 -- Daylite
								THEN 999990004	--Direct Insert
							 WHEN 101468 --Direct Insert
								THEN 999990004	--Direct Insert
							 WHEN 102409 -- Direct Mailer
								THEN 999990004 -- Direct Insert
							 WHEN 327 -- Distibutor
								THEN 999990006	--Distributor
							 WHEN 101609 -- Inbound Call
								THEN 999990008 -- Inbound Call
							 WHEN 102303 -- LoadStone
								THEN 958560004 -- Direct Insert
							 WHEN 102410 -- Politi
								THEN 958560004 -- Direct Insert
							 WHEN 101520 -- PR
								THEN 958560004	-- Direct Insert
							 WHEN 337 --Referral
								THEN 999990011 -- Referral
							 WHEN 102411 -- Rosenwald
								THEN 999990004 --Direct Insert
							 WHEN 101888 -- Trade Show
								THEN 999990013 -- Tradeshow
							 WHEN 102412 -- Web Site
								THEN 999990014 --Web Site
							 ELSE NULL
						END
			,vth_Subtype = NULL
			,vth_TaxExempt = CONVERT(BIT, CASE CVW.TAX_EXEMPT WHEN 'Y' THEN 1 ELSE 0 END)--LTRIM(RTRIM(C.vchUser7))
			,vth_TaxId = ISNULL(CVW.TAX_ID_NUMBER,'')--C.vchTaxId
			--,vth_territoryId = NULL --LTRIM(RTRIM(C.vchUser3)) --NOT NEEDED IN CRM
			--,vth_Tier1GoldStar = 1 --CE.vchUser11 -- REMOVED FROM CRM
			,vth_UseAsReference = CASE(C.vchUser6)
									WHEN 1
										THEN 1
									ELSE 0
								  END
			,vth_Valid = CASE(C.bValidAddress)
							WHEN 1
								THEN 1
							ELSE 0
						 END
			,vth_CreditStatus = CASE (CVW.CREDIT_STATUS)
								WHEN 'S' 
									THEN 999990003
								WHEN 'A' 
									THEN 999990000
								WHEN 'O' 
									THEN 999990002
								WHEN 'H' 
									THEN 999990001
								ELSE 999990001
							 END 
			,vth_ExpiratiON =  CASE WHEN ISDATE(CVW.USER_9)=1 THEN CVW.USER_9 ELSE NULL END --cvw.USER_9 --(SELECT dbo.fn_LocalTimeToUTC(CONVERT(DATETIME, CASE WHEN ISDATE(CVW.USER_9)=1 THEN CVW.USER_9 ELSE NULL END))) --NULL
			--,vth_EIN = NULL --REMOVED FROM CRM
			,vth_PreferredCarrier = NULL
			,vth_CarrierAccountNumber = NULL
			,vth_ServicePartner = NULL
			,RowActiON = NULL
			,vth_buildingtype = FacilityType.DestinationValue
			,vth_pricing = NULL --CompanyPricing.DestinationValue
			,vth_state = RST.DestinationValue								
		
			FROM	
					ONyx.[dbo].Company C 
				WITH (NOLOCK)
				
			LEFT OUTER JOIN 
					ONyx.[dbo].csuCompanyExtensiON CE 
				WITH (NOLOCK)
					ON C.iCompanyId = CE.iCompanyId
					
			LEFT OUTER JOIN 
					ONyx.[dbo].Country CO 
				WITH (NOLOCK)
					ON LTRIM(RTRIM(C.chCountryCode)) = LTRIM(RTRIM(CO.chCountryCode))
					AND CO.tiRecordStatus = 1
			LEFT OUTER JOIN
					CountryTranslation CT
					ON LTRIM(RTRIM(CT.SourceValue)) = LTRIM(RTRIM(C.chCountryCode))
						
						
			LEFT OUTER JOIN
					 ONyx.[dbo].RegiON R 
					WITH (NOLOCK)
				ON LTRIM(RTRIM(C.chRegiONCode)) = LTRIM(RTRIM(R.chRegiONCode))
					AND LTRIM(RTRIM(C.chCountryCode)) = LTRIM(RTRIM(R.chCountryCode))
					AND R.tiRecordStatus = 1
			LEFT OUTER JOIN
					RegionStateTranslation RST
					WITH(NOLOCK)
				ON LTRIM(RTRIM(RST.SourceValue)) = 	LTRIM(RTRIM(C.chRegiONCode))
					AND LTRIM(RTRIM(RST.CountryCode)) = LTRIM(RTRIM(C.chCountryCode))
											
			LEFT OUTER JOIN 
					ONyx.[dbo].CustomerPhONe CP1 
				WITH (NOLOCK)
					ON C.iCompanyId = CP1.iOwnerID
						AND CP1.iPhONeTypeId = 100136 --Main
							AND	CP1.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].CustomerPhONe CP2 
				WITH (NOLOCK)
					ON C.iCompanyId = CP2.iOwnerID
						AND CP2.iPhONeTypeId = 102308 --Toll Free
							AND	CP2.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].CustomerPhONe CP3 
				WITH (NOLOCK)
					ON C.iCompanyId = CP3.iOwnerID
						AND CP3.iPhONeTypeId = 115 --Fax
							AND	CP3.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].ReferenceDefinitiON RD1 
				WITH (NOLOCK)
					ON C.vchUser3 = RD1.iParameterId
						AND RD1.iReferenceId = 499 --Territroy
							AND	RD1.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].ReferenceDefinitiON RD2 
				WITH (NOLOCK)
					ON C.vchUser9 = RD2.iParameterId
						AND RD2.iReferenceId = 69 --Export Status
							AND	RD2.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].ReferenceDefinitiON RD3 
				WITH (NOLOCK)
					ON C.iAddressTypeId = RD3.iParameterId
						AND RD3.iReferenceId = 71 --Address Type
							AND	RD3.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].ReferenceDefinitiON RD4 
				WITH (NOLOCK)
					ON C.vchUser4 = RD4.iParameterId
						AND RD3.iReferenceId = 64 --Budget Request
							AND	RD3.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].ReferenceDefinitiON RD5 
				WITH (NOLOCK)
					ON C.vchUser5 = RD5.iParameterId
					AND RD5.iReferenceId = 65 --Fiscal Year
						AND	RD5.tiRecordStatus = 1
						
			LEFT OUTER JOIN 
					ONyx.[dbo].ReferenceDefinitiON RD6 
				WITH (NOLOCK)
					ON C.vchUser6 = RD5.iParameterId
						AND RD6.iReferenceId = 45 --Source
							AND	RD6.tiRecordStatus = 1
							
			LEFT OUTER JOIN 
					ONyx.[dbo].CompanyFamily CF WITH (NOLOCK)
					ON C.iFamilyId = CF.iFamilyId --Bed Count
						AND	CF.tiRecordStatus = 1
							
			LEFT OUTER  JOIN Users SU -- Ths gets user id of Company.chUpdateBY
				WITH(NOLOCK)
					ON C.chUpdateBy = SU.vth_OnyxUserId 
			LEFT OUTER JOIN Users ISU -- This gets user id of Company.chInsertBy
				WITH(NOLOCK)
					ON C.chInsertBy = ISU.vth_OnyxUserId 
			LEFT OUTER  JOIN CRM_TeamBase T
				WITH(NOLOCK)
				ON T.BusinessUnitId = SU.BusinessUnitId
			
			LEFT OUTER JOIN #CompanyPricing CompanyPricing
				WITH(NOLOCK)
				ON CompanyPricing.SourceValue = C.iSICCode
				
			LEFT OUTER JOIN #FacilityType FacilityType
				WITH(NOLOCK)
				ON FacilityType.SourceValue = C.iMarketSector
				
			LEFT OUTER JOIN	--A company could be worked on by more than one BU. To resolve such cases, if multiple companies are present,
							--we take the company that has the more recent last order date, or more open orders.
				(SELECT ID,
						CREDIT_LIMIT,
						TAX_EXEMPT,
						TAX_ID_NUMBER,
						CREDIT_STATUS,
						TERMS_DESCRIPTION,
						USER_9 FROM ProdPortal.Visual.vwCustomer V (NOLOCK)
					WHERE ROWID = (SELECT TOP 1 ROWID 
									FROM ProdPortal.Visual.vwCustomer V1 (NOLOCK)
									WHERE V1.ID = V.ID
										ORDER BY ISNULL(LAST_ORDER_DATE, CONVERT(DATETIME,'1990-12-01 00:00:00')) DESC,												
												OPEN_ORDER_COUNT DESC,
												OPEN_RECV_COUNT DESC,
												TOTAL_OPEN_ORDERS DESC)) CVW
				ON  CAST(C.iCompanyId AS NVARCHAR(MAX))= CVW.ID
		
		WHERE	C.tiRecordStatus = 1 
			AND DATEDIFF(HH, @LastRunDate, C.dtUpdateDate) > 0	

		-- Update  Set AccountId to AccountId in CRM		 
		UPDATE Stage 
			SET    Stage.AccountId = CRM.AccountId				  
		 FROM   CRM_Staging.dbo.Company Stage 
			INNER JOIN CRM_Accountbase CRM 
		 ON 
			CRM.AccountNumber = Stage.AccountNumber COLLATE Latin1_General_CI_AI
                                                    
		--Update Address1_Address id      
		UPDATE Stage
			SET Stage.Address1_AddressId = CRM.CustomerAddressId
		FROM
			CRM_Staging.dbo.Company Stage
		LEFT OUTER JOIN CRM_CustomerAddressBase CRM
			ON CRM.ParentId = Stage.AccountId
		WHERE CRM.AddressNumber = 1
		
	END TRY
	BEGIN CATCH
		--Log Row - ERROR
		SELECT	@Success		= 0,
				@ErrorId		= ERROR_NUMBER(),
				@ErrorMessage	= ERROR_MESSAGE(),
				@ReturnCode		= 0
		SELECT @ErrorMessage = 'An error occurred in Company_Import: ' + @ErrorMessage
		RAISERROR (@ErrorMessage, 0, 1)
		--EXEC CRM_Staging.[dbo].DataMigratiONLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage
	END CATCH

	-- Log Row - Stop
	SELECT @RowsProcessed = COUNT(1) FROM CRM_Staging.[dbo].CONtact WITH (NOLOCK)
	--EXEC CRM_Staging.[dbo].DataMigratiONLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL

	RETURN @ReturnCode
END


GO


