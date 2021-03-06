/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS
Programmer Name 	: IMP Team
Description			: The process loads the receipt level details required for the OCSE34A - Report
Frequency			: 'MONTHLY/QUATERLY'
Developed On		: 10/14/2011
Called BY			: None
Called On			: BATCH_RPT_OCSE34A$SP_INSERT_LINE9_DETAILS,BATCH_RPT_OCSE34A$SP_INSERT_R34RT,
					  BATCH_RPT_OCSE34A$SP_INSERT_OC34,BATCH_RPT_OCSE34A$SP_ADJUST_DOLLAR_DIFF
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS]
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ad_BeginQtr_DATE         DATE,
 @Ad_EndQtr_DATE           DATE,
 @Ad_PrevBeginQtr_DATE     DATE,
 @Ad_PrevEndQtr_DATE       DATE,
 @Ac_TypeReport_CODE       CHAR(1),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ManuallyDistributeReceipt1810_NUMB INT = 1810,
          @Li_ReceiptDistributed1820_NUMB        INT = 1820,
          @Lc_Space_TEXT                         CHAR (1) = ' ',
          @Lc_No_INDC                            CHAR (1) = 'N',
          @Lc_Yes_INDC                           CHAR (1) = 'Y',
          @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
          @Lc_TypeError_CODE                     CHAR (1) = 'E',
          @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
          @Lc_StatusReceiptUnidentified_CODE     CHAR (1) = 'U',
          @Lc_StatusReceiptHeld_CODE             CHAR (1) = 'H',
          @Lc_TypeRecordOriginal_CODE            CHAR (1) = 'O',
          @Lc_RelationshipCaseDp_TEXT            CHAR (1) = 'D',
          @Lc_CaseTypeNonIvd_CODE                CHAR (1) = 'H',
          @Lc_StatusReceiptRefunded_CODE         CHAR (1) = 'R',
          @Lc_StatusReceiptOthpRefund_CODE       CHAR (1) = 'O',
          @Lc_StatusReceiptIdentified_CODE       CHAR (1) = 'I',
          @Lc_WelfareTypeTanf_CODE               CHAR (1) = 'A',
          @Lc_WelfareTypeNonIve_CODE             CHAR (1) = 'F',
          @Lc_WelfareTypeNonIvd_CODE             CHAR (1) = 'H',
          @Lc_WelfareTypeMedicaid_CODE           CHAR (1) = 'M',
          @Lc_AddrHold_TEXT                      CHAR (1) = 'A',
          @Lc_CheckHold_TEXT                     CHAR (1) = 'C',
          @Lc_RegularHold_TEXT                   CHAR (1) = 'D',
          @Lc_CpHold_TEXT                        CHAR (1) = 'P',
          @Lc_TanfHold_TEXT                      CHAR (1) = 'T',
          @Lc_IvEHold_TEXT                       CHAR (1) = 'E',
          @Lc_DollarHold_TEXT                    CHAR (1) = 'Z',
          @Lc_SPCHold_TEXT                       CHAR (1) = 'I',
          @Lc_DisbursementHold_TEXT              CHAR (1) = 'H',
          @Lc_ReadyForDisbursement_TEXT          CHAR (1) = 'R',
          @Lc_Current_TEXT                       CHAR (1) = 'C',
          @Lc_Former_TEXT                        CHAR (1) = 'F',
          @Lc_ReceiptSrcDirectPaymentCredit_CODE CHAR (2) = 'CD',
          @Lc_DisburseStatusVoidNoReissue_CODE   CHAR (2) = 'VN',
          @Lc_DisburseStatusVoidReissue_CODE     CHAR (2) = 'VR',
          @Lc_DisburseStatusStopNoReissue_CODE   CHAR (2) = 'SN',
          @Lc_DisburseStatusStopReissue_CODE     CHAR (2) = 'SR',
          @Lc_ReceiptSrcEmployerwage_CODE        CHAR (2) = 'EW',
          @Lc_DisburseStatusOutstanding_CODE     CHAR (2) = 'OU',
          @Lc_AssistNever_TEXT                   CHAR (2) = 'NN',
          @Lc_SourceBatchDcs_CODE                CHAR (3) = 'DCS',
          @Lc_ErrorE1310_CODE                    CHAR (5) = 'E1310',
          @Lc_DisbursementTypeRefund_CODE        CHAR (5) = 'REFND',
          @Lc_DisbursementTypeRothp_CODE         CHAR (5) = 'ROTHP',
          @Lc_DisbursementTypeCzniv_CODE         CHAR (5) = 'CZNIV',
          @Lc_DisbursementTypeAzniv_CODE         CHAR (5) = 'AZNIV',
          @Lc_DisbursementTypeCrnaa_CODE         CHAR (5) = 'CRNAA',
          @Lc_TypeDisburseLine3_CODE             CHAR (5) = 'LINE3',
          @Lc_TypeDisburseLine1_CODE             CHAR (5) = 'LINE1',
          @Lc_TypeDisburseLine9_CODE             CHAR (5) = 'LINE9',
          @Lc_TypeDisburseRcth_CODE              CHAR (7) = 'RCTH',
          @Lc_TypeDisburseLsup_CODE              CHAR (7) = 'LSUP',
          @Lc_CheckRecipientOsr_IDNO             CHAR (10) = '999999980',
          @Lc_BatchRunUser_TEXT                  CHAR (30) = 'BATCH',
          @Lc_LookinUnidentifiedRcpt_TEXT        CHAR (30) = 'UNIDENTIFIED RCPT',
          @Lc_LookinHeld_TEXT                    CHAR (30) = 'HELD',
          @Lc_LookinHold_ADDR                    CHAR (30) = 'ADDRESS HOLD',
          @Lc_LookinCheckHold_TEXT               CHAR (30) = 'CHECK HOLD',
          @Lc_LookinRegularHold_TEXT             CHAR (30) = 'REGULAR HOLD',
          @Lc_LookinSpcHold_TEXT                 CHAR (30) = 'SPC HOLD',
          @Lc_LookinPayeeHold_TEXT               CHAR (30) = 'PAYEE HOLD',
          @Lc_LookinWelfareHold_TEXT             CHAR (30) = 'WELFARE HOLD',
          @Lc_LookinDollarHold_TEXT              CHAR (30) = 'LESS THAN $1 HOLD',
          @Ls_Process_NAME                       VARCHAR (100) = 'BATCH_RPT_OCSE34A',
          @Ls_Procedure_NAME                     VARCHAR (100) = 'SP_OCSE34_RECEIPT_LEVEL_DTLS',
          @Ld_Low_DATE                           DATE = '01/01/0001',
          @Ld_High_DATE                          DATE = '12/31/9999',
          @Ld_Start_DATE                         DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_Error_NUMB            NUMERIC (11),
          @Ln_ErrorLine_NUMB        NUMERIC (11),
          @Ln_Line9PrevQtr_AMNT     NUMERIC (11, 2),
          @Ln_Line1CurrentQtr_AMNT  NUMERIC (11, 2),
          @Ln_QNTY                  NUMERIC (19) = 0,
          @Ln_CursorCount_QNTY      NUMERIC (19) = 0,
          @Ln_MismatchCurRow_QNTY   NUMERIC (19) = 0,
          @Ln_Cur_QNTY              NUMERIC (19) = 0,
          @Ln_MismatchRowCount_QNTY NUMERIC (19) = 0,
          @Ln_RowCount_QNTY         NUMERIC (19) = 0,
          @Ls_Sql_TEXT              VARCHAR (100),
          @Ls_Sqldata_TEXT          VARCHAR (1000),
          @Ls_ErrorMessage_TEXT     VARCHAR (1000),
          @Ls_ReceiptKey_TEXT       VARCHAR (1000),
          @Ls_DescriptionError_TEXT VARCHAR (4000);
  DECLARE @Ld_MisMatchCUR_Batch_DATE       DATE,
          @Ln_MisMatchCUR_Batch_NUMB       NUMERIC(4),
          @Ln_MisMatchCUR_SeqReceipt_NUMB  NUMERIC(6),
          @Lc_MisMatchCUR_SourceBatch_CODE CHAR(3),
          @Ln_MisMatchCUR_LineNo1_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo2_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo3_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo4_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo5_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo6_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo8_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo9_AMNT     NUMERIC(11, 2),
          @Ln_MisMatchCUR_LineNo9ab_AMNT   NUMERIC(11, 2);

  CREATE TABLE #Mismatch_P1
   (
     Batch_DATE       DATE,
     Batch_NUMB       NUMERIC(4),
     SeqReceipt_NUMB  NUMERIC(6),
     SourceBatch_CODE CHAR(3),
     LineNo1_AMNT     NUMERIC(11, 2),
     LineNo2_AMNT     NUMERIC(11, 2),
     LineNo3_AMNT     NUMERIC(11, 2),
     LineNo4_AMNT     NUMERIC(11, 2),
     LineNo5_AMNT     NUMERIC(11, 2),
     LineNo6_AMNT     NUMERIC(11, 2),
     LineNo8_AMNT     NUMERIC(11, 2),
     LineNo9_AMNT     NUMERIC(11, 2),
     LineNo9ab_AMNT   NUMERIC(11, 2),
     Row_NUMB         NUMERIC(19)
   );

  BEGIN TRY
   -- Delete the records from R34DR_Y1, RPODSM_Y1, RPODSL_Y1, RPPAID_Y1 and RPOVPY_Y1 
   SET @Ls_Sql_TEXT = 'DELETE TMP TABLE R34DR_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM R34DR_Y1;

   SET @Ls_Sql_TEXT = 'DELETE TMP TABLE RPODSM_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM RPODSM_Y1;

   SET @Ls_Sql_TEXT = 'DELETE TMP TABLE RPODSL_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM RPODSL_Y1;

   SET @Ls_Sql_TEXT = 'DELETE TMP TABLE RPPAID_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM RPPAID_Y1;

   SET @Ls_Sql_TEXT = 'DELETE TMP TABLE RPOVPY_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM RPOVPY_Y1;

   -- Delete the records from R34RT_Y1, R34UD_Y1 and ROC34_Y1 for current quarter.	
   SET @Ls_Sql_TEXT = 'DELETE FROM R34RT_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   DELETE a
     FROM R34RT_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_EndQtr_DATE;

   SET @Ls_Sql_TEXT = 'DELETE FROM R34UD_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   DELETE a
     FROM R34UD_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_EndQtr_DATE;

   SET @Ls_Sql_TEXT = 'DELETE FROM ROC34_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE;

   DELETE a
     FROM ROC34_Y1 a
    WHERE BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND EndQtr_DATE = @Ad_EndQtr_DATE
      AND TypeReport_CODE = @Ac_TypeReport_CODE;

   /*
    Loading RPPAID_Y1 table with all the eligible receipts ::
   Get the receipts posted in the current period and also undistributed receipts posted in the previous period from RCTH_Y1.
   */
   SET @Ls_Sql_TEXT = 'INSERT RPPAID_Y1-RCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   INSERT RPPAID_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB)
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB
     FROM RCTH_Y1 a
    WHERE (a.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
            OR (a.BeginValidity_DATE <= @Ad_EndQtr_DATE
                AND (a.Distribute_DATE = @Ld_Low_DATE
                      OR a.Distribute_DATE > @Ad_EndQtr_DATE)))
      AND a.EndValidity_DATE > @Ad_EndQtr_DATE
      AND a.SourceReceipt_CODE != @Lc_ReceiptSrcDirectPaymentCredit_CODE; ---Direct Payment Credit 
   --Insert Post Distribution Held Receipts from DHLD_Y1 for the current period.
   SET @Ls_Sql_TEXT = 'INSERT RPPAID_Y1-DHLD';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   INSERT RPPAID_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB)
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB
     FROM DHLD_Y1 a
    WHERE a.BeginValidity_DATE <= @Ad_EndQtr_DATE
      AND a.EndValidity_DATE > @Ad_EndQtr_DATE
      AND a.TypeHold_CODE != @Lc_RegularHold_TEXT
      AND a.Batch_DATE != @Ld_Low_DATE;

   SET @Ls_Sql_TEXT = 'POPULATE R34UD_Y1 FOR PREVIOUS QUARTER';
   SET @Ls_Sqldata_TEXT = 'PrevBeginQtr_DATE = ' + CAST(@Ad_PrevBeginQtr_DATE AS VARCHAR) + ', PrevEndQtr_DATE = ' + CAST(@Ad_PrevEndQtr_DATE AS VARCHAR);

   SELECT @Ln_QNTY = COUNT(1)
     FROM R34UD_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_PrevBeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_PrevEndQtr_DATE;

   IF @Ln_QNTY < 1
    BEGIN
     -- Insert undistributed receipt details for the previous period from RCTH_Y1, DHLD_Y1.
     SET @Ls_Sql_TEXT = 'INSERT R34UD_Y1 FOR PREVIOUS QUARTER - 1';
     SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

     INSERT R34UD_Y1
            (BeginQtr_DATE,
             EndQtr_DATE,
             Case_IDNO,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             LookIn_TEXT,
             Trans_DATE,
             Trans_AMNT,
             PayorMCI_IDNO,
             CheckNo_TEXT,
             Receipt_DATE,
             ReasonHold_CODE,
             EventGlobalSeq_NUMB,
             LineP1No_TEXT,
             LineP2A1No_TEXT,
             LineP2B1No_TEXT,
             Hold_DATE,
             ObligationKey_ID,
             TypeDisburse_CODE,
             IvaCase_ID)
     SELECT @Ad_PrevBeginQtr_DATE AS BeginQtr_DATE,
            @Ad_PrevEndQtr_DATE AS EndQtr_DATE,
            a.Case_IDNO,
            a.Batch_DATE,
            a.SourceBatch_CODE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            CASE a.StatusReceipt_CODE
             WHEN @Lc_StatusReceiptUnidentified_CODE
              THEN @Lc_LookinUnidentifiedRcpt_TEXT
             WHEN @Lc_StatusReceiptHeld_CODE
              THEN @Lc_LookinHeld_TEXT
            END AS LookIn_TEXT,
            a.Receipt_DATE AS Trans_DATE,
            a.ToDistribute_AMNT AS Trans_AMNT,
            a.PayorMCI_IDNO,
            a.CheckNo_TEXT,
            a.Receipt_DATE AS Receipt_DATE,
            a.ReasonStatus_CODE AS ReasonHold_CODE,
            a.EventGlobalBeginSeq_NUMB AS EventGlobalSeq_NUMB,
            @Lc_Space_TEXT AS LineP1No_TEXT,
            @Lc_Space_TEXT AS LineP2A1No_TEXT,
            @Lc_Space_TEXT AS LineP2B1No_TEXT,
            a.BeginValidity_DATE AS Hold_DATE,
            @Lc_Space_TEXT AS ObligationKey_ID,
            @Lc_TypeDisburseRcth_CODE AS TypeDisburse_CODE,
            @Lc_Space_TEXT AS IvaCase_ID
       FROM RCTH_Y1 a
      WHERE a.BeginValidity_DATE < @Ad_BeginQtr_DATE
        AND a.EndValidity_DATE > @Ad_BeginQtr_DATE
        AND a.StatusReceipt_CODE IN (@Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptUnidentified_CODE)
     UNION
     SELECT @Ad_PrevBeginQtr_DATE AS BeginQtr_DATE,
            @Ad_PrevEndQtr_DATE AS EndQtr_DATE,
            a.Case_IDNO,
            a.Batch_DATE,
            a.SourceBatch_CODE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            CASE a.TypeHold_CODE
             WHEN @Lc_AddrHold_TEXT
              THEN @Lc_LookinHold_ADDR
             WHEN @Lc_CheckHold_TEXT
              THEN @Lc_LookinCheckHold_TEXT
             WHEN @Lc_RegularHold_TEXT
              THEN @Lc_LookinRegularHold_TEXT
             WHEN @Lc_CpHold_TEXT
              THEN @Lc_LookinPayeeHold_TEXT
             WHEN @Lc_TanfHold_TEXT
              THEN @Lc_LookinWelfareHold_TEXT
             WHEN @Lc_IvEHold_TEXT
              THEN @Lc_LookinWelfareHold_TEXT
             WHEN @Lc_DollarHold_TEXT
              THEN @Lc_LookinDollarHold_TEXT
             WHEN @Lc_SPCHold_TEXT
              THEN @Lc_LookinSpcHold_TEXT
            END AS LookIn_TEXT,
            a.Transaction_DATE,
            a.Transaction_AMNT,
            ISNULL(CASE (SELECT COUNT(m.MemberMci_IDNO)
                           FROM CMEM_Y1 m
                          WHERE m.Case_IDNO = a.Case_IDNO
                            AND m.CaseRelationship_CODE IN ('A', 'P')
                            AND m.CaseMemberStatus_CODE = 'A')
                    WHEN 1
                     THEN (SELECT m.MemberMci_IDNO
                             FROM CMEM_Y1 m
                            WHERE m.Case_IDNO = a.Case_IDNO
                              AND m.CaseRelationship_CODE IN ('A', 'P')
                              AND m.CaseMemberStatus_CODE = 'A')
                    ELSE (SELECT TOP 1 r.payormci_idno
                            FROM rcth_y1 r
                           WHERE a.Batch_DATE = r.Batch_DATE
                             AND a.SourceBatch_CODE = r.SourceBatch_CODE
                             AND a.Batch_NUMB = r.Batch_NUMB
                             AND a.SourceBatch_CODE = r.SourceBatch_CODE
                             AND a.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                             AND r.EndValidity_DATE = @Ld_High_DATE)
                   END, 0) AS PayorMCI_IDNO,
            '0' AS CheckNo_TEXT,
            a.Disburse_DATE,
            a.ReasonStatus_CODE,
            a.Unique_IDNO AS EventGlobalSeq_NUMB,
            @Lc_Space_TEXT AS LineP1No_TEXT,
            @Lc_Space_TEXT AS LineP2A1No_TEXT,
            @Lc_Space_TEXT AS LineP2B1No_TEXT,
            a.BeginValidity_DATE AS Hold_DATE,
            @Lc_Space_TEXT AS ObligationKey_ID,
            a.TypeDisburse_CODE,
            @Lc_Space_TEXT AS IvaCase_ID
       FROM DHLD_Y1 a
      WHERE a.Transaction_DATE < @Ad_BeginQtr_DATE
        AND a.EndValidity_DATE > @Ad_BeginQtr_DATE
        AND a.Batch_DATE != @Ld_Low_DATE
        AND a.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE);
    --line 3 adjustment -- do not consider REFND / ROTHP as HELD 
    END

   SET @Ls_Sql_TEXT = 'INSERT RPPAID_Y1-R34UD_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_PrevBeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_PrevEndQtr_DATE AS VARCHAR) + ', Batch_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR);

   --Insert all eligible receipts in to temporary table RPPAID_Y1 table for further processing.
   INSERT RPPAID_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB)
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB
     FROM R34UD_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_PrevBeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_PrevEndQtr_DATE
      AND a.Batch_DATE != @Ld_Low_DATE
      --  7aa and 7ac details are inserted in R34UD_Y1. Need to avoid these records
      -- these records have Batch_DATE as low date
      AND NOT EXISTS (SELECT 1
                        FROM RPPAID_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB);

   /*
    Loading Driver table R34DR_Y1 with distinct eligible receipts:
    Get Receipts from eligible receipts (RPPAID_Y1), and get fee amount, payor  id, receipt date, receipt source, check no, 
    distributed date, receipts reversed indicator  and reverse date from RCTH_Y1
   */
   SET @Ls_Sql_TEXT = 'INSERT R34DR_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   INSERT R34DR_Y1
          (Seq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Fee_AMNT,
           PayorMCI_IDNO,
           SourceReceipt_CODE,
           Receipt_DATE,
           CheckNo_TEXT,
           BackOut_INDC,
           BackOut_DATE)
   SELECT dd.Seq_IDNO,
          dd.Batch_DATE,
          dd.SourceBatch_CODE,
          dd.Batch_NUMB,
          dd.SeqReceipt_NUMB,
          dd.Fee_AMNT,
          dd.PayorMCI_IDNO,
          dd.SourceReceipt_CODE,
          dd.Receipt_DATE,
          CASE
           WHEN dd.CheckNo_TEXT = ''
            THEN ' '
           ELSE dd.CheckNo_TEXT
          END AS CheckNo_TEXT,
          dd.BackOut_INDC,
          dd.Distribute_DATE
     FROM (SELECT ROW_NUMBER() OVER(PARTITION BY aa.Batch_DATE, aa.SourceBatch_CODE, aa.Batch_NUMB, aa.SeqReceipt_NUMB ORDER BY aa.BackOut_INDC DESC, aa.EventGlobalBeginSeq_NUMB DESC) AS Seq_IDNO,
                  aa.Batch_DATE,
                  aa.SourceBatch_CODE,
                  aa.Batch_NUMB,
                  aa.SeqReceipt_NUMB,
                  aa.Fee_AMNT,
                  aa.PayorMCI_IDNO,
                  aa.SourceReceipt_CODE,
                  aa.Receipt_DATE,
                  aa.CheckNo_TEXT,
                  aa.BackOut_INDC,
                  aa.Distribute_DATE
             FROM RPPAID_Y1 bb,
                  RCTH_Y1 aa
            WHERE bb.Batch_DATE = aa.Batch_DATE
              AND bb.SourceBatch_CODE = aa.SourceBatch_CODE
              AND bb.Batch_NUMB = aa.Batch_NUMB
              AND bb.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
              AND aa.EndValidity_DATE > @Ad_EndQtr_DATE
              AND (aa.SourceBatch_CODE NOT IN (@Lc_SourceBatchDcs_CODE)
                    OR (aa.SourceBatch_CODE IN (@Lc_SourceBatchDcs_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RCTR_Y1 b
                                     WHERE aa.Batch_DATE = b.Batch_DATE
                                       AND aa.Batch_NUMB = b.Batch_NUMB
                                       AND aa.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                       AND aa.SourceBatch_CODE = b.SourceBatch_CODE
                                       AND (b.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                                             OR (b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                                 AND (EXISTS (SELECT 1
                                                                FROM RCTH_Y1 d
                                                               WHERE d.Batch_DATE = aa.Batch_DATE
                                                                 AND d.SourceBatch_CODE = aa.SourceBatch_CODE
                                                                 AND d.Batch_NUMB = aa.Batch_NUMB
                                                                 AND d.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
                                                                 AND ((d.StatusReceipt_CODE != @Lc_DisbursementHold_TEXT
                                                                       AND d.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE)
                                                                       OR d.StatusReceipt_CODE = @Lc_DisbursementHold_TEXT)
                                                                 AND d.EndValidity_DATE > @Ad_EndQtr_DATE)
                                                       OR EXISTS (SELECT 1
                                                                    FROM DHLD_Y1 e
                                                                   WHERE e.Batch_DATE = aa.Batch_DATE
                                                                     AND e.SourceBatch_CODE = aa.SourceBatch_CODE
                                                                     AND e.Batch_NUMB = aa.Batch_NUMB
                                                                     AND e.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
                                                                     AND e.Status_CODE = @Lc_DisbursementHold_TEXT
                                                                     AND e.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                                                                     AND e.EndValidity_DATE >= @Ad_BeginQtr_DATE))))
                                       AND b.EndValidity_DATE > @Ad_EndQtr_DATE)))) dd
    WHERE dd.Seq_IDNO = 1;

   SET @Ls_Sql_TEXT = 'INSERT R34DR_Y1-DHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   INSERT R34DR_Y1
          (Seq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Fee_AMNT,
           PayorMCI_IDNO,
           SourceReceipt_CODE,
           Receipt_DATE,
           CheckNo_TEXT,
           BackOut_INDC,
           BackOut_DATE)
   SELECT t.Seq_IDNO,
          t.Batch_DATE,
          t.SourceBatch_CODE,
          t.Batch_NUMB,
          t.SeqReceipt_NUMB,
          t.Fee_AMNT,
          ISNULL(t.PayorMCI_IDNO, 0) AS PayorMCI_IDNO,
          t.SourceReceipt_CODE,
          t.Receipt_DATE,
          CASE
           WHEN t.Check_NUMB = 0
            THEN '0'
           ELSE CAST(t.Check_NUMB AS VARCHAR)
          END AS CheckNo_TEXT,
          t.BackOut_INDC,
          t.Distribute_DATE
     FROM (SELECT ROW_NUMBER() OVER(PARTITION BY aa.Batch_DATE, aa.SourceBatch_CODE, aa.Batch_NUMB, aa.SeqReceipt_NUMB ORDER BY aa.EventGlobalBeginSeq_NUMB DESC) AS Seq_IDNO,
                  aa.Batch_DATE,
                  aa.SourceBatch_CODE,
                  aa.Batch_NUMB,
                  aa.SeqReceipt_NUMB,
                  0 AS Fee_AMNT,
                  ISNULL(CASE (SELECT COUNT(m.MemberMci_IDNO)
                                 FROM CMEM_Y1 m
                                WHERE m.Case_IDNO = aa.Case_IDNO
                                  AND m.CaseRelationship_CODE IN ('A', 'P')
                                  AND m.CaseMemberStatus_CODE = 'A')
                          WHEN 1
                           THEN (SELECT m.MemberMci_IDNO
                                   FROM CMEM_Y1 m
                                  WHERE m.Case_IDNO = aa.Case_IDNO
                                    AND m.CaseRelationship_CODE IN ('A', 'P')
                                    AND m.CaseMemberStatus_CODE = 'A')
                          ELSE (SELECT TOP 1 r.payormci_idno
                                  FROM rcth_y1 r
                                 WHERE aa.Batch_DATE = r.Batch_DATE
                                   AND aa.SourceBatch_CODE = r.SourceBatch_CODE
                                   AND aa.Batch_NUMB = r.Batch_NUMB
                                   AND aa.SourceBatch_CODE = r.SourceBatch_CODE
                                   AND aa.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                   AND r.EndValidity_DATE = @Ld_High_DATE)
                         END, 0) AS PayorMCI_IDNO,
                  ' ' AS SourceReceipt_CODE,
                  aa.Transaction_DATE AS Receipt_DATE,
                  ' ' AS Check_NUMB,
                  'N' AS BackOut_INDC,
                  aa.Transaction_DATE AS Distribute_DATE
             FROM DHLD_Y1 aa
                  LEFT OUTER JOIN RPPAID_Y1 bb
                   ON bb.Batch_DATE = aa.Batch_DATE
                      AND bb.SourceBatch_CODE = aa.SourceBatch_CODE
                      AND bb.Batch_NUMB = aa.Batch_NUMB
                      AND bb.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
            WHERE ((aa.Status_CODE = @Lc_DisbursementHold_TEXT
                    AND aa.EndValidity_DATE > @Ad_EndQtr_DATE)
                    OR (aa.Status_CODE = @Lc_ReadyForDisbursement_TEXT
                        AND aa.EndValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE))
              AND (aa.SourceBatch_CODE NOT IN (@Lc_SourceBatchDcs_CODE)
                    OR (aa.SourceBatch_CODE IN (@Lc_SourceBatchDcs_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RCTR_Y1 b
                                     WHERE aa.Batch_DATE = b.Batch_DATE
                                       AND aa.Batch_NUMB = b.Batch_NUMB
                                       AND aa.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                       AND aa.SourceBatch_CODE = b.SourceBatch_CODE
                                       AND ((aa.Status_CODE <> @Lc_DisbursementHold_TEXT
                                             AND b.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE)
                                             OR aa.Status_CODE = @Lc_DisbursementHold_TEXT)
                                       AND b.EndValidity_DATE > @Ad_EndQtr_DATE)))
              AND (NOT EXISTS (SELECT 1
                                 FROM RCTH_Y1 cc
                                WHERE aa.Batch_DATE = cc.Batch_DATE
                                  AND aa.SourceBatch_CODE = cc.SourceBatch_CODE
                                  AND aa.Batch_NUMB = cc.Batch_NUMB
                                  AND aa.SeqReceipt_NUMB = cc.SeqReceipt_NUMB))) t
    WHERE t.Seq_IDNO = 1;

   /*
    Loading RPOVPY_Y1 Obligation Details table RPOVPY_Y1:
   	Get all active Obligation details Case ID, Obligation Key, Check Recipient ID, Debt Type and FIPS from OBLE_Y1
   	and insert in RPOVPY_Y1 table
   */
   SET @Ls_Sql_TEXT = 'INSERT RPOVPY_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   INSERT RPOVPY_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CheckRecipient_ID,
           TypeDisburse_CODE,
           Payee_ID)
   SELECT DISTINCT
          o.Case_IDNO,
          o.OrderSeq_NUMB,
          o.ObligationSeq_NUMB,
          o.MemberMci_IDNO,
          o.TypeDebt_CODE,
          o.Fips_CODE
     FROM OBLE_Y1 o
    WHERE o.EndValidity_DATE > @Ad_EndQtr_DATE
      AND o.BeginValidity_DATE <= @Ad_EndQtr_DATE;

   -- To consider the Refund transactions if it is not disbursed
   SET @Ls_Sql_TEXT = 'INSERT TMP_OCSE34_DHLD - RPODSM_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   INSERT RPODSM_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           DisburseSubSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeDisburse_CODE,
           ReasonStatus_CODE,
           Disburse_AMNT,
           StatusCheck_DATE,
           StatusCheck_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           Receipt_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           BackOut_DATE,
           EventGlobalSeq_NUMB)
   SELECT a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.Disburse_DATE,
          a.DisburseSeq_NUMB,
          0 AS DisburseSubSeq_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.TypeDisburse_CODE,
          ' ' AS ReasonStatus_CODE,
          a.Transaction_AMNT,
          a.Transaction_DATE,
          a.Status_CODE,
          a.BeginValidity_DATE,
          a.EndValidity_DATE,
          x.Receipt_DATE,
          x.SourceReceipt_CODE,
          x.BackOut_INDC,
          'N' AS Process_INDC,
          x.PayorMCI_IDNO,
          x.CheckNo_TEXT,
          x.BackOut_DATE,
          a.EventGlobalBeginSeq_NUMB
     FROM R34DR_Y1 x,
          DHLD_Y1 a
    WHERE x.Batch_DATE = a.Batch_DATE
      AND x.SourceBatch_CODE = a.SourceBatch_CODE
      AND x.Batch_NUMB = a.Batch_NUMB
      AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
      AND a.Status_CODE IN ('R', 'H')
      AND a.TypeDisburse_CODE IN ('REFND', 'ROTHP')
      AND a.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
      AND a.EndValidity_DATE > @Ad_EndQtr_DATE
      -- Include refund rcpts for this qtr only if it was not refunded to the same obligation previously
      AND NOT EXISTS (SELECT 1
                        FROM DHLD_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                         AND a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND a.TypeDisburse_CODE = b.TypeDisburse_CODE
                         AND b.Status_CODE IN (@Lc_ReadyForDisbursement_TEXT, @Lc_DisbursementHold_TEXT)
                         AND b.Transaction_DATE < @Ad_BeginQtr_DATE
                         AND b.EndValidity_DATE >= @Ad_BeginQtr_DATE
                         AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB)
      -- Do not include the receipts which is VN / VR / SN / SR this period
      AND NOT EXISTS (SELECT 1
                        FROM DSBH_Y1 b
                       WHERE a.CheckRecipient_ID = b.CheckRecipient_ID
                         AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                         AND a.Disburse_DATE = b.Disburse_DATE
                         AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                         AND b.StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE)
                         AND b.Disburse_DATE < @Ad_BeginQtr_DATE
                         AND b.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                         AND b.EndValidity_DATE > @Ad_EndQtr_DATE)
      AND NOT EXISTS (SELECT 1
                        FROM DSBC_Y1 c,
                             DSBH_Y1 b
                       WHERE a.CheckRecipient_ID = c.CheckRecipient_ID
                         AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
                         AND a.Disburse_DATE = c.Disburse_DATE
                         AND a.DisburseSeq_NUMB = c.DisburseSeq_NUMB
                         AND c.CheckRecipientOrig_ID = b.CheckRecipient_ID
                         AND c.CheckRecipientOrig_CODE = b.CheckRecipient_CODE
                         AND c.DisburseOrig_DATE = b.Disburse_DATE
                         AND c.DisburseOrigSeq_NUMB = b.DisburseSeq_NUMB
                         AND b.StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE)
                         AND b.Disburse_DATE < @Ad_BeginQtr_DATE
                         AND b.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                         AND b.EndValidity_DATE > @Ad_EndQtr_DATE);

   -- Get eligible receipts (R34DR_Y1) Disbursed money details from DSBL_Y1 and DSBH_Y1.
   SET @Ls_Sql_TEXT = 'INSERT TMP_OCSE34_DISB_DSBL - RPODSM_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + 'Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   INSERT RPODSM_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           DisburseSubSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeDisburse_CODE,
           ReasonStatus_CODE,
           Disburse_AMNT,
           StatusCheck_DATE,
           StatusCheck_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           Receipt_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           BackOut_DATE,
           EventGlobalSeq_NUMB)
   SELECT a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.Disburse_DATE,
          a.DisburseSeq_NUMB,
          0 AS DisburseSubSeq_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.TypeDisburse_CODE,
          b.ReasonStatus_CODE,
          a.Disburse_AMNT,
          b.StatusCheck_DATE,
          b.StatusCheck_CODE,
          b.BeginValidity_DATE,
          b.EndValidity_DATE,
          x.Receipt_DATE,
          x.SourceReceipt_CODE,
          'N' AS BackOut_INDC,
          @Lc_No_INDC AS Process_INDC,
          x.PayorMCI_IDNO,
          x.CheckNo_TEXT,
          x.BackOut_DATE,
          a.EventGlobalSeq_NUMB
     FROM R34DR_Y1 x,
          DSBL_Y1 a,
          DSBH_Y1 b
    WHERE x.Batch_DATE = a.Batch_DATE
      AND x.SourceBatch_CODE = a.SourceBatch_CODE
      AND x.Batch_NUMB = a.Batch_NUMB
      AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
      AND b.CheckRecipient_ID = a.CheckRecipient_ID
      AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
      AND b.Disburse_DATE = a.Disburse_DATE
      AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB
      AND ((b.StatusCheck_CODE NOT IN ('SN', 'VN', 'RE', 'VR', 'SR')
            AND b.Disburse_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
            -- CZNIV/ AZNIV holds should not be considered on a void/reissue in similar lines as refunds
            AND (a.TypeDisburse_CODE NOT IN ('REFND', 'ROTHP', 'CZNIV', 'AZNIV')
                  OR (a.TypeDisburse_CODE IN ('REFND', 'ROTHP')
                      AND ((x.BackOut_INDC = @Lc_No_INDC)
                            OR (x.BackOut_INDC = 'Y'
                                AND x.BackOut_DATE NOT BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE))
                      AND (NOT EXISTS (SELECT 1
                                         FROM RCTH_Y1 z
                                        WHERE z.Batch_DATE = a.Batch_DATE
                                          AND z.Batch_NUMB = a.Batch_NUMB
                                          AND z.SourceBatch_CODE = a.SourceBatch_CODE
                                          AND z.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                          AND z.BeginValidity_DATE < @Ad_BeginQtr_DATE)
                            OR EXISTS (SELECT 1
                                         FROM R34UD_Y1 z
                                        WHERE z.Batch_DATE = a.Batch_DATE
                                          AND z.Batch_NUMB = a.Batch_NUMB
                                          AND z.SourceBatch_CODE = a.SourceBatch_CODE
                                          AND z.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                          AND z.BeginQtr_DATE = @Ad_PrevBeginQtr_DATE
                                          AND z.EndQtr_DATE = @Ad_PrevEndQtr_DATE
                                          AND z.Trans_AMNT > 0))
                      --to disregard a refund if it was released from a hold in previous qtr
                      -- this refund would not have been reported previously so we should
                      -- not report this qtr                                          
                      AND NOT EXISTS (SELECT 1
                                        FROM DHLD_Y1 n
                                       WHERE n.Batch_DATE = a.Batch_DATE
                                         AND n.Batch_NUMB = a.Batch_NUMB
                                         AND n.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                         AND n.SourceBatch_CODE = a.SourceBatch_CODE
                                         AND n.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                         AND n.EventGlobalSupportSeq_NUMB = a.EventGlobalSupportSeq_NUMB)
                      -- If a receipt was already refunded last qtr and is being voided and reissued this qtr
                      -- do not pick up such receipts
                      AND NOT EXISTS (SELECT 1
                                        FROM DSBC_Y1 c,
                                             DSBH_Y1 b
                                       WHERE a.CheckRecipient_ID = c.CheckRecipient_ID
                                         AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
                                         AND a.Disburse_DATE = c.Disburse_DATE
                                         AND a.DisburseSeq_NUMB = c.DisburseSeq_NUMB
                                         AND c.CheckRecipientOrig_ID = b.CheckRecipient_ID
                                         AND c.CheckRecipientOrig_CODE = b.CheckRecipient_CODE
                                         AND c.DisburseOrig_DATE = b.Disburse_DATE
                                         AND c.DisburseOrigSeq_NUMB = b.DisburseSeq_NUMB
                                         AND b.StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE)
                                         AND b.Disburse_DATE < @Ad_BeginQtr_DATE
                                         AND b.EndValidity_DATE > @Ad_EndQtr_DATE))
                  -- CZNIV/ AZNIV holds should not be considered on a void/reissue in similar lines as refunds
                  OR (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                      AND NOT EXISTS (SELECT 1
                                        FROM DSBC_Y1 c,
                                             DSBH_Y1 b
                                       WHERE a.CheckRecipient_ID = c.CheckRecipient_ID
                                         AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
                                         AND a.Disburse_DATE = c.Disburse_DATE
                                         AND a.DisburseSeq_NUMB = c.DisburseSeq_NUMB
                                         AND c.CheckRecipientOrig_ID = b.CheckRecipient_ID
                                         AND c.CheckRecipientOrig_CODE = b.CheckRecipient_CODE
                                         AND c.DisburseOrig_DATE = b.Disburse_DATE
                                         AND c.DisburseOrigSeq_NUMB = b.DisburseSeq_NUMB
                                         AND x.SourceReceipt_CODE <> @Lc_ReceiptSrcEmployerwage_CODE
                                         AND b.StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusStopReissue_CODE)
                                         AND b.Disburse_DATE < @Ad_BeginQtr_DATE
                                         AND b.EndValidity_DATE > @Ad_EndQtr_DATE))))
            OR (b.StatusCheck_CODE IN ('SN', 'VN', 'RE', 'VR', 'SR')
                AND b.Disburse_DATE < @Ad_BeginQtr_DATE
                -- CZNIV/ AZNIV holds should not be considered on a void/reissue in similar lines as refunds
                AND (a.TypeDisburse_CODE NOT IN ('REFND', 'ROTHP', 'CZNIV', 'AZNIV')
                      OR (a.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
                          AND x.SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwage_CODE))))
      AND b.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
      AND b.EndValidity_DATE > @Ad_EndQtr_DATE
      AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(x.EventGlobalBeginSeq_NUMB)
                                          FROM DSBH_Y1 x
                                         WHERE a.Disburse_DATE = x.Disburse_DATE
                                           AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                           AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                           AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                           AND x.BeginValidity_DATE <= @Ad_EndQtr_DATE);

   --Get eligible receipts (R34DR_Y1) Offset Recovered money details from POFL_Y1.
   SET @Ls_Sql_TEXT = 'INSERT TMP_OCSE34_DISB_DSBL_POFL_LWEL - RPODSM_Y1';
   SET @Ls_Sqldata_TEXT = 'ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_DisburseStatusOutstanding_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   INSERT RPODSM_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           DisburseSubSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeDisburse_CODE,
           ReasonStatus_CODE,
           Disburse_AMNT,
           StatusCheck_DATE,
           StatusCheck_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           Receipt_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           BackOut_DATE,
           EventGlobalSeq_NUMB)
   SELECT a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.Transaction_DATE,
          0 AS DisburseSeq_NUMB,
          0 AS DisburseSubSeq_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          CASE
           WHEN a.TypeDisburse_CODE = @Lc_Space_TEXT
                AND a.RecOverpay_AMNT > 0
                AND x.BackOut_INDC = @Lc_No_INDC
            THEN @Lc_DisbursementTypeCrnaa_CODE
           ELSE a.TypeDisburse_CODE
          END AS TypeDisburse_CODE,
          @Lc_Space_TEXT AS ReasonStatus_CODE,
          a.RecOverpay_AMNT,
          a.Transaction_DATE AS StatusCheck_DATE,
          @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
          a.Transaction_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          x.Receipt_DATE,
          x.SourceReceipt_CODE,
          x.BackOut_INDC,
          @Lc_No_INDC AS Process_INDC,
          x.PayorMCI_IDNO,
          x.CheckNo_TEXT,
          x.BackOut_DATE,
          a.EventGlobalSeq_NUMB
     FROM R34DR_Y1 x,
          POFL_Y1 a
    WHERE x.Batch_DATE = a.Batch_DATE
      AND x.SourceBatch_CODE = a.SourceBatch_CODE
      AND x.Batch_NUMB = a.Batch_NUMB
      AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB;

   --Get eligible receipts (R34DR_Y1) Offset Recovered money details from POFL_Y1.
   -- To create podsm entries  with ind backout as 'N' for the vpofl record for which the backout has happened   
   SET @Ls_Sql_TEXT = 'INSERT RPODSM_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + 'ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_DisburseStatusOutstanding_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   INSERT RPODSM_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           DisburseSubSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeDisburse_CODE,
           ReasonStatus_CODE,
           Disburse_AMNT,
           StatusCheck_DATE,
           StatusCheck_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           Receipt_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           BackOut_DATE,
           EventGlobalSeq_NUMB)
   SELECT a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.Transaction_DATE,
          0 AS DisburseSeq_NUMB,
          0 AS DisburseSubSeq_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.TypeDisburse_CODE,
          @Lc_Space_TEXT AS ReasonStatus_CODE,
          -- Since this is the coresponding pofl entry for the positive record in the pofl insert above,
          -- this value here needs to be negative to cause a net effect of 0
          -- for the backout          
          CASE
           WHEN a.TypeDisburse_CODE = 'REFND'
            THEN a.RecOverpay_AMNT * -1
           ELSE a.RecOverpay_AMNT
          END AS ReasonStatus_CODE,
          a.Transaction_DATE AS StatusCheck_DATE,
          @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
          a.Transaction_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          x.Receipt_DATE,
          x.SourceReceipt_CODE,
          @Lc_No_INDC AS BackOut_INDC,
          @Lc_No_INDC AS Process_INDC,
          x.PayorMCI_IDNO,
          x.CheckNo_TEXT,
          x.BackOut_DATE,
          a.EventGlobalSeq_NUMB
     FROM R34DR_Y1 x,
          POFL_Y1 a
    WHERE x.Batch_DATE = a.Batch_DATE
      AND x.SourceBatch_CODE = a.SourceBatch_CODE
      AND x.Batch_NUMB = a.Batch_NUMB
      AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
      AND x.BackOut_INDC = @Lc_Yes_INDC
      AND x.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
      AND a.TypeDisburse_CODE <> @Lc_Space_TEXT;

   -- Get eligible receipts (R34DR_Y1)'s Non-IV-D payment details from LSUP_Y1.
   SET @Ls_Sql_TEXT = 'INSERT TMP_OCSE34_DISB_DSBL_LSUP - RPODSM_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburseLsup_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_DisburseStatusOutstanding_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   INSERT RPODSM_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           DisburseSubSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeDisburse_CODE,
           ReasonStatus_CODE,
           Disburse_AMNT,
           StatusCheck_DATE,
           StatusCheck_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           Receipt_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           BackOut_DATE,
           EventGlobalSeq_NUMB)
   SELECT y.CheckRecipient_ID,
          y.CheckRecipient_CODE,
          y.Distribute_DATE,
          0 AS DisburseSeq_NUMB,
          0 AS DisburseSubSeq_NUMB,
          y.Batch_DATE,
          y.SourceBatch_CODE,
          y.Batch_NUMB,
          y.SeqReceipt_NUMB,
          y.Case_IDNO,
          y.OrderSeq_NUMB,
          y.ObligationSeq_NUMB,
          @Lc_TypeDisburseLsup_CODE AS TypeDisburse_CODE,
          @Lc_Space_TEXT AS ReasonStatus_CODE,
          y.TransactionNaa_AMNT + y.TransactionPaa_AMNT + y.TransactionTaa_AMNT + y.TransactionCaa_AMNT + y.TransactionUpa_AMNT + y.TransactionUda_AMNT + y.TransactionIvef_AMNT + y.TransactionMedi_AMNT + y.TransactionFuture_AMNT + y.TransactionNffc_AMNT + y.TransactionNonIvd_AMNT AS Disburse_AMNT,
          y.Distribute_DATE AS StatusCheck_DATE,
          @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
          y.Distribute_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          x.Receipt_DATE,
          x.SourceReceipt_CODE,
          x.BackOut_INDC,
          @Lc_No_INDC AS Process_INDC,
          x.PayorMCI_IDNO,
          x.CheckNo_TEXT,
          x.BackOut_DATE,
          y.EventGlobalSeq_NUMB
     FROM R34DR_Y1 x,
          LSUP_Y1 y
    WHERE x.SourceReceipt_CODE != @Lc_ReceiptSrcEmployerwage_CODE
      AND x.Batch_DATE = y.Batch_DATE
      AND x.Batch_NUMB = y.Batch_NUMB
      AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
      AND x.SourceBatch_CODE = y.SourceBatch_CODE
      AND y.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB)
      AND y.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND EXISTS (SELECT 1
                    FROM CMEM_Y1 c,
                         MHIS_Y1 d
                   WHERE c.Case_IDNO = y.Case_IDNO
                     AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                     AND d.MemberMci_IDNO = c.MemberMci_IDNO
                     AND d.Case_IDNO = c.Case_IDNO
                     AND d.TypeWelfare_CODE = @Lc_CaseTypeNonIvd_CODE
                     AND d.BeginValidity_DATE <= @Ad_EndQtr_DATE
                     AND x.Receipt_DATE BETWEEN d.Start_DATE AND d.End_DATE);

   -- Included this code to eliminate the receipts that were disbursed in the previous period and
   -- is backed out this period
   SET @Ls_Sql_TEXT = 'INSERT TMP_OCSE34_DISB_DSBL_2 - RPODSM_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + 'EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   INSERT RPODSM_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           DisburseSubSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeDisburse_CODE,
           ReasonStatus_CODE,
           Disburse_AMNT,
           StatusCheck_DATE,
           StatusCheck_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           Receipt_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           BackOut_DATE,
           EventGlobalSeq_NUMB)
   SELECT y.CheckRecipient_ID,
          y.CheckRecipient_CODE,
          y.Disburse_DATE,
          y.DisburseSeq_NUMB,
          0 AS DisburseSubSeq_NUMB,
          y.Batch_DATE,
          y.SourceBatch_CODE,
          y.Batch_NUMB,
          y.SeqReceipt_NUMB,
          y.Case_IDNO,
          y.OrderSeq_NUMB,
          y.ObligationSeq_NUMB,
          y.TypeDisburse_CODE,
          z.ReasonStatus_CODE,
          y.Disburse_AMNT AS Disburse_AMNT,
          z.StatusCheck_DATE,
          z.StatusCheck_CODE,
          z.BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          x.Receipt_DATE,
          x.SourceReceipt_CODE,
          x.BackOut_INDC,
          'N' AS Process_INDC,
          x.PayorMCI_IDNO,
          x.CheckNo_TEXT,
          x.BackOut_DATE,
          y.EventGlobalSeq_NUMB
     FROM R34DR_Y1 x,
          DSBL_Y1 y,
          DSBH_Y1 z
    WHERE x.BackOut_INDC = 'Y'
      AND x.BackOut_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
      AND x.Batch_DATE = y.Batch_DATE
      AND x.SourceBatch_CODE = y.SourceBatch_CODE
      AND x.Batch_NUMB = y.Batch_NUMB
      AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
      AND z.CheckRecipient_ID = y.CheckRecipient_ID
      AND z.CheckRecipient_CODE = y.CheckRecipient_CODE
      AND z.Disburse_DATE = y.Disburse_DATE
      AND z.DisburseSeq_NUMB = y.DisburseSeq_NUMB
      AND z.BeginValidity_DATE <= @Ad_EndQtr_DATE
      AND z.EndValidity_DATE > @Ad_EndQtr_DATE
      AND y.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE);

   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE34A$SP_INSERT_LINE9_DETAILS';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   EXECUTE BATCH_RPT_OCSE34A$SP_INSERT_LINE9_DETAILS
    @Ad_BeginQtr_DATE         = @Ad_BeginQtr_DATE,
    @Ad_EndQtr_DATE           = @Ad_EndQtr_DATE,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   /*
   Loading RPODSL_Y1 table to calculate OCSE-34A lines:
   1. Get the receipt collection and reversed details by using R34DR_Y1 and RCTH_Y1. Make disburse type as 'RCTH'.
   2. Get Disbursement Hold payment details from DHLD_Y1, and make disburse type as 'DHLD'.
   3. Get previous quarter undisbursed payment from R34UD_Y1, and make record type as 'LINE1'
   4. Get the loaded disbursements details from RPODSM_Y1 (Disbursement) by joining RPOVPY_Y1 (Obligation), and get recipient welfare status from MHIS_Y1.
   5. Insert the above selected records into RPODSL_Y1 table.
    */
   SET @Ls_Sql_TEXT = 'INSERT RPODSL_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   WITH Cte
        AS (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.StatusCheck_DATE,
                   a.StatusCheck_CODE,
                   a.TypeDisburse_CODE,
                   a.Disburse_AMNT,
                   ISNULL(aa.TypeDisburse_CODE, @Lc_Space_TEXT) AS TypeDebt_CODE,
                   a.BeginValidity_DATE,
                   a.EndValidity_DATE,
                   a.Receipt_DATE,
                   a.SourceReceipt_CODE,
                   a.BackOut_INDC,
                   aa.Case_IDNO,
                   aa.CheckRecipient_ID AS MemberMci_IDNO,
                   ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB, aa.Case_IDNO, aa.CheckRecipient_ID ORDER BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB, aa.Case_IDNO, aa.CheckRecipient_ID ) AS Row_NUMB,
                   a.Process_INDC,
                   a.PayorMCI_IDNO,
                   a.CheckNo_TEXT,
                   a.BackOut_DATE
              FROM (SELECT pp.Batch_DATE,
                           pp.SourceBatch_CODE,
                           pp.Batch_NUMB,
                           pp.SeqReceipt_NUMB,
                           pp.CheckRecipient_ID,
                           pp.CheckRecipient_CODE,
                           pp.Disburse_DATE,
                           pp.DisburseSeq_NUMB,
                           pp.StatusCheck_DATE,
                           pp.StatusCheck_CODE,
                           pp.TypeDisburse_CODE,
                           pp.BeginValidity_DATE,
                           pp.EndValidity_DATE,
                           pp.Case_IDNO,
                           pp.OrderSeq_NUMB,
                           pp.ObligationSeq_NUMB,
                           CASE
                            WHEN (pp.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE, @Lc_TypeDisburseLsup_CODE)
                                  AND pp.CheckRecipient_ID <> @Lc_CheckRecipientOsr_IDNO)
                             THEN pp.Disburse_AMNT * -1
                            ELSE pp.Disburse_AMNT
                           END AS Disburse_AMNT,
                           pp.SourceReceipt_CODE,
                           pp.Receipt_DATE,
                           pp.BackOut_INDC,
                           pp.Process_INDC,
                           pp.PayorMCI_IDNO,
                           pp.CheckNo_TEXT,
                           pp.BackOut_DATE
                      FROM RPODSM_Y1 pp) AS a
                   LEFT OUTER JOIN RPOVPY_Y1 aa
                    ON a.Case_IDNO = aa.Case_IDNO
                       AND a.OrderSeq_NUMB = aa.OrderSeq_NUMB
                       AND a.ObligationSeq_NUMB = aa.ObligationSeq_NUMB)
   INSERT RPODSL_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           StatusCheck_DATE,
           StatusCheck_CODE,
           TypeDisburse_CODE,
           Disburse_AMNT,
           TypeDebt_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           MinimumBegin_DATE,
           StatusWelfare_CODE,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           Receipt_DATE,
           BackOut_DATE)
   (SELECT y.Batch_DATE,
           y.SourceBatch_CODE,
           y.Batch_NUMB,
           y.SeqReceipt_NUMB,
           @Lc_Space_TEXT AS CheckRecipient_ID,
           @Lc_Space_TEXT AS CheckRecipient_CODE,
           y.BeginValidity_DATE AS StatusCheck_DATE,
           @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
           -- To create a podsl Line3 entry for adjusment amounts
           -- If a receipt is refunded previous qtr/month and then moves to unidentified status this qtr
           -- we will create a line 3 entry to balance the amount in the report
           -- @Lc_TypeDisburseRcth_CODE TypeDisburse_CODE,
           CASE
            WHEN y.StatusReceipt_CODE IN (@Lc_StatusReceiptUnidentified_CODE, @Lc_StatusReceiptHeld_CODE)
                 AND y.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                 AND (y.Distribute_DATE = @Ld_Low_DATE
                       OR y.Distribute_DATE > @Ad_EndQtr_DATE)
                 AND EXISTS (SELECT 1
                               FROM RCTH_Y1 c WITH (INDEX(0))
                              WHERE y.Batch_DATE = c.Batch_DATE
                                AND y.Batch_NUMB = c.Batch_NUMB
                                AND y.SourceBatch_CODE = c.SourceBatch_CODE
                                AND y.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                AND c.StatusReceipt_CODE IN (@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
                                AND c.ToDistribute_AMNT = y.ToDistribute_AMNT
                                AND c.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                AND c.EndValidity_DATE >= @Ad_BeginQtr_DATE)
                 AND ((y.EndValidity_DATE = @Ld_High_DATE
                       AND NOT EXISTS (SELECT 1
                                         FROM RCTH_Y1 d WITH (INDEX(0))
                                        WHERE y.Batch_DATE = d.Batch_DATE
                                          AND y.Batch_NUMB = d.Batch_NUMB
                                          AND y.SourceBatch_CODE = d.SourceBatch_CODE
                                          AND y.SeqReceipt_NUMB = d.SeqReceipt_NUMB
                                          -- receipt must still be in unidentified status only during the qtr
                                          -- if it is in any other status we dont need a line 3 entry
                                          AND d.StatusReceipt_CODE IN(@Lc_StatusReceiptIdentified_CODE, @Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
                                          AND d.ToDistribute_AMNT = y.ToDistribute_AMNT
                                          AND d.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE))
                       OR (y.EndValidity_DATE >= @Ad_BeginQtr_DATE
                           AND EXISTS (SELECT 1
                                         FROM DSBL_Y1 l WITH (INDEX(0))
                                        WHERE y.Batch_DATE = l.Batch_DATE
                                          AND y.Batch_NUMB = l.Batch_NUMB
                                          AND y.SourceBatch_CODE = l.SourceBatch_CODE
                                          AND y.SeqReceipt_NUMB = l.SeqReceipt_NUMB
                                          AND l.Disburse_AMNT = y.ToDistribute_AMNT
                                          AND l.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE)
                                          AND l.Disburse_DATE >= y.EndValidity_DATE
                                          AND l.Disburse_DATE <= @Ad_EndQtr_DATE)))
             THEN @Lc_TypeDisburseLine3_CODE
            ELSE @Lc_TypeDisburseRcth_CODE
           END AS TypeDisburse_CODE,
           CASE
            WHEN y.BackOut_INDC = @Lc_Yes_INDC
             THEN (y.ToDistribute_AMNT + ISNULL((SELECT SUM(c.ToDistribute_AMNT)
                                                   FROM RCTH_Y1 c WITH (INDEX(0))
                                                  WHERE y.Batch_DATE = c.Batch_DATE
                                                    AND y.Batch_NUMB = c.Batch_NUMB
                                                    AND y.SourceBatch_CODE = c.SourceBatch_CODE
                                                    AND y.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                    AND c.Receipt_AMNT <> c.ToDistribute_AMNT
                                                    AND c.StatusReceipt_CODE IN(@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
                                                    AND c.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                                    AND c.EndValidity_DATE >= @Ad_BeginQtr_DATE), 0))
            ELSE y.ToDistribute_AMNT
           END AS Disburse_AMNT,
           @Lc_Space_TEXT AS TypeDebt_CODE,
           y.BeginValidity_DATE,
           y.EndValidity_DATE,
           y.SourceReceipt_CODE,
           y.BackOut_INDC,
           MIN(y.BeginValidity_DATE) OVER(PARTITION BY y.Batch_DATE, y.SourceBatch_CODE, y.Batch_NUMB, y.SeqReceipt_NUMB) AS MinimumBegin_DATE,
           @Lc_Space_TEXT AS StatusWelfare_Code,
           @Lc_No_INDC AS Process_INDC,
           x.PayorMCI_IDNO,
           x.CheckNo_TEXT,
           x.Receipt_DATE,
           x.BackOut_DATE
      FROM R34DR_Y1 x,
           RCTH_Y1 y
     WHERE x.Batch_DATE = y.Batch_DATE
       AND x.SourceBatch_CODE = y.SourceBatch_CODE
       AND x.Batch_NUMB = y.Batch_NUMB
       AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
       AND ((y.BackOut_INDC = @Lc_Yes_INDC
             AND (NOT EXISTS (SELECT 1
                                FROM RCTH_Y1 c WITH (INDEX(0))
                               WHERE y.Batch_DATE = c.Batch_DATE
                                 AND y.Batch_NUMB = c.Batch_NUMB
                                 AND y.SourceBatch_CODE = c.SourceBatch_CODE
                                 AND y.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                 AND ((c.StatusReceipt_CODE IN (@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
                                       AND c.Receipt_AMNT = c.ToDistribute_AMNT)
                                       OR (c.SourceReceipt_CODE != 'EW'
                                           AND EXISTS (SELECT 1
                                                         FROM DHLD_Y1 n WITH (INDEX(0))
                                                        WHERE c.Batch_DATE = n.Batch_DATE
                                                          AND c.Batch_NUMB = n.Batch_NUMB
                                                          AND c.SourceBatch_CODE = n.SourceBatch_CODE
                                                          AND c.SeqReceipt_NUMB = n.SeqReceipt_NUMB
                                                          AND n.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE))))
                                 AND c.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                 AND c.EndValidity_DATE >= @Ad_BeginQtr_DATE))
              --Condition to include reversed N-IVD regular receipts if it was in receipt hold in prior qtr
              --This receipt will be part of Line-1 as undistributed and need to be accounted as a reversal in collection
              OR (EXISTS (SELECT 1
                            FROM RCTH_Y1 c WITH (INDEX(0))
                           WHERE y.Batch_DATE = c.Batch_DATE
                             AND y.Batch_NUMB = c.Batch_NUMB
                             AND y.SourceBatch_CODE = c.SourceBatch_CODE
                             AND y.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                             AND c.StatusReceipt_CODE = 'I'
                             AND c.Receipt_AMNT = c.ToDistribute_AMNT
                             AND c.SourceReceipt_CODE != 'EW'
                             AND EXISTS (SELECT 1
                                           FROM DHLD_Y1 n WITH (INDEX(0))
                                          WHERE C.Batch_DATE = N.Batch_DATE
                                            AND C.Batch_NUMB = N.Batch_NUMB
                                            AND C.SourceBatch_CODE = N.SourceBatch_CODE
                                            AND C.SeqReceipt_NUMB = N.SeqReceipt_NUMB
                                            AND n.TypeDisburse_CODE IN ('CZNIV', 'AZNIV'))
                             AND EXISTS (SELECT 1
                                           FROM R34UD_Y1 y WITH (INDEX(0))
                                          WHERE y.Batch_DATE = c.Batch_DATE
                                            AND y.Batch_NUMB = c.Batch_NUMB
                                            AND y.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                            AND y.SourceBatch_CODE = c.SourceBatch_CODE
                                            AND y.BeginQtr_DATE = @Ad_PrevBeginQtr_DATE
                                            AND y.EndQtr_DATE = @Ad_PrevEndQtr_DATE
                                            AND y.LookIn_TEXT != 'Escheatment'
                                            AND y.LineP1No_TEXT != '9A')
                             AND c.BeginValidity_DATE >= @Ad_BeginQtr_DATE
                             AND c.EndValidity_DATE = @Ld_High_DATE)))
             OR y.BackOut_INDC = @Lc_No_INDC)
    UNION ALL
    SELECT y.Batch_DATE,
           y.SourceBatch_CODE,
           y.Batch_NUMB,
           y.SeqReceipt_NUMB,
           y.CheckRecipient_ID,
           y.CheckRecipient_CODE,
           y.BeginValidity_DATE AS StatusCheck_DATE,
           @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
           @Lc_TypeDisburseLine1_CODE AS TypeDisburse_CODE,
           y.Transaction_AMNT,
           @Lc_Space_TEXT AS TypeDebt_CODE,
           y.BeginValidity_DATE,
           y.EndValidity_DATE,
           x.SourceReceipt_CODE,
           x.BackOut_INDC,
           MIN(y.BeginValidity_DATE) OVER (PARTITION BY y.Batch_DATE, y.SourceBatch_CODE, y.Batch_NUMB, y.SeqReceipt_NUMB) AS MinimumBegin_DATE,
           @Lc_Space_TEXT AS StatusWelfare_CODE,
           @Lc_No_INDC AS Process_INDC,
           x.PayorMCI_IDNO,
           x.CheckNo_TEXT,
           x.Receipt_DATE,
           x.BackOut_DATE
      FROM R34DR_Y1 x,
           DHLD_Y1 y
     WHERE x.Batch_DATE = y.Batch_DATE
       AND x.SourceBatch_CODE = y.SourceBatch_CODE
       AND x.Batch_NUMB = y.Batch_NUMB
       AND x.SeqReceipt_NUMB = y.SeqReceipt_NUMB
       AND y.Status_CODE = @Lc_DisbursementHold_TEXT
       AND y.EndValidity_DATE != @Ld_High_DATE
       AND NOT EXISTS (SELECT 1
                         FROM RCTH_Y1 z
                        WHERE x.Batch_DATE = z.Batch_DATE
                          AND x.SourceBatch_CODE = z.SourceBatch_CODE
                          AND x.Batch_NUMB = z.Batch_NUMB
                          AND x.SeqReceipt_NUMB = z.SeqReceipt_NUMB)
       AND NOT EXISTS (SELECT 1
                         FROM DHLD_Y1 z
                        WHERE x.Batch_DATE = z.Batch_DATE
                          AND x.SourceBatch_CODE = z.SourceBatch_CODE
                          AND x.Batch_NUMB = z.Batch_NUMB
                          AND x.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                          AND z.BeginValidity_DATE < @Ad_BeginQtr_DATE)
       AND NOT EXISTS (SELECT 1
                         FROM R34UD_Y1 z
                        WHERE x.Batch_DATE = z.Batch_DATE
                          AND x.SourceBatch_CODE = z.SourceBatch_CODE
                          AND x.Batch_NUMB = z.Batch_NUMB
                          AND x.SeqReceipt_NUMB = z.SeqReceipt_NUMB)
    UNION ALL
    SELECT z.Batch_DATE,
           z.SourceBatch_CODE,
           z.Batch_NUMB,
           z.SeqReceipt_NUMB,
           @Lc_Space_TEXT AS CheckRecipient_ID,
           @Lc_Space_TEXT AS CheckRecipient_CODE,
           z.Trans_DATE AS StatusCheck_DATE,
           @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
           CASE ISNULL((SELECT TOP 1 1
                          FROM RCTH_Y1 x
                         WHERE x.Batch_DATE = z.Batch_DATE
                           AND x.Batch_NUMB = z.Batch_NUMB
                           AND x.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                           AND x.SourceBatch_CODE = z.SourceBatch_CODE), 0)
            WHEN 0
             THEN
             CASE
              WHEN z.BeginQtr_DATE != @Ad_PrevBeginQtr_DATE
               THEN @Lc_TypeDisburseLine1_CODE
             END
            WHEN 1
             THEN
             CASE
              WHEN z.BeginQtr_DATE = @Ad_BeginQtr_DATE
               THEN @Lc_TypeDisburseLine9_CODE
              ELSE @Lc_TypeDisburseLine1_CODE
             END
           END AS TypeDisburse_CODE,
           z.Trans_AMNT AS Disburse_AMNT,
           @Lc_Space_TEXT AS TypeDebt_CODE,
           z.Trans_DATE AS BeginValidity_DATE,
           @Ld_High_DATE AS EndValidity_DATE,
           @Lc_Space_TEXT AS SourceReceipt_CODE,
           @Lc_No_INDC AS BackOut_INDC,
           z.Trans_DATE AS MinimumBegin_DATE,
           @Lc_Space_TEXT AS StatusWelfare_CODE,
           @Lc_No_INDC AS Process_INDC,
           z.PayorMCI_IDNO,
           z.CheckNo_TEXT,
           ISNULL(z.Receipt_DATE, @Ld_Low_DATE) AS Receipt_DATE,
           @Ld_Low_DATE AS BackOut_DATE
      FROM R34UD_Y1 z
     WHERE ((z.BeginQtr_DATE = @Ad_BeginQtr_DATE
             AND z.EndQtr_DATE = @Ad_EndQtr_DATE)
             OR (z.BeginQtr_DATE = @Ad_PrevBeginQtr_DATE
                 AND z.EndQtr_DATE = @Ad_PrevEndQtr_DATE
                 AND z.LineP1No_TEXT NOT IN ('3', '9A')))
       AND z.Batch_DATE <> @Ld_Low_DATE
    UNION ALL
    SELECT bb.Batch_DATE,
           bb.SourceBatch_CODE,
           bb.Batch_NUMB,
           bb.SeqReceipt_NUMB,
           bb.CheckRecipient_ID,
           bb.CheckRecipient_CODE,
           bb.StatusCheck_DATE,
           bb.StatusCheck_CODE,
           bb.TypeDisburse_CODE,
           bb.Disburse_AMNT,
           bb.TypeDebt_CODE,
           bb.BeginValidity_DATE,
           bb.EndValidity_DATE,
           bb.SourceReceipt_CODE,
           bb.BackOut_INDC,
           bb.BeginValidity_DATE AS MinimumBegin_DATE,
           bb.StatusWelfare_CODE,
           bb.Process_INDC,
           bb.PayorMCI_IDNO,
           bb.CheckNo_TEXT,
           bb.Receipt_DATE,
           bb.BackOut_DATE
      FROM (SELECT ct.Batch_DATE,
                   ct.SourceBatch_CODE,
                   ct.Batch_NUMB,
                   ct.SeqReceipt_NUMB,
                   ct.CheckRecipient_ID,
                   ct.CheckRecipient_CODE,
                   ct.StatusCheck_DATE,
                   ct.StatusCheck_CODE,
                   ct.TypeDisburse_CODE,
                   ct.Disburse_AMNT,
                   ct.TypeDebt_CODE,
                   ct.BeginValidity_DATE,
                   ct.EndValidity_DATE,
                   ct.Receipt_DATE,
                   ct.SourceReceipt_CODE,
                   ct.BackOut_INDC,
                   ct.Case_IDNO,
                   ct.CheckRecipient_ID AS MemberMci_IDNO,
                   (ISNULL((SELECT TOP 1
                           -- Calculate MIN() is changed as TOP 1 & ORDER BY StatusWelfare_Code ASC
                           ISNULL((CASE
                                    WHEN ct.Receipt_DATE <= m.End_DATE
                                         AND m.TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE, @Lc_WelfareTypeNonIvd_CODE)
                                     THEN ISNULL(@Lc_Current_TEXT, '') + ISNULL(m.TypeWelfare_CODE, '')
                                    WHEN m.TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE, @Lc_WelfareTypeNonIvd_CODE, @Lc_WelfareTypeMedicaid_CODE)
                                     THEN ISNULL(@Lc_Former_TEXT, '') + ISNULL(m.TypeWelfare_CODE, '')
                                    ELSE @Lc_AssistNever_TEXT
                                   END), @Lc_AssistNever_TEXT)StatusWelfare_Code
                              FROM MHIS_Y1 m
                             WHERE m.Case_IDNO = ct.Case_IDNO
                               AND m.MemberMci_IDNO = ct.MemberMci_IDNO
                               AND ct.EndValidity_DATE > @Ad_EndQtr_DATE
                               AND m.Start_DATE <= ct.Receipt_DATE
                               AND (m.TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE, @Lc_WelfareTypeNonIvd_CODE, @Lc_WelfareTypeMedicaid_CODE)
                                     OR ct.Receipt_DATE <= m.End_DATE)
                             ORDER BY StatusWelfare_Code ASC), @Lc_AssistNever_TEXT)) AS StatusWelfare_Code,
                   ct.Process_INDC,
                   ct.PayorMCI_IDNO,
                   ct.CheckNo_TEXT,
                   ct.BackOut_DATE
              FROM Cte AS ct) AS bb);

   SET @Ls_Sql_TEXT = 'INSERT RPODSL_Y1-DHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + 'StatusCheck_CODE = ' + ISNULL(@Lc_DisburseStatusOutstanding_CODE, '') + ', TypeDebt_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', StatusWelfare_Code = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', BackOut_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '');

   --To identify the Non - IVD amount which went on hold
   INSERT RPODSL_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           StatusCheck_DATE,
           StatusCheck_CODE,
           TypeDisburse_CODE,
           Disburse_AMNT,
           TypeDebt_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           MinimumBegin_DATE,
           StatusWelfare_CODE,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           Receipt_DATE,
           BackOut_DATE)
   SELECT b.Batch_DATE,
          b.SourceBatch_CODE,
          b.Batch_NUMB,
          b.SeqReceipt_NUMB,
          b.CheckRecipient_ID,
          b.CheckRecipient_CODE,
          b.Transaction_DATE AS StatusCheck_DATE,
          @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
          'NDHLD' AS TypeDisburse_CODE,
          b.Transaction_AMNT AS Disburse_AMNT,
          @Lc_Space_TEXT AS TypeDebt_CODE,
          b.Transaction_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          (SELECT TOP 1 c.SourceReceipt_CODE
             FROM RCTH_Y1 c
            WHERE c.Batch_DATE = b.Batch_DATE
              AND c.Batch_NUMB = b.Batch_NUMB
              AND c.SourceBatch_CODE = b.SourceBatch_CODE
              AND c.SeqReceipt_NUMB = b.SeqReceipt_NUMB
              AND c.EndValidity_DATE = @Ld_High_DATE) AS SourceReceipt_CODE,
          @Lc_No_INDC AS BackOut_INDC,
          b.Transaction_DATE AS MinimumBegin_DATE,
          @Lc_Space_TEXT AS StatusWelfare_CODE,
          @Lc_No_INDC AS Process_INDC,
          0 AS PayorMCI_IDNO,
          0 AS Check_NUMB,
          ISNULL(b.Batch_DATE, @Ld_Low_DATE) AS Receipt_DATE,
          @Ld_Low_DATE AS BackOut_DATE
     FROM DHLD_Y1 b WITH (INDEX(0))
    WHERE b.TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
          -- Need to consider even those receipts that have their dt_beg_validity as last day of the month
          AND b.BeginValidity_DATE <= @Ad_EndQtr_DATE
          AND b.EndValidity_DATE > @Ad_EndQtr_DATE
          AND EXISTS (SELECT 1
                        FROM RPODSL_Y1 a WITH (INDEX(0))
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND a.SourceReceipt_CODE != @Lc_ReceiptSrcEmployerwage_CODE
                         AND a.BeginValidity_DATE <= @Ad_EndQtr_DATE
                         AND a.EndValidity_DATE > @Ad_EndQtr_DATE
                         AND a.BackOut_INDC = @Lc_No_INDC
                         AND a.TypeDisburse_CODE = @Lc_TypeDisburseRcth_CODE)
          -- In addition to a non ivd hold on a receipt we need to check if receipt was distributed this quarter      
          AND EXISTS (SELECT 1
                        FROM DHLD_Y1 x,
                             LSUP_Y1 y
                       WHERE x.Case_IDNO = b.Case_IDNO
                         AND x.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND x.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                         AND x.Batch_DATE = b.Batch_DATE
                         AND x.SourceBatch_CODE = b.SourceBatch_CODE
                         AND x.Batch_NUMB = b.Batch_NUMB
                         AND x.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND x.Case_IDNO = y.Case_IDNO
                         AND x.OrderSeq_NUMB = y.OrderSeq_NUMB
                         AND x.ObligationSeq_NUMB = y.ObligationSeq_NUMB
                         AND x.EventGlobalSupportSeq_NUMB = y.EventGlobalSeq_NUMB
                         AND y.Distribute_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE);

   -- This code creates backout entries for receipts that have been posted last quarter
   -- but end dated from RPOS this quarter. Inorder to avoid mismatch we will treat this as a backout scenario
   SET @Ls_Sql_TEXT = 'RPODSL_Y1 - CREATE RCTH ENTRY FOR END DATED RECEIPTS';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + 'CheckRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_DisburseStatusOutstanding_CODE, '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburseRcth_CODE, '') + ', TypeDebt_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', StatusWelfare_Code = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   INSERT RPODSL_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           StatusCheck_DATE,
           StatusCheck_CODE,
           TypeDisburse_CODE,
           Disburse_AMNT,
           TypeDebt_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           MinimumBegin_DATE,
           StatusWelfare_CODE,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           Receipt_DATE,
           BackOut_DATE)
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          'ENDDATED' AS CheckRecipient_ID,
          @Lc_Space_TEXT AS CheckRecipient_CODE,
          a.BeginValidity_DATE AS StatusCheck_DATE,
          @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
          @Lc_TypeDisburseRcth_CODE AS TypeDisburse_CODE,
          a.ToDistribute_AMNT * -1 AS Disburse_AMNT,
          @Lc_Space_TEXT AS TypeDebt_CODE,
          a.BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.SourceReceipt_CODE,
          @Lc_Yes_INDC AS BackOut_INDC,
          MIN(BeginValidity_DATE) OVER (PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS MinimumBegin_DATE,
          @Lc_Space_TEXT AS StatusWelfare_CODE,
          @Lc_No_INDC AS Process_INDC,
          a.PayorMCI_IDNO,
          0 AS Check_NUMB,
          a.Receipt_DATE,
          a.EndValidity_DATE AS BackOut_DATE
     FROM RCTH_Y1 a
    WHERE a.BeginValidity_DATE < @Ad_BeginQtr_DATE
      AND a.EndValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
      AND NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE b.Batch_DATE = a.Batch_DATE
                         AND b.SourceBatch_CODE = a.SourceBatch_CODE
                         AND b.Batch_NUMB = a.Batch_NUMB
                         AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                         AND b.EndValidity_DATE = @Ld_High_DATE);

   -- This code creates line 3 entries for adjustment when the receipt amount for a receipt that was posted last quarter
   -- is changed this quarter from RPOS for purposes of batch reconcilation
   SET @Ls_Sql_TEXT = 'RPODSL_Y1 - CREATE LINE3 ENTRY FOR RCTH_Y1 AMT CHANGES';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + 'CheckRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_DisburseStatusOutstanding_CODE, '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburseLine3_CODE, '') + ', TypeDebt_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusWelfare_Code = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   INSERT RPODSL_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           StatusCheck_DATE,
           StatusCheck_CODE,
           TypeDisburse_CODE,
           Disburse_AMNT,
           TypeDebt_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           MinimumBegin_DATE,
           StatusWelfare_CODE,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           Receipt_DATE,
           BackOut_DATE)
   SELECT fci.Batch_DATE,
          fci.SourceBatch_CODE,
          fci.Batch_NUMB,
          fci.SeqReceipt_NUMB,
          'AMT CHG' AS CheckRecipient_ID,
          @Lc_Space_TEXT AS CheckRecipient_CODE,
          fci.StatusCheck_DATE,
          @Lc_DisburseStatusOutstanding_CODE AS StatusCheck_CODE,
          @Lc_TypeDisburseLine3_CODE AS TypeDisburse_CODE,
          fci.Disburse_AMNT,
          @Lc_Space_TEXT AS TypeDebt_CODE,
          fci.BeginValidity_DATE,
          fci.EndValidity_DATE,
          fci.SourceReceipt_CODE,
          fci.BackOut_INDC,
          fci.MinimumBegin_DATE,
          @Lc_Space_TEXT AS StatusWelfare_CODE,
          @Lc_No_INDC AS Process_INDC,
          fci.PayorMCI_IDNO,
          0 AS Check_NUMB,
          fci.Receipt_DATE,
          fci.BackOut_DATE
     FROM (SELECT a.Batch_DATE,
                  a.SourceBatch_CODE,
                  a.Batch_NUMB,
                  a.SeqReceipt_NUMB,
                  a.BeginValidity_DATE AS StatusCheck_DATE,
                  a.Receipt_AMNT - ISNULL((SELECT ABS(b.Receipt_AMNT)
                                             FROM RCTH_Y1 b
                                            WHERE b.Batch_DATE = a.Batch_DATE
                                              AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                              AND b.Batch_NUMB = a.Batch_NUMB
                                              AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                              AND b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                              AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(z.EventGlobalBeginSeq_NUMB)
                                                                                  FROM RCTH_Y1 z
                                                                                 WHERE b.Batch_DATE = z.Batch_DATE
                                                                                   AND b.SourceBatch_CODE = z.SourceBatch_CODE
                                                                                   AND b.Batch_NUMB = z.Batch_NUMB
                                                                                   AND b.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                                                                                   AND z.BeginValidity_DATE < @Ad_BeginQtr_DATE)), 0) AS Disburse_AMNT,
                  a.BeginValidity_DATE,
                  a.EndValidity_DATE,
                  a.SourceReceipt_CODE,
                  a.BackOut_INDC,
                  MIN(a.BeginValidity_DATE) OVER (PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS MinimumBegin_DATE,
                  a.PayorMCI_IDNO,
                  a.Receipt_DATE,
                  a.Distribute_DATE AS BackOut_DATE,
                  ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB ORDER BY a.EventGlobalBeginSeq_NUMB DESC ) AS rnm
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
              AND a.EndValidity_DATE > @Ad_EndQtr_DATE
              AND ABS(a.Receipt_AMNT) != (SELECT ABS(b.Receipt_AMNT)
                                            FROM RCTH_Y1 b
                                           WHERE b.Batch_DATE = a.Batch_DATE
                                             AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                             AND b.Batch_NUMB = a.Batch_NUMB
                                             AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                             AND b.BeginValidity_DATE < @Ad_BeginQtr_DATE
                                             AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(z.EventGlobalBeginSeq_NUMB)
                                                                                 FROM RCTH_Y1 z
                                                                                WHERE b.Batch_DATE = z.Batch_DATE
                                                                                  AND b.SourceBatch_CODE = z.SourceBatch_CODE
                                                                                  AND b.Batch_NUMB = z.Batch_NUMB
                                                                                  AND b.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                                                                                  AND z.BeginValidity_DATE < @Ad_BeginQtr_DATE))) AS fci
    WHERE fci.rnm = 1;

   -- Line-3 adjustment amounts added for all receipts that were escheated after refund process. 
   -- This is done since we do not account for refunds on the 34A and the total escheated amounts are displayed 
   -- as part of Line9a causing mismatched totals on Page-2 details
   SET @Ls_Sql_TEXT = 'INSERT RPODSL_Y1 - ESCHEATED';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   INSERT RPODSL_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           StatusCheck_DATE,
           StatusCheck_CODE,
           TypeDisburse_CODE,
           Disburse_AMNT,
           TypeDebt_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           SourceReceipt_CODE,
           BackOut_INDC,
           MinimumBegin_DATE,
           StatusWelfare_CODE,
           Process_INDC,
           PayorMCI_IDNO,
           CheckNo_TEXT,
           Receipt_DATE,
           BackOut_DATE)
   SELECT l.Batch_DATE,
          l.SourceBatch_CODE,
          l.Batch_NUMB,
          l.SeqReceipt_NUMB,
          '999999962' AS CheckRecipient_ID,
          ' ' AS CheckRecipient_CODE,
          r.BeginValidity_DATE AS StatusCheck_DATE,
          'OU' AS StatusCheck_CODE,
          'LINE3' AS TypeDisburse_CODE,
          l.Disburse_AMNT,
          ' ' TypeDebt_CODE,
          r.BeginValidity_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          SourceReceipt_CODE AS SourceReceipt_CODE,
          r.Backout_INDC,
          r.BeginValidity_DATE AS MinimumBegin_DATE,
          ' ' AS StatusWelfare_CODE,
          ' ' AS Process_INDC,
          r.PayorMCI_IDNO,
          0 AS Check_NUMB,
          r.Receipt_DATE,
          @Ld_Low_DATE AS BackOut_DATE
     FROM DSBL_Y1 l,
          DSBH_Y1 h,
          (SELECT DISTINCT
                  a.Batch_DATE,
                  a.SourceBatch_CODE,
                  a.Batch_NUMB,
                  a.SeqReceipt_NUMB,
                  a.SourceReceipt_CODE,
                  a.BeginValidity_DATE,
                  a.Backout_INDC,
                  a.PayorMci_IDNO,
                  a.Receipt_DATE
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE >= @Ad_BeginQtr_DATE
              AND a.BeginValidity_DATE <= @Ad_EndQtr_DATE
              AND a.StatusReceipt_CODE = 'E' -- 'ESCHEATED' 
              AND a.EndValidity_DATE = @Ld_High_DATE) r
    WHERE h.CheckRecipient_ID = '999999962' -- 'ESCHEATED' 
      AND h.CheckRecipient_CODE = '3'
      AND h.Disburse_DATE >= @Ad_BeginQtr_DATE
      AND r.Batch_DATE = l.Batch_DATE
      AND r.SourceBatch_CODE = l.SourceBatch_CODE
      AND r.Batch_NUMB = l.Batch_NUMB
      AND r.SeqReceipt_NUMB = l.SeqReceipt_NUMB
      AND l.CheckRecipient_ID = h.CheckRecipient_ID
      AND l.CheckRecipient_CODE = h.CheckRecipient_CODE
      AND l.Disburse_DATE = h.Disburse_DATE
      AND l.DisburseSeq_NUMB = h.DisburseSeq_NUMB
      AND h.BeginValidity_DATE <= @Ad_BeginQtr_DATE
      AND h.EndValidity_DATE > @Ad_EndQtr_DATE
      AND NOT EXISTS (SELECT 1
                        FROM RPODSM_Y1 p
                       WHERE p.Batch_DATE = l.Batch_DATE
                         AND p.SourceBatch_CODE = l.SourceBatch_CODE
                         AND p.Batch_NUMB = l.Batch_NUMB
                         AND p.SeqReceipt_NUMB = l.SeqReceipt_NUMB
                         AND p.TypeDisburse_CODE = @Lc_TypeDisburseLsup_CODE
                         AND p.Case_IDNO = l.Case_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM R34UD_Y1 a
                       WHERE a.Batch_DATE = l.Batch_DATE
                         AND a.SourceBatch_CODE = l.SourceBatch_CODE
                         AND a.Batch_NUMB = l.Batch_NUMB
                         AND a.SeqReceipt_NUMB = l.SeqReceipt_NUMB
                         AND a.BeginQtr_DATE = @Ad_PrevBeginQtr_DATE
                         AND a.EndQtr_DATE = @Ad_PrevEndQtr_DATE
                         AND a.LookIn_TEXT = @Lc_LookinUnidentifiedRcpt_TEXT);

   SET @Ls_Sql_TEXT = 'UPDATE RPODSL_Y1 - CONVERSION RECEIPTS 1 ';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   UPDATE c
      SET TypeDisburse_CODE = 'LINE1'
     FROM RPODSL_Y1 c
    WHERE c.TypeDisburse_CODE = 'RCTH'
      AND c.EndValidity_DATE > @Ad_EndQtr_DATE
      AND c.BackOut_INDC = 'N'
      AND EXISTS (SELECT 1
                    FROM RCTH_Y1 a,
                         GLEV_Y1 g
                   WHERE a.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB
                     AND c.Batch_DATE = a.Batch_DATE
                     AND c.SourceBatch_CODE = a.SourceBatch_CODE
                     AND c.Batch_NUMB = a.Batch_NUMB
                     AND c.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                     AND a.BeginValidity_DATE >= @Ad_BeginQtr_DATE
                     AND g.Worker_ID = 'CONVERSION'
                     AND g.Process_ID NOT LIKE 'CQ%');

   SET @Ls_Sql_TEXT = 'UPDATE RPODSL_Y1';
   SET @Ls_Sqldata_TEXT = 'BackOut_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE RPODSL_Y1
      SET BackOut_DATE = MinimumBegin_DATE
    WHERE BackOut_DATE = @Ld_Low_DATE
      AND TypeDisburse_CODE IN (@Lc_DisbursementTypeCzniv_CODE, @Lc_DisbursementTypeAzniv_CODE)
      AND EndValidity_DATE = @Ld_High_DATE
      AND SourceReceipt_CODE <> @Lc_ReceiptSrcEmployerwage_CODE;

   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE34A$SP_INSERT_R34RT - INSERT R34RT_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR);

   EXECUTE BATCH_RPT_OCSE34A$SP_INSERT_R34RT
    @Ad_BeginQtr_DATE         = @Ad_BeginQtr_DATE,
    @Ad_EndQtr_DATE           = @Ad_EndQtr_DATE,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'INSERT #Mismatch_P1';
   SET @Ls_Sqldata_TEXT = '';

   -- Cursor added to find the receipts that have mismatch
   INSERT #Mismatch_P1
          (Batch_DATE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           SourceBatch_CODE,
           LineNo1_AMNT,
           LineNo2_AMNT,
           LineNo3_AMNT,
           LineNo4_AMNT,
           LineNo5_AMNT,
           LineNo6_AMNT,
           LineNo8_AMNT,
           LineNo9_AMNT,
           LineNo9ab_AMNT,
           Row_NUMB)
   SELECT a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          a.LineNo1_AMNT,
          a.LineNo2_AMNT,
          a.LineNo3_AMNT,
          a.LineNo4_AMNT,
          a.LineNo5_AMNT,
          a.LineNo6_AMNT,
          a.LineNo8_AMNT,
          a.LineNo9_AMNT,
          a.LineNo9ab_AMNT,
          ROW_NUMBER() OVER (ORDER BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE) AS Row_NUMB
     FROM (SELECT DISTINCT
                  c.Batch_DATE,
                  c.Batch_NUMB,
                  c.SeqReceipt_NUMB,
                  c.SourceBatch_CODE,
                  c.LineNo1_AMNT,
                  c.LineNo2_AMNT,
                  c.LineNo3_AMNT,
                  c.LineNo4_AMNT,
                  c.LineNo5_AMNT,
                  c.LineNo6_AMNT,
                  c.LineNo8_AMNT,
                  c.LineNo9_AMNT,
                  c.LineNo9ab_AMNT
             FROM (SELECT a.Batch_DATE,
                          a.Batch_NUMB,
                          a.SeqReceipt_NUMB,
                          a.SourceBatch_CODE,
                          a.LineNo1_AMNT,
                          a.LineNo2_AMNT,
                          a.LineNo3_AMNT,
                          a.LineNo4_AMNT,
                          a.LineNo5_AMNT,
                          a.LineNo6_AMNT,
                          a.LineNo8_AMNT,
                          a.LineNo9_AMNT,
                          ISNULL(LineNo9ab_AMNT, 0) AS LineNo9ab_AMNT
                     FROM (SELECT DISTINCT
                                  a.Batch_DATE,
                                  a.Batch_NUMB,
                                  a.SeqReceipt_NUMB,
                                  a.SourceBatch_CODE,
                                  SUM(a.LineNo1_AMNT) OVER(PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo1_AMNT,
                                  SUM(a.LineNo2a_AMNT + a.LineNo2b_AMNT + a.LineNo2b_AMNT + a.LineNo2c_AMNT + a.LineNo2d_AMNT + a.LineNo2e_AMNT + a.LineNo2f_AMNT + a.LineNo2g_AMNT + a.LineNo2h_AMNT) OVER (PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo2_AMNT,
                                  SUM(a.LineNo3_AMNT) OVER (PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo3_AMNT,
                                  SUM(a.LineNo4a_AMNT + a.LineNo4ba_AMNT + a.LineNo4bb_AMNT + a.LineNo4bc_AMNT + a.LineNo4bd_AMNT + a.LineNo4be_AMNT + a.LineNo4bf_AMNT + a.LineNo4c_AMNT) OVER (PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo4_AMNT,
                                  SUM(a.LineNo5_AMNT) OVER (PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo5_AMNT,
                                  SUM((a.LineNo1_AMNT + a.LineNo2a_AMNT + a.LineNo2b_AMNT + a.LineNo2c_AMNT + a.LineNo2d_AMNT + a.LineNo2e_AMNT + a.LineNo2f_AMNT + a.LineNo2g_AMNT + a.LineNo2h_AMNT + a.LineNo3_AMNT) - (a.LineNo4a_AMNT + a.LineNo4ba_AMNT + a.LineNo4bb_AMNT + a.LineNo4bc_AMNT + a.LineNo4bd_AMNT + a.LineNo4be_AMNT + a.LineNo4bf_AMNT + a.LineNo4c_AMNT)) OVER (PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo6_AMNT,
                                  SUM (a.LineNo7aa_AMNT + a.LineNo7ac_AMNT + a.LineNo7ba_AMNT + a.LineNo7bb_AMNT + a.LineNo7bc_AMNT + a.LineNo7bd_AMNT + a.LineNo7ca_AMNT + a.LineNo7cb_AMNT + a.LineNo7cc_AMNT + a.LineNo7cd_AMNT + a.LineNo7ce_AMNT + a.LineNo7cf_AMNT + a.LineNo7da_AMNT + a.LineNo7db_AMNT + a.LineNo7dc_AMNT + a.LineNo7dd_AMNT + a.LineNo7de_AMNT + a.LineNo7df_AMNT + a.LineNo7ee_AMNT + a.LineNo7ef_AMNT) OVER (PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE) AS LineNo8_AMNT,
                                  SUM (((a.LineNo1_AMNT + a.LineNo2a_AMNT + a.LineNo2b_AMNT + a.LineNo2c_AMNT + a.LineNo2d_AMNT + a.LineNo2e_AMNT + a.LineNo2f_AMNT + a.LineNo2g_AMNT + a.LineNo2h_AMNT + a.LineNo3_AMNT) - (a.LineNo4a_AMNT + a.LineNo4ba_AMNT + a.LineNo4bb_AMNT + a.LineNo4bc_AMNT + a.LineNo4bd_AMNT + a.LineNo4be_AMNT + a.LineNo4bf_AMNT + a.LineNo4c_AMNT)) - (a.LineNo7aa_AMNT + a.LineNo7ac_AMNT + a.LineNo7ba_AMNT + a.LineNo7bb_AMNT + a.LineNo7bc_AMNT + a.LineNo7bd_AMNT + a.LineNo7ca_AMNT + a.LineNo7cb_AMNT + a.LineNo7cc_AMNT + a.LineNo7cd_AMNT + a.LineNo7ce_AMNT + a.LineNo7cf_AMNT + a.LineNo7da_AMNT + a.LineNo7db_AMNT + a.LineNo7dc_AMNT + a.LineNo7dd_AMNT + a.LineNo7de_AMNT + a.LineNo7df_AMNT + a.LineNo7ee_AMNT + a.LineNo7ef_AMNT)) OVER ( PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo9_AMNT,
                                  SUM(LineNo11_AMNT) OVER (PARTITION BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.SourceBatch_CODE ) AS LineNo11_AMNT
                             FROM R34RT_Y1 a WITH (INDEX(0))
                            WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
                              AND a.EndQtr_DATE = @Ad_EndQtr_DATE) a
                          LEFT OUTER JOIN (SELECT DISTINCT
                                                  r.Batch_DATE,
                                                  r.Batch_NUMB,
                                                  r.SeqReceipt_NUMB,
                                                  r.SourceBatch_CODE,
                                                  SUM(r.Trans_AMNT) OVER (PARTITION BY r.Batch_DATE, r.Batch_NUMB, r.SeqReceipt_NUMB, r.SourceBatch_CODE ) AS LineNo9ab_AMNT
                                             FROM R34UD_Y1 r WITH (INDEX(0))
                                            WHERE r.BeginQtr_DATE = @Ad_BeginQtr_DATE
                                              AND r.EndQtr_DATE = @Ad_EndQtr_DATE) AS b
                           ON a.Batch_DATE = b.Batch_DATE
                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                              AND a.Batch_NUMB = b.Batch_NUMB
                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB) c
            WHERE c.LineNo9_AMNT <> LineNo9ab_AMNT) a;

   SET @Ln_MismatchRowCount_QNTY = @@ROWCOUNT;
   SET @Ln_RowCount_QNTY = 1;

   --	
   WHILE @Ln_RowCount_QNTY <= @Ln_MismatchRowCount_QNTY
    BEGIN
     SELECT @Ld_MisMatchCUR_Batch_DATE = Batch_DATE,
            @Ln_MisMatchCUR_Batch_NUMB = Batch_NUMB,
            @Ln_MisMatchCUR_SeqReceipt_NUMB = SeqReceipt_NUMB,
            @Lc_MisMatchCUR_SourceBatch_CODE = SourceBatch_CODE,
            @Ln_MisMatchCUR_LineNo1_AMNT = LineNo1_AMNT,
            @Ln_MisMatchCUR_LineNo2_AMNT = LineNo2_AMNT,
            @Ln_MisMatchCUR_LineNo3_AMNT = LineNo3_AMNT,
            @Ln_MisMatchCUR_LineNo4_AMNT = LineNo4_AMNT,
            @Ln_MisMatchCUR_LineNo5_AMNT = LineNo5_AMNT,
            @Ln_MisMatchCUR_LineNo6_AMNT = LineNo6_AMNT,
            @Ln_MisMatchCUR_LineNo8_AMNT = LineNo8_AMNT,
            @Ln_MisMatchCUR_LineNo9_AMNT = LineNo9_AMNT,
            @Ln_MisMatchCUR_LineNo9ab_AMNT = LineNo9ab_AMNT
       FROM #Mismatch_P1 A
      WHERE Row_NUMB = @Ln_RowCount_QNTY;

     SET @Ln_RowCount_QNTY = @Ln_RowCount_QNTY + 1;
     SET @Ln_MismatchCurRow_QNTY = @Ln_MismatchCurRow_QNTY + 1;
     SET @Ls_ReceiptKey_TEXT = 'Batch_DATE = ' + CAST(@Ld_MisMatchCUR_Batch_DATE AS CHAR) + ISNULL(@Lc_Space_TEXT, '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_MisMatchCUR_SourceBatch_CODE, '') + ISNULL(@Lc_Space_TEXT, '') + ', , Batch_NUMB = ' + ISNULL(CAST(@Ln_MisMatchCUR_Batch_NUMB AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', , SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_MisMatchCUR_SeqReceipt_NUMB AS VARCHAR), '');
     SET @Ls_DescriptionError_TEXT = 'Batch_DATE = ' + CAST(@Ld_MisMatchCUR_Batch_DATE AS CHAR) + ISNULL(@Lc_Space_TEXT, '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_MisMatchCUR_SourceBatch_CODE, '') + ISNULL(@Lc_Space_TEXT, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_MisMatchCUR_Batch_NUMB AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_MisMatchCUR_SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', LineNo1_AMNT = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo1_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', AMT_LINE_NO_2 = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo2_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', LineNo3_AMNT = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo3_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', LineNo4_AMNT = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo4_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', LineNo5_AMNT = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo5_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', AMT_LINE_NO_6 = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo6_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', AMT_LINE_NO_8 = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo8_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', AMT_LINE_NO_9 = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo9_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '') + ', AMT_LINE_NO_9AB = ' + ISNULL(CAST(@Ln_MisMatchCUR_LineNo9ab_AMNT AS VARCHAR), '') + ISNULL(@Lc_Space_TEXT, '');
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Ac_Job_ID + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeError_CODE + ', Line_NUMB = ' + CAST(0 AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorE1310_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', ListKey_TEXT = ' + @Ls_ReceiptKey_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_ErrorE1310_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_ReceiptKey_TEXT,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ln_CursorCount_QNTY = @@CURSOR_ROWS;
     SET @Ls_Sql_TEXT = 'INSERT R34UD_Y1 - MISMATCH RECEIPT';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_MisMatchCUR_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_MisMatchCUR_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_MisMatchCUR_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_MisMatchCUR_SeqReceipt_NUMB AS VARCHAR), '') + ', BeginQtr_DATE = ' + ISNULL(CAST(@Ad_BeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL(CAST(@Ad_EndQtr_DATE AS VARCHAR), '') + ', ObligationKey_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', IvaCase_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReasonHold_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

     INSERT R34UD_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             BeginQtr_DATE,
             EndQtr_DATE,
             LineP1No_TEXT,
             LookIn_TEXT,
             Case_IDNO,
             Trans_DATE,
             Trans_AMNT,
             LineP2A1No_TEXT,
             EventGlobalSeq_NUMB,
             LineP2B1No_TEXT,
             Hold_DATE,
             PayorMCI_IDNO,
             ObligationKey_ID,
             CheckNo_TEXT,
             Receipt_DATE,
             TypeDisburse_CODE,
             IvaCase_ID,
             ReasonHold_CODE)
     SELECT @Ld_MisMatchCUR_Batch_DATE AS Batch_DATE,
            @Lc_MisMatchCUR_SourceBatch_CODE AS SourceBatch_CODE,
            @Ln_MisMatchCUR_Batch_NUMB AS Batch_NUMB,
            @Ln_MisMatchCUR_SeqReceipt_NUMB AS SeqReceipt_NUMB,
            @Ad_BeginQtr_DATE AS BeginQtr_DATE,
            @Ad_EndQtr_DATE AS EndQtr_DATE,
            '3' AS LineP1No_TEXT,
            'MISMATCH' AS LookIn_TEXT,
            0 AS Case_IDNO,
            (SELECT TOP 1 r.Receipt_DATE
               FROM RCTH_Y1 r
              WHERE r.Batch_DATE = @Ld_MisMatchCUR_Batch_DATE
                AND r.SourceBatch_CODE = @Lc_MisMatchCUR_SourceBatch_CODE
                AND r.Batch_NUMB = @Ln_MisMatchCUR_Batch_NUMB
                AND r.SeqReceipt_NUMB = @Ln_MisMatchCUR_SeqReceipt_NUMB
                AND r.EndValidity_DATE > @Ad_EndQtr_DATE) AS Trans_DATE,
            (@Ln_MisMatchCUR_LineNo9ab_AMNT - @Ln_MisMatchCUR_LineNo9_AMNT) AS Trans_AMNT,
            '0' AS LineP2A1No_TEXT,
            RIGHT(CAST(YEAR(@Ld_MisMatchCUR_Batch_DATE) AS CHAR(4)), 2) + RIGHT('000' + CAST(DATEPART(dy, @Ld_MisMatchCUR_Batch_DATE) AS VARCHAR(3)), 3) AS EventGlobalSeq_NUMB,
            '0' AS LineP2B1No_TEXT,
            @Ld_Low_DATE AS Hold_DATE,
            0 PayorMCI_IDNO,
            @Lc_Space_TEXT AS ObligationKey_ID,
            0 AS CheckNo_TEXT,
            @Ld_Low_DATE AS Receipt_DATE,
            @Lc_Space_TEXT AS TypeDisburse_CODE,
            @Lc_Space_TEXT AS IvaCase_ID,
            @Lc_Space_TEXT AS ReasonHold_CODE;

     SET @Ls_Sql_TEXT = 'UPDATE R34DR_Y1 LINE3 - MISMATCH RECEIPT';
     SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', Batch_DATE = ' + CAST(@Ld_MisMatchCUR_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_MisMatchCUR_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_MisMatchCUR_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_MisMatchCUR_SeqReceipt_NUMB AS VARCHAR);

     UPDATE R34RT_Y1
        SET LineNo3_AMNT = (@Ln_MisMatchCUR_LineNo9ab_AMNT - @Ln_MisMatchCUR_LineNo9_AMNT)
      WHERE BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND EndQtr_DATE = @Ad_EndQtr_DATE
        AND Batch_DATE = @Ld_MisMatchCUR_Batch_DATE
        AND SourceBatch_CODE = @Lc_MisMatchCUR_SourceBatch_CODE
        AND Batch_NUMB = @Ln_MisMatchCUR_Batch_NUMB
        AND SeqReceipt_NUMB = @Ln_MisMatchCUR_SeqReceipt_NUMB;
    END

   -- 1. Insert into R34UD for Line-3 entries already present in RPODSL_Y1
   -- 2. Moved code "SP_INSERT_VOC34" call from before mismatch cursor to after cursor ends    
   -- 3. Removed Line9a amount from  "PREV QTR LINE 9"  comparision	
   SET @Ls_Sql_TEXT = 'INSERT R34UD_Y1 LINE3 - UNPROCESSED RECEIPT';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST(@Ad_BeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL(CAST(@Ad_EndQtr_DATE AS VARCHAR), '') + ', ObligationKey_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReasonHold_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

   INSERT R34UD_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           BeginQtr_DATE,
           EndQtr_DATE,
           LineP1No_TEXT,
           LookIn_TEXT,
           Case_IDNO,
           Trans_DATE,
           Trans_AMNT,
           LineP2A1No_TEXT,
           EventGlobalSeq_NUMB,
           LineP2B1No_TEXT,
           Hold_DATE,
           PayorMci_IDNO,
           ObligationKey_ID,
           CheckNo_TEXT,
           Receipt_DATE,
           TypeDisburse_CODE,
           ReasonHold_CODE,
           IvaCase_ID)
   SELECT Batch_DATE,
          SourceBatch_CODE,
          Batch_NUMB,
          SeqReceipt_NUMB,
          @Ad_BeginQtr_DATE AS BeginQtr_DATE,
          @Ad_EndQtr_DATE AS EndQtr_DATE,
          '3' AS LineP1No_TEXT,
          CASE
           WHEN CAST(CheckRecipient_ID AS VARCHAR) = ' '
            THEN 'REFUNDS UNIDENTIFIED'
           ELSE CAST(CheckRecipient_ID AS VARCHAR)
          END AS LookIn_TEXT,
          0 AS Case_IDNO,
          Receipt_DATE AS Trans_DATE,
          Disburse_AMNT AS Trans_AMNT,
          '0' AS LineP2A1No_TEXT,
          RIGHT(CAST(YEAR(@Ld_MisMatchCUR_Batch_DATE) AS CHAR(4)), 2) + RIGHT('000' + CAST(DATEPART(dy, @Ld_MisMatchCUR_Batch_DATE) AS VARCHAR(3)), 3) AS EventGlobalSeq_NUMB,
          '0' AS LineP2B1No_TEXT,
          @Ld_Low_DATE AS Hold_DATE,
          0 AS PayorMci_IDNO,
          @Lc_Space_TEXT AS ObligationKey_ID,
          CheckNo_TEXT,
          Receipt_DATE,
          @Lc_Space_TEXT AS TypeDisburse_CODE,
          @Lc_Space_TEXT AS ReasonHold_CODE,
          @Lc_Space_TEXT AS IvaCase_ID
     FROM RPODSL_Y1 A
    WHERE TypeDisburse_CODE = @Lc_TypeDisburseLine3_CODE
      AND CheckRecipient_ID <> '999999962';

   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE34A$SP_INSERT_OC34';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE + ', PrevBeginQtr_DATE = ' + CAST(@Ad_PrevBeginQtr_DATE AS VARCHAR) + ', PrevEndQtr_DATE = ' + CAST(@Ad_PrevEndQtr_DATE AS VARCHAR);

   EXECUTE BATCH_RPT_OCSE34A$SP_INSERT_OC34
    @Ad_BeginQtr_DATE         = @Ad_BeginQtr_DATE,
    @Ad_EndQtr_DATE           = @Ad_EndQtr_DATE,
    @Ac_TypeReport_CODE       = @Ac_TypeReport_CODE,
    @Ad_PrevBeginQtr_DATE     = @Ad_PrevBeginQtr_DATE,
    @Ad_PrevEndQtr_DATE       = @Ad_PrevEndQtr_DATE,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PREV QTR LINE 9 VS CURR QTR LINE 1 CHECK';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST(@Ad_PrevBeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL(CAST(@Ad_PrevEndQtr_DATE AS VARCHAR), '') + ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE, '');

   SELECT @Ln_Line9PrevQtr_AMNT = a.Line9a_AMNT
     FROM ROC34_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_PrevBeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_PrevEndQtr_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE;

   SET @Ls_Sql_TEXT = 'PREV QTR LINE 1 VS CURR QTR LINE 1 CHECK';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE;

   SELECT @Ln_Line1CurrentQtr_AMNT = a.Line1_AMNT
     FROM ROC34_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_EndQtr_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE;

   IF (@Ln_Line9PrevQtr_AMNT != @Ln_Line1CurrentQtr_AMNT)
    BEGIN
     SET @Ls_ReceiptKey_TEXT = 'BEGIN_QTR_DATE = ' + CAST (@Ad_BeginQtr_DATE AS CHAR) + ', END_QTR_DATE =' + CAST(@Ad_EndQtr_DATE AS CHAR) + ', PREV_BEGINQTR_DATE=' + CAST(@Ad_PrevEndQtr_DATE AS CHAR) + ', PREV_ENDQTR_DATE=' + CAST(@Ad_PrevEndQtr_DATE AS CHAR) + ', REPORT_TYPE=' + ', LINE1_CURRENT_QTR_AMNT =' + CAST(@Ln_Line1CurrentQtr_AMNT AS CHAR) + ', LINE9_PREV_QTR_AMNT =' + CAST(@Ln_Line9PrevQtr_AMNT AS CHAR);
     SET @Ls_DescriptionError_TEXT = '@Ln_Line9PrevQtr_AMNT  = ' + CAST(@Ln_Line9PrevQtr_AMNT AS CHAR) + ', @Ln_Line1CurrentQtr_AMNT = ' + ISNULL(CAST(@Ln_Line1CurrentQtr_AMNT AS VARCHAR), '');
     SET @Ls_Sql_TEXT = 'PREVIOUS QUARTER LINE 9 DOES NOT MATCH THIS QUARTER LINE 1';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL('0', '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE1310_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_ReceiptKey_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Cur_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE1310_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_ReceiptKey_TEXT,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE34A$SP_ADJUST_DOLLAR_DIFF ';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE + ', PrevBeginQtr_DATE = ' + CAST(@Ad_PrevBeginQtr_DATE AS VARCHAR) + ', PrevEndQtr_DATE = ' + CAST(@Ad_PrevEndQtr_DATE AS VARCHAR);

   EXECUTE BATCH_RPT_OCSE34A$SP_ADJUST_DOLLAR_DIFF
    @Ad_BeginQtr_DATE         = @Ad_BeginQtr_DATE,
    @Ad_EndQtr_DATE           = @Ad_EndQtr_DATE,
    @Ac_TypeReport_CODE       = @Ac_TypeReport_CODE,
    @Ad_PrevBeginQtr_DATE     = @Ad_PrevBeginQtr_DATE,
    @Ad_PrevEndQtr_DATE       = @Ad_PrevEndQtr_DATE,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Process_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END;


GO
