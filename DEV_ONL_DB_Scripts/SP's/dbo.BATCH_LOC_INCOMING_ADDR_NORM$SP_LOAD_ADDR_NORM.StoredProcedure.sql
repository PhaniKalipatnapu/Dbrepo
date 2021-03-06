/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_ADDR_NORM$SP_LOAD_ADDR_NORM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_INCOMING_ADDR_NORM$SP_LOAD_ADDR_NORM

Programmer Name 	: IMP Team

Description			: This process reads the incoming normalized addresses and loads the data to a temporary normalized address load (LADRN_Y1) table. 

Frequency			: 'Weekly'

Developed On		: 

Called BY			: None

Called On			: 
------------------------------------------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0	
------------------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_ADDR_NORM$SP_LOAD_ADDR_NORM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_Yes_TEXT               CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_RecTypeA_TEXT          CHAR(1) = 'A',
          @Lc_RecTypeO_TEXT          CHAR(1) = 'O',
          @Lc_Zero_TEXT              CHAR(1) = '0',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB9011',-- TODO : confirm @Lc_Job_ID value with Rajkumar.
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_ADDR_NORM',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_ADDR_NORM';
  DECLARE @Ln_Zero_NUMB                 NUMERIC(1) = 0,
          @Ln_CommitFreq_QNTY           NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY   NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY NUMERIC(6) = 0,
          @Ln_Error_NUMB                NUMERIC(11),
          @Ln_ErrorLine_NUMB            NUMERIC(11),
          @Lc_Msg_CODE                  CHAR(1) = '',
          @Ls_File_NAME                 VARCHAR(60),
          @Ls_FileLocation_TEXT         VARCHAR(80),
          @Ls_FileSource_TEXT           VARCHAR(130),
          @Ls_SqlStmnt_TEXT             VARCHAR(200) = '',
          @Ls_Sql_TEXT                  VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT       VARCHAR(200),
          @Ls_Sqldata_TEXT              VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT     VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT         VARCHAR(4000) = '',
          @Ld_Run_DATE                  DATE,
          @Ld_Start_DATE                DATE,
          @Ld_LastRun_DATE              DATETIME2;

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Creating Temperory Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   -- Drop temporary table if exists
   IF OBJECT_ID('tempdb..#LoadAddressNorm_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadAddressNorm_P1;
    END

   CREATE TABLE #LoadAddressNorm_P1
    (
      LineData_TEXT VARCHAR(180)
    );

   /*Get the current run date and last run date from the Parameter (PARM_Y1) table, and validate that the batch program was not executed for the current run date. 
   Otherwise, an error message to that effect will be written into the Batch Status Log (BSTL_Y1) table, and the process will terminate */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ld_LastRun_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF @Ld_LastRun_DATE > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   -- Assign the Source File Location
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'FileSource_TEXT = ' + @Ls_FileSource_TEXT;

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_ErrorMessage_TEXT ='FILE LOCATION AND NAMES DO NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'BULK INSERT #LoadAddressNorm_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadAddressNorm_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStmnt_TEXT);

   --Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:
   --Transaction begins
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   BEGIN TRANSACTION ADDRNORM_LOAD;

   --Check for Record Count is same as records in Trailer.
   SET @Ls_Sql_TEXT = 'SELECT TMP_LOAD_NORM_TABLE - DETAILS COUNT';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT (1)
     FROM #LoadAddressNorm_P1
    WHERE SUBSTRING(LineData_TEXT, 1, 1) IN (@Lc_RecTypeA_TEXT, @Lc_RecTypeO_TEXT);

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     --Delete Processed Records in LOAD job:
     SET @Ls_Sql_TEXT ='DELETE PROCESSED RECORDS IN LADRN_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Process_INDC = ' + @Lc_Yes_TEXT;

     DELETE LADRN_Y1
      WHERE Process_INDC = @Lc_Yes_TEXT;

     --Read the ADDRESS-EXTRACT.TXT and insert all incoming data to LADRN_Y1 table.
     SET @Ls_Sql_TEXT = 'INSERT LADRN_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

     INSERT INTO LADRN_Y1
                 (TypeRecord_CODE,
                  MemberMci_IDNO,
                  OtherParty_IDNO,
                  AddrOthpType_CODE,
                  TransactionEventSeq_NUMB,
                  Line1_ADDR,
                  Line2_ADDR,
                  City_ADDR,
                  State_ADDR,
                  Zip_ADDR,
                  Country_ADDR,
                  Normalization_CODE,
                  Process_INDC)
     SELECT (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 1, 1), @Lc_Space_TEXT))),-- Record Type.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 2, 10), @Lc_Space_TEXT))),-- Member Mci.
            @Lc_Zero_TEXT,
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 12, 1), @Lc_Space_TEXT))),-- Address Type.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 13, 19), @Lc_Space_TEXT))),-- Transaction Event Seq Numb.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 32, 50), @Lc_Space_TEXT))),-- Line1 Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 82, 50), @Lc_Space_TEXT))),-- Line2 Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 132, 28), @Lc_Space_TEXT))),-- City Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 160, 2), @Lc_Space_TEXT))),-- State Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 162, 15), @Lc_Space_TEXT))),-- Zip Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 177, 2), @Lc_Space_TEXT))),-- Country Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 179, 1), @Lc_Space_TEXT))),-- Normalization Return Code.
            @Lc_ProcessN_INDC-- Process_INDC. 
       FROM #LoadAddressNorm_P1 l
      WHERE SUBSTRING(l.LineData_TEXT, 1, 1) = @Lc_RecTypeA_TEXT
     UNION
     SELECT (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 1, 1), @Lc_Space_TEXT))),-- Record Type.
            @Lc_Zero_TEXT,
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 2, 9), @Lc_Space_TEXT))),-- Othp IDNO.			
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 12, 1), @Lc_Space_TEXT))),-- Address Type.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 13, 19), @Lc_Space_TEXT))),-- Transaction Event Seq Numb.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 32, 50), @Lc_Space_TEXT))),-- Line1 Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 82, 50), @Lc_Space_TEXT))),-- Line2 Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 132, 28), @Lc_Space_TEXT))),-- City Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 160, 2), @Lc_Space_TEXT))),-- State Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 162, 15), @Lc_Space_TEXT))),-- Zip Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 177, 2), @Lc_Space_TEXT))),-- Country Addr.
            (RTRIM(ISNULL(SUBSTRING(l.LineData_TEXT, 179, 1), @Lc_Space_TEXT))),-- Normalization Return Code.
            @Lc_ProcessN_INDC-- Process_INDC. 
       FROM #LoadAddressNorm_P1 l
      WHERE SUBSTRING(l.LineData_TEXT, 1, 1) = @Lc_RecTypeO_TEXT;
    END
   ELSE
    BEGIN
     --If no record is present in the input file, then record the error ‘E0944 – No Record(s) to Process” into the Batch error (BATE_Y1) table.
     SET @Ls_Sql_TEXT = 'NO RECORD(S) TO PROCESS';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorWarning_CODE + ', Line_NUMB = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorE0944_CODE + ', DescriptionError_TEXT = ' + @Ls_Sql_TEXT + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT;

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
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   --Update the last run date in the PARM_Y1 table with the current run date upon successful completion.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR)

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Log the error encountered or successful completion in BSTL_Y1 for future references.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Drop Temperory Table.
   SET @Ls_Sql_TEXT = 'DROP TABLE #LoadAddressNorm_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   DROP TABLE #LoadAddressNorm_P1;

   --Commit the transaction
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   COMMIT TRANSACTION ADDRNORM_LOAD;
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ADDRNORM_LOAD;
    END

   -- Check if global temporary table exists drop the table
   IF OBJECT_ID('tempdb..#LoadAddressNorm_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadAddressNorm_P1;
    END

   -- Check for Exception information to log the description text based on the error
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

   --Update the Log in BSTL_Y1 as the Job is failed.
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
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
