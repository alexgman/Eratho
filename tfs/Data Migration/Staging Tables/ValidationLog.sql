IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ValidationLog]') AND type in (N'U'))
	DROP TABLE [dbo].[ValidationLog]
GO

/****** Object:  Table [dbo].[ValidationLog]    Script Date: 11/20/2012 13:42:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ValidationLog](
	[EntityName] [varchar](100) NULL,
	[Records_In_Source] [int] NULL,
	[Records_In_Destination] [int] NULL,
	[System_Compared_With] NVARCHAR(100),
	[Exec_DateTime] [datetime] NULL,
	[Field_Name] VARCHAR(100),
	[ValidationMessage]	VARCHAR(MAX)
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


