/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S15] (
 @An_Case_IDNO                     NUMERIC(6, 0),
 @An_Schedule_NUMB                 NUMERIC(10, 0),
 @An_OthpLocation_IDNO             NUMERIC(9, 0) OUTPUT,
 @Ac_Worker_ID                     CHAR(30) OUTPUT,
 @Ac_TypeActivity_CODE             CHAR(1) OUTPUT,
 @Ad_Schedule_DATE                 DATE OUTPUT,
 @Ad_BeginSch_DTTM                 DATETIME2 OUTPUT,
 @Ac_ApptStatus_CODE               CHAR(2) OUTPUT,
 @An_SchPrev_NUMB                  NUMERIC(10, 0) OUTPUT,
 @Ac_TypeFamisProceeding_CODE      CHAR(5) OUTPUT,
 @Ac_ReasonAdjourn_CODE            CHAR(3) OUTPUT,
 @As_Worker_NAME                   VARCHAR(78) OUTPUT,
 @Ac_TypeOthp_CODE                 CHAR(1) OUTPUT,
 @Ac_SchedulingUnit_CODE           CHAR(2) OUTPUT,
 @Ad_EndSch_DTTM                   DATETIME2 OUTPUT,
 @As_OtherParty_NAME               VARCHAR(60) OUTPUT,
 @Ac_TypeOthpSource_CODE           CHAR(1) OUTPUT,
 @An_MemberMci_IDNO                NUMERIC(10,0) OUTPUT,   
 @An_MajorIntSeq_NUMB              NUMERIC(5, 0) OUTPUT,
 @An_MinorIntSeq_NUMB              NUMERIC(5, 0) OUTPUT,
 @An_Topic_IDNO                    NUMERIC(10, 0) OUTPUT,
 @Ac_Subsystem_CODE                CHAR(2) OUTPUT,
 @Ac_Status_CODE                   CHAR(3) OUTPUT,
 @As_DescriptionActivityMinor_TEXT VARCHAR(75) OUTPUT,
 @An_Petition_IDNO      		   NUMERIC(7, 0) OUTPUT
 )
