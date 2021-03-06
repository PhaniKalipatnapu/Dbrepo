/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S186]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S186] (
 @An_Case_IDNO      NUMERIC(6),
 @An_MemberMci_IDNO NUMERIC(10) OUTPUT
 )
AS
 BEGIN

  DECLARE @Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A',
		  @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A';

  SELECT @An_MemberMci_IDNO = cm.MemberMci_IDNO
    FROM CMEM_Y1 cm
   WHERE cm.Case_IDNO = @An_Case_IDNO
     AND cm.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
     AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END --END OF CMEM_RETRIEVE_S186

GO
