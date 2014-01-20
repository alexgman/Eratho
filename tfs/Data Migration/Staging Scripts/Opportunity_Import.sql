USE CRM_Staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Opportunity_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	Company_Import
** Description:	Insert/Update Sales Incidents from Onyx Company table into MSCRM Opportunity 
**
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-03		BrianD			Initial Creation
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
		TRUNCATE TABLE CRM_Staging.dbo.Opportunity
		INSERT INTO CRM_Staging.dbo.Opportunity(
			 OpportunityId
			,PriceLevelId
			,OpportunityRatingCode
			,PriorityCode
			,Name
			,StepId
			,Description
			,EstimatedValue
			,StepName
			,SalesStageCode
			,ParticipatesInWorkflow
			,PricingErrorCode
			,EstimatedCloseDate
			,CloseProbability
			,ActualValue
			,ActualCloseDate
			,OwningBusinessUnit
			,OriginatingLeadId
			,CreatedOn
			,IsPrivate
			,CreatedBy
			,ModifiedOn
			,ModifiedBy
			,VersionNumber
			,StateCode
			,StatusCode
			,IsRevenueSystemCalculated
			,CampaignId
			,TransactionCurrencyId
			,ExchangeRate
			,ImportSequenceNumber
			,UTCConversionTimeZoneCode
			,TimeZoneRuleVersionNumber
			,OverriddenCreatedOn
			,ActualValue_Base
			,EstimatedValue_Base
			,TotalDiscountAmount
			,ModifiedOnBehalfBy
			,TotalAmount
			,CreatedOnBehalfBy
			,TotalAmountLessFreight
			,TotalLineItemDiscountAmount
			,CustomerId
			,DiscountAmount
			,OwnerId
			,FreightAmount
			,TotalTax
			,DiscountPercentage
			,TotalLineItemAmount
			,CustomerIdName
			,CustomerIdType
			,OwnerIdType
			,TotalDiscountAmount_Base
			,FreightAmount_Base
			,TotalLineItemAmount_Base
			,TotalTax_Base
			,TotalLineItemDiscountAmount_Base
			,TotalAmount_Base
			,DiscountAmount_Base
			,TotalAmountLessFreight_Base
			,CustomerIdYomiName
			,vth_PrimaryContactId
			,vth_CustomerPO
			,vth_Department
			,vth_OpportunityNumber
			,vth_Type
			,vth_Source
			,vth_Competitor
			,vth_TerritoryId
			,vth_ProductBrand
			,vth_ProductModel
			,vth_Probability
) 

select --top 100
			 OpportunityId = NEWID()--uniqueidentifier primary key
			,PriceLevelId = null
			,OpportunityRatingCode = null
			,PriorityCode = null
			,Name = cast(SLS.vchDesc1 as nvarchar(600))--nvarchar(600)
			,StepId = null
			,Description = cast(SLS.vchDesc1 as nvarchar(200)) --nvarchar(200)
			,EstimatedValue = null
			,StepName = null
			,SalesStageCode = null
			,ParticipatesInWorkflow = null
			,PricingErrorCode = null
			,EstimatedCloseDate = null--datetime
			,CloseProbability = null--int
			,ActualValue = null--money
			,ActualCloseDate = null--datetime
			,OwningBusinessUnit = null
			,OriginatingLeadId = null--uniqueidentifier
			,CreatedOn = SLS.dtInsertDate --datetime
			,IsPrivate = null--bit
			,CreatedBy = U1.SystemUserId
			,ModifiedOn = SLS.dtUpdateDate --datetime
			,ModifiedBy = U2.SystemUserId
			,VersionNumber = null
			,StateCode = null
			,StatusCode = SLS.iStatusId--int
			,IsRevenueSystemCalculated = null
			,CampaignId = null
			,TransactionCurrencyId = null
			,ExchangeRate = null
			,ImportSequenceNumber = null
			,UTCConversionTimeZoneCode = null
			,TimeZoneRuleVersionNumber = null
			,OverriddenCreatedOn = null
			,ActualValue_Base = null
			,EstimatedValue_Base = null
			,TotalDiscountAmount = null
			,ModifiedOnBehalfBy = null
			,TotalAmount = null
			,CreatedOnBehalfBy = null
			,TotalAmountLessFreight = null
			,TotalLineItemDiscountAmount = null
			,CustomerId = C2.AccountId--uniqueidentifier
			,DiscountAmount = null
			,OwnerId = null--uniqueidentifier
			,FreightAmount = null
			,TotalTax = null
			,DiscountPercentage = null
			,TotalLineItemAmount = null
			,CustomerIdName = C.vchCompanyName --nvarchar(200)
			,CustomerIdType = C.iCompanyTypeCode --int
			,OwnerIdType = null--int
			,TotalDiscountAmount_Base = null
			,FreightAmount_Base = null
			,TotalLineItemAmount_Base = null
			,TotalTax_Base = null
			,TotalLineItemDiscountAmount_Base = null
			,TotalAmount_Base = null
			,DiscountAmount_Base = null
			,TotalAmountLessFreight_Base = null
			,CustomerIdYomiName = null
			,vth_PrimaryContactId = CON.ContactId --uniqueidentifier
			,vth_CustomerPO = SLS.vchUser5 --nvarchar(200)
			,vth_Department = null --SLS.vchUser10 --int
			,vth_OpportunityNumber = SLS.iIncidentId --int
			,vth_Type = SLS.iIncidentTypeId --int
			,vth_Source = SLS.iSourceId --int
			,vth_Competitor = null --SLS.vchUser1 --bit
			,vth_TerritoryId = null --uniqueidentifier
			,vth_ProductBrand = null --SLS.vchProductId --int
			,vth_ProductModel = null --SLS.vchProductId --int
			,vth_Probability = null --int
--select top 10 *
from		 Onyx..Incident SLS WITH (NOLOCK)
			 join Onyx..Company C WITH (NOLOCK)
				on SLS.iOwnerID = C.iCompanyId
			 join Company C2 WITH (NOLOCK)
				on C.iCompanyId = C2.AccountNumber
			 left join Onyx..NetWorkUser CB WITH (NOLOCK)
				on SLS.chInsertBy = CB.chUserId 
			 left join Users U1 WITH (NOLOCK)
				on ltrim(rtrim(CB.vchNetWorkUser)) = ltrim(rtrim(U1.DomainName))
			 left join Onyx..NetWorkUser UB WITH (NOLOCK)
				on SLS.chUpdateBy = UB.chUserId
			 left join Users U2 WITH (NOLOCK)
				on ltrim(rtrim(UB.vchNetWorkUser)) = ltrim(rtrim(U2.DomainName))
			 left join Contact CON WITH (NOLOCK)
				on sls.iContactId = CON.vth_contactNumber
where		 SLS.tiRecordStatus = 1
			 and SLS.iIncidentCategory = 3 --sales
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

