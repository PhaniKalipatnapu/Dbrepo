/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE34A$SP_INSERT_R34RT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_RPT_OCSE34A$SP_INSERT_R34RT
Programmer Name 	: IMP Team
Description			: The process loads the receipt level details for the R34RT table
Frequency			: 'MONTHLY/QUATERLY'
Developed On		: 10/14/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE34A$SP_INSERT_R34RT]
 @Ad_BeginQtr_DATE         DATE,
 @Ad_EndQtr_DATE           DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                         CHAR (1) = ' ',
          @Lc_No_INDC                            CHAR (1) = 'N',
          @Lc_Yes_INDC                           CHAR (1) = 'Y',
          @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
          @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
          @Lc_RecipientTypeFips_CODE             CHAR (1) = '2',
          @Lc_RecipientTypeCpNcp_CODE            CHAR (1) = '1',
          @Lc_DisburseStatusVoidReissue_CODE     CHAR (2) = 'VR',
          @Lc_DisburseStatusStopNoReissue_CODE   CHAR (2) = 'SN',
          @Lc_DisburseStatusStopReissue_CODE     CHAR (2) = 'SR',
          @Lc_ReceiptSrcEmployerwage_CODE        CHAR (2) = 'EW',
          @Lc_DisburseStatusOutstanding_CODE     CHAR (2) = 'OU',
          @Lc_ReceiptSrcSpecialCollection_CODE   CHAR (2) = 'SC',
          @Lc_ReceiptSrcStateTaxRefund_CODE      CHAR (2) = 'ST',
          @Lc_ReceiptSrcHomesteadRebate_CODE     CHAR (2) = 'SH',
          @Lc_ReceiptSrcSaverRebate_CODE         CHAR (2) = 'SS',
          @Lc_ReceiptSrcUib_CODE                 CHAR (2) = 'UC',
          @Lc_ReceiptSrcInterstativdreg_CODE     CHAR (2) = 'F4',
          @Lc_ReceiptSrcInterstativdfee_CODE     CHAR (2) = 'FF',
          @Lc_DebtTypeGeneticTest_CODE           CHAR (2) = 'GT',
          @Lc_VsaStatusVoidnoreissue_CODE        CHAR (2) = 'VN',
          @Lc_DisburseStatusRejectedEft_CODE     CHAR (2) = 'RE',
          @Lc_ReceiptSrcAdminretirement_CODE     CHAR (2) = 'AR',
          @Lc_ReceiptSrcAdminsalary_CODE         CHAR (2) = 'AS',
          @Lc_ReceiptSrcAdminvendorpymt_CODE     CHAR (2) = 'AV',
          @Lc_DebtTypeMedicalSupp_CODE           CHAR (2) = 'MS',
          @Lc_DisburseStatusCashed_CODE          CHAR (2) = 'CA',
          @Lc_DisburseStatusTransferEft_CODE     CHAR (2) = 'TR',
          @Lc_AssistNever_TEXT                   CHAR (2) = 'NN',
          @Lc_DisburseStatusStopeft_CODE         CHAR (2) = 'SE',
          @Lc_AssistCurrentTanf_TEXT             CHAR (2) = 'CA',
          @Lc_AssistCurrentIve_TEXT              CHAR (2) = 'CF',
          @Lc_AssistFormerTanf_TEXT              CHAR (2) = 'FA',
          @Lc_AssistFormerIve_TEXT               CHAR (2) = 'FF',
          @Lc_AssistFormerMedicaid_TEXT          CHAR (2) = 'FM',
          @Lc_AssistFormerNonIvd_TEXT            CHAR (2) = 'FH',
          @Lc_AssistCurrentNonIvd_TEXT           CHAR (2) = 'CH',
          @Lc_AssistCurrentMedicaid_TEXT         CHAR (2) = 'CM',
          @Lc_DisbursementTypeRefund_CODE        CHAR (5) = 'REFND',
          @Lc_DisbursementTypeRothp_CODE         CHAR (5) = 'ROTHP',
          @Lc_DisbursementTypeCzniv_CODE         CHAR (5) = 'CZNIV',
          @Lc_DisbursementTypeAzniv_CODE         CHAR (5) = 'AZNIV',
          @Lc_DisbursementTypeCgpaa_CODE         CHAR (5) = 'CGPAA',
          @Lc_DisbursementTypePgpaa_CODE         CHAR (5) = 'PGPAA',
          @Lc_DisbursementTypeAgpaa_CODE         CHAR (5) = 'AGPAA',
          @Lc_DisbursementTypeAgtaa_CODE         CHAR (5) = 'AGTAA',
          @Lc_DisbursementTypeAxive_CODE         CHAR (5) = 'AXIVE',
          @Lc_DisbursementTypeCxive_CODE         CHAR (5) = 'CXIVE',
          @Lc_DisbursementTypeAznfc_CODE         CHAR (5) = 'AZNFC',
          @Lc_DisbursementTypeCznfc_CODE         CHAR (5) = 'CZNFC',
          @Lc_TypeDisburseLine3_CODE             CHAR (5) = 'LINE3',
          @Lc_TypeDisburseLine1_CODE             CHAR (5) = 'LINE1',
          @Lc_TypeDisburseLine9_CODE             CHAR (5) = 'LINE9',
          @Lc_TypeDisburseVrcth_CODE             CHAR (7) = 'RCTH',
          @Lc_TypeDisburseVlsup_CODE             CHAR (7) = 'LSUP',
          @Lc_RfndRecipientTanf_TEXT             CHAR (9) = '999999994',
          @Lc_CheckRecipientOsr_ID				 CHAR (10) = '999999980',
          @Lc_CheckRecipientIve_ID               CHAR (10) = '999999993',
          @Lc_CheckRecipientMedi_ID              CHAR (10) = '999999982',
          @Lc_CheckRecipientIrs_ID				 CHAR (10) = '999999977',
          @Lc_CheckRecipientDra_ID               CHAR (10) = '999999978',
          @Ls_Procedure_NAME                     VARCHAR (100) = 'SP_INSERT_R34RT',
          @Ld_High_DATE                          DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB        NUMERIC (11),
          @Ln_ErrorLine_NUMB    NUMERIC (11),
          @Ls_Sql_TEXT          VARCHAR (100),
          @Ls_Sqldata_TEXT      VARCHAR (1000),
          @Ls_ErrorMessage_TEXT VARCHAR (4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'INSERT R34RT_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST( @Ad_BeginQtr_DATE AS VARCHAR ),'')+ ', EndQtr_DATE = ' + ISNULL(CAST( @Ad_EndQtr_DATE AS VARCHAR ),'');
   INSERT R34RT_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           PayorMCI_IDNO,
           Case_IDNO,
           CheckNo_TEXT,
           Receipt_DATE,
           BeginQtr_DATE,
           EndQtr_DATE,
           LineNo1_AMNT,
           LineNo2a_AMNT,
           LineNo2b_AMNT,
           LineNo2c_AMNT,
           LineNo2d_AMNT,
           LineNo2e_AMNT,
           LineNo2f_AMNT,
           LineNo2g_AMNT,
           LineNo2h_AMNT,
           LineNo3_AMNT,
           LineNo4_AMNT,
           LineNo4a_AMNT,
           LineNo4ba_AMNT,
           LineNo4bb_AMNT,
           LineNo4bc_AMNT,
           LineNo4bd_AMNT,
           LineNo4be_AMNT,
           LineNo4bf_AMNT,
           LineNo4c_AMNT,
           LineNo5_AMNT,
           LineNo7aa_AMNT,
           LineNo7ac_AMNT,
           LineNo7ba_AMNT,
           LineNo7bb_AMNT,
           LineNo7bc_AMNT,
           LineNo7bd_AMNT,
           LineNo7ca_AMNT,
           LineNo7cb_AMNT,
           LineNo7cc_AMNT,
           LineNo7cd_AMNT,
           LineNo7ce_AMNT,
           LineNo7cf_AMNT,
           LineNo7da_AMNT,
           LineNo7db_AMNT,
           LineNo7dc_AMNT,
           LineNo7dd_AMNT,
           LineNo7de_AMNT,
           LineNo7df_AMNT,
           LineNo7ee_AMNT,
           LineNo7ef_AMNT,
           LineNo11_AMNT)
   SELECT fci.Batch_DATE,
          fci.SourceBatch_CODE,
          fci.Batch_NUMB,
          fci.SeqReceipt_NUMB,
          MAX(fci.PayorMCI_IDNO) AS PayorMCI_IDNO,
          0 AS Case_IDNO,
          MAX(fci.CheckNo_TEXT) AS CheckNo_TEXT,
          MAX(fci.Receipt_DATE) AS Receipt_DATE,
          @Ad_BeginQtr_DATE AS BeginQtr_DATE,
          @Ad_EndQtr_DATE AS EndQtr_DATE,
          ISNULL(SUM(CAST(fci.line_1_amt AS NUMERIC(11, 2))), 0) AS line_1_amt,
          ISNULL(SUM(CAST(fci.line_2a_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_2b_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_2c_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_2d_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_2e_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_2f_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_2g_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_2h_amt AS NUMERIC(11, 2))), 0),
          ISNULL(SUM(CAST(fci.line_3_amt AS NUMERIC(11, 2))), 0) AS line_3_amt,
          ISNULL(SUM(CAST(fci.line_4_amt AS NUMERIC(11, 2))), 0) AS line_4_amt,
          ISNULL(SUM(CAST(fci.line_4a_amt AS NUMERIC(11, 2))), 0) AS line_4a_amt,
          ISNULL(SUM(CAST(fci.line_4ba_amt AS NUMERIC(11, 2))), 0) AS line_4ba_amt,
          ISNULL(SUM(CAST(fci.line_4bb_amt AS NUMERIC(11, 2))), 0) AS line_4bb_amt,
          ISNULL(SUM(CAST(fci.line_4bc_amt AS NUMERIC(11, 2))), 0) AS line_4bc_amt,
          ISNULL(SUM(CAST(fci.line_4bd_amt AS NUMERIC(11, 2))), 0) AS line_4bd_amt,
          ISNULL(SUM(CAST(fci.line_4be_amt AS NUMERIC(11, 2))), 0) AS line_4be_amt,
          ISNULL(SUM(CAST(fci.line_4bf_amt AS NUMERIC(11, 2))), 0) AS line_4bf_amt,
          ISNULL(SUM(CAST(fci.line_4c_amt AS NUMERIC(11, 2))), 0) AS line_4c_amt,
          ISNULL(SUM(CAST(fci.line_5_amt AS NUMERIC(11, 2))), 0) AS line_5_amt,
          ISNULL(SUM(CAST(fci.line_7aa_amt AS NUMERIC(11, 2))), 0) AS line_7aa_amt,
          ISNULL(SUM(CAST(fci.line_7ac_amt AS NUMERIC(11, 2))), 0) AS line_7ac_amt,
          ISNULL(SUM(CAST(fci.line_7ba_amt AS NUMERIC(11, 2))), 0) AS line_7ba_amt,
          ISNULL(SUM(CAST(fci.line_7bb_amt AS NUMERIC(11, 2))), 0) AS line_7bb_amt,
          ISNULL(SUM(CAST(fci.line_7bc_amt AS NUMERIC(11, 2))), 0) AS line_7bc_amt,
          ISNULL(SUM(CAST(fci.line_7bd_amt AS NUMERIC(11, 2))), 0) AS line_7bd_amt,
          ISNULL(SUM(CAST(fci.line_7ca_amt AS NUMERIC(11, 2))), 0) AS line_7ca_amt,
          ISNULL(SUM(CAST(fci.line_7cb_amt AS NUMERIC(11, 2))), 0) AS line_7cb_amt,
          ISNULL(SUM(CAST(fci.line_7cc_amt AS NUMERIC(11, 2))), 0) AS line_7cc_amt,
          ISNULL(SUM(CAST(fci.line_7cd_amt AS NUMERIC(11, 2))), 0) AS line_7cd_amt,
          ISNULL(SUM(CAST(fci.line_7ce_amt AS NUMERIC(11, 2))), 0) AS line_7ce_amt,
          ISNULL(SUM(CAST(fci.line_7cf_amt AS NUMERIC(11, 2))), 0) AS line_7cf_amt,
          ISNULL(SUM(CAST(fci.line_7da_amt AS NUMERIC(11, 2))), 0) AS line_7da_amt,
          ISNULL(SUM(CAST(fci.line_7db_amt AS NUMERIC(11, 2))), 0) AS line_7db_amt,
          ISNULL(SUM(CAST(fci.line_7dc_amt AS NUMERIC(11, 2))), 0) AS line_7dc_amt,
          ISNULL(SUM(CAST(fci.line_7dd_amt AS NUMERIC(11, 2))), 0) AS line_7dd_amt,
          ISNULL(SUM(CAST(fci.line_7de_amt AS NUMERIC(11, 2))), 0) AS line_7de_amt,
          ISNULL(SUM(CAST(fci.line_7df_amt AS NUMERIC(11, 2))), 0) AS line_7df_amt,
          ISNULL(SUM(CAST(fci.line_7ee_amt AS NUMERIC(11, 2))), 0) AS line_7ee_amt,
          ISNULL(SUM(CAST(fci.line_7ef_amt AS NUMERIC(11, 2))), 0) AS line_7ef_amt,
          ISNULL(SUM(CAST(fci.line_11_amt AS NUMERIC(11, 2))), 0)
     FROM (SELECT a.Batch_DATE,
                  a.SourceBatch_CODE,
                  a.Batch_NUMB,
                  a.SeqReceipt_NUMB,
                  a.PayorMCI_IDNO,
                  a.CheckNo_TEXT,
                  a.Receipt_DATE,
                  CASE
                   WHEN a.TypeDisburse_CODE = @Lc_TypeDisburseLine1_CODE
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_1_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcSpecialCollection_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_2a_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE)
                        AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_2b_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcUib_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_2c_amt,
                  0 AS line_2d_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwage_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_2e_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcInterstativdreg_CODE)
                        AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_2f_amt,
                  0 AS line_2g_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE NOT IN (@Lc_ReceiptSrcEmployerwage_CODE, @Lc_ReceiptSrcInterstativdfee_CODE, @Lc_ReceiptSrcInterstativdreg_CODE, @Lc_ReceiptSrcSpecialCollection_CODE,
                                                     @Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcUib_CODE)
                        AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_2h_amt,
                  CASE
                   WHEN a.TypeDisburse_CODE = @Lc_TypeDisburseLine3_CODE
                    THEN a.Disburse_AMNT
                   ELSE 0
                  END AS line_3_amt,
                  0 AS line_4_amt,
                  0 AS line_4a_amt,
                  0 AS line_4ba_amt,
                  0 AS line_4bb_amt,
                  0 AS line_4bc_amt,
                  0 AS line_4bd_amt,
                  0 AS line_4be_amt,
                  0 AS line_4bf_amt,
                  0 AS line_4c_amt,
                  0 AS line_5_amt,
                  0 AS line_7aa_amt,
                  0 AS line_7ac_amt,
                  0 AS line_7ba_amt,
                  0 AS line_7bb_amt,
                  0 AS line_7bc_amt,
                  0 AS line_7bd_amt,
                  0 AS line_7ca_amt,
                  0 AS line_7cb_amt,
                  0 AS line_7cc_amt,
                  0 AS line_7cd_amt,
                  0 AS line_7ce_amt,
                  0 AS line_7cf_amt,
                  0 AS line_7da_amt,
                  0 AS line_7db_amt,
                  0 AS line_7dc_amt,
                  0 AS line_7dd_amt,
                  0 AS line_7de_amt,
                  0 AS line_7df_amt,
                  0 AS line_7ee_amt,
                  0 AS line_7ef_amt,
                  0 AS line_11_amt
             FROM RPODSL_Y1 a
            WHERE (((a.Batch_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                      OR (a.Batch_DATE < @Ad_BeginQtr_DATE
                          AND a.MinimumBegin_DATE >= @Ad_BeginQtr_DATE))
                AND a.BeginValidity_DATE <= @Ad_EndQtr_DATE
                AND a.EndValidity_DATE > @Ad_EndQtr_DATE
                AND a.BackOut_INDC = @Lc_No_INDC
                AND a.TypeDisburse_CODE = @Lc_TypeDisburseVrcth_CODE)
                OR a.TypeDisburse_CODE IN (@Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE))
           UNION ALL
           SELECT a.Batch_DATE,
                  a.SourceBatch_CODE,
                  a.Batch_NUMB,
                  a.SeqReceipt_NUMB,
                  a.PayorMCI_IDNO,
                  a.CheckNo_TEXT,
                  a.Receipt_DATE,
                  0 AS line_1_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcSpecialCollection_CODE
                        AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RPODSL_Y1 b
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND b.TypeDisburse_CODE = 'LINE1'
                                       AND b.Disburse_AMNT > 0
                                    UNION
                                    SELECT 1
                                      FROM RCTH_Y1 B
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND B.Batch_DATE >= @Ad_BeginQtr_DATE)
                        AND NOT EXISTS (SELECT 1
                                          FROM POFL_Y1 p
                                         WHERE p.Batch_DATE = a.Batch_DATE
                                           AND p.SourceBatch_CODE = a.SourceBatch_CODE
                                           AND p.Batch_NUMB = a.Batch_NUMB
                                           AND p.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                           AND p.CheckRecipient_ID = a.CheckRecipient_ID
                                           AND p.Transaction_CODE = 'CHSW'
                                           AND p.TypeDisburse_CODE = 'REFND'
                                           AND ABS(p.RecOverpay_AMNT) = a.Disburse_AMNT)
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcSpecialCollection_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN a.Disburse_AMNT * -1
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcSpecialCollection_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND (a.TypeDisburse_CODE = 'NDHLD'
                              OR (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                                  AND (a.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                                        OR (a.BackOut_DATE < @Ad_BeginQtr_DATE
                                            AND a.BackOut_INDC = @Lc_No_INDC
                                            AND EXISTS (SELECT 1
                                                          FROM RPODSL_Y1 b
                                                         WHERE b.Batch_DATE = a.Batch_DATE
                                                           AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                           AND b.Batch_NUMB = a.Batch_NUMB
                                                           AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                           AND b.TypeDisburse_CODE = @Lc_TypeDisburseLine1_CODE
                                                           AND b.Disburse_AMNT > 0)))
                                  AND NOT EXISTS (SELECT 1
                                                    FROM RPODSL_Y1 b
                                                   WHERE b.Batch_DATE = a.Batch_DATE
                                                     AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                     AND b.Batch_NUMB = a.Batch_NUMB
                                                     AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                     AND b.TypeDisburse_CODE = @Lc_TypeDisburseVrcth_CODE
                                                     AND b.BackOut_INDC = @Lc_Yes_INDC
                                                     AND b.EndValidity_DATE >= @Ad_EndQtr_DATE)))
                    THEN a.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_2a_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE)
                        AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RPODSL_Y1 b
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceReceipt_CODE = a.SourceReceipt_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND b.TypeDisburse_CODE = 'LINE1'
                                       AND b.Disburse_AMNT > 0
                                    UNION
                                    SELECT 1
                                      FROM RCTH_Y1 B
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceReceipt_CODE = a.SourceReceipt_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND B.Batch_DATE >= @Ad_BeginQtr_DATE)
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN a.Disburse_AMNT * -1
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND (a.TypeDisburse_CODE = 'NDHLD'
                              OR (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                                  AND (a.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                                        OR (a.BackOut_DATE < @Ad_BeginQtr_DATE
                                            AND a.BackOut_INDC = @Lc_No_INDC
                                            AND EXISTS (SELECT 1
                                                          FROM RPODSL_Y1 b
                                                         WHERE b.Batch_DATE = a.Batch_DATE
                                                           AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                           AND b.Batch_NUMB = a.Batch_NUMB
                                                           AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                           AND b.TypeDisburse_CODE = @Lc_TypeDisburseLine1_CODE
                                                           AND b.Disburse_AMNT > 0)))
                                  AND NOT EXISTS (SELECT 1
                                                    FROM RPODSL_Y1 b
                                                   WHERE b.Batch_DATE = a.Batch_DATE
                                                     AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                     AND b.Batch_NUMB = a.Batch_NUMB
                                                     AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                     AND b.TypeDisburse_CODE = @Lc_TypeDisburseVrcth_CODE
                                                     AND b.BackOut_INDC = @Lc_Yes_INDC
                                                     AND b.EndValidity_DATE >= @Ad_EndQtr_DATE)))
                    THEN a.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_2b_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcUib_CODE
                        AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RPODSL_Y1 b
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND b.TypeDisburse_CODE = 'LINE1'
                                       AND b.Disburse_AMNT > 0
                                    UNION
                                    SELECT 1
                                      FROM RCTH_Y1 B
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND B.Batch_DATE >= @Ad_BeginQtr_DATE)
                        AND NOT EXISTS (SELECT 1
                                          FROM RPODSL_Y1 q
                                         WHERE q.Batch_DATE = a.Batch_DATE
                                           AND q.SourceReceipt_CODE = a.SourceReceipt_CODE
                                           AND q.Batch_NUMB = a.Batch_NUMB
                                           AND q.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                           AND q.BackOut_INDC = 'Y'
                                           AND q.EndValidity_DATE = @Ld_High_DATE
                                           AND q.MinimumBegin_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcUib_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN a.Disburse_AMNT * -1
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcUib_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND (a.TypeDisburse_CODE = 'NDHLD'
                              OR (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                                  AND (a.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                                        OR (a.BackOut_DATE < @Ad_BeginQtr_DATE
                                            AND a.BackOut_INDC = @Lc_No_INDC
                                            AND EXISTS (SELECT 1
                                                          FROM RPODSL_Y1 b
                                                         WHERE b.Batch_DATE = a.Batch_DATE
                                                           AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                           AND b.Batch_NUMB = a.Batch_NUMB
                                                           AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                           AND b.TypeDisburse_CODE = @Lc_TypeDisburseLine1_CODE
                                                           AND b.Disburse_AMNT > 0)))
                                  AND NOT EXISTS (SELECT 1
                                                    FROM RPODSL_Y1 b
                                                   WHERE b.Batch_DATE = a.Batch_DATE
                                                     AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                     AND b.Batch_NUMB = a.Batch_NUMB
                                                     AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                     AND b.TypeDisburse_CODE = @Lc_TypeDisburseVrcth_CODE
                                                     AND b.BackOut_INDC = @Lc_Yes_INDC
                                                     AND b.EndValidity_DATE >= @Ad_EndQtr_DATE)))
                    THEN a.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_2c_amt,
                  0 AS line_2d_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwage_CODE
                        AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RPODSL_Y1 b
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND b.TypeDisburse_CODE = 'LINE1'
                                       AND b.Disburse_AMNT > 0
                                    UNION
                                    SELECT 1
                                      FROM RCTH_Y1 B
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND B.Batch_DATE >= @Ad_BeginQtr_DATE)
                        AND NOT EXISTS (SELECT 1
                                          FROM POFL_Y1 p
                                         WHERE p.Batch_DATE = a.Batch_DATE
                                           AND p.SourceBatch_CODE = a.SourceBatch_CODE
                                           AND p.Batch_NUMB = a.Batch_NUMB
                                           AND p.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                           AND p.CheckRecipient_ID = a.CheckRecipient_ID
                                           AND p.Transaction_CODE = 'CHSW'
                                           AND p.TypeDisburse_CODE = 'REFND'
                                           AND ABS(p.RecOverpay_AMNT) = a.Disburse_AMNT)
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwage_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN a.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_2e_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcInterstativdreg_CODE)
                        AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RPODSL_Y1 b
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND b.TypeDisburse_CODE = 'LINE1'
                                       AND b.Disburse_AMNT > 0
                                    UNION
                                    SELECT 1
                                      FROM RCTH_Y1 B
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND B.Batch_DATE >= @Ad_BeginQtr_DATE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcInterstativdreg_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN a.Disburse_AMNT * -1
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcInterstativdreg_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND (a.TypeDisburse_CODE = 'NDHLD'
                              OR (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                                  AND (a.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                                        OR (a.BackOut_DATE < @Ad_BeginQtr_DATE
                                            AND a.BackOut_INDC = @Lc_No_INDC
                                            AND EXISTS (SELECT 1
                                                          FROM RPODSL_Y1 b
                                                         WHERE b.Batch_DATE = a.Batch_DATE
                                                           AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                           AND b.Batch_NUMB = a.Batch_NUMB
                                                           AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                           AND b.TypeDisburse_CODE = @Lc_TypeDisburseLine1_CODE
                                                           AND b.Disburse_AMNT > 0)))
                                  AND NOT EXISTS (SELECT 1
                                                    FROM RPODSL_Y1 b
                                                   WHERE b.Batch_DATE = a.Batch_DATE
                                                     AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                     AND b.Batch_NUMB = a.Batch_NUMB
                                                     AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                     AND b.TypeDisburse_CODE = @Lc_TypeDisburseVrcth_CODE
                                                     AND b.BackOut_INDC = @Lc_Yes_INDC
                                                     AND b.EndValidity_DATE >= @Ad_EndQtr_DATE)))
                    THEN a.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_2f_amt,
                  0 AS line_2g_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE NOT IN (@Lc_ReceiptSrcEmployerwage_CODE, @Lc_ReceiptSrcInterstativdfee_CODE, @Lc_ReceiptSrcInterstativdreg_CODE, @Lc_ReceiptSrcSpecialCollection_CODE,
                                                     @Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcUib_CODE)
                        AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RPODSL_Y1 b
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND b.TypeDisburse_CODE = 'LINE1'
                                       AND b.Disburse_AMNT > 0
                                    UNION
                                    SELECT 1
                                      FROM RCTH_Y1 B
                                     WHERE b.Batch_DATE = a.Batch_DATE
                                       AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND b.Batch_NUMB = a.Batch_NUMB
                                       AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND B.Batch_DATE >= @Ad_BeginQtr_DATE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   WHEN a.SourceReceipt_CODE NOT IN (@Lc_ReceiptSrcAdminretirement_CODE, @Lc_ReceiptSrcAdminsalary_CODE, @Lc_ReceiptSrcAdminvendorpymt_CODE, @Lc_ReceiptSrcEmployerwage_CODE,
                                                     @Lc_ReceiptSrcInterstativdfee_CODE, @Lc_ReceiptSrcInterstativdreg_CODE, @Lc_ReceiptSrcSpecialCollection_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE,
                                                     @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcUib_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN a.Disburse_AMNT * -1
                   WHEN a.SourceReceipt_CODE NOT IN (@Lc_ReceiptSrcAdminretirement_CODE, @Lc_ReceiptSrcAdminsalary_CODE, @Lc_ReceiptSrcAdminvendorpymt_CODE, @Lc_ReceiptSrcEmployerwage_CODE,
                                                     @Lc_ReceiptSrcInterstativdfee_CODE, @Lc_ReceiptSrcInterstativdreg_CODE, @Lc_ReceiptSrcSpecialCollection_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE,
                                                     @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcUib_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND (a.TypeDisburse_CODE = 'NDHLD'
                              OR (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                                  AND NOT EXISTS (SELECT 1
                                                    FROM DHLD_Y1 d
                                                   WHERE d.Batch_DATE = a.Batch_DATE
                                                     AND d.SourceBatch_CODE = a.SourceBatch_CODE
                                                     AND d.Batch_NUMB = a.Batch_NUMB
                                                     AND d.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                     AND d.Transaction_DATE < @Ad_BeginQtr_DATE
                                                     AND D.EndValidity_DATE >= @Ad_EndQtr_DATE
                                                     AND D.EndValidity_DATE != @Ld_High_DATE
                                                     AND D.Status_CODE = 'H'
                                                     AND d.TypeHold_CODE = 'A'
                                                     AND D.Release_DATE >= @Ad_BeginQtr_DATE
                                                     AND d.Transaction_AMNT = Disburse_AMNT)
                                  AND (a.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                                        OR (a.BackOut_DATE < @Ad_BeginQtr_DATE
                                            AND a.BackOut_INDC = @Lc_No_INDC
                                            AND EXISTS (SELECT 1
                                                          FROM RPODSL_Y1  b
                                                         WHERE b.Batch_DATE = a.Batch_DATE
                                                           AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                           AND b.Batch_NUMB = a.Batch_NUMB
                                                           AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                           AND b.TypeDisburse_CODE = @Lc_TypeDisburseLine1_CODE
                                                           AND b.Disburse_AMNT > 0)))
                                  AND NOT EXISTS (SELECT 1
                                                    FROM RPODSL_Y1 b
                                                   WHERE b.Batch_DATE = a.Batch_DATE
                                                     AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                     AND b.Batch_NUMB = a.Batch_NUMB
                                                     AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                     AND b.TypeDisburse_CODE = @Lc_TypeDisburseVrcth_CODE
                                                     AND b.BackOut_INDC = @Lc_Yes_INDC
                                                     AND b.EndValidity_DATE >= @Ad_EndQtr_DATE)))
                    THEN a.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_2h_amt,
                  0 AS line_3_amt,
                  0 AS line_4_amt,
                  CASE
                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcEmployerwage_CODE)
                        AND (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE))
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_4a_amt,
                  CASE
                   WHEN a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistCurrentTanf_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_4ba_amt,
                  CASE
                   WHEN a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistCurrentIve_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_4bb_amt,
                  CASE
                   WHEN a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistFormerTanf_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_4bc_amt,
                  CASE
                   WHEN a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistFormerIve_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_4bd_amt,
                  CASE
                   WHEN a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistFormerMedicaid_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_4be_amt,
                  CASE
                   WHEN a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE, @Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.StatusWelfare_Code IN (@Lc_AssistNever_TEXT, @Lc_AssistFormerNonIvd_TEXT)
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_4bf_amt,
                  0 AS line_4c_amt,
                  0 AS line_5_amt,
                  0 AS line_7aa_amt,
                  0 AS line_7ac_amt,
                  CASE
                   WHEN a.CheckRecipient_ID LIKE @Lc_RfndRecipientTanf_TEXT
                        AND (a.StatusWelfare_Code = @Lc_AssistCurrentTanf_TEXT
                              OR (a.StatusWelfare_Code = @Lc_AssistNever_TEXT
                                  AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCgpaa_CODE, @Lc_DisbursementTypePgpaa_CODE, @Lc_DisbursementTypeAgpaa_CODE, @Lc_DisbursementTypeAgtaa_CODE))
                              OR (a.StatusWelfare_Code IN (@Lc_AssistCurrentNonIvd_TEXT, @Lc_AssistFormerNonIvd_TEXT)
                                  AND a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCgpaa_CODE, @Lc_DisbursementTypePgpaa_CODE)))
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7ba_amt,
                  CASE
                   WHEN a.CheckRecipient_ID = @Lc_CheckRecipientIve_ID
                        AND a.StatusWelfare_Code = @Lc_AssistCurrentIve_TEXT
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7bb_amt,
                  CASE
                   WHEN a.CheckRecipient_ID LIKE @Lc_RfndRecipientTanf_TEXT
                        AND a.StatusWelfare_Code NOT IN (@Lc_AssistCurrentNonIvd_TEXT, @Lc_AssistCurrentTanf_TEXT, @Lc_AssistNever_TEXT)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7bc_amt,
                  CASE
                   WHEN a.CheckRecipient_ID = @Lc_CheckRecipientIve_ID
                        AND a.StatusWelfare_Code = @Lc_AssistFormerIve_TEXT
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7bd_amt,
                  CASE
                   WHEN (a.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR a.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.StatusWelfare_Code = @Lc_AssistCurrentTanf_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7ca_amt,
                  CASE
                   WHEN (a.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR a.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND a.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.StatusWelfare_Code = @Lc_AssistCurrentIve_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7cb_amt,
                  CASE
                   WHEN (a.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR a.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND a.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.StatusWelfare_Code = @Lc_AssistFormerTanf_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7cc_amt,
                  CASE
                   WHEN (a.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR a.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND a.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.StatusWelfare_Code = @Lc_AssistFormerIve_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7cd_amt,
                  CASE
                   WHEN (a.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR a.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND a.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.StatusWelfare_Code IN (@Lc_AssistFormerMedicaid_TEXT, @Lc_AssistCurrentMedicaid_TEXT)
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7ce_amt,
                  CASE
                   WHEN (a.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR a.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND a.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
                        AND a.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.StatusWelfare_Code IN (@Lc_AssistNever_TEXT, @Lc_AssistFormerNonIvd_TEXT) 
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7cf_amt,
                  CASE
                   WHEN ((a.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                        AND a.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistCurrentTanf_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7da_amt,
                  CASE
                   WHEN ((a.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                        AND a.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistCurrentIve_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7db_amt,
                  CASE
                   WHEN ((a.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                        AND a.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistFormerTanf_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7dc_amt,
                  CASE
                   WHEN ((a.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                        AND a.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND a.StatusWelfare_Code = @Lc_AssistFormerIve_TEXT
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7dd_amt,
                  CASE
                   WHEN ((a.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                        AND a.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND a.StatusWelfare_Code IN (@Lc_AssistFormerMedicaid_TEXT, @Lc_AssistCurrentMedicaid_TEXT)
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7de_amt,
                  CASE
                   WHEN (((a.CheckRecipient_ID = @Lc_CheckRecipientIve_ID
                           AND (a.TypeDisburse_CODE NOT LIKE '%IVE'
                                 OR a.TypeDisburse_CODE NOT LIKE '%NFC'))
                           OR a.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND a.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDebt_CODE <> @Lc_DebtTypeMedicalSupp_CODE
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND a.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND a.StatusWelfare_Code IN (@Lc_AssistNever_TEXT, @Lc_AssistCurrentNonIvd_TEXT, @Lc_AssistFormerNonIvd_TEXT)
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7df_amt,
                  0 AS line_7ee_amt,
                  CASE
                   WHEN a.CheckRecipient_ID IN (@Lc_CheckRecipientIrs_ID, @Lc_CheckRecipientDra_ID )
                        AND a.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN
                    CASE
                     WHEN a.StatusCheck_CODE IN (@Lc_VsaStatusVoidnoreissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE,
                                                 @Lc_DisburseStatusRejectedEft_CODE, @Lc_DisburseStatusStopeft_CODE)
                      THEN a.Disburse_AMNT * -1
                     ELSE a.Disburse_AMNT
                    END
                   ELSE 0
                  END AS line_7ef_amt,
                  CASE
                   WHEN a.CheckRecipient_ID = @Lc_CheckRecipientOsr_ID
                    THEN a.Disburse_AMNT
                  END AS line_11_amt
             FROM RPODSL_Y1 a
            WHERE a.StatusCheck_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
              AND ((a.StatusCheck_CODE != @Lc_DisburseStatusCashed_CODE
                    AND a.Process_INDC = @Lc_No_INDC)
                    OR (a.CheckRecipient_ID NOT LIKE @Lc_RfndRecipientTanf_TEXT
                         OR a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientIve_ID, @Lc_CheckRecipientMedi_ID, @Lc_CheckRecipientOsr_ID))
                    OR (a.Process_INDC = @Lc_Yes_INDC
                        AND a.StatusCheck_CODE = @Lc_DisburseStatusCashed_CODE))
              AND a.BackOut_INDC = @Lc_No_INDC
              AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseVrcth_CODE, @Lc_TypeDisburseLine1_CODE, @Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
           UNION ALL
           SELECT r.Batch_DATE,
                  r.SourceBatch_CODE,
                  r.Batch_NUMB,
                  r.SeqReceipt_NUMB,
                  r.PayorMCI_IDNO,
                  r.CheckNo_TEXT,
                  r.Receipt_DATE,
                  0 AS line_1_amt,
                  CASE
                   WHEN r.SourceReceipt_CODE = @Lc_ReceiptSrcSpecialCollection_CODE
                        AND (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_TypeDisburseVrcth_CODE, @Lc_DisbursementTypeRothp_CODE)
                              OR r.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT + ISNULL((SELECT SUM(b.Disburse_AMNT)
                                                     FROM RPODSL_Y1 b
                                                    WHERE b.Batch_DATE = r.Batch_DATE
                                                      AND b.Batch_NUMB = r.Batch_NUMB
                                                      AND b.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                                      AND b.SourceBatch_CODE = r.SourceBatch_CODE
                                                      AND b.TypeDisburse_CODE IN ('AZNIV', 'CZNIV')
                                                      AND b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                                      AND b.EndValidity_DATE >= @Ad_EndQtr_DATE), 0)
                   ELSE 0
                  END AS line_2a_amt,
                  CASE
                   WHEN r.SourceReceipt_CODE IN (@Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE)
                        AND (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_TypeDisburseVrcth_CODE, @Lc_DisbursementTypeRothp_CODE)
                              OR r.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT + ISNULL((SELECT SUM(b.Disburse_AMNT)
                                                     FROM RPODSL_Y1 b
                                                    WHERE b.Batch_DATE = r.Batch_DATE
                                                      AND b.Batch_NUMB = r.Batch_NUMB
                                                      AND b.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                                      AND b.SourceBatch_CODE = r.SourceBatch_CODE
                                                      AND b.TypeDisburse_CODE IN ('AZNIV', 'CZNIV')
                                                      AND b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                                      AND b.EndValidity_DATE >= @Ad_EndQtr_DATE), 0)
                   ELSE 0
                  END AS line_2b_amt,
                  CASE
                   WHEN r.SourceReceipt_CODE = @Lc_ReceiptSrcUib_CODE
                        AND (r.TypeDisburse_CODE = @Lc_TypeDisburseVrcth_CODE
                              OR (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                                  AND r.MinimumBegin_DATE NOT BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE)
                              OR r.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT + ISNULL((SELECT SUM(b.Disburse_AMNT)
                                                     FROM RPODSL_Y1 b
                                                    WHERE b.Batch_DATE = r.Batch_DATE
                                                      AND b.Batch_NUMB = r.Batch_NUMB
                                                      AND b.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                                      AND b.SourceBatch_CODE = r.SourceBatch_CODE
                                                      AND b.TypeDisburse_CODE IN ('AZNIV', 'CZNIV')
                                                      AND b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                                      AND b.EndValidity_DATE >= @Ad_EndQtr_DATE), 0)
                   ELSE 0
                  END AS line_2c_amt,
                  0 AS line_2d_amt,
                  CASE
                   WHEN r.SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwage_CODE
                        AND (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_TypeDisburseVrcth_CODE, @Lc_DisbursementTypeRothp_CODE)
                              OR r.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT
                   ELSE 0
                  END AS line_2e_amt,
                  CASE
                   WHEN r.SourceReceipt_CODE IN (@Lc_ReceiptSrcInterstativdreg_CODE)
                        AND (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_TypeDisburseVrcth_CODE, @Lc_DisbursementTypeRothp_CODE)
                              OR r.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT + ISNULL((SELECT SUM(b.Disburse_AMNT)
                                                     FROM RPODSL_Y1 b
                                                    WHERE b.Batch_DATE = r.Batch_DATE
                                                      AND b.Batch_NUMB = r.Batch_NUMB
                                                      AND b.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                                      AND b.SourceBatch_CODE = r.SourceBatch_CODE
                                                      AND b.TypeDisburse_CODE IN ('AZNIV', 'CZNIV')
                                                      AND b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                                      AND b.EndValidity_DATE >= @Ad_EndQtr_DATE), 0)
                   ELSE 0
                  END AS line_2f_amt,
                  0 AS line_2g_amt,
                  CASE
                   WHEN r.SourceReceipt_CODE NOT IN (@Lc_ReceiptSrcEmployerwage_CODE, @Lc_ReceiptSrcInterstativdfee_CODE, @Lc_ReceiptSrcInterstativdreg_CODE, @Lc_ReceiptSrcSpecialCollection_CODE,
                                                     @Lc_ReceiptSrcStateTaxRefund_CODE, @Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcUib_CODE)
                        AND (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_TypeDisburseVrcth_CODE, @Lc_DisbursementTypeRothp_CODE)
                              OR r.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT + ISNULL((SELECT SUM(b.Disburse_AMNT)
                                                     FROM RPODSL_Y1 b
                                                    WHERE b.Batch_DATE = r.Batch_DATE
                                                      AND b.Batch_NUMB = r.Batch_NUMB
                                                      AND b.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                                      AND b.SourceBatch_CODE = r.SourceBatch_CODE
                                                      AND b.TypeDisburse_CODE IN ('AZNIV', 'CZNIV')
                                                      AND b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                                      AND b.EndValidity_DATE >= @Ad_EndQtr_DATE), 0)
                   ELSE 0
                  END AS line_2h_amt,
                  0 AS line_3_amt,
                  0 AS line_4_amt,
                  CASE
                   WHEN r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_TypeDisburseVrcth_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND (r.StatusWelfare_Code = @Lc_AssistCurrentNonIvd_TEXT
                              OR (r.StatusWelfare_Code != @Lc_AssistCurrentNonIvd_TEXT
                                  AND r.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)))
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND r.SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwage_CODE
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_4a_amt,
                  0 AS line_4ba_amt,
                  0 AS line_4bb_amt,
                  0 AS line_4bc_amt,
                  0 AS line_4bd_amt,
                  0 AS line_4be_amt,
                  CASE
                   WHEN r.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                        AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_TypeDisburseVrcth_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND r.StatusWelfare_Code <> @Lc_AssistCurrentNonIvd_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_4bf_amt,
                  0 AS line_4c_amt,
                  0 AS line_5_amt,
                  0 AS line_7aa_amt,
                  0 AS line_7ac_amt,
                  CASE
                   WHEN r.CheckRecipient_ID LIKE @Lc_RfndRecipientTanf_TEXT
                        AND (r.StatusWelfare_Code = @Lc_AssistCurrentTanf_TEXT
                              OR (r.StatusWelfare_Code = @Lc_AssistNever_TEXT
                                  AND r.TypeDisburse_CODE IN (@Lc_DisbursementTypeCgpaa_CODE, @Lc_DisbursementTypeAgpaa_CODE, @Lc_DisbursementTypePgpaa_CODE, @Lc_DisbursementTypeAgtaa_CODE)))
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeGeneticTest_CODE, @Lc_DebtTypeMedicalSupp_CODE)
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7ba_amt,
                  CASE
                   WHEN r.CheckRecipient_ID = @Lc_CheckRecipientIve_ID
                        AND r.StatusWelfare_Code = @Lc_AssistCurrentIve_TEXT
                        AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7bb_amt,
                  CASE
                   WHEN (r.CheckRecipient_ID LIKE @Lc_RfndRecipientTanf_TEXT
                          OR (LEN(r.CheckRecipient_ID) = 8
                              AND SUBSTRING(r.TypeDisburse_CODE, 2, 1) = 'G'
                              AND SourceReceipt_CODE = 'NR'))
                        AND r.StatusWelfare_Code NOT IN (@Lc_AssistCurrentNonIvd_TEXT, @Lc_AssistCurrentTanf_TEXT, @Lc_AssistNever_TEXT)
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7bc_amt,
                  CASE
                   WHEN r.CheckRecipient_ID = @Lc_CheckRecipientIve_ID
                        AND r.StatusWelfare_Code NOT IN (@Lc_AssistCurrentNonIvd_TEXT, @Lc_AssistCurrentIve_TEXT)
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7bd_amt,
                  CASE
                   WHEN (r.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR r.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND r.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistCurrentTanf_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7ca_amt,
                  CASE
                   WHEN (r.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR r.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND r.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistCurrentIve_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7cb_amt,
                  CASE
                   WHEN (r.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR r.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND r.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistFormerTanf_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7cc_amt,
                  CASE
                   WHEN (r.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR r.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND r.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistFormerIve_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7cd_amt,
                  CASE
                   WHEN (r.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR r.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND r.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistFormerMedicaid_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7ce_amt,
                  CASE
                   WHEN (r.CheckRecipient_ID = @Lc_CheckRecipientMedi_ID
                          OR r.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE)
                        AND r.CheckRecipient_CODE != @Lc_RecipientTypeFips_CODE
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.StatusWelfare_Code IN (@Lc_AssistNever_TEXT, @Lc_AssistFormerNonIvd_TEXT)
                        AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                        AND r.TypeDebt_CODE != @Lc_DebtTypeGeneticTest_CODE
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7cf_amt,
                  CASE
                   WHEN ((r.CheckRecipient_ID = @Lc_CheckRecipientIve_ID
                           OR r.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (r.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND r.TypeDisburse_CODE NOT LIKE '%G%'
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistCurrentTanf_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7da_amt,
                  CASE
                   WHEN ((r.CheckRecipient_ID NOT LIKE @Lc_RfndRecipientTanf_TEXT
                          AND r.CheckRecipient_ID NOT IN (@Lc_CheckRecipientIve_ID, @Lc_CheckRecipientMedi_ID))
                          OR (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                               OR (r.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                                   AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE))))
                        AND r.TypeDisburse_CODE NOT LIKE '%G%'
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistCurrentIve_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7db_amt,
                  CASE
                   WHEN ((r.CheckRecipient_ID NOT LIKE @Lc_RfndRecipientTanf_TEXT
                          AND r.CheckRecipient_ID NOT IN (@Lc_CheckRecipientIve_ID, @Lc_CheckRecipientMedi_ID)
                          AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE))
                          OR r.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                          OR (r.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND r.TypeDisburse_CODE NOT LIKE '%G%'
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistFormerTanf_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7dc_amt,
                  CASE
                   WHEN ((r.CheckRecipient_ID NOT LIKE @Lc_RfndRecipientTanf_TEXT
                          AND r.CheckRecipient_ID NOT IN (@Lc_CheckRecipientIve_ID, @Lc_CheckRecipientMedi_ID))
                          OR r.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                          OR (r.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND r.TypeDisburse_CODE NOT LIKE '%G%'
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistFormerIve_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7dd_amt,
                  CASE
                   WHEN ((r.CheckRecipient_ID NOT LIKE @Lc_RfndRecipientTanf_TEXT
                          AND r.CheckRecipient_ID NOT IN (@Lc_CheckRecipientIve_ID, @Lc_CheckRecipientMedi_ID))
                          OR r.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE)
                          OR (r.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND r.TypeDisburse_CODE NOT LIKE '%G%'
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND r.StatusWelfare_Code = @Lc_AssistFormerMedicaid_TEXT
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7de_amt,
                  CASE
                   WHEN (((r.CheckRecipient_ID = @Lc_CheckRecipientIve_ID
                           AND (r.TypeDisburse_CODE NOT LIKE '%IVE'
                                 OR r.TypeDisburse_CODE NOT LIKE '%NFC'))
                           OR r.TypeDisburse_CODE IN (@Lc_DisbursementTypeAxive_CODE, @Lc_DisbursementTypeCxive_CODE, @Lc_DisbursementTypeAznfc_CODE, @Lc_DisbursementTypeCznfc_CODE))
                          OR (r.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeAzniv_CODE, @Lc_DisbursementTypeCzniv_CODE)))
                        AND r.TypeDisburse_CODE NOT LIKE '%G%'
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                        AND r.CheckRecipient_CODE <> @Lc_RecipientTypeFips_CODE
                        AND r.StatusWelfare_Code IN (@Lc_AssistNever_TEXT, @Lc_AssistCurrentNonIvd_TEXT, @Lc_AssistFormerNonIvd_TEXT)
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7df_amt,
                  0 line_7ee_amt,
                  CASE
                   WHEN r.CheckRecipient_ID IN (@Lc_CheckRecipientIrs_ID, @Lc_CheckRecipientDra_ID )
                        AND r.TypeDisburse_CODE NOT LIKE '%G%'
                        AND r.TypeDisburse_CODE != @Lc_Space_TEXT
                        AND r.TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeGeneticTest_CODE)
                        AND r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseVlsup_CODE)
                    THEN r.Disburse_AMNT * -1
                   ELSE 0
                  END AS line_7ef_amt,
                  0 AS line_11_amt
             FROM RPODSL_Y1 r
            WHERE r.BeginValidity_DATE <= @Ad_EndQtr_DATE
              AND r.EndValidity_DATE >= @Ad_EndQtr_DATE
              AND r.BackOut_INDC = @Lc_Yes_INDC
              AND r.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
              AND r.CheckRecipient_ID <> @Lc_CheckRecipientOsr_ID
              AND r.StatusCheck_CODE IN (@Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusCashed_CODE)
              AND (r.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                    OR (r.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                        AND r.MinimumBegin_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE))
              AND r.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseLine9_CODE, @Lc_TypeDisburseLine3_CODE)
              AND (r.MinimumBegin_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                    OR (EXISTS (SELECT 1
                                  FROM RPODSL_Y1 x
                                 WHERE x.Batch_DATE = r.Batch_DATE
                                   AND x.Batch_NUMB = r.Batch_NUMB
                                   AND x.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                   AND x.SourceBatch_CODE = r.SourceBatch_CODE
                                   AND x.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseVrcth_CODE, @Lc_TypeDisburseVlsup_CODE))
                         OR NOT EXISTS (SELECT 1
                                          FROM RPODSL_Y1 y
                                         WHERE y.Batch_DATE = r.Batch_DATE
                                           AND y.Batch_NUMB = r.Batch_NUMB
                                           AND y.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                           AND y.SourceBatch_CODE = r.SourceBatch_CODE
                                           AND y.TypeDisburse_CODE = @Lc_TypeDisburseVlsup_CODE)))) AS fci
    GROUP BY fci.Batch_DATE,
             fci.SourceBatch_CODE,
             fci.Batch_NUMB,
             fci.SeqReceipt_NUMB;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

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
