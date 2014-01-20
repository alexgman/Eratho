IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CountryTranslation]') AND type in (N'U'))
	DROP TABLE [dbo].[CountryTranslation]
GO

/*
	Staging table to store in advance the translation of the Onyx Countries into those in CRM.
*/
CREATE TABLE [dbo].[CountryTranslation]
(
	CountryDesc NVARCHAR(255),
	DestinationValue INT,
	SourceValue NVARCHAR(20),
	Id INT IDENTITY (0,1) PRIMARY KEY
)

