USE [CRM_Staging]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tsf_GetOptionSetId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	DROP FUNCTION [dbo].[tsf_GetOptionSetId]
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* =============================================
-- Author:		InessaT
-- Create date: 10/09/2012
-- Description:	Table Value Function that returns Reference LookUp Id and Description

SELECT dbo.tsf_GetOptionSetId ('vth_country','account','Canada','Active')
SELECT dbo.tsf_GetOptionSetId ('vth_pricing','account','Amerinet','Active')
-- ============================================= */

CREATE FUNCTION [dbo].[tsf_GetOptionSetId]
(	
	@FieldSchemaName NVARCHAR(100) ,
	@EntityName NVARCHAR(100) ,
	@Label NVARCHAR(100),
	@SolutionUniqueName NVARCHAR(100)
	
)
RETURNS INT 
AS
BEGIN 
	DECLARE @OptionSetId INT 
	SELECT TOP 1 @OptionSetId = P.Value
            FROM CRM_OptionSet O (NOLOCK)
                  INNER JOIN CRM_Attribute A (NOLOCK) 
                              ON A.OptionSetId = O.OptionSetId
                  INNER JOIN CRM_Entity E (NOLOCK) 
                              ON A.EntityId = E.EntityId
                  INNER JOIN CRM_AttributePicklistValue P (NOLOCK) 
                              ON O.OptionSetId = P.OptionSetId 
                              AND P.ComponentState = 0
                  INNER JOIN CRM_LocalizedLabel L (NOLOCK) 
                              ON L.ObjectId = P.AttributePicklistValueId
                              AND L.ComponentState = 0
                              AND L.ObjectColumnName = 'DisplayName'
                  INNER JOIN CRM_SolutionBase S
							ON S.SolutionId = L.SolutionId
							AND S.UniqueName = @SolutionUniqueName
            WHERE A.Name = @FieldSchemaName     -- Field Schema Name
                  AND E.Name = @EntityName     --Entity Schema name
                  AND L.Label = @Label
    RETURN @OptionSetId
END
GO

GRANT EXECUTE ON [dbo].[tsf_GetOptionSetId] TO PUBLIC
GO