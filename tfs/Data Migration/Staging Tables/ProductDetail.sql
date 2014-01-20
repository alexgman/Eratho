USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[ProductDetail]') IS NOT NULL

DROP TABLE [dbo].[ProductDetail]
GO
BEGIN
CREATE TABLE [dbo].[ProductDetail](
[vth_productdetailId] [uniqueidentifier],
[CreatedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[ModifiedBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[OrganizationId] [uniqueidentifier],
[statecode] [int],
[statuscode] [int],
[VersionNumber] [timestamp],
[ImportSequenceNumber] [int],
[OverriddenCreatedOn] [datetime],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],
[vth_name] [nvarchar](200),
[vth_ProductEntityId] [int],
[vth_VisualBusinessEntity] [int],
[vth_ProductId] [uniqueidentifier]



)END