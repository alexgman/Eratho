USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[Note]') IS NOT NULL

DROP TABLE [dbo].[Note]
go 
Begin
CREATE TABLE [dbo].[Note]
(

[AnnotationId] [uniqueidentifier],
[ObjectTypeCode] [int],
[ObjectId] [uniqueidentifier],
[OwningBusinessUnit] [uniqueidentifier],
[Subject] [nvarchar](1000),
[IsDocument] [bit],
[NoteText] [nvarchar](4000),
[MimeType] [nvarchar](512),
[LangId] [nvarchar](4),
[DocumentBody] [varchar],
[CreatedOn] [datetime],
[FileSize] [int],
[FileName] [nvarchar](510),
[CreatedBy] [uniqueidentifier],
[IsPrivate] [bit],
[ModifiedBy] [uniqueidentifier],
[ModifiedOn] [datetime],
[VersionNumber] [timestamp],
[StepId] [nvarchar](64),
[OverriddenCreatedOn] [datetime],
[ImportSequenceNumber] [int],
[CreatedOnBehalfBy] [uniqueidentifier],
[OwnerId] [uniqueidentifier],
[ModifiedOnBehalfBy] [uniqueidentifier],
[OwnerIdType] [int]

)
END