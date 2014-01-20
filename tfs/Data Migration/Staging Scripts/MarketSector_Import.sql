USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[SalesLiterature_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.SalesLiterature_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.SalesLiterature_Import
GO 

CREATE PROCEDURE [dbo].SalesLiterature_Import
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS

/*
** ObjectName:	SalesLiterature_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to Onyx.dbo.Literature
*/

BEGIN
	SET NOCOUNT ON
	
	--Run Sproc Logic
	BEGIN TRY
		--Declare Variables
		DECLARE	@dtCurrent							DATETIME

		--Get DEFAULT values
		SELECT	@dtCurrent							= GETDATE()

		--Clear out the staging table
		TRUNCATE TABLE CRM_Staging.dbo.SalesLiterature
		
		--Fill the staging table with the following Users data
		INSERT INTO [CRM_Staging].[dbo].[SalesLiterature]
           (
			  [SalesLiteratureId]
			  ,[OrganizationId]
			  --,[EmployeeContactId]
			  --,[SubjectId]
			  ,[Description]
			  --,[LiteratureTypeCode]
			  --,[Name]
			  --,[ExpirationDate]
			  --,[IsCustomerViewable]
			  ,[CreatedBy]
			  --,[KeyWords]
			  --,[HasAttachments]
			  ,[ModifiedBy]
			  ,[CreatedOn]
			  ,[ModifiedOn]
			  --,[VersionNumber]
			  --,[UTCConversionTimeZoneCode]
			  --,[OverriddenCreatedOn]
			  --,[TimeZoneRuleVersionNumber]
			  --,[ImportSequenceNumber]
			  --,[TransactionCurrencyId]
			  --,[ExchangeRate]
			  --,[ModifiedOnBehalfBy]
			  --,[CreatedOnBehalfBy]
        )
		SELECT 
			  NEWID()
			  ,(select OrganizationId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')
			  ,L.[chProductNumber]
			  ,U.SystemUserId
			  ,U.SystemUserId
			  ,L.[dtInsertDate]
			  ,L.[dtUpdateDate]

		FROM Onyx.dbo.Literature L WITH (NOLOCK) 
					-- Get SystemUserId for the record creator
			left join Onyx..NetWorkUser nu 
				on L.chInsertBy = nu.chUserId
			left join CRM_Staging..Users U 
				on U.DomainName = nu.vchNetWorkUser
			
			-- Get SystemUserId for the record updator/modifier
			left join Onyx..NetWorkUser nu2 
				on L.chUpdateBy = nu2.chUserId
			left join CRM_Staging..Users U2 
				on U2.DomainName = nu2.vchNetWorkUser

			-- Get only HQ literature Documents
			join Onyx..ProductMaster pm on L.chProductNumber = pm.chProductNumber
		
		WHERE L.tiRecordStatus = 1		
    	and pm.iHierarchyId = 324 -- HQ

	
		
	END TRY
	BEGIN CATCH
		-- Log Row - ERROR
		--SELECT	@Success		= 0,
		--		@ErrorId		= ERROR_NUMBER(),
		--		@ErrorMessage	= ERROR_MESSAGE()
		--EXEC CRM_Staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage
	END CATCH

	-- Log Row - Stop
	--SELECT @RowsProcessed = COUNT(1) FROM CRM_Staging.dbo.Account WITH (NOLOCK)
	--EXEC CRM_Staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL

	RETURN 1 --@Success
END

