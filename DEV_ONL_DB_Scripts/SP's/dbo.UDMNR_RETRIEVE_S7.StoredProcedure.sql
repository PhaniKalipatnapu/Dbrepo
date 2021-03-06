/****** Object:  StoredProcedure [dbo].[UDMNR_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDMNR_RETRIEVE_S7] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @An_Topic_IDNO NUMERIC(10, 0)
 )
AS
 /*        
  *     PROCEDURE NAME    : UDMNR_RETRIEVE_S7        
  *     DESCRIPTION       : Retrieve Post ID, Number of total replies/views, Appointment number, etc., from Minor Activity Diary, Schedule and Notes for a Case ID and Topic ID.        
  *     DEVELOPED BY      : IMP Team        
  *     DEVELOPED ON      : 18-AUG-2011        
  *     MODIFIED BY       :         
  *     MODIFIED ON       :         
  *     VERSION NO        : 1        
 */
 BEGIN
  DECLARE @Lc_ActivityMinorNteup_CODE CHAR(5) = 'NTEUP',
		  @Ld_High_DATE               DATE = '12/31/9999';
          
  SELECT a.ActivityMinor_CODE,
         a.Schedule_NUMB,
         a.Forum_IDNO,
         a.Topic_IDNO,
         a.TotalReplies_QNTY,
         a.TotalViews_QNTY,
         ISNULL(b.WorkerUpdate_ID,a.UserLastPoster_ID) UserLastPoster_ID,
         ISNULL(b.Update_DTTM, a.LastPost_DTTM) LastPost_DTTM,
         b.Post_IDNO,
         b.WorkerUpdate_ID,
         (SELECT c.DescriptionActivity_TEXT
            FROM AMNR_Y1 c
           WHERE c.ActivityMinor_CODE = a.ActivityMinor_CODE
             AND c.EndValidity_DATE = @Ld_High_DATE)AS DescriptionActivity_TEXT,
         dbo.BATCH_COMMON$SF_GET_UNCHECKED_FORMS(@An_Topic_IDNO, a.MemberMci_IDNO, a.Case_IDNO, a.ActivityMajor_CODE) AS DescriptionUnCheckedNotices_TEXT,
         dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(b.DescriptionNote_TEXT) AS DescriptionNote_TEXT,
         (SELECT TOP 1 s.ApptStatus_CODE
            FROM SWKS_Y1 s
           WHERE s.Schedule_NUMB = a.Schedule_NUMB) ApptStatus_CODE
    FROM UDMNR_V1 a
    LEFT JOIN NOTE_Y1 b
      ON b.Case_IDNO = a.Case_IDNO
     AND b.Topic_IDNO = a.Topic_IDNO
     AND b.EndValidity_DATE = @Ld_High_DATE
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.Topic_IDNO = @An_Topic_IDNO
     AND a.ActivityMinor_CODE != @Lc_ActivityMinorNteup_CODE
   ORDER BY b.Post_IDNO ASC;
 END; --END OF UDMNR_RETRIEVE_S7        



GO
