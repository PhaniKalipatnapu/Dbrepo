/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S81]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S81](
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S81
  *     DESCRIPTION       : Gets the Case Initiation record Count for the given case Id where Case is Initiation and Status of the Case is Open.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_CaseStatusOpen_CODE      CHAR(1) = 'O',
          @Lc_RespondInitInitiate_CODE CHAR(1) = 'I';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CASE_Y1 C
   WHERE C.RespondInit_CODE = @Lc_RespondInitInitiate_CODE
     AND C.Case_IDNO = @An_Case_IDNO
     AND C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;
 END; -- End Of CASE_RETRIEVE_S81


GO
