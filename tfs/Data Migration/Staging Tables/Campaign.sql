USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Campaign]') IS NOT NULL

DROP TABLE [dbo].[Campaign]

GO 
BEGIN
CREATE TABLE [dbo].[Campaign]
(
[TypeCode] [int],
[ProposedEnd] [datetime],
[BudgetedCost] [money],
[CreatedOn] [datetime],
[PromotionCodeName] [nvarchar](256),
[ModifiedOn] [datetime],
[PriceListId] [uniqueidentifier],
[StatusCode] [int],
[CreatedBy] [uniqueidentifier],
[IsTemplate] [bit],
[CampaignId] [uniqueidentifier] null,
[ActualStart] [datetime],
[OwningBusinessUnit] [uniqueidentifier],
[TotalActualCost] [money],
[Message] [nvarchar](512),
[ModifiedBy] [uniqueidentifier],
[ExpectedRevenue] [money],
[VersionNumber] [timestamp],
[CodeName] [nvarchar](64),
[ProposedStart] [datetime],
[Objective] [nvarchar](200),
[ActualEnd] [datetime],
[StateCode] [int] null,
[OtherCost] [money],
[Description] [nvarchar](200),
[TotalCampaignActivityActualCost] [money],
[ExpectedResponse] [int],
[Name] [nvarchar](200) null ,
[ExchangeRate] [decimal],
[TimeZoneRuleVersionNumber] [int],
[TransactionCurrencyId] [uniqueidentifier] null,
[ImportSequenceNumber] [int],
[OverriddenCreatedOn] [datetime],
[UTCConversionTimeZoneCode] [int],
[TotalCampaignActivityActualCost_Base] [money],
[BudgetedCost_Base] [money],
[ExpectedRevenue_Base] [money],
[OtherCost_Base] [money],
[TotalActualCost_Base] [money],
[OwnerId] [uniqueidentifier] null,
[ModifiedOnBehalfBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[OwnerIdType] [int],
[vth_VerathonRefId][int]


)END