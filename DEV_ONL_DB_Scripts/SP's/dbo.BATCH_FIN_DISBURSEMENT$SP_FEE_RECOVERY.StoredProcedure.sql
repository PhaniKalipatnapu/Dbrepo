/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_FEE_RECOVERY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_FEE_RECOVERY
Programmer Name 	: IMP Team
Description			: Procedure to recover DRA Fees; Tax Offset Fee;
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
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_FEE_RECOVERY] (
 @Ad_Batch_DATE                 DATE,
 @An_Batch_NUMB                 NUMERIC(4),
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @Ac_FeeType_CODE               CHAR(6),
 @Ac_Job_ID                     CHAR(7),
 @An_Case_IDNO                  NUMERIC(6),
 @Ad_Run_DATE                   DATE,
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @An_EventGlobalSeq_NUMB        NUMERIC(19),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @Ad_Disburse_DATE              DATE,
 @An_DisburseSeq_NUMB           NUMERIC(4),
 @An_OffsetFeeIrs_AMNT          NUMERIC (3),
 @An_OffsetEligIrs_AMNT         NUMERIC(11, 2),
 @An_DraFee_AMNT                NUMERIC (3),
 @An_DisbYtdEligDra_AMNT        NUMERIC(11, 2),
 @An_Remaining_AMNT             NUMERIC(11, 2) OUTPUT,
 @An_Fee_AMNT                   NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE         CHAR (1) = 'S',
          @Lc_StatusFailed_CODE          CHAR (1) = 'F',
          @Lc_CheckRecipient3_CODE       CHAR (1) = '3',
          @Lc_FeeTypeDrafee_CODE         CHAR (2) = 'DR',
          @Lc_FeeTypeIrsfee_CODE         CHAR (2) = 'SC',
          @Lc_TransactionSrec_CODE       CHAR (4) = 'SREC',
          @Lc_CheckRecipientTaxofffee_ID CHAR (9) = '999999977',
          @Lc_CheckRecipientCpdrafee_ID  CHAR (9) = '999999978',
          @Ls_Procedure_NAME             VARCHAR (100) = 'SP_FEE_RECOVERY';
  DECLARE @Ln_DisburseDsbl_AMNT     NUMERIC (11, 2) = 0,
          @Ln_RecoveredPoflCr_AMNT  NUMERIC (11, 2) = 0,
          @Ln_RecoveredPofl_AMNT    NUMERIC (11, 2) = 0,
          @Ln_RecoveredCpflDra_AMNT NUMERIC (11, 2) = 0,
          @Ln_TransactionLhld_AMNT  NUMERIC (11, 2) = 0,
          @Ln_Balance_AMNT          NUMERIC (11, 2) = 0,
          @Ln_AssessedTot_AMNT      NUMERIC (11, 2) = 0,
          @Ln_RecoveredTot_AMNT     NUMERIC (11, 2) = 0,
          @Ln_Error_NUMB            NUMERIC (11),
          @Ln_ErrorLine_NUMB        NUMERIC (11),
          @Ln_Rowcount_QNTY         NUMERIC (19),
          @Lc_Msg_CODE              CHAR (5),
          @Lc_CheckRecipient_ID     CHAR (10),
          @Ls_Sql_TEXT              VARCHAR (100) = '',
          @Ls_SqlData_TEXT          VARCHAR (1000),
          @Ls_ErrorMessage_TEXT     VARCHAR (4000);

  BEGIN TRY
   IF @Ac_FeeType_CODE = @Lc_FeeTypeIrsfee_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_IRSOFFSET_FEE_ASSESSMENT';
     SET @Ls_SqlData_TEXT = 'Remaining_AMNT = ' + ISNULL(CAST(@An_Remaining_AMNT AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', OffsetFeeIrs_AMNT = ' + ISNULL(CAST(@An_OffsetFeeIrs_AMNT AS VARCHAR), '') + ', IrsOffsetElig_AMNT = ' + ISNULL(CAST(@An_OffsetEligIrs_AMNT AS VARCHAR), '');

     EXECUTE BATCH_FIN_DISBURSEMENT$SP_IRSOFFSET_FEE_ASSESSMENT
      @An_Remaining_AMNT             = @An_Remaining_AMNT,
      @Ad_Run_DATE                   = @Ad_Run_DATE,
      @An_Case_IDNO                  = @An_Case_IDNO,
      @Ad_Batch_DATE                 = @Ad_Batch_DATE,
      @An_Batch_NUMB                 = @An_Batch_NUMB,
      @Ac_SourceBatch_CODE           = @Ac_SourceBatch_CODE,
      @An_SeqReceipt_NUMB            = @An_SeqReceipt_NUMB,
      @Ac_CheckRecipient_ID          = @Ac_CheckRecipient_ID,
      @Ac_CheckRecipient_CODE        = @Ac_CheckRecipient_CODE,
      @An_OrderSeq_NUMB              = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB         = @An_ObligationSeq_NUMB,
      @Ac_Job_ID                     = @Ac_Job_ID,
      @An_EventGlobalSeq_NUMB        = @An_EventGlobalSeq_NUMB,
      @An_EventGlobalSupportSeq_NUMB = @An_EventGlobalSupportSeq_NUMB,
      @Ac_TypeDisburse_CODE          = @Ac_TypeDisburse_CODE,
      @An_OffsetFeeIrs_AMNT          = @An_OffsetFeeIrs_AMNT,
      @An_IrsOffsetElig_AMNT         = @An_OffsetEligIrs_AMNT,
      @An_DisburseDsbl_AMNT          = @Ln_DisburseDsbl_AMNT OUTPUT,
      @An_RecoveredPofl_AMNT         = @Ln_RecoveredPofl_AMNT OUTPUT,
      @An_RecoveredCpflDra_AMNT      = @Ln_RecoveredCpflDra_AMNT OUTPUT,
      @An_TransactionLhld_AMNT       = @Ln_TransactionLhld_AMNT OUTPUT,
      @An_AssessedTot_AMNT           = @Ln_AssessedTot_AMNT OUTPUT,
      @An_RecoveredTot_AMNT          = @Ln_RecoveredTot_AMNT OUTPUT,
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

     IF @Ln_AssessedTot_AMNT - @Ln_RecoveredTot_AMNT > 0
      BEGIN
       
       SET @Ln_Balance_AMNT = (@An_Remaining_AMNT + @Ln_DisburseDsbl_AMNT + @Ln_RecoveredPofl_AMNT + @Ln_RecoveredCpflDra_AMNT + @Ln_TransactionLhld_AMNT) - @An_OffsetFeeIrs_AMNT;

       IF @Ln_Balance_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT @An_Fee_AMNT - 1';
         SET @Ls_SqlData_TEXT = '';

         SELECT @An_Fee_AMNT = MIN(C1)
           FROM (SELECT @Ln_AssessedTot_AMNT - @Ln_RecoveredTot_AMNT AS C1
                 UNION ALL
                 SELECT @An_Remaining_AMNT AS C1
                 UNION ALL
                 SELECT @Ln_Balance_AMNT AS C1) C1;

         SET @An_Remaining_AMNT = @An_Remaining_AMNT - @An_Fee_AMNT;
         SET @Lc_CheckRecipient_ID = @Lc_CheckRecipientTaxofffee_ID;
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT @An_Fee_AMNT - 2';
         SET @Ls_SqlData_TEXT = '';

         SELECT @An_Fee_AMNT = MIN(C1)
           FROM (SELECT @Ln_AssessedTot_AMNT - @Ln_RecoveredTot_AMNT AS C1
                 UNION ALL
                 SELECT @An_Remaining_AMNT AS C1) C1;

         SET @An_Remaining_AMNT = @An_Remaining_AMNT - @An_Fee_AMNT;
         SET @Lc_CheckRecipient_ID = @Lc_CheckRecipientTaxofffee_ID;
        END
      END
    END
   ELSE IF @Ac_FeeType_CODE = @Lc_FeeTypeDrafee_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_DRA_FEE_ASSESSMENT';
     SET @Ls_SqlData_TEXT = 'Remaining_AMNT = ' + ISNULL(CAST(@An_Remaining_AMNT AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', DisbEligYtdDra_AMNT = ' + ISNULL(CAST(@An_DisbYtdEligDra_AMNT AS VARCHAR), '') + ', DraFee_AMNT = ' + ISNULL(CAST(@An_DraFee_AMNT AS VARCHAR), '');

     EXECUTE BATCH_FIN_DISBURSEMENT$SP_DRA_FEE_ASSESSMENT
      @An_Remaining_AMNT             = @An_Remaining_AMNT,
      @Ad_Run_DATE                   = @Ad_Run_DATE,
      @An_Case_IDNO                  = @An_Case_IDNO,
      @Ad_Batch_DATE                 = @Ad_Batch_DATE,
      @An_Batch_NUMB                 = @An_Batch_NUMB,
      @Ac_SourceBatch_CODE           = @Ac_SourceBatch_CODE,
      @An_SeqReceipt_NUMB            = @An_SeqReceipt_NUMB,
      @Ac_CheckRecipient_ID          = @Ac_CheckRecipient_ID,
      @Ac_CheckRecipient_CODE        = @Ac_CheckRecipient_CODE,
      @An_OrderSeq_NUMB              = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB         = @An_ObligationSeq_NUMB,
      @Ac_Job_ID                     = @Ac_Job_ID,
      @An_EventGlobalSeq_NUMB        = @An_EventGlobalSeq_NUMB,
      @An_EventGlobalSupportSeq_NUMB = @An_EventGlobalSupportSeq_NUMB,
      @Ac_TypeDisburse_CODE          = @Ac_TypeDisburse_CODE,
      @An_DisbEligYtdDra_AMNT        = @An_DisbYtdEligDra_AMNT,
      @An_DraFee_AMNT                = @An_DraFee_AMNT,
      @An_DisburseDsbl_AMNT          = @Ln_DisburseDsbl_AMNT OUTPUT,
      @An_RecoveredPoflCr_AMNT       = @Ln_RecoveredPoflCr_AMNT OUTPUT,
      @An_TransactionLhld_AMNT       = @Ln_TransactionLhld_AMNT OUTPUT,
      @An_AssessedTot_AMNT           = @Ln_AssessedTot_AMNT OUTPUT,
      @An_RecoveredTot_AMNT          = @Ln_RecoveredTot_AMNT OUTPUT,
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

     IF @Ln_AssessedTot_AMNT - @Ln_RecoveredTot_AMNT > 0
      BEGIN
       SET @Ln_Balance_AMNT = (@An_Remaining_AMNT + @Ln_DisburseDsbl_AMNT + @Ln_TransactionLhld_AMNT - @Ln_RecoveredPoflCr_AMNT) - @An_DisbYtdEligDra_AMNT;

       IF @Ln_Balance_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT @An_Fee_AMNT - 3';
         SET @Ls_SqlData_TEXT = '';

         SELECT @An_Fee_AMNT = MIN(C1)
           FROM (SELECT @Ln_AssessedTot_AMNT - @Ln_RecoveredTot_AMNT AS C1
                 UNION ALL
                 SELECT @An_Remaining_AMNT AS C1
                 UNION ALL
                 SELECT @Ln_Balance_AMNT AS C1) C1;

         SET @An_Remaining_AMNT = @An_Remaining_AMNT - @An_Fee_AMNT;
         SET @Lc_CheckRecipient_ID = @Lc_CheckRecipientCpdrafee_ID;
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT @An_Fee_AMNT - 4';
         SET @Ls_SqlData_TEXT = '';

         SELECT @An_Fee_AMNT = MIN(C1)
           FROM (SELECT @Ln_AssessedTot_AMNT - @Ln_RecoveredTot_AMNT AS C1
                 UNION ALL
                 SELECT @An_Remaining_AMNT AS C1) C1;

         SET @An_Remaining_AMNT = @An_Remaining_AMNT - @An_Fee_AMNT;
         SET @Lc_CheckRecipient_ID = @Lc_CheckRecipientCpdrafee_ID;
        END
      END
    END

   IF @An_Fee_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'DE_DISBURSEMENT$SP_CPFL_INSERT ';
     SET @Ls_SqlData_TEXT = 'FeeType_CODE = ' + ISNULL(@Ac_FeeType_CODE, '') + ', Transaction_CODE = ' + ISNULL(@Lc_TransactionSrec_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_Fee_AMNT AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_FIN_DISBURSEMENT$SP_CPFL_INSERT
      @Ac_FeeType_CODE               = @Ac_FeeType_CODE,
      @Ac_Transaction_CODE           = @Lc_TransactionSrec_CODE,
      @An_Transaction_AMNT           = @An_Fee_AMNT,
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
      @An_AssessedTot_AMNT           = @Ln_AssessedTot_AMNT OUTPUT,
      @An_RecoveredTot_AMNT          = @Ln_RecoveredTot_AMNT OUTPUT,
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

     SET @Ls_Sql_TEXT = 'INSERT #Tlhld_P1';
     SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient3_CODE, '') + ', DisburseSubSeq_NUMB = ' + ISNULL('0', '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_Fee_AMNT AS VARCHAR), '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@An_DisburseSeq_NUMB AS VARCHAR), '');

     INSERT #Tlhld_P1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             DisburseSubSeq_NUMB,
             Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalSupportSeq_NUMB,
             TypeDisburse_CODE,
             Transaction_AMNT,
             Disburse_DATE,
             DisburseSeq_NUMB)
     VALUES ( @Lc_CheckRecipient_ID,--CheckRecipient_ID
              @Lc_CheckRecipient3_CODE,--CheckRecipient_CODE
              0,--DisburseSubSeq_NUMB
              @An_Case_IDNO,--Case_IDNO
              @An_OrderSeq_NUMB,--OrderSeq_NUMB
              @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
              @Ad_Batch_DATE,--Batch_DATE
              @Ac_SourceBatch_CODE,--SourceBatch_CODE
              @An_Batch_NUMB,--Batch_NUMB
              @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
              @An_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
              @Ac_TypeDisburse_CODE,--TypeDisburse_CODE
              @An_Fee_AMNT,--Transaction_AMNT
              @Ad_Disburse_DATE,--Disburse_DATE
              @An_DisburseSeq_NUMB --DisburseSeq_NUMB
			);

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT #Tlhld_P1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE #Tlhld_P1 IRS';
     SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientTaxofffee_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient3_CODE, '');

     WITH Cte
          AS (SELECT CheckRecipient_ID,
                     CheckRecipient_CODE,
                     DisburseSubSeq_NUMB,
                     ROW_NUMBER() OVER (ORDER BY CheckRecipient_ID, CheckRecipient_CODE) AS ROWNUM
                FROM #Tlhld_P1
               WHERE CheckRecipient_ID = @Lc_CheckRecipientTaxofffee_ID
                 AND CheckRecipient_CODE = @Lc_CheckRecipient3_CODE)
     UPDATE t
        SET DisburseSubSeq_NUMB = ISNULL((SELECT MAX(DisburseSubSeq_NUMB)
                                            FROM DSBL_Y1
                                           WHERE CheckRecipient_ID = @Lc_CheckRecipientTaxofffee_ID
                                             AND CheckRecipient_CODE = @Lc_CheckRecipient3_CODE
                                             AND Disburse_DATE = @Ad_Run_DATE), 0) + c.ROWNUM
       FROM #Tlhld_P1 t,
            Cte c
      WHERE t.CheckRecipient_ID = @Lc_CheckRecipientTaxofffee_ID
        AND t.CheckRecipient_CODE = @Lc_CheckRecipient3_CODE
        AND t.CheckRecipient_ID = c.CheckRecipient_ID
        AND t.CheckRecipient_CODE = c.CheckRecipient_CODE
        AND t.DisburseSubSeq_NUMB = c.DisburseSubSeq_NUMB;

     SET @Ls_Sql_TEXT = 'UPDATE #Tlhld_P1 DRA';
     SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientCpdrafee_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient3_CODE, '');

     WITH Cte
          AS (SELECT CheckRecipient_ID,
                     CheckRecipient_CODE,
                     DisburseSubSeq_NUMB,
                     ROW_NUMBER() OVER (ORDER BY CheckRecipient_ID, CheckRecipient_CODE, DisburseSubSeq_NUMB) AS ROWNUM
                FROM #Tlhld_P1
               WHERE CheckRecipient_ID = @Lc_CheckRecipientCpdrafee_ID
                 AND CheckRecipient_CODE = @Lc_CheckRecipient3_CODE)
     UPDATE t
        SET DisburseSubSeq_NUMB = ISNULL((SELECT MAX(DisburseSubSeq_NUMB)
                                            FROM DSBL_Y1
                                           WHERE CheckRecipient_ID = @Lc_CheckRecipientCpdrafee_ID
                                             AND CheckRecipient_CODE = @Lc_CheckRecipient3_CODE
                                             AND Disburse_DATE = @Ad_Run_DATE), 0) + c.ROWNUM
       FROM #Tlhld_P1 t,
            Cte c
      WHERE t.CheckRecipient_ID = @Lc_CheckRecipientCpdrafee_ID
        AND t.CheckRecipient_CODE = @Lc_CheckRecipient3_CODE
        AND t.CheckRecipient_ID = c.CheckRecipient_ID
        AND t.CheckRecipient_CODE = c.CheckRecipient_CODE
        AND t.DisburseSubSeq_NUMB = c.DisburseSubSeq_NUMB;
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
