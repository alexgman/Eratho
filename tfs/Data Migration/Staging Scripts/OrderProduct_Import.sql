USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[OrderProduct_Import]    Script Date: 09/26/2012 14:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OrderProduct_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	OrderProduct_Import
** 
** Description:	Build Staging Data for table OrderProduct from ProdPortal for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-09-25		Inessa		Initial Creation
*/


BEGIN

BEGIN TRY

TRUNCATE TABLE [CRM_Staging].[dbo].[OrderProduct]
 
  INSERT INTO CRM_Staging.dbo.[OrderProduct] 
(
	   [SalesOrderDetailId]
      ,[SalesOrderId]
      ,[LineItemNumber]
      ,[ProductId]
      ,[Quantity]
      ,[PricePerUnit]
      ,[ManualDiscountAmount]
      ,[ProductDescription]
      ,[Description]
      ,[vth_WarrantyStart]
      ,[vth_WarrantyEnd]
      ,[vth_TaxGroup]
      ,[vth_Serial1]
      ,[vth_Serial2]
)
  SELECT 
   NewId() as [SalesOrderDetailId] 
 ,c.[SalesOrderId] as [SalesOrderId]
 ,a.[LINE_NO] as [LineItemNumber]
 ,b.ProductId as [PRODUCT_ID]
 ,a.[QUANTITY_ORDERED] as [Quantity]
 ,a.[UNIT_PRICE] as PricePerUnit
 ,a.[DISCOUNT_AMOUNT] as ManualDiscountAmount
 ,b.Description as [ProductDescription]
,a.[DESCR] as [Description]
,a.[WARRANTY_BEGIN]  as vth_WarrantyStart
,a.[WARRANTY_END] as vth_WarrantyEnd
,a.[TAX_JURISDICTION] AS [vth_TaxGroup]
,a.[SERIAL_NO] as vth_Serial1
,a.[SERIAL_NO2] as vth_Serial2

FROM [ProdPortal].[dbo].[ORDER_LINE] a
left join [Product]									b
on a.Product_Id = b.ProductNumber
and a.[DESCR] = b.Description          --temporary, need to have entity field
JOIN [Order]										c
on a.order_id = c.vth_OrderNumber
 
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
 
  