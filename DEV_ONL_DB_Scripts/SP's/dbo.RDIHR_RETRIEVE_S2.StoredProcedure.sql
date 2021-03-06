/****** Object:  StoredProcedure [dbo].[RDIHR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RDIHR_RETRIEVE_S2] (
 @Ad_Transaction_DATE  DATE,
 @Ac_ReasonStatus_CODE CHAR(4),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RDIHR_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve the count summary for how many   reasonstatus_codes are hold or release.
  *     DEVELOPED BY      : IMP Team     
  *     DEVELOPED ON      : 01-NOV-2011 
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusReceiptHeld_CODE CHAR(1) = 'H',
          @Li_Zero_NUMB              SMALLINT = 0,
          @Lc_StatusR_CODE           CHAR(1) = 'R',
          @Lc_TypeHoldC_CODE         CHAR(1) = 'C';

  SELECT e.ReasonStatus_CODE,
         e.CountSummary_QNTY,
         e.Summary_AMNT,
         e.RowCount_NUMB,
         e.Total_AMNT,
         e.CountTotal_QNTY
    FROM (SELECT d.ReasonStatus_CODE,
                 d.CountSummary_QNTY,
                 d.Summary_AMNT,
                 d.RowCount_NUMB,
                 d.Total_AMNT,
                 d.CountTotal_QNTY,
                 d.ORD_ROWNUM
            FROM (SELECT c.ReasonStatus_CODE,
                         ISNULL(c.Count_QNTY, @Li_Zero_NUMB) AS CountSummary_QNTY,
                         ISNULL(c.amt, @Li_Zero_NUMB) AS Summary_AMNT,
                         c.RowCount_NUMB,
                         SUM(c.amt) OVER() AS Total_AMNT,
                         SUM(c.Count_QNTY) OVER() AS CountTotal_QNTY,
                         ROW_NUMBER() OVER( ORDER BY c.ReasonStatus_CODE) AS ORD_ROWNUM
                    FROM (SELECT b.ReasonStatus_CODE,
                                 COUNT(1) AS Count_QNTY,
                                 SUM(b.Transaction_AMNT) AS amt,
                                 COUNT(1) OVER() AS RowCount_NUMB,
                                 ROW_NUMBER() OVER( ORDER BY b.ReasonStatus_CODE) AS ORD_ROWNUM
                            FROM (SELECT a.TypeHold_CODE,
                                         a.ReasonStatus_CODE,
                                         a.Transaction_AMNT,
                                         ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                                    FROM RDIHR_Y1 a
                                   WHERE ((a.Transaction_DATE = @Ad_Transaction_DATE
                                           AND a.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                           AND a.EndValidity_DATE > a.Transaction_DATE)
                                           OR (a.EndValidity_DATE = @Ad_Transaction_DATE
                                               AND (a.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                                     OR (a.Transaction_CODE = @Lc_StatusR_CODE
                                                         AND a.TypeHold_CODE = @Lc_TypeHoldC_CODE))
                                               AND a.EndValidity_DATE > a.Transaction_DATE))
                                     AND (@Ac_ReasonStatus_CODE IS NULL
                                           OR a.ReasonStatus_CODE = @Ac_ReasonStatus_CODE)) AS b
                           GROUP BY b.ReasonStatus_CODE) AS c) AS d
           WHERE (d.ORD_ROWNUM <= @Ai_RowTo_NUMB
               OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)) AS e
   WHERE (e.ORD_ROWNUM >= @Ai_RowFrom_NUMB
       OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB);
 END -- End of RDIHR_RETRIEVE_S2

GO
