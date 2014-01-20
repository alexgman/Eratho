IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PopulateCountryTranslation]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [dbo].[PopulateCountryTranslation]
END

GO
SET NOCOUNT ON
GO 
SET QUOTED_IDENTIFIER ON
GO

/*
	TRUNCATE TABLE CountryTranslation
	EXEC PopulateCountryTranslation 
	SELECT * FROM CountryTranslation ORDER BY DestinationValue
	
	Populate the staging table that stores, in advance, the translation of the Onyx Countries into those in CRM.
*/
CREATE PROCEDURE [dbo].[PopulateCountryTranslation]
(
	@LogId UNIQUEIDENTIFIER = NULL,
	@Debug BIT = 0
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM CRM_Staging.dbo.CountryTranslation)					
		INSERT INTO CRM_Staging.dbo.CountryTranslation (CountryDesc, DestinationValue, SourceValue)
		SELECT C.chCountryDesc, CRM_Staging.dbo.tsf_GetOptionSetId('vth_country','account', C.chCountryDesc, 'Active'), chCountryCode
		FROM Onyx.dbo.Country C (NOLOCK)
		WHERE tiRecordStatus = 1
END