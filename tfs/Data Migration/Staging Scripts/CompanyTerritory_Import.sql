USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[CompanyTerritory_Import]    Script Date: 10/17/2012 19:08:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CompanyTerritory_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	CompanyTerritory_Import
** 
** Description:	Build Staging Data for table CompanyTerritory from ProdPortal for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-15		Inessa		Initial Creation
*/

BEGIN

BEGIN TRY

TRUNCATE TABLE [CRM_Staging].[dbo].[CompanyTerritory]

INSERT INTO [CRM_Staging].[dbo].[CompanyTerritory]
	( [vth_account_territoryId]
      --,[VersionNumber]
      ,[accountid]
      ,[territoryid] )
      
SELECT  
	NEWID() as [vth_account_territoryId]
	,b.accountid as [accountid]
	,a.TerritoryId as [territoryid]
FROM Territory	a
JOIN Company	b
ON a.Name = b.TerritoryCode 

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