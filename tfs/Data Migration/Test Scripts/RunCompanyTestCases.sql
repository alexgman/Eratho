USE [CRM_Staging]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RunCompanyTestCases]') AND type in (N'P', N'PC'))
BEGIN
          DROP PROCEDURE [dbo].[RunCompanyTestCases]
END
GO
/****** Object:  StoredProcedure [dbo].[RunCompanyTestCases]    Script Date: 11/12/2012 22:06:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET NOCOUNT ON
GO
/* =============================================
-- Author:		Paul Rogers
-- Create date: Oct 17,2012
-- Description:	This matches the number rows in the staging table with the number of rows in the CRM/Onyx Company tables to verify that all rows were imported

	EXEC RunCompanyTestCases
-- ============================================= */
CREATE PROCEDURE [dbo].[RunCompanyTestCases]	
AS
BEGIN
	DECLARE 
		@StagingTableName VARCHAR(75),
		@CRMTableName VARCHAR(75),
		@StageCount INT, 
		@CRMCount INT,
		@OnyxCount INT,
		@ValidationMessage VARCHAR(MAX)
	
	BEGIN TRY		
	    
		/**************************************************************************
			Validation for Companies
		**************************************************************************/
		--Test Case 1. Compare total counts	
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountBase (NOLOCK)
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company (NOLOCK)
				WHERE tiRecordStatus = 1

		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 1: Compare total counts between Staging table and CRM . Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			 INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'CRM'
			)
		END   
		
		--Test Case2: Compare total counts between Onyx and staging table.
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 2: Compare total counts between Onyx and Staging table. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'Onyx'
			)
		END	
		
		--Test Case 3. Compare total counts of records with a value in source between staging table and CRM.
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
				WHERE vth_Source IS NOT NULL
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountExtensionBase (NOLOCK)
				WHERE vth_Source IS NOT NULL
			
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 3: Company Import - Compare total counts of records with Source. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				Field_Name,
				ValidationMessage,
				System_Compared_With
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				'vth_Source',
				@ValidationMessage,
				'CRM'
			)
		END
		
		--Test Case 4. Compare total counts of records with a value in source between staging table and Onyx.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company C (NOLOCK)
				INNER JOIN Onyx.dbo.ReferenceFields RF (NOLOCK)
					ON RF.chFieldName = 'company.source'
				INNER JOIN Onyx.dbo.ReferenceDefinition RD (NOLOCK)
					ON RD.iReferenceId = RF.iReferenceId
					AND RD.iParameterId = C.iSourceId
				WHERE ISNULL(iSourceId, 0) <> 0
				AND C.tiRecordStatus = 1
				AND RD.tiRecordStatus = 1
				AND RF.tiRecordStatus = 1
			
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 4: Company Import - Compare total counts of records with Source. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Entity Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				Field_Name,
				ValidationMessage,
				System_Compared_With
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				'vth_Source',
				@ValidationMessage,
				'Onyx'
			)
		END
	    
		--Test Case 5. Compare total counts of records with a value in Company Type between staging table and CRM.
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
				WHERE BusinessTypeCode IS NOT NULL
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountBase (NOLOCK)
				WHERE BusinessTypeCode IS NOT NULL
			
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 5: Company Import - Compare total counts of records with Company Type. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				Field_Name,
				ValidationMessage,
				System_Compared_With
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				'BusinessTypeCode',
				@ValidationMessage,
				'CRM'
			)
		END
		
		--Test Case 6. Compare total counts of records with a value in source between staging table and Onyx.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company C (NOLOCK)
				INNER JOIN Onyx.dbo.ReferenceFields RF (NOLOCK)
					ON RF.chFieldName = 'company.type'
				INNER JOIN Onyx.dbo.ReferenceDefinition RD (NOLOCK)
					ON RD.iReferenceId = RF.iReferenceId
					AND RD.iParameterId = C.iCompanyTypeCode			
			WHERE ISNULL(iCompanyTypeCode, 0) <> 0
			AND C.tiRecordStatus = 1
			AND RD.tiRecordStatus = 1
			AND RF.tiRecordStatus = 1
			
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 6: Company Import - Compare total counts of records with Company Type. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Entity Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				Field_Name,
				ValidationMessage,
				System_Compared_With
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				'BusinessTypeCode',
				@ValidationMessage,
				'Onyx'
			)
		END
		
		--Test Case 7. Compare total counts	of records that have a parent company
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
			WHERE ParentAccountId IS NOT NULL
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountBase (NOLOCK)		
			WHERE ParentAccountId IS NOT NULL

		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 7: Compare total counts of records, between Staging table and CRM, that have a parent company - Company Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			 INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'CRM',
				'ParentAccountId'
			)
		END   
		
		--Test Case 8: Compare total counts between Onyx and staging table.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company (NOLOCK)
				WHERE tiRecordStatus = 1
				AND iParentId IS NOT NULL
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 8:  Compare total counts of records, between Staging table and Onyx, that have a parent company. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'Onyx',
				'iParentId'
			)
		END	
		
		--Test Case 9. Compare total counts	of records that have a parent company
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
			WHERE vth_BuildingType IS NOT NULL
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountExtensionBase (NOLOCK)		
			WHERE vth_BuildingType IS NOT NULL

		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 9: Compare total counts of records, between Staging table and CRM, that have a Facility Type - Company Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			 INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'CRM',
				'vth_BuildingType'
			)
		END   
		
		--Test Case 10: Compare total counts between Onyx and staging table.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company C (NOLOCK)
				INNER JOIN Onyx.dbo.ReferenceFields RF (NOLOCK)
					ON RF.chFieldName = 'company.marketsector'
				INNER JOIN Onyx.dbo.ReferenceDefinition RD (NOLOCK)
					ON RD.iReferenceId = RF.iReferenceId
					AND RD.iParameterId = C.iMarketSector			
			WHERE ISNULL(iMarketSector, 0) <> 0
				AND C.tiRecordStatus = 1
				AND RD.tiRecordStatus = 1
				AND RF.tiRecordStatus = 1
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 10:  Compare total counts of records, between Staging table and Onyx, that have a Facility Type. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'Onyx',
				'iMarketSector'
			)
		END	
		
		--Test Case 11. Compare total counts of records that have a parent company
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
			WHERE vth_Pricing IS NOT NULL
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountExtensionBase (NOLOCK)		
			WHERE vth_Pricing IS NOT NULL

		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 11: Compare total counts of records, between Staging table and CRM, that have a Pricing - Company Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			 INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'CRM',
				'vth_Pricing'
			)
		END   
		
		--Test Case 12: Compare total counts between Onyx and staging table.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company C (NOLOCK)
				INNER JOIN Onyx.dbo.ReferenceFields RF (NOLOCK)
					ON RF.chFieldName = 'company.sic'
				INNER JOIN Onyx.dbo.ReferenceDefinition RD (NOLOCK)
					ON RD.iReferenceId = RF.iReferenceId
					AND RD.iParameterId = C.iSICCode			
			WHERE ISNULL(iSICCode, 0) <> 0
				AND C.tiRecordStatus = 1
				AND RD.tiRecordStatus = 1
				AND RF.tiRecordStatus = 1
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 12:  Compare total counts of records, between Staging table and Onyx, that have a Pricing. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'Onyx',
				'iMarketSector'
			)
		END	
		
		--Test Case 13. Compare total counts of records that have a Country (text)
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
			WHERE ISNULL(Address1_Country, '') <> ''
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountBase C (NOLOCK)
				INNER JOIN CRM_CustomerAddressBase CA (NOLOCK)
					ON C.AccountId = CA.ParentId
			WHERE ISNULL(Country, '') <> ''
				AND AddressNumber = 1
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 13: Compare total counts of records, between Staging table and CRM, that have a Country (text) - Company Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			 INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'CRM',
				'Address1_Country'
			)
		END   
		
		--Test Case 14: Compare total counts of records with address type between Onyx and staging table.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company C (NOLOCK)
			WHERE ISNULL(chCountryCode, '') <> ''
				AND C.tiRecordStatus = 1
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 14:  Compare total counts of records, between Staging table and Onyx, that have a Country (text). Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'Onyx',
				'chCountryCode'
			)
		END
		
		--Test Case 15. Compare total counts of records that have an Address Type
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
			WHERE Address1_AddressTypeCode IS NOT NULL
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountBase C (NOLOCK)
				INNER JOIN CRM_CustomerAddressBase CA (NOLOCK)
					ON C.AccountId = CA.ParentId
			WHERE AddressTypeCode IS NOT NULL
				AND AddressNumber = 1
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 15: Compare total counts of records, between Staging table and CRM, that have a Address Type - Company Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			 INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'CRM',
				'Address1_AddressType'
			)
		END   
		
		--Test Case 16: Compare total counts of records with address type between Onyx and staging table.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company C (NOLOCK)
				INNER JOIN Onyx.dbo.ReferenceFields RF (NOLOCK)
					ON RF.chFieldName = 'company.addresstype'
				INNER JOIN Onyx.dbo.ReferenceDefinition RD (NOLOCK)
					ON RD.iReferenceId = RF.iReferenceId
					AND RD.iParameterId = C.iAddressTypeId			
			WHERE ISNULL(iAddressTypeId, 0) <> 0
				AND C.tiRecordStatus = 1
				AND RD.tiRecordStatus = 1
				AND RF.tiRecordStatus = 1
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 16:  Compare total counts of records, between Staging table and Onyx, that have a Address Type. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'Onyx',
				'iAddressTypeId'
			)
		END
		
		--Test Case 17. Compare total counts of records that have Country (drop down)
		SELECT @StageCount = COUNT(1)
			FROM Company (NOLOCK)
			WHERE vth_Country IS NOT NULL
		SELECT @CRMCount = COUNT(1)
			FROM CRM_AccountExtensionBase C (NOLOCK)
			WHERE C.vth_Country IS NOT NULL
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 17: Compare total counts of records, between Staging table and CRM, that have a Country (drop down) - Company Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			 INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'CRM',
				'vth_Country'
			)
		END   
		
		--Test Case 18: Compare total counts of records with address type between Onyx and staging table.
		SELECT @OnyxCount = COUNT(1)
			FROM Onyx.dbo.Company C (NOLOCK)
				INNER JOIN Onyx.dbo.Country CO (NOLOCK)
					ON C.chCountryCode = CO.chCountryCode
			WHERE ISNULL(C.chCountryCode, '') <> ''
				AND C.tiRecordStatus = 1
				
		IF ISNULL(@StageCount, 0) <> ISNULL(@OnyxCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Company Import - Test Case 18:  Compare total counts of records, between Staging table and Onyx, that have a Country (drop down). Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' Onyx Rows = ' + CONVERT (NVARCHAR(20), @OnyxCount)
			RAISERROR (@ValidationMessage, 0 , 1)
			
			INSERT INTO dbo.ValidationLog
			(
				EntityName,
				Records_In_Source,
				Records_In_Destination,
				Exec_DateTime,
				ValidationMessage,
				System_Compared_With,
				Field_Name
			)
			VALUES
			(
				'Company',
				@StageCount,
				@CRMCount,
				GETDate(),
				@ValidationMessage,
				'Onyx',
				'chCountryCode'
			)
		END
		
	END TRY
	BEGIN CATCH
		SELECT @ValidationMessage = ERROR_MESSAGE()
		SELECT @ValidationMessage = 'Error Occurred: ' + @ValidationMessage
		RAISERROR (@ValidationMessage, 0, 1)
	END CATCH
    RETURN 1 --Success!
END