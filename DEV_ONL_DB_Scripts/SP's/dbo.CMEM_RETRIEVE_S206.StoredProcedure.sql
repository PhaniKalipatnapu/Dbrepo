/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S206]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S206](
 @An_Application_IDNO NUMERIC(15),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S206
  *     DESCRIPTION       : Check if the CP and NCP already exist on another case with same MCI number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_CaseRelationshipCp_CODE             CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE            CHAR(1) = 'A',
          @Lc_CaseMemberStatusActive_CODE         CHAR(1) = 'A',
          @Lc_CaseRelationshipPutativeFather_CODE CHAR(1) = 'P',
          @Lc_TypeCaseFosterCare_CODE             CHAR(1) = 'F',
          @Lc_TypeCaseNonFosterCare_CODE          CHAR(1) = 'J',
          @Lc_CreateMemberMciNew_CODE             CHAR(1) = 'Y',
          @Lc_CreateMemberMciUpdate_CODE          CHAR(1) = 'U',
          @Ld_High_DATE                           DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 M
   WHERE M.MemberMci_IDNO = (SELECT A.MemberMci_IDNO
                               FROM APCM_Y1 A,
                                    APCS_Y1 S
                              WHERE A.Application_IDNO = @An_Application_IDNO
                                AND A.EndValidity_DATE = @Ld_High_DATE
                                AND A.CreateMemberMci_CODE IN (@Lc_CreateMemberMciNew_CODE, @Lc_CreateMemberMciUpdate_CODE)
                                AND A.Application_IDNO = S.Application_IDNO
                                AND S.EndValidity_DATE = @Ld_High_DATE
                                AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE)
                                AND S.TypeCase_CODE NOT IN (@Lc_TypeCaseNonFosterCare_CODE, @Lc_TypeCaseFosterCare_CODE))
	 AND M.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
     AND M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND M.Case_IDNO IN (SELECT E.case_idno
                           FROM CMEM_Y1 E
                          WHERE E.MemberMci_IDNO IN (SELECT A.MemberMci_IDNO
                                                      FROM APCM_Y1 A,
                                                           APCS_Y1 S
                                                     WHERE A.Application_IDNO = @An_Application_IDNO
                                                       AND A.EndValidity_DATE = @Ld_High_DATE
                                                       AND A.CreateMemberMci_CODE IN (@Lc_CreateMemberMciNew_CODE, @Lc_CreateMemberMciUpdate_CODE)
                                                       AND A.Application_IDNO = S.Application_IDNO
                                                       AND S.EndValidity_DATE = @Ld_High_DATE
                                                       AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPutativeFather_CODE)
                                                       AND S.TypeCase_CODE NOT IN (@Lc_TypeCaseNonFosterCare_CODE, @Lc_TypeCaseFosterCare_CODE))
                            AND E.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                            AND E.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutativeFather_CODE));
 END;


GO
