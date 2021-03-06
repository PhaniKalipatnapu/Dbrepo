/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S117]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S117](
 @Ac_CaseRelationship_CODE CHAR(1),
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ac_MemberSex_CODE        CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S117
  *     DESCRIPTION       : Retrieve Gender of the Member for a Case ID, Members Case Relation.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN

  SET @Ac_MemberSex_CODE = NULL;

  DECLARE @Lc_CaseMemberStatus_CODE	CHAR(1) = 'A';

  SELECT @Ac_MemberSex_CODE = d.MemberSex_CODE
    FROM CMEM_Y1 C
         JOIN DEMO_Y1 D
          ON (C.MemberMci_IDNO = D.MemberMci_IDNO)
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseMemberStatus_Code = @Lc_CaseMemberStatus_CODE
     AND C.CaseRelationship_CODE = @Ac_CaseRelationship_CODE;
 END; --End of CMEM_RETRIEVE_S117

GO
