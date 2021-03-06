/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S63]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S63] (
 @Ac_RefundRecipient_CODE CHAR(1),
 @Ac_RefundRecipient_ID   CHAR(10),
 @As_Recipient_NAME       VARCHAR(60),
 @As_Line1_ADDR           VARCHAR(50),
 @As_Line2_ADDR           VARCHAR(50),
 @Ac_City_ADDR            CHAR(28),
 @Ac_State_ADDR           CHAR(2),
 @Ac_Zip_ADDR             CHAR(15),
 @Ai_RowFrom_NUMB         INT = 1,
 @Ai_RowTo_NUMB           INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S63
  *     DESCRIPTION       : Retrieve the receipt details for a particular receipient.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 29-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_INDC                      CHAR(1) = 'N',
          @Lc_StatusReceiptHeld_CODE       CHAR(1) = 'H',
          @Lc_StatusReceiptIdentified_CODE CHAR(1) = 'I',
          @Lc_StatusReceiptRefunded_CODE   CHAR(1) = 'R',
          @Lc_Yes_INDC                     CHAR(1) = 'Y',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Ld_Low_DATE                     DATE = '01/01/0001',
          @Li_Zero_NUMB                    SMALLINT = 0,
          @Lc_ReasonStatusSnrp_CODE        CHAR(4) = 'SNRP',
          @Lc_SourceReceiptSc_CODE         CHAR(2) = 'SC',
          @Lc_TaxJointJ_CODE               CHAR(1) = 'J';

  SELECT Y.Batch_DATE,
         Y.SourceBatch_CODE,
         Y.Batch_NUMB,
         Y.SeqReceipt_NUMB,
         Y.EventGlobalBeginSeq_NUMB,
         Y.Receipt_DATE,
         Y.SourceReceipt_CODE,
         Y.Case_IDNO,
         Y.PayorMCI_IDNO,
         Y.Receipt_AMNT,
         Y.ToDistribute_AMNT,
         Y.CheckNo_Text,
         Y.ReasonStatus_CODE,
         Y.Held_AMNT,
         Y.ToRefund_AMNT,
         Y.Distributed_AMNT,
         Y.Refunded_AMNT,
         Y.Worker_ID,
         Y.Ref_INDC,
         Y.Ir_INDC,
         Y.OnlyIr_INDC,
         Y.TypeRemittance_CODE,
         Y.MemberSsn_NUMB,
         Y.Last_NAME,
         Y.Suffix_NAME,
         Y.First_NAME,
         Y.Middle_NAME,
         Y.ReasonBackOut_CODE,
         Y.Recipient_NAME,
         Y.Line1_ADDR,
         Y.Line2_ADDR,
         Y.City_ADDR,
         Y.State_ADDR,
         Y.Zip_ADDR,
         Y.RowCount_NUMB,
         Y.Total_AMNT
    FROM (SELECT X.Batch_DATE,
                 X.SourceBatch_CODE,
                 X.Batch_NUMB,
                 X.SeqReceipt_NUMB,
                 X.Receipt_DATE,
                 X.SourceReceipt_CODE,
                 X.Receipt_AMNT,
                 X.Held_AMNT,
                 X.ToDistribute_AMNT,
                 X.ToRefund_AMNT,
                 X.Distributed_AMNT,
                 X.Refunded_AMNT,
                 X.ReasonStatus_CODE,
                 X.Worker_ID,
                 X.Ref_INDC,
                 X.PayorMCI_IDNO,
                 X.Ir_INDC,
                 X.OnlyIr_INDC,
                 X.EventGlobalBeginSeq_NUMB,
                 X.CheckNo_Text,
                 X.TypeRemittance_CODE,
                 X.Case_IDNO,
                 X.MemberSsn_NUMB,
                 X.Last_NAME,
                 X.Suffix_NAME,
                 X.First_NAME,
                 X.Middle_NAME,
                 X.ReasonBackOut_CODE,
                 X.Recipient_NAME,
                 X.Line1_ADDR,
                 X.Line2_ADDR,
                 X.City_ADDR,
                 X.State_ADDR,
                 X.Zip_ADDR,
                 X.RowCount_NUMB,
                 X.Total_AMNT,
                 X.ORD_ROWNUM AS rnm
            FROM (SELECT Z.Batch_DATE,
                         Z.SourceBatch_CODE,
                         Z.Batch_NUMB,
                         Z.SeqReceipt_NUMB,
                         Z.Receipt_DATE,
                         Z.SourceReceipt_CODE,
                         Z.Receipt_AMNT,
                         Z.Held_AMNT,
                         Z.ToDistribute_AMNT,
                         Z.ToRefund_AMNT,
                         Z.Distributed_AMNT,
                         Z.Refunded_AMNT,
                         Z.ReasonStatus_CODE,
                         Z.Worker_ID,
                         Z.Ref_INDC,
                         Z.PayorMCI_IDNO,
                         Z.ind_ir_l,
                         Z.ind_only_ir_l,
                         Z.EventGlobalBeginSeq_NUMB,
                         Z.CheckNo_Text,
                         Z.TypeRemittance_CODE,
                         Z.Case_IDNO,
                         Z.MemberSsn_NUMB,
                         Z.Last_NAME,
                         Z.Suffix_NAME,
                         Z.First_NAME,
                         Z.Middle_NAME,
                         Z.ReasonBackOut_CODE,
                         Z.Recipient_NAME,
                         Z.Line1_ADDR,
                         Z.Line2_ADDR,
                         Z.City_ADDR,
                         Z.State_ADDR,
                         Z.Zip_ADDR,
                         Z.RowCount_NUMB,
                         Z.Total_AMNT,
                         MAX(z.ind_ir_L) OVER() AS Ir_INDC,
                         MIN(z.ind_only_ir_L) OVER() AS OnlyIr_INDC,
                         ROW_NUMBER() OVER( ORDER BY z.Receipt_DATE) AS ORD_ROWNUM
                    FROM (SELECT q.Batch_DATE,
                                 q.SourceBatch_CODE,
                                 q.Batch_NUMB,
                                 q.SeqReceipt_NUMB,
                                 q.Receipt_DATE,
                                 q.SourceReceipt_CODE,
                                 q.Receipt_AMNT,
                                 q.Held_AMNT,
                                 q.ToDistribute_AMNT,
                                 q.ToRefund_AMNT,
                                 q.Distributed_AMNT,
                                 q.Refunded_AMNT,
                                 q.ReasonStatus_CODE,
                                 g.Worker_ID,
                                 @Lc_No_INDC AS Ref_INDC,
                                 q.PayorMCI_IDNO,
                                 CASE
                                  WHEN q.SourceReceipt_CODE = @Lc_SourceReceiptSc_CODE
                                       AND q.TaxJoint_CODE = @Lc_TaxJointJ_CODE
                                   THEN @Lc_Yes_INDC
                                  ELSE @Lc_No_INDC
                                 END AS ind_ir_l,
                                 CASE
                                  WHEN q.SourceReceipt_CODE = @Lc_SourceReceiptSc_CODE
                                       AND q.TaxJoint_CODE = @Lc_TaxJointJ_CODE
                                   THEN @Lc_Yes_INDC
                                  ELSE @Lc_No_INDC
                                 END AS ind_only_ir_l,
                                 q.EventGlobalBeginSeq_NUMB,
                                 q.CheckNo_Text,
                                 q.TypeRemittance_CODE,
                                 q.Case_IDNO,
                                 d.MemberSsn_NUMB,
                                 d.Last_NAME,
                                 d.Suffix_NAME,
                                 d.First_NAME,
                                 d.Middle_NAME,
                                 q.ReasonBackOut_CODE,
                                 @As_Recipient_NAME AS Recipient_NAME,
                                 @As_Line1_ADDR AS Line1_ADDR,
                                 @As_Line2_ADDR AS Line2_ADDR,
                                 @Ac_City_ADDR AS City_ADDR,
                                 @Ac_State_ADDR AS State_ADDR,
                                 @Ac_Zip_ADDR AS Zip_ADDR,
                                 COUNT(1) OVER() AS RowCount_NUMB,
                                 SUM(CAST(q.ToRefund_AMNT AS FLOAT(53))) OVER() AS Total_AMNT
                            FROM (SELECT a.Batch_DATE,
                                         a.SourceBatch_CODE,
                                         a.Batch_NUMB,
                                         a.SeqReceipt_NUMB,
                                         a.Receipt_DATE,
                                         a.SourceReceipt_CODE,
                                         a.Receipt_AMNT,
                                         a.ToRefund_AMNT,
                                         a.ReasonStatus_CODE,
                                         a.PayorMCI_IDNO,
                                         a.EventGlobalBeginSeq_NUMB,
                                         a.TaxJoint_CODE,
                                         a.CheckNo_Text,
                                         a.TypeRemittance_CODE,
                                         a.Case_IDNO,
                                         a.ReasonBackOut_CODE,
                                         a.StatusReceipt_CODE,
                                         a.Distribute_DATE,
                                         a.RefundRecipient_ID,
                                         a.RefundRecipient_CODE,
                                         SUM(CAST(a.amt_held_l AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS Held_AMNT,
                                         SUM(CAST(a.amt_to_distribute_l AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS ToDistribute_AMNT,
                                         SUM(CAST(a.amt_distributed_l AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS Distributed_AMNT,
                                         SUM(CAST(a.amt_refunded_l AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS Refunded_AMNT
                                    FROM (SELECT a.Batch_DATE,
                                                 a.SourceBatch_CODE,
                                                 a.Batch_NUMB,
                                                 a.SeqReceipt_NUMB,
                                                 a.Receipt_DATE,
                                                 a.SourceReceipt_CODE,
                                                 a.Receipt_AMNT,
                                                 CASE
                                                  WHEN a.Distribute_DATE = @Ld_Low_DATE
                                                       AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                                       AND a.ReasonStatus_CODE != @Lc_ReasonStatusSnrp_CODE
                                                   THEN a.ToDistribute_AMNT
                                                  ELSE @Li_Zero_NUMB
                                                 END AS amt_held_l,
                                                 CASE
                                                  WHEN a.Distribute_DATE = @Ld_Low_DATE
                                                       AND a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                                       AND a.ReasonStatus_CODE != @Lc_ReasonStatusSnrp_CODE
                                                   THEN a.ToDistribute_AMNT
                                                  ELSE @Li_Zero_NUMB
                                                 END AS amt_to_distribute_l,
                                                 a.ToDistribute_AMNT AS ToRefund_AMNT,
                                                 CASE
                                                  WHEN a.Distribute_DATE > @Ld_Low_DATE
                                                       AND a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                                   THEN a.ToDistribute_AMNT
                                                  ELSE @Li_Zero_NUMB
                                                 END AS amt_distributed_l,
                                                 CASE
                                                  WHEN a.Distribute_DATE > @Ld_Low_DATE
                                                       AND a.StatusReceipt_CODE = @Lc_StatusReceiptRefunded_CODE
                                                   THEN a.ToDistribute_AMNT
                                                  ELSE @Li_Zero_NUMB
                                                 END AS amt_refunded_l,
                                                 a.ReasonStatus_CODE,
                                                 a.PayorMCI_IDNO,
                                                 a.EventGlobalBeginSeq_NUMB,
                                                 a.TaxJoint_CODE,
                                                 a.CheckNo_Text,
                                                 a.TypeRemittance_CODE,
                                                 a.Case_IDNO,
                                                 a.ReasonBackOut_CODE,
                                                 a.StatusReceipt_CODE,
                                                 a.Distribute_DATE,
                                                 a.RefundRecipient_ID,
                                                 a.RefundRecipient_CODE
                                            FROM RCTH_Y1 a,
                                                 (SELECT DISTINCT x.Batch_DATE,
                                                         x.SourceBatch_CODE,
                                                         x.Batch_NUMB,
                                                         x.SeqReceipt_NUMB
                                                    FROM RCTH_Y1 x
                                                   WHERE x.RefundRecipient_ID = @Ac_RefundRecipient_ID
                                                     AND x.RefundRecipient_CODE = @Ac_RefundRecipient_CODE
                                                     AND x.StatusReceipt_CODE IN (@Lc_StatusReceiptHeld_CODE)
                                                     AND x.Distribute_DATE = @Ld_Low_DATE
                                                     AND x.EndValidity_DATE = @Ld_High_DATE
                                                     AND x.ReasonStatus_CODE = @Lc_ReasonStatusSnrp_CODE) AS b
                                           WHERE a.Batch_DATE = b.Batch_DATE
                                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                             AND a.Batch_NUMB = b.Batch_NUMB
                                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                             AND a.EndValidity_DATE = @Ld_High_DATE) AS a) AS q
                                 JOIN GLEV_Y1 g
                                  ON g.EventGlobalSeq_NUMB = q.EventGlobalBeginSeq_NUMB
                                 JOIN DEMO_Y1 d
                                  ON d.MemberMci_IDNO = q.PayorMCI_IDNO
                           WHERE q.ReasonStatus_CODE = @Lc_ReasonStatusSnrp_CODE
                             AND q.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                             AND q.Distribute_DATE = @Ld_Low_DATE
                             AND q.RefundRecipient_ID = @Ac_RefundRecipient_ID
                             AND q.RefundRecipient_CODE = @Ac_RefundRecipient_CODE) AS Z) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;
 END -- End of RCTH_RETRIEVE_S63

GO
