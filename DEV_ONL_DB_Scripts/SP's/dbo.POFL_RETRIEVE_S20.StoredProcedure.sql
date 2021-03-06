/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S20]( 
     @Ad_Batch_DATE		DATE,   
     @Ac_SourceBatch_CODE		 CHAR(3),
     @An_Batch_NUMB               NUMERIC(4,0),  
     @An_SeqReceipt_NUMB		 NUMERIC(6,0)   
     )                 
AS  
  
/*  
 *     PROCEDURE NAME    : POFL_RETRIEVE_S20  
 *     DESCRIPTION       : It Retrieves the Recoupment Details for Batch Date,Sourcebatch Code,Batch Number & SeqReceipt Number. 
 *     DEVELOPED BY      : IMP Team                      
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
      
      DECLARE  
         @Li_Zero_NUMB SMALLINT = 0,   
         @Li_ReceiptReversed1250_NUMB INT = 1250;  
  
      SELECT   
         a.CheckRecipient_ID,   
         dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(a.CheckRecipient_ID, a.CheckRecipient_CODE) AS RecipientName_TEXT,   
         a.Case_IDNO,    
         a.Transaction_CODE ,  
         a.Transaction_DATE ,
         SUM(a.PendOffset_AMNT) AS Transaction_AMNT ,
         a.TypeRecoupment_CODE   
      FROM POFL_Y1 a  
      WHERE   
         a.Batch_DATE = @Ad_Batch_DATE AND   
         a.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
         a.Batch_NUMB = @An_Batch_NUMB AND   
         a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
         a.PendOffset_AMNT != @Li_Zero_NUMB AND   
         EXISTS   
         (  
            SELECT 1 
            FROM LSUP_Y1 b  
            WHERE   
               b.Batch_DATE = @Ad_Batch_DATE AND   
               b.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               b.Batch_NUMB = @An_Batch_NUMB AND   
               b.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               b.EventGlobalSeq_NUMB <= a.EventGlobalSeq_NUMB AND   
               b.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB  
         )  
      GROUP BY   
         a.Transaction_DATE,   
         a.Transaction_CODE,   
         a.CheckRecipient_ID,   
         a.CheckRecipient_CODE,   
         a.Case_IDNO,   
         a.TypeRecoupment_CODE,   
         a.RecAdvance_AMNT  
       UNION  
      SELECT      
         a.CheckRecipient_ID,   
         dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(a.CheckRecipient_ID, a.CheckRecipient_CODE) AS RecipientName_TEXT,   
         a.Case_IDNO,    
         a.Transaction_CODE,
         a.Transaction_DATE,  
         SUM(a.AssessOverpay_AMNT) AS Transaction_AMNT,
         a.TypeRecoupment_CODE  
      FROM POFL_Y1 a  
      WHERE   
         a.Batch_DATE = @Ad_Batch_DATE AND   
         a.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
         a.Batch_NUMB = @An_Batch_NUMB AND   
         a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
         a.AssessOverpay_AMNT != @Li_Zero_NUMB AND   
         EXISTS   
         (  
            SELECT 1 
            FROM LSUP_Y1 b  
            WHERE   
               b.Batch_DATE = @Ad_Batch_DATE AND   
               b.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               b.Batch_NUMB = @An_Batch_NUMB AND   
               b.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               b.EventGlobalSeq_NUMB <= a.EventGlobalSeq_NUMB AND   
               b.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB  
         )  
      GROUP BY   
         a.Transaction_DATE,   
         a.Transaction_CODE,   
         a.CheckRecipient_ID,   
         a.CheckRecipient_CODE,   
         a.Case_IDNO,  
         a.TypeRecoupment_CODE,   
         a.RecAdvance_AMNT;
                    
END;--End of POFL_RETRIEVE_S20   
  


GO
