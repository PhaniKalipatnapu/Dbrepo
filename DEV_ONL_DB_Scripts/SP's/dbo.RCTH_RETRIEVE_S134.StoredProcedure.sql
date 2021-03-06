/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S134]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S134]( 
     @Ad_Batch_DATE		DATE,  
     @Ac_SourceBatch_CODE		 CHAR(3),  
     @An_Batch_NUMB               NUMERIC(4,0),  
     @An_SeqReceipt_NUMB		 NUMERIC(6,0),  
     @An_Case_IDNO		 NUMERIC(6,0),  
     @An_PayorMCI_IDNO		 NUMERIC(10,0),  
     @Ad_From_DATE		DATE,  
     @Ad_To_DATE		DATE,  
     @Ac_Worker_ID		 CHAR(30),  
     @Ai_RowFrom_NUMB             INT=1       ,  
     @Ai_RowTo_NUMB               INT=10         
     )                                            
AS  
  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S134  
 *     DESCRIPTION       : It Retrieve the reversed receipts details which are not yet posted ,existence on RCTH_Y1 and not exists in RCTR_Y1.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
       BEGIN    
    
        
      DECLARE    
         @Ld_High_DATE     DATE = '12/31/9999',  
         @Lc_BackOutY_INDC CHAR(1)='Y',  
         @Li_Zero_NUMB     SMALLINT=0;  
            
       SELECT Y.Batch_DATE,   
         Y.SourceBatch_CODE,   
         Y.Batch_NUMB,   
         Y.SeqReceipt_NUMB,  
         Y.Case_IDNO ,    
         Y.PayorMCI_IDNO ,  
         dbo.BATCH_COMMON$SF_GET_MASKED_MEMBER_NAME(Y.PayorMCI_IDNO) AS PayorName_TEXT,   
         Y.Receipt_AMNT  ,                                                              
         Y.Receipt_DATE  ,    
         Y.ReasonStatus_CODE ,  
         Y.ReasonBackOut_CODE,  
         Y.BeginValidity_DATE ,
         Y.County_IDNO,
         Y.RowCount_NUMB ,  
         g.Worker_ID   
      FROM  ( 
         SELECT X.Receipt_DATE,     
               X.Receipt_AMNT,     
               X.PayorMCI_IDNO,     
               X.Case_IDNO,     
               X.ReasonStatus_CODE,     
               X.BeginValidity_DATE,     
               X.ReasonBackOut_CODE,     
               X.EventGlobalBeginSeq_NUMB,     
               X.SeqReceipt_NUMB,     
               X.Batch_NUMB,     
               X.SourceBatch_CODE,     
               X.Batch_DATE,
               X.County_IDNO,    
               X.RowCount_NUMB,     
               X.ORD_ROWNUM    
            FROM ( 
               SELECT h.Receipt_DATE,     
                     h.Receipt_AMNT,     
                     h.PayorMCI_IDNO,     
                     h.Case_IDNO,     
                     h.ReasonStatus_CODE ,     
                     h.BeginValidity_DATE ,     
                     h.ReasonBackOut_CODE ,     
                     h.EventGlobalBeginSeq_NUMB,     
                     h.SeqReceipt_NUMB,     
                     h.Batch_NUMB,     
                     h.SourceBatch_CODE,     
                     h.Batch_DATE,
                     CA.County_IDNO,     
                     COUNT(1) OVER() AS RowCount_NUMB,     
                     ROW_NUMBER() OVER(    
                        ORDER BY     
                           h.Batch_DATE,     
                           h.SourceBatch_CODE,     
                           h.Batch_NUMB,     
                           h.SeqReceipt_NUMB,     
                           h.EventGlobalBeginSeq_NUMB) AS ORD_ROWNUM    
                  FROM RCTH_Y1 h LEFT OUTER JOIN CASE_Y1 CA
                  ON h.Case_IDNO=CA.Case_IDNO 
                     
                  WHERE ((  
                  @Ad_From_DATE IS NOT NULL AND                  
                  h.BeginValidity_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE )  OR @Ad_From_DATE IS NULL)     
                     AND h.BackOut_INDC = @Lc_BackOutY_INDC     
                     AND h.EndValidity_DATE = @Ld_High_DATE      
                     AND NOT EXISTS     
                     (    
                        SELECT 1    
                        FROM RCTR_Y1 r    
                        WHERE     
                           h.Batch_DATE = r.BatchOrig_DATE      
                           AND h.SourceBatch_CODE = r.SourceBatchOrig_CODE      
                           AND h.Batch_NUMB = r.BatchOrig_NUMB      
                           AND h.SeqReceipt_NUMB = r.SeqReceiptOrig_NUMB      
                           AND r.EndValidity_DATE = @Ld_High_DATE    
                     )                         
                     AND h.PayorMCI_IDNO = ISNULL( @An_PayorMCI_IDNO, h.PayorMCI_IDNO)      
                     AND h.Case_IDNO = ISNULL( @An_Case_IDNO, h.Case_IDNO)      
                     AND ((    
                      @An_SeqReceipt_NUMB IS NOT NULL      
                     AND h.Batch_DATE = @Ad_Batch_DATE      
                     AND h.SourceBatch_CODE = @Ac_SourceBatch_CODE      
                     AND h.Batch_NUMB = @An_Batch_NUMB      
                     AND h.SeqReceipt_NUMB = @An_SeqReceipt_NUMB) 
                     OR @An_SeqReceipt_NUMB IS NULL)    
               )  AS X  
              WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB 
              OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB)    
         )  AS Y LEFT OUTER JOIN GLEV_Y1 g   
         ON  
         Y.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB    
      WHERE (Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB 
         OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB)            
         AND g.Worker_ID = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR( @Ac_Worker_ID), g.Worker_ID)    
       ORDER BY ORD_ROWNUM;   
                      
END;--End of RCTH_RETRIEVE_S134    

GO
