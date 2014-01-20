USE CRM_Staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Quote_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	Quote_Import
** Description:	Insert/Update Quote from Onyx Quote Header table into MSCRM ContactBase 
**
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-11		BrianD			Initial Creation
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
		TRUNCATE TABLE CRM_Staging.dbo.Quote
		INSERT INTO CRM_Staging.dbo.Quote(
			 QuoteId
			,OwningBusinessUnit
			,PriceLevelId
			,OpportunityId
			,QuoteNumber
			,RevisionNumber
			,Name
			,PricingErrorCode
			,Description
			,DiscountAmount
			,FreightAmount
			,TotalAmount
			,TotalLineItemAmount
			,TotalLineItemDiscountAmount
			,TotalAmountLessFreight
			,EffectiveFrom
			,TotalTax
			,TotalDiscountAmount
			,EffectiveTo
			,ExpiresOn
			,ClosedOn
			,RequestDeliveryBy
			,ShippingMethodCode
			,PaymentTermsCode
			,FreightTermsCode
			,CreatedBy
			,CreatedOn
			,ModifiedBy
			,ModifiedOn
			,StateCode
			,StatusCode
			,ShipTo_Name
			--,VersionNumber
			,ShipTo_Line1
			,ShipTo_Line2
			,ShipTo_Line3
			,ShipTo_City
			,ShipTo_StateOrProvince
			,ShipTo_Country
			,ShipTo_PostalCode
			,WillCall
			,ShipTo_Telephone
			,BillTo_Name
			,ShipTo_FreightTermsCode
			,ShipTo_Fax
			,BillTo_Line1
			,BillTo_Line2
			,BillTo_Line3
			,BillTo_City
			,BillTo_StateOrProvince
			,BillTo_Country
			,BillTo_PostalCode
			,BillTo_Telephone
			,BillTo_Fax
			,DiscountPercentage
			,CampaignId
			,ShipTo_AddressId
			,ShipTo_ContactName
			,BillTo_AddressId
			,BillTo_ContactName
			,TimeZoneRuleVersionNumber
			,UniqueDscId
			,ImportSequenceNumber
			,ExchangeRate
			,OverriddenCreatedOn
			,UTCConversionTimeZoneCode
			,TransactionCurrencyId
			,TotalLineItemDiscountAmount_Base
			,TotalAmountLessFreight_Base
			,DiscountAmount_Base
			,FreightAmount_Base
			,TotalAmount_Base
			,TotalDiscountAmount_Base
			,TotalTax_Base
			,TotalLineItemAmount_Base
			,CreatedOnBehalfBy
			,OwnerId
			,ModifiedOnBehalfBy
			,CustomerId
			,OwnerIdType
			,CustomerIdName
			,CustomerIdType
			,CustomerIdYomiName
			,vth_PrimaryContactId
			,vth_BillToCompanyId
			,vth_ShipToCompanyId
			,vth_billtocontactid
			,vth_shiptocontactid
)

select --top 100
			 QuoteId = newid() --uniqueidentifier
			,OwningBusinessUnit = null --uniqueidentifier
			,PriceLevelId = null --uniqueidentifier
			,OpportunityId = SO.OpportunityId --uniqueidentifier
			,QuoteNumber = QH.iQuoteId --nvarchar(200)
			,RevisionNumber = null --int
			,Name = ltrim(rtrim(QH.vchName)) --nvarchar(600)
			,PricingErrorCode = null --int
			,Description = ltrim(rtrim(QH.vchComment)) --nvarchar(200)
			,DiscountAmount = null --money
			,FreightAmount = null --money
			,TotalAmount = null --money
			,TotalLineItemAmount = null --money
			,TotalLineItemDiscountAmount = null --money
			,TotalAmountLessFreight = null --money
			,EffectiveFrom = QH.dtCreateDate --datetime
			,TotalTax = null --money
			,TotalDiscountAmount = null --money
			,EffectiveTo = QH.dtExpirationDate --datetime
			,ExpiresOn = QH.dtExpirationDate --datetime
			,ClosedOn = QH.dtCloseDate --datetime
			,RequestDeliveryBy = null --datetime
			,ShippingMethodCode = null --int
			,PaymentTermsCode = null --int
			,FreightTermsCode = null --int
			,CreatedBy = U1.SystemUserId --uniqueidentifier
			,CreatedOn = QH.dtInsertDate --datetime
			,ModifiedBy = U2.SystemUserId --uniqueidentifier
			,ModifiedOn = QH.dtUpdateDate --datetime
			,StateCode = null --int
			,StatusCode = QH.iStatusId --int
			,ShipTo_Name = null --nvarchar(400)
			--,VersionNumber = null --timestamp
			,ShipTo_Line1 = null --nvarchar(800)
			,ShipTo_Line2 = null --nvarchar(800)
			,ShipTo_Line3 = null --nvarchar(800)
			,ShipTo_City = null --nvarchar(160)
			,ShipTo_StateOrProvince = null --nvarchar(100)
			,ShipTo_Country = null --nvarchar(160)
			,ShipTo_PostalCode = null --nvarchar(40)
			,WillCall = null --bit
			,ShipTo_Telephone = null --nvarchar(100)
			,BillTo_Name = null --nvarchar(400)
			,ShipTo_FreightTermsCode = null --int
			,ShipTo_Fax = null --nvarchar(100)
			,BillTo_Line1 = null --nvarchar(800)
			,BillTo_Line2 = null --nvarchar(800)
			,BillTo_Line3 = null --nvarchar(800)
			,BillTo_City = null --nvarchar(160)
			,BillTo_StateOrProvince = null --nvarchar(100)
			,BillTo_Country = null --nvarchar(160)
			,BillTo_PostalCode = null --nvarchar(40)
			,BillTo_Telephone = null --nvarchar(100)
			,BillTo_Fax = null --nvarchar(100)
			,DiscountPercentage = null --decimal(18,0)
			,CampaignId = null --uniqueidentifier
			,ShipTo_AddressId = null --uniqueidentifier
			,ShipTo_ContactName = null --nvarchar(300)
			,BillTo_AddressId = null --uniqueidentifier
			,BillTo_ContactName = null --nvarchar(300)
			,TimeZoneRuleVersionNumber = null --int
			,UniqueDscId = null --uniqueidentifier
			,ImportSequenceNumber = null --int
			,ExchangeRate = null --decimal(18,0)
			,OverriddenCreatedOn = null --datetime
			,UTCConversionTimeZoneCode = null --int
			,TransactionCurrencyId = null --uniqueidentifier
			,TotalLineItemDiscountAmount_Base = null --money
			,TotalAmountLessFreight_Base = null --money
			,DiscountAmount_Base = null --money
			,FreightAmount_Base = null --money
			,TotalAmount_Base = null --money
			,TotalDiscountAmount_Base = null --money
			,TotalTax_Base = null --money
			,TotalLineItemAmount_Base = null --money
			,CreatedOnBehalfBy = null --uniqueidentifier
			,OwnerId = null --uniqueidentifier
			,ModifiedOnBehalfBy = null --uniqueidentifier
			,CustomerId = SO.CustomerId --uniqueidentifier
			,OwnerIdType = null --int
			,CustomerIdName = SO.CustomerIdName --nvarchar(800)
			,CustomerIdType = SO.CustomerIdType  --int
			,CustomerIdYomiName = null --nvarchar(800)
			,vth_PrimaryContactId = SO.vth_PrimaryContactId --uniqueidentifier
			,vth_BillToCompanyId = null --uniqueidentifier
			,vth_ShipToCompanyId = null --uniqueidentifier
			,vth_billtocontactid = null --uniqueidentifier
			,vth_shiptocontactid = null --uniqueidentifier
--select top 100
from		 Onyx..QuoteHeader QH WITH (NOLOCK)
			 inner join dbo.Opportunity SO WITH (NOLOCK)
				on QH.iSystemId = vth_OpportunityNumber
			 left join Onyx..NetWorkUser CB WITH (NOLOCK)
				on QH.chInsertBy = CB.chUserId 
			 left join Users U1 WITH (NOLOCK)
				on ltrim(rtrim(CB.vchNetWorkUser)) = ltrim(rtrim(U1.DomainName))
			 left join Onyx..NetWorkUser UB WITH (NOLOCK)
				on QH.chUpdateBy = UB.chUserId
			 left join Users U2 WITH (NOLOCK)
				on ltrim(rtrim(UB.vchNetWorkUser)) = ltrim(rtrim(U2.DomainName))
where QH.tiRecordStatus = 1
	  and QH.iQuotecategory = 2 --Quote


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

