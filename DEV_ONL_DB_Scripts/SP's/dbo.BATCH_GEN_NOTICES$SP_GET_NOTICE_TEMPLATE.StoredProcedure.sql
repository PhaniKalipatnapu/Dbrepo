/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NOTICE_TEMPLATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_NOTICE_TEMPLATE
Programmer Name	:	IMP Team.
Description		:	This Procedure is used to get the Notice template from NVER table
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NOTICE_TEMPLATE]
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE
		@Ln_RestartLine_NUMB            NUMERIC(5,0) = 0,
		@Li_Error_NUMB					INT = NULL,
		@Li_ErrorLine_NUMB				INT = NULL,
		@Lc_StatusFailed_CODE			CHAR (1) = 'F',
		@Lc_StatusSuccess_CODE			CHAR (1) = 'S',
		@Lc_StatusAbnormalend_CODE      CHAR (1) = 'A',
		@Lc_TypeError_IDNO				CHAR (1) = 'E',
		@Lc_NoDataFound_CODE			CHAR (1) = 'N',
		@Lc_StatusNoticeGenerate_CODE	CHAR (1) = 'G',
		@Lc_StatusNoticeFailed_CODE		CHAR (1) = 'F',
		@Lc_PrintMethodCentral_CODE		CHAR (1) = 'C',
		@Lc_Space_TEXT					CHAR (1) = ' ',
		@Lc_WorkerPrinter_ID			CHAR (30) = 'BATCH',
		@Lc_Job_ID						CHAR (7) = 'DEB0960',
		@Lc_ErrorE0944_CODE				CHAR (5) = 'E0944',
		@Lc_Successful_TEXT				CHAR(20) = 'SUCCESSFUL',
		@Ls_Procedure_NAME              VARCHAR (100) = 'SP_GET_NOTICE_TEMPLATE',
		@Ls_Process_NAME                VARCHAR (100) = 'Dhss.Ivd.Decss.Batch.CentralPrint';
		
	DECLARE
		@Ln_CommitFreqParm_QNTY			NUMERIC (5),
		@Ln_ExceptionThresholdParm_QNTY	NUMERIC (5),
		@Lc_Msg_CODE					CHAR (1),
		@Ls_ErrorMessage_TEXT			VARCHAR (4000),
		@Ls_Sql_TEXT					VARCHAR (1000),
		@Ls_Sqldata_TEXT				VARCHAR (4000),
		@Ls_DescriptionError_TEXT		VARCHAR (4000),
		@Ls_BateRecord_TEXT				VARCHAR (4000),
		@Ld_Run_DATE					DATE,
		@Ld_LastRun_DATE				DATE,
		@Ld_Start_DATE                  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	
	BEGIN TRY
		SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_NOTICE_TEMPLATE';
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
		
		EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
			@Ac_Job_ID                  = @Lc_Job_ID,
			@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
			@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
			@An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
			@An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
			@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

		IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			RAISERROR (50001,16,1);
		END

		SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
		SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(DATEADD(D, 1, @Ld_LastRun_DATE) AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
		IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
		BEGIN
			SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
			RAISERROR (50001,16,1);
		END

		SET @Ls_Sql_TEXT = 'SELECT PENDING NOTICES TEMPLATES';
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
		
		SELECT
			N.Notice_id,
			N.NoticeVersion_NUMB,
			V.XslTemplate_TEXT
		FROM
			NMRQ_Y1 N
			JOIN
			NVER_Y1 V
			ON V.Notice_ID = N.Notice_ID AND
			V.NoticeVersion_NUMB = N.NoticeVersion_NUMB
		WHERE
			N.StatusNotice_CODE IN (@Lc_StatusNoticeGenerate_CODE, @Lc_StatusNoticeFailed_CODE) AND
			N.PrintMethod_CODE = @Lc_PrintMethodCentral_CODE
		GROUP BY
			N.Notice_id,
			N.NoticeVersion_NUMB,
			V.XslTemplate_TEXT;

		IF @@ROWCOUNT = 0
		BEGIN
			EXECUTE BATCH_COMMON$SP_BATE_LOG
				@As_Process_NAME             = @Ls_Process_NAME,
				@As_Procedure_NAME           = @Ls_Procedure_NAME,
				@Ac_Job_ID                   = @Lc_Job_ID,
				@Ad_Run_DATE                 = @Ld_Run_DATE,
				@Ac_TypeError_CODE           = @Lc_TypeError_IDNO,
				@An_Line_NUMB                = @Ln_RestartLine_NUMB,
				@Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
				@As_DescriptionError_TEXT    = @Lc_ErrorE0944_CODE,
				@As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
				@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				RAISERROR (50001,16,1);
			END
			
			--Update the run date field for this procedure in PARM_Y1 table
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
			SET @Ls_SqlData_TEXT = ' Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
			
			EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
				@Ac_Job_ID                = @Lc_Job_ID,
				@Ad_Run_DATE              = @Ld_Run_DATE,
				@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				RAISERROR (50001,16,1);
			END
			
			--Success full execution write to VBSTL
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
			SET @Ls_SqlData_TEXT = ' Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', USER ID = ' + @Lc_WorkerPrinter_ID;

			EXECUTE BATCH_COMMON$SP_BSTL_LOG
				@Ad_Run_DATE                  = @Ld_Run_DATE,
				@Ad_Start_DATE                = @Ld_Start_DATE,
				@Ac_Job_ID                    = @Lc_Job_ID,
				@As_Process_NAME              = @Ls_Process_NAME,
				@As_Procedure_NAME            = @Ls_Procedure_NAME,
				@As_CursorLocation_TEXT       = @Lc_Space_TEXT,
				@An_ProcessedRecordCount_QNTY = 0,
				@As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
				@As_ListKey_TEXT              = @Lc_Successful_TEXT,
				@As_DescriptionError_TEXT     = @Lc_Space_TEXT,
				@Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
				@Ac_Worker_ID                 = @Lc_WorkerPrinter_ID;
		END
	END TRY
	BEGIN CATCH
		SET @Li_Error_NUMB		= ERROR_NUMBER ();
		SET @Li_ErrorLine_NUMB	= ERROR_LINE ();
		
		IF (@Li_Error_NUMB <> 50001)
        BEGIN
			SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
        END
        
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
			@As_Procedure_NAME			= @Ls_Procedure_NAME,
			@As_ErrorMessage_TEXT		= @Ls_DescriptionError_TEXT,
            @As_Sql_TEXT				= @Ls_Sql_TEXT,
            @As_Sqldata_TEXT			= @Ls_SqlData_TEXT,
            @An_Error_NUMB				= @Li_Error_NUMB,
            @An_ErrorLine_NUMB			= @Li_ErrorLine_NUMB,
            @As_DescriptionError_TEXT	= @Ls_DescriptionError_TEXT OUTPUT ;
		
		EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE                  = @Ld_Run_DATE,
			@Ad_Start_DATE                = @Ld_Start_DATE,
			@Ac_Job_ID                    = @Lc_Job_ID,
			@As_Process_NAME              = @Ls_Process_NAME,
			@As_Procedure_NAME            = @Ls_Procedure_NAME,
			@As_CursorLocation_TEXT       = @Lc_Space_TEXT,
			@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
			@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
			@An_ProcessedRecordCount_QNTY = 0,
			@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
			@Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
			@Ac_Worker_ID                 = @Lc_WorkerPrinter_ID;
	END CATCH
END
GO
