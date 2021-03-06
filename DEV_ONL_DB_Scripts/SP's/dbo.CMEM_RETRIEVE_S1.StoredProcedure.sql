/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S1](
 @An_MemberMci_IDNO      NUMERIC(10, 0),
 @An_SignedOnOffice_IDNO NUMERIC(3, 0)
 )
AS
 /*
 *      PROCEDURE NAME    : CMEM_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Case Idno, Relation Case Code for a Member Idno and Office Signed On Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/18/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_RelationshipCaseCP_CODE        CHAR(1) = 'C',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A';

  WITH CASEMEMEBER_CTE( Case_IDNO, MemberMci_IDNO, CaseRelationship_CODE, Opened_DATE, SortOffice_NUMB )
       AS (SELECT CM.Case_IDNO,
                  CM.MemberMci_IDNO,
                  CM.CaseRelationship_CODE,
                  C.Opened_DATE,
                  CASE
                   WHEN C.Office_IDNO = @An_SignedOnOffice_IDNO
                    THEN 1
                   ELSE 2
                  END AS SortOffice_NUMB
             FROM CMEM_Y1 CM
                  JOIN CASE_Y1 C
                   ON CM.Case_IDNO = C.Case_IDNO
            WHERE CM.MemberMci_IDNO = @An_MemberMci_IDNO
              AND CM.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
              AND CM.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE, @Lc_RelationshipCaseCP_CODE)
              AND C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE)
  SELECT A.Case_IDNO,
         A.MemberMci_IDNO,
         A.CaseRelationship_CODE
    FROM CASEMEMEBER_CTE A
   ORDER BY A.SortOffice_NUMB,
            A.Opened_DATE DESC;
 END


GO
