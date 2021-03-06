/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S44] ( 
     @An_Case_IDNO		  NUMERIC(6,0),
     @Ai_Count_QNTY       INT           OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S44
 *     DESCRIPTION       : Checking Valid NCP or not.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = 0;

      DECLARE
         @Lc_RelationshipCaseNcp_CODE        CHAR(1) = 'A',
         @Lc_RelationshipCasePf_CODE		 CHAR(1) = 'P',
         @Lc_CaseMemberStatusActive_CODE	 CHAR(1) = 'A'; 
         
        SELECT  @Ai_Count_QNTY = COUNT(1)
         FROM CMEM_Y1 c
        WHERE c.Case_IDNO = @An_Case_IDNO
          AND c.CaseRelationship_CODE = @Lc_RelationshipCasePf_CODE
		  AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE		  
		  AND NOT EXISTS (SELECT 1 FROM CMEM_Y1 b
					WHERE b.Case_IDNO = c.Case_IDNO
					AND b.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
					AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) 

                  
END; --END OF CMEM_RETRIEVE_S44


GO
