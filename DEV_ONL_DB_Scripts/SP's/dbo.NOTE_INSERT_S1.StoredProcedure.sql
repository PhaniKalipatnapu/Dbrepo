/****** Object:  StoredProcedure [dbo].[NOTE_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_INSERT_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @An_Post_IDNO                NUMERIC(19, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_MajorIntSeq_NUMB         NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB         NUMERIC(5, 0),
 @An_Office_IDNO              NUMERIC(3, 0),
 @Ac_Category_CODE            CHAR(2),
 @Ac_Subject_CODE             CHAR(5),
 @Ac_CallBack_INDC            CHAR(1),
 @Ac_NotifySender_INDC        CHAR(1),
 @Ac_TypeContact_CODE         CHAR(2),
 @Ac_SourceContact_CODE       CHAR(2),
 @Ac_MethodContact_CODE       CHAR(2),
 @Ac_Status_CODE              CHAR(1),
 @Ac_TypeAssigned_CODE        CHAR(1),
 @Ac_WorkerAssigned_ID        CHAR(30),
 @Ac_RoleAssigned_ID          CHAR(10),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ad_Due_DATE                 DATE,
 @Ad_Received_DATE            DATE,
 @Ac_OpenCases_CODE           CHAR(31),
 @As_DescriptionNote_TEXT     VARCHAR(4000),
 @An_EventGlobalSeq_NUMB      NUMERIC(19, 0),
 @An_TotalReplies_QNTY        NUMERIC(10, 0),
 @An_TotalViews_QNTY          NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_INSERT_S1
  *     DESCRIPTION       : Insert Notes details with the provided values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_Systemdatetime_DTTM DATETIME2(0) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT NOTE_Y1
         (Case_IDNO,
          Topic_IDNO,
          Post_IDNO,
          TransactionEventSeq_NUMB,
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
          EventGlobalSeq_NUMB,
          Update_DTTM,
          TotalReplies_QNTY,
          TotalViews_QNTY)
  VALUES ( @An_Case_IDNO,
           @An_Topic_IDNO,
           @An_Post_IDNO,
           @An_TransactionEventSeq_NUMB,
           @An_MajorIntSeq_NUMB,
           @An_MinorIntSeq_NUMB,
           @An_Office_IDNO,
           @Ac_Category_CODE,
           @Ac_Subject_CODE,
           @Ac_CallBack_INDC,
           @Ac_NotifySender_INDC,
           @Ac_TypeContact_CODE,
           @Ac_SourceContact_CODE,
           @Ac_MethodContact_CODE,
           @Ac_Status_CODE,
           @Ac_TypeAssigned_CODE,
           @Ac_WorkerAssigned_ID,
           @Ac_RoleAssigned_ID,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @Ad_Due_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ad_Received_DATE,
           @Ac_OpenCases_CODE,
           @As_DescriptionNote_TEXT,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @An_EventGlobalSeq_NUMB,
           @Ld_Systemdatetime_DTTM,
           @An_TotalReplies_QNTY,
           @An_TotalViews_QNTY);
 END; -- End of NOTE_INSERT_S1


GO
