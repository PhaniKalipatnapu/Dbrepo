/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S23](
     @Ad_Batch_DATE		DATE, 
     @Ac_SourceBatch_CODE		 CHAR(3),
     @An_Batch_NUMB              NUMERIC(4,0),  
     @An_SeqReceipt_NUMB		 NUMERIC(6,0)   
    
     )   
AS  
  
/*  
 *     PROCEDURE NAME    : DHLD_RETRIEVE_S23  
 *     DESCRIPTION       : It retrives the corresponding receipt on disbursement hold details for the Batch date,SourceBatch CODE ,Batch Number & SeqReceipt Number.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN 
      
  DECLARE  
         @Ld_High_DATE              	 DATE = '12/31/9999',   
         @Li_ReceiptReversed1250_NUMB INT = 1250;          
           
                
          
      SELECT DISTINCT h.Case_IDNO ,
         h.Transaction_DATE,
         h.Release_DATE ,
         h.TypeDisburse_CODE, 
         SUM(h.Transaction_AMNT) OVER(PARTITION BY   
            h.TypeHold_CODE,   
            h.Case_IDNO,   
            h.Transaction_DATE,   
            h.Release_DATE,   
            h.TypeDisburse_CODE,   
            h.CheckRecipient_ID,   
            h.CheckRecipient_CODE,   
            h.ReasonStatus_CODE) AS Transaction_AMNT,  
         h.TypeHold_CODE,      
         h.CheckRecipient_ID ,   
         h.CheckRecipient_CODE ,   
         h.ReasonStatus_CODE  
      FROM DHLD_Y1 h  
      WHERE   
         h.Batch_DATE = @Ad_Batch_DATE    
        AND h.SourceBatch_CODE = @Ac_SourceBatch_CODE    
        AND h.Batch_NUMB = @An_Batch_NUMB    
        AND h.SeqReceipt_NUMB = @An_SeqReceipt_NUMB    
        AND NOT EXISTS   
         (  
            SELECT 1  
            FROM LSUP_Y1 a  
            WHERE   
               a.Batch_DATE = @Ad_Batch_DATE    
              AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE   
              AND  a.Batch_NUMB = @An_Batch_NUMB    
              AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB   
              AND  a.EventGlobalSeq_NUMB = h.EventGlobalEndSeq_NUMB   
              AND  a.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB  
         ) 
         AND h.EndValidity_DATE = @Ld_High_DATE;
         
END; --End of  DHLD_RETRIEVE_S23

GO
