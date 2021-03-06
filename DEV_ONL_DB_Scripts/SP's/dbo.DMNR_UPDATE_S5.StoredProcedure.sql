/****** Object:  StoredProcedure [dbo].[DMNR_UPDATE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_UPDATE_S5] (
 @An_Case_IDNO                NUMERIC(6),
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ad_Status_DATE              DATE,
 @Ac_Status_CODE              CHAR(4),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*  
 *     PROCEDURE NAME    : DMNR_UPDATE_S5  
  *     DESCRIPTION       : Update the Worker details for a Case Idno, Order sequence, Major and Minor Int sequence, and Transaction sequence.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 09-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
  DECLARE @Lc_StatusStart_CODE CHAR(4) = 'STRT',
          @Ld_Systemdate_DTTM  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DMNR_Y1
     SET ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE,
         Status_DATE = @Ad_Status_DATE,
         Status_CODE = @Ac_Status_CODE,
         ReasonStatus_CODE = @Ac_ReasonStatus_CODE,
         BeginValidity_DATE = @Ld_Systemdate_DTTM,
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
     AND Status_CODE = @Lc_StatusStart_CODE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of DMNR_UPDATE_S5   


GO
