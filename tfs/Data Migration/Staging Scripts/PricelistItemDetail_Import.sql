USE [CRM_staging] 

GO 

/****** Object:  StoredProcedure [dbo].[Pricelist_Import]    Script Date: 09/20/2012 14:15:35 ******/ 
SET ansi_nulls ON 

GO 

SET quoted_identifier ON 

GO 

IF Object_id('dbo.PricelistItemDetail_Import', N'P') IS NOT NULL 
  DROP PROCEDURE dbo.pricelistitemdetail_import 

GO 

CREATE PROCEDURE [dbo].[Pricelistitemdetail_import] (@LogId UNIQUEIDENTIFIER = 
NULL) 
AS 
  /* 
  ** ObjectName:  User_Import 
  **  
  ** Description:  Build Staging Data from Onyx for processing into CRM  
  **         
  ** Revision History 
  ** -------------------------------------------------------------------------- 
  ** Date        Name      Description 
  ** -------------------------------------------------------------------------- 
  ** 2012-06-19    GBS.MMrad    Initial Creation 
  ** 2012-08-31       GBS.KHeiman    Simplified for Verathon baseline and use with SSIS 
  ** 2012-09-20       Vth.ramild    Updated to map to ProdPortal 
  ** 2012-11-08    GBS.PRogers    Added Required Fields 
  */ 
  BEGIN 
      SET nocount ON 

      --Run Sproc Logic 
      BEGIN TRY 
          --Declare Variables 
          DECLARE @dtCurrent DATETIME 

          --Get DEFAULT values 
          SELECT @dtCurrent = Getdate() 

          --Clear out the staging table 
          TRUNCATE TABLE crm_staging.dbo.pricelistitemdetail 

          --Fill the staging table with the following PricelistItemDetail data 
          INSERT INTO [CRM_staging].[dbo].[pricelistitemdetail] 
                      (vth_pricelistitemdetailid, 
                       organizationid, 
                       vth_name, 
                       vth_productid, 
                       vth_pricelistid, 
                       vth_minimumprice, 
                       statecode, 
                       statuscode, 
                       transactioncurrencyid) 
          SELECT Newid(), 
                 (SELECT organizationid 
                  FROM   crm_businessunitbase 
                  WHERE  name = 'Headquarters (HQ)') AS OrganizationId, 
                 StagingProduct.productnumber        AS vth_name, 
                 StagingProduct.productid            AS vth_productid, 
                 StagingPriceList.pricelevelid       AS vth_PriceListId, 
                 PP.min_price                        AS vth_minimumprice, 
                 0, 
                 1, 
                 (SELECT [CRM_Staging].[dbo].[Svf_getcurrency] (PL.currency)) 
          FROM   [ProdPortal].[dbo].[productprice] PP 
                 INNER JOIN [ProdPortal].[dbo].[pricelistversion] 
                            PLV 
                         ON PP.price_list_version_id = PLV.price_list_version_id 
                 INNER JOIN [ProdPortal].[dbo].[pricelist] PL 
                         ON PLV.price_list_id = PL.price_list_id 
                 INNER JOIN [ProdPortal].[dbo].[productentity] PE 
                         ON PL.entity_dbname = PE.entity_dbname 
                            AND PP.product_id = PE.product_id 
                 INNER JOIN pricelist AS StagingPriceList 
                         ON StagingPriceList.name = PL.descr 
                 INNER JOIN product AS StagingProduct 
                         ON StagingProduct.productnumber = PP.product_id 
          --AND CRMProduct.Description = PE.ProductDescription 
          WHERE  PL.isactive = 1 
                 AND PLV.status = 'C' 
          ORDER  BY PP.product_id 

          UPDATE Stage 
          SET    Stage.vth_pricelistitemdetailid = 
                 PLID.vth_pricelistitemdetailid 
          FROM   crm_staging.dbo.pricelistitemdetail Stage 
                 INNER JOIN crm_vth_pricelistitemdetailextensionbase PLID 
                         ON Stage.vth_productid = PLID.vth_productid 
                            AND Stage.vth_pricelistid = PLID.vth_pricelistid 
      END TRY 

      BEGIN CATCH 
      -- Log Row - ERROR 
      --SELECT  @Success    = 0, 
      --    @ErrorId    = ERROR_NUMBER(), 
      --    @ErrorMessage  = ERROR_MESSAGE() 
      --EXEC CRM_staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage 
      END CATCH

      -- Log Row - Stop 
      --SELECT @RowsProcessed = COUNT(1) FROM CRM_staging.dbo.Account WITH (NOLOCK) 
      --EXEC CRM_staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL 
      RETURN 1 --@Success 
  END 