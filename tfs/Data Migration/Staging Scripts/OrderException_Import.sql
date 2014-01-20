
CREATE PROCEDURE [dbo].[OrderException_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	OrderException_Import
** 
** Description:	Build Staging Data for OrderException table from ProdPortal for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-09-26       Vth.Inessa		Map to Onyx.dbo.OrderException
*/

BEGIN
	SET NOCOUNT ON
	
	--Run Sproc Logic
	BEGIN TRY
		--Declare Variables
		DECLARE	@dtCurrent							DATETIME

		--Get DEFAULT values
		SELECT	@dtCurrent							= GETDATE()

--	--Clear out the staging table
	TRUNCATE TABLE dbo.OrderException
		
	--Fill the staging table with the following Users data
	INSERT INTO dbo.OrderException
(--[createdby]
 [createdon]
  --,[createdonutc]
  --,[createdonbehalfby]
  --,[importsequencenumber]
  --,[modifiedby]
  --,[modifiedon]
  --,[modifiedonutc]
  --,[modifiedonbehalfby]
  --,[overriddencreatedon]
  --,[overriddencreatedonutc]
  --,[ownerid]
  --,[owneriddsc]
  --,[owneridtype]
  --,[owningbusinessunit]
  --,[owningteam]
  --,[owninguser]
  --,[statecode]
  ,[statuscode]
  --,[timezoneruleversionnumber]
  --,[utcconversiontimezonecode]
  --,[versionnumber]
  ,[vth_cleared]
  ,[vth_description]
  ,[vth_name]
  ,[vth_orderexceptionid]
  ,[vth_orderid]
)
SELECT  
a.[EXCEPTION_DATE] as [createdon]
,b.[EXCEPTION_STATUS] as [statuscode]
,CASE WHEN a.CLEARED_BY_ID IS NOT NULL THEN 1 ELSE 0 END  as [vth_cleared]
,b.descr as [vth_description]
,b.rule_name as [vth_name]
,NEWID()  as [vth_orderexceptionid]
,c.SalesOrderId as [vth_orderid]
FROM [ProdPortal].[dbo].[ORDERPROCESSINGRULEEXCEPTION]   a
JOIN [ProdPortal].[dbo].ORDERPROCESSINGRULE			    b
ON b.ORDER_PROCESSING_RULE_ID = a.ORDER_PROCESSING_RULE_ID	
and b.is_active = 1			
JOIN [Order]															c
ON a.[ORDER_ID] = c.vth_OrderNumber
  
--  select * from OrderException
	
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