/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S200]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S200] (
@An_MemberMci_IDNO NUMERIC(10),
@Ai_Count_QNTY     INT OUTPUT
)
AS
/*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S200
  *     DESCRIPTION       : Retrieve the count of Open (O) Cases from Case Details table for Unique Number Assigned by the System to the Member who is an Active Non-Custodial Parent (A) or Active Putative Father (P) in Case Members table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
*/
BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_StatusCaseOpen_CODE				CHAR(1) = 'O',
          @Lc_CaseRelationshipNcp_CODE			CHAR(1) = 'A',
          @Lc_CaseRelationshipCp_CODE			CHAR(1) = 'C',
          @Lc_CaseRelationshipPutFather_CODE	CHAR(1) = 'P',
          @Lc_CaseRelationshipDependent_CODE	CHAR(1) = 'D',
          @Lc_CaseMemberStatusActive_CODE		CHAR(1) = 'A';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM CMEM_Y1 M
         JOIN CASE_Y1 C
          ON M.Case_IDNO = C.Case_IDNO
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPutFather_CODE ,@Lc_CaseRelationshipCp_CODE,                           @Lc_CaseRelationshipDependent_CODE)                                     
     AND M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
END; 
 -- END OF CMEM_RETRIEVE_S200                                                                 

GO
