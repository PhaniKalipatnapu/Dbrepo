/****** Object:  StoredProcedure [dbo].[LWEL_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[LWEL_RETRIEVE_S11]( 
     @Ad_Batch_DATE			DATE,  
     @Ac_SourceBatch_CODE	CHAR(3),   
     @An_Batch_NUMB			NUMERIC(4,0),  
     @An_SeqReceipt_NUMB	NUMERIC(6,0)  
     )  
     
AS                                                                      
                                                                        
/*  
 *     PROCEDURE NAME    : LWEL_RETRIEVE_S11  
 *     DESCRIPTION       : It Retrieve the welfare distribution details  exists in Support log.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
     
  
      DECLARE    
         @Ld_High_DATE				  DATE = '12/31/9999', 
         @Li_ReceiptReversed1250_NUMB INT = 1250  ;
  
      SELECT l.Case_IDNO,  
			 l.CaseWelfare_IDNO , 
			 l.TypeDisburse_CODE ,   
			 l.Distribute_AMNT,    
			 l.Distribute_DATE ,
			 o.MemberMci_IDNO,
			 o.TypeDebt_CODE,
			 o.Fips_CODE,  
			 s.Order_IDNO  
      FROM LWEL_Y1 l 
		JOIN OBLE_Y1 o 
		 ON l.Case_IDNO = o.Case_IDNO 
		AND l.OrderSeq_NUMB = o.OrderSeq_NUMB 
		AND l.ObligationSeq_NUMB = o.ObligationSeq_NUMB 
      JOIN SORD_Y1 s  
        ON l.Case_IDNO = s.Case_IDNO 
       AND l.OrderSeq_NUMB = s.OrderSeq_NUMB 
      WHERE l.Batch_DATE = @Ad_Batch_DATE 
        AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE 
        AND l.Batch_NUMB = @An_Batch_NUMB 
        AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
        AND o.EndValidity_DATE = @Ld_High_DATE 
        AND s.EndValidity_DATE = @Ld_High_DATE 
        AND  o.EndObligation_DATE =   
         (  
            SELECT MAX(b.EndObligation_DATE) 
            FROM  OBLE_Y1 b  
            WHERE b.Case_IDNO = o.Case_IDNO 
              AND b.OrderSeq_NUMB = o.OrderSeq_NUMB 
              AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB 
              AND b.EndValidity_DATE = @Ld_High_DATE  
         ) 
         AND EXISTS   
         (  
            SELECT 1   
            FROM LSUP_Y1 a  
            WHERE a.Batch_DATE = @Ad_Batch_DATE 
              AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE 
              AND a.Batch_NUMB = @An_Batch_NUMB 
              AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
              AND a.EventGlobalSeq_NUMB = l.EventGlobalSeq_NUMB 
              AND a.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB  
         ); 
                    
END;--End of LWEL_RETRIEVE_S11   
  


GO
