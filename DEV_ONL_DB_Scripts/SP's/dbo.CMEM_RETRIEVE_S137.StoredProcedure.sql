/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S137]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S137] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S137
  *     DESCRIPTION       : Retrieve the Member for a given Case  and an Active Father or Non Custodial Parent.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_MemberMci_IDNO = NULL;

  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A';

  SELECT @An_MemberMci_IDNO = C.MemberMci_IDNO
    FROM CMEM_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
     AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
 END; --END OF CMEM_RETRIEVE_S137


GO
