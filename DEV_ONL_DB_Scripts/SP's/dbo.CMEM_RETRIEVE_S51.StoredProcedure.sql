/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S51]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S51] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_Case_IDNO      NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S51
  *     DESCRIPTION       : Retrieves the case Id for the respective member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @An_Case_IDNO = NULL;

  DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT @An_Case_IDNO = C.Case_IDNO
    FROM CMEM_Y1 C
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; -- End Of Procedure CMEM_RETRIEVE_S51


GO
