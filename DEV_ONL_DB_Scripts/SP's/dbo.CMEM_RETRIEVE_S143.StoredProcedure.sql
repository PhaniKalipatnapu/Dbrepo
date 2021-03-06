/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S143]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S143]  
	(
	 @An_Case_IDNO	               NUMERIC(6,0),
	 @Ac_CaseRelationshipCP_CODE   CHAR(1),
     @Ac_CaseRelationshipDP_CODE   CHAR(1)               
    )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S143
 *     DESCRIPTION       : Retrieve the CP and Dependent's member mci number from CMEM_Y1 table  for case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      DECLARE
         @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A';
                 
      SELECT C.MemberMci_IDNO 
		FROM CMEM_Y1 C
      WHERE C.Case_IDNO = @An_Case_IDNO 
        AND C.CaseRelationship_CODE IN ( @Ac_CaseRelationshipDP_CODE, @Ac_CaseRelationshipCP_CODE ) 
        AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
                  
END; --END OF CMEM_RETRIEVE_S143 


GO
