/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S215]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S215] (
 @An_Case_IDNO NUMERIC(6),
 @Ac_File_ID   CHAR(10)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S215
  *     DESCRIPTION       : To Retrive Respondent Name for the FAR Combinations that does not Requires ISIN Records.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_TypePersonCp_CODE				 CHAR(3) = 'CP',        
          @Lc_TypePersonNcp_CODE			 CHAR(3) = 'NCP',
          @Ld_High_DATE                      DATE	 = '12/31/9999';

  SELECT C.MemberMci_IDNO,
		 C.CaseRelationship_CODE,
         D.Last_NAME,
         D.First_NAME,
         D.Middle_NAME,
         D.Suffix_NAME
    FROM CMEM_Y1 C
         JOIN DEMO_Y1 D
          ON C.MemberMci_IDNO = D.MemberMci_IDNO
         JOIN DPRS_Y1 P
          ON C.MemberMci_IDNO = P.DocketPerson_IDNO
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND P.File_ID = @Ac_File_ID
     AND P.EffectiveEnd_DATE = @Ld_High_DATE
     AND P.EndValidity_DATE = @Ld_High_DATE
     AND ( ( C.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
			AND P.TypePerson_CODE = @Lc_TypePersonNcp_CODE)
		OR ( C.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
			AND P.TypePerson_CODE = @Lc_TypePersonCp_CODE) )
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; -- End of CMEM_RETRIEVE_S215            

GO
