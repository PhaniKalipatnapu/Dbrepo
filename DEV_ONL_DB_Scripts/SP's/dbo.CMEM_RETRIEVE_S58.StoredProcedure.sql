/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S58]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S58] (
     @An_MemberMci_IDNO		 NUMERIC(10,0)                
    )
AS  
/*  
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S58  
 *     DESCRIPTION       : This procedure returns the Open cases for the given active NCP/PF MemberMci_IDNO.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 27-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
BEGIN 
	DECLARE	@Lc_StatusCaseOpen_CODE				CHAR(1) = 'O',   
			@Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A',   
			@Lc_CaseRelationshipPutFather_CODE	CHAR(1) = 'P',   
			@Lc_CaseMemberStatusActive_CODE		CHAR(1) = 'A';  
          
	 SELECT a.Case_IDNO 
	   FROM CMEM_Y1 a
	  WHERE a.MemberMci_IDNO		= @An_MemberMci_IDNO
		AND a.CaseMemberStatus_CODE	= @Lc_CaseMemberStatusActive_CODE
		AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
		AND EXISTS (
					SELECT 1 
		              FROM CASE_Y1 b
		             WHERE b.Case_IDNO		= a.Case_IDNO
					   AND b.StatusCase_CODE	= @Lc_StatusCaseOpen_CODE);
  
END;   --End of CMEM_RETRIEVE_S58.    

GO
