/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S45]  (

     @An_MemberMci_IDNO		NUMERIC(10,0),
     @Ai_Count_QNTY         INT   OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S45
 *     DESCRIPTION       : Check whther Member exists or Not.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_RelationshipCaseNcp_CODE         CHAR(1) = 'A',
         @Lc_StatusCaseMemberActive_CODE      CHAR(1) = 'A';
        
        SELECT  @Ai_Count_QNTY = COUNT(1)
      FROM CMEM_Y1 C
      WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND  C.CaseRelationship_CODE =  @Lc_RelationshipCaseNcp_CODE
       AND  C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

                  
END; --END OF CMEM_RETRIEVE_S45


GO
