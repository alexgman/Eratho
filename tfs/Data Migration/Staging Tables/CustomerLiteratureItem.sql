USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CustomerLiteratureItem]') IS NOT NULL

DROP TABLE [dbo].[CustomerLiteratureItem]

GO

BEGIN
CREATE TABLE [dbo].[CustomerLiteratureItem](

[vth_customerliteratureitemId] [uniqueidentifier] null,
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
[vth_CustomerLiteratureId] [uniqueidentifier],
[vth_Quantity] [int],
[vth_SalesLiteratureId] [uniqueidentifier],
[vth_ShipDate] [datetime],



)END