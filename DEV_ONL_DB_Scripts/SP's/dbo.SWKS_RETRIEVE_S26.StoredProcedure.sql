/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S26] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_OthpLocation_IDNO  NUMERIC(9, 0),
 @Ac_Worker_ID          CHAR(30),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ac_TypeActivity_CODE  CHAR(1),
 @Ac_ApptStatus_CODE    CHAR(2),
 @Ad_Start_DATE         DATE,
 @Ad_End_DATE           DATE,
 @An_Petition_IDNO      NUMERIC(7, 0),
 @Ac_File_ID            CHAR(10)
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S26
  *     DESCRIPTION       : Retrieve Monthly Schedule details for a Case Idno, Location Idno, Worker Idno, Activity Type, Major and Minor Activity, Schedule Date and Appointment Status. 
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
          @Lc_ActivityMinorAdmin_CODE    CHAR(5) = 'ADMIN',
          @Lc_ActivityMinorPrsnl_CODE    CHAR(5) = 'PRSNL',
          @Lc_ActivityMinorVactn_CODE    CHAR(5) = 'VACTN',
          @Li_MinusOne_NUMB              SMALLINT =-1,
          @Li_Zero_NUMB                  SMALLINT =0,
          @Ld_High_DATE                  DATE ='12/31/9999',
          @Li_Five_NUMB                  SMALLINT = 5;
          
          
  SELECT S.TypeActivity_CODE,
         S.ApptStatus_CODE,
         S.Schedule_DATE,
         S.BeginSch_DTTM,
         S.OthpLocation_IDNO,
         (SELECT OtherParty_NAME
	        FROM OTHP_Y1 O
	        WHERE O.OtherParty_IDNO = S.OthpLocation_IDNO
	        AND O.TransactionEventSeq_NUMB = (SELECT MAX(O1.TransactionEventSeq_NUMB)
                                                 FROM OTHP_Y1 O1
                                               WHERE O1.OtherParty_IDNO = S.OthpLocation_IDNO)) AS OtherParty_NAME,
         S.Case_IDNO,
         ISNULL(S.File_ID,(SELECT TOP 1 f.File_ID   
						    FROM FDEM_Y1 f  
						    WHERE f.Case_IDNO        = s.Case_IDNO  
						     AND ( (f.Petition_IDNO <> @Li_Zero_NUMB)   
						       OR EXISTS ( SELECT 1   
								        FROM DCKT_Y1 A  
								       WHERE A.File_ID=f.File_ID  
								         AND f.Petition_IDNO =@Li_Zero_NUMB ))   
						      AND f.EndValidity_DATE = @Ld_High_DATE)) AS File_ID,
         ISNULL(S.Petition_IDNO,@Li_MinusOne_NUMB)  AS Petition_IDNO,
         S.ActivityMajor_CODE,
         (SELECT A.DescriptionActivity_TEXT
            FROM AMNR_Y1 A
           WHERE A.ActivityMinor_CODE = S.ActivityMinor_CODE
             AND A.EndValidity_DATE = @Ld_High_DATE) AS DescriptionActivity_TEXT,
         DBO.BATCH_COMMON$SF_GET_MEMBERS(S.Schedule_NUMB, S.Case_IDNO) AS Members_TEXT,
         S.Worker_ID,
         S.BeginValidity_DATE,
         S.SchedulingUnit_CODE,
         S.EndSch_DTTM
    FROM (SELECT K.Schedule_DATE,
                 K.BeginSch_DTTM,
                 K.ActivityMinor_CODE,
                 K.ActivityMajor_CODE,
                 K.Case_IDNO,
                 K.Worker_ID,
                 K.Schedule_NUMB,
                 K.OthpLocation_IDNO,
                 K.Petition_IDNO,
                 K.File_ID,
                 K.ApptStatus_CODE,
                 K.TypeActivity_CODE,
                 K.BeginValidity_DATE,
                 K.SchedulingUnit_CODE,
                 K.EndSch_DTTM,
                 ROW_NUMBER() OVER(PARTITION BY K.Schedule_DATE ORDER BY K.BeginSch_DTTM, K.Schedule_NUMB) AS Rownum_NUMB
            FROM (SELECT S.Schedule_DATE,
                         S.BeginSch_DTTM,
                         S.ActivityMinor_CODE,
                         S.ActivityMajor_CODE,
                         S.Case_IDNO,
                         S.Worker_ID,
                         S.Schedule_NUMB,
                         S.OthpLocation_IDNO,
                         F.Petition_IDNO,
                         F.File_ID,
                         S.ApptStatus_CODE,
                         S.TypeActivity_CODE,
                         S.BeginValidity_DATE,
                         S.SchedulingUnit_CODE,
                         S.EndSch_DTTM
                    FROM SWKS_Y1 S
                         JOIN DMNR_Y1 D
                          ON (s.Case_IDNO = D.Case_IDNO
                              AND s.Schedule_NUMB = D. Schedule_NUMB)
                         LEFT OUTER JOIN FDEM_Y1 F
                          ON (F.Case_IDNO = D.Case_IDNO
                              AND F. MajorIntSeq_NUMB = D. MajorIntSeq_NUMB
                              )
                   WHERE s.Case_IDNO = ISNULL(@An_Case_IDNO, s.Case_IDNO) 
     				 AND s.OthpLocation_IDNO = ISNULL(@An_OthpLocation_IDNO, s.OthpLocation_IDNO) 
                     AND S.Worker_ID = ISNULL(@Ac_Worker_ID, S.Worker_ID)
                     AND S.TypeActivity_CODE = ISNULL(@Ac_TypeActivity_CODE, S.TypeActivity_CODE)
                     AND S.ActivityMinor_CODE = ISNULL(@Ac_ActivityMinor_CODE, S.ActivityMinor_CODE)
                     AND S.ActivityMajor_CODE = ISNULL(@Ac_ActivityMajor_CODE, S.ActivityMajor_CODE)
                     AND S.Schedule_DATE BETWEEN @Ad_Start_DATE AND @Ad_End_DATE
                     AND S.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorAdmin_CODE, @Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorVactn_CODE)
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
														   ON (F.Case_IDNO=D.Case_IDNO
															   AND F. MajorIntSeq_NUMB = D. MajorIntSeq_NUMB)
														  WHERE  S.CASE_IDNO=  @An_Case_IDNO) OR (F.File_ID=@Ac_File_ID)))
                     AND S.Worker_ID != @Lc_Space_TEXT
                     AND (@Ac_ApptStatus_CODE IS NULL
                           OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusScheduled_CODE
                               AND (S.ApptStatus_CODE IN(@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)))
                           OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusCancelled_CODE
                               AND (S.ApptStatus_CODE IN(@Lc_ApptStatusCanForResch_CODE, @Lc_ApptStatusCancelled_CODE)))
                           OR (@Ac_ApptStatus_CODE = @Lc_ApptStatusConducted_CODE
                               AND S.ApptStatus_CODE = @Lc_ApptStatusConducted_CODE))) AS K) AS S
   WHERE S.Rownum_NUMB < @Li_Five_NUMB
   ORDER BY S.Schedule_DATE,
            S.BeginSch_DTTM,
            S.Schedule_NUMB;
 END; --END OF SWKS_RETRIEVE_S26



GO
