/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_ERRORS$SP_LOAD_CSENET_ERRORS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_ERRORS$SP_LOAD_CSENET_ERRORS
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_LOC_INCOMING_CSENET_ERRORS$SP_FILE_LOAD reads the data received from CSNET Error File and loads into
					table LCSER_Y1 for further processing.  If an Error occurred,error message will be written into Batch Status_CODE Log
                    (BSTL screen/BSTL table) and the file processing will be terminated.
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_ERRORS$SP_LOAD_CSENET_ERRORS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_No_INDC                      CHAR(1) = 'N',
          @Lc_Yes_INDC                     CHAR(1) = 'Y',
          @Lc_TypeErrorWarning_CODE        CHAR(1) = 'W',
          @Lc_StatusAbnormalend_CODE       CHAR(1) = 'A',
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_BatchRunUser_TEXT            CHAR(5) = 'BATCH',
          @Lc_NoRecordsToProcessE0944_CODE CHAR(5) = 'E0944',
          @Lc_Job_ID                       CHAR(7) = 'DEB0340',
          @Lc_Successful_TEXT              CHAR(20) = 'SUCCESSFUL',
          @Lc_Procedure_NAME               CHAR(21) = 'SP_LOAD_CSENET_ERRORS',
          @Lc_Process_NAME                 CHAR(31) = 'BATCH_CI_INCOMING_CSENET_ERRORS';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(10),
          @Ln_RecordCount_NUMB            NUMERIC(10) = 0,
          @Ln_RowCount_NUMB               NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(100),
          @Ls_SqlStmnt_TEXT               VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   --create temporary local load table 
   CREATE TABLE #LoadCsenet_P1
    (
      Record_TEXT VARCHAR (158)
    );

   BEGIN TRANSACTION CsnetErrors;

   /* Get the current run date and last run date from  Parameters table (PARM_Y1)*/
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     RAISERROR(50001,16,1);
    END;

   --Validation: Check whether the Batch already ran for the day        
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END;

   --Delete the processed records from the temporary table, LCSER_Y1  
   SET @Ls_Sql_TEXT = 'DELETE LCSER_Y1';
   SET @Ls_Sqldata_TEXT = 'PROCESS_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   DELETE FROM LCSER_Y1
    WHERE PROCESS_INDC = @Lc_Yes_INDC;

   --Load data into temp table    
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadCsenet_P1 FROM  ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE ';
   SET @Ls_Sqldata_TEXT = 'SqlStmnt_TEXT = ' + ISNULL(@Ls_SqlStmnt_TEXT, '');

   EXEC (@Ls_SqlStmnt_TEXT);

   SET @Ln_RowCount_NUMB = (SELECT COUNT(1)
                              FROM #LoadCsenet_P1 a);

   IF @Ln_RowCount_NUMB <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LCSER_Y1';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

     INSERT INTO LCSER_Y1
                 (Sequence_NUMB,
                  InStateFips_CODE,
                  IVDOutOfStateFips_CODE,
                  Case_IDNO,
                  IVDOutOfStateCase_ID,
                  Action_CODE,
                  Function_CODE,
                  Reason_CODE,
                  ActionResolution_DATE,
                  Transaction_DATE,
                  Error_CODE,
                  TransactionSerial_NUMB,
                  ErrorMessage_TEXT,
                  Run_DATE,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 1, 6))), '000000') AS Sequence_NUMB,--Sequence_NUMB
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 8, 7))), '') AS InStateFips_CODE,--InStateFips_CODE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 16, 7))), '') AS IVDOutOfStateFips_CODE,--IVDOutOfStateFips_CODE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 24, 15))), '') AS Case_IDNO,--Case_IDNO
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 40, 15))), '') AS IVDOutOfStateCase_ID,--IVDOutOfStateCase_ID
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 56, 1))), '') AS Action_CODE,--Action_CODE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 58, 3))), '') AS Function_CODE,--Function_CODE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 62, 5))), '') AS Reason_CODE,--Reason_CODE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 68, 8))), '') AS ActionResolution_DATE,--ActionResolution_DATE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 77, 8))), '') AS Transaction_DATE,--Transaction_DATE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 86, 4))), '') AS Error_CODE,--Error_CODE
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 91, 12))), '') AS TransactionSerial_NUMB,--TransactionSerial_NUMB
            ISNULL((RTRIM(SUBSTRING(Ld.Record_TEXT, 104, 41))), '') AS ErrorMessage_TEXT,--ErrorMessage_TEXT
            @Ld_Run_DATE AS Run_DATE,--Run_DATE
            @Ld_Run_DATE AS FileLoad_DATE,--FileLoad_DATE
            @Lc_No_INDC AS Process_INDC --Process_INDC
       FROM #LoadCsenet_P1 Ld;

	 SET @Ln_RowCount_NUMB = @@ROWCOUNT;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT ='';
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RecordCount_NUMB AS VARCHAR), '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_ErrorMessage_TEXT, '') + ', Error_CODE = ' + ISNULL(@Lc_NoRecordsToProcessE0944_CODE, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_RecordCount_NUMB,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcessE0944_CODE,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END;

   -- Drop  temporary table after successful process 
   SET @Ls_Sql_TEXT = ' DROP #LoadCsenet_P1';

   DROP TABLE #LoadCsenet_P1;

   --Update the last run date in the PARM_Y1 table with the current run date upon successful completion.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE  ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   --Update the Log in BSTL_Y1 as the Job is succeeded.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_RowCount_NUMB AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_RowCount_NUMB;

   COMMIT TRANSACTION CsnetErrors;
  END TRY

  BEGIN CATCH
   --Close the Transaction     
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CsnetErrors;
    END

   --Drop temporary table   
   IF OBJECT_ID('tempdb..#LoadCsenet_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadCsenet_P1;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @LC_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @LC_Process_NAME,
    @As_Procedure_NAME            = @LC_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_RowCount_NUMB,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END;


GO
