/****** Object:  StoredProcedure [dbo].[CPAF_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                                        
                                                                                                        
CREATE PROCEDURE [dbo].[CPAF_UPDATE_S1](
 @An_Case_IDNO		             NUMERIC(6,0),
 @An_TransactionEventSeq_NUMB    NUMERIC(19,0),
 @An_Paid_AMNT		             NUMERIC(11,2),
 @An_Waived_AMNT		         NUMERIC(11,2),
 @Ac_FeeCheckNo_TEXT			 CHAR(20),
 @As_DescriptionReason_TEXT	     VARCHAR(70)           
)                                                                                                  
AS                                                                                                      
                                                                                                        
/*                                                                                                      
*     PROCEDURE NAME    : CPAF_UPDATE_S1                                                                
*     DESCRIPTION       : Updating the valid record for the given case. 
*     DEVELOPED BY      : IMP Team                                                                      
*     DEVELOPED ON      : 02-AUG-2011                                                                   
*     MODIFIED BY       :                                                                               
*     MODIFIED ON       :                                                                               
*     VERSION NO        : 1                                                                             
*/                                                                                                      
                                                                                                        
BEGIN                                                                                                
      DECLARE @Ld_Current_DTTM       DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),                         
    	      @Ld_High_DATE          DATE = '12/31/9999',                                                       
    	      @Ln_RowsAffected_NUMB  NUMERIC(10);                                                                
    	                                                                                                   
      UPDATE CPAF_Y1                                                                                    
         SET Paid_AMNT=@An_Paid_AMNT,                  
			 Waived_AMNT=@An_Waived_AMNT,               
			 DescriptionReason_TEXT=@As_DescriptionReason_TEXT,     
			 BeginValidity_DATE=@Ld_Current_DTTM,
			 FeeCheckNo_TEXT = @Ac_FeeCheckNo_TEXT,
			 TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB   
      OUTPUT DELETED.Case_IDNO,
		     DELETED.Assessed_AMNT, 
		     DELETED.Paid_AMNT, 
		     DELETED.Waived_AMNT, 
		     DELETED.DescriptionReason_TEXT, 
		     DELETED.FeeCheckNo_TEXT,  		
		     DELETED.TransactionEventSeq_NUMB,       
		     DELETED.BeginValidity_DATE, 
		     @Ld_Current_DTTM AS EndValidity_DATE                                                 
      INTO CPAF_Y1                                                                                        
      WHERE Case_IDNO = @An_Case_IDNO
        AND EndValidity_DATE = @Ld_High_DATE;   
                                                                                                        
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;                                                           
                                                                                                        
      SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;                                                
                                                                                                        
END; -- END OF CPAF_UPDATE_S1                                                                         
                                                                                                        

GO
