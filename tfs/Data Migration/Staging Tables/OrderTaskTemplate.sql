USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


GO 
If  Object_ID('[dbo].[OrderTaskTemplate]') IS NOT NULL

DROP TABLE [dbo].[OrderTaskTemplate]
GO
BEGIN
CREATE TABLE [dbo].[OrderTaskTemplate]
([vth_ordertasktemplateId] [uniqueidentifier],
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
[vth_DatePartCount] [int],
[vth_DatePartType] [nvarchar](4),
[vth_TaskId] [int],
[vth_VisualBusinessEntity] [int],
[vth_QueueId] [uniqueidentifier],

	
)END