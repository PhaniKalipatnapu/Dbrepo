/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_REVERSE_DIST_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_REVERSE_DIST_RECEIPT
Programmer Name		: IMP Team
Description			: This procedure is used for Reverting distribution for a given receipt.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_REVERSE_DIST_RECEIPT]
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_INDC                              CHAR(1) = 'Y',
          @Lc_No_INDC                               CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE                    CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                     CHAR(1) = 'F',
          @Lc_DisburseStatusCheckRejectedEft_CODE   CHAR(2) = 'RE',
          @Lc_DisburseStatusCheckVoidNoReissue_CODE CHAR(2) = 'VN',
          @Lc_DisburseStatusCheckVoidReissue_CODE   CHAR(2) = 'VR',
          @Lc_DisburseStatusCheckStopNoReissue_CODE CHAR(2) = 'SN',
          @Lc_DisburseStatusCheckStopReissue_CODE   CHAR(2) = 'SR',
          @Lc_JobDeb0560_ID                         CHAR(7) = 'DEB0560',
          @Ls_Routine_TEXT                          VARCHAR(60) = 'BATCH_COMMON$SP_REVERSE_DIST_RECEIPT',
          @Ld_High_DATE                             DATE = '12/31/9999',
          @Ld_Low_DATE                              DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_QNTY                  NUMERIC(9, 0),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB   NUMERIC(19),
          @Lc_Msg_CODE              CHAR(1),
          @Lc_DelStatus_CODE        CHAR(1),
          @Lc_ReceiptFailed_INDC    CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ReceiptAmount_TEXT    VARCHAR(2000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ln_QNTY = COUNT (1)
     FROM RCTH_Y1 b
    WHERE b.Batch_DATE = @Ad_Batch_DATE
      AND b.Batch_NUMB = @An_Batch_NUMB
      AND b.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND b.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND b.BackOut_INDC = @Lc_Yes_INDC
      AND b.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_QNTY > 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'RCTH_Y1 REVERSED';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT DSBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

   SELECT @Ln_QNTY = COUNT (1)
     FROM DSBL_Y1 d
    WHERE d.Batch_DATE = @Ad_Batch_DATE
      AND d.Batch_NUMB = @An_Batch_NUMB
      AND d.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND d.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND d.Disburse_DATE = @Ad_Run_DATE;

   IF @Ln_QNTY > 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'RCTH_Y1 DISBURSED';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT POFL_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

   SELECT @Ln_QNTY = COUNT (1)
     FROM POFL_Y1 p
    WHERE p.Batch_DATE = @Ad_Batch_DATE
      AND p.Batch_NUMB = @An_Batch_NUMB
      AND p.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND p.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND p.Transaction_DATE = @Ad_Run_DATE;

   IF @Ln_QNTY > 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'RCTH_Y1 USED FOR RECOUPMENT';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT LSUP_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Process_ID = ' + ISNULL(@Lc_JobDeb0560_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT DISTINCT
          @Lc_DelStatus_CODE = ISNULL ((SELECT TOP 1 @Lc_No_INDC
                                          FROM LSUP_Y1 l
                                         WHERE l.Case_IDNO = a.Case_IDNO
                                           AND l.EventGlobalSeq_NUMB > a.EventGlobalSeq_NUMB), @Lc_Yes_INDC),
          @Ln_EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.EventGlobalSeq_NUMB IN (SELECT g.EventGlobalSeq_NUMB
                                      FROM GLEV_Y1 g
                                     WHERE g.Process_ID = @Lc_JobDeb0560_ID
                                       AND g.EffectiveEvent_DATE = @Ad_Run_DATE)
      AND NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND b.BackOut_INDC = @Lc_Yes_INDC
                         AND b.EndValidity_DATE = @Ld_High_DATE);

   IF @Lc_DelStatus_CODE = @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE RCTH_Y1 DIST';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_JobDeb0560_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

     DELETE RCTH_Y1
       FROM RCTH_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.EventGlobalEndSeq_NUMB = 0
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.EventGlobalBeginSeq_NUMB IN (SELECT GLEV_Y1.EventGlobalSeq_NUMB
                                             FROM GLEV_Y1
                                            WHERE GLEV_Y1.Process_ID = @Lc_JobDeb0560_ID
                                              AND GLEV_Y1.EffectiveEvent_DATE = @Ad_Run_DATE);

     SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1 DIST';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Process_ID = ' + ISNULL(@Lc_JobDeb0560_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ld_High_DATE,
            EventGlobalEndSeq_NUMB = 0
      WHERE RCTH_Y1.Batch_DATE = @Ad_Batch_DATE
        AND RCTH_Y1.Batch_NUMB = @An_Batch_NUMB
        AND RCTH_Y1.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND RCTH_Y1.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND RCTH_Y1.EventGlobalEndSeq_NUMB IN (SELECT GLEV_Y1.EventGlobalSeq_NUMB
                                                 FROM GLEV_Y1
                                                WHERE GLEV_Y1.Process_ID = @Lc_JobDeb0560_ID
                                                  AND GLEV_Y1.EffectiveEvent_DATE = @Ad_Run_DATE);

     SET @Ls_Sql_TEXT = 'DELETE LSUP_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');

     DELETE LSUP_Y1
      WHERE LSUP_Y1.Batch_DATE = @Ad_Batch_DATE
        AND LSUP_Y1.Batch_NUMB = @An_Batch_NUMB
        AND LSUP_Y1.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND LSUP_Y1.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND LSUP_Y1.Distribute_DATE = @Ad_Run_DATE
        AND LSUP_Y1.EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Ls_Sql_TEXT = 'DELETE DHLD_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');

     DELETE DHLD_Y1
      WHERE DHLD_Y1.Batch_DATE = @Ad_Batch_DATE
        AND DHLD_Y1.Batch_NUMB = @An_Batch_NUMB
        AND DHLD_Y1.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND DHLD_Y1.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND DHLD_Y1.Transaction_DATE = @Ad_Run_DATE
        AND DHLD_Y1.EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Ls_Sql_TEXT = 'DELETE ESEM_Y1';
     SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');

     DELETE ESEM_Y1
      WHERE ESEM_Y1.EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CREATE_RCTH_HOLD';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

     EXECUTE BATCH_COMMON$SP_CREATE_RCTH_HOLD
      @Ad_Batch_DATE            = @Ad_Batch_DATE,
      @Ac_SourceBatch_CODE      = @Ac_SourceBatch_CODE,
      @An_Batch_NUMB            = @An_Batch_NUMB,
      @An_SeqReceipt_NUMB       = @An_SeqReceipt_NUMB,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'ASSINING RECEIPT AMOUNT';
     SET @Ls_Sqldata_TEXT = '';
     
     SELECT @Ls_ReceiptAmount_TEXT = ISNULL (CAST (d.Receipt_AMNT AS NVARCHAR (12)), '') + '=' + 'amt_dist_hold :=' + ISNULL (CAST (d.amt_dist_hold AS NVARCHAR (12)), '') + 'amt_disb_hold :=' + ISNULL (CAST (d.amt_disb_hold AS NVARCHAR (12)), '') + 'amt_recovered := ' + ISNULL (CAST (d.amt_recovered AS NVARCHAR (12)), '') + 'amt_disbursed :=' + ISNULL (CAST (d.amt_disbursed AS NVARCHAR (12)), '') + 'amt_ready_to_disb:= ' + ISNULL (CAST (d.amt_ready_to_disb AS NVARCHAR (12)), '')
       FROM (SELECT x.Batch_DATE,
                    x.Batch_NUMB,
                    x.SourceBatch_CODE,
                    x.SeqReceipt_NUMB,
                    x.SourceReceipt_CODE,
                    x.Receipt_AMNT,
                    x.amt_dist_hold,
                    x.amt_distributed_rcth,
                    (SELECT ISNULL (SUM (y.TransactionNaa_AMNT + y.TransactionPaa_AMNT + y.TransactionTaa_AMNT + y.TransactionCaa_AMNT + y.TransactionUpa_AMNT + y.TransactionUda_AMNT + y.TransactionIvef_AMNT + y.TransactionMedi_AMNT + y.TransactionNffc_AMNT + y.TransactionNonIvd_AMNT), 0)
                       FROM LSUP_Y1 y
                      WHERE x.Batch_DATE = y.Batch_DATE
                        AND x.Batch_NUMB = y.Batch_NUMB
                        AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                        AND x.SourceBatch_CODE = y.SourceBatch_CODE
                        AND y.TypeRecord_CODE = 'O') AS amt_distributed_lsup,
                    (SELECT ISNULL (SUM (y.Transaction_AMNT), 0)
                       FROM DHLD_Y1 y
                      WHERE x.Batch_DATE = y.Batch_DATE
                        AND x.Batch_NUMB = y.Batch_NUMB
                        AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                        AND x.SourceBatch_CODE = y.SourceBatch_CODE
                        AND y.Status_CODE = 'H'
                        AND y.EndValidity_DATE = @Ld_High_DATE) AS amt_disb_hold,
                    (SELECT ISNULL (SUM (y.Transaction_AMNT), 0)
                       FROM DHLD_Y1 y
                      WHERE x.Batch_DATE = y.Batch_DATE
                        AND x.Batch_NUMB = y.Batch_NUMB
                        AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                        AND x.SourceBatch_CODE = y.SourceBatch_CODE
                        AND y.Status_CODE = 'R'
                        AND y.EndValidity_DATE = @Ld_High_DATE) AS amt_ready_to_disb,
                    (SELECT ISNULL (SUM (y.RecOverpay_AMNT), 0)
                       FROM POFL_Y1 y
                      WHERE x.Batch_DATE = y.Batch_DATE
                        AND x.Batch_NUMB = y.Batch_NUMB
                        AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                        AND x.SourceBatch_CODE = y.SourceBatch_CODE) AS amt_recovered,
                    (SELECT ISNULL (SUM (y.Disburse_AMNT), 0)
                       FROM DSBL_Y1 y,
                            DSBH_Y1 z
                      WHERE x.Batch_DATE = y.Batch_DATE
                        AND x.Batch_NUMB = y.Batch_NUMB
                        AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                        AND x.SourceBatch_CODE = y.SourceBatch_CODE
                        AND y.CheckRecipient_ID = z.CheckRecipient_ID
                        AND y.CheckRecipient_CODE = z.CheckRecipient_CODE
                        AND y.Disburse_DATE = z.Disburse_DATE
                        AND y.DisburseSeq_NUMB = z.DisburseSeq_NUMB
                        AND z.StatusCheck_CODE NOT IN (@Lc_DisburseStatusCheckRejectedEft_CODE, @Lc_DisburseStatusCheckVoidNoReissue_CODE, @Lc_DisburseStatusCheckVoidReissue_CODE, @Lc_DisburseStatusCheckStopNoReissue_CODE, @Lc_DisburseStatusCheckStopReissue_CODE)
                        AND z.EndValidity_DATE = @Ld_High_DATE) AS amt_disbursed
               FROM (SELECT a.Batch_DATE,
                            a.Batch_NUMB,
                            a.SourceBatch_CODE,
                            a.SeqReceipt_NUMB,
                            a.SourceReceipt_CODE,
                            a.Receipt_AMNT,
                            (SELECT ISNULL (SUM (c.ToDistribute_AMNT), 0)
                               FROM RCTH_Y1 c
                              WHERE a.Batch_DATE = c.Batch_DATE
                                AND a.Batch_NUMB = c.Batch_NUMB
                                AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                AND c.Distribute_DATE != @Ld_Low_DATE
                                AND c.EndValidity_DATE = @Ld_High_DATE) AS amt_distributed_rcth,
                            (SELECT ISNULL (SUM (c.ToDistribute_AMNT), 0)
                               FROM RCTH_Y1 c
                              WHERE a.Batch_DATE = c.Batch_DATE
                                AND a.Batch_NUMB = c.Batch_NUMB
                                AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                AND c.Distribute_DATE = @Ld_Low_DATE
                                AND c.EndValidity_DATE = @Ld_High_DATE) AS amt_dist_hold
                       FROM (SELECT a.Batch_DATE,
                                    a.Batch_NUMB,
                                    a.SourceBatch_CODE,
                                    a.SeqReceipt_NUMB,
                                    a.SourceReceipt_CODE,
                                    a.Receipt_AMNT,
                                    ROW_NUMBER () OVER ( PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SourceBatch_CODE, a.SeqReceipt_NUMB ORDER BY a.Batch_DATE, a.Batch_NUMB, a.SourceBatch_CODE, a.SeqReceipt_NUMB, a.EventGlobalBeginSeq_NUMB) AS rown
                               FROM RCTH_Y1 a
                              WHERE a.EndValidity_DATE = @Ld_High_DATE
                                AND a.Batch_DATE = @Ad_Batch_DATE
                                AND a.Batch_NUMB = @An_Batch_NUMB
                                AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
                                AND NOT EXISTS (SELECT 1
                                                  FROM RCTH_Y1 b
                                                 WHERE a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND b.BackOut_INDC = @Lc_Yes_INDC
                                                   AND b.EndValidity_DATE = @Ld_High_DATE)) AS a
                      WHERE a.rown = 1) AS x) AS d
      WHERE d.Receipt_AMNT != CAST (d.amt_dist_hold AS NUMERIC (11, 2)) + CAST (d.amt_disb_hold AS NUMERIC (11, 2)) + CAST (d.amt_recovered AS NUMERIC (11, 2)) + CAST (d.amt_disbursed AS NUMERIC (11, 2)) + CAST (d.amt_ready_to_disb AS NUMERIC (11, 2));

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Lc_ReceiptFailed_INDC = @Lc_No_INDC;
      END
     ELSE
      BEGIN
       SET @Lc_ReceiptFailed_INDC = @Lc_Yes_INDC;
      END

     IF @Lc_ReceiptFailed_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'RCTH_Y1 VALIDATION FAILED' + '-' + ISNULL (@Ls_ReceiptAmount_TEXT, '');

       RAISERROR (50001,16,1);
      END
     ELSE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
       SET @As_DescriptionError_TEXT = 'VALIDATION SUCCESS';
      END
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
