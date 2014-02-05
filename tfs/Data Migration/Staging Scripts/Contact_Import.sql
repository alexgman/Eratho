USE CRM_Staging
GO
/****** Object:  StoredProcedure [dbo].[CONtact_Import]    Script Date: 09/24/2012 10:39:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Contact_Import]') AND type in (N'P', N'PC'))
BEGIN
          DROP PROCEDURE [dbo].[Contact_Import]
END
GO
CREATE PROCEDURE [dbo].[Contact_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	CONtact_Import
** DescriptiON:	Insert/UPDATE CONtact FROM ONyx Individual table into MSCRM CONtactBase 
**
** RevisiON History
** --------------------------------------------------------------------------
** Date				Name			DescriptiON
** --------------------------------------------------------------------------
** 2012-09-25		BriAND			Initial CreatiON
** 2012-10-09		BriAND			Add link to parent company; add primary phONe type
*/

BEGIN
	SET NOCOUNT ON
	
		
	DECLARE	@Success		BIT,
			@RowId			UNIQUEIDENTIFIER,
			@ErrorId		NVARCHAR(50),
			@ErrorMessage	NVARCHAR(2000),
			@RowsProcessed	INT

		--Declare Variables
	DECLARE	
			@DefaultUoMScheduleId				NVARCHAR(255),
			@OrganizatiONId						NVARCHAR(255),
			@DefaultUoMId						NVARCHAR(255),
			@PriceLevelId						NVARCHAR(255),
			@CreatedBY							NVARCHAR(255),
			@ModifiedBY							NVARCHAR(255),
			@ExchangeRate						NVARCHAR(255),
			@OwningBusinessUnit					NVARCHAR(255),
			@TransactiONCurrencyId				NVARCHAR(255),
			@OwnerIdType						INT,
			@UnassignedTeam						NVARCHAR(255),
			@UnassignedTeamINC					UNIQUEIDENTIFIER,
			@UnassignedTeamLTD					UNIQUEIDENTIFIER

		--Get DEFAULT values
	SELECT	@DefaultUoMScheduleId				= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMScheduleId'),
			@OrganizatiONId						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'OrganizatiONId'),
			@DefaultUoMId						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMid'),
			@PriceLevelId						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'PriceLevelId'),
			@CreatedBY							= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'CreatedBY'),
			@ModifiedBY							= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'ModifiedBY'),
			@ExchangeRate						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'ExchangeRate'),
			@OwningBusinessUnit					= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'OwningBusinessUnit'),
			@TransactiONCurrencyId				= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'TransactiONCurrencyId'),
			@OwnerIdType						= NULL,--9, --CONtacts are owned BY Teams
			@UnassignedTeam						= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeam'),
			@UnassignedTeamINC					= NULL,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamINC'),
			@UnassignedTeamLTD					= NULL--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamLTD')

	--Created Temp Table for Job Titles
		IF OBJECT_ID('tempdb..#JobTitle') IS NOT NULL
			DROP TABLE #JobTitle
		
		CREATE TABLE #JobTitle(DestinationLabel NVARCHAR(250), DestinationValue INT, SourceValue NVARCHAR(250))
		INSERT INTO #JobTitle
			VALUES
			('Administrator',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Administrator','Active'),'ADM'),
			('Anaesthetist',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Anaesthetist','Active'),'ANAESTH'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'ASSIST'),
			('Biomed',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Biomed','Active'),'BIOMED'),
			('other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','other','Active'),'BUSMGR'),
			('other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','other','Active'),'CSEMGR'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'CHRGNURSE'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'CHIEF'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'CEO'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'CFO'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'CIO'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'COO'),
			('Clinical Trainer',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Clinical Trainer','Active'),'CLINICTRNR'),
			('Consultant',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Consultant','Active'),'CONS'),
			('Continence Advisor',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Continence Advisor','Active'),'CONTADV'),
			('Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Manager','Active'),'DEPTMGR'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'DIR'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'DON'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'DISTNURSE'),
			('Doctor',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Doctor','Active'),'DR'),
			('Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Manager','Active'),'EBME'),
			('Engineer',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Engineer','Active'),'ENG'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'FINDIR'),
			('Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Manager','Active'),'GENMGR'),
			('General Practitioner',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','General Practitioner','Active'),'GENPRAC'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'HCA'),
			('Infection Control Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Infection Control Nurse','Active'),'INFCONTNUR'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'LPN'),
			('Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Manager','Active'),'MGR'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'MATRON'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'MEDDEVCOOR'),
			('Midwife',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Midwife','Active'),'MIDWIFE'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'NURSE'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'NURSEADV'),
			('Nurse Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse Manager','Active'),'NURMGR'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'NURSESPEC'),
			('Office Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Office Manager','Active'),'OFFMGR'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'OTHER'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'OUTNURSE'),
			('Paramedic',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Paramedic','Active'),'PARA'),
			('Doctor',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Doctor','Active'),'Ped-ER-Phys'),
			('Physiotherapist',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Physiotherapist','Active'),'PHYSIOTH'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'PRACDEVNUR'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'PRACTNURSE'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'PRES'),
			('Product Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Product Manager','Active'),'PRODMAN'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'PRODSPEC'),
			('Purchaser',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Purchaser','Active'),'PURCHASER'),
			('Purchasing Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Purchasing Manager','Active'),'PURCHMGR'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'RN'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'REGISTRAR'),
			('Respiratory Therapist',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Respiratory Therapist','Active'),'RespTherap'),
			('Secretary',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Secretary','Active'),'SEC'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'SRHOUSEOFF'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'SISTER'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'SONO'),
			('Other',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Other','Active'),'SPECREG'),
			('Nurse',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Nurse','Active'),'STAFFNURSE'),
			('Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Manager','Active'),'SUPR'),
			('Supplies Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Supplies Manager','Active'),'SUPPMGR'),
			('Doctor',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Doctor','Active'),'SURG'),
			('Biomed',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Biomed','Active'),'TECH'),
			('Executive',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Executive','Active'),'VP'),
			('Manager',[CRM_STAGING].[dbo].[tsf_GetOptionSetId]('vth_jobtitle','Contact','Manager','Active'),'WARDMGR')


	--Map PhONe Types
	IF OBJECT_ID('tempdb..#pt') is not NULL
		DROP TABLE #pt

	SELECT DISTINCT L.Label, P.Value, CAST(NULL as varchar(100)) PhONeTypeId into #pt
				FROM CRM_OptiONSET O (NOLOCK)
					  INNER JOIN CRM_Attribute A (NOLOCK) 
								  ON A.OptiONSETId = O.OptiONSETId
					  INNER JOIN CRM_Entity E (NOLOCK) 
								  ON A.EntityId = E.EntityId
					  INNER JOIN CRM_AttributePicklistValue P (NOLOCK) 
								  ON O.OptiONSETId = P.OptiONSETId 
								  AND P.CompONentState = 0
					  INNER JOIN CRM_LocalizedLabel L (NOLOCK) 
								  ON L.ObjectId = P.AttributePicklistValueId
								  AND L.CompONentState = 0
								  AND L.ObjectColumnName = 'DisplayName'
				WHERE A.Name = 'vth_PrimaryPhONe' -- Field Schema Name
					  AND E.Name = 'CONtact' --Entity Schema name
	ORDER BY P.Value

	UPDATE A
	SET A.PhONeTypeId = RD.iParameterid
	--SELECT Label, Value, iParameterid 
	FROM #pt A
		 join  ONyx..ReferenceDefinitiON RD
			ON A.Label collate SQL_Latin1_General_CP1_CI_AS = RD.vchParameterDesc --collate Latin1_General_CI_AI 
	WHERE RD.tiRecordStatus = 1
		  AND RD.iReferenceId = 2 --PhONe Type
		  

	--Run Sproc Logic
	BEGIN TRY
	--Clear out the staging table
		TRUNCATE TABLE CRM_Staging.dbo.CONtact
		INSERT INTO CRM_Staging.dbo.CONtact(
					 CONtactId
					,DefaultPriceLevelId
					,CustomerSizeCode
					,CustomerTypeCode
					,PreferredCONtactMethodCode
					,LeadSourceCode
					,OriginatingLeadId
					,OwningBusinessUnit
					,PaymentTermsCode
					,ShippingMethodCode
					,ParticipatesInWorkflow
					,IsBackofficeCustomer
					,SalutatiON
					,JobTitle
					,FirstName
					,Department
					,NickName
					,MiddleName
					,LastName
					,Suffix
					,YomiFirstName
					,FullName
					,YomiMiddleName
					,YomiLastName
					,Anniversary
					,BirthDate
					,GovernmentId
					,YomiFullName
					,DescriptiON
					,EmployeeId
					,GENDerCode
					,AnnualIncome
					,HasChildrenCode
					,EducatiONCode
					,WebSiteUrl
					,FamilyStatusCode
					,FtpSiteUrl
					,EMailAddress1
					,SpousesName
					,AssistantName
					,EMailAddress2
					,AssistantPhONe
					,EMailAddress3
					,DONotPhONe
					,ManagerName
					,ManagerPhONe
					,DONotFax
					,DONotEMail
					,DONotPostalMail
					,DONotBulkEMail
					,DONotBulkPostalMail
					,AccountRoleCode
					,TerritoryCode
					,IsPrivate
					,CreditLimit
					,CreatedON
					,CreditONHold
					,CreatedBY
					,ModifiedON
					,ModifiedBY
					,NumberOfChildren
					,ChildrensNames
					--,VersiONNumber
					,MobilePhONe
					,Pager
					,TelephONe1
					,TelephONe2
					,TelephONe3
					,Fax
					,Aging30
					,StateCode
					,Aging60
					,StatusCode
					,Aging90
					,PreferredSystemUserId
					,PreferredServiceId
					,MasterId
					,PreferredAppointmentDayCode
					,PreferredAppointmentTimeCode
					,DONotSENDMM
					,Merged
					,ExternalUserIdentifier
					,SubscriptiONId
					,PreferredEquipmentId
					,LastUsedInCampaign
					,TransactiONCurrencyId
					,OverriddenCreatedON
					,ExchangeRate
					,ImportSequenceNumber
					,TimeZONeRuleVersiONNumber
					,UTCCONversiONTimeZONeCode
					,AnnualIncome_Base
					,CreditLimit_Base
					,Aging60_Base
					,Aging90_Base
					,Aging30_Base
					,OwnerId
					,CreatedONBehalfBY
					,IsAutoCreate
					,ModifiedONBehalfBY
					,ParentCustomerId
					,ParentCustomerIdType
					,ParentCustomerIdName
					,OwnerIdType
					,ParentCustomerIdYomiName
					,vth_cONtactNumber
					,vth_PrimaryPhONe
					,vth_Address1_Valid
					,vth_UseAsaReference
					,vth_LastExportReview
					,vth_jobtitle
					,vth_Department
					,vth_Source
					,vth_ExportStatus
					,vth_Country
					,vth_State,
					Address1_AddressTypeCode,
					Address1_City,
					Address1_Country,
					Address1_Line1,
					Address1_Line2,
					Address1_Line3,
					Address1_Name,
					Address1_PostalCode,
					Address1_StateOrProvince
		)
		SELECT --top 100
					 CONtactId = NEWID() --generate
					,DefaultPriceLevelId = NULL
					,CustomerSizeCode = NULL
					,CustomerTypeCode = NULL
					,PreferredCONtactMethodCode = NULL
					,LeadSourceCode = NULL --?
					,OriginatingLeadId = NULL
					,OwningBusinessUnit = NULL
					,PaymentTermsCode = NULL
					,ShippingMethodCode = NULL
					,ParticipatesInWorkflow = NULL
					,IsBackofficeCustomer = NULL				
					,SalutatiON = LTRIM(RTRIM(I.vchSalutation))
					,JobTitle = LTRIM(RTRIM(I.vchTitleDesc))  --chTitleCode
					,FirstName = LTRIM(RTRIM(I.vchFirstName))
					,Department = LTRIM(RTRIM(I.vchDepartmentDesc)) --chDepartmentCode
					,NickName = NULL
					,MiddleName = LTRIM(RTRIM(I.vchMiddleName))
					,LastName = LTRIM(RTRIM(I.vchLastName))
					,Suffix = LEFT(LTRIM(RTRIM(I.vchSuffix)), 10) --causes truncatiON error
					,YomiFirstName = NULL
					,FullName = LTRIM(RTRIM( 
									  --CASE WHEN len(LTRIM(RTRIM(ISNULL(I.vchSalutatiON, '')))) = 0 THEN '' ELSE LTRIM(RTRIM(ISNULL(I.vchFirstName, ''))) + ' ' END
									--+ 
									  CASE WHEN len(LTRIM(RTRIM(ISNULL(I.vchFirstName, '')))) = 0 THEN '' ELSE LTRIM(RTRIM(ISNULL(I.vchFirstName, ''))) + ' ' END
									+ CASE WHEN len(LTRIM(RTRIM(ISNULL(I.vchMiddleName, '')))) = 0 THEN '' ELSE LTRIM(RTRIM(ISNULL(I.vchMiddleName, ''))) + ' ' END
									+ CASE WHEN len(LTRIM(RTRIM(ISNULL(I.vchLastName, '')))) = 0 THEN '' ELSE LTRIM(RTRIM(ISNULL(I.vchLastName, ''))) + ' ' END
									--+ CASE WHEN len(LTRIM(RTRIM(ISNULL(I.vchSuffix, '')))) = 0 THEN '' ELSE LTRIM(RTRIM(ISNULL(I.vchSuffix, ''))) + ' ' END
									 ))
					,YomiMiddleName = NULL
					,YomiLastName = NULL
					,Anniversary = NULL
					,BirthDate = NULL
					,GovernmentId = NULL
					,YomiFullName = NULL
					,DescriptiON = NULL
					,EmployeeId = NULL
					,GENDerCode = CASE WHEN I.chGENDer = 'M' THEN 1 WHEN I.chGENDer = 'F' THEN 2 ELSE NULL END
					,AnnualIncome = NULL
					,HasChildrenCode = NULL
					,EducatiONCode = NULL
					,WebSiteUrl = LTRIM(RTRIM(I.vchURL))
					,FamilyStatusCode = NULL
					,FtpSiteUrl = NULL
					,EMailAddress1 = LTRIM(RTRIM(I.vchEmailAddress))
					,SpousesName = NULL
					,AssistantName = NULL
					,EMailAddress2 = NULL
					,AssistantPhONe = NULL
					,EMailAddress3 = NULL
					,DONotPhONe = NULL
					,ManagerName = NULL
					,ManagerPhONe = NULL
					,DONotFax = NULL
					,DONotEMail = NULL
					,DONotPostalMail = NULL
					,DONotBulkEMail = NULL
					,DONotBulkPostalMail = NULL
					,AccountRoleCode = NULL
					,TerritoryCode = NULL
					,IsPrivate = I.bPrivate
					,CreditLimit = NULL
					,CreatedON = I.dtInsertDate
					,CreditONHold = NULL
					,CreatedBY = NULL --lookup user
					,ModifiedON = I.dtUPDATEDate
					,ModifiedBY = NULL --lookup user
					,NumberOfChildren = NULL
					,ChildrensNames = NULL
					--,VersiONNumber = NULL
					,MobilePhONe = (CASE WHEN I.iPhONeTypeId = 103 THEN (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(I.vchPhONeNumber)),CO.chPhoneMask))  ELSE (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP.vchPhoneNumber)),CO.chPhoneMask)) END)
					,Pager = (CASE WHEN I.iPhONeTypeId = 339 THEN (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(I.vchPhONeNumber)),CO.chPhoneMask)) ELSE (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP.vchPhoneNumber)),CO.chPhoneMask)) END)
					,TelephONe1 = (CASE WHEN I.iPhONeTypeId = 100137 THEN (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(I.vchPhONeNumber)),Co.chPhoneMask)) ELSE (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP.vchPhoneNumber)),CO.chPhoneMask)) END) --Direct
					,TelephONe2 = (CASE WHEN I.iPhONeTypeId = 102 THEN (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(I.vchPhONeNumber)),CO.chPhoneMask)) ELSE (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP.vchPhoneNumber)),CO.chPhoneMask)) END) --Business
					,TelephONe3 = (CASE WHEN I.iPhONeTypeId = 119 THEN (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(I.vchPhONeNumber)),CO.chPhoneMask)) ELSE (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP.vchPhoneNumber)),CO.chPhoneMask)) END) --Home
					,Fax = (CASE WHEN I.iPhONeTypeId = 115 THEN (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(I.vchPhONeNumber)),CO.chPhoneMask)) ELSE (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(CP.vchPhoneNumber)),CO.chPhoneMask)) END)
					,Aging30 = NULL
					,StateCode = NULL
					,Aging60 = NULL
					,StatusCode = NULL
					,Aging90 = NULL
					,PreferredSystemUserId = NULL
					,PreferredServiceId = NULL
					,MasterId = NULL
					,PreferredAppointmentDayCode = NULL
					,PreferredAppointmentTimeCode = NULL
					,DONotSENDMM = NULL
					,Merged = NULL
					,ExternalUserIdentifier = NULL
					,SubscriptiONId = NULL
					,PreferredEquipmentId = NULL
					,LastUsedInCampaign = NULL
					,TransactiONCurrencyId = NULL
					,OverriddenCreatedON = NULL
					,ExchangeRate = NULL
					,ImportSequenceNumber = NULL
					,TimeZONeRuleVersiONNumber = NULL
					,UTCCONversiONTimeZONeCode = NULL
					,AnnualIncome_Base = NULL
					,CreditLimit_Base = NULL
					,Aging60_Base = NULL
					,Aging90_Base = NULL
					,Aging30_Base = NULL
					,OwnerId = NULL
					,CreatedONBehalfBY = NULL
					,IsAutoCreate = NULL
					,ModifiedONBehalfBY = NULL
					,ParentCustomerId = NULL --link to Company
					,ParentCustomerIdType = NULL
					,ParentCustomerIdName = NULL --link to Company
					,OwnerIdType = NULL
					,ParentCustomerIdYomiName = NULL
					,vth_cONtactNumber = I.iIndividualId --CON.iCONtactID
					,vth_PrimaryPhONe = CASE(i.iPhoneTypeId)
											WHEN 102
												THEN 958560001
											WHEN 103
												THEN 958560004
											WHEN 100137
												THEN 958560000
											WHEN 115
												THEN 958560002
											WHEN 119
												THEN 958560003
											WHEN 339
												THEN 958560005
										END
					,vth_Address1_Valid = I.bValidAddress
					,vth_UseAsaReference = CASE WHEN isnumeric(I.vchuser9) = 1 THEN I.vchuser9 ELSE NULL END                         
					,vth_LastExportReview = CASE WHEN isdate(LTRIM(RTRIM(I.vchUser2))) = 1 THEN LTRIM(RTRIM(I.vchUser2)) ELSE NULL END
					,vth_jobtitle = JobTitle.DestinationValue
					,vth_Department = NULL
					,vth_Source = I.iSourceId
					,vth_ExportStatus = (CASE 
                        WHEN 
                              I.vchUser3 = 101410 
                                  THEN 999990001 --ON-Hold
                        WHEN 
                              I.vchUser3= 102927 
                                  THEN 999990002 --Cleared
                        ELSE
                        NULL
                  END)

					,vth_Country = CT.DestinationValue
					,vth_State = RST.DestinationValue 
					,Address1_AddressTypeCode = CASE(I.iAddressTypeId)
													WHEN 102
														THEN 1
													WHEN 119
														THEN 2
												END
					,Address1_City = I.vchCity
					,Address1_Country = CO.chCountryDesc
					,Address1_Line1 = I.vchAddress1
					,Address1_Line2 = I.vchAddress2
					,Address1_Line3 = I.vchAddress3
					,Address1_Name = CASE(I.iAddressTypeId)
										WHEN 102
											THEN 'Business'
										WHEN 119
											THEN 'HOME'
									 END
					,Address1_PostalCode = (SELECT dbo.fn_ReturnMaskValue(LTRIM(RTRIM(I.vchPostCode)),CO.chPostCodeMask))
					,Address1_StateOrProvince = R.chRegionName
					
					
		FROM ONyx.dbo.Individual I WITH (NOLOCK)
			 left outer join #pt PT
				ON I.iPhONeTypeId = PT.PhONeTypeId		
				
			 LEFT OUTER JOIN #JobTitle JobTitle --Job Title
			 WITH (NOLOCK)
				ON I.chTitleCode = JobTitle.SourceValue
			
			 LEFT OUTER JOIN Onyx.dbo.CustomerPhone CP -- Customer Phone
			 WITH (NOLOCK)
				ON I.iIndividualId = CP.iOwnerID
				
			LEFT OUTER JOIN -- Country Code
					ONyx.[dbo].Country CO 
				WITH (NOLOCK)
					ON LTRIM(RTRIM(I.chCountryCode)) = LTRIM(RTRIM(CO.chCountryCode))
					
			LEFT OUTER JOIN  --State or Region
					 ONyx.[dbo].RegiON R 
					WITH (NOLOCK)
				ON LTRIM(RTRIM(I.chRegiONCode)) = LTRIM(RTRIM(R.chRegiONCode))
					AND LTRIM(RTRIM(I.chCountryCode)) = LTRIM(RTRIM(R.chCountryCode))
			LEFT OUTER JOIN -- State or Region Drop Down
					RegionStateTranslation RST
					WITH(NOLOCK)
				ON LTRIM(RTRIM(RST.SourceValue)) = 	LTRIM(RTRIM(I.chRegiONCode))
					AND LTRIM(RTRIM(RST.CountryCode)) = LTRIM(RTRIM(I.chCountryCode))
			LEFT OUTER JOIN --Country Drop Down
					CountryTranslation CT
					ON LTRIM(RTRIM(CT.SourceValue)) = LTRIM(RTRIM(I.chCountryCode))
			 
		WHERE I.tiRecordStatus = 1
			  AND exists (SELECT *
						  FROM ONyx.dbo.CONtact CON WITH (NOLOCK)
						  	   join ONyx.dbo.Company C WITH (NOLOCK)
								  ON CON.iOwnerID = C.iCompanyId
						  WHERE CON.tiRecordStatus = 1
								AND C.tiRecordStatus = 1
								AND CON.iCONtactID = I.iIndividualId
						 )
			  AND (SELECT COUNT(distinct CON2.iownerid)
				   FROM ONyx.dbo.CONtact CON2 WITH (NOLOCK)
				   WHERE CON2.iCONtactID = I.iIndividualId
						 AND CON2.tiRecordStatus = 1
				   GROUP BY CON2.iCONtactID
			      )	= 1
			      
		
		--SET Parent Company record		 
		UPDATE a
		SET a.ParentCustomerId = c.Accountid
		   ,a.ParentCustomerIdType = NULL
		   ,a.ParentCustomerIdName = c.Name --link to Company
		--SELECT * 
		FROM CONtact a
			 join ONyx..Individual b
				ON a.vth_cONtactNumber = b.iIndividualId
			 join Company c
				ON b.iCompanyId = c.AccountNumber	


	END TRY
	BEGIN CATCH
		-- Log Row - ERROR
		SELECT	@Success		= 0,
			@ErrorId		= ERROR_NUMBER(),
			@ErrorMessage	= ERROR_MESSAGE()
		EXEC CRM_Staging.dbo.DataMigratiONLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage
	END CATCH

	-- Log Row - Stop
	SELECT @RowsProcessed = COUNT(1) FROM CRM_Staging.dbo.CONtact WITH (NOLOCK)
	EXEC CRM_Staging.dbo.DataMigratiONLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL

	RETURN 1
END

