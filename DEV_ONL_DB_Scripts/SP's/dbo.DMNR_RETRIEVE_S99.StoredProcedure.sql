/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S99]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S99] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB NUMERIC(5, 0),
 @An_Schedule_NUMB    NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S99
  *     DESCRIPTION       : Retrieve Maximum Updated Schedule Number for a Case ID, Major Sequence Number, Schedule Number, Appointment Status is Re-Schedule and Scheduled and Worker Id not Space.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_Schedule_NUMB = NULL;

  DECLARE @Lc_Space_TEXT        CHAR(1) = ' ',
          @Lc_ApptStatusRs_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusSc_CODE CHAR(2) = 'SC';

  SELECT @An_Schedule_NUMB = MAX(n.Schedule_NUMB)
    FROM DMNR_Y1 n
         JOIN SWKS_Y1 s
          ON n.Schedule_NUMB = s.Schedule_NUMB
             AND n.Case_IDNO = s.Case_IDNO
   WHERE n.Case_IDNO = @An_Case_IDNO
     AND n.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND s.ApptStatus_CODE IN (@Lc_ApptStatusSc_CODE, @Lc_ApptStatusRs_CODE)
     AND s.Worker_ID != @Lc_Space_TEXT;
 END; --END OF DMNR_RETRIEVE_S99


GO
