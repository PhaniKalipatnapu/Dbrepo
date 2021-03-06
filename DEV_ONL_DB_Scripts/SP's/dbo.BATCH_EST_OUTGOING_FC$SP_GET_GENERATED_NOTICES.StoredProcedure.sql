/****** Object:  StoredProcedure [dbo].[BATCH_EST_OUTGOING_FC$SP_GET_GENERATED_NOTICES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_OUTGOING_FC$SP_GET_GENERATED_NOTICES
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_EST_OUTGOING_FC$SP_GET_GENERATED_NOTICES batch process is to 
					 get the list of generated notices
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_OUTGOING_FC$SP_GET_GENERATED_NOTICES]
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR (5) = '' OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) = '' OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_GeneratePdfN_INDC  CHAR(1) = 'N',
          @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_County_TEXT        CHAR(6) = 'COUNTY',
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_GET_GENERATED_NOTICES',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Empty_TEXT            CHAR = '',
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Run_DATE              DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET GENERATED NOTICES';
   SET @Ls_Sqldata_TEXT = '';

   SELECT M.Case_IDNO,
          M.County_IDNO,
          M.County_NAME,
          M.MajorIntSeq_NUMB,
          M.ActivityMajor_CODE,
          M.ReasonStatus_CODE,
          M.Barcode_NUMB,
          M.GeneratedPdf_NAME
     FROM (SELECT DISTINCT
                  Row_NUMB = ROW_NUMBER() OVER ( ORDER BY A.Case_IDNO, A.MajorIntSeq_NUMB, A.ActivityMajor_CODE, A.ReasonStatus_CODE, C.Notice_ID DESC, A.Barcode_NUMB),
                  A.Case_IDNO,
                  A.County_IDNO,
                  LTRIM(RTRIM(REPLACE(REPLACE(LTRIM(RTRIM(B.County_NAME)), @Lc_County_TEXT, ''), @Lc_Space_TEXT, ''))) AS County_NAME,
                  A.MajorIntSeq_NUMB,
                  A.ActivityMajor_CODE,
                  A.ReasonStatus_CODE,
                  A.Barcode_NUMB,
                  CAST(A.Barcode_NUMB AS VARCHAR) + '.PDF' AS GeneratedPdf_NAME
             FROM PDAFP_Y1 A,
                  COPT_Y1 B,
                  FORM_Y1 C
            WHERE C.Barcode_NUMB = A.Barcode_NUMB
              AND B.County_IDNO = A.County_IDNO
              AND NOT EXISTS (SELECT 1
                                FROM PDAFP_Y1 X
                               WHERE X.Case_IDNO = A.Case_IDNO
                                 AND X.County_IDNO = A.County_IDNO
                                 AND X.MajorIntSeq_NUMB = A.MajorIntSeq_NUMB
                                 AND X.ActivityMajor_CODE = A.ActivityMajor_CODE
                                 AND X.GeneratePdf_INDC = 'N')) M
    ORDER BY M.Row_NUMB;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
