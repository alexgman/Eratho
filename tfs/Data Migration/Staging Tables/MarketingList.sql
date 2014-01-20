USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[MarketingList]') IS NOT NULL

DROP TABLE [dbo].[MarketingList]
GO
BEGIN
CREATE TABLE [dbo].[MarketingList](
[CreatedOn] [datetime],
[ModifiedOn] [datetime],
[MemberCount] [int],
[ListName] [nvarchar](256),
[LastUsedOn] [datetime],
[ListId] [uniqueidentifier] null,
[StateCode] [int],
[StatusCode] [int],
[OwningBusinessUnit] [uniqueidentifier],
[ModifiedBy] [uniqueidentifier],
[DoNotSendOnOptOut] [bit],
[Description] [nvarchar](200),
[Purpose] [nvarchar](200),
[Cost] [money],
[IgnoreInactiveListMembers] [bit],
[MemberType] [int],
[Source] [nvarchar](200),
[CreatedFromCode] [int],
[VersionNumber] [timestamp],
[LockStatus] [bit],
[CreatedBy] [uniqueidentifier],
[TransactionCurrencyId] [uniqueidentifier] null,
[ImportSequenceNumber] [int],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],
[ExchangeRate] [decimal],
[OverriddenCreatedOn] [datetime],
[Cost_Base] [money],
[CreatedOnBehalfBy] [uniqueidentifier],
[Type] [bit],
[Query] [nvarchar](200),
[ModifiedOnBehalfBy] [uniqueidentifier],
[OwnerId] [uniqueidentifier] null,
[OwnerIdType] [int],





)END