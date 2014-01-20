USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[PriceListItem]') IS NOT NULL

DROP TABLE [dbo].[PriceListItem]
GO
BEGIN
CREATE TABLE [dbo].[PriceListItem](
	[PriceLevelId] [uniqueidentifier] null,
	[ProductPriceLevelId] [uniqueidentifier] null DEFAULT(NEWID()),
	
[UoMId] [uniqueidentifier],
[UoMScheduleId] [uniqueidentifier],
[DiscountTypeId] [uniqueidentifier],
[ProductId] [uniqueidentifier],
[Percentage] [decimal],
[Amount] [money],
[CreatedOn] [datetime],
[QuantitySellingCode] [int],
[RoundingPolicyCode] [int],
[ModifiedOn] [datetime],
[PricingMethodCode] [int],
[RoundingOptionCode] [int],
[RoundingOptionAmount] [money],
[VersionNumber] [timestamp],
[CreatedBy] [uniqueidentifier],
[ModifiedBy] [uniqueidentifier],
[ExchangeRate] [decimal],
[TransactionCurrencyId] [uniqueidentifier],
[OverriddenCreatedOn] [datetime],
[ImportSequenceNumber] [int],
[Amount_Base] [money],
[RoundingOptionAmount_Base] [money],
[ModifiedOnBehalfBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[organizationid] [uniqueidentifier]
)
END
