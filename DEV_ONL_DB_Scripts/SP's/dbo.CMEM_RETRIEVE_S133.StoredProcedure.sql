/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S133]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S133] (
 @An_MemberMci_IDNO				NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ac_Status_CODE       			CHAR(1) OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S133
 *     DESCRIPTION       : Return B if the Primary Member is an Active (A) Custodial Parent (C) and Secondary Member is an Active (A) Dependant (D) (or) if the Primary Member is an Active (A) Dependant (D) and Secondary Member is an Active (A) Custodial Parent (C), Return C if the Primary Member is an Active (A) Custodial Parent (C) and Secondary Member is an Active (A) Non-Custodial Parent (A) / Putative Father (P) (or) if the Primary Member is an Active (A) Non-Custodial Parent (A) / Putative Father (P) and Secondary Member is an Active (A) Custodial Parent (C) and Return D if the Primary Member is an Active (A) Dependant (D) and Secondary Member is an Active (A) Non-Custodial Parent (A) / Putative Father (P) (or) if the Primary Member is an Active (A) Non-Custodial Parent (A) / Putative Father (P) and Secondary Member is an Active (A) Dependant (D) in Case Members table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with same Case and different Case Relation for both the Members. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

 SET @Ac_Status_CODE = NULL;

 DECLARE @Lc_RelationshipCaseCp_CODE		CHAR(1) = 'C', 
         @Lc_RelationshipCaseDp_CODE		CHAR(1) = 'D', 
         @Lc_RelationshipCaseNcp_CODE 		CHAR(1) = 'A', 
         @Lc_RelationshipCasePutFather_CODE	CHAR(1) = 'P', 
         @Lc_StatusCaseMemberActive_CODE 	CHAR(1) = 'A';
        
      SELECT TOP 1 @Ac_Status_CODE = 
         CASE 
            WHEN (pr.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE AND se.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE) OR (pr.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE AND se.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE) THEN 'B'
            WHEN (pr.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE AND (se.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE OR se.CaseRelationship_CODE = @Lc_RelationshipCasePutFather_CODE)) OR ((pr.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE OR pr.CaseRelationship_CODE = @Lc_RelationshipCasePutFather_CODE) AND se.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE) THEN 'C'
            WHEN (pr.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE AND (se.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE OR se.CaseRelationship_CODE = @Lc_RelationshipCasePutFather_CODE)) OR ((pr.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE OR pr.CaseRelationship_CODE = @Lc_RelationshipCasePutFather_CODE) AND se.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE) THEN 'D'
         END
       FROM CMEM_Y1 pr
            JOIN
            CMEM_Y1 se
         ON pr.CaseRelationship_CODE <> se.CaseRelationship_CODE 
        AND pr.Case_IDNO = se.Case_IDNO
      WHERE pr.MemberMci_IDNO = @An_MemberMci_IDNO 
        AND se.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
        AND pr.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE 
        AND se.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
     
END; --END OF CMEM_RETRIEVE_S133


GO
