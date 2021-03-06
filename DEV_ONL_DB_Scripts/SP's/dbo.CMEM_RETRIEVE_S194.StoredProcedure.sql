/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S194]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE 
	[dbo].[CMEM_RETRIEVE_S194]  
		(
			 @An_MemberMci_IDNO		 NUMERIC(10,0)		,
			 @Ai_Count_QNTY          INT           OUTPUT
		)
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S194
 *     DESCRIPTION       : Check whether the record is exist for active CP,NCP,PF member.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET 
		@Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A'	, 
         @Lc_CaseRelationshipPutFather_CODE	CHAR(1) = 'P'	,
         @Lc_CaseRelationshipCp_CODE		CHAR(1) = 'C'	,  
         @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A'	;
        
      SELECT @Ai_Count_QNTY = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO 
      AND   c.CaseRelationship_CODE IN ( @Lc_CaseRelationshipCp_CODE,@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE ) 
      AND   c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

                  
END;	--END OF CMEM_RETRIEVE_S194


GO
