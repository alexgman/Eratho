USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Incident]') IS NOT NULL

DROP TABLE [dbo].[Incident]
GO
BEGIN
CREATE TABLE [dbo].[Incident](
	[IncidentId] [uniqueidentifier] null DEFAULT(NEWID()),
	

[OwningBusinessUnit] [uniqueidentifier],
[ContractDetailId] [uniqueidentifier],
[SubjectId] [uniqueidentifier],
[ContractId] [uniqueidentifier],
[ActualServiceUnits] [int],
[CaseOriginCode] [int],
[BilledServiceUnits] [int],
[CaseTypeCode] [int],
[ProductSerialNumber] [nvarchar](200),
[Title] [nvarchar](400),
[ProductId] [uniqueidentifier],
[ContractServiceLevelCode] [int],
[Description] [nvarchar](200),
[IsDecrementing] [bit],
[CreatedOn] [datetime],
[TicketNumber] [nvarchar](200),
[PriorityCode] [int],
[CustomerSatisfactionCode] [int],
[IncidentStageCode] [int],
[ModifiedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[FollowupBy] [datetime],
[ModifiedBy] [uniqueidentifier],
[VersionNumber] [timestamp],
[StateCode] [int],
[SeverityCode] [int],
[StatusCode] [int],
[ResponsibleContactId] [uniqueidentifier],
[KbArticleId] [uniqueidentifier],
[TimeZoneRuleVersionNumber] [int],
[ImportSequenceNumber] [int],
[UTCConversionTimeZoneCode] [int],
[OverriddenCreatedOn] [datetime],
[ExchangeRate] [decimal],
[ModifiedOnBehalfBy] [uniqueidentifier],
[TransactionCurrencyId] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[CustomerId] [uniqueidentifier],
[OwnerId] [uniqueidentifier],
[OwnerIdType] [int],
[CustomerIdType] [int],
[CustomerIdName] [nvarchar](800),
[CustomerIdYomiName] [nvarchar](800),

[vth_OriginalOrderId] [uniqueidentifier],
[vth_Resoultion1] [nvarchar](200),
[vth_ContactId] [uniqueidentifier],
[vth_Action] [int],
[vth_Conclusion] [int],
[vth_CustomerPO] [nvarchar](200),
[vth_QAApproval] [bit],
[vth_SVCApproval] [bit],
[vth_CARRes] [nvarchar](200),
[vth_ReasonforInitialCall] [int],
[vth_IncidentNumber] [int],
[vth_Source] [int],
[vth_CustomerProduct1Id] [uniqueidentifier],
[vth_CustomerProduct2Id] [uniqueidentifier],
[vth_Resolution2] [nvarchar](200),
[vth_ProductBrand] [int],
[vth_ProductModel] [int]

)END


	
