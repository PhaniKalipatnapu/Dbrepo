/****** Object:  StoredProcedure [dbo].[DMNR_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_INSERT_S2] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MinorIntSeq_NUMB         NUMERIC(5),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ad_Due_DATE                 DATE,
 @Ad_Status_DATE              DATE,
 @Ac_Status_CODE              CHAR(4),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @An_Schedule_NUMB            NUMERIC(10),
 @An_Forum_IDNO               NUMERIC(10),
 @An_Topic_IDNO               NUMERIC(10),
 @Ad_AlertPrior_DATE          DATE,
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerDelegate_ID        CHAR(30),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_Subsystem_CODE           CHAR(2),
 @An_PostLastPoster_IDNO      NUMERIC(10)
 )
AS
 /*                                                                                                                                                                                                     
  *     PROCEDURE NAME    : DMNR_INSERT_S2                                                                                                                                                               
  *     DESCRIPTION       : Insert Minor Activity Diary details like Case ID, Sequence Order, Minor Activity code, Next Minor Activity code, Forum ID, Topic ID, Minor Activity Sequence number, etc.,  
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                   
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                                                 
  *     MODIFIED BY       :                                                                                                                                                                             
  *     MODIFIED ON       :                                                                                                                                                                             
  *     VERSION NO        : 1                                                                                                                                                                           
 */
 BEGIN
  DECLARE @Li_Zero_NUMB           SMALLINT = 0,
          @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Current_DATE        DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT DMNR_Y1
         (Case_IDNO,
          OrderSeq_NUMB,
          MajorIntSeq_NUMB,
          MinorIntSeq_NUMB,
          MemberMci_IDNO,
          ActivityMinor_CODE,
          ActivityMinorNext_CODE,
          Entered_DATE,
          Due_DATE,
          Status_DATE,
          Status_CODE,
          ReasonStatus_CODE,
          Schedule_NUMB,
          Forum_IDNO,
          Topic_IDNO,
          TotalReplies_QNTY,
          TotalViews_QNTY,
          PostLastPoster_IDNO,
          UserLastPoster_ID,
          LastPost_DTTM,
          AlertPrior_DATE,
          BeginValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          WorkerDelegate_ID,
          ActivityMajor_CODE,
          Subsystem_CODE)
  VALUES ( @An_Case_IDNO,
           @An_OrderSeq_NUMB,
           @An_MajorIntSeq_NUMB,
           @An_MinorIntSeq_NUMB,
           @An_MemberMci_IDNO,
           @Ac_ActivityMinor_CODE,
           @Ac_ActivityMinorNext_CODE,
           @Ld_Current_DATE,
           @Ad_Due_DATE,
           @Ad_Status_DATE,
           @Ac_Status_CODE,
           @Ac_ReasonStatus_CODE,
           @An_Schedule_NUMB,
           @An_Forum_IDNO,
           @An_Topic_IDNO,
           @Li_Zero_NUMB,
           @Li_Zero_NUMB,
           @An_PostLastPoster_IDNO,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           CASE
            WHEN @Ad_AlertPrior_DATE < @Ld_Current_DATE
             THEN @Ld_Current_DATE
            ELSE @Ad_AlertPrior_DATE
           END,
           @Ld_Current_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB,
           @Ac_WorkerDelegate_ID,
           @Ac_ActivityMajor_CODE,
           @Ac_Subsystem_CODE);
 END


GO
