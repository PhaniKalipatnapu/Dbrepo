/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S165]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
 CREATE PROCEDURE  [dbo].[CMEM_RETRIEVE_S165] (
     @An_MemberMci_IDNO		 NUMERIC(10,0)   
     )             
AS  
  
/*  
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S165  
 *     DESCRIPTION       : This procedure is used to get caseidno based on case relationship and member active status.
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN  
      DECLARE  
         @Lc_CaseStatusOpen_CODE			CHAR(1) = 'O',   
         @Lc_RelationshipCaseNcp_CODE		CHAR(1) = 'A',   
         @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A';  
          
      SELECT a.Case_IDNO 
        FROM CMEM_Y1 a  
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO   
		 AND EXISTS ( 
					 SELECT 1  
					   FROM CASE_Y1  b  
					  WHERE b.Case_IDNO = a.Case_IDNO 
						AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
					)    
         AND a.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE  
		 AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;  
		                      
END; -- End of CMEM_RETRIEVE_S165

GO
