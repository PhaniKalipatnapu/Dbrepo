/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S67]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S67]  
(
     @An_MemberMci_IDNO		 NUMERIC(10,0),         
     @Ai_Count_QNTY          INT       OUTPUT
)     
AS                                                                            

/*
*     PROCEDURE NAME    : CMEM_RETRIEVE_S67
*     DESCRIPTION       : Retrieve Record Count for a Member MCI and Members Case Relation is CP,NCP,PutFather.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C', 
         @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A', 
         @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P';
        
      SELECT TOP 1 @Ai_Count_QNTY = COUNT(1)
      FROM CMEM_Y1 C
      WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO 
      AND C.CaseRelationship_CODE IN ( @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE );

                  
END; --End of CMEM_RETRIEVE_S67  

GO
