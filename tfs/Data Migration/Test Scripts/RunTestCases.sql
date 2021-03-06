USE [CRM_Staging]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RunTestCases]') AND type in (N'P', N'PC'))
BEGIN
          DROP PROCEDURE [dbo].[RunTestCases]
END
GO
/****** Object:  StoredProcedure [dbo].[RunTestCases]    Script Date: 11/12/2012 22:06:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET NOCOUNT ON
GO
/* =============================================
-- Author:		Paul Rogers
-- Create date: Oct 17,2012
-- Description:	This matches the number rows in the staging table with the number of rows in the CRM/Onyx tables to verify that all rows were imported

	EXEC RunTestCases
-- ============================================= */
CREATE PROCEDURE [dbo].[RunTestCases]	
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
			Validation for Products and Price Lists
		**************************************************************************/
		--Check Product Import
		SELECT 
			@StageCount = COUNT(*) 
		FROM 
			Product 
		SELECT 
			@CRMCount = COUNT(*) 
		FROM 
			CRM_ProductBase		
		
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Test Case: Compare total counts - Product Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
		END
		
		INSERT INTO dbo.ValidationLog
			(
			EntityName,
			Records_In_Source,
			Records_In_Destination,
			Exec_DateTime,
			ValidationMessage		
			)
		VALUES
		(
		'Product',
		@StageCount,
		@CRMCount,
		GETDate(),
		@ValidationMessage
		)
		    
		 --Check ProductDetail Import     
		SELECT 
			@StageCount = COUNT(*) 
		FROM 
			ProductDetail 
		SELECT 
			@CRMCount = COUNT(*) 
		FROM 
			CRM_ProductDetailBase
		
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Test Case: Compare total counts - vth_ProductDetail Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
		END
		
		INSERT INTO dbo.ValidationLog
			(
			EntityName,
			Records_In_Source,
			Records_In_Destination,
			Exec_DateTime,
			ValidationMessage
			)
		VALUES
		(
		'vth_ProductDetail',
		@StageCount,
		@CRMCount,
		GETDate(),
		@ValidationMessage
		)
		IF 
			@StageCount <> @CRMCount
		PRINT 'Error in ProductDetail Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
		else print 'They match'
	    
		--Check PriceList Import
		SELECT 
			@StageCount = COUNT(*) 
		FROM 
			PriceList 
		SELECT 
			@CRMCount = COUNT(*) 
		FROM 		
			CRM_PriceLevelBase
			
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Test Case: Compare total counts - PriceList Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
		END
		
		INSERT INTO dbo.ValidationLog
			(
			EntityName,
			Records_In_Source,
			Records_In_Destination,
			Exec_DateTime,
			ValidationMessage
			)
		VALUES
		(
		'PriceList',
		@StageCount,
		@CRMCount,
		GETDate(),
		@ValidationMessage
		)
		   
	   --Check PriceListItem Import
		SELECT 
			@StageCount = COUNT(*) 
		FROM 
			PriceListItem
		SELECT 
			@CRMCount = COUNT(*) 
		FROM		
			CRM_ProductPriceLevelBase
		
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Test Case: Compare total counts - PriceListItem Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
		END
			
		INSERT INTO dbo.ValidationLog
			(
			EntityName,
			Records_In_Source,
			Records_In_Destination,
			Exec_DateTime,
			ValidationMessage
			)
		VALUES
		(
		'PriceListItem',
		@StageCount,
		@CRMCount,
		GETDate(),
		@ValidationMessage
		)
	    
		--Check PriceListItemDetail
		 SELECT 
			@StageCount = COUNT(*) 
		FROM 
			PriceListItemDetail
		SELECT 
			@CRMCount = COUNT(*) 
		FROM		
			CRM_vth_PriceListItemDetailBase		
		
		IF ISNULL(@StageCount, 0) <> ISNULL(@CRMCount, -1)
		BEGIN
			SELECT @ValidationMessage = ''
			SELECT @ValidationMessage = 'Test Case: Compare total counts - vth_PriceListItemDetail Import. Staging Table Rows = ' + CONVERT(NVARCHAR(20),@StageCount) + ' CRM Entity Rows = ' + CONVERT (NVARCHAR(20), @CRMCount)
			RAISERROR (@ValidationMessage, 0 , 1)
		END
		
		INSERT INTO dbo.ValidationLog
			(
			EntityName,
			Records_In_Source,
			Records_In_Destination,
			Exec_DateTime,
			ValidationMessage
			)
		VALUES
		(
			'vth_PriceListItemDetail',
			@StageCount,
			@CRMCount,
			GETDate(),
			@ValidationMessage
		)	
	    
		/**************************************************************************
			Validation for Companies
		**************************************************************************/
		EXEC RunCompanyTestCases
		
	END TRY
	BEGIN CATCH
		SELECT @ValidationMessage = ERROR_MESSAGE()
		SELECT @ValidationMessage = 'Error Occurred: ' + @ValidationMessage
		RAISERROR (@ValidationMessage, 0, 1)
	END CATCH
    RETURN 1 --Success!
    
    
END
