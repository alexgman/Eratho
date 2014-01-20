USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[MarketingList_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.MarketingList_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.MarketingList_Import
GO 

CREATE PROCEDURE [dbo].MarketingList_Import
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS

/*
** ObjectName:	MarketingList_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to Onyx.dbo.TrackingCode
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
		TRUNCATE TABLE CRM_Staging.dbo.MarketingList
		
		--Fill the staging table with the following Users data
		INSERT INTO [CRM_Staging].[dbo].[MarketingList]
        (
		  -- [CreatedOn]
		  --,[ModifiedOn]
		  --,[MemberCount]
		  [ListName]
		  --,[LastUsedOn]
		  ,[ListId]
		  --,[StateCode]
		  --,[StatusCode]
		  ,[OwningBusinessUnit]
		  --,[ModifiedBy]
		  --,[DoNotSendOnOptOut]
		  ,[Description]
		  --,[Purpose]
		  --,[Cost]
		  --,[IgnoreInactiveListMembers]
		  --,[MemberType]
		  --,[Source]
		  --,[CreatedFromCode]
		  --,[VersionNumber]
		  --,[LockStatus]
		  --,[CreatedBy]
		  --,[TransactionCurrencyId]
		  --,[ImportSequenceNumber]
		  --,[TimeZoneRuleVersionNumber]
		  --,[UTCConversionTimeZoneCode]
		  --,[ExchangeRate]
		  --,[OverriddenCreatedOn]
		  --,[Cost_Base]
		  --,[CreatedOnBehalfBy]
		  --,[Type]
		  --,[Query]
		  --,[ModifiedOnBehalfBy]
		  ,[OwnerId]
		  ,[OwnerIdType]

        )
		SELECT
	      [chTrackingName]
		  ,NEWID()
		  ,(select BusinessUnitId from CRM_BusinessUnitBase where Name = 'Verathon')
		  --,[chTrackingCode]
		  --,[dtModifiedDate]
		  --,[chCampaignCode]
		  --,[dtStartDate]
		  --,[dtEndDate]
	      ,[vchTrackingDesc]
		  ,(Select TeamId from CRM_Staging..CRM_TeamBase where name = 'Verathon') as 'OwnerID'
		  ,9

		FROM Onyx.dbo.TrackingCode u WITH (NOLOCK) 

		WHERE u.tiRecordStatus = 1		
		

		
		
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
