/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S19] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_OthpLocation_IDNO  NUMERIC(9, 0),
 @Ac_Worker_ID          CHAR(30),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ac_TypeActivity_CODE  CHAR(1),
 @Ac_ApptStatus_CODE    CHAR(2),
 @An_Petition_IDNO      NUMERIC(7, 0),
 @Ad_Start_DATE         DATE,
 @Ad_End_DATE           DATE
 )
AS
 /*                                                                                                                                                                                                                                                                                                                                                          
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S19                                                                                                                                                                                                                                                                                                                 
  *     DESCRIPTION       : Retrieve the Appointment Date and Record Count of the Appointment Date for a Case , Location Number, Worker  that cannot be Empty, Activity Type, Major and Minor Activity, Schedule Date is between Start Date and End Date, Appointment Status. If Output's record count is 0 then modify Message Code and return Output.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                                                                                                       
  *     DEVELOPED ON      : 01-SEP-2011                                                                                                                                                                                                                                                                                                                      
  *     MODIFIED BY       :                                                                                                                                                                                                                                                                                                                                  
  *     MODIFIED ON       :                                                                                                                                                                                                                                                                                                                                  
  *     VERSION NO        : 1                                                                                                                                                                                                                                                                                                                                
 */
 BEGIN
  DECLARE @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_ApptStatusCancelled_CODE   CHAR(2) = 'CN',
          @Lc_ApptStatusCanForResch_CODE CHAR(2) = 'CR',
          @Lc_ApptStatusConducted_CODE   CHAR(2) = 'CD',
          @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC',
          @Lc_ActivityMinorADMIN_CODE    CHAR(4) = 'ADMIN',
          @Lc_ActivityMinorPRSNL_CODE    CHAR(4) = 'PRSNL',
          @Lc_ActivityMinorVACTN_CODE    CHAR(4) = 'VACTN';

  SELECT S.Schedule_DATE AS Schedule_DATE,
         COUNT(S.Schedule_DATE) AS Schedule_QNTY
    FROM (SELECT S.Schedule_DATE
            FROM SWKS_Y1 S
                 JOIN DMNR_Y1 D
                  ON (s.Case_IDNO = D.Case_IDNO
                      AND s.Schedule_NUMB = D.Schedule_NUMB)
                 LEFT OUTER JOIN FDEM_Y1 F
                  ON (F.Case_IDNO = D.Case_IDNO
                      AND F.MajorIntSeq_NUMB = D.MajorIntSeq_NUMB
                      )
           WHERE s.Case_IDNO = ISNULL(@An_Case_IDNO, s.Case_IDNO) 
     		 AND s.OthpLocation_IDNO = ISNULL(@An_OthpLocation_IDNO, s.OthpLocation_IDNO) 
             AND S.Worker_ID = ISNULL (@Ac_Worker_ID, S.Worker_ID)
             AND S.TypeActivity_CODE = ISNULL (@Ac_TypeActivity_CODE, S.TypeActivity_CODE)
             AND S.ActivityMinor_CODE = ISNULL (@Ac_ActivityMinor_CODE, S.ActivityMinor_CODE)
             AND S.ActivityMajor_CODE = ISNULL (@Ac_ActivityMajor_CODE, S.ActivityMajor_CODE)
             AND S.Schedule_DATE BETWEEN @Ad_Start_DATE AND @Ad_End_DATE
             AND S.Worker_ID != @Lc_Space_TEXT
             AND S.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorADMIN_CODE, @Lc_ActivityMinorPRSNL_CODE, @Lc_ActivityMinorVACTN_CODE)
             AND (@An_Petition_IDNO IS NULL
          		  OR F.Petition_IDNO = @An_Petition_IDNO)
             AND (@Ac_ApptStatus_CODE IS NULL
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusScheduled_CODE
                       AND (S.ApptStatus_CODE IN(@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)))
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusCancelled_CODE
                       AND (S.ApptStatus_CODE IN(@Lc_ApptStatusCanForResch_CODE, @Lc_ApptStatusCancelled_CODE)))
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusConducted_CODE
                       AND S.ApptStatus_CODE = @Lc_ApptStatusConducted_CODE))) AS S
   GROUP BY S.Schedule_DATE
   ORDER BY S.Schedule_DATE;
 END; --END OF SWKS_RETRIEVE_S19                                                                                                                                                                                                                                                                                                                                                         


GO
