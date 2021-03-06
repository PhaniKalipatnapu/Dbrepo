/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_SETUP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_SETUP
Programmer Name	:	IMP Team.
Description		:	This process is to read file and load the LEEMP_Y1 table.
Frequency		:	
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS ,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_UPDATE_PARM_DATE,
                    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_SETUP]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_Process_INDC           CHAR(1) = 'N',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB6470',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_EIWO_SETUP',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_EIWO';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Ls_FileName_TEXT               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLoc_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_LastRun_DATE                DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadEiwo_P1
    (
      LineData_TEXT VARCHAR (600)
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

   IF @Ls_FileSource_TEXT = @Lc_Empty_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT ='FILE LOCATION AND NAMES DOES NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadEiwo_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);

   --Transaction begins
   SET @Ls_Sql_TEXT = 'BEGIN TRASACTION';
   SET @Ls_Sqldata_TEXT = '';

   BEGIN TRANSACTION LoadEiwoTran;

   --Delete all the rows in Load table before loading the data 
   SET @Ls_Sql_TEXT = 'DELETE LEEMP_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LEEMP_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'INSERT LEEMP_Y1';
   SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_Process_INDC, '');

   INSERT LEEMP_Y1
          (Fein_IDNO,
           IwoStart_DATE,
           Employer_NAME,
           EmployerLine1_ADDR,
           EmployerLine2_ADDR,
           EmployerCity_ADDR,
           EmployerState_ADDR,
           EmployerZip_ADDR,
           Contact_NAME,
           EmployerPhone_NUMB,
           EmployerPhoneExtension_NUMB,
           Employer_EML,
           FileLoad_DATE,
           Process_INDC,
           AlternateLine1_ADDR,
           AlternateLine2_ADDR,
           AlternateCity_ADDR,
           AlternateState_ADDR,
           AlternateZip_ADDR,
           FeinStatus_CODE,
           FeinStatus_DATE,
           Aka_NAME)
   SELECT (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 1, 9), @Lc_Empty_TEXT))) AS Fein_IDNO,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 10, 10), @Lc_Empty_TEXT))) AS IwoStart_DATE,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 20, 65), @Lc_Empty_TEXT))) AS Employer_NAME,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 85, 40), @Lc_Empty_TEXT))) AS EmployerLine1_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 125, 40), @Lc_Empty_TEXT))) AS EmployerLine2_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 165, 25), @Lc_Empty_TEXT))) AS EmployerCity_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 190, 2), @Lc_Empty_TEXT))) AS EmployerState_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 192, 10), @Lc_Empty_TEXT))) AS EmployerZip_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 202, 40), @Lc_Empty_TEXT))) AS Contact_NAME,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 242, 10), @Lc_Empty_TEXT))) AS EmployerPhone_NUMB,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 252, 5), @Lc_Empty_TEXT))) AS EmployerPhoneExtension_NUMB,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 257, 65), @Lc_Empty_TEXT))) AS Employer_EML,
          @Ld_Run_DATE AS FileLoad_DATE,
          @Lc_Process_INDC AS Process_INDC,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 322, 40), @Lc_Empty_TEXT))) AS AlternateLine1_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 362, 40), @Lc_Empty_TEXT))) AS AlternateLine2_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 402, 25), @Lc_Empty_TEXT))) AS AlternateCity_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 427, 2), @Lc_Empty_TEXT))) AS AlternateState_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 429, 10), @Lc_Empty_TEXT))) AS AlternateZip_ADDR,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 439, 1), @Lc_Empty_TEXT))) AS FeinStatus_CODE,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 440, 10), @Lc_Empty_TEXT))) AS FeinStatus_DATE,
          (RTRIM (ISNULL (SUBSTRING (l.LineData_TEXT, 450, 65), @Lc_Empty_TEXT))) AS Aka_NAME
     FROM #LoadEiwo_P1 l;

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_ProcessedRecordCount_QNTY = 0
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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Drop Temperory Table 
   DROP TABLE #LoadEiwo_P1;

   COMMIT TRANSACTION LoadEiwoTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LoadEiwoTran;
    END

   --Drop temporary table if exists
   IF OBJECT_ID('tempdb..#LoadEiwo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadEiwo_P1;
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
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
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
