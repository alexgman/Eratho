USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CustomerProduct]') IS NOT NULL

DROP TABLE [dbo].[CustomerProduct]
GO
BEGIN
CREATE TABLE [dbo].[CustomerProduct](
	[vth_customerproductId] [uniqueidentifier] null DEFAULT(NEWID()),
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[CreatedOnBehalfBy] [uniqueidentifier] NULL,
	[ModifiedOnBehalfBy] [uniqueidentifier] NULL,
	[OwnerId] [uniqueidentifier] null,
	[OwnerIdType] [int] null,
	[OwningBusinessUnit] [uniqueidentifier] NULL,
	[statecode] [int] null,
	[statuscode] [int] NULL,
	[VersionNumber] [timestamp] NULL,
	[ImportSequenceNumber] [int] NULL,
	[OverriddenCreatedOn] [datetime] NULL,
	[TimeZoneRuleVersionNumber] [int] NULL,
	[UTCConversionTimeZoneCode] [int] NULL,
	
[vth_name] [nvarchar](200),
[vth_ProductId] [uniqueidentifier],
[vth_OrderId] [uniqueidentifier],
[vth_SerialNumber] [nvarchar](200),
[vth_PartNumber] [nvarchar](200),
[vth_ReturnAuth] [nvarchar](200),
[vth_CustomerProductStatus] [int],
[vth_Location] [int],
[vth_ContactId] [uniqueidentifier],
[vth_Department] [int],
[vth_Return] [int],
[vth_Received] [bit],
[vth_ProbeSerialNumber] [nvarchar](200),
[vth_LastCalibrationDate] [datetime],
[vth_BatteryReplacementDate] [datetime],
[vth_Floor] [nvarchar](200),
[vth_PurchaseDate] [datetime],
[vth_NextInvoiceDate] [datetime],
[vth_CompanyId] [uniqueidentifier],




	[RowAction] [nvarchar](25) NULL,
	[vth_VerathonRefId][int]
	)END