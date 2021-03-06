/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S42] (
     @Ac_SourceReceipt_CODE		 CHAR(2)	  ,
     @An_Case_IDNO		 		 NUMERIC(6,0) ,
     @An_PayorMCI_IDNO			 NUMERIC(10,0),    
     @Ac_ReasonStatus_CODE       CHAR(4)      ,
     @Ai_Count_QNTY              INT OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S42
 *     DESCRIPTION       : Retrieves the record count for the given payormci idno, case idno, distribute date, source receipt code for the identified and hold receipts and the end validity date equals high date.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
  BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
      
         @Lc_StatusReceiptHeld_CODE       	CHAR(1)    = 'H', 
         @Lc_StatusReceiptIdentified_CODE 	CHAR(1)    = 'I', 
         @Ld_High_DATE                		DATE 		= '12/31/9999', 
         @Ld_Low_DATE                 		DATE 		= '01/01/0001', 
         @Lc_SourceReceiptHoldDH_CODE       CHAR(2) 	= 'DH';
        
         
       SELECT TOP 1 @Ai_Count_QNTY = COUNT(1)                                                             
         FROM RCTH_Y1 a                                                   
        WHERE a.PayorMCI_IDNO = @An_PayorMCI_IDNO                     
          AND a.Case_IDNO = ISNULL(@An_Case_IDNO, a.Case_IDNO)
          AND a.SourceReceipt_CODE =                                  
                 CASE @Ac_SourceReceipt_CODE                                   
                    WHEN @Lc_SourceReceiptHoldDH_CODE                                 
                       THEN a.SourceReceipt_CODE                      
                    ELSE @Ac_SourceReceipt_CODE                                
                 END                                                        
          AND a.Distribute_DATE = @Ld_Low_DATE                         
          AND a.EndValidity_DATE = @Ld_High_DATE                       
          AND (   a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE  
               OR (    a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE   
                   AND a.ReasonStatus_CODE = @Ac_ReasonStatus_CODE    
                  )                                                         
              );                                                            
                                                                            
END; -- END OF RCTH_RETRIEVE_S42


GO
