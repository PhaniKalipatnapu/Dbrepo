/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S25](
 @An_Application_IDNO NUMERIC(15, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : APCM_RETRIEVE_S25
  *     DESCRIPTION       : Retrieve Member ID, indicator saying Member need a new DCN or not, Member Type and Case Type for an Application ID in case member details at the time of application received when Application ID is same in member demographics and case member at the time of application received.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipCP_CODE       CHAR(1) = 'C',
          @Lc_CaseRelationshipDep_CODE      CHAR(1) = 'D',
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE       CHAR(1) = 'P',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Lc_TypeCaseNonFederalFoster_CODE CHAR(1) = 'J',
          @Lc_TypeCasePaIveFoster_CODE      CHAR(1) = 'F',
          @Lc_Space_TEXT					CHAR(1) = ' ';

  SELECT a.MemberMci_IDNO AS MemberMci_IDNO,
         a.CreateMemberMci_CODE AS CreateMemberMci_CODE,
         a.CaseRelationship_CODE AS CaseRelationship_CODE,
         c.TypeCase_CODE AS TypeCase_CODE,
         CASE
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE
               AND c.TypeCase_CODE NOT IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 1
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
               AND c.TypeCase_CODE NOT IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 2
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipPf_CODE
               AND c.TypeCase_CODE NOT IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 3
		  WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipDep_CODE
               AND c.TypeCase_CODE NOT IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 4
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipDep_CODE
               AND c.TypeCase_CODE IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
               AND a.MemberMci_IDNO = (SELECT TOP 1 X.MemberMci_IDNO
                                         FROM (SELECT m.MemberMci_IDNO,
                                                      ROW_NUMBER() OVER( ORDER BY m.Birth_DATE ASC) AS ORD_ROWNUM
                                                 FROM APDM_Y1 m
                                                      JOIN APCM_Y1 p
                                                       ON (m.MemberMci_IDNO = p.MemberMci_IDNO
                                                           AND p.Application_IDNO = m.Application_IDNO)
                                                WHERE m.Application_IDNO = @An_Application_IDNO
                                                  AND p.CaseRelationship_CODE = @Lc_CaseRelationshipDep_CODE
                                                  AND p.EndValidity_DATE = @Ld_High_DATE) AS X)
           THEN 1
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE
               AND c.TypeCase_CODE IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 2
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
               AND c.TypeCase_CODE IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 3
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipPf_CODE
               AND c.TypeCase_CODE IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 4
          WHEN a.CaseRelationship_CODE = @Lc_CaseRelationshipDep_CODE
           AND c.TypeCase_CODE IN (@Lc_TypeCasePaIveFoster_CODE, @Lc_TypeCaseNonFederalFoster_CODE)
           THEN 5
         END AS Rnm_NUMB
    FROM APCM_Y1 a
         JOIN APCS_Y1 c
          ON a.Application_IDNO = c.Application_IDNO
   WHERE a.Application_IDNO = @An_Application_IDNO
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND c.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Rnm_NUMB;
 END; --End of APCM_RETRIEVE_S25


GO
