/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_IRSOFFSET_FEE_ASSESSMENT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_IRSOFFSET_FEE_ASSESSMENT
Programmer Name 	: IMP Team
Description			: Procedure IRS Offset Fee assessment
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_IRSOFFSET_FEE_ASSESSMENT] (
 @An_Remaining_AMNT             NUMERIC(11, 2),
 @Ad_Run_DATE                   DATE,
 @An_Case_IDNO                  NUMERIC(6),
 @Ad_Batch_DATE                 DATE,
 @An_Batch_NUMB                 NUMERIC(4),
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @Ac_Job_ID                     CHAR(7),
 @An_EventGlobalSeq_NUMB        NUMERIC(19),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @An_OffsetFeeIrs_AMNT          NUMERIC(11, 2),
 @An_IrsOffsetElig_AMNT         NUMERIC(11, 2),
 @An_DisburseDsbl_AMNT          NUMERIC(11, 2) OUTPUT,
 @An_RecoveredPofl_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_RecoveredCpflDra_AMNT      NUMERIC(11, 2) OUTPUT,
 @An_TransactionLhld_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_AssessedTot_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_RecoveredTot_AMNT          NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_TEXT			   CHAR(1) = 'Y',
		  @Lc_StatusFailed_CODE    CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE   CHAR(1) = 'S',
          @Lc_IrsAsmtToBeDone_INDC CHAR(1) = 'N',
          @Lc_StatusCheckOU_CODE   CHAR(2) = 'OU',
		  @Lc_StatusCheckCA_CODE   CHAR(2) = 'CA',
		  @Lc_StatusCheckTR_CODE   CHAR(2) = 'TR',
          @Lc_FeeTypeDrafee_CODE   CHAR(2) = 'DR',
          @Lc_FeeTypeIrsfee_CODE   CHAR(2) = 'SC',
          @Lc_TransactionAsmt_CODE CHAR(4) = 'ASMT',
          @Lc_TransactionSrec_CODE CHAR(4) = 'SREC',
          @Lc_TransactionRdcr_CODE CHAR(4) = 'RDCR',
          @Lc_TransactionRdca_CODE CHAR(4) = 'RDCA',
          @Lc_LowDate6Char_TEXT    CHAR(6) = '01/01/',
          @Ls_Procedure_NAME       VARCHAR(100) = 'SP_IRSOFFSET_FEE_ASSESSMENT',
          @Ld_High_DATE            DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_Rowcount_QNTY         NUMERIC (19),
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_SqlData_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT		VARCHAR(4000),
          @Ld_Begin_DATE            DATE;

  BEGIN TRY
   SET @An_AssessedTot_AMNT = 0;
   SET @An_RecoveredTot_AMNT = 0;
   SET @Ld_Begin_DATE = @Lc_LowDate6Char_TEXT + SUBSTRING(CONVERT(VARCHAR(4), @Ad_Run_DATE, 112), 1, 4);

   -- IRS Offset Fee Assessment and Recovery is by IVD Case and receipt wise.
   IF NOT EXISTS (SELECT 1
                    FROM (
                         -- when receipt is reversed amount will be zero here so we can add ASMT record again
                         SELECT SUM(b.Transaction_AMNT) Transaction_AMNT
                            FROM CPFL_Y1 b
                           WHERE b.Batch_DATE = @Ad_Batch_DATE
                             AND b.Batch_NUMB = @An_Batch_NUMB
                             AND b.SourceBatch_CODE = @Ac_SourceBatch_CODE
                             AND b.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                             AND b.Case_IDNO = @An_Case_IDNO
                             AND b.Transaction_CODE IN (@Lc_TransactionAsmt_CODE, @Lc_TransactionRdca_CODE)
                             AND b.FeeType_CODE = @Lc_FeeTypeIrsfee_CODE) a
                   WHERE a.Transaction_AMNT > 0)
    BEGIN
     SET @Lc_IrsAsmtToBeDone_INDC = @Lc_Yes_TEXT;
    END

   -- Amount from DSBL (already disbursed amount to CP excluding VOIDs and STOPs)
   SET @Ls_Sql_TEXT = 'SELECT IRS AMT DISBURSE ';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '');

   SELECT @An_DisburseDsbl_AMNT = ISNULL (SUM (a.Disburse_AMNT), 0)
     FROM DSBL_Y1 a,
          DSBH_Y1 b
    WHERE b.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND b.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND b.StatusCheck_CODE IN (@Lc_StatusCheckOU_CODE, @Lc_StatusCheckCA_CODE, @Lc_StatusCheckTR_CODE)
      AND b.Disburse_DATE BETWEEN @Ld_Begin_DATE AND @Ad_Run_DATE
      AND b.EndValidity_DATE = @Ld_High_DATE
      AND a.CheckRecipient_ID = b.CheckRecipient_ID
      AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
      AND a.Case_IDNO = @An_Case_IDNO
      AND a.Disburse_DATE = b.Disburse_DATE
      AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
      AND a.Batch_DATE = @Ad_Batch_DATE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB;

   -- Amount From DHLD (Ready for Disbursement for CP)
   SET @Ls_Sql_TEXT = 'SELECT #Tlhld_P1 IRS ASMT';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '');

   SELECT @An_TransactionLhld_AMNT = ISNULL (SUM (Transaction_AMNT), 0)
     FROM #Tlhld_P1 a
    WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND a.Case_IDNO = @An_Case_IDNO
      AND a.Batch_DATE = @Ad_Batch_DATE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB;

   -- Amount from POFL (recovered amount against the CP recoupment balance)
   SET @Ls_Sql_TEXT = 'SELECT POFL - IRS ASMT ';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '');

   SELECT @An_RecoveredPofl_AMNT = ISNULL (SUM (a.RecOverpay_AMNT), 0)
     FROM POFL_Y1 a
    WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND a.Case_IDNO = @An_Case_IDNO
      AND a.Batch_DATE = @Ad_Batch_DATE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB;

   -- Amount from CPFL (recovered amount from the IRS receipts for IRSOFFSET and DRA Fees.)
   SET @Ls_Sql_TEXT = 'SELECT DRA - IRS ASMT';
   SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', FeeType_CODE = ' + ISNULL(@Lc_FeeTypeDrafee_CODE, '');

   SELECT @An_RecoveredCpflDra_AMNT = ISNULL (SUM (b.Transaction_AMNT), 0)
     FROM CPFL_Y1 b
    WHERE b.Batch_DATE = @Ad_Batch_DATE
      AND b.Batch_NUMB = @An_Batch_NUMB
      AND b.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND b.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND b.Case_IDNO = @An_Case_IDNO
      AND b.Transaction_CODE IN (@Lc_TransactionSrec_CODE, @Lc_TransactionRdcr_CODE)
      AND b.FeeType_CODE = @Lc_FeeTypeDrafee_CODE;

   IF @Lc_IrsAsmtToBeDone_INDC = @Lc_Yes_TEXT
    BEGIN
     IF @An_Remaining_AMNT + @An_DisburseDsbl_AMNT + @An_RecoveredPofl_AMNT + @An_RecoveredCpflDra_AMNT + @An_TransactionLhld_AMNT >= @An_IrsOffsetElig_AMNT
      BEGIN
       SET @Ls_Sql_TEXT = 'DE_DISBURSEMENT$SP_CPFL_INSERT REG DISB';
       SET @Ls_SqlData_TEXT = 'FeeType_CODE = ' + ISNULL(@Lc_FeeTypeIrsfee_CODE, '') + ', Transaction_CODE = ' + ISNULL(@Lc_TransactionAsmt_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_OffsetFeeIrs_AMNT AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_CPFL_INSERT
        @Ac_FeeType_CODE               = @Lc_FeeTypeIrsfee_CODE,
        @Ac_Transaction_CODE           = @Lc_TransactionAsmt_CODE,
        @An_Transaction_AMNT           = @An_OffsetFeeIrs_AMNT,
        @An_Case_IDNO                  = @An_Case_IDNO,
        @Ac_CheckRecipient_ID          = @Ac_CheckRecipient_ID,
        @Ac_CheckRecipient_CODE        = @Ac_CheckRecipient_CODE,
        @Ad_Run_DATE                   = @Ad_Run_DATE,
        @An_OrderSeq_NUMB              = @An_OrderSeq_NUMB,
        @An_ObligationSeq_NUMB         = @An_ObligationSeq_NUMB,
        @Ac_TypeDisburse_CODE          = @Ac_TypeDisburse_CODE,
        @Ad_Batch_DATE                 = @Ad_Batch_DATE,
        @An_Batch_NUMB                 = @An_Batch_NUMB,
        @Ac_SourceBatch_CODE           = @Ac_SourceBatch_CODE,
        @An_SeqReceipt_NUMB            = @An_SeqReceipt_NUMB,
        @Ac_Job_ID                     = @Ac_Job_ID,
        @An_EventGlobalSeq_NUMB        = @An_EventGlobalSeq_NUMB,
        @An_EventGlobalSupportSeq_NUMB = @An_EventGlobalSupportSeq_NUMB,
        @An_AssessedTot_AMNT           = @An_AssessedTot_AMNT OUTPUT,
        @An_RecoveredTot_AMNT          = @An_RecoveredTot_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
       ELSE IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_Msg_CODE;

         RAISERROR (50001,16,1);
        END
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT IRS CPFL BALANCE';
     SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', FeeType_CODE = ' + ISNULL(@Lc_FeeTypeIrsfee_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

     SELECT @An_AssessedTot_AMNT = AssessedTot_AMNT,
            @An_RecoveredTot_AMNT = RecoveredTot_AMNT
       FROM CPFL_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.FeeType_CODE = @Lc_FeeTypeIrsfee_CODE
        AND a.Case_IDNO = @An_Case_IDNO
        AND a.Unique_IDNO = (SELECT MAX (Unique_IDNO)
                               FROM CPFL_Y1 b
                              WHERE a.Case_IDNO = b.Case_IDNO
                                AND a.MemberMci_IDNO = b.MemberMci_IDNO
                                AND a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.FeeType_CODE = b.FeeType_CODE);

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @An_AssessedTot_AMNT = 0;
       SET @An_RecoveredTot_AMNT = 0;
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF LEN(@Lc_Msg_CODE) <> 5 
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END


GO
