/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S135]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S135] (
 @An_MemberMci_IDNO				NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ai_Count_QNTY		 			INT OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S135
 *     DESCRIPTION       : Retrieve the count of records from Case Members table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with Case Relation equal to Dependant (D) for both the Members. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
  BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_RelationshipCaseDp_CODE	CHAR(1) = 'D';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM CMEM_Y1 cmp, CMEM_Y1 cms
       WHERE cmp.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND cms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
         AND cmp.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE 
         AND cms.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE;
                  
END; --END OF CMEM_RETRIEVE_S135


GO
