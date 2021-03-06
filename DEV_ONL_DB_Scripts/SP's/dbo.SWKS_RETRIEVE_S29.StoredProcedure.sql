/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S29] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_OthpLocation_IDNO  NUMERIC(9, 0),
 @Ac_Worker_ID          CHAR(30),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ac_TypeActivity_CODE  CHAR(1),
 @Ac_ApptStatus_CODE    CHAR(2),
 @Ad_Start_DATE         DATE,
 @Ad_End_DATE           DATE,
 @An_Petition_IDNO      NUMERIC(7, 0)
 )
AS
 /*                                                                                                                                                                                                                                                     
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S29                                                                                                                                                                                                            
  *     DESCRIPTION       : Retrieve Appointment Date and Session Type for a Worker Idno that cannot be Empty, Case Idno, Location Idno, Activity Type, Major and Minor Activity, Schedule Date between Start Date and End Date, and Appointment Status.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                 
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                                                                                                 
  *     MODIFIED BY       :                                                                                                                                                                                                                             
  *     MODIFIED ON       :                                                                                                                                                                                                                             
  *     VERSION NO        : 1                                                                                                                                                                                                                           
 */
 BEGIN
  DECLARE @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_AmSession_CODE             CHAR(2) = 'AM',
          @Lc_ApptStatusCancelled_CODE   CHAR(2) = 'CN',
          @Lc_ApptStatusCanForResch_CODE CHAR(2) = 'CR',
          @Lc_ApptStatusConducted_CODE   CHAR(2) = 'CD',
          @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC',
          @Lc_ActivityMinorAdmin_CODE    CHAR(5) = 'ADMIN',
          @Lc_ActivityMinorPrsnl_CODE    CHAR(5) = 'PRSNL',
          @Lc_ActivityMinorVactn_CODE    CHAR(5) = 'VACTN',
          @Lc_SessionPm_CODE             CHAR(2) = 'PM';

  SELECT K.Schedule_DATE,
         SUM (CASE K.type_session
               WHEN @Lc_AmSession_CODE
                THEN 1
               ELSE 0
              END) AS AmApptCount_QNTY,
         SUM (CASE K.type_session
               WHEN @Lc_SessionPm_CODE
                THEN 1
               ELSE 0
              END) AS PmApptCount_QNTY
    FROM (SELECT S.Schedule_DATE,
                 RIGHT(CONVERT(VARCHAR, CONVERT(DATETIME2, S.BeginSch_DTTM ), 100),2) AS type_session
            FROM SWKS_Y1 S
                 JOIN DMNR_Y1 D
		          ON (s.Case_IDNO = D.Case_IDNO
		              AND s.Schedule_NUMB = D. Schedule_NUMB)
		         LEFT OUTER JOIN FDEM_Y1 F
		          ON (F.Case_IDNO = D.Case_IDNO
		              AND F. MajorIntSeq_NUMB = D. MajorIntSeq_NUMB
		             )
           WHERE S.Worker_ID != @Lc_Space_TEXT
             AND s.Case_IDNO = ISNULL(@An_Case_IDNO, s.Case_IDNO) 
     		 AND s.OthpLocation_IDNO = ISNULL(@An_OthpLocation_IDNO, s.OthpLocation_IDNO)
             AND S.Worker_ID = ISNULL(@Ac_Worker_ID, S.Worker_ID)
             AND S.TypeActivity_CODE = ISNULL(@Ac_TypeActivity_CODE, S.TypeActivity_CODE)
             AND S.ActivityMinor_CODE = ISNULL(@Ac_ActivityMinor_CODE, S.ActivityMinor_CODE)
             AND S.ActivityMajor_CODE = ISNULL(@Ac_ActivityMajor_CODE, S.ActivityMajor_CODE)
             AND S.Schedule_DATE BETWEEN @Ad_Start_DATE AND @Ad_End_DATE
             AND S.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorAdmin_CODE, @Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorVactn_CODE)
             AND (@An_Petition_IDNO IS NULL
                  OR F.Petition_IDNO = @An_Petition_IDNO)
             AND (@Ac_ApptStatus_CODE IS NULL
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusScheduled_CODE
                       AND (S.ApptStatus_CODE IN (@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)))
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusCancelled_CODE
                       AND (S.ApptStatus_CODE IN (@Lc_ApptStatusCanForResch_CODE, @Lc_ApptStatusCancelled_CODE)))
                   OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusConducted_CODE
                       AND S.ApptStatus_CODE = @Lc_ApptStatusConducted_CODE))) AS K
   GROUP BY K.Schedule_DATE
   ORDER BY K.Schedule_DATE;
 END; --END OF SWKS_RETRIEVE_S29                                                                                                                                                                                                                                                    


GO
