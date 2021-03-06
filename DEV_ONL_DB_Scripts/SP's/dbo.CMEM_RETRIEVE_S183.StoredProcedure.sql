/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S183]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S183] (
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S183
  *     DESCRIPTION       : Retrieve the Case from Case Members table for the Member who is an Active.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT DISTINCT C.Case_IDNO
    FROM CMEM_Y1 C
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --END OF CMEM_RETRIEVE_S183


GO
