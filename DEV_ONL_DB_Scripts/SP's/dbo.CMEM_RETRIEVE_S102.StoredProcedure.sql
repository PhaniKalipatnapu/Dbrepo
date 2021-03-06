/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S102]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S102] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
 *      PROCEDURE NAME    : CMEM_RETRIEVE_S102
  *     DESCRIPTION       : To get the List of Petitioner Name for a Given Case id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseCp_CODE        CHAR(1) = 'C',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A';

  SELECT C.MemberMci_IDNO,
		 C.CaseRelationship_CODE,
         D.Last_NAME,
         D.First_NAME,
         D.Middle_NAME,
         D.Suffix_NAME
    FROM CMEM_Y1 C
         JOIN DEMO_Y1 D
          ON C.MemberMci_IDNO = D.MemberMci_IDNO
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
     AND C.CaseRelationship_CODE IN (@Lc_RelationshipCaseCp_CODE, @Lc_RelationshipCaseNcp_CODE)
   ORDER BY CaseRelationship_CODE;
 END; -- END OF CMEM_RETRIEVE_S102

GO
