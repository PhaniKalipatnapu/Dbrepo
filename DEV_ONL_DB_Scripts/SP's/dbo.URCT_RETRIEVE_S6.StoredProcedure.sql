/****** Object:  StoredProcedure [dbo].[URCT_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[URCT_RETRIEVE_S6] (
 @Ac_RefundRecipient_CODE CHAR(1),
 @Ac_RefundRecipient_ID   CHAR(10),
 @Ai_RowFrom_NUMB         INT =1,
 @Ai_RowTo_NUMB           INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : URCT_RETRIEVE_S6
  *     DESCRIPTION       : Retrieves the Receipt details for a given Recipient ID
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 30-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusReceiptUnidentified_CODE CHAR(1) = 'U',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Lc_ReasonStatusUsrp_CODE          CHAR(4) = 'USRP';

  SELECT Y.Batch_DATE,
         Y.Batch_NUMB,
         Y.SeqReceipt_NUMB,
         Y.SourceBatch_CODE,
         Y.EventGlobalBeginSeq_NUMB,
         Y.IdentificationStatus_CODE,
         Y.SourceReceipt_CODE,
         Y.TypeRemittance_CODE,
         Y.CheckNo_TEXT,
         Y.Receipt_AMNT,
         Y.ToDistribute_AMNT,
         Y.Receipt_DATE,
         Y.Payor_NAME,
         Y.Total_AMNT,
         Y.RowCount_NUMB
    FROM (SELECT X.Batch_DATE,
                 X.SourceBatch_CODE,
                 X.Batch_NUMB,
                 X.SeqReceipt_NUMB,
                 X.CheckNo_TEXT,
                 X.TypeRemittance_CODE,
                 X.SourceReceipt_CODE,
                 X.Receipt_DATE,
                 X.Receipt_AMNT,
                 X.ToDistribute_AMNT,
                 X.IdentificationStatus_CODE,
                 X.Payor_NAME,
                 X.RowCount_NUMB,
                 X.Total_AMNT,
                 X.EventGlobalBeginSeq_NUMB,
                 X.ORD_ROWNUM AS rnm
            FROM (SELECT a.Batch_DATE,
                         a.SourceBatch_CODE,
                         a.Batch_NUMB,
                         a.SeqReceipt_NUMB,
                         b.CheckNo_TEXT,
                         b.TypeRemittance_CODE,
                         a.SourceReceipt_CODE,
                         b.Receipt_DATE,
                         b.Receipt_AMNT,
                         b.ToDistribute_AMNT,
                         a.IdentificationStatus_CODE,
                         a.Payor_NAME,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         SUM(b.Receipt_AMNT) OVER() AS Total_AMNT,
                         b.EventGlobalBeginSeq_NUMB AS EventGlobalBeginSeq_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Batch_DATE DESC, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS ORD_ROWNUM
                    FROM URCT_Y1 a
                         JOIN RCTH_Y1 b
                          ON a.Batch_DATE = b.Batch_DATE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                   WHERE b.EndValidity_DATE = @Ld_High_DATE
                     AND a.EndValidity_DATE = @Ld_High_DATE
                     AND b.RefundRecipient_ID = @Ac_RefundRecipient_ID
                     AND b.RefundRecipient_CODE = @Ac_RefundRecipient_CODE
                     AND b.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
                     AND b.ReasonStatus_CODE = @Lc_ReasonStatusUsrp_CODE
                     AND b.Distribute_DATE = @Ld_Low_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;
 END -- End of URCT_RETRIEVE_S6

GO
