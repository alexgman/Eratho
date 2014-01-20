USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[OrderProduct]') IS NOT NULL

DROP TABLE [dbo].[OrderProduct]
GO
BEGIN
CREATE TABLE [dbo].[OrderProduct](

[SalesOrderDetailId] [uniqueidentifier] null,
[SalesOrderId] [uniqueidentifier],
[SalesRepId] [uniqueidentifier],
[IsProductOverridden] [bit],
[IsCopied] [bit],
[QuantityShipped] [decimal],
[LineItemNumber] [int],
[QuantityBackordered] [decimal],
[UoMId] [uniqueidentifier],
[QuantityCancelled] [decimal],
[ProductId] [uniqueidentifier],
[RequestDeliveryBy] [datetime],
[Quantity] [decimal],
[PricingErrorCode] [int],
[ManualDiscountAmount] [money],
[ProductDescription] [nvarchar](1000),
[VolumeDiscountAmount] [money],
[PricePerUnit] [money],
[BaseAmount] [money],
[ExtendedAmount] [money],
[Description] [nvarchar](200),
[IsPriceOverridden] [bit],
[ShipTo_Name] [nvarchar](400),
[Tax] [money],
[CreatedOn] [datetime],
[ShipTo_Line1] [nvarchar](800),
[CreatedBy] [uniqueidentifier],
[ModifiedBy] [uniqueidentifier],
[ShipTo_Line2] [nvarchar](800),
[ShipTo_Line3] [nvarchar](800),
[ModifiedOn] [datetime],
[ShipTo_City] [nvarchar](160),
[ShipTo_StateOrProvince] [nvarchar](100),
[ShipTo_Country] [nvarchar](160),
[ShipTo_PostalCode] [nvarchar](40),
[WillCall] [bit],
[ShipTo_Telephone] [nvarchar](100),
[ShipTo_Fax] [nvarchar](100),
[ShipTo_FreightTermsCode] [int],
[ShipTo_ContactName] [nvarchar](300),
[VersionNumber] [timestamp],
[ShipTo_AddressId] [uniqueidentifier],
[TimeZoneRuleVersionNumber] [int],
[ImportSequenceNumber] [int],
[UTCConversionTimeZoneCode] [int],
[ExchangeRate] [decimal],
[OverriddenCreatedOn] [datetime],
[TransactionCurrencyId] [uniqueidentifier],
[BaseAmount_Base] [money],
[PricePerUnit_Base] [money],
[VolumeDiscountAmount_Base] [money],
[ExtendedAmount_Base] [money],
[Tax_Base] [money],
[ManualDiscountAmount_Base] [money],
[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],

[vth_WarrantyStart] [datetime],
[vth_WarrantyEnd] [datetime],
[vth_TaxGroup] [nvarchar](200),
[vth_Serial1] [nvarchar](200),
[vth_Serial2] [nvarchar](200),
[vth_VerathonRefId][int]



)END