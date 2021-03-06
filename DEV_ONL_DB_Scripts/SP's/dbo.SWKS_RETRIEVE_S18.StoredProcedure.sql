/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S18] (
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
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S18                                                                                                                                                                                                                         
  *     DESCRIPTION       : Retrieve Appointment Date and Start time for Appointment for a Case , Location number, Worker  that cannot be Empty, Activity Type, Major and Minor Activity, Schedule Date is between Start Date and End Date, Appointment Status.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                               
  *     DEVELOPED ON      : 31-AUG-2011                                                                                                                                                                                                                              
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
          @Li_MinusOne_NUMB 			 SMALLINT = -1 ,
          @Lc_ActivityMinorAdmin_CODE    CHAR(5) = 'ADMIN',
          @Lc_ActivityMinorPrsnl_CODE    CHAR(5) = 'PRSNL',
          @Lc_ActivityMinorVactn_CODE    CHAR(5) = 'VACTN';

		  
 SELECT K.Schedule_DATE,
 		K.BeginSch_DTTM,
 		COUNT(K.BeginSch_DTTM) AS Schedule_QNTY
   FROM		        
          (SELECT s.Schedule_DATE,
                 s1.SchdTime_DTTM AS BeginSch_DTTM
            FROM SWKS_Y1 s
                 JOIN DMNR_Y1 D
                  ON (s.Case_IDNO = D.Case_IDNO
                      AND s.Schedule_NUMB = D.Schedule_NUMB)
                 JOIN STMS_Y1 S1
                 ON (CAST(S1.SchdTime_DTTM AS TIME(0)) BETWEEN CAST(S.BeginSch_DTTM AS TIME(0)) AND DATEADD(MI,@Li_MinusOne_NUMB,CAST(S.EndSch_DTTM  AS TIME(0))))
                 LEFT OUTER JOIN FDEM_Y1 F
                  ON (F.Case_IDNO = D.Case_IDNO
                      AND F.MajorIntSeq_NUMB = D.MajorIntSeq_NUMB
                      )
           WHERE s.Case_IDNO = ISNULL(@An_Case_IDNO, s.Case_IDNO) 
     		 AND s.OthpLocation_IDNO = ISNULL(@An_OthpLocation_IDNO, s.OthpLocation_IDNO) 
             AND s.Worker_ID = ISNULL (@Ac_Worker_ID, s.Worker_ID)
             AND s.TypeActivity_CODE = ISNULL (@Ac_TypeActivity_CODE, s.TypeActivity_CODE)
             AND s.ActivityMinor_CODE = ISNULL (@Ac_ActivityMinor_CODE, s.ActivityMinor_CODE)
             AND s.ActivityMajor_CODE = ISNULL (@Ac_ActivityMajor_CODE, s.ActivityMajor_CODE)
             AND (@An_Petition_IDNO IS NULL
          			OR F.Petition_IDNO = @An_Petition_IDNO)
             AND s.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorAdmin_CODE, @Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorVactn_CODE)
             AND s.Schedule_DATE BETWEEN @Ad_Start_DATE AND @Ad_End_DATE
             AND s.Worker_ID != @Lc_Space_TEXT
             AND (@Ac_ApptStatus_CODE IS NULL
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusScheduled_CODE
                       AND (s.ApptStatus_CODE IN (@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)))
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusCancelled_CODE
                       AND (s.ApptStatus_CODE IN (@Lc_ApptStatusCanForResch_CODE, @Lc_ApptStatusCancelled_CODE)))
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusConducted_CODE
                       AND s.ApptStatus_CODE = @Lc_ApptStatusConducted_CODE))) AS K
   GROUP BY k.Schedule_DATE,
            k.BeginSch_DTTM
   ORDER BY k.Schedule_DATE,
            k.BeginSch_DTTM;
 END; --END OF SWKS_RETRIEVE_S18                                                                                                                                                                                                                                                                


GO
