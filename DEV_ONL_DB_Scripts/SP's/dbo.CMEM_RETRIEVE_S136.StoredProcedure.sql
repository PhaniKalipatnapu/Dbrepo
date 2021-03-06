/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S136]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S136] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S136
  *     DESCRIPTION       : Retrieve the Case  for a  given Relation of the case
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
 --13258 - NOTE - CR0364 DFS Note - START -
 
  DECLARE @Lc_CaseStatusOpen_CODE         CHAR(1) = 'O',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A',
          @Li_Zero_NUMB                   SMALLINT = 0,
          @Li_One_NUMB                    SMALLINT = 1,
          @Ln_MemberMciFosterCare_IDNO    NUMERIC(10) = 999998,
          @Ln_MemberMciAbsentParent_IDNO  NUMERIC(10) = 999995,
          @Lc_Empty_TEXT                  CHAR(1) = '';

  SELECT @An_Case_IDNO AS Case_IDNO,
         @Li_Zero_NUMB AS Rnm_NUMB
  UNION
  SELECT DISTINCT
         C1.Case_IDNO,
         @Li_One_NUMB AS Rnm_NUMB
    FROM CMEM_Y1 C1
         JOIN CASE_Y1 C2
          ON C1.Case_IDNO = C2.Case_IDNO
         JOIN (SELECT C3.MemberMci_IDNO
                 FROM CMEM_Y1 C3
                WHERE C3.Case_IDNO = @An_Case_IDNO
                  AND C3.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
                  AND C3.MemberMci_IDNO NOT IN ( @Ln_MemberMciFosterCare_IDNO, @Ln_MemberMciAbsentParent_IDNO )
                  AND C3.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) C4
          ON C1.MemberMci_IDNO = C4.MemberMci_IDNO
   WHERE @Ac_CaseRelationship_CODE != @Lc_Empty_TEXT
     AND C1.Case_IDNO != @An_Case_IDNO
     AND C1.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
     AND C1.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
     AND C2.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
   ORDER BY Rnm_NUMB;
   
 --13258 - NOTE - CR0364 DFS Note - END -
 
 END; --END OF CMEM_RETRIEVE_S136


GO
