/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_DMV$SP_LOAD_DMV]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_DMV$SP_LOAD_DMV
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_DMV$SP_LOAD_DMV loads the address and license information data match file from DMV to LDMVL_Y1
Frequency		:	'DAILY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_DMV$SP_LOAD_DMV]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_RecHeader_ID           CHAR(1) = 'H',
          @Lc_RecTrailer_ID          CHAR(1) = 'T',
          @Lc_RecDetail_ID           CHAR(1) = 'D',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB5040',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_DMV',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_DMV';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10) = 0,
          @Ln_HeaderRecCount_QNTY         NUMERIC(10) = 0,
          @Ln_TrailerRecCount_QNTY        NUMERIC(10) = 0,
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
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##LoadDmvl_P1';

   CREATE TABLE #LoadDmvl_P1
    (
      Record_TEXT CHAR(778)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_LOAD_DMV';

   BEGIN TRANSACTION TXN_LOAD_DMV;

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
   SET @Ls_BulkInsertSql_TEXT = 'BULK INSERT #LoadDmvl_P1 FROM ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_SqlData_TEXT = '';

   EXEC (@Ls_BulkInsertSql_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadDmvl_P1 - HEADER COUNT';
   SET @Ln_HeaderRecCount_QNTY = ISNULL((SELECT CASE
                                                 WHEN ISNUMERIC(SUBSTRING(A.Record_TEXT, 10, 6)) = 0
                                                  THEN 0
                                                 ELSE SUBSTRING(A.Record_TEXT, 10, 6)
                                                END
                                           FROM #LoadDmvl_P1 A
                                          WHERE LTRIM(RTRIM(SUBSTRING(A.Record_TEXT, 1, 1))) = @Lc_RecHeader_ID), 0);
   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadDmvl_P1 - TRAILER COUNT';
   SET @Ln_TrailerRecCount_QNTY = ISNULL((SELECT CASE
                                                  WHEN ISNUMERIC(SUBSTRING(A.Record_TEXT, 10, 6)) = 0
                                                   THEN 0
                                                  ELSE SUBSTRING(A.Record_TEXT, 10, 6)
                                                 END
                                            FROM #LoadDmvl_P1 A
                                           WHERE LTRIM(RTRIM(SUBSTRING(A.Record_TEXT, 1, 1))) = @Lc_RecTrailer_ID), 0);
   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadDmvl_P1 - DETAILS COUNT';
   SET @Ln_RecordCount_QNTY = ISNULL((SELECT COUNT(1)
                                        FROM #LoadDmvl_P1 A
                                       WHERE LTRIM(RTRIM(SUBSTRING(A.Record_TEXT, 1, 1))) = @Lc_RecDetail_ID), 0);
   SET @Ls_Sql_TEXT = 'CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN HEADER';

   IF @Ln_RecordCount_QNTY != (@Ln_HeaderRecCount_QNTY + @Ln_TrailerRecCount_QNTY)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO. OF RECORDS IN HEADER DOESNT MATCH WITH SUM OF DETAIL RECORDS' + ', DETAIL RECORD COUNT = ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR) + ', HEADER RECORD COUNT = ' + CAST((@Ln_HeaderRecCount_QNTY + @Ln_TrailerRecCount_QNTY) AS VARCHAR);

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE PROCESSED RECORDS FROM LDMVL_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE FROM LDMVL_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO LOAD INTO LDMVL_Y1';

   IF @Ln_RecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LDMVL_Y1';
     SET @Ls_SqlData_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC, '');

     INSERT INTO LDMVL_Y1
                 (Rec_ID,
                  LastNcp_NAME,
                  FirstNcp_NAME,
                  MiddleNcp_NAME,
                  BirthNcp_DATE,
                  NcpDriversLicenseNo_TEXT,
                  NcpSsn_NUMB,
                  NcpSex_CODE,
                  NcpMemberMci_IDNO,
                  Source_CODE,
                  Action_CODE,
                  Ncp_NAME,
                  SuffixNcp_NAME,
                  MailingLine1NcpOld_ADDR,
                  MailingLine2NcpOld_ADDR,
                  MailingCityNcpOld_ADDR,
                  MailingStateNcpOld_ADDR,
                  MailingZipNcpOld_ADDR,
                  ResidenceLine1NcpOld_ADDR,
                  ResidenceLine2NcpOld_ADDR,
                  ResidenceCityNcpOld_ADDR,
                  ResidenceStateNcpOld_ADDR,
                  ResidenceZipNcpOld_ADDR,
                  DmvBirthNcp_DATE,
                  NcpDmvDriversLicenseNo_TEXT,
                  NcpDriversLicenseType_CODE,
                  NcpDmvSsn_NUMB,
                  NcpDmvSex_CODE,
                  NcpAka_INDC,
                  AkaNcp1_NAME,
                  SuffixAkaNcp1_NAME,
                  AkaNcp2_NAME,
                  SuffixAkaNcp2_NAME,
                  AkaNcp3_NAME,
                  SuffixAkaNcp3_NAME,
                  AkaNcpSsn1_NUMB,
                  AkaNcpSsn2_NUMB,
                  AkaNcpSsn3_NUMB,
                  AkaBirthNcp1_DATE,
                  AkaBirthNcp2_DATE,
                  AkaBirthNcp3_DATE,
                  MatchLevel_CODE,
                  NcpSuspLicEff_DATE,
                  NcpLicLiftEff_DATE,
                  NcpDeceased_TEXT,
                  MailingAddressNormalization_CODE,
                  MailingLine1Ncp_ADDR,
                  MailingLine2Ncp_ADDR,
                  MailingCityNcp_ADDR,
                  MailingStateNcp_ADDR,
                  MailingZipNcp_ADDR,
                  ResidenceAddressNormalization_CODE,
                  ResidenceLine1Ncp_ADDR,
                  ResidenceLine2Ncp_ADDR,
                  ResidenceCityNcp_ADDR,
                  ResidenceStateNcp_ADDR,
                  ResidenceZipNcp_ADDR,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (SUBSTRING(A.Record_TEXT, 1, 1)) AS Rec_ID,
            (SUBSTRING(A.Record_TEXT, 2, 12)) AS LastNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 14, 11)) AS FirstNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 25, 1)) AS MiddleNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 26, 8)) AS BirthNcp_DATE,
            (SUBSTRING(A.Record_TEXT, 34, 12)) AS NcpDriversLicenseNo_TEXT,
            (SUBSTRING(A.Record_TEXT, 46, 9)) AS NcpSsn_NUMB,
            (SUBSTRING(A.Record_TEXT, 55, 1)) AS NcpSex_CODE,
            (SUBSTRING(A.Record_TEXT, 56, 10)) AS NcpMemberMci_IDNO,
            (SUBSTRING(A.Record_TEXT, 66, 2)) AS Source_CODE,
            (SUBSTRING(A.Record_TEXT, 68, 1)) AS Action_CODE,
            (SUBSTRING(A.Record_TEXT, 101, 32)) AS Ncp_NAME,
            (SUBSTRING(A.Record_TEXT, 133, 3)) AS SuffixNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 136, 21)) AS MailingLine1NcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 157, 21)) AS MailingLine2NcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 178, 15)) AS MailingCityNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 193, 2)) AS MailingStateNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 195, 9)) AS MailingZipNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 204, 21)) AS ResidenceLine1NcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 225, 21)) AS ResidenceLine2NcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 246, 15)) AS ResidenceCityNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 261, 2)) AS ResidenceStateNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 263, 9)) AS ResidenceZipNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 272, 8)) AS DmvBirthNcp_DATE,
            (SUBSTRING(A.Record_TEXT, 280, 8)) AS NcpDmvDriversLicenseNo_TEXT,
            (SUBSTRING(A.Record_TEXT, 288, 2)) AS NcpDriversLicenseType_CODE,
            (SUBSTRING(A.Record_TEXT, 290, 9)) AS NcpDmvSsn_NUMB,
            (SUBSTRING(A.Record_TEXT, 299, 1)) AS NcpDmvSex_CODE,
            (SUBSTRING(A.Record_TEXT, 300, 1)) AS NcpAka_INDC,
            (SUBSTRING(A.Record_TEXT, 301, 32)) AS AkaNcp1_NAME,
            (SUBSTRING(A.Record_TEXT, 333, 3)) AS SuffixAkaNcp1_NAME,
            (SUBSTRING(A.Record_TEXT, 336, 32)) AS AkaNcp2_NAME,
            (SUBSTRING(A.Record_TEXT, 368, 3)) AS SuffixAkaNcp2_NAME,
            (SUBSTRING(A.Record_TEXT, 371, 32)) AS AkaNcp3_NAME,
            (SUBSTRING(A.Record_TEXT, 403, 3)) AS SuffixAkaNcp3_NAME,
            (SUBSTRING(A.Record_TEXT, 406, 9)) AS AkaNcpSsn1_NUMB,
            (SUBSTRING(A.Record_TEXT, 415, 9)) AS AkaNcpSsn2_NUMB,
            (SUBSTRING(A.Record_TEXT, 424, 9)) AS AkaNcpSsn3_NUMB,
            (SUBSTRING(A.Record_TEXT, 433, 8)) AS AkaBirthNcp1_DATE,
            (SUBSTRING(A.Record_TEXT, 441, 8)) AS AkaBirthNcp2_DATE,
            (SUBSTRING(A.Record_TEXT, 449, 8)) AS AkaBirthNcp3_DATE,
            (SUBSTRING(A.Record_TEXT, 457, 1)) AS MatchLevel_CODE,
            (SUBSTRING(A.Record_TEXT, 458, 8)) AS NcpSuspLicEff_DATE,
            (SUBSTRING(A.Record_TEXT, 466, 8)) AS NcpLicLiftEff_DATE,
            (SUBSTRING(A.Record_TEXT, 474, 13)) AS NcpDeceased_TEXT,
            (SUBSTRING(A.Record_TEXT, 487, 1)) AS MailingAddressNormalization_CODE,
            (SUBSTRING(A.Record_TEXT, 488, 50)) AS MailingLine1Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 538, 50)) AS MailingLine2Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 588, 28)) AS MailingCityNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 616, 2)) AS MailingStateNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 618, 15)) AS MailingZipNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 633, 1)) AS ResidenceAddressNormalization_CODE,
            (SUBSTRING(A.Record_TEXT, 634, 50)) AS ResidenceLine1Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 684, 50)) AS ResidenceLine2Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 734, 28)) AS ResidenceCityNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 762, 2)) AS ResidenceStateNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 764, 15)) AS ResidenceZipNcp_ADDR,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_ProcessN_INDC AS Process_INDC
       FROM #LoadDmvl_P1 A
      WHERE LTRIM(RTRIM(SUBSTRING(A.Record_TEXT, 1, 1))) = @Lc_RecDetail_ID;

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_LOAD_DMV';

   COMMIT TRANSACTION TXN_LOAD_DMV;

   SET @Ls_Sql_TEXT = 'DROP #LoadDmvl_P1';

   DROP TABLE #LoadDmvl_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_LOAD_DMV;
    END;

   IF OBJECT_ID('tempdb..#LoadDmvl_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDmvl_P1;
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
