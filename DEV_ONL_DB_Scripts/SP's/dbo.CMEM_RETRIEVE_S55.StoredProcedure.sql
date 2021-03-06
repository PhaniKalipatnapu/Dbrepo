/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S55]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S55]  
(
     @An_Case_IDNO		NUMERIC(6,0),
     @An_MemberMci_IDNO	NUMERIC(10,0)	 OUTPUT
)     
AS

/*
*     PROCEDURE NAME    : CMEM_RETRIEVE_S55
*     DESCRIPTION       : Procedure is used to retrieve the member id from cmem table.
*     DEVELOPED BY      : IMP TEAM
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
BEGIN

      SET @An_MemberMci_IDNO = NULL;

      DECLARE
         @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A', 
         @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P';
        
        SELECT @An_MemberMci_IDNO = m.MemberMci_IDNO
      FROM CMEM_Y1   M
      JOIN
       CASE_Y1 C
       ON(C.Case_IDNO = M.Case_IDNO)
      WHERE 
         C.Case_IDNO = @An_Case_IDNO  
        AND (M.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE 
        OR (M.CaseRelationship_CODE = @Lc_CaseRelationshipPutFather_CODE  
        AND NOT EXISTS (
            SELECT 1 
            FROM CMEM_Y1 V
            WHERE V.Case_IDNO = @An_Case_IDNO 
            AND V.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
         )));

                  
END;   --End of CMEM_RETRIEVE_S55 


GO
