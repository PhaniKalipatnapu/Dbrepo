/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S17] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_OthpLocation_IDNO  NUMERIC(9, 0),
 @Ac_Worker_ID          CHAR(30),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ac_TypeActivity_CODE  CHAR(1),
 @Ac_ApptStatus_CODE    CHAR(2),
 @Ad_Schedule_DATE      DATE,
 @An_Petition_IDNO      NUMERIC(7, 0),
 @Ac_File_ID            CHAR(10)
 )
AS
 /*                                                                                                                                                                                                       
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S17                                                                                                                                                              
  *     DESCRIPTION       : Retrieve Schedule details for a Case , Location Number, Worker  that cannot be Empty, Activity Type, Major and Minor Activity, Appointment Date, and Appointment Status.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                    
  *     DEVELOPED ON      : 07-SEP-2011                                                                                                                                                                   
  *     MODIFIED BY       :                                                                                                                                                                               
  *     MODIFIED ON       :                                                                                                                                                                               
  *     VERSION NO        : 1                                                                                                                                                                             
 */
 BEGIN
  DECLARE @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_Empty_TEXT                 CHAR (1) = '',
          @Lc_ApptStatusCancelled_CODE   CHAR(2) = 'CN',
          @Lc_ApptStatusCanForResch_CODE CHAR(2) = 'CR',
          @Lc_ApptStatusConducted_CODE   CHAR(2) = 'CD',
          @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC',
          @Ld_High_DATE                  DATE = '12/31/9999',
          @Li_MinusOne_NUMB              SMALLINT =-1,
          @Li_Zero_NUMB                  SMALLINT =0,
          @Lc_ActivityMinorAdmin_CODE    CHAR(5)='ADMIN',
          @Lc_ActivityMinorPrsnl_CODE    CHAR(5)='PRSNL',
          @Lc_ActivityMinorVactn_CODE    CHAR(5)='VACTN';
          

  SELECT s.ApptStatus_CODE,
         s.TypeActivity_CODE,
         s.Schedule_DATE AS Schedule_DATE,
         s.BeginSch_DTTM,
         s.OthpLocation_IDNO,
         (SELECT OtherParty_NAME
            FROM OTHP_Y1 O
           WHERE O.OtherParty_IDNO = s.OthpLocation_IDNO
             AND O.TransactionEventSeq_NUMB = (SELECT MAX(O1.TransactionEventSeq_NUMB)
                                                 FROM OTHP_Y1 O1
                                               WHERE O1.OtherParty_IDNO = s.OthpLocation_IDNO)) AS OtherParty_NAME,
         s.Case_IDNO AS Case_IDNO,
         ISNULL(F.File_ID,(SELECT TOP 1 f.File_ID   
						    FROM FDEM_Y1 f  
						    WHERE f.Case_IDNO        = s.Case_IDNO  
						     AND ( (f.Petition_IDNO <> @Li_Zero_NUMB)   
						       OR EXISTS ( SELECT 1   
								        FROM DCKT_Y1 A  
								       WHERE A.File_ID=f.File_ID  
								         AND f.Petition_IDNO =@Li_Zero_NUMB ))   
						      AND f.EndValidity_DATE = @Ld_High_DATE)) AS File_ID,
          ISNULL(F.Petition_IDNO,@Li_MinusOne_NUMB) AS Petition_IDNO,
         s.ActivityMajor_CODE AS ActivityMajor_CODE,
         (SELECT A.DescriptionActivity_TEXT
            FROM AMNR_Y1 A
           WHERE A.ActivityMinor_CODE = s.ActivityMinor_CODE
             AND A.EndValidity_DATE = @Ld_High_DATE) AS DescriptionActivity_TEXT,
         dbo.BATCH_COMMON$SF_GET_MEMBERS(s.Schedule_NUMB, s.Case_IDNO) AS Members_TEXT,
         s.Worker_ID,
         s.ActivityMinor_CODE AS ActivityMinor_CODE,
         s.Schedule_NUMB AS Schedule_NUMB,
         s.TransactionEventSeq_NUMB,
         s.BeginValidity_DATE,
         s.SchedulingUnit_CODE,
         s.EndSch_DTTM
    FROM SWKS_Y1 s
         JOIN DMNR_Y1 D
          ON (s.Case_IDNO = D.Case_IDNO
              AND s.Schedule_NUMB = D. Schedule_NUMB)
         LEFT OUTER JOIN FDEM_Y1 F
          ON (F.Case_IDNO = D.Case_IDNO
              AND F. MajorIntSeq_NUMB = D. MajorIntSeq_NUMB)
   WHERE s.Case_IDNO = ISNULL(@An_Case_IDNO, s.Case_IDNO)
     AND s.OthpLocation_IDNO = ISNULL(@An_OthpLocation_IDNO, s.OthpLocation_IDNO)
     AND s.Worker_ID = ISNULL (@Ac_Worker_ID, s.Worker_ID)
     AND s.TypeActivity_CODE = ISNULL (@Ac_TypeActivity_CODE, s.TypeActivity_CODE)
     AND s.ActivityMinor_CODE = ISNULL (@Ac_ActivityMinor_CODE, s.ActivityMinor_CODE)
     AND s.ActivityMajor_CODE = ISNULL (@Ac_ActivityMajor_CODE, s.ActivityMajor_CODE)
     AND s.Schedule_DATE = @Ad_Schedule_DATE
     AND s.Worker_ID != @Lc_Space_TEXT
     AND s.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorAdmin_CODE, @Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorVactn_CODE)
     AND (@An_Petition_IDNO IS NULL
         OR
           F.Petition_IDNO =@An_Petition_IDNO)
     AND (@Ac_File_ID IS NULL
          OR
          (s.ActivityMajor_CODE NOT IN (SELECT S.ActivityMajor_CODE 
										 FROM SWKS_Y1 S 
										  JOIN
										  DMNR_Y1 D
										   ON (S.Case_IDNO=D.Case_IDNO
											 AND s.Schedule_NUMB = D. Schedule_NUMB)
										   JOIN
										  FDEM_Y1 F
										   ON ( F.Case_IDNO=D.Case_IDNO
											   AND F. MajorIntSeq_NUMB = D. MajorIntSeq_NUMB)
										  WHERE  S.CASE_IDNO=  @An_Case_IDNO) OR (F.File_ID=@Ac_File_ID)))
     AND (@Ac_ApptStatus_CODE IS NULL
           OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusScheduled_CODE
               AND (s.ApptStatus_CODE IN (@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)))
           OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusCancelled_CODE
               AND (s.ApptStatus_CODE IN (@Lc_ApptStatusCanForResch_CODE, @Lc_ApptStatusCancelled_CODE)))
           OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusConducted_CODE
               AND s.ApptStatus_CODE = @Lc_ApptStatusConducted_CODE))
   ORDER BY BeginSch_DTTM,
            Schedule_NUMB;
 END; --END OF SWKS_RETRIEVE_S17                                                                                                                                                                                                      



GO
