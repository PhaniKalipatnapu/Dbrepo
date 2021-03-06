/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S67]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S67] (
 @An_Case_IDNO          NUMERIC(6),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_TypeReference_CODE CHAR(5),
 @Ai_Count_QNTY         INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S67
  *     DESCRIPTION       : To Check whether AREN remedy started for a Same Reference Type
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_StatusStart_CODE CHAR(4) = 'STRT';

  SELECT @Ai_Count_QNTY = COUNT(DISTINCT b.Forum_IDNO)
    FROM DMNR_Y1 a
         JOIN DMJR_Y1 b
          ON b.Case_IDNO = a.Case_IDNO
             AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
             AND b.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
   WHERE b.Case_IDNO = @An_Case_IDNO
     AND b.Status_CODE = @Lc_StatusStart_CODE
     AND b.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND b.TypeReference_CODE = @Ac_TypeReference_CODE;
 END; -- End of DMJR_RETRIEVE_S67


GO
