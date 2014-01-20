USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[CompanyMarketSector_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.CompanyMarketSector_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.CompanyMarketSector_Import
GO 

CREATE PROCEDURE [dbo].[CompanyMarketSector_Import]
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS

/*
** ObjectName:	CompanyMarketSector_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to Onyx.dbo.Company via iMarketSector
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
		TRUNCATE TABLE CRM_Staging.dbo.CompanyMatrketSector
		
		--Fill the staging table with the following  Company Market Sector data
		 INSERT dbo.CompanyMatrketSector 
		 (
			 vth_account_vth_marketsectorId
			--,VersionNumber
			,accountid
			,vth_marketsectorid
         )
		Select
			 vth_account_vth_marketsectorId =  NEWID()
			--,VersionNumber = null
			,accountid = d.AccountId
			,vth_marketsectorid = ms.vth_marketsectorId
			  
			  from Onyx..Company c join Company d on c.iCompanyId = d.AccountNumber
			  left join Onyx..ReferenceDefinition rd on c.iMarketSector = rd.iParameterId
			  left join CRM_Staging..MatrketSector ms on rd.vchParameterDesc = ms.vth_name
			  where rd.iReferenceId = 38
		

		
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

