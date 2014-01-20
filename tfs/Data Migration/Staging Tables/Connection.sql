USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Connection]') IS NOT NULL
BEGIN
DROP TABLE [dbo].[Connection]
CREATE TABLE [dbo].[Connection](
	


[Record2RoleId] [uniqueidentifier],
[ModifiedBy] [uniqueidentifier],
[Record2Id] [uniqueidentifier],
[CreatedOn] [datetime],
[ModifiedOnBehalfBy] [uniqueidentifier],
[ConnectionId] [uniqueidentifier],
[IsMaster] [bit],
[OwnerId] [uniqueidentifier],
[VersionNumber] [timestamp],
[Record2ObjectTypeCode] [int],
[ImportSequenceNumber] [int],
[StateCode] [int],
[Description] [nvarchar](4000),
[EffectiveStart] [datetime],
[ModifiedOn] [datetime],
[TransactionCurrencyId] [uniqueidentifier],
[OwningBusinessUnit] [uniqueidentifier],
[OverriddenCreatedOn] [datetime],
[Record1Id] [uniqueidentifier],
[StatusCode] [int],
[CreatedOnBehalfBy] [uniqueidentifier],
[Record1ObjectTypeCode] [int],
[RelatedConnectionId] [uniqueidentifier],
[Record1RoleId] [uniqueidentifier],
[CreatedBy] [uniqueidentifier],
[EffectiveEnd] [datetime],
[ExchangeRate] [decimal],
[Record2IdName] [nvarchar](4000),
[Record1IdName] [nvarchar](4000)


)END