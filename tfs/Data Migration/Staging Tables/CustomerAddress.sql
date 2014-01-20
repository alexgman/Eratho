USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CustomerAddress]') IS NOT NULL

DROP TABLE [dbo].[CustomerAddress]
GO
BEGIN
CREATE TABLE [dbo].[CustomerAddress](
	[ParentId] [uniqueidentifier] null,
	[onyx_CustomerId] [int] NULL,
	[onyx_CustomerTypeId] [int] NULL,
	[onyx_FromTable] [nvarchar] (25) NULL,
	[onyx_AddressId] [int] NULL,
	[CustomerAddressId] [uniqueidentifier] null DEFAULT(NEWID()),

AddressNumber int,
ObjectTypeCode int,
AddressTypeCode int,
Name nvarchar(400),
PrimaryContactName nvarchar(300),
Line1 nvarchar(200),
Line2 nvarchar(200),
Line3 nvarchar(200),
City nvarchar(200),
StateOrProvince nvarchar(200),
County nvarchar(200),
Country nvarchar(200),
PostOfficeBox nvarchar(100),
PostalCode nvarchar(100),
UTCOffset int,
FreightTermsCode int,
UPSZone nvarchar(8),
Latitude float,
Telephone1 nvarchar(100),
Longitude float,
ShippingMethodCode int,
Telephone2 nvarchar(100),
Telephone3 nvarchar(100),
Fax nvarchar(100),
VersionNumber timestamp,
CreatedBy uniqueidentifier,
CreatedOn datetime,
ModifiedBy uniqueidentifier,
ModifiedOn datetime,
TimeZoneRuleVersionNumber int,
OverriddenCreatedOn datetime,
UTCConversionTimeZoneCode int,
ImportSequenceNumber int,
CreatedOnBehalfBy uniqueidentifier,
TransactionCurrencyId uniqueidentifier,
ExchangeRate decimal,
ModifiedOnBehalfBy uniqueidentifier,
ParentIdTypeCode int,
vth_Country int,
vth_State int,
vth_exportStatus bit,
vth_LastExportReview datetime
)
END