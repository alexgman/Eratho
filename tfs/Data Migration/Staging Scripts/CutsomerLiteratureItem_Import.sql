USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[CutsomerLiteratureItem_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.CutsomerLiteratureItem_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.CutsomerLiteratureItem_Import
GO 

CREATE PROCEDURE [dbo].[CutsomerLiteratureItem_Import]
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS

/*
** ObjectName:	CutsomerLiteratureItem_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to Onyx.dbo.OrderDetail
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
		TRUNCATE TABLE CRM_Staging.dbo.CustomerLiteratureItem
		
		--Fill the staging table with the following Users data
		INSERT INTO [CRM_Staging].[dbo].[CustomerLiteratureItem]
           (
				--[vth_customerliteratureitemId]
			  [CreatedOn]
			  ,[CreatedBy]
			  ,[ModifiedOn]
			  ,[ModifiedBy]
			  ,[OwnerId]
			  ,[OwnerIdType]
			  ,[OwningBusinessUnit]
        )			  --,[CreatedOnBehalfBy]
			  --,[ModifiedOnBehalfBy]
			  --,[statecode]
			  --,[statuscode]
			  --,[VersionNumber]
			  --,[ImportSequenceNumber]
			  --,[OverriddenCreatedOn]
			  --,[TimeZoneRuleVersionNumber]
			  --,[UTCConversionTimeZoneCode]
			  --,[vth_name]
			  --,[vth_CustomerLiteratureId]
			  --,[vth_Quantity]
			  --,[vth_SalesLiteratureId]
			  --,[vth_ShipDate]

		SELECT 
		
			   OD.[dtInsertDate]
		      ,U.SystemUserId
			  ,OD.[dtModifiedDate]
			  ,U2.SystemUserId
			  ,(Select TeamId from CRM_Staging..CRM_TeamBase where name = 'Verathon') as 'OwnerID'
			  ,9
			  ,(select BusinessUnitId from CRM_BusinessUnitBase where Name = 'Verathon')

		FROM Onyx.dbo.OrderDetail OD WITH (NOLOCK) 
			-- Get SystemUserId for the record creator
			left join Onyx..NetWorkUser nu 
				on OD.chInsertBy = nu.chUserId
			left join CRM_Staging..Users U 
				on U.DomainName = nu.vchNetWorkUser
			
			-- Get SystemUserId for the record updator/modifier
			left join Onyx..NetWorkUser nu2 
				on OD.chUpdateBy = nu2.chUserId
			left join CRM_Staging..Users U2 
				on U2.DomainName = nu2.vchNetWorkUser		
		
		WHERE OD.tiRecordStatus = 1		
	
		
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

