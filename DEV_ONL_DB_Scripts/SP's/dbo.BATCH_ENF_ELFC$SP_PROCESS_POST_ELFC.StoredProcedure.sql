/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_PROCESS_POST_ELFC]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_PROCESS_POST_ELFC]
/*
---------------------------------------------------------
 Procedure Name			: BATCH_ENF_ELFC$SP_PROCESS_POST_ELFC
 Programmer Name		: IMP Team
 Description			: This process reads records from Initiate/Close Enforcement Remedies database table and initiates or 
						  closes remedies based on the eligibility criteria.
 Frequency				: DAILY
 Developed On			: 07/07/2011
 Called By				: 
 Called On				: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK, BATCH_COMMON$SP_UPDATE_PARM_DATE,
						  and BATCH_COMMON$SP_BSTL_LOG
---------------------------------------------------------
 Modified By			:
 Modified On			:
 Version No				: 1.0 
---------------------------------------------------------
*/ 
AS
 BEGIN
  SET NOCOUNT ON;
   DECLARE @Lc_StatusAbnormalend_CODE		CHAR(1)			= 'A',
           @Lc_StatusSuccess_CODE			CHAR(1)			= 'S',
           @Lc_JobPost_ID					CHAR(7)			= 'DEB9992',
           @Lc_JobProcess_ID				CHAR(7)			= 'DEB0665',
           @Lc_Successful_TEXT				CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_ID				CHAR(30)		= 'BATCH',
           @Ls_Procedure_NAME				VARCHAR(80)		= 'SP_PROCESS_POST_ELFC',
           @Ls_Process_NAME					VARCHAR(100)	= 'BATCH_ENF_ELFC',
           @Ld_High_DATE					DATE			= '12/31/9999';
           
  DECLARE  @Ln_ExceptionThreshold_QNTY      NUMERIC(5)		= 0,
           @Ln_CommitFreqParm_QNTY          NUMERIC(5),
           @Ln_Cursor_QNTY                  NUMERIC(10)		= 0,
           @Lc_Null_TEXT                    CHAR(1)			= '',
           @Lc_Msg_CODE                     CHAR(5),
           @Ls_Sql_TEXT                     VARCHAR(100),
           @Ls_Sqldata_TEXT                 VARCHAR(1000),
           @Ls_DescriptionError_TEXT        VARCHAR(4000),
           @Ld_Run_DATE                     DATE,
           @Ld_Start_DATE                   DATETIME2(0),
           @Ld_LastRun_DATE                 DATETIME2(0);

  BEGIN TRY 
		SET @Ln_CommitFreqParm_QNTY = 0;

		SET @Ls_Sql_TEXT = 'GET BATCH START TIME : ElPOST1';
		SET @Ls_Sqldata_TEXT = '';
		SET @Ld_Start_DATE =  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

		BEGIN TRANSACTION PostELFC_TRAN;

		SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_GET_BATCH_DETAILS : ElPOST2';
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPost_ID, '');
		
		 EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
				@Ac_Job_ID                  = @Lc_JobPost_ID,
				@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
				@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
				@An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
				@An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
				@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EUPD003 : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPost_ID, '');
     RAISERROR(50001,16,1);
    END
    
	IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
		BEGIN
			SET @Ls_Sql_TEXT = 'PARM DATE CONDITION FAILED ElLC ElPOST3';
			SET @Ls_Sqldata_TEXT = 'DT_LAST_RUN = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR(10)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');
			SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
			RAISERROR(50001,16,1);
		END   
		
	------ UPdating ELFC table	
	UPDATE e SET Process_DATE = i.Process_DATE
			FROM ELFC_Y1 e, IELFC_Y1 i
				  WHERE e.Case_IDNO = i.Case_IDNO
					AND e.MemberMci_IDNO = i.MemberMci_IDNO
					AND e.OthpSource_IDNO = i.OthpSource_IDNO
					AND e.Reference_ID = i.Reference_ID
					AND e.Process_ID = i.Process_ID
					AND e.TypeChange_CODE = i.TypeChange_CODE
					AND e.Process_DATE = @Ld_High_DATE
					AND e.Create_DATE = i.Create_DATE 
					AND e.UPDATE_DTTM = i.UPDATE_DTTM;
		
		
	SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK : ElPOST4';
	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobProcess_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

	EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
				@Ad_Run_DATE              = @Ld_Run_DATE,
				@Ac_Job_ID                = @Lc_JobProcess_ID,
				@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		 
	
	IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
		BEGIN
		 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED : ElPOST5';
		 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobProcess_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');
		 RAISERROR(50001,16,1);
		END
		
	SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_UPDATE_PARM_DATE : ElPOST6';
	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPost_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');
	
	EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
					@Ac_Job_ID                = @Lc_JobPost_ID,
					@Ad_Run_DATE              = @Ld_Run_DATE,
					@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
					@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
					
	IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
		BEGIN
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED : ElPOST7';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPost_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

			RAISERROR(50001,16,1);
		END
	
	EXECUTE BATCH_COMMON$SP_BSTL_LOG
						@Ad_Run_DATE                  = @Ld_Run_DATE,
						@Ad_Start_DATE                = @Ld_Start_DATE,
						@Ac_Job_ID                    = @Lc_JobPost_ID,
						@As_Process_NAME              = @Ls_Process_NAME,
						@As_Procedure_NAME            = @Ls_Procedure_NAME,
						@As_CursorLocation_TEXT       = @Lc_Null_TEXT,
						@As_ExecLocation_TEXT         = @LC_Successful_TEXT,
						@As_ListKey_TEXT              = @LC_Successful_TEXT,
						@As_DescriptionError_TEXT     = @Lc_Null_TEXT,
						@Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
						@Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
						@An_ProcessedRecordCount_QNTY = 0;

	 COMMIT TRANSACTION PostELFC_TRAN;	    
		
  END TRY
  BEGIN CATCH
	DECLARE @Li_Error_NUMB                      INT = NULL,
			@Li_ErrorLine_NUMB                  INT = NULL;

	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION PostELFC_TRAN;
		END
		
	EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
          @As_Procedure_NAME        = @Ls_Procedure_NAME,
          @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
          @As_Sql_TEXT              = @Ls_Sql_TEXT,
          @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
          @An_Error_NUMB            = @Li_Error_NUMB,
          @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		
          
	IF ERROR_NUMBER() = 50001
		BEGIN
			EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE                  = @Ld_Run_DATE,
			@Ad_Start_DATE                = @Ld_Start_DATE,
			@Ac_Job_ID                    = @Lc_JobPost_ID,
			@As_Process_NAME              = @Ls_Process_NAME,
			@As_Procedure_NAME            = @Ls_Procedure_NAME,
			@As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
			@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
			@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
			@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
			@Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
			@Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
			@An_ProcessedRecordCount_QNTY = 0;

			RAISERROR(@Ls_DescriptionError_TEXT,16,1);
		END
	ELSE
		BEGIN
		SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 100);

		EXECUTE BATCH_COMMON$SP_BSTL_LOG
		@Ad_Run_DATE                  = @Ld_Run_DATE,
		@Ad_Start_DATE                = @Ld_Start_DATE,
		@Ac_Job_ID                    = @Lc_JobPost_ID,
		@As_Process_NAME              = @Ls_Process_NAME,
		@As_Procedure_NAME            = @Ls_Procedure_NAME,
		@As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
		@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
		@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
		@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
		@Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
		@Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
		@An_ProcessedRecordCount_QNTY = 0;

		RAISERROR(@Ls_DescriptionError_TEXT,16,1);
		END          
    			
  END CATCH
 END


GO
