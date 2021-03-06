/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S101]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S101] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_PetitionerMci_IDNO NUMERIC(10, 0),
 @An_RespondentMci_IDNO NUMERIC(10, 0),
 @An_MemberMci_IDNO     NUMERIC(10, 0) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : CMEM_RETRIEVE_S101
  *     DESCRIPTION       : To Retrive Active NCP Member MCI Number for a Given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_MemberMci_IDNO = NULL;

  DECLARE @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A';

  SELECT @An_MemberMci_IDNO = MemberMci_IDNO
    FROM CMEM_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.CaseRelationship_CODE IN (@Lc_RelationshipCasePutFather_CODE, @Lc_RelationshipCaseNcp_CODE)
     AND (c.MemberMci_IDNO = @An_PetitionerMci_IDNO
           OR c.MemberMci_IDNO = @An_RespondentMci_IDNO)
     AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
 END; -- End of CMEM_RETRIEVE_S101

GO
