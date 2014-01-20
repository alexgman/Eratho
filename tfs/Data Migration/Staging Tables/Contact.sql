USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Contact]') IS NOT NULL

DROP TABLE [dbo].[Contact]
GO
BEGIN
CREATE TABLE [dbo].[Contact](
	[ContactId] [uniqueidentifier] null DEFAULT(NEWID()),
	
[DefaultPriceLevelId] [uniqueidentifier],
[CustomerSizeCode] [int],
[CustomerTypeCode] [int],
[PreferredContactMethodCode] [int],
[LeadSourceCode] [int],
[OriginatingLeadId] [uniqueidentifier],
[OwningBusinessUnit] [uniqueidentifier],
[PaymentTermsCode] [int],
[ShippingMethodCode] [int],
[ParticipatesInWorkflow] [bit],
[IsBackofficeCustomer] [bit],
[Salutation] [nvarchar](200),
[JobTitle] [nvarchar](200),
[FirstName] [nvarchar](100),
[Department] [nvarchar](200),
[NickName] [nvarchar](100),
[MiddleName] [nvarchar](100),
[LastName] [nvarchar](100),
[Suffix] [nvarchar](20),
[YomiFirstName] [nvarchar](300),
[FullName] [nvarchar](320),
[YomiMiddleName] [nvarchar](300),
[YomiLastName] [nvarchar](300),
[Anniversary] [datetime],
[BirthDate] [datetime],
[GovernmentId] [nvarchar](100),
[YomiFullName] [nvarchar](900),
[Description] [nvarchar](200),
[EmployeeId] [nvarchar](100),
[GenderCode] [int],
[AnnualIncome] [money],
[HasChildrenCode] [int],
[EducationCode] [int],
[WebSiteUrl] [nvarchar](400),
[FamilyStatusCode] [int],
[FtpSiteUrl] [nvarchar](400),
[EMailAddress1] [nvarchar](200),
[SpousesName] [nvarchar](200),
[AssistantName] [nvarchar](200),
[EMailAddress2] [nvarchar](200),
[AssistantPhone] [nvarchar](100),
[EMailAddress3] [nvarchar](200),
[DoNotPhone] [bit],
[ManagerName] [nvarchar](200),
[ManagerPhone] [nvarchar](100),
[DoNotFax] [bit],
[DoNotEMail] [bit],
[DoNotPostalMail] [bit],
[DoNotBulkEMail] [bit],
[DoNotBulkPostalMail] [bit],
[AccountRoleCode] [int],
[TerritoryCode] [int],
[IsPrivate] [bit],
[CreditLimit] [money],
[CreatedOn] [datetime],
[CreditOnHold] [bit],
[CreatedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[ModifiedBy] [uniqueidentifier],
[NumberOfChildren] [int],
[ChildrensNames] [nvarchar](510),
[VersionNumber] [timestamp],
[MobilePhone] [nvarchar](100),
[Pager] [nvarchar](100),
[Telephone1] [nvarchar](100),
[Telephone2] [nvarchar](100),
[Telephone3] [nvarchar](100),
[Fax] [nvarchar](100),
[Aging30] [money],
[StateCode] [int],
[Aging60] [money],
[StatusCode] [int],
[Aging90] [money],
[PreferredSystemUserId] [uniqueidentifier],
[PreferredServiceId] [uniqueidentifier],
[MasterId] [uniqueidentifier],
[PreferredAppointmentDayCode] [int],
[PreferredAppointmentTimeCode] [int],
[DoNotSendMM] [bit],
[Merged] [bit],
[ExternalUserIdentifier] [nvarchar](100),
[SubscriptionId] [uniqueidentifier],
[PreferredEquipmentId] [uniqueidentifier],
[LastUsedInCampaign] [datetime],
[TransactionCurrencyId] [uniqueidentifier],
[OverriddenCreatedOn] [datetime],
[ExchangeRate] [decimal],
[ImportSequenceNumber] [int],
[TimeZoneRuleVersionNumber] [int],
[UTCConversionTimeZoneCode] [int],
[AnnualIncome_Base] [money],
[CreditLimit_Base] [money],
[Aging60_Base] [money],
[Aging90_Base] [money],
[Aging30_Base] [money],
[OwnerId] [uniqueidentifier],
[CreatedOnBehalfBy] [uniqueidentifier],
[IsAutoCreate] [bit],
[ModifiedOnBehalfBy] [uniqueidentifier],
[ParentCustomerId] [uniqueidentifier],
[ParentCustomerIdType] [int],
[ParentCustomerIdName] [nvarchar](200),
[OwnerIdType] [int],
[ParentCustomerIdYomiName] [nvarchar](200),
[vth_contactNumber] [nvarchar](200),
[vth_PrimaryPhone] [int],
[vth_Address1_Valid] [bit],
[vth_UseAsaReference] [bit],
[vth_LastExportReview] [datetime],
[vth_jobtitle] [int],
[vth_Department] [int],
[vth_Source] [int],
[vth_ExportStatus] [int],
[vth_Country] [int],
[vth_State] [int],
[Address1_AddressTypeCode][int],
[Address1_Name][NVARCHAR](200),
[Address1_Line1][NVARCHAR](50),
[Address1_Line2][NVARCHAR](50),
[Address1_Line3][NVARCHAR](50),
[Address1_City][NVARCHAR](50),
[Address1_StateOrProvince][NVARCHAR](50),
[Address1_PostalCode][NVARCHAR](50),
[Address1_Country][NVARCHAR](50)

)END