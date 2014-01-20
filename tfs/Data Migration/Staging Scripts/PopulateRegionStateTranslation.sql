IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PopulateRegionStateTranslation]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [dbo].[PopulateRegionStateTranslation]
END

GO
SET NOCOUNT ON
GO 
SET QUOTED_IDENTIFIER ON
GO

/*
	TRUNCATE TABLE RegionStateTranslation
	EXEC PopulateRegionStateTranslation 
	SELECT * FROM RegionStateTranslation	
	
	Populate the staging table that stores, in advance, the translation of the Onyx Region/States into those in CRM.
*/
CREATE PROCEDURE [dbo].[PopulateRegionStateTranslation]
(
	@LogId UNIQUEIDENTIFIER = NULL,
	@Debug BIT = 0
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM CRM_Staging.dbo.RegionStateTranslation)					
		INSERT INTO CRM_Staging.dbo.RegionStateTranslation (RegionStateDesc, CountryCode, DestinationValue, SourceValue)
		SELECT R.chRegionName, R.chCountryCode , CRM_Staging.dbo.tsf_GetOptionSetId('vth_state','account', R.chRegionName, 'Active'), R.chRegionCode
		FROM Onyx.dbo.Region R (NOLOCK)
		WHERE tiRecordStatus = 1
END