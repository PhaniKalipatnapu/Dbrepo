/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S34] (
 @An_Schedule_NUMB            NUMERIC(10, 0),
 @An_Case_IDNO                NUMERIC(6, 0) OUTPUT,
 @An_OthpLocation_IDNO        NUMERIC(9, 0) OUTPUT,
 @Ac_ActivityMajor_CODE       CHAR(4) OUTPUT,
 @Ac_ActivityMinor_CODE       CHAR(5) OUTPUT,
 @Ac_WorkerDelegateTo_ID      CHAR(30) OUTPUT,
 @Ac_TypeActivity_CODE        CHAR(1) OUTPUT,
 @Ad_Schedule_DATE            DATE OUTPUT,
 @Ad_BeginSch_DTTM            DATETIME2 OUTPUT,
 @Ad_EndSch_DTTM              DATETIME2 OUTPUT,
 @Ac_ApptStatus_CODE          CHAR(2) OUTPUT,
 @An_SchPrev_NUMB             NUMERIC(10, 0) OUTPUT,
 @An_SchParent_NUMB           NUMERIC(10, 0) OUTPUT,
 @Ac_ReasonAdjourn_CODE       CHAR(3) OUTPUT,
 @Ac_TypeFamisProceeding_CODE CHAR(5) OUTPUT,
 @Ac_SchedulingUnit_CODE      CHAR(2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S34
  *     DESCRIPTION       : Retrieve Schedule details for a Schedule Number and where Worker Idno cannot be Empty.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_Space_TEXT CHAR(1) = ' ';

  SELECT @An_Case_IDNO = s.Case_IDNO,
         @An_OthpLocation_IDNO = s.OthpLocation_IDNO,
         @Ac_ActivityMajor_CODE = s.ActivityMajor_CODE,
         @Ac_ActivityMinor_CODE = s.ActivityMinor_CODE,
         @Ac_WorkerDelegateTo_ID = s.WorkerDelegateTo_ID,
         @Ac_TypeActivity_CODE = s.TypeActivity_CODE,
         @Ad_Schedule_DATE = s.Schedule_DATE,
         @Ad_BeginSch_DTTM = s.BeginSch_DTTM,
         @Ad_EndSch_DTTM = s.EndSch_DTTM,
         @Ac_ApptStatus_CODE = s.ApptStatus_CODE,
         @An_SchPrev_NUMB = s.SchPrev_NUMB,
         @An_SchParent_NUMB = s.SchParent_NUMB,
         @Ac_ReasonAdjourn_CODE = s.ReasonAdjourn_CODE,
         @Ac_TypeFamisProceeding_CODE = s.TypeFamisProceeding_CODE,
         @Ac_SchedulingUnit_CODE = s.SchedulingUnit_CODE
    FROM SWKS_Y1 s
   WHERE s.Schedule_NUMB = @An_Schedule_NUMB
     AND s.Worker_ID != @Lc_Space_TEXT;
 END; --End of SWKS_RETRIEVE_S34


GO
