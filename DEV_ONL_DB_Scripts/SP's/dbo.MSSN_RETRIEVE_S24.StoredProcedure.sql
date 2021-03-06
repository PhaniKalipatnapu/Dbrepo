/****** Object:  StoredProcedure [dbo].[MSSN_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 CREATE PROCEDURE [dbo].[MSSN_RETRIEVE_S24] 
    (
     @An_MemberSsn_NUMB	NUMERIC(9,0),
     @An_MemberMci_IDNO	NUMERIC(10,0)	 OUTPUT,  
     @Ai_Count_QNTY     INT				 OUTPUT  
     )
AS  
  
/*  
 *     PROCEDURE NAME    : MSSN_RETRIEVE_S24  
 *     DESCRIPTION       : Retrieves the count of valid memberssn_numb.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 03-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN   
    
      SELECT @Ai_Count_QNTY = 0,
             @An_MemberMci_IDNO = NULL; 
  
     DECLARE @Li_One_NUMB   INT  = 1, 
			 @Ld_High_DATE	DATE = '12/31/9999';  
          
      SELECT @Ai_Count_QNTY = @Li_One_NUMB,
             @An_MemberMci_IDNO = a.MemberMci_IDNO  
        FROM MSSN_Y1  a
       WHERE a.MemberSsn_NUMB   = @An_MemberSsn_NUMB 
         AND a.EndValidity_DATE = @Ld_High_DATE;
  
END;  -- End of MSSN_RETRIEVE_S24

GO
