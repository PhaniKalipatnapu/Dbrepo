/****** Object:  StoredProcedure [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_POST_CASE_CLOSURE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_POST_CASE_CLOSURE]
/*
-----------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_POST_CASE_CLOSURE
 Programmer Name	: IMP Team
 Description		: This procedure is used to check CASE CLOSURE process has 
						sucessfully completed or not
 Frequency			: WEEKLY
 Developed On		: 01/20/2012
 Called By			:
 Called On			: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK, BATCH_COMMON$SP_UPDATE_PARM_DATE
					  and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No			: 1.0 
------------------------------------------------------------------------------------------------------------------------
*/ 
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
           @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
           @Lc_Job_ID                  CHAR(7) = 'DEB5270',
           @Lc_JobPostCclr_ID          CHAR(7) = 'DEB5450',
           @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT       CHAR(30) = 'BATCH',
           @Ls_Routine_TEXT            VARCHAR(80) = 'SP_PROCESS_POST_CASE_CLOSURE',
           @Ls_Process_NAME            VARCHAR(100) = 'BATCH_CM_CASE_CLOSURE_ELIG';
           
  DECLARE  @Ln_CommitFreqParm_QNTY      NUMERIC(5),
		   @Ln_CommitFreq_QNTY          NUMERIC(5),
           @Ln_ExceptionThreshold_QNTY   NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY   NUMERIC(5),
           @Ln_Error_NUMB                NUMERIC(10,0),
           @Ln_ErrorLine_NUMB            NUMERIC(10,0),
           @Lc_Null_TEXT                 CHAR(1) = '',
           @Lc_Msg_CODE                  CHAR(3),
           @Ls_Sql_TEXT                  VARCHAR(100),
           @Ls_Sqldata_TEXT              VARCHAR(1000),
           @Ls_DescriptionError_TEXT     VARCHAR(4000),
           @Ld_Start_DATE                DATETIME2(0),
           @Ld_Run_DATE                  DATETIME2(0),
           @Ld_LastRun_DATE              DATETIME2(0);

  BEGIN TRY
  
   SET @Ln_CommitFreq_QNTY = 0;
   SET @Ln_ExceptionThresholdParm_QNTY = 0;
   
   SET @Ls_Sql_TEXT = 'GET BATCH START TIME : EUPD001';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
 
   BEGIN TRANSACTION PostCaseClosure_TRAN;
   
   SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_GET_BATCH_DETAILS : EUPD002';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPostCclr_ID, '');
    
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobPostCclr_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EUPD003 : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPostCclr_ID, '');

     RAISERROR(50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_Sql_TEXT = 'PARM DATE CONDITION FAILED EUPD005';
     SET @Ls_Sqldata_TEXT = 'DT_LAST_RUN = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR(10)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END
  
   SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK : EUPD006';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED : EUPD007';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_UPDATE_PARM_DATE : EUPD020';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPostCclr_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobPostCclr_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED : EUPD020A';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPostCclr_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

     RAISERROR(50001,16,1);
    END

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobPostCclr_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Null_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   COMMIT TRANSACTION PostCaseClosure_TRAN;
  END TRY

  BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PostCaseClosure_TRAN;
    END
   
   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobPostCclr_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
