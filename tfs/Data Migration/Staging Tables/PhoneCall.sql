USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[PhoneCall]') IS NOT NULL

DROP TABLE [dbo].[PhoneCall]
GO
BEGIN
CREATE TABLE [dbo].[PhoneCall]
(

[OwnerId] [uniqueidentifier],

[OwnerIdDsc] [int],
[OwnerIdType] [int],
[OwningUser] [uniqueidentifier],
[OwningTeam] [uniqueidentifier],
[Subject] [nvarchar](900),
[ModifiedBy] [uniqueidentifier],
[OwningBusinessUnit] [uniqueidentifier],
[ActualEnd] [datetime],
[ActivityId] [uniqueidentifier],
[CreatedBy] [uniqueidentifier],
[PhoneNumber] [nvarchar](400),
[DirectionCode] [bit],
[RegardingObjectId] [uniqueidentifier],
[IsBilled] [bit],
[ModifiedOn] [datetime],
[ScheduledEnd] [datetime],
[CreatedOn] [datetime],
[VersionNumber] [timestamp],
[IsWorkflowCreated] [bit],
[PriorityCode] [int],
[ActualStart] [datetime],
[Category] [nvarchar](500),
[ScheduledDurationMinutes] [int],
[Description] [nvarchar](200),
[StateCode] [int],
[Subcategory] [nvarchar](500),
[ActualDurationMinutes] [int],
[StatusCode] [int],
[ScheduledStart] [datetime],
[ServiceId] [uniqueidentifier],

[RegardingObjectTypeCode] [int],
[ImportSequenceNumber] [int],
[OverriddenCreatedOn] [datetime],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],
[SubscriptionId] [uniqueidentifier],

[CreatedOnBehalfBy] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[ActivityTypeCode] [int],
[IsRegularActivity] [bit],
[TransactionCurrencyId] [uniqueidentifier],
[ExchangeRate] [decimal]


)
END