/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_NOTARY_SIGN_DATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_GEN_NOTICES$SP_NOTARY_SIGN_DATE 
Programmer Name		: IMP Team
Description 	    : This Procedure is used to retrieve the system day,system month and system year.
Frequency			:
Developed On		: 11/05/2012
Called By			: BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On	        : 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_NOTARY_SIGN_DATE] 
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_NOTARY_SIGN_DATE ';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Run_DATE              DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_NOTARY_SIGN_DATE ';
   SET @Ld_Run_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sqldata_TEXT = 'Notary_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), DATE_DAY) NOTARY_DAY_TEXT,
                   CONVERT(VARCHAR(100), DATE_MONTH) NOTARY_MONTH_TEXT,
                   CONVERT(VARCHAR(100), DATE_YEAR) NOTARY_YEAR_NUMB
              FROM (SELECT dbo.BATCH_GEN_NOTICE_UTIL$SF_GET_TIDY_DAY(@Ld_Run_DATE) AS DATE_DAY,
                           DATENAME (M, @Ld_Run_DATE) AS DATE_MONTH,
                           DATENAME (YEAR, @Ld_Run_DATE) AS DATE_YEAR)a) up UNPIVOT (tag_value FOR tag_name IN (NOTARY_DAY_TEXT, NOTARY_MONTH_TEXT, NOTARY_YEAR_NUMB)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE(),
          @Ls_DescriptionError_TEXT = 'INSERT_#NoticeElementsData_P1 FAILED';

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
