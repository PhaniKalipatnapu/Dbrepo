/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S110]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S110](
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE CHAR(1),
 @Ai_Count_QNTY            INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S110
  *     DESCRIPTION       : Gets the NCP record count for the given Case Id, Members Case Relation where Members Case Relation is not Custodial-Parent/Dependent.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_RelationshipCaseCp_CODE CHAR(1) = 'C',
          @Lc_RelationshipCaseDp_CODE CHAR(1) = 'D';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
     AND C.CaseRelationship_CODE NOT IN (@Lc_RelationshipCaseDp_CODE, @Lc_RelationshipCaseCp_CODE);
 END; --End of CMEM_RETRIEVE_S110


GO
