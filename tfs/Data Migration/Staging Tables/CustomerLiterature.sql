USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CustomerLiterature]') IS NOT NULL

DROP TABLE [dbo].[CustomerLiterature]
GO 
BEGIN
CREATE TABLE [dbo].[CustomerLiterature](

[vth_customerliteratureId] [uniqueidentifier] null,
[CreatedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[ModifiedBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[OwnerId] [uniqueidentifier],
[OwnerIdType] [int],
[OwningBusinessUnit] [uniqueidentifier],
[statecode] [int],
[statuscode] [int],
[VersionNumber] [timestamp],
[ImportSequenceNumber] [int],
[OverriddenCreatedOn] [datetime],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],

[vth_name] [nvarchar](200),
[vth_CompanyId] [uniqueidentifier],
[vth_AddressType] [int],
[vth_ShipTo] [nvarchar](200),
[vth_ShipMethod] [int],
[vth_Priority] [bit],
[vth_Comments] [nvarchar](200),
[vth_CustomerReference] [nvarchar](200),
[vth_Fax] [nvarchar](200),
[vth_CampaignId] [uniqueidentifier],
[vth_OrderId] [int],
[vth_ordernumber][int]


)end