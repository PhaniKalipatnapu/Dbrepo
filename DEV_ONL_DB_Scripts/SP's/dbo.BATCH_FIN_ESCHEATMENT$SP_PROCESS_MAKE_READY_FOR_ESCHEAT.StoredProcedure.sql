/****** Object:  StoredProcedure [dbo].[BATCH_FIN_ESCHEATMENT$SP_PROCESS_MAKE_READY_FOR_ESCHEAT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_ESCHEATMENT$SP_PROCESS_MAKE_READY_FOR_ESCHEAT
Programmer Name		: IMP Team
Description			: This process gets the receipts which are in pending escheatment status from Receipt History (RCTH_Y1)
					  with reason codes of  'UMPE – Manual Pending Escheatment', 'USPE – System Pending Escheatment' and 
					  Disbursement Hold Code in DHLD_Y1 table as 'SDPE – System Disbursement Pending Escheatment' and mark
					  the payment to be ready for disbursement to State.
Frequency			: Annually
Developed On		: 6/8/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			: 
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_ESCHEATMENT$SP_PROCESS_MAKE_READY_FOR_ESCHEAT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_PendingEscheatment2270_NUMB               INT = 2270,
          @Lc_TypeErrorE_CODE                           CHAR(1) = 'E',
          @Lc_StatusRelese_CODE                         CHAR(1) = 'R',
          @Lc_StatusReceiptUnidentified_CODE            CHAR(1) = 'U',
          @Lc_StatusReceiptHold_CODE                    CHAR(1) = 'H',
          @Lc_RecipientTypeOthp_CODE                    CHAR(1) = '3',
          @Lc_ErrorTypeWarning_CODE                     CHAR(1) = 'W',
          @Lc_StatusFailed_CODE                         CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                        CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE                    CHAR(1) = 'A',
          @Lc_StatusEscheatEscheated_CODE               CHAR(1) = 'E',
          @Lc_StatusReceiptEscheated_CODE				CHAR(1) = 'E',
          @Lc_TypeHoldRegular_CODE                      CHAR(1) = 'D',
          @Lc_Yes_INDC                                  CHAR(1) = 'Y',
          @Lc_No_INDC                                   CHAR(1) = 'N',
          @Lc_Space_TEXT                                CHAR(1) = ' ',
          @Lc_ReasonSystemPendingEscheatment_CODE       CHAR(4) = 'USPE',
          @Lc_ReasonManualPendingEscheatment_CODE       CHAR(4) = 'UMPE',
          @Lc_SystemDisbursementPendingEscheatment_CODE CHAR(4) = 'SDPE',
          @Lc_NoRecordsToProcess_CODE                   CHAR(5) = 'E0944',
          @Lc_BateErrorUnknown_CODE                     CHAR(5) = 'E1424',
          @Lc_Job_ID                                    CHAR(7) = 'DEB8600',
          @Lc_CheckRecipientDelawareStateEscheator_ID   CHAR(10) = '999999983',
          @Lc_Successful_TEXT                           CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                         CHAR(30) = 'BATCH',
          @Lc_Process_NAME                              CHAR(30) = 'BATCH_FIN_ESCHEATMENT',
          @Lc_Procedure_NAME                            CHAR(34) = 'SP_PROCESS_MAKE_READY_FOR_ESCHEAT',
          @Ld_High_DATE                                 DATE = '12/31/9999',
          @Ld_Low_DATE                                  DATE = '01/01/0001',
          @Ld_Start_DATE                                DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5) =0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) =0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) =0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_RcthCursorIndex_QNTY        NUMERIC(10) = 0,
          @Ln_DhldCursorIndex_QNTY        NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11)= 0,
          @Ln_RowCount_QNTY               NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) =0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) =0,
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
          @Ld_LastRun_DATE                DATE;
  DECLARE @Ld_RcthCur_Batch_DATE               DATE,
          @Lc_RcthCur_SourceBatch_CODE         CHAR(3),
          @Ln_RcthCur_Batch_NUMB               NUMERIC(4),
          @Ln_RcthCur_SeqReceipt_NUMB          NUMERIC(6),
          @Ln_RcthCur_ToDistribute_AMNT        NUMERIC(11, 2),
          @Ln_RcthCur_EventGlobalBeginSeq_NUMB NUMERIC(19);
  DECLARE @Ln_DhldCur_Case_IDNO                  NUMERIC(6),
          @Ln_DhldCur_OrderSeq_NUMB              NUMERIC(2),
          @Ln_DhldCur_ObligationSeq_NUMB         NUMERIC(2),
          @Ld_DhldCur_Batch_DATE                 DATE,
          @Lc_DhldCur_SourceBatch_CODE           CHAR(3),
          @Ln_DhldCur_Batch_NUMB                 NUMERIC(4),
          @Ln_DhldCur_SeqReceipt_NUMB            NUMERIC(6),
          @Ln_DhldCur_Transaction_AMNT           NUMERIC(11, 2),
          @Lc_DhldCur_ProcessOffset_INDC         CHAR(1),
          @Ln_DhldCur_EventGlobalSupportSeq_NUMB NUMERIC(19),
          @Ld_DhldCur_Disburse_DATE              DATE,
          @Ln_DhldCur_DisburseSeq_NUMB           NUMERIC(4),
          @Ld_DhldCur_Transaction_DATE           DATE,
          @Ln_DhldCur_Unique_IDNO                NUMERIC(19);

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
   Get the run date and last run date from Parameter (PARM_Y1) table and validate that the batch program was not 
   executed for the run date, by ensuring that the run date is different from the last run date in the PARM_Y1 table
   */
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   /*
   	Get the receipts which are in pending escheatment status from Receipt (RCTH_Y1) 
   */
   DECLARE Rcth_CUR INSENSITIVE CURSOR FOR
    SELECT a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.ToDistribute_AMNT,
           a.EventGlobalBeginSeq_NUMB
      FROM RCTH_Y1 a
     WHERE
     --Receipt Status is ‘U’ – Unidentified 
     a.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
    AND NOT EXISTS (SELECT 1
                   FROM RCTH_Y1 b
                  WHERE b.Batch_DATE = a.Batch_DATE
                    AND b.SourceBatch_CODE = a.SourceBatch_CODE
                    AND b.Batch_NUMB = a.Batch_NUMB
                    AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                    --Receipt is not Backed Out 
                    AND b.BackOut_INDC = @Lc_Yes_INDC
                    AND b.EndValidity_DATE = @Ld_High_DATE)
    --Reason code is either ‘UMPE’ or ‘USPE’
    AND a.ReasonStatus_CODE IN (@Lc_ReasonManualPendingEscheatment_CODE, @Lc_ReasonSystemPendingEscheatment_CODE)
    AND a.EndValidity_DATE = @Ld_High_DATE
    AND a.Distribute_DATE <> @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'OPEN Rcth_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Rcth_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Rcth_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Rcth_CUR INTO @Ld_RcthCur_Batch_DATE, @Lc_RcthCur_SourceBatch_CODE, @Ln_RcthCur_Batch_NUMB, @Ln_RcthCur_SeqReceipt_NUMB, @Ln_RcthCur_ToDistribute_AMNT, @Ln_RcthCur_EventGlobalBeginSeq_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', ToDistribute_AMNT = ' + CAST(@Ln_RcthCur_ToDistribute_AMNT AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_RcthCur_EventGlobalBeginSeq_NUMB AS VARCHAR);

   /*
   	Process each receipt  which are in pending escheatment status from Receipt (RCTH_Y1)
   */
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION ESCHEAT_SAVE

      SET @Ln_RcthCursorIndex_QNTY = @Ln_RcthCursorIndex_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_CursorLocation_TEXT = ' RcthCursorIndex_QNTY = ' + ISNULL(CAST(@Ln_RcthCursorIndex_QNTY AS VARCHAR), '');
      SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', ToDistribute_AMNT = ' + CAST(@Ln_RcthCur_ToDistribute_AMNT AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_RcthCur_EventGlobalBeginSeq_NUMB AS VARCHAR);
      /*
      Call the common routine 'BATCH_COMMON$SP_GENERATE_SEQ' to generate a sequence number
      */
      SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ RCTH_Y1';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PendingEscheatment2270_NUMB AS VARCHAR), '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', Job_ID = ' + @Lc_Job_ID;

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

      SET @Ls_Sql_TEXT = ' UPDATE RCTH_Y1';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      UPDATE RCTH_Y1
         SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
             EndValidity_DATE = @Ld_Run_DATE
        FROM RCTH_Y1 a
       WHERE a.Batch_DATE = @Ld_RcthCur_Batch_DATE
         AND a.SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_RcthCur_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
         AND a.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE RCTH_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END

      /*
      	In RCTH_Y1 table, update Distribute_DATE column to job run date to identify the date when the escheatment record was distributed
      */
      SET @Ls_Sql_TEXT = ' INSERT RCTH_Y1';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', High_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR)+', StatusReceiptEscheated_CODE = '+@Lc_StatusReceiptEscheated_CODE;

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
              CheckNo_TEXT,
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
             a.CheckNo_TEXT,
             a.Receipt_DATE,
             @Ld_Run_DATE AS Distribute_DATE,
             a.Tanf_CODE,
             a.TaxJoint_CODE,
             a.TaxJoint_NAME,
             @Lc_StatusReceiptEscheated_CODE AS StatusReceipt_CODE, 
             a.ReasonStatus_CODE,
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
       WHERE a.Batch_DATE = @Ld_RcthCur_Batch_DATE
         AND a.SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_RcthCur_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
         AND a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = ' INSERT RCTH_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = ' UPDATE URCT_Y1';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR)+', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR);

      UPDATE URCT_Y1
         SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
             EndValidity_DATE = @Ld_Run_DATE
        FROM URCT_Y1 a
       WHERE a.Batch_DATE = @Ld_RcthCur_Batch_DATE
         AND a.SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_RcthCur_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
         AND a.EndValidity_DATE =@Ld_High_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE URCT_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END

      /*
      	Update Unidentified Receipts (URCT_Y1) table; update reason code field (StatusEscheat_CODE) from pending to escheated
      */
      SET @Ls_Sql_TEXT = ' INSERT URCT_Y1';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', StatusEscheatEscheated_CODE = ' + @Lc_StatusEscheatEscheated_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', High_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', StatusEscheatEscheated_CODE = ' + @Lc_StatusEscheatEscheated_CODE;

      INSERT URCT_Y1
             (Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              SourceReceipt_CODE,
              Payor_NAME,
              PayorLine1_ADDR,
              PayorLine2_ADDR,
              PayorCity_ADDR,
              PayorState_ADDR,
              PayorZip_ADDR,
              PayorCountry_ADDR,
              Bank_NAME,
              Bank1_ADDR,
              Bank2_ADDR,
              BankCity_ADDR,
              BankState_ADDR,
              BankZip_ADDR,
              BankCountry_ADDR,
              Bank_IDNO,
              BankAcct_NUMB,
              Remarks_TEXT,
              CaseIdent_IDNO,
              IdentifiedPayorMci_IDNO,
              Identified_DATE,
              OtherParty_IDNO,
              IdentificationStatus_CODE,
              Employer_IDNO,
              IvdAgency_IDNO,
              UnidentifiedMemberMci_IDNO,
              UnidentifiedSsn_NUMB,
              EventGlobalBeginSeq_NUMB,
              EventGlobalEndSeq_NUMB,
              BeginValidity_DATE,
              EndValidity_DATE,
              StatusEscheat_DATE,
              StatusEscheat_CODE)
      SELECT a.Batch_DATE,
             a.SourceBatch_CODE,
             a.Batch_NUMB,
             a.SeqReceipt_NUMB,
             a.SourceReceipt_CODE,
             a.Payor_NAME,
             a.PayorLine1_ADDR,
             a.PayorLine2_ADDR,
             a.PayorCity_ADDR,
             a.PayorState_ADDR,
             a.PayorZip_ADDR,
             a.PayorCountry_ADDR,
             a.Bank_NAME,
             a.Bank1_ADDR,
             a.Bank2_ADDR,
             a.BankCity_ADDR,
             a.BankState_ADDR,
             a.BankZip_ADDR,
             a.BankCountry_ADDR,
             a.Bank_IDNO,
             a.BankAcct_NUMB,
             a.Remarks_TEXT,
             a.CaseIdent_IDNO,
             a.IdentifiedPayorMci_IDNO,
             a.Identified_DATE,
             a.OtherParty_IDNO,
             a.IdentificationStatus_CODE,
             a.Employer_IDNO,
             a.IvdAgency_IDNO,
             a.UnidentifiedMemberMci_IDNO,
             a.UnidentifiedSsn_NUMB,
             @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             @Ld_Run_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @Ld_Run_DATE AS StatusEscheat_DATE,
             @Lc_StatusEscheatEscheated_CODE AS StatusEscheat_CODE
        FROM URCT_Y1 a
       WHERE a.Batch_DATE = @Ld_RcthCur_Batch_DATE
         AND a.SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_RcthCur_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
		 AND a.EventGlobalEndSeq_NUMB=@Ln_EventGlobalSeq_NUMB;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = ' INSERT RCTH_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END

      /*
      Insert the above receipt details RCTH_Y1 table into DHLD_Y1 table with data like amount to be distributed,
      Status code as ‘Ready for Disbursement’, Check Recipient ID is OTHP ID of the State and Check Recipient Code
      of ‘3’ – Other party ID
      */
      SET @Ls_Sql_TEXT = ' INSERT DHLD_Y1 1';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Release_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@Ln_RcthCur_ToDistribute_AMNT AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusRelese_CODE, '') + ', TypeHold_CODE = ' + ISNULL(@Lc_TypeHoldRegular_CODE, '') + ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientDelawareStateEscheator_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', StatusEscheat_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

      INSERT INTO DHLD_Y1
                  (Case_IDNO,
                   OrderSeq_NUMB,
                   ObligationSeq_NUMB,
                   Batch_DATE,
                   SourceBatch_CODE,
                   Batch_NUMB,
                   SeqReceipt_NUMB,
                   Transaction_DATE,
                   Release_DATE,
                   TypeDisburse_CODE,
                   Transaction_AMNT,
                   Status_CODE,
                   TypeHold_CODE,
                   ProcessOffset_INDC,
                   CheckRecipient_ID,
                   CheckRecipient_CODE,
                   ReasonStatus_CODE,
                   --Unique_IDNO,
                   EventGlobalSupportSeq_NUMB,
                   EventGlobalBeginSeq_NUMB,
                   EventGlobalEndSeq_NUMB,
                   BeginValidity_DATE,
                   EndValidity_DATE,
                   Disburse_DATE,
                   DisburseSeq_NUMB,
                   StatusEscheat_DATE,
                   StatusEscheat_CODE)
           VALUES ( 0,--Case_IDNO
                    0,--OrderSeq_NUMB
                    0,--ObligationSeq_NUMB
                    @Ld_RcthCur_Batch_DATE,--Batch_DATE
                    @Lc_RcthCur_SourceBatch_CODE,--SourceBatch_CODE
                    @Ln_RcthCur_Batch_NUMB,--Batch_NUMB
                    @Ln_RcthCur_SeqReceipt_NUMB,--SeqReceipt_NUMB
                    @Ld_Run_DATE,--Transaction_DATE
                    @Ld_Run_DATE,--Release_DATE
                    @Lc_Space_TEXT,--TypeDisburse_CODE
                    @Ln_RcthCur_ToDistribute_AMNT,--Transaction_AMNT
                    @Lc_StatusRelese_CODE,--Status_CODE
                    @Lc_TypeHoldRegular_CODE,--TypeHold_CODE
                    @Lc_Yes_INDC,--ProcessOffset_INDC
                    @Lc_CheckRecipientDelawareStateEscheator_ID,--CheckRecipient_ID
                    @Lc_RecipientTypeOthp_CODE,--CheckRecipient_CODE
                    @Lc_Space_TEXT,--ReasonStatus_CODE
                    --Unique_IDNO
                    @Ln_EventGlobalSeq_NUMB,--EventGlobalSupportSeq_NUMB
                    @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                    0,--EventGlobalEndSeq_NUMB
                    @Ld_Run_DATE,--BeginValidity_DATE
                    @Ld_High_DATE,--EndValidity_DATE
                    @Ld_Low_DATE,--Disburse_DATE
                    0,--DisburseSeq_NUMB
                    @Ld_High_DATE,--StatusEscheat_DATE
                    @Lc_Space_TEXT--StatusEscheat_CODE
      );
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION ESCHEAT_SAVE
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

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

     SET @Ls_Sql_TEXT = 'FETCH Rcth_CUR-2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Rcth_CUR INTO @Ld_RcthCur_Batch_DATE, @Lc_RcthCur_SourceBatch_CODE, @Ln_RcthCur_Batch_NUMB, @Ln_RcthCur_SeqReceipt_NUMB, @Ln_RcthCur_ToDistribute_AMNT, @Ln_RcthCur_EventGlobalBeginSeq_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Rcth_CUR;

   DEALLOCATE Rcth_CUR;

   COMMIT TRANSACTION ESCHEAT;

   BEGIN TRANSACTION ESCHEAT;

   SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY;
   SET @Ln_CommitFreq_QNTY = 0;

   /*
   For identified receipts, it updates the UDC code (Reason Status Code in DHLD_Y1) of the disbursement holds in
   DHLD_Y1 table to 'SDPE' – System Disbursement Pending Escheatment where the disbursement date in DHLD_Y1 table 
   is equal to or greater earlier than 1825 days or five years from batch run date
   */
   DECLARE Dhld_CUR INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.Transaction_AMNT,
           a.ProcessOffset_INDC,
           a.EventGlobalSupportSeq_NUMB,
           a.Disburse_DATE,
           a.DisburseSeq_NUMB,
           a.Transaction_DATE,
           a.Unique_IDNO
      FROM DHLD_Y1 a
     WHERE
     --Receipt Status is ‘H’ – Hold
     a.Status_CODE = @Lc_StatusReceiptHold_CODE
     --Reason code is 'SDPE' – System Disbursement Pending Escheatment 
     AND a.ReasonStatus_CODE = @Lc_SystemDisbursementPendingEscheatment_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND NOT EXISTS (SELECT 1
                       FROM RCTH_Y1 b
                      WHERE b.Batch_DATE = a.Batch_DATE
                        AND b.SourceBatch_CODE = a.SourceBatch_CODE
                        AND b.Batch_NUMB = a.Batch_NUMB
                        AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                        --Receipt is Not Backed Out
                        AND b.BackOut_INDC = @Lc_Yes_INDC
                        AND b.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'OPEN Dhld_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Dhld_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Dhld_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_ProcessOffset_INDC, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Unique_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-2';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR) + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR);

   /*While loop for updating UDC code (Reason Status Code in DHLD_Y1) of the disbursement holds in
     DHLD_Y1 table to 'SDPE' – System Disbursement Pending Escheatment*/
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION ESCHEAT_SAVE

      SET @Ln_DhldCursorIndex_QNTY = @Ln_DhldCursorIndex_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_CursorLocation_TEXT = ' DhldCursorIndex_QNTY = ' + ISNULL(CAST(@Ln_DhldCursorIndex_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '');
      SET @Ls_BateRecord_TEXT ='Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '');
      SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ DHLD_Y1';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PendingEscheatment2270_NUMB AS VARCHAR), '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', Job_ID = ' + @Lc_Job_ID;

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

      SET @Ls_Sql_TEXT = ' UPDATE RCTH_Y1-2';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR), '') + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      UPDATE RCTH_Y1
         SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
             EndValidity_DATE = @Ld_Run_DATE
        FROM RCTH_Y1 a
       WHERE a.Batch_DATE = @Ld_DhldCur_Batch_DATE
         AND a.SourceBatch_CODE = @Lc_DhldCur_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_DhldCur_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_DhldCur_SeqReceipt_NUMB
         AND a.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE RCTH_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END

      /*
      	In RCTH_Y1 table, update StatusReceipt_CODE column to 'E' 
      */
      SET @Ls_Sql_TEXT = ' INSERT RCTH_Y1-2';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', High_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR)+', StatusReceiptEscheated_CODE = '+@Lc_StatusReceiptEscheated_CODE;

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
              CheckNo_TEXT,
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
             a.CheckNo_TEXT,
             a.Receipt_DATE,
             a.Distribute_DATE, 
             a.Tanf_CODE,
             a.TaxJoint_CODE,
             a.TaxJoint_NAME,
             @Lc_StatusReceiptEscheated_CODE AS StatusReceipt_CODE, 
             a.ReasonStatus_CODE,
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
       WHERE a.Batch_DATE = @Ld_DhldCur_Batch_DATE
         AND a.SourceBatch_CODE = @Lc_DhldCur_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_DhldCur_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_DhldCur_SeqReceipt_NUMB
         AND a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = ' INSERT RCTH_Y1 FAILED ';

        RAISERROR (50001,16,1);
       END
      
      SET @Ls_Sql_TEXT = 'UPDATE DHLD_Y1 FOR BAD ADDRESS';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

      /*
      	Update the above receipts in DHLD_Y1 table by moving newly generated sequence number and batch run date as EndValidity_DATE
      */
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

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE DHLD_Y1 FAILED BAD ADDRESS';

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'INSERT INTO DHLD_Y1 BAD ADDRESS';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', StatusRelese_CODE = ' + @Lc_StatusRelese_CODE + ', CheckRecipientDelawareStateEscheator_ID = ' + @Lc_CheckRecipientDelawareStateEscheator_ID + ', RecipientTypeOthp_CODE = ' + @Lc_RecipientTypeOthp_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR)+', Space_TEXT = '+@Lc_Space_TEXT;

      --Insert the receipts from the above step into DHLD_Y1 table
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
             @Lc_StatusRelese_CODE AS Status_CODE,
             a.TypeHold_CODE,
             @Lc_Space_TEXT AS TypeDisburse_CODE,
             @Lc_CheckRecipientDelawareStateEscheator_ID AS CheckRecipient_ID,
             @Lc_RecipientTypeOthp_CODE AS CheckRecipient_CODE,
             a.ProcessOffset_INDC,
             @Lc_Space_TEXT AS ReasonStatus_CODE,
             @Ld_Run_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             a.EventGlobalSupportSeq_NUMB AS EventGlobalSupportSeq_NUMB,
             @Ld_Run_DATE AS Release_DATE,
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

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_ErrorMessage_TEXT = 'INSERT DHLD_Y1 FAILED BAD ADDRESS';

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
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

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

     SET @Ls_Sql_TEXT = 'FETCH Dhld_CUR-2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_ProcessOffset_INDC, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Unique_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Dhld_CUR;

   DEALLOCATE Dhld_CUR;

   IF @Ln_DhldCursorIndex_QNTY = 0
      AND @Ln_RcthCursorIndex_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_BATE_LOG 1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RcthCursorIndex_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_NoRecordsToProcess_CODE, '') + ', Space_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
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
    END

   SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY + @Ln_DhldCursorIndex_QNTY;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                 = @Ld_Run_DATE,
    @Ad_Start_DATE               = @Ld_Start_DATE,
    @Ac_Job_ID                   = @Lc_Job_ID,
    @As_Process_NAME             = @Lc_Process_NAME,
    @As_Procedure_NAME           = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT      = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT        = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY= @Ln_ProcessedRecordCount_QNTY,
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

   IF CURSOR_STATUS ('LOCAL', 'Rcth_CUR') IN (0, 1)
    BEGIN
     CLOSE Rcth_CUR;

     DEALLOCATE Rcth_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'Dhld_CUR') IN (0, 1)
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
