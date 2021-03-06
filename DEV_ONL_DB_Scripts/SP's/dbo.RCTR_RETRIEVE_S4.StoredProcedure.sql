/****** Object:  StoredProcedure [dbo].[RCTR_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_RETRIEVE_S4] (
 @Ad_Batch_DATE               DATE,
 @An_Batch_NUMB               NUMERIC(4, 0),
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @An_ReceiptCurrent_AMNT      NUMERIC(11, 2) OUTPUT,
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_RETRIEVE_S4
  *     DESCRIPTION       : Procedure To Retrieve The Receipt Ammount And EventGlobalbeginSeq, By Using RCTR_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 18-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_ReceiptCurrent_AMNT = NULL,
         @An_EventGlobalBeginSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_ReceiptCurrent_AMNT = r.ReceiptCurrent_AMNT,
         @An_EventGlobalBeginSeq_NUMB = r.EventGlobalBeginSeq_NUMB
    FROM RCTR_Y1 r
   WHERE r.Batch_DATE = @Ad_Batch_DATE
     AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND r.Batch_NUMB = @An_Batch_NUMB
     AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND r.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of Procedure RCTR_RETRIEVE_S4

GO
