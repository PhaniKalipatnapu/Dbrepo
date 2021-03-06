/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S144]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S144] 
	(
	 @An_Case_IDNO		                NUMERIC(6,0),
     @Ac_CaseRelationshipCP_CODE        CHAR(1),
     @Ac_CaseRelationshipDP_CODE        CHAR(1),
     @Ai_Count_QNTY		                INT		OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S144
 *     DESCRIPTION       : Retrieve the count of member exist in the CMEM_Y1 for Case ID. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
		FROM CMEM_Y1 C
      WHERE C.Case_IDNO = @An_Case_IDNO 
        AND C.CaseRelationship_CODE IN ( @Ac_CaseRelationshipDP_CODE, @Ac_CaseRelationshipCP_CODE ) 
        AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
                  
END; --END OF CMEM_RETRIEVE_S144


GO
