/****** Object:  StoredProcedure [dbo].[RDIHR_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RDIHR_RETRIEVE_S4](
 @Ad_Transaction_DATE  DATE,
 @Ac_ReasonStatus_CODE CHAR(4),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RDIHR_RETRIEVE_S4
  *     DESCRIPTION       : Retrieve the reasonstatus_code and transaction amount.
  *     DEVELOPED BY      : IMP Team     
  *     DEVELOPED ON      : 02-NOV-2011  
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusReceiptHeld_CODE           CHAR(1) = 'H',
          @Ld_Low_DATE                         DATE = '01/01/0001',
          @Li_Zero_NUMB                        SMALLINT = 0,
          @Lc_ChildSrcDacsesDcs_CODE           CHAR(3) = 'DCS',
          @Lc_DisburseStatusRejectedEft_CODE   CHAR(2) = 'RE',
          @Lc_DisburseStatusStopNoReissue_CODE CHAR(2) = 'SN',
          @Lc_DisburseStatusStopReissue_CODE   CHAR(2) = 'SR',
          @Lc_DisburseStatusVoidNoReissue_CODE CHAR(2) = 'VN',
          @Lc_DisburseStatusVoidReissue_CODE   CHAR(2) = 'VR',
          @Lc_StatusR_CODE                     CHAR(1) = 'R',
          @Lc_TypeHoldC_CODE                   CHAR(1) = 'C',
          @Li_One_NUMB                         SMALLINT = 1,
          @Lc_CheckReceipent999999980_ID       CHAR(10) ='999999980';

  SELECT p.ReasonStatus_CODE,
         p.Count_QNTY AS CountSummary_QNTY,
         p.Transaction_AMNT AS Summary_AMNT,
         p.RowCount_NUMB,
         p.Total_AMNT,
         p.CountTotal_QNTY
    FROM (SELECT o.ReasonStatus_CODE,
                 o.Count_QNTY,
                 o.Transaction_AMNT,
                 o.RowCount_NUMB,
                 o.Total_AMNT,
                 o.CountTotal_QNTY,
                 o.ORD_ROWNUM
            FROM (SELECT n.ReasonStatus_CODE,
                         ISNULL(n.Count_QNTY, @Li_Zero_NUMB) AS Count_QNTY,
                         ISNULL(n.Transaction_AMNT, @Li_Zero_NUMB) AS Transaction_AMNT,
                         n.RowCount_NUMB,
                         SUM(n.Transaction_AMNT) OVER() AS Total_AMNT,
                         SUM(n.Count_QNTY) OVER() AS CountTotal_QNTY,
                         ROW_NUMBER() OVER( ORDER BY n.ReasonStatus_CODE) AS ORD_ROWNUM
                    FROM (SELECT m.ReasonStatus_CODE,
                                 COUNT(1) AS Count_QNTY,
                                 SUM(m.Transaction_AMNT) AS Transaction_AMNT,
                                 COUNT(1) OVER() AS RowCount_NUMB,
                                 ROW_NUMBER() OVER( ORDER BY m.ReasonStatus_CODE) AS ORD_ROWNUM
                            FROM (SELECT k.ReasonStatus_CODE,
                                         k.Value_AMNT AS Transaction_AMNT,
                                         ROW_NUMBER() OVER(PARTITION BY k.Batch_DATE, k.SourceBatch_CODE, k.Batch_NUMB, k.SeqReceipt_NUMB, k.Case_IDNO, k.OrderSeq_NUMB, k.ObligationSeq_NUMB ORDER BY k.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                                    FROM (SELECT j.CheckRecipient_ID,
                                                 j.CheckRecipient_CODE,
                                                 j.Disburse_DATE,
                                                 j.DisburseSeq_NUMB,
                                                 j.Transaction_DATE,
                                                 j.Case_IDNO,
                                                 j.PayorMCI_IDNO,
                                                 j.ObligationKey_TEXT,
                                                 j.TypeDisburse_CODE,
                                                 j.Transaction_AMNT,
                                                 j.Receipt_ID,
                                                 j.TypeHold_CODE,
                                                 j.DescriptionHold_TEXT,
                                                 j.ControlNo_TEXT,
                                                 j.County_IDNO,
                                                 j.ReasonStatus_CODE,
                                                 j.DescriptionReason_TEXT,
                                                 j.BeginValidity_DATE,
                                                 j.EndValidity_DATE,
                                                 j.First_NAME,
                                                 j.Last_NAME,
                                                 j.Middle_NAME,
                                                 j.Worker_ID,
                                                 j.Release_DATE,
                                                 j.MemberSsn_NUMB,
                                                 j.RespondInit_CODE,
                                                 j.Recipient_NAME,
                                                 j.Transaction_CODE,
                                                 j.EventGlobalBeginSeq_NUMB,
                                                 j.EventGlobalEndSeq_NUMB,
                                                 j.EventGlobalSupportSeq_NUMB,
                                                 j.OrderSeq_NUMB,
                                                 j.ObligationSeq_NUMB,
                                                 j.Batch_DATE,
                                                 j.SourceBatch_CODE,
                                                 j.Batch_NUMB,
                                                 j.SeqReceipt_NUMB,
                                                 j.Disburse_AMNT,
                                                 j.ORD_ROWNUM,
                                                 j.Value_AMNT
                                            FROM (SELECT a.CheckRecipient_ID,
                                                         a.CheckRecipient_CODE,
                                                         a.Disburse_DATE,
                                                         a.DisburseSeq_NUMB,
                                                         a.Transaction_DATE,
                                                         a.Case_IDNO,
                                                         a.PayorMCI_IDNO,
                                                         a.ObligationKey_TEXT,
                                                         a.TypeDisburse_CODE,
                                                         a.Transaction_AMNT,
                                                         a.Receipt_ID,
                                                         a.TypeHold_CODE,
                                                         a.DescriptionHold_TEXT,
                                                         a.ControlNo_TEXT,
                                                         a.County_IDNO,
                                                         a.ReasonStatus_CODE,
                                                         a.DescriptionReason_TEXT,
                                                         a.BeginValidity_DATE,
                                                         a.EndValidity_DATE,
                                                         a.First_NAME,
                                                         a.Last_NAME,
                                                         a.Middle_NAME,
                                                         a.Worker_ID,
                                                         a.Release_DATE,
                                                         a.MemberSsn_NUMB,
                                                         a.RespondInit_CODE,
                                                         a.Recipient_NAME,
                                                         a.Transaction_CODE,
                                                         a.EventGlobalBeginSeq_NUMB,
                                                         a.EventGlobalEndSeq_NUMB,
                                                         a.EventGlobalSupportSeq_NUMB,
                                                         a.OrderSeq_NUMB,
                                                         a.ObligationSeq_NUMB,
                                                         a.Batch_DATE,
                                                         a.SourceBatch_CODE,
                                                         a.Batch_NUMB,
                                                         a.SeqReceipt_NUMB,
                                                         a.Disburse_AMNT,
                                                         a.ORD_ROWNUM,
                                                         a.Disburse_AMNT AS Value_AMNT
                                                    FROM (SELECT a.CheckRecipient_ID,
                                                                 a.CheckRecipient_CODE,
                                                                 a.Disburse_DATE,
                                                                 a.DisburseSeq_NUMB,
                                                                 a.Transaction_DATE,
                                                                 a.Case_IDNO,
                                                                 a.PayorMCI_IDNO,
                                                                 a.ObligationKey_TEXT,
                                                                 a.TypeDisburse_CODE,
                                                                 a.Transaction_AMNT,
                                                                 a.Receipt_ID,
                                                                 a.TypeHold_CODE,
                                                                 a.DescriptionHold_TEXT,
                                                                 a.ControlNo_TEXT,
                                                                 a.County_IDNO,
                                                                 a.ReasonStatus_CODE,
                                                                 a.DescriptionReason_TEXT,
                                                                 a.BeginValidity_DATE,
                                                                 a.EndValidity_DATE,
                                                                 a.First_NAME,
                                                                 a.Last_NAME,
                                                                 a.Middle_NAME,
                                                                 a.Worker_ID,
                                                                 a.Release_DATE,
                                                                 a.MemberSsn_NUMB,
                                                                 a.RespondInit_CODE,
                                                                 a.Recipient_NAME,
                                                                 a.Transaction_CODE,
                                                                 a.EventGlobalBeginSeq_NUMB,
                                                                 a.EventGlobalEndSeq_NUMB,
                                                                 a.EventGlobalSupportSeq_NUMB,
                                                                 a.OrderSeq_NUMB,
                                                                 a.ObligationSeq_NUMB,
                                                                 a.Batch_DATE,
                                                                 a.SourceBatch_CODE,
                                                                 a.Batch_NUMB,
                                                                 a.SeqReceipt_NUMB,
                                                                 b.Disburse_AMNT,
                                                                 ROW_NUMBER() OVER(PARTITION BY b.CheckRecipient_ID, b.CheckRecipient_CODE, b.Disburse_DATE, b.DisburseSeq_NUMB, b.DisburseSubSeq_NUMB ORDER BY b.EventGlobalSeq_NUMB) AS ORD_ROWNUM
                                                            FROM RDIHR_Y1 a WITH (INDEX(0))
                                                                 JOIN DSBL_Y1 b WITH (INDEX(0))
                                                                  ON (a.Case_IDNO = b.Case_IDNO
                                                                      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                                      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                                      AND a.Batch_DATE = b.Batch_DATE
                                                                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                      AND a.Batch_NUMB = b.Batch_NUMB
                                                                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                      AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB)
                                                                 JOIN DSBH_Y1 h WITH (INDEX(0))
                                                                  ON (b.CheckRecipient_ID = h.CheckRecipient_ID
                                                                      AND b.CheckRecipient_CODE = h.CheckRecipient_CODE
                                                                      AND b.Disburse_DATE = h.Disburse_DATE
                                                                      AND b.DisburseSeq_NUMB = h.DisburseSeq_NUMB)
                                                                 JOIN CASE_Y1 x WITH (INDEX(0))
                                                                  ON (a.Case_IDNO = x.Case_IDNO)
                                                           WHERE a.EndValidity_DATE = @Ad_Transaction_DATE
                                                             AND a.Transaction_DATE < @Ad_Transaction_DATE
                                                             AND (a.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                                                   OR (a.Transaction_CODE = @Lc_StatusR_CODE
                                                                       AND a.TypeHold_CODE = @Lc_TypeHoldC_CODE))
                                                             AND b.Disburse_DATE = @Ad_Transaction_DATE
                                                             AND b.Batch_DATE != @Ld_Low_DATE
															 --13562 - DIHR - receiving system error Fix - Start
                                                             AND @Ad_Transaction_DATE BETWEEN h.BeginValidity_DATE AND h.EndValidity_DATE
															 --13562 - DIHR - receiving system error Fix - End
                                                             AND b.CheckRecipient_ID != @Lc_CheckReceipent999999980_ID
                                                             AND (b.SourceBatch_CODE NOT IN (@Lc_ChildSrcDacsesDcs_CODE)
                                                                   OR (b.SourceBatch_CODE IN (@Lc_ChildSrcDacsesDcs_CODE)
                                                                       AND EXISTS (SELECT 1
                                                                                     FROM RCTR_Y1 c
                                                                                    WHERE b.Batch_DATE = c.Batch_DATE
                                                                                      AND b.Batch_NUMB = c.Batch_NUMB
                                                                                      AND b.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                                      AND b.SourceBatch_CODE = c.SourceBatch_CODE
                                                                                      AND c.BeginValidity_DATE <= @Ad_Transaction_DATE
                                                                                      AND c.EndValidity_DATE > @Ad_Transaction_DATE)))
                                                             AND NOT EXISTS (SELECT 1
                                                                               FROM DSBC_Y1 x
                                                                                    JOIN DSBH_Y1 y
                                                                                     ON (y.Disburse_DATE = x.DisburseOrig_DATE
                                                                                         AND y.DisburseSeq_NUMB = x.DisburseOrigSeq_NUMB
                                                                                         AND y.CheckRecipient_ID = x.CheckRecipientOrig_ID
                                                                                         AND y.CheckRecipient_CODE = x.CheckRecipientOrig_CODE)
                                                                              WHERE b.Disburse_DATE = x.Disburse_DATE
                                                                                AND b.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                                                                AND b.CheckRecipient_ID = x.CheckRecipient_ID
                                                                                AND b.CheckRecipient_CODE = x.CheckRecipient_CODE
                                                                                AND y.StatusCheck_CODE IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                                                                                AND y.EndValidity_DATE > @Ad_Transaction_DATE)) AS a
                                                   WHERE a.ORD_ROWNUM <= @Li_One_NUMB
                                                  UNION ALL
                                                  SELECT i.CheckRecipient_ID,
                                                         i.CheckRecipient_CODE,
                                                         i.Disburse_DATE,
                                                         i.DisburseSeq_NUMB,
                                                         i.Transaction_DATE,
                                                         i.Case_IDNO,
                                                         i.PayorMCI_IDNO,
                                                         i.ObligationKey_TEXT,
                                                         i.TypeDisburse_CODE,
                                                         i.Transaction_AMNT,
                                                         i.Receipt_ID,
                                                         i.TypeHold_CODE,
                                                         i.DescriptionHold_TEXT,
                                                         i.ControlNo_TEXT,
                                                         i.County_IDNO,
                                                         i.ReasonStatus_CODE,
                                                         i.DescriptionReason_TEXT,
                                                         i.BeginValidity_DATE,
                                                         i.EndValidity_DATE,
                                                         i.First_NAME,
                                                         i.Last_NAME,
                                                         i.Middle_NAME,
                                                         i.Worker_ID,
                                                         i.Release_DATE,
                                                         i.MemberSsn_NUMB,
                                                         i.RespondInit_CODE,
                                                         i.Recipient_NAME,
                                                         i.Transaction_CODE,
                                                         i.EventGlobalBeginSeq_NUMB,
                                                         i.EventGlobalEndSeq_NUMB,
                                                         i.EventGlobalSupportSeq_NUMB,
                                                         i.OrderSeq_NUMB,
                                                         i.ObligationSeq_NUMB,
                                                         i.Batch_DATE,
                                                         i.SourceBatch_CODE,
                                                         i.Batch_NUMB,
                                                         i.SeqReceipt_NUMB,
                                                         i.RecOverpay_AMNT,
                                                         i.ORD_ROWNUM,
                                                         i.RecOverpay_AMNT AS Value_AMNT
                                                    FROM (SELECT a.CheckRecipient_ID,
                                                                 a.CheckRecipient_CODE,
                                                                 a.Disburse_DATE,
                                                                 a.DisburseSeq_NUMB,
                                                                 a.Transaction_DATE,
                                                                 a.Case_IDNO,
                                                                 a.PayorMCI_IDNO,
                                                                 a.ObligationKey_TEXT,
                                                                 a.TypeDisburse_CODE,
                                                                 a.Transaction_AMNT,
                                                                 a.Receipt_ID,
                                                                 a.TypeHold_CODE,
                                                                 a.DescriptionHold_TEXT,
                                                                 a.ControlNo_TEXT,
                                                                 a.County_IDNO,
                                                                 a.ReasonStatus_CODE,
                                                                 a.DescriptionReason_TEXT,
                                                                 a.BeginValidity_DATE,
                                                                 a.EndValidity_DATE,
                                                                 a.First_NAME,
                                                                 a.Last_NAME,
                                                                 a.Middle_NAME,
                                                                 a.Worker_ID,
                                                                 a.Release_DATE,
                                                                 a.MemberSsn_NUMB,
                                                                 a.RespondInit_CODE,
                                                                 a.Recipient_NAME,
                                                                 a.Transaction_CODE,
                                                                 a.EventGlobalBeginSeq_NUMB,
                                                                 a.EventGlobalEndSeq_NUMB,
                                                                 a.EventGlobalSupportSeq_NUMB,
                                                                 a.OrderSeq_NUMB,
                                                                 a.ObligationSeq_NUMB,
                                                                 a.Batch_DATE,
                                                                 a.SourceBatch_CODE,
                                                                 a.Batch_NUMB,
                                                                 a.SeqReceipt_NUMB,
                                                                 f.RecOverpay_AMNT,
                                                                 ROW_NUMBER() OVER(PARTITION BY f.Unique_IDNO ORDER BY f.EventGlobalSeq_NUMB) AS ORD_ROWNUM
                                                            FROM RDIHR_Y1 a WITH (INDEX(0))
                                                                 JOIN POFL_Y1 f WITH (INDEX(0))
                                                                  ON (a.Case_IDNO = f.Case_IDNO
                                                                      AND a.OrderSeq_NUMB = f.OrderSeq_NUMB
                                                                      AND a.ObligationSeq_NUMB = f.ObligationSeq_NUMB
                                                                      AND a.Batch_DATE = f.Batch_DATE
                                                                      AND a.SourceBatch_CODE = f.SourceBatch_CODE
                                                                      AND a.Batch_NUMB = f.Batch_NUMB
                                                                      AND a.SeqReceipt_NUMB = f.SeqReceipt_NUMB
                                                                      AND a.EventGlobalSupportSeq_NUMB = f.EventGlobalSupportSeq_NUMB)
                                                           WHERE a.EndValidity_DATE = @Ad_Transaction_DATE
                                                             AND a.Transaction_DATE < @Ad_Transaction_DATE
                                                             AND (a.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                                                   OR (a.Transaction_CODE = @Lc_StatusR_CODE
                                                                       AND a.TypeHold_CODE = @Lc_TypeHoldC_CODE))
                                                             AND f.Transaction_DATE = @Ad_Transaction_DATE
                                                             AND (f.RecOverpay_AMNT + f.RecAdvance_AMNT > @Li_Zero_NUMB)
                                                             AND (f.SourceBatch_CODE NOT IN (@Lc_ChildSrcDacsesDcs_CODE)
                                                                   OR (f.SourceBatch_CODE IN (@Lc_ChildSrcDacsesDcs_CODE)
                                                                       AND EXISTS (SELECT 1
                                                                                     FROM RCTR_Y1 d
                                                                                    WHERE f.Batch_DATE = d.Batch_DATE
                                                                                      AND f.Batch_NUMB = d.Batch_NUMB
                                                                                      AND f.SeqReceipt_NUMB = d.SeqReceipt_NUMB
                                                                                      AND f.SourceBatch_CODE = d.SourceBatch_CODE
                                                                                      AND d.BeginValidity_DATE <= @Ad_Transaction_DATE
                                                                                      AND d.EndValidity_DATE > @Ad_Transaction_DATE)))) AS i
                                                   WHERE i.ORD_ROWNUM <= @Li_One_NUMB) AS j
                                           WHERE (@Ac_ReasonStatus_CODE IS NULL
                                               OR j.ReasonStatus_CODE = @Ac_ReasonStatus_CODE)) AS k) AS m
                           WHERE m.ORD_ROWNUM = @Li_One_NUMB
                           GROUP BY m.ReasonStatus_CODE) AS n) AS o
           WHERE (o.ORD_ROWNUM <= @Ai_RowTo_NUMB
               OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)) AS p
   WHERE (ORD_ROWNUM >= @Ai_RowFrom_NUMB
       OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB);
 END -- END OF RDIHR_RETRIEVE_S4

GO
