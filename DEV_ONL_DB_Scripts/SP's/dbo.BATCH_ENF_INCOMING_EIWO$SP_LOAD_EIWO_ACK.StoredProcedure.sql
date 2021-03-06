/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_ACK]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_ACK
Programmer Name	:	IMP Team.
Description		:	This process is to read file and load the LEACK_Y1 table.
Frequency		:	
Developed On	:	01/20/2011
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_UPDATE_PARM_DATE,
                    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_ACK]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_Yes_INDC                CHAR(1) = 'Y',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_Process_INDC            CHAR(1) = 'N',
          @Lc_TypeErrorWarning_CODE   CHAR(1) = 'W',
          @Lc_FileHeaderRecord_TEXT   CHAR(3) = 'FHA',
          @Lc_FileTrailerRecord_TEXT  CHAR(3) = 'FTA',
          @Lc_BatchHeaderRecord_TEXT  CHAR(3) = 'BHA',
          @Lc_BatchTrailerRecord_TEXT CHAR(3) = 'BTA',
          @Lc_ErrorE0944_CODE         CHAR(5) = 'E0944',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_Job_ID                  CHAR(7) = 'DEB1290',
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_EIWO_ACK',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_ENF_INCOMING_EIWO';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TrailerRecordCount_NUMB     NUMERIC(11, 0),
          @Ln_RecordCount_NUMB            NUMERIC(11, 0),
          @Ln_BatchHeaderCount_NUMB       NUMERIC(11, 0),
          @Ln_BatchTrailerCount_NUMB      NUMERIC(11, 0),
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Ls_FileName_TEXT               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_LastRun_DATE                DATETIME2,
          @Ld_FileCreate_DATE             DATETIME2(0);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMPERORY TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadEiwoAck_P1
    (
      LineData_TEXT VARCHAR (573)
    );

   -- Selecting Date Run, Date Last Run, Commit Freq, Exception Threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_TEXT OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   -- Validation 1:Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Assign the Source File Location
   SET @Ls_FileSource_TEXT = LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_TEXT));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT ='FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadEiwoAck_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT = '';

   --Transaction begins
   BEGIN TRANSACTION LoadEiwoTran;

   SET @Ls_Sql_TEXT = 'CHECK FOR EMPTY INPUT FILE';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_RecordCount_NUMB = COUNT (1)
     FROM #LoadEiwoAck_P1 l;

   IF @Ln_RecordCount_NUMB != 0
    BEGIN
     -- Validation :Check for the File Create Date And Run Date
     SET @Ls_Sql_TEXT = 'SELECT LOAD TABLE - FILE CREATE DATE ';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ld_FileCreate_DATE = SUBSTRING (l.LineData_TEXT, 49, 8)
       FROM #LoadEiwoAck_P1 l
      WHERE SUBSTRING (l.LineData_TEXT, 1, 3) = @Lc_FileHeaderRecord_TEXT;

     SET @Ls_Sql_TEXT = 'FILE CREATION DATE AND RUN DATE VALIDATION';
     SET @Ls_Sqldata_TEXT = '';

     IF @Ld_FileCreate_DATE != @Ld_Run_DATE
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'FILE CREATION DATE IS NOT SAME AS THE RUN DATE';

       RAISERROR (50001,16,1);
      END;

     --Validation :Check for Record Count is same as records in File Trailer.
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT - BATCH COUNT';
      SET @Ls_Sqldata_TEXT = '';

      SELECT @Ln_TrailerRecordCount_NUMB = (SUBSTRING (l.LineData_TEXT, 26, 5))
        FROM #LoadEiwoAck_P1 l
       WHERE SUBSTRING (l.LineData_TEXT, 1, 3) = @Lc_FileTrailerRecord_TEXT;

      SET @Ls_Sql_TEXT = 'SELECT - TOTAL BATCH COUNT';
      SET @Ls_Sqldata_TEXT = '';

      SELECT @Ln_RecordCount_NUMB = COUNT (1) / 2
        FROM #LoadEiwoAck_P1 l
       WHERE SUBSTRING (l.LineData_TEXT, 1, 3) IN (@Lc_BatchHeaderRecord_TEXT, @Lc_BatchTrailerRecord_TEXT);

      SET @Ls_Sql_TEXT = 'CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN TRIALER';
      SET @Ls_Sqldata_TEXT = '';

      IF @Ln_RecordCount_NUMB != @Ln_TrailerRecordCount_NUMB
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'NO. OF BATCH RECORDS IN TRAILER DOESNT MATCH WITH SUM OF BATCH RECORDS.' + ' SUM OF BATCH RECORDS COUNT = ' + CAST (@Ln_RecordCount_NUMB AS VARCHAR) + '.BATCH RECORD COUNT IN TRAILER = ' + CAST (@Ln_TrailerRecordCount_NUMB AS VARCHAR);

        RAISERROR (50001,16,1);
       END
     END

     SET @Ls_Sql_TEXT = 'Check FILE HEADER RECORD';
     SET @Ls_Sqldata_TEXT = '';

     IF NOT EXISTS (SELECT 1
                      FROM #LoadEiwoAck_P1
                     WHERE SUBSTRING (LineData_TEXT, 1, 3) = @Lc_FileHeaderRecord_TEXT)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'FILE HEADER RECORD NOT FOUND';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'Check FILE TRAILER RECORD';
     SET @Ls_Sqldata_TEXT = '';

     IF NOT EXISTS (SELECT 1
                      FROM #LoadEiwoAck_P1
                     WHERE SUBSTRING (LineData_TEXT, 1, 3) = @Lc_FileTrailerRecord_TEXT)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'FILE TRAILER RECORD NOT FOUND';

       RAISERROR(50001,16,1);
      END

     --Validation :Check for Record Count is same as Batch Records in header.   
     SET @Ls_Sql_TEXT = 'Check for Record Count is same as Batch Records in header.';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_BatchHeaderCount_NUMB = COUNT(1)
       FROM #LoadEiwoAck_P1 l
      WHERE SUBSTRING(l.LineData_TEXT, 1, 3) = @Lc_BatchHeaderRecord_TEXT;

     SET @Ls_Sql_TEXT = 'Check for Record Count is same as Batch Records in Trailer.';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_BatchTrailerCount_NUMB = COUNT(1)
       FROM #LoadEiwoAck_P1 l
      WHERE SUBSTRING(l.LineData_TEXT, 1, 3) = @Lc_BatchTrailerRecord_TEXT;

     SET @Ls_Sql_TEXT = 'Check BATCH HEADER AND TRAILERS ARE NOT EQUAL';
     SET @Ls_Sqldata_TEXT = '';

     IF @Ln_BatchHeaderCount_NUMB ! = @Ln_BatchTrailerCount_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH HEADER AND TRAILERS ARE NOT EQUAL';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'DELETE LEACK_Y1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE LEACK_Y1
      WHERE Process_INDC = @Lc_Yes_INDC;

     SET @Ls_Sql_TEXT = 'INSERT LEACK_Y1';
     SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_Process_INDC, '');

     INSERT LEACK_Y1
            (DocumentAction_CODE,
             Case_IDNO,
             Fein_IDNO,
             LastNcp_NAME,
             FirstNcp_NAME,
             MiddleNcp_NAME,
             SuffixNcp_NAME,
             NcpSsn_NUMB,
             DocTrackNo_TEXT,
             Order_IDNO,
             Disp_CODE,
             RejReason_CODE,
             Termination_DATE,
             Line1Ncp_ADDR,
             Line2Ncp_ADDR,
             CityNcp_ADDR,
             StateNcp_ADDR,
             ZipNcp_ADDR,
             FinalPayment_DATE,
             FinalPay_AMNT,
             NewEmployer_NAME,
             Line1NewEmployer_ADDR,
             Line2NewEmployer_ADDR,
             CityNewEmployer_ADDR,
             StateNewEmployer_ADDR,
             ZipNewEmployer_ADDR,
             LumpSumPay_DATE,
             LumpSumPay_AMNT,
             DescriptionLumpSumPay_TEXT,
             PhoneNcp_NUMB,
             FirstError_NAME,
             SecondError_NAME,
             MultipleError_CODE,
             CorrectFein_IDNO,
             MultiIWOState_CODE,
             FileLoad_DATE,
             Process_INDC)
     SELECT (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 4, 3), @Lc_Empty_TEXT))) AS DocumentAction_CODE,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 7, 15), @Lc_Empty_TEXT))) AS Case_IDNO,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 22, 9), @Lc_Empty_TEXT))) AS Fein_IDNO,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 31, 20), @Lc_Empty_TEXT))) AS LastNcp_NAME,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 51, 15), @Lc_Empty_TEXT))) AS FirstNcp_NAME,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 66, 15), @Lc_Empty_TEXT))) AS MiddleNcp_NAME,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 81, 4), @Lc_Empty_TEXT))) AS SuffixNcp_NAME,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 85, 9), @Lc_Empty_TEXT))) AS NcpSsn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 94, 30), @Lc_Empty_TEXT))) AS DocTrackNo_TEXT,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 124, 30), @Lc_Empty_TEXT))) AS Order_IDNO,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 154, 2), @Lc_Empty_TEXT))) AS Disp_CODE,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 156, 3), @Lc_Empty_TEXT))) AS RejReason_CODE,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 160, 8), @Lc_Empty_TEXT))) AS Termination_DATE,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 168, 25), @Lc_Empty_TEXT))) AS Line1Ncp_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 193, 25), @Lc_Empty_TEXT))) AS Line2Ncp_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 218, 22), @Lc_Empty_TEXT))) AS CityNcp_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 240, 2), @Lc_Empty_TEXT))) AS StateNcp_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 242, 5), @Lc_Empty_TEXT))) + (RTRIM (ISNULL (SUBSTRING (LineData_TEXT, 247, 4), @Lc_Empty_TEXT))) AS ZipNcp_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 251, 8), @Lc_Empty_TEXT))) AS FinalPayment_DATE,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 259, 11), @Lc_Empty_TEXT))) AS FinalPay_AMNT,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 270, 57), @Lc_Empty_TEXT))) AS NewEmployer_NAME,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 327, 25), @Lc_Empty_TEXT))) AS Line1NewEmployer_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 352, 25), @Lc_Empty_TEXT))) AS Line2NewEmployer_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 377, 22), @Lc_Empty_TEXT))) AS CityNewEmployer_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 399, 2), @Lc_Empty_TEXT))) AS StateNewEmployer_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 401, 5), @Lc_Empty_TEXT))) + (RTRIM (ISNULL (SUBSTRING (LineData_TEXT, 406, 4), @Lc_Empty_TEXT))) AS ZipNewEmployer_ADDR,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 410, 8), @Lc_Empty_TEXT))) AS LumpSumPay_DATE,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 418, 11), @Lc_Empty_TEXT))) AS LumpSumPay_AMNT,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 429, 35), @Lc_Empty_TEXT))) AS DescriptionLumpSumPay_TEXT,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 464, 10), @Lc_Empty_TEXT))) AS PhoneNcp_NUMB,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 474, 32), @Lc_Empty_TEXT))) AS FirstError_NAME,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 506, 32), @Lc_Empty_TEXT))) AS SecondError_NAME,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 538, 1), @Lc_Empty_TEXT))) AS MultipleError_CODE,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 539, 9), @Lc_Empty_TEXT))) AS CorrectFein_IDNO,
            (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 548, 2), @Lc_Empty_TEXT))) AS MultiIWOState_CODE,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_Process_INDC AS Process_INDC
       FROM #LoadEiwoAck_P1 l
      WHERE SUBSTRING (l.LineData_TEXT, 1, 3) NOT IN (@Lc_FileHeaderRecord_TEXT, @Lc_FileTrailerRecord_TEXT, @Lc_BatchHeaderRecord_TEXT, @Lc_BatchTrailerRecord_TEXT);

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO UPDATE';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Drop Temperory Table 
   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = '';

   DROP TABLE #LoadEiwoAck_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = '';

   COMMIT TRANSACTION LoadEiwoTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LoadEiwoTran;
    END

   --Drop temporary table if exists
   IF OBJECT_ID('tempdb..#LoadEiwoAck_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadEiwoAck_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   -- Retrieve and log the Error Description.
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
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
