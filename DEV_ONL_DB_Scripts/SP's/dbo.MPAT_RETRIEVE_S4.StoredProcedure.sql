/****** Object:  StoredProcedure [dbo].[MPAT_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MPAT_RETRIEVE_S4] (
 @An_Case_IDNO  NUMERIC(6),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MPAT_RETRIEVE_S4
  *     DESCRIPTION       : Retrieves the count of children whose paternity is not yet established.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 08-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipDependent_CODE CHAR(1) = 'D',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_StatusEstablished_CODE         CHAR(1) = 'E';

 SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 c
    WHERE c.Case_IDNO = @An_Case_IDNO
      AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND NOT EXISTS (
		SELECT 1 
		 FROM MPAT_Y1 m 
		 WHERE m.MemberMci_IDNO = c.MemberMci_IDNO
		   AND m.StatusEstablish_CODE = @Lc_StatusEstablished_CODE
      );
 END -- END of MPAT_RETRIEVE_S4

GO
