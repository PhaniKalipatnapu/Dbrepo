/****** Object:  StoredProcedure [dbo].[RDIHR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RDIHR_RETRIEVE_S1] (
 @Ad_Transaction_DATE  DATE,
 @Ac_ReasonStatus_CODE CHAR(4),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RDIHR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the hold reason summary 
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusReceiptHeld_CODE CHAR(1) ='H',
          @Li_Zero_NUMB              SMALLINT = 0;

  SELECT d.ReasonStatus_CODE,
         d.CountSummary_QNTY,
         d.Summary_AMNT,
         d.RowCount_NUMB,
         d.Total_AMNT,
         d.CountTotal_QNTY
    FROM (SELECT c.ReasonStatus_CODE,
                 c.CountSummary_QNTY,
                 c.Summary_AMNT,
                 c.RowCount_NUMB,
                 c.Total_AMNT,
                 c.CountTotal_QNTY,
                 c.ORD_ROWNUM
            FROM (SELECT b.ReasonStatus_CODE,
                         ISNULL(b.Count_QNTY, @Li_Zero_NUMB) AS CountSummary_QNTY,
                         ISNULL(b.Transaction_AMNT, @Li_Zero_NUMB) AS Summary_AMNT,
                         b.RowCount_NUMB,
                         SUM(b.Transaction_AMNT) OVER() AS Total_AMNT,
                         SUM(b.Count_QNTY) OVER() AS CountTotal_QNTY,
                         ROW_NUMBER() OVER(ORDER BY b.ReasonStatus_CODE) AS ORD_ROWNUM
                    FROM (SELECT a.ReasonStatus_CODE,
                                 COUNT(1) AS Count_QNTY,
                                 SUM(a.Transaction_AMNT) AS Transaction_AMNT,
                                 COUNT(1) OVER() AS RowCount_NUMB
                            FROM (SELECT r.ReasonStatus_CODE,
                                         r.Transaction_AMNT,
                                         ROW_NUMBER() OVER(PARTITION BY r.ObligationKey_TEXT, r.Receipt_ID, r.TypeDisburse_CODE ORDER BY r.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                                    FROM RDIHR_Y1 r
                                   WHERE r.Transaction_DATE <= @Ad_Transaction_DATE
                                     AND r.EndValidity_DATE > @Ad_Transaction_DATE
                                     AND r.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                     AND (@Ac_ReasonStatus_CODE IS NULL
                                           OR r.ReasonStatus_CODE = @Ac_ReasonStatus_CODE)) AS a
                           GROUP BY a.ReasonStatus_CODE) AS b) AS c
           WHERE (c.ORD_ROWNUM <= @Ai_RowTo_NUMB
               OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)) AS d
   WHERE (ORD_ROWNUM >= @Ai_RowFrom_NUMB
       OR @Ai_RowTo_NUMB = @Li_Zero_NUMB);
 END -- End of RDIHR_RETRIEVE_S1

GO
