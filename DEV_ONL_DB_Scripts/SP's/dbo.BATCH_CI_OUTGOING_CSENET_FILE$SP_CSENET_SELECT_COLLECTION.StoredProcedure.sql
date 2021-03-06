/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_COLLECTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_COLLECTION
Programmer Name	:	IMP Team.
Description		:	This procedure loads all collection data in to extract_collection_data_blocks table for each row of pending_request table
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INIT_TRAN
Called On		:	
----------------------------------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
-------------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_COLLECTION]
 @An_Case_IDNO             NUMERIC(6),
 @An_TransHeader_IDNO      NUMERIC(12),
 @Ai_Collection_QNTY       INTEGER OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ErrorLine_NUMB                   INT = 0,
          @Lc_Yes_INDC                         CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE                CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
          @Lc_ReceiptSrcHomesteadRebate_CODE   CHAR(2) = 'SQ',
          @Lc_ReceiptSrcStateTaxRefund_CODE    CHAR(2) = 'ST',
          @Lc_ReceiptSrcSaverRebate_CODE       CHAR(2) = 'SS',
          @Lc_DisburseStatusVoidReissue_CODE   CHAR(2) = 'VR',
          @Lc_DisburseStatusVoidNoReissue_CODE CHAR(2) = 'VN',
          @Lc_DisburseStatusStopNoReissue_CODE CHAR(2) = 'SN',
          @Lc_DisburseStatusStopReissue_CODE   CHAR(2) = 'SR',
          @Lc_DisburseStatusRejectedEft_CODE   CHAR(2) = 'RE',
          @Lc_ReceiptSrcSpecialCollection_CODE CHAR(2) = 'SC',
          @Lc_SpecialCollection_CODE           CHAR(3) = 'SPC',
          @Lc_Refund_TEXT                      CHAR(5) = 'REFND',
          @Lc_Rdfi_ID                          CHAR(20) = ' ',
          @Lc_RdfiAcctNo_TEXT                  CHAR(20) = ' ',
          @Ls_Procedure_NAME                   VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_COLLECTION',
          @Ld_Low_DATE                         DATE = '01/01/0001',
          @Ld_High_DATE                        DATE = '12/31/9999';
  DECLARE @Ln_Payment_AMNT          NUMERIC(11, 2) = 0,
          @Li_Error_NUMB            INT = 0,
          @Li_FetchStatus_NUMB      INT,
          @Li_Col_QNTY              SMALLINT = 0,
          @Lc_OthStateFips_CODE     CHAR(2),
          @Ls_Sql_TEXT              VARCHAR(2000),
          @Ls_Sqldata_TEXT          VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Generated_DATE        DATE;
  DECLARE @Ld_SelectColCur_Batch_DATE         DATE,
          @Lc_SelectColCur_SourceBatch_CODE   CHAR(3),
          @Ln_SelectColCur_Batch_NUMB         NUMERIC(4),
          @Ln_SelectColCur_SeqReceipt_NUMB    NUMERIC(6),
          @Ld_SelectColCur_Receipt_DATE       DATE,
          @Lc_SelectColCur_SourceReceipt_CODE CHAR(2),
		  @Lc_SelectColCur_TypeRemittance_ID  CHAR(3),
          @Ln_SelectColCur_Receipt_AMNT       NUMERIC(11, 2);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 - NCP data Block ' + CAST(@An_Case_IDNO AS VARCHAR);
   SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_OthStateFips_CODE = a.IVDOutOfStateFips_CODE,
          @Ld_Generated_DATE = a.Generated_DATE
     FROM CSPR_Y1 a
    WHERE a.Request_IDNO = CAST(@An_TransHeader_IDNO AS NUMERIC(12))
      AND a.EndValidity_DATE = @Ld_High_DATE;

   -- Collection block should send Disbursed amount instead of receipt amount
   DECLARE SelectCol_CUR INSENSITIVE CURSOR FOR
    SELECT fci.Batch_DATE,
           fci.SourceBatch_CODE,
           fci.Batch_NUMB,
           fci.SeqReceipt_NUMB,
           fci.Receipt_DATE,
           fci.SourceReceipt_CODE,
		   fci.TypeRemittance_CODE,
           SUM(CAST(Receipt_AMNT AS NUMERIC(11, 2))) AS Receipt_AMNT
      FROM (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   x.Receipt_DATE,
                   x.SourceReceipt_CODE,
				   x.TypeRemittance_CODE,
                   a.Receipt_AMNT
              FROM (SELECT a.Batch_DATE,
                           a.SourceBatch_CODE,
                           a.Batch_NUMB,
                           a.SeqReceipt_NUMB,
                           a.Disburse_AMNT AS Receipt_AMNT
                      FROM DSBL_Y1 a,
                           DSBH_Y1 b
                     WHERE a.Case_IDNO = @An_Case_IDNO
                       AND a.Disburse_DATE BETWEEN @Ld_Generated_DATE AND CONVERT(DATE, (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), 102)
                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                       AND a.Disburse_DATE = b.Disburse_DATE
                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                       AND b.EndValidity_DATE = @Ld_High_DATE
                       AND a.TypeDisburse_CODE != @Lc_Refund_TEXT
                       AND b.StatusCheck_CODE NOT IN (@Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                       --AND a.SourceBatch_CODE = @Lc_SpecialCollection_CODE
					   AND EXISTS (SELECT 1
                                     FROM RCTH_Y1 i
                                    WHERE a.Batch_DATE = i.Batch_DATE
                                      AND a.SourceBatch_CODE = i.SourceBatch_CODE
                                      AND a.Batch_NUMB = i.Batch_NUMB
                                      AND a.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                      AND i.SourceReceipt_CODE IN (@Lc_ReceiptSrcSpecialCollection_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE)
                                      AND i.EndValidity_DATE = @Ld_High_DATE)
                       AND NOT EXISTS (SELECT 1
                                         FROM RCTH_Y1 i
                                        WHERE a.Batch_DATE = i.Batch_DATE
                                          AND a.SourceBatch_CODE = i.SourceBatch_CODE
                                          AND a.Batch_NUMB = i.Batch_NUMB
                                          AND a.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                          AND i.BackOut_INDC = @Lc_Yes_INDC
                                          AND i.EndValidity_DATE = @Ld_High_DATE)
                    UNION ALL
                    SELECT a.Batch_DATE,
                           a.SourceBatch_CODE,
                           a.Batch_NUMB,
                           a.SeqReceipt_NUMB,
                           a.Disburse_AMNT * -1 AS Receipt_AMNT
                      FROM DSBL_Y1 a,
                           DSBH_Y1 b
                     WHERE a.Case_IDNO = @An_Case_IDNO
                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                       AND a.Disburse_DATE = b.Disburse_DATE
                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                       --AND a.SourceBatch_CODE = @Lc_SpecialCollection_CODE
					   AND EXISTS (SELECT 1
                                     FROM RCTH_Y1 i
                                    WHERE a.Batch_DATE = i.Batch_DATE
                                      AND a.SourceBatch_CODE = i.SourceBatch_CODE
                                      AND a.Batch_NUMB = i.Batch_NUMB
                                      AND a.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                      AND i.SourceReceipt_CODE IN (@Lc_ReceiptSrcSpecialCollection_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE)
                                      AND i.EndValidity_DATE = @Ld_High_DATE)
                       AND a.TypeDisburse_CODE != @Lc_Refund_TEXT
                       AND b.Disburse_DATE < @Ld_Generated_DATE
                       AND b.BeginValidity_DATE BETWEEN @Ld_Generated_DATE AND CONVERT(DATE, (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), 102)
                       AND b.EndValidity_DATE = @Ld_High_DATE
                       AND b.StatusCheck_CODE IN (@Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                       AND NOT EXISTS (SELECT 1
                                         FROM RCTH_Y1 i
                                        WHERE a.Batch_DATE = i.Batch_DATE
                                          AND a.SourceBatch_CODE = i.SourceBatch_CODE
                                          AND a.Batch_NUMB = i.Batch_NUMB
                                          AND a.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                          AND i.BackOut_INDC = @Lc_Yes_INDC
                                          AND i.EndValidity_DATE = @Ld_High_DATE)
                    UNION ALL
                    SELECT a.Batch_DATE,
                           a.SourceBatch_CODE,
                           a.Batch_NUMB,
                           a.SeqReceipt_NUMB,
                           a.RecOverpay_AMNT AS Receipt_AMNT
                      FROM POFL_Y1 a
                     WHERE a.Case_IDNO = @An_Case_IDNO
                       --AND a.SourceBatch_CODE = @Lc_SpecialCollection_CODE
					   AND EXISTS (SELECT 1
                                     FROM RCTH_Y1 i
                                    WHERE a.Batch_DATE = i.Batch_DATE
                                      AND a.SourceBatch_CODE = i.SourceBatch_CODE
                                      AND a.Batch_NUMB = i.Batch_NUMB
                                      AND a.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                      AND i.SourceReceipt_CODE IN (@Lc_ReceiptSrcSpecialCollection_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE)
                                      AND i.EndValidity_DATE = @Ld_High_DATE)
                       AND a.Transaction_DATE BETWEEN @Ld_Generated_DATE AND CONVERT(DATE, (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), 102)
                    UNION ALL
                    SELECT a.Batch_DATE,
                           a.SourceBatch_CODE,
                           a.Batch_NUMB,
                           a.SeqReceipt_NUMB,
                           (a.PendOffset_AMNT + a.AssessOverpay_AMNT) * -1 AS Receipt_AMNT
                      FROM POFL_Y1 a
                     WHERE a.Case_IDNO = @An_Case_IDNO
                       --AND a.SourceBatch_CODE = @Lc_SpecialCollection_CODE
					   AND EXISTS (SELECT 1
                                     FROM RCTH_Y1 i
                                    WHERE a.Batch_DATE = i.Batch_DATE
                                      AND a.SourceBatch_CODE = i.SourceBatch_CODE
                                      AND a.Batch_NUMB = i.Batch_NUMB
                                      AND a.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                      AND i.SourceReceipt_CODE IN (@Lc_ReceiptSrcSpecialCollection_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE)
                                      AND i.EndValidity_DATE = @Ld_High_DATE)
                       AND a.Transaction_DATE BETWEEN @Ld_Generated_DATE AND CONVERT(DATE, (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), 102)) AS a,
                   RCTH_Y1 x
             WHERE x.SourceBatch_CODE = a.SourceBatch_CODE
               AND x.Batch_DATE = a.Batch_DATE
               AND x.Batch_NUMB = a.Batch_NUMB
               AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
               AND x.SourceReceipt_CODE IN (@Lc_ReceiptSrcSpecialCollection_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE)
               AND x.EndValidity_DATE = @Ld_High_DATE
               AND x.EventGlobalBeginSeq_NUMB = (SELECT MAX(y.EventGlobalBeginSeq_NUMB)
                                                   FROM RCTH_Y1 y
                                                  WHERE x.SourceBatch_CODE = y.SourceBatch_CODE
                                                    AND x.Batch_DATE = y.Batch_DATE
                                                    AND x.Batch_NUMB = y.Batch_NUMB
                                                    AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                                                    AND y.EndValidity_DATE = @Ld_High_DATE)) AS fci
     GROUP BY fci.Batch_DATE,
              fci.SourceBatch_CODE,
              fci.Batch_NUMB,
              fci.SeqReceipt_NUMB,
              fci.Receipt_DATE,
              fci.SourceReceipt_CODE,
			  fci.TypeRemittance_CODE;

   SET @Ls_Sql_TEXT = 'OPEN SelectCol_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN SelectCol_CUR;

   SET @Ls_Sql_TEXT = 'FETCH SelectCol_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM SelectCol_CUR INTO @Ld_SelectColCur_Batch_DATE, @Lc_SelectColCur_SourceBatch_CODE, @Ln_SelectColCur_Batch_NUMB, @Ln_SelectColCur_SeqReceipt_NUMB, @Ld_SelectColCur_Receipt_DATE, @Lc_SelectColCur_SourceReceipt_CODE, @Lc_SelectColCur_TypeRemittance_ID, @Ln_SelectColCur_Receipt_AMNT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Insert the collection details to ECBLK
   WHILE (@Li_FetchStatus_NUMB = 0)
    BEGIN
     SET @Li_Col_QNTY = @Li_Col_QNTY + 1;

     SET @Ls_Sql_TEXT = 'INSERT ECBLK_Y1';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Generated_DATE AS VARCHAR), '') + ', BlockSeq_NUMB = ' + ISNULL(CAST(@Li_Col_QNTY AS VARCHAR), '') + ', PaymentSource_CODE = ' + ISNULL(@Lc_SelectColCur_SourceReceipt_CODE, '') + ', PaymentMethod_CODE = ' + ISNULL(@Lc_SelectColCur_TypeRemittance_ID, '') + ', Rdfi_ID = ' + ISNULL(@Lc_Rdfi_ID, '') + ', RdfiAcctNo_TEXT = ' + ISNULL(@Lc_RdfiAcctNo_TEXT, '');

     INSERT ECBLK_Y1
            (TransHeader_IDNO,
             IVDOutOfStateFips_CODE,
             Transaction_DATE,
             BlockSeq_NUMB,
             Collection_DATE,
             Posting_DATE,
             Payment_AMNT,
             PaymentSource_CODE,
             PaymentMethod_CODE,
             Rdfi_ID,
             RdfiAcctNo_TEXT)
     VALUES ( @An_TransHeader_IDNO,
              @Lc_OthStateFips_CODE,--IVDOutOfStateFips_CODE
              @Ld_Generated_DATE,--Transaction_DATE
              @Li_Col_QNTY,--BlockSeq_NUMB
              ISNULL(@Ld_SelectColCur_Receipt_DATE, @Ld_Low_DATE),--Collection_DATE
              ISNULL(@Ld_SelectColCur_Receipt_DATE, @Ld_Low_DATE),--Posting_DATE
              ISNULL(@Ln_SelectColCur_Receipt_AMNT, @Ln_Payment_AMNT),
              dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE('COLLECTION_DATA_BLOCKS', 'PAYMENT_SOURCE_CODE', 'O', @Lc_SelectColCur_SourceReceipt_CODE),--PaymentSource_CODE
              CASE
			   WHEN dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE('COLLECTION_DATA_BLOCKS', 'PAYMENT_SOURCE_CODE', 'O', @Lc_SelectColCur_SourceReceipt_CODE) = 'I' 
			    THEN 'O'
               ELSE dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE('COLLECTION_DATA_BLOCKS', 'PAYMENT_METHOD_CODE', 'O', @Lc_SelectColCur_TypeRemittance_ID)
			  END,--PaymentMethod_CODE
              @Lc_Rdfi_ID,
              @Lc_RdfiAcctNo_TEXT );

     SET @Ls_Sql_TEXT = 'FETCH SelectCol_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM SelectCol_CUR INTO @Ld_SelectColCur_Batch_DATE, @Lc_SelectColCur_SourceBatch_CODE, @Ln_SelectColCur_Batch_NUMB, @Ln_SelectColCur_SeqReceipt_NUMB, @Ld_SelectColCur_Receipt_DATE, @Lc_SelectColCur_SourceReceipt_CODE, @Lc_SelectColCur_TypeRemittance_ID, @Ln_SelectColCur_Receipt_AMNT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END; -- End While loop for the Cursor
   IF CURSOR_STATUS('LOCAL', 'SelectCol_CUR') IN (0, 1)
    BEGIN
     CLOSE SelectCol_CUR;

     DEALLOCATE SelectCol_CUR;
    END;

   IF @Li_Col_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO COLLECTION INFORMATION FOUND FOR : ' + CAST(@An_Case_IDNO AS VARCHAR);
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO COLLECTION INFORMATION FOUND FOR : ' + CAST(@An_Case_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   IF @Li_Col_QNTY < @Ai_Collection_QNTY
      AND @Li_Col_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'COLLECTION DATA BLOCK INFORMATION FOR : ' + CAST(@An_Case_IDNO AS VARCHAR);
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @Ls_DescriptionError_TEXT = 'THIS CASE REQUIRES ' + CAST(@Ai_Collection_QNTY AS VARCHAR) + ' COLLECTION DATA BLOCKS : ' + CAST(@An_Case_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   SET @Ai_Collection_QNTY = @Li_Col_QNTY;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'SelectCol_CUR') IN (0, 1)
    BEGIN
     CLOSE SelectCol_CUR;

     DEALLOCATE SelectCol_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
