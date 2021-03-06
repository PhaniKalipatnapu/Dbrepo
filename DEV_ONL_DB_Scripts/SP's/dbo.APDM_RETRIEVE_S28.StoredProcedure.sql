/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S28](
 @An_Application_IDNO        NUMERIC(15, 0),
 @An_MemberMci_IDNO          NUMERIC(10, 0),
 @Ac_PaternityEst_INDC       CHAR(1) OUTPUT,
 @Ac_PaternityEst_CODE       CHAR(3) OUTPUT,
 @Ac_FamilyViolence_INDC     CHAR(1) OUTPUT,
 @Ad_FamilyViolence_DATE     DATE OUTPUT,
 @Ac_TypeFamilyViolence_CODE CHAR(2) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : APDM_RETRIEVE_S28  
  *     DESCRIPTION       : Retrieve Paternity Indicator, Paternity Establishment Method, Family Violence Indicator, Family Violence Date and Type of Family Violence for an Application ID and Member IA.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 22-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ac_FamilyViolence_INDC = NULL,
         @Ac_PaternityEst_INDC = NULL,
         @Ad_FamilyViolence_DATE = NULL,
         @Ac_PaternityEst_CODE = NULL,
         @Ac_TypeFamilyViolence_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_PaternityEst_INDC = A.PaternityEst_INDC,
         @Ac_PaternityEst_CODE = A.PaternityEst_CODE,
         @Ac_FamilyViolence_INDC = A1.FamilyViolence_INDC,
         @Ad_FamilyViolence_DATE = A1.FamilyViolence_DATE,
         @Ac_TypeFamilyViolence_CODE = A1.TypeFamilyViolence_CODE
    FROM APDM_Y1 A
         JOIN APCM_Y1 A1
          ON (A.MemberMci_IDNO = A1.MemberMci_IDNO)
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APDM_RETRIEVE_S28


GO
