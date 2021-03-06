/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S96]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S96] (  

     @An_Case_IDNO		 NUMERIC(6,0),
     @An_MemberMci_IDNO		 NUMERIC(10,0)	 OUTPUT
   )
 AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S96
 *     DESCRIPTION       :
 *     DaClass_Name      : CmemDA
 *     Method_Name       : GetNcpForCase
 *     InputClass_Name   : CmemRetrieveS96InData
 *     OutputClass_Name  : PayorMCIIdnoOutData
 *     DEVELOPED BY      : Protech Solution Inc
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @An_MemberMci_IDNO = NULL

      DECLARE
         @Lc_RelationshipCaseNcp         CHAR(1) = 'A', 
         @Lc_RelationshipCasePutFather   CHAR(1) = 'P';
        
        SELECT @An_MemberMci_IDNO = a.MemberMci_IDNO
      FROM dbo.CMEM_Y1   a
      WHERE a.Case_IDNO = @An_Case_IDNO AND 
      (a.CaseRelationship_CODE = @Lc_RelationshipCaseNcp OR (a.CaseRelationship_CODE = @Lc_RelationshipCasePutFather AND NOT EXISTS 
         (
            SELECT 1 AS expr
            FROM dbo.CMEM_Y1   b
            WHERE b.Case_IDNO = a.Case_IDNO 
            AND b.CaseRelationship_CODE = @Lc_RelationshipCaseNcp
         )));

                  
END --END OF CMEM_RETRIEVE_S96


GO
