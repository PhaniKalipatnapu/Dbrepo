/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S173]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S173] (
 @An_Case_IDNO               NUMERIC(6, 0),
 @An_MemberMci_IDNO          NUMERIC(10, 0) OUTPUT,
 @Ac_FamilyViolence_INDC     CHAR(1) OUTPUT,
 @Ad_FamilyViolence_DATE     DATE OUTPUT,
 @Ac_TypeFamilyViolence_CODE CHAR(2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S173
  *     DESCRIPTION       : Retrieve the Member Idno for a Case Idno, Case Relation is Custodial Parent, and Member Case Status is Active.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_MemberMci_IDNO = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT @An_MemberMci_IDNO = C.MemberMci_IDNO,
         @Ac_FamilyViolence_INDC = C.FamilyViolence_INDC,
         @Ad_FamilyViolence_DATE = C.FamilyViolence_DATE,
         @Ac_TypeFamilyViolence_CODE = C.TypeFamilyViolence_CODE
    FROM CMEM_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --END OF CMEM_RETRIEVE_S173 


GO
