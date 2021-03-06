/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S184]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S184]  (

     @An_Case_IDNO		 NUMERIC(6,0),
     @An_MemberMci_IDNO		 NUMERIC(10,0)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S184
 *     DESCRIPTION       : Retrieve the  Member Idno for the Cp.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @An_MemberMci_IDNO = NULL;

      DECLARE
         @Lc_RelationshipCaseCp_CODE  CHAR(1) = 'C';
        
      SELECT @An_MemberMci_IDNO = a.MemberMci_IDNO
      FROM CMEM_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO 
      AND a.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE;
END 

GO
