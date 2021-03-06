/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S95]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S95] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE	CHAR(1)  
 )
AS
 /*  
       PROCEDURE NAME     : CASE_RETRIEVE_S95  
  *     DESCRIPTION       : Retrieve Non Custodial Parent or Putative Father Personal Information for a given Case.  
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
          @Ld_High_DATE                       DATE = '12/31/9999';



  SELECT d.MemberMci_IDNO,
         d.Last_NAME,
         d.First_NAME,
         d.Suffix_NAME,
         d.Middle_NAME,
         d.Birth_DATE,
         d.MemberSsn_NUMB,
         d.HomePhone_NUMB,
         d.WorkPhone_NUMB,
         d.CellPhone_NUMB,
         d.Contact_EML,
         c2.FamilyViolence_INDC,
         d.DescriptionIdentifyingMarks_TEXT,
         m.InstitutionStatus_CODE
    FROM CASE_Y1 c1
         JOIN CMEM_Y1 c2
          ON c2.Case_IDNO = c1.Case_IDNO
         JOIN DEMO_Y1 d
          ON c2.MemberMci_IDNO = d.MemberMci_IDNO
         LEFT OUTER JOIN MDET_Y1 m
          ON d.MemberMci_IDNO = m.MemberMci_IDNO
             AND m.EndValidity_DATE = @Ld_High_DATE
   WHERE c1.Case_IDNO = @An_Case_IDNO
     AND c2.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND ((@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipNcpA_CODE
             AND c2.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipPutFatherP_CODE))
             OR (@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipNcpC_CODE) 
             AND c2.CaseRelationship_CODE =@Lc_CaseRelationshipNcpC_CODE);
 END; --End Of  CASE_RETRIEVE_S95

GO
