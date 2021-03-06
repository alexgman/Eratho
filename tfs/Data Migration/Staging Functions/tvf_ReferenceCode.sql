USE [CRM_StagingVth]
GO
/****** Object:  UserDefinedFunction [dbo].[ReferenceCode]    Script Date: 10/10/2012 18:11:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		InessaT
-- Create date: 10/09/2012
-- Description:	Table Value Function that returns Reference LookUp Id and Description
-- =============================================
ALTER FUNCTION [dbo].[tvf_ReferenceCode]
(	
	@schemaField varchar(100) ,
	@entityField varchar(100)
	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT DISTINCT L.Label COLLATE DATABASE_DEFAULT as RefDesc
	       , P.Value as ReferenceID
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
            WHERE A.Name = @schemaField     -- Field Schema Name
                  AND E.Name = @entityField     --Entity Schema name
    
)
