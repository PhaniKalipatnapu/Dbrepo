/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S64]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S64] (
 @An_Case_IDNO NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE	CHAR(1)
 )
AS
 /*  
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S64  
  *     DESCRIPTION       : Retrieve Non Custodial Parent's Current Primary Employer and Current Secondary Employer Income source Details for a given Case.
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
		  @Lc_CaseMemberStatusActive_CODE	  CHAR(1) = 'A',
          @Ld_High_DATE                       DATE = '12/31/9999',
          @Lc_StatusConfirmedGood_CODE        CHAR(1) = 'Y';

  SELECT X.MemberMci_IDNO,
         X.Status_CODE,
         X.EmployerPrime_INDC,
         X.OtherParty_NAME,
         X.Line1_ADDR,
         X.Line2_ADDR,
         X.City_ADDR,
         X.Zip_ADDR,
         X.State_ADDR,
         X.Country_ADDR,
         X.DescriptionContactOther_TEXT
    FROM (SELECT C.MemberMci_IDNO,
                 C.Status_CODE,
                 C.EmployerPrime_INDC,
                 D.Fein_IDNO,
                 D.OtherParty_NAME,
                 D.Line1_ADDR,
                 D.Line2_ADDR,
                 D.City_ADDR,
                 D.State_ADDR,
                 D.Zip_ADDR,
                 D.Country_ADDR,
                 D.DescriptionContactOther_TEXT
            FROM CMEM_Y1 B
                 JOIN EHIS_Y1 C
                  ON B.MemberMci_IDNO = C.MemberMci_IDNO
                 JOIN OTHP_Y1 D
                  ON C.OthpPartyEmpl_IDNO = D.OtherParty_IDNO
           WHERE B.Case_IDNO = @An_Case_IDNO
		     AND B.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
             AND( (@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipNcpA_CODE
             AND B.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipPutFatherP_CODE))
             OR (@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipNcpC_CODE) 
             AND B.CaseRelationship_CODE =@Lc_CaseRelationshipNcpC_CODE)
             AND C.Status_CODE = @Lc_StatusConfirmedGood_CODE
             AND C.EndEmployment_DATE = @Ld_High_DATE
             AND D.EndValidity_DATE = @Ld_High_DATE) AS X
			 ORDER BY X.MemberMci_IDNO,X.EmployerPrime_INDC DESC;
 END; --End of OTHP_RETRIEVE_S64 

GO
