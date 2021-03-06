/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDHLD]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIDHLD
Programmer Name	:	IMP Team.
Description		:	This process loads receipt details for disbursement holds.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDHLD]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY               INT = 0,
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_Success_CODE                CHAR(1) = 'S',
          @Lc_DisbursementStatusHold_CODE CHAR(1) = 'H',
          @Lc_Failed_CODE                 CHAR(1) = 'F',
          @Lc_TypeError_CODE              CHAR(1) = 'E',
          @Lc_BateError_CODE              CHAR(5) = 'E0944',
          @Lc_Job_ID                      CHAR(7) = 'DEB0830',
          @Lc_Process_NAME                CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME              VARCHAR(50) = 'SP_PROCESS_BIDHLD',
          @Ld_Highdate_DATE               DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_SqlData_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BPDHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPDHLD_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPDHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPDHLD_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           Transaction_DATE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           TypeHold_CODE,
           Transaction_AMNT,
           Unique_IDNO,
           ReasonStatus_CODE,
           PayorMCI_IDNO,
           Receipt_DATE,
           EventGlobalSupportSeq_NUMB)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Transaction_DATE,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.TypeHold_CODE,
          a.Transaction_AMNT,
          a.Unique_IDNO,
          a.ReasonStatus_CODE,
          ISNULL(x.PayorMCI_IDNO, @Ln_Zero_NUMB) AS PayorMCI_IDNO,
          ISNULL(x.Receipt_DATE, @Lc_Space_TEXT) AS Receipt_DATE,
          a.EventGlobalSupportSeq_NUMB
     FROM DHLD_Y1 a
          LEFT OUTER JOIN (SELECT DISTINCT
                                  b.Batch_DATE,
                                  b.SourceBatch_CODE,
                                  b.Batch_NUMB,
                                  b.SeqReceipt_NUMB,
                                  b.Receipt_DATE,
                                  b.PayorMCI_IDNO
                             FROM RCTH_Y1 b
                            WHERE b.EndValidity_DATE = @Ld_Highdate_DATE) AS x
           ON a.Batch_DATE = x.Batch_DATE
              AND a.SourceBatch_CODE = x.SourceBatch_CODE
              AND a.Batch_NUMB = x.Batch_NUMB
              AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB
    WHERE a.Status_CODE = @Lc_DisbursementStatusHold_CODE
      AND a.EndValidity_DATE = @Ld_Highdate_DATE;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_Failed_CODE;
    SET @An_RecordCount_NUMB = 0;
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

    IF @Ln_Error_NUMB <> 50001
     BEGIN
      SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
     END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH
 END 

GO
