/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S202]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S202] (
 @An_MemberMci_IDNO        NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S202
  *     DESCRIPTION       : Retrieve Putative Father MemberMci id for given dependent(D)
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 15-APR-2014
  *     VERSION NO        : 1
 */
 BEGIN

  DECLARE @Lc_CaseRelationshipD_CODE CHAR(1) = 'D',
          @Lc_CaseRelationshipP_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusA_CODE CHAR(1) = 'A',
		  @Lc_StatusEstablished_CODE CHAR(1) = 'E',
		  @Lc_StatusCaseOpen_CODE	 CHAR(1) = 'O';
          
  SELECT DISTINCT C.MemberMci_IDNO
    FROM CMEM_Y1 C
	JOIN CASE_Y1 A
	  ON C.Case_IDNO = A.Case_IDNO
   WHERE C.CaseRelationship_CODE =  @Lc_CaseRelationshipP_CODE
     AND C.CaseMemberStatus_CODE =  @Lc_CaseMemberStatusA_CODE
     AND A.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
     AND EXISTS (SELECT 1
                   FROM CMEM_Y1 C1
                  WHERE C1.Case_IDNO = C.Case_IDNO
                    AND C1.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
                    AND C.CaseMemberStatus_CODE=@Lc_CaseMemberStatusA_CODE
                    AND C1.MemberMci_IDNO = @An_MemberMci_IDNO)
     AND NOT EXISTS(SELECT 1
                      FROM CMEM_Y1 c1
                    WHERE c1.Case_IDNO = c.Case_IDNO
                      AND c1.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
                      AND c1.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                      AND NOT EXISTS (SELECT 1 
		                                FROM MPAT_Y1 m 
		                              WHERE m.MemberMci_IDNO = c1.MemberMci_IDNO
		                                AND m.StatusEstablish_CODE =  @Lc_StatusEstablished_CODE ));
                    
 END; -- END OF CMEM_RETRIEVE_S202

GO
