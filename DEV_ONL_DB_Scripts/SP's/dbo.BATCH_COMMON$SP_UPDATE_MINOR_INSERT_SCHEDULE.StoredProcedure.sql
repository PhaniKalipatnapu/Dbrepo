/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-----------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE
Programmer Name		: IMP Team
Description			: This process updates the DMNR_Y1 table with the reason selected by the
					   BATCH_COMMON$SF_GET_REASON PROCEDURE and inserts the next activity and also generates
					   notices defined for the next activity
Frequency			: 
Developed On		: 04/12/2011
Called By			: BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_PETITION_REQUEST
Called On			: BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY, BATCH_COMMON$SP_INSERT_SCHEDULE and BATCH_COMMON$SP_INSERT_ACTIVITY
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE]
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_Forum_IDNO               NUMERIC(10),
 @An_Topic_IDNO               NUMERIC(10) = 0,
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MinorIntSeq_NUMB         NUMERIC(5),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATETIME2,
 @As_Process_ID               VARCHAR(100),
 @As_DescriptionNote_TEXT     VARCHAR(4000),
 @An_OthpLocation_IDNO        NUMERIC(9) = 0,
 @Ac_WorkerDelegateTo_ID      CHAR(30) = ' ',
 @Ac_TypeActivity_CODE        CHAR(1),
 @Ad_Schedule_DATE            DATE,
 @Ad_BeginSch_DTTM            DATETIME2,
 @Ad_EndSch_DTTM              DATETIME2,
 @Ac_ApptStatus_CODE          CHAR(2),
 @An_SchParent_NUMB           NUMERIC(10) = 0,
 @An_SchPrev_NUMB             NUMERIC(10) = 0,
 @Ac_ProceedingType_CODE      CHAR(5) = ' ',
 @Ac_ReasonAdjourn_CODE       CHAR(3) = ' ',
 @As_Worker_NAME              VARCHAR(78) = ' ',
 @Ac_SchedulingUnit_CODE      CHAR(2) = ' ',
 @Ac_ScheduleWorker_ID        CHAR(30) = NULL,
 @As_Schedule_MemberMci_IDNO  VARCHAR(400),
 @Ac_Msg_CODE                 CHAR (5) OUTPUT,
 @An_Schedule_NUMB            NUMERIC(10) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFail_CODE     CHAR(1) = 'F',
           @Lc_Space_TEXT          CHAR(1) = ' ',
           @Ls_Procedure_NAME      VARCHAR(100) = 'SP_UPDATE_MINOR_INSERT_SCHEDULE',
           @Ls_ErrorMessage_TEXT   VARCHAR(4000) = ' ';
  DECLARE  @Ln_Rowcount_QNTY   NUMERIC(6),
           @Ln_Schedule_NUMB   NUMERIC(10),
           @Ln_Error_NUMB      NUMERIC(10),
           @Ln_ErrorLine_NUMB  NUMERIC(11),
           @Ln_Topic_IDNO      NUMERIC(11) = 0,
           @Ls_Sql_TEXT        VARCHAR(200),
           @Ls_Sqldata_TEXT    VARCHAR(400);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   SET @Ls_Sql_TEXT = 'DELETE FROM IdentSeqSwks_T1';
   SET @Ls_Sqldata_TEXT = '';
   
   BEGIN TRANSACTION
   DELETE FROM IdentSeqSwks_T1;
   
   SET @Ls_Sql_TEXT = 'INSERT INTO IdentSeqSwks_T1';
   SET @Ls_Sqldata_TEXT = '';   
   INSERT INTO IdentSeqSwks_T1
         (Entered_DATE)
        VALUES (DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() -- Entered_DATE
        );

   SET @Ls_Sql_TEXT = 'ASSIGN SEQUNECE NUMBER';
   SET @Ls_Sqldata_TEXT = '';   

   SELECT @Ln_Schedule_NUMB = Seq_IDNO
     FROM IdentSeqSwks_T1;
   COMMIT TRANSACTION
   
   IF @Ac_ActivityMajor_CODE <> 'CASE'
      AND @An_MajorIntSeq_NUMB <> 0
      AND @An_MinorIntSeq_NUMB <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY - 1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Forum_IDNO = ' + ISNULL(CAST( @An_Forum_IDNO AS VARCHAR ),'')+ ', Topic_IDNO = ' + ISNULL(CAST( @An_Topic_IDNO AS VARCHAR ),'')+ ', MajorIntSeq_NUMB = ' + ISNULL(CAST( @An_MajorIntSeq_NUMB AS VARCHAR ),'')+ ', MinorIntSeq_NUMB = ' + ISNULL(CAST( @An_MinorIntSeq_NUMB AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Ac_ReasonStatus_CODE,'')+ ', Schedule_NUMB = ' + ISNULL(CAST( @Ln_Schedule_NUMB AS VARCHAR ),'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@As_Process_ID,'');
     
     EXEC BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
      @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
      @An_Forum_IDNO               = @An_Forum_IDNO,
      @An_Topic_IDNO               = @An_Topic_IDNO,
      @An_MajorIntSeq_NUMB         = @An_MajorIntSeq_NUMB,
      @An_MinorIntSeq_NUMB         = @An_MinorIntSeq_NUMB,
      @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
      @Ac_ActivityMinor_CODE       = @Ac_ActivityMinor_CODE,
      @Ac_ReasonStatus_CODE        = @Ac_ReasonStatus_CODE,
      @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
      @As_DescriptionNote_TEXT     = @As_DescriptionNote_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_Process_ID               = @As_Process_ID,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY - 2';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Ac_ReasonStatus_CODE,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'')+ ', Subsystem_CODE = ' + ISNULL('ES','')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', WorkerDelegate_ID = ' + ISNULL(@Ac_WorkerDelegateTo_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', TopicIn_IDNO = ' + ISNULL('0','')+ ', Job_ID = ' + ISNULL(@As_Process_ID,'')+ ', Schedule_NUMB = ' + ISNULL(CAST( @Ln_Schedule_NUMB AS VARCHAR ),'')+ ', Schedule_DATE = ' + ISNULL(CAST( @Ad_Schedule_DATE AS VARCHAR ),'')+ ', BeginSch_DTTM = ' + ISNULL(CAST( @Ad_BeginSch_DTTM AS VARCHAR ),'')+ ', OthpLocation_IDNO = ' + ISNULL(CAST( @An_OthpLocation_IDNO AS VARCHAR ),'')+ ', ScheduleWorker_ID = ' + ISNULL(@As_Worker_NAME,'')+ ', ScheduleListMemberMci_ID = ' + ISNULL(@As_Schedule_MemberMci_IDNO,'')+ ', OthpSource_IDNO = ' + ISNULL(CAST( @An_OthpLocation_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'');
     
     EXEC BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
      @Ac_ActivityMinor_CODE       = @Ac_ActivityMinor_CODE,
      @Ac_ReasonStatus_CODE        = @Ac_ReasonStatus_CODE,
      @As_DescriptionNote_TEXT     = @As_DescriptionNote_TEXT,
      @Ac_Subsystem_CODE           = 'ES',
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
      @Ac_WorkerDelegate_ID        = @Ac_WorkerDelegateTo_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @An_TopicIn_IDNO             = 0,
      @Ac_Job_ID                   = @As_Process_ID,
      @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
      @Ad_Schedule_DATE            = @Ad_Schedule_DATE,
      @Ad_BeginSch_DTTM            = @Ad_BeginSch_DTTM,
      @An_OthpLocation_IDNO        = @An_OthpLocation_IDNO,
      @Ac_ScheduleWorker_ID        = @As_Worker_NAME,
      @As_ScheduleListMemberMci_ID = @As_Schedule_MemberMci_IDNO,
      @An_OthpSource_IDNO          = @An_OthpLocation_IDNO,
      @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_SCHEDULE';
   SET @Ls_Sqldata_TEXT = 'Schedule_NUMB = ' + ISNULL(CAST( @Ln_Schedule_NUMB AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OthpLocation_IDNO = ' + ISNULL(CAST( @An_OthpLocation_IDNO AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE,'')+ ', WorkerDelegateTo_ID = ' + ISNULL(@Ac_WorkerDelegateTo_ID,'')+ ', TypeActivity_CODE = ' + ISNULL(@Ac_TypeActivity_CODE,'')+ ', Schedule_DATE = ' + ISNULL(CAST( @Ad_Schedule_DATE AS VARCHAR ),'')+ ', BeginSch_DTTM = ' + ISNULL(CAST( @Ad_BeginSch_DTTM AS VARCHAR ),'')+ ', EndSch_DTTM = ' + ISNULL(CAST( @Ad_EndSch_DTTM AS VARCHAR ),'')+ ', ApptStatus_CODE = ' + ISNULL(@Ac_ApptStatus_CODE,'')+ ', SchParent_NUMB = ' + ISNULL(CAST( @An_SchParent_NUMB AS VARCHAR ),'')+ ', SchPrev_NUMB = ' + ISNULL(CAST( @An_SchPrev_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', TypeFamisProceeding_CODE = ' + ISNULL(@Ac_ProceedingType_CODE,'')+ ', ReasonAdjourn_CODE = ' + ISNULL(@Ac_ReasonAdjourn_CODE,'')+ ', Worker_NAME = ' + ISNULL(@As_Worker_NAME,'')+ ', ScheduleWorker_ID = ' + ISNULL(@Ac_ScheduleWorker_ID,'')+ ', ScheduleListMemberMci_ID = ' + ISNULL(@As_Schedule_MemberMci_IDNO,'')+ ', SchedulingUnit_CODE = ' + ISNULL(@Ac_SchedulingUnit_CODE,'')+ ', MajorIntSeq_NUMB = ' + ISNULL(CAST( @An_MajorIntSeq_NUMB AS VARCHAR ),'');

   EXEC BATCH_COMMON$SP_INSERT_SCHEDULE
    @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
    @An_Case_IDNO                = @An_Case_IDNO,
    @An_OthpLocation_IDNO        = @An_OthpLocation_IDNO,
    @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
    @Ac_ActivityMinor_CODE       = @Ac_ActivityMinor_CODE,
    @Ac_WorkerDelegateTo_ID      = @Ac_WorkerDelegateTo_ID,
    @Ac_TypeActivity_CODE        = @Ac_TypeActivity_CODE,
    @Ad_Schedule_DATE            = @Ad_Schedule_DATE,
    @Ad_BeginSch_DTTM            = @Ad_BeginSch_DTTM,
    @Ad_EndSch_DTTM              = @Ad_EndSch_DTTM,
    @Ac_ApptStatus_CODE          = @Ac_ApptStatus_CODE,
    @An_SchParent_NUMB           = @An_SchParent_NUMB,
    @An_SchPrev_NUMB             = @An_SchPrev_NUMB,
    @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
    @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
    @Ac_TypeFamisProceeding_CODE = @Ac_ProceedingType_CODE,
    @Ac_ReasonAdjourn_CODE       = @Ac_ReasonAdjourn_CODE,
    @As_Worker_NAME              = @As_Worker_NAME,
    @Ac_ScheduleWorker_ID        = @Ac_ScheduleWorker_ID,
    @As_ScheduleListMemberMci_ID = @As_Schedule_MemberMci_IDNO,
    @Ac_SchedulingUnit_CODE      = @Ac_SchedulingUnit_CODE,
    @An_MajorIntSeq_NUMB         = @An_MajorIntSeq_NUMB,
    @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --- Executing Update Minor Activity
   SET @Ls_Sql_TEXT = 'UPDATE SCHEDULE IN DMNR';
   SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'');

   UPDATE Y
      SET Y.Schedule_NUMB = @Ln_Schedule_NUMB
     FROM DMNR_Y1 Y
    WHERE TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
      AND Case_IDNO = @An_Case_IDNO
      AND ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      AND MinorIntSeq_NUMB IN (SELECT MAX(v.MinorIntSeq_NUMB)
                                 FROM DMNR_Y1 v
                                WHERE v.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
                                  AND v.Case_IDNO = @An_Case_IDNO
                                  AND v.ActivityMajor_CODE = @Ac_ActivityMajor_CODE);

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
   
   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE DMNR FAILED';

     RAISERROR (50001,16,1);
    END

   SET @An_Schedule_NUMB = @Ln_Schedule_NUMB;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFail_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

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
