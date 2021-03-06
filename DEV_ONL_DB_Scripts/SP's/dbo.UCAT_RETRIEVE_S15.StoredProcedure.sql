/****** Object:  StoredProcedure [dbo].[UCAT_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UCAT_RETRIEVE_S15] ( 
	 @Ac_Udc_CODE		 		  CHAR(4)			   ,      
	 @An_TransactionEventSeq_NUMB NUMERIC(19,0)	 OUTPUT,
     @Ac_ExtendResearch_INDC	  CHAR(1)	 	 OUTPUT,
     @Ac_Alert_INDC				  CHAR(1)		 OUTPUT,
     @An_AlertDuration_QNTY		  NUMERIC(9,0)	 OUTPUT,
     @An_ErDuration_QNTY		  NUMERIC(9,0)	 OUTPUT,
     @An_NumDaysHold_QNTY		  NUMERIC(9,0)	 OUTPUT
 ) 
AS  
  
/*  
 *     PROCEDURE NAME    : UCAT_RETRIEVE_S15  
 *     DESCRIPTION       : Retrieves the expiration date, extended research, alert duration quantity and Er duration quantity for given UDC code. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 30-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN  

  SELECT @An_TransactionEventSeq_NUMB = NULL,
         @Ac_ExtendResearch_INDC	  = NULL,
         @Ac_Alert_INDC				  = NULL,
    	 @An_AlertDuration_QNTY		  = NULL,
    	 @An_ErDuration_QNTY		  = NULL,
		 @An_NumDaysHold_QNTY		  = NULL;  

  DECLARE  
     @Ld_High_DATE 	DATE = '12/31/9999';
      
  SELECT @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB,
         @An_NumDaysHold_QNTY = a.NumDaysHold_QNTY,
         @Ac_Alert_INDC = a.Alert_INDC, 
   		 @Ac_ExtendResearch_INDC = a.ExtendResearch_INDC, 
    	 @An_AlertDuration_QNTY = a.AlertDuration_QNTY, 
    	 @An_ErDuration_QNTY = a.ErDuration_QNTY  
    FROM UCAT_Y1 a  
  WHERE a.Udc_CODE = @Ac_Udc_CODE 
    AND a.EndValidity_DATE = @Ld_High_DATE;  
                    
END;  -- END of UCAT_RETRIEVE_S15  

GO
