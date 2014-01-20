USE [CRM_Staging]
GO
--drop table CRMImportError
/****** Object:  Table [dbo].[CRMImportError]    Script Date: 09/20/2012 15:28:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[CRMImportError]') IS NOT NULL

DROP TABLE [dbo].[CRMImportError]
GO
BEGIN
CREATE TABLE [dbo].[CRMImportError](
	[CRMId] [uniqueidentifier] NULL,
	[Entity] [varchar](50) NULL,
	[Name] [nvarchar](400) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL,
	[Id] [uniqueidentifier] NULL,
	[CrmErrorMessage] [nvarchar](2048) NULL
) ON [PRIMARY]

END


