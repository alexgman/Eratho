USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Competitor]') IS NOT NULL

DROP TABLE [dbo].[Competitor]
GO
BEGIN
CREATE TABLE [dbo].[Competitor](
[CompetitorId] [uniqueidentifier],
[OrganizationId] [uniqueidentifier],
[Name] [nvarchar](200),
[Overview] [nvarchar](200),
[ReferenceInfoUrl] [nvarchar](400),
[ReportedRevenue] [money],
[ReportingQuarter] [int],
[ReportingYear] [int],
[Strengths] [nvarchar](200),
[Weaknesses] [nvarchar](200),
[Opportunities] [nvarchar](200),
[Threats] [nvarchar](200),
[TickerSymbol] [nvarchar](20),
[KeyProduct] [nvarchar](400),
[StockExchange] [nvarchar](40),
[WinPercentage] [float],
[WebSiteUrl] [nvarchar](400),
[CreatedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[ModifiedBy] [uniqueidentifier],
[VersionNumber] [timestamp],
[UTCConversionTimeZoneCode] [int],
[TimeZoneRuleVersionNumber] [int],
[OverriddenCreatedOn] [datetime],
[ExchangeRate] [decimal],
[TransactionCurrencyId] [uniqueidentifier],
[ImportSequenceNumber] [int],
[ReportedRevenue_Base] [money],
[YomiName] [nvarchar](200),
[ModifiedOnBehalfBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],


	

)END