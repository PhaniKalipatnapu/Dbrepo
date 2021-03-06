/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S8](
 @An_Application_IDNO           NUMERIC(15),
 @Ac_CaseRelationship_CODE      CHAR(1),
 @An_MemberMciKey_IDNO          NUMERIC(10),
 @Ac_CreateMemberMci_CODE       CHAR(1) OUTPUT,
 @Ac_AttyComplaint_INDC         CHAR(1) OUTPUT,
 @An_TransactionEventSeq_NUMB   NUMERIC(19) OUTPUT,
 @Ac_CpRelationshipToChild_CODE CHAR(3) OUTPUT,
 @An_MemberMci_IDNO             NUMERIC(10) OUTPUT,
 @An_OthpAtty_IDNO              NUMERIC(9) OUTPUT,
 @Ac_CpRelationshipToNcp_CODE   CHAR(3) OUTPUT,
 @Ac_FamilyViolence_INDC        CHAR(1) OUTPUT,
 @Ad_FamilyViolence_DATE        DATE OUTPUT,
 @Ac_TypeFamilyViolence_CODE    CHAR(2) OUTPUT
 )
AS
 /*            
 *     PROCEDURE NAME    : APCM_RETRIEVE_S8            
  *     DESCRIPTION       : Retrieve Member ID, CP Relationship with Dependents, Other party attorney ID, Indicator to check whether new MCI need to be created for the Member, Indicator to show weather this is compliant to Attorney or NOT, Unique Sequence       
  Number for the given Application ID and Member Type is CP.            
  *     DEVELOPED BY      : IMP Team            
  *     DEVELOPED ON      : 02-MAR-2011  
  *     MODIFIED BY       :             
  *     MODIFIED ON       :             
  *     VERSION NO        : 1            
 */
 BEGIN
  SELECT @Ac_CreateMemberMci_CODE = NULL,
         @Ac_AttyComplaint_INDC = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_CpRelationshipToChild_CODE = NULL,
         @An_MemberMci_IDNO = NULL,
         @An_OthpAtty_IDNO = NULL,
         @Ac_CpRelationshipToNcp_CODE = NULL,
         @Ac_FamilyViolence_INDC = NULL,
         @Ad_FamilyViolence_DATE = NULL,
         @Ac_TypeFamilyViolence_CODE = NULL;

  DECLARE @Lc_IvdApplicantCp_CODE CHAR(1) = 'C',
          @Ld_High_DATE           DATE = '12/31/9999';

  SELECT @An_MemberMci_IDNO = AC.MemberMci_IDNO,
         @Ac_CpRelationshipToChild_CODE = AC.CpRelationshipToChild_CODE,
         @An_OthpAtty_IDNO = AC.OthpAtty_IDNO,
         @Ac_CreateMemberMci_CODE = AC.CreateMemberMci_CODE,
         @An_TransactionEventSeq_NUMB = AC.TransactionEventSeq_NUMB,
         @Ac_AttyComplaint_INDC = AC.AttyComplaint_INDC,
         @Ac_CpRelationshipToNcp_CODE = AC.CpRelationshipToNcp_CODE,
         @Ac_FamilyViolence_INDC = AC.FamilyViolence_INDC,
         @Ad_FamilyViolence_DATE = AC.FamilyViolence_DATE,
         @Ac_TypeFamilyViolence_CODE = AC.TypeFamilyViolence_CODE
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.MemberMci_IDNO = ISNULL(@An_MemberMciKey_IDNO, AC.MemberMci_IDNO)
     AND AC.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
     AND AC.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCM_RETRIEVE_S8


GO
