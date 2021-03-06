/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S42](
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : MHIS_RETRIEVE_S42
  *     DESCRIPTION       : Retrieves the Member Id, Case  Id for the given Case Id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseNcp_CODE CHAR(1) = 'A',
		  @Lc_CaseMemberStatus_CODE	   CHAR(1) = 'A',
		  @Lc_RelationshipCaseP_CODE   CHAR(1) = 'P';

  SELECT DISTINCT
         M.MemberMci_IDNO,
         M.Case_IDNO
    FROM MHIS_Y1 M
		 JOIN CMEM_Y1 C
		 ON C.MemberMci_IDNO = M.MemberMci_IDNO AND CaseMemberStatus_CODE = @Lc_CaseMemberStatus_CODE
   WHERE M.Case_IDNO = @An_Case_IDNO
		 AND C.Case_Idno = M.Case_IDNO
		 AND C.CaseRelationship_CODE NOT IN (@Lc_RelationshipCaseNcp_CODE,@Lc_RelationshipCaseP_CODE);
 END; --End of MHIS_RETRIEVE_S42

GO
