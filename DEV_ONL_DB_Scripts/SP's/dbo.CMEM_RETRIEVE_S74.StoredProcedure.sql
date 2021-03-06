/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S74]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S74] ( 
 @An_MemberMci_IDNO	NUMERIC(10,0)
 )              
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S74
  *     DESCRIPTION       : Retrieve to get associated cases for the member CP or NCP
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 30-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
  BEGIN
      DECLARE
         @Lc_CaseRelationshipCp_CODE    CHAR(1) = 'C', 
         @Lc_CaseRelationshipNcp_CODE	CHAR(1) = 'A';
        
      SELECT DISTINCT a.Case_IDNO 
        FROM CMEM_Y1 a
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND a.CaseRelationship_CODE IN ( @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE );
                  
END; --END OF CMEM_RETRIEVE_S74


GO
