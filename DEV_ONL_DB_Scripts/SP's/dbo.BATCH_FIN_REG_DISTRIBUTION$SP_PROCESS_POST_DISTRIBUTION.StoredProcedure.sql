/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_POST_DISTRIBUTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_POST_DISTRIBUTION
Programmer Name 	: IMP Team
Description			: This procedure is used to delete PRREL_Y1 table and updates Regular Distribution (DEB0560) Job 
					  Run Date with DAILY Job run date when last two regular distribution thread jobs are completed 
					  at the same time and DEB0560 Job Run Date didn't update with DAILY Job run date.
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_POST_DISTRIBUTION]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
		   -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - Start --
		   @Lc_No_INDC				   CHAR (1) = 'N',
		   -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - End --
           @Lc_Space_TEXT              CHAR(1) = ' ',
           @Lc_JobPostDist_ID          CHAR(7) = 'DEB1280',
           @Lc_ProcessRdist_ID         CHAR(10) = 'DEB0560',
           @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT       CHAR(30) = 'BATCH',
           @Ls_Process_NAME            VARCHAR(100) = 'BATCH_FIN_REG_DISTRIBUTION',
           @Ls_Procedure_NAME          VARCHAR(100) = 'SP_PROCESS_POST_DISTRIBUTION';
  DECLARE  @Ln_CommitFreqParm_QNTY          NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
           @Ln_ProcessedRecordCount_QNTY    NUMERIC(6) = 0,
		   -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - Start --
           @Ln_PdistNotProcessRecord_QNTY   NUMERIC (9) = 0,   
           @Ln_JrtlNotProcessThread_QNTY    NUMERIC(9) = 0,
           @Ln_JrtlRdistJobRunDateThread_QNTY  NUMERIC(9) = 0,          
		   -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - End --
           @Ln_Error_NUMB                   NUMERIC(11),
           @Ln_ErrorLine_NUMB               NUMERIC(11),
           @Li_Rowcount_QNTY                INT = 0,
           @Lc_Msg_CODE                     CHAR(1),
           @Ls_CursorLoc_TEXT               VARCHAR(200),
           @Ls_Sql_TEXT                     VARCHAR(4000),
           @Ls_Sqldata_TEXT                 VARCHAR(4000),
           @Ls_ErrorMessage_TEXT            VARCHAR(4000),
           @Ls_DescriptionError_TEXT        VARCHAR(4000),
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE,
		   -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - Start --
           @Ld_RdistRun_DATE                DATE,
           @Ld_RdistLastRun_DATE            DATE,		   
           -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - End --
           @Ld_Create_DATE                  DATETIME2;

  BEGIN TRY
   BEGIN TRANSACTION PDistTran;
   -- Selecting the Batch start time
   SET @Ld_Create_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Selecting date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPostDist_ID,'');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobPostDist_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
    
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END

   -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - Start --
   -- Get Regular Distribution (DEB0560) Job Run Date using BATCH_COMMON$SP_GET_BATCH_DETAILS common procedure
   SET @Ls_Sql_TEXT = 'RegDist:BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_ProcessRdist_ID,
    @Ad_Run_DATE                = @Ld_RdistRun_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_RdistLastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- If DAILY Job run date is not equal to Regular Distribution (DEB0560) Job Run Date then check all PDIST records processes successfully
   -- and update DEB0560 Job Run Date with DAILY Job run before BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK common procedure execution
   IF @Ld_Run_DATE <> @Ld_RdistLastRun_DATE
   BEGIN
	   SET @Ls_Sql_TEXT = 'SELECT JRTL_Y1 COUNT-1';   
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR ),'');
	   
	   -- Checking Pre Distribution job is executed successfully and eligible records are assigned with thread number(s) in JRTL_Y1 table for Run Date. 
	   -- @Ln_JrtlRdistJobRunDateThread_QNTY value should have > 0.
	   SELECT @Ln_JrtlRdistJobRunDateThread_QNTY = COUNT (1)
		 FROM JRTL_Y1 a
		WHERE a.Job_ID = @Lc_ProcessRdist_ID
		  AND a.Run_DATE = @Ld_Run_DATE;    
		  
	   SET @Ls_Sql_TEXT = 'SELECT PDIST_Y1 COUNT';   
	   SET @Ls_Sqldata_TEXT = 'Process_CODE = ' + ISNULL(@Lc_No_INDC,'');
	   
	   -- Checking Regular Distribution job all threads are executed successfully and all records are processed and marked 'Y' 
	   -- in PDIST_Y1 table Process_CODE Column. @Ln_PdistNotProcessRecord_QNTY value should have = 0 i.e.) Record should not exists with Process_CODE = 'N'.
	   SELECT @Ln_PdistNotProcessRecord_QNTY = COUNT (1)
		 FROM PDIST_Y1 a
		WHERE a.Process_CODE = @Lc_No_INDC;
	    
	   SET @Ls_Sql_TEXT = 'SELECT JRTL_Y1 COUNT-2';   
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR ),'') + ', ThreadProcess_CODE = ' + ISNULL(@Lc_No_INDC,'');
	   -- Checking Regular Distribution job all threads are executed successfully and all records are processed and thread records marked 'Y' 
	   -- in JRTL_Y1 table ThreadProcess_CODE Column. @Ln_JrtlNotProcessThread_QNTY value should have = 0 i.e.) Record should not exists with ThreadProcess_CODE = 'N'.
	   SELECT @Ln_JrtlNotProcessThread_QNTY = COUNT (1)
		 FROM JRTL_Y1 a
		WHERE a.Job_ID = @Lc_ProcessRdist_ID
		  AND a.Run_DATE = @Ld_Run_DATE
		  AND a.ThreadProcess_CODE = @Lc_No_INDC;

	   -- Regular Distribution (DEB0560) Job Run Date will be updated only if all the eligbile records are processed 
	   -- and threads status is marked with 'Y' in PDIST_Y1.Process_CODE & JRTL_Y1.ThreadProcess_CODE columns.
	   IF @Ln_JrtlRdistJobRunDateThread_QNTY > 0 AND @Ln_PdistNotProcessRecord_QNTY = 0 AND @Ln_JrtlNotProcessThread_QNTY = 0 
		BEGIN

		 SET @Ls_Sql_TEXT = 'RegDist:BATCH_COMMON$SP_UPDATE_PARM_DATE';
		 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR ),'');

		 EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
		  @Ac_Job_ID                = @Lc_ProcessRdist_ID,
		  @Ad_Run_DATE              = @Ld_Run_DATE,
		  @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		  @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

		 IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
		  BEGIN
		   RAISERROR (50001,16,1);
		  END
		END
	END
   -- Defect 13776 - Regular Distribution (DEB0560) Job Run Date Update When last two regular distribution thread jobs are completed at the same time & DEB0560 Job PARM date didn't update successfully - Fix - End --

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';   
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'');

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_ProcessRdist_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DELETE PRREL_Y1';   
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM PRREL_Y1;
   
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   SET @Ln_ProcessedRecordCount_QNTY = @Li_Rowcount_QNTY;
   
   -- Update the run date field for post distribution job in PARM_Y1 table with DAILY job run date value
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';   
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPostDist_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobPostDist_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';   
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Create_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_JobPostDist_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Create_DATE,
    @Ac_Job_ID                = @Lc_JobPostDist_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION PDistTran; 
  END TRY

  BEGIN CATCH
   
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PDistTran;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Create_DATE,
    @Ac_Job_ID                = @Lc_JobPostDist_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
