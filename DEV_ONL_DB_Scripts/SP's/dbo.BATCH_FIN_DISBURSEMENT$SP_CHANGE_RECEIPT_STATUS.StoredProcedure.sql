/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHANGE_RECEIPT_STATUS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_DISBURSEMENT$SP_CHANGE_RECEIPT_STATUS
Programmer Name   :	Imp Team
Description       :	Procedure to change the RCTH_Y1 Status_CODE to 'E' -- Escheated.
Frequency         :	'DAILY'
Developed On      :	01/31/2012
Called BY         :	None
Called On		  :	
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHANGE_RECEIPT_STATUS]
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @Ad_Batch_DATE                 DATE OUTPUT,
 @Ac_SourceBatch_CODE           CHAR(3) OUTPUT,
 @An_Batch_NUMB                 NUMERIC(4) OUTPUT,
 @An_SeqReceipt_NUMB            NUMERIC(6) OUTPUT,
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19) OUTPUT,
 @An_EventGlobalSeq_NUMB        NUMERIC(19) OUTPUT,
 @Ad_Run_DATE                   DATE OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Escheated2280_NUMB             INT = 2280,
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_StatusReceiptUnidentified_CODE CHAR(1) = 'U',
          @Lc_StatusReceiptRefunded_CODE     CHAR(1) = 'R',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_StatusReceiptEscheated_CODE    CHAR(1) = 'E',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_Job_ID                         CHAR(7) = 'DEB0620',
          @Lc_BatchRunUser_TEXT              CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_CHANGE_RECEIPT_STATUS',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB          NUMERIC(11),
          @Ln_ErrorLine_NUMB      NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB NUMERIC(19),
          @Li_Rowcount_QNTY       SMALLINT,
          @Lc_Msg_CODE            CHAR(1),
          @Ls_Sql_TEXT            VARCHAR(100) = '',
          @Ls_Sqldata_TEXT        VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT   VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ls_Sql_TEXT = 'RCPT STS SELECT RCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '');

   SELECT @Li_Rowcount_QNTY = COUNT (1)
     FROM RCTH_Y1 r
    WHERE r.Batch_DATE = @Ad_Batch_DATE
      AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND r.Batch_NUMB = @An_Batch_NUMB
      AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND r.EventGlobalBeginSeq_NUMB = @An_EventGlobalSeq_NUMB;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ln_EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;
    END;
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'RCPT STS BATCH_COMMON$SP_GENERATE_SEQ REG_DISB GF';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_Escheated2280_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_Escheated2280_NUMB,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE RCTH_Y1
      SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
          EndValidity_DATE = @Ad_Run_DATE
     FROM RCTH_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.StatusReceipt_CODE IN (@Lc_StatusReceiptUnidentified_CODE, @Lc_StatusReceiptRefunded_CODE)
      AND a.EndValidity_DATE = @Ld_High_DATE
      AND a.EventGlobalBeginSeq_NUMB = @An_EventGlobalSupportSeq_NUMB
      AND NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 AS b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND b.BackOut_INDC = @Lc_Yes_INDC
                         AND b.EndValidity_DATE = @Ld_High_DATE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY <> 1
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE RCTH_Y1 FAILED';
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptEscheated_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = 0';

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
           Refund_DATE,
           Release_DATE,
           ReferenceIrs_IDNO,
           RefundRecipient_ID,
           RefundRecipient_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB)
   SELECT Batch_DATE,
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
          @Lc_StatusReceiptEscheated_CODE AS StatusReceipt_CODE,
          @Lc_Space_TEXT AS ReasonStatus_CODE,
          BackOut_INDC,
          ReasonBackOut_CODE,
          Refund_DATE,
          Release_DATE,
          ReferenceIrs_IDNO,
          RefundRecipient_ID,
          RefundRecipient_CODE,
          @Ad_Run_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB
     FROM RCTH_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT RCTH_Y1 FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
  END CATCH;
 END;


GO
