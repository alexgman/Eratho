GO
/****** Object:  StoredProcedure [dbo].[Users_Import]    Script Date: 09/20/2012 14:15:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.Users_Import', N'P') IS NOT NULL
	DROP PROCEDURE dbo.Users_Import
GO 

CREATE PROCEDURE [dbo].[Users_Import]
(
	@LogId UNIQUEIDENTIFIER = NULL
)
AS

/*
** ObjectName:	User_Import
** 
** Description:	Build Staging Data FROM Onyx for processing into CRM 
**				
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 2012-06-19		GBS.MMrad		Initial Creation
** 2012-08-31       GBS.KHeiman		Simplified for Verathon baseline and use with SSIS
** 2012-09-20       Vth.ramild		Updated to map to Onyx.dbo.Users
** 2012-11-15		GBS.AdhisG		1. If the user exists in CRM then update SystemUserid in the staging table.
									2. Fixes to user assignment to a BU based upon their Onyx group and domain name.
** 2012-11-20		GBS.AdhishG		Fixed the SELECT query to get only unique UserId records from Onyx.Users table.
									

EXEC Users_Import
select distinct u.chGroupId from Onyx.dbo.users u
left outer join Onyx.dbo.NetworkUser nu on u.chuserid = nu.chUserid
where u.chUserId in 
(select vth_Onyxuserid from Users
	where businessunitid is null)
	
select * from Onyx.dbo.users u
	where u.chUserid like '%uk%cleanup%'
*/

BEGIN
	SET NOCOUNT ON
	
	--Run Sproc Logic
	BEGIN TRY
		--Declare Variables
		DECLARE	@dtCurrent							DATETIME

		--Get DEFAULT values
		SELECT	@dtCurrent							= GETDATE()
		
		--Clear out the staging table
		TRUNCATE TABLE CRM_Staging.dbo.Users
		
		--Fill the staging table with the following Users data
		INSERT INTO [CRM_Staging].[dbo].[Users]
           ([SystemUserId]
           ,[OrganizationId]
           ,[BusinessUnitId]
           ,[FirstName]
           ,[LastName]
           ,[FullName]
           --,[Title]
           ,[InternalEMailAddress]
           --,[JobTitle]
           --,[HomePhone]
           --,[MobilePhone]
           ,[DomainName]
           --,[EmployeeId]
           --,[IsDisabled]
           --,[IncomingEmailDeliveryMethod]
           --,[OutgoingEmailDeliveryMethod]
           --,[IsActiveDirectoryUser]
           , vth_OnyxUserId
           , OnyxStatus
        )
		SELECT NEWID(),
				(SELECT TOP 1 OrganizationId FROM CRM_OrganizationBase),
				CASE  
					WHEN LTRIM(RTRIM(vchNetWorkUser)) LIKE 'dxu\%' OR vchNetWorkUser LIKE 'jp.%' OR vchNetWorkUser LIKE 'jp%' 
						THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Headquarters (HQ)')
					WHEN vchNetWorkUser LIKE 'uk\%' THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'United Kingdom (UK)')
					WHEN vchNetWorkUser LIKE 'fr\%' THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'France (FR)')
					WHEN vchNetWorkUser LIKE 'nl\%' THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Netherlands (EU)')
					WHEN vchNetWorkUser LIKE 'au\%' THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Australia (AU)')
					WHEN vchNetWorkUser LIKE 'sm\%' THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Verathon Medical Canada (SBM)')
					WHEN u.chGroupId IN ('salesgerman','salegerman', 'SALES_EURO','SalesItaly','SalesSpain') 
						THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Netherlands (EU)')
					WHEN u.chGroupId IN ('SALES_FR') THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'France (FR)')
					WHEN u.chGroupId IN ('SALES_AU','SALES_AU_E','SALES_AU_N','SALES_AU_S','SALES_AU_W') THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Australia (AU)')
					WHEN u.chGroupId IN ('SALES_CAN') THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Verathon Medical Canada (SBM)')
					WHEN u.chGroupId IN ('UK','SALES_EC_E','SALES_EC_N','SALES_EC_S','SALES_EC_W') 
						THEN (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'United Kingdom (UK)')
					ELSE (SELECT BusinessUnitId FROM CRM_BusinessUnitBase WHERE name = 'Headquarters (HQ)')
				END
				,
				SUBSTRING(u.chUserName,1,charindex(' ',U.chUserName)-1),
				SUBSTRING(U.chUserName,charindex(' ',U.chUserName)+1,LEN(U.chUserName)),
				u.chUserName,
				u.vchEmailAlias,
				nu.vchNetWorkUser,
				u.chUserId,
				u.tiRecordStatus			
		FROM Onyx.dbo.Users U
			LEFT OUTER JOIN Onyx.dbo.NetWorkUser NU 
				ON U.chUserId = NU.chUserId
			LEFT OUTER JOIN Onyx.dbo.groups g (NOLOCK)
				ON g.chGroupId = u.chGroupId
		WHERE (U.chUserId														-- GBS.AdhishG: Some userIds in Onyx Users table have duplicate records (present more than once).
					+ ISNULL(CONVERT(NVARCHAR(20), U.dtLastLoginDate), '')		-- We are getting the latest record for each unique UserId based upon Users.dtLastLoginDate,
					+ ISNULL(CONVERT(NVARCHAR(20), NU.dtUpdateDate), '')		 --NetworkUsers.dtUpdateDate and Users.dtUpdateDate
					+ ISNULL(CONVERT(NVARCHAR(20), U.dtUpdateDate), '')) =
					(SELECT TOP 1 U1.chUserId 
							+ ISNULL(CONVERT(NVARCHAR(20), U1.dtLastLoginDate), '')
							+ ISNULL(CONVERT(NVARCHAR(20), NU1.dtUpdateDate), '')
							+ ISNULL(CONVERT(NVARCHAR(20), U1.dtUpdateDate), '')
						FROM Onyx.dbo.Users U1
							LEFT OUTER JOIN Onyx.dbo.NetWorkUser NU1
								ON U1.chUserId = NU1.chUserId
						WHERE U.chUserId = U1.chUserId
						ORDER BY U1.chUserId,	
							U1.dtLastLoginDate DESC,
							NU1.dtUpdatedate DESC,
							U1.dtUpdateDate DESC)
				--AND u.tiRecordStatus = 1
		   
		--GBS.Adhish: Update the SystemUserId in stage if the user is already present in CRM
		UPDATE U
			SET SystemUserId = CRM.SystemUserId
		FROM Users U	
			INNER JOIN Onyx.dbo.NetWorkUser NU WITH (NOLOCK) 
				ON U.vth_OnyxUserId = NU.chUserId COLLATE Latin1_General_CI_AI
			INNER JOIN CRM_SystemUserBase CRM
				ON NU.vchNetWorkUser = CRM.DomainName COLLATE Latin1_General_CI_AI		
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

