/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_PROCESS_CHECK_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_PROCESS_CHECK_HOLD
Programmer Name		: IMP Team
Description			: This procedure is used to process the check holds.
Frequency			: 
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_PROCESS_CHECK_HOLD]
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @Ad_Disburse_DATE         DATE,
 @An_DisburseSeq_NUMB      NUMERIC(4),
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ac_StatusCheck_CODE      CHAR(2),
 @Ac_ReasonStatus_CODE     CHAR(2),
 @Ac_Prog_IDNO             CHAR(7) = NULL,
 @Ad_Process_DATE          DATE,
 @An_TransactionDhld_AMNT  NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE                CHAR(1) = 'F',
          @Lc_No_INDC                          CHAR(1) = 'N',
          @Lc_Yes_INDC                         CHAR(1) = 'Y',
          @Lc_CaseRelationshipCp_CODE          CHAR(1) = 'C',
          @Lc_StatusReceiptHeld_CODE           CHAR(1) = 'H',
          @Lc_StatusReceiptRefunded_CODE       CHAR(1) = 'R',
          @Lc_RecipientTypeCpNcp_CODE          CHAR(1) = '1',
          @Lc_RecipientTypeFips_CODE           CHAR(1) = '2',
          @Lc_RecipientTypeOthp_CODE           CHAR(1) = '3',
          @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
          @Lc_System_CODE                      CHAR(1) = 'S',
          @Lc_Manual_CODE                      CHAR(1) = 'M',
          @Lc_CheckHold_CODE                   CHAR(1) = 'C',
          @Lc_Hold_ADDR                        CHAR(1) = 'A',
          @Lc_HoldR_ADDR                       CHAR(1) = 'R',
          @Lc_BackOut_INDC                     CHAR(1) = 'B',
          @Lc_Ready4Disbursement_CODE          CHAR(1) = 'R',
          @Lc_DisburseStatusOutstanding_CODE   CHAR(2) = 'OU',
          @Lc_DisburseStatusTransferEft_CODE   CHAR(2) = 'TR',
          @Lc_VsaStatusVoidReissue_CODE        CHAR(2) = 'VR',
          @Lc_VsaStatusStopReissue_CODE        CHAR(2) = 'SR',
          @Lc_DisburseStatusVoidNoReissue_CODE CHAR(2) = 'VN',
          @Lc_DisburseStatusStopNoReissue_CODE CHAR(2) = 'SN',
          @Lc_DisburseStatusRejectedEft_CODE   CHAR(2) = 'RE',
          @Lc_VsrStatusRetfrmpostoffice_CODE   CHAR(2) = 'RP',
          @Lc_VsrStatusBadaddress_CODE         CHAR(2) = 'BA',
          @Lc_DisburseStatusCashed_CODE        CHAR(2) = 'CA',
          @Lc_DisburseStatusVoid_CODE          CHAR(2) = 'VD',
          @Lc_DisburseStatusPending_CODE       CHAR(2) = 'PS',
          @Lc_DisbursementPendingEsch_TEXT     CHAR(2) = 'PE',
          @Lc_SystemDisbursment_TEXT           CHAR(2) = 'SD',
          @Lc_FipsNonExistingAddress_CODE      CHAR(2) = 'FA',
          @Lc_OthpNonExisting_ADDR             CHAR(2) = 'OA',
          @Lc_NcpBad_ADDR                      CHAR(2) = 'NA',
          @Lc_ReadyDisbursement_TEXT           CHAR(2) = 'DR',
          @Lc_EftRejectForFipsOrOthp_CODE	   CHAR(4) = 'SDRE',
          @Lc_SystemEscheatmentPending_TEXT    CHAR(4) = 'SDPE',
          @Lc_DisbursementTypeRothp_CODE       CHAR(5) = 'ROTHP',
          @Lc_DisbursementTypeRefund_CODE      CHAR(5) = 'REFND',
          @Lc_ProgStale_IDNO                   CHAR(5) = 'STALE',
          @Ls_Procedure_NAME                   VARCHAR(100) = 'BATCH_COMMON$SP_PROCESS_CHECK_HOLD',
          @Ld_High_DATE                        DATE = '12/31/9999',
          @Ld_Low_DATE                         DATE = '01/01/0001';
  DECLARE @Ln_FetchStatus_QNTY     NUMERIC,
          @Ln_Batch_NUMB           NUMERIC(4),
          @Ln_Case_IDNO            NUMERIC(6),
          @Ln_SeqReceipt_NUMB      NUMERIC(6),
          @Ln_Ins_QNTY             NUMERIC(10),
          @Ln_Dummy_NUMB           NUMERIC(10),
          @Ln_Othp_QNTY            NUMERIC(10),
          @Ln_TotPendOffset_QNTY   NUMERIC(11, 2),
          @Ln_TotAssessOvpy_QNTY   NUMERIC(11, 2),
          @Ln_TotRecOvpy_QNTY      NUMERIC(11, 2),
          @Ln_Error_NUMB           NUMERIC(11),
          @Ln_ErrorLine_NUMB       NUMERIC(11),
          @Ln_Unique_IDNO          NUMERIC(19),
          @Lc_Null_TEXT            CHAR(1) = '',
          @Lc_ChkRecipient_CODE    CHAR(1),
          @Lc_TypeRecoupment_CODE  CHAR(1),
          @Lc_RecoupmentPayee_CODE CHAR(1),
          @Lc_SourceBatch_CODE     CHAR(3),
          @Lc_TypeDisburse_CODE    CHAR(5),
          @Lc_ChkRecipient_ID      CHAR(10),
          @Ls_Sql_TEXT             VARCHAR(100),
          @Ls_Sqldata_TEXT         VARCHAR(1000),
          @Ls_ErrorMessage_TEXT    VARCHAR(2000),
          @Ld_Batch_DATE           DATE;
          
  DECLARE @Ln_CheckHoldCur_Case_IDNO                  NUMERIC(6),
          @Ln_CheckHoldCur_OrderSeq_NUMB              NUMERIC(2),
          @Ln_CheckHoldCur_ObligationSeq_NUMB         NUMERIC(2),
          @Ld_CheckHoldCur_Batch_DATE                 DATE,
          @Lc_CheckHoldCur_SourceBatch_CODE           CHAR(3),
          @Ln_CheckHoldCur_Batch_NUMB                 NUMERIC(4),
          @Ln_CheckHoldCur_SeqReceipt_NUMB            NUMERIC(6),
          @Ld_CheckHoldCur_Transaction_DATE           DATE,
          @Ld_CheckHoldCur_Release_DATE               DATE,
          @Ln_CheckHoldCur_Transaction_AMNT           NUMERIC(11, 2),
          @Lc_CheckHoldCur_Status_CODE                CHAR(1),
          @Lc_CheckHoldCur_TypeDisburse_CODE          CHAR(5),
          @Lc_CheckHoldCur_CheckRecipient_ID          CHAR(10),
          @Lc_CheckHoldCur_TypeHold_CODE              CHAR(1),
          @Lc_CheckHoldCur_CheckRecipient_CODE        CHAR(1),
          @Ln_CheckHoldCur_DisburseSubSeq_NUMB        NUMERIC(6),
          @Lc_CheckHoldCur_ProcessOffset_INDC         CHAR(1),
          @Ln_CheckHoldCur_EventGlobalSupportSeq_NUMB NUMERIC(19),
          @Ln_CheckHoldCur_EventGlobalBackOutSeq_NUMB NUMERIC(19),
          @Ln_CheckHoldCur_TotAssessOvpy_QNTY         NUMERIC(11, 2),
          @Ln_CheckHoldCur_Paid_AMNT                  NUMERIC(11, 2),
          @Ln_CheckHoldCur_TotPendOffset_QNTY         NUMERIC(11, 2),
          @Ln_CheckHoldCur_TotRecOvpy_QNTY            NUMERIC(11, 2),
          @Ln_CheckHoldCur_Swap_AMNT                  NUMERIC(11, 2),
          @Ln_CheckHoldCur_Unique_IDNO                NUMERIC(19),
          @Ld_CheckHoldCur_Disburse_DATE              DATE,
          @Ln_CheckHoldCur_DisburseSeq_NUMB           NUMERIC(4);

  CREATE TABLE #TLHLD_P1
   (
     Case_IDNO                  NUMERIC(6, 0),
     OrderSeq_NUMB              NUMERIC(2, 0),
     ObligationSeq_NUMB         NUMERIC(2, 0),
     Batch_DATE                 DATE,
     SourceBatch_CODE           CHAR(3),
     Batch_NUMB                 NUMERIC(4, 0),
     SeqReceipt_NUMB            NUMERIC(6, 0),
     Transaction_DATE           DATE,
     Release_DATE               DATE,
     Transaction_AMNT           NUMERIC(11, 2),
     Status_CODE                CHAR(1),
     TypeDisburse_CODE          CHAR(5),
     CheckRecipient_ID          CHAR(10),
     TypeHold_CODE              CHAR(1),
     CheckRecipient_CODE        CHAR(1),
     DisburseSubSeq_NUMB        NUMERIC(6, 0),
     ProcessOffset_INDC         CHAR(1),
     EventGlobalSupportSeq_NUMB NUMERIC(19, 0),
     EventGlobalBackOutSeq_NUMB NUMERIC(19, 0),
     TotAssessOvpy_QNTY         NUMERIC(11, 2),
     Paid_AMNT                  NUMERIC(11, 2),
     TotPendOffset_QNTY         NUMERIC(11, 2),
     TotRecOvpy_QNTY            NUMERIC(11, 2),
     Swap_AMNT                  NUMERIC(11, 2),
     Unique_IDNO                NUMERIC(19, 0),
     Disburse_DATE              DATE,
     DisburseSeq_NUMB           NUMERIC(4, 0)
   );

  DECLARE @TempOrdeby3_P1 TABLE (
   Case_IDNO                  NUMERIC(6),
   OrderSeq_NUMB              NUMERIC(2),
   ObligationSeq_NUMB         NUMERIC(2),
   Batch_DATE                 DATE,
   SourceBatch_CODE           CHAR(3),
   Batch_NUMB                 NUMERIC(4),
   SeqReceipt_NUMB            NUMERIC(6),
   EventGlobalSupportSeq_NUMB NUMERIC(19),
   TypeDisburse_CODE          CHAR(5),
   Unique_IDNO                NUMERIC(19),
   Transaction_AMNT           NUMERIC(11, 2),
   Rank_NUMB                  NUMERIC (19, 0));
  DECLARE @TempOrderby_P1 TABLE (
   Case_IDNO                  NUMERIC(6),
   OrderSeq_NUMB              NUMERIC(2),
   ObligationSeq_NUMB         NUMERIC(2),
   Batch_DATE                 DATE,
   SourceBatch_CODE           CHAR(3),
   Batch_NUMB                 NUMERIC(4),
   SeqReceipt_NUMB            NUMERIC(6),
   EventGlobalSupportSeq_NUMB NUMERIC(19),
   TypeDisburse_CODE          CHAR(5),
   Unique_IDNO                NUMERIC(19),
   Swap_AMNT                  NUMERIC(11, 2),
   Rank_NUMB                  NUMERIC (19, 0));
  DECLARE @TempOrderby4_P1 TABLE (
   RecOverpay_AMNT            NUMERIC(11, 2),
   BAL_AMT                    NUMERIC(11, 2),
   Unique_IDNO                NUMERIC(19),
   Case_IDNO                  NUMERIC(6),
   OrderSeq_NUMB              NUMERIC(2),
   ObligationSeq_NUMB         NUMERIC(2),
   Batch_DATE                 DATE,
   SourceBatch_CODE           CHAR(3),
   Batch_NUMB                 NUMERIC(4),
   SeqReceipt_NUMB            NUMERIC(6),
   EventGlobalSupportSeq_NUMB NUMERIC(19),
   TypeDisburse_CODE          CHAR(5),
   Rank_NUMB                  NUMERIC (19, 0));
  DECLARE @TempOrderby5_P1 TABLE (
   DisburseSubSeq_NUMB NUMERIC(6),
   Transaction_AMNT    NUMERIC(11, 2),
   PendOffset_AMNT     NUMERIC(11, 2),
   AssessOverpay_AMNT  NUMERIC(11, 2),
   RecOverpay_AMNT     NUMERIC(11, 2),
   Pofl_AMNT           NUMERIC(11, 2),
   Rank_NUMB           NUMERIC(19, 0),
   GroupColumn_NUMB    NUMERIC(19, 0));
  DECLARE @TempOrderby6_P1 TABLE (
   Batch_DATE         DATE,
   SourceBatch_CODE   CHAR(3),
   Batch_NUMB         NUMERIC(4),
   SeqReceipt_NUMB    NUMERIC(6),
   Paid_AMNT          NUMERIC(11, 2),
   TotPendOffset_QNTY NUMERIC(11, 2),
   TotAssessOvpy_QNTY NUMERIC(11, 2),
   TotRecOvpy_QNTY    NUMERIC(11, 2),
   EstBal_AMNT        NUMERIC(11, 2),
   Rank_NUMB          NUMERIC (19, 0));
  DECLARE @TempOrderby7_P1 TABLE (
   Batch_DATE         DATE,
   SourceBatch_CODE   CHAR(3),
   Batch_NUMB         NUMERIC(4),
   SeqReceipt_NUMB    NUMERIC(6),
   Paid_AMNT          NUMERIC(11, 2),
   cum_amt            NUMERIC(11, 2),
   EstBal_AMNT        NUMERIC(11, 2),
   TxnAssess_AMNT     NUMERIC(11, 2),
   TotPendOffset_QNTY NUMERIC(11, 2),
   TotAssessOvpy_QNTY NUMERIC(11, 2),
   TotRecOvpy_QNTY    NUMERIC(11, 2));
  DECLARE @TempOrderby8_P1 TABLE (
   Batch_DATE         DATE,
   SourceBatch_CODE   CHAR(3),
   Batch_NUMB         NUMERIC(4),
   SeqReceipt_NUMB    NUMERIC(6),
   TxnAssess_AMNT     NUMERIC(11, 2),
   TxnPend_AMNT       NUMERIC(11, 2),
   TotPendOffset_QNTY NUMERIC(11, 2),
   TotAssessOvpy_QNTY NUMERIC(11, 2),
   TotRecOvpy_QNTY    NUMERIC(11, 2),
   Rank_NUMB          NUMERIC(19, 0));
  DECLARE @CheckHold_CUR CURSOR;

  SET @CheckHold_CUR = CURSOR
  FOR SELECT a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB,
             a.Batch_DATE,
             a.SourceBatch_CODE,
             a.Batch_NUMB,
             a.SeqReceipt_NUMB,
             a.Transaction_DATE,
             a.Release_DATE,
             a.Transaction_AMNT,
             a.Status_CODE,
             a.TypeDisburse_CODE,
             a.CheckRecipient_ID,
             a.TypeHold_CODE,
             a.CheckRecipient_CODE,
             a.DisburseSubSeq_NUMB,
             a.ProcessOffset_INDC,
             a.EventGlobalSupportSeq_NUMB,
             a.EventGlobalBackOutSeq_NUMB,
             a.TotAssessOvpy_QNTY,
             a.Paid_AMNT,
             a.TotPendOffset_QNTY,
             a.TotRecOvpy_QNTY,
             a.Swap_AMNT,
             a.Unique_IDNO,
             a.Disburse_DATE,
             a.DisburseSeq_NUMB
        FROM #TLHLD_P1 a WITH ( UPDLOCK )
       WHERE a.ProcessOffset_INDC = @Lc_Yes_INDC
         AND a.Transaction_AMNT > a.Paid_AMNT
       ORDER BY a.DisburseSubSeq_NUMB;

  BEGIN TRY
   SET @An_TransactionDhld_AMNT = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   IF ISNULL(LTRIM(RTRIM(@Ac_ReasonStatus_CODE)), '') = ''
       OR @Ac_StatusCheck_CODE IN (@Lc_DisburseStatusVoid_CODE, @Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusPending_CODE)
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = 'THIS PROCESS REQUIRES A VALID CHECK Status_CODE AND REASON CODE';

     RETURN;
    END

   /*starts -  Receipts put on hold if identified from ROTHP and Status_CODE check is void no re-issue.
   Voiding unidentified refund recieipts will place the RCTH_Y1 back from 'O' to 'U' */
   SET @Ls_Sql_TEXT = 'DELETE TLHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', DisburseSubSeq_NUMB = ' + ISNULL('1','');
   
   SELECT TOP 1 @Lc_TypeDisburse_CODE = d.TypeDisburse_CODE
     FROM DSBL_Y1 d
    WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND d.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND d.Disburse_DATE = @Ad_Disburse_DATE
      AND d.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
      AND d.DisburseSubSeq_NUMB = 1;

   IF @Lc_TypeDisburse_CODE = @Lc_DisbursementTypeRothp_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'ASSIGN OTHP QNTY';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     
     SELECT @Ln_Othp_QNTY = COUNT(1)
       FROM OTHP_Y1 o
      WHERE CAST(o.OtherParty_IDNO AS VARCHAR) = @Ac_CheckRecipient_ID
        AND o.EndValidity_DATE = @Ld_High_DATE;
    END

   IF @Lc_TypeDisburse_CODE = @Lc_DisbursementTypeRothp_CODE
      AND @Ac_StatusCheck_CODE NOT IN (@Lc_VsaStatusVoidReissue_CODE, @Lc_VsaStatusStopReissue_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UNIDENTIFY_RECEIPT - ROTHP ';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'');

     EXECUTE BATCH_COMMON$SP_UNIDENTIFY_RECEIPT
      @Ac_CheckRecipient_ID     = @Ac_CheckRecipient_ID,
      @Ac_CheckRecipient_CODE   = @Ac_CheckRecipient_CODE,
      @Ad_Disburse_DATE         = @Ad_Disburse_DATE,
      @An_DisburseSeq_NUMB      = @An_DisburseSeq_NUMB,
      @An_EventGlobalSeq_NUMB   = @An_EventGlobalSeq_NUMB,
      @Ad_Run_DATE              = @Ad_Process_DATE,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RETURN;
      END
    END
   ELSE IF @Lc_TypeDisburse_CODE = @Lc_DisbursementTypeRothp_CODE
      AND @Ac_StatusCheck_CODE IN (@Lc_VsaStatusVoidReissue_CODE, @Lc_VsaStatusStopReissue_CODE)
      AND @Ln_Othp_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UNIDENTIFY_RECEIPT';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'');
     
     EXECUTE BATCH_COMMON$SP_UNIDENTIFY_RECEIPT
      @Ac_CheckRecipient_ID     = @Ac_CheckRecipient_ID,
      @Ac_CheckRecipient_CODE   = @Ac_CheckRecipient_CODE,
      @Ad_Disburse_DATE         = @Ad_Disburse_DATE,
      @An_DisburseSeq_NUMB      = @An_DisburseSeq_NUMB,
      @An_EventGlobalSeq_NUMB   = @An_EventGlobalSeq_NUMB,
      @Ad_Run_DATE              = @Ad_Process_DATE,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RETURN;
      END

     RETURN;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE #TLHLD_P1';
     SET @Ls_Sqldata_TEXT = '';
     
     DELETE #TLHLD_P1;
     
	 --Insert all the DSBL records into #TLHLD_P1 with the RCTH_Y1 back-out indicator if any
     SET @Ls_Sql_TEXT = 'INSERT TLHLD_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Status_CODE = ' + ISNULL(@Lc_Null_TEXT,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_Null_TEXT,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'');
     INSERT #TLHLD_P1
            (Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalSupportSeq_NUMB,
             TypeDisburse_CODE,
             Transaction_AMNT,
             CheckRecipient_ID,
             CheckRecipient_CODE,
             DisburseSubSeq_NUMB,
             Status_CODE,
             TypeHold_CODE,
             Transaction_DATE,
             Release_DATE,
             ProcessOffset_INDC,
             EventGlobalBackOutSeq_NUMB,
             Paid_AMNT,
             Swap_AMNT)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.SourceBatch_CODE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.EventGlobalSupportSeq_NUMB,
            a.TypeDisburse_CODE,
            a.Disburse_AMNT,
            @Ac_CheckRecipient_ID AS CheckRecipient_ID,
            @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,
            a.DisburseSubSeq_NUMB,
            @Lc_Null_TEXT AS Status_CODE,
            @Lc_Null_TEXT AS TypeHold_CODE,
            @Ld_Low_DATE AS Transaction_DATE,
            ISNULL(b.Distribute_DATE, @Ld_Low_DATE) AS Release_DATE,
            ISNULL(b.BackOut_INDC, @Lc_No_INDC) AS ProcessOffset_INDC,
            ISNULL(b.EventGlobalBeginSeq_NUMB, 0) AS EventGlobalBackOutSeq_NUMB,
            0 AS Paid_AMNT,
            0 AS Swap_AMNT
       FROM DSBL_Y1 a
            LEFT OUTER JOIN RCTH_Y1 b
             ON a.Batch_DATE = b.Batch_DATE
                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                AND a.Batch_NUMB = b.Batch_NUMB
                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                AND b.EndValidity_DATE = @Ld_High_DATE
                AND b.BackOut_INDC = @Lc_Yes_INDC
      WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
        AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
        AND a.Disburse_DATE = @Ad_Disburse_DATE
        AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB;

     --Recover any Recoupment Value_AMNT from the money getting voided. 
     BEGIN
      --proceed with the OD recovery if altleast one RCTH_Y1 in #TLHLD_P1 is backed-out
      SET @Ls_Sql_TEXT = 'SELECT_TLHLD1';
      SET @Ls_Sqldata_TEXT = 'ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

      SELECT TOP 1 @Ln_Dummy_NUMB = 1,
                   @Ln_Case_IDNO = t.Case_IDNO,
                   @Lc_ChkRecipient_ID = t.CheckRecipient_ID,
                   @Lc_ChkRecipient_CODE = t.CheckRecipient_CODE,
                   @Ld_Batch_DATE = t.Batch_DATE,
                   @Lc_SourceBatch_CODE = t.SourceBatch_CODE,
                   @Ln_Batch_NUMB = t.Batch_NUMB,
                   @Ln_SeqReceipt_NUMB = t.SeqReceipt_NUMB,
                   @Lc_TypeDisburse_CODE = t.TypeDisburse_CODE
        FROM #TLHLD_P1 t
       WHERE t.ProcessOffset_INDC = @Lc_Yes_INDC;

      IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
       BEGIN
        IF @Lc_TypeDisburse_CODE <> @Lc_DisbursementTypeRefund_CODE
         BEGIN
          --For FIPS, check the OD balances for the CP associated with the Case
          SET @Ls_Sql_TEXT = 'SELECT_VCMEM';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL(CAST(@Ln_Case_IDNO AS NVARCHAR(6)), '');

          SELECT @Lc_ChkRecipient_ID = fci.MemberMci_IDNO,
                 @Lc_ChkRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
            FROM (SELECT TOP (1) a.MemberMci_IDNO,
                                 a.CaseMemberStatus_CODE
                    FROM CMEM_Y1 a
                   WHERE a.Case_IDNO = @Ln_Case_IDNO
                     AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                   ORDER BY 2) AS fci;
         END
        ELSE IF @Lc_TypeDisburse_CODE = @Lc_DisbursementTypeRefund_CODE
         BEGIN
          --NCP Pin_BIN is required for AR check type
          SET @Ls_Sql_TEXT = 'SELECT VRCTH_POFL';
          SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

          SELECT TOP 1 @Lc_ChkRecipient_ID = r.PayorMCI_IDNO,
                       @Lc_ChkRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
            FROM RCTH_Y1 r
           WHERE r.Batch_DATE = @Ld_Batch_DATE
             AND r.SourceBatch_CODE = @Lc_SourceBatch_CODE
             AND r.Batch_NUMB = @Ln_Batch_NUMB
             AND r.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
             AND r.EndValidity_DATE = @Ld_High_DATE;
         END
       END
       
      SET @Lc_TypeRecoupment_CODE = ' ';
      SET @Lc_RecoupmentPayee_CODE = 'S';
      
      SET @Ls_Sql_TEXT = 'SELECT POFL_Y1';
      SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_ChkRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_ChkRecipient_CODE,'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'');

      SELECT TOP 1 @Lc_TypeRecoupment_CODE = p.TypeRecoupment_CODE,
                   @Lc_RecoupmentPayee_CODE = p.RecoupmentPayee_CODE
        FROM POFL_Y1 p
       WHERE p.CheckRecipient_ID = @Lc_ChkRecipient_ID
         AND p.CheckRecipient_CODE = @Lc_ChkRecipient_CODE
         AND p.Batch_DATE = @Ld_Batch_DATE
         AND p.SourceBatch_CODE = @Lc_SourceBatch_CODE
         AND p.Batch_NUMB = @Ln_Batch_NUMB
         AND p.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB;

      SET @Ls_Sql_TEXT = 'INSERT @TempOrderby5_P1';
      SET @Ls_Sqldata_TEXT = 'ProcessOffset_INDC = ' + @Lc_Yes_INDC;
      
      INSERT @TempOrderby5_P1
             (DisburseSubSeq_NUMB,
              Transaction_AMNT,
              PendOffset_AMNT,
              AssessOverpay_AMNT,
              RecOverpay_AMNT,
              Pofl_AMNT,
              Rank_NUMB)
      SELECT a.DisburseSubSeq_NUMB,
             a.Transaction_AMNT,
             b.PendTotOffset_AMNT AS PendOffset_AMNT,
             b.AssessTotOverpay_AMNT AS AssessOverpay_AMNT,
             b.RecTotOverpay_AMNT AS RecOverpay_AMNT,
             (b.AssessTotOverpay_AMNT + b.PendTotOffset_AMNT - b.RecTotOverpay_AMNT) AS Pofl_AMNT,
             RANK() OVER (ORDER BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB, DisburseSubSeq_NUMB) AS Rank_NUMB
        FROM #TLHLD_P1 a,
             (SELECT MAX(b.Unique_IDNO) AS Unique_IDNO
                FROM POFL_Y1 b
               WHERE b.CheckRecipient_ID = @Lc_ChkRecipient_ID
                 AND b.CheckRecipient_CODE = @Lc_ChkRecipient_CODE) AS c
             LEFT OUTER JOIN POFL_Y1 b
              ON b.Unique_IDNO = c.Unique_IDNO
       WHERE a.ProcessOffset_INDC = @Lc_Yes_INDC;

      --Reduce the OD balances if any exists and update the Paid_AMNT column for each DisburseSubSeq_NUMB
      --Paid_AMNT for each DisburseSubSeq_NUMB level will be the SUM of Assessed and Pending OD
      SET @Ls_Sql_TEXT = 'CTE UpdTLHLDTbl';
      SET @Ls_Sqldata_TEXT = 'ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'');
      
      WITH UpdTLHLDTbl
           AS (SELECT CASE
                       WHEN CAST(a.Pofl_AMNT AS FLOAT) - CAST(a.cum_amt AS FLOAT) > 0
                            AND a.Transaction_AMNT > 0
                        THEN dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT(CAST(a.Pofl_AMNT AS FLOAT) - CAST(a.cum_amt AS FLOAT), a.Transaction_AMNT)
                       ELSE 0
                      END AS paid_amt,
                      a.PendOffset_AMNT,
                      a.AssessOverpay_AMNT,
                      a.RecOverpay_AMNT,
                      a.DisburseSubSeq_NUMB
                 FROM (SELECT DisburseSubSeq_NUMB,
                              Transaction_AMNT,
                              ((SELECT SUM((Transaction_AMNT))
                                  FROM @TempOrderby5_P1 b
                                 WHERE b.Rank_NUMB <= a.Rank_NUMB) - Transaction_AMNT) cum_amt,
                              PendOffset_AMNT,
                              AssessOverpay_AMNT,
                              RecOverpay_AMNT,
                              Pofl_AMNT
                         FROM @TempOrderby5_P1 a) AS a)
      UPDATE #TLHLD_P1
         SET Paid_AMNT = d.paid_amt,
             TotPendOffset_QNTY = d.PendOffset_AMNT,
             TotAssessOvpy_QNTY = d.AssessOverpay_AMNT,
             TotRecOvpy_QNTY = d.RecOverpay_AMNT
        FROM #TLHLD_P1 c
             LEFT OUTER JOIN UpdTLHLDTbl d
              ON c.DisburseSubSeq_NUMB = d.DisburseSubSeq_NUMB
       WHERE c.ProcessOffset_INDC = @Lc_Yes_INDC;

      SET @Ls_Sql_TEXT = 'INSERT @TempOrderby6_P1';
      SET @Ls_Sqldata_TEXT = 'ProcessOffset_INDC = ' + @Lc_Yes_INDC;

      INSERT @TempOrderby6_P1
             (Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              Paid_AMNT,
              TotPendOffset_QNTY,
              TotAssessOvpy_QNTY,
              TotRecOvpy_QNTY,
              EstBal_AMNT,
              Rank_NUMB)
      SELECT a.Batch_DATE,
             a.SourceBatch_CODE,
             a.Batch_NUMB,
             a.SeqReceipt_NUMB,
             SUM(a.Paid_AMNT) AS Paid_AMNT,
             a.TotPendOffset_QNTY,
             a.TotAssessOvpy_QNTY,
             a.TotRecOvpy_QNTY,
             (a.TotAssessOvpy_QNTY - a.TotRecOvpy_QNTY) AS EstBal_AMNT,
             RANK() OVER (ORDER BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS Rank_NUMB
        FROM #TLHLD_P1 a
       WHERE a.ProcessOffset_INDC = @Lc_Yes_INDC
         AND a.Paid_AMNT > 0
       GROUP BY a.Batch_DATE,
                a.SourceBatch_CODE,
                a.Batch_NUMB,
                a.SeqReceipt_NUMB,
                a.Case_IDNO,
                a.TotPendOffset_QNTY,
                a.TotAssessOvpy_QNTY,
                a.TotRecOvpy_QNTY;

      SET @Ls_Sql_TEXT = 'INSERT @TempOrderby7_P1';
      SET @Ls_Sqldata_TEXT = '';

      INSERT @TempOrderby7_P1
             (Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              Paid_AMNT,
              cum_amt,
              EstBal_AMNT,
              TxnAssess_AMNT,
              TotPendOffset_QNTY,
              TotAssessOvpy_QNTY,
              TotRecOvpy_QNTY)
      SELECT Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             Paid_AMNT,
             (SELECT SUM((Paid_AMNT))
                FROM @TempOrderby6_P1 b
               WHERE b.Rank_NUMB <= a.Rank_NUMB) - Paid_AMNT cum_amt,
             EstBal_AMNT,
             CASE
              WHEN CAST(EstBal_AMNT AS FLOAT) - CAST((SELECT SUM((Paid_AMNT))
                                                        FROM @TempOrderby6_P1 b
                                                       WHERE b.Rank_NUMB <= a.Rank_NUMB) - Paid_AMNT AS FLOAT) > 0
                   AND Paid_AMNT > 0
               THEN dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT(CAST(EstBal_AMNT AS FLOAT) - CAST((SELECT SUM((Paid_AMNT))
                                                                                                FROM @TempOrderby6_P1 b
                                                                                               WHERE b.Rank_NUMB <= a.Rank_NUMB) - Paid_AMNT AS FLOAT), CAST(Paid_AMNT AS FLOAT))
              ELSE 0
             END AS TxnAssess_AMNT,
             TotPendOffset_QNTY,
             TotAssessOvpy_QNTY,
             TotRecOvpy_QNTY
        FROM @TempOrderby6_P1 a;

      SET @Ls_Sql_TEXT = 'INSERT @TempOrderby8_P1';
      SET @Ls_Sqldata_TEXT = '';

      INSERT @TempOrderby8_P1
             (Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              TxnAssess_AMNT,
              TxnPend_AMNT,
              TotPendOffset_QNTY,
              TotAssessOvpy_QNTY,
              TotRecOvpy_QNTY,
              Rank_NUMB)
      SELECT Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             TxnAssess_AMNT,
             CASE
              WHEN TotPendOffset_QNTY + CAST(EstBal_AMNT AS FLOAT) - CAST(cum_amt AS FLOAT) > 0
                   AND CAST(Paid_AMNT AS FLOAT) - CAST(TxnAssess_AMNT AS FLOAT) > 0
               THEN dbo.BATCH_COMMON_SCALAR$SF_LEAST_INT (TotPendOffset_QNTY + EstBal_AMNT - cum_amt, Paid_AMNT - TxnAssess_AMNT)
              ELSE 0
             END AS TxnPend_AMNT,
             TotPendOffset_QNTY,
             TotAssessOvpy_QNTY,
             TotRecOvpy_QNTY,
             RANK() OVER (ORDER BY Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB) AS Rank_NUMB
        FROM @TempOrderby7_P1;

      -- Insert into POFL for the reduction in Pending and Assessed OD Value_AMNT. Paid_AMNT values will be grouped
      -- and inserted at RCTH_Y1 level with further break-up for Assessed and Pending buckets
      SET @Ls_Sql_TEXT = 'INSERT_POFL_Y1-1';
      SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_ChkRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_ChkRecipient_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL('0','') + ', ObligationSeq_NUMB = ' + ISNULL('0','') + ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(' ','')+ ', RecAdvance_AMNT = ' + ISNULL('0','') + ', RecTotAdvance_AMNT = ' + ISNULL('0','') + ', RecOverpay_AMNT = ' + ISNULL('0','') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL('0','') + ', TypeRecoupment_CODE = ' + ISNULL(@Lc_TypeRecoupment_CODE,'')+ ', RecoupmentPayee_CODE = ' + ISNULL(@Lc_RecoupmentPayee_CODE,'');

      INSERT POFL_Y1
             (CheckRecipient_ID,
              CheckRecipient_CODE,
              Case_IDNO,
              OrderSeq_NUMB,
              ObligationSeq_NUMB,
              Transaction_DATE,
              TypeDisburse_CODE,
              Reason_CODE,
              PendOffset_AMNT,
              PendTotOffset_AMNT,
              RecAdvance_AMNT,
              RecTotAdvance_AMNT,
              AssessOverpay_AMNT,
              AssessTotOverpay_AMNT,
              RecOverpay_AMNT,
              RecTotOverpay_AMNT,
              Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              EventGlobalSeq_NUMB,
              EventGlobalSupportSeq_NUMB,
              Transaction_CODE,
              TypeRecoupment_CODE,
              RecoupmentPayee_CODE)
      SELECT @Lc_ChkRecipient_ID AS CheckRecipient_ID,--CheckRecipient_ID
             @Lc_ChkRecipient_CODE AS CheckRecipient_CODE,--CheckRecipient_CODE
             @Ln_Case_IDNO AS Case_IDNO,--Case_IDNO
             0 AS OrderSeq_NUMB,--OrderSeq_NUMB
             0 AS ObligationSeq_NUMB,--ObligationSeq_NUMB
             @Ad_Process_DATE AS Transaction_DATE,--Transaction_DATE
             ' ' AS TypeDisburse_CODE,--TypeDisburse_CODE
             CASE
              WHEN TxnPend_AMNT <> 0
               THEN 'PV'
              WHEN TxnAssess_AMNT <> 0
               THEN 'AV'
              ELSE ' '
             END AS Reason_CODE,--Reason_CODE
             -TxnPend_AMNT AS PendOffset_AMNT,--PendOffset_AMNT
             TotPendOffset_QNTY - (SELECT SUM (TxnPend_AMNT)
                                     FROM @TempOrderby8_P1 b
                                    WHERE b.Rank_NUMB <= a.Rank_NUMB) AS PendTotOffset_AMNT,--PendTotOffset_AMNT
             0 AS RecAdvance_AMNT,--RecAdvance_AMNT
             0 AS RecTotAdvance_AMNT,--RecTotAdvance_AMNT
             -TxnAssess_AMNT AS AssessOverpay_AMNT,--AssessOverpay_AMNT
             TotAssessOvpy_QNTY - (SELECT SUM (TxnAssess_AMNT)
                                     FROM @TempOrderby8_P1 b
                                    WHERE b.Rank_NUMB <= a.Rank_NUMB) AS AssessTotOverpay_AMNT,--AssessTotOverpay_AMNT
             0 AS RecOverpay_AMNT,--RecOverpay_AMNT
             TotRecOvpy_QNTY,--RecTotOverpay_AMNT
             Batch_DATE,--Batch_DATE
             SourceBatch_CODE,--SourceBatch_CODE
             Batch_NUMB,--Batch_NUMB
             SeqReceipt_NUMB,--SeqReceipt_NUMB
             @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
             0 AS EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
             CASE
              WHEN TxnPend_AMNT <> 0
                   AND TxnAssess_AMNT <> 0
               THEN 'CMUL'
              WHEN TxnPend_AMNT <> 0
               THEN 'CHPV'
              WHEN TxnAssess_AMNT <> 0
               THEN 'CHAV'
             END AS Transaction_CODE,--Transaction_CODE
             @Lc_TypeRecoupment_CODE AS TypeRecoupment_CODE,--TypeRecoupment_CODE
             @Lc_RecoupmentPayee_CODE AS RecoupmentPayee_CODE--RecoupmentPayee_CODE
        FROM @TempOrderby8_P1 a;

      SET @Ls_Sql_TEXT = 'DELETE FROM @TempOrderby5_P1';
      SET @Ls_Sqldata_TEXT = '';
      DELETE FROM @TempOrderby5_P1;

      SET @Ls_Sql_TEXT = 'DELETE FROM @TempOrderby6_P1';
      SET @Ls_Sqldata_TEXT = '';
      DELETE FROM @TempOrderby6_P1;
      
      SET @Ls_Sql_TEXT = 'DELETE FROM @TempOrderby7_P1';
      SET @Ls_Sqldata_TEXT = '';
      DELETE FROM @TempOrderby7_P1;

      SET @Ls_Sql_TEXT = 'DELETE FROM @TempOrderby8_P1';
      SET @Ls_Sqldata_TEXT = '';      
      DELETE FROM @TempOrderby8_P1;

      SET @Ln_Ins_QNTY = @@ROWCOUNT;
      
      OPEN @CheckHold_CUR;

      FETCH NEXT FROM @CheckHold_CUR INTO @Ln_CheckHoldCur_Case_IDNO, @Ln_CheckHoldCur_OrderSeq_NUMB, @Ln_CheckHoldCur_ObligationSeq_NUMB, @Ld_CheckHoldCur_Batch_DATE, @Lc_CheckHoldCur_SourceBatch_CODE, @Ln_CheckHoldCur_Batch_NUMB, @Ln_CheckHoldCur_SeqReceipt_NUMB, @Ld_CheckHoldCur_Transaction_DATE, @Ld_CheckHoldCur_Release_DATE, @Ln_CheckHoldCur_Transaction_AMNT, @Lc_CheckHoldCur_Status_CODE, @Lc_CheckHoldCur_TypeDisburse_CODE, @Lc_CheckHoldCur_CheckRecipient_ID, @Lc_CheckHoldCur_TypeHold_CODE, @Lc_CheckHoldCur_CheckRecipient_CODE, @Ln_CheckHoldCur_DisburseSubSeq_NUMB, @Lc_CheckHoldCur_ProcessOffset_INDC, @Ln_CheckHoldCur_EventGlobalSupportSeq_NUMB, @Ln_CheckHoldCur_EventGlobalBackOutSeq_NUMB, @Ln_CheckHoldCur_TotAssessOvpy_QNTY, @Ln_CheckHoldCur_Paid_AMNT, @Ln_CheckHoldCur_TotPendOffset_QNTY, @Ln_CheckHoldCur_TotRecOvpy_QNTY, @Ln_CheckHoldCur_Swap_AMNT, @Ln_CheckHoldCur_Unique_IDNO, @Ld_CheckHoldCur_Disburse_DATE, @Ln_CheckHoldCur_DisburseSeq_NUMB;

      SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

      BEGIN
       -- FETCH EACH RECORD
       WHILE @Ln_FetchStatus_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT @TempOrderby4_P1';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + CAST(@Lc_ChkRecipient_ID AS VARCHAR) + ', CheckRecipient_CODE = ' + @Lc_ChkRecipient_CODE + ', RecOverpay_AMNT > ' + CAST(0 AS VARCHAR) + ', EventGlobalSeq_NUMB > ' + CAST(@Ln_CheckHoldCur_EventGlobalBackOutSeq_NUMB AS VARCHAR);
         
         INSERT @TempOrderby4_P1
                (RecOverpay_AMNT,
                 BAL_AMT,
                 Unique_IDNO,
                 Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 EventGlobalSupportSeq_NUMB,
                 TypeDisburse_CODE,
                 Rank_NUMB)
         SELECT (a.RecOverpay_AMNT - ISNULL(x.curr_swap_amt, 0) - ISNULL(y.prev_swap_amt, 0)) AS RecOverpay_AMNT,
                @Ln_CheckHoldCur_Transaction_AMNT - @Ln_CheckHoldCur_Paid_AMNT AS BAL_AMT,
                a.Unique_IDNO,
                a.Case_IDNO,
                a.OrderSeq_NUMB,
                a.ObligationSeq_NUMB,
                a.Batch_DATE,
                a.SourceBatch_CODE,
                a.Batch_NUMB,
                a.SeqReceipt_NUMB,
                a.EventGlobalSupportSeq_NUMB,
                a.TypeDisburse_CODE,
                RANK() OVER(ORDER BY a.Unique_IDNO ASC) AS Rank_NUMB
           FROM POFL_Y1 a
                LEFT OUTER JOIN (SELECT b.Unique_IDNO,
                                        SUM(b.Transaction_AMNT) AS curr_swap_amt
                                   FROM #TLHLD_P1 b
                                  WHERE b.ProcessOffset_INDC = 'X'
                                  GROUP BY b.Unique_IDNO) AS x
                 ON a.Unique_IDNO = x.Unique_IDNO
                LEFT OUTER JOIN (SELECT c.Case_IDNO,
                                        c.OrderSeq_NUMB,
                                        c.ObligationSeq_NUMB,
                                        c.Batch_DATE,
                                        c.SourceBatch_CODE,
                                        c.Batch_NUMB,
                                        c.SeqReceipt_NUMB,
                                        c.EventGlobalSupportSeq_NUMB,
                                        c.TypeDisburse_CODE,
                                        -SUM(c.RecOverpay_AMNT) AS prev_swap_amt
                                   FROM POFL_Y1 c
                                  WHERE c.CheckRecipient_ID = @Lc_ChkRecipient_ID
                                    AND c.CheckRecipient_CODE = @Lc_ChkRecipient_CODE
                                    AND c.RecOverpay_AMNT < 0
                                  GROUP BY c.Case_IDNO,
                                           c.OrderSeq_NUMB,
                                           c.ObligationSeq_NUMB,
                                           c.Batch_DATE,
                                           c.SourceBatch_CODE,
                                           c.Batch_NUMB,
                                           c.SeqReceipt_NUMB,
                                           c.EventGlobalSupportSeq_NUMB,
                                           c.TypeDisburse_CODE) AS y
                 ON a.Case_IDNO = y.Case_IDNO
                    AND a.OrderSeq_NUMB = y.OrderSeq_NUMB
                    AND a.ObligationSeq_NUMB = y.ObligationSeq_NUMB
                    AND a.Batch_DATE = y.Batch_DATE
                    AND a.SourceBatch_CODE = y.SourceBatch_CODE
                    AND a.Batch_NUMB = y.Batch_NUMB
                    AND a.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                    AND a.EventGlobalSupportSeq_NUMB = y.EventGlobalSupportSeq_NUMB
                    AND a.TypeDisburse_CODE = y.TypeDisburse_CODE
          WHERE a.CheckRecipient_ID = @Lc_ChkRecipient_ID
            AND a.CheckRecipient_CODE = @Lc_ChkRecipient_CODE
            AND a.RecOverpay_AMNT > 0
            AND a.RecOverpay_AMNT - ISNULL(x.curr_swap_amt, 0) - ISNULL(y.prev_swap_amt, 0) > 0
            AND a.EventGlobalSeq_NUMB > @Ln_CheckHoldCur_EventGlobalBackOutSeq_NUMB
            AND NOT EXISTS (SELECT 1
                              FROM RCTH_Y1 d
                             WHERE d.Batch_DATE = a.Batch_DATE
                               AND d.SourceBatch_CODE = a.SourceBatch_CODE
                               AND d.Batch_NUMB = a.Batch_NUMB
                               AND d.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                               AND d.EndValidity_DATE = @Ld_High_DATE
                               AND d.BackOut_INDC = @Lc_Yes_INDC)
          ORDER BY a.Unique_IDNO ASC;

         -- For each LHLD backed out record which did not satisfy the OD balance in prev statement,
         -- scan the POFL for any recovery transaction after the RCTH_Y1 backed out event.
         -- Subtract previously swapped money for the recovery record. Make sure that the RCTH_Y1 is not backed-out
         -- Insert a record into LHLD with ProcessOffset_INDC ='X' using the POFL recovery records that
         -- can be used for RCTH_Y1 swap
         SET @Ls_Sql_TEXT = 'INSERT_TLHLD_Y1 - 2';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', DisburseSubSeq_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_DisburseSubSeq_NUMB AS VARCHAR ),'')+ ', ProcessOffset_INDC = ' + ISNULL('X','');

         INSERT #TLHLD_P1
                (Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 EventGlobalSupportSeq_NUMB,
                 Transaction_AMNT,
                 TypeDisburse_CODE,
                 CheckRecipient_ID,
                 CheckRecipient_CODE,
                 DisburseSubSeq_NUMB,
                 ProcessOffset_INDC,
                 Unique_IDNO)
         SELECT fci.Case_IDNO,
                fci.OrderSeq_NUMB,
                fci.ObligationSeq_NUMB,
                fci.Batch_DATE,
                fci.SourceBatch_CODE,
                fci.Batch_NUMB,
                fci.SeqReceipt_NUMB,
                fci.EventGlobalSupportSeq_NUMB,
                fci.swap_amt,
                fci.TypeDisburse_CODE,
                @Ac_CheckRecipient_ID AS CheckRecipient_ID,
                @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,
                @Ln_CheckHoldCur_DisburseSubSeq_NUMB AS DisburseSubSeq_NUMB,
                'X' AS ProcessOffset_INDC,
                fci.Unique_IDNO
           FROM (SELECT fci.Case_IDNO,
                        fci.OrderSeq_NUMB,
                        fci.ObligationSeq_NUMB,
                        fci.Batch_DATE,
                        fci.SourceBatch_CODE,
                        fci.Batch_NUMB,
                        fci.SeqReceipt_NUMB,
                        fci.EventGlobalSupportSeq_NUMB,
                        CASE
                         WHEN CAST(fci.bal_amt AS FLOAT) - (CAST(fci.cum_amt AS FLOAT) - CAST(fci.RecOverpay_AMNT AS FLOAT)) > 0
                              AND fci.RecOverpay_AMNT > 0
                          THEN dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT(CAST(fci.bal_amt AS FLOAT) - (CAST(fci.cum_amt AS FLOAT) - CAST(fci.RecOverpay_AMNT AS FLOAT)), CAST(fci.RecOverpay_AMNT AS FLOAT))
                         ELSE 0
                        END AS swap_amt,
                        fci.TypeDisburse_CODE,
                        @Ac_CheckRecipient_ID AS CheckRecipient_ID,
                        @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,
                        @Ln_CheckHoldCur_DisburseSubSeq_NUMB AS DisburseSubSeq_NUMB,
                        'X' AS ProcessOffset_INDC,
                        fci.Unique_IDNO
                   FROM (SELECT RecOverpay_AMNT,
                                (SELECT SUM((RecOverpay_AMNT))
                                   FROM @TempOrderby4_P1 b
                                  WHERE b.Rank_NUMB <= a.Rank_NUMB) AS cum_amt,
                                BAL_AMT,
                                Unique_IDNO,
                                Case_IDNO,
                                OrderSeq_NUMB,
                                ObligationSeq_NUMB,
                                Batch_DATE,
                                SourceBatch_CODE,
                                Batch_NUMB,
                                SeqReceipt_NUMB,
                                EventGlobalSupportSeq_NUMB,
                                TypeDisburse_CODE
                           FROM @TempOrderby4_P1 a) AS fci) AS fci
          WHERE fci.swap_amt > 0;

         SET @Ls_Sql_TEXT = 'DELETE FROM @TempOrderby4_P1';
         SET @Ls_Sqldata_TEXT = '';
         
         DELETE FROM @TempOrderby4_P1;

		 --Update the swapped amount for the current record 	
         SET @Ls_Sql_TEXT = 'UPDATE_TLHLD1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CheckHoldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_CheckHoldCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CheckHoldCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_CheckHoldCur_Transaction_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_CheckHoldCur_Release_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_CheckHoldCur_Transaction_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_CheckHoldCur_Status_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_CheckHoldCur_TypeDisburse_CODE,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckHoldCur_CheckRecipient_ID,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_CheckHoldCur_TypeHold_CODE,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckHoldCur_CheckRecipient_CODE,'')+ ', DisburseSubSeq_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_DisburseSubSeq_NUMB AS VARCHAR ),'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_CheckHoldCur_ProcessOffset_INDC,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalBackOutSeq_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_EventGlobalBackOutSeq_NUMB AS VARCHAR ),'')+ ', TotAssessOvpy_QNTY = ' + ISNULL(CAST( @Ln_CheckHoldCur_TotAssessOvpy_QNTY AS VARCHAR ),'')+ ', Paid_AMNT = ' + ISNULL(CAST( @Ln_CheckHoldCur_Paid_AMNT AS VARCHAR ),'')+ ', TotPendOffset_QNTY = ' + ISNULL(CAST( @Ln_CheckHoldCur_TotPendOffset_QNTY AS VARCHAR ),'')+ ', TotRecOvpy_QNTY = ' + ISNULL(CAST( @Ln_CheckHoldCur_TotRecOvpy_QNTY AS VARCHAR ),'')+ ', Swap_AMNT = ' + ISNULL(CAST( @Ln_CheckHoldCur_Swap_AMNT AS VARCHAR ),'')+ ', Unique_IDNO = ' + ISNULL(CAST( @Ln_CheckHoldCur_Unique_IDNO AS VARCHAR ),'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_CheckHoldCur_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @Ln_CheckHoldCur_DisburseSeq_NUMB AS VARCHAR ),'');

         UPDATE #TLHLD_P1
            SET Swap_AMNT = (SELECT ISNULL(SUM(b.Transaction_AMNT), 0)
                               FROM #TLHLD_P1 b
                              WHERE b.ProcessOffset_INDC = 'X'
                                AND b.DisburseSubSeq_NUMB = @Ln_CheckHoldCur_DisburseSubSeq_NUMB)
           FROM #TLHLD_P1 a
          WHERE Case_IDNO = @Ln_CheckHoldCur_Case_IDNO
            AND OrderSeq_NUMB = @Ln_CheckHoldCur_OrderSeq_NUMB
            AND ObligationSeq_NUMB = @Ln_CheckHoldCur_ObligationSeq_NUMB
            AND Batch_DATE = @Ld_CheckHoldCur_Batch_DATE
            AND SourceBatch_CODE = @Lc_CheckHoldCur_SourceBatch_CODE
            AND Batch_NUMB = @Ln_CheckHoldCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_CheckHoldCur_SeqReceipt_NUMB
            AND Transaction_DATE = @Ld_CheckHoldCur_Transaction_DATE
            AND Release_DATE = @Ld_CheckHoldCur_Release_DATE
            AND Transaction_AMNT = @Ln_CheckHoldCur_Transaction_AMNT
            AND Status_CODE = @Lc_CheckHoldCur_Status_CODE
            AND TypeDisburse_CODE = @Lc_CheckHoldCur_TypeDisburse_CODE
            AND CheckRecipient_ID = @Lc_CheckHoldCur_CheckRecipient_ID
            AND TypeHold_CODE = @Lc_CheckHoldCur_TypeHold_CODE
            AND CheckRecipient_CODE = @Lc_CheckHoldCur_CheckRecipient_CODE
            AND DisburseSubSeq_NUMB = @Ln_CheckHoldCur_DisburseSubSeq_NUMB
            AND ProcessOffset_INDC = @Lc_CheckHoldCur_ProcessOffset_INDC
            AND EventGlobalSupportSeq_NUMB = @Ln_CheckHoldCur_EventGlobalSupportSeq_NUMB
            AND EventGlobalBackOutSeq_NUMB = @Ln_CheckHoldCur_EventGlobalBackOutSeq_NUMB
            AND TotAssessOvpy_QNTY = @Ln_CheckHoldCur_TotAssessOvpy_QNTY
            AND Paid_AMNT = @Ln_CheckHoldCur_Paid_AMNT
            AND TotPendOffset_QNTY = @Ln_CheckHoldCur_TotPendOffset_QNTY
            AND TotRecOvpy_QNTY = @Ln_CheckHoldCur_TotRecOvpy_QNTY
            AND Swap_AMNT = @Ln_CheckHoldCur_Swap_AMNT
            AND Unique_IDNO = @Ln_CheckHoldCur_Unique_IDNO
            AND Disburse_DATE = @Ld_CheckHoldCur_Disburse_DATE
            AND DisburseSeq_NUMB = @Ln_CheckHoldCur_DisburseSeq_NUMB;

         FETCH NEXT FROM @CheckHold_CUR INTO @Ln_CheckHoldCur_Case_IDNO, @Ln_CheckHoldCur_OrderSeq_NUMB, @Ln_CheckHoldCur_ObligationSeq_NUMB, @Ld_CheckHoldCur_Batch_DATE, @Lc_CheckHoldCur_SourceBatch_CODE, @Ln_CheckHoldCur_Batch_NUMB, @Ln_CheckHoldCur_SeqReceipt_NUMB, @Ld_CheckHoldCur_Transaction_DATE, @Ld_CheckHoldCur_Release_DATE, @Ln_CheckHoldCur_Transaction_AMNT, @Lc_CheckHoldCur_Status_CODE, @Lc_CheckHoldCur_TypeDisburse_CODE, @Lc_CheckHoldCur_CheckRecipient_ID, @Lc_CheckHoldCur_TypeHold_CODE, @Lc_CheckHoldCur_CheckRecipient_CODE, @Ln_CheckHoldCur_DisburseSubSeq_NUMB, @Lc_CheckHoldCur_ProcessOffset_INDC, @Ln_CheckHoldCur_EventGlobalSupportSeq_NUMB, @Ln_CheckHoldCur_EventGlobalBackOutSeq_NUMB, @Ln_CheckHoldCur_TotAssessOvpy_QNTY, @Ln_CheckHoldCur_Paid_AMNT, @Ln_CheckHoldCur_TotPendOffset_QNTY, @Ln_CheckHoldCur_TotRecOvpy_QNTY, @Ln_CheckHoldCur_Swap_AMNT, @Ln_CheckHoldCur_Unique_IDNO, @Ld_CheckHoldCur_Disburse_DATE, @Ln_CheckHoldCur_DisburseSeq_NUMB;

         SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
        END
      END

      CLOSE @CheckHold_CUR;

      DEALLOCATE @CheckHold_CUR;

      BEGIN
       -- Proceed with RCTH_Y1 swap if atleast one swap record exists
       SET @Ls_Sql_TEXT = 'SELECT_TLHLD2';
       SET @Ls_Sqldata_TEXT = 'ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

       SELECT TOP 1 @Ln_Dummy_NUMB = 1
         FROM #TLHLD_P1 t
        WHERE t.ProcessOffset_INDC = @Lc_Yes_INDC
          AND t.Swap_AMNT > 0;

       SET @Ls_Sql_TEXT = 'SELECT MAX OF UNIQUE IDNO';
       SET @Ls_Sqldata_TEXT = '';
       
       SELECT @Ln_Unique_IDNO = MAX(Unique_IDNO)
         FROM POFL_Y1 g;

       IF @Ln_Ins_QNTY > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_VPOFL';
         SET @Ls_Sqldata_TEXT = 'Unique_IDNO = ' + ISNULL(CAST( @Ln_Unique_IDNO AS VARCHAR ),'');

         SELECT @Ln_TotPendOffset_QNTY = p.PendTotOffset_AMNT,
                @Ln_TotAssessOvpy_QNTY = p.AssessTotOverpay_AMNT,
                @Ln_TotRecOvpy_QNTY = p.RecTotOverpay_AMNT
           FROM POFL_Y1 p
          WHERE p.Unique_IDNO = @Ln_Unique_IDNO;
        END
       ELSE
        BEGIN
         --Else Select from LHLD for the total values
         SET @Ls_Sql_TEXT = 'SELECT_TLHLD3';
         SET @Ls_Sqldata_TEXT = 'ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

         SELECT TOP 1 @Ln_TotPendOffset_QNTY = t.TotPendOffset_QNTY,
                      @Ln_TotAssessOvpy_QNTY = t.TotAssessOvpy_QNTY,
                      @Ln_TotRecOvpy_QNTY = t.TotRecOvpy_QNTY
           FROM #TLHLD_P1 t
          WHERE t.ProcessOffset_INDC = @Lc_Yes_INDC;
        END

       SET @Ls_Sql_TEXT = 'INSERT_@TempOrdeby3_P1';
       SET @Ls_Sqldata_TEXT = 'Unique_IDNO = ' + ISNULL(CAST( @Ln_Unique_IDNO AS VARCHAR ),'');

       INSERT @TempOrdeby3_P1
              (Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               EventGlobalSupportSeq_NUMB,
               TypeDisburse_CODE,
               Unique_IDNO,
               Transaction_AMNT,
               Rank_NUMB)
       SELECT Case_IDNO,
              OrderSeq_NUMB,
              ObligationSeq_NUMB,
              Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              EventGlobalSupportSeq_NUMB,
              TypeDisburse_CODE,
              @Ln_Unique_IDNO AS Unique_IDNO,
              SUM(Transaction_AMNT) Transaction_AMNT,
              RANK() OVER(ORDER BY Unique_IDNO) Rank_NUMB
         FROM (SELECT a.Case_IDNO,
                      a.OrderSeq_NUMB,
                      a.ObligationSeq_NUMB,
                      a.Batch_DATE,
                      a.SourceBatch_CODE,
                      a.Batch_NUMB,
                      a.SeqReceipt_NUMB,
                      a.EventGlobalSupportSeq_NUMB,
                      a.TypeDisburse_CODE,
                      @Ln_Unique_IDNO AS Unique_IDNO,
                      a.Transaction_AMNT
                 FROM #TLHLD_P1 a
                WHERE a.ProcessOffset_INDC = 'X')ZZ
        GROUP BY Unique_IDNO,
                 Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 EventGlobalSupportSeq_NUMB,
                 TypeDisburse_CODE;

       --RECEIPT SWAP : Insert the negative amt_rec_overpay txn for receipt already used for OD recovery
       SET @Ls_Sql_TEXT = 'INSERT_VPOFL2';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_ChkRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_ChkRecipient_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Reason_CODE = ' + ISNULL('SW','')+ ', PendOffset_AMNT = ' + ISNULL('0','') + ', PendTotOffset_AMNT = ' + ISNULL(CAST( @Ln_TotPendOffset_QNTY AS VARCHAR ),'')+ ', RecAdvance_AMNT = ' + ISNULL('0','') + ', RecTotAdvance_AMNT = ' + ISNULL('0','') + ', AssessOverpay_AMNT = ' + ISNULL('0','') + ', AssessTotOverpay_AMNT = ' + ISNULL(CAST( @Ln_TotAssessOvpy_QNTY AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Transaction_CODE = ' + ISNULL('CHSW','')+ ', TypeRecoupment_CODE = ' + ISNULL(@Lc_TypeRecoupment_CODE,'')+ ', RecoupmentPayee_CODE = ' + ISNULL(@Lc_RecoupmentPayee_CODE,'');

       INSERT POFL_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Transaction_DATE,
               TypeDisburse_CODE,
               Reason_CODE,
               PendOffset_AMNT,
               PendTotOffset_AMNT,
               RecAdvance_AMNT,
               RecTotAdvance_AMNT,
               AssessOverpay_AMNT,
               AssessTotOverpay_AMNT,
               RecOverpay_AMNT,
               RecTotOverpay_AMNT,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               EventGlobalSeq_NUMB,
               EventGlobalSupportSeq_NUMB,
               Transaction_CODE,
               TypeRecoupment_CODE,
               RecoupmentPayee_CODE)
       SELECT @Lc_ChkRecipient_ID AS CheckRecipient_ID,--CheckRecipient_ID
              @Lc_ChkRecipient_CODE AS CheckRecipient_CODE,--CheckRecipient_CODE
              fci.Case_IDNO,
              fci.OrderSeq_NUMB,
              fci.ObligationSeq_NUMB,
              @Ad_Process_DATE AS Transaction_DATE,--Transaction_DATE
              fci.TypeDisburse_CODE,
              'SW' AS Reason_CODE,--Reason_CODE
              0 AS PendOffset_AMNT,--PendOffset_AMNT
              @Ln_TotPendOffset_QNTY AS PendTotOffset_AMNT,--PendTotOffset_AMNT
              0 AS RecAdvance_AMNT,--RecAdvance_AMNT
              0 AS RecTotAdvance_AMNT,--RecTotAdvance_AMNT
              0 AS AssessOverpay_AMNT,--AssessOverpay_AMNT
              @Ln_TotAssessOvpy_QNTY AS AssessTotOverpay_AMNT,--AssessTotOverpay_AMNT
              -fci.Paid_AMNT AS RecOverpay_AMNT,
              @Ln_TotRecOvpy_QNTY - CAST(fci.cum_amt AS FLOAT) AS RecTotOverpay_AMNT,--RecTotOverpay_AMNT
              fci.Batch_DATE,
              fci.SourceBatch_CODE,
              fci.Batch_NUMB,
              fci.SeqReceipt_NUMB,
              @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
              fci.EventGlobalSupportSeq_NUMB,
              'CHSW' AS Transaction_CODE,--Transaction_CODE
              @Lc_TypeRecoupment_CODE AS TypeRecoupment_CODE,--TypeRecoupment_CODE
              @Lc_RecoupmentPayee_CODE AS RecoupmentPayee_CODE--RecoupmentPayee_CODE
         FROM (SELECT a.Case_IDNO,
                      a.OrderSeq_NUMB,
                      a.ObligationSeq_NUMB,
                      a.Batch_DATE,
                      a.SourceBatch_CODE,
                      a.Batch_NUMB,
                      a.SeqReceipt_NUMB,
                      a.EventGlobalSupportSeq_NUMB,
                      a.TypeDisburse_CODE,
                      a.Unique_IDNO,
                      a.Transaction_AMNT AS Paid_AMNT,
                      (SELECT SUM((Transaction_AMNT))
                         FROM @TempOrdeby3_P1 b
                        WHERE b.Rank_NUMB <= a.Rank_NUMB) cum_amt
                 FROM @TempOrdeby3_P1 a) AS fci;

       SET @Ls_Sql_TEXT = 'DELETE FROM @TempOrdeby3_P1';
       SET @Ls_Sqldata_TEXT = '';
       
       DELETE FROM @TempOrdeby3_P1;

       --Reduce the swapped amount to derive the current tot_recovered amount	
       SET @Ls_Sql_TEXT = 'INSERT_DUAL1';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_TotRecOvpy_QNTY = @Ln_TotRecOvpy_QNTY - (SELECT SUM(t.Transaction_AMNT)
                                                             FROM #TLHLD_P1 t
                                                            WHERE t.ProcessOffset_INDC = 'X');

       SET @Ls_Sql_TEXT = 'INSERT @TempOrderby_P1';
       SET @Ls_Sqldata_TEXT = '';

       INSERT @TempOrderby_P1
              (Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               EventGlobalSupportSeq_NUMB,
               TypeDisburse_CODE,
               Unique_IDNO,
               Swap_AMNT,
               Rank_NUMB)
       SELECT zz.Case_IDNO,
              zz.OrderSeq_NUMB,
              zz.ObligationSeq_NUMB,
              zz.Batch_DATE,
              zz.SourceBatch_CODE,
              zz.Batch_NUMB,
              zz.SeqReceipt_NUMB,
              zz.EventGlobalSupportSeq_NUMB,
              zz.TypeDisburse_CODE,
              zz.Unique_IDNO,
              zz.Swap_AMNT,
              RANK() OVER (ORDER BY zz.DisburseSubSeq_NUMB) AS Rank_NUMB
         FROM (SELECT a.Case_IDNO,
                      a.OrderSeq_NUMB,
                      a.ObligationSeq_NUMB,
                      a.Batch_DATE,
                      a.SourceBatch_CODE,
                      a.Batch_NUMB,
                      a.SeqReceipt_NUMB,
                      a.EventGlobalSupportSeq_NUMB,
                      a.TypeDisburse_CODE,
                      @Ln_Unique_IDNO AS Unique_IDNO,
                      a.Swap_AMNT,
                      a.DisburseSubSeq_NUMB
                 FROM #TLHLD_P1 a
                WHERE a.ProcessOffset_INDC = @Lc_Yes_INDC
                  AND a.Swap_AMNT > 0)zz;

       --RECEIPT SWAP : Insert the amt_rec_overpay with the backed out receipt to satisfy OD balance
       
       SET @Ls_Sql_TEXT = 'INSERT @POFL_Y1 - 1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_ChkRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_ChkRecipient_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Reason_CODE = ' + ISNULL('WP','')+ ', PendOffset_AMNT = ' + ISNULL('0','') + ', PendTotOffset_AMNT = ' + ISNULL(CAST( @Ln_TotPendOffset_QNTY AS VARCHAR ),'')+ ', RecAdvance_AMNT = ' + ISNULL('0','') + ', RecTotAdvance_AMNT = ' + ISNULL('0','') + ', AssessOverpay_AMNT = ' + ISNULL('0','') + ', AssessTotOverpay_AMNT = ' + ISNULL(CAST( @Ln_TotAssessOvpy_QNTY AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Transaction_CODE = ' + ISNULL('CHWP','')+ ', TypeRecoupment_CODE = ' + ISNULL(@Lc_TypeRecoupment_CODE,'')+ ', RecoupmentPayee_CODE = ' + ISNULL(@Lc_RecoupmentPayee_CODE,'');
       INSERT POFL_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Transaction_DATE,
               TypeDisburse_CODE,
               Reason_CODE,
               PendOffset_AMNT,
               PendTotOffset_AMNT,
               RecAdvance_AMNT,
               RecTotAdvance_AMNT,
               AssessOverpay_AMNT,
               AssessTotOverpay_AMNT,
               RecOverpay_AMNT,
               RecTotOverpay_AMNT,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               EventGlobalSeq_NUMB,
               EventGlobalSupportSeq_NUMB,
               Transaction_CODE,
               TypeRecoupment_CODE,
               RecoupmentPayee_CODE)
       SELECT @Lc_ChkRecipient_ID AS CheckRecipient_ID,--CheckRecipient_ID
              @Lc_ChkRecipient_CODE AS CheckRecipient_CODE,--CheckRecipient_CODE
              y.Case_IDNO,
              y.OrderSeq_NUMB,
              y.ObligationSeq_NUMB,
              @Ad_Process_DATE AS Transaction_DATE,--Transaction_DATE
              y.TypeDisburse_CODE,
              'WP' AS Reason_CODE,--Reason_CODE
              0 AS PendOffset_AMNT,--PendOffset_AMNT
              @Ln_TotPendOffset_QNTY AS PendTotOffset_AMNT,--PendTotOffset_AMNT
              0 AS RecAdvance_AMNT,--RecAdvance_AMNT
              0 AS RecTotAdvance_AMNT,--RecTotAdvance_AMNT
              0 AS AssessOverpay_AMNT,--AssessOverpay_AMNT
              @Ln_TotAssessOvpy_QNTY AS AssessTotOverpay_AMNT,--AssessTotOverpay_AMNT
              y.Swap_AMNT,
              @Ln_TotRecOvpy_QNTY + CAST(y.cum_amt AS FLOAT) AS RecTotOverpay_AMNT,--RecTotOverpay_AMNT
              y.Batch_DATE,
              y.SourceBatch_CODE,
              y.Batch_NUMB,
              y.SeqReceipt_NUMB,
              @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
              y.EventGlobalSupportSeq_NUMB,
              'CHWP' AS Transaction_CODE,--Transaction_CODE
              @Lc_TypeRecoupment_CODE AS TypeRecoupment_CODE,--TypeRecoupment_CODE
              @Lc_RecoupmentPayee_CODE AS RecoupmentPayee_CODE--RecoupmentPayee_CODE
         FROM (SELECT a.Case_IDNO,
                      a.OrderSeq_NUMB,
                      a.ObligationSeq_NUMB,
                      a.Batch_DATE,
                      a.SourceBatch_CODE,
                      a.Batch_NUMB,
                      a.SeqReceipt_NUMB,
                      a.EventGlobalSupportSeq_NUMB,
                      a.TypeDisburse_CODE,
                      a.Unique_IDNO,
                      a.Swap_AMNT,
                      (SELECT SUM((Swap_AMNT))
                         FROM @TempOrderby_P1 b
                        WHERE b.Rank_NUMB <= a.Rank_NUMB) cum_amt
                 FROM @TempOrderby_P1 a) AS y;

       SET @Ls_Sql_TEXT = 'DELETE FROM @TempOrderby_P1';
       SET @Ls_Sqldata_TEXT = '';
       
       DELETE FROM @TempOrderby_P1;
      END
     END

     --Not Backed-out Receipts. Insert as Check Holds
     SET @Ls_Sql_TEXT = 'INSERT VDHLD1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','') + ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(' ','');

     INSERT DHLD_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Disburse_DATE,
             DisburseSeq_NUMB,
             Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalSupportSeq_NUMB,
             TypeDisburse_CODE,
             Transaction_DATE,
             Release_DATE,
             Transaction_AMNT,
             Status_CODE,
             TypeHold_CODE,
             ReasonStatus_CODE,
             ProcessOffset_INDC,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
     SELECT @Ac_CheckRecipient_ID AS CheckRecipient_ID,--CheckRecipient_ID
            @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,--CheckRecipient_CODE
            @Ad_Disburse_DATE AS Disburse_DATE,--Disburse_DATE
            @An_DisburseSeq_NUMB AS DisburseSeq_NUMB,--DisburseSeq_NUMB
            t.Case_IDNO,
            t.OrderSeq_NUMB,
            t.ObligationSeq_NUMB,
            t.Batch_DATE,
            t.SourceBatch_CODE,
            t.Batch_NUMB,
            t.SeqReceipt_NUMB,
            t.EventGlobalSupportSeq_NUMB,
            t.TypeDisburse_CODE,
            @Ad_Process_DATE AS Transaction_DATE,--Transaction_DATE
            CASE
             WHEN @Ac_StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE)
              THEN @Ld_High_DATE
             ELSE @Ad_Process_DATE
            END AS Release_DATE,--Release_DATE
            t.Transaction_AMNT,
            CASE
             WHEN @Ac_StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE)
              THEN @Lc_StatusReceiptHeld_CODE
             ELSE @Lc_StatusReceiptRefunded_CODE
            END AS Status_CODE,--Status_CODE
            CASE
             WHEN @Ac_StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
              THEN
              CASE
               WHEN @Ac_ReasonStatus_CODE IN (@Lc_VsrStatusRetfrmpostoffice_CODE, @Lc_VsrStatusBadaddress_CODE)
                THEN @Lc_Hold_ADDR
               WHEN @Ac_StatusCheck_CODE = @Lc_DisburseStatusRejectedEft_CODE AND @Ac_CheckRecipient_CODE <> @Lc_RecipientTypeCpNcp_CODE
				THEN @Lc_HoldR_ADDR
               ELSE @Lc_CheckHold_CODE
              END
             ELSE @Lc_CheckHold_CODE
            END AS TypeHold_CODE,--TypeHold_CODE
            CASE
             WHEN @Ac_StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE)
              THEN
              CASE
               WHEN @Ac_ReasonStatus_CODE IN (@Lc_VsrStatusRetfrmpostoffice_CODE, @Lc_VsrStatusBadaddress_CODE)
                THEN ISNULL(@Lc_SystemDisbursment_TEXT, '') + ISNULL(CASE @Ac_CheckRecipient_CODE
                                                                      WHEN @Lc_RecipientTypeFips_CODE
                                                                       THEN @Lc_FipsNonExistingAddress_CODE
                                                                      WHEN @Lc_RecipientTypeOthp_CODE
                                                                       THEN @Lc_OthpNonExisting_ADDR
                                                                      ELSE
                                                                       CASE t.TypeDisburse_CODE
                                                                        WHEN @Lc_DisbursementTypeRefund_CODE
                                                                         THEN @Lc_NcpBad_ADDR
                                                                        ELSE @Lc_DisburseStatusCashed_CODE
                                                                       END
                                                                     END, '')
               WHEN (@Ac_Prog_IDNO = @Lc_ProgStale_IDNO
                     AND @Ac_ReasonStatus_CODE = @Lc_DisbursementPendingEsch_TEXT
                     AND @Ac_StatusCheck_CODE = @Lc_DisburseStatusVoidNoReissue_CODE)
                THEN @Lc_SystemEscheatmentPending_TEXT
               ELSE ISNULL(CASE
                            WHEN @Ac_Prog_IDNO IN (@Lc_ProgStale_IDNO)
                             THEN @Lc_System_CODE
                            ELSE @Lc_Manual_CODE
                           END, '') + ISNULL(SUBSTRING(@Ac_StatusCheck_CODE, 1, 1), '') + ISNULL (@Ac_ReasonStatus_CODE, '')
              END
             WHEN @Ac_StatusCheck_CODE = @Lc_DisburseStatusRejectedEft_CODE AND @Ac_CheckRecipient_CODE <> @Lc_RecipientTypeCpNcp_CODE
             THEN @Lc_EftRejectForFipsOrOthp_CODE 
             ELSE @Lc_ReadyDisbursement_TEXT
            END AS ReasonStatus_CODE,--ReasonStatus_CODE
            @Lc_No_INDC AS ProcessOffset_INDC,--ProcessOffset_INDC
            @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0 AS EventGlobalEndSeq_NUMB,--EventGlobalEndSeq_NUMB
            @Ad_Process_DATE AS BeginValidity_DATE,--BeginValidity_DATE
            @Ld_High_DATE AS EndValidity_DATE,--EndValidity_DATE
            @Ld_High_DATE AS StatusEscheat_DATE,--StatusEscheat_DATE
            ' ' AS StatusEscheat_CODE --StatusEscheat_CODE
       FROM #TLHLD_P1 t
      WHERE t.ProcessOffset_INDC = @Lc_No_INDC;

     --Receipt swap records. Insert as Regular Holds.
     SET @Ls_Sql_TEXT = 'INSERT_VDHLD2';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_Ready4Disbursement_CODE,'')+ ', TypeHold_CODE = ' + ISNULL('D','')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReadyDisbursement_TEXT,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','') + ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL('','');

     INSERT DHLD_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Disburse_DATE,
             DisburseSeq_NUMB,
             Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalSupportSeq_NUMB,
             TypeDisburse_CODE,
             Transaction_DATE,
             Release_DATE,
             Transaction_AMNT,
             Status_CODE,
             TypeHold_CODE,
             ReasonStatus_CODE,
             ProcessOffset_INDC,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
     SELECT @Ac_CheckRecipient_ID AS CheckRecipient_ID,--CheckRecipient_ID
            @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,--CheckRecipient_CODE
            @Ad_Disburse_DATE AS Disburse_DATE,--Disburse_DATE
            @An_DisburseSeq_NUMB AS DisburseSeq_NUMB,--DisburseSeq_NUMB
            fci.Case_IDNO,
            fci.OrderSeq_NUMB,
            fci.ObligationSeq_NUMB,
            fci.Batch_DATE,
            fci.SourceBatch_CODE,
            fci.Batch_NUMB,
            fci.SeqReceipt_NUMB,
            fci.EventGlobalSupportSeq_NUMB,
            fci.TypeDisburse_CODE,
            @Ad_Process_DATE AS Transaction_DATE,--Transaction_DATE
            @Ad_Process_DATE AS Release_DATE,--Release_DATE
            fci.Transaction_AMNT,
            @Lc_Ready4Disbursement_CODE AS Status_CODE,--Status_CODE
            'D' AS TypeHold_CODE,--TypeHold_CODE
            @Lc_ReadyDisbursement_TEXT AS ReasonStatus_CODE,--ReasonStatus_CODE
            @Lc_No_INDC AS ProcessOffset_INDC,--ProcessOffset_INDC
            @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0 AS EventGlobalEndSeq_NUMB,--EventGlobalEndSeq_NUMB
            @Ad_Process_DATE AS BeginValidity_DATE,--BeginValidity_DATE
            @Ld_High_DATE AS EndValidity_DATE,--EndValidity_DATE
            @Ld_High_DATE AS StatusEscheat_DATE,--StatusEscheat_DATE
            '' AS StatusEscheat_CODE
       FROM (SELECT a.Case_IDNO,
                    a.OrderSeq_NUMB,
                    a.ObligationSeq_NUMB,
                    a.Batch_DATE,
                    a.SourceBatch_CODE,
                    a.Batch_NUMB,
                    a.SeqReceipt_NUMB,
                    a.EventGlobalSupportSeq_NUMB,
                    a.TypeDisburse_CODE,
                    SUM(a.Transaction_AMNT) OVER(PARTITION BY a.Unique_IDNO) AS Transaction_AMNT,
                    ROW_NUMBER() OVER(PARTITION BY a.Unique_IDNO ORDER BY a.DisburseSubSeq_NUMB) AS row_num
               FROM #TLHLD_P1 a
              WHERE a.ProcessOffset_INDC = 'X') AS fci
      WHERE fci.row_num = 1;

	 --Backed out receipts - Not able to adjust OD or do receipt swap
     SET @Ls_Sql_TEXT = 'INSERT VDHLD3';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_BackOut_INDC,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_CheckHold_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL('','');

     INSERT DHLD_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Disburse_DATE,
             DisburseSeq_NUMB,
             Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalSupportSeq_NUMB,
             TypeDisburse_CODE,
             Transaction_DATE,
             Release_DATE,
             Transaction_AMNT,
             Status_CODE,
             TypeHold_CODE,
             ReasonStatus_CODE,
             ProcessOffset_INDC,
             --Unique_IDNO, 
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
     SELECT @Ac_CheckRecipient_ID AS CheckRecipient_ID,--CheckRecipient_ID
            @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,--CheckRecipient_CODE
            @Ad_Disburse_DATE AS Disburse_DATE,--Disburse_DATE
            @An_DisburseSeq_NUMB AS DisburseSeq_NUMB,--DisburseSeq_NUMB
            t.Case_IDNO,
            t.OrderSeq_NUMB,
            t.ObligationSeq_NUMB,
            t.Batch_DATE,
            t.SourceBatch_CODE,
            t.Batch_NUMB,
            t.SeqReceipt_NUMB,
            t.EventGlobalSupportSeq_NUMB,
            t.TypeDisburse_CODE,
            @Ad_Process_DATE AS Transaction_DATE,--Transaction_DATE
            @Ld_High_DATE AS Release_DATE,--Release_DATE
            (t.Transaction_AMNT - t.Paid_AMNT - t.Swap_AMNT) AS Transaction_AMNT,--Transaction_AMNT
            @Lc_BackOut_INDC AS Status_CODE,--Status_CODE
            @Lc_CheckHold_CODE AS TypeHold_CODE,--TypeHold_CODE
            CASE
             WHEN @Ac_StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE)
              THEN
              CASE
               WHEN @Ac_ReasonStatus_CODE IN (@Lc_VsrStatusRetfrmpostoffice_CODE, @Lc_VsrStatusBadaddress_CODE)
                THEN ISNULL(@Lc_SystemDisbursment_TEXT, '') + ISNULL(CASE @Ac_CheckRecipient_CODE
                                                                      WHEN @Lc_RecipientTypeFips_CODE
                                                                       THEN @Lc_FipsNonExistingAddress_CODE
                                                                      WHEN @Lc_RecipientTypeOthp_CODE
                                                                       THEN @Lc_OthpNonExisting_ADDR
                                                                      ELSE
                                                                       CASE t.TypeDisburse_CODE
                                                                        WHEN @Lc_DisbursementTypeRefund_CODE
                                                                         THEN @Lc_NcpBad_ADDR
                                                                        ELSE @Lc_DisburseStatusCashed_CODE
                                                                       END
                                                                     END, '')
               WHEN (@Ac_Prog_IDNO = @Lc_ProgStale_IDNO
                     AND @Ac_ReasonStatus_CODE = @Lc_DisbursementPendingEsch_TEXT
                     AND @Ac_StatusCheck_CODE = @Lc_DisburseStatusVoidNoReissue_CODE)
                THEN @Lc_SystemEscheatmentPending_TEXT
               ELSE ISNULL(CASE
                            WHEN @Ac_Prog_IDNO IN (@Lc_ProgStale_IDNO)
                             THEN @Lc_System_CODE
                            ELSE @Lc_Manual_CODE
                           END, '') + ISNULL(SUBSTRING(@Ac_StatusCheck_CODE, 1, 1), '') + ISNULL (@Ac_ReasonStatus_CODE, '')
              END
             ELSE @Lc_ReadyDisbursement_TEXT
            END AS ReasonStatus_CODE,--ReasonStatus_CODE
            @Lc_No_INDC AS ProcessOffset_INDC,--ProcessOffset_INDC
            @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            @An_EventGlobalSeq_NUMB AS EventGlobalEndSeq_NUMB,--EventGlobalEndSeq_NUMB
            @Ad_Process_DATE AS BeginValidity_DATE,--BeginValidity_DATE
            @Ad_Process_DATE AS EndValidity_DATE,--EndValidity_DATE
            @Ld_High_DATE AS StatusEscheat_DATE,-- StatusEscheat_DATE
            '' AS StatusEscheat_CODE
       FROM #TLHLD_P1 t
      WHERE t.ProcessOffset_INDC = @Lc_Yes_INDC
        AND (t.Transaction_AMNT - t.Paid_AMNT - t.Swap_AMNT) > 0;

     SET @Ls_Sql_TEXT = 'SELECT TLHLD_Y1';
     SET @Ls_Sqldata_TEXT = 'ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC,'');

     SELECT @An_TransactionDhld_AMNT = ISNULL(SUM(t.Transaction_AMNT), 0)
       FROM #TLHLD_P1 t
      WHERE t.ProcessOffset_INDC = @Lc_No_INDC;

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
   
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END


GO
