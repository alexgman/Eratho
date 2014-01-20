USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Territory]') IS NOT NULL

DROP TABLE [dbo].[Territory]
GO
BEGIN
CREATE TABLE [dbo].[Territory](

[TerritoryId] [uniqueidentifier],
[OrganizationId] [uniqueidentifier],
[ManagerId] [uniqueidentifier],
[Name] [nvarchar](400),
[Description] [nvarchar](200),
[CreatedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[ModifiedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[VersionNumber] [timestamp],
[ImportSequenceNumber] [int],
[OverriddenCreatedOn] [datetime],
[TransactionCurrencyId] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[ExchangeRate] [decimal],
[vth_MarketSectorId] [uniqueidentifier],
[vth_Product] [int],
[vth_VisualBusinessEntity] [int],
[vth_Country] [int],
[vth_Territoryid][uniqueidentifier],
[vth_verathonrefid] [int],




)END