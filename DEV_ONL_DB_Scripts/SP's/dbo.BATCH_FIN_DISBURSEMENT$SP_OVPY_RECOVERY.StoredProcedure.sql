/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY
Programmer Name 	: IMP Team
Description			: Procedure to find recover the money from the disbursements if there is a recoupment for the recipient.
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On			: None
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY]
 @Ac_TypeRecoupment_CODE        CHAR(3),
 @An_Remaining_AMNT             NUMERIC (11, 2) OUTPUT,
 @An_OdOrigRcpt_AMNT            NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @Ac_PoflChkRecipient_ID        CHAR(10) OUTPUT,
 @Ac_CheckRecipient_ID          CHAR(10) OUTPUT,
 @Ac_PoflChkRecipient_CODE      CHAR (1) OUTPUT,
 @Ac_CheckRecipient_CODE        CHAR(1) OUTPUT,
 @Ac_TypeDisburse_CODE          CHAR(5) OUTPUT,
 @An_Case_IDNO                  NUMERIC(6) OUTPUT,
 @Ad_Batch_DATE                 DATE OUTPUT,
 @Ac_SourceBatch_CODE           CHAR(3) OUTPUT,
 @An_Batch_NUMB                 NUMERIC(4) OUTPUT,
 @An_SeqReceipt_NUMB            NUMERIC(6) OUTPUT,
 @An_StPendTotOffset_AMNT       NUMERIC (11, 2) OUTPUT,
 @An_StAssessTotOverpay_AMNT    NUMERIC (11, 2) OUTPUT,
 @An_StRecTotAdvance_AMNT       NUMERIC (11, 2) OUTPUT,
 @An_StRecTotOverpay_AMNT       NUMERIC (11, 2) OUTPUT,
 @An_StTotBalOvpy_AMNT          NUMERIC (11, 2) OUTPUT,
 @An_OrderSeq_NUMB              NUMERIC(2) OUTPUT,
 @An_ObligationSeq_NUMB         NUMERIC(2) OUTPUT,
 @An_EventGlobalSeq_NUMB        NUMERIC(19) OUTPUT,
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19) OUTPUT,
 @Ad_Run_DATE                   DATE OUTPUT,
 @Ad_Disburse_DATE              DATE OUTPUT,
 @An_DisburseSeq_NUMB           NUMERIC(4) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RecoupmentRecovery2230_NUMB    INT = 2230,
          @Lc_RecipientTypeFips_CODE         CHAR(1) = '2',
          @Lc_RecipientTypeCpNcp_CODE        CHAR(1) = '1',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_TypeRecoupmentRegular_CODE     CHAR(1) = 'R',
          @Lc_RecoupmentPayeeState_CODE      CHAR(1) = 'S',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_SourceReceiptCpRecoupment_CODE CHAR(2) = 'CR',
          @Lc_RecoupmentTypeNsf_CODE		 CHAR(3) = 'NSF',
          @Lc_PoflTransactionSrec_CODE       CHAR(4) = 'SREC',
          @Lc_TypeDisburseRefund_CODE        CHAR(5) = 'REFND',
          @Lc_NoDataFound_TEXT               CHAR(20) = ' NO DATA FOUND ',
          @Lc_TypeEntityRctno_CODE           CHAR(30) = 'RCTNO',
          @Lc_TypeEntityCase_CODE            CHAR(30) = 'CASE',
          @Lc_TypeEntityRcpid_CODE           CHAR(30) = 'RCPID',
          @Lc_TypeEntityRcpcd_CODE           CHAR(30) = 'RCPCD',
          @Lc_CpRecoupLessThanTran_TEXT      CHAR(40) = 'CP RECOUP BAL LESS THAN TRAN AMT',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_OVPY_RECOVERY',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_RecordCount_QNTY                 NUMERIC(9),
          @Ln_StateTransactionOvpyRcvd_AMNT    NUMERIC(11, 2) = 0,
          @Ln_StateTransactionOvpyRcvdStg_AMNT NUMERIC(11, 2) = 0,
          @Ln_StateTransactionOvpyRcvdNr_AMNT  NUMERIC(11, 2) = 0,
          @Ln_Error_NUMB                       NUMERIC(11),
          @Ln_ErrorLine_NUMB                   NUMERIC(11),
          @Li_Rowcount_QNTY                    SMALLINT,
          @Lc_Msg_CODE                         CHAR(1),
          @Ls_Sql_TEXT                         VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                     VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT                VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ac_PoflChkRecipient_ID = @Ac_CheckRecipient_ID;
   SET @Ac_PoflChkRecipient_CODE = @Ac_CheckRecipient_CODE;

   IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
    BEGIN
     IF @Ac_TypeDisburse_CODE <> @Lc_TypeDisburseRefund_CODE
      BEGIN

       SET @Ls_Sql_TEXT = 'SELECT CMEM_POFL';
       SET @Ls_Sqldata_TEXT = '';

       SELECT TOP 1 @Ac_PoflChkRecipient_ID = f.MemberMci_IDNO,
                    @Ac_PoflChkRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
         FROM (SELECT a.MemberMci_IDNO,
                      a.CaseMemberStatus_CODE
                 FROM CMEM_Y1 a
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE) AS f
        ORDER BY 2;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_Sql_TEXT + @Lc_NoDataFound_TEXT;

         RAISERROR (50001,16,1);
        END
      END
     ELSE IF @Ac_TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT RCTH_POFL';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT TOP 1 @Ac_PoflChkRecipient_ID = r.PayorMCI_IDNO,
                    @Ac_PoflChkRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
         FROM RCTH_Y1 r
        WHERE r.Batch_DATE = @Ad_Batch_DATE
          AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
          AND r.Batch_NUMB = @An_Batch_NUMB
          AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
          AND r.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_Sql_TEXT + @Lc_NoDataFound_TEXT;

         RAISERROR (50001,16,1);
        END;
      END;
    END;

   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT POFL STATE';
    SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_PoflChkRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_PoflChkRecipient_CODE,'')+ ', TypeRecoupment_CODE = ' + ISNULL(@Lc_TypeRecoupmentRegular_CODE,'')+ ', RecoupmentPayee_CODE = ' + ISNULL(@Lc_RecoupmentPayeeState_CODE,'');

    SELECT @An_StPendTotOffset_AMNT = a.PendTotOffset_AMNT,
           @An_StAssessTotOverpay_AMNT = a.AssessTotOverpay_AMNT,
           @An_StRecTotAdvance_AMNT = a.RecTotAdvance_AMNT,
           @An_StRecTotOverpay_AMNT = a.RecTotOverpay_AMNT,
           @An_StTotBalOvpy_AMNT = (a.AssessTotOverpay_AMNT - a.RecTotOverpay_AMNT)
      FROM POFL_Y1 a
     WHERE a.CheckRecipient_ID = @Ac_PoflChkRecipient_ID
       AND a.CheckRecipient_CODE = @Ac_PoflChkRecipient_CODE
       AND a.TypeRecoupment_CODE = @Lc_TypeRecoupmentRegular_CODE
       AND a.RecoupmentPayee_CODE = @Lc_RecoupmentPayeeState_CODE
       AND a.Unique_IDNO = (SELECT MAX (c.Unique_IDNO)
                              FROM POFL_Y1 c
                             WHERE c.CheckRecipient_ID = a.CheckRecipient_ID
                               AND c.CheckRecipient_CODE = a.CheckRecipient_CODE
								AND c.TypeRecoupment_CODE = a.TypeRecoupment_CODE
								AND c.RecoupmentPayee_CODE = a.RecoupmentPayee_CODE);
    SET @Li_Rowcount_QNTY = @@ROWCOUNT;

    IF (@Li_Rowcount_QNTY = 0)
     BEGIN
      SET @An_StPendTotOffset_AMNT = 0;
      SET @An_StTotBalOvpy_AMNT = 0;
      SET @An_StAssessTotOverpay_AMNT = 0;
     END;
   END;

   SET @Ls_Sql_TEXT = 'CHECK CP RECOUP BAL';
   SET @Ls_Sqldata_TEXT = 'Remaining_AMNT = ' + ISNULL(CAST(@An_StTotBalOvpy_AMNT AS VARCHAR),'0') + ', TypeRecoupment_CODE = ' + @Lc_SourceReceiptCpRecoupment_CODE;	
   IF @An_Remaining_AMNT > @An_StTotBalOvpy_AMNT
      AND @Ac_TypeRecoupment_CODE = @Lc_SourceReceiptCpRecoupment_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_CpRecoupLessThanTran_TEXT;
     
     SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_INSERT_SDER';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@An_DisburseSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_FIN_DISBURSEMENT$SP_INSERT_SDER
      @An_Remaining_AMNT             = @An_Remaining_AMNT OUTPUT,
      @Ac_CheckRecipient_ID          = @Ac_CheckRecipient_ID,
      @Ac_CheckRecipient_CODE        = @Ac_CheckRecipient_CODE,
      @An_Case_IDNO                  = @An_Case_IDNO,
      @An_OrderSeq_NUMB              = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB         = @An_ObligationSeq_NUMB,
      @Ad_Batch_DATE                 = @Ad_Batch_DATE,
      @An_Batch_NUMB                 = @An_Batch_NUMB,
      @Ac_SourceBatch_CODE           = @Ac_SourceBatch_CODE,
      @An_SeqReceipt_NUMB            = @An_SeqReceipt_NUMB,
      @An_EventGlobalSupportSeq_NUMB = @An_EventGlobalSupportSeq_NUMB,
      @Ac_TypeDisburse_CODE          = @Ac_TypeDisburse_CODE,
      @Ad_Disburse_DATE              = @Ad_Disburse_DATE,
      @An_DisburseSeq_NUMB           = @An_DisburseSeq_NUMB,
      @An_EventGlobalSeq_NUMB        = @An_EventGlobalSeq_NUMB,
      @Ad_Run_DATE                   = @Ad_Run_DATE,
      @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT		 = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ln_StateTransactionOvpyRcvdStg_AMNT = 0;
     SET @Ln_StateTransactionOvpyRcvd_AMNT = 0;

     IF @An_StTotBalOvpy_AMNT > 0
      BEGIN
       SET @Ln_StateTransactionOvpyRcvd_AMNT = dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT (@An_StTotBalOvpy_AMNT, @An_Remaining_AMNT);
       SET @An_Remaining_AMNT = @An_Remaining_AMNT - @Ln_StateTransactionOvpyRcvd_AMNT;
       SET @An_StTotBalOvpy_AMNT = @An_StTotBalOvpy_AMNT - @Ln_StateTransactionOvpyRcvd_AMNT;
       SET @An_StRecTotOverpay_AMNT = @An_StRecTotOverpay_AMNT + @Ln_StateTransactionOvpyRcvd_AMNT;
       SET @An_OdOrigRcpt_AMNT = dbo.BATCH_COMMON_SCALAR$SF_GREATEST_FLOAT (@An_OdOrigRcpt_AMNT - @Ln_StateTransactionOvpyRcvd_AMNT, 0);
      END;

     -- After satisfying the Active balance, there is still OD from original receipt then the DHLD money can be used for Pending recoupment balance
     -- upto the disbursement amount from Original receipt.
     IF @An_OdOrigRcpt_AMNT > 0
        AND @An_Remaining_AMNT > 0
        AND @An_StPendTotOffset_AMNT > 0
      BEGIN
       SET @Ln_StateTransactionOvpyRcvdStg_AMNT = dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT (@An_StPendTotOffset_AMNT, dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT (@An_Remaining_AMNT, @An_OdOrigRcpt_AMNT));
       SET @An_Remaining_AMNT = @An_Remaining_AMNT - @Ln_StateTransactionOvpyRcvdStg_AMNT;
       SET @An_StTotBalOvpy_AMNT = @An_StTotBalOvpy_AMNT - @Ln_StateTransactionOvpyRcvdStg_AMNT;
       SET @An_StRecTotOverpay_AMNT = @An_StRecTotOverpay_AMNT + @Ln_StateTransactionOvpyRcvdStg_AMNT;
       SET @An_OdOrigRcpt_AMNT = dbo.BATCH_COMMON_SCALAR$SF_GREATEST_FLOAT (@An_OdOrigRcpt_AMNT - @Ln_StateTransactionOvpyRcvdStg_AMNT, 0);
      END;

     -- NR Receipts can be used to recover Pending offset money and the balance should be disbursed to the recipient
     IF @An_Remaining_AMNT > 0
        AND @Ac_TypeRecoupment_CODE = @Lc_RecoupmentTypeNsf_CODE
        AND (@An_StPendTotOffset_AMNT - @Ln_StateTransactionOvpyRcvdStg_AMNT) > 0
      BEGIN
       SET @Ln_StateTransactionOvpyRcvdNr_AMNT = dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT ((@An_StPendTotOffset_AMNT - @Ln_StateTransactionOvpyRcvdStg_AMNT), @An_Remaining_AMNT);
       SET @An_Remaining_AMNT = @An_Remaining_AMNT - @Ln_StateTransactionOvpyRcvdNr_AMNT;
       SET @An_StTotBalOvpy_AMNT = @An_StTotBalOvpy_AMNT - @Ln_StateTransactionOvpyRcvdNr_AMNT;
       SET @An_StRecTotOverpay_AMNT = @An_StRecTotOverpay_AMNT + @Ln_StateTransactionOvpyRcvdNr_AMNT;
      END

     IF @Ln_StateTransactionOvpyRcvd_AMNT + @Ln_StateTransactionOvpyRcvdStg_AMNT + @Ln_StateTransactionOvpyRcvdNr_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_POFL_Y1 STATE';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_PoflChkRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_PoflChkRecipient_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Reason_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', RecAdvance_AMNT = ' + ISNULL('0','')+ ', RecTotAdvance_AMNT = ' + ISNULL(CAST( @An_StRecTotAdvance_AMNT AS VARCHAR ),'')+ ', RecTotOverpay_AMNT = ' + ISNULL(CAST( @An_StRecTotOverpay_AMNT AS VARCHAR ),'')+ ', Transaction_CODE = ' + ISNULL(@Lc_PoflTransactionSrec_CODE,'')+ ', TypeRecoupment_CODE = ' + ISNULL(@Lc_TypeRecoupmentRegular_CODE,'')+ ', RecoupmentPayee_CODE = ' + ISNULL(@Lc_RecoupmentPayeeState_CODE,'');

       INSERT POFL_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Batch_DATE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               SourceBatch_CODE,
               EventGlobalSeq_NUMB,
               EventGlobalSupportSeq_NUMB,
               TypeDisburse_CODE,
               Transaction_DATE,
               PendOffset_AMNT,
               PendTotOffset_AMNT,
               Reason_CODE,
               AssessOverpay_AMNT,
               AssessTotOverpay_AMNT,
               RecAdvance_AMNT,
               RecTotAdvance_AMNT,
               RecOverpay_AMNT,
               RecTotOverpay_AMNT,
               Transaction_CODE,
               TypeRecoupment_CODE,
               RecoupmentPayee_CODE)
       VALUES ( @Ac_PoflChkRecipient_ID,--CheckRecipient_ID
                @Ac_PoflChkRecipient_CODE,--CheckRecipient_CODE
                @An_Case_IDNO,--Case_IDNO
                @An_OrderSeq_NUMB,--OrderSeq_NUMB
                @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
                @Ad_Batch_DATE,--Batch_DATE
                @An_Batch_NUMB,--Batch_NUMB
                @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
                @Ac_SourceBatch_CODE,--SourceBatch_CODE
                @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                @An_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
                @Ac_TypeDisburse_CODE,--TypeDisburse_CODE
                @Ad_Run_DATE,--Transaction_DATE
                (@Ln_StateTransactionOvpyRcvdStg_AMNT + @Ln_StateTransactionOvpyRcvdNr_AMNT) * -1,--PendOffset_AMNT
                @An_StPendTotOffset_AMNT - @Ln_StateTransactionOvpyRcvdStg_AMNT - @Ln_StateTransactionOvpyRcvdNr_AMNT,--PendTotOffset_AMNT
                @Lc_Space_TEXT,--Reason_CODE
                @Ln_StateTransactionOvpyRcvdStg_AMNT + @Ln_StateTransactionOvpyRcvdNr_AMNT,--AssessOverpay_AMNT
                @An_StAssessTotOverpay_AMNT + @Ln_StateTransactionOvpyRcvdStg_AMNT + @Ln_StateTransactionOvpyRcvdNr_AMNT,--AssessTotOverpay_AMNT
                0,--RecAdvance_AMNT
                @An_StRecTotAdvance_AMNT,--RecTotAdvance_AMNT
                @Ln_StateTransactionOvpyRcvd_AMNT + @Ln_StateTransactionOvpyRcvdStg_AMNT + @Ln_StateTransactionOvpyRcvdNr_AMNT,--RecOverpay_AMNT
                @An_StRecTotOverpay_AMNT,--RecTotOverpay_AMNT
                @Lc_PoflTransactionSrec_CODE,--Transaction_CODE
                @Lc_TypeRecoupmentRegular_CODE,--TypeRecoupment_CODE
                @Lc_RecoupmentPayeeState_CODE --RecoupmentPayee_CODE
       );

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_POFL_Y1 STATE FAILED';

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'INSERT_PESEM_POFL STATE';
       SET @Ls_Sqldata_TEXT = '';

       INSERT INTO PESEM_Y1
                   (Entity_ID,
                    EventGlobalSeq_NUMB,
                    TypeEntity_CODE,
                    EventFunctionalSeq_NUMB)
       SELECT dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRctno_CODE,
              @Li_RecoupmentRecovery2230_NUMB
       UNION ALL
       SELECT CAST(@An_Case_IDNO AS VARCHAR),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityCase_CODE,
              @Li_RecoupmentRecovery2230_NUMB
       UNION ALL
       SELECT @Ac_PoflChkRecipient_ID,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRcpid_CODE,
              @Li_RecoupmentRecovery2230_NUMB
       UNION ALL
       SELECT @Ac_PoflChkRecipient_CODE,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRcpcd_CODE,
              @Li_RecoupmentRecovery2230_NUMB;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_POFL STATE FAILED';

         RAISERROR (50001,16,1);
        END;

       -- Do RECP percentage clearance if there is NO pending balance and Active Balance...
       IF (@An_StPendTotOffset_AMNT - @Ln_StateTransactionOvpyRcvdStg_AMNT - @Ln_StateTransactionOvpyRcvdNr_AMNT) = 0
          AND (@An_StAssessTotOverpay_AMNT = @Ln_StateTransactionOvpyRcvdStg_AMNT + @Ln_StateTransactionOvpyRcvdStg_AMNT + @Ln_StateTransactionOvpyRcvdNr_AMNT)
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT RECP_Y1';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_PoflChkRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_PoflChkRecipient_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         SELECT @Ln_RecordCount_QNTY = COUNT (1)
           FROM RECP_Y1 r
          WHERE r.CheckRecipient_ID = @Ac_PoflChkRecipient_ID
            AND r.CheckRecipient_CODE = @Ac_PoflChkRecipient_CODE
            AND r.EndValidity_DATE = @Ld_High_DATE;

         IF @Ln_RecordCount_QNTY > 0
          BEGIN
           --Update RECP recoupment percentage
           SET @Ls_Sql_TEXT = 'UPDATE VRECP';
           SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_PoflChkRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_PoflChkRecipient_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

           UPDATE RECP_Y1
              SET EndValidity_DATE = @Ad_Run_DATE
            WHERE CheckRecipient_ID = @Ac_PoflChkRecipient_ID
              AND CheckRecipient_CODE = @Ac_PoflChkRecipient_CODE
              AND EndValidity_DATE = @Ld_High_DATE;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             SET @Ls_ErrorMessage_TEXT = 'UPDATE RECP FAILED';

             RAISERROR (50001,16,1);
            END
          END
        END
      END;
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
