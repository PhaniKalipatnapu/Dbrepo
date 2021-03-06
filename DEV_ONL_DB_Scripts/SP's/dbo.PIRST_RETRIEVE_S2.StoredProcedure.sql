/****** Object:  StoredProcedure [dbo].[PIRST_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[PIRST_RETRIEVE_S2]    
   (
     @An_MemberMci_IDNO		 NUMERIC(10,0),  
     @Ac_ClChange_INDC		 CHAR(1)	 OUTPUT,  
     @Ac_PreOffset_INDC		 CHAR(1)	 OUTPUT,
     @Ai_Count_QNTY			 INT		 OUTPUT 
    ) 
AS  
  
/*  
 *     PROCEDURE NAME    : PIRST_RETRIEVE_S2  
 *     DESCRIPTION       : Retrieves the case_idno change & preoffsetnotice request indicator for the respective membermci_idno.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 03-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN  
  
      SELECT @Ac_ClChange_INDC  = NULL,  
             @Ac_PreOffset_INDC = NULL,
             @Ai_Count_QNTY     = NULL;  
  
      SELECT @Ac_ClChange_INDC  = P.ClChange_INDC, 
			 @Ac_PreOffset_INDC = P.PreOffset_INDC,
			 @Ai_Count_QNTY     = 1  
        FROM PIRST_Y1  P
       WHERE P.MemberMci_IDNO = @An_MemberMci_IDNO;  
  
END;  --END OF PIRST_RETRIEVE_S2

GO
