USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Warranty]') IS NOT NULL

DROP TABLE [dbo].[Warranty]
GO
BEGIN
CREATE TABLE [dbo].[Warranty](

[vth_warrantyId] [uniqueidentifier],
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
[vth_CustomerProductId] [uniqueidentifier],
[vth_StartDate] [datetime],
[vth_EndDate] [datetime],
[vth_Type] [int],
[vth_VerathonRefId][int]


)END