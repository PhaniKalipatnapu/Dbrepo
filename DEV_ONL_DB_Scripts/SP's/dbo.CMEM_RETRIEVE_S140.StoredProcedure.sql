/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S140]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S140]
(  
     @An_MemberMci_IDNO				NUMERIC(10,0),
     @Ac_CaseRelationship_CODE		CHAR(1),
     @Ai_Count_QNTY					INT          OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S140
 *     DESCRIPTION       : This procedure retruns the count of member from CMEM_Y1 table whose relation ship is C AND P.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
          SET @Ai_Count_QNTY = NULL;

      DECLARE @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM CMEM_Y1 a
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND a.CaseRelationship_CODE IN ( @Ac_CaseRelationship_CODE, @Lc_RelationshipCasePutFather_CODE );
                  
END;--End of CMEM_RETRIEVE_S140


GO
