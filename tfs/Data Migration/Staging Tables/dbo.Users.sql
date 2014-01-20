
USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Users]') IS NOT NULL

DROP TABLE [dbo].[Users]
GO
BEGIN
CREATE TABLE [dbo].[Users]
(
[SystemUserId] [uniqueidentifier] null,
[TerritoryId] [uniqueidentifier],
[OrganizationId] [uniqueidentifier] null,
[BusinessUnitId] [uniqueidentifier] null,
[ParentSystemUserId] [uniqueidentifier],
[FirstName] [nvarchar](100),
[Salutation] [nvarchar](40),
[MiddleName] [nvarchar](100),
[LastName] [nvarchar](100),
[PersonalEMailAddress] [nvarchar](200),
[FullName] [nvarchar](320),
[NickName] [nvarchar](100),
[Title] [nvarchar](200),
[InternalEMailAddress] [nvarchar](200),
[JobTitle] [nvarchar](200),
[MobileAlertEMail] [nvarchar](200),
[PreferredEmailCode] [int],
[HomePhone] [nvarchar](100),
[MobilePhone] [nvarchar](100),
[PreferredPhoneCode] [int],
[PreferredAddressCode] [int],
[PhotoUrl] [nvarchar](400),
[DomainName] [nvarchar](510),
[PassportLo] [int],
[CreatedOn] [datetime],
[PassportHi] [int],
[DisabledReason] [nvarchar](1000),
[ModifiedOn] [datetime],
[CreatedBy] [uniqueidentifier],
[EmployeeId] [nvarchar](200),
[ModifiedBy] [uniqueidentifier],
[IsDisabled] [bit],
[GovernmentId] [nvarchar](200),
[VersionNumber] [timestamp],
[Skills] [nvarchar](200),
[DisplayInServiceViews] [bit],
[CalendarId] [uniqueidentifier],
[ActiveDirectoryGuid] [uniqueidentifier],
[SetupUser] [bit],
[SiteId] [uniqueidentifier],
[WindowsLiveID] [nvarchar](200),
[IncomingEmailDeliveryMethod] [int],
[OutgoingEmailDeliveryMethod] [int],
[ImportSequenceNumber] [int],
[AccessMode] [int],
[InviteStatusCode] [int],
[IsActiveDirectoryUser] [bit],
[OverriddenCreatedOn] [datetime],
[UTCConversionTimeZoneCode] [int],
[TimeZoneRuleVersionNumber] [int],
[YomiFullName] [nvarchar](320),
[YomiLastName] [nvarchar](100),
[YomiMiddleName] [nvarchar](100),
[YomiFirstName] [nvarchar](100),
[CreatedOnBehalfBy] [uniqueidentifier],
[ExchangeRate] [decimal],
[IsIntegrationUser] [bit],
[ModifiedOnBehalfBy] [uniqueidentifier],
[EmailRouterAccessApproval] [int],
[DefaultFiltersPopulated] [bit],
[CALType] [int],
[QueueId] [uniqueidentifier],
[TransactionCurrencyId] [uniqueidentifier],
[IsSyncWithDirectory] [bit],
[IsLicensed] [bit],
[vth_OnyxUserId] [NVARCHAR] (100),
[OnyxStatus] BIT
)
END