/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S185]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S185]  (

     @An_Case_IDNO		 NUMERIC(6,0),
     @An_MemberMci_IDNO		 NUMERIC(10,0)	 OUTPUT
     )
AS

   BEGIN

      SET @An_MemberMci_IDNO = NULL

      DECLARE
         @Lc_RelationshipCaseNcp           CHAR(1) = 'A', 
         @Lc_RelationshipCasePutFather     CHAR(1) = 'P';
        
        SELECT @An_MemberMci_IDNO = CMEM_Y1.MemberMci_IDNO
      FROM dbo.CMEM_Y1
      WHERE CMEM_Y1.Case_IDNO = @An_Case_IDNO 
      AND CMEM_Y1.CaseRelationship_CODE IN ( @Lc_RelationshipCaseNcp, @Lc_RelationshipCasePutFather );

                  
END  --END OF CMEM_RETRIEVE_S185


GO
