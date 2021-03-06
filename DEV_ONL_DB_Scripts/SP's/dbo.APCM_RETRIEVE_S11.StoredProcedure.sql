/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S11](
 @An_TransactionEventSeq_NUMB     NUMERIC(19),
 @An_Application_IDNO             NUMERIC(15),
 @An_MemberMci_IDNO               NUMERIC(10),
 @Ac_CpRelationshipToChild_CODE   CHAR(3) OUTPUT,
 @Ac_NcpRelationshipToChild_CODE  CHAR(3) OUTPUT,
 @Ac_DescriptionRelationship_TEXT CHAR(30) OUTPUT,
 @An_OthpAtty_IDNO                NUMERIC(9) OUTPUT,
 @Ac_Applicant_CODE               CHAR(1) OUTPUT,
 @Ac_CreateMemberMci_CODE         CHAR(1) OUTPUT
 )
AS
 /*  
 *     PROCEDURE NAME    : APCM_RETRIEVE_S11  
  *     DESCRIPTION       : gets the Indicator to check whether Member needs to be created in DACSES, CP Relationship with Dependents, NCP Relationship with Dependents, Relationship Description, Other party attorney ID for the member, Legal Guardian of the
  Dependent, Applicant indicator for the given Application Id, Member Id, Transaction event sequence where enddate validity is highdate.  
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
         @Ac_CreateMemberMci_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_CreateMemberMci_CODE = AC.CreateMemberMci_CODE,
         @Ac_CpRelationshipToChild_CODE = AC.CpRelationshipToChild_CODE,
         @Ac_NcpRelationshipToChild_CODE = AC.NcpRelationshipToChild_CODE,
         @Ac_DescriptionRelationship_TEXT = AC.DescriptionRelationship_TEXT,
         @An_OthpAtty_IDNO = AC.OthpAtty_IDNO,
         @Ac_Applicant_CODE = AC.Applicant_CODE
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.MemberMci_IDNO = @An_MemberMci_IDNO
     AND AC.EndValidity_DATE = @Ld_High_DATE
     AND AC.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; --End of APCM_RETRIEVE_S11


GO
