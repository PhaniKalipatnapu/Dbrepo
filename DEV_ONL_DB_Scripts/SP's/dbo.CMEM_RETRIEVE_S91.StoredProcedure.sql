/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S91]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S91](
 @An_Case_IDNO             NUMERIC(6, 0),
 @An_MemberMci_IDNO        NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S91
  *     DESCRIPTION       : Retrieve CP Member Mci for the given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_MemberMci_IDNO = NULL;
  
  DECLARE @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
		@Lc_CaseRelationshipCp_CODE		CHAR(1) = 'C';

  SELECT TOP 1 @An_MemberMci_IDNO = MemberMci_IDNO
    FROM CMEM_Y1
   WHERE Case_IDNO = @An_Case_IDNO
     AND CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE)
     AND CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
 END; --End of CMEM_RETRIEVE_S91

GO
