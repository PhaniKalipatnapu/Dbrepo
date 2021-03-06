/****** Object:  View [dbo].[UDMNR_V1]    Script Date: 4/10/2015 3:12:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE VIEW [dbo].[UDMNR_V1]     
AS     
       
   SELECT     
      MinorActivityDiary_T1.Case_IDNO,     
      MinorActivityDiary_T1.OrderSeq_NUMB,     
      MinorActivityDiary_T1.MajorIntSeq_NUMB ,     
      MinorActivityDiary_T1.MinorIntSeq_NUMB ,     
      MinorActivityDiary_T1.MemberMci_IDNO,     
      MinorActivityDiary_T1.ActivityMinor_CODE,     
      MinorActivityDiary_T1.ActivityMinorNext_CODE,     
      MinorActivityDiary_T1.Entered_DATE,     
      MinorActivityDiary_T1.Due_DATE,     
      MinorActivityDiary_T1.Status_DATE,     
      MinorActivityDiary_T1.Status_CODE,     
      MinorActivityDiary_T1.ReasonStatus_CODE,     
      MinorActivityDiary_T1.Schedule_NUMB,     
      MinorActivityDiary_T1.Forum_IDNO,     
      MinorActivityDiary_T1.Topic_IDNO,     
      MinorActivityDiary_T1.TotalReplies_QNTY,     
      MinorActivityDiary_T1.TotalViews_QNTY,     
      MinorActivityDiary_T1.PostLastPoster_IDNO ,     
      MinorActivityDiary_T1.UserLastPoster_ID,     
      MinorActivityDiary_T1.LastPost_DTTM,     
      MinorActivityDiary_T1.AlertPrior_DATE,     
      MinorActivityDiary_T1.BeginValidity_DATE,     
      MinorActivityDiary_T1.WorkerUpdate_ID,     
      MinorActivityDiary_T1.Update_DTTM,     
      MinorActivityDiary_T1.TransactionEventSeq_NUMB ,     
      MinorActivityDiary_T1.WorkerDelegate_ID,     
      MinorActivityDiary_T1.ActivityMajor_CODE,     
      MinorActivityDiary_T1.Subsystem_CODE    
   FROM dbo.MinorActivityDiary_T1  
    UNION ALL    
   SELECT     
      CaseJournalActivity_T1.Case_IDNO,     
      CaseJournalActivity_T1.OrderSeq_NUMB,     
      CaseJournalActivity_T1.MajorIntSeq_NUMB,     
      CaseJournalActivity_T1.MinorIntSeq_NUMB ,     
      CaseJournalActivity_T1.MemberMci_IDNO,     
      CaseJournalActivity_T1.ActivityMinor_CODE,     
      CaseJournalActivity_T1.ActivityMinorNext_CODE,     
      CaseJournalActivity_T1.Entered_DATE,     
      CaseJournalActivity_T1.Due_DATE,     
      CaseJournalActivity_T1.Status_DATE,     
      CaseJournalActivity_T1.Status_CODE,     
      CaseJournalActivity_T1.ReasonStatus_CODE,     
      CaseJournalActivity_T1.Schedule_NUMB,     
      CaseJournalActivity_T1.Forum_IDNO,     
      CaseJournalActivity_T1.Topic_IDNO,     
      CaseJournalActivity_T1.TotalReplies_QNTY,     
      CaseJournalActivity_T1.TotalViews_QNTY,     
      CaseJournalActivity_T1.PostLastPoster_IDNO,     
      CaseJournalActivity_T1.UserLastPoster_ID,     
      CaseJournalActivity_T1.LastPost_DTTM,     
      CaseJournalActivity_T1.AlertPrior_DATE,     
      CaseJournalActivity_T1.BeginValidity_DATE,     
      CaseJournalActivity_T1.WorkerUpdate_ID,     
      CaseJournalActivity_T1.Update_DTTM,     
      CaseJournalActivity_T1.TransactionEventSeq_NUMB ,     
      CaseJournalActivity_T1.WorkerDelegate_ID,     
      CaseJournalActivity_T1.ActivityMajor_CODE,     
      CaseJournalActivity_T1.Subsystem_CODE    
   FROM dbo.CaseJournalActivity_T1 

GO
