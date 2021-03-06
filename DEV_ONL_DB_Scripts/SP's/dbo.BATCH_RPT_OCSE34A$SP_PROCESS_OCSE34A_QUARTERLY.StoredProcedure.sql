/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE34A$SP_PROCESS_OCSE34A_QUARTERLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_RPT_OCSE34A$SP_PROCESS_OCSE34A_QUARTERLY
Programmer Name 	: IMP Team
Description			: The process loads OCSE34A - Report Quarterly
Frequency			: 'MONTHLY/QUATERLY'
Developed On		: 9/13/2011
Called BY			: None
Called On			: BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE34A$SP_PROCESS_OCSE34A_QUARTERLY]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusFailed_CODE       CHAR (1) = 'F',
           @Lc_StatusAbnormalend_CODE  CHAR (1) = 'A',
           @Lc_Space_TEXT              CHAR (1) = ' ',
           @Lc_StatusSuccess_CODE      CHAR (1) = 'S',
           @Lc_Job_ID                  CHAR (7) = 'DEB7630',
           @Lc_Successful_TEXT         CHAR (20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT       CHAR (30) = 'BATCH',
           @Lc_Parmdateproblem_TEXT    CHAR (30) = 'PARM DATE PROBLEM',
           @Ls_Process_NAME            VARCHAR (100) = 'BATCH_RPT_OCSE34A',
           @Ls_Procedure_NAME          VARCHAR (100) = 'SP_PROCESS_OCSE34A_QUARTERLY',
           @Ls_CursorLoc_TEXT          VARCHAR (200) = ' ',
           @Ld_Start_DATE              DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_CommitFreqParm_QNTY     NUMERIC (5),
		   @Ln_ExceptionThresholdParm_QNTY NUMERIC (5),
           @Ln_Cur_QNTY                 NUMERIC (6) = 0,
           @Ln_Error_NUMB               NUMERIC (11),
           @Ln_ErrorLine_NUMB           NUMERIC (11),
           @Lc_TypeReport_CODE          CHAR (1),
           @Lc_Msg_CODE                 CHAR (1),
           @Ls_Sql_TEXT                 VARCHAR (1000),
           @Ls_Sqldata_TEXT             VARCHAR (2000),
           @Ls_ErrorMessage_TEXT        VARCHAR (4000),           
           @Ls_DescriptionError_TEXT    VARCHAR (4000),           
           @Ld_Run_DATE                 DATE,
           @Ld_LastRun_DATE             DATE,
           @Ld_BeginQtr_DATE            DATE,
           @Ld_EndQtr_DATE              DATE,
           @Ld_PrevBeginQtr_DATE        DATE,
           @Ld_PrevEndQtr_DATE          DATE;

  BEGIN TRY
  
   BEGIN TRANSACTION O34Quarterly_TRAN;
   /*
	Get the run date and last run date from PARM_Y1 table and validate that the batch program was not 
	executed for the run date by ensuring that the run date is different from the last run date in the 
	PARM_Y1 table.  Otherwise, an error message to that effect will be written into BSTL_Y1 
	table and terminate the process
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                   = @Lc_Job_ID,
    @Ad_Run_DATE                 = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE             = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY          = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY  = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Check whether the Job ran already on same week.
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_Parmdateproblem_TEXT;
     RAISERROR(50001,16,1);
    END

   SET @Ld_BeginQtr_DATE = CONVERT(DATETIME, CONVERT(CHAR(8),DATEPART(YEAR, @Ld_Run_DATE) * 10000 + ( DATEPART(QUARTER, @Ld_Run_DATE) * 3 - 2) * 100 + 1),112) ;
   SET @Ld_EndQtr_DATE = DATEADD(m, 3, CONVERT(DATETIME, CONVERT(CHAR(8),DATEPART(YEAR, @Ld_BeginQtr_DATE) * 10000 + ( DATEPART(QUARTER, @Ld_BeginQtr_DATE) * 3 - 2) * 100 + 1),112)) - 1;
   SET @Ld_PrevBeginQtr_DATE = DATEADD(m, -3, @Ld_BeginQtr_DATE);
   SET @Ld_PrevEndQtr_DATE = DATEADD(D, -1, @Ld_BeginQtr_DATE);
   SET @Lc_TypeReport_CODE = dbo.BATCH_RPT_OCSE34A$SF_GET_REP_TYPE(@Lc_Job_ID);	
   SET @Lc_TypeReport_CODE = 'I';
   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS : QUARTERLY';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', BeginQtr_DATE = ' + CAST(@Ld_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ld_EndQtr_DATE AS VARCHAR) + ', PrevBeginQtr_DATE = ' + CAST(@Ld_PrevBeginQtr_DATE AS VARCHAR) + ', PrevEndQtr_DATE = ' + CAST(@Ld_PrevEndQtr_DATE AS VARCHAR) + ', TypeReport_CODE = ' + @Lc_TypeReport_CODE;
   EXECUTE BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS
    @Ac_Job_ID            = @Lc_Job_ID,
    @Ad_Run_DATE          = @Ld_Run_DATE,
    @Ad_BeginQtr_DATE     = @Ld_BeginQtr_DATE,
    @Ad_EndQtr_DATE       = @Ld_EndQtr_DATE,
    @Ad_PrevBeginQtr_DATE = @Ld_PrevBeginQtr_DATE,
    @Ad_PrevEndQtr_DATE   = @Ld_PrevEndQtr_DATE,
    @Ac_TypeReport_CODE   = @Lc_TypeReport_CODE,
    @AC_MSG_CODE          = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT  = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
    
   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   --Update the Log in BSTL_Y1 as the Job is suceeded.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'') + ', ProcessedRecordCount_QNTY = ' + '1';   
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE             = @Ld_Run_DATE,
    @Ad_Start_DATE           = @Ld_Start_DATE,
    @Ac_Job_ID               = @Lc_Job_ID,
    @As_Process_NAME         = @Ls_Process_NAME,
    @As_Procedure_NAME       = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT  = '',
    @As_ExecLocation_TEXT    = @Lc_Successful_TEXT,
    @As_ListKey_TEXT         = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT= @Lc_Space_TEXT,
    @Ac_Status_CODE          = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID            = @Lc_BatchRunUser_TEXT,
	@An_ProcessedRecordCount_QNTY = 1;
   COMMIT TRANSACTION O34Quarterly_TRAN;
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION O34Quarterly_TRAN;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   IF @Ln_Error_NUMB <> 50001
   BEGIN
	 SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
   END		

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Process_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;
   
   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
       
  END CATCH;
 END;


GO
