USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[OpportunityCompetitor]') IS NOT NULL

DROP TABLE [dbo].[OpportunityCompetitor]
GO
BEGIN
CREATE TABLE [dbo].[OpportunityCompetitor](

[OpportunityId] [uniqueidentifier],
[CompetitorId] [uniqueidentifier],
[VersionNumber] [timestamp],
[OpportunityCompetitorId] [uniqueidentifier],

	

)END