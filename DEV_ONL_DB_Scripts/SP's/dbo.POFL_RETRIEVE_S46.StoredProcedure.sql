/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S46]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                
CREATE PROCEDURE  [dbo].[POFL_RETRIEVE_S46] (                    
 @Ac_Reason_CODE	CHAR(2)	,                    
 @Ac_Status_CODE	CHAR(1) ,   
 @Ad_From_DATE		DATE	,                    
 @Ad_To_DATE		DATE	
 )                    
 AS            
 /*        
 *     PROCEDURE NAME    : POFL_RETRIEVE_S46        
 *     DESCRIPTION       : Retrieve Transaction summary for transaction date,reason code and status code    
 *     DEVELOPED BY      : IMP Team         
 *     DEVELOPED ON      : 19-OCT-2011        
 *     MODIFIED BY       :         
 *     MODIFIED ON       :         
 *     VERSION NO        : 1        
*/                
 BEGIN                    
   DECLARE        
      @Lc_TransactionRepe_CODE		CHAR (4) = 'REPE',                    
      @Lc_TransactionAppe_CODE		CHAR (4) = 'APPE',                    
      @Lc_RecoupmentPayeeSdu_CODE	CHAR(1)  = 'D',                    
      @Lc_TypeRecoupmentR_CODE		CHAR(1)  = 'R',                    
      @Lc_RecoupmentPayeeState_CODE	CHAR(1)  = 'S',                    
      @Lc_Yes_INDC					CHAR(1)  = 'Y',   
      @Li_Zero_NUMB					SMALLINT = 0 ,
	  @Li_One_NUMB					SMALLINT = 1,               
      @Ld_High_DATE					DATE	 = '12/31/9999',                    
      @Lc_StatusPending_CODE		CHAR(1)  = 'P',                    
      @Lc_StatusActive_CODE			CHAR(1)  = 'A',                    
      @Lc_StatusRecouped_CODE		CHAR(1)  = 'R';                  
                                
       SELECT   SUM (CASE                    
                        WHEN (Y.PendOffset_AMNT > @Li_Zero_NUMB) OR (Y.PendOffset_AMNT < @Li_Zero_NUMB AND Y.AssessOverpay_AMNT= @Li_Zero_NUMB)                    
                           THEN Y.PendOffset_AMNT                    
                        ELSE @Li_Zero_NUMB                    
                     END                    
                    ) PendOffset_AMNT,                    
                SUM (CASE                    
                        WHEN (Y.PendOffset_AMNT > @Li_Zero_NUMB) OR (Y.PendOffset_AMNT < @Li_Zero_NUMB AND Y.AssessOverpay_AMNT= @Li_Zero_NUMB)                    
                           THEN @Li_One_NUMB                    
                        ELSE @Li_Zero_NUMB                    
                     END                    
                    ) PendOffset_QNTY,                    
                SUM (CASE                    
                        WHEN Y.ActivePendOffset >  @Li_Zero_NUMB                
                           THEN  Y.ActivePendOffset    
                        ELSE @Li_Zero_NUMB              
                     END                    
                    ) ActivePendOffset_AMNT,                    
                SUM (CASE                    
                        WHEN Y.ActivePendOffset >  @Li_Zero_NUMB                
                           THEN  @Li_One_NUMB    
                        ELSE @Li_Zero_NUMB              
                     END                    
                    ) ActivePendOffset_QNTY,                    
                SUM (CASE                    
                        WHEN (Y.AssessOverpay_AMNT >  @Li_Zero_NUMB ) OR (Y.AssessOverpay_AMNT <  @Li_Zero_NUMB  AND Y.PendOffset_AMNT= @Li_Zero_NUMB )                    
                           THEN  Y.AssessOverpay_AMNT                      
                        ELSE  @Li_Zero_NUMB                    
                     END                    
                    ) AssessOverpay_AMNT,                    
                SUM (CASE                    
                        WHEN (Y.AssessOverpay_AMNT >  @Li_Zero_NUMB ) OR (Y.AssessOverpay_AMNT <  @Li_Zero_NUMB  AND Y.PendOffset_AMNT= @Li_Zero_NUMB )                    
                           THEN  @Li_One_NUMB                      
                        ELSE  @Li_Zero_NUMB                    
                     END                    
                    ) AssessOverpay_QNTY,                    
                SUM (CASE                    
                        WHEN Y.PendActive >  @Li_Zero_NUMB                     
                           THEN  Y.PendActive                  
                        ELSE  @Li_Zero_NUMB                   
                     END                    
                    ) PendActive_AMNT,                    
                SUM (CASE                    
                        WHEN Y.PendActive >  @Li_Zero_NUMB                     
                           THEN  @Li_One_NUMB                  
                        ELSE  @Li_Zero_NUMB                   
                     END                    
                    ) PendActive_QNTY,
               SUM (CASE WHEN Y.Recouped_AMNT > @Li_Zero_NUMB  THEN Y.Recouped_AMNT END                    
                ) Recouped_AMNT,              
				COUNT(                    
                     (CASE                    
                        WHEN Y.Recouped_AMNT > @Li_Zero_NUMB                  
                           THEN Y.Recouped_AMNT                    
                        ELSE NULL                    
                     END)                    
                    ) Recouped_QNTY                    
          FROM (
				SELECT ISNULL (a.PendOffset_AMNT, @Li_Zero_NUMB  ) PendOffset_AMNT,                    
                    ISNULL (CASE a.Transaction_CODE                    
								 WHEN  @Lc_TransactionRepe_CODE 
								 THEN a.PendOffset_AMNT               
								ELSE  @Li_Zero_NUMB  END,  @Li_Zero_NUMB                
                            ) ActivePendOffset,                    
                    ISNULL (a.AssessOverpay_AMNT,@Li_Zero_NUMB) AssessOverpay_AMNT,                    
                    ISNULL (CASE a.Transaction_CODE                    
                                   WHEN @Lc_TransactionAppe_CODE   THEN a.AssessOverpay_AMNT                    
                                   ELSE @Li_Zero_NUMB END,                    
                             @Li_Zero_NUMB                   
                            ) PendActive,
                    ISNULL ((a.RecOverpay_AMNT + a.RecAdvance_AMNT),@Li_Zero_NUMB) Recouped_AMNT
                   FROM POFL_Y1 a 
                   LEFT OUTER JOIN RCTH_Y1 b                    
						 ON  ( b.Batch_DATE = a.Batch_DATE 
						AND b.SourceBatch_CODE = a.SourceBatch_CODE                    
						AND b.Batch_NUMB = a.Batch_NUMB 
						AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB 
						AND a.Reason_CODE = b.ReasonBackOut_CODE     
						AND b.BackOut_INDC = @Lc_Yes_INDC                    
						AND b.EndValidity_DATE =  @Ld_High_DATE ) 
					WHERE a.Transaction_DATE BETWEEN  @Ad_From_DATE AND   @Ad_To_DATE                     
                      AND (   a.TypeRecoupment_CODE <> @Lc_TypeRecoupmentR_CODE                    
                           OR (    a.TypeRecoupment_CODE = @Lc_TypeRecoupmentR_CODE                    
                               AND a.RecoupmentPayee_CODE IN ( @Lc_RecoupmentPayeeState_CODE ,  @Lc_RecoupmentPayeeSdu_CODE )                    
                              )                    
                          )                    
                   AND (  ( 	@Ac_Status_CODE = @Lc_StatusPending_CODE                    
							AND  (a.PendOffset_AMNT <>  @Li_Zero_NUMB                     
                            AND a.AssessOverpay_AMNT <= @Li_Zero_NUMB)                    
                              ) 
                         OR (  @Ac_Status_CODE = @Lc_StatusActive_CODE 
							AND (  a.AssessOverpay_AMNT <> @Li_Zero_NUMB                    
                            AND a.PendOffset_AMNT <= @Li_Zero_NUMB)                    
                             ) 
						OR (	@Ac_Status_CODE = @Lc_StatusRecouped_CODE  
							AND ( a.PendOffset_AMNT = @Li_Zero_NUMB                    
                            AND a.AssessOverpay_AMNT =@Li_Zero_NUMB                   
                            AND a.RecOverpay_AMNT != @Li_Zero_NUMB )     
                             )         
                         OR
                         (   
							@Ac_Status_CODE IS NULL
							AND (   a.PendOffset_AMNT != @Li_Zero_NUMB                     
                                   OR a.AssessOverpay_AMNT != @Li_Zero_NUMB                   
                                   OR a.RecOverpay_AMNT != @Li_Zero_NUMB                 
                                           ) 
                         ) )
			   AND a.Reason_CODE =ISNULL(@Ac_Reason_CODE , a.Reason_CODE ) 
				)Y ;                 
                    
   END;	--END OF POFL_RETRIEVE_S46
GO
