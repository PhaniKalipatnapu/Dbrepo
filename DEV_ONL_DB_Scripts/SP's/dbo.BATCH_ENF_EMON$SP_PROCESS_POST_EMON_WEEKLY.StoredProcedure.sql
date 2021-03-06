/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_POST_EMON_WEEKLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_EMON$SP_PROCESS_POST_EMON_WEEKLY
Programmer Name   : IMP Team
Description       : This procedure is used check whether the EMON weekly batch program was executed on the run date
Frequency         : WEEKLY
Developed On      : 01/05/2012
Called BY         : None
Called On         : BATCH_COMMON$SP_GET_BATCH_DETAILS , BATCH_COMMON$BATE_LOG, BATCH_COMMON$BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_POST_EMON_WEEKLY]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
		  @Lc_StatusAbnormalend_CODE			CHAR(1)			= 'A',
          @Lc_Null_TEXT							CHAR(1)			= ' ',
          @Lc_JobPost_ID						CHAR(7)			= 'DEB5480',
          @Lc_JobProcess_ID						CHAR(7)			= 'DEB5420',
          @Lc_Successful_TEXT					CHAR(20)		= 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT					CHAR(30)		= 'BATCH',
          @Ls_Procedure_Name					VARCHAR(50)		= 'SP_PROCESS_POST_EMON_WEEKLY',
          @Ls_Process_NAME						VARCHAR(100)	= 'BATCH_ENF_EMON';
  DECLARE @Ln_CommitFreq_QNTY					NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY			NUMERIC(5),
          @Ln_Error_NUMB						NUMERIC(11),
          @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Lc_Msg_CODE							CHAR(5),
          @Ls_Sql_TEXT							VARCHAR(300),
          @Ls_Sqldata_TEXT						VARCHAR(3000),
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ld_Run_DATE							DATE,
          @Ld_LastRun_DATE						DATE,
          @Ld_Start_DATE						DATETIME2(0);

  BEGIN TRY
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   BEGIN TRAN POST_EMON_TRAN;

   -- Selecting date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'EUPD002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_JobPost_ID, '');

   -- Get the Batch Details
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobPost_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EUPD003 : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_JobPost_ID, '');

     RAISERROR (50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_Sql_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_Sqldata_TEXT = @Lc_Null_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EUPD006 : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_JobProcess_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_JobProcess_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EUPD007 : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_JobProcess_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

     RAISERROR (50001,16,1);
    END

   -- Update the daily_date field for this procedure in vparm table with the pd_dt_run value
   SET @Ls_Sql_TEXT = 'EUPD020 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_JobPost_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobPost_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EUPD020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_JobPost_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

     RAISERROR (50001,16,1);
    END

   -- Updating the log with result.
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_JobPost_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_Name,
    @As_CursorLocation_TEXT   = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Null_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRAN POST_EMON_TRAN;
    END
  END TRY

  BEGIN CATCH
 
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRAN POST_EMON_TRAN;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_Name,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobPost_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_Name,
    @As_CursorLocation_TEXT       = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
