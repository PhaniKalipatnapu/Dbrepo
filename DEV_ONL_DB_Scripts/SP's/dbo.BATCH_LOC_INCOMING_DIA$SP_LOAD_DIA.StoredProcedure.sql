/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DIA$SP_LOAD_DIA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_LOC_INCOMING_DIA$SP_LOAD_DIA
Programmer Name   : IMP Team
Description       : This Batch loads the information  from DIA(Division of Industrial Affairs) 
					into temperory load table.
Frequency         : Weekly
Developed On      : 01/17/2012
Called BY         : None
Called On		  : BATCH_COMMON$SP_GET_BATCH_DETAILS,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_UPDATE_PARM_DATE,
                    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DIA$SP_LOAD_DIA]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_HeaderRecord_CODE      CHAR(3) = 'HDR',
          @Lc_TrailerRecord_CODE     CHAR(3) = 'TOT',
          @Lc_ErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB8109',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'BATCH_LOC_INCOMING_DIA$SP_LOAD_DIA',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_DIA$SP_LOAD_DIA';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_TrailerRecord_NUMB          NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_FileHeaderDate_TEXT         CHAR(8),
          @Lc_FileTrailerDate_TEXT        CHAR(8),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadDia_P1
    (
      Record_TEXT VARCHAR (1238)
    );

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

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
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST (@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_FileSource_TEXT = LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = @Lc_Space_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadDia_P1  FROM  ''' + LTRIM(RTRIM(@Ls_FileSource_TEXT)) + '''';

   EXEC (@Ls_SqlStmnt_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT #LoadDia_P1 - FILE HEADER DATE ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   SELECT @Lc_FileHeaderDate_TEXT = SUBSTRING (Record_TEXT, 4, 8)
     FROM #LoadDia_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 3) = @Lc_HeaderRecord_CODE;

   SET @Ls_Sql_TEXT = 'SELECT #LoadDia_P1 - FILE TRAILER DATE ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   SELECT @Lc_FileTrailerDate_TEXT = SUBSTRING (Record_TEXT, 4, 8)
     FROM #LoadDia_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 3) = @Lc_HeaderRecord_CODE;

   SET @Ls_Sql_TEXT = 'FILE TRANSACTION DATE AND TRAILER DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   IF @Lc_FileHeaderDate_TEXT <> @Lc_FileTrailerDate_TEXT
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'FILE TRANSACTION DATE IS NOT SAME AS THE TRAILER DATE';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'SELECT #LoadDia_P1 - TRAILER COUNT';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_TrailerRecord_NUMB = CAST((SUBSTRING (Record_TEXT, 12, 11)) AS NUMERIC)
     FROM #LoadDia_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 3) = @Lc_TrailerRecord_CODE;

   SET @Ls_Sql_TEXT = 'SELECT #LoadDia_P1 - DETAILS COUNT';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT (1)
     FROM #LoadDia_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 3) NOT IN (@Lc_TrailerRecord_CODE, @Lc_HeaderRecord_CODE);

   SET @Ls_Sql_TEXT = 'CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN TRIALER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   IF @Ln_ProcessedRecordCount_QNTY != @Ln_TrailerRecord_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO. OF RECORDS IN TRAILER DOESNT MATCH WITH SUM OF DETAIL RECORDS. DETAIL RECORD COUNT = ' + CAST (@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', TRAILER RECORD COUNT = ' + CAST (@Ln_TrailerRecord_NUMB AS VARCHAR);

     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION DIA_LOAD;

   SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS FROM LDIAL_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   DELETE LDIAL_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   IF @Ln_ProcessedRecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO LDIAL_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

     INSERT INTO LDIAL_Y1
                 (InsuranceMatchRecord_NUMB,
                  DiaCase_IDNO,
                  DiaInsurer_IDNO,
                  Insurer_NAME,
                  InsurerLine1Old_ADDR,
                  InsurerLine2Old_ADDR,
                  InsurerCityOld_ADDR,
                  InsurerStateOld_ADDR,
                  InsurerZipOld_ADDR,
                  InsurerClaim_NUMB,
                  ClaimLoss_DATE,
                  First_NAME,
                  Middle_NAME,
                  Last_NAME,
                  MemberSsn_NUMB,
                  Birth_DATE,
                  ClaimantLine1Old_ADDR,
                  ClaimantLine2Old_ADDR,
                  ClaimantCityOld_ADDR,
                  ClaimantStateOld_ADDR,
                  ClaimantZipOld_ADDR,
                  Employer_NAME,
                  EmployerLine1Old_ADDR,
                  EmployerLine2Old_ADDR,
                  EmployerCityOld_ADDR,
                  EmployerStateOld_ADDR,
                  EmployerZipOld_ADDR,
                  InsurerAddressNormalization_CODE,
                  InsurerLine1_ADDR,
                  InsurerLine2_ADDR,
                  InsurerCity_ADDR,
                  InsurerState_ADDR,
                  InsurerZip_ADDR,
                  ClaimantAddressNormalization_CODE,
                  ClaimantLine1_ADDR,
                  ClaimantLine2_ADDR,
                  ClaimantCity_ADDR,
                  ClaimantState_ADDR,
                  ClaimantZip_ADDR,
                  EmployerAddressNormalization_CODE,
                  EmployerLine1_ADDR,
                  EmployerLine2_ADDR,
                  EmployerCity_ADDR,
                  EmployerState_ADDR,
                  EmployerZip_ADDR,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1, 6), @Lc_Space_TEXT))) AS InsuranceMatchRecord_NUMB,-- InsuranceMatchRecord_IDNO
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 7, 10), @Lc_Space_TEXT))) AS DiaCase_IDNO,--  Case_IDNO
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 17, 4), @Lc_Space_TEXT))) AS DiaInsurer_IDNO,--  Insurer_IDNO
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 21, 50), @Lc_Space_TEXT))) AS Insurer_NAME,--  Insurer_NAME
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 71, 30), @Lc_Space_TEXT))) AS InsurerLine1Old_ADDR,-- InsLine1_ADDR old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 101, 30), @Lc_Space_TEXT))) AS InsurerLine2Old_ADDR,--  InsLine2_ADDR old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 131, 28), @Lc_Space_TEXT))) AS InsurerCityOld_ADDR,--  InsCity_ADDR old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 159, 2), @Lc_Space_TEXT))) AS InsurerStateOld_ADDR,--   InsState_ADDR old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 161, 10), @Lc_Space_TEXT))) AS InsurerZipOld_ADDR,--  InsZip_ADDR old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 171, 30), @Lc_Space_TEXT))) AS InsurerClaim_NUMB,--  InsClaim_NUMB
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 201, 8), @Lc_Space_TEXT))) AS ClaimLoss_DATE,--  ClaimLoss_DATE
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 209, 20), @Lc_Space_TEXT))) AS First_NAME,--  Claimant First_NAME
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 229, 5), @Lc_Space_TEXT))) AS Middle_NAME,--  Claimant Middle_NAME
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 234, 30), @Lc_Space_TEXT))) AS Last_NAME,--  Claimant Last_NAME
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 264, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,--  Claimant SSN
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 273, 8), @Lc_Space_TEXT))) AS Birth_DATE,--  Claimant Date of Birth
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 281, 50), @Lc_Space_TEXT))) AS ClaimantLine1Old_ADDR,--  Claimant Line 1 address old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 331, 50), @Lc_Space_TEXT))) AS ClaimantLine2Old_ADDR,--  Claimant Line 2 address old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 381, 28), @Lc_Space_TEXT))) AS ClaimantCityOld_ADDR,--  Claimant City old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 409, 2), @Lc_Space_TEXT))) AS ClaimantStateOld_ADDR,--  Claimant State old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 411, 10), @Lc_Space_TEXT))) AS ClaimantZipOld_ADDR,--  Claimant Zip Code old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 421, 60), @Lc_Space_TEXT))) AS Employer_NAME,--  DIA Employer Name
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 481, 50), @Lc_Space_TEXT))) AS EmployerLine1Old_ADDR,--  DIA Employer Line 1 Address old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 531, 50), @Lc_Space_TEXT))) AS EmployerLine2Old_ADDR,--  DIA Employer Line 2 Address old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 581, 28), @Lc_Space_TEXT))) AS EmployerCityOld_ADDR,--  DIA Employer City old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 609, 2), @Lc_Space_TEXT))) AS EmployerStateOld_ADDR,--  DIA Employer State old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 611, 10), @Lc_Space_TEXT))) AS EmployerZipOld_ADDR,--  DIA Employer Zip Code old
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 801, 1), @Lc_Space_TEXT))) AS InsurerAddressNormalization_CODE,-- InsurerNormalization_CODE
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 802, 50), @Lc_Space_TEXT))) AS InsurerLine1_ADDR,-- InsurerLine1_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 852, 50), @Lc_Space_TEXT))) AS InsurerLine2_ADDR,-- InsurerLine2_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 902, 28), @Lc_Space_TEXT))) AS InsurerCity_ADDR,-- InsurerCity_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 930, 2), @Lc_Space_TEXT))) AS InsurerState_ADDR,-- InsurerState_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 932, 15), @Lc_Space_TEXT))) AS InsurerZip_ADDR,-- InsurerZip_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 947, 1), @Lc_Space_TEXT))) AS ClaimantAddressNormalization_CODE,-- Claimant Normalization_CODE
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 948, 50), @Lc_Space_TEXT))) AS ClaimantLine1_ADDR,-- Claimant Line1_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 998, 50), @Lc_Space_TEXT))) AS ClaimantLine2_ADDR,-- Claimant Line2_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1048, 28), @Lc_Space_TEXT))) AS ClaimantCity_ADDR,--  Claimant City_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1076, 2), @Lc_Space_TEXT))) AS ClaimantState_ADDR,-- Claimant State_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1078, 15), @Lc_Space_TEXT))) AS ClaimantZip_ADDR,-- Claimant Zip ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1093, 1), @Lc_Space_TEXT))) AS EmployerAddressNormalization_CODE,-- EmployerNormalization_CODE
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1094, 50), @Lc_Space_TEXT))) AS EmployerLine1_ADDR,-- EmployerLine1_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1144, 50), @Lc_Space_TEXT))) AS EmployerLine2_ADDR,-- EmployerLine2_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1194, 28), @Lc_Space_TEXT))) AS EmployerCity_ADDR,-- EmployerCity_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1222, 2), @Lc_Space_TEXT))) AS EmployerState_ADDR,-- EmployerState_ADDR
            (RTRIM(ISNULL(SUBSTRING (Record_TEXT, 1224, 15), @Lc_Space_TEXT))) AS EmployerZip_ADDR,-- EmployerZip_ADDR
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_ProcessN_INDC AS Process_INDC
       FROM #LoadDia_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 3) NOT IN (@Lc_HeaderRecord_CODE, @Lc_TrailerRecord_CODE);
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

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

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   DROP TABLE #LoadDia_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION DIA_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRAN DIA_LOAD;
    END

   IF OBJECT_ID('tempdb..#LoadDia_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDia_P1;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
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
  END CATCH
 END


GO
