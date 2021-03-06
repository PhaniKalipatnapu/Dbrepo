/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S4] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_Post_IDNO                NUMERIC(19, 0) OUTPUT,
 @An_MajorIntSeq_NUMB         NUMERIC(5, 0) OUTPUT,
 @An_MinorIntSeq_NUMB         NUMERIC(5, 0) OUTPUT,
 @An_Office_IDNO              NUMERIC(3, 0) OUTPUT,
 @Ac_Category_CODE            CHAR(2) OUTPUT,
 @Ac_Subject_CODE             CHAR(5) OUTPUT,
 @Ac_CallBack_INDC            CHAR(1) OUTPUT,
 @Ac_NotifySender_INDC        CHAR(1) OUTPUT,
 @Ac_TypeContact_CODE         CHAR(2) OUTPUT,
 @Ac_SourceContact_CODE       CHAR(2) OUTPUT,
 @Ac_MethodContact_CODE       CHAR(2) OUTPUT,
 @Ac_Status_CODE              CHAR(1) OUTPUT,
 @Ac_TypeAssigned_CODE        CHAR(1) OUTPUT,
 @Ac_WorkerAssigned_ID        CHAR(30) OUTPUT,
 @Ac_RoleAssigned_ID          CHAR(10) OUTPUT,
 @Ac_WorkerCreated_ID         CHAR(30) OUTPUT,
 @Ad_Start_DATE               DATE OUTPUT,
 @Ad_Due_DATE                 DATE OUTPUT,
 @Ad_Action_DATE              DATE OUTPUT,
 @Ad_Received_DATE            DATE OUTPUT,
 @Ac_OpenCases_CODE           CHAR(31) OUTPUT,
 @As_DescriptionNote_TEXT     VARCHAR(4000) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @An_EventGlobalSeq_NUMB      NUMERIC(19, 0) OUTPUT,
 @An_TotalReplies_QNTY        NUMERIC(10, 0) OUTPUT,
 @An_TotalViews_QNTY          NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S4
  *     DESCRIPTION       : Retrieve Note details for a given case topic. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Category_CODE = NULL,
         @Ac_MethodContact_CODE = NULL,
         @An_Office_IDNO = NULL,
         @Ac_OpenCases_CODE = NULL,
         @Ac_SourceContact_CODE = NULL,
         @Ac_Status_CODE = NULL,
         @Ac_Subject_CODE = NULL,
         @Ac_TypeAssigned_CODE = NULL,
         @Ac_TypeContact_CODE = NULL,
         @As_DescriptionNote_TEXT = NULL,
         @Ad_Action_DATE = NULL,
         @Ad_Due_DATE = NULL,
         @Ad_Received_DATE = NULL,
         @Ad_Start_DATE = NULL,
         @An_Post_IDNO = NULL,
         @Ac_RoleAssigned_ID = NULL,
         @Ac_WorkerAssigned_ID = NULL,
         @Ac_WorkerCreated_ID = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ac_CallBack_INDC = NULL,
         @Ac_NotifySender_INDC = NULL,
         @An_TotalReplies_QNTY = NULL,
         @An_TotalViews_QNTY = NULL,
         @An_EventGlobalSeq_NUMB = NULL,
         @An_MajorIntSeq_NUMB = NULL,
         @An_MinorIntSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_Post_IDNO = A.Post_IDNO,
         @An_MajorIntSeq_NUMB = A.MajorIntSeq_NUMB,
         @An_MinorIntSeq_NUMB = A.MinorIntSeq_NUMB,
         @An_Office_IDNO = A.Office_IDNO,
         @Ac_Category_CODE = A.Category_CODE,
         @Ac_Subject_CODE = A.Subject_CODE,
         @Ac_CallBack_INDC = A.CallBack_INDC,
         @Ac_NotifySender_INDC = A.NotifySender_INDC,
         @Ac_TypeContact_CODE = A.TypeContact_CODE,
         @Ac_SourceContact_CODE = A.SourceContact_CODE,
         @Ac_MethodContact_CODE = A.MethodContact_CODE,
         @Ac_Status_CODE = A.Status_CODE,
         @Ac_TypeAssigned_CODE = A.TypeAssigned_CODE,
         @Ac_WorkerAssigned_ID = A.WorkerAssigned_ID,
         @Ac_RoleAssigned_ID = A.RoleAssigned_ID,
         @Ac_WorkerCreated_ID = A.WorkerCreated_ID,
         @Ad_Start_DATE = A.Start_DATE,
         @Ad_Due_DATE = A.Due_DATE,
         @Ad_Action_DATE = A.Action_DATE,
         @Ad_Received_DATE = A.Received_DATE,
         @Ac_OpenCases_CODE = A.OpenCases_CODE,
         @As_DescriptionNote_TEXT = A.DescriptionNote_TEXT,
         @Ac_WorkerUpdate_ID = A.WorkerUpdate_ID,
         @An_EventGlobalSeq_NUMB = A.EventGlobalSeq_NUMB,
         @An_TotalReplies_QNTY = A.TotalReplies_QNTY,
         @An_TotalViews_QNTY = A.TotalViews_QNTY
    FROM NOTE_Y1 A
         JOIN (SELECT MAX (B.Post_IDNO) AS Post_IDNO
                 FROM NOTE_Y1 B
                WHERE B.Case_IDNO = @An_Case_IDNO
                  AND B.Topic_IDNO = @An_Topic_IDNO) C
          ON A.Post_IDNO = C.Post_IDNO
   WHERE A.Case_IDNO = @An_Case_IDNO
     AND A.Topic_IDNO = @An_Topic_IDNO
     AND A.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of NOTE_RETRIEVE_S4


GO
