/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S37](    
  
       @An_Case_IDNO   NUMERIC(6,0)     
     )              
AS  
  
/*  
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S37  
 *     DESCRIPTION       : Retrieves distinct Member Idno's for the given Case Idno.  
 *     DEVELOPED BY      : Imp Team 
 *     DEVELOPED ON      : 02-MAR-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN  
      --CMEM_RETRIEVE_S37 RETURNS REFCURSOR AREF_MEMBERID  
      SELECT DISTINCT C.MemberMci_IDNO  
         FROM CMEM_Y1 C  
       WHERE C.Case_IDNO = @An_Case_IDNO;  
       
    END; --End of CMEM_RETRIEVE_S37  
    

GO
