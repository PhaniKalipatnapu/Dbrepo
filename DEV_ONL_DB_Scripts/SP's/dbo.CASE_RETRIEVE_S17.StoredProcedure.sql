/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S17] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve the count of records from Case Details table for the retrieved Open (O) Case whose Member is an Active Non-Custodial Parent (A) or Putative Father (P) in Case Members table and Case Respond Init Code equal to Initiation (I) or Responding (R).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_RespondInitR_CODE              CHAR(1) = 'R',
          @Lc_RespondInitS_CODE              CHAR(1) = 'S',
          @Lc_RespondInitY_CODE              CHAR(1) = 'Y',
          @Lc_RespondInitI_CODE              CHAR(1) = 'I',
          @Lc_RespondInitC_CODE              CHAR(1) = 'C',
          @Lc_RespondInitT_CODE              CHAR(1) = 'T';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CASE_Y1 C
   WHERE C.RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE, @Lc_RespondInitR_CODE, @Lc_RespondInitS_CODE, @Lc_RespondInitY_CODE)
     AND C.Case_IDNO = @An_Case_IDNO
     AND C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
     AND EXISTS (SELECT 1
                   FROM CMEM_Y1 M
                  WHERE M.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
                    AND M.Case_IDNO = @An_Case_IDNO
                    AND M.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE);
 END; -- END of  CASE_RETRIEVE_S17


GO
