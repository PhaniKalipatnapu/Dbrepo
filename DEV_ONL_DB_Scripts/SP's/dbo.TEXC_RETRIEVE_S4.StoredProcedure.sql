/****** Object:  StoredProcedure [dbo].[TEXC_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[TEXC_RETRIEVE_S4]    
    (
     @An_Case_IDNO					NUMERIC(6,0),  
     @An_MemberMci_IDNO				NUMERIC(10,0),  
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)	 OUTPUT
    )  
AS  
  
/*  
 *     PROCEDURE NAME    : TEXC_RETRIEVE_S4  
 *     DESCRIPTION       : Retrieve txnseqeventno for the given membermci_idno & case_idno.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN 
          SET @An_TransactionEventSeq_NUMB = NULL;  

      DECLARE @Ld_High_DATE DATE  = '12/31/9999';  

       SELECT @An_TransactionEventSeq_NUMB = K.TransactionEventSeq_NUMB  
        FROM TEXC_Y1 K 
       WHERE K.MemberMci_IDNO   = @An_MemberMci_IDNO 
         AND K.Case_IDNO        = @An_Case_IDNO 
         AND K.EndValidity_DATE = @Ld_High_DATE;  
END;  --END OF TEXC_RETRIEVE_S4 

GO
