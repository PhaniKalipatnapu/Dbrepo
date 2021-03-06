/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S150]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S150](
 @An_PayorMCI_IDNO				NUMERIC(10, 0),
 @An_EventGlobalBeginSeq_NUMB   NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S150
  *     DESCRIPTION       : Procedure to retrieves the refunded receipts details for the given 
                            member MCI and global event sequence
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12/05/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusReceiptRefunded_CODE CHAR(1) = 'R',
          @Ld_High_DATE                  DATE    = '12/31/9999';

  SELECT r.Batch_DATE,
         r.SourceBatch_CODE,
         r.Batch_NUMB,
         r.SeqReceipt_NUMB,
         r.Receipt_DATE,
         r.Receipt_AMNT,
         r.ToDistribute_AMNT,
         r.ReasonStatus_CODE,
         g.Worker_ID,
         n.DescriptionNote_TEXT,
         s.Note1_TEXT,
         s.Note2_TEXT,
         s.Note3_TEXT,
         s.Note4_TEXT
    FROM RCTH_Y1 r
         JOIN GLEV_Y1 g
      ON r.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB
         LEFT OUTER JOIN UNOT_Y1 n
      ON n.EventGlobalApprovalSeq_NUMB = r.EventGlobalBeginSeq_NUMB
         LEFT OUTER JOIN STUB_Y1 s
      ON s.EventGlobalApprovalSeq_NUMB = r.EventGlobalBeginSeq_NUMB
   WHERE r.PayorMCI_IDNO = @An_PayorMCI_IDNO
     AND r.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND r.StatusReceipt_CODE = @Lc_StatusReceiptRefunded_CODE
     AND r.EndValidity_DATE = @Ld_High_DATE;
     
 END; --End Of Procedure RCTH_RETRIEVE_S150 


GO
