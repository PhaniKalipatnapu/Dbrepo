/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_GET_DTLS_FOR_ORIGINAL_RCPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_GET_DTLS_FOR_ORIGINAL_RCPT
Programmer Name 	: IMP Team
Description			: This procedure is to get over disbursed Value_AMNT and recoupment payee from the original RCTH_Y1.
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_GET_DTLS_FOR_ORIGINAL_RCPT]
 @Ad_BatchIn_DATE          DATE,
 @An_BatchIn_NUMB          NUMERIC(4),
 @Ac_SourceBatchIn_CODE    CHAR (3),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @An_OdOrigRcpt_AMNT       NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @Ac_CheckRecipient_ID     CHAR(10) OUTPUT,
 @Ac_CheckRecipient_CODE   CHAR(1) OUTPUT,
 @Ac_TypeDisburse_CODE     CHAR(5) OUTPUT,
 @An_Case_IDNO             NUMERIC(6) OUTPUT,
 @Ad_Batch_DATE            DATETIME2 (0) OUTPUT,
 @Ac_SourceBatch_CODE      CHAR(3) OUTPUT,
 @An_Batch_NUMB            NUMERIC (4) OUTPUT,
 @Ac_SeqReceipt_NUMB       CHAR (6) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_RecipientTypeFips_CODE      CHAR(1) = '2',
          @Lc_RecipientTypeCpNcp_CODE     CHAR(1) = '1',
          @Lc_RelationshipCaseCp_CODE     CHAR(1) = 'C',
          @Lc_RecoupmentTypeRegular_CODE  CHAR(1) = 'R',
          @Lc_StatusSuccess_CODE		  CHAR(1) = 'S',
          @Lc_StatusFailed_CODE			  CHAR(1) = 'F',
          @Lc_DisbursementTypeRefund_CODE CHAR(5) = 'REFND',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_GET_DTLS_FOR_ORIGINAL_RCPT',
          @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB        NUMERIC(11),
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Li_Rowcount_QNTY     SMALLINT,
          @Lc_ChkRecipient_CODE CHAR(1),
          @Lc_ChkRecipient_ID   CHAR(10),
          @Ls_Sql_TEXT          VARCHAR(100) = '',
          @Ls_Sqldata_TEXT      VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @An_OdOrigRcpt_AMNT = 0;
   SET @Ac_Msg_CODE = '';
   SET @Lc_ChkRecipient_ID = @Ac_CheckRecipient_ID;
   SET @Lc_ChkRecipient_CODE = @Ac_CheckRecipient_CODE;
   SET @Ls_Sql_TEXT = 'SELECT DSBL_Y1 DSBH_Y1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_BatchIn_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_BatchIn_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatchIn_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @An_OdOrigRcpt_AMNT = ISNULL(SUM (a.Disburse_AMNT), 0)
     FROM DSBL_Y1 a,
          DSBH_Y1 c
    WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND a.CheckRecipient_ID = c.CheckRecipient_ID
      AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
      AND a.Disburse_DATE = c.Disburse_DATE
      AND a.DisburseSeq_NUMB = c.DisburseSeq_NUMB
      AND c.EndValidity_DATE = @Ld_High_DATE
      AND NOT EXISTS (SELECT 1
                        FROM DSBC_Y1 d
                       WHERE c.CheckRecipient_ID = d.CheckRecipientOrig_ID
                         AND c.CheckRecipient_CODE = d.CheckRecipientOrig_CODE
                         AND c.Disburse_DATE = d.DisburseOrig_DATE
                         AND c.DisburseSeq_NUMB = d.DisburseOrigSeq_NUMB)
      AND EXISTS (SELECT 1
                    FROM RCTR_Y1 b
                   WHERE b.Batch_DATE = @Ad_BatchIn_DATE
                     AND b.Batch_NUMB = @An_BatchIn_NUMB
                     AND b.SourceBatch_CODE = @Ac_SourceBatchIn_CODE
                     AND b.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                     AND b.EndValidity_DATE = @Ld_High_DATE
                     AND a.Batch_DATE = b.BatchOrig_DATE
					 AND a.SourceBatch_CODE = b.SourceBatchOrig_CODE
					 AND a.Batch_NUMB = b.BatchOrig_NUMB
					 AND a.SeqReceipt_NUMB = b.SeqReceiptOrig_NUMB);

   IF @Lc_ChkRecipient_CODE = @Lc_RecipientTypeFips_CODE
    BEGIN
     IF @Ac_TypeDisburse_CODE <> @Lc_DisbursementTypeRefund_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1_POFL';
       SET @Ls_Sqldata_TEXT = '';

       SELECT TOP (1) @Lc_ChkRecipient_ID = x.MemberMci_IDNO,
                      @Lc_ChkRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
         FROM (SELECT a.MemberMci_IDNO,
                      a.CaseMemberStatus_CODE
                 FROM CMEM_Y1 a
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE) AS x
        ORDER BY 2;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;
     ELSE IF @Ac_TypeDisburse_CODE = @Lc_DisbursementTypeRefund_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT VRCTH_POFL';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(@Ac_SeqReceipt_NUMB, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT TOP 1 @Lc_ChkRecipient_ID = r.PayorMCI_IDNO,
                    @Lc_ChkRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
         FROM RCTH_Y1 r
        WHERE r.Batch_DATE = @Ad_Batch_DATE
          AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
          AND r.Batch_NUMB = @An_Batch_NUMB
          AND r.SeqReceipt_NUMB = @Ac_SeqReceipt_NUMB
          AND r.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;
    END

   -- The following query is used select the amount which is recovered from the reposted receipts.
   SET @Ls_Sql_TEXT = 'SELECT POFL_Y1 2';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_ChkRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_ChkRecipient_CODE, '') + ', TypeRecoupment_CODE = ' + ISNULL(@Lc_RecoupmentTypeRegular_CODE, '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_BatchIn_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatchIn_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_BatchIn_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_BatchIn_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_BatchIn_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatchIn_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @An_OdOrigRcpt_AMNT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_GREATEST_FLOAT (@An_OdOrigRcpt_AMNT - ISNULL (SUM (a.RecOverpay_AMNT), 0), 0), 0)
     FROM POFL_Y1 a
    WHERE a.CheckRecipient_ID = @Lc_ChkRecipient_ID
      AND a.CheckRecipient_CODE = @Lc_ChkRecipient_CODE
      AND a.TypeRecoupment_CODE = @Lc_RecoupmentTypeRegular_CODE
      AND a.Batch_DATE = @Ad_BatchIn_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatchIn_CODE
      AND a.Batch_NUMB = @An_BatchIn_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND EXISTS (SELECT 1
                    FROM POFL_Y1 c
                   WHERE a.CheckRecipient_ID = c.CheckRecipient_ID
                     AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
                     AND a.TypeRecoupment_CODE = c.TypeRecoupment_CODE)
      AND EXISTS (SELECT 1
                    FROM RCTR_Y1 b
                   WHERE Batch_DATE = @Ad_BatchIn_DATE
                     AND Batch_NUMB = @An_BatchIn_NUMB
                     AND SourceBatch_CODE = @Ac_SourceBatchIn_CODE
                     AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                     AND EndValidity_DATE = @Ld_High_DATE
                     AND a.Batch_DATE = b.BatchOrig_DATE
					 AND a.SourceBatch_CODE = b.SourceBatchOrig_CODE
					 AND a.Batch_NUMB = b.BatchOrig_NUMB
					 AND a.SeqReceipt_NUMB = b.SeqReceiptOrig_NUMB);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;  
  END TRY

  BEGIN CATCH
   SET @An_OdOrigRcpt_AMNT = 0;
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
