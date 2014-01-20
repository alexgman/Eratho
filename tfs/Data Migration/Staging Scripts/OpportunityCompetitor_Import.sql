USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[OpportunityCompetitor_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.OpportunityCompetitor_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.OpportunityCompetitor_Import
GO 

CREATE PROCEDURE [dbo].[OpportunityCompetitor_Import]
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS

/*
** ObjectName:	OpportunityCompetitor_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to CRM_Staging.OpportunityCompetitor
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
		TRUNCATE TABLE CRM_Staging.dbo.OpportunityCompetitor
		
		--Fill the staging table with the following Market Sector data
INSERT INTO [CRM_Staging].[dbo].[OpportunityCompetitor]
        (
	       [OpportunityId]
		  ,[CompetitorId]
		  --,[VersionNumber]
		  ,[OpportunityCompetitorId]
	           
        )
        
		SELECT 
		
			 NEWID()
			,CompetitorId = c.CompetitorId
			--,VersionNumber
			,OpportunityCompetitorId = o.OpportunityId	
		
			from Onyx..Incident i 
			join Opportunity o on i.iIncidentId = o.vth_OpportunityNumber			  
			join CRM_Staging..Competitor c on c.Name = i.vchUser2
			where i.vchUser2 is not null


		

		
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

