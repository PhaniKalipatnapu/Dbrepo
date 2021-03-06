/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S23] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE CHAR(1),
 @Ai_Count_QNTY            INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S23
  *     DESCRIPTION       : Retrieve the count of records from Case Members table for each retrieved Case and Members Case Relation other than Custodial Parent (C) and Dependant (D).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 07-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE CHAR(1) = 'C',
          @Lc_CaseRelationshipDp_CODE CHAR(1) = 'D';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
     AND C.CaseRelationship_CODE NOT IN (@Lc_CaseRelationshipDp_CODE, @Lc_CaseRelationshipCp_CODE);
 END; -- END OF CMEM_RETRIEVE_S23


GO
