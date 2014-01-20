USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Tracking_Import]    Script Date: 10/24/2012 17:32:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tracking_Import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Tracking_Import]
GO

USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Tracking_Import]    Script Date: 10/24/2012 17:32:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Tracking_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	Tracking_Import
** 
** Description:	Build Staging Data for table [Tracking] from DXU for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-09-24		Inessa		Initial Creation
*/


BEGIN

BEGIN TRY

TRUNCATE TABLE CRM_Staging.dbo.[Tracking]


  INSERT INTO  [CRM_Staging].[dbo].[Tracking]
      ([vth_trackingId]
      ,[CreatedOn]
      ,[OwningBusinessUnit]
      ,[vth_Carrier]
      ,[vth_CustomerPOReference]
      ,[vth_OrderNumber]
      ,[vth_TrackingNumber]
      ,[vth_Company]
      ,[vth_OrderId] )
SELECT
	NewID() as vth_trackingId
	,insert_date_time as CreatedOn
	,(select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)' ) as OwningBusinessUnit
	,a.vth_Carrier 
	,customer_po_ref
	,OrderNum
	,tracking_number as vth_TrackingNumber
	,b.CustomerId as customer_id
	,b.SalesOrderId as vth_OrderId
FROM 
	(SELECT OrderNum
	,tracking_number 
	,insert_date_time 
	,customer_id 
	,customer_po_ref 
	,(select ReferenceID from [tvf_ReferenceCode]('vth_Carrier','vth_tracking') where RefDesc = 'UPS') as vth_Carrier
	FROM dxu.dbo.Visual_UPS_Tracking 
	UNION ALL
	SELECT OrderNum
	,tracking_number 
	,insert_date_time 
	,customer_id 
	,customer_po_ref 
	,(select ReferenceID from [tvf_ReferenceCode]('vth_Carrier','vth_tracking') where RefDesc = 'FedEx') as vth_Carrier
	FROM  dxu.dbo.Visual_FedEx_Tracking
				  ) a
  join [Order]		b
  on a.OrderNum = b.OrderNumber 

END TRY

BEGIN CATCH
		-- Log Row - ERROR
		--SELECT	@Success		= 0,
		--		@ErrorId		= ERROR_NUMBER(),
		--		@ErrorMessage	= ERROR_MESSAGE()
		--EXEC CRM_Staging.dbo.DataMigrationLog_RowError @LogId,@RowId,@ErrorId,@ErrorMessage
	END CATCH

	 --Log Row - Stop
	--SELECT @RowsProcessed = COUNT(1) FROM CRM_Staging.dbo.Account WITH (NOLOCK)
	--EXEC CRM_Staging.dbo.DataMigrationLog_RowStop @LogId,@RowId,@Success,@RowsProcessed,NULL

	RETURN 1 --@Success
END


GO


