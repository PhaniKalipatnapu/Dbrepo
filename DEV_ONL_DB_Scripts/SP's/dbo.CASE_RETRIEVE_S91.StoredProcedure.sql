/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S91]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S91](
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_County_IDNO    NUMERIC(3, 0),
 @An_Office_IDNO    NUMERIC(3, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : CASE_RETRIEVE_S91  
  *     DESCRIPTION       : Retrieves the Case Member details for the given Member Id, Office Code, County Code.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 20-NOV-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseCp_CODE  CHAR(1) = 'C',
          @Ln_MemberMciFoster_IDNO     NUMERIC(6) = 999998,
          @Ln_MemberMciUnknown_IDNO    NUMERIC(10) = 999995,
          @Li_Ten_NUMB                 SMALLINT = 10;

  SELECT B.Case_IDNO,
         B.TypeCase_CODE,
         B.StatusCase_CODE,
         B.Office_IDNO,
         B.CaseRelationship_CODE,
         B.MemberMci_IDNO,
         B.LastCp_NAME,
         B.FirstCp_NAME,
         B.MiddleCp_NAME,
         B.Row_NUMB
    FROM (SELECT A.Case_IDNO,
                 A.TypeCase_CODE,
                 A.StatusCase_CODE,
                 A.Office_IDNO,
                 A.CaseRelationship_CODE,
                 A.MemberMci_IDNO,
                 A.LastCp_NAME,
                 A.FirstCp_NAME,
                 A.MiddleCp_NAME,
                 ROW_NUMBER() OVER( ORDER BY Case_IDNO ) Row_NUMB
            FROM (SELECT C.Case_IDNO,
                         C.TypeCase_CODE,
                         C.StatusCase_CODE,
                         C.Office_IDNO,
                         C1.CaseRelationship_CODE,
                         C1.MemberMci_IDNO,
                         D1.Last_NAME LastCp_NAME,
                         D1.First_NAME FirstCp_NAME,
                         D1.Middle_NAME MiddleCp_NAME
                    FROM CASE_Y1 C
                         JOIN CMEM_Y1 C1
                          ON (C.Case_IDNO = C1.Case_IDNO)
                          LEFT OUTER JOIN CMEM_Y1 C3
                          ON(C.Case_IDNO = C3.Case_IDNO
                             AND C3.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE)
                         JOIN DEMO_Y1 D1
                          ON (D1.MemberMci_IDNO = C3.MemberMci_IDNO)
                   WHERE C1.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND C.County_IDNO = ISNULL(@An_County_IDNO, C.County_IDNO)
                     AND C.Office_IDNO = ISNULL(@An_Office_IDNO, C.Office_IDNO)) A) B
   WHERE (B.MemberMci_IDNO IN (@Ln_MemberMciFoster_IDNO, @Ln_MemberMciUnknown_IDNO)
      AND B.Row_NUMB <= @Li_Ten_NUMB)
      OR (B.MemberMci_IDNO NOT IN (@Ln_MemberMciFoster_IDNO, @Ln_MemberMciUnknown_IDNO));
 END; --End of CASE_RETRIEVE_S91


GO
