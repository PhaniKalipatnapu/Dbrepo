/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S16] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @An_Schedule_NUMB     NUMERIC(10, 0),
 @Ac_Worker_ID         CHAR(30),
 @Ad_Schedule_DATE     DATE,
 @Ad_BeginSch_DTTM     DATETIME2,
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S16
  *     DESCRIPTION       : Retrieve the Row Count for an Appointment Date, Location Number and  Schedule number, Worker Idno, Start time for Appointment, and Appointment Status is Scheduled or Rescheduled.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 27-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SWKS_Y1 S
   WHERE S.Schedule_DATE = @Ad_Schedule_DATE
     AND S.BeginSch_DTTM = @Ad_BeginSch_DTTM
     AND S.OthpLocation_IDNO = @An_OthpLocation_IDNO
     AND S.Schedule_NUMB = @An_Schedule_NUMB
     AND S.Worker_ID = @Ac_Worker_ID
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusScheduled_CODE, @Lc_ApptStatusRescheduled_CODE);
 END; --END OF  SWKS_RETRIEVE_S16



GO
