/****** Object:  StoredProcedure [dbo].[DMNR_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_UPDATE_S3] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Status_CODE              CHAR(4),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @An_PostLastPoster_IDNO      NUMERIC(10, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_WorkerDelegate_ID        CHAR(30)
 )
AS
 /*
 *     PROCEDURE NAME    : DMNR_UPDATE_S3
 *     DESCRIPTION       : Update Worker details for a given Case and Minor Activity.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN

  DECLARE @Lc_StatusStart_CODE 		CHAR(4) = 'STRT';

  DECLARE @Ld_Systemdate_DTTM   DATETIME2(0) = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Current_DATE      DATE =		DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);
     

  UPDATE DMNR_Y1
     SET WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         WorkerDelegate_ID = @Ac_WorkerDelegate_ID,
         Update_DTTM = @Ld_Systemdate_DTTM,
         BeginValidity_DATE = @Ld_Current_DATE,
         LastPost_DTTM = @Ld_Systemdate_DTTM,
         PostLastPoster_IDNO = @An_PostLastPoster_IDNO,
         UserLastPoster_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Status_CODE = @Ac_Status_CODE,
         Status_DATE = CASE @Ac_Status_CODE
	         WHEN @Lc_StatusStart_CODE THEN Status_DATE
	         ELSE @Ld_Current_DATE
         END
         
  OUTPUT DELETED.Case_IDNO,
		 DELETED.OrderSeq_NUMB,
		 DELETED.MajorIntSeq_NUMB,
		 DELETED.MinorIntSeq_NUMB,
		 DELETED.MemberMci_IDNO,
		 DELETED.ActivityMinor_CODE,
		 DELETED.ActivityMinorNext_CODE,
		 DELETED.Entered_DATE,
		 DELETED.Due_DATE,
		 DELETED.Status_DATE,
		 DELETED.Status_CODE,
		 DELETED.ReasonStatus_CODE,
		 DELETED.Schedule_NUMB,
		 DELETED.Forum_IDNO,
		 DELETED.Topic_IDNO,
		 DELETED.TotalReplies_QNTY,
		 DELETED.TotalViews_QNTY,
		 DELETED.PostLastPoster_IDNO,
		 DELETED.UserLastPoster_ID,
		 DELETED.LastPost_DTTM,
		 DELETED.AlertPrior_DATE,
		 DELETED.BeginValidity_DATE,
		 @Ld_Current_DATE AS EndValidity_DATE,
		 DELETED.WorkerUpdate_ID,
		 DELETED.Update_DTTM,
		 DELETED.TransactionEventSeq_NUMB,
		 DELETED.WorkerDelegate_ID,
		 DELETED.ActivityMajor_CODE,
         DELETED.Subsystem_CODE
    INTO HDMNR_Y1 
   WHERE Case_IDNO = @An_Case_IDNO
     AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND Topic_IDNO = @An_Topic_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF  DMNR_UPDATE_S3                                 


GO
