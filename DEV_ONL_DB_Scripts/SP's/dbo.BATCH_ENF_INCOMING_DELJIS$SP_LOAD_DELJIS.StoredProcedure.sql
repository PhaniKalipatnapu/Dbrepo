/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_DELJIS$SP_LOAD_DELJIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_INCOMING_DELJIS$SP_LOAD_DELJIS
Programmer Name 	: IMP Team
Description			: The procedure BATCH_ENF_INCOMING_DELJIS$SP_LOAD_DELJIS reads the incoming file 
					  from Delaware Criminal Justice Information System (DELJIS)
                      which contains incarceration, parole and probation information 
                      from Delaware Department of Corrections (DOC)
                      on Non-Custodial Parent (NCP) address and the Capias Issued flag for the NCP from courts.
Frequency			: 'WEEKLY'
Developed On		: 05/02/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_DELJIS$SP_LOAD_DELJIS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE  CHAR(1) = 'A',
          @Lc_ProcessY_INDC           CHAR(1) = 'Y',
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_No_INDC                 CHAR(1) = 'N',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_Job_ID                  CHAR(7) = 'DEB8085',
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT    CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_DELJIS',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_ENF_INCOMING_DELJIS';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_BulkInsertSql_TEXT          VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(2000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE #LoadDeljis_P1';

   CREATE TABLE #LoadDeljis_P1
    (
      Record_TEXT CHAR(1534)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_LOAD_DELJIS';

   BEGIN TRANSACTION TXN_LOAD_DELJIS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF LEN(@Ls_FileSource_TEXT) = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_BulkInsertSql_TEXT = 'BULK INSERT #LoadDeljis_P1 FROM ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_SqlData_TEXT = '';

   EXEC (@Ls_BulkInsertSql_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadDeljis_P1 - DETAILS COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_RecordCount_QNTY = COUNT(1)
     FROM #LoadDeljis_P1 A;

   SET @Ls_Sql_TEXT='DELETE PROCESSED RECORDS FROM LDLJS_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE FROM LDLJS_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO LOAD INTO LDLJS_Y1';

   IF @Ln_RecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LDLJS_Y1';
     SET @Ls_SqlData_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

     INSERT INTO LDLJS_Y1
                 (MemberMci_IDNO,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Suffix_NAME,
                  Birth_DATE,
                  IssuingState_CODE,
                  LicenseNo_TEXT,
                  MemberSsn_NUMB,
                  Race_CODE,
                  MemberSex_CODE,
                  Case_IDNO,
                  Deljis_IDNO,
                  DeljisFirst_NAME,
                  DeljisLast_NAME,
                  DeljisMiddle_NAME,
                  DeljisSuffix_NAME,
                  DeljisBirth_DATE,
                  DeljisIssuingState_CODE,
                  DeljisLicenseNo_TEXT,
                  DeljisMemberSsn_NUMB,
                  DeljisRace_CODE,
                  DeljisMemberSex_CODE,
                  DeljisMatch_CODE,
                  DeljisWarrant_INDC,
                  DeljisWarrantIssue_DATE,
                  DeljisWarrantClear_DATE,
                  DeljisLine1Old_ADDR,
                  DeljisLine2Old_ADDR,
                  DeljisCityOld_ADDR,
                  DeljisStateOld_ADDR,
                  DeljisZipOld_ADDR,
                  DeljisInstitution_CODE,
                  DeljisFacility_NAME,
                  DeljisIncarceration_DATE,
                  DeljisMaximumRelease_DATE,
                  DeljisWorkRelease_INDC,
                  DeljisTypeSentence_CODE,
                  DeljisRelease_DATE,
                  DeljisReleaseComments_TEXT,
                  DeljisStatusInitiated_DATE,
                  DeljisOfficer_NAME,
                  DeljisOfficerLine1Old_ADDR,
                  DeljisOfficerLine2Old_ADDR,
                  DeljisOfficerCityOld_ADDR,
                  DeljisOfficerStateOld_ADDR,
                  DeljisOfficerZipOld_ADDR,
                  DeljisOfficerPhone_NUMB,
                  DeljisLine1NcpOld_ADDR,
                  DeljisLine2NcpOld_ADDR,
                  DeljisCityNcpOld_ADDR,
                  DeljisStateNcpOld_ADDR,
                  DeljisZipNcpOld_ADDR,
                  DeljisEmployer_NAME,
                  DeljisEmployerLine1Old_ADDR,
                  DeljisEmployerLine2Old_ADDR,
                  DeljisEmployerCityOld_ADDR,
                  DeljisEmployerStateOld_ADDR,
                  DeljisEmployerZipOld_ADDR,
                  DeljisNormalization_CODE,
                  DeljisLine1_ADDR,
                  DeljisLine2_ADDR,
                  DeljisCity_ADDR,
                  DeljisState_ADDR,
                  DeljisZip_ADDR,
                  OfficerNormalization_CODE,
                  DeljisOfficerLine1_ADDR,
                  DeljisOfficerLine2_ADDR,
                  DeljisOfficerCity_ADDR,
                  DeljisOfficerState_ADDR,
                  DeljisOfficerZip_ADDR,
                  NcpNormalization_CODE,
                  DeljisLine1Ncp_ADDR,
                  DeljisLine2Ncp_ADDR,
                  DeljisCityNcp_ADDR,
                  DeljisStateNcp_ADDR,
                  DeljisZipNcp_ADDR,
                  EmployerNormalization_CODE,
                  DeljisEmployerLine1_ADDR,
                  DeljisEmployerLine2_ADDR,
                  DeljisEmployerCity_ADDR,
                  DeljisEmployerState_ADDR,
                  DeljisEmployerZip_ADDR,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT ISNULL (SUBSTRING (LD.Record_TEXT, 1, 10), @Lc_Space_TEXT) AS MemberMci_IDNO,
            ISNULL (SUBSTRING (LD.Record_TEXT, 11, 40), @Lc_Space_TEXT) AS Last_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 51, 40), @Lc_Space_TEXT) AS First_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 91, 40), @Lc_Space_TEXT) AS Middle_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 131, 5), @Lc_Space_TEXT) AS Suffix_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 136, 8), @Lc_Space_TEXT) AS Birth_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 144, 2), @Lc_Space_TEXT) AS IssuingState_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 146, 12), @Lc_Space_TEXT) AS LicenseNo_TEXT,
            ISNULL (SUBSTRING (LD.Record_TEXT, 158, 9), @Lc_Space_TEXT) AS MemberSsn_NUMB,
            ISNULL (SUBSTRING (LD.Record_TEXT, 167, 2), @Lc_Space_TEXT) AS Race_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 169, 1), @Lc_Space_TEXT) AS MemberSex_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 170, 6), @Lc_Space_TEXT) AS Case_IDNO,
            ISNULL (SUBSTRING (LD.Record_TEXT, 176, 8), @Lc_Space_TEXT) AS Deljis_IDNO,
            ISNULL (SUBSTRING (LD.Record_TEXT, 184, 40), @Lc_Space_TEXT) AS DeljisFirst_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 224, 40), @Lc_Space_TEXT) AS DeljisLast_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 264, 40), @Lc_Space_TEXT) AS DeljisMiddle_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 304, 5), @Lc_Space_TEXT) AS DeljisSuffix_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 309, 8), @Lc_Space_TEXT) AS DeljisBirth_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 317, 2), @Lc_Space_TEXT) AS DeljisIssuingState_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 319, 25), @Lc_Space_TEXT) AS DeljisLicenseNo_TEXT,
            ISNULL (SUBSTRING (LD.Record_TEXT, 344, 9), @Lc_Space_TEXT) AS DeljisMemberSsn_NUMB,
            ISNULL (SUBSTRING (LD.Record_TEXT, 353, 1), @Lc_Space_TEXT) AS DeljisRace_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 354, 1), @Lc_Space_TEXT) AS DeljisMemberSex_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 355, 1), @Lc_Space_TEXT) AS DeljisMatch_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 356, 1), @Lc_Space_TEXT) AS DeljisWarrant_INDC,
            ISNULL (SUBSTRING (LD.Record_TEXT, 357, 8), @Lc_Space_TEXT) AS DeljisWarrantIssue_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 365, 8), @Lc_Space_TEXT) AS DeljisWarrantClear_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 373, 30), @Lc_Space_TEXT) AS DeljisLine1Old_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 403, 30), @Lc_Space_TEXT) AS DeljisLine2Old_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 433, 18), @Lc_Space_TEXT) AS DeljisCityOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 451, 2), @Lc_Space_TEXT) AS DeljisStateOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 453, 9), @Lc_Space_TEXT) AS DeljisZipOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 462, 2), @Lc_Space_TEXT) AS DeljisInstitution_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 464, 50), @Lc_Space_TEXT) AS DeljisFacility_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 514, 8), @Lc_Space_TEXT) AS DeljisIncarceration_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 522, 6), @Lc_Space_TEXT) AS DeljisMaximumRelease_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 528, 8), @Lc_Space_TEXT) AS DeljisWorkRelease_INDC,
            ISNULL (SUBSTRING (LD.Record_TEXT, 536, 1), @Lc_Space_TEXT) AS DeljisTypeSentence_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 537, 8), @Lc_Space_TEXT) AS DeljisRelease_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 545, 15), @Lc_Space_TEXT) AS DeljisReleaseComments_TEXT,
            ISNULL (SUBSTRING (LD.Record_TEXT, 560, 8), @Lc_Space_TEXT) AS DeljisStatusInitiated_DATE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 568, 50), @Lc_Space_TEXT) AS DeljisOfficer_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 618, 30), @Lc_Space_TEXT) AS DeljisOfficerLine1Old_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 648, 30), @Lc_Space_TEXT) AS DeljisOfficerLine2Old_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 678, 30), @Lc_Space_TEXT) AS DeljisOfficerCityOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 708, 2), @Lc_Space_TEXT) AS DeljisOfficerStateOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 710, 9), @Lc_Space_TEXT) AS DeljisOfficerZipOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 719, 10), @Lc_Space_TEXT) AS DeljisOfficerPhone_NUMB,
            ISNULL (SUBSTRING (LD.Record_TEXT, 729, 30), @Lc_Space_TEXT) AS DeljisLine1NcpOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 759, 30), @Lc_Space_TEXT) AS DeljisLine2NcpOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 789, 18), @Lc_Space_TEXT) AS DeljisCityNcpOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 807, 2), @Lc_Space_TEXT) AS DeljisStateNcpOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 809, 9), @Lc_Space_TEXT) AS DeljisZipNcpOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 818, 40), @Lc_Space_TEXT) AS DeljisEmployer_NAME,
            ISNULL (SUBSTRING (LD.Record_TEXT, 858, 30), @Lc_Space_TEXT) AS DeljisEmployerLine1Old_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 888, 30), @Lc_Space_TEXT) AS DeljisEmployerLine2Old_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 918, 18), @Lc_Space_TEXT) AS DeljisEmployerCityOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 936, 2), @Lc_Space_TEXT) AS DeljisEmployerStateOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 938, 9), @Lc_Space_TEXT) AS DeljisEmployerZipOld_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 951, 1), @Lc_Space_TEXT) AS DeljisNormalization_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 952, 50), @Lc_Space_TEXT) AS DeljisLine1_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1002, 50), @Lc_Space_TEXT) AS DeljisLine2_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1052, 28), @Lc_Space_TEXT) AS DeljisCity_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1080, 2), @Lc_Space_TEXT) AS DeljisState_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1082, 15), @Lc_Space_TEXT) AS DeljisZip_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1097, 1), @Lc_Space_TEXT) AS OfficerNormalization_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1098, 50), @Lc_Space_TEXT) AS DeljisOfficerLine1_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1148, 50), @Lc_Space_TEXT) AS DeljisOfficerLine2_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1198, 28), @Lc_Space_TEXT) AS DeljisOfficerCity_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1226, 2), @Lc_Space_TEXT) AS DeljisOfficerState_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1228, 15), @Lc_Space_TEXT) AS DeljisOfficerZip_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1243, 1), @Lc_Space_TEXT) AS NcpNormalization_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1244, 50), @Lc_Space_TEXT) AS DeljisLine1Ncp_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1294, 50), @Lc_Space_TEXT) AS DeljisLine2Ncp_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1344, 28), @Lc_Space_TEXT) AS DeljisCityNcp_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1372, 2), @Lc_Space_TEXT) AS DeljisStateNcp_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1374, 15), @Lc_Space_TEXT) AS DeljisZipNcp_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1389, 1), @Lc_Space_TEXT) AS EmployerNormalization_CODE,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1390, 50), @Lc_Space_TEXT) AS DeljisEmployerLine1_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1440, 50), @Lc_Space_TEXT) AS DeljisEmployerLine2_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1490, 28), @Lc_Space_TEXT) AS DeljisEmployerCity_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1518, 2), @Lc_Space_TEXT) AS DeljisEmployerState_ADDR,
            ISNULL (SUBSTRING (LD.Record_TEXT, 1520, 15), @Lc_Space_TEXT) AS DeljisEmployerZip_ADDR,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_No_INDC AS Process_INDC
       FROM #LoadDeljis_P1 LD;

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_LOAD_DELJIS';

   COMMIT TRANSACTION TXN_LOAD_DELJIS;

   SET @Ls_Sql_TEXT = 'DROP #LoadDeljis_P1';

   DROP TABLE #LoadDeljis_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_LOAD_DELJIS;
    END;

   IF OBJECT_ID('tempdb..#LoadDeljis_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDeljis_P1;
    END;

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
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
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
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
