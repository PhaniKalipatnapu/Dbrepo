/****** Object:  StoredProcedure [dbo].[DMNR_UPDATE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_UPDATE_S7] (
 @An_Case_IDNO                   NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB            NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB            NUMERIC(5, 0),
 @Ac_SignedOnWorker_ID           CHAR(30),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_UPDATE_S7
  *     DESCRIPTION       : Update Begin Validity date to system date, worker ID who created/modified the record, Date-Time to System Date-Time and Unique Sequence Number for a Case ID, Major & Minor Sequence and Unique Sequence Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
  DECLARE @Ld_Systemdate_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DMNR_Y1
     SET BeginValidity_DATE = @Ld_Systemdate_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         Update_DTTM = @Ld_Systemdate_DTTM,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
         
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
		 @Ld_Systemdate_DTTM AS EndValidity_DATE,
		 DELETED.WorkerUpdate_ID,
		 DELETED.Update_DTTM,
		 DELETED.TransactionEventSeq_NUMB,
		 DELETED.WorkerDelegate_ID,
		 DELETED.ActivityMajor_CODE,
         DELETED.Subsystem_CODE
    INTO HDMNR_Y1 
   WHERE Case_IDNO = @An_Case_IDNO
     AND MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of DMNR_UPDATE_S7   


GO
