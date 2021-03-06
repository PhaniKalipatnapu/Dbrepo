/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S54]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S54] (
 @Ad_Batch_DATE         DATE,
 @Ac_SourceBatch_CODE   CHAR(3),
 @An_Batch_NUMB         NUMERIC(4, 0),
 @An_SeqReceipt_NUMB    NUMERIC(6, 0),
 @Ac_SourceReceipt_CODE CHAR(2),
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_PayorMCI_IDNO      NUMERIC(10, 0),
 @Ac_SourceBatchIn_CODE  CHAR(3),
 @Ai_RowFrom_NUMB       INT =1,
 @Ai_RowTo_NUMB         INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S54
  *     DESCRIPTION       : Retrieve the Receipt details for the given PayorMci Idno
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 27-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_INDC                      CHAR(1) = 'N',
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_StatusReceiptHeld_CODE       CHAR(1) = 'H',
          @Lc_StatusReceiptIdentified_CODE CHAR(1) = 'I',
          @Lc_StatusReceiptRefunded_CODE   CHAR(1) = 'R',
          @Lc_Yes_INDC                     CHAR(1) = 'Y',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Ld_Low_DATE                     DATE = '01/01/0001',
          @Li_Zero_NUMB                    SMALLINT= 0,
          @Lc_ReasonStatusSnip_CODE        CHAR(4) = 'SNIP',
          @Lc_ReasonStatusSnrp_CODE        CHAR(4) = 'SNRP',
          @Lc_SourceReceiptSc_CODE         CHAR(2) = 'SC',
          @Li_One_NUMB                     SMALLINT = 1,
          @Lc_TaxJointJ_CODE               CHAR(1) = 'J';

  SELECT Z.Batch_DATE,
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
         Z.Ir_INDC,
         Z.OnlyIr_INDC,
         Z.EventGlobalLockSeq_NUMB,
         Z.EventGlobalUdcSeq_NUMB,
         Z.TaxJoint_CODE,
         Z.CheckNo_Text,
         Z.TypeRemittance_CODE,
         Z.Case_IDNO,
         Z.MemberSsn_NUMB,
         Z.Last_NAME,
         Z.Suffix_NAME,
         Z.First_NAME,
         Z.Middle_NAME,
         Z.RowCount_NUMB,
         Z.Total_AMNT
    FROM (SELECT Y.Batch_DATE,
                 Y.SourceBatch_CODE,
                 Y.Batch_NUMB,
                 Y.SeqReceipt_NUMB,
                 Y.Receipt_DATE,
                 Y.SourceReceipt_CODE,
                 Y.Receipt_AMNT,
                 Y.Held_AMNT,
                 Y.ToDistribute_AMNT,
                 Y.ToRefund_AMNT,
                 Y.Distributed_AMNT,
                 Y.Refunded_AMNT,
                 Y.ReasonStatus_CODE,
                 Y.Worker_ID,
                 Y.Ref_INDC,
                 Y.PayorMCI_IDNO,
                 Y.Ir_INDC,
                 Y.OnlyIr_INDC,
                 Y.EventGlobalLockSeq_NUMB,
                 Y.EventGlobalUdcSeq_NUMB,
                 Y.TaxJoint_CODE,
                 Y.CheckNo_Text,
                 Y.TypeRemittance_CODE,
                 Y.Case_IDNO,
                 Y.MemberSsn_NUMB,
                 Y.Last_NAME,
                 Y.Suffix_NAME,
                 Y.First_NAME,
                 Y.Middle_NAME,
                 Y.RowCount_NUMB,
                 Y.Total_AMNT,
                 Y.ORD_ROWNUM AS rnm
            FROM (SELECT X.Batch_DATE,
                         X.SourceBatch_CODE,
                         X.Batch_NUMB,
                         X.SeqReceipt_NUMB,
                         X.Receipt_DATE,
                         X.SourceReceipt_CODE,
                         X.Receipt_AMNT,
                         X.Held_AMNT,
                         X.ToDistribute_AMNT,
                         (CAST(X.Held_AMNT AS FLOAT(53)) + CAST(X.ToDistribute_AMNT AS FLOAT(53))) AS ToRefund_AMNT,
                         X.Distributed_AMNT,
                         X.Refunded_AMNT,
                         X.ReasonStatus_CODE,
                         X.Worker_ID,
                         @Lc_No_INDC AS Ref_INDC,
                         X.PayorMCI_IDNO,
                         MAX(CASE
                              WHEN X.SourceReceipt_CODE = @Lc_SourceReceiptSc_CODE
                                   AND X.TaxJoint_CODE = @Lc_TaxJointJ_CODE
                               THEN @Lc_Yes_INDC
                              ELSE @Lc_No_INDC
                             END) OVER() AS Ir_INDC,
                         MIN(CASE
                              WHEN X.SourceReceipt_CODE = @Lc_SourceReceiptSc_CODE
                                   AND X.TaxJoint_CODE = @Lc_TaxJointJ_CODE
                               THEN @Lc_Yes_INDC
                              ELSE @Lc_No_INDC
                             END) OVER() AS OnlyIr_INDC,
                         X.EventGlobalLockSeq_NUMB,
                         X.EventGlobalUdcSeq_NUMB,
                         X.TaxJoint_CODE,
                         X.CheckNo_Text,
                         X.TypeRemittance_CODE,
                         X.Case_IDNO,
                         X.MemberSsn_NUMB,
                         X.Last_NAME,
                         X.Suffix_NAME,
                         X.First_NAME,
                         X.Middle_NAME,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         SUM(CAST(X.Held_AMNT AS FLOAT(53)) + CAST(X.ToDistribute_AMNT AS FLOAT(53))) OVER() AS Total_AMNT,
                         ROW_NUMBER() OVER( ORDER BY X.Batch_DATE, X.SourceBatch_CODE, X.Batch_NUMB, X.SeqReceipt_NUMB) AS ORD_ROWNUM
                    FROM (SELECT a.Batch_DATE,
                                 a.SourceBatch_CODE,
                                 a.Batch_NUMB,
                                 a.SeqReceipt_NUMB,
                                 a.Receipt_DATE,
                                 a.SourceReceipt_CODE,
                                 a.Receipt_AMNT,
                                 SUM(CAST(a.amt_held_m AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS Held_AMNT,
                                 SUM(CAST(a.amt_to_distribute_m AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS ToDistribute_AMNT,
                                 SUM(CAST(a.amt_distributed_m AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS Distributed_AMNT,
                                 SUM(CAST(a.amt_refunded_m AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS Refunded_AMNT,
                                 MAX(a.cd_reason_status_m) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS ReasonStatus_CODE,
                                 a.Worker_ID,
                                 a.PayorMCI_IDNO,
                                 MAX(CAST(a.Seq_Event_Global_Lock_m AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS EventGlobalLockSeq_NUMB,
                                 MAX(CAST(a.seq_event_global_udc_m AS FLOAT(53))) OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS EventGlobalUdcSeq_NUMB,
                                 a.TaxJoint_CODE,
                                 a.CheckNo_Text,
                                 a.TypeRemittance_CODE,
                                 a.Case_IDNO,
                                 a.MemberSsn_NUMB,
                                 a.Last_NAME,
                                 a.Suffix_NAME,
                                 a.First_NAME,
                                 a.Middle_NAME,
                                 ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS Seq_IDNO
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
                                         END AS amt_held_m,
                                         CASE
                                          WHEN a.Distribute_DATE = @Ld_Low_DATE
                                               AND a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                           THEN a.ToDistribute_AMNT
                                          ELSE @Li_Zero_NUMB
                                         END AS amt_to_distribute_m,
                                         CASE
                                          WHEN a.Distribute_DATE > @Ld_Low_DATE
                                               AND a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                           THEN a.ToDistribute_AMNT
                                          ELSE @Li_Zero_NUMB
                                         END AS amt_distributed_m,
                                         CASE
                                          WHEN a.Distribute_DATE > @Ld_Low_DATE
                                               AND a.StatusReceipt_CODE = @Lc_StatusReceiptRefunded_CODE
                                           THEN a.ToDistribute_AMNT
                                          ELSE @Li_Zero_NUMB
                                         END AS amt_refunded_m,
                                         CASE
                                          WHEN a.Distribute_DATE = @Ld_Low_DATE
                                               AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                           THEN a.ReasonStatus_CODE
                                          ELSE @Lc_Space_TEXT
                                         END AS cd_reason_status_m,
                                         g.Worker_ID,
                                         a.PayorMCI_IDNO,
                                         a.EventGlobalBeginSeq_NUMB AS Seq_Event_Global_Lock_m,
                                         CASE
                                          WHEN a.Distribute_DATE = @Ld_Low_DATE
                                               AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                           THEN a.EventGlobalBeginSeq_NUMB
                                          ELSE @Li_Zero_NUMB
                                         END AS seq_event_global_udc_m,
                                         a.TaxJoint_CODE,
                                         a.CheckNo_Text,
                                         a.TypeRemittance_CODE,
                                         a.Case_IDNO,
                                         d.MemberSsn_NUMB,
                                         d.Last_NAME,
                                         d.Suffix_NAME,
                                         d.First_NAME,
                                         d.Middle_NAME,
                                         a.EventGlobalBeginSeq_NUMB
                                    FROM RCTH_Y1 a
                                         JOIN GLEV_Y1 g
                                          ON g.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB
                                         JOIN DEMO_Y1 d
                                          ON a.PayorMCI_IDNO = d.MemberMci_IDNO
                                         JOIN (SELECT DISTINCT r.Batch_DATE,
                                                      r.SourceBatch_CODE,
                                                      r.Batch_NUMB,
                                                      r.SeqReceipt_NUMB
                                                 FROM RCTH_Y1 r
                                                WHERE r.PayorMCI_IDNO = ISNULL(@An_PayorMCI_IDNO, r.PayorMCI_IDNO)
                                                  AND r.Batch_DATE = ISNULL(@Ad_Batch_DATE, r.Batch_DATE)
                                                  AND r.SourceBatch_CODE = ISNULL(@Ac_SourceBatch_CODE, r.SourceBatch_CODE)
                                                  AND r.Batch_NUMB = ISNULL(@An_Batch_NUMB, r.Batch_NUMB)
                                                  AND r.SeqReceipt_NUMB = ISNULL(@An_SeqReceipt_NUMB, r.SeqReceipt_NUMB)
                                                  AND r.SourceBatch_CODE = ISNULL(@Ac_SourceBatchIn_CODE , r.SourceBatch_CODE)
                                                  AND r.SourceReceipt_CODE = ISNULL(@Ac_SourceReceipt_CODE, r.SourceReceipt_CODE)
                                                  AND r.Case_IDNO = ISNULL(@An_Case_IDNO, r.Case_IDNO)
                                                  AND ((r.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                                        AND r.ReasonStatus_CODE NOT IN (@Lc_ReasonStatusSnrp_CODE, @Lc_ReasonStatusSnip_CODE))
                                                        OR (r.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE))
                                                  AND r.Distribute_DATE = @Ld_Low_DATE
                                                  AND r.EndValidity_DATE = @Ld_High_DATE) AS b
                                          ON a.Batch_DATE = b.Batch_DATE
                                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                             AND a.Batch_NUMB = b.Batch_NUMB
                                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                   WHERE a.EndValidity_DATE = @Ld_High_DATE) AS a) AS X
                   WHERE X.Seq_IDNO = @Li_One_NUMB) AS Y
           WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Z
   WHERE Z.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;
 END -- End of RCTH_RETRIEVE_S54

GO
