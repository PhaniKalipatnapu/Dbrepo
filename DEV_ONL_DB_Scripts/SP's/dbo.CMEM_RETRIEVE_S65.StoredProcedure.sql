/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S65]  
    (
     @An_Case_IDNO		 	NUMERIC(6,0),
     @An_MemberMci_IDNO		NUMERIC(10,0),
     @Ai_Count_QNTY         INT OUTPUT
  )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S65
 *     DESCRIPTION       : Retrieve the count of records for a case idno, member mci idno for a CP.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_CaseRelationshipCp_CODE	CHAR(1) = 'C';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
      FROM CMEM_Y1 c
      WHERE c.Case_IDNO = @An_Case_IDNO 
      AND   c.MemberMci_IDNO = @An_MemberMci_IDNO 
      AND   c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;

                  
END  --End of CMEM_RETRIEVE_S65 


GO
