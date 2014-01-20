USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CompanyDepartment]') IS NOT NULL

DROP TABLE [dbo].[CompanyDepartment]
GO 
BEGIN
CREATE TABLE [dbo].[CompanyDepartment](

[vth_account_vth_departmentId] [uniqueidentifier],
[VersionNumber] [timestamp],
[accountid] [uniqueidentifier],
[vth_departmentid] [uniqueidentifier],


	

)END