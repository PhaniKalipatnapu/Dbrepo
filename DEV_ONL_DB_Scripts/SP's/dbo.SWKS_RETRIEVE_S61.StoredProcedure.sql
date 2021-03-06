/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S61]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S61] (
  
 @An_MemberMci_IDNO     NUMERIC(10),
 @An_SchPrev_NUMB		NUMERIC(10),
 @Ad_Schedule_DATE      DATE,
 @Ad_BeginSch_DTTM      DATETIME2,
 @Ad_EndSch_DTTM        DATETIME2,
 @Ac_Worker_ID          CHAR(30),
 @An_OthpLocation_IDNO  NUMERIC(9),
 @Ac_Exists_INDC        CHAR(1) OUTPUT
 )
 AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S61
  *     DESCRIPTION       : It is check whether Scheduling already exists for given date and schedule worker and same or different location.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-JUN-2012
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */

BEGIN
  DECLARE
	   @Lc_No_TEXT	CHAR(1)	= 'N',
	   @Lc_Yes_TEXT	CHAR(1)	= 'Y',
	   @Lc_ScheduleStatusSc_CODE	CHAR(2) = 'SC';

   SET @Ac_Exists_INDC = @Lc_No_TEXT;

		SELECT  @Ac_Exists_INDC=@Lc_Yes_TEXT
		   FROM SWKS_Y1 S1
		   WHERE S1.MemberMci_IDNO=@An_MemberMci_IDNO
		   AND S1.Schedule_NUMB != @An_SchPrev_NUMB
		   AND S1.Schedule_DATE=@Ad_Schedule_DATE
		   AND (S1.BeginSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM
				  OR S1.EndSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM
				  OR @Ad_BeginSch_DTTM BETWEEN S1.BeginSch_DTTM AND S1.EndSch_DTTM
				  OR @Ad_EndSch_DTTM BETWEEN S1.BeginSch_DTTM AND S1.EndSch_DTTM)
		   AND S1.ApptStatus_CODE =@Lc_ScheduleStatusSc_CODE
		   AND EXISTS ( SELECT 1 
						 FROM SWKS_Y1 S2
						 WHERE S2.CASE_IDNO=S1.CASE_IDNO
						  AND S2.Schedule_DATE=S1.Schedule_DATE 
						  AND S2.BeginSch_DTTM=S1.BeginSch_DTTM
						  AND S2.EndSch_DTTM=S1.EndSch_DTTM
						  AND (S2.Worker_ID<>@Ac_Worker_ID  
						       OR S2.Worker_ID = @Ac_Worker_ID)
						  AND (S2.OthpLocation_IDNO<>@An_OthpLocation_IDNO
						       OR S2.OthpLocation_IDNO=@An_OthpLocation_IDNO )) 
						  

END ; -- END OF SWKS_RETRIEVE_S61
GO
