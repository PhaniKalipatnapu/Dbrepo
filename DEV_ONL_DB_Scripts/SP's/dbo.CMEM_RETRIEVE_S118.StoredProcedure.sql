/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S118]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S118](
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S118
  *     DESCRIPTION       : Retrieve Record Count for a Case Idno and Members Case Relation is Dependent.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_RelationshipCaseDp_CODE CHAR(1) = 'D',
		  @Lc_CaseMemberStatusActive_CODE	  CHAR(1) = 'A';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --End of CMEM_RETRIEVE_S118

GO
