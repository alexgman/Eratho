IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_ReturnMaskValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	DROP FUNCTION [dbo].[fn_ReturnMaskValue]
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_ReturnMaskValue]
(
	@Input nvarchar(40),
	@Mask nvarchar(40)
)
RETURNS NVARCHAR(255)
AS
/*
** ObjectName:	fn_ReturnMaskValue
** 
** Description:	Return Phone/Zip formatted using the supplied mask
**
** Example:		SQL Command:	SELECT dbo.fn_ReturnMaskValue('111222333','(999) 999-9999 /x 999999999999')
**				Results:		(111) 222-333
**
** Revision History
** --------------------------------------------------------------------------
** Date				Name			Description
** --------------------------------------------------------------------------
** 06/27/2012		GBS.MMrad		Initial Creation
*/
BEGIN 
	DECLARE	@iValuePos			INT,
			@iPos				INT,
			@iMaskPos			INT,
			@vchCurrMaskChar	NVARCHAR(255),
			@ApplyMask			NVARCHAR(255)
			
	SELECT	@iValuePos			= 1,
			@iPos				= 0,
			@iMaskPos			= 1,
			@vchCurrMaskChar	= NULL,
			@ApplyMask			= NULL

	IF (LTRIM(RTRIM(ISNULL(@Input,''))) = '')
	BEGIN
		SELECT @ApplyMask = NULL
	END
	ELSE IF (LTRIM(RTRIM(ISNULL(@Mask,''))) = '')
	BEGIN
		SELECT @ApplyMask = @Input
	END
	ELSE
	BEGIN
		-- we have a mask and a value lets figure out what to do
		--Apply the mask to the string
		WHILE (@iMaskPos <= LEN(@Mask))
		BEGIN
			SET @vchCurrMaskChar = SUBSTRING(@Mask, @iMaskPos, 1)
			
			IF ( 
				@vchCurrMaskChar = '9'
				OR @vchCurrMaskChar = '#'
				OR @vchCurrMaskChar = 'A'
				)
			BEGIN
			
				-- Replace masking character with character from value
				SELECT	@ApplyMask	= ISNULL(@ApplyMask,'') + SUBSTRING(@Input, @iValuePos, 1)
				SELECT	@iValuePos	= @iValuePos + 1,
						@iMaskPos	= @iMaskPos + 1
			END
			ELSE
			BEGIN
				-- Add character from mask
				SELECT	@ApplyMask	= ISNULL(@ApplyMask,'') + SUBSTRING(@Mask, @iMaskPos, 1)
				SELECT	@iMaskPos	= @iMaskPos + 1
			END

			IF (@iValuePos > LEN(@Input))
			BEGIN
				-- We are done applying the mask to the value, now we finish processing
				-- the extra mask characters
				WHILE (@iMaskPos <= LEN(@Mask))
				BEGIN
					SELECT @vchCurrMaskChar = SUBSTRING(@Mask, @iMaskPos, 1)

					IF (
						@vchCurrMaskChar = '9'
						OR @vchCurrMaskChar = '#'
						OR @vchCurrMaskChar = 'A'
						)
					BEGIN
						-- Replace masking character with character from value
						SELECT	@ApplyMask	= ISNULL(@ApplyMask,'') + ' '
						SELECT	@iMaskPos	= @iMaskPos + 1
					END
					ELSE
					BEGIN
						-- Add character from mask
						SELECT	@ApplyMask	= ISNULL(@ApplyMask,'') + SUBSTRING(@Mask, @iMaskPos, 1)
						SELECT	@iMaskPos	= @iMaskPos + 1
					END
				END
			END
		END
	END
	
	SELECT	@ApplyMask	= LTRIM(RTRIM(@ApplyMask))
	SELECT	@ApplyMask	= CASE WHEN (RIGHT(RTRIM(@ApplyMask),2) IN ( '/x')) 
								THEN LTRIM(RTRIM(LEFT(RTRIM(@ApplyMask),LEN(RTRIM(@ApplyMask))-2))) 
							   WHEN (RIGHT(RTRIM(@ApplyMask),1) IN ( 'x','-','/')) 
								THEN LTRIM(RTRIM(LEFT(RTRIM(@ApplyMask),LEN(RTRIM(@ApplyMask))-1)))								
								ELSE @ApplyMask END

	RETURN @ApplyMask
END

GO


GRANT EXECUTE ON [dbo].[fn_ReturnMaskValue] TO PUBLIC