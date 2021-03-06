/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S72]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S72] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S72
  *     DESCRIPTION       : Retrieves the Case IDNO for a MemberMci IDNO
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatuActive_CODE     CHAR(1) = 'A';

  SELECT c.Case_IDNO
    FROM CMEM_Y1 c
   WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
     AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
     AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatuActive_CODE;
 END -- End of CMEM_RETRIEVE_S72

GO
