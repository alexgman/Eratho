
USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[CustomerLiterature_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.Users_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.CustomerLiterature_Import
GO 

CREATE PROCEDURE [dbo].[CustomerLiterature_Import]
--(
--	@LogId UNIQUEIDENTIFIER = NULL
--)
AS


/*
** ObjectName:	CustomerLiterature_Import
** 
** Description:	Build Staging Data from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ericl		Updated to map to Onyx.dbo.OrderHeader
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
		TRUNCATE TABLE CRM_Staging.dbo.CustomerLiterature
		
		--Fill the staging table with the following CustomerLiterature data
		INSERT INTO [CRM_Staging].[dbo].[CustomerLiterature]
        (
		   --[vth_customerliteratureId]
		  [CreatedOn]
		  ,[CreatedBy]
		  ,[ModifiedOn]
		  ,[ModifiedBy]
		  --,[CreatedOnBehalfBy]
		  --,[ModifiedOnBehalfBy]
		  ,[OwnerId]
		  ,[vth_OrderId]
		  ,[OwnerIdType]
		  ,[OwningBusinessUnit]
		  --,[statecode]
		  --,[statuscode]
		  --,[VersionNumber]
		  --,[ImportSequenceNumber]
		  --,[OverriddenCreatedOn]
		  --,[TimeZoneRuleVersionNumber]
		  --,[UTCConversionTimeZoneCode]
		  ,[vth_CompanyId]
		  ,[vth_name]
		  --,[vth_AddressType]
		  ,[vth_ShipTo]
		  --,[vth_ShipMethod]
		  --,[vth_Priority]
		  ,[vth_Comments]
		  --,[vth_CustomerReference]
		  ,[vth_Fax]
		  --,[vth_CampaignId]
        )
 
  SELECT
		       a.[dtInsertDate]
		      ,U.SystemUserId
			  ,a.[dtModifiedDate]
			  ,U2.SystemUserId
			  ,(Select TeamId from CRM_Staging..CRM_TeamBase where name = 'Verathon') as 'OwnerID'			  
			  ,a.[iOrderId]
			  ,9
			  ,(select BusinessUnitId from CRM_Staging..CRM_BusinessUnitBase where Name = 'Verathon')
              ,null --[CompanyId]	
			  ,LEFT([vchShipToAddress1] , 200)
			  ,LEFT([vchShipToAddress2] + ',' + [vchShipToAddress3]    + ',' +  [vchShipToAddress4] + ',' +  [vchShipToAddress5] + ',' +  [vchShipToAddress6], 200)
			  ,LEFT([vchHeaderComment1], 200)
			  ,a.[vchFaxPhoneNumber]
			  
	
	 FROM Onyx.dbo.OrderHeader a
			-- Get SystemUserId for the record creator
			left join Onyx..NetWorkUser nu 
				on a.chInsertBy = nu.chUserId
			left join CRM_Staging..Users U 
				on U.DomainName = nu.vchNetWorkUser
			
			-- Get SystemUserId for the record updator/modifier
			left join Onyx..NetWorkUser nu2 
				on a.chUpdateBy = nu2.chUserId
			left join CRM_Staging..Users U2 
				on U2.DomainName = nu2.vchNetWorkUser

	 WHERE tiRecordStatus = 1 
		

		
	END TRY
	BEGIN CATCH
		--Log Row - ERROR
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

