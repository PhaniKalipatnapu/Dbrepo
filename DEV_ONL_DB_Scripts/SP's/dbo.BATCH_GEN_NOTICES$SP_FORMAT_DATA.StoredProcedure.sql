/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_FORMAT_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_FORMAT_DATA
Programmer Name	:	IMP Team.
Description		:	procedure BATCH_GEN_NOTICES$SP_FORMAT_DATA gets elements and Format_CODE for each element that requires formatting
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_FORMAT_DATA]
 @Ac_Notice_ID             CHAR(8),
 @Ac_Recipient_INDC		   CHAR(1) = 'N',
 @An_Barcode_NUMB		   NUMERIC(12) = 0,
 @Ac_ActivityMajor_CODE    CHAR(4) = '',
 @Ac_ActivityMinor_CODE	   CHAR(5) = '',
 @Ac_Reason_CODE		   CHAR(2) = '',
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ls_ErrorDesc_TEXT          VARCHAR(4000),
          @Ls_Sql_TEXT                VARCHAR(100) = '',
          @Ls_Sqldata_TEXT            VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT   VARCHAR(4000),
          @Ls_ErrorMesg_TEXT          VARCHAR(4000),
          @Lc_Error_CODE              CHAR(4),
          @Ls_Errorproc_NAME          VARCHAR(75),
          @Ls_SQLParameterString_TEXT NVARCHAR(MAX),
          @Ls_ParmDefinition_TEXT     NVARCHAR(MAX),
          @Ls_SQLProcName_TEXT        VARCHAR(75),
          @Ls_SQLString_TEXT          NVARCHAR(MAX),
          @GetFormat_CODE_CUR         CURSOR,
          @Ls_Element_NAME            VARCHAR(100),
          @Ls_Element_VALUE           VARCHAR(300),
          @Lc_Format_CODE             CHAR(15),
          @Lc_Mask_INDC               CHAR(1),
          @Ls_Element_TEXT            VARCHAR(100),
          @Ls_EleValue_TEXT           VARCHAR(300),
          @Ls_Routine_TEXT            VARCHAR(75) ='BATCH_GEN_NOTICES$SP_FORMAT_DATA',
          @Ls_Formatted_value_TEXT    VARCHAR(300),
          @Ls_EleFormat_CODE          VARCHAR(100),
          @Lc_StatusSuccess_CODE      CHAR,
          @Lc_StatusFailed_CODE       CHAR,
          @Ln_Zero_NUMB               NUMERIC(1);

  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';
  SET @Ln_Zero_NUMB = 0;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_FORMAT_DATA';
   SET @Ls_Sqldata_TEXT = ' Notice_ID : ' + ISNULL(@Ac_Notice_ID, '');
   SET @Ls_ErrorDesc_TEXT = 'No Elements found FOR Formating IN NDEL';
   
   
   --Cursor to get elements that have formats from NDEL_Y1
   IF @Ac_Recipient_INDC = 'N' AND (@An_Barcode_NUMB = 0 OR @An_Barcode_NUMB IS NULL)
		BEGIN
		   SET @GetFormat_CODE_CUR = CURSOR
				   FOR SELECT DISTINCT V.Element_NAME,
							  T.Element_VALUE,
							  V.Format_CODE,
							  V.Mask_INDC
						 FROM NDEL_Y1 V
							  INNER JOIN #NoticeElementsData_P1 T
							   ON V.Element_NAME = T.Element_NAME
						WHERE V.Input_CODE = 'O'
						  AND V.Format_CODE <> ''
						  AND V.Element_NAME NOT LIKE 'option_%'
						  AND V.Notice_ID = @Ac_Notice_ID;
		END
	ELSE IF @Ac_Recipient_INDC = 'Y' AND (@An_Barcode_NUMB = 0 OR @An_Barcode_NUMB IS NULL)
		BEGIN
			SET @GetFormat_CODE_CUR = CURSOR
				   FOR SELECT V.Element_NAME,
							  T.Element_VALUE,
							  V.Format_CODE,
							  V.Mask_INDC
						 FROM NDEL_Y1 V
							  INNER JOIN #NoticeElementsData_P1 T
							   ON V.Element_NAME = T.Element_NAME
						WHERE V.Input_CODE = 'O'
						  AND V.Format_CODE <> ''
						  AND V.Element_NAME LIKE '%RECIPIENT%'
						  AND V.Notice_ID = @Ac_Notice_ID;
		END
	ELSE IF @An_Barcode_NUMB != 0
		BEGIN
			
			SET @GetFormat_CODE_CUR = CURSOR
				   FOR SELECT V.Element_NAME,
							  T.Element_VALUE,
							  V.Format_CODE,
							  V.Mask_INDC
						 FROM NDEL_Y1 V
							  INNER JOIN #NoticeElementsData_P1 T
							   ON V.Element_NAME = T.Element_NAME
						WHERE V.Input_CODE = 'O'
						  AND V.Format_CODE <> ''
						  AND V.Element_NAME LIKE '%RECIPIENT%'
						  AND V.Notice_ID = @Ac_Notice_ID
						UNION
						SELECT V.Element_NAME,
							   T.Element_VALUE,
							   V.Format_CODE,
							   V.Mask_INDC
						  FROM RARE_Y1 R
								INNER JOIN NDEL_Y1 V
								ON R.Element_NAME = V.Element_NAME
								INNER JOIN #NoticeElementsData_P1 T
								ON V.Element_NAME = T.Element_NAME
						 WHERE ActivityMajor_CODE = @Ac_ActivityMajor_CODE
						   AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
						   AND Reason_CODe = @Ac_Reason_CODE
						   AND R.Notice_ID = @Ac_Notice_ID
						   AND R.Required_INDC = 'Y'
						   AND V.Input_CODE = 'O'
						   AND V.Format_CODE <> '';
		END
		
   OPEN @GetFormat_CODE_CUR

   FETCH NEXT FROM @GetFormat_CODE_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Lc_Format_CODE, @Lc_Mask_INDC

   WHILE @@FETCH_STATUS = 0
    BEGIN
     SET @Ls_Element_TEXT = @Ls_Element_NAME;
     SET @Ls_EleValue_TEXT = @Ls_Element_VALUE;
     SET @Ls_EleFormat_CODE = @Lc_Format_CODE;

     IF @Lc_Format_CODE <> '' AND @Ls_Element_VALUE != '' AND @Ls_Element_VALUE IS NOT NULL
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA';
       SET @Ls_Sqldata_TEXT = ' Element_NAME: ' + ISNULL(@Ls_Element_TEXT, '') + ' Element_value: ' + ISNULL(@Ls_EleValue_TEXT, '') + ' Format_CODE: ' + ISNULL(@Ls_EleFormat_CODE, '');

       EXEC BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA
					@As_Element_NAME          = @Ls_Element_TEXT,
					@As_Element_VALUE         = @Ls_EleValue_TEXT,
					@Ac_Format_CODE           = @Ls_EleFormat_CODE,
					@Ac_Mask_INDC             = @Lc_Mask_INDC,
					@As_FormattedResult_TEXT  = @Ls_Formatted_value_TEXT OUTPUT,
					@Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
					@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
		
       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
          SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA FAILED' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '');
         ELSE
          SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA FAILED' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');

         RETURN;
        END

       UPDATE #NoticeElementsData_P1
          SET Element_VALUE = RTRIM(@Ls_Formatted_value_TEXT)
        WHERE LOWER(LTRIM(RTRIM(Element_NAME))) = LOWER(LTRIM(RTRIM(@Ls_Element_NAME)));
	   
      END

     FETCH NEXT FROM @GetFormat_CODE_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Lc_Format_CODE, @Lc_Mask_INDC
    END

   CLOSE @GetFormat_CODE_CUR

   DEALLOCATE @GetFormat_CODE_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', '@GetFormat_CODE_CUR') IN (0, 1)
    BEGIN
     CLOSE @GetFormat_CODE_CUR

     DEALLOCATE @GetFormat_CODE_CUR
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE(), '') + ' PROCEDURE' + '. Error DESC - ' + @Ls_ErrorDesc_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), '') + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
