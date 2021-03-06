/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S65] (
 @An_Case_IDNO         NUMERIC(6, 0),
 @Ac_StatusCase_CODE   CHAR(1) OUTPUT,
 @Ac_TypeCase_CODE     CHAR(1) OUTPUT,
 @Ac_RespondInit_CODE  CHAR(1) OUTPUT,
 @An_MemberMciNcp_IDNO    NUMERIC(10) OUTPUT,
 @Ac_LastNcp_NAME      CHAR(20) OUTPUT,
 @Ac_SuffixNcp_NAME    CHAR(4) OUTPUT,
 @Ac_FirstNcp_NAME     CHAR(16) OUTPUT,
 @Ac_MiddleNcp_NAME    CHAR(20) OUTPUT,
 @An_MemberSsnNcp_NUMB NUMERIC(9, 0) OUTPUT,
 @An_MemberMciCp_IDNO     NUMERIC(10) OUTPUT,
 @Ac_LastCp_NAME       CHAR(20) OUTPUT,
 @Ac_SuffixCp_NAME     CHAR(4) OUTPUT,
 @Ac_FirstCp_NAME      CHAR(16) OUTPUT,
 @Ac_MiddleCp_NAME     CHAR(20) OUTPUT,
 @An_MemberSsnCp_NUMB  NUMERIC(9, 0) OUTPUT
 )
AS
 /*                                                                                                                                                         
  *     PROCEDURE NAME    : CASE_RETRIEVE_S65                                                                                                                
  *     DESCRIPTION       : Retrieves CP, NCP's membermci, ssn number, interstate respond, case status code for the given case ID.                                                                                                                                
  *     DEVELOPED BY      : IMP Team                                                                                                                       
  *     DEVELOPED ON      : 14-SEP-2011                                                                                                                     
  *     MODIFIED BY       :                                                                                                                                 
  *     MODIFIED ON       :                                                                                                                                 
  *     VERSION NO        : 1                                                                                                                               
 */
 BEGIN
  SELECT @Ac_TypeCase_CODE = NULL,
         @Ac_StatusCase_CODE = NULL,
         @An_MemberMciCp_IDNO = NULL,
         @Ac_RespondInit_CODE = NULL,
         @Ac_LastNcp_NAME = NULL,
         @Ac_SuffixNcp_NAME = NULL,
         @Ac_FirstNcp_NAME = NULL,
         @Ac_MiddleNcp_NAME = NULL,
         @Ac_LastNcp_NAME = NULL,
         @Ac_SuffixNcp_NAME = NULL,
         @Ac_FirstNcp_NAME = NULL,
         @Ac_MiddleNcp_NAME = NULL,
         @An_MemberMciNcp_IDNO = NULL,
         @An_MemberSsnCp_NUMB = NULL,
         @An_MemberSsnNcp_NUMB = NULL;

  DECLARE @Lc_RelationshipCaseCp_CODE        CHAR(1) = 'C',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A';

  SELECT @Ac_StatusCase_CODE = a.StatusCase_CODE,
         @Ac_TypeCase_CODE = a.TypeCase_CODE,
         @Ac_RespondInit_CODE = a.RespondInit_CODE,
         @An_MemberMciNcp_IDNO = c.MemberMci_IDNO,
         @Ac_LastNcp_NAME = dd.Last_NAME,
         @Ac_SuffixNcp_NAME = dd.Suffix_NAME,
         @Ac_FirstNcp_NAME = dd.First_NAME,
         @Ac_MiddleNcp_NAME = dd.Middle_NAME,
         @An_MemberSsnNcp_NUMB = dd.MemberSsn_NUMB,
         @An_MemberMciCp_IDNO = e.MemberMci_IDNO,
         @Ac_LastCp_NAME = d.Last_NAME,
         @Ac_SuffixCp_NAME = d.Suffix_NAME,
         @Ac_FirstCp_NAME = d.First_NAME,
         @Ac_MiddleCp_NAME = d.Middle_NAME,
         @An_MemberSsnCp_NUMB = d.MemberSsn_NUMB
    FROM CASE_Y1 a
         JOIN CMEM_Y1 c
          ON c.Case_IDNO = a.Case_IDNO
         LEFT OUTER JOIN DEMO_Y1 dd
          ON dd.MemberMci_IDNO = c.MemberMci_IDNO
         JOIN CMEM_Y1 e
          ON e.Case_IDNO = a.Case_IDNO
         LEFT OUTER JOIN DEMO_Y1 d
          ON d.MemberMci_IDNO = e.MemberMci_IDNO
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND (c.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
           OR (c.CaseRelationship_CODE = @Lc_RelationshipCasePutFather_CODE
               AND NOT EXISTS (SELECT 1
                                 FROM CMEM_Y1 i
                                WHERE i.Case_IDNO = c.Case_IDNO
                                  AND i.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
                                  AND i.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)))
     AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND e.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE;
 END; --End of CASE_RETRIEVE_S65              

GO
