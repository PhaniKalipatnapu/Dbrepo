/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S145]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S145]
(  
     @An_Case_IDNO		                NUMERIC(6,0),
     @Ac_CaseRelationship_CODE			CHAR(1),
     @Ac_CaseRelationshipDP_CODE        CHAR(1) 
 )                  
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S145
 *     DESCRIPTION       : This procedure returns the member id from CMEM_Y1 for a case whose relation is either NCP OR CP and case is active in state.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

      DECLARE
         @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A';
        
       SELECT C.MemberMci_IDNO,
			  D.Last_NAME,
			  D.First_NAME,
			  D.Middle_NAME,
			  D.Suffix_NAME
         FROM CMEM_Y1 C
		 JOIN DEMO_Y1 D ON C.MemberMci_IDNO = D.MemberMci_IDNO
       WHERE C.Case_IDNO = @An_Case_IDNO 
         AND C.CaseRelationship_CODE IN (@Ac_CaseRelationship_CODE,@Ac_CaseRelationshipDP_CODE ) 
         AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
                  
END;--End of CMEM_RETRIEVE_S145


GO
