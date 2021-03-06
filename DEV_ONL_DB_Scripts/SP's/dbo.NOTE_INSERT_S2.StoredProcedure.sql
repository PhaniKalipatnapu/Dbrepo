/****** Object:  StoredProcedure [dbo].[NOTE_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_INSERT_S2] (
 @An_Case_IDNO                NUMERIC(6),
 @An_Topic_IDNO               NUMERIC(10),
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MinorIntSeq_NUMB         NUMERIC(5),
 @Ac_Category_CODE            CHAR(2),
 @Ac_Subject_CODE             CHAR(5),
 @As_DescriptionNote_TEXT     VARCHAR(4000),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ad_Start_DATE               DATE,
 @Ad_Due_DATE                 DATE,
 @Ad_Action_DATE              DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*
 *      PROCEDURE NAME    : NOTE_INSERT_S2
  *     DESCRIPTION       : Insert Notes details with the provided values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : Sep-02-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Current_DATE        DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999',
          @Lc_Space_TEXT          CHAR(1) = ' ',
          @Lc_NotifySenderNo_INDC CHAR(1) = 'N',
          @Li_Zero_NUMB           SMALLINT = 0,
          @Li_One_NUMB            SMALLINT = 1;

  INSERT NOTE_Y1
         (Case_IDNO,
          Topic_IDNO,
          Post_IDNO,
          MajorIntSeq_NUMB,
          MinorIntSeq_NUMB,
          Office_IDNO,
          Category_CODE,
          Subject_CODE,
          CallBack_INDC,
          NotifySender_INDC,
          TypeContact_CODE,
          SourceContact_CODE,
          MethodContact_CODE,
          Status_CODE,
          TypeAssigned_CODE,
          WorkerAssigned_ID,
          RoleAssigned_ID,
          WorkerCreated_ID,
          Start_DATE,
          Due_DATE,
          Action_DATE,
          Received_DATE,
          OpenCases_CODE,
          DescriptionNote_TEXT,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          EventGlobalSeq_NUMB,
          Update_DTTM,
          TotalReplies_QNTY,
          TotalViews_QNTY)
  VALUES ( @An_Case_IDNO,--Case_IDNO
           @An_Topic_IDNO,--Topic_IDNO
           @Li_One_NUMB,--Post_IDNO
           @An_MajorIntSeq_NUMB,--MajorIntSeq_NUMB
           @An_MinorIntSeq_NUMB,--MinorIntSeq_NUMB
           @Li_Zero_NUMB,--Office_IDNO
           @Ac_Category_CODE,--Category_CODE
           @Ac_Subject_CODE,--Subject_CODE
           @Lc_Space_TEXT,--CallBack_INDC
           @Lc_NotifySenderNo_INDC,--NotifySender_INDC
           @Lc_Space_TEXT,--TypeContact_CODE
           @Lc_Space_TEXT,--SourceContact_CODE
           @Lc_Space_TEXT,--MethodContact_CODE
           @Lc_Space_TEXT,--Status_CODE
           @Lc_Space_TEXT,--TypeAssigned_CODE
           @Lc_Space_TEXT,--WorkerAssigned_ID
           @Lc_Space_TEXT,--RoleAssigned_ID
           @Ac_SignedOnWorker_ID,--WorkerCreated_ID
           @Ad_Start_DATE,--Start_DATE
           @Ad_Due_DATE,--Due_DATE
           @Ad_Action_DATE,--Action_DATE
           @Ld_High_DATE,--Received_DATE
           @Lc_Space_TEXT,--OpenCases_CODE
           @As_DescriptionNote_TEXT,--DescriptionNote_TEXT
           @Ld_Current_DATE,--BeginValidity_DATE
           @Ld_High_DATE,--EndValidity_DATE
           @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
           @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
           @Li_Zero_NUMB,--EventGlobalSeq_NUMB
           @Ld_Systemdatetime_DTTM,--Update_DTTM
           @Li_Zero_NUMB,--TotalReplies_QNTY
           @Li_Zero_NUMB); --TotalViews_QNTY
 END


GO
