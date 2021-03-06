/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_TMP_RREP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_TMP_RREP
Programmer Name		: IMP Team
Description			: This Procedure is used to  insert  into prrep table which is used to store all complete list of valid receipts which have 
					  not been reversed.  The receipts can be viewed on RREP in the Inquire mode using the Payor DCN , Date Range option, 
					  the Case ID , Date Range or the Receipt /Trans option. This Service is called in Reverse  Receipts, Reverse and Repost
					  Receipts and Reverse and Refund Receipts screen functions	
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_TMP_RREP] (
 @An_PayorMci_IDNO         NUMERIC(10, 0),
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ac_SourceReceipt_CODE    CHAR(2),
 @Ad_From_DATE             DATE,
 @Ad_To_DATE               DATE,
 @Ac_Session_ID            CHAR(30),
 @Ac_MultiCase_INDC        CHAR(1),
 @Ac_ClosedCase_INDC       CHAR(1),
 @Ac_SignedOnWorker_ID     CHAR(30) = ' ',
 @An_ScrnFunc_NUMB         NUMERIC(1, 0) = 0,
 @Ac_CheckNo_TEXT          CHAR(18) = ' ',
 @An_HdrReceipt_QNTY       NUMERIC(9) OUTPUT,
 @An_HdrReceipt_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_Receipt_QNTY          NUMERIC(11) OUTPUT,
 @An_TotReceipt_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_TotHeld_AMNT          NUMERIC(11, 2) OUTPUT,
 @An_TotDist_AMNT          NUMERIC(11, 2) OUTPUT,
 @An_TotRefund_AMNT        NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_ManuallyDistributeReceipt1810_NUMB INT = 1810,
		   @Li_ReceiptDistributed1820_NUMB		  INT = 1820,
		   @Lc_Space_TEXT                        CHAR(1) = ' ',
           @Lc_Percentage_TEXT                   CHAR(1) = '%',
           @Lc_Yes_INDC                          CHAR(1) = 'Y',
           @Lc_No_INDC                           CHAR(1) = 'N',
           @Lc_TypePostingPayor_CODE             CHAR(1) = 'P',
           @Lc_StatusCaseClosed_CODE             CHAR(1) = 'C',
           @Lc_StatusReceiptRefunded_CODE        CHAR(1) = 'R',
           @Lc_StatusReceiptHeld_CODE            CHAR(1) = 'H',
           @Lc_StatusReceiptUnidentified_CODE    CHAR(1) = 'U',
           @Lc_StatusReceiptIdentified_CODE      CHAR(1) = 'I',
           @Lc_StatusReceiptEscheated_CODE       CHAR(1) = 'E',
           @Lc_StatusBatchReconciled_CODE        CHAR(1) = 'R',
		   @Ld_StatusReceiptRefund_CODE			 CHAR(1)  ='R',
           @Lc_StatusReceiptOthpRefund_CODE      CHAR(1) = 'O',
           @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
           @Lc_StatusNoDataFound_CODE            CHAR(1) = 'N',
           @Lc_SourceReceiptCpRecoupmentCr_CODE  CHAR(2) = 'CR',
           @Lc_SourceReceiptCpFeePaymentCf_CODE  CHAR(2) = 'CF',
           @Lc_ChildSrcDirectPayCredit_CODE      CHAR(3) = 'DCR',
           @Lc_SeqReceipt_TEXT					 CHAR(6) = NULL,
           @Ls_Routine_TEXT                      VARCHAR(60) = 'BATCH_COMMON$SP_INSERT_TMP_RREP',
           @Ld_Low_DATE                          DATE = '01/01/0001',
           @Ld_Run_DATE							 DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
           @Ld_High_DATE                         DATE = '12/31/9999';
  DECLARE  @Ln_RowCount_QNTY       NUMERIC,
           @Ln_ErrorLine_NUMB      NUMERIC(11),
           @Li_Error_NUMB          INT,
           @Lc_Null_TEXT           CHAR(1) = '',
           @Ls_Sql_TEXT            VARCHAR(100),
           @Ls_Sqldata_TEXT        VARCHAR(500),
           @Ls_ErrorMessage_TEXT   VARCHAR(4000),
           @Ld_From_DATE           DATE,
           @Ld_To_DATE             DATE;

  BEGIN TRY
   SET @An_HdrReceipt_QNTY = 0;
   SET @An_HdrReceipt_AMNT = 0;
   SET @An_Receipt_QNTY = 0;
   SET @An_TotReceipt_AMNT = 0;
   SET @An_TotHeld_AMNT = 0;
   SET @An_TotDist_AMNT = 0;
   SET @An_TotRefund_AMNT = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'DELETE_PRREP';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');

   DELETE PRREP_Y1
    WHERE ( Worker_ID = @Ac_SignedOnWorker_ID
        OR Transaction_DATE < @Ld_Run_DATE );

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NVARCHAR(3, @Ad_From_DATE) IS NULL
    BEGIN
     SET @Ld_From_DATE = @Ld_Low_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_From_DATE = @Ad_From_DATE;
    END

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NVARCHAR(3, @Ad_To_DATE) IS NULL
    BEGIN
     SET @Ld_To_DATE = @Ld_Run_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_To_DATE = @Ad_To_DATE;
    END

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_CheckNo_TEXT) IS NOT NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_TMP_PRREP0';
     SET @Ls_Sqldata_TEXT = 'Check_NUMB = ' + ISNULL(@Ac_CheckNo_TEXT, '') + ', DT FROM = ' + ISNULL(CONVERT(VARCHAR(10), @Ad_From_DATE, 101), '') + ', DT TO = ' + ISNULL (CONVERT(VARCHAR(10), @Ad_To_DATE, 101), '');

     INSERT PRREP_Y1
            (Session_ID,
             BackOut_INDC,
             RePost_INDC,
             Refund_INDC,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceReceipt_CODE,
             Receipt_DATE,
             PayorMCI_IDNO,
             CasePayorMCI_IDNO,
             Ncp_NAME,
             Receipt_AMNT,
             Held_AMNT,
             Distributed_AMNT,
             Refund_AMNT,
             MultiCase_INDC,
             ClosedCase_INDC,
             MultiCounty_INDC,
             Distd_INDC,
             EventGlobalBeginSeq_NUMB,
             Transaction_DATE,
             Worker_ID,
             RepostedPayorMci_IDNO,
             CasePayorMCIReposted_IDNO)
     SELECT xyz.Session_ID,
            xyz.BackOut_INDC,
            xyz.RePost_INDC,
            xyz.Refund_INDC,
            xyz.Batch_DATE,
            xyz.SourceBatch_CODE,
            xyz.Batch_NUMB,
            xyz.SeqReceipt_NUMB,
            xyz.SourceReceipt_CODE,
            xyz.Receipt_DATE,
            xyz.PayorMCI_IDNO,
            xyz.CasePayorMCI_IDNO,
            xyz.Ncp_NAME,
            xyz.Receipt_AMNT,
            xyz.Held_AMNT,
            xyz.amt_distd,
            xyz.Refund_AMNT,
            xyz.MultiCase_INDC,
            xyz.ClosedCase_INDC,
            xyz.MultiCounty_INDC,
            xyz.Distd_INDC,
            xyz.seq_event_global_beg_orig,
            xyz.Transaction_DATE,
            xyz.Worker_ID,
            xyz.RepostedPayorMci_IDNO,
            xyz.CasePayorMCIReposted_IDNO
       FROM (SELECT @Ac_Session_ID AS Session_ID,
                    @Lc_Yes_INDC AS BackOut_INDC,
                    CASE a.SourceBatch_CODE
                     WHEN @Lc_ChildSrcDirectPayCredit_CODE
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END AS RePost_INDC,
                    CASE a.SourceBatch_CODE
                     WHEN @Lc_ChildSrcDirectPayCredit_CODE
                      THEN @Lc_No_INDC
                     ELSE
                      CASE SIGN(CAST(aa.Refund_AMNT AS NUMERIC(11, 2)))
                       WHEN 0
                        THEN @Lc_No_INDC
                       ELSE @Lc_Yes_INDC
                      END
                    END AS Refund_INDC,
                    a.Batch_DATE,
                    a.SourceBatch_CODE,
                    a.Batch_NUMB,
                    a.SeqReceipt_NUMB,
                    a.SourceReceipt_CODE,
                    a.Receipt_DATE,
                    a.PayorMCI_IDNO,
                    CASE a.TypePosting_CODE
                     WHEN @Lc_TypePostingPayor_CODE
                      THEN a.PayorMCI_IDNO
                     ELSE a.Case_IDNO
                    END AS CasePayorMCI_IDNO,
                    CASE dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.PayorMCI_IDNO)
                     WHEN NULL
                      THEN @Lc_Space_TEXT
                     ELSE dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(a.PayorMCI_IDNO)
                    END AS Ncp_NAME,
                    a.Receipt_AMNT,
                    aa.Held_AMNT,
                    aa.Distributed_AMNT AS amt_distd,
                    aa.Refund_AMNT,
                    CASE
                     WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                          AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                 FROM CPFL_Y1 l
                                WHERE l.Batch_DATE = a.Batch_DATE
                                  AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                  AND l.Batch_NUMB = a.Batch_NUMB
                                  AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                      THEN @Lc_Yes_INDC
                     WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                          AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                 FROM POFL_Y1 l
                                WHERE l.Batch_DATE = a.Batch_DATE
                                  AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                  AND l.Batch_NUMB = a.Batch_NUMB
                                  AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                      THEN @Lc_Yes_INDC
                     WHEN a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCpFeePaymentCf_CODE, @Lc_SourceReceiptCpRecoupmentCr_CODE)
                          AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                 FROM LSUP_Y1 l
                                WHERE l.Batch_DATE = a.Batch_DATE
                                  AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                  AND l.Batch_NUMB = a.Batch_NUMB
                                  AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                      THEN @Lc_Yes_INDC
                     ELSE @Lc_No_INDC
                    END AS MultiCase_INDC,
                    CASE
                     WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                      THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                     FROM CPFL_Y1 x,
                                          CASE_Y1 y
                                    WHERE x.Batch_DATE = a.Batch_DATE
                                      AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                      AND x.Batch_NUMB = a.Batch_NUMB
                                      AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                      AND y.Case_IDNO = x.Case_IDNO
                                      AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                     WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                      THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                     FROM POFL_Y1 x,
                                          CASE_Y1 y
                                    WHERE x.Batch_DATE = a.Batch_DATE
                                      AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                      AND x.Batch_NUMB = a.Batch_NUMB
                                      AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                      AND y.Case_IDNO = x.Case_IDNO
                                      AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                     ELSE ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                    FROM LSUP_Y1 x,
                                         CASE_Y1 y
                                   WHERE x.Batch_DATE = a.Batch_DATE
                                     AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                     AND x.Batch_NUMB = a.Batch_NUMB
                                     AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                     AND y.Case_IDNO = x.Case_IDNO
                                     AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                    END AS ClosedCase_INDC,
                    @Lc_Null_TEXT AS MultiCounty_INDC,
                    CASE SIGN(CAST(aa.Distributed_AMNT AS NUMERIC(11, 2)))
                     WHEN 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END AS Distd_INDC,
                    aa.seq_event_global_max AS seq_event_global_beg_orig,
                    @Ld_Run_DATE AS Transaction_DATE,
                    @Ac_SignedOnWorker_ID AS Worker_ID,
                    CASE a.SourceBatch_CODE
                     WHEN @Lc_ChildSrcDirectPayCredit_CODE
                      THEN 0
                     ELSE a.PayorMCI_IDNO
                    END AS RepostedPayorMci_IDNO,
                    CASE a.SourceBatch_CODE
                     WHEN @Lc_ChildSrcDirectPayCredit_CODE
                      THEN 0
                     ELSE
                      CASE a.TypePosting_CODE
                       WHEN @Lc_TypePostingPayor_CODE
                        THEN a.PayorMCI_IDNO
                       ELSE a.Case_IDNO
                      END
                    END AS CasePayorMCIReposted_IDNO
               FROM RCTH_Y1 a
                    LEFT OUTER JOIN DEMO_Y1 b
                     ON b.MemberMci_IDNO = a.PayorMCI_IDNO,
                    (SELECT z.Batch_DATE,
                            z.SourceBatch_CODE,
                            z.Batch_NUMB,
                            z.SeqReceipt_NUMB,
                            SUM(CASE z.StatusReceipt_CODE
                                 WHEN @Lc_StatusReceiptRefunded_CODE
                                  THEN z.ToDistribute_AMNT
                                 ELSE 0
                                END) AS Refund_AMNT,
                            SUM(CASE
                                 WHEN z.StatusReceipt_CODE IN (@Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptUnidentified_CODE, @Lc_StatusReceiptIdentified_CODE, @Lc_StatusReceiptEscheated_CODE)
                                      AND z.Distribute_DATE = @Ld_Low_DATE
                                  THEN z.ToDistribute_AMNT
                                 ELSE 0
                                END) AS Held_AMNT,
                            SUM(CASE
                                 WHEN z.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                      AND z.Distribute_DATE > @Ld_Low_DATE
                                  THEN z.ToDistribute_AMNT
                                 ELSE 0
                                END) AS Distributed_AMNT,
                            MAX(z.EventGlobalBeginSeq_NUMB) AS seq_event_global_max,
                            @Lc_Space_TEXT AS man_dist
                       FROM RCTH_Y1 z
                      WHERE z.CheckNo_TEXT = dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_CheckNo_TEXT)
                        AND z.Receipt_DATE BETWEEN @Ld_From_DATE AND @Ld_To_DATE
                        AND z.EndValidity_DATE = @Ld_High_DATE
                        AND z.SourceReceipt_CODE = ISNULL(@Ac_SourceReceipt_CODE, z.SourceReceipt_CODE)
                        AND NOT EXISTS (SELECT 1
                                          FROM RCTH_Y1 r
                                         WHERE r.Batch_DATE = z.Batch_DATE
                                           AND r.SourceBatch_CODE = z.SourceBatch_CODE
                                           AND r.Batch_NUMB = z.Batch_NUMB
                                           AND r.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                                           AND r.BackOut_INDC = @Lc_Yes_INDC
                                           AND r.EndValidity_DATE = @Ld_High_DATE)
                        AND EXISTS (SELECT 1
                                      FROM RBAT_Y1 b
                                     WHERE b.Batch_DATE = z.Batch_DATE
                                       AND b.Batch_NUMB = z.Batch_NUMB
                                       AND b.SourceBatch_CODE = z.SourceBatch_CODE
                                       AND b.StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
                                       AND b.EndValidity_DATE = @Ld_High_DATE)
                      GROUP BY z.Batch_DATE,
                               z.SourceBatch_CODE,
                               z.Batch_NUMB,
                               z.SeqReceipt_NUMB) AS aa
              WHERE a.Batch_DATE = aa.Batch_DATE
                AND a.SourceBatch_CODE = aa.SourceBatch_CODE
                AND a.Batch_NUMB = aa.Batch_NUMB
                AND a.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
                AND a.EventGlobalBeginSeq_NUMB = aa.seq_event_global_max
                AND a.StatusReceipt_CODE NOT IN( @Lc_StatusReceiptOthpRefund_CODE, @Lc_StatusReceiptEscheated_CODE)) AS xyz
      WHERE xyz.MultiCase_INDC = ISNULL(@Ac_MultiCase_INDC, xyz.MultiCase_INDC)
        AND xyz.ClosedCase_INDC = ISNULL(@Ac_ClosedCase_INDC, xyz.ClosedCase_INDC);

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      END
    END
   ELSE
    BEGIN
     IF (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@An_PayorMCI_IDNO) IS NOT NULL
         AND @An_PayorMCI_IDNO > 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_TMP_PRREP1';
       SET @Ls_Sqldata_TEXT = 'Seq_IDNO PAYOR = ' + ISNULL(CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', DT FROM = ' + ISNULL(CONVERT(VARCHAR(10), @Ad_From_DATE, 101), '') + ', DT TO = ' + ISNULL(CONVERT(VARCHAR(10), @Ad_To_DATE, 101), '');

       INSERT PRREP_Y1
              (Session_ID,
               BackOut_INDC,
               RePost_INDC,
               Refund_INDC,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               SourceReceipt_CODE,
               Receipt_DATE,
               PayorMCI_IDNO,
               CasePayorMCI_IDNO,
               Ncp_NAME,
               Receipt_AMNT,
               Held_AMNT,
               Distributed_AMNT,
               Refund_AMNT,
               MultiCase_INDC,
               ClosedCase_INDC,
               MultiCounty_INDC,
               Distd_INDC,
               EventGlobalBeginSeq_NUMB,
               Transaction_DATE,
               Worker_ID,
               RepostedPayorMci_IDNO,
               CasePayorMCIReposted_IDNO)
       SELECT xyz.Session_ID,
              xyz.BackOut_INDC,
              xyz.RePost_INDC,
              xyz.Refund_INDC,
              xyz.Batch_DATE,
              xyz.SourceBatch_CODE,
              xyz.Batch_NUMB,
              xyz.SeqReceipt_NUMB,
              xyz.SourceReceipt_CODE,
              xyz.Receipt_DATE,
              xyz.PayorMCI_IDNO,
              xyz.CasePayorMCI_IDNO,
              xyz.Ncp_NAME,
              xyz.Receipt_AMNT,
              xyz.Held_AMNT,
              xyz.amt_distd,
              xyz.Refund_AMNT,
              xyz.MultiCase_INDC,
              xyz.ClosedCase_INDC,
              xyz.MultiCounty_INDC,
              xyz.Distd_INDC,
              xyz.seq_event_global_beg_orig,
              xyz.Transaction_DATE,
              xyz.Worker_ID,
              xyz.RepostedPayorMci_IDNO,
              xyz.CasePayorMCIReposted_IDNO
         FROM (SELECT @Ac_Session_ID AS Session_ID,
                      @Lc_Yes_INDC AS BackOut_INDC,
                      CASE a.SourceBatch_CODE
                       WHEN @Lc_ChildSrcDirectPayCredit_CODE
                        THEN @Lc_No_INDC
                       ELSE @Lc_Yes_INDC
                      END AS RePost_INDC,
                      CASE a.SourceBatch_CODE
                       WHEN @Lc_ChildSrcDirectPayCredit_CODE
                        THEN @Lc_No_INDC
                       ELSE
                        CASE SIGN(CAST(aa.Refund_AMNT AS NUMERIC(11, 2)))
                         WHEN 0
                          THEN @Lc_No_INDC
                         ELSE @Lc_Yes_INDC
                        END
                      END AS Refund_INDC,
                      a.Batch_DATE,
                      a.SourceBatch_CODE,
                      a.Batch_NUMB,
                      a.SeqReceipt_NUMB,
                      a.SourceReceipt_CODE,
                      a.Receipt_DATE,
                      a.PayorMCI_IDNO,
                      CASE a.TypePosting_CODE
                       WHEN @Lc_TypePostingPayor_CODE
                        THEN a.PayorMCI_IDNO
                       ELSE a.Case_IDNO
                      END AS CasePayorMCI_IDNO,
                      CASE dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.PayorMCI_IDNO)
                       WHEN NULL
                        THEN @Lc_Space_TEXT
                       ELSE dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(a.PayorMCI_IDNO)
                      END AS Ncp_NAME,
                      a.Receipt_AMNT,
                      aa.Held_AMNT,
                      aa.Distributed_AMNT AS amt_distd,
                      aa.Refund_AMNT,
                      CASE
                       WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                            AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                   FROM CPFL_Y1 l
                                  WHERE l.Batch_DATE = a.Batch_DATE
                                    AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                    AND l.Batch_NUMB = a.Batch_NUMB
                                    AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                        THEN @Lc_Yes_INDC
                       WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                            AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                   FROM POFL_Y1 l
                                  WHERE l.Batch_DATE = a.Batch_DATE
                                    AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                    AND l.Batch_NUMB = a.Batch_NUMB
                                    AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                        THEN @Lc_Yes_INDC
                       WHEN a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCpFeePaymentCf_CODE, @Lc_SourceReceiptCpRecoupmentCr_CODE)
                            AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                   FROM LSUP_Y1 l
                                  WHERE l.Batch_DATE = a.Batch_DATE
                                    AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                    AND l.Batch_NUMB = a.Batch_NUMB
                                    AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                        THEN @Lc_Yes_INDC
                       ELSE @Lc_No_INDC
                      END AS MultiCase_INDC,
                      CASE
                       WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                        THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                       FROM CPFL_Y1 x,
                                            CASE_Y1 y
                                      WHERE x.Batch_DATE = a.Batch_DATE
                                        AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                        AND x.Batch_NUMB = a.Batch_NUMB
                                        AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                        AND y.Case_IDNO = x.Case_IDNO
                                        AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                       WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                        THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                       FROM POFL_Y1 x,
                                            CASE_Y1 y
                                      WHERE x.Batch_DATE = a.Batch_DATE
                                        AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                        AND x.Batch_NUMB = a.Batch_NUMB
                                        AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                        AND y.Case_IDNO = x.Case_IDNO
                                        AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                       ELSE ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                      FROM LSUP_Y1 x,
                                           CASE_Y1 y
                                     WHERE x.Batch_DATE = a.Batch_DATE
                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                       AND x.Batch_NUMB = a.Batch_NUMB
                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                       AND y.Case_IDNO = x.Case_IDNO
                                       AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                      END AS ClosedCase_INDC,
                      @Lc_Null_TEXT AS MultiCounty_INDC,
                      CASE SIGN(CAST(aa.Distributed_AMNT AS NUMERIC(11, 2)))
                       WHEN 0
                        THEN @Lc_No_INDC
                       ELSE @Lc_Yes_INDC
                      END AS Distd_INDC,
                      aa.seq_event_global_max AS seq_event_global_beg_orig,
                      @Ld_Run_DATE AS Transaction_DATE,
                      @Ac_SignedOnWorker_ID AS Worker_ID,
                      CASE a.SourceBatch_CODE
                       WHEN @Lc_ChildSrcDirectPayCredit_CODE
                        THEN 0
                       ELSE a.PayorMCI_IDNO
                      END AS RepostedPayorMci_IDNO,
                      CASE a.SourceBatch_CODE
                       WHEN @Lc_ChildSrcDirectPayCredit_CODE
                        THEN 0
                       ELSE
                        CASE a.TypePosting_CODE
                         WHEN @Lc_TypePostingPayor_CODE
                          THEN a.PayorMCI_IDNO
                         ELSE a.Case_IDNO
                        END
                      END AS CasePayorMCIReposted_IDNO
                 FROM RCTH_Y1 a
                      LEFT OUTER JOIN DEMO_Y1 b
                       ON b.MemberMci_IDNO = a.PayorMCI_IDNO,
                      (SELECT z.Batch_DATE,
                              z.SourceBatch_CODE,
                              z.Batch_NUMB,
                              z.SeqReceipt_NUMB,
                              SUM(CASE z.StatusReceipt_CODE
                                   WHEN @Lc_StatusReceiptRefunded_CODE
                                    THEN z.ToDistribute_AMNT
                                   ELSE 0
                                  END) AS Refund_AMNT,
                              SUM(CASE
                                   WHEN z.StatusReceipt_CODE IN (@Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptUnidentified_CODE, @Lc_StatusReceiptIdentified_CODE, @Lc_StatusReceiptEscheated_CODE)
                                        AND z.Distribute_DATE = @Ld_Low_DATE
                                    THEN z.ToDistribute_AMNT
                                   ELSE 0
                                  END) AS Held_AMNT,
                              SUM(CASE
                                   WHEN z.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                        AND z.Distribute_DATE > @Ld_Low_DATE
                                    THEN z.ToDistribute_AMNT
                                   ELSE 0
                                  END) AS Distributed_AMNT,
                              MAX(z.EventGlobalBeginSeq_NUMB) AS seq_event_global_max,
                              @Lc_Space_TEXT AS man_dist
                         FROM RCTH_Y1 z
                        WHERE z.PayorMCI_IDNO = @An_PayorMCI_IDNO
                          AND z.Receipt_DATE BETWEEN @Ld_From_DATE AND @Ld_To_DATE
                          AND z.EndValidity_DATE = @Ld_High_DATE
                          AND z.SourceReceipt_CODE = ISNULL(@Ac_SourceReceipt_CODE, z.SourceReceipt_CODE)
                          AND NOT EXISTS (SELECT 1
                                            FROM RCTH_Y1 r
                                           WHERE r.Batch_DATE = z.Batch_DATE
                                             AND r.SourceBatch_CODE = z.SourceBatch_CODE
                                             AND r.Batch_NUMB = z.Batch_NUMB
                                             AND r.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                                             AND r.BackOut_INDC = @Lc_Yes_INDC
                                             AND r.EndValidity_DATE = @Ld_High_DATE)
                          AND EXISTS (SELECT 1
                                        FROM RBAT_Y1 b
                                       WHERE b.Batch_DATE = z.Batch_DATE
                                         AND b.Batch_NUMB = z.Batch_NUMB
                                         AND b.SourceBatch_CODE = z.SourceBatch_CODE
                                         AND b.StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
                                         AND b.EndValidity_DATE = @Ld_High_DATE)
                        GROUP BY z.Batch_DATE,
                                 z.SourceBatch_CODE,
                                 z.Batch_NUMB,
                                 z.SeqReceipt_NUMB) AS aa
                WHERE a.Batch_DATE = aa.Batch_DATE
                  AND a.SourceBatch_CODE = aa.SourceBatch_CODE
                  AND a.Batch_NUMB = aa.Batch_NUMB
                  AND a.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
                  AND a.EventGlobalBeginSeq_NUMB = aa.seq_event_global_max
                  AND a.StatusReceipt_CODE NOT IN( @Lc_StatusReceiptOthpRefund_CODE, @Lc_StatusReceiptEscheated_CODE)) AS xyz
        WHERE xyz.MultiCase_INDC = ISNULL(@Ac_MultiCase_INDC, xyz.MultiCase_INDC)
          AND xyz.ClosedCase_INDC = ISNULL(@Ac_ClosedCase_INDC, xyz.ClosedCase_INDC);

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        END
      END
     ELSE
      BEGIN
       IF (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@An_Case_IDNO) IS NOT NULL
           AND @An_Case_IDNO > 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_TMP_PRREP2';
         SET @Ls_Sqldata_TEXT = 'Seq_IDNO CASE = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', DT FROM = ' + ISNULL(CONVERT(VARCHAR(10), @Ad_From_DATE, 101), '') + ', DT TO = ' + ISNULL(CONVERT(VARCHAR(10), @Ad_To_DATE, 101), '');

         INSERT PRREP_Y1
                (Session_ID,
                 BackOut_INDC,
                 RePost_INDC,
                 Refund_INDC,
                 Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceReceipt_CODE,
                 Receipt_DATE,
                 PayorMCI_IDNO,
                 CasePayorMCI_IDNO,
                 Ncp_NAME,
                 Receipt_AMNT,
                 Held_AMNT,
                 Distributed_AMNT,
                 Refund_AMNT,
                 MultiCase_INDC,
                 ClosedCase_INDC,
                 MultiCounty_INDC,
                 Distd_INDC,
                 EventGlobalBeginSeq_NUMB,
                 Transaction_DATE,
                 Worker_ID,
                 RepostedPayorMci_IDNO,
                 CasePayorMCIReposted_IDNO)
         SELECT xyz.Session_ID,
                xyz.BackOut_INDC,
                xyz.RePost_INDC,
                xyz.Refund_INDC,
                xyz.Batch_DATE,
                xyz.SourceBatch_CODE,
                xyz.Batch_NUMB,
                xyz.SeqReceipt_NUMB,
                xyz.SourceReceipt_CODE,
                xyz.Receipt_DATE,
                xyz.PayorMCI_IDNO,
                xyz.CasePayorMCI_IDNO,
                xyz.Ncp_NAME,
                xyz.Receipt_AMNT,
                xyz.Held_AMNT,
                xyz.amt_distd,
                xyz.Refund_AMNT,
                xyz.MultiCase_INDC,
                xyz.ClosedCase_INDC,
                xyz.MultiCounty_INDC,
                xyz.Distd_INDC,
                xyz.seq_event_global_beg_orig,
                xyz.Transaction_DATE,
                xyz.Worker_ID,
                xyz.RepostedPayorMci_IDNO,
                xyz.CasePayorMCIReposted_IDNO
           FROM (SELECT @Ac_Session_ID AS Session_ID,
                        @Lc_Yes_INDC AS BackOut_INDC,
                        CASE a.SourceBatch_CODE
                         WHEN @Lc_ChildSrcDirectPayCredit_CODE
                          THEN @Lc_No_INDC
                         ELSE @Lc_Yes_INDC
                        END AS RePost_INDC,
                        CASE a.SourceBatch_CODE
                         WHEN @Lc_ChildSrcDirectPayCredit_CODE
                          THEN @Lc_No_INDC
                         ELSE
                          CASE SIGN(CAST(aa.Refund_AMNT AS NUMERIC(11, 2)))
                           WHEN 0
                            THEN @Lc_No_INDC
                           ELSE @Lc_Yes_INDC
                          END
                        END AS Refund_INDC,
                        a.Batch_DATE,
                        a.SourceBatch_CODE,
                        a.Batch_NUMB,
                        a.SeqReceipt_NUMB,
                        a.SourceReceipt_CODE,
                        a.Receipt_DATE,
                        a.PayorMCI_IDNO,
                        CASE a.TypePosting_CODE
                         WHEN @Lc_TypePostingPayor_CODE
                          THEN a.PayorMCI_IDNO
                         ELSE a.Case_IDNO
                        END AS CasePayorMCI_IDNO,
                        CASE dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.PayorMCI_IDNO)
                         WHEN NULL
                          THEN @Lc_Space_TEXT
                         ELSE dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(a.PayorMCI_IDNO)
                        END AS Ncp_NAME,
                        a.Receipt_AMNT,
                        aa.Held_AMNT,
                        aa.Distributed_AMNT AS amt_distd,
                        aa.Refund_AMNT,
                        CASE
                         WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                              AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                     FROM CPFL_Y1 l
                                    WHERE l.Batch_DATE = a.Batch_DATE
                                      AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                      AND l.Batch_NUMB = a.Batch_NUMB
                                      AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                          THEN @Lc_Yes_INDC
                         WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                              AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                     FROM POFL_Y1 l
                                    WHERE l.Batch_DATE = a.Batch_DATE
                                      AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                      AND l.Batch_NUMB = a.Batch_NUMB
                                      AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                          THEN @Lc_Yes_INDC
                         WHEN a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCpFeePaymentCf_CODE, @Lc_SourceReceiptCpRecoupmentCr_CODE)
                              AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                     FROM LSUP_Y1 l
                                    WHERE l.Batch_DATE = a.Batch_DATE
                                      AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                      AND l.Batch_NUMB = a.Batch_NUMB
                                      AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                          THEN @Lc_Yes_INDC
                         ELSE @Lc_No_INDC
                        END AS MultiCase_INDC,
                        CASE
                         WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                          THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                         FROM CPFL_Y1 x,
                                              CASE_Y1 y
                                        WHERE x.Batch_DATE = a.Batch_DATE
                                          AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                          AND x.Batch_NUMB = a.Batch_NUMB
                                          AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                          AND y.Case_IDNO = x.Case_IDNO
                                          AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                         WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                          THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                         FROM POFL_Y1 x,
                                              CASE_Y1 y
                                        WHERE x.Batch_DATE = a.Batch_DATE
                                          AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                          AND x.Batch_NUMB = a.Batch_NUMB
                                          AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                          AND y.Case_IDNO = x.Case_IDNO
                                          AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                         ELSE ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                        FROM LSUP_Y1 x,
                                             CASE_Y1 y
                                       WHERE x.Batch_DATE = a.Batch_DATE
                                         AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                         AND x.Batch_NUMB = a.Batch_NUMB
                                         AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                         AND y.Case_IDNO = x.Case_IDNO
                                         AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                        END AS ClosedCase_INDC,
                        @Lc_Null_TEXT AS MultiCounty_INDC,
                        CASE SIGN(CAST(aa.Distributed_AMNT AS NUMERIC(11, 2)))
                         WHEN 0
                          THEN @Lc_No_INDC
                         ELSE @Lc_Yes_INDC
                        END AS Distd_INDC,
                        aa.seq_event_global_max AS seq_event_global_beg_orig,
                        @Ld_Run_DATE AS Transaction_DATE,
                        @Ac_SignedOnWorker_ID AS Worker_ID,
                        CASE a.SourceBatch_CODE
                         WHEN @Lc_ChildSrcDirectPayCredit_CODE
                          THEN 0
                         ELSE a.PayorMCI_IDNO
                        END AS RepostedPayorMci_IDNO,
                        CASE a.SourceBatch_CODE
                         WHEN @Lc_ChildSrcDirectPayCredit_CODE
                          THEN 0
                         ELSE
                          CASE a.TypePosting_CODE
                           WHEN @Lc_TypePostingPayor_CODE
                            THEN a.PayorMCI_IDNO
                           ELSE a.Case_IDNO
                          END
                        END AS CasePayorMCIReposted_IDNO
                   FROM RCTH_Y1 a
                        LEFT OUTER JOIN DEMO_Y1 b
                         ON b.MemberMci_IDNO = a.PayorMCI_IDNO,
                        (SELECT z.Batch_DATE,
                                z.SourceBatch_CODE,
                                z.Batch_NUMB,
                                z.SeqReceipt_NUMB,
                                SUM(CASE z.StatusReceipt_CODE
                                     WHEN @Lc_StatusReceiptRefunded_CODE
                                      THEN z.ToDistribute_AMNT
                                     ELSE 0
                                    END) AS Refund_AMNT,
                                SUM(CASE
                                     WHEN z.StatusReceipt_CODE IN (@Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptUnidentified_CODE, @Lc_StatusReceiptIdentified_CODE, @Lc_StatusReceiptEscheated_CODE)
                                          AND z.Distribute_DATE = @Ld_Low_DATE
                                      THEN z.ToDistribute_AMNT
                                     ELSE 0
                                    END) AS Held_AMNT,
                                SUM(CASE
                                     WHEN z.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                          AND z.Distribute_DATE > @Ld_Low_DATE
                                      THEN z.ToDistribute_AMNT
                                     ELSE 0
                                    END) AS Distributed_AMNT,
                                MAX(z.EventGlobalBeginSeq_NUMB) AS seq_event_global_max,
                                @Lc_Space_TEXT AS man_dist
                           FROM RCTH_Y1 z,
                                (SELECT p.Batch_DATE,
                                        p.SourceBatch_CODE,
                                        p.Batch_NUMB,
                                        p.SeqReceipt_NUMB
                                   FROM LSUP_Y1 p
                                  WHERE p.Case_IDNO = @An_Case_IDNO
                                    AND p.Distribute_DATE >= @Ad_From_DATE
                                    AND p.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB)
                                    AND p.Receipt_DATE BETWEEN @Ld_From_DATE AND @Ld_To_DATE
                                 UNION
                                 SELECT r.Batch_DATE,
                                        r.SourceBatch_CODE,
                                        r.Batch_NUMB,
                                        r.SeqReceipt_NUMB
                                   FROM RCTH_Y1 r
                                  WHERE r.Case_IDNO = @An_Case_IDNO
                                    AND r.EndValidity_DATE = @Ld_High_DATE
                                    AND r.Receipt_DATE BETWEEN @Ld_From_DATE AND @Ld_To_DATE
                                    AND r.SourceReceipt_CODE LIKE ISNULL(@Ac_SourceReceipt_CODE, r.SourceReceipt_CODE)) AS bb
                          WHERE z.Batch_DATE = bb.Batch_DATE
                            AND z.SourceBatch_CODE = bb.SourceBatch_CODE
                            AND z.Batch_NUMB = bb.Batch_NUMB
                            AND z.SeqReceipt_NUMB = bb.SeqReceipt_NUMB
                            AND z.EndValidity_DATE = @Ld_High_DATE
                            AND z.SourceReceipt_CODE LIKE ISNULL(@Ac_SourceReceipt_CODE, z.SourceReceipt_CODE)
                            AND NOT EXISTS (SELECT 1
                                              FROM RCTH_Y1 h
                                             WHERE h.Batch_DATE = z.Batch_DATE
                                               AND h.SourceBatch_CODE = z.SourceBatch_CODE
                                               AND h.Batch_NUMB = z.Batch_NUMB
                                               AND h.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                                               AND h.BackOut_INDC = @Lc_Yes_INDC
                                               AND h.EndValidity_DATE = @Ld_High_DATE)
                            AND EXISTS (SELECT 1
                                          FROM RBAT_Y1 b
                                         WHERE b.Batch_DATE = z.Batch_DATE
                                           AND b.Batch_NUMB = z.Batch_NUMB
                                           AND b.SourceBatch_CODE = z.SourceBatch_CODE
                                           AND b.StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
                                           AND b.EndValidity_DATE = @Ld_High_DATE)
                          GROUP BY z.Batch_DATE,
                                   z.SourceBatch_CODE,
                                   z.Batch_NUMB,
                                   z.SeqReceipt_NUMB) AS aa
                  WHERE a.Batch_DATE = aa.Batch_DATE
                    AND a.SourceBatch_CODE = aa.SourceBatch_CODE
                    AND a.Batch_NUMB = aa.Batch_NUMB
                    AND a.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
                    AND a.EventGlobalBeginSeq_NUMB = aa.seq_event_global_max
                    AND a.StatusReceipt_CODE NOT IN( @Lc_StatusReceiptOthpRefund_CODE, @Lc_StatusReceiptEscheated_CODE)) AS xyz
          WHERE xyz.MultiCase_INDC = ISNULL(@Ac_MultiCase_INDC, xyz.MultiCase_INDC)
            AND xyz.ClosedCase_INDC = ISNULL(@Ac_ClosedCase_INDC, xyz.ClosedCase_INDC);

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
          END
        END
       ELSE
        BEGIN
         IF (@Ad_Batch_DATE IS NOT NULL
             AND @Ac_SourceBatch_CODE IS NOT NULL
             AND @An_Batch_NUMB IS NOT NULL
             AND @An_SeqReceipt_NUMB IS NOT NULL)
          BEGIN
           IF @An_SeqReceipt_NUMB <= 999
            BEGIN
             SET @Lc_SeqReceipt_TEXT = RIGHT (REPLICATE (0, 3) + CONVERT (VARCHAR, @An_SeqReceipt_NUMB), 3) + @Lc_Percentage_TEXT;
            END
           ELSE
            BEGIN
             SET @Lc_SeqReceipt_TEXT = RIGHT (REPLICATE (0, 6) + CONVERT (VARCHAR, @An_SeqReceipt_NUMB), 6);
            END

           SET @Ls_Sql_TEXT = 'INSERT_TMP_PRREP3';
           SET @Ls_Sqldata_TEXT = '';

           INSERT PRREP_Y1
                  (Session_ID,
                   BackOut_INDC,
                   RePost_INDC,
                   Refund_INDC,
                   Batch_DATE,
                   SourceBatch_CODE,
                   Batch_NUMB,
                   SeqReceipt_NUMB,
                   SourceReceipt_CODE,
                   Receipt_DATE,
                   PayorMCI_IDNO,
                   CasePayorMCI_IDNO,
                   Ncp_NAME,
                   Receipt_AMNT,
                   Held_AMNT,
                   Distributed_AMNT,
                   Refund_AMNT,
                   MultiCase_INDC,
                   ClosedCase_INDC,
                   MultiCounty_INDC,
                   Distd_INDC,
                   EventGlobalBeginSeq_NUMB,
                   Transaction_DATE,
                   Worker_ID,
                   RepostedPayorMci_IDNO,
                   CasePayorMCIReposted_IDNO)
           SELECT xyz.Session_ID,
                  xyz.BackOut_INDC,
                  xyz.RePost_INDC,
                  xyz.Refund_INDC,
                  xyz.Batch_DATE,
                  xyz.SourceBatch_CODE,
                  xyz.Batch_NUMB,
                  xyz.SeqReceipt_NUMB,
                  xyz.SourceReceipt_CODE,
                  xyz.Receipt_DATE,
                  xyz.PayorMCI_IDNO,
                  xyz.CasePayorMCI_IDNO,
                  xyz.Ncp_NAME,
                  xyz.Receipt_AMNT,
                  xyz.Held_AMNT,
                  xyz.amt_distd,
                  xyz.Refund_AMNT,
                  xyz.MultiCase_INDC,
                  xyz.ClosedCase_INDC,
                  xyz.MultiCounty_INDC,
                  xyz.Distd_INDC,
                  xyz.seq_event_global_beg_orig,
                  xyz.Transaction_DATE,
                  xyz.Worker_ID,
                  xyz.RepostedPayorMci_IDNO,
                  xyz.CasePayorMCIReposted_IDNO
             FROM (SELECT @Ac_Session_ID AS Session_ID,
                          @Lc_Yes_INDC AS BackOut_INDC,
                          CASE a.SourceBatch_CODE
                           WHEN @Lc_ChildSrcDirectPayCredit_CODE
                            THEN @Lc_No_INDC
                           ELSE @Lc_Yes_INDC
                          END AS RePost_INDC,
                          CASE a.SourceBatch_CODE
                           WHEN @Lc_ChildSrcDirectPayCredit_CODE
                            THEN @Lc_No_INDC
                           ELSE @Lc_Yes_INDC
                          END AS ind_recoup,
                          CASE a.SourceBatch_CODE
                           WHEN @Lc_ChildSrcDirectPayCredit_CODE
                            THEN @Lc_No_INDC
                           ELSE
                            CASE SIGN(CAST(aa.Refund_AMNT AS NUMERIC(11, 2)))
                             WHEN 0
                              THEN @Lc_No_INDC
                             ELSE @Lc_Yes_INDC
                            END
                          END AS Refund_INDC,
                          a.Batch_DATE,
                          a.SourceBatch_CODE,
                          a.Batch_NUMB,
                          a.SeqReceipt_NUMB,
                          a.SourceReceipt_CODE,
                          a.Receipt_DATE,
                          a.PayorMCI_IDNO,
                          CASE a.TypePosting_CODE
                           WHEN @Lc_TypePostingPayor_CODE
                            THEN a.PayorMCI_IDNO
                           ELSE a.Case_IDNO
                          END AS CasePayorMCI_IDNO,
                          CASE dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.PayorMCI_IDNO)
                           WHEN NULL
                            THEN @Lc_Space_TEXT
                           ELSE dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(a.PayorMCI_IDNO)
                          END AS Ncp_NAME,
                          a.Receipt_AMNT,
                          aa.Held_AMNT,
                          aa.Distributed_AMNT AS amt_distd,
                          aa.Refund_AMNT,
                          CASE
                           WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                                AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                       FROM CPFL_Y1 l
                                      WHERE l.Batch_DATE = a.Batch_DATE
                                        AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                        AND l.Batch_NUMB = a.Batch_NUMB
                                        AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                            THEN @Lc_Yes_INDC
                           WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                                AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                       FROM POFL_Y1 l
                                      WHERE l.Batch_DATE = a.Batch_DATE
                                        AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                        AND l.Batch_NUMB = a.Batch_NUMB
                                        AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                            THEN @Lc_Yes_INDC
                           WHEN a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCpFeePaymentCf_CODE, @Lc_SourceReceiptCpRecoupmentCr_CODE)
                                AND (SELECT COUNT(DISTINCT l.Case_IDNO)
                                       FROM LSUP_Y1 l
                                      WHERE l.Batch_DATE = a.Batch_DATE
                                        AND l.SourceBatch_CODE = a.SourceBatch_CODE
                                        AND l.Batch_NUMB = a.Batch_NUMB
                                        AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB) > 1
                            THEN @Lc_Yes_INDC
                           ELSE @Lc_No_INDC
                          END AS MultiCase_INDC,
                          CASE
                           WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCf_CODE
                            THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                           FROM CPFL_Y1 x,
                                                CASE_Y1 y
                                          WHERE x.Batch_DATE = a.Batch_DATE
                                            AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                            AND x.Batch_NUMB = a.Batch_NUMB
                                            AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                            AND y.Case_IDNO = x.Case_IDNO
                                            AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                           WHEN a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCr_CODE
                            THEN ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                           FROM POFL_Y1 x,
                                                CASE_Y1 y
                                          WHERE x.Batch_DATE = a.Batch_DATE
                                            AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                            AND x.Batch_NUMB = a.Batch_NUMB
                                            AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                            AND y.Case_IDNO = x.Case_IDNO
                                            AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                           ELSE ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                                          FROM LSUP_Y1 x,
                                               CASE_Y1 y
                                         WHERE x.Batch_DATE = a.Batch_DATE
                                           AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                           AND x.Batch_NUMB = a.Batch_NUMB
                                           AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                           AND y.Case_IDNO = x.Case_IDNO
                                           AND y.StatusCase_CODE = @Lc_StatusCaseClosed_CODE), @Lc_No_INDC)
                          END AS ClosedCase_INDC,
                          @Lc_Null_TEXT AS MultiCounty_INDC,
                          CASE SIGN(CAST(aa.Distributed_AMNT AS NUMERIC(11, 2)))
                           WHEN 0
                            THEN @Lc_No_INDC
                           ELSE @Lc_Yes_INDC
                          END AS Distd_INDC,
                          aa.seq_event_global_max AS seq_event_global_beg_orig,
                          @Ld_Run_DATE AS Transaction_DATE,
                          @Ac_SignedOnWorker_ID AS Worker_ID,
                          CASE a.SourceBatch_CODE
                           WHEN @Lc_ChildSrcDirectPayCredit_CODE
                            THEN 0
                           ELSE a.PayorMCI_IDNO
                          END AS RepostedPayorMci_IDNO,
                          CASE a.SourceBatch_CODE
                           WHEN @Lc_ChildSrcDirectPayCredit_CODE
                            THEN 0
                           ELSE
                            CASE a.TypePosting_CODE
                             WHEN @Lc_TypePostingPayor_CODE
                              THEN a.PayorMCI_IDNO
                             ELSE a.Case_IDNO
                            END
                          END AS CasePayorMCIReposted_IDNO
                     FROM RCTH_Y1 a
                          LEFT OUTER JOIN DEMO_Y1 b
                           ON b.MemberMci_IDNO = a.PayorMCI_IDNO,
                          (SELECT z.Batch_DATE,
                                  z.SourceBatch_CODE,
                                  z.Batch_NUMB,
                                  z.SeqReceipt_NUMB,
                                  SUM(CASE z.StatusReceipt_CODE
                                       WHEN @Lc_StatusReceiptRefunded_CODE
                                        THEN z.ToDistribute_AMNT
                                       ELSE 0
                                      END) AS Refund_AMNT,
                                  SUM(CASE
                                       WHEN z.StatusReceipt_CODE IN (@Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptUnidentified_CODE, @Lc_StatusReceiptIdentified_CODE, @Lc_StatusReceiptEscheated_CODE)
                                            AND z.Distribute_DATE = @Ld_Low_DATE
                                        THEN z.ToDistribute_AMNT
                                       ELSE 0
                                      END) AS Held_AMNT,
                                  SUM(CASE
                                       WHEN z.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                            AND z.Distribute_DATE > @Ld_Low_DATE
                                        THEN z.ToDistribute_AMNT
                                       ELSE 0
                                      END) AS Distributed_AMNT,
                                  MAX(z.EventGlobalBeginSeq_NUMB) AS seq_event_global_max,
                                  @Lc_Space_TEXT AS man_dist
                             FROM RCTH_Y1 z
                            WHERE z.Batch_DATE = @Ad_Batch_DATE
                              AND z.SourceBatch_CODE = @Ac_SourceBatch_CODE
                              AND z.Batch_NUMB = @An_Batch_NUMB
                              AND RIGHT (REPLICATE (0, 6) + CONVERT (VARCHAR, SeqReceipt_NUMB), 6) LIKE @Lc_SeqReceipt_TEXT
                              AND z.EndValidity_DATE = @Ld_High_DATE
                              AND NOT EXISTS (SELECT 1
                                                FROM RCTH_Y1 r
                                               WHERE r.Batch_DATE = z.Batch_DATE
                                                 AND r.SourceBatch_CODE = z.SourceBatch_CODE
                                                 AND r.Batch_NUMB = z.Batch_NUMB
                                                 AND r.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                                                 AND r.BackOut_INDC = @Lc_Yes_INDC
                                                 AND r.EndValidity_DATE = @Ld_High_DATE)
                              AND EXISTS (SELECT 1
                                            FROM RBAT_Y1 b
                                           WHERE b.Batch_DATE = z.Batch_DATE
                                             AND b.Batch_NUMB = z.Batch_NUMB
                                             AND b.SourceBatch_CODE = z.SourceBatch_CODE
                                             AND b.StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
                                             AND b.EndValidity_DATE = @Ld_High_DATE)
                            GROUP BY z.Batch_DATE,
                                     z.SourceBatch_CODE,
                                     z.Batch_NUMB,
                                     z.SeqReceipt_NUMB) AS aa
                    WHERE a.Batch_DATE = aa.Batch_DATE
                      AND a.SourceBatch_CODE = aa.SourceBatch_CODE
                      AND a.Batch_NUMB = aa.Batch_NUMB
                      AND a.SeqReceipt_NUMB = aa.SeqReceipt_NUMB
                      AND a.EventGlobalBeginSeq_NUMB = aa.seq_event_global_max
                      AND a.StatusReceipt_CODE NOT IN ( @Lc_StatusReceiptOthpRefund_CODE, @Lc_StatusReceiptEscheated_CODE)) AS xyz
            WHERE xyz.MultiCase_INDC = ISNULL(@Ac_MultiCase_INDC, xyz.MultiCase_INDC)
              AND xyz.ClosedCase_INDC = ISNULL(@Ac_ClosedCase_INDC, xyz.ClosedCase_INDC);

           SET @Ln_RowCount_QNTY = @@ROWCOUNT;

           IF @Ln_RowCount_QNTY = 0
            BEGIN
             SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
            END
          END
        END
      END
    END

   IF @An_ScrnFunc_NUMB = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE_PRREP - 1';
     SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Ac_Session_ID, '');    
     UPDATE PRREP_Y1
        SET BackOut_INDC = @Lc_Yes_INDC,
            RePost_INDC = @Lc_No_INDC
      WHERE Session_ID = @Ac_Session_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      END
    END
   ELSE
    BEGIN
     IF @An_ScrnFunc_NUMB = 2
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE_PRREP - 2';
       SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Ac_Session_ID,'');
       
       UPDATE PRREP_Y1
          SET BackOut_INDC = @Lc_Yes_INDC,
              RePost_INDC = CASE SourceBatch_CODE
                             WHEN @Lc_ChildSrcDirectPayCredit_CODE
                              THEN @Lc_No_INDC
                             ELSE @Lc_Yes_INDC
                            END
        WHERE Session_ID = @Ac_Session_ID;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        END
      END
     ELSE
      BEGIN
       IF @An_ScrnFunc_NUMB = 3
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE_PRREP - 3';
         SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Ac_Session_ID,'');
         
         UPDATE PRREP_Y1
            SET BackOut_INDC = @Lc_Yes_INDC,
                RePost_INDC = CASE SourceBatch_CODE
                               WHEN @Lc_ChildSrcDirectPayCredit_CODE
                                THEN @Lc_No_INDC
                               ELSE @Lc_Yes_INDC
                              END
          WHERE Session_ID = @Ac_Session_ID;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
          END
        END
      END
    END

   SET @Ls_Sql_TEXT = 'UPDATE_TMP_PRREP - 1';
   SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Ac_Session_ID,'')+ ', ClosedCase_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

   UPDATE PRREP_Y1
      SET BackOut_INDC = @Lc_No_INDC,
          RePost_INDC = @Lc_No_INDC,
          Refund_INDC = @Lc_No_INDC
    WHERE Session_ID = @Ac_Session_ID
      AND PRREP_Y1.ClosedCase_INDC = @Lc_Yes_INDC;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   ---Below code was added not do Refund and not to count the Refund Receipts 
   SET @Ls_Sql_TEXT = 'UPDATE_TMP_PRREP - 2';
   SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Ac_Session_ID,'')+ ', Refund_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

   UPDATE PRREP_Y1
      SET BackOut_INDC = @Lc_No_INDC,
          RePost_INDC = @Lc_No_INDC
    WHERE Session_ID = @Ac_Session_ID
      AND PRREP_Y1.Refund_INDC = @Lc_Yes_INDC
	  --Bug 13447 : CR0384 - For fully refunded receipt RV-Reverse, RP-Repost checkbox will be unchecked by default -START
	  AND PRREP_Y1.RECEIPT_AMNT=Refund_AMNT;
	  --Bug 13447 : CR0384 - For fully refunded receipt RV-Reverse, RP-Repost checkbox will be unchecked by default -END
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'SELECT_TMP_PRREP ';
   SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Ac_Session_ID, '');

   SELECT @An_HdrReceipt_QNTY = COUNT(1),
          @An_HdrReceipt_AMNT = ISNULL(SUM(fci.Receipt_AMNT), 0),
          @An_Receipt_QNTY = ISNULL(SUM(CAST(fci.cnt2 AS NUMERIC(11))), 0),
          @An_TotReceipt_AMNT = ISNULL(SUM(CAST(fci.amt_rect AS NUMERIC(11, 2))), 0),
          @An_TotHeld_AMNT = ISNULL(SUM(CAST(fci.Held_AMNT AS NUMERIC(11, 2))), 0),
          @An_TotDist_AMNT = ISNULL(SUM(CAST(fci.amt_dist AS NUMERIC(11, 2))), 0),
          @An_TotRefund_AMNT = ISNULL(SUM(CAST(fci.Refund_AMNT AS NUMERIC(11, 2))), 0)
     FROM (SELECT a.Receipt_AMNT,
                  CASE
                   WHEN a.BackOut_INDC = @Lc_Yes_INDC
                    THEN 1
                   ELSE 0
                  END AS cnt2,
                  CASE
                   WHEN a.BackOut_INDC = @Lc_Yes_INDC
                    THEN a.Receipt_AMNT
                   ELSE 0
                  END AS amt_rect,
                  CASE
                   WHEN a.BackOut_INDC = @Lc_Yes_INDC
                    THEN a.Held_AMNT
                   ELSE 0
                  END AS Held_AMNT,
                  CASE
                   WHEN a.BackOut_INDC = @Lc_Yes_INDC
                    THEN a.Distributed_AMNT
                   ELSE 0
                  END AS amt_dist,
                  CASE
                   WHEN a.BackOut_INDC = @Lc_Yes_INDC
                    THEN a.Refund_AMNT
                   ELSE 0
                  END AS Refund_AMNT
             FROM PRREP_Y1 a
            WHERE a.Session_ID = @Ac_Session_ID) fci;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;
  END CATCH
 END


GO
