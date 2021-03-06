USE [CRM_Staging]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetCurrOfIndeterminateTeams]    Script Date: 11/19/2012 13:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		GBS.PRogers
-- Create date: 11-19-2012	
-- Description:	Return CurrencyId 
-- =============================================
ALTER FUNCTION [dbo].[fn_GetCurrOfIndeterminateTeams] 
(
	@TeamId UniqueIdentifier
	
)
RETURNS UniqueIdentifier
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CurrencyId UniqueIdentifier
	
	select @CurrencyId = CASE
				WHEN @TeamId IS  NULL 	
					THEN CASE(C.chUpdateBy) 
							WHEN 'UKCleanUp'
								THEN '5C7269F4-150C-E211-A38F-005056A37549'
							WHEN 'VMFRSync'
								THEN '1C370964-160C-E211-A38F-005056A37549'
							WHEN 'France-ASA'
								THEN '1C370964-160C-E211-A38F-005056A37549'
							WHEN 'DXUMLSynch'
								THEN '1C370964-160C-E211-A38F-005056A37549'
							ELSE '644729F5-9FFE-E111-91BD-005056A37549'
						END 
					ELSE T.TransactionCurrencyId
				EnD
				FROM	
					ONyx.[dbo].Company C 
				WITH (NOLOCK)
				LEFT OUTER  JOIN Users SU
					ON SU.vth_OnyxUserId = C.chUpdateBy
			LEFT OUTER  JOIN CRM_TeamBase T
				ON T.BusinessUnitId = SU.BusinessUnitId
	
	RETURN @CurrencyID

END
