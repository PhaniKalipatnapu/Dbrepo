/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S28](
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10)
 )
AS
 /*
 *     PROCEDURE NAME    : APCM_RETRIEVE_S28
  *     DESCRIPTION       : Retrieve Case ID, Member ID, Members Case Relation, Member Status on the Case, Relation Code of the NCP to Dependent and Relation Code of the CP to Dependent and space for Bench Warrant, Paternity Adjourned for the Plaintiff, Plaintiff indicator and Reason for Pursue.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT AC.CpRelationshipToChild_CODE,
         AC.NcpRelationshipToChild_CODE,
         AC.CaseRelationship_CODE,
         AC.FamilyViolence_DATE,
         AC.FamilyViolence_INDC,
         AC.TypeFamilyViolence_CODE
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.MemberMci_IDNO = @An_MemberMci_IDNO
     AND AC.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCM_RETRIEVE_S28


GO
