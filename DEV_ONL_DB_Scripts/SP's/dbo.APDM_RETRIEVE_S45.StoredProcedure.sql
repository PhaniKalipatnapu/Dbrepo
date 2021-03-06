/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S45](
 @An_Application_IDNO NUMERIC(15, 0)
 )
AS
 /*       
  *     PROCEDURE NAME    : APDM_RETRIEVE_S45          
  *     DESCRIPTION       : Retrieves the person covered for insurance details for respective application.            
  *     DEVELOPED BY      : IMP Team          
  *     DEVELOPED ON      : 22-AUG-2011          
  *     MODIFIED BY       :           
  *     MODIFIED ON       :           
  *     VERSION NO        : 1          
 */
 BEGIN
  DECLARE @Ld_High_DATE                DATE = '12/31/9999',
          @Lc_Yes_INDC                 CHAR(1) = 'Y',
          @Lc_CaseRelationshipCp_CODE  CHAR(1) = 'C',
          @Lc_CaseRelationshipDep_CODE CHAR(1) = 'D';

  SELECT A1.MemberMci_IDNO,
         A1.First_NAME,
         A1.Last_NAME,
         A1.Middle_NAME,
         A1.Suffix_NAME,
         A1.Birth_DATE,
         A1.MemberSsn_NUMB,
         A.CaseRelationship_CODE,
         ISNULL((SELECT A.MedicalIns_INDC
                   FROM APDI_Y1 A
                  WHERE A.DependantMci_IDNO = A1.MemberMci_IDNO AND A.Application_IDNO = A1.Application_IDNO ), @Lc_Yes_INDC) MedicalIns_INDC,
         ISNULL((SELECT A.DentalIns_INDC
                   FROM APDI_Y1 A
                  WHERE A.DependantMci_IDNO = A1.MemberMci_IDNO AND A.Application_IDNO = A1.Application_IDNO ), @Lc_Yes_INDC) DentalIns_INDC
    FROM APCM_Y1 A
         JOIN APDM_Y1 A1
          ON (A1.Application_IDNO = A.Application_IDNO
              AND A1.MemberMci_IDNO = A.MemberMci_IDNO)
   WHERE A1.Application_IDNO = @An_Application_IDNO
     AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipDep_CODE, @Lc_CaseRelationshipCp_CODE)
     AND A1.EndValidity_DATE = @Ld_High_DATE
     AND A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.CaseRelationship_CODE;
 END; -- End Of APDM_RETRIEVE_S45

GO
