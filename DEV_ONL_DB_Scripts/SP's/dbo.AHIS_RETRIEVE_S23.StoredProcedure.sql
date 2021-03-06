/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S23] (
 @An_Case_IDNO 				NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE	CHAR(1) 
 )
AS
 /*  
  *     PROCEDURE NAME    : AHIS_RETRIEVE_S23  
  *     DESCRIPTION       : Retrieve Non Custodial Parent Last Court Address  and Current Mailing Address for a given Case.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE 
          @Lc_CaseRelationshipNcpC_CODE       CHAR(1) = 'C',
          @Lc_CaseRelationshipNcpA_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFatherP_CODE CHAR(1) = 'P',
          @Lc_TypeAddressMailingM_CODE        CHAR(1) = 'M',
          @Lc_TypeAddressCourtC_CODE          CHAR(1) = 'C',
          @Lc_StatusConfirmedGood_CODE        CHAR(1) = 'Y',
		  @Lc_CaseMemberStatusActive_CODE	  CHAR(1) = 'A',
          @Ld_System_DATE                     DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT a.MemberMci_IDNO,
         a.Attn_ADDR,
         a.Line1_ADDR,
         a.Line2_ADDR,
         a.City_ADDR,
         a.State_ADDR,
         a.Zip_ADDR,
         a.Country_ADDR,
         a.TypeAddress_CODE,
         a.Status_CODE,
         d.FullDisplay_NAME
    FROM AHIS_Y1 a
         JOIN CMEM_Y1 c2
          ON a.MemberMci_IDNO = c2.MemberMci_IDNO
         JOIN CASE_Y1 c1
          ON c2.Case_IDNO = c1.Case_IDNO
         JOIN DEMO_Y1 D
          ON D.MemberMci_IDNO = C2.MemberMci_IDNO
   WHERE c1.Case_IDNO = @An_Case_IDNO
     AND c2.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND((@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipNcpA_CODE
             AND c2.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipPutFatherP_CODE))
             OR (@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipNcpC_CODE) 
             AND c2.CaseRelationship_CODE =@Lc_CaseRelationshipNcpC_CODE)
     AND a.End_DATE >= @Ld_System_DATE
     AND a.TypeAddress_CODE IN (@Lc_TypeAddressMailingM_CODE, @Lc_TypeAddressCourtC_CODE)
     AND a.Status_CODE = @Lc_StatusConfirmedGood_CODE
   ORDER BY a.MemberMci_IDNO,a.TypeAddress_CODE;
 END; --End Of  AHIS_RETRIEVE_S23

GO
