/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_IVA_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_IVA_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This process is to read normalized address file and update the LIVAD_Y1 table.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
					BATCH_COMMON$SP_GET_ERROR_DESCRIPTION,
					BATCH_COMMON$SP_BATE_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_IVA_ADDRESS]
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  -- Common Variables
  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_Empty_TEXT             CHAR(1) = ' ',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB0320',
          @Lc_ErrorE0944_CODE        CHAR(18) = 'E0944',
          @Lc_Successful_INDC        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_IVA_ADDRESS',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   -- The Batch start time to use while inserting in to the batch log
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Creating Temporary Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadIvadFile_P1
    (
      Record_TEXT VARCHAR (2000)
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

   -- Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'Run_DATE AND LAST Run_DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   -- Assign the Source File Location
   SET @Ls_FileSource_TEXT = LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadIvadFile_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStmnt_TEXT);

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT = '';

   BEGIN TRANSACTION IVAD_LOAD;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM #LoadIvadFile_P1);

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     --Update Load table
     SET @Ls_Sql_TEXT = 'UPDATE LIVAD_Y1';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAD_Y1
        SET CpAddrNormalization_CODE = a.CpAddrNormalized_CODE,
            CpLine1_ADDR = a.CpLine1_ADDR,
            CpLine2_ADDR = a.CpLine2_ADDR,
            CpCity_ADDR = a.CpCity_ADDR,
            CpState_ADDR = a.CpState_ADDR,
            CpZip_ADDR = a.CpZip_ADDR,
            CpEmpAddrNormalization_CODE = a.CpEmpAddrNormalized_CODE,
            CpEmployerLine1_ADDR = a.CpEmployerLine1_ADDR,
            CpEmployerLine2_ADDR = a.CpEmployerLine2_ADDR,
            CpEmployerCity_ADDR = a.CpEmployerCity_ADDR,
            CpEmployerState_ADDR = a.CpEmployerState_ADDR,
            CpEmployerZip_ADDR = a.CpEmployerZip_ADDR,
            NcpAddrNormalization_CODE = a.NcpAddrNormalized_CODE,
            NcpLine1_ADDR = a.NcpLine1_ADDR,
            NcpLine2_ADDR = a.NcpLine2_ADDR,
            NcpCity_ADDR = a.NcpCity_ADDR,
            NcpState_ADDR = a.NcpState_ADDR,
            NcpZip_ADDR = a.NcpZip_ADDR,
            NcpEmpAddrNormalization_CODE = a.NcpEmpAddrNormalized_CODE,
            NcpEmployerLine1_ADDR = a.NcpEmployerLine1_ADDR,
            NcpEmployerLine2_ADDR = a.NcpEmployerLine2_ADDR,
            NcpEmployerCity_ADDR = a.NcpEmployerCity_ADDR,
            NcpEmployerState_ADDR = a.NcpEmployerState_ADDR,
            NcpEmployerZip_ADDR = a.NcpEmployerZip_ADDR
       FROM (SELECT (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 10), @Lc_Empty_TEXT))) AS Seq_IDNO,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 596, 1), @Lc_Empty_TEXT))) AS CpAddrNormalized_CODE,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 597, 50), @Lc_Empty_TEXT))) AS CpLine1_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 647, 50), @Lc_Empty_TEXT))) AS CpLine2_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 697, 28), @Lc_Empty_TEXT))) AS CpCity_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 725, 2), @Lc_Empty_TEXT))) AS CpState_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 727, 15), @Lc_Empty_TEXT))) AS CpZip_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 742, 1), @Lc_Empty_TEXT))) AS CpEmpAddrNormalized_CODE,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 743, 50), @Lc_Empty_TEXT))) AS CpEmployerLine1_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 793, 50), @Lc_Empty_TEXT))) AS CpEmployerLine2_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 843, 28), @Lc_Empty_TEXT))) AS CpEmployerCity_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 871, 2), @Lc_Empty_TEXT))) AS CpEmployerState_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 873, 15), @Lc_Empty_TEXT))) AS CpEmployerZip_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 888, 1), @Lc_Empty_TEXT))) AS NcpAddrNormalized_CODE,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 889, 50), @Lc_Empty_TEXT))) AS NcpLine1_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 939, 50), @Lc_Empty_TEXT))) AS NcpLine2_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 989, 28), @Lc_Empty_TEXT))) AS NcpCity_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1017, 2), @Lc_Empty_TEXT))) AS NcpState_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1019, 15), @Lc_Empty_TEXT))) AS NcpZip_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1034, 1), @Lc_Empty_TEXT))) AS NcpEmpAddrNormalized_CODE,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1035, 50), @Lc_Empty_TEXT))) AS NcpEmployerLine1_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1085, 50), @Lc_Empty_TEXT))) AS NcpEmployerLine2_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1135, 28), @Lc_Empty_TEXT))) AS NcpEmployerCity_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1163, 2), @Lc_Empty_TEXT))) AS NcpEmployerState_ADDR,
                    (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1165, 15), @Lc_Empty_TEXT))) AS NcpEmployerZip_ADDR
               FROM #LoadIvadFile_P1) a
      WHERE LIVAD_Y1.Seq_IDNO = a.Seq_IDNO;

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

     IF @Ln_ProcessedRecordCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE LIVAD_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
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

   --Update the Parameter Table with the Job Run Date as the current system date
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

   -- Update the Log in BSTL_Y1 as the Job is succeeded.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
    @As_ListKey_TEXT              = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   -- Drop Temporary Table
   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = '';

   -- Drop Temporary Table
   IF OBJECT_ID('tempdb..#LoadIvadFile_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadIvadFile_P1;
    END

   -- Transaction Ends
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = '';

   COMMIT TRANSACTION IVAD_LOAD;
  END TRY

  -- Exception Begins
  BEGIN CATCH
   -- Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:
   -- If Transaction is not committed, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVAD_LOAD;
    END

   -- Drop Temporary Table
   IF OBJECT_ID('tempdb..#LoadIvadFile_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadIvadFile_P1;
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
