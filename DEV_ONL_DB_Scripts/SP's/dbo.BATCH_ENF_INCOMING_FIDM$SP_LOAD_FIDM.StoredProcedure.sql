/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_FIDM$SP_LOAD_FIDM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_FIDM$SP_LOAD_FIDM
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_FIDM$SP_LOAD_FIDM reads the NCP's address and financial account details received 
					  from the FIDM match file and loads the data into a temporary tables LFIIR_Y1 and LACHL_Y1.
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_FIDM$SP_LOAD_FIDM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_RecFiir_ID             CHAR(1) = 'A',
          @Lc_RecAchl_ID             CHAR(1) = 'B',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateErrorE0085_CODE    CHAR(5) = 'E0085',
          @Lc_Job_ID                 CHAR(7) = 'DEB5190',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_FIDM',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_FIDM';
  DECLARE
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10),
          @Ln_FiirRecordCount_QNTY        NUMERIC(10) = 0,
          @Ln_AchlRecordCount_QNTY        NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_FidmFiirSeq_IDNO            NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowCount_QNTY               SMALLINT,
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_BateError_CODE              CHAR(5),
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_BulkInsertSql_TEXT          VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(2000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ls_FidmInputCur_Record_TEXT VARCHAR(566);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE #LoadFidm_P1';
   CREATE TABLE #LoadFidm_P1
    (
      Record_TEXT CHAR(566)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_LOAD_FIDM';
   BEGIN TRANSACTION TXN_LOAD_FIDM;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'');

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

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF LEN(@Ls_FileSource_TEXT) = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';   SET @Ls_BulkInsertSql_TEXT = 'BULK INSERT #LoadFidm_P1 FROM ''' + @Ls_FileSource_TEXT + '''';

   SET @Ls_SqlData_TEXT = '';

   EXEC (@Ls_BulkInsertSql_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadFidm_P1 - DETAILS COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_RecordCount_QNTY = COUNT(1)
     FROM #LoadFidm_P1 A;
     
   SET @Ls_Sql_TEXT='DELETE PROCESSED RECORDS FROM LACHL_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'');

   DELETE FROM LACHL_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;  

   SET @Ls_Sql_TEXT='DELETE PROCESSED RECORDS FROM LFIIR_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'');

   DELETE FROM LFIIR_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO LOAD INTO LFIIR_Y1 AND LACHL_Y1';
   IF @Ln_RecordCount_QNTY > 0
    BEGIN
     DECLARE FidmInput_CUR INSENSITIVE CURSOR FOR
      SELECT A.Record_TEXT
        FROM #LoadFidm_P1 A;

     SET @Ls_Sql_TEXT = 'OPEN FidmInput_CUR';
     OPEN FidmInput_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FidmInput_CUR - 1';
     FETCH NEXT FROM FidmInput_CUR INTO @Ls_FidmInputCur_Record_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH FidmInput_CUR';
     --Reads the NCP's address and financial account details received from the FIDM match file
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
       SET @Ls_CursorLocation_TEXT = 'FidmInput - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
       SET @Ls_BateRecord_TEXT = 'RecordCount_QNTY = ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR) + ', Record_TEXT = ' + @Ls_FidmInputCur_Record_TEXT;

       IF LEN(LTRIM(RTRIM(@Ls_FidmInputCur_Record_TEXT))) = 0
        BEGIN
         SET @Ls_SqlData_TEXT = '';

         SELECT @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE,
                @Ls_ErrorMessage_TEXT = 'INVALID VALUE';

         RAISERROR(50001,16,1);
        END;

       IF UPPER(SUBSTRING(RTRIM(LTRIM(@Ls_FidmInputCur_Record_TEXT)), 1, 1)) = @Lc_RecFiir_ID
        BEGIN
         SET @Ls_SqlData_TEXT = '';

         SELECT @Ln_FidmFiirSeq_IDNO = 0,
                @Ln_FiirRecordCount_QNTY = @Ln_FiirRecordCount_QNTY + 1,
                @Ln_AchlRecordCount_QNTY = 0;

         SET @Ls_BateRecord_TEXT += ', FiirRecordCount_QNTY = ' + CAST(@Ln_FiirRecordCount_QNTY AS VARCHAR);

         SET @Ls_Sql_TEXT = 'INSERT LFIIR_Y1';
         SET @Ls_SqlData_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC,'');

         INSERT INTO LFIIR_Y1
                     (Rec_ID,
                      TapeReel_NUMB,
                      FinancialInstitutionEIN_IDNO,
                      InstitutionControl_NAME,
                      FileGenerated_DATE,
                      ReceivedFileType_CODE,
                      ServiceBureau_CODE,
                      MagneticTape_CODE,
                      ForeignCorrespondence_CODE,
                      Institution_NAME,
                      InstitutionSecond_NAME,
                      TransferAgent_CODE,
                      InstitutionStreetOld_ADDR,
                      InstitutionCityOld_ADDR,
                      InstitutionStateOld_ADDR,
                      InstitutionZipOld_ADDR,
                      ReportingAgentEIN_IDNO,
                      ReportingAgent_NAME,
                      ReportingAgentStreet_ADDR,
                      ReportingAgentCity_ADDR,
                      ReportingAgentState_ADDR,
                      ReportingAgentZip_ADDR,
                      DataMatch_CODE,
                      InstitutionAddrNormalization_CODE,
                      InstitutionLine1_ADDR,
                      InstitutionLine2_ADDR,
                      InstitutionCity_ADDR,
                      InstitutionState_ADDR,
                      InstitutionZip_ADDR,
                      FileLoad_DATE,
                      Process_INDC)
         SELECT SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 1, 1) AS Rec_ID,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 4, 3) AS TapeReel_NUMB,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 7, 9) AS FinancialInstitutionEIN_IDNO,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 16, 4) AS InstitutionControl_NAME,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 20, 6) AS FileGenerated_DATE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 32, 1) AS ReceivedFileType_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 33, 1) AS ServiceBureau_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 42, 2) AS MagneticTape_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 49, 1) AS ForeignCorrespondence_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 50, 40) AS Institution_NAME,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 90, 40) AS InstitutionSecond_NAME,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 130, 1) AS TransferAgent_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 131, 40) AS InstitutionStreetOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 171, 29) AS InstitutionCityOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 200, 2) AS InstitutionStateOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 202, 9) AS InstitutionZipOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 211, 9) AS ReportingAgentEIN_IDNO,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 220, 71) AS ReportingAgent_NAME,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 291, 40) AS ReportingAgentStreet_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 331, 29) AS ReportingAgentCity_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 360, 2) AS ReportingAgentState_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 362, 9) AS ReportingAgentZip_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 371, 1) AS DataMatch_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 421, 1) AS InstitutionAddrNormalization_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 422, 50) AS InstitutionLine1_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 472, 50) AS InstitutionLine2_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 522, 28) AS InstitutionCity_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 550, 2) AS InstitutionState_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 552, 15) AS InstitutionZip_ADDR,
                @Ld_Run_DATE AS FileLoad_DATE,
                @Lc_ProcessN_INDC AS Process_INDC;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY > 0
          BEGIN
           SET @Ln_FidmFiirSeq_IDNO = @@IDENTITY;
          END;
         ELSE
          BEGIN
           SET @Ls_SqlData_TEXT = '';

           SELECT @Ls_ErrorMessage_TEXT = 'INSERT LFIIR_Y1 FAILED';

           RAISERROR (50001,16,1);
          END;
        END;

       IF UPPER(SUBSTRING(RTRIM(LTRIM(@Ls_FidmInputCur_Record_TEXT)), 1, 1)) = @Lc_RecAchl_ID
          AND @Ln_FidmFiirSeq_IDNO > 0
        BEGIN
         SET @Ln_AchlRecordCount_QNTY = @Ln_AchlRecordCount_QNTY + 1;
         SET @Ls_BateRecord_TEXT += ', AchlRecordCount_QNTY = ' + CAST(@Ln_AchlRecordCount_QNTY AS VARCHAR);
         SET @Ls_Sql_TEXT = 'INSERT LACHL_Y1';
         SET @Ls_SqlData_TEXT = 'FidmFiirSeq_IDNO = ' + ISNULL(CAST( @Ln_FidmFiirSeq_IDNO AS VARCHAR ),'')+ ', FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC,'');

         INSERT INTO LACHL_Y1
                     (FidmFiirSeq_IDNO,
                      Rec_ID,
                      FileGenerated_DATE,
                      PayeeLast_NAME,
                      MatchedSsn_NUMB,
                      PayeeAccount_NUMB,
                      FullAccountTitle_TEXT,
                      ForeignCountry_CODE,
                      Matched_NAME,
                      SecondPayee_NAME,
                      MatchedStreetOld_ADDR,
                      MatchedCityOld_ADDR,
                      MatchedStateOld_ADDR,
                      MatchedZipOld_ADDR,
                      FipsPassBack_CODE,
                      AdditionalStatePassBack_TEXT,
                      AccountBalance_AMNT,
                      AccountMatch_CODE,
                      TrustFund_CODE,
                      AccountBalance_CODE,
                      AccountUpdate_CODE,
                      AccountHolderBirth_DATE,
                      StatePassBack_TEXT,
                      AccountType_CODE,
                      CasePassBack_TEXT,
                      Payee_CODE,
                      PrimarySsn_NUMB,
                      SecondPayeeSsn_NUMB,
                      MatchedAddrNormalization_CODE,
                      MatchedLine1_ADDR,
                      MatchedLine2_ADDR,
                      MatchedCity_ADDR,
                      MatchedState_ADDR,
                      MatchedZip_ADDR,
                      FileLoad_DATE,
                      Process_INDC)
         SELECT @Ln_FidmFiirSeq_IDNO AS FidmFiirSeq_IDNO,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 1, 1) AS Rec_ID,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 2, 6) AS FileGenerated_DATE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 8, 4) AS PayeeLast_NAME,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 15, 9) AS MatchedSsn_NUMB,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 24, 20) AS PayeeAccount_NUMB,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 61, 100) AS FullAccountTitle_TEXT,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 161, 1) AS ForeignCountry_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 162, 40) AS Matched_NAME,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 202, 40) AS SecondPayee_NAME,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 242, 40) AS MatchedStreetOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 282, 29) AS MatchedCityOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 311, 2) AS MatchedStateOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 313, 9) AS MatchedZipOld_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 322, 5) AS FipsPassBack_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 327, 23) AS AdditionalStatePassBack_TEXT,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 351, 7) AS AccountBalance_AMNT,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 358, 1) AS AccountMatch_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 359, 1) AS TrustFund_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 361, 1) AS AccountBalance_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 362, 1) AS AccountUpdate_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 363, 8) AS AccountHolderBirth_DATE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 371, 10) AS StatePassBack_TEXT,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 381, 2) AS AccountType_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 383, 15) AS CasePassBack_TEXT,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 401, 1) AS Payee_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 402, 9) AS PrimarySsn_NUMB,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 411, 9) AS SecondPayeeSsn_NUMB,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 421, 1) AS MatchedAddrNormalization_CODE,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 422, 50) AS MatchedLine1_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 472, 50) AS MatchedLine2_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 522, 28) AS MatchedCity_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 550, 2) AS MatchedState_ADDR,
                SUBSTRING(@Ls_FidmInputCur_Record_TEXT, 552, 15) AS MatchedZip_ADDR,
                @Ld_Run_DATE AS FileLoad_DATE,
                @Lc_ProcessN_INDC AS Process_INDC;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_SqlData_TEXT = '';

           SELECT @Ls_ErrorMessage_TEXT = 'INSERT LACHL_Y1 FAILED';

           RAISERROR (50001,16,1);
          END;
        END;

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FidmInput_CUR - 2';
       FETCH NEXT FROM FidmInput_CUR INTO @Ls_FidmInputCur_Record_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     SET @Ls_Sql_TEXT = 'CLOSE FidmInput_CUR';
     CLOSE FidmInput_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FidmInput_CUR';
     DEALLOCATE FidmInput_CUR;
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

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
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_LOAD_FIDM';
   COMMIT TRANSACTION TXN_LOAD_FIDM;

   SET @Ls_Sql_TEXT = 'DROP #LoadFidm_P1';
   DROP TABLE #LoadFidm_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_LOAD_FIDM;
    END;

   IF CURSOR_STATUS('Local', 'FidmInput_CUR') IN (0, 1)
    BEGIN
     CLOSE FidmInput_CUR;

     DEALLOCATE FidmInput_CUR;
    END;

   IF OBJECT_ID('tempdb..#LoadFidm_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadFidm_P1;
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
    @As_ListKey_TEXT              = @Ls_BateRecord_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
