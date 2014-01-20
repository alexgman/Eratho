USE [CRM_Staging]
GO
--drop table oledberrors
/****** Object:  Table [dbo].[OLEDBErrors]    Script Date: 09/20/2012 15:28:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[OLEDBErrors]') IS NOT NULL

DROP TABLE [dbo].[OLEDBErrors]
GO
BEGIN
CREATE TABLE [dbo].[OLEDBErrors](
	[CRMId] [uniqueidentifier] NULL,
	[Entity] [varchar](50) NULL,
	[Name] [nvarchar](400) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY]

END


