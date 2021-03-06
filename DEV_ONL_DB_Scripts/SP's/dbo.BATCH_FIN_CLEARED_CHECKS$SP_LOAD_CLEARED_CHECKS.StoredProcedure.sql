/****** Object:  StoredProcedure [dbo].[BATCH_FIN_CLEARED_CHECKS$SP_LOAD_CLEARED_CHECKS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_CLEARED_CHECKS$SP_LOAD_CLEARED_CHECKS
Programmer Name 	: IMP Team
Description			: The process loads the Bank Reconciliation file from PNC Bank to the temporary table LCCLE_Y1 for
					  further processing. This file includes the daily cleared check information and monthly void and 
					  stop payment information.
Frequency			: 'DAILY'
Developed On		: 06/11/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_CLEARED_CHECKS$SP_LOAD_CLEARED_CHECKS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC                  CHAR(1) = 'N',
          @Lc_Yes_INDC                 CHAR(1) = 'Y',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE   CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE    CHAR(1) = 'W',
          @Lc_Detail_CODE              CHAR(1) = 'D',
          @Lc_Trailer_CODE             CHAR(1) = 'T',
          @Lc_ErrorNoRecordsE0944_CODE CHAR(5) = 'E0944',
          @Lc_Job_ID                   CHAR(7) = 'DEB0210',
          @Lc_Successful_TEXT          CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT        CHAR(30) = 'BATCH',
          @Lc_Process_NAME             CHAR(30) = 'BATCH_FIN_CLEARED_CHECKS',
          @Lc_Procedure_NAME           CHAR(30) = 'SP_LOAD_CLEARED_CHECKS',
          @Lc_NoRecordsToProcess_TEXT  CHAR(30) = 'NO RECORD(S) TO PROCESS';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10) = 0,
          @Ln_CursorPosition_QNTY         NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_DetailRecordCount_QNTY      NUMERIC(11),
          @Ln_TrailerRecordCount_QNTY     NUMERIC(11),
          @Ln_TotalRecordCount_QNTY       NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                VARCHAR(200) = '',
		  @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',          
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY

   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   CREATE TABLE #LoadClearedChecks_P1
    (
      Record_TEXT VARCHAR (80)
    );

   BEGIN TRANSACTION LoadCCLRTran;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   -- Delete the processed records from the LCCLE_Y1 table 
   SET @Ls_Sql_TEXT = 'DELETE FROM LCCLE_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

   DELETE LCCLE_Y1 
    WHERE Process_INDC = @Lc_Yes_INDC;

   SET @Ls_Sql_TEXT = 'LOAD DATA';
   SET @Ls_Sqldata_TEXT = 'BULK INSERT #LoadClearedChecks_P1 FROM ''' + @Ls_FileLocation_TEXT + @Ls_File_NAME + '''';

   EXECUTE ( 'BULK INSERT   
					#LoadClearedChecks_P1
				FROM ''' +@Ls_FileLocation_TEXT +@Ls_File_NAME +'''' );

   SET @Ls_Sql_TEXT = 'SELECT TOTAL RECORD COUNT';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_TotalRecordCount_QNTY = COUNT(1)
     FROM #LoadClearedChecks_P1 a;
   
  IF @Ln_TotalRecordCount_QNTY > 0
  BEGIN
   SET @Ls_Sql_TEXT = 'SELECT DETAIL RECORD COUNT';
   SET @Ls_Sqldata_TEXT = 'Detail Record Identifier = ' + @Lc_Detail_CODE;

   SELECT @Ln_DetailRecordCount_QNTY = COUNT(1)
     FROM #LoadClearedChecks_P1 a
    WHERE SUBSTRING(Record_TEXT, 1, 1) = @Lc_Detail_CODE;

   SET @Ln_RecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_DetailRecordCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'DETAIL RECORD NOT FOUND';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT TRAILER RECORD DETAIL COUNT';
   SET @Ls_Sqldata_TEXT = 'Trailer Record Identifier = ' + @Lc_Trailer_CODE;

   SELECT @Ln_TrailerRecordCount_QNTY = CONVERT(NUMERIC(11), SUBSTRING(Record_TEXT, 12, 6))
     FROM #LoadClearedChecks_P1 a
    WHERE SUBSTRING(Record_TEXT, 1, 1) = @Lc_Trailer_CODE;

   SET @Ln_RecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_RecordCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'TRAILER RECORD NOT FOUND';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DETAIL & TRAILER RECORD COUNT VALIDATION';
   SET @Ls_Sqldata_TEXT = 'DetailRecordCount_QNTY = ' + CAST(@Ln_DetailRecordCount_QNTY AS VARCHAR) + ', TrailerRecordCount_QNTY = ' + CAST(@Ln_TrailerRecordCount_QNTY AS VARCHAR);
   IF @Ln_DetailRecordCount_QNTY <> @Ln_TrailerRecordCount_QNTY
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'TRAILER RECORD COUNT AND DETAIL RECORD COUNT IN FILE ARE NOT MATCHING';

     RAISERROR (50001,16,1);
    END
   END 

   SET @Ls_Sql_TEXT = 'INSERT INTO LCCLE_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO LCCLE_Y1
               (AccountBankNo_TEXT,
                Rec_ID,
                PaidCheck_DATE,
                CheckSerial_NUMB,
                Check_AMNT,
                FileLoad_DATE,
                Process_INDC)
   SELECT SUBSTRING(Record_TEXT, 2, 10) AS AccountBankNo_TEXT,
          SUBSTRING(Record_TEXT, 12, 1) AS Rec_ID,
          SUBSTRING(Record_TEXT, 13, 8) AS PaidCheck_DATE,
          SUBSTRING(Record_TEXT, 21, 10) AS CheckSerial_NUMB,
          SUBSTRING(Record_TEXT, 31, 12) AS Check_AMNT,
          @Ld_Run_DATE AS FileLoad_DATE,
          @Lc_No_INDC AS Process_INDC
     FROM #LoadClearedChecks_P1 a
    WHERE SUBSTRING(Record_TEXT, 1, 1) = @Lc_Detail_CODE;

   SET @Ln_RecordCount_QNTY =@@ROWCOUNT;

   IF @Ln_RecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorWarning_CODE + ', DescriptionError_TEXT = ' + @Lc_NoRecordsToProcess_TEXT + ', Line_NUMB = ' + CAST(@Ln_CursorPosition_QNTY AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorNoRecordsE0944_CODE + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @As_DescriptionError_TEXT    = @Lc_NoRecordsToProcess_TEXT,
      @An_Line_NUMB                = @Ln_CursorPosition_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorNoRecordsE0944_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;
      
     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'SELECT LCCLE_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM LCCLE_Y1 a;

   -- Update the parameter table with the job run date AS the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Success full execution write to VBSTL
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Lc_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Commit the transaction
   COMMIT TRANSACTION LoadCCLRTran;

   --Drop the temporary table used to store data
   SET @Ls_Sql_TEXT = 'DROP TABLE #LoadClearedChecks_P1 - 2';
   SET @Ls_Sqldata_TEXT = '';
   DROP TABLE #LoadClearedChecks_P1;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LoadCCLRTran;
    END;

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..#LoadClearedChecks_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadClearedChecks_P1;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
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
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
