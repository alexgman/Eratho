USE [CRM_staging] 

GO 

/****** Object:  StoredProcedure [dbo].[Pricelist_Import]    Script Date: 09/20/2012 14:15:35 ******/ 
SET ansi_nulls ON 

GO 

SET quoted_identifier ON 

GO 

IF Object_id('dbo.PricelistItem_Import', N'P') IS NOT NULL 
  DROP PROCEDURE dbo.pricelistitem_import 

GO 

CREATE PROCEDURE [dbo].[Pricelistitem_import] (@LogId UNIQUEIDENTIFIER = NULL) 
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
  ** 2012-11-01       Vth.ramild    Added more required fields 
  ** 2012-11-08    GBS.PRogers     Added more required fields 
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
          TRUNCATE TABLE crm_staging.dbo.pricelistitem 

          --Fill the staging table with the following PricelistItem data 
          INSERT INTO [CRM_staging].[dbo].[pricelistitem] 
                      (pricelevelid, 
                       uomid, 
                       uomscheduleid, 
                       productid, 
                       transactioncurrencyid, 
                       amount) 
          SELECT StagingPriceList.pricelevelid, 
                 (SELECT TOP 1 uomid 
                  FROM   crm_uombase)-- UoMBase 
                 , 
                 (SELECT TOP 1 uomscheduleid 
                  FROM   crm_uombase) --UoMScheduleBase 
                 , 
                 StagingProduct.productid, 
                 (SELECT [CRM_Staging].[dbo].[Svf_getcurrency] (PL.currency)), 
                 PP.list_price 
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
                         ON StagingPriceList.vth_verathonrefid = 
                            PL.price_list_id 
                 INNER JOIN product AS StagingProduct 
                         ON StagingProduct.productnumber = PP.product_id 
          --AND CRMProduct.Description = PE.ProductDescription 
          WHERE  PL.isactive = 1 
                 AND PLV.status = 'C' 
          ORDER  BY PP.product_id 

          UPDATE Stage 
          SET    Stage.productpricelevelid = PLI.productpricelevelid 
          FROM   crm_staging.dbo.pricelistitem Stage 
                 INNER JOIN crm_productpricelevelbase PLI 
                         ON Stage.productid = PLI.productid 
                            AND Stage.pricelevelid = PLI.pricelevelid 
      --select CRMPriceList.PriceLevelId 
      --,ProductId 
      ----,'14DF12DD-E1A7-42BC-84B9-0A5B30D3D7A5'  
      --from  [ProdPortal].[dbo].[Pricelistversion] as Version, 
      --      [ProdPortal].[dbo].[PriceList] as PriceList, 
      --      [ProdPortal].[dbo].[ProductPrice] as ProductPrice, 
      --      PriceList as CRMPriceList     , 
      --      Product as CRMProduct 
      --where PriceList.Price_list_id = version.Price_list_id 
      --and         [Version].status = 'C' 
      --and         [productprice].price_list_version_id = [version].price_list_version_id 
      --and       CRMPriceList.Name = PriceList.DESCR 
      --and       CRMProduct.ProductNumber = productprice.Product_ID 
      --and PriceList.IsActive = 1 
      END TRY 

      BEGIN catch 
      -- Log Row - ERROR 
      --SELECT  @Success    = 0, 
      --    @ErrorId    = ERROR_NUMBER(), 
      --    @ErrorMessage  = ERROR_MESSAGE() 
      --EXEC CRM_staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage 
      END catch 

      -- Log Row - Stop 
      --SELECT @RowsProcessed = COUNT(1) FROM CRM_staging.dbo.Account WITH (NOLOCK) 
      --EXEC CRM_staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL 
      RETURN 1 --@Success 
  END 