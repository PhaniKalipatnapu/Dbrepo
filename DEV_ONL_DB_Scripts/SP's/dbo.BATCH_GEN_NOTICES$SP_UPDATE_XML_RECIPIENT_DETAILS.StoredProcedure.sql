/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_UPDATE_XML_RECIPIENT_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_UPDATE_XML_RECIPIENT_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to update recipient details for each recipient and returns updated XML 
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_UPDATE_XML_RECIPIENT_DETAILS]
 @As_XML_Result_TEXT       VARCHAR(MAX),
 @Ac_Notice_ID             CHAR(8),
 @As_Result_TEXT           VARCHAR(MAX) OUTPUT,
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  --CREATE TABLE #RecipientElementsData_P1
  -- (
  --   Element_NAME  VARCHAR(100),
  --   Element_VALUE VARCHAR(4000)
  -- );

  DECLARE 
	--@Ls_XML_RECIPIENT        VARCHAR(MAX),
	@Ls_Output_TEXT          VARCHAR(MAX),
	@Lc_StatusSuccess_CODE   CHAR,
	@Ls_Routine_TEXT         VARCHAR(60) ='BATCH_GEN_NOTICES$SP_UPDATE_XML_RECIPIENT_DETAILS',
	@Ls_Sql_TEXT             VARCHAR(1000),
	@Ls_Sqldata_TEXT         VARCHAR(400),
	@recipientxml_text       VARCHAR(MAX) = ' ',
	@Lc_StatusFailed_CODE    CHAR,
	@Ls_Err_Description_TEXT VARCHAR(4000),
	@RecipientTags_CUR		 CURSOR,
	@Ls_Element_NAME		 VARCHAR(150),
	@Ls_ElementToDelete_TEXT VARCHAR(150);
  
  DECLARE 
	@Ls_Source_XML VARCHAR(MAX),
	@Ln_PositionStart_NUMB	NUMERIC(10),
	@Ln_PositionEnd_NUMB	NUMERIC(10),
	@Ln_SourceLength_NUMB	NUMERIC(10);
  
  SET @Lc_StatusSuccess_CODE ='S';
  SET @Lc_StatusFailed_CODE = 'F';

  BEGIN TRY
   
   SET @Ls_Source_XML = @As_XML_Result_TEXT;
   
   SET @RecipientTags_CUR = CURSOR FOR
		SELECT Element_NAME
		  FROM NDEL_Y1
		 WHERE Notice_ID = @Ac_Notice_ID
		   AND Input_CODE = 'O'
		   AND Element_NAME LIKE 'RECIPIENT%';
		   
   OPEN @RecipientTags_CUR;

   FETCH NEXT FROM @RecipientTags_CUR INTO @Ls_Element_NAME;

   WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @Ln_PositionStart_numb = 0;
		SET @Ln_PositionEnd_NUMB = 0;
		SET @Ln_SourceLength_NUMB = LEN(@Ls_Source_XML);
		
		SET @Ln_PositionStart_numb = CHARINDEX('<'+@Ls_Element_NAME+'>', @Ls_Source_XML, @Ln_positionStart_NUMB); --+ LEN('<'+@Ls_Element_NAME+'>');
		
		IF @Ln_PositionStart_numb != 0
			BEGIN
				SET @Ln_PositionEnd_numb = CHARINDEX('</'+@Ls_Element_NAME+'>', @Ls_Source_XML, @Ln_positionStart_NUMB) + LEN('</'+@Ls_Element_NAME+'>');
				
				SET @Ls_Source_XML = SUBSTRING(@Ls_Source_XML, 1, @Ln_PositionStart_numb-1) +
									 SUBSTRING(@Ls_Source_XML, @Ln_PositionEnd_numb, (@Ln_SourceLength_NUMB - @Ln_PositionEnd_numb) + 1);
				
			END
		FETCH NEXT FROM @RecipientTags_CUR INTO @Ls_Element_NAME;
	END
   
   EXEC BATCH_GEN_NOTICES$SP_FORMAT_DATA
				@Ac_Notice_ID				= @Ac_Notice_ID,
				@Ac_Recipient_INDC			= 'Y',
				@Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT;
	
   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
		BEGIN
			RETURN;
		END
   
   SELECT @recipientxml_text = COALESCE(@recipientxml_text, '') + '<' + b.Element_NAME + '>' + ISNULL(b.Element_Value, '') + '</' + b.Element_NAME + '>'
     FROM (SELECT a.element_name,
                  a.element_value
             FROM (SELECT DISTINCT
                          V.Element_NAME,
                          ISNULL(T.Element_VALUE, '')Element_VALUE
                     FROM NDEL_Y1 V
                          JOIN #NoticeElementsData_P1 T
                           ON V.Element_NAME = T.Element_NAME
                    WHERE V.Input_CODE = 'O'
                      AND v.Notice_ID = @Ac_Notice_ID
                      AND v.Element_NAME LIKE 'RECIPIENT%'
                      --AND v.element_name IN (SELECT t.Element_name
                      --                         FROM #RecipientElementsData_P1 t)
                   ) a
          ) b;
	
   SET @As_Result_TEXT = '<' + RTRIM(@Ac_Notice_ID) + '>' + LTRIM(RTRIM(@recipientxml_text)) 
						+ SUBSTRING(@Ls_Source_XML, LEN('<' + RTRIM(@Ac_Notice_ID) + '>') + 1, (LEN(@Ls_Source_XML) - LEN('<' + RTRIM(@Ac_Notice_ID) + '>')));
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
