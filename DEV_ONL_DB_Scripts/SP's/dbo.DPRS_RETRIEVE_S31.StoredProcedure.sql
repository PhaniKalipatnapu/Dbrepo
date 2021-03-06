/****** Object:  StoredProcedure [dbo].[DPRS_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE 
	[dbo].[DPRS_RETRIEVE_S31]   
		(                                                                                                                                      
			 @Ac_File_ID	CHAR(10)    
		)    
AS   
  
/*                                                                                                                                    
 *     PROCEDURE NAME    : DPRS_RETRIEVE_S31                                                                                           
 *     DESCRIPTION       : Retrieve Docket Members Excluding Attorneys
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-JAN-2012                                                                                                
 *     MODIFIED BY       :                                                                                                            
 *     MODIFIED ON       :                                                                                                            
 *     VERSION NO        : 1                                                                                                          
*/  
  
BEGIN  
      DECLARE                                                                                                
         @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A',                                                             
         @Lc_TypePersonNm_CODE				CHAR(2) = 'NM',                                                                              
         @Ld_High_DATE						DATE	= '12/31/9999';   
  
     SELECT DISTINCT a.DocketPerson_IDNO,                                                                                          
        a.File_NAME  
     FROM  DPRS_Y1   a
		JOIN  FDEM_Y1   m
		  ON  a.File_ID = m.File_ID    
		JOIN CMEM_Y1   c
		  ON  m.Case_IDNO = c.Case_IDNO 
		  AND a.DocketPerson_IDNO = c.MemberMci_IDNO   
		JOIN DEMO_Y1   d  
		  ON  d.MemberMci_IDNO = c.MemberMci_IDNO                                                                                         
     WHERE a.File_ID = @Ac_File_ID 
	   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
	   AND a.EndValidity_DATE = @Ld_High_DATE                                   
      UNION ALL                                                                                            
     SELECT                                                                                                       
        a.DocketPerson_IDNO,                                                                                          
        a.File_NAME  
     FROM DPRS_Y1   a 
     WHERE a.File_ID = @Ac_File_ID 
       AND a.TypePerson_CODE  = @Lc_TypePersonNm_CODE  
       AND a.EndValidity_DATE = @Ld_High_DATE;  
          
END; --END OF DPRS_RETRIEVE_S31  


GO
