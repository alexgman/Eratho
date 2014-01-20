USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CREATE TABLE [dbo].[PriceList]') IS NOT NULL

DROP TABLE [dbo].[CREATE TABLE [dbo].[PriceList]
GO
BEGIN

CREATE TABLE [dbo].[PriceList](
	[PriceLevelId] [uniqueidentifier] null DEFAULT(NEWID()),
	[OrganizationId] [uniqueidentifier] null,
	[Name] [nvarchar](100) null,
	
[Description] [nvarchar](200),
[ShippingMethodCode] [int],
[BeginDate] [datetime],
[PaymentMethodCode] [int],
[FreightTermsCode] [int],
[EndDate] [datetime],
[CreatedBy] [uniqueidentifier],
[CreatedOn] [datetime],
[ModifiedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[StateCode] [int],
[VersionNumber] [timestamp],
[StatusCode] [int],
[ImportSequenceNumber] [int],
[TransactionCurrencyId] [uniqueidentifier],
[OverriddenCreatedOn] [datetime],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],
[ModifiedOnBehalfBy] [uniqueidentifier],
[ExchangeRate] [decimal],
[CreatedOnBehalfBy] [uniqueidentifier],
[vth_visualbusinessentity] [int],
[vth_VerathonRefId][nvarchar](100)



	
	
	
	)END