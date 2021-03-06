/****** Object:  StoredProcedure [dbo].[BATCH_FIN_ESCHEATMENT$SP_PROCESS_MARK_PENDING_ESCHEAT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_ESCHEATMENT$SP_PROCESS_MARK_PENDING_ESCHEAT
Programmer Name		: IMP Team
Description			: This process identifies the unidentified receipts in RCTH_Y1 table where the receipt date (Receipt
					  Date in RCTH_Y1) is equal to or greater earlier than 1825 days or five years from batch run date and
					  updates the UDC code (Reason Status Code in RCTH_Y1) to 'UMPE' – Manual Pending Escheatment if the
					  current UDC code is 'UMDF' – Manual Unidentifiable and updates to 'USPE' – System Pending Escheatment
					  in case of other unidentified receipts.
					  In addition to the unidentified receipts, for identified receipts, it updates the UDC code (Reason Status
					  Code in DHLD_Y1) of the disbursement holds in DHLD_Y1 table to ’SDPE' – System Disbursement Pending
					  Escheatment where the disbursement date in DHLD_Y1 table is equal to or greater earlier than 1825 days or
					  five years from batch run date
Frequency			: Annually
Developed On		: 4/12/2011
Called By			:
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_ESCHEATMENT$SP_PROCESS_MARK_PENDING_ESCHEAT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_PendingEscheatment2270_NUMB               INT = 2270,
          @Lc_Yes_INDC                                  CHAR(1) = 'Y',
          @Lc_No_INDC                                   CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE                        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                         CHAR(1) = 'F',
          @Lc_TypeErrorE_CODE                           CHAR(1) = 'E',
          @Lc_TypeErrorWarning_CODE                     CHAR(1) = 'W',
          @Lc_StatusAbnormalend_CODE                    CHAR(1) = 'A',
          @Lc_TypeHoldCp_CODE							CHAR(1) = 'P',
          @Lc_StatusReceiptUnidentified_CODE            CHAR(1) = 'U',
          @Lc_RecipientCpNcp_CODE                       CHAR(1) = '1',
          @Lc_RecipientFips_CODE                        CHAR(1) = '2',
          @Lc_RecipientOtherParty_CODE                  CHAR(1) = '3',
          @Lc_Space_TEXT                                CHAR(1) = ' ',
          @Lc_ReasonManualUnidentifiable_CODE           CHAR(4) = 'UMDF',
          @Lc_ReasonSystemPendingEscheatment_CODE       CHAR(4) = 'USPE',
          @Lc_ReasonManualPendingEscheatment_CODE       CHAR(4) = 'UMPE',
          @Lc_SystemDisbursementPendingEscheatment_CODE CHAR(4) = 'SDPE',
          @Lc_NoRecordsToProcess_CODE                   CHAR(5) = 'E0944',
          @Lc_BateErrorUnknown_CODE                     CHAR(5) = 'E1424',
          @Lc_Job_ID                                    CHAR(7) = 'DEB8590',
          @Lc_Successful_TEXT                           CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                         CHAR(30) = 'BATCH',
          @Lc_Process_NAME                              CHAR(30) = 'BATCH_FIN_ESCHEATMENT',
          @Lc_Procedure_NAME                            CHAR(31) = 'SP_PROCESS_MARK_PENDING_ESCHEAT',
          @Ld_High_DATE                                 DATE = '12/31/9999',
          @Ld_Low_DATE                                  DATE = '01/01/0001',
          @Ld_Start_DATE                                DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5) =0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) =0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) =0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_RcthCursorIndex_QNTY        NUMERIC(10) = 0,
          @Ln_DhldCursorIndex_QNTY        NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) =0,
          @Ln_Error_NUMB                  NUMERIC(11) =0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) =0,
          @Ln_RowCount_QNTY               NUMERIC(11) =0,
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19) =0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Lc_BateError_CODE              CHAR(5),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Prev5Year_DATE              DATE;
  DECLARE @Ld_RcptCur_Batch_DATE               DATE,
          @Lc_RcptCur_SourceBatch_CODE         CHAR(3),
          @Ln_RcptCur_Batch_NUMB               NUMERIC(4),
          @Ln_RcptCur_SeqReceipt_NUMB          NUMERIC(6),
          @Ln_RcptCur_EventGlobalBeginSeq_NUMB NUMERIC(19);
  DECLARE @Ln_DhldCur_Case_IDNO          NUMERIC(6),
          @Ln_DhldCur_OrderSeq_NUMB      NUMERIC(2),
          @Ln_DhldCur_ObligationSeq_NUMB NUMERIC(2),
          @Ld_DhldCur_Transaction_DATE   DATE,
          @Ln_DhldCur_Unique_IDNO        NUMERIC(19),
          @Lc_DhldCur_CheckRecipient_ID  CHAR(10),
          @Ld_DhldCur_Batch_DATE         DATE,
          @Lc_DhldCur_SourceBatch_CODE   CHAR(3),
          @Ln_DhldCur_Batch_NUMB         NUMERIC(4),
          @Ln_DhldCur_SeqReceipt_NUMB    NUMERIC(6);

  BEGIN TRY
   BEGIN TRANSACTION ESCHEAT;

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

   /*
   Get the run date and last run date from Parameter (PARM_Y1) table and validate that the batch program was not executed for the run date, by ensuring that the run date is different from the last run date in the PARM_Y1 table
   */
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ld_Prev5Year_DATE = DATEADD(yy, -5, @Ld_Run_DATE);

   /*
      Get Unidentified receipts from Receipt History (RCTH_Y1) table 
   */
   DECLARE Rcpt_CUR INSENSITIVE CURSOR FOR
    SELECT a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.EventGlobalBeginSeq_NUMB
      FROM RCTH_Y1 a
     WHERE
     --Receipt status is Unidentified and 
     a.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
    AND a.EndValidity_DATE = @Ld_High_DATE
    --Receipt Date is equal to or greater than earlier than 1825 days or five years from batch run date and
    AND a.Receipt_DATE <= @Ld_Prev5Year_DATE
    AND NOT EXISTS (SELECT 1
                   FROM RCTH_Y1 b
                  WHERE b.Batch_DATE = a.Batch_DATE
                    AND b.SourceBatch_CODE = a.SourceBatch_CODE
                    AND b.Batch_NUMB = a.Batch_NUMB
                    AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                    --Receipt is not Backed Out/Reversed 
                    AND b.BackOut_INDC = @Lc_Yes_INDC
                    AND b.EndValidity_DATE = @Ld_High_DATE)
    AND a.ReasonStatus_CODE NOT IN (@Lc_ReasonManualPendingEscheatment_CODE, @Lc_ReasonSystemPendingEscheatment_CODE);

   SET @Ls_Sql_TEXT='OPEN Rcpt_CUR -1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Rcpt_CUR;

   SET @Ls_Sql_TEXT='FETCH Rcpt_CUR -1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Rcpt_CUR INTO @Ld_RcptCur_Batch_DATE, @Lc_RcptCur_SourceBatch_CODE, @Ln_RcptCur_Batch_NUMB, @Ln_RcptCur_SeqReceipt_NUMB, @Ln_RcptCur_EventGlobalBeginSeq_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT='WHILE -1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcptCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcptCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_RcptCur_EventGlobalBeginSeq_NUMB AS VARCHAR);

   /*
   while loop for updating UDC code in RCTH_Y1 to 'UMPE' - Manual Pending Escheatment if the current is UDC code RCTH_Y1 is 
   'UMDF' - Manual Unidentifiable Pending Escheatment or it will be updated to 'USPE' - System Unidentifiable
   Pending Escheatment
   */
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION ESCHEAT_SAVE

      SET @Ln_RcthCursorIndex_QNTY = @Ln_RcthCursorIndex_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_ErrorMessage_TEXT ='';
      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_CursorLocation_TEXT = 'RcthCursorIndex_QNTY = ' + ISNULL(CAST(@Ln_RcthCursorIndex_QNTY AS VARCHAR), '');
      SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcptCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcptCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_RcptCur_EventGlobalBeginSeq_NUMB AS VARCHAR);
      /*
      Call the common routine 'BATCH_COMMON$SP_GENERATE_SEQ' to generate a sequence number
      */
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ RCTH_Y1 ';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PendingEscheatment2270_NUMB AS VARCHAR), '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + @Lc_Job_ID + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_PendingEscheatment2270_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = ' UPDATE RCTH_Y1 ';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcptCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcptCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_RcptCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', High_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      UPDATE RCTH_Y1
         SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
             EndValidity_DATE = @Ld_Run_DATE
       WHERE Batch_DATE = @Ld_RcptCur_Batch_DATE
         AND SourceBatch_CODE = @Lc_RcptCur_SourceBatch_CODE
         AND Batch_NUMB = @Ln_RcptCur_Batch_NUMB
         AND SeqReceipt_NUMB = @Ln_RcptCur_SeqReceipt_NUMB
         AND EventGlobalBeginSeq_NUMB = @Ln_RcptCur_EventGlobalBeginSeq_NUMB
         AND EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY=@@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = ' UPDATE RCTH_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END

      /*
      	update the UDC code in RCTH_Y1 to 'UMPE' - Manual Pending Escheatment if the current is UDC code RCTH_Y1 is 
      	'UMDF' - Manual Unidentifiable Pending Escheatment or it will be updated to 'USPE' - System Unidentifiable
      	Pending Escheatment
      */
      SET @Ls_Sql_TEXT = ' INSERT RCTH_Y1 ';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcptCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcptCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcptCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', High_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', ReasonManualUnidentifiable_CODE = ' + @Lc_ReasonManualUnidentifiable_CODE + ', ReasonManualPendingEscheatment_CODE = ' + @Lc_ReasonManualPendingEscheatment_CODE;

      INSERT RCTH_Y1
             (Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              SourceReceipt_CODE,
              TypeRemittance_CODE,
              TypePosting_CODE,
              Case_IDNO,
              PayorMCI_IDNO,
              Receipt_AMNT,
              ToDistribute_AMNT,
              Fee_AMNT,
              Employer_IDNO,
              Fips_CODE,
              Check_DATE,
              CheckNo_Text,
              Receipt_DATE,
              Distribute_DATE,
              Tanf_CODE,
              TaxJoint_CODE,
              TaxJoint_NAME,
              StatusReceipt_CODE,
              ReasonStatus_CODE,
              BackOut_INDC,
              ReasonBackOut_CODE,
              BeginValidity_DATE,
              EndValidity_DATE,
              Release_DATE,
              EventGlobalBeginSeq_NUMB,
              EventGlobalEndSeq_NUMB,
              Refund_DATE,
              ReferenceIrs_IDNO,
              RefundRecipient_CODE,
              RefundRecipient_ID)
      SELECT a.Batch_DATE,
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
             a.CheckNo_Text,
             a.Receipt_DATE,
             @Ld_Low_DATE AS Distribute_DATE,
             a.Tanf_CODE,
             a.TaxJoint_CODE,
             a.TaxJoint_NAME,
             a.StatusReceipt_CODE,
             CASE a.ReasonStatus_CODE
              WHEN @Lc_ReasonManualUnidentifiable_CODE
               THEN @Lc_ReasonManualPendingEscheatment_CODE
              ELSE @Lc_ReasonSystemPendingEscheatment_CODE
             END AS ReasonStatus_CODE,
             a.BackOut_INDC,
             a.ReasonBackOut_CODE,
             @Ld_Run_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             a.Release_DATE,
             @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             a.Refund_DATE,
             a.ReferenceIrs_IDNO,
             a.RefundRecipient_CODE,
             a.RefundRecipient_ID
        FROM RCTH_Y1 a
       WHERE a.Batch_DATE = @Ld_RcptCur_Batch_DATE
         AND a.SourceBatch_CODE = @Lc_RcptCur_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_RcptCur_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_RcptCur_SeqReceipt_NUMB
         AND a.EndValidity_DATE = @Ld_Run_DATE
         AND a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

      SET @Ln_RowCount_QNTY=@@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = ' INSERT RCTH_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION ESCHEAT_SAVE
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Lc_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', RcthCursorIndex_QNTY = ' + CAST(@Ln_RcthCursorIndex_QNTY AS VARCHAR) + ', BateError_CODE = ' + @Lc_BateError_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Lc_Process_NAME,
       @As_Procedure_NAME           = @Lc_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_RcthCursorIndex_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION ESCHEAT;

       BEGIN TRANSACTION ESCHEAT;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'ExceptionThreshold Check -1';
     SET @Ls_Sqldata_TEXT ='ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION ESCHEAT;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT='FETCH Rcpt_CUR -2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Rcpt_CUR INTO @Ld_RcptCur_Batch_DATE, @Lc_RcptCur_SourceBatch_CODE, @Ln_RcptCur_Batch_NUMB, @Ln_RcptCur_SeqReceipt_NUMB, @Ln_RcptCur_EventGlobalBeginSeq_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Rcpt_CUR;

   DEALLOCATE Rcpt_CUR;

   COMMIT TRANSACTION ESCHEAT;

   BEGIN TRANSACTION ESCHEAT;

   SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY;
   SET @Ln_CommitFreq_QNTY =0;

   /*
   Get Identified receipts in Disbursement Hold (DHLD_Y1) table
   */
   DECLARE Dhld_CUR INSENSITIVE CURSOR FOR
    SELECT b.Case_IDNO,
           b.OrderSeq_NUMB,
           b.ObligationSeq_NUMB,
           b.Transaction_DATE,
           b.Unique_IDNO,
           b.CheckRecipient_ID,
           b.Batch_DATE,
           b.SourceBatch_CODE,
           b.Batch_NUMB,
           b.SeqReceipt_NUMB
      FROM DHLD_Y1 b
     --Disbursement date  is equal to or greater than earlier than 1825 days or five years from batch run date
     WHERE b.Disburse_DATE <= @Ld_Prev5Year_DATE
           --Recipient is CP MCI, NCP MCI, OTHP ID or FIPS ID
           AND b.CheckRecipient_CODE IN (@Lc_RecipientCpNcp_CODE, @Lc_RecipientFips_CODE, @Lc_RecipientOtherParty_CODE)
           AND b.EndValidity_DATE = @Ld_High_DATE
           AND EXISTS (SELECT 1
                         FROM RCTH_Y1 a
                        WHERE a.Receipt_DATE <= @Ld_Prev5Year_DATE
                          AND a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND a.EndValidity_DATE = @Ld_High_DATE)
           AND NOT EXISTS (SELECT 1
                             FROM RCTH_Y1 c
                            WHERE c.Batch_DATE = b.Batch_DATE
                              AND c.SourceBatch_CODE = b.SourceBatch_CODE
                              AND c.Batch_NUMB = b.Batch_NUMB
                              AND c.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                              --Receipt is not Backed Out/Reversed
                              AND c.BackOut_INDC = @Lc_Yes_INDC
                              AND c.EndValidity_DATE = @Ld_High_DATE)
           AND b.ReasonStatus_CODE <> @Lc_SystemDisbursementPendingEscheatment_CODE;

   SET @Ls_Sql_TEXT='OPEN Dhld_CUR -1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Dhld_CUR;

   SET @Ls_Sql_TEXT='FETCH Dhld_CUR -2';
   SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

   FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Unique_IDNO, @Lc_DhldCur_CheckRecipient_ID, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT='WHILE LOOP -2';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DhldCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_DhldCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR);

   /*
   while loop for updating Reason field to 'SDPE - System Disbursement Pending Escheatment' in DHLD_Y1 table
   */
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION ESCHEAT_SAVE

      SET @Ln_DhldCursorIndex_QNTY = @Ln_DhldCursorIndex_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_ErrorMessage_TEXT ='';
      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_CursorLocation_TEXT = ' DhldCursorIndex_QNTY = ' + ISNULL(CAST(@Ln_DhldCursorIndex_QNTY AS VARCHAR), '');
      SET @Ls_BateRecord_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DhldCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_DhldCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ DHLD_Y1';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PendingEscheatment2270_NUMB AS VARCHAR), '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + @Lc_Job_ID + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_PendingEscheatment2270_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'UPDATE_DHLD';
      SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DhldCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', High_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR);

      UPDATE DHLD_Y1
         SET EndValidity_DATE = @Ld_Run_DATE,
             EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
        FROM DHLD_Y1 a
       WHERE a.Case_IDNO = @Ln_DhldCur_Case_IDNO
         AND a.OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB
         AND a.ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
         AND a.Transaction_DATE = @Ld_DhldCur_Transaction_DATE
         AND a.Unique_IDNO = @Ln_DhldCur_Unique_IDNO
         AND a.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY=@@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE DHLD_Y1 FAILED';

        RAISERROR (50001,16,1);
       END

      /*
      update the Reason field to 'SDPE - System Disbursement Pending Escheatment' for the above receipts in DHLD_Y1 table
      */
      SET @Ls_Sql_TEXT = 'INSERT INTO DHLD_Y1';
      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', High_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR)+', SystemDisbursementPendingEscheatment_CODE = '+@Lc_SystemDisbursementPendingEscheatment_CODE;

      INSERT DHLD_Y1
             (Case_IDNO,
              OrderSeq_NUMB,
              ObligationSeq_NUMB,
              Batch_DATE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              SourceBatch_CODE,
              Transaction_DATE,
              Transaction_AMNT,
              Status_CODE,
              TypeHold_CODE,
              TypeDisburse_CODE,
              CheckRecipient_ID,
              CheckRecipient_CODE,
              ProcessOffset_INDC,
              ReasonStatus_CODE,
              BeginValidity_DATE,
              EndValidity_DATE,
              EventGlobalBeginSeq_NUMB,
              EventGlobalEndSeq_NUMB,
              EventGlobalSupportSeq_NUMB,
              Release_DATE,
              Disburse_DATE,
              DisburseSeq_NUMB,
              StatusEscheat_DATE,
              StatusEscheat_CODE)
      SELECT a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB,
             a.Batch_DATE,
             a.Batch_NUMB,
             a.SeqReceipt_NUMB,
             a.SourceBatch_CODE,
             @Ld_Run_DATE AS Transaction_DATE,
             a.Transaction_AMNT,
             a.Status_CODE,
             --13576 :Not able to release SDPE hold on DHLD for escheatment receipts with DHLD_Y1.TypeHold_CODE<>'P'
             @Lc_TypeHoldCp_CODE AS TypeHold_CODE,
             a.TypeDisburse_CODE,
             a.CheckRecipient_ID,
             a.CheckRecipient_CODE,
             a.ProcessOffset_INDC,
             @Lc_SystemDisbursementPendingEscheatment_CODE AS ReasonStatus_CODE,
             @Ld_Run_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             a.EventGlobalSupportSeq_NUMB,
             a.Release_DATE,
             a.Disburse_DATE,
             a.DisburseSeq_NUMB,
             a.StatusEscheat_DATE,
             a.StatusEscheat_CODE
        FROM DHLD_Y1 a
       WHERE a.Case_IDNO = @Ln_DhldCur_Case_IDNO
         AND a.OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB
         AND a.ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
         AND a.Transaction_DATE = @Ld_DhldCur_Transaction_DATE
         AND a.Unique_IDNO = @Ln_DhldCur_Unique_IDNO
         AND a.EndValidity_DATE = @Ld_Run_DATE
         AND a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

      SET @Ln_RowCount_QNTY=@@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT DHLD FAILED';

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION ESCHEAT_SAVE
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Lc_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', DhldCursorIndex_QNTY = ' + CAST(@Ln_DhldCursorIndex_QNTY AS VARCHAR) + ', BateError_CODE = ' + @Lc_BateError_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Lc_Process_NAME,
       @As_Procedure_NAME           = @Lc_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_DhldCursorIndex_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION ESCHEAT;

       BEGIN TRANSACTION ESCHEAT;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY + @Ln_DhldCursorIndex_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'ExceptionThreshold Check -2';
     SET @Ls_Sqldata_TEXT ='ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION ESCHEAT;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY + @Ln_DhldCursorIndex_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT='FETCH Dhld_CUR -2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Unique_IDNO, @Lc_DhldCur_CheckRecipient_ID, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Dhld_CUR;

   DEALLOCATE Dhld_CUR;

   IF @Ln_RcthCursorIndex_QNTY = 0
      AND @Ln_DhldCursorIndex_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 3';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorWarning_CODE + ', Line_NUMB = ' + CAST(@Ln_RcthCursorIndex_QNTY AS VARCHAR) + ', Error_CODE  = ' + @Lc_NoRecordsToProcess_CODE + ', Sqldata_TEXT = ' + @Ls_Sqldata_TEXT + ', Space_TEXT = ' + @Lc_Space_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_RcthCursorIndex_QNTY,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

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
    END;

   SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY + @Ln_DhldCursorIndex_QNTY;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Successful_TEXT = ' + @Lc_Successful_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', StatusSuccess_CODE = ' + @Lc_StatusSuccess_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Space_TEXT = ' + @Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                 = @Ld_Run_DATE,
    @Ad_Start_DATE               = @Ld_Start_DATE,
    @Ac_Job_ID                   = @Lc_Job_ID,
    @As_Process_NAME             = @Lc_Process_NAME,
    @As_Procedure_NAME           = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT      = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT        = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY=@Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT             = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
    @Ac_Status_CODE              = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT;

   COMMIT TRANSACTION ESCHEAT;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ESCHEAT;
    END;

   IF CURSOR_STATUS ('VARIABLE', 'Rcpt_CUR') IN (0, 1)
    BEGIN
     CLOSE Rcpt_CUR;

     DEALLOCATE Rcpt_CUR;
    END

   IF CURSOR_STATUS ('VARIABLE', 'Dhld_CUR') IN (0, 1)
    BEGIN
     CLOSE Dhld_CUR;

     DEALLOCATE Dhld_CUR;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
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
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @An_ProcessedRecordCount_QNTY =@Ln_ProcessedRecordCount_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
