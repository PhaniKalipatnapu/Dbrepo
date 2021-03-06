/****** Object:  StoredProcedure [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_POST_NMSN_ANNUAL_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_POST_NMSN_ANNUAL_NOTICE
Programmer Name 	: IMP Team.
Description			: This procedure is used check whether the NMSN batch program was executed on the run date
Frequency			: 'ANNUAL'
Developed On		: 01/05/2012
Called By			: 
Called Procedures	: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK, BATCH_COMMON$SP_UPDATE_PARM_DATE 
					  and BATCH_COMMON$SP_BSTL_LOG.
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_POST_NMSN_ANNUAL_NOTICE]
AS
 BEGIN
    DECLARE @Ls_SuccessStatus_CODE      CHAR(1)			= 'S',
			@Lc_AbnormalEndStatus_CODE  CHAR(1)			= 'A',
			@Lc_FailedStatus_CODE       CHAR(1)			= 'F',
			@Lc_PostNmsnJob_ID          CHAR(7)			= 'DEB8680',
			@Lc_NmsnRenewalJob_ID       CHAR(7)			= 'DEB8670',
			@Lc_Successful_TEXT         CHAR(20)		= 'SUCCESSFUL',
			@Lc_BatchRunUser_TEXT       VARCHAR(30)		= 'BATCH',
			@Ls_Procedure_NAMR			VARCHAR(60)		= 'SP_PROCESS_POST_NMSN_ANNUAL_NOTICE',
			@Ls_Process_NAME            VARCHAR(100)	= 'BATCH_ENF_NMSN_ANNUAL_NOTICES';
			
  DECLARE  @Li_Error_NUMB               INT = 0,
           @Li_ErrorLine_NUMB           INT = 0,
           @Ln_Error_NUMB               INT,
           @Ln_ErrorLine_NUMB           INT,
           @Ln_NoCommitFreq_QNTY        NUMERIC(5),
           @Ln_ExceptionThreshold_QNTY  NUMERIC(5),
           @Ls_Null_TEXT                CHAR(1) = '',
           @Lc_Msg_CODE                 CHAR(3),
           @Ls_Sql_TEXT                 VARCHAR(100),
           @Ls_Sqldata_TEXT             VARCHAR(1000),
           @Ls_DescriptionError_TEXT    VARCHAR(4000),
           @Ls_ErrorMessage_TEXT        VARCHAR(4000),
           @Ld_Start_DATE               DATE,
           @Ld_RunParm_DATE             DATE,
           @Ld_LastRun_DATE             DATE;

  BEGIN TRY
   BEGIN TRANSACTION POSTNMSNANNUALNOTICE_Tran;

   
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'EUPD002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID: ' + ISNULL(@Lc_PostNmsnJob_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_PostNmsnJob_ID,
    @Ad_Run_DATE                = @Ld_RunParm_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_NoCommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Ls_SuccessStatus_CODE
    BEGIN
		 SET @Ls_Sql_TEXT = 'EUPD003 : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
		 RAISERROR(50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_RunParm_DATE
    BEGIN
		 SET @Ls_Sql_TEXT = 'EUPD005 : PARM DATE CONDITION FAILED';
		 SET @Ls_Sqldata_TEXT = 'DT_LAST_RUN: ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR(20)), '') 
							  + ' Run_DATE: ' + ISNULL (CAST(@Ld_RunParm_DATE AS VARCHAR(20)), '')
		 SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
		 RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EUPD006 : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_Sqldata_TEXT = 'Job_ID: ' + ISNULL(@Lc_NmsnRenewalJob_ID, '') + ' Run_DATE: ' + ISNULL(CAST(@Ld_RunParm_DATE AS NVARCHAR (10)), '');

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_RunParm_DATE,
    @Ac_Job_ID                = @Lc_NmsnRenewalJob_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Ls_SuccessStatus_CODE
    BEGIN
		SET @Ls_Sql_TEXT = 'EUPD007 : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED';
		RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EUPD020 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID: ' + ISNULL(@Lc_NmsnRenewalJob_ID, '') + ' Run_DATE: ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR (MAX)), '')

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_PostNmsnJob_ID,
    @Ad_Run_DATE              = @Ld_RunParm_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Ls_SuccessStatus_CODE
    BEGIN
		 SET @Ls_Sql_TEXT = 'EUPD020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
		 RAISERROR(50001,16,1);
    END


	 EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE                  = @Ld_RunParm_DATE,
			@Ad_Start_DATE                = @Ld_Start_DATE,
			@Ac_Job_ID                    = @Lc_PostNmsnJob_ID,
			@As_Process_NAME              = @Ls_Process_NAME,
			@As_Procedure_NAME            = @Ls_Procedure_NAMR,
			@As_CursorLocation_TEXT       = @Ls_Null_TEXT,
			@As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
			@As_ListKey_TEXT              = @Lc_Successful_TEXT,
			@As_DescriptionError_TEXT     = @Ls_Null_TEXT,
			@Ac_Status_CODE               = @Ls_SuccessStatus_CODE,
			@Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
			@An_ProcessedRecordCount_QNTY = 0;

   IF @@TRANCOUNT >0
	BEGIN
		COMMIT TRANSACTION POSTNMSNANNUALNOTICE_Tran;
	END
  END TRY

  BEGIN CATCH
	  IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION POSTNMSNANNUALNOTICE_Tran;
			END
	    
		SET @Lc_Msg_CODE = @Lc_FailedStatus_CODE;
		SET @Li_Error_NUMB = ERROR_NUMBER ();
		SET @Li_ErrorLine_NUMB = ERROR_LINE ();
		
		IF (@Li_Error_NUMB <> 50001)
		BEGIN
		 SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
		END
	    
		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
				@As_Procedure_NAME        = @Ls_Procedure_NAMR,
				@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
				@As_Sql_TEXT              = @Ls_Sql_TEXT,
				@As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
				@An_Error_NUMB            = @Li_Error_NUMB,
				@An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
				@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

	   EXECUTE BATCH_COMMON$SP_BSTL_LOG
				@Ad_Run_DATE                  = @Ld_RunParm_DATE,
				@Ad_Start_DATE                = @Ld_Start_DATE,
				@Ac_Job_ID                    = @Lc_PostNmsnJob_ID,
				@As_Process_NAME              = @Ls_Process_NAME,
				@As_Procedure_NAME            = @Ls_Procedure_NAMR,
				@As_CursorLocation_TEXT       = @Ls_Null_TEXT,
				@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
				@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
				@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
				@Ac_Status_CODE               = @Lc_AbnormalEndStatus_CODE,
				@Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
				@An_ProcessedRecordCount_QNTY = 0;    
	   
	   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
