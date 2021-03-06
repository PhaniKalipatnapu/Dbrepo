/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S44] (
 @An_PayorMCI_IDNO          NUMERIC(10, 0),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19, 0),
 @Ad_EndValidity_DATE       DATE
 )
AS
 /*  
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S44  
  *     DESCRIPTION       : Retrieves the Receipt details for the given payormci, event global end sequence number and endvalidity date equal to high date.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 29-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SELECT a.Batch_DATE,
         a.SourceBatch_CODE,
         a.Batch_NUMB,
         a.SeqReceipt_NUMB,
         a.SourceReceipt_CODE,
         a.TypeRemittance_CODE,
         a.TypePosting_CODE,
         a.Case_IDNO,
         a.PayorMCI_IDNO,
         a.Receipt_AMNT,
         a.ToDistribute_AMNT,
         a.Fee_AMNT,
         a.Employer_IDNO,
         a.Fips_CODE,
         a.Check_DATE,
         a.CheckNo_Text,
         a.Receipt_DATE,
         a.ReferenceIrs_IDNO,
         a.Distribute_DATE,
         a.Tanf_CODE,
         a.TaxJoint_CODE,
         a.TaxJoint_NAME,
         a.BackOut_INDC,
         a.ReasonBackOut_CODE,
         a.Refund_DATE,
         a.RefundRecipient_ID,
         a.RefundRecipient_CODE
    FROM RCTH_Y1 a
   WHERE a.PayorMCI_IDNO = @An_PayorMCI_IDNO
     AND a.EndValidity_DATE = @Ad_EndValidity_DATE
     AND a.EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB;
 END; -- END OF RCTH_RETRIEVE_S44

GO
