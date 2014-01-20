USE CRM_Staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Incident_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	Company_Import
** Description:	Insert/Update Service Incidents from Onyx Incident table into MSCRM Incident 
**
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-04		BrianD			Initial Creation
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
			@OrganizationId						NVARCHAR(255),
			@DefaultUoMId						NVARCHAR(255),
			@PriceLevelId						NVARCHAR(255),
			@CreatedBy							NVARCHAR(255),
			@ModifiedBy							NVARCHAR(255),
			@ExchangeRate						NVARCHAR(255),
			@OwningBusinessUnit					NVARCHAR(255),
			@TransactionCurrencyId				NVARCHAR(255),
			@OwnerIdType						INT,
			@UnassignedTeam						NVARCHAR(255),
			@UnassignedTeamINC					UNIQUEIDENTIFIER,
			@UnassignedTeamLTD					UNIQUEIDENTIFIER

		--Get DEFAULT values
	SELECT	@DefaultUoMScheduleId				= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMScheduleId'),
			@OrganizationId						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'OrganizationId'),
			@DefaultUoMId						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMid'),
			@PriceLevelId						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'PriceLevelId'),
			@CreatedBy							= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'CreatedBy'),
			@ModifiedBy							= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'ModifiedBy'),
			@ExchangeRate						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'ExchangeRate'),
			@OwningBusinessUnit					= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'OwningBusinessUnit'),
			@TransactionCurrencyId				= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'TransactionCurrencyId'),
			@OwnerIdType						= null,--9, --Contacts are owned by Teams
			@UnassignedTeam						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeam'),
			@UnassignedTeamINC					= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamINC'),
			@UnassignedTeamLTD					= null--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamLTD')
				
	--Run Sproc Logic
	BEGIN TRY
	--Clear out the staging table
		TRUNCATE TABLE CRM_Staging.dbo.Incident
		INSERT INTO CRM_Staging.dbo.Incident(
			 IncidentId
			,OwningBusinessUnit
			,ContractDetailId
			,SubjectId
			,ContractId
			,ActualServiceUnits
			,CaseOriginCode
			,BilledServiceUnits
			,CaseTypeCode
			,ProductSerialNumber
			,Title
			,ProductId
			,ContractServiceLevelCode
			,Description
			,IsDecrementing
			,CreatedOn
			,TicketNumber
			,PriorityCode
			,CustomerSatisfactionCode
			,IncidentStageCode
			,ModifiedOn
			,CreatedBy
			,FollowupBy
			,ModifiedBy
			,VersionNumber
			,StateCode
			,SeverityCode
			,StatusCode
			,ResponsibleContactId
			,KbArticleId
			,TimeZoneRuleVersionNumber
			,ImportSequenceNumber
			,UTCConversionTimeZoneCode
			,OverriddenCreatedOn
			,ExchangeRate
			,ModifiedOnBehalfBy
			,TransactionCurrencyId
			,CreatedOnBehalfBy
			,CustomerId
			,OwnerId
			,OwnerIdType
			,CustomerIdType
			,CustomerIdName
			,CustomerIdYomiName
			,vth_OriginalOrderId
			,vth_Resoultion1
			,vth_ContactId
			,vth_Action
			,vth_Conclusion
			,vth_CustomerPO
			,vth_QAApproval
			,vth_SVCApproval
			,vth_CARRes
			,vth_ReasonforInitialCall
			,vth_IncidentNumber
			,vth_Source
			,vth_CustomerProduct1Id
			,vth_CustomerProduct2Id
			,vth_Resolution2
			,vth_ProductBrand
			,vth_ProductModel
) 

