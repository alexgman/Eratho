USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[PriceListItemDetail]') IS NOT NULL

DROP TABLE [dbo].[PriceListItemDetail]
GO
BEGIN
CREATE TABLE [dbo].[PriceListItemDetail](
[vth_pricelistitemdetailId] [uniqueidentifier],
[CreatedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[ModifiedBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[OrganizationId] [uniqueidentifier],
[statecode] [int],
[statuscode] [int],
[VersionNumber] [timestamp],
[ImportSequenceNumber] [int],
[OverriddenCreatedOn] [datetime],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],
[TransactionCurrencyId] [uniqueidentifier],
[ExchangeRate] [decimal],
[vth_name] [nvarchar](200),
[vth_ProductId] [uniqueidentifier],
[vth_PriceListId] [uniqueidentifier],
[vth_ProductEntityid] [int],

[vth_MinimumPrice] [money],
[vth_minimumprice_Base] [money],



	

)END