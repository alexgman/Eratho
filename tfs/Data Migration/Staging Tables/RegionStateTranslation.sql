IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RegionStateTranslation]') AND type in (N'U'))
	DROP TABLE [dbo].[RegionStateTranslation]
GO

/*
	Staging table to store in advance the translation of the Onyx Region/States into those in CRM.
*/
CREATE TABLE [dbo].[RegionStateTranslation]
(
	RegionStateDesc NVARCHAR(255),
	CountryCode NVARCHAR(20),
	DestinationValue INT,
	SourceValue NVARCHAR(20),
	Id INT IDENTITY (0,1) PRIMARY KEY
)

