USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[Department_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.Department_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.Department_Import
GO 


CREATE PROCEDURE [dbo].[Department_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	User_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ramild		Updated to map to ProdPortal.dbo.Department
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
		TRUNCATE TABLE CRM_Staging.dbo.Department
		
		--Fill the staging table with the following Department data
		INSERT INTO [CRM_Staging].[dbo].[Department]
           (vth_departmentId
           ,OrganizationId
        )
		select 
		deb.vth_departmentId
		,db.OrganizationId
		from CRM_vth_departmentExtensionBase deb join CRM_vth_departmentBase db on deb.vth_departmentid = db.vth_departmentid
		
		
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

