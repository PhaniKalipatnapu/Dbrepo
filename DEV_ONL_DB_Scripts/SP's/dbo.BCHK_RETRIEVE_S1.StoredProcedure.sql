/****** Object:  StoredProcedure [dbo].[BCHK_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[BCHK_RETRIEVE_S1] (  
     @An_MemberMci_IDNO		 NUMERIC(10,0)		,  
     @Ac_BadCheck_INDC		 CHAR(1)	 OUTPUT
  )     
AS  
  
/*  
 *     PROCEDURE NAME    : BCHK_RETRIEVE_S1  
 *     DESCRIPTION       : Retrieves BadCheck_INDC for a membermci idno  and eventglobal sequence number.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 20-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
BEGIN  
  
      SET @Ac_BadCheck_INDC = NULL;  
  
      SELECT @Ac_BadCheck_INDC = a.BadCheck_INDC  
      	FROM BCHK_Y1 a  
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO 
      AND a.EventGlobalSeq_NUMB =   
         				(  
         				   SELECT MAX(b.EventGlobalSeq_NUMB) 
         				   FROM BCHK_Y1 b  
         				   WHERE a.MemberMci_IDNO = b.MemberMci_IDNO  
         				);  
                    
END;  -- END of BCHK_RETRIEVE_S1


GO
