USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[ListMembers]') IS NOT NULL

DROP TABLE [dbo].[ListMembers]
GO
BEGIN
CREATE TABLE [dbo].[ListMembers](

[EntityType] [int],
[CreatedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[VersionNumber] [timestamp],
[EntityId] [uniqueidentifier],
[ModifiedBy] [uniqueidentifier],
[ListId] [uniqueidentifier],
[ListMemberId] [uniqueidentifier],
[ModifiedOn] [datetime],
[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[EntityIdTypeCode] [int],


	

)END