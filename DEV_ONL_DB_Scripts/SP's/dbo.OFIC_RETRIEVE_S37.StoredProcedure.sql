/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S37] ( 
			@An_Office_IDNO			 NUMERIC(3,0),
			@An_MemberMci_IDNO		 NUMERIC(10,0),
			@Ac_WrkAccess_INDC       CHAR(1)		OUTPUT
		)
AS
/*
 *     PROCEDURE NAME    : OFIC_RETRIEVE_S37
 *     DESCRIPTION       : This procedure returns 'N' if the worker doesn't have access to all the payor's case counties.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 01-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   
BEGIN
     DECLARE @Lc_CaseStatusOpen_CODE				CHAR(1) = 'O', 
			 @Lc_No_INDC							CHAR(1) = 'N', 
			 @Lc_RelationshipCaseNcp_CODE			CHAR(1) = 'A', 
			 @Lc_RelationshipCasePutFather_CODE		CHAR(1) = 'P', 
			 @Lc_StatusCaseMemberActive_CODE		CHAR(1) = 'A', 
			 @Ld_High_DATE							DATE	= '12/31/9999';
         
         SET @Ac_WrkAccess_INDC = 'Y';
      
      SELECT @Ac_WrkAccess_INDC = @Lc_No_INDC
		FROM OFIC_Y1  a
	   WHERE a.Office_IDNO		= @An_Office_IDNO 
		 AND a.EndValidity_DATE = @Ld_High_DATE 
		 AND EXISTS (
				SELECT 1 
				  FROM CMEM_Y1 c 
					   JOIN CASE_Y1 b
					ON c.Case_IDNO = b.Case_IDNO 
				   AND b.County_IDNO <> a.County_IDNO					
				 WHERE c.MemberMci_IDNO			= @An_MemberMci_IDNO 
				   AND b.StatusCase_CODE		= @Lc_CaseStatusOpen_CODE 
				   AND c.CaseMemberStatus_CODE  = @Lc_StatusCaseMemberActive_CODE 
				   AND c.CaseRelationship_CODE IN ( 
													@Lc_RelationshipCaseNcp_CODE, 
													@Lc_RelationshipCasePutFather_CODE
												  ));                  
END; -- END OF OFIC_RETRIEVE_S37


GO
