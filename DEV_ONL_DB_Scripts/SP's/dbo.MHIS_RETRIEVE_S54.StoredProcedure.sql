/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S54]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S54] (
 @An_MemberMci_IDNO		 NUMERIC(10)
 )
AS
 /*
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S54
  *     DESCRIPTION       : Retrieves the CaseWelfareIdno for a given member.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN

	DECLARE @Lc_RelationshipCaseCp_TEXT CHAR(1) = 'C', 
			@Ln_Zero_NUMB     NUMERIC(1) = 0,
			@Lc_StatusCaseMemberActive_TEXT CHAR(1) = 'A', 
			@Lc_WelfareTypeMedicaid_TEXT CHAR(1) = 'M', 
			@Lc_WelfareTypeTanf_TEXT CHAR(1) = 'A';
        
	SELECT DISTINCT M.CaseWelfare_IDNO 
	FROM MHIS_Y1 M, CMEM_Y1 C
	WHERE 
		M.TypeWelfare_CODE IN ( @Lc_WelfareTypeTanf_TEXT, @Lc_WelfareTypeMedicaid_TEXT )  
		AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_TEXT  
		AND M.Case_IDNO = C.Case_IDNO  
		AND C.CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT  
		AND M.CaseWelfare_IDNO != @Ln_Zero_NUMB  
		AND C.MemberMci_IDNO = @An_MemberMci_IDNO;
                  
END;-- End of MHIS_RETRIEVE_S54

GO
