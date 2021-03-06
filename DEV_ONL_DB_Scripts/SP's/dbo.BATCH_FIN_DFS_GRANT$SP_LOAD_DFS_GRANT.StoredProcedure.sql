/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DFS_GRANT$SP_LOAD_DFS_GRANT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_DFS_GRANT$SP_LOAD_DFS_GRANT
Programmer Name   :	IMP Team
Description       :	This process reads the file sent by IV-E and moves the data to the temporary table.
Frequency         :	Monthly.
Developed On      :	11/29/2011
Called By         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DFS_GRANT$SP_LOAD_DFS_GRANT]
AS
 BEGIN
  --	SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  --	Variable Declarations After SET NOCOUNT ON Statement:
  -- Common Variables
  DECLARE @Lc_DetailRecord_CODE      CHAR(1) = 'D',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB6030',
          @Lc_ErrorE0944_CODE        CHAR(18) = 'E0944',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_DFS_GRANT',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_FIN_DFS_GRANT',
          @Ls_CursorLocation_TEXT    VARCHAR(200) = ' ';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   --Creating Temperory Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadDfsGrant_P1
    (
      Record_TEXT VARCHAR (48)
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
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Assign the Source File Location
   SET @Ls_FileSource_TEXT = LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadDfsGrant_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStmnt_TEXT);

   -- Transaction begins
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   BEGIN TRANSACTION DFSGRANT_LOAD;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM #LoadDfsGrant_P1 a
                                         WHERE SUBSTRING(Record_TEXT, 1, 1) = @Lc_DetailRecord_CODE);

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     --Delete Processed Records in LOAD job:
     SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS IN LFGRA_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

     DELETE LFGRA_Y1
      WHERE Process_INDC = @Lc_ProcessY_INDC;

     --Insert into Load table
     SET @Ls_Sql_TEXT = 'INSERT LFGRA_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

     INSERT INTO LFGRA_Y1
                 (Rec_ID,
                  ChildMci_IDNO,
                  ChildPid_IDNO,
                  ChidSsn_NUMB,
                  GrantYearMonth_NUMB,
                  Grant_AMNT,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 1), @Lc_Space_TEXT))),-- Record Id
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 2, 10), @Lc_Space_TEXT))),-- Child Mci
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 12, 10), @Lc_Space_TEXT))),-- Child PID
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 22, 9), @Lc_Space_TEXT))),-- Child SSN
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 31, 6), @Lc_Space_TEXT))),-- Month, year of Care
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 37, 12), @Lc_Space_TEXT))),-- Cost of Care
            @Ld_Run_DATE FileLoad_DATE,
            @Lc_ProcessN_INDC Process_INDC
       FROM #LoadDfsGrant_P1 a
      WHERE SUBSTRING(Record_TEXT, 1, 1) = @Lc_DetailRecord_CODE;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', File Name = ' + @Ls_File_NAME;

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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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

   --Drop Temperory Table
   SET @Ls_Sql_TEXT = 'DROP TEMPORARY TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE #LoadDfsGrant_P1;

   --Transaction Ends
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION DFSGRANT_LOAD;
  END TRY

  BEGIN CATCH
   ---If Transaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DFSGRANT_LOAD;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadDfsGrant_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDfsGrant_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
 END


GO
