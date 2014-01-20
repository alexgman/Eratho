USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Task]') IS NOT NULL

DROP TABLE [dbo].[Task]
GO
BEGIN
CREATE TABLE [dbo].[Task]
(

[OwnerId] [uniqueidentifier],
[OwnerIdName] [nvarchar](320),

[OwnerIdDsc] [int],
[OwnerIdType] [int],
[OwningUser] [uniqueidentifier],
[OwningTeam] [uniqueidentifier],
[Subject] [nvarchar](900),
[ActualEnd] [datetime],
[ScheduledStart] [datetime],
[RegardingObjectId] [uniqueidentifier],
[ScheduledDurationMinutes] [int],
[ActualStart] [datetime],
[StateCode] [int],
[ActivityId] [uniqueidentifier],
[Category] [nvarchar](500),
[CreatedOn] [datetime],
[OwningBusinessUnit] [uniqueidentifier],
[IsWorkflowCreated] [bit],
[CreatedBy] [uniqueidentifier],
[ModifiedBy] [uniqueidentifier],
[Subcategory] [nvarchar](500),
[ScheduledEnd] [datetime],
[Description] [nvarchar](100),
[PercentComplete] [int],
[SubscriptionId] [uniqueidentifier],
[PriorityCode] [int],
[VersionNumber] [timestamp],
[ServiceId] [uniqueidentifier],
[ActualDurationMinutes] [int],
[ModifiedOn] [datetime],
[StatusCode] [int],
[IsBilled] [bit],

[RegardingObjectTypeCode] [int],
[ImportSequenceNumber] [int],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],
[OverriddenCreatedOn] [datetime],

[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[ActivityTypeCode] [int],
[IsRegularActivity] [bit],
[TransactionCurrencyId] [uniqueidentifier],
[ExchangeRate] [decimal]


)
END