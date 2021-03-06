/****** Object:  StoredProcedure [dbo].[RDIHR_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RDIHR_RETRIEVE_S7] (
 @Ac_CheckRecipient_ID CHAR(10),
 @Ad_Transaction_DATE  DATE,
 @Ac_ReasonStatus_CODE CHAR(4),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RDIHR_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve the checkrecipient, transaction amount and receipients details.
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
          @Lc_DisburseStatusRejectedEft_CODE   CHAR(2) = 'RE',
          @Lc_DisburseStatusStopNoReissue_CODE CHAR(2) = 'SN',
          @Lc_DisburseStatusStopReissue_CODE   CHAR(2) = 'SR',
          @Lc_DisburseStatusVoidNoReissue_CODE CHAR(2) = 'VN',
          @Lc_DisburseStatusVoidReissue_CODE   CHAR(2) = 'VR',
          @Lc_StatusR_CODE                     CHAR(1) = 'R',
          @Lc_TypeHoldC_CODE                   CHAR(1) = 'C',
          @Li_Zero_NUMB                        SMALLINT = 0;

  SELECT X.CheckRecipient_ID,
         X.CheckRecipient_CODE,
         X.Case_IDNO,
         X.PayorMCI_IDNO,
         X.Transaction_AMNT,
         X.Receipt_ID,
         X.ControlNo_TEXT,
         X.ReasonStatus_CODE,
         X.BeginValidity_DATE,
         X.First_NAME,
         X.Last_NAME,
         X.Middle_NAME,
         X.Worker_ID,
         X.Release_DATE,
         X.RespondInit_CODE,
         X.Recipient_NAME,
         X.Transaction_CODE,
         X.RowCount_NUMB,
         X.Total_AMNT
    FROM (SELECT d.CheckRecipient_ID,
                 d.CheckRecipient_CODE,
                 d.Case_IDNO,
                 d.PayorMCI_IDNO,
                 d.Transaction_AMNT,
                 d.Receipt_ID,
                 d.ControlNo_TEXT,
                 d.ReasonStatus_CODE,
                 d.BeginValidity_DATE,
                 d.First_NAME,
                 d.Last_NAME,
                 d.Middle_NAME,
                 d.Worker_ID,
                 d.Release_DATE,
                 d.RespondInit_CODE,
                 d.Recipient_NAME,
                 d.Transaction_CODE,
                 d.RowCount_NUMB,
                 d.Total_AMNT,
                 d.ORD_ROWNUM
            FROM (SELECT c.CheckRecipient_ID,
                         c.CheckRecipient_CODE,
                         c.Case_IDNO,
                         c.PayorMCI_IDNO,
                         c.Transaction_AMNT,
                         c.Receipt_ID,
                         c.ControlNo_TEXT,
                         c.ReasonStatus_CODE,
                         c.BeginValidity_DATE,
                         c.First_NAME,
                         c.Last_NAME,
                         c.Middle_NAME,
                         c.Worker_ID,
                         c.Release_DATE,
                         c.RespondInit_CODE,
                         c.Recipient_NAME,
                         c.Transaction_CODE,
                         c.EventGlobalBeginSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         SUM(c.Transaction_AMNT) OVER() AS Total_AMNT,
                         ROW_NUMBER() OVER( ORDER BY c.Worker_ID, c.Release_DATE, c.Case_IDNO, c.Receipt_ID, c.EventGlobalBeginSeq_NUMB) AS ORD_ROWNUM
                    FROM (SELECT a.CheckRecipient_ID,
                                 a.CheckRecipient_CODE,
                                 a.Case_IDNO,
                                 a.PayorMCI_IDNO,
                                 a.Transaction_AMNT,
                                 a.Receipt_ID,
                                 a.ControlNo_TEXT,
                                 a.ReasonStatus_CODE,
                                 a.BeginValidity_DATE,
                                 a.First_NAME,
                                 a.Last_NAME,
                                 a.Middle_NAME,
                                 a.Worker_ID,
                                 a.Release_DATE,
                                 a.RespondInit_CODE,
                                 a.Recipient_NAME,
                                 a.Transaction_CODE,
                                 a.EventGlobalBeginSeq_NUMB
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
                                   OR a.ReasonStatus_CODE = @Ac_ReasonStatus_CODE)
                             AND (@Ac_CheckRecipient_ID IS NULL
                                   OR a.CheckRecipient_ID = @Ac_CheckRecipient_ID)) AS c) AS d
           WHERE (d.ORD_ROWNUM <= @Ai_RowTo_NUMB
               OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)) AS X
   WHERE (X.ORD_ROWNUM >= @Ai_RowFrom_NUMB
       OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB)
   ORDER BY ORD_ROWNUM;
 END -- END OF RDIHR_RETRIEVE_S7

GO
