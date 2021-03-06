/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S7](
 @An_Application_IDNO           NUMERIC(15),
 @Ac_FamilyViolence_INDC        CHAR(1),
 @Ac_TypeFamilyViolence_CODE    CHAR(2)
 )
AS
 /*            
  *     PROCEDURE NAME    : APCM_RETRIEVE_S7            
  *     DESCRIPTION       : Retrieve the Dependent Case Member details for given Application ID.            
  *     DEVELOPED BY      : IMP Team            
  *     DEVELOPED ON      : 21-FEB-2013  
  *     MODIFIED BY       :             
  *     MODIFIED ON       :             
  *     VERSION NO        : 1            
 */
 BEGIN
  
  DECLARE @Lc_CaseRelationship_CODE CHAR(1) = 'D',
          @Ld_High_DATE           DATE = '12/31/9999';

  SELECT 	AC.MemberMci_IDNO,
  			AC.CaseRelationship_CODE,
			AC.CreateMemberMci_CODE,
			AC.CpRelationshipToChild_CODE,
			AC.CpRelationshipToNcp_CODE,
			AC.NcpRelationshipToChild_CODE,
			AC.DescriptionRelationship_TEXT,
			AC.TransactionEventSeq_NUMB,
			AC.OthpAtty_IDNO,
			AC.Applicant_CODE,
			AC.AttyComplaint_INDC			
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO     
     AND AC.CaseRelationship_CODE = @Lc_CaseRelationship_CODE
     AND ( AC.FamilyViolence_INDC <> @Ac_FamilyViolence_INDC    
     OR AC.TypeFamilyViolence_CODE <> @Ac_TypeFamilyViolence_CODE )
     AND AC.EndValidity_DATE = @Ld_High_DATE;
     
 END; --End of APCM_RETRIEVE_S7


GO
