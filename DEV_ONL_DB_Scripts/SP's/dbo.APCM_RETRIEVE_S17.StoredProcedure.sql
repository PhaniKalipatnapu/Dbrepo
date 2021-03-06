/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S17](
 @An_Application_IDNO             NUMERIC(15),
 @An_MemberMci_IDNO               NUMERIC(10) = NULL,
 @Ac_CpRelationshipToChild_CODE   CHAR(3) OUTPUT,
 @Ac_NcpRelationshipToChild_CODE  CHAR(3) OUTPUT,
 @Ac_CpRelationshipToNcp_CODE     CHAR(3) OUTPUT,
 @Ac_DescriptionRelationship_TEXT CHAR(30) OUTPUT,
 @An_OthpAtty_IDNO                NUMERIC(9) OUTPUT,
 @Ac_Applicant_CODE               CHAR(1) OUTPUT,
 @Ac_CreateMemberMci_CODE         CHAR(1) OUTPUT,
 @Ac_FamilyViolence_INDC          CHAR(1) OUTPUT,
 @Ad_FamilyViolence_DATE          DATE OUTPUT,
 @Ac_TypeFamilyViolence_CODE      CHAR(2) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCM_RETRIEVE_S17
  *     DESCRIPTION       : Gets the Indicator whether to create the Member in DACSES, the CP Relationship with Dependents,
                            the NCP Relationship with Dependents, Relationship Description, 
                            Other party attorney ID for the member, Indicator to check the Legal Guardian of the Dependent,
                            Indicator to check Applicant for the given Application Id, Member Id where enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_CpRelationshipToChild_CODE = NULL,
         @Ac_NcpRelationshipToChild_CODE = NULL,
         @Ac_DescriptionRelationship_TEXT = NULL,
         @An_OthpAtty_IDNO = NULL,
         @Ac_Applicant_CODE = NULL,
         @Ac_CreateMemberMci_CODE = NULL,
         @Ac_FamilyViolence_INDC = NULL,
         @Ad_FamilyViolence_DATE = NULL,
         @Ac_TypeFamilyViolence_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_CreateMemberMci_CODE = AC.CreateMemberMci_CODE,
         @Ac_CpRelationshipToChild_CODE = AC.CpRelationshipToChild_CODE,
         @Ac_NcpRelationshipToChild_CODE = AC.NcpRelationshipToChild_CODE,
         @Ac_CpRelationshipToNcp_CODE = AC.CpRelationshipToNcp_CODE,
         @Ac_DescriptionRelationship_TEXT = AC.DescriptionRelationship_TEXT,
         @An_OthpAtty_IDNO = AC.OthpAtty_IDNO,
         @Ac_Applicant_CODE = AC.Applicant_CODE,
         @Ac_FamilyViolence_INDC = AC.FamilyViolence_INDC,
         @Ad_FamilyViolence_DATE = AC.FamilyViolence_DATE,
         @Ac_TypeFamilyViolence_CODE = AC.TypeFamilyViolence_CODE
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, AC.MemberMci_IDNO)
     AND AC.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCM_RETRIEVE_S17


GO
