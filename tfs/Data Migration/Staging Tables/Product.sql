
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Product]') IS NOT NULL

DROP TABLE [dbo].[Product]
GO
BEGIN
CREATE TABLE [dbo].[Product](
	[ProductId] [uniqueidentifier] null DEFAULT(NEWID()),
	[DefaultUoMScheduleId] [uniqueidentifier] NULL,
	[SubjectId] [uniqueidentifier] NULL,
	[OrganizationId] [uniqueidentifier] null,
	[Name] [nvarchar](100) NULL,
	[DefaultUoMId] [uniqueidentifier],
[PriceLevelId] [uniqueidentifier],
[Description] [nvarchar](200),
[ProductTypeCode] [int],
[ProductUrl] [nvarchar](510),
[Price] [money],
[IsKit] [bit],
[ProductNumber] [nvarchar](200),
[Size] [nvarchar](400),
[CurrentCost] [money],
[StockVolume] [decimal],
[StandardCost] [money],
[StockWeight] [decimal],
[QuantityDecimal] [int],
[QuantityOnHand] [decimal],
[IsStockItem] [bit],
[SupplierName] [nvarchar](200),
[VendorName] [nvarchar](200),
[VendorPartNumber] [nvarchar](200),
[CreatedOn] [datetime],
[ModifiedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[StateCode] [int],
[ModifiedBy] [uniqueidentifier],
[StatusCode] [int],
[VersionNumber] [timestamp],
[OverriddenCreatedOn] [datetime],
[TransactionCurrencyId] [uniqueidentifier],
[ExchangeRate] [decimal],
[UTCConversionTimeZoneCode] [int],
[ImportSequenceNumber] [int],
[TimeZoneRuleVersionNumber] [int],
[CurrentCost_Base] [money],
[Price_Base] [money],
[StandardCost_Base] [money],
[ModifiedOnBehalfBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[vth_ProductFamily] [int],
[vth_ProductModel] [int],
[vth_productbrand][int],
[vth_WarrantyProduct][Bit],
[vth_length][decimal],
[vth_width][decimal],
[vth_heieght][decimal],
[vth_shippingweight][decimal],
[vth_canhavewarranty][bit],
[vth_consolidate][Bit]
)


END

