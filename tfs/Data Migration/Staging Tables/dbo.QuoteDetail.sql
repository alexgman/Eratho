USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[QuoteProduct]') IS NOT NULL

DROP TABLE [dbo].[QuoteProduct]
GO
BEGIN
CREATE TABLE [dbo].[QuoteProduct](
	[QuoteDetailId] [uniqueidentifier] null DEFAULT(NEWID()),
	[QuoteId] [uniqueidentifier] null,
	[SalesRepId] [uniqueidentifier] NULL,
	[LineItemNumber] [int] NULL,
	[UoMId] [uniqueidentifier] NULL,
	[ProductId] [uniqueidentifier] NULL,
	[RequestDeliveryBy] [datetime] NULL,
	[Quantity] [decimal](23, 10) NULL,
	[PricingErrorCode] [int] NULL,
	[ManualDiscountAmount] [money] NULL,
	[ProductDescription] [nvarchar](500) NULL,
	[VolumeDiscountAmount] [money] NULL,
	[PricePerUnit] [money] NULL,
	[BaseAmount] [money] NULL,
	[ExtendedAmount] [money] NULL,
	[Description] [nvarchar](max) NULL,
	[ShipTo_Name] [nvarchar](200) NULL,
	[IsPriceOverridden] [bit] NULL,
	[Tax] [money] NULL,
	[ShipTo_Line1] [nvarchar](4000) NULL,
	[CreatedOn] [datetime] NULL,
	[ShipTo_Line2] [nvarchar](4000) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ShipTo_Line3] [nvarchar](4000) NULL,
	[ShipTo_City] [nvarchar](50) NULL,
	[ModifiedOn] [datetime] NULL,
	[ShipTo_StateOrProvince] [nvarchar](50) NULL,
	[ShipTo_Country] [nvarchar](50) NULL,
	[ShipTo_PostalCode] [nvarchar](20) NULL,
	[WillCall] [bit] NULL,
	[IsProductOverridden] [bit] NULL,
	[ShipTo_Telephone] [nvarchar](50) NULL,
	[ShipTo_Fax] [nvarchar](50) NULL,
	[ShipTo_FreightTermsCode] [int] NULL,
	[ShipTo_AddressId] [uniqueidentifier] NULL,
	[ShipTo_ContactName] [nvarchar](150) NULL,
	[VersionNumber] [timestamp] NULL,
	[ImportSequenceNumber] [int] NULL,
	[UTCConversionTimeZoneCode] [int] NULL,
	[OverriddenCreatedOn] [datetime] NULL,
	[TransactionCurrencyId] [uniqueidentifier] NULL,
	[ExchangeRate] [decimal](23, 10) NULL,
	[TimeZoneRuleVersionNumber] [int] NULL,
	[Tax_Base] [money] NULL,
	[ExtendedAmount_Base] [money] NULL,
	[PricePerUnit_Base] [money] NULL,
	[BaseAmount_Base] [money] NULL,
	[ManualDiscountAmount_Base] [money] NULL,
	[VolumeDiscountAmount_Base] [money] NULL,
	[ModifiedOnBehalfBy] [uniqueidentifier] NULL,
	[CreatedOnBehalfBy] [uniqueidentifier] NULL,
	
	[RowAction] [nvarchar](25) NULL,
	
[vth_DiscountType] [int],
[vth_ProductDescription] [nvarchar](200),
[vth_DiscountPercent] [decimal],
[vth_VerathonRefId][int]

	)END