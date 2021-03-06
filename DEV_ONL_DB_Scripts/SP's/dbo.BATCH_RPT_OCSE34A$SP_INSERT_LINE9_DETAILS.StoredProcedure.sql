/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE34A$SP_INSERT_LINE9_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_RPT_OCSE34A$SP_INSERT_LINE9_DETAILS
Programmer Name 	: IMP Team
Description			: The process loads the receipt level details for the Line 9 in the OCSE34A - Report
Frequency			: MONTHLY/QUATERLY
Developed On		: 10/14/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE34A$SP_INSERT_LINE9_DETAILS]
 @Ad_BeginQtr_DATE         DATE,
 @Ad_EndQtr_DATE           DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                     CHAR (1) = ' ',
          @Lc_No_INDC                        CHAR (1) = 'N',
          @Lc_StatusSuccess_CODE             CHAR (1) = 'S',
          @Lc_StatusFailed_CODE              CHAR (1) = 'F',
          @Lc_StatusReceiptIdentified_CODE   CHAR (1) = 'I',
          @Lc_StatusReceiptEscheated_CODE    CHAR (1) = 'E',
          @Lc_StatusReceiptUnidentified_CODE CHAR (1) = 'U',
          @Lc_StatusReceiptHeld_CODE         CHAR (1) = 'H',
          @Lc_RecipientTypeOthp_CODE         CHAR (1) = '3',
          @Lc_DisbursementHold_TEXT          CHAR (1) = 'H',
          @Lc_Hold_ADDR                      CHAR (1) = 'A',
          @Lc_CheckHold_TEXT                 CHAR (1) = 'C',
          @Lc_RegularHold_TEXT               CHAR (1) = 'D',
          @Lc_CpHold_TEXT                    CHAR (1) = 'P',
          @Lc_TanfHold_TEXT                  CHAR (1) = 'T',
          @Lc_IvE1Hold_TEXT                  CHAR (1) = 'E',
          @Lc_DollarHold_TEXT                CHAR (1) = 'Z',
          @Lc_SPCHold_TEXT                   CHAR (1) = 'I',
          @Lc_ReceiptSrcInterstativdfee_CODE CHAR (2) = 'FF',
          @Lc_Lineno9a_TEXT                  CHAR (2) = '9A',
          @Lc_Lineno9b_TEXT                  CHAR (2) = '9B',
          @Lc_Lineno03_TEXT                  CHAR (2) = '3',
          @Lc_Lineno20_TEXT                  CHAR (2) = '20',
          @Lc_Lineno14_TEXT                  CHAR (2) = '14',
          @Lc_Lineno15_TEXT                  CHAR (2) = '15',
          @Lc_Lineno16_TEXT                  CHAR (2) = '16',
          @Lc_Lineno17_TEXT                  CHAR (2) = '17',
          @Lc_Lineno18_TEXT                  CHAR (2) = '18',
          @Lc_Lineno19_TEXT                  CHAR (2) = '19',
          @Lc_SourceBatchDcs_CODE			 CHAR (3) = 'DCS',
          @Lc_HoldRsnMnfn_CODE               CHAR (4) = 'MNFN',
          @Lc_TypeDisburseVlsup_CODE         CHAR (5) = 'LSUP',
          @Lc_CheckRecipientOsr_IDNO         CHAR (10) = '999999980',
          @Lc_CheckRecipientEsch_IDNO        CHAR (10) = '999999983',
          @Lc_LookinReadyForDist_TEXT        CHAR (30) = 'READY FOR DIST',
          @Lc_LookinUnidentifiedRcpt_TEXT    CHAR (30) = 'UNIDENTIFIED RCPT',
          @Lc_LookinHeld_TEXT                CHAR (30) = 'HELD',
          @Lc_LookinHold_ADDR                CHAR (30) = 'ADDRESS HOLD',
          @Lc_LookinCheckHold_TEXT           CHAR (30) = 'CHECK HOLD',
          @Lc_LookinRegularHold_TEXT         CHAR (30) = 'REGULAR HOLD',
          @Lc_LookinPayeeHold_TEXT           CHAR (30) = 'PAYEE HOLD',
          @Lc_LookinWelfareHold_TEXT         CHAR (30) = 'WELFARE HOLD',
          @Lc_LookinDollarHold_TEXT          CHAR (30) = 'LESS THAN $1 HOLD',
          @Lc_LookinSpcHold_TEXT             CHAR (30) = 'SPC HOLD',
          @Lc_LookinEscheatment_TEXT         CHAR (30) = 'ESCHEATMENT',
          @Ls_Procedure_NAME                 VARCHAR (100) = 'SP_INSERT_LINE9_DETAILS',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB        NUMERIC (11),
          @Ln_ErrorLine_NUMB    NUMERIC (11),
          @Ls_Sql_TEXT          VARCHAR (100),
          @Ls_Sqldata_TEXT      VARCHAR (1000),
          @Ls_ErrorMessage_TEXT VARCHAR (4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   ---------------------------------------------------------------------------------------------
	--                                9. Undistributed Collections                             --
	---------------------------------------------------------------------------------------------
	
	--9.1. Held, Errored and Unidentified receipts Detail including receipts posted to NIVD cases.
    --     for receipts that were not reversed as of the end of the qtr.
   SET @Ls_Sql_TEXT = 'INSERT R34UD_Y1 QUERY 1';
   SET @Ls_Sqldata_TEXT = 'ObligationKey_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginQtr_DATE = ' + ISNULL(CAST( @Ad_BeginQtr_DATE AS VARCHAR ),'')+ ', EndQtr_DATE = ' + ISNULL(CAST( @Ad_EndQtr_DATE AS VARCHAR ),'');
   INSERT R34UD_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           ObligationKey_ID,
           PayorMCI_IDNO,
           Trans_DATE,
           Hold_DATE,
           CheckNo_TEXT,
           Trans_AMNT,
           LookIn_TEXT,
           LineP1No_TEXT,
           LineP2A1No_TEXT,
           LineP2B1No_TEXT,
           BeginQtr_DATE,
           EndQtr_DATE,
           ReasonHold_CODE,
           Receipt_DATE,
           TypeDisburse_CODE,
           IvaCase_ID,
           EventGlobalSeq_NUMB)
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.Case_IDNO,
          @Lc_Space_TEXT AS ObligationKey_ID,
          a.PayorMCI_IDNO,
          a.Receipt_DATE,
          @Ld_Low_DATE AS Hold_DATE,
          a.CheckNo_TEXT,
          a.ToDistribute_AMNT,
          CASE a.StatusReceipt_CODE
           WHEN @Lc_StatusReceiptIdentified_CODE
            THEN @Lc_LookinReadyForDist_TEXT
           WHEN @Lc_StatusReceiptEscheated_CODE
            THEN @Lc_LookinReadyForDist_TEXT
           WHEN @Lc_StatusReceiptUnidentified_CODE
            THEN @Lc_LookinUnidentifiedRcpt_TEXT
           WHEN @Lc_StatusReceiptHeld_CODE
            THEN @Lc_LookinHeld_TEXT
          END AS LookIn_TEXT,
          CASE
           WHEN a.StatusReceipt_CODE IN (@Lc_StatusReceiptEscheated_CODE)
            THEN @Lc_Lineno9a_TEXT
           ELSE @Lc_Lineno9b_TEXT
          END AS LineP1No_TEXT,
          CASE
           WHEN a.Receipt_DATE BETWEEN DATEADD(D, -1, @Ad_EndQtr_DATE) AND @Ad_EndQtr_DATE
                AND a.Distribute_DATE = @Ld_Low_DATE
                AND a.EndValidity_DATE > @Ad_EndQtr_DATE
                AND a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
            THEN @Lc_Lineno03_TEXT
           ELSE LTRIM(RTRIM((ISNULL(CAST(CASE u.NumUdcLine_IDNO
                                          WHEN 0
                                           THEN 13
                                          ELSE u.NumUdcLine_IDNO
                                         END AS VARCHAR), '13'))))
          END AS LineP2A1No_TEXT,
          CASE
           WHEN a.Receipt_DATE > @Ad_EndQtr_DATE
            THEN @Lc_Lineno20_TEXT
           ELSE
            CASE
             WHEN DATEDIFF(DD, a.Receipt_DATE, @Ad_EndQtr_DATE) <= 2
              THEN @Lc_Lineno14_TEXT
             WHEN DATEDIFF(DD, a.Receipt_DATE, @Ad_EndQtr_DATE) <= 30
              THEN @Lc_Lineno15_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Receipt_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 0.5
              THEN @Lc_Lineno16_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Receipt_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 1
              THEN @Lc_Lineno17_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Receipt_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 3
              THEN @Lc_Lineno18_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Receipt_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 5
              THEN @Lc_Lineno19_TEXT
             ELSE @Lc_Lineno20_TEXT
            END
          END AS LineP2B1No_TEXT,
          @Ad_BeginQtr_DATE AS BeginQtr_DATE,
          @Ad_EndQtr_DATE AS EndQtr_DATE,
          ISNULL(u.Udc_CODE, @Lc_HoldRsnMnfn_CODE)AS ReasonHold_CODE,
          a.Receipt_DATE AS Receipt_DATE,
          ' ' AS TypeDisburse_CODE,
          ' ' AS IvaCase_ID,
          a.EventGlobalBeginSeq_NUMB
     FROM RCTH_Y1 a
          LEFT OUTER JOIN UCAT_Y1 u
           ON a.ReasonStatus_CODE = u.Udc_CODE
              AND u.EndValidity_DATE = @Ld_High_DATE
    WHERE ((a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
            AND a.Distribute_DATE = @Ld_Low_DATE)
            OR ((a.Distribute_DATE > @Ad_EndQtr_DATE
                  OR a.Distribute_DATE = @Ld_Low_DATE)
                AND a.StatusReceipt_CODE IN (@Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptEscheated_CODE, @Lc_StatusReceiptUnidentified_CODE)))
      -- Include ACS Receipt only if it is reposted          
      AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDcs_CODE)
            OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDcs_CODE)
                AND EXISTS (SELECT 1
                              FROM RCTR_Y1 b
                             WHERE a.Batch_DATE = b.Batch_DATE
                               AND a.Batch_NUMB = b.Batch_NUMB
                               AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                               AND a.SourceBatch_CODE = b.SourceBatch_CODE
                               -- Include ACS Receipt reposted within the quarter
                               -- modified below cond to include reposted ACS receipt still on hold start
                               AND ((b.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE
                                     AND a.StatusReceipt_CODE != @Lc_DisbursementHold_TEXT)
                                     OR a.StatusReceipt_CODE = @Lc_DisbursementHold_TEXT)
                               AND b.EndValidity_DATE > @Ad_EndQtr_DATE)))
      -- Do not Inclued Cost Recovery Fees in Line 2 and Line 7
      AND a.SourceReceipt_CODE != @Lc_ReceiptSrcInterstativdfee_CODE
      AND a.BeginValidity_DATE <= @Ad_EndQtr_DATE
      AND a.EndValidity_DATE > @Ad_EndQtr_DATE;
         
   SET @Ls_Sql_TEXT = 'INSERT R34UD_Y1 - QUERY 2';
   SET @Ls_Sqldata_TEXT = 'LineP1No_TEXT = ' + ISNULL(@Lc_Lineno9b_TEXT,'')+ ', BeginQtr_DATE = ' + ISNULL(CAST( @Ad_BeginQtr_DATE AS VARCHAR ),'')+ ', EndQtr_DATE = ' + ISNULL(CAST( @Ad_EndQtr_DATE AS VARCHAR ),'');
   INSERT R34UD_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           ObligationKey_ID,
           PayorMCI_IDNO,
           Trans_DATE,
           Hold_DATE,
           CheckNo_TEXT,
           Trans_AMNT,
           LookIn_TEXT,
           LineP1No_TEXT,
           LineP2A1No_TEXT,
           LineP2B1No_TEXT,
           BeginQtr_DATE,
           EndQtr_DATE,
           ReasonHold_CODE,
           Receipt_DATE,
           TypeDisburse_CODE,
           IvaCase_ID,
           EventGlobalSeq_NUMB)
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.Case_IDNO,
          ISNULL(ISNULL(LTRIM(RTRIM(b.TypeDisburse_CODE)), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(LTRIM(RTRIM(b.CheckRecipient_ID)), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(CAST(LTRIM(RTRIM(b.Payee_ID)) AS VARCHAR), ''), @Lc_Space_TEXT) AS ObligationKey_ID,
          x.PayorMCI_IDNO,
          a.Transaction_DATE,
         @Ld_Low_DATE AS Hold_DATE,
          x.CheckNo_TEXT,
          a.Transaction_AMNT,
          CASE a.TypeHold_CODE
           WHEN @Lc_Hold_ADDR
            THEN @Lc_LookinHold_ADDR
           WHEN @Lc_CheckHold_TEXT
            THEN @Lc_LookinCheckHold_TEXT
           WHEN @Lc_RegularHold_TEXT
            THEN @Lc_LookinRegularHold_TEXT
           WHEN @Lc_CpHold_TEXT
            THEN @Lc_LookinPayeeHold_TEXT
           WHEN @Lc_TanfHold_TEXT
            THEN @Lc_LookinWelfareHold_TEXT
           WHEN @Lc_IvE1Hold_TEXT
            THEN @Lc_LookinWelfareHold_TEXT
           WHEN @Lc_DollarHold_TEXT
            THEN @Lc_LookinDollarHold_TEXT
           WHEN @Lc_SPCHold_TEXT
            THEN @Lc_LookinSpcHold_TEXT
          END AS LookIn_TEXT,
          @Lc_Lineno9b_TEXT AS LineP1No_TEXT,
          LTRIM(RTRIM((ISNULL(CAST(CASE CAST(u.NumUdcLine_IDNO AS VARCHAR)
                                    WHEN '0'
                                     THEN '13'
                                    ELSE CAST(u.NumUdcLine_IDNO AS VARCHAR)
                                   END AS VARCHAR), '13')))) AS LineP2A1No_TEXT,
          CASE
           WHEN a.Transaction_DATE > @Ad_EndQtr_DATE
            THEN @Lc_Lineno20_TEXT
           ELSE
            CASE
             WHEN DATEDIFF(DD, a.Transaction_DATE, @Ad_EndQtr_DATE) <= 2
              THEN @Lc_Lineno14_TEXT
             WHEN DATEDIFF(DD, a.Transaction_DATE, @Ad_EndQtr_DATE) <= 30
              THEN @Lc_Lineno15_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Transaction_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 0.5
              THEN @Lc_Lineno16_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Transaction_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 1
              THEN @Lc_Lineno17_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Transaction_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 3
              THEN @Lc_Lineno18_TEXT
             WHEN ROUND(DATEDIFF(MM, a.Transaction_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 5
              THEN @Lc_Lineno19_TEXT
             ELSE @Lc_Lineno20_TEXT
            END
          END AS LineP2B1No_TEXT,
          @Ad_BeginQtr_DATE AS BeginQtr_DATE,
          @Ad_EndQtr_DATE AS EndQtr_DATE,
          a.ReasonStatus_CODE,
          x.Receipt_DATE,
          ' ' AS TypeDisburse_CODE,
          ' ' AS IvaCase_ID,
          a.Unique_IDNO AS EventGlobalSeq_NUMB
     FROM R34DR_Y1 x,
          DHLD_Y1 a
          LEFT OUTER JOIN RPOVPY_Y1 b
           ON a.Case_IDNO = b.Case_IDNO
              AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
              AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
          LEFT OUTER JOIN UCAT_Y1 u
           ON a.ReasonStatus_CODE = u.Udc_CODE
              AND u.EndValidity_DATE = @Ld_High_DATE
    WHERE x.Batch_DATE = a.Batch_DATE
      AND x.SourceBatch_CODE = a.SourceBatch_CODE
      AND x.Batch_NUMB = a.Batch_NUMB
      AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
      AND x.BackOut_INDC = @Lc_No_INDC
      AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDcs_CODE)
            OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDcs_CODE)
                AND EXISTS (SELECT 1
                              FROM RCTR_Y1 b
                             WHERE a.Batch_DATE = b.Batch_DATE
                               AND a.Batch_NUMB = b.Batch_NUMB
                               AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                               AND a.SourceBatch_CODE = b.SourceBatch_CODE
                               AND ((a.Status_CODE != @Lc_DisbursementHold_TEXT
                                     AND b.BeginValidity_DATE BETWEEN @Ad_BeginQtr_DATE AND @Ad_EndQtr_DATE)
                                     OR a.Status_CODE = @Lc_DisbursementHold_TEXT)
                               AND b.EndValidity_DATE > @Ad_EndQtr_DATE)))
      AND a.BeginValidity_DATE <= @Ad_EndQtr_DATE
      AND a.EndValidity_DATE > @Ad_EndQtr_DATE
      AND a.Batch_DATE != @Ld_Low_DATE
      AND a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOsr_IDNO)
      AND (a.TypeDisburse_CODE NOT IN ('AZNIV', 'CZNIV')
            OR (a.TypeDisburse_CODE IN ('AZNIV', 'CZNIV')
                AND EXISTS (SELECT 1
                              FROM RCTH_Y1 e
                             WHERE a.Batch_DATE = e.Batch_DATE
                               AND a.Batch_NUMB = e.Batch_NUMB
                               AND a.SeqReceipt_NUMB = e.SeqReceipt_NUMB
                               AND a.SourceBatch_CODE = e.SourceBatch_CODE
                               AND e.SourceReceipt_CODE = 'EW')))
      AND a.TypeDisburse_CODE NOT IN ('REFND', 'ROTHP');

   SET @Ls_Sql_TEXT = 'INSERT R34UD_Y1 - QUERY 3';
   SET @Ls_Sqldata_TEXT = 'LookIn_TEXT = ' + ISNULL(@Lc_LookinEscheatment_TEXT,'')+ ', LineP1No_TEXT = ' + ISNULL(@Lc_Lineno9a_TEXT,'')+ ', BeginQtr_DATE = ' + ISNULL(CAST( @Ad_BeginQtr_DATE AS VARCHAR ),'')+ ', EndQtr_DATE = ' + ISNULL(CAST( @Ad_EndQtr_DATE AS VARCHAR ),'');
   INSERT R34UD_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Case_IDNO,
           ObligationKey_ID,
           PayorMCI_IDNO,
           Trans_DATE,
           Hold_DATE,
           CheckNo_TEXT,
           Trans_AMNT,
           LookIn_TEXT,
           LineP1No_TEXT,
           LineP2A1No_TEXT,
           LineP2B1No_TEXT,
           BeginQtr_DATE,
           EndQtr_DATE,
           ReasonHold_CODE,
           Receipt_DATE,
           TypeDisburse_CODE,
           IvaCase_ID,
           EventGlobalSeq_NUMB)
   SELECT l.Batch_DATE,
          l.SourceBatch_CODE,
          l.Batch_NUMB,
          l.SeqReceipt_NUMB,
          l.Case_IDNO,
          ISNULL(ISNULL(LTRIM(RTRIM(b.TypeDisburse_CODE)), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(LTRIM(RTRIM(b.CheckRecipient_ID)), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(CAST(LTRIM(RTRIM(b.Payee_ID)) AS VARCHAR), ''), @Lc_Space_TEXT) AS ObligationKey_ID,
          (SELECT TOP 1 r.PayorMCI_IDNO
             FROM RCTH_Y1 r
            WHERE r.Batch_DATE = l.Batch_DATE
              AND r.SourceBatch_CODE = l.SourceBatch_CODE
              AND r.Batch_NUMB = l.Batch_NUMB
              AND r.SeqReceipt_NUMB = l.SeqReceipt_NUMB
              AND r.EndValidity_DATE > @Ad_EndQtr_DATE) AS PayorMCI_IDNO,
          h.Disburse_DATE,
          @Ld_Low_DATE AS Hold_DATE,
          CAST(h.Check_NUMB AS VARCHAR) AS CheckNo_TEXT,
          l.Disburse_AMNT,
          @Lc_LookinEscheatment_TEXT AS LookIn_TEXT,
          @Lc_Lineno9a_TEXT AS LineP1No_TEXT,
          LTRIM(RTRIM((ISNULL(CAST(CASE u.NumUdcLine_IDNO
                                    WHEN 0
                                     THEN 13
                                    ELSE u.NumUdcLine_IDNO
                                   END AS VARCHAR(MAX)), '13')))) AS LineP2A1No_TEXT,
          CASE
           WHEN h.Disburse_DATE > @Ad_EndQtr_DATE
            THEN @Lc_Lineno20_TEXT
           ELSE
            CASE
             WHEN DATEDIFF(DD, h.Disburse_DATE, @Ad_EndQtr_DATE) <= 2
              THEN @Lc_Lineno14_TEXT
             WHEN DATEDIFF(DD, h.Disburse_DATE, @Ad_EndQtr_DATE) <= 30
              THEN @Lc_Lineno15_TEXT
             WHEN ROUND(DATEDIFF(MM, h.Disburse_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 0.5
              THEN @Lc_Lineno16_TEXT
             WHEN ROUND(DATEDIFF(MM, h.Disburse_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 1
              THEN @Lc_Lineno17_TEXT
             WHEN ROUND(DATEDIFF(MM, h.Disburse_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 3
              THEN @Lc_Lineno18_TEXT
             WHEN ROUND(DATEDIFF(MM, h.Disburse_DATE, @Ad_EndQtr_DATE) / 12, 2) <= 5
              THEN @Lc_Lineno19_TEXT
             ELSE @Lc_Lineno20_TEXT
            END
          END AS LineP2B1No_TEXT,
          @Ad_BeginQtr_DATE AS BeginQtr_DATE,
          @Ad_EndQtr_DATE AS EndQtr_DATE,
          h.ReasonStatus_CODE,
          (SELECT TOP 1 r.Receipt_DATE
             FROM RCTH_Y1 r
            WHERE r.Batch_DATE = l.Batch_DATE
              AND r.SourceBatch_CODE = l.SourceBatch_CODE
              AND r.Batch_NUMB = l.Batch_NUMB
              AND r.SeqReceipt_NUMB = l.SeqReceipt_NUMB
              AND r.EndValidity_DATE > @Ad_EndQtr_DATE) AS Receipt_DATE,
          ' ' AS TypeDisburse_CODE,
          ' ' AS IvaCase_ID,
          l.EventGlobalSeq_NUMB
     FROM DSBL_Y1 l
          LEFT OUTER JOIN RPOVPY_Y1 b
           ON l.Case_IDNO = b.Case_IDNO
              AND l.OrderSeq_NUMB = b.OrderSeq_NUMB
              AND l.ObligationSeq_NUMB = b.ObligationSeq_NUMB,
          DSBH_Y1 h
          LEFT OUTER JOIN UCAT_Y1 u
           ON h.ReasonStatus_CODE = u.Udc_CODE
              AND u.EndValidity_DATE = @Ld_High_DATE
    WHERE h.CheckRecipient_ID = @Lc_CheckRecipientEsch_IDNO -- DELAWARE STATE TREASURY '999999983',
      AND h.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
      AND h.Disburse_DATE >= @Ad_BeginQtr_DATE
      AND l.CheckRecipient_ID = h.CheckRecipient_ID
      AND l.CheckRecipient_CODE = h.CheckRecipient_CODE
      AND l.Disburse_DATE = h.Disburse_DATE
      AND l.DisburseSeq_NUMB = h.DisburseSeq_NUMB
      AND h.BeginValidity_DATE <= @Ad_EndQtr_DATE
      AND h.EndValidity_DATE > @Ad_EndQtr_DATE
      AND NOT EXISTS (SELECT 1
                        FROM RPODSM_Y1 b
                       WHERE b.Batch_DATE = l.Batch_DATE
                         AND b.SourceBatch_CODE = l.SourceBatch_CODE
                         AND b.Batch_NUMB = l.Batch_NUMB
                         AND b.SeqReceipt_NUMB = l.SeqReceipt_NUMB
                         AND b.TypeDisburse_CODE = @Lc_TypeDisburseVlsup_CODE
                         AND b.Case_IDNO = l.Case_IDNO);

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
