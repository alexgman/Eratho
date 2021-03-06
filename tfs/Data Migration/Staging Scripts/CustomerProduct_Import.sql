USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[CustomerProduct_Import]    Script Date: 10/17/2012 18:24:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CustomerProduct_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	CustomerProduct_Import
** 
** Description:	Build Staging Data for table CustomerProduct from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-03		Inessa		Initial Creation
*/

BEGIN

BEGIN TRY

 
TRUNCATE TABLE dbo.CustomerProduct

 INSERT INTO dbo.CustomerProduct
 
 --[vth_customerproductId]
 (     [CreatedOn]
      ,[CreatedBy]
      ,[ModifiedOn]
      ,[ModifiedBy]
      --,[CreatedOnBehalfBy]
      --,[ModifiedOnBehalfBy]
      --,[OwnerId]
      --,[OwnerIdType]
      ,[OwningBusinessUnit]
      --,[statecode]
      --,[statuscode]
      --,[VersionNumber]
      --,[ImportSequenceNumber]
      --,[OverriddenCreatedOn]
      --,[TimeZoneRuleVersionNumber]
      --,[UTCConversionTimeZoneCode]
      --,[vth_name]
      ,[vth_ProductId]
      ,[vth_OrderId]
      ,[vth_SerialNumber]
      ,[vth_PartNumber]
      --,[vth_ReturnAuth]
      ,[vth_CustomerProductStatus]
 --     ,[vth_Location]
 --     --,[vth_ContactId]
 --     --,[vth_Department]
 --     --,[vth_Return]
 --     --,[vth_Received]
 --     --,[vth_ProbeSerialNumber]
 --     --,[vth_LastCalibrationDate]
 --     --,[vth_BatteryReplacementDate]
 --     --,[vth_Floor]
      ,[vth_PurchaseDate]
 --     --,[vth_NextInvoiceDate]
      ,[vth_CompanyId]
      ,[RowAction]
)
--select * from tvf_ReferenceCode('vth_CustomerProductStatus', 'vth_customerproduct')

