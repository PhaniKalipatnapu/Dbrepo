/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S138]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S138] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S138
  *     DESCRIPTION       : Retrieve Non Custodial Parent or Putative Father for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN

  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE	 CHAR(1) = 'A';

  SELECT TOP 1 @An_MemberMci_IDNO = C.MemberMci_IDNO
    FROM CMEM_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
   ORDER BY C.CaseRelationship_CODE DESC;
 END; --End Of Procedure CMEM_RETRIEVE_S138  

GO
