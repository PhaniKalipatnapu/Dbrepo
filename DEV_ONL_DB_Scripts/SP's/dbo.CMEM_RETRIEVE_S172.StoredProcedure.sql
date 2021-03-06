/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S172]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S172] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S172
  *     DESCRIPTION       : Retrieve Case Relation for Case  Idno, Member Idno, and where Case Member Status is Active.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_CaseRelationship_CODE = NULL;

  DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT @Ac_CaseRelationship_CODE = a.CaseRelationship_CODE
    FROM CMEM_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --END OF CMEM_RETRIEVE_S172 

GO
