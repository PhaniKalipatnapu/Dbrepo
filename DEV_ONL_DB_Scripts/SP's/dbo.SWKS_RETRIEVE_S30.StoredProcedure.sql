/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S30] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_Schedule_NUMB  NUMERIC(10, 0),
 @An_MemberMci_IDNO NUMERIC(10,0),
 @Ad_Schedule_DATE  DATE,
 @Ad_BeginSch_DTTM  DATETIME2,
 @Ad_EndSch_DTTM    DATETIME2,
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S30
  *     DESCRIPTION       : Retrieve the Row Count for a Case Idno, Appointment Date, Start time of Appointment, Application Status is Scheduled or Rescheduled
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE
          @Lc_ApptStatusRescheduled_CODE  CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE    CHAR(2) = 'SC';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SWKS_Y1 S
   WHERE S.Case_IDNO = @An_Case_IDNO
     AND S.Schedule_DATE = @Ad_Schedule_DATE
     AND (@Ad_BeginSch_DTTM BETWEEN S.BeginSch_DTTM AND S.EndSch_DTTM
          OR @Ad_EndSch_DTTM BETWEEN S.BeginSch_DTTM AND S.EndSch_DTTM
          OR S.BeginSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM
          OR S.EndSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM) 
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)
     AND S.Schedule_NUMB != @An_Schedule_NUMB
     AND S.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; --END OF SWKS_RETRIEVE_S30


GO
