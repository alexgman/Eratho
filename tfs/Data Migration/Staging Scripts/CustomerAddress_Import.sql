USE CRM_Staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CustomerAddress_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	CustomerAddress_Import
** Description:	Insert/Update CustomerAddress from Onyx CustomerAddress table into MSCRM ContactBase 
**
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-09-25		BrianD			Initial Creation
** 2012-10-17		BrianD			Adding Individual Addresses
*/

BEGIN
	SET NOCOUNT ON
	
		
	DECLARE	@Success		BIT,
			@RowId			UNIQUEIDENTIFIER,
			@ErrorId		NVARCHAR(50),
			@ErrorMessage	NVARCHAR(2000),
			@RowsProcessed	INT

	--Declare Variables
	DECLARE	
			@DefaultUoMScheduleId				NVARCHAR(255),
			@OrganizationId						NVARCHAR(255),
			@DefaultUoMId						NVARCHAR(255),
			@PriceLevelId						NVARCHAR(255),
			@CreatedBy							NVARCHAR(255),
			@ModifiedBy							NVARCHAR(255),
			@ExchangeRate						NVARCHAR(255),
			@OwningBusinessUnit					NVARCHAR(255),
			@TransactionCurrencyId				NVARCHAR(255),
			@OwnerIdType						INT,
			@UnassignedTeam						NVARCHAR(255),
			@UnassignedTeamINC					UNIQUEIDENTIFIER,
			@UnassignedTeamLTD					UNIQUEIDENTIFIER

		--Get DEFAULT values
	SELECT	@DefaultUoMScheduleId				= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMScheduleId'),
			@OrganizationId						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'OrganizationId'),
			@DefaultUoMId						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UoMid'),
			@PriceLevelId						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'PriceLevelId'),
			@CreatedBy							= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'CreatedBy'),
			@ModifiedBy							= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'ModifiedBy'),
			@ExchangeRate						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'ExchangeRate'),
			@OwningBusinessUnit					= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'OwningBusinessUnit'),
			@TransactionCurrencyId				= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'TransactionCurrencyId'),
			@OwnerIdType						= null,--9, --Contacts are owned by Teams
			@UnassignedTeam						= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeam'),
			@UnassignedTeamINC					= null,--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamINC'),
			@UnassignedTeamLTD					= null--(SELECT TOP 1 FIELD_VALUE FROM CRM_Staging.dbo.Default_Values WITH (NOLOCK) WHERE Field_ID = 'UnassignedTeamLTD')
				
	--Run Sproc Logic
	BEGIN TRY
	--Clear out the staging table
		TRUNCATE TABLE CRM_Staging.dbo.CustomerAddress
		INSERT INTO CRM_Staging.dbo.CustomerAddress(
					 ParentId
					,onyx_CustomerId
					,onyx_CustomerTypeId
					,onyx_FromTable
					,onyx_AddressId
					,CustomerAddressId
					,AddressNumber
					,ObjectTypeCode
					,AddressTypeCode
					,Name
					,PrimaryContactName
					,Line1
					,Line2
					,Line3
					,City
					,StateOrProvince
					,County
					,Country
					,PostOfficeBox
					,PostalCode
					,UTCOffset
					,FreightTermsCode
					,UPSZone
					,Latitude
					,Telephone1
					,Longitude
					,ShippingMethodCode
					,Telephone2
					,Telephone3
					,Fax
					--,VersionNumber
					,CreatedBy
					,CreatedOn
					,ModifiedBy
					,ModifiedOn
					,TimeZoneRuleVersionNumber
					,OverriddenCreatedOn
					,UTCConversionTimeZoneCode
					,ImportSequenceNumber
					,CreatedOnBehalfBy
					,TransactionCurrencyId
					,ExchangeRate
					,ModifiedOnBehalfBy
					,ParentIdTypeCode
					,vth_Country
					,vth_State
		) 

		select --top 1000
					 ParentId = null --link to company.AccountId
					,onyx_CustomerId = CA.iOwnerId
					,onyx_CustomerTypeId = null
					,onyx_FromTable = 'CustomerAddress'
					,onyx_AddressId = CA.iAddressId
					,CustomerAddressId = NEWID()
					,AddressNumber = null
					,ObjectTypeCode = null
					,AddressTypeCode = CA.iAddressTypeId
					,Name =  RD1.vchParameterDesc +
							 case when len(ltrim(rtrim(ISNULL(CA.vchCompanyName, '')))) = 0 then '' else ' - ' + ltrim(rtrim(ISNULL(CA.vchCompanyName, ''))) end
					,PrimaryContactName = rtrim( 
							  case when len(ltrim(rtrim(ISNULL(CA.vchSalutation, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchSalutation, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchFirstName, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchFirstName, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchMiddleName, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchMiddleName, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchLastName, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchLastName, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchSuffix, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchSuffix, ''))) + ' ' end
							)
					,Line1 = CA.vchAddress1
					,Line2 = CA.vchAddress2
					,Line3 = CA.vchAddress3
					,City = CA.vchCity
					,StateOrProvince = R.chRegionName --CA.chRegionCode
					,County = null
					,Country = CO.chCountryDesc --CA.chCountryCode
					,PostOfficeBox = null
					,PostalCode = CA.vchPostCode
					,UTCOffset = null
					,FreightTermsCode = null
					,UPSZone = null
					,Latitude = null
					,Telephone1 = null
					,Longitude = null
					,ShippingMethodCode = null
					,Telephone2 = null
					,Telephone3 = null
					,Fax = null
					--,VersionNumber
					,CreatedBy = null
					,CreatedOn = CA.dtInsertDate
					,ModifiedBy = null
					,ModifiedOn = CA.dtUpdateDate
					,TimeZoneRuleVersionNumber  = null
					,OverriddenCreatedOn  = null
					,UTCConversionTimeZoneCode = null
					,ImportSequenceNumber = null
					,CreatedOnBehalfBy = null
					,TransactionCurrencyId = null
					,ExchangeRate = null
					,ModifiedOnBehalfBy = null
					,ParentIdTypeCode = null
					,vth_Country = null --CA.chCountryCode
					,vth_State = null --CA.chRegionCode
		from	Onyx.dbo.CustomerAddress CA WITH (NOLOCK)
				join Onyx.dbo.Company C WITH (NOLOCK)
					on CA.iOwnerID = C.iCompanyId
				left outer join Onyx.dbo.ReferenceDefinition RD1 WITH (NOLOCK)
					on CA.iAddressTypeId = RD1.iParameterId
					and RD1.iReferenceId = 71 --Address Type
					and	RD1.tiRecordStatus = 1
				left outer join Onyx.dbo.Country CO WITH (NOLOCK)
					on ltrim(rtrim(CO.chCountryCode)) = ltrim(rtrim(CA.chCountryCode))
					and CO.tiRecordStatus = 1
				left outer join Onyx.dbo.Region R WITH (NOLOCK)
					on ltrim(rtrim(CA.chRegionCode)) = ltrim(rtrim(R.chRegionCode))
					and ltrim(rtrim(CA.chCountryCode)) = ltrim(rtrim(R.chCountryCode))
					and R.tiRecordStatus = 1					
		where	CA.tiRecordStatus = 1
				and C.tiRecordStatus = 1
				
		UNION ALL
		
		select --top 1000
					 ParentId = null --link to company.AccountId
					,onyx_CustomerId = CA.iOwnerId
					,onyx_CustomerTypeId = null
					,onyx_FromTable = 'CustomerAddress'
					,onyx_AddressId = CA.iAddressId
					,CustomerAddressId = NEWID()
					,AddressNumber = null
					,ObjectTypeCode = null
					,AddressTypeCode = CA.iAddressTypeId
					,Name =  RD1.vchParameterDesc +
							 case when len(ltrim(rtrim(ISNULL(CA.vchCompanyName, '')))) = 0 then '' else ' - ' + ltrim(rtrim(ISNULL(CA.vchCompanyName, ''))) end
					,PrimaryContactName = rtrim( 
							  case when len(ltrim(rtrim(ISNULL(CA.vchSalutation, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchSalutation, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchFirstName, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchFirstName, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchMiddleName, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchMiddleName, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchLastName, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchLastName, ''))) + ' ' end
							+ case when len(ltrim(rtrim(ISNULL(CA.vchSuffix, '')))) = 0 then '' else ltrim(rtrim(ISNULL(CA.vchSuffix, ''))) + ' ' end
							)
					,Line1 = CA.vchAddress1
					,Line2 = CA.vchAddress2
					,Line3 = CA.vchAddress3
					,City = CA.vchCity
					,StateOrProvince = R.chRegionName --CA.chRegionCode
					,County = null
					,Country = CO.chCountryDesc --CA.chCountryCode
					,PostOfficeBox = null
					,PostalCode = CA.vchPostCode
					,UTCOffset = null
					,FreightTermsCode = null
					,UPSZone = null
					,Latitude = null
					,Telephone1 = null
					,Longitude = null
					,ShippingMethodCode = null
					,Telephone2 = null
					,Telephone3 = null
					,Fax = null
					--,VersionNumber
					,CreatedBy = null
					,CreatedOn = CA.dtInsertDate
					,ModifiedBy = null
					,ModifiedOn = CA.dtUpdateDate
					,TimeZoneRuleVersionNumber  = null
					,OverriddenCreatedOn  = null
					,UTCConversionTimeZoneCode = null
					,ImportSequenceNumber = null
					,CreatedOnBehalfBy = null
					,TransactionCurrencyId = null
					,ExchangeRate = null
					,ModifiedOnBehalfBy = null
					,ParentIdTypeCode = null
					,vth_Country = null --CA.chCountryCode
					,vth_State = null --CA.chRegionCode
		from	Onyx.dbo.CustomerAddress CA WITH (NOLOCK)
				join Onyx.dbo.Individual I WITH (NOLOCK)
					on CA.iOwnerID = I.iIndividualId
				left outer join Onyx.dbo.ReferenceDefinition RD1 WITH (NOLOCK)
					on CA.iAddressTypeId = RD1.iParameterId
					and RD1.iReferenceId = 1 --Address Type
					and	RD1.tiRecordStatus = 1
				left outer join Onyx.dbo.Country CO WITH (NOLOCK)
					on ltrim(rtrim(CO.chCountryCode)) = ltrim(rtrim(CA.chCountryCode))
					and CO.tiRecordStatus = 1
				left outer join Onyx.dbo.Region R WITH (NOLOCK)
					on ltrim(rtrim(CA.chRegionCode)) = ltrim(rtrim(R.chRegionCode))
					and ltrim(rtrim(CA.chCountryCode)) = ltrim(rtrim(R.chCountryCode))
					and R.tiRecordStatus = 1					
		where	CA.tiRecordStatus = 1
				and I.tiRecordStatus = 1
				and not exists (select * from Contact c where C.vth_contactNumber = I.iIndividualId) --?

			
		--Link CustomerAddress records to Company records				
		update a
		set a.ParentId = b.AccountId
		--select a.ParentId , b.AccountId, a.onyx_CustomerId, b.AccountNumber 
		from CustomerAddress a
			 join Company b
				 on a.onyx_CustomerId = b.AccountNumber
				 
		--Link CustomerAddress records to Contact records				
		update a
		set a.ParentId = b.ContactId
		--select a.ParentId , b.ContactId, a.onyx_CustomerId, b.vth_contactNumber
		from CustomerAddress a
			 join Contact b
				 on a.onyx_CustomerId = b.vth_contactNumber


	END TRY
	BEGIN CATCH
		-- Log Row - ERROR
		--SELECT	@Success		= 0,
		--		@ErrorId		= ERROR_NUMBER(),
		--		@ErrorMessage	= ERROR_MESSAGE()
		--EXEC CRM_Staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage
	END CATCH

	-- Log Row - Stop
	--SELECT @RowsProcessed = COUNT(1) FROM CRM_Staging.dbo.Contact WITH (NOLOCK)
	--EXEC CRM_Staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL

	RETURN 1
END

