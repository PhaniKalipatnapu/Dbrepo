/****** Object:  StoredProcedure [dbo].[CHLD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CHLD_RETRIEVE_S1] ( 
 	@Ac_CheckRecipient_ID	CHAR(10)	 , 
 	@An_Case_IDNO		 	NUMERIC(6,0) , 
 	@An_Sequence_NUMB		NUMERIC(11,0),
    @Ac_History_INDC          	CHAR(1)		 ,       
    @Ai_RowFrom_NUMB       	INT = 1 	 ,  
    @Ai_RowTo_NUMB         	INT = 10 		     
 )
AS  
  
/*  
 *     PROCEDURE NAME    : CHLD_RETRIEVE_S1  
 *     DESCRIPTION       : Retrieves the cphold details from the CHLD_Y1 
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 28-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
BEGIN  

  DECLARE  
     @Lc_No_INDC 				CHAR(1) = 'N',   
     @Lc_Yes_INDC 				CHAR(1) = 'Y',   
     @Ld_High_DATE 				DATE 	= '12/31/9999',
     @Ld_Current_DATE			DATE	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),   
     @Lc_StatusActive_CODE 		CHAR(6) = 'ACTIVE',   
     @Lc_StatusInactive_CODE 	CHAR(8) = 'INACTIVE';  
      
    SELECT   y.CheckRecipient_ID, 
    		 y.EventGlobalBeginSeq_NUMB,
    		 y.ReasonHold_CODE,
    		 y.Case_IDNO, 
    		 y.Effective_DATE,
             y.Expiration_DATE,  
             y.BeginValidity_DATE,
             y.Sequence_NUMB, 
             CASE                                                       
                WHEN (   y.Expiration_DATE <=   @Ld_Current_DATE                                        
                      OR y.Effective_DATE > @Ld_Current_DATE  )                                        
                THEN @Lc_StatusInactive_CODE                              
                ELSE @Lc_StatusActive_CODE                                   
             END AS Status_CODE,  		           
             y.DescriptionNote_TEXT,                         
             y.Worker_ID,               
             y.RowCount_NUMB                     
        FROM (SELECT X.CheckRecipient_ID, 
        			 x.Case_IDNO,                                
                     X.ReasonHold_CODE, 
                     X.DescriptionNote_TEXT,             
                     X.Effective_DATE, 
                     X.Expiration_DATE, 
                     X.Worker_ID, 
                     X.EventGlobalBeginSeq_NUMB, 
                     X.Sequence_NUMB,            
                     X.BeginValidity_DATE, 
                     X.RowCount_NUMB, 
                     X.ORD_ROWNUM AS rnm         
                FROM (SELECT a.CheckRecipient_ID, 
                		     a.Case_IDNO,                        
                             a.ReasonHold_CODE,          
                             b.DescriptionNote_TEXT, 
                             a.Effective_DATE,
                             a.Expiration_DATE,               
                             g.Worker_ID, 
                             a.EventGlobalBeginSeq_NUMB,                     
                             a.Sequence_NUMB, 
                             a.BeginValidity_DATE,                     
                             COUNT (1) OVER () AS RowCount_NUMB,                        
                             ROW_NUMBER () OVER (ORDER BY a.Expiration_DATE DESC,       
                              a.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM                
                        FROM CHLD_Y1 a LEFT OUTER JOIN UNOT_Y1 b                
                             ON b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB 
                             JOIN                                                          
                             GLEV_Y1 g                                              
                             ON  g.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB
                       WHERE (    a.CheckRecipient_ID =                               
                                     ISNULL (@Ac_CheckRecipient_ID,                   
                                             a.CheckRecipient_ID                      
                                            )                                           
                              AND a.Case_IDNO =                                         
                                         ISNULL (@An_Case_IDNO, a.Case_IDNO)            
                             )                                                          
                         AND (   (    @Ac_History_INDC = @Lc_No_INDC                            
                                  AND a.EndValidity_DATE = @Ld_High_DATE                 
                                 )                                                      
                              OR (    @Ac_History_INDC = @Lc_Yes_INDC                           
                                  AND a.Sequence_NUMB = @An_Sequence_NUMB               
                                  AND a.EndValidity_DATE != @Ld_High_DATE                
                                 )                                                      
                             )                                                          
                         ) AS X           
               WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS y                               
       WHERE y.rnm >= @Ai_RowFrom_NUMB                                                  
    ORDER BY RNM;                                                                       
END; -- END of CHLD_RETRIEVE_S1                                                                                        


GO
