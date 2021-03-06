/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S58]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S58] (
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4, 0),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @Ac_StatusReceipt_CODE       CHAR(1),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_EventGlobalEndSeq_NUMB   NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S58
  *     DESCRIPTION       : Retrirves the details about a particular identified receipt.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 28-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_Low_DATE     DATE = '01/01/0001',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT TOP 1 R.Batch_DATE,
               R.SourceBatch_CODE,
               R.Batch_NUMB,
               R.SeqReceipt_NUMB,
               R.SourceReceipt_CODE,
               R.TypeRemittance_CODE,
               R.TypePosting_CODE,
               R.PayorMCI_IDNO,
               R.Case_IDNO,
               R.Receipt_AMNT,
               R.Fee_AMNT,
               R.Employer_IDNO,
               R.Fips_CODE,
               R.Check_DATE,
               R.CheckNo_TEXT,
               R.Receipt_DATE,
               R.Distribute_DATE,
               R.Tanf_CODE,
               R.TaxJoint_CODE,
               R.TaxJoint_NAME,
               R.ReasonStatus_CODE,
               R.BackOut_INDC,
               R.ReasonBackOut_CODE,
               R.Refund_DATE,
               R.Release_DATE,
               R.RefundRecipient_ID,
               R.RefundRecipient_CODE
    FROM RCTH_Y1 R
   WHERE R.Batch_DATE = @Ad_Batch_DATE
     AND R.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND R.Batch_NUMB = @An_Batch_NUMB
     AND R.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND R.StatusReceipt_CODE = @Ac_StatusReceipt_CODE
     AND R.Distribute_DATE = @Ld_Low_DATE
     AND R.EndValidity_DATE = @Ld_Current_DATE
     AND R.EventGlobalEndSeq_NUMB = ISNULL(@An_EventGlobalEndSeq_NUMB, R.EventGlobalEndSeq_NUMB)
     AND R.EventGlobalBeginSeq_NUMB = ISNULL(@An_EventGlobalBeginSeq_NUMB, R.EventGlobalBeginSeq_NUMB);
 END -- End of RCTH_RETRIEVE_S58

GO
