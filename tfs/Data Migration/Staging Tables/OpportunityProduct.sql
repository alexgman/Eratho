USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[OpportunityProduct]') IS NOT NULL

DROP TABLE [dbo].[OpportunityProduct]
GO
BEGIN
CREATE TABLE [dbo].[OpportunityProduct](
[ProductId] [uniqueidentifier] null,
[OpportunityProductId] [uniqueidentifier] null,
[PricingErrorCode] [int],
[IsProductOverridden] [bit],
[IsPriceOverridden] [bit],
[PricePerUnit] [money],
[OpportunityId] [uniqueidentifier] null,
[BaseAmount] [money],
[ExtendedAmount] [money],
[UoMId] [uniqueidentifier] null,
[ManualDiscountAmount] [money],
[Quantity] [decimal] null,
[CreatedOn] [datetime],
[VolumeDiscountAmount] [money],
[CreatedBy] [uniqueidentifier],
[Tax] [money],
[ModifiedBy] [uniqueidentifier],
[ProductDescription] [nvarchar](1000),
[ModifiedOn] [datetime],
[Description] [nvarchar](200),
[VersionNumber] [timestamp],
[OverriddenCreatedOn] [datetime],
[UTCConversionTimeZoneCode] [int],
[TimeZoneRuleVersionNumber] [int],
[ImportSequenceNumber] [int],
[ExchangeRate] [decimal],
[TransactionCurrencyId] [uniqueidentifier],
[BaseAmount_Base] [money],
[ManualDiscountAmount_Base] [money],
[VolumeDiscountAmount_Base] [money],
[PricePerUnit_Base] [money],
[Tax_Base] [money],
[ExtendedAmount_Base] [money],
[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[LineItemNumber] [int],

[vth_DiscountType] [int],
[vth_DiscountPercent] [decimal],
[vth_VerathonRefId][int]




)END