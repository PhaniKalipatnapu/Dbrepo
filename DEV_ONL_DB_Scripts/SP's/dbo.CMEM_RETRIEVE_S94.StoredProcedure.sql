/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S94]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S94] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S94
  *     DESCRIPTION       : Validates weather the given case member is active.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
		  @Lc_Yes_INDC					  CHAR(1) = 'Y';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND c.FamilyViolence_INDC = @Lc_Yes_INDC;
 END; -- End Of CMEM_RETRIEVE_S94

GO
