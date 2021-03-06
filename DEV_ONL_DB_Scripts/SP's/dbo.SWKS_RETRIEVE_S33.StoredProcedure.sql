/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S33]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S33] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ac_TypeActivity_CODE CHAR(1),
 @Ac_Worker_ID         CHAR(30),
 @Ad_Schedule_DATE     DATE,
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S33
  *     DESCRIPTION       : Retrieve the Row Count of a Schedule Number for a Location Idno, Appointment Date, Activity Type, Appointment Status is Scheduled or Reschedule, and Member Idno cannot be Empty.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Li_Zero_NUMB                  SMALLINT = 0,
          @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC';

  SELECT @Ai_Count_QNTY = COUNT(S.Schedule_NUMB)
    FROM SWKS_Y1 S
   WHERE S.OthpLocation_IDNO = ISNULL(@An_OthpLocation_IDNO, S.OthpLocation_IDNO)
     AND S.Schedule_DATE = @Ad_Schedule_DATE
     AND S.TypeActivity_CODE = ISNULL(@Ac_TypeActivity_CODE, S.TypeActivity_CODE)
     AND S.Worker_ID = ISNULL(@Ac_Worker_ID, S.Worker_ID)
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusScheduled_CODE, @Lc_ApptStatusRescheduled_CODE)
     AND S.MemberMci_IDNO = @Li_Zero_NUMB;
 END --END OF SWKS_RETRIEVE_S33



GO
