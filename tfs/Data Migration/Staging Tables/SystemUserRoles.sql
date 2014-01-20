USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[SystemUserRoles]') IS NOT NULL

DROP TABLE [dbo].[SystemUserRoles]
GO
BEGIN
CREATE TABLE [dbo].[SystemUserRoles]
(


[SystemUserId] [uniqueidentifier],
[RoleId] [uniqueidentifier],
[SystemUserRoleId] [uniqueidentifier],
[VersionNumber] [timestamp],
)END