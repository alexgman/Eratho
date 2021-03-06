USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[ProductDetail_Import]    Script Date: 11/07/2012 20:02:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ProductDetail_Import]
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
** 2012-11-07		GBS.PRogers		Initial Creation

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
		TRUNCATE TABLE CRM_staging.dbo.ProductDetail
		
		--Fill the staging table with the following product data
		INSERT INTO [CRM_staging].[dbo].[ProductDetail]
           (OrganizationId
           ,vth_ProductEntityId
           ,vth_Name
           ,vth_VisualBusinessEntity
           ,vth_ProductId
           ,StateCode
           ,StatusCode
                    
		   )
		SELECT
		(
		SELECT TOP 1
			 OrganizationId 
	    FROM 
		 	 CRM_staging.dbo.CRM_BusinessUnitBase
		 ),
			pe.productentityid,
			pe.productdescription,
			dbo.tsf_GetOptionSetId('vth_visualbusinessentity','vth_productdetail', pe.entity_dbname),
			p.productid,
			0,
			1
	    FROM 
			[ProdPortal].[dbo].[ProductEntity] pe 
		LEFT OUTER JOIN
			crm_staging.dbo.product p
		ON 
			pe.Product_id = p.productnumber 
		
		
		
		

		
		
	END TRY
	BEGIN CATCH
		-- Log Row - ERROR
		--SELECT	@Success		= 0,
		--		@ErrorId		= ERROR_NUMBER(),
		--		@ErrorMessage	= ERROR_MESSAGE()
		--EXEC CRM_staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage
	END CATCH

	-- Log Row - Stop
	--SELECT @RowsProcessed = COUNT(1) FROM CRM_staging.dbo.Account WITH (NOLOCK)
	--EXEC CRM_staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL

	RETURN 1 --@Success
END
