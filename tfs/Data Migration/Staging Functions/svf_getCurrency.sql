-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		GBS.PRogers
-- Create date: 2012.11.09	
-- Description:	Gets GUID of Currency
-- =============================================
CREATE FUNCTION [dbo].[svf_getCurrency] 
(
	-- Add the parameters for the function here
	@currencyName nvarchar(100)
)
RETURNS UniqueIdentifier
AS
BEGIN
	-- Declare the return variable here
	DECLARE @currencyGUID UniqueIdentifier

	-- Add the T-SQL statements to compute the return value here
	 select @currencyGUID = TransactionCurrencyID from CRM_TransactionCurrencyBase where ISOCurrencyCode = @currencyName 

	-- Return the result of the function
	RETURN @currencyGUID

END
GO

