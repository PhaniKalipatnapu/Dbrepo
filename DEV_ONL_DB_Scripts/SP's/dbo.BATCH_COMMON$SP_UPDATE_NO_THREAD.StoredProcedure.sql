/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_NO_THREAD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_NO_THREAD
Programmer Name		: IMP Team
Description			: This procedure will update the NO_THREAD in REF_JOB_PARM table 
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_NO_THREAD]
 @Ac_Job_ID                CHAR(7),
 @An_Thread_NUMB           NUMERIC(15),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_NoteN_INDC         CHAR(1) = 'N',
          @Lc_Process_ID         CHAR(10) = 'ADHOC',
          @Lc_BatchRunUser_TEXT  CHAR(30) = 'BATCH',
          @Ls_Routine_TEXT       VARCHAR(60) = 'BATCH_COMMON$SP_UPDATE_NO_THREAD',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB                  NUMERIC,
          @Ln_RowCount_QNTY               NUMERIC,
          @Ln_TransactionEventSeqOld_NUMB NUMERIC(9, 0),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Systyem_DATE                DATETIME2(0);

  BEGIN TRY
   SET @Ld_Systyem_DATE = CAST (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS DATE);
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1 TransactionEventSeq_NUMB';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Ln_TransactionEventSeqOld_NUMB = TransactionEventSeq_NUMB
     FROM PARM_Y1 p
    WHERE Job_ID = @Ac_Job_ID
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'JOB NOT AVAILABLE';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   -- Generating new seq_txn_event
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Systyem_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_NoteN_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(0 AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Process_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Systyem_DATE,
    @Ac_Note_INDC                = @Lc_NoteN_INDC,
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RETURN;
    END

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeqOld_NUMB AS VARCHAR), '');

   UPDATE PARM_Y1
      SET EndValidity_DATE = @Ld_Systyem_DATE
    WHERE Job_ID = @Ac_Job_ID
      AND TransactionEventSeq_NUMB = @Ln_TransactionEventSeqOld_NUMB;

   SET @Ls_Sql_TEXT = 'INSERT INTO PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Thread_NUMB = ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Systyem_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   INSERT INTO PARM_Y1
               (Job_ID,
                Process_NAME,
                Procedure_NAME,
                DescriptionJob_TEXT,
                JobFreq_CODE,
                Run_DATE,
                CommitFreq_QNTY,
                DayRun_CODE,
                ExceptionThreshold_QNTY,
                FileIo_CODE,
                File_NAME,
                Server_NAME,
                ServerPath_NAME,
                Thread_NUMB,
                StartSeq_NUMB,
                TotalSeq_QNTY,
                TransactionEventSeq_NUMB,
                BeginValidity_DATE,
                EndValidity_DATE,
                Update_DTTM,
                ResponseTime_QNTY,
                WorkerUpdate_ID,
                DescriptionMisc_TEXT)
   SELECT Job_ID,
          Process_NAME,
          Procedure_NAME,
          DescriptionJob_TEXT,
          JobFreq_CODE,
          Run_DATE,
          CommitFreq_QNTY,
          DayRun_CODE,
          ExceptionThreshold_QNTY,
          FileIo_CODE,
          File_NAME,
          Server_NAME,
          ServerPath_NAME,
          @An_Thread_NUMB AS Thread_NUMB,
          StartSeq_NUMB,
          TotalSeq_QNTY,
          @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
          @Ld_Systyem_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
          ResponseTime_QNTY,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          DescriptionMisc_TEXT
     FROM PARM_Y1 p
    WHERE Job_ID = @Ac_Job_ID
      AND TransactionEventSeq_NUMB = @Ln_TransactionEventSeqOld_NUMB;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT INTO PARM_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
