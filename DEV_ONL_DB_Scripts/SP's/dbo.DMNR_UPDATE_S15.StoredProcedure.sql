/****** Object:  StoredProcedure [dbo].[DMNR_UPDATE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_UPDATE_S15] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Schedule_NUMB            NUMERIC(10, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*                                                                                                                                                                                                                                                                                                                                                                    
  *     PROCEDURE NAME    : DMNR_UPDATE_S15                                                                                                                                                                                                                                                                                                                           
  *     DESCRIPTION       : Update the Date on which the Minor Activity has actually been updated and Begin Validity Date and Updated Date to Today, Current Status of the Minor Activity to Completed, Reason for updating the Current Minor Activity to System Closed, Worker Idno, and Transaction Sequence Event for a Sequence Number and Case Idno of the Member.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                                                                                                                 
  *     DEVELOPED ON      : 01-SEP-2011                                                                                                                                                                                                                                                                                                                             
  *     MODIFIED BY       :                                                                                                                                                                                                                                                                                                                                            
  *     MODIFIED ON       :                                                                                                                                                                                                                                                                                                                                            
  *     VERSION NO        : 1                                                                                                                                                                                                                                                                                                                                          
 */
 BEGIN
  DECLARE @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_StatusComplete_CODE CHAR(4)='COMP',
          @Lc_ReasonstatusSy_CODE CHAR(2) ='SY',
          @Ln_RowsAffected_NUMB   NUMERIC(10);

  UPDATE DMNR_Y1
     SET Status_DATE = @Ld_Current_DATE,
         Status_CODE = @Lc_StatusComplete_CODE,
         ReasonStatus_CODE = @Lc_ReasonstatusSy_CODE,
         BeginValidity_DATE = @Ld_Current_DATE,
         Update_DTTM = @Ld_Current_DATE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
  OUTPUT Deleted.Case_IDNO,
         Deleted.OrderSeq_NUMB,
         Deleted.MajorIntSeq_NUMB,
         Deleted.MinorIntSeq_NUMB,
         Deleted.MemberMci_IDNO,
         Deleted.ActivityMinor_CODE,
         Deleted.ActivityMinorNext_CODE,
         Deleted.Entered_DATE,
         Deleted.Due_DATE,
         Deleted.Status_DATE,
         Deleted.Status_CODE,
         Deleted.ReasonStatus_CODE,
         Deleted.Schedule_NUMB,
         Deleted.Forum_IDNO,
         Deleted.Topic_IDNO,
         Deleted.TotalReplies_QNTY,
         Deleted.TotalViews_QNTY,
         Deleted.PostLastPoster_IDNO,
         Deleted.UserLastPoster_ID,
         Deleted.LastPost_DTTM,
         Deleted.AlertPrior_DATE,
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         Deleted.WorkerUpdate_ID,
         Deleted.Update_DTTM,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.WorkerDelegate_ID,
         Deleted.ActivityMajor_CODE,
         Deleted.Subsystem_CODE
    INTO HDMNR_Y1
   WHERE Schedule_NUMB = @An_Schedule_NUMB
     AND Case_IDNO = @An_Case_IDNO;

  SET @Ln_RowsAffected_NUMB=@@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF DMNR_UPDATE_S15



GO