--select * FROM [Onyx].[dbo].[CustomerProduct]	
SELECT DISTINCT 
cp.[dtInsertDate] as CreatedOn
,d.[SystemUserId] as [CreatedBy] 
,cp.[dtUpdateDate] as ModifiedOn
,f.SystemUserId as [ModifiedBy]
,COALESCE(b.OwningBusinessUnit,
	case when h.cust_order_id IS not null or cp.chInsertBy = 'SerTranHQ' or c.vchNetWorkUser LIKE 'dxu\%'   THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)')  --'dxu'
	when h_dxunl.cust_order_id IS not null or cp.chInsertBy in ('SerTranNL','NL_Upload') or c.vchNetWorkUser LIKE 'nl\%'    THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Netherlands (EU)') --'dxunl'
	when h_dxuuk.cust_order_id IS not null or cp.chInsertBy = 'SerTranUK' or c.vchNetWorkUser LIKE 'uk\%'  THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'United Kingdom (UK)') -- 'dxuuk'
	when h_dxusm.cust_order_id IS not null or cp.chInsertBy = 'SerTranSM' or c.vchNetWorkUser LIKE 'sm\%'  THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Verathon Medical Canada (SBM)') -- 'dxusm'
	when h_vmfr.cust_order_id IS not null  or cp.chInsertBy in ('SerTranFR', 'FR_Ser_Upl') or c.vchNetWorkUser LIKE 'fr\%'  THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'France (FR)')
	when h_vmau.cust_order_id IS not null  or cp.chInsertBy = 'SerTranAU' or c.vchNetWorkUser LIKE 'au\%'  THEN (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Australia (AU)')--'vmau'
	ELSE  (select BusinessUnitId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)') END ) as OwningBusinessUnit
,k.ProductId   as [vth_ProductId]
,b.SalesOrderId 	as [vth_OrderId]
,cp.[vchSerialNumber] as [vth_SerialNumber]
,cp.[chProductNumber] as [vth_PartNumber]
,n.ReferenceID  AS  [vth_CustomerProductStatus]
,cp.[dtPurchaseDate] as [vth_PurchaseDate]
,g.AccountId as  [vth_CompanyId]
,cp.[tiRecordStatus]  as RowAction 
--select cp.iStatusId, a.*, b.* ,c.*
FROM [Onyx].[dbo].[CustomerProduct]				cp
LEFT JOIN [Order]								b
ON case when CHARINDEX ( '/' ,[vchUser1]) > 0  then rtrim(left([vchUser1],CHARINDEX ( '/' ,[vchUser1])-1)) 
   else [vchUser1] end = b.OrderNumber
LEFT JOIN [Onyx].[dbo].[NetWorkUser]			c
ON cp.[chInsertBy] = c.chUserId
LEFT JOIN [Users]								d
ON c.vchNetWorkUser = d.DomainName
LEFT JOIN [Onyx].[dbo].[NetWorkUser]			e
ON cp.[chUpdateBy] = e.chUserId
LEFT JOIN [Users]								f
ON c.vchNetWorkUser = f.DomainName
LEFT JOIN CRM_Staging..Company				g
ON cp.iOwnerId =  g.AccountNumber
LEFT JOIN dxu.dbo.djb_shippedSerializedItems    h
ON 
--  get rid of duplicates from 2007-2008
 case when h.trace_id = 'P7001163' and h.part_id = '0270-0636' then 'A7001163'
      when h.trace_id = 'P7001164' and h.part_id = '0270-0636' then 'A7001164'
	  else h.trace_id end 
 = case when cp.vchSerialNumber = 'P7001163' and cp.chProductNumber = 'AS9700' then 'A7001163' else cp.vchSerialNumber end 
AND  h.customer_id = cast(cp.iOwnerId as varchar(15))
LEFT JOIN dxunl.dbo.djb_shippedSerializedItems   h_dxunl
ON h_dxunl.trace_id  = cp.vchSerialNumber
AND  h_dxunl.customer_id = cast(cp.iOwnerId as varchar(15)) 
LEFT JOIN dxuuk.dbo.djb_shippedSerializedItems   h_dxuuk
ON h_dxuuk.trace_id  = cp.vchSerialNumber
AND  h_dxuuk.customer_id = cast(cp.iOwnerId as varchar(15)) 
LEFT JOIN dxusm.dbo.djb_shippedSerializedItems   h_dxusm
ON h_dxusm.trace_id  = cp.vchSerialNumber
AND  h_dxusm.customer_id = cast(cp.iOwnerId as varchar(15))
LEFT JOIN vmfr.dbo.djb_shippedSerializedItems    h_vmfr
ON h_vmfr.trace_id  = cp.vchSerialNumber
AND  h_vmfr.customer_id = cast(cp.iOwnerId as varchar(15)) 
LEFT JOIN vmfr.dbo.djb_shippedSerializedItems    h_vmau
ON h_vmau.trace_id  = cp.vchSerialNumber
AND  h_vmau.customer_id = cast(cp.iOwnerId as varchar(15))
LEFT JOIN dbo.Product										k
ON 
-- to get rid of SerialNo/ProductNo duplicates for years 2007-2008
case when coalesce(h.part_id, h_dxunl.part_id, h_dxuuk.part_id,h_dxusm.part_id, h_vmfr.part_id, h_vmau.part_id) 
	IN ( '0570-0174', '0570-0176')  and year([dtPurchaseDate]) in (2008, 2009) then '0270-0292' 
 when coalesce(h.part_id, h_dxunl.part_id, h_dxuuk.part_id,h_dxusm.part_id, h_vmfr.part_id, h_vmau.part_id) = '0003-0284'  
	and  cp.[chProductNumber] = 'BVI6100' and year([dtPurchaseDate]) in (2006, 2007, 2008)  
 then '0270-0284'  
 when coalesce(h.part_id, h_dxunl.part_id, h_dxuuk.part_id,h_dxusm.part_id, h_vmfr.part_id, h_vmau.part_id) 
	IN ('0270-0292','0570-0188') and  cp.[chProductNumber] = 'BVI9400' and year([dtPurchaseDate]) 	in (2006, 2007, 2008)  
 then '0270-0405' 
 when coalesce(h.part_id, h_dxunl.part_id, h_dxuuk.part_id,h_dxusm.part_id, h_vmfr.part_id, h_vmau.part_id) 
	IN ('0270-0405','0570-0174') and  cp.[chProductNumber] = 'BVI9400/9600-PROBE' and year([dtPurchaseDate])in (2006, 2007, 2008) 
 then '0570-0188'
 when coalesce(h.part_id, h_dxunl.part_id, h_dxuuk.part_id,h_dxusm.part_id, h_vmfr.part_id, h_vmau.part_id) in ('0270-0405','0570-0188') 
	and cp.[chProductNumber] in ('FP-Elite-Sensor','FP-Elite-Remote')and year([dtPurchaseDate]) in (2006, 2007, 2008)  
 then '0270-0292'
 when coalesce(h.part_id, h_dxunl.part_id, h_dxuuk.part_id,h_dxusm.part_id, h_vmfr.part_id, h_vmau.part_id) in ('0270-0626') 
	and cp.[chProductNumber] in ('PHANTOM-STRING') and year([dtPurchaseDate]) in (2006, 2007, 2008)  
 then '0620-0156'
 else 
 coalesce(h.part_id, h_dxunl.part_id, h_dxuuk.part_id,h_dxusm.part_id, h_vmfr.part_id, h_vmau.part_id) end = k.ProductNumber 
 
 left join  onyx.dbo.ReferenceDefinition			l
on cp.iStatusId  = l.iParameterId
left join onyx.dbo.ReferenceFields					m
on l.iReferenceId = m.iReferenceId and m.chFieldName  = 'product.status'   
left join tvf_ReferenceCode('vth_CustomerProductStatus', 'vth_customerproduct') n
on n.RefDesc  = l.vchParameterDesc 
 WHERE cp.[tiRecordStatus] = 1

--DXU entity
update crm_cp
set [vth_ProductId] = c.ProductId 
--select  k.ProductNumber
FROM CustomerProduct					crm_cp
join [Onyx].[dbo].[CustomerProduct]			cp
on crm_cp.vth_SerialNumber = cp.vchSerialNumber 
and crm_cp.vth_PurchaseDate = cp.[dtPurchaseDate]
and crm_cp.[vth_PartNumber] = cp.chProductNumber
and cp.[dtInsertDate] =  crm_cp.CreatedOn
and cp.[dtUpdateDate] =  crm_cp.[ModifiedOn]
join onyx..djb_productFamilyPartsMap		a
on cp.chProductNumber = a.family 
join dxu.dbo.SerializedItems   b
on a.chProductNumber = b.part_id 
and cp.vchSerialNumber = b.trace_id
and DateAdd(day, datediff(day,0, cp.[dtPurchaseDate]), 0) = b.order_date
JOIN dbo.Product							c					
on c.ProductNumber = b.part_id
where crm_cp.[vth_ProductId] is null 

--DXUNL entity
update crm_cp
set [vth_ProductId] = c.ProductId 
FROM CustomerProduct					crm_cp
join [Onyx].[dbo].[CustomerProduct]			cp
on crm_cp.vth_SerialNumber = cp.vchSerialNumber 
and crm_cp.vth_PurchaseDate = cp.[dtPurchaseDate]
and crm_cp.[vth_PartNumber] = cp.chProductNumber
and cp.[dtInsertDate] =  crm_cp.CreatedOn
and cp.[dtUpdateDate] =  crm_cp.[ModifiedOn]
join onyx..djb_productFamilyPartsMap		a
on cp.chProductNumber = a.family 
join dxunl.dbo.SerializedItems   b
on a.chProductNumber = b.part_id
and cp.vchSerialNumber = b.trace_id
and DateAdd(day, datediff(day,0, cp.[dtPurchaseDate]), 0) = b.order_date
JOIN dbo.Product							c					
on c.ProductNumber = b.part_id
where crm_cp.[vth_ProductId] is null 

--DXUUK entity
update crm_cp
set [vth_ProductId] = c.ProductId 
FROM CustomerProduct					crm_cp
join [Onyx].[dbo].[CustomerProduct]			cp
on crm_cp.vth_SerialNumber = cp.vchSerialNumber 
and crm_cp.vth_PurchaseDate = cp.[dtPurchaseDate]
and crm_cp.[vth_PartNumber] = cp.chProductNumber
and cp.[dtInsertDate] =  crm_cp.CreatedOn
and cp.[dtUpdateDate] =  crm_cp.[ModifiedOn]
join onyx..djb_productFamilyPartsMap		a
on cp.chProductNumber = a.family 
join dxuuk.dbo.SerializedItems   b
on a.chProductNumber = b.part_id 
and cp.vchSerialNumber = b.trace_id
and DateAdd(day, datediff(day,0, cp.[dtPurchaseDate]), 0) = b.order_date
JOIN dbo.Product							c					
on c.ProductNumber = b.part_id
where crm_cp.[vth_ProductId] is null 

--DXUSM entity
update crm_cp
set [vth_ProductId] = c.ProductId 
FROM CustomerProduct					crm_cp
join [Onyx].[dbo].[CustomerProduct]			cp
on crm_cp.vth_SerialNumber = cp.vchSerialNumber 
and crm_cp.vth_PurchaseDate = cp.[dtPurchaseDate]
and crm_cp.[vth_PartNumber] = cp.chProductNumber
and cp.[dtInsertDate] =  crm_cp.CreatedOn
and cp.[dtUpdateDate] =  crm_cp.[ModifiedOn]
join onyx..djb_productFamilyPartsMap		a
on cp.chProductNumber = a.family 
join dxusm.dbo.SerializedItems   b
on a.chProductNumber = b.part_id 
and cp.vchSerialNumber = b.trace_id
and DateAdd(day, datediff(day,0, cp.[dtPurchaseDate]), 0) = b.order_date
JOIN dbo.Product							c					
on c.ProductNumber = b.part_id
where crm_cp.[vth_ProductId] is null 

--VMAU entity
update crm_cp
set [vth_ProductId] = c.ProductId 
FROM CustomerProduct					crm_cp
join [Onyx].[dbo].[CustomerProduct]			cp
on crm_cp.vth_SerialNumber = cp.vchSerialNumber 
and crm_cp.vth_PurchaseDate = cp.[dtPurchaseDate]
and crm_cp.[vth_PartNumber] = cp.chProductNumber
and cp.[dtInsertDate] =  crm_cp.CreatedOn
and cp.[dtUpdateDate] =  crm_cp.[ModifiedOn]
join onyx..djb_productFamilyPartsMap		a
on cp.chProductNumber = a.family 
join VMAU.dbo.SerializedItems   b
on a.chProductNumber = b.part_id 
and cp.vchSerialNumber = b.trace_id
and DateAdd(day, datediff(day,0, cp.[dtPurchaseDate]), 0) = b.order_date
JOIN dbo.Product							c					
on c.ProductNumber = b.part_id
where crm_cp.[vth_ProductId] is null 

--VMFR entity
update crm_cp
set [vth_ProductId] = c.ProductId 
FROM CustomerProduct					crm_cp
join [Onyx].[dbo].[CustomerProduct]			cp
on crm_cp.vth_SerialNumber = cp.vchSerialNumber 
and crm_cp.vth_PurchaseDate = cp.[dtPurchaseDate]
and crm_cp.[vth_PartNumber] = cp.chProductNumber
and cp.[dtInsertDate] =  crm_cp.CreatedOn
and cp.[dtUpdateDate] =  crm_cp.[ModifiedOn]
join onyx..djb_productFamilyPartsMap		a
on cp.chProductNumber = a.family 
join VMFR.dbo.SerializedItems   b
on a.chProductNumber = b.part_id 
and cp.vchSerialNumber = b.trace_id
and DateAdd(day, datediff(day,0, cp.[dtPurchaseDate]), 0) = b.order_date
JOIN dbo.Product							c					
on c.ProductNumber = b.part_id
where crm_cp.[vth_ProductId] is null 

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

