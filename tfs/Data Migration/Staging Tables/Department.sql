USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Department]') IS NOT NULL

DROP TABLE [dbo].[Department]
GO
BEGIN
CREATE TABLE [dbo].[Department](
[vth_departmentId] [uniqueidentifier],
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
[vth_Department] [int],

	

)END