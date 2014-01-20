USE CRM_Staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[QuoteProduct_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	QuoteProduct_Import
** Description:	Insert/Update QuoteProduct from Onyx Quote Header and Quote Details tables into MSCRM 
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
		TRUNCATE TABLE CRM_Staging.dbo.QuoteProduct
		INSERT INTO CRM_Staging.dbo.QuoteProduct(
			 QuoteDetailId
			,QuoteId
			,SalesRepId
			,LineItemNumber
			,UoMId
			,ProductId
			,RequestDeliveryBy
			,Quantity
			,PricingErrorCode
			,ManualDiscountAmount
			,ProductDescription
			,VolumeDiscountAmount
			,PricePerUnit
			,BaseAmount
			,ExtendedAmount
			,Description
			,ShipTo_Name
			,IsPriceOverridden
			,Tax
			,ShipTo_Line1
			,CreatedOn
			,ShipTo_Line2
			,CreatedBy
			,ModifiedBy
			,ShipTo_Line3
			,ShipTo_City
			,ModifiedOn
			,ShipTo_StateOrProvince
			,ShipTo_Country
			,ShipTo_PostalCode
			,WillCall
			,IsProductOverridden
			,ShipTo_Telephone
			,ShipTo_Fax
			,ShipTo_FreightTermsCode
			,ShipTo_AddressId
			,ShipTo_ContactName
			--,VersionNumber
			,ImportSequenceNumber
			,UTCConversionTimeZoneCode
			,OverriddenCreatedOn
			,TransactionCurrencyId
			,ExchangeRate
			,TimeZoneRuleVersionNumber
			,Tax_Base
			,ExtendedAmount_Base
			,PricePerUnit_Base
			,BaseAmount_Base
			,ManualDiscountAmount_Base
			,VolumeDiscountAmount_Base
			,ModifiedOnBehalfBy
			,CreatedOnBehalfBy
			,RowAction
			,vth_DiscountType
			,vth_ProductDescription
			,vth_DiscountPercent
)

select --top 100
			 QuoteDetailId = newid() --uniqueidentifier
			,QuoteId = Q.QuoteId --uniqueidentifier
			,SalesRepId = null --uniqueidentifier
			,LineItemNumber = QD.iLineNumberId --int
			,UoMId = null --uniqueidentifier
			,ProductId = null --uniqueidentifier
			,RequestDeliveryBy = null --datetime
			,Quantity = QD.flQuantity --decimal(23,10)
			,PricingErrorCode = null --int
			,ManualDiscountAmount = case when QD.iDiscountTypeId = 101879 then QD.flDiscount else null end --money
			,ProductDescription = ltrim(rtrim(QD.chProductNumber)) + ' - ' + ltrim(rtrim(QD.vchDescription)) --nvarchar(500)
			,VolumeDiscountAmount = null --money
			,PricePerUnit = QD.flUnitPrice --money
			,BaseAmount = null --money
			,ExtendedAmount = case
							  when QD.iDiscountTypeId = 101879
								   or QD.iDiscountTypeId = 101645 --Trade-In
							  then QD.flQuantity * (QD.flUnitPrice - QD.flDiscount) --discount amount
							  when QD.iDiscountTypeId = 101878 then QD.flQuantity * QD.flUnitPrice * (1 - QD.flDiscount/100.0) --discount percent
							  else QD.flQuantity * QD.flUnitPrice
							  end  --money
			,Description = null --nvarchar(max)
			,ShipTo_Name = null --nvarchar(200)
			,IsPriceOverridden = null --bit
			,Tax = null --money
			,ShipTo_Line1 = null --nvarchar(4000)
			,CreatedOn = QD.dtInsertDate --datetime
			,ShipTo_Line2 = null --nvarchar(4000)
			,CreatedBy = U1.SystemUserId --uniqueidentifier
			,ModifiedBy = U2.SystemUserId --uniqueidentifier
			,ShipTo_Line3 = null --nvarchar(4000)
			,ShipTo_City = null --nvarchar(50)
			,ModifiedOn = QD.dtUpdateDate --datetime
			,ShipTo_StateOrProvince = null --nvarchar(50)
			,ShipTo_Country = null --nvarchar(50)
			,ShipTo_PostalCode = null --nvarchar(20)
			,WillCall = null --bit
			,IsProductOverridden = null --bit
			,ShipTo_Telephone = null --nvarchar(50)
			,ShipTo_Fax = null --nvarchar(50)
			,ShipTo_FreightTermsCode = null --int
			,ShipTo_AddressId = null --uniqueidentifier
			,ShipTo_ContactName = null --nvarchar(150)
			--,VersionNumber = null --timestamp
			,ImportSequenceNumber = null --int
			,UTCConversionTimeZoneCode = null --int
			,OverriddenCreatedOn = null --datetime
			,TransactionCurrencyId = null --uniqueidentifier
			,ExchangeRate = null --decimal(23,10)
			,TimeZoneRuleVersionNumber = null --int
			,Tax_Base = null --money
			,ExtendedAmount_Base = null --money
			,PricePerUnit_Base = null --money
			,BaseAmount_Base = null --money
			,ManualDiscountAmount_Base = null --money
			,VolumeDiscountAmount_Base = null --money
			,ModifiedOnBehalfBy = null --uniqueidentifier
			,CreatedOnBehalfBy = null --uniqueidentifier
			,RowAction = null --nvarchar(25)
			,vth_DiscountType = QD.iDiscountTypeId --int
			,vth_ProductDescription = ltrim(rtrim(QD.chProductNumber)) + ' - ' + ltrim(rtrim(QD.vchDescription)) --nvarchar(200)
			,vth_DiscountPercent = case when QD.iDiscountTypeId = 101878 then QD.flDiscount else null end --decimal(18,0)
--select top 10 *
from		 Onyx..QuoteHeader QH WITH (NOLOCK)
			 inner join Onyx..QuoteDetail QD WITH (NOLOCK)
				on QH.iQuoteId = QD.iQuoteId
			 inner join Quote Q WITH (NOLOCK)
				on QH.iQuoteId = Q.QuoteNumber
			 left join Onyx..NetWorkUser CB WITH (NOLOCK)
				on QH.chInsertBy = CB.chUserId 
			 left join Users U1 WITH (NOLOCK)
				on ltrim(rtrim(CB.vchNetWorkUser)) = ltrim(rtrim(U1.DomainName))
			 left join Onyx..NetWorkUser UB WITH (NOLOCK)
				on QH.chUpdateBy = UB.chUserId
			 left join Users U2 WITH (NOLOCK)
				on ltrim(rtrim(UB.vchNetWorkUser)) = ltrim(rtrim(U2.DomainName))
where		QH.tiRecordStatus = 1
			and QH.iQuotecategory = 2 --Quote
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

