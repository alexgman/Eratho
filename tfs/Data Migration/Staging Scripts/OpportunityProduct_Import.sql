USE CRM_Staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OpportunityProduct_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	OpportunityProduct_Import
** Description:	Insert/Update OpportunityProduct from Onyx Quote Header and Quote Details tables into MSCRM 
**
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-17		BrianD			Initial Creation
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
		TRUNCATE TABLE CRM_Staging.dbo.OpportunityProduct
		INSERT INTO CRM_Staging.dbo.OpportunityProduct(
			 ProductId
			,OpportunityProductId
			,PricingErrorCode
			,IsProductOverridden
			,IsPriceOverridden
			,PricePerUnit
			,OpportunityId
			,BaseAmount
			,ExtendedAmount
			,UoMId
			,ManualDiscountAmount
			,Quantity
			,CreatedOn
			,VolumeDiscountAmount
			,CreatedBy
			,Tax
			,ModifiedBy
			,ProductDescription
			,ModifiedOn
			,Description
			--,VersionNumber
			,OverriddenCreatedOn
			,UTCConversionTimeZoneCode
			,TimeZoneRuleVersionNumber
			,ImportSequenceNumber
			,ExchangeRate
			,TransactionCurrencyId
			,BaseAmount_Base
			,ManualDiscountAmount_Base
			,VolumeDiscountAmount_Base
			,PricePerUnit_Base
			,Tax_Base
			,ExtendedAmount_Base
			,CreatedOnBehalfBy
			,ModifiedOnBehalfBy
			,LineItemNumber
			,vth_DiscountType
			,vth_DiscountPercent
)

select --top 100
			 ProductId = null --uniqueidentifier
			,OpportunityProductId = newid() --uniqueidentifier
			,PricingErrorCode = null --int
			,IsProductOverridden = null --bit
			,IsPriceOverridden = null --bit
			,PricePerUnit = QD.flUnitPrice --money
			,OpportunityId = SO.OpportunityId --uniqueidentifier
			,BaseAmount = null --money
			,ExtendedAmount = case
							  when QD.iDiscountTypeId = 101879 --discount amount
								   or QD.iDiscountTypeId = 101645 --Trade-In
							  then QD.flQuantity * (QD.flUnitPrice - QD.flDiscount) 
							  when QD.iDiscountTypeId = 101878 then QD.flQuantity * QD.flUnitPrice * (1 - QD.flDiscount/100.0) --discount percent
							  else QD.flQuantity * QD.flUnitPrice
							  end  --money
			,UoMId = null --uniqueidentifier
			,ManualDiscountAmount = case when QD.iDiscountTypeId = 101879 then QD.flDiscount else null end --money
			,Quantity = QD.flQuantity --decimal(18,0)
			,CreatedOn = QD.dtInsertDate --datetime
			,VolumeDiscountAmount = null --money
			,CreatedBy = U1.SystemUserId --uniqueidentifier
			,Tax = null --money
			,ModifiedBy = U2.SystemUserId --uniqueidentifier
			,ProductDescription = ltrim(rtrim(QD.chProductNumber)) + ' - ' + ltrim(rtrim(QD.vchDescription)) --nvarchar(1000)
			,ModifiedOn = QD.dtUpdateDate --datetime
			,Description = null --nvarchar(200)
			--,VersionNumber = null --timestamp
			,OverriddenCreatedOn = null --datetime
			,UTCConversionTimeZoneCode = null --int
			,TimeZoneRuleVersionNumber = null --int
			,ImportSequenceNumber = null --int
			,ExchangeRate = null --decimal(18,0)
			,TransactionCurrencyId = null --uniqueidentifier
			,BaseAmount_Base = null --money
			,ManualDiscountAmount_Base = null --money
			,VolumeDiscountAmount_Base = null --money
			,PricePerUnit_Base = null --money
			,Tax_Base = null --money
			,ExtendedAmount_Base = null --money
			,CreatedOnBehalfBy = null --uniqueidentifier
			,ModifiedOnBehalfBy = null --uniqueidentifier
			,LineItemNumber = QD.iLineNumberId --int
			,vth_DiscountType = QD.iDiscountTypeId --int
			,vth_DiscountPercent = case when QD.iDiscountTypeId = 101878 then QD.flDiscount else null end  --decimal(18,0)

--select top 10 *
from		 Onyx..QuoteHeader QH WITH (NOLOCK)
			 inner join Onyx..QuoteDetail QD WITH (NOLOCK)
				on QH.iQuoteId = QD.iQuoteId
			 inner join dbo.Opportunity SO WITH (NOLOCK)
				on QH.iSystemId = vth_OpportunityNumber
			 left join Onyx..NetWorkUser CB WITH (NOLOCK)
				on QD.chInsertBy = CB.chUserId 
			 left join Users U1 WITH (NOLOCK)
				on ltrim(rtrim(CB.vchNetWorkUser)) = ltrim(rtrim(U1.DomainName))
			 left join Onyx..NetWorkUser UB WITH (NOLOCK)
				on QD.chUpdateBy = UB.chUserId
			 left join Users U2 WITH (NOLOCK)
				on ltrim(rtrim(UB.vchNetWorkUser)) = ltrim(rtrim(U2.DomainName))
where		QH.tiRecordStatus = 1
			and QH.iQuotecategory = 1 --Forecast
			and QD.tiRecordStatus = 1



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

