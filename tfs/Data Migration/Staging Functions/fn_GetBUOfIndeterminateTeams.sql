
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		GBS.PRogers
-- Create date: 11-19-2012	
-- Description:	Return  BusinessUnitId
-- =============================================
CREATE FUNCTION [dbo].[fn_GetBUOfIndeterminateTeams] 
(
	@TeamId UniqueIdentifier
	
)
RETURNS UniqueIdentifier
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CurrencyId UniqueIdentifier
	
	select @CurrencyId = CASE
				WHEN @TeamId is  NULL 	
					THEN CASE(C.chUpdateBy)
							WHEN 'UKCleanUp'
								THEN 'FFEF7166-000C-E211-A38F-005056A37549'
							WHEN 'VMFRSync'
								THEN 'FFCC1372-000C-E211-A38F-005056A37549'
							WHEN 'France-ASA'
								THEN 'FFCC1372-000C-E211-A38F-005056A37549'
							WHEN 'DXUMLSynch'
								THEN '02CD1372-000C-E211-A38F-005056A37549'
							ELSE 'A4DAF922-000C-E211-A38F-005056A375499'
						END 
					ELSE T.BusinessUnitId
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
GO

