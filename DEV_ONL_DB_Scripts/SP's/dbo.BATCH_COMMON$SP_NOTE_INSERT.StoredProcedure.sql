/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_NOTE_INSERT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_NOTE_INSERT
Programmer Name		: IMP Team
Description			: This procedure inserts into the NOTE_Y1 table with given parameters
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_NOTE_INSERT]
 @Ac_Case_IDNO                CHAR(6),
 @An_Topic_IDNO               NUMERIC(10),
 @An_Post_IDNO                NUMERIC(19),
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MinorIntSeq_NUMB         NUMERIC(5),
 @An_Office_IDNO              NUMERIC(3),
 @Ac_Category_CODE            CHAR(2),
 @Ac_Subject_CODE             CHAR(5),
 @Ac_CallBack_INDC            CHAR(1),
 @Ac_NotifySender_INDC        CHAR(1),
 @Ac_TypeContact_CODE         CHAR(3),
 @Ac_SourceContact_CODE       CHAR(2),
 @Ac_MethodContact_CODE       CHAR(2),
 @Ac_Status_CODE              CHAR(1),
 @Ac_TypeAssigned_CODE        CHAR(1),
 @Ac_WorkerAssigned_ID        CHAR(30),
 @Ac_RoleAssigned_ID          CHAR(10),
 @Ac_WorkerCreated_ID         CHAR(30),
 @Ad_Start_DATE               DATE,
 @Ad_Due_DATE                 DATE,
 @Ad_Action_DATE              DATE,
 @Ad_Received_DATE            DATE,
 @Ac_OpenCases_CODE           CHAR(31),
 @As_DescriptionNote_TEXT     VARCHAR(4000),
 @Ad_BeginValidity_DATE       DATE,
 @Ad_EndValidity_DATE         DATE,
 @Ac_WorkerUpdate_ID          CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @An_EventGlobalSeq_NUMB      NUMERIC(19),
 @Ad_Update_DTTM              DATETIME2,
 @An_TotalReplies_QNTY        NUMERIC(10),
 @An_TotalViews_QNTY          NUMERIC(10),
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_COMMON$SP_NOTE_INSERT';
  DECLARE @Ln_RowCount_QNTY     NUMERIC(7),
          @Ln_Error_NUMB        NUMERIC(11),
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Ls_Sql_TEXT          VARCHAR(100) = '',
          @Ls_Sqldata_TEXT      VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT VARCHAR(2000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   SET @Ls_Sql_TEXT = 'INSERT INTO NOTE_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Ac_Case_IDNO,'')+ ', Topic_IDNO = ' + ISNULL(CAST( @An_Topic_IDNO AS VARCHAR ),'')+ ', Post_IDNO = ' + ISNULL(CAST( @An_Post_IDNO AS VARCHAR ),'')+ ', MajorIntSEQ_NUMB = ' + ISNULL(CAST( @An_MajorIntSeq_NUMB AS VARCHAR ),'')+ ', MinorIntSeq_NUMB = ' + ISNULL(CAST( @An_MinorIntSeq_NUMB AS VARCHAR ),'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Category_CODE = ' + ISNULL(@Ac_Category_CODE,'')+ ', Subject_CODE = ' + ISNULL(@Ac_Subject_CODE,'')+ ', CallBack_INDC = ' + ISNULL(@Ac_CallBack_INDC,'')+ ', NotifySender_INDC = ' + ISNULL(@Ac_NotifySender_INDC,'')+ ', TypeContact_CODE = ' + ISNULL(@Ac_TypeContact_CODE,'')+ ', SourceContact_CODE = ' + ISNULL(@Ac_SourceContact_CODE,'')+ ', MethodContact_CODE = ' + ISNULL(@Ac_MethodContact_CODE,'')+ ', Status_CODE = ' + ISNULL(@Ac_Status_CODE,'')+ ', TypeAssigned_CODE = ' + ISNULL(@Ac_TypeAssigned_CODE,'')+ ', WorkerAssigned_ID = ' + ISNULL(@Ac_WorkerAssigned_ID,'')+ ', RoleAssigned_ID = ' + ISNULL(@Ac_RoleAssigned_ID,'')+ ', WorkerCreated_ID = ' + ISNULL(@Ac_WorkerCreated_ID,'')+ ', Start_DATE = ' + ISNULL(CAST( @Ad_Start_DATE AS VARCHAR ),'')+ ', Due_DATE = ' + ISNULL(CAST( @Ad_Due_DATE AS VARCHAR ),'')+ ', Action_DATE = ' + ISNULL(CAST( @Ad_Action_DATE AS VARCHAR ),'')+ ', Received_DATE = ' + ISNULL(CAST( @Ad_Received_DATE AS VARCHAR ),'')+ ', OpenCases_CODE = ' + ISNULL(@Ac_OpenCases_CODE,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_BeginValidity_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ad_EndValidity_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Update_DTTM = ' + ISNULL(CAST( @Ad_Update_DTTM AS VARCHAR ),'')+ ', TotalReplies_QNTY = ' + ISNULL(CAST( @An_TotalReplies_QNTY AS VARCHAR ),'')+ ', TotalViews_QNTY = ' + ISNULL(CAST( @An_TotalViews_QNTY AS VARCHAR ),'');

   INSERT NOTE_Y1
          (Case_IDNO,
           Topic_IDNO,
           Post_IDNO,
           MajorIntSEQ_NUMB,
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
   VALUES ( @Ac_Case_IDNO,--Case_IDNO
            @An_Topic_IDNO,--Topic_IDNO
            @An_Post_IDNO,--Post_IDNO
            @An_MajorIntSeq_NUMB,--MajorIntSEQ_NUMB
            @An_MinorIntSeq_NUMB,--MinorIntSeq_NUMB
            @An_Office_IDNO,--Office_IDNO
            @Ac_Category_CODE,--Category_CODE
            @Ac_Subject_CODE,--Subject_CODE
            @Ac_CallBack_INDC,--CallBack_INDC
            @Ac_NotifySender_INDC,--NotifySender_INDC
            @Ac_TypeContact_CODE,--TypeContact_CODE
            @Ac_SourceContact_CODE,--SourceContact_CODE
            @Ac_MethodContact_CODE,--MethodContact_CODE
            @Ac_Status_CODE,--Status_CODE
            @Ac_TypeAssigned_CODE,--TypeAssigned_CODE
            @Ac_WorkerAssigned_ID,--WorkerAssigned_ID
            @Ac_RoleAssigned_ID,--RoleAssigned_ID
            @Ac_WorkerCreated_ID,--WorkerCreated_ID
            @Ad_Start_DATE,--Start_DATE
            @Ad_Due_DATE,--Due_DATE
            @Ad_Action_DATE,--Action_DATE
            @Ad_Received_DATE,--Received_DATE
            @Ac_OpenCases_CODE,--OpenCases_CODE
            @As_DescriptionNote_TEXT,--DescriptionNote_TEXT
            @Ad_BeginValidity_DATE,--BeginValidity_DATE
            @Ad_EndValidity_DATE,--EndValidity_DATE
            @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
            @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
            @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
            @Ad_Update_DTTM,--Update_DTTM
            @An_TotalReplies_QNTY,--TotalReplies_QNTY
            @An_TotalViews_QNTY); --TotalViews_QNTY
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT NOTE_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END


GO
