/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S29](
 @An_Case_IDNO					NUMERIC(6),
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19),
 @Ac_CheckRecipient_CODE		CHAR(1)		= NULL,
 @Ac_CheckRecipient_ID			CHAR(10)	= NULL,
 @Ad_Batch_DATE					DATE		= NULL,
 @Ac_SourceBatch_CODE			CHAR(3)		= NULL,
 @An_Batch_NUMB					NUMERIC(4)	= NULL,
 @An_SeqReceipt_NUMB			NUMERIC(6)	= NULL
 )
AS
 /*
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S29
  *     DESCRIPTION       : This procedure used to display the receipt level and will show information about
                            CP Hold (disbursement holds) amounts that were cancelled as a result of the receipt
                            reversal event from RREP.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/27/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT h.TypeHold_CODE,
         h.Case_IDNO,
         h.EndValidity_DATE AS Transaction_DATE,
         h.Transaction_AMNT,
         h.Release_DATE,
         h.TypeDisburse_CODE,
         h.Batch_DATE,
         h.SourceBatch_CODE,
         h.Batch_NUMB,
         h.SeqReceipt_NUMB,
         h.Status_CODE,
         h.ReasonStatus_CODE,
         h.CheckRecipient_ID,
         h.CheckRecipient_CODE,
         n.DescriptionNote_TEXT,
         h.Disburse_DATE
    FROM DHLD_Y1 h
         LEFT OUTER JOIN UNOT_Y1 n
      ON n.EventGlobalSeq_NUMB = h.EventGlobalBeginSeq_NUMB
   WHERE h.Case_IDNO = @An_Case_IDNO
     AND h.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND ((@Ac_CheckRecipient_ID IS NOT NULL
           AND h.CheckRecipient_ID   = @Ac_CheckRecipient_ID
           AND h.CheckRecipient_CODE = @Ac_CheckRecipient_CODE)
           OR (@Ad_Batch_DATE IS NOT NULL
               AND h.Batch_DATE       = @Ad_Batch_DATE
               AND h.SourceBatch_CODE = @Ac_SourceBatch_CODE
               AND h.Batch_NUMB       = @An_Batch_NUMB
               AND h.SeqReceipt_NUMB  = @An_SeqReceipt_NUMB));
               
 END; --End Of Procedure DHLD_RETRIEVE_S29 


GO
