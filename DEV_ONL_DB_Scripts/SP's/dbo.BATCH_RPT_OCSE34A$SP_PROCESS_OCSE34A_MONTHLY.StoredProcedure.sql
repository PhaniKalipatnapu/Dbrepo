/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE34A$SP_PROCESS_OCSE34A_MONTHLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Program Name      : BATCH_RPT_OCSE34A$SP_PROCESS_OCSE34A_MONTHLY
Programmer Name   : IMP Team
Description       : The process loads OCSE34A - Report Monthly
Frequency         : MONTHLY/QUATERLY
Developed On      : 09/13/2011
Called BY         : None
Called Procedures : BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS
----------------------------------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
----------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE34A$SP_PROCESS_OCSE34A_MONTHLY]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE      CHAR (1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR (1) = 'A',
          @Lc_StatusSuccess_CODE     CHAR (1) = 'S',
          @Lc_Job_ID                 CHAR (7) = 'DEB6390',
          @Lc_BatchRunUser_TEXT      CHAR (7) = 'BATCH',          
          @Lc_Successful_TEXT        CHAR (20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   VARCHAR (50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME			 VARCHAR (60) = 'BATCH_RPT_OCSE34A',          
          @Ls_Procedure_NAME         VARCHAR (60) = 'SP_PROCESS_OCSE34A_MONTHLY',
          @Ld_Start_DATE             DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_CommitFreqParm_QNTY     NUMERIC (5),
		  @Ln_ExceptionThresholdParm_QNTY NUMERIC (5),
          @Ln_Error_NUMB              NUMERIC (11),
          @Ln_ErrorLine_NUMB          NUMERIC (11),
          @Lc_Msg_CODE                CHAR (1),
          @Ls_Sql_TEXT                VARCHAR (100),
          @Ls_Sqldata_TEXT            VARCHAR (1000),
          @Ls_ErrorMessage_TEXT       VARCHAR (4000),
          @Ls_DescriptionError_TEXT   VARCHAR (4000),
          @Ld_Run_DATE                DATE,
          @Ld_LastRun_DATE            DATE,
          @Ld_EndQtr_DATE             DATE,
          @Ld_PreviousBeginQtr_DATE   DATE,
          @Ld_PreviousEndQtr_DATE     DATE,
          @Ld_BeginQtr_DATE           DATE;

  BEGIN TRY
   BEGIN TRANSACTION O34MONTHLY;
   /*
	Get the run date and last run date from PARM_Y1 table and validate that the batch program was not 
	executed for the run date by ensuring that the run date is different from the last run date in the 
	PARM_Y1 table.  Otherwise, an error message to that effect will be written into BSTL_Y1 
	table and terminate the process
   */	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Check whether the Job ran already.
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR(50001,16,1);
    END;
   --If the batch is run for monthly, batch is executed on the last day of the calendar month.	
   SET @Ld_BeginQtr_DATE = CONVERT(VARCHAR(10), DATEADD(dd, -(DAY(@Ld_Run_DATE) - 1), @Ld_Run_DATE), 120);
   SET @Ld_EndQtr_DATE = CONVERT(VARCHAR(10), DATEADD(dd, -(DAY(DATEADD(mm, 1, @Ld_BeginQtr_DATE))), DATEADD(mm, 1, @Ld_BeginQtr_DATE)), 120);
   SET @Ld_PreviousBeginQtr_DATE = DATEADD(mm, -1, @Ld_BeginQtr_DATE);
   SET @Ld_PreviousEndQtr_DATE = DATEADD(dd, -1, @Ld_BeginQtr_DATE);
   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', BeginQtr_DATE = ' + CAST(@Ld_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ld_EndQtr_DATE AS VARCHAR) + ', PrevBeginQtr_DATE = ' + CAST(@Ld_PreviousBeginQtr_DATE AS VARCHAR) + ', PrevEndQtr_DATE = ' + CAST(@Ld_PreviousEndQtr_DATE AS VARCHAR) + ', TypeReport_CODE = ' + 'I';
   EXECUTE BATCH_RPT_OCSE34A$SP_OCSE34_RECEIPT_LEVEL_DTLS
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_BeginQtr_DATE         = @Ld_BeginQtr_DATE,
    @Ad_EndQtr_DATE           = @Ld_EndQtr_DATE,
    @Ad_PrevBeginQtr_DATE     = @Ld_PreviousBeginQtr_DATE,
    @Ad_PrevEndQtr_DATE       = @Ld_PreviousEndQtr_DATE,
    @Ac_TypeReport_CODE       = 'I',
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
    
    --Update the Parameter table with the Job Run Date as the current system date
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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + '' + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + ' ' + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + '0';
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE             = @Ld_Run_DATE,
    @Ad_Start_DATE           = @Ld_Start_DATE,
    @Ac_Job_ID               = @Lc_Job_ID,
    @As_Process_NAME         = @Ls_Process_NAME,
    @As_Procedure_NAME       = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT  = '',
    @As_ExecLocation_TEXT    = @Lc_Successful_TEXT,
    @As_ListKey_TEXT         = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT= ' ',
    @Ac_Status_CODE          = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID            = @Lc_BatchRunUser_TEXT,
	@An_ProcessedRecordCount_QNTY = 1;
    
   COMMIT TRANSACTION O34MONTHLY;
  END TRY

  BEGIN CATCH
  -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION O34MONTHLY;
    END
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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = '',
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
