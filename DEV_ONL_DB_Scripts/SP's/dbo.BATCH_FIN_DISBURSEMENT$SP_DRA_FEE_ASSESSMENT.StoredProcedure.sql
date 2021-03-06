/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_DRA_FEE_ASSESSMENT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_DRA_FEE_ASSESSMENT
Programmer Name 	: IMP Team
Description			: Procedure to do DRA Fee assessment
Frequency           : 'DAILY'
Developed On        : 01/31/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_DRA_FEE_ASSESSMENT] (
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
 @An_DisbEligYtdDra_AMNT        NUMERIC(11, 2),
 @An_DraFee_AMNT                NUMERIC(11, 2),
 @An_DisburseDsbl_AMNT          NUMERIC(11, 2) OUTPUT,
 @An_RecoveredPoflCr_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_TransactionLhld_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_AssessedTot_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_RecoveredTot_AMNT          NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE   CHAR(1) = 'S',
          @Lc_StatusFailed_CODE    CHAR(1) = 'F',
          @Lc_EligibleDra_INDC     CHAR(1) = 'N',
          @Lc_EligibleDraY_INDC    CHAR(1) = 'Y',
          @Lc_EligibleDraN_INDC    CHAR(1) = 'N',
          @Lc_TypeCaseN_CODE	   CHAR(1) = 'N',
          @Lc_TypeWelfareA_CODE	   CHAR(1) = 'A',
          @Lc_FeeTypeDrafee_CODE   CHAR(2) = 'DR',
          @Lc_StatusCheckVR_CODE   CHAR(2) = 'VR',
          @Lc_StatusCheckVN_CODE   CHAR(2) = 'VN',
          @Lc_StatusCheckSR_CODE   CHAR(2) = 'SR',
          @Lc_StatusCheckSN_CODE   CHAR(2) = 'SN',
          @Lc_StatusCheckRE_CODE   CHAR(2) = 'RE',
          @Lc_SourceReceiptCR_CODE CHAR(2) = 'CR',
          @Lc_TransactionAsmt_CODE CHAR(4) = 'ASMT',
          @Lc_FyBeg01Oct_TEXT      CHAR(6) = '10/01/',
          @Lc_FyEnd30Sep_TEXT      CHAR(6) = '09/30/',
          @Lc_MonthOct_TEXT        CHAR(10) = 'October',
          @Lc_MonthNov_TEXT        CHAR(10) = 'November',
          @Lc_MonthDec_TEXT        CHAR(10) = 'December',
          @Ls_Procedure_NAME       VARCHAR(100) = 'SP_DRA_FEE_ASSESSMENT',
          @Ld_High_DATE            DATE = '12/31/9999';
  DECLARE @Ln_FiscalYear_NUMB       NUMERIC(4),
		  @Ln_DisbYtd_AMNT          NUMERIC(11, 2) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_RowCount_QNTY         NUMERIC(19),
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_SqlData_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ld_FyBegin_DATE			DATE,
          @Ld_FyEnd_DATE			DATE;

  BEGIN TRY
   SET @An_AssessedTot_AMNT = 0;
   SET @An_RecoveredTot_AMNT = 0;

     IF (DATENAME(MONTH, @Ad_Run_DATE) NOT IN (@Lc_MonthOct_TEXT, @Lc_MonthNov_TEXT, @Lc_MonthDec_TEXT))
      BEGIN
       SET @Ld_FyBegin_DATE = @Lc_FYBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -12, @Ad_Run_DATE));
       SET @Ld_FyEnd_DATE = @Lc_FYEnd30Sep_TEXT + DATENAME(YEAR, @Ad_Run_DATE);
       SET @Ln_FiscalYear_NUMB = YEAR(@Ad_Run_DATE)
      END
     ELSE
      BEGIN
       SET @Ld_FyBegin_DATE = @Lc_FYBeg01Oct_TEXT + DATENAME(YEAR, @Ad_Run_DATE);
       SET @Ld_FyEnd_DATE = @Lc_FYEnd30Sep_TEXT + DATENAME(YEAR, DATEADD(m, 3, @Ad_Run_DATE));
       SET @Ln_FiscalYear_NUMB = YEAR(DATEADD(m, 3, @Ad_Run_DATE))
      END;
   
   SET @Ls_Sql_TEXT = 'SELECT DSBH_Y1,DSBL_Y1 ';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @An_DisburseDsbl_AMNT = ISNULL (SUM (a.Disburse_AMNT), 0)
     FROM DSBL_Y1 a,
          DSBH_Y1 b
    WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND a.Case_IDNO = @An_Case_IDNO
      AND a.CheckRecipient_ID = b.CheckRecipient_ID
      AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
      AND a.Disburse_DATE = b.Disburse_DATE
      AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
      AND b.EndValidity_DATE = @Ld_High_DATE
      AND b.Disburse_DATE BETWEEN @Ld_FyBegin_DATE AND @Ld_FyEnd_DATE
      AND b.StatusCheck_CODE NOT IN (@Lc_StatusCheckVR_CODE, @Lc_StatusCheckVN_CODE, @Lc_StatusCheckSR_CODE, @Lc_StatusCheckSN_CODE, @Lc_StatusCheckRE_CODE);

   SET @Ls_Sql_TEXT = 'SELECT #Tlhld_P1 DRA';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

   SELECT @An_TransactionLhld_AMNT = ISNULL (SUM (Transaction_AMNT), 0)
     FROM #Tlhld_P1 a
    WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND a.Case_IDNO = @An_Case_IDNO;

   SET @Ls_Sql_TEXT = 'SELECT POFL_Y1 ';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceiptCR_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @An_RecoveredPoflCr_AMNT = ISNULL (SUM (RecOverpay_AMNT), 0)
     FROM POFL_Y1 a
    WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND a.Transaction_DATE BETWEEN @Ld_FyBegin_DATE AND @Ld_FyEnd_DATE
      AND EXISTS (SELECT 1
                    FROM RCTH_Y1 b
                   WHERE a.Batch_DATE = b.Batch_DATE
                     AND a.SourceBatch_CODE = b.SourceBatch_CODE
                     AND a.Batch_NUMB = b.Batch_NUMB
                     AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                     AND b.SourceReceipt_CODE = @Lc_SourceReceiptCR_CODE
                     AND b.EndValidity_DATE = @Ld_High_DATE);

   SET @Ln_DisbYtd_AMNT = @An_DisburseDsbl_AMNT + @An_TransactionLhld_AMNT - @An_RecoveredPoflCr_AMNT;
   
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 ';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseN_CODE,'')+ ', MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', FeeType_CODE = ' + ISNULL(@Lc_FeeTypeDrafee_CODE,'')+ ', Transaction_CODE = ' + ISNULL(@Lc_TransactionAsmt_CODE,'');

   SELECT @Lc_EligibleDra_INDC = @Lc_EligibleDraY_INDC
     FROM CASE_Y1 a
    WHERE Case_IDNO = @An_Case_IDNO
      AND TypeCase_CODE = @Lc_TypeCaseN_CODE
      AND NOT EXISTS(SELECT 1 FROM MHIS_Y1 b WHERE a.Case_IDNO = b.Case_IDNO AND TypeWelfare_CODE = @Lc_TypeWelfareA_CODE)    
      AND @Ln_DisbYtd_AMNT + @An_Remaining_AMNT >= @An_DisbEligYtdDra_AMNT
      AND NOT EXISTS (SELECT 1
                        FROM CPFL_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND b.MemberMci_IDNO = @Ac_CheckRecipient_ID
                         AND FeeType_CODE = @Lc_FeeTypeDrafee_CODE
                         AND b.AssessedYear_NUMB = @Ln_FiscalYear_NUMB
                         AND b.Transaction_CODE = @Lc_TransactionAsmt_CODE);

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Lc_EligibleDra_INDC = @Lc_EligibleDraN_INDC;
    END;

   IF @Lc_EligibleDra_INDC = @Lc_EligibleDraY_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_CPFL_INSERT';
     SET @Ls_SqlData_TEXT = 'FeeType_CODE = ' + ISNULL(@Lc_FeeTypeDrafee_CODE, '') + ', Transaction_CODE = ' + ISNULL(@Lc_TransactionAsmt_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_DraFee_AMNT AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_FIN_DISBURSEMENT$SP_CPFL_INSERT
      @Ac_FeeType_CODE               = @Lc_FeeTypeDrafee_CODE,
      @Ac_Transaction_CODE           = @Lc_TransactionAsmt_CODE,
      @An_Transaction_AMNT           = @An_DraFee_AMNT,
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
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT DRA CPFL BALANCE';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', FeeType_CODE = ' + ISNULL(@Lc_FeeTypeDrafee_CODE, '');

     SELECT @An_AssessedTot_AMNT = AssessedTot_AMNT,
            @An_RecoveredTot_AMNT = RecoveredTot_AMNT
       FROM CPFL_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.MemberMci_IDNO = @Ac_CheckRecipient_ID
        AND a.AssessedYear_NUMB = @Ln_FiscalYear_NUMB
        AND a.FeeType_CODE = @Lc_FeeTypeDrafee_CODE
        AND a.Unique_IDNO = (SELECT MAX (Unique_IDNO)
                               FROM CPFL_Y1 b
                              WHERE a.Case_IDNO = b.Case_IDNO
                                AND a.MemberMci_IDNO = b.MemberMci_IDNO
                                AND a.AssessedYear_NUMB = b.AssessedYear_NUMB
                                AND a.FeeType_CODE = b.FeeType_CODE);

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
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
