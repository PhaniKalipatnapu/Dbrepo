/****** Object:  StoredProcedure [dbo].[RJDT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RJDT_RETRIEVE_S2] (
     @An_MemberSsn_NUMB				NUMERIC(9,0),
     @Ac_TypeArrear_CODE			CHAR(1),
     @Ac_TransactionType_CODE		CHAR(1),
     @Ad_Rejected_DATE				DATE,
     @Ac_Reject1_CODE				CHAR(2),
     @Ac_TypeReject_CODE			CHAR(1)          OUTPUT,
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)	 OUTPUT
     )
AS    
/*    
 *     PROCEDURE NAME    : RJDT_RETRIEVE_S2    
 *     DESCRIPTION       : Retrieving the TypeReject_CODE and TransactionEventSeq_NUMB for the given reject code  
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
BEGIN    
		 SELECT @Ac_TypeReject_CODE = NULL,
				@An_TransactionEventSeq_NUMB = NULL;    
    
		DECLARE @Ld_High_DATE	DATE =  '12/31/9999';    
		
         SELECT @Ac_TypeReject_CODE		= a.TypeReject1_CODE,
				@An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
		   FROM RJDT_Y1 a
		  WHERE a.MemberSsn_NUMB	= @An_MemberSsn_NUMB
			AND a.TypeArrear_CODE	= @Ac_TypeArrear_CODE
			AND a.Rejected_DATE		= @Ad_Rejected_DATE
			AND a.TransactionType_CODE	= @Ac_TransactionType_CODE
			AND a.Reject1_CODE		= @Ac_Reject1_CODE
			AND a.EndValidity_DATE	= @Ld_High_DATE;
END;   --End of RJDT_RETRIEVE_S2.    


GO
