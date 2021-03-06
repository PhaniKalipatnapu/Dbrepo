/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S56]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S56]
(
	@An_Case_IDNO 		    	  NUMERIC(6,0),
	@An_Schedule_NUMB       	  NUMERIC(10,0),
	@Ad_Schedule_DATE       	  DATE OUTPUT,
    @Ad_BeginSch_DTTM       	  DATETIME2 OUTPUT,
    @Ad_EndSch_DTTM         	  DATETIME2 OUTPUT,
    @An_OthpLocation_IDNO         NUMERIC(9, 0) OUTPUT,
    @As_OtherParty_NAME           VARCHAR(60) OUTPUT,
    @Ac_ScheduleWorker_ID         CHAR(30) OUTPUT,
    @Ac_CaseWorker_ID             CHAR(30) OUTPUT,
    @As_ScheduleWorkerContact_EML VARCHAR(100) OUTPUT,
    @As_CaseWorkerContact_EML     VARCHAR(100) OUTPUT,
    @Ac_ActivityMinor_CODE        CHAR(5) OUTPUT,
    @As_Members_TEXT              VARCHAR(200) OUTPUT 
)
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S56
  *     DESCRIPTION       : Retrieve the schedule date and beginschedule and Endschedule date time,othplocation details. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN
   DECLARE
       @Lc_Space_TEXT     CHAR(1) =' ',
       @Ld_High_DATE      DATE ='12/31/9999';
   DECLARE
       @Ld_Current_DATE	  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
       
   SELECT @Ad_Schedule_DATE       	      = NULL, 
          @Ad_BeginSch_DTTM       	      = NULL,
          @Ad_EndSch_DTTM         	      = NULL,
          @An_OthpLocation_IDNO           = NULL,
          @As_OtherParty_NAME             = NULL,
          @Ac_ScheduleWorker_ID           = NULL,
          @Ac_CaseWorker_ID               = NULL,
          @As_ScheduleWorkerContact_EML   = NULL,
          @As_CaseWorkerContact_EML       = NULL,
          @Ac_ActivityMinor_CODE          = NULL,
          @As_Members_TEXT                = NULL;
      
       
	SELECT @Ad_Schedule_DATE = S.Schedule_DATE, 
	       @Ad_BeginSch_DTTM = S.BeginSch_DTTM, 
	       @Ad_EndSch_DTTM = S.EndSch_DTTM, 
	       @An_OthpLocation_IDNO = S.OthpLocation_IDNO,
	       @As_OtherParty_NAME = (SELECT OtherParty_NAME
							        FROM OTHP_Y1 O
							        WHERE O.OtherParty_IDNO = S.OthpLocation_IDNO
							        AND O.EndValidity_DATE =@Ld_High_DATE),
	       @Ac_ScheduleWorker_ID = S.Worker_ID,
	       @Ac_CaseWorker_ID = C.Worker_ID,
	       @As_ScheduleWorkerContact_EML = Y.Contact_EML,
	       @As_CaseWorkerContact_EML = U.Contact_EML,
	       @Ac_ActivityMinor_CODE = D.ActivityMinor_CODE ,
	       @As_Members_TEXT = DBO.BATCH_COMMON$SF_GET_MEMBERS(S.Schedule_NUMB, S.Case_IDNO)
	FROM SWKS_Y1 S
	     JOIN DMNR_Y1 D
			ON S.Schedule_NUMB = D.Schedule_NUMB
			 AND S.Case_IDNO = D.Case_IDNO
	     JOIN CASE_Y1 C
			ON C.Case_IDNO = S.Case_IDNO
	     JOIN USEM_Y1 U
			ON U.Worker_ID = C.Worker_ID
	       AND @Ld_Current_DATE BETWEEN U.BeginEmployment_DATE AND U.EndEmployment_DATE
	       AND U.EndValidity_DATE=@Ld_High_DATE
	     JOIN USEM_Y1 Y
			ON Y.Worker_ID = S.Worker_ID
	       AND @Ld_Current_DATE BETWEEN Y.BeginEmployment_DATE AND Y.EndEmployment_DATE
	       AND Y.EndValidity_DATE=@Ld_High_DATE
	WHERE S.Schedule_NUMB = @An_Schedule_NUMB    
	  AND S.Case_IDNO = @An_Case_IDNO
	  AND S.Worker_ID != @Lc_Space_TEXT; 
		
	
END; --END OF SWKS_RETRIEVE_S56


GO
