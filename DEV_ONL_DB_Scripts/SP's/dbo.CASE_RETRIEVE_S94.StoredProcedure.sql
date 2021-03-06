/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S94]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S94] (
 @An_Case_IDNO NUMERIC(6)
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S94
  *     DESCRIPTION       : Retrieve cross reference details for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_MemberMciUnidentified_IDNO		NUMERIC(10)	=	999995,
		  @Ln_MemberMciDivOfFamService_IDNO		NUMERIC(10)	=	999998,
		  @Lc_CaseRelationshipCp_CODE			CHAR(1)		=	'C',
          @Lc_CaseRelationshipNcp_CODE			CHAR(1)		=	'A',
          @Lc_CaseRelationshipPutFather_CODE	CHAR(1)		=	'P',
          @Lc_CaseMemberStatusActive_CODE		CHAR(1)		=	'A';

	SELECT c.Case_IDNO,
		c.File_ID,
		d1.Last_NAME AS CpLast_NAME,
		d1.First_NAME AS CpFirst_NAME,
		d1.Middle_NAME AS CpMiddle_NAME,
		d1.Suffix_NAME AS CpSuffix_NAME,
		d2.Last_NAME AS NcpLast_NAME,
		d2.First_NAME AS NcpFirst_NAME,
		d2.Middle_NAME AS NcpMiddle_NAME,
		d2.Suffix_NAME AS NcpSuffix_NAME,
		c.County_IDNO,
		p.County_NAME
	FROM CASE_Y1 c
	JOIN ( SELECT c1.Case_IDNO, 
			   c2.MemberMci_IDNO CpMemberMci_IDNO, 
			   c1.MemberMci_IDNO NcpMemberMci_IDNO
		  FROM CMEM_Y1 c1
		  JOIN CMEM_Y1 c2
			ON c2.Case_IDNO = c1.Case_IDNO
		   AND c2.CaseRelationShip_CODE = @Lc_CaseRelationshipCp_CODE
		   AND c2.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
		 WHERE EXISTS (SELECT 1
						 FROM CMEM_Y1 t2
						WHERE t2.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
						  AND t2.Case_IDNO = c2.Case_IDNO
						  AND EXISTS ( SELECT 1 
										 FROM CMEM_Y1 t1
										WHERE t1.Case_IDNO = @An_Case_IDNO
										  AND t1.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
										  AND t1.MemberMci_IDNO NOT IN (@Ln_MemberMciUnidentified_IDNO, @Ln_MemberMciDivOfFamService_IDNO)
										  AND t1.MemberMci_IDNO = t2.MemberMci_IDNO
										  AND t1.Case_IDNO != t2.Case_IDNO ))
		   AND c1.CaseRelationShip_CODE IN (@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPutFather_CODE)
		   AND c1.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) m
	  ON m.Case_IDNO = c.Case_IDNO
	JOIN COPT_Y1 p
	  ON p.County_IDNO = c.County_IDNO
	JOIN DEMO_Y1 d1
	  ON d1.MemberMci_IDNO = m.CpMemberMci_IDNO
	JOIN DEMO_Y1 d2
	  ON d2.MemberMci_IDNO = m.NcpMemberMci_IDNO;
	 
 END; --End Of CASE_RETRIEVE_S94

GO
