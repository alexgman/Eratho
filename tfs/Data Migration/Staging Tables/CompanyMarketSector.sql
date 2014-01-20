USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CompanyMarketSector]') IS NOT NULL
DROP TABLE [dbo].[CompanyMarketSector]
GO 
BEGIN

CREATE TABLE [dbo].[CompanyMatrketSector](

[vth_account_vth_marketsectorId] [uniqueidentifier],
[VersionNumber] [timestamp],
[accountid] [uniqueidentifier],
[vth_marketsectorid] [uniqueidentifier],


	

)END