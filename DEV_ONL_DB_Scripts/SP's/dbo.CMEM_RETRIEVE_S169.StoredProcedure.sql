/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S169]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S169] (
 @An_Case_IDNO               NUMERIC(6, 0),
 @Ac_TypeTest_CODE           CHAR(1),
 @Ac_MemberCombinations_CODE CHAR(1)
 )
AS
 /*  
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S169  
  *     DESCRIPTION       : Retrieve the Case Member Details for a Case , Type of Genetic Test Conducted, Member Combinations, and Status of the CaseMember is Active and Members Case Relation is in CP/NCP/PF/DEP.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 26-AUG-2011 
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipDp_CODE        CHAR(1) = 'D',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_GtstTestResult_CODE            CHAR(1) = 'S',
          @Lc_GtstTypeTestDna_CODE           CHAR(1) = 'D',
          @Lc_MemberCombCp_CODE              CHAR(1) = '1',
          @Lc_MemberCombCpChild_CODE         CHAR(1) = '5',
          @Lc_MemberCombCpNcpPf_CODE         CHAR(1) = '3',
          @Lc_MemberCombCpNcpPfChild_CODE    CHAR(1) = '7',
          @Lc_MemberCombChild_CODE           CHAR(1) = '4',
          @Lc_MemberCombChildNcpPf_CODE      CHAR(1) = '6',
          @Lc_MemberCombNcpPf_CODE           CHAR(1) = '2',
          @Lc_TypePersonCp_CODE				 CHAR(3) = 'CP',
          @Lc_TypePersonNCp_CODE			 CHAR(3) = 'NCP',
          @Lc_TypePersonChild_CODE			 CHAR(3) = 'CI',
          @Lc_TableDprs_ID                   CHAR(4) = 'DPRS',
          @Lc_TableSubRole_ID                CHAR(4) = 'ROLE',
          @Ld_High_DATE                      DATE	 = '12/31/9999';
          
  DECLARE @Ld_Current_DATE					 DATE	 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT X.MemberMci_IDNO,
         X.MemberCheck_CODE,
         X.CaseRelationship_CODE,
         (SELECT TOP 1 ISNULL(MAX(@Lc_Yes_INDC), @Lc_No_INDC) AS expr
            FROM GTST_Y1 G
           WHERE G.TypeTest_CODE = ISNULL(@Ac_TypeTest_CODE, @Lc_GtstTypeTestDna_CODE)
             AND G.MemberMci_IDNO = X.MemberMci_IDNO
             AND G.Case_IDNO = @An_Case_IDNO
             AND G.TestResult_CODE = @Lc_GtstTestResult_CODE
             AND G.EndValidity_DATE = @Ld_High_DATE) AS ActivityType_INDC,
         D.Last_NAME,
         D.Suffix_NAME,
         D.First_NAME,
         D.Middle_NAME,
         X.TypePerson_CODE,
         (SELECT R.DescriptionValue_TEXT
            FROM REFM_Y1 R
           WHERE R.TableSub_ID = @Lc_TableSubRole_ID
             AND R.Table_ID = @Lc_TableDprs_ID
             AND R.Value_CODE = X.TypePerson_CODE) AS TypePartyDescription_TEXT
    FROM (SELECT A.MemberMci_IDNO,
                 CASE
                  WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                   THEN
                   CASE
                    WHEN @Ac_MemberCombinations_CODE IN (@Lc_MemberCombCp_CODE, @Lc_MemberCombCpNcpPf_CODE, @Lc_MemberCombCpChild_CODE, @Lc_MemberCombCpNcpPfChild_CODE)
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END
                  WHEN a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                   THEN
                   CASE
                    WHEN @Ac_MemberCombinations_CODE IN (@Lc_MemberCombNcpPf_CODE, @Lc_MemberCombCpNcpPf_CODE, @Lc_MemberCombChildNcpPf_CODE, @Lc_MemberCombCpNcpPfChild_CODE)
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END
                  WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                   THEN
                   CASE
                    WHEN @Ac_MemberCombinations_CODE IN (@Lc_MemberCombChild_CODE, @Lc_MemberCombCpChild_CODE, @Lc_MemberCombChildNcpPf_CODE, @Lc_MemberCombCpNcpPfChild_CODE)
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END
                 END AS MemberCheck_CODE,
                 A.CaseRelationship_CODE,
                 CASE A.CaseRelationship_CODE
                  WHEN @Lc_CaseRelationshipNcp_CODE
                   THEN 1
                  WHEN @Lc_CaseRelationshipPutFather_CODE
                   THEN 1
                  WHEN @Lc_CaseRelationshipCp_CODE
                   THEN 2
                  ELSE 3
                 END AS member_order,
                 A.Case_IDNO,
                 (SELECT D.TypePerson_CODE
					FROM DPRS_Y1 D
					JOIN CASE_Y1 C
					 ON C.Case_IDNO = A.Case_IDNO
					AND D.File_ID = C.File_ID 
					AND ((A.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
							AND D.TypePerson_CODE  = @Lc_TypePersonCp_CODE)
						OR (A.CaseRelationship_CODE IN ( @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
							AND D.TypePerson_CODE  = @Lc_TypePersonNCp_CODE)
						OR (A.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
							AND D.TypePerson_CODE  = @Lc_TypePersonChild_CODE))
				   WHERE D.DocketPerson_IDNO = A.MemberMci_IDNO
					 AND @Ld_Current_DATE BETWEEN D.EffectiveStart_DATE AND D.EffectiveEnd_DATE
					 AND D.EndValidity_DATE = @Ld_High_DATE) AS TypePerson_CODE
            FROM CMEM_Y1 A
           WHERE A.Case_IDNO = @An_Case_IDNO
             AND A.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
             AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipDp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)) X
         LEFT OUTER JOIN DEMO_Y1 D
          ON X.MemberMci_IDNO = D.MemberMci_IDNO
   ORDER BY X.MemberCheck_CODE DESC,
            X.member_order;
 END; --END OF CMEM_RETRIEVE_S169 


GO
