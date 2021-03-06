/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S127]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S127](
 @Ac_CheckRecipient_ID CHAR(10),
 @Ad_From_DATE         DATE,
 @Ad_To_DATE           DATE,
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*          
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S127          
  *     DESCRIPTION       : Retrieves the disbursement details for the respective agency          
  *     DEVELOPED BY      : IMP Team          
  *     DEVELOPED ON      : 02-OCT-2011          
  *     MODIFIED BY       :           
  *     MODIFIED ON       :           
  *     VERSION NO        : 1          
 */
 BEGIN
  DECLARE @Lc_CheckRecipientOthp_CODE     CHAR(1) = '3',
          @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Li_Zero_NUMB                   SMALLINT = 0,
          @Lc_TypeDisburseRefnd_CODE      CHAR(5) = 'REFND',
          @Lc_TypeDisburseRothp_CODE      CHAR(5) = 'ROTHP';

  SELECT Z.Case_IDNO,
         Z.Last_NAME,
         Z.Suffix_NAME,
         Z.First_NAME,
         Z.Middle_NAME,
         Z.CaseWelfare_IDNO,
         Z.Disburse_AMNT,
         Z.RecordType_CODE,
         Z.TotalDisburse_AMNT,
         Z.RowCount_NUMB
    FROM (SELECT Y.RecordType_CODE,
                 Y.Last_NAME,
                 Y.Suffix_NAME,
                 Y.First_NAME,
                 Y.Middle_NAME,
                 Y.Case_IDNO,
                 Y.CaseWelfare_IDNO,
                 Y.Disburse_AMNT,
                 Y.TotalDisburse_AMNT,
                 Y.ORD_ROWNUM,
                 Y.RowCount_NUMB,
                 Y.TransType_CODE
            FROM (SELECT X.RecordType_CODE,
                         X.Last_NAME,
                         X.Suffix_NAME,
                         X.First_NAME,
                         X.Middle_NAME,
                         X.Case_IDNO,
                         X.CaseWelfare_IDNO,
                         SUM(CAST(X.Disburse_AMNT AS FLOAT(53))) Disburse_AMNT,
                         SUM(SUM(CAST(CASE
                                       WHEN X.Disburse_AMNT > @Li_Zero_NUMB
                                        THEN X.Disburse_AMNT
                                       ELSE @Li_Zero_NUMB
                                      END AS FLOAT(53)))) OVER() TotalDisburse_AMNT,
                         COUNT(1) OVER() RowCount_NUMB,
                         X.TransType_CODE,
                         ROW_NUMBER() OVER( ORDER BY X.RecordType_CODE, X.TransType_CODE, X.Last_NAME, X.Suffix_NAME, X.First_NAME, X.Middle_NAME, X.CaseWelfare_IDNO, X.Case_IDNO) ORD_ROWNUM
                    FROM (SELECT 'Disbursement' RecordType_CODE,
                                 d.Last_NAME,
                                 d.Suffix_NAME,
                                 d.First_NAME,
                                 d.Middle_NAME,
                                 a.Case_IDNO,
                                 ISNULL((SELECT TOP 1 b.CaseWelfare_IDNO
                                           FROM LWEL_Y1 b
                                          WHERE a.Case_IDNO = b.Case_IDNO
                                            AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                            AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                            AND a.Batch_DATE = b.Batch_DATE
                                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                            AND a.Batch_NUMB = b.Batch_NUMB
                                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                            AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB
                                            AND a.TypeDisburse_CODE = b.TypeDisburse_CODE), (SELECT TOP 1 c.CaseWelfare_IDNO
                                                                                               FROM WELR_Y1 c
                                                                                              WHERE a.Case_IDNO = c.CaseOrig_IDNO
                                                                                                AND a.OrderSeq_NUMB = c.OrderOrigSeq_NUMB
                                                                                                AND a.ObligationSeq_NUMB = c.ObleOrigSeq_NUMB
                                                                                                AND a.Batch_DATE = c.Batch_DATE
                                                                                                AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                                                                AND a.Batch_NUMB = c.Batch_NUMB
                                                                                                AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                                                AND a.EventGlobalSupportSeq_NUMB = c.EventGlobalSupportSeq_NUMB)) CaseWelfare_IDNO,
                                 a.Disburse_AMNT,
                                 1 AS TransType_CODE
                            FROM DSBL_Y1 a
                                 JOIN DSBH_Y1 f
                                  ON (f.CheckRecipient_ID = a.CheckRecipient_ID
                                      AND f.CheckRecipient_CODE = a.CheckRecipient_CODE
                                      AND f.Disburse_DATE = a.Disburse_DATE
                                      AND f.DisburseSeq_NUMB = a.DisburseSeq_NUMB
                                      AND f.EventGlobalBeginSeq_NUMB = a.EventGlobalSeq_NUMB)
                                 JOIN CMEM_Y1 c
                                  ON (a.Case_IDNO = c.Case_IDNO)
                                 JOIN DEMO_Y1 d
                                  ON (c.MemberMci_IDNO = d.MemberMci_IDNO)
                           WHERE a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE)
                             AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                             AND f.CheckRecipient_ID = @Ac_CheckRecipient_ID
                             AND f.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                             AND f.Issue_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
                          UNION ALL
                          SELECT 'Recoupment' RecordType_CODE,
                                 d.Last_NAME,
                                 d.Suffix_NAME,
                                 d.First_NAME,
                                 d.Middle_NAME,
                                 a.Case_IDNO,
                                 ISNULL((SELECT TOP 1 b.CaseWelfare_IDNO
                                           FROM LWEL_Y1 b
                                          WHERE a.Case_IDNO = b.Case_IDNO
                                            AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                            AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                            AND a.Batch_DATE = b.Batch_DATE
                                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                            AND a.Batch_NUMB = b.Batch_NUMB
                                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                            AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB
                                            AND a.TypeDisburse_CODE = b.TypeDisburse_CODE), (SELECT TOP 1 c.CaseWelfare_IDNO
                                                                                               FROM WELR_Y1 c
                                                                                              WHERE a.Case_IDNO = c.CaseOrig_IDNO
                                                                                                AND a.OrderSeq_NUMB = c.OrderOrigSeq_NUMB
                                                                                                AND a.ObligationSeq_NUMB = c.ObleOrigSeq_NUMB
                                                                                                AND a.Batch_DATE = c.Batch_DATE
                                                                                                AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                                                                AND a.Batch_NUMB = c.Batch_NUMB
                                                                                                AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                                                AND a.EventGlobalSupportSeq_NUMB = c.EventGlobalSupportSeq_NUMB)) CaseWelfare_IDNO,
                                 -a.RecOverpay_AMNT Disburse_AMNT,
                                 2 TransType_CODE
                            FROM POFL_Y1 a
                                 JOIN CMEM_Y1 c
                                  ON (a.Case_IDNO = c.Case_IDNO)
                                 JOIN DEMO_Y1 d
                                  ON (c.MemberMci_IDNO = d.MemberMci_IDNO)
                           WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
                             AND a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                             AND a.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
                             AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                             AND a.RecOverpay_AMNT > @Li_Zero_NUMB) X
                   GROUP BY X.RecordType_CODE,
                            X.TransType_CODE,
                            X.Last_NAME,
                            X.Suffix_NAME,
                            X.First_NAME,
                            X.Middle_NAME,
                            X.CaseWelfare_IDNO,
                            X.Case_IDNO) Y
           WHERE (Y.ORD_ROWNUM <= @Ai_RowTo_NUMB
               OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB))) Z
   WHERE (Z.ORD_ROWNUM >= @Ai_RowFrom_NUMB
       OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB))
   ORDER BY ORD_ROWNUM;
 END; -- End Of DEMO_RETRIEVE_S127

GO
