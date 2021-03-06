/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S22] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S22
  *     DESCRIPTION       : Retrieve Open (O) Cases from Case Details table for Unique Number Assigned by the System to the Member who is an Active Dependant (D) in Case Members table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 07-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
          @Lc_CaseRelationshipDp_CODE     CHAR(1) = 'D',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT DISTINCT M.Case_IDNO
    FROM CMEM_Y1 M
         JOIN CASE_Y1 C
          ON M.Case_IDNO = C.Case_IDNO
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
     AND M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
 END; -- END OF CMEM_RETRIEVE_S22


GO
