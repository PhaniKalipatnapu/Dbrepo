/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S142]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S142]  
(
     @An_Case_IDNO				NUMERIC(6,0),
     @An_MemberMci_IDNO			NUMERIC(10,0),
     @Ac_CaseRelationship_CODE	CHAR(1)		OUTPUT
 )    
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S142
 *     DESCRIPTION       : This procedure is used to retrieve the Case Relationship code for the Case and its member.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN
      SET @Ac_CaseRelationship_CODE = NULL;

      SELECT DISTINCT @Ac_CaseRelationship_CODE = a.CaseRelationship_CODE
        FROM CMEM_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.MemberMci_IDNO = @An_MemberMci_IDNO;
                  
END;--END OF  CMEM_RETRIEVE_S142


GO
