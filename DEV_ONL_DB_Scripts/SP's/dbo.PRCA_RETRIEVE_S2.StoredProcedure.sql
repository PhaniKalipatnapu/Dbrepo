/****** Object:  StoredProcedure [dbo].[PRCA_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[PRCA_RETRIEVE_S2] (
 @An_CaseWelfare_IDNO         NUMERIC(10,0),
 @An_AgSequence_NUMB          NUMERIC(4,0),
 @An_TransactionEventSeq_NUMB NUMERIC(19,0),
 @Ac_Exists_INDC              CHAR(1) OUTPUT
 )
AS    
    
/*    
 *     PROCEDURE NAME    : PRCA_RETRIEVE_S2    
 *     DESCRIPTION       : Check whether the case is exist for the given case welfare.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
BEGIN    
       DECLARE @Lc_No_TEXT               CHAR(1)  = 'N',
		       @Lc_Yes_TEXT              CHAR(1)  = 'Y',
		       @Lc_ReferralProcessD_CODE CHAR(1)  = 'D';

	   SET @Ac_Exists_INDC = @Lc_No_TEXT;	       
	   
	   SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
	    FROM PRCA_Y1 P 
	   WHERE P.CaseWelfare_IDNO=@An_CaseWelfare_IDNO
         AND P.AgSequence_NUMB=@An_AgSequence_NUMB
		 AND P.TransactionEventSeq_NUMB =@An_TransactionEventSeq_NUMB
		 AND P.ReferralProcess_CODE = @Lc_ReferralProcessD_CODE;
		 		 
END;--End of PRCA_RETRIEVE_S2.    


GO
