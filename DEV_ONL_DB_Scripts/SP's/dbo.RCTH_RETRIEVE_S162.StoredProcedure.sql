/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S162]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S162]
    (
     @An_Case_IDNO		            NUMERIC(6,0),
     @An_OrderSeq_NUMB		        NUMERIC(2,0),
     @An_ObligationSeq_NUMB		    NUMERIC(2,0),
     @Ai_Count_QNTY                 INT  OUTPUT
    )
    AS
/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S162	
 *     DESCRIPTION       : Procedure to count the records which exist in RCTH_Y1 and LSUP_Y1 with the reason status code 'DR'.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	 
   DECLARE @Li_Number1_NUMB         INT = 1,
           @Li_Number2_NUMB         INT = 2,
           @Lc_SourceBatchDCR_CODE  CHAR(3) = 'DCR',
           @Lc_SourceReceiptCD_CODE CHAR(2) = 'CD',
           @Lc_ReasonStatusDR_CODE  CHAR(2) = 'DR',
           @Lc_TypeRecordO_CODE     CHAR(1) = 'O',
           @Lc_BackOutY_INDC        CHAR(1) = 'Y',
           @Ld_High_DATE            DATE    = '12/31/9999';
	  
	   SET @Ai_Count_QNTY = NULL;
	 
	SELECT @Ai_Count_QNTY = COUNT(1)
	  FROM RCTH_Y1 a 
		   JOIN 
		   LSUP_Y1 b
		ON a.Batch_DATE = b.Batch_DATE
	   AND a.SourceBatch_CODE = b.SourceBatch_CODE
	   AND a.Batch_NUMB = b.Batch_NUMB
	   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
	   AND a.EventGlobalBeginSeq_NUMB = b.EventGlobalSeq_NUMB
	       JOIN
	       UNOT_Y1 d  
        ON d.EventGlobalSeq_NUMB = b.EventGlobalSeq_NUMB
	 WHERE a.SourceReceipt_CODE = @Lc_SourceReceiptCD_CODE
	   AND b.SourceBatch_CODE = @Lc_SourceBatchDCR_CODE
	   AND b.TypeRecord_CODE = @Lc_TypeRecordO_CODE
	   AND SUBSTRING(d.DescriptionNote_TEXT,@Li_Number1_NUMB,@Li_Number2_NUMB) = @Lc_ReasonStatusDR_CODE
	   AND b.Case_IDNO = @An_Case_IDNO
	   AND b.OrderSeq_NUMB = @An_OrderSeq_NUMB
	   AND b.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
	   AND NOT EXISTS ( SELECT 1 
						  FROM RCTH_Y1 c 
						 WHERE a.Batch_DATE = c.Batch_DATE
						   AND a.SourceBatch_CODE = c.SourceBatch_CODE
						   AND a.Batch_NUMB = c.Batch_NUMB
						   AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
						   AND c.BackOut_INDC = @Lc_BackOutY_INDC
						   AND c.EndValidity_DATE = @Ld_High_DATE);
					  
END;--End Of RCTH_RETRIEVE_S162


GO
