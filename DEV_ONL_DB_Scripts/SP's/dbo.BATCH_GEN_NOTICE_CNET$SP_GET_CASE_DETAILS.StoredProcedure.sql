/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CASE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


   /*
   ---------------------------------------------------------
    Procedure Name     : BATCH_GEN_NOTICE_CNET$SP_GET_CASE_DETAILS
    Programmer Name    : IMP Team.
    Description        : Get Csenet case details
    Frequency          :
    Developed On       : 12/27/2011
    Called By          :
    Called On          :
   ---------------------------------------------------------
    Modified By        :
    Modified On        :
    Version No         : 1.0
   ---------------------------------------------------------
   */
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CASE_DETAILS] (
   @An_Case_IDNO                      NUMERIC (6),
   @Ac_Notice_ID                      CHAR (8),
   @An_OrderSeq_NUMB                  NUMERIC (2),
   @An_MajorIntSeq_NUMB               NUMERIC (5),
   @Ac_Msg_CODE                       CHAR (5)     OUTPUT ,
   @As_DescriptionError_TEXT          VARCHAR(4000) OUTPUT
   )
AS
   BEGIN
      SET  NOCOUNT ON;
      DECLARE
         @Ln_One_NUMB NUMERIC (3) = 1,
         @Ln_Two_NUMB NUMERIC (3) = 2,
         @Lc_StatusSuccess_CODE CHAR (1)  = 'S',
         @Lc_StatusFailed_CODE CHAR (1)   = 'F',
         @Lc_TableCpro_IDNO CHAR (4)      = 'CPRO',
         @Lc_TableSubReas_IDNO CHAR (4)   = 'REAS',
         @Lc_ReasonStatusWs_CODE CHAR (2) = 'WS',
         @Lc_ReasonStatusZn_CODE CHAR (2) = 'ZN',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_CNET$SP_GET_CASE_DETAILS';

      DECLARE
         @Ln_CaseOrderSeq_NUMB NUMERIC (9),
         @Ln_SordOrderSeq_NUMB NUMERIC (9),
         @Ln_BarcodeOut_NUMB NUMERIC (19),
         @Lc_ReasonStatus_CODE CHAR (2),
         @Lc_CaseClosureReason_CODE CHAR (5),
         @Ls_Sql_TEXT VARCHAR (100),
         @Ls_Sqldata_TEXT VARCHAR (200),
         @Ls_DescriptionError_TEXT VARCHAR (4000);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         SET @Ln_CaseOrderSeq_NUMB = 0;
         SET @Ln_SordOrderSeq_NUMB = 1;
         SET @Ln_BarcodeOut_NUMB =
                (SELECT MAX (F.Barcode_NUMB)
                   FROM FORM_Y1 F
                  WHERE F.Topic_IDNO IN
                           (SELECT DM.Topic_IDNO
                              FROM DMNR_Y1 DM
                             WHERE DM.Case_IDNO = @An_Case_IDNO
                                   AND DM.OrderSeq_NUMB = @An_OrderSeq_NUMB
                                   AND DM.MajorIntSEQ_NUMB =
                                          @An_MajorIntSeq_NUMB)
                        AND Notice_ID = @Ac_Notice_ID);
         SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1';
         SET @Ls_Sqldata_TEXT =  'Case_IDNO'  + ISNULL (CAST (@An_Case_IDNO AS VARCHAR(6)), '')
                                + ' OrderSeq_NUMB'        + ISNULL (CAST (@An_OrderSeq_NUMB AS VARCHAR (2)), '')
                                + ' MajorIntSEQ_NUMB  '  + ISNULL (CAST (@An_MajorIntSeq_NUMB AS VARCHAR (2)), '');
         SELECT @Lc_ReasonStatus_CODE = n.ReasonStatus_CODE,
                @Lc_CaseClosureReason_CODE =
                   dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (
                      @Lc_TableCpro_IDNO,
                      @Lc_TableSubReas_IDNO,
                      n.ReasonStatus_CODE)
           FROM DMNR_Y1 n
          WHERE n.Case_IDNO = @An_Case_IDNO
                AND n.OrderSeq_NUMB IN
                       (@Ln_CaseOrderSeq_NUMB, @Ln_SordOrderSeq_NUMB)
                AND n.MajorIntSEQ_NUMB = @An_MajorIntSeq_NUMB
                AND n.MinorIntSeq_NUMB = @Ln_One_NUMB;

         IF (@Lc_ReasonStatus_CODE IN
               (@Lc_ReasonStatusWs_CODE, @Lc_ReasonStatusZn_CODE)
               )
            INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
               (SELECT pvt.Element_NAME, pvt.Element_VALUE
                  FROM (SELECT CONVERT (VARCHAR (100),
                                        CaseClosureReason_CODE)
                                  AS CASE_CLOSURE_REASON
                          FROM (SELECT dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (
                                          @Lc_TableCpro_IDNO,
                                          @Lc_TableSubReas_IDNO,
                                          n.ReasonStatus_CODE)
                                          AS CaseClosureReason_CODE
                                  FROM DMNR_Y1 n
                                 WHERE n.Case_IDNO = @An_Case_IDNO
                                       AND n.OrderSeq_NUMB IN
                                              (@Ln_CaseOrderSeq_NUMB,
                                               @Ln_SordOrderSeq_NUMB)
                                       AND n.MajorIntSEQ_NUMB =
                                              @An_MajorIntSeq_NUMB
                                       AND n.MinorIntSeq_NUMB = @Ln_Two_NUMB) a) up 
                                     UNPIVOT (Element_VALUE FOR Element_NAME IN  (CASE_CLOSURE_REASON)) AS pvt);

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB     INT =  ERROR_NUMBER(),
                 @Li_ErrorLine_NUMB INT =  ERROR_LINE ();
         
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =   SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END

GO
