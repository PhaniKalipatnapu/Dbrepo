/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S128]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S128](
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S128
  *     DESCRIPTION       : Retrieve Case and Case Relation for the Member from Case Members table who is an Active Non-Custodial Parent (A) / Putative Father (P) and whose Case is Open (O) in Case Details table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE        CHAR(1) = 'O',
          @Lc_CaseRelationshipCp_CODE    CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE   CHAR(1) = 'A',
          @Lc_CaseMembeStatusActive_CODE CHAR(1) = 'A';

  SELECT DISTINCT CM.Case_IDNO,
         CM.CaseRelationship_CODE
    FROM CMEM_Y1 CM
         JOIN CASE_Y1 C
          ON CM.Case_IDNO = C.Case_IDNO
   WHERE CM.MemberMci_IDNO = @An_MemberMci_IDNO
     AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE)
     AND CM.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE
     AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
   ORDER BY CM.Case_IDNO;
 END -- End of CMEM_RETRIEVE_S128

GO
