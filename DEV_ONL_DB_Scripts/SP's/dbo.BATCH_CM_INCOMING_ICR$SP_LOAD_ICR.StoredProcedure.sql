/****** Object:  StoredProcedure [dbo].[BATCH_CM_INCOMING_ICR$SP_LOAD_ICR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_CM_INCOMING_ICR$SP_LOAD_ICR]
AS
 /*
 --------------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_CM_INCOMING_ICR$SP_LOAD_ICR
 Programmer Name 	: IMP Team
 Description		: Process loads the incoming ICR response file to a temporary ICR response table, LIGCR_Y1 table.
 Frequency			:
 Developed On		: 3/3/2011
 Called By			:
 Called On       	:
 ---------------------------------------------------------------------------------------------------------------------   
 Modified By		:
 Modified On		:
 Version No			: 1.0
 --------------------------------------------------------------------------------------------------------------------
 */
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusAbnormalend_CODE CHAR = 'A',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB9304',
          @Lc_Successful_INDC        CHAR(20) = 'SUCCESSFUL',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_CM_INCOMING_ICR',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_ICR';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_NUMB            NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_Sql_TEXT                    VARCHAR(200),
          @Ls_SqlStatement_TEXT           VARCHAR(200),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadIcr_P1
    (
      Record_TEXT VARCHAR (550)
    );

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
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST (@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_FileSource_TEXT = LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = @Lc_Space_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT ='FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   SET @Ls_SqlStatement_TEXT = 'BULK INSERT #LoadIcr_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStatement_TEXT);

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   BEGIN TRANSACTION IcrLoad;

   --Delete the Load Table Data
   SET @Ls_Sql_TEXT = 'DELETE LIGCR_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE FROM LIGCR_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'SELECT LIGCR_Y1 ';
   SET @Ls_Sqldata_TEXT = 'PROCESSED RECORD COUNT = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR(20));

   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM #LoadIcr_P1 L;

   IF @Ln_ProcessedRecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LIGCR_Y1';
     SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '') + ', Process_INDC = ' + ISNULL('N', '');

     --Insert into Load table
     INSERT INTO LIGCR_Y1
                 (Case_IDNO,
                  RespondInit_CODE,
                  StateFips_CODE,
                  County_IDNO,
                  OfficeFips_CODE,
                  MemberSsn_NUMB,
                  MemberMci_IDNO,
                  CaseRelationship_CODE,
                  StatusCase_CODE,
                  SentLast_NAME,
                  SentFirst_NAME,
                  SentMiddle_NAME,
                  SentBirth_DATE,
                  SentMemberSex_CODE,
                  SentIVDOutOfStateCase_IDNO,
                  SentIVDOutOfStateFips_CODE,
                  SentIVDOutOfStateCountyFips_CODE,
                  IVDOutOfStateOfficeFips_CODE,
                  SentContact_NAME,
                  SentPhoneContact_NUMB,
                  SentContact_EML,
                  IcrStatus_INDC,
                  Reason1_CODE,
                  Reason2_CODE,
                  Reason3_CODE,
                  Reason4_CODE,
                  Reason5_CODE,
                  Reason6_CODE,
                  ReceivedIVDOutOfStateCase_IDNO,
                  ReceivedIVDOutOfStateFips_CODE,
                  ReceivedMemberSsn_NUMB,
                  ReceivedMemberMci_IDNO,
                  TypeParticipant_CODE,
                  ReceivedLast_NAME,
                  ReceivedFirst_NAME,
                  ReceivedMiddle_NAME,
                  ReceivedBirth_DATE,
                  ReceivedMemberSex_CODE,
                  InStateAdult_QNTY,
                  OutStateAdult_QNTY,
                  AdultMatched_QNTY,
                  InStateChild_QNTY,
                  OutStateChild_QNTY,
                  MatchedChild_QNTY,
                  ReceivedContact_NAME,
                  ReceivedContactPhone_NUMB,
                  ReceivedContact_EML,
                  FipsVerification_INDC,
                  OutStateFipsVerification_INDC,
                  CpMatched_INDC,
                  NcpMatched_INDC,
                  IVDOutOfStateRespondInit_CODE,
                  SentSsnVerification_INDC,
                  ReceivedSsnVerification_INDC,
                  MultipleCase_INDC,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 15), @Lc_Space_TEXT))) AS Case_IDNO,-- Case_IDNO
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 16, 1), @Lc_Space_TEXT)))AS RespondInit_CODE,-- RespondInit_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 17, 2), @Lc_Space_TEXT))) AS StateFips_CODE,-- StateFips_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 19, 3), @Lc_Space_TEXT))) AS County_IDNO,-- County_IDNO
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 22, 2), @Lc_Space_TEXT))) AS OfficeFips_CODE,--OfficeFips_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 24, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- MemberSsn_NUMB
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 33, 15), @Lc_Space_TEXT))) AS MemberMci_IDNO,-- MemberMci_IDNO
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 48, 2), @Lc_Space_TEXT))) AS CaseRelationship_CODE,-- CaseRelationship_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 50, 1), @Lc_Space_TEXT))) AS StatusCase_CODE,-- StatusCase_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 51, 30), @Lc_Space_TEXT))) AS SentLast_NAME,-- SentLast_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 81, 16), @Lc_Space_TEXT)))AS SentFirst_NAME,-- SentFirst_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 97, 16), @Lc_Space_TEXT))) AS SentMiddle_NAME,-- SentMiddle_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 113, 8), @Lc_Space_TEXT))) AS SentBirth_DATE,-- SentBirth_DATE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 121, 1), @Lc_Space_TEXT))) AS SentMemberSex_CODE,-- SentMemberSex_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 122, 15), @Lc_Space_TEXT))) AS SentIVDOutOfStateCase_IDNO,-- SentIVDOutOfStateCase_IDNO
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 138, 2), @Lc_Space_TEXT))) AS SentIVDOutOfStateFips_CODE,-- SentIVDOutOfStateFips_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 140, 3), @Lc_Space_TEXT))) AS SentIVDOutOfStateCountyFips_CODE,-- SentIVDOutOfStateCountyFips_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 143, 2), @Lc_Space_TEXT))) AS IVDOutOfStateOfficeFips_CODE,-- IVDOutOfStateOfficeFips_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 162, 40), @Lc_Space_TEXT))) AS SentContact_NAME,-- SentContact_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 202, 10), @Lc_Space_TEXT))) AS SentPhoneContact_NUMB,-- SentPhoneContact_NUMB
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 212, 30), @Lc_Space_TEXT))) AS SentContact_EML,-- SentContact_EML
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 242, 1), @Lc_Space_TEXT))) AS IcrStatus_INDC,-- IcrStatus_INDC
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 243, 2), @Lc_Space_TEXT))) AS Reason1_CODE,-- Reason1_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 245, 2), @Lc_Space_TEXT))) AS Reason2_CODE,-- Reason2_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 247, 2), @Lc_Space_TEXT))) AS Reason3_CODE,-- Reason3_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 249, 2), @Lc_Space_TEXT))) AS Reason4_CODE,-- Reason4_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 251, 2), @Lc_Space_TEXT))) AS Reason5_CODE,-- Reason5_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 253, 2), @Lc_Space_TEXT))) AS Reason6_CODE,-- Reason6_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 267, 15), @Lc_Space_TEXT))) AS ReceivedIVDOutOfStateCase_IDNO,-- ReceivedIVDOutOfStateCase_IDNO 
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 282, 7), @Lc_Space_TEXT))) AS ReceivedIVDOutOfStateFips_CODE,-- ReceivedIVDOutOfStateFips_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 289, 9), @Lc_Space_TEXT))) AS ReceivedMemberSsn_NUMB,-- ReceivedMemberSsn_NUMB
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 298, 15), @Lc_Space_TEXT)))AS ReceivedMemberMci_IDNO,-- ReceivedMemberMci_IDNO
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 313, 2), @Lc_Space_TEXT))) AS TypeParticipant_CODE,-- TypeParticipant_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 315, 30), @Lc_Space_TEXT))) AS ReceivedLast_NAME,-- ReceivedLast_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 345, 16), @Lc_Space_TEXT))) AS ReceivedFirst_NAME,-- ReceivedFirst_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 361, 16), @Lc_Space_TEXT))) AS ReceivedMiddle_NAME,-- ReceivedMiddle_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 377, 8), @Lc_Space_TEXT))) AS ReceivedBirth_DATE,-- ReceivedBirth_DATE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 385, 1), @Lc_Space_TEXT))) AS ReceivedMemberSex_CODE,-- ReceivedMemberSex_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 386, 2), @Lc_Space_TEXT))) AS InStateAdult_QNTY,-- InStateAdult_QNTY
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 388, 2), @Lc_Space_TEXT))) AS OutStateAdult_QNTY,-- OutStateAdult_QNTY
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 390, 2), @Lc_Space_TEXT))) AS AdultMatched_QNTY,-- AdultMatched_QNTY
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 392, 2), @Lc_Space_TEXT))) AS InStateChild_QNTY,-- InStateChild_QNTY
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 394, 2), @Lc_Space_TEXT))) AS OutStateChild_QNTY,-- OutStateChild_QNTY
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 396, 2), @Lc_Space_TEXT))) AS MatchedChild_QNTY,-- MatchedChild_QNTY
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 398, 40), @Lc_Space_TEXT))) AS ReceivedContact_NAME,-- ReceivedContact_NAME
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 438, 10), @Lc_Space_TEXT))) AS ReceivedContactPhone_NUMB,-- ReceivedContactPhone_NUMB
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 448, 30), @Lc_Space_TEXT))) AS ReceivedContact_EML,-- ReceivedContact_EML
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 478, 1), @Lc_Space_TEXT))) AS FipsVerification_INDC,-- FipsVerification_INDC
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 479, 1), @Lc_Space_TEXT))) AS OutStateFipsVerification_INDC,-- OutStateFipsVerification_INDC
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 480, 1), @Lc_Space_TEXT))) AS CpMatched_INDC,-- CpMatch_INDC
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 481, 1), @Lc_Space_TEXT))) AS NcpMatched_INDC,-- NcpMatch_INDC
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 482, 1), @Lc_Space_TEXT))) AS IVDOutOfStateRespondInit_CODE,-- OthRespondInit_CODE
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 483, 1), @Lc_Space_TEXT))) AS SentSsnVerification_INDC,-- SentSsnVerification_INDC
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 484, 1), @Lc_Space_TEXT))) AS ReceivedSsnVerification_INDC,-- ReceivedSsnVerification_INDC
            LTRIM(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 485, 1), @Lc_Space_TEXT))) AS MultipleCase_INDC,-- MultipleCase_INDC
            @Ld_Run_DATE AS FileLoad_DATE,--FileLoad_DATE 
            @Lc_ProcessN_INDC AS Process_INDC-- Process_INDC
       FROM #LoadIcr_P1 L;
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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR (20)), '') + ', RestartKey_TEXT = ' + ISNULL(CAST(@Ln_RecordCount_NUMB AS VARCHAR(20)), '');

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

   --Drop Temperory Table
   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE #LoadIcr_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION IcrLoad;
  END TRY

  BEGIN CATCH
   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IcrLoad;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadIcr_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadIcr_P1;
    END

   --Set Error Description
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
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
