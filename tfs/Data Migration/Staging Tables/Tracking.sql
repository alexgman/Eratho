USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Tracking]') IS NOT NULL

DROP TABLE [dbo].[Tracking]
GO
BEGIN
CREATE TABLE [dbo].[Tracking]
(
	
	[vth_trackingId] [uniqueidentifier],
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
[vth_Carrier] [int],
[vth_CustomerPOReference] [nvarchar](200),
[vth_OrderNumber] [nvarchar](200),
[vth_TrackingNumber] [nvarchar](200),
[vth_Company] [uniqueidentifier],
[vth_OrderId] [uniqueidentifier]




)
END