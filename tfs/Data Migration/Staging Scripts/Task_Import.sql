USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Task_Import]    Script Date: 10/24/2012 17:30:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Task_Import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Task_Import]
GO

USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Task_Import]    Script Date: 10/24/2012 17:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Task_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	Task_Import
** 
** Description:	Build Staging Data for table Task from ProdPortal for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-24		Inessa		Initial Creation
*/


BEGIN

BEGIN TRY

TRUNCATE TABLE [CRM_Staging].[dbo].[Task]



INSERt INTO [CRM_Staging].[dbo].[Task]
	   ( ActivityId
      ,[RegardingObjectId]
      ,[ScheduledEnd]
      ,[Description]
      ,[ImportSequenceNumber])
SELECT 
NEWID() as ActivityId
,a.SalesOrderId as RegardingObjectId
--a.OrderNumber,  ot.orderid
,ot.DueDate as ScheduledEnd
,ot.Descr as Description 
,seq  as ImportSequenceNumber
from prodportal.dbo.order_task ot
JOIN [Order] a
on ot.orderid = a.vth_OrderNumber 
order by RegardingObjectId
  
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


