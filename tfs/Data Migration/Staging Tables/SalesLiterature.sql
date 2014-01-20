USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[SalesLiterature]') IS NOT NULL

DROP TABLE [dbo].[SalesLiterature]
GO
BEGIN
CREATE TABLE [dbo].[SalesLiterature](

[SalesLiteratureId] [uniqueidentifier] null,
[OrganizationId] [uniqueidentifier],
[EmployeeContactId] [uniqueidentifier],
[SubjectId] [uniqueidentifier],
[Description] [nvarchar](200),
[LiteratureTypeCode] [int],
[Name] [nvarchar](200),
[ExpirationDate] [datetime],
[IsCustomerViewable] [bit],
[CreatedBy] [uniqueidentifier],
[KeyWords] [nvarchar](200),
[HasAttachments] [bit],
[ModifiedBy] [uniqueidentifier],
[CreatedOn] [datetime],
[ModifiedOn] [datetime],
[VersionNumber] [timestamp],
[UTCConversionTimeZoneCode] [int],
[OverriddenCreatedOn] [datetime],
[TimeZoneRuleVersionNumber] [int],
[ImportSequenceNumber] [int],
[TransactionCurrencyId] [uniqueidentifier],
[ExchangeRate] [decimal],
[ModifiedOnBehalfBy] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],


)END