USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlternateAddress]
(

ParentId uniqueidentifier,
CustomerAddressId uniqueidentifier null,
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
vth_State int


)