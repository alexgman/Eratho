USE [CRM_staging] 

GO 

/****** Object:  StoredProcedure [dbo].[Pricelist_Import]    Script Date: 09/20/2012 14:15:35 ******/ 
SET ansi_nulls ON 

GO 

SET quoted_identifier ON 

GO 

IF Object_id('dbo.Pricelist_Import', N'P') IS NOT NULL 
  DROP PROCEDURE dbo.pricelist_import 

GO 

CREATE PROCEDURE [dbo].[Pricelist_import] (@LogId UNIQUEIDENTIFIER = NULL) 
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
  ** 2012-09-20       Vth.ramild    Updated to map to ProdPortal.dbo.Pricelist 
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
				CRM_SystemParameterExtensionbase
			WHERE
				gbs_name = 'LastRunDate'

          --Clear out the staging table 
          TRUNCATE TABLE crm_staging.dbo.pricelist 

          --Fill the staging table with the following Pricelist data 
          INSERT INTO [CRM_staging].[dbo].[pricelist] 
                      (organizationid, 
                       name, 
                       description, 
                       vth_visualbusinessentity, 
                       transactioncurrencyid, 
                       vth_verathonrefid) 
          SELECT (SELECT organizationid 
                  FROM   crm_businessunitbase 
                  WHERE  name = 'Headquarters (HQ)'), 
                 descr, 
                 descr, 
                 CASE( entity_dbname ) 
                   WHEN 'DXU' THEN 999990000 
                   WHEN 'DXUSM' THEN 999990004 
                   WHEN 'DXUUK' THEN 999990005 
                   WHEN 'VMFR' THEN 999990001 
                   WHEN 'DXUNL' THEN 999990002 
                   WHEN 'VMAU' THEN 999990003 
                 END AS vth_visualbusinessentity, 
                 (SELECT [CRM_Staging].[dbo].[Svf_getcurrency] (currency)), 
                 CONVERT(NVARCHAR(20), price_list_id) 
          FROM   [ProdPortal].[dbo].[pricelist] 
          WHERE  isactive = 1 
				AND
					DATEDIFF(hh,@LastRunDate,UpdateDt)>0

          UPDATE Stage 
          SET    Stage.pricelevelid = CRM.pricelevelid 
          FROM   crm_staging.dbo.pricelist Stage 
                 INNER JOIN crm_pricelevelextensionbase CRM 
                         ON CRM.vth_verathonrefid = Stage.vth_verathonrefid 
                                                    COLLATE 
                                                    latin1_general_ci_ai 
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