/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S154]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S154] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S154
  *     DESCRIPTION       : Retrieve Open (O) Cases from Case Details table for a dependent on a responding interstate intergovernmental case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_RelationshipCaseDp_CODE     CHAR(1) = 'D',
          @Lc_CaseStatusOpen_CODE         CHAR(1) = 'O',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A',
          @Lc_RespondInitR_CODE           CHAR(1) = 'R',
          @Lc_RespondInitS_CODE           CHAR(1) = 'S',
          @Lc_RespondInitY_CODE           CHAR(1) = 'Y';

  SELECT DISTINCT C.Case_IDNO
    FROM CMEM_Y1 M
         JOIN CASE_Y1 C
          ON M.Case_IDNO = C.Case_IDNO
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
     AND M.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
     AND M.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
     AND C.RespondInit_CODE IN (@Lc_RespondInitR_CODE, @Lc_RespondInitS_CODE, @Lc_RespondInitY_CODE);
 END; -- END of CASE_RETRIEVE_S154


GO
