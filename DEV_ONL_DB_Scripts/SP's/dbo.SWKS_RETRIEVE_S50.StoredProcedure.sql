/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S50]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S50] (
 @Ac_Worker_ID     CHAR(30),
 @Ad_Schedule_DATE DATE,
 @Ad_BeginSch_DTTM DATETIME2,
 @Ad_EndSch_DTTM   DATETIME2,
 @Ai_Count_QNTY    INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S50
  *     DESCRIPTION       : Returns the no of count if any record exists for the given Schedule date and worker_id with given time
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
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
     AND S.Worker_ID = @Ac_Worker_ID
     AND (S.BeginSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM
          OR S.EndSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM
          OR @Ad_BeginSch_DTTM BETWEEN S.BeginSch_DTTM AND S.EndSch_DTTM
          OR @Ad_EndSch_DTTM BETWEEN S.BeginSch_DTTM AND S.EndSch_DTTM)
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusScheduled_CODE, @Lc_ApptStatusRescheduled_CODE);
     
 END; -- END OF SWKS_RETRIEVE_S50






GO
