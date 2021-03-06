/****** Object:  StoredProcedure [dbo].[CJNR_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CJNR_INSERT_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_OrderSeq_NUMB            NUMERIC(2, 0),
 @An_MajorIntSeq_NUMB         NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB         NUMERIC(5, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ad_Due_DATE                 DATE,
 @Ad_Status_DATE              DATE,
 @Ac_Status_CODE              CHAR(4),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @An_Schedule_NUMB            NUMERIC(10, 0),
 @An_Forum_IDNO               NUMERIC(10, 0),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @Ad_AlertPrior_DATE          DATE,
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_Subsystem_CODE           CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : CJNR_INSERT_S1
  *     DESCRIPTION       : Insert Case Journal Minor Activity details for a Case ID, Sequence Order, Member ID, Minor/Minor Next Activity code, etc.,
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Li_Zero_NUMB           SMALLINT = 0,
          @Lc_Space_TEXT          CHAR(1) = ' ',
          @Ld_Current_DATE        DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_SystemDateTime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT CJNR_Y1
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
  VALUES ( @An_Case_IDNO,--Case_IDNO
           @An_OrderSeq_NUMB,--OrderSeq_NUMB
           @An_MajorIntSeq_NUMB,--MajorIntSeq_NUMB
           @An_MinorIntSeq_NUMB,--MinorIntSeq_NUMB
           @An_MemberMci_IDNO,--MemberMci_IDNO
           @Ac_ActivityMinor_CODE,--ActivityMinor_CODE
           @Lc_Space_TEXT,--ActivityMinorNext_CODE
           @Ld_Current_DATE,--Entered_DATE
           @Ad_Due_DATE,--Due_DATE
           @Ad_Status_DATE,--Status_DATE
           @Ac_Status_CODE,--Status_CODE
           @Ac_ReasonStatus_CODE,--ReasonStatus_CODE
           @An_Schedule_NUMB,--Schedule_NUMB
           @An_Forum_IDNO,--Forum_IDNO
           @An_Topic_IDNO,--Topic_IDNO
           @Li_Zero_NUMB,--TotalReplies_QNTY
           @Li_Zero_NUMB,--TotalViews_QNTY
           @Li_Zero_NUMB,--PostLastPoster_IDNO
           @Ac_SignedOnWorker_ID,--UserLastPoster_ID
           @Ld_SystemDateTime_DTTM,--LastPost_DTTM
           CASE
            WHEN @Ad_AlertPrior_DATE < @Ld_Current_DATE
             THEN @Ld_Current_DATE
            ELSE @Ad_AlertPrior_DATE
           END,--AlertPrior_DATE
           @Ld_Current_DATE,--BeginValidity_DATE
           @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
           @Ld_SystemDateTime_DTTM,--Update_DTTM
           @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
           @Lc_Space_TEXT,--WorkerDelegate_ID
           @Ac_ActivityMajor_CODE,--ActivityMajor_CODE
           @Ac_Subsystem_CODE --Subsystem_CODE
  );
 END; -- End of CJNR_INSERT_S1

GO
