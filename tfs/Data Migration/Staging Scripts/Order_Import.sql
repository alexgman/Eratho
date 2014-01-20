USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Order_Import]    Script Date: 10/24/2012 17:27:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Order_Import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Order_Import]
GO

USE [CRM_Staging]
GO

/****** Object:  StoredProcedure [dbo].[Order_Import]    Script Date: 10/24/2012 17:27:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Order_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	Order_Import
** 
** Description:	Build Staging Data for table Order from ProdPortal for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-09-24		Inessa		Initial Creation
*/


BEGIN

BEGIN TRY

TRUNCATE TABLE CRM_Staging.dbo.[Order]

INSERT INTO CRM_Staging.dbo.[Order]
		(
	    SalesOrderId		
	  , OpportunityId
      , SubmitDate
	  , OwningBusinessUnit
      , SubmitStatusDescription
      , [OrderNumber]
	  , CreatedBy
      , [CreatedOn]
	  , ModifiedBy
      , [ModifiedOn]
      , [vth_BillToTaxExempt]
      , [vth_OrderType]
      , [vth_PONumber]
      , [vth_OrderNumber]
      )
SELECT 	
NEWID() as SalesOrderId		--uniqueidentifier
      ,(select OrganizationId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)') as OpportunityId
      ,a.SUBMIT_DATE as SubmitDate
	  ,(SELECT CASE  
		  WHEN b.Entity_DBName = 'dxu' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')
		  WHEN b.Entity_DBName = 'DXUUK' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'United Kingdom (UK)')
		  WHEN b.Entity_DBName = 'VMFR' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'France (FR)')
		  WHEN b.Entity_DBName = 'DXUNL' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Netherlands (EU)')
		  WHEN b.Entity_DBName = 'VMAU' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Australia (AU)')
		  WHEN b.Entity_DBName = 'DXUSM' THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Verathon Medical Canada (SBM)')
		  ELSE  (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')
	END ) as OwningBusinessUnit
      ,c.Descr as SubmitStatusDescription
      ,b.VisualOrderID [OrderNumber]
      ,e.SystemUserId as CreatedBy
      ,b.InsertDt as [CreatedOn]
      ,f.SystemUserId as ModifiedBy
      ,b.UpdateDt as [ModifiedOn]
      ,a.TAX_EXEMPT [vth_BillToTaxExempt]
      ,d.[OrderTypeCodeID] [vth_OrderType]
      ,a.PO_NUMBER [vth_PONumber]
      ,a.ORDER_ID [vth_OrderNumber] 
  
      FROM [ProdPortal].[dbo].[Portal_Order]				a
	  JOIN [ProdPortal].[dbo].[Orders]					b
	  ON b.OrderID = a.Order_ID 
	  LEFT JOIN [ProdPortal].[dbo].[ORDER_STATUS]		c
	  on a.STATUS_ID = c.STATUS_ID 
	  LEFT JOIN 
	  [ProdPortal].[dbo].[OrderTypes]					d
	  ON a.ORDER_TYPE = d.OrderTypeCode	
	  AND d.isActive = 1 and d.OrderTypeCode != ''
	  LEFT JOIN    [Users]												e
	  on b.InsertBy = e.DomainName
	  LEFT JOIN    [Users]												f
	  on b.UpdateBy = f.DomainName
WHERE c.Descr not in ('Cancel', 'Reject')
 
--Set CompanyID for the orders
update o
set  o.CustomerId = c.Accountid, o.CustomerIdType = 1
--select o.SalesOrderId, c.AccountId, c.AccountNumber
from [Order] o with (nolock)
	 join [ProdPortal].[dbo].[Orders] po
		on po.VisualOrderID = o.[OrderNumber]   --(341346 row(s) affected)
	 join [ProdPortal].[dbo].[Portal_Order] ppo
	    on ppo.ORDER_ID = po.OrderID
	 join Company c
				on c.AccountNumber = ppo.SOLD_TO_COMPANY

--Set SalesRepID, OwnerID
update o
set  o.vth_salesrepid  = coalesce(d.SystemUserId,e.SystemUserId),
o.OwnerID = CASE  
		  WHEN po.Entity_DBName = 'dxu' and o.CreatedBy IS NULL THEN 
										(select TeamId FROM CRM_TeamBase T  
										INNER JOIN CRM_BusinessUnitBase BU
										ON T.BusinessUnitId = BU.BusinessUnitId
										WHERE BU.Name = 'Headquarters (HQ)')

		  WHEN po.Entity_DBName != 'dxu' and o.CreatedBy IS NULL THEN  
										(select TeamId FROM CRM_TeamBase T   
										INNER JOIN CRM_BusinessUnitBase BU
										ON T.BusinessUnitId = BU.BusinessUnitId
										where bu.businessUnitID = o.OwningBusinessUnit)
		  ELSE o.CreatedBy 
		END  
--SELECT o.SalesOrderId,coalesce(d.SystemUserId,e.SystemUserId) as SystemUserId, 
--ppo.territory_rep_id,a.territory_id,a.rep_id 
FROM [Order]											o with (nolock)
JOIN
[ProdPortal].[dbo].[Orders] po
on po.ORDERID = o.[vth_OrderNumber]   --(341346 row(s) affected)
JOIN [ProdPortal].[dbo].[Portal_Order] ppo
on ppo.ORDER_ID = po.OrderID
LEFT JOIN  [ProdPortal].dbo.TerritoryRep	a
  on ppo.TERRITORY_REP_ID = a.TERRITORY_rep_ID 
LEFT JOIN prodportal.dbo.salesRep		b 
  on a.rep_id=b.rep_id 
LEFT JOIN [Onyx].[dbo].[NetWorkUser]					c
ON ltrim(rtrim(b.onyx_login)) = c.chUserId
LEFT JOIN  [Users]										d
ON c.vchNetWorkUser = d.DomainName
LEFT JOIN Users											e
on left(rtrim(ltrim(b.first_name)),3) = left(e.FirstName,3)
and rtrim(ltrim(b.last_name)) = e.LastName 


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


