/****** Object:  StoredProcedure [dbo].[RJCS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RJCS_RETRIEVE_S2] (
     @An_MemberMci_IDNO	 NUMERIC(10,0),  
     @Ac_TypeArrear_CODE CHAR(1),
     @Ai_Count_QNTY      INT    OUTPUT
     )
AS        
/*    
 *     PROCEDURE NAME    : RJCS_RETRIEVE_S2    
 *     DESCRIPTION       : Retrieve the count for the given MemberMci_IDNO and TypeArrear_CODE   
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
BEGIN    

			SET @Ai_Count_QNTY = NULL;    
		DECLARE @Ld_High_DATE	DATE  =  '12/31/9999';   
            
		 SELECT @Ai_Count_QNTY = COUNT(1)
		   FROM RJCS_Y1 a
		  WHERE a.MemberMci_IDNO	= @An_MemberMci_IDNO
			AND a.TypeArrear_CODE	= @Ac_TypeArrear_CODE
			AND a.EndValidity_DATE	= @Ld_High_DATE;

END;   --End of RJCS_RETRIEVE_S2.    


GO
