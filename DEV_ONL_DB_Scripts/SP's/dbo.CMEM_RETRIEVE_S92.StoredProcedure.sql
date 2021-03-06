/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S92]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S92] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S92  
  *     DESCRIPTION       : Retrieve member details for a given case.     
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A';

  SELECT c.MemberMci_IDNO,
         d.Last_NAME,
         d.First_NAME,
         d.Middle_NAME,
         d.Suffix_NAME
    FROM CMEM_Y1 c
         JOIN DEMO_Y1 d
          ON c.MemberMci_IDNO = d.MemberMci_IDNO
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND (c.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
           OR (c.CaseRelationship_CODE = @Lc_CaseRelationshipPutFather_CODE
               AND NOT EXISTS (SELECT 1
                                 FROM CMEM_Y1 c1
                                WHERE c1.Case_IDNO = c.Case_IDNO
                                  AND c1.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
                                  AND c1.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)));
 END; -- END OF CMEM_RETRIEVE_S92

GO
