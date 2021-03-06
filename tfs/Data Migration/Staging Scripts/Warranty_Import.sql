USE [CRM_Staging]
GO
/****** Object:  StoredProcedure [dbo].[Warranty_Import]    Script Date: 10/17/2012 19:29:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Warranty_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	Warranty_Import
** 
** Description:	Build Staging Data for table WArranty from Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-10-10		Inessa		Initial Creation
*/

BEGIN

BEGIN TRY

TRUNCATE TABLE dbo.Warranty

 INSERT INTO dbo.Warranty
(     [vth_warrantyId]
      ,[CreatedOn]
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
      ,[vth_name]
      ,[vth_CustomerProductId]
      ,[vth_StartDate]
      ,[vth_EndDate]
      ,[vth_Type]
  )
  
SELECT distinct
	NEWID() 
	,cp.[dtInsertDate] as CreatedOn
	,g.SystemUserId as [CreatedBy] 
	,cp.[dtUpdateDate] as ModifiedOn
	,e.OwningBusinessUnit as OwningBusinessUnit
	,j.SystemUserId as [ModifiedBy]
	,a.vchParameterDesc as vth_Name
	,e.vth_customerproductId as [vth_CustomerProductId]
	,cp.dtPurchaseDate as [vth_StartDate]
	,cast(case when ISDATE(cp.vchUser8) = 0 then NULL else cp.vchUser8 end as datetime) as [vth_EndDate]
	,c.ReferenceID as vth_Type
from onyx..CustomerProduct							cp
 left join  onyx.dbo.ReferenceDefinition			a
on cp.vchUser7 = a.iParameterId
left join onyx.dbo.ReferenceFields					b
on a.iReferenceId = b.iReferenceId 
left join tvf_ReferenceCode('vth_type', 'vth_warranty') c
on c.RefDesc  = a.vchParameterDesc 
LEFT JOIN CRM_Staging..Company					d
ON cp.iOwnerId =  d.AccountNumber
LEFT JOIN CustomerProduct							e
on e.vth_CompanyId = d.AccountId
and e.vth_SerialNumber = cp.vchSerialNumber 
and e.vth_PartNumber = cp.chProductNumber
and e.vth_PurchaseDate = cp.dtPurchaseDate 
and e.CreatedOn = cp.dtInsertDate 
LEFT JOIN [Onyx].[dbo].[NetWorkUser]			f
on cp.[chInsertBy] = f.chUserId
LEFT JOIN [Users]								g
on f.vchNetWorkUser = g.DomainName
LEFT JOIN [Onyx].[dbo].[NetWorkUser]			h
on cp.[chUpdateBy] = h.chUserId
LEFT JOIN [Users]								j
on h.vchNetWorkUser = j.DomainName
where cp.tiRecordStatus = 1 
and coalesce(cp.vchUser7,'') != '' 
and  b.vchFieldCaption = 'Warranty Type'

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