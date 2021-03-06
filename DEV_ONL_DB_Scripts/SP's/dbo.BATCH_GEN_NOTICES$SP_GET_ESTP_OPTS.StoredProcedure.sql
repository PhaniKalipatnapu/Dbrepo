/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_ESTP_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_ESTP_OPTS](
 @Ac_ActivityMajor_CODE    CHAR(4),
 @Ac_ActivityMinor_CODE    CHAR(5),
 @Ac_ReasonStatus_CODE     CHAR(2),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_ESTP_OPTS';
         
  DECLARE @Ln_Error_NUMB     NUMERIC(11),
          @Ln_ErrorLine_NUMB NUMERIC(11),
          @Ls_Sql_TEXT       VARCHAR(200),
          @Ls_Sqldata_TEXT   VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';
  BEGIN TRY
   SET @AC_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' INSERT #NoticeElementsData_P1 ';
   SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE =	' + ISNULL(CAST(@Ac_ActivityMajor_CODE AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(CAST(@Ac_ActivityMinor_CODE AS VARCHAR), '');

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(100), petition_cs_indc) petition_cs_code,
                   CONVERT(VARCHAR(100), petition_ms_indc) petition_ms_code
              FROM (SELECT CASE
                            WHEN @Ac_ActivityMajor_CODE = 'ESTP'
                                 AND @Ac_ActivityMinor_CODE = 'PETDE'
                                 AND @Ac_ReasonStatus_CODE = 'PE'
                             THEN 'X'
                            ELSE ''
                           END AS petition_cs_indc,
                           CASE
                            WHEN @Ac_ActivityMajor_CODE = 'ESTP'
                                 AND @Ac_ActivityMinor_CODE = 'PETDE'
                                 AND @Ac_ReasonStatus_CODE IN ('PE', 'PF')
                             THEN 'X'
                            ELSE ''
                           END AS petition_ms_indc) a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (petition_cs_code, petition_ms_code )) AS pvt);

   SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF ERROR_NUMBER () <> 50001
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
 END;


GO
