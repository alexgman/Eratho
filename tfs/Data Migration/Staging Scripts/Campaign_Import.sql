USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[Campaign_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.Campaign_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.Campaign_Import
GO 

CREATE PROCEDURE [dbo].Campaign_Import
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS

/*
** ObjectName:	Campaign_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to Onyx.dbo.Campaign
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
		TRUNCATE TABLE CRM_Staging.dbo.Campaign	
		
		--Fill the staging table with the following Users data
		INSERT INTO [CRM_Staging].[dbo].[Campaign]
        (
       --    [TypeCode]
	      --,[ProposedEnd]
	      --,[BudgetedCost]
		  --,[CreatedOn]
		  [PromotionCodeName]
		  ,[ModifiedOn]
		  --,[PriceListId]
		  --,[StatusCode]
		  --,[CreatedBy]
		  --,[IsTemplate]
		  ,[CampaignId]
		  --,[ActualStart]
		  ,[OwningBusinessUnit]
		  --,[TotalActualCost]
		  --,[Message]
		  --,[ModifiedBy]
		  --,[ExpectedRevenue]
		  --,[VersionNumber]
		  ,[CodeName]
		  ,[ProposedStart]
		  --,[Objective]
		  ,[ActualEnd]
		  --,[StateCode]
		  --,[OtherCost]
		  ,[Description]
		  --,[TotalCampaignActivityActualCost]
		  --,[ExpectedResponse]
		  ,[Name]
		  --,[ExchangeRate]
		  --,[TimeZoneRuleVersionNumber]
		  --,[TransactionCurrencyId]
		  --,[ImportSequenceNumber]
		  --,[OverriddenCreatedOn]
		  --,[UTCConversionTimeZoneCode]
		  --,[TotalCampaignActivityActualCost_Base]
		  --,[BudgetedCost_Base]
		  --,[ExpectedRevenue_Base]
		  --,[OtherCost_Base]
		  --,[TotalActualCost_Base]
		  ,[OwnerId]
		  --,[ModifiedOnBehalfBy]
		  --,[CreatedOnBehalfBy]
		  ,[OwnerIdType]

        )
		SELECT
		   [chTrackingCode]
		  ,[dtModifiedDate]
		  ,NEWID()
		  ,(select BusinessUnitId from CRM_BusinessUnitBase where Name = 'Verathon')
		  ,[chCampaignCode]
		  ,[dtStartDate]
		  ,[dtEndDate]
	      ,[vchTrackingDesc]
	      ,[chTrackingName]
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
