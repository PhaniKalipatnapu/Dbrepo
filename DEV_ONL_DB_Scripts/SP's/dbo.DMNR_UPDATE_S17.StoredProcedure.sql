/****** Object:  StoredProcedure [dbo].[DMNR_UPDATE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_UPDATE_S17] (
 @An_MajorIntSeq_NUMB				NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB				NUMERIC(5, 0),
 @An_OrderSeq_NUMB					NUMERIC(2, 0),
 @An_Case_IDNO						NUMERIC(6, 0),
 @An_TransactionEventSeq_NUMB		NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB	NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID				CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_UPDATE_S17
  *     DESCRIPTION       : Update the Worker Delegate for a given Case, Major Int Seq, Minor Int Seq and Order seq
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
		  @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Update_DTTM       DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();          

  UPDATE DMNR_Y1
     SET WorkerDelegate_ID = @Ac_SignedOnWorker_ID,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         BeginValidity_DATE = @Ld_Current_DATE,
         Update_DTTM = @Ld_Update_DTTM,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
         
  OUTPUT  DELETED.Case_IDNO,
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
     AND OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END;


GO
