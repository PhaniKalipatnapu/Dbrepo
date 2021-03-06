/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S57]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S57] (
 @Ad_Schedule_DATE  DATE,
 @Ac_Worker_ID		CHAR(30),
 @Ad_BeginSch_DTTM  DATETIME2,
 @Ad_EndSch_DTTM    DATETIME2,
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S57
  *     DESCRIPTION       : Retrieve the Row Count for schedule_DATE which is in scheduled and rescheduled status other than the activity minor code 'ADMIN','PRSNL' and 'VACTN'
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_ApptStatusRescheduled_CODE  CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE    CHAR(2) = 'SC',
          @Lc_ActivityMinorAdmin_CODE  CHAR(5) = 'ADMIN',  
    	  @Lc_ActivityMinorPrsnl_CODE  CHAR(5) = 'PRSNL',  
    	  @Lc_ActivityMinorVacation_CODE  CHAR(5) = 'VACTN';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SWKS_Y1 S
   WHERE 
   	 S.Schedule_DATE = @Ad_Schedule_DATE
   	 AND S.Worker_ID = @Ac_Worker_ID
     AND (@Ad_BeginSch_DTTM BETWEEN S.BeginSch_DTTM AND S.EndSch_DTTM
          OR @Ad_EndSch_DTTM BETWEEN S.BeginSch_DTTM AND S.EndSch_DTTM
          OR S.BeginSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM
          OR S.EndSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM) 
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)
     AND S.ActivityMinor_CODE NOT IN(@Lc_ActivityMinorAdmin_CODE,@Lc_ActivityMinorPrsnl_CODE,@Lc_ActivityMinorVacation_CODE);


 END; --END OF SWKS_RETRIEVE_S57
 



GO
