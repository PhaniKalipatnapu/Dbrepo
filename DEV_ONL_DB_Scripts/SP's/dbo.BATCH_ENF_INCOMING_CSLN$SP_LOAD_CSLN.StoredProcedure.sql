/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_CSLN$SP_LOAD_CSLN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_CSLN$SP_LOAD_CSLN
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_CSLN$SP_LOAD_CSLN reads CSLN file and loads data into a temporary table LCSLN_Y1
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
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_CSLN$SP_LOAD_CSLN]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB5180',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_CSLN',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_CSLN';
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
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##LoadCsln_P1';

   CREATE TABLE #LoadCsln_P1
    (
      Record_TEXT CHAR(1192)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_LOAD_CSLN';

   BEGIN TRANSACTION TXN_LOAD_CSLN;

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
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_BulkInsertSql_TEXT = 'BULK INSERT #LoadCsln_P1 FROM ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_SqlData_TEXT = '';

   EXEC (@Ls_BulkInsertSql_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadCsln_P1 - DETAILS COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_RecordCount_QNTY = COUNT(1)
     FROM #LoadCsln_P1 A;

   SET @Ls_Sql_TEXT='DELETE PROCESSED RECORDS FROM LCSLN_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE FROM LCSLN_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO LOAD INTO LCSLN_Y1';

   IF @Ln_RecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LCSLN_Y1';
     SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     INSERT INTO LCSLN_Y1
                 (NcpMemberMci_IDNO,
                  LastNcp_NAME,
                  FirstNcp_NAME,
                  MiddleNcp_NAME,
                  SuffixNcp_NAME,
                  NcpSsn_NUMB,
                  BirthNcp_DATE,
                  LkcaAttnNcp_ADDR,
                  LkcaLine1Ncp_ADDR,
                  LkcaLine2Ncp_ADDR,
                  LkcaCityNcp_ADDR,
                  LkcaStateNcp_ADDR,
                  LkcaZipNcp_ADDR,
                  MailingAttnNcp_ADDR,
                  MailingLine1NcpOld_ADDR,
                  MailingLine2NcpOld_ADDR,
                  MailingCityNcpOld_ADDR,
                  MailingStateNcpOld_ADDR,
                  MailingZipNcpOld_ADDR,
                  HomePhoneNcp_NUMB,
                  CellPhoneNcp_NUMB,
                  InsCompany_NAME,
                  InsCompanyLine1Old_ADDR,
                  InsCompanyLine2Old_ADDR,
                  InsCompanyCityOld_ADDR,
                  InsCompanyStateOld_ADDR,
                  InsCompanyZipOld_ADDR,
                  InsClaim_NUMB,
                  InsClaimType_CODE,
                  InsClaimLoss_DATE,
                  InsContactFirst_NAME,
                  InsContactLast_NAME,
                  InsContactPhone_NUMB,
                  InsFaxContact_NUMB,
                  Case_IDNO,
                  File_ID,
                  LastCourtOrder_DATE,
                  CaseState_CODE,
                  TotalArrears_AMNT,
                  TypeAction_CODE,
                  Action_DATE,
                  MailingAddressNormalization_CODE,
                  MailingLine1Ncp_ADDR,
                  MailingLine2Ncp_ADDR,
                  MailingCityNcp_ADDR,
                  MailingStateNcp_ADDR,
                  MailingZipNcp_ADDR,
                  InsCompanyAddressNormalization_CODE,
                  InsCompanyLine1_ADDR,
                  InsCompanyLine2_ADDR,
                  InsCompanyCity_ADDR,
                  InsCompanyState_ADDR,
                  InsCompanyZip_ADDR,
                  Process_INDC,
                  FileLoad_DATE)
     SELECT (SUBSTRING(A.Record_TEXT, 1, 10)) AS NcpMemberMci_IDNO,
            (SUBSTRING(A.Record_TEXT, 11, 15)) AS LastNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 26, 11)) AS FirstNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 37, 1)) AS MiddleNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 38, 3)) AS SuffixNcp_NAME,
            (SUBSTRING(A.Record_TEXT, 41, 9)) AS NcpSsn_NUMB,
            (SUBSTRING(A.Record_TEXT, 50, 8)) AS BirthNcp_DATE,
            (SUBSTRING(A.Record_TEXT, 58, 40)) AS LkcaAttnNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 98, 40)) AS LkcaLine1Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 138, 40)) AS LkcaLine2Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 178, 30)) AS LkcaCityNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 208, 2)) AS LkcaStateNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 210, 9)) AS LkcaZipNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 219, 40)) AS MailingAttnNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 259, 40)) AS MailingLine1NcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 299, 40)) AS MailingLine2NcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 339, 30)) AS MailingCityNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 369, 2)) AS MailingStateNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 371, 9)) AS MailingZipNcpOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 380, 25)) AS HomePhoneNcp_NUMB,
            (SUBSTRING(A.Record_TEXT, 405, 25)) AS CellPhoneNcp_NUMB,
            (SUBSTRING(A.Record_TEXT, 430, 80)) AS InsCompany_NAME,
            (SUBSTRING(A.Record_TEXT, 510, 40)) AS InsCompanyLine1Old_ADDR,
            (SUBSTRING(A.Record_TEXT, 550, 40)) AS InsCompanyLine2Old_ADDR,
            (SUBSTRING(A.Record_TEXT, 590, 30)) AS InsCompanyCityOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 620, 2)) AS InsCompanyStateOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 622, 9)) AS InsCompanyZipOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 631, 30)) AS InsClaim_NUMB,
            (SUBSTRING(A.Record_TEXT, 661, 1)) AS InsClaimType_CODE,
            (SUBSTRING(A.Record_TEXT, 662, 8)) AS InsClaimLoss_DATE,
            (SUBSTRING(A.Record_TEXT, 670, 20)) AS InsContactFirst_NAME,
            (SUBSTRING(A.Record_TEXT, 690, 30)) AS InsContactLast_NAME,
            (SUBSTRING(A.Record_TEXT, 720, 25)) AS InsContactPhone_NUMB,
            (SUBSTRING(A.Record_TEXT, 745, 25)) AS InsFaxContact_NUMB,
            (SUBSTRING(A.Record_TEXT, 770, 6)) AS Case_IDNO,
            (SUBSTRING(A.Record_TEXT, 776, 11)) AS File_ID,
            (SUBSTRING(A.Record_TEXT, 787, 8)) AS LastCourtOrder_DATE,
            (SUBSTRING(A.Record_TEXT, 795, 2)) AS CaseState_CODE,
            (SUBSTRING(A.Record_TEXT, 797, 8)) AS TotalArrears_AMNT,
            (SUBSTRING(A.Record_TEXT, 805, 1)) AS TypeAction_CODE,
            (SUBSTRING(A.Record_TEXT, 806, 8)) AS Action_DATE,
            (SUBSTRING(A.Record_TEXT, 901, 1)) AS MailingAddressNormalization_CODE,
            (SUBSTRING(A.Record_TEXT, 902, 50)) AS MailingLine1Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 952, 50)) AS MailingLine2Ncp_ADDR,
            (SUBSTRING(A.Record_TEXT, 1002, 28)) AS MailingCityNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 1030, 2)) AS MailingStateNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 1032, 15)) AS MailingZipNcp_ADDR,
            (SUBSTRING(A.Record_TEXT, 1047, 1)) AS InsCompanyAddressNormalization_CODE,
            (SUBSTRING(A.Record_TEXT, 1048, 50)) AS InsCompanyLine1_ADDR,
            (SUBSTRING(A.Record_TEXT, 1098, 50)) AS InsCompanyLine2_ADDR,
            (SUBSTRING(A.Record_TEXT, 1148, 28)) AS InsCompanyCity_ADDR,
            (SUBSTRING(A.Record_TEXT, 1176, 2)) AS InsCompanyState_ADDR,
            (SUBSTRING(A.Record_TEXT, 1178, 15)) AS InsCompanyZip_ADDR,
            @Lc_ProcessN_INDC AS Process_INDC,
            @Ld_Run_DATE AS FileLoad_DATE
       FROM #LoadCsln_P1 A;

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_LOAD_CSLN';

   COMMIT TRANSACTION TXN_LOAD_CSLN;

   SET @Ls_Sql_TEXT = 'DROP #LoadCsln_P1';

   DROP TABLE #LoadCsln_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_LOAD_CSLN;
    END;

   IF OBJECT_ID('tempdb..#LoadCsln_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadCsln_P1;
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
