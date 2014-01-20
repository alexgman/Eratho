USE CRM_Staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Note_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS


/*
** ObjectName:	Note
** Description:	Insert/Update Note from Onyx Note
**
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-25		BrianD			Initial Creation
** 2012-10-31		BrianD			Populating ObjectTypeCode, OwningBusinessUnit, OwnerId
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
		TRUNCATE TABLE CRM_Staging.dbo.Note
		INSERT INTO CRM_Staging.dbo.Note(
			 AnnotationId
			,ObjectTypeCode
			,ObjectId
			,OwningBusinessUnit
			,Subject
			,IsDocument
			,NoteText
			,MimeType
			,LangId
			,DocumentBody
			,CreatedOn
			,FileSize
			,FileName
			,CreatedBy
			,IsPrivate
			,ModifiedBy
			,ModifiedOn
			--,VersionNumber
			,StepId
			,OverriddenCreatedOn
			,ImportSequenceNumber
			,CreatedOnBehalfBy
			,OwnerId
			,ModifiedOnBehalfBy
			,OwnerIdType
)

select --top 100 
			 AnnotationId = N.note_id
			,ObjectTypeCode = 1 --Company
			,ObjectId = C.AccountId
			,OwningBusinessUnit = CASE  
									WHEN UB.vchNetWorkUser LIKE 'dxu\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')
									WHEN UB.vchNetWorkUser LIKE 'uk\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'United Kingdom (UK)')
									WHEN UB.vchNetWorkUser LIKE 'fr\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'France (FR)')
									WHEN UB.vchNetWorkUser LIKE 'nl\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Netherlands (EU)')
									WHEN UB.vchNetWorkUser LIKE 'au\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Australia (AU)')
									WHEN UB.vchNetWorkUser LIKE 'sm\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Verathon Medical Canada (SBM)')
									ELSE (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')
								  END
			,Subject = N.note_desc
			,IsDocument = 0
			,NoteText = cast(N.text as nvarchar(2000))
			,MimeType = 'text/plain' --null
			,LangId = null
			,DocumentBody = null
			,CreatedOn = N.insert_date
			,FileSize = null
			,FileName = null
			,CreatedBy = U1.SystemUserId
			,IsPrivate = N.private_access
			,ModifiedBy = U2.SystemUserId
			,ModifiedOn = N.update_date
			--,VersionNumber = null
			,StepId = null
			,OverriddenCreatedOn = null
			,ImportSequenceNumber = null
			,CreatedOnBehalfBy = null
			,OwnerId = U2.SystemUserId
			,ModifiedOnBehalfBy = null
			,OwnerIdType = null
--select top 10 *
from		Onyx..Note N WITH (NOLOCK)
			join Company C WITH (NOLOCK)
				on N.owner_id = C.AccountNumber
  			left outer join Onyx..NetWorkUser CB WITH (NOLOCK)
				on N.insert_by = CB.chUserId 
			left outer join Users U1 WITH (NOLOCK)
				on ltrim(rtrim(CB.vchNetWorkUser)) = ltrim(rtrim(U1.DomainName))
			left outer join Onyx..NetWorkUser UB WITH (NOLOCK)
				on n.update_by = UB.chUserId
			left outer join Users U2 WITH (NOLOCK)
				on ltrim(rtrim(UB.vchNetWorkUser)) = ltrim(rtrim(U2.DomainName))
where		N.delete_status = 0

union all  

select --top 100 
			 AnnotationId = N.note_id
			,ObjectTypeCode = 2 --Contact
			,ObjectId = C.ContactId
			,OwningBusinessUnit = CASE  
									WHEN UB.vchNetWorkUser LIKE 'dxu\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')
									WHEN UB.vchNetWorkUser LIKE 'uk\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'United Kingdom (UK)')
									WHEN UB.vchNetWorkUser LIKE 'fr\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'France (FR)')
									WHEN UB.vchNetWorkUser LIKE 'nl\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Netherlands (EU)')
									WHEN UB.vchNetWorkUser LIKE 'au\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Australia (AU)')
									WHEN UB.vchNetWorkUser LIKE 'sm\%' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Verathon Medical Canada (SBM)')
									ELSE (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')
								  END
			,Subject = N.note_desc
			,IsDocument = 0
			,NoteText = cast(N.text as nvarchar(2000))
			,MimeType = 'text/plain' --null
			,LangId = null
			,DocumentBody = null
			,CreatedOn = N.insert_date
			,FileSize = null
			,FileName = null
			,CreatedBy = U1.SystemUserId
			,IsPrivate = N.private_access
			,ModifiedBy = U2.SystemUserId
			,ModifiedOn = N.update_date
			--,VersionNumber = null
			,StepId = null
			,OverriddenCreatedOn = null
			,ImportSequenceNumber = null
			,CreatedOnBehalfBy = null
			,OwnerId = U2.SystemUserId
			,ModifiedOnBehalfBy = null
			,OwnerIdType = null
--select top 10 *
from		Onyx..Note N WITH (NOLOCK)
			join Contact C WITH (NOLOCK)
				on N.owner_id = C.vth_contactNumber
  			left outer join Onyx..NetWorkUser CB WITH (NOLOCK)
				on N.insert_by = CB.chUserId 
			left outer join Users U1 WITH (NOLOCK)
				on ltrim(rtrim(CB.vchNetWorkUser)) = ltrim(rtrim(U1.DomainName))
			left outer join Onyx..NetWorkUser UB WITH (NOLOCK)
				on n.update_by = UB.chUserId
			left outer join Users U2 WITH (NOLOCK)
				on ltrim(rtrim(UB.vchNetWorkUser)) = ltrim(rtrim(U2.DomainName))
where		N.delete_status = 0



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

