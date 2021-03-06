USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[CompanyDepartment_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.CompanyDepartment_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.CompanyDepartment_Import
GO 


CREATE PROCEDURE [dbo].[CompanyDepartment_Import]
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
** 2012-09-20       Vth.ramild		Updated to map to ProdPortal.dbo.CompanyDepartment
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
		TRUNCATE TABLE CRM_Staging.dbo.CompanyDepartment
		
		--Fill the staging table with the following CompanyDepartment data
		INSERT INTO [CRM_Staging].[dbo].[CompanyDepartment]
           (vth_account_vth_departmentId
           ,accountid
           ,vth_departmentid
        )
		select NEWID(), c.AccountId, d.vth_departmentId
		from Onyx.dbo.CustomerProduct cp 
			join Onyx.dbo.ReferenceParameters rp on cp.vchUser9 = rp.iParameterId
			left join dbo.Department d on rp.vchParameterDesc = d.vth_name
			left join dbo.Company c on cp.iOwnerId = c.AccountNumber
		where cp.vchUser9 is not null and cp.vchUser9 != ''
		
		--TODO: some departments in Onyx do not exist in CRM.  need to map to where?
		
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