AS
 /*                                                                                                                                                   
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S15                                                                                                          
  *     DESCRIPTION       : Retrieve the Schedule Event Details for a Location Number and Case , Appointment Number associated with the Minor Activity.
  *     DEVELOPED BY      : IMP Team                                                                                                                
  *     DEVELOPED ON      : 05-SEP-2011                                                                                                               
  *     MODIFIED BY       :                                                                                                                           
  *     MODIFIED ON       :                                                                                                                           
  *     VERSION NO        : 1                                                                                                                         
 */
 BEGIN
  SELECT @Ac_TypeActivity_CODE = NULL,
         @Ac_TypeOthp_CODE = NULL,
         @Ad_Schedule_DATE = NULL,
         @An_Topic_IDNO = NULL,
         @An_SchPrev_NUMB = NULL,
         @Ac_TypeOthpSource_CODE=NULL,
         @An_MemberMci_IDNO=NULL,
         @An_MajorIntSeq_NUMB = NULL,
         @An_MinorIntSeq_NUMB = NULL,
         @Ac_ApptStatus_CODE = NULL,
         @Ac_ReasonAdjourn_CODE = NULL,
         @Ac_Subsystem_CODE = NULL,
         @Ac_TypeFamisProceeding_CODE = NULL,
         @As_DescriptionActivityMinor_TEXT = NULL,
         @An_OthpLocation_IDNO = NULL,
         @Ac_Worker_ID = NULL,
         @As_Worker_NAME = NULL,
         @Ad_BeginSch_DTTM = NULL,
         @Ac_Status_CODE = NULL,
         @As_OtherParty_NAME = NULL,
         @Ac_SchedulingUnit_CODE = NULL,
         @Ad_EndSch_DTTM = NULL,
         @An_Petition_IDNO = NULL;

  DECLARE @Lc_Space_TEXT     CHAR(1) = ' ',
          @Ld_High_DATE      DATE = '12/31/9999',
          @Li_MinusOne_NUMB  SMALLINT = -1;

  SELECT TOP 1 @As_DescriptionActivityMinor_TEXT = (SELECT A1.DescriptionActivity_TEXT
                                                      FROM AMNR_Y1 A1
                                                     WHERE A1.ActivityMinor_CODE = a.ActivityMinor_CODE
                                                       AND A1.EndValidity_DATE = @Ld_High_DATE),
               @Ac_Worker_ID = a.Worker_ID,
               @As_Worker_NAME = a.Worker_NAME,
               @An_OthpLocation_IDNO = a.OthpLocation_IDNO,
               @Ac_TypeOthp_CODE = a.TypeOthp_CODE,
               @As_OtherParty_NAME = a.OtherParty_NAME,
               @Ad_Schedule_DATE = a.Schedule_DATE,
               @Ad_BeginSch_DTTM = a.BeginSch_DTTM,
               @Ac_ApptStatus_CODE = a.ApptStatus_CODE,
               @Ac_TypeActivity_CODE = a.TypeActivity_CODE,
               @An_SchPrev_NUMB = a.SchPrev_NUMB,
               @An_Topic_IDNO = a.Topic_IDNO,
               @Ac_TypeOthpSource_CODE =a.TypeOthpSource_CODE,
               @An_MemberMci_IDNO =a.MemberMci_IDNO,
               @An_MajorIntSeq_NUMB = a.MajorIntSeq_NUMB,
               @An_MinorIntSeq_NUMB = a.MinorIntSeq_NUMB,
               @Ac_TypeFamisProceeding_CODE = a.TypeFamisProceeding_CODE,
               @Ac_ReasonAdjourn_CODE = a.ReasonAdjourn_CODE,
               @Ac_Status_CODE = a.Status_CODE,
               @Ac_Subsystem_CODE = a.Subsystem_CODE,
               @Ac_SchedulingUnit_CODE = a.SchedulingUnit_CODE,
               @Ad_EndSch_DTTM = a.EndSch_DTTM,
               @An_Petition_IDNO = ISNULL(a.Petition_IDNO,@Li_MinusOne_NUMB)
    FROM (SELECT a.ActivityMinor_CODE,
                 a.Worker_ID,
                 a.Worker_NAME,
                 a.OthpLocation_IDNO,
                 o.TypeOthp_CODE,
                 (SELECT O1.OtherParty_NAME
                   FROM OTHP_Y1 O1
                   WHERE O1.OtherParty_IDNO =a.OthpLocation_IDNO
                    AND O1.TransactionEventSeq_NUMB =(SELECT MAX(O.TransactionEventSeq_NUMB)
                                                        FROM OTHP_Y1 O
                                                       WHERE O.OtherParty_IDNO =a.OthpLocation_IDNO)) AS OtherParty_NAME,
                 a.Schedule_DATE,
                 a.BeginSch_DTTM,
                 a.ApptStatus_CODE,
                 a.TypeActivity_CODE,
                 a.SchPrev_NUMB,
                 m.Topic_IDNO,
                 (SELECT D.TypeOthpSource_CODE
                   FROM DMJR_Y1 D
                  WHERE D.Case_IDNO =a.Case_IDNO
                  AND D.MajorIntSeq_NUMB = m.MajorIntSeq_NUMB) AS TypeOthpSource_CODE,
                 (SELECT D.MemberMci_IDNO
                   FROM DMJR_Y1 D
                  WHERE D.Case_IDNO =a.Case_IDNO
                  AND D.MajorIntSeq_NUMB = m.MajorIntSeq_NUMB) AS MemberMci_IDNO,
                 m.MajorIntSeq_NUMB,
                 m.MinorIntSeq_NUMB,
                 a.TypeFamisProceeding_CODE,
                 a.ReasonAdjourn_CODE,
                 m.Status_CODE,
                 m.Subsystem_CODE,
                 a.SchedulingUnit_CODE,
                 a.EndSch_DTTM,
                 f.Petition_IDNO,
                 ROW_NUMBER() OVER( ORDER BY o.EndValidity_DATE DESC) AS ORD_ROWNUM
            FROM SWKS_Y1 a
                 LEFT OUTER JOIN OTHP_Y1 o
                  ON (a.OthpLocation_IDNO = o.OtherParty_IDNO)
                 JOIN DMNR_Y1 m
                  ON (m.Schedule_NUMB = a.Schedule_NUMB
                      AND m.Case_IDNO = a.Case_IDNO)
                 LEFT OUTER JOIN FDEM_Y1 F
		          ON (F.Case_IDNO = m.Case_IDNO
		              AND F.MajorIntSeq_NUMB=m.MajorIntSeq_NUMB)      
           WHERE a.Schedule_NUMB = @An_Schedule_NUMB
             AND a.Worker_ID != @Lc_Space_TEXT
             AND m.Case_IDNO = @An_Case_IDNO) AS a;
 END; --END OF SWKS_RETRIEVE_S15                                                                                                                                                 

GO
