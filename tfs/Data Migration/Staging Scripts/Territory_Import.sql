USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[Territory_Import]    Script Date: 10/17/2012 19:09:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Territory_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	Territory_Import
** 
** Description:	Build Staging Data for table Territory from ProdPortal for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-15		Inessa		Initial Creation
*/

BEGIN

BEGIN TRY

TRUNCATE TABLE CRM_Staging.dbo.[Territory]

 INSERT INTO [Territory]
	(	[TerritoryId]
      ,[OrganizationId]
      ,[ManagerId]
      ,[Name]
      ,[Description]
      --,[CreatedOn]
      --,[CreatedBy]
      --,[ModifiedBy]
      --,[ModifiedOn]
      --,[VersionNumber]
      --,[ImportSequenceNumber]
      --,[OverriddenCreatedOn]
      --,[TransactionCurrencyId]
      --,[ModifiedOnBehalfBy]
      --,[CreatedOnBehalfBy]
      --,[ExchangeRate]
      --,[vth_MarketSectorId]
      --,[vth_Product]
      ,[vth_VisualBusinessEntity]
      --,[vth_Country]
      )
      
SELECT 
 NEWID()as TerritoryId
,(select OrganizationId from CRM_BusinessUnitBase where name = 'Headquarters (HQ)') as OrganizationId
,SystemUserId as ManagerId
,CODE as Name
,DESCR as Description
-- table-valued function
,(SELECT ReferenceID from tvf_ReferenceCode('vth_VisualBusinessEntity', 'Territory') where RefDesc = COALESCE(BusUnit_NetworkUser, BusUnit_Descr,'DXU'))
FROM 
(
SELECT ROW_NUMBER() OVER(PARTITION BY a.territory_id ORDER BY a.territory_id,b.begin_date desc ) as RowNo
,a.CODE
,a.DESCR
,a.territory_id,c.onyx_login
,e.SystemUserId
,case WHEN vchNetWorkUser LIKE 'uk\%' THEN 'DXUUK'
      WHEN vchNetWorkUser LIKE 'fr\%' THEN 'VMFR'
      WHEN vchNetWorkUser LIKE 'nl\%' THEN 'DXUNL'
      WHEN vchNetWorkUser LIKE 'au\%'  THEN 'VMAU'
      WHEN vchNetWorkUser LIKE 'sm\%' THEN 'DXUSM'
      WHEN vchNetWorkUser LIKE 'dxu\%' THEN 'DXU'
      ELSE vchNetWorkUser  END  as BusUnit_NetworkUser
,case when a.DESCR LIKE '%UK %'   THEN 'DXUUK'
	when a.DESCR LIKE '%eu %'    THEN 'DXUNL'
	when  a.DESCR LIKE '%canada %'  THEN 'DXUSM'
	when  a.DESCR LIKE '%France%'  THEN 'VMFR'
	when  a.DESCR LIKE '%Australia%'  THEN 'VMAU'
	ELSE  NULL END as BusUnit_Descr
,b.REP_ID
,a.BEGIN_DATE , a.END_DATE 
FROM prodportal.dbo.Territory			a
LEFT JOIN prodportal.dbo.TerritoryRep		b
ON a.TERRITORY_ID = b.TERRITORY_ID and b.END_DATE > GETDATE() and rep_id != 105
LEFT JOIN  prodportal.dbo.salesrep		c
ON b.REP_ID = c.REP_ID  and c.END_DATE > GETDATE()
LEFT JOIN [Onyx].[dbo].[NetWorkUser]					d
ON ltrim(rtrim(c.onyx_login)) = d.chUserId
LEFT JOIN  [Users]										e
ON d.vchNetWorkUser = e.DomainName
WHERE a.END_DATE > GETDATE() 
) x
where RowNo = 1 

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

      
 