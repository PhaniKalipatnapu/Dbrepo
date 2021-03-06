/****** Object:  StoredProcedure [dbo].[PIRST_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[PIRST_RETRIEVE_S4]    
    (
     @An_MemberMci_IDNO	NUMERIC(10,0),  
     @Ac_ClChange_INDC	CHAR(1)	 OUTPUT,  
     @Ac_PreOffset_INDC	CHAR(1)	 OUTPUT,
     @Ai_Count_QNTY		INT		 OUTPUT
    )  
AS  
  
/*  
 *     PROCEDURE NAME    : PIRST_RETRIEVE_S4  
 *     DESCRIPTION       : Retrieves the top case_idno change & preoffset notice request indicator for the respective membermci_idno  
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
  
      SELECT TOP 1 @Ac_ClChange_INDC  = K.ClChange_INDC,
				   @Ac_PreOffset_INDC = K.PreOffset_INDC,
				   @Ai_Count_QNTY     = 1  
        FROM PIRST_Y1 K 
       WHERE K.MemberMci_IDNO = @An_MemberMci_IDNO;  
  
END; --END OF PIRST_RETRIEVE_S4

GO
