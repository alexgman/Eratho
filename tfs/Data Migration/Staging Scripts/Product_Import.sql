USE [CRM_Staging] 

GO 

/****** Object:  StoredProcedure [dbo].[Product_Import]    Script Date: 11/06/2012 14:14:03 ******/ 
SET ansi_nulls ON 

GO 

SET quoted_identifier ON 

GO 

CREATE PROCEDURE [dbo].[Product_import] (@LogId UNIQUEIDENTIFIER = NULL) 
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
  ** 2012-09-20       Vth.ramild    Updated to map to ProdPortal.dbo.ProductEntity 
  ** 2012-10-15    GBS.KHeiman    updated / samples for re-use and re-running 
         
         NOTE - Need synonyms for UoMBase and UoMScheduleBase 
  */ 
  BEGIN 
      SET nocount ON 

      --Run Sproc Logic 
      BEGIN TRY 
          --Declare Variables 
          DECLARE @dtCurrent DATETIME,
				  @LastRunDate DATETIME 

          --Get DEFAULT values 
          SELECT @dtCurrent = Getdate() 
          SELECT @LastRunDate = CONVERT(DATETIME,ISNULL(gbs_value,'1990-01-01'))
					 FROM
						CRM_SystemParameterExtensionBase
					WHERE
						gbs_name = 'LastRunDate'

          --Clear out the staging table 
          TRUNCATE TABLE crm_staging.dbo.product 

          --Fill the staging table with the following product data 
          INSERT INTO [CRM_staging].[dbo].[product] 
                      (organizationid, 
                       defaultuomscheduleid, 
                       defaultuomid, 
                       productnumber, 
                       vth_warrantyproduct, 
                       producttypecode, 
                       quantitydecimal, 
                       statecode, 
                       statuscode, 
                       stockweight, 
                       vth_length, 
                       vth_width, 
                       vth_height, 
                       vth_shippingweight, 
                       vth_consolidate) 
          SELECT DISTINCT (SELECT TOP 1 organizationid 
                           FROM   crm_staging.dbo.crm_businessunitbase), 
                          (SELECT TOP 1 uomscheduleid 
                           FROM   crm_uombase), 
                          (SELECT TOP 1 uomid 
                           FROM   crm_uombase), 
                          pe.product_id, 
                          pe.iswarrantyproduct, 
                          1 --ProductTypeCode 
                          , 
                          2 --QuantityDecimal 
                          , 
                          0 --StateCode 
                          , 
                          1 --StatusCode 
                          , 
                          pd.productweight, 
                          pd.productlength, 
                          pd.productwidth, 
                          pd.productheight, 
                          pd.shippingweight, 
                          pd.consolidate 
          FROM   [ProdPortal].[dbo].[productentity] pe 
                 LEFT OUTER JOIN prodportal.dbo.productdimensions 
                                 pd 
                              ON pe.product_id = pd.productid 
          WHERE DATEDIFF(hh,@LastRunDate,pe.UpdateDT)>0

          --UPDATE GUIDs from CRM (via Synonym) where the record already exists. Join on Product Number which is unique (0001-0001, etc) 
          --this ensures no duplicate products (update instead of insert) in SSIS package 
          UPDATE crm_staging.dbo.product 
          SET    productid = crmProduct.productid 
          FROM   crm_staging.dbo.crm_productbase crmProduct 
          WHERE  crm_staging.dbo.product.productnumber COLLATE database_default 
                 = 
                 crmProduct.productnumber COLLATE database_default 

          UPDATE crm_staging.dbo.product 
          SET    vth_canhavewarranty = 1 
          WHERE  productnumber IN (SELECT product_id 
                                   FROM 
                 [ProdPortal].[dbo].[productentity] 
                                   WHERE  canhavewarranty = 1) 

          --update the description fields 
          --since we can have ONLY one product catalog item for each unique product number, populate the descriptions here
          --with the DXU descriptions, then UK, then NL, then AU, then FR for any products not yet matched. When quoting/ordering, different descriptions will be pulled based on the price list.
          --this is only for the main 'product catalog' descriptions, NOT the pricelist descriptions 
          UPDATE crm_staging.dbo.product 
          SET    name = dxu.productdescription, 
                 description = dxu.productdescription 
          --vth_orderDescription = dxu.ProductDescription 
          FROM   [ProdPortal].[dbo].[productentity] dxu 
          WHERE  crm_staging.dbo.product.productnumber = dxu.product_id 
                 AND productnumber = dxu.product_id 
                 AND entity_dbname = 'dxu' 

          UPDATE crm_staging.dbo.product 
          SET    name = dxu.productdescription, 
                 description = dxu.productdescription 
          FROM   [ProdPortal].[dbo].[productentity] dxu 
          WHERE  crm_staging.dbo.product.productnumber = dxu.product_id 
                 AND entity_dbname = 'dxuuk' 
                 AND Isnull(name, '') = '' 

          UPDATE crm_staging.dbo.product 
          SET    name = dxu.productdescription, 
                 description = dxu.productdescription 
          FROM   [ProdPortal].[dbo].[productentity] dxu 
          WHERE  crm_staging.dbo.product.productnumber = dxu.product_id 
                 AND entity_dbname = 'dxunl' 
                 AND Isnull(name, '') = '' 

          UPDATE crm_staging.dbo.product 
          SET    name = dxu.productdescription, 
                 description = dxu.productdescription 
          FROM   [ProdPortal].[dbo].[productentity] dxu 
          WHERE  crm_staging.dbo.product.productnumber = dxu.product_id 
                 AND entity_dbname = 'VMAU' 
                 AND Isnull(name, '') = '' 

          UPDATE crm_staging.dbo.product 
          SET    name = dxu.productdescription, 
                 description = dxu.productdescription 
          FROM   [ProdPortal].[dbo].[productentity] dxu 
          WHERE  crm_staging.dbo.product.productnumber = dxu.product_id 
                 AND entity_dbname = 'VMFR' 
                 AND Isnull(name, '') = '' 

          UPDATE crm_staging.dbo.product 
          SET    productid = CRM.productid 
          FROM   crm_staging.dbo.product Stage 
                 INNER JOIN crm_productbase CRM 
                         ON CRM.productnumber = Stage.productnumber COLLATE 
                                                latin1_general_ci_ai 
      END TRY 

      BEGIN Catch 
      -- Log Row - ERROR 
      --SELECT  @Success    = 0, 
      --    @ErrorId    = ERROR_NUMBER(), 
      --    @ErrorMessage  = ERROR_MESSAGE() 
      --EXEC CRM_staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage 
      END Catch 

      -- Log Row - Stop 
      --SELECT @RowsProcessed = COUNT(1) FROM CRM_staging.dbo.Account WITH (NOLOCK) 
      --EXEC CRM_staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL 
      RETURN 1 --@Success 
  END 