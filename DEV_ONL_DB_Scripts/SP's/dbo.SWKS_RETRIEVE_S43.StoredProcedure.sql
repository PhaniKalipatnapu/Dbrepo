/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S43] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB NUMERIC(5, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S43
  *     DESCRIPTION       : Retrieve Row Count for a Case-ID, Scheduled Number, Type Activity is Genetic Testing and Appointment Status is Schedule and Re-Schedule.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_TypeActivityG_CODE CHAR(1) = 'G',
          @Lc_ApptStatusRs_CODE  CHAR(2) = 'RS',
          @Lc_ApptStatusSc_CODE  CHAR(2) = 'SC';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SWKS_Y1 s
   WHERE s.Case_IDNO = @An_Case_IDNO
     AND s.Schedule_NUMB IN (SELECT d.Schedule_NUMB
                               FROM DMNR_Y1 d
                              WHERE d.Case_IDNO = @An_Case_IDNO
                                AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB)
     AND s.TypeActivity_CODE = @Lc_TypeActivityG_CODE
     AND s.ApptStatus_CODE IN (@Lc_ApptStatusSc_CODE, @Lc_ApptStatusRs_CODE);
 END; --End of SWKS_RETRIEVE_S43


GO
