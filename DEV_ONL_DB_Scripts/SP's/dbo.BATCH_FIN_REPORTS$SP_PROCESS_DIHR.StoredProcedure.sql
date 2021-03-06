/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REPORTS$SP_PROCESS_DIHR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REPORTS$SP_PROCESS_DIHR
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_COLLECTIONS$SP_PROCESS_DIHR takes held receipts data from DHLD_Y1
					  and loads into table RDIHR_Y1 Table. 
Frequency			: 'DAILY'
Developed On		: 10/19/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REPORTS$SP_PROCESS_DIHR]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusReceiptHeld_CODE CHAR(1) = 'H',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_StatusR_CODE           CHAR(1) = 'R',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_Job_ID                 CHAR(7) = 'DEB0900',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT      CHAR(30) = 'BATCH',
          @Lc_Parmdateproblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_FIN_REPORTS',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_DIHR',
          @Ld_Low_DATE               DATE = '01/01/0001',
          @Ld_High_DATE              DATE = '12/31/9999';
  DECLARE @Ln_County_IDNO				  NUMERIC(3) = 0,
		  @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ld_RunStart_DATE               DATE,
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_BeginValidity_DATE          DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   BEGIN TRANSACTION DihrTran;

   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
   --- Setting the Batch start time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   --  Selecting date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Job Run Date validation
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_Parmdateproblem_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DELETE RDIHR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   DELETE FROM RDIHR_Y1;
   
   SET @Ls_Sql_TEXT = 'SELECT RDIHR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ld_BeginValidity_DATE = ISNULL(MAX(r.BeginValidity_DATE), @Ld_Low_DATE)
     FROM RDIHR_Y1 r;

   IF @Ld_BeginValidity_DATE = @Ld_Low_DATE
    BEGIN
     SET @Ld_RunStart_DATE = @Ld_BeginValidity_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_RunStart_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO RDIHR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   INSERT RDIHR_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           Transaction_DATE,
           Case_IDNO,
           PayorMCI_IDNO,
           ObligationKey_TEXT,
           TypeDisburse_CODE,
           Transaction_AMNT,
           Receipt_ID,
           TypeHold_CODE,
           DescriptionHold_TEXT,
           ControlNo_TEXT,
           County_IDNO,
           ReasonStatus_CODE,
           DescriptionReason_TEXT,
           BeginValidity_DATE,
           EndValidity_DATE,
           First_NAME,
           Last_NAME,
           Middle_NAME,
           Worker_ID,
           Release_DATE,
           MemberSsn_NUMB,
           RespondInit_CODE,
           Recipient_NAME,
           Transaction_CODE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB,
           EventGlobalSupportSeq_NUMB,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB)
   SELECT a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.Disburse_DATE,
          a.DisburseSeq_NUMB,
          a.Transaction_DATE,
          a.Case_IDNO,
          x.PayorMCI_IDNO,
          ISNULL(CAST(a.Case_IDNO AS VARCHAR), '') + ISNULL(CAST(a.OrderSeq_NUMB AS VARCHAR), '') + ISNULL(CAST(a.ObligationSeq_NUMB AS VARCHAR), '') AS ObligationKey_TEXT,
          a.TypeDisburse_CODE,
          a.Transaction_AMNT,
          dbo.BATCH_COMMON$SF_GET_RECEIPT_NO(a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS ReceiptNo_TEXT,
          a.TypeHold_CODE,
          @Lc_Space_TEXT AS DescriptionHold_TEXT,
          @Lc_Space_TEXT AS ControlNo_TEXT,
          --When there is no Case ID, Central office code used for County_IDNO
          ISNULL(c.County_IDNO, @Ln_County_IDNO) AS County_IDNO,
          a.ReasonStatus_CODE,
          @Lc_Space_TEXT AS DescriptionReason_TEXT,
          a.BeginValidity_DATE,
          a.EndValidity_DATE,
          @Lc_Space_TEXT AS First_NAME,
          @Lc_Space_TEXT AS Last_NAME,
          @Lc_Space_TEXT AS Middle_NAME,
          ISNULL(c.Worker_ID, @Lc_Space_TEXT) AS Worker_ID,
          a.Release_DATE,
          0 AS MemberSsn_NUMB,
          ISNULL(c.RespondInit_CODE,@Lc_Space_TEXT) AS RespondInit_CODE,
          dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(a.CheckRecipient_ID, a.CheckRecipient_CODE) AS Recipient_NAME,
          a.Status_CODE AS Transaction_CODE,
          a.EventGlobalBeginSeq_NUMB,
          a.EventGlobalEndSeq_NUMB,
          a.EventGlobalSupportSeq_NUMB,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB
     FROM (SELECT a.Case_IDNO,
                  a.OrderSeq_NUMB,
                  a.ObligationSeq_NUMB,
                  a.Batch_DATE,
                  a.SourceBatch_CODE,
                  a.Batch_NUMB,
                  a.SeqReceipt_NUMB,
                  a.Transaction_DATE,
                  a.Release_DATE,
                  a.TypeDisburse_CODE,
                  a.Transaction_AMNT,
                  a.Status_CODE,
                  a.TypeHold_CODE,
                  a.ProcessOffset_INDC,
                  a.CheckRecipient_ID,
                  a.CheckRecipient_CODE,
                  a.ReasonStatus_CODE,
                  a.Unique_IDNO,
                  a.EventGlobalSupportSeq_NUMB,
                  a.EventGlobalBeginSeq_NUMB,
                  a.EventGlobalEndSeq_NUMB,
                  a.BeginValidity_DATE,
                  a.EndValidity_DATE,
                  a.Disburse_DATE,
                  a.DisburseSeq_NUMB,
                  a.StatusEscheat_DATE,
                  a.StatusEscheat_CODE
             FROM DHLD_Y1 a
            WHERE a.Transaction_DATE BETWEEN @Ld_RunStart_DATE AND @Ld_Run_DATE
              AND (a.Status_CODE = @Lc_StatusReceiptHeld_CODE
                    OR (a.Status_CODE = @Lc_StatusR_CODE
                        AND a.Transaction_DATE > a.Batch_DATE))) AS a
          -- Receipts from VDHLD that do not have Case ID also included to insert into DIHR_Y1                        
          LEFT OUTER JOIN CASE_Y1 c
           ON a.Case_IDNO = c.Case_IDNO,
          (SELECT y.Batch_DATE,
                  y.SourceBatch_CODE,
                  y.Batch_NUMB,
                  y.SeqReceipt_NUMB,
                  y.SourceReceipt_CODE,
                  y.TypeRemittance_CODE,
                  y.TypePosting_CODE,
                  y.Case_IDNO,
                  y.PayorMCI_IDNO,
                  y.Receipt_AMNT,
                  y.ToDistribute_AMNT,
                  y.Fee_AMNT,
                  y.Employer_IDNO,
                  y.Fips_CODE,
                  y.Check_DATE,
                  y.CheckNo_TEXT,
                  y.Receipt_DATE,
                  y.Distribute_DATE,
                  y.Tanf_CODE,
                  y.TaxJoint_CODE,
                  y.TaxJoint_NAME,
                  y.StatusReceipt_CODE,
                  y.ReasonStatus_CODE,
                  y.BackOut_INDC,
                  y.ReasonBackOut_CODE,
                  y.Refund_DATE,
                  y.Release_DATE,
                  y.ReferenceIrs_IDNO,
                  y.RefundRecipient_ID,
                  y.RefundRecipient_CODE,
                  y.BeginValidity_DATE,
                  y.EndValidity_DATE,
                  y.EventGlobalBeginSeq_NUMB,
                  y.EventGlobalEndSeq_NUMB,
                  y.rnm
             FROM (SELECT a.Batch_DATE,
                          a.SourceBatch_CODE,
                          a.Batch_NUMB,
                          a.SeqReceipt_NUMB,
                          a.SourceReceipt_CODE,
                          a.TypeRemittance_CODE,
                          a.TypePosting_CODE,
                          a.Case_IDNO,
                          a.PayorMCI_IDNO,
                          a.Receipt_AMNT,
                          a.ToDistribute_AMNT,
                          a.Fee_AMNT,
                          a.Employer_IDNO,
                          a.Fips_CODE,
                          a.Check_DATE,
                          a.CheckNo_TEXT,
                          a.Receipt_DATE,
                          a.Distribute_DATE,
                          a.Tanf_CODE,
                          a.TaxJoint_CODE,
                          a.TaxJoint_NAME,
                          a.StatusReceipt_CODE,
                          a.ReasonStatus_CODE,
                          a.BackOut_INDC,
                          a.ReasonBackOut_CODE,
                          a.Refund_DATE,
                          a.Release_DATE,
                          a.ReferenceIrs_IDNO,
                          a.RefundRecipient_ID,
                          a.RefundRecipient_CODE,
                          a.BeginValidity_DATE,
                          a.EndValidity_DATE,
                          a.EventGlobalBeginSeq_NUMB,
                          a.EventGlobalEndSeq_NUMB,
                          ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS rnm
                     FROM RCTH_Y1 a
                    WHERE a.EndValidity_DATE = @Ld_High_DATE
                      AND EXISTS (SELECT 1
                                    FROM DHLD_Y1 z
                                   WHERE a.Batch_DATE = z.Batch_DATE
                                     AND a.Batch_NUMB = z.Batch_NUMB
                                     AND a.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                                     AND a.SourceBatch_CODE = z.SourceBatch_CODE)) AS y
            WHERE y.rnm = 1) AS x
    WHERE a.Batch_DATE = x.Batch_DATE
      AND a.Batch_NUMB = x.Batch_NUMB
      AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB
      AND a.SourceBatch_CODE = x.SourceBatch_CODE;

   SET @Ls_Sql_TEXT = 'UPDATE RDIHR_Y1 - REASON CODE - FOR RELEASED RECEIPTS';
   SET @Ls_Sqldata_TEXT = 'Transaction_CODE = ' + ISNULL(@Lc_StatusR_CODE,'');
   UPDATE RDIHR_Y1
      SET ReasonStatus_CODE = ISNULL((SELECT TOP 1 x.ReasonStatus_CODE
                                        FROM DHLD_Y1 x
                                       WHERE a.Batch_DATE = x.Batch_DATE
                                         AND a.Batch_NUMB = x.Batch_NUMB
                                         AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                         AND a.SourceBatch_CODE = x.SourceBatch_CODE
                                         AND a.Case_IDNO = x.Case_IDNO
                                         AND a.OrderSeq_NUMB = x.OrderSeq_NUMB
                                         AND a.ObligationSeq_NUMB = x.ObligationSeq_NUMB
                                         AND x.Status_CODE = @Lc_StatusReceiptHeld_CODE
                                         AND a.Transaction_AMNT <= x.Transaction_AMNT
                                         AND x.BeginValidity_DATE < a.BeginValidity_DATE), @Lc_Space_TEXT)
     FROM RDIHR_Y1 a
    WHERE a.Transaction_CODE = @Lc_StatusR_CODE
      AND a.BeginValidity_DATE BETWEEN @Ld_RunStart_DATE AND @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'SELECT RDIHR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM RDIHR_Y1 a;

   --Update the parameter table with the job run date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Successful Execution write to BSTL
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION DihrTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DihrTran;
    END

   --Check for Exception information to log the description text based on the error
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
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY =@Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
