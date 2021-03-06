/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S14](
 @Ad_IssueFrom_DATE DATE,
 @Ad_IssueTo_DATE   DATE,
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT =10
 )
AS
 /*          
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S14          
  *     DESCRIPTION       : Retrieves the list of agencies and their Disbursement summary.          
  *     DEVELOPED BY      : IMP Team          
  *     DEVELOPED ON      : 02-OCT-2011          
  *     MODIFIED BY       :           
  *     MODIFIED ON       :           
  *     VERSION NO        : 1          
 */
 BEGIN
  DECLARE @Lc_TypeOthp_CODE          CHAR(1)= 'O',
          @Lc_TypeDisburseRefnd_CODE CHAR(5) = 'REFND',
          @Lc_TypeDisburseRothp_CODE CHAR(5) = 'ROTHP',
          @Li_Zero_NUMB              SMALLINT =0,
          @Ld_High_DATE              DATE = '12/31/9999';

  WITH Othp_CTE
       AS (SELECT CONVERT(CHAR(10), O.OtherParty_IDNO) AS CheckRecipient_ID,
                  O.OtherParty_NAME
             FROM OTHP_Y1 O
            WHERE O.TypeOthp_CODE = @Lc_TypeOthp_CODE
              AND O.EndValidity_DATE = @Ld_High_DATE)
  SELECT Y.CheckRecipient_ID,
         CR.OtherParty_NAME,
         Y.DisbursementCOUNT_QNTY,
         Y.Disburse_AMNT,
         Y.RecoupCount_QNTY,
         Y.RecOverpay_AMNT,
         Y.SubCOUNT_QNTY,
         Y.Sub_AMNT,
         Y.TotalCOUNT_QNTY,
         Y.TotalAmount_QNTY,
         Y.RowCount_NUMB
    FROM (SELECT X.CheckRecipient_ID,
                 X.DisbursementCOUNT_QNTY,
                 X.Disburse_AMNT,
                 X.RecoupCount_QNTY,
                 X.RecOverpay_AMNT,
                 X.SubCOUNT_QNTY,
                 X.Sub_AMNT,
                 X.TotalCOUNT_QNTY,
                 X.TotalAmount_QNTY,
                 X.RowCount_NUMB,
                 X.Row_NUMB
            FROM (SELECT ISNULL(D.CheckRecipient_ID, r.CheckRecipient_ID) AS CheckRecipient_ID,
                         ISNULL(D.DisbursementCOUNT_QNTY, @Li_Zero_NUMB) AS DisbursementCOUNT_QNTY,
                         ISNULL(D.Disburse_AMNT, @Li_Zero_NUMB) AS Disburse_AMNT,
                         ISNULL(r.RecoupCount_QNTY, @Li_Zero_NUMB) AS RecoupCount_QNTY,
                         ISNULL(r.RecOverpay_AMNT, @Li_Zero_NUMB) AS RecOverpay_AMNT,
                         (ISNULL(D.DisbursementCOUNT_QNTY, @Li_Zero_NUMB) - ISNULL(r.RecoupCount_QNTY, @Li_Zero_NUMB)) AS SubCOUNT_QNTY,
                         (ISNULL(D.Disburse_AMNT, @Li_Zero_NUMB)) AS Sub_AMNT,
                         COUNT(D.DisbursementCOUNT_QNTY) OVER () AS TotalCOUNT_QNTY,
                         SUM(ISNULL(D.Disburse_AMNT, @Li_Zero_NUMB)) OVER () AS TotalAmount_QNTY,
                         COUNT(1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER() OVER (ORDER BY D.CheckRecipient_ID, r.CheckRecipient_ID) AS Row_NUMB
                    FROM (SELECT A.CheckRecipient_ID,
                                 COUNT(DISTINCT CONVERT(CHAR(10), A.case_idno) + ISNULL(CONVERT(CHAR(10), a.CaseWelfare_IDNO), ' ')) DisbursementCOUNT_QNTY,
                                 SUM(A.Disburse_AMNT) Disburse_AMNT
                            FROM (SELECT DH.CheckRecipient_ID,
                                         DH.Misc_Id,
                                         DL.case_idno,
                                         ISNULL((SELECT TOP 1 b.CaseWelfare_IDNO
                                                   FROM LWEL_Y1 b
                                                  WHERE DL.Case_IDNO = b.Case_IDNO
                                                    AND DL.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                    AND DL.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                    AND DL.Batch_DATE = b.Batch_DATE
                                                    AND DL.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND DL.Batch_NUMB = b.Batch_NUMB
                                                    AND DL.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND DL.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB
                                                    AND DL.TypeDisburse_CODE = b.TypeDisburse_CODE), (SELECT TOP 1 c.CaseWelfare_IDNO
                                                                                                        FROM WELR_Y1 c
                                                                                                       WHERE DL.Case_IDNO = c.CaseOrig_IDNO
                                                                                                         AND DL.OrderSeq_NUMB = c.OrderOrigSeq_NUMB
                                                                                                         AND DL.ObligationSeq_NUMB = c.ObleOrigSeq_NUMB
                                                                                                         AND DL.Batch_DATE = c.Batch_DATE
                                                                                                         AND DL.SourceBatch_CODE = c.SourceBatch_CODE
                                                                                                         AND DL.Batch_NUMB = c.Batch_NUMB
                                                                                                         AND DL.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                                                         AND DL.EventGlobalSupportSeq_NUMB = c.EventGlobalSupportSeq_NUMB)) CaseWelfare_IDNO,
                                         DL.Disburse_AMNT
                                    FROM DSBH_Y1 DH
                                         JOIN Othp_CTE O
                                          ON DH.CheckRecipient_ID = O.CheckRecipient_ID
                                         JOIN DSBL_Y1 DL
                                          ON DH.CheckRecipient_ID = DL.CheckRecipient_ID
                                             AND DH.CheckRecipient_CODE = DL.CheckRecipient_CODE
                                             AND DH.Disburse_DATE = DL.Disburse_DATE
                                             AND DH.DisburseSeq_NUMB = DL.DisburseSeq_NUMB
                                             AND DH.EventGlobalBeginSeq_NUMB = DL.EventGlobalSeq_NUMB
                                             AND DL.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE)
                                   WHERE DH.Issue_DATE BETWEEN @Ad_IssueFrom_DATE AND @Ad_IssueTo_DATE)A
                           GROUP BY A.CheckRecipient_ID) D
                         FULL OUTER JOIN (SELECT P.CheckRecipient_ID,
                                                 COUNT(DISTINCT P.Case_IDNO) AS RecoupCount_QNTY,
                                                 SUM(P.RecOverpay_AMNT) AS RecOverpay_AMNT
                                            FROM POFL_Y1 P
                                                 JOIN Othp_CTE ORE
                                                  ON p.CheckRecipient_ID = ORE.CheckRecipient_ID
                                           WHERE P.Transaction_DATE BETWEEN @Ad_IssueFrom_DATE AND @Ad_IssueTo_DATE
                                             AND P.RecOverpay_AMNT > @Li_Zero_NUMB
                                           GROUP BY P.CheckRecipient_ID) R
                          ON D.CheckRecipient_ID = r.CheckRecipient_ID) X
           WHERE ((X.Row_NUMB <= @Ai_RowTo_NUMB)
               OR (@Ai_RowTo_NUMB = @Li_Zero_NUMB))) Y
         JOIN Othp_CTE CR
          ON Y.CheckRecipient_ID = CR.CheckRecipient_ID
   WHERE ((Y.Row_NUMB >= @Ai_RowFrom_NUMB)
       OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB));
 END; -- End Of DSBL_RETRIEVE_S14  

GO