select --top 100
			 IncidentId = NEWID() --uniqueidentifier primary key
			,OwningBusinessUnit = null --uniqueidentifier
			,ContractDetailId = null --uniqueidentifier
			,SubjectId = null --uniqueidentifier
			,ContractId = null --uniqueidentifier
			,ActualServiceUnits = null --int
			,CaseOriginCode = null --int
			,BilledServiceUnits = null--int
			,CaseTypeCode = null --int
			,ProductSerialNumber = left(ltrim(rtrim(SRV.vchUser6)) + ' ; ' + ltrim(rtrim(SRV.vchUser6)) , 200)--nvarchar(200)
			,Title = left(ltrim(rtrim(SRV.vchDesc1)), 400) --nvarchar(400)
			,ProductId = null --uniqueidentifier
			,ContractServiceLevelCode = null
			,Description = left(ltrim(rtrim(SRV.vchDesc1)), 200)   --nvarchar(200)
			,IsDecrementing = null --bit
			,CreatedOn = SRV.dtInsertDate --datetime
			,TicketNumber = null --nvarchar(200)
			,PriorityCode = SRV.iPriorityId --int
			,CustomerSatisfactionCode = null --int
			,IncidentStageCode = null --int
			,ModifiedOn = SRV.dtUpdateDate --datetime
			,CreatedBy = U1.SystemUserId --uniqueidentifier
			,FollowupBy = null --datetime?
			,ModifiedBy = U2.SystemUserId --uniqueidentifier
			,VersionNumber = null --timestamp
			,StateCode = null --int
			,SeverityCode = null --int
			,StatusCode = SRV.iStatusId --int
			,ResponsibleContactId = null --uniqueidentifier
			,KbArticleId = null --uniqueidentifier
			,TimeZoneRuleVersionNumber = null --int
			,ImportSequenceNumber = null --int
			,UTCConversionTimeZoneCode = null --int
			,OverriddenCreatedOn = null --datetime
			,ExchangeRate = null --decimal 18,0
			,ModifiedOnBehalfBy = null --uniqueidentifier
			,TransactionCurrencyId = null --uniqueidentifier
			,CreatedOnBehalfBy = null --uniqueidentifier
			,CustomerId = C2.AccountId --uniqueidentifier
			,OwnerId = null --uniqueidentifier
			,OwnerIdType = null --int
			,CustomerIdType = C.iCompanyTypeCode --int
			,CustomerIdName = ltrim(rtrim(C.vchCompanyName)) --nvarchar(800)
			,CustomerIdYomiName = null --nvarchar(800)
			,vth_OriginalOrderId = null --uniqueidentifier
			,vth_Resoultion1 = ltrim(rtrim(CD1.vchParameterDesc)) --nvarchar(200)
			,vth_ContactId = CON.ContactId --uniqueidentifier
			,vth_Action = null --SRV.vchUser8 --int
			,vth_Conclusion = SRV.vchUser9 --int
			,vth_CustomerPO = ltrim(rtrim(SRV.vchUser10)) --nvarchar(200)
			,vth_QAApproval = null --SRV.vchUser4 --bit
			,vth_SVCApproval = null --SRV.vchUser5 --bit
			,vth_CARRes = null --SRV.vchUser3 --nvarchar(200) ???? not in Onyx UI
			,vth_ReasonforInitialCall = SE.vchUser11 --int
			,vth_IncidentNumber = SRV.iIncidentId --int
			,vth_Source = SRV.iSourceId --int
			,vth_CustomerProduct1Id = null --uniqueidentifier
			,vth_CustomerProduct2Id = null --uniqueidentifier
			,vth_Resolution2 = ltrim(rtrim(CD2.vchParameterDesc)) --nvarchar(200)
			,vth_ProductBrand = null --SRV.vchProductId --int
			,vth_ProductModel = null --SRV.vchProductId --int
--select count(*) --top 10 *
from		Onyx..Incident SRV WITH (NOLOCK)
			left outer join Onyx..csuIncidentExtension SE WITH (NOLOCK)
				on SRV.iIncidentId = SE.iIncidentId
			join Onyx..Company C WITH (NOLOCK)
				on SRV.iOwnerID = C.iCompanyId
			join Company C2 WITH (NOLOCK)
				on C.iCompanyId = C2.AccountNumber
			left outer join Onyx..NetWorkUser CB WITH (NOLOCK)
				on SRV.chInsertBy = CB.chUserId 
			left outer join Users U1 WITH (NOLOCK)
				on ltrim(rtrim(CB.vchNetWorkUser)) = ltrim(rtrim(U1.DomainName))
			left outer join Onyx..NetWorkUser UB WITH (NOLOCK)
				on SRV.chUpdateBy = UB.chUserId
			left outer join Users U2 WITH (NOLOCK)
				on ltrim(rtrim(UB.vchNetWorkUser)) = ltrim(rtrim(U2.DomainName))
			left outer join Contact CON WITH (NOLOCK)
				on SRV.iContactId = CON.vth_contactNumber
			left outer join Onyx.dbo.ReferenceDefinition CD1 WITH (NOLOCK)
				on SRV.iCode1  = CD1.iParameterId
				and CD1.iReferenceId = 25 --Res. Code 1
				and	CD1.tiRecordStatus = 1
			left outer join Onyx.dbo.ReferenceDefinition CD2 WITH (NOLOCK)
				on SRV.iCode2  = CD2.iParameterId
				and CD2.iReferenceId = 26 --Res. Code 2
				and CD1.iParameterId = CD2.iParentId
				and	CD2.tiRecordStatus = 1
			left outer join Onyx.dbo.ReferenceDefinition CD3 WITH (NOLOCK)
				on SRV.iCode3  = CD3.iParameterId
				and CD3.iReferenceId = 27 --Res. Code 3
				and CD2.iParameterId = CD3.iParentId
				and	CD3.tiRecordStatus = 1
			left outer join Onyx.dbo.ReferenceDefinition CD4 WITH (NOLOCK)
				on SRV.iCode4  = CD4.iParameterId
				and CD4.iReferenceId = 28 --Res. Code 4
				and CD3.iParameterId = CD4.iParentId
				and	CD4.tiRecordStatus = 1
where SRV.tiRecordStatus = 1
	  and SRV.iIncidentCategory = 2 --service
	  and C.tiRecordStatus = 1

	END TRY
	BEGIN CATCH
		-- Log Row - ERROR
		--SELECT	@Success		= 0,
		--		@ErrorId		= ERROR_NUMBER(),
		--		@ErrorMessage	= ERROR_MESSAGE()
		--EXEC CRM_Staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage
	END CATCH

	-- Log Row - Stop
	--SELECT @RowsProcessed = COUNT(1) FROM CRM_Staging.dbo.Contact WITH (NOLOCK)
	--EXEC CRM_Staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL

	RETURN 1
END

