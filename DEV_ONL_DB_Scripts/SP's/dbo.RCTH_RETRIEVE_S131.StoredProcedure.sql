/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S131]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S131](
     @Ad_Batch_DATE			DATE,
     @Ac_SourceBatch_CODE	CHAR(3),  
     @An_Batch_NUMB			NUMERIC(4,0),  
     @An_SeqReceipt_NUMB	NUMERIC(6,0)  
     )
AS  
  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S131  
 *     DESCRIPTION       : It Retrieve the portion of the receipt still on hold.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
     
  
      DECLARE  
         @Lc_StatusReceiptHeld_CODE CHAR(1)= 'H',   
         @Ld_High_DATE				DATE = '12/31/9999',   
         @Ld_Low_DATE				DATE = '01/01/0001';  
          
      SELECT a.Case_IDNO ,   
			 a.ToDistribute_AMNT,
			 a.TaxJoint_CODE, 
			 a.ReasonStatus_CODE ,
			 a.BeginValidity_DATE ,
			 n.DescriptionNote_TEXT,
			 g.Worker_ID   
      FROM RCTH_Y1 a
		LEFT OUTER JOIN  UNOT_Y1 n   
            ON a.EventGlobalBeginSeq_NUMB = n.EventGlobalSeq_NUMB
			JOIN GLEV_Y1 g  
				ON a.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB
      WHERE a.Batch_DATE = @Ad_Batch_DATE 
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE 
        AND a.Batch_NUMB = @An_Batch_NUMB 
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
        AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE 
        AND a.Distribute_DATE = @Ld_Low_DATE 
        AND a.EndValidity_DATE = @Ld_High_DATE ;  
  
    END;--End of RCTH_RETRIEVE_S131  
  

GO
