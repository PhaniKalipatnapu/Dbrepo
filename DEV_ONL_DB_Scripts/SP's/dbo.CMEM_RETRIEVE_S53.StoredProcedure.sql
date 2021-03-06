/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S53]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S53] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_Case_IDNO      NUMERIC(6, 0) OUTPUT,
 @An_MemberSsn_NUMB NUMERIC(9, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S53
  *     DESCRIPTION       : Retrieves the Case details for a respective member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_Case_IDNO = NULL,
         @An_MemberSsn_NUMB = NULL;

  DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT TOP 1 @An_Case_IDNO = C.Case_IDNO,
               @An_MemberSsn_NUMB = D.MemberSsn_NUMB
    FROM CMEM_Y1 C
         JOIN DEMO_Y1 D
          ON D.MemberMci_IDNO = C.MemberMci_IDNO
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --End Of Procedure CMEM_RETRIEVE_S53


GO
