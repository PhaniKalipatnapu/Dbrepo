/****** Object:  StoredProcedure [dbo].[RDIHR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RDIHR_RETRIEVE_S3] (
 @Ad_Transaction_DATE  DATE,
 @Ac_ReasonStatus_CODE CHAR(4),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RDIHR_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve the hold amount summary
  *     DEVELOPED BY      : IMP Team     
  *     DEVELOPED ON      : 01-NOV-2011 
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusReceiptHeld_CODE           CHAR(1) = 'H',
          @Lc_Yes_INDC                         CHAR(1) = 'Y',
          @Ld_High_DATE                        DATE = '12/31/9999',
          @Li_Zero_NUMB                        SMALLINT = 0,
          @Lc_DisburseStatusRejectedEft_CODE   CHAR(2) = 'RE',
          @Lc_DisburseStatusStopNoReissue_CODE CHAR(2) = 'SN',
          @Lc_DisburseStatusStopReissue_CODE   CHAR(2) = 'SR',
          @Lc_DisburseStatusVoidNoReissue_CODE CHAR(2) = 'VN',
          @Lc_DisburseStatusVoidReissue_CODE   CHAR(2) = 'VR',
          @Lc_StatusR_CODE                     CHAR(1) = 'R',
          @Lc_TypeHoldC_CODE                   CHAR(1) = 'C';

  SELECT f.ReasonStatus_CODE,
         f.CountSummary_QNTY,
         f.Summary_AMNT,
         f.RowCount_NUMB,
         f.Total_AMNT,
         f.CountTotal_QNTY
    FROM (SELECT e.ReasonStatus_CODE,
                 e.CountSummary_QNTY,
                 e.Summary_AMNT,
                 e.RowCount_NUMB,
                 e.Total_AMNT,
                 e.CountTotal_QNTY,
                 e.ORD_ROWNUM
            FROM (SELECT d.ReasonStatus_CODE,
                         ISNULL(d.Count_QNTY, @Li_Zero_NUMB) AS CountSummary_QNTY,
                         ISNULL(d.amt, @Li_Zero_NUMB) AS Summary_AMNT,
                         d.RowCount_NUMB,
                         SUM(d.amt) OVER() AS Total_AMNT,
                         SUM(d.Count_QNTY) OVER() AS CountTotal_QNTY,
                         ROW_NUMBER() OVER( ORDER BY d.ReasonStatus_CODE) AS ORD_ROWNUM
                    FROM (SELECT c.ReasonStatus_CODE,
                                 COUNT(1) AS Count_QNTY,
                                 SUM(c.Transaction_AMNT) AS amt,
                                 COUNT(1) OVER() AS RowCount_NUMB,
                                 ROW_NUMBER() OVER( ORDER BY c.ReasonStatus_CODE) AS ORD_ROWNUM
                            FROM (SELECT a.ReasonStatus_CODE,
                                         a.Transaction_AMNT
                                    FROM RDIHR_Y1 a
                                   WHERE a.Transaction_DATE = @Ad_Transaction_DATE
                                     AND a.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                     AND a.EndValidity_DATE > a.Transaction_DATE
                                     AND NOT EXISTS (SELECT 1
                                                       FROM RCTH_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.Transaction_DATE = b.BeginValidity_DATE
                                                        AND b.BackOut_INDC = @Lc_Yes_INDC)
                                     AND NOT EXISTS (SELECT 1
                                                       FROM RDIHR_Y1 b
                                                      WHERE a.Case_IDNO = b.Case_IDNO
                                                        AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                        AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                        AND a.Batch_DATE = b.Batch_DATE
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND (b.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                                              OR (b.Transaction_CODE = @Lc_StatusR_CODE
                                                                  AND b.TypeHold_CODE = @Lc_TypeHoldC_CODE))
                                                        AND b.TypeDisburse_CODE = a.TypeDisburse_CODE
                                                        AND b.EndValidity_DATE <= a.EndValidity_DATE
                                                        AND b.Transaction_AMNT = a.Transaction_AMNT
                                                        AND b.Transaction_DATE < a.Transaction_DATE
                                                        AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(R.EventGlobalBeginSeq_NUMB)
                                                                                            FROM RDIHR_Y1 R
                                                                                           WHERE R.Case_IDNO = a.Case_IDNO
                                                                                             AND R.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                                                             AND R.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                                                             AND R.Batch_DATE = a.Batch_DATE
                                                                                             AND R.SourceBatch_CODE = a.SourceBatch_CODE
                                                                                             AND R.Batch_NUMB = a.Batch_NUMB
                                                                                             AND R.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                                                             AND R.TypeDisburse_CODE = a.TypeDisburse_CODE
                                                                                             AND R.EndValidity_DATE <= a.EndValidity_DATE
                                                                                             AND R.Transaction_AMNT = a.Transaction_AMNT
                                                                                             AND R.Transaction_DATE < a.Transaction_DATE)
                                                        AND NOT EXISTS (SELECT 1
                                                                          FROM DSBL_Y1 b
                                                                               JOIN DSBH_Y1 h
                                                                                ON (b.CheckRecipient_ID = h.CheckRecipient_ID
                                                                                    AND b.CheckRecipient_CODE = h.CheckRecipient_CODE
                                                                                    AND b.Disburse_DATE = h.Disburse_DATE
                                                                                    AND b.DisburseSeq_NUMB = h.DisburseSeq_NUMB)
                                                                         WHERE a.Case_IDNO = b.Case_IDNO
                                                                           AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                                           AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                                           AND a.Batch_DATE = b.Batch_DATE
                                                                           AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                           AND a.Batch_NUMB = b.Batch_NUMB
                                                                           AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                           AND a.TypeDisburse_CODE = b.TypeDisburse_CODE
                                                                           AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB
                                                                           AND a.EventGlobalBeginSeq_NUMB = h.EventGlobalBeginSeq_NUMB
                                                                           AND h.StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                                                                           AND h.StatusCheck_DATE = a.Transaction_DATE
                                                                           AND h.EndValidity_DATE = @Ld_High_DATE))
                                     AND (@Ac_ReasonStatus_CODE IS NULL
                                           OR a.ReasonStatus_CODE = @Ac_ReasonStatus_CODE)) AS c
                           GROUP BY c.ReasonStatus_CODE) AS d) AS e
           WHERE (e.ORD_ROWNUM <= @Ai_RowTo_NUMB
               OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)) AS f
   WHERE (ORD_ROWNUM >= @Ai_RowFrom_NUMB
       OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB);
 END -- END OF RDIHR_RETRIEVE_S3

GO
