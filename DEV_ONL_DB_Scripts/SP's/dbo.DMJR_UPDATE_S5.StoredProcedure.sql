/****** Object:  StoredProcedure [dbo].[DMJR_UPDATE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_UPDATE_S5] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_MajorIntSeq_NUMB         NUMERIC(5, 0),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @Ac_Status_CODE              CHAR(4)
 )
AS
 /*  
 *     PROCEDURE NAME    : DMJR_UPDATE_S5  
  *     DESCRIPTION       : Update Start & End Exemption date, Begining Validity to System date, Worker ID, Effective date-time at which record was inserted/modified and Unique Sequence Number for a Case ID, Remedy Status is Exemption, Activity Major Code 
 							and Start & End Exemption date is between System date..  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
  DECLARE @Lc_ActivityMajorCase_CODE CHAR(4) = 'CASE',
          @Lc_StatusStart_CODE       CHAR(4) = 'STRT',
          @Ld_Systemdate_DTTM        DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DMJR_Y1
     SET Status_DATE = @Ld_Systemdate_DTTM,
         Status_CODE = @Ac_Status_CODE,
         ReasonStatus_CODE = @Ac_ReasonStatus_CODE,
         UserLastPoster_ID = @Ac_SignedOnWorker_ID,
         LastPost_DTTM = @Ld_Systemdate_DTTM,
         BeginValidity_DATE = @Ld_Systemdate_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         Update_DTTM = @Ld_Systemdate_DTTM,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
  OUTPUT Deleted.Case_IDNO,
         Deleted.OrderSeq_NUMB,
         Deleted.MajorIntSeq_NUMB,
         Deleted.MemberMci_IDNO,
         Deleted.ActivityMajor_CODE,
         Deleted.Subsystem_CODE,
         Deleted.TypeOthpSource_CODE,
         Deleted.OthpSource_IDNO,
         Deleted.Entered_DATE,
         Deleted.Status_DATE,
         Deleted.Status_CODE,
         Deleted.ReasonStatus_CODE,
         Deleted.BeginExempt_DATE,
         Deleted.EndExempt_DATE,
         Deleted.Forum_IDNO,
         Deleted.TotalTopics_QNTY,
         Deleted.PostLastPoster_IDNO,
         Deleted.UserLastPoster_ID,
         Deleted.SubjectLastPoster_TEXT,
         Deleted.LastPost_DTTM,
         Deleted.BeginValidity_DATE,
         @Ld_Systemdate_DTTM AS EndValidity_DATE,
         Deleted.WorkerUpdate_ID,
         Deleted.Update_DTTM,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.TypeReference_CODE,
         Deleted.Reference_ID
    INTO HDMJR_Y1 
   WHERE Case_IDNO = @An_Case_IDNO
     AND MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND Status_CODE = @Lc_StatusStart_CODE
     AND ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End Of DMJR_UPDATE_S5


GO
