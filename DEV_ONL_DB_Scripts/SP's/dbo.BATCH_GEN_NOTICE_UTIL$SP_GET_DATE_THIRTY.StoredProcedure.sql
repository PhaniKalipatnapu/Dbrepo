/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_THIRTY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_THIRTY
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Next date after 30 days from System date.
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_THIRTY]
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_Thirtydaysaftersysdate_TEXT CHAR(26) = 'THIRTY_DAYS_AFTER_SYS_DATE',
          @Ls_Procedure_NAME              VARCHAR(100) ='BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_THIRTY';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Next_DATE             DATE;

  BEGIN TRY
   SET @Ld_Next_DATE = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_THIRTY';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');
   SET @Ld_Next_DATE = DATEADD(D, 30, @Ad_Run_DATE);

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
        VALUES(@Lc_Thirtydaysaftersysdate_TEXT,--Element_NAME
               CONVERT(VARCHAR, @Ld_Next_DATE, 101)--Element_VALUE
   );

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
