/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S193]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S193] (
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S193
  *     DESCRIPTION       : Retrieve Member id for case relationship and the record exists for case id, and relationship is dependent(D)
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipD_CODE CHAR(1) = 'D',
          @Lc_CaseRelationshipP_CODE CHAR(1) = 'P',
          @Lc_CaseRelationshipA_CODE CHAR(1) = 'A',          
          @Lc_CaseMemberStatusA_CODE CHAR(1) = 'A';

  SELECT DISTINCT C.MemberMci_IDNO
    FROM CMEM_Y1 C
   WHERE ( (@Ac_CaseRelationship_CODE =@Lc_CaseRelationshipA_CODE AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE,@Lc_CaseRelationshipP_CODE))
           OR C.CaseRelationship_CODE =@Ac_CaseRelationship_CODE
          )
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
     AND EXISTS (SELECT 1
                   FROM CMEM_Y1 C1
                  WHERE C1.Case_IDNO = C.Case_IDNO
                    AND C1.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
                    AND C1.MemberMci_IDNO = @An_MemberMci_IDNO);
 END; -- END OF CMEM_RETRIEVE_S193

GO
