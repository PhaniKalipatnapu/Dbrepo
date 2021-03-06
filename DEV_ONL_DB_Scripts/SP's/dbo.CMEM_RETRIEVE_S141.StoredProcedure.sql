/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S141]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S141]
(  
     @An_MemberMci_IDNO			NUMERIC(10,0),
     @Ac_CaseRelationship_CODE	CHAR(1), 
     @Ai_Count_QNTY             INT				  OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S141
 *     DESCRIPTION       : This procedure retruns the count for the given case member from casemembers_t1 table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

         SET @Ai_Count_QNTY = NULL;

      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM CMEM_Y1 a 
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND a.CaseRelationship_CODE = @Ac_CaseRelationship_CODE;
                  
END;--End Of CMEM_RETRIEVE_S141


GO
