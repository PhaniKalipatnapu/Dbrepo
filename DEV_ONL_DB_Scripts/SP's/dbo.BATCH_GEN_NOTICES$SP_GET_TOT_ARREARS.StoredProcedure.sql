/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_TOT_ARREARS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_TOT_ARREARS](
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_TOT_ARREARS';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_sql_TEXT = 'SELECT LSUP_Y1';
   SET @Ls_Sqldata_TEXT = '@An_Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR);

   INSERT INTO #NoticeElementsData_P1
               (ELEMENT_NAME,
                ELEMENT_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT
           CONVERT(VARCHAR(100), CAST(Naa_Arrears AS VARCHAR)) TOTAL_ARREARS_OWED_CP_AMNT,
           CONVERT(VARCHAR(100), CAST(Paa_Arrears AS VARCHAR)) TOTAL_ARREARS_OWED_STATE_AMNT,
           CONVERT(VARCHAR(100), STATE_ARREARS_OWED_YES_INDC) STATE_ARREARS_OWED_YES_INDC,
           CONVERT(VARCHAR(100), STATE_ARREARS_OWED_NO_INDC) STATE_ARREARS_OWED_NO_INDC
              FROM(SELECT Naa_Arrears,
                          Paa_Arrears,
                          CASE
                           WHEN Paa_Arrears > 0
                            THEN 'X'
                           ELSE ''
                          END STATE_ARREARS_OWED_YES_INDC,
                          CASE
                           WHEN Paa_Arrears <= 0
                            THEN 'X'
                           ELSE ''
                          END STATE_ARREARS_OWED_NO_INDC
                     FROM (SELECT SUM((a.OweTotpaa_AMNT - a.AppTotpaa_AMNT) + (a.OweTottaa_AMNT - a.AppTottaa_AMNT) + (a.OweTotcaa_AMNT - a.AppTotcaa_AMNT)) Paa_Arrears,
                                  SUM((a.OweTotnaa_AMNT - a.AppTotnaa_AMNT) + (a.OweTotupa_AMNT - a.AppTotupa_AMNT) + (a.OweTotuda_AMNT - a.AppTotuda_AMNT)) Naa_Arrears
                             FROM (SELECT A.*,
                                          ROW_NUMBER() OVER(PARTITION BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB ORDER BY SupportYearMonth_NUMB DESC, EventGlobalSeq_NUMB DESC) RNM
                                     FROM LSUP_Y1 a
                                    WHERE Case_IDNO = @An_Case_IDNO) a
                            WHERE RNM = 1)a)b) up UNPIVOT (tag_value FOR tag_name IN (TOTAL_ARREARS_OWED_CP_AMNT, TOTAL_ARREARS_OWED_STATE_AMNT, STATE_ARREARS_OWED_YES_INDC, STATE_ARREARS_OWED_NO_INDC )) AS pvt);

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
