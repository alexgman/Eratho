USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[ListMembers_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.ListMembers_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.ListMembers_Import
GO 

CREATE PROCEDURE [dbo].ListMembers_Import
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS

/*
** ObjectName:	ListMembers_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to Onyx.dbo.CustomerCampaign
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
		TRUNCATE TABLE CRM_Staging.dbo.ListMembers
		
		--Fill the staging table with the following Users data
		--Fill the staging table with the following Users data
		INSERT INTO [CRM_Staging].[dbo].[ListMembers]
        (
		  [EntityType]
		  --,[CreatedBy]
		  --,[VersionNumber]
		  ,[EntityId]
		  --,[ModifiedBy]
		  ,[ListId]
		  ,[CreatedOn]
		  --,[ListMemberId]
		  ,[ModifiedOn]
		  --,[CreatedOnBehalfBy]
		  --,[ModifiedOnBehalfBy]
		  --,[EntityIdTypeCode]

        )
	SELECT
		  1
		  ,cc.AccountId
		  ,NEWID()
		  ,u.[dtInsertDate]
		  ,u.[dtUpdateDate]
	      --,[iCampaignId]
		  --,[iSiteId]
		  --,[iOwnerId]
		  --,[chLanguageCode]
		  --,[iTrackingId]
		  --,[iAccessCode]
		  --,[vchUser1]
		  --,[vchUser2]
		  --,[vchUser3]
		  --,[vchUser4]
		  --,[vchUser5]
		  --,[chInsertBy]
		  --,[chUpdateBy]
		  --,[tiRecordStatus]
			  
		FROM Onyx.dbo.CustomerCampaign u WITH (NOLOCK) 
		join Onyx..Company oc
		on u.iOwnerId = oc.iCompanyId
		join CRM_Staging..Company cc on oc.iCompanyId = cc.AccountNumber

union all

SELECT
		  2
		  ,c.ContactId
		  ,NEWID()
		  ,u.[dtInsertDate]
		  ,u.[dtUpdateDate]
	      --,[iCampaignId]
		  --,[iSiteId]
		  --,[iOwnerId]
		  --,[chLanguageCode]
		  --,[iTrackingId]
		  --,[iAccessCode]
		  --,[vchUser1]
		  --,[vchUser2]
		  --,[vchUser3]
		  --,[vchUser4]
		  --,[vchUser5]
		  --,[chInsertBy]
		  --,[chUpdateBy]
		  --,[tiRecordStatus]
			  
		FROM Onyx.dbo.CustomerCampaign u WITH (NOLOCK) 
		join Onyx..Individual i
		on u.iOwnerId = i.iIndividualId
		join CRM_Staging..Contact c on i.iIndividualId = c.vth_contactNumber
		

		--WHERE u.tiRecordStatus = 1		
		

		
		
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
