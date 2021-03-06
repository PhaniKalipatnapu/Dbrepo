/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_TPL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_TPL
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_TPL 
					  loads the member insurance details from the Medicaid agency 
					  to the temporary table for further processing.
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
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_TPL]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_TypeRecordDt_CODE      CHAR(2) = 'DT',
          @Lc_TypeRecordFt_CODE      CHAR(2) = 'FT',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB6190',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_MEDICAID_TPL',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_MEDICAID_TPL';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10),
          @Ln_TrailerRecCount_QNTY        NUMERIC(10, 0),
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
   SET @Ls_Sql_TEXT = 'CREATE #LoadTpl_P1';
   CREATE TABLE #LoadTpl_P1
    (
      Record_TEXT CHAR(496)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_LOAD_MEDICAID_TPL';
   BEGIN TRANSACTION TXN_LOAD_MEDICAID_TPL;

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

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';   SET @Ls_BulkInsertSql_TEXT = 'BULK INSERT #LoadTpl_P1 FROM ''' + @Ls_FileSource_TEXT + '''';

   SET @Ls_SqlData_TEXT = '';

   EXEC (@Ls_BulkInsertSql_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadTpl_P1 - TRAILER COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_TrailerRecCount_QNTY = SUBSTRING(A.Record_TEXT, 3, 8)
     FROM #LoadTpl_P1 A
    WHERE SUBSTRING(A.Record_TEXT, 1, 2) = @Lc_TypeRecordFt_CODE;

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadTpl_P1 - DETAILS COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_RecordCount_QNTY = COUNT(1)
     FROM #LoadTpl_P1 A
    WHERE SUBSTRING(A.Record_TEXT, 1, 2) = @Lc_TypeRecordDt_CODE;

   SET @Ls_Sql_TEXT = 'CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN TRIALER';
   IF @Ln_RecordCount_QNTY != @Ln_TrailerRecCount_QNTY
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO. OF RECORDS IN TRAILER DOESNT MATCH WITH SUM OF DETAIL RECORDS' + ', DETAIL RECORD COUNT = ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR) + ', TRAILER RECORD COUNT = ' + CAST(@Ln_TrailerRecCount_QNTY AS VARCHAR);

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE PROCESSED RECORDS FROM LMTPL_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'');

   DELETE FROM LMTPL_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   IF @Ln_RecordCount_QNTY > @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LMTPL_Y1';
     SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC,'')+ ', FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

     INSERT INTO LMTPL_Y1
                 (Case_IDNO,
                  InsuredMemberMci_IDNO,
                  InsuredMemberSsn_NUMB,
                  BirthInsured_DATE,
                  LastInsured_NAME,
                  FirstInsured_NAME,
                  InsCompanyCarrier_CODE,
                  InsCompanyLocation_CODE,
                  InsHolderFull_NAME,
                  InsHolderMemberSsn_NUMB,
                  InsHolderBirth_DATE,
                  InsHolderMemberMci_IDNO,
                  PolicyInsNo_TEXT,
                  InsuranceGroupNo_TEXT,
                  Coverage_CODE,
                  InsPolicyStatus_CODE,
                  InsPolicyVerification_INDC,
                  Begin_DATE,
                  End_DATE,
                  InsHolderRelationship_CODE,
                  InsHolderEmployer_NAME,
                  InsHolderEmpLine1Old_ADDR,
                  InsHolderEmpLine2Old_ADDR,
                  InsHolderEmpCityOld_ADDR,
                  InsHolderEmpStateOld_ADDR,
                  InsHolderEmpZipOld_ADDR,
                  InsPolicyInfoAdd_DATE,
                  InsPolicyInfoModify_DATE,
                  InsHolderEmpAddrNormalization_CODE,
                  InsHolderEmpLine1_ADDR,
                  InsHolderEmpLine2_ADDR,
                  InsHolderEmpCity_ADDR,
                  InsHolderEmpState_ADDR,
                  InsHolderEmpZip_ADDR,
                  Process_INDC,
                  FileLoad_DATE)
     SELECT SUBSTRING(A.Record_TEXT, 3, 10) AS Case_IDNO,
            SUBSTRING(A.Record_TEXT, 13, 10) AS InsuredMemberMci_IDNO,
            SUBSTRING(A.Record_TEXT, 23, 9) AS InsuredMemberSsn_NUMB,
            SUBSTRING(A.Record_TEXT, 32, 8) AS BirthInsured_DATE,
            SUBSTRING(A.Record_TEXT, 40, 20) AS LastInsured_NAME,
            SUBSTRING(A.Record_TEXT, 60, 16) AS FirstInsured_NAME,
            SUBSTRING(A.Record_TEXT, 76, 5) AS InsCompanyCarrier_CODE,
            SUBSTRING(A.Record_TEXT, 81, 4) AS InsCompanyLocation_CODE,
            SUBSTRING(A.Record_TEXT, 85, 35) AS InsHolderFull_NAME,
            SUBSTRING(A.Record_TEXT, 120, 9) AS InsHolderMemberSsn_NUMB,
            SUBSTRING(A.Record_TEXT, 129, 8) AS InsHolderBirth_DATE,
            SUBSTRING(A.Record_TEXT, 137, 10) AS InsHolderMemberMci_IDNO,
            SUBSTRING(A.Record_TEXT, 147, 18) AS PolicyInsNo_TEXT,
            SUBSTRING(A.Record_TEXT, 165, 17) AS InsuranceGroupNo_TEXT,
            SUBSTRING(A.Record_TEXT, 182, 4) AS Coverage_CODE,
            SUBSTRING(A.Record_TEXT, 186, 1) AS InsPolicyStatus_CODE,
            SUBSTRING(A.Record_TEXT, 187, 1) AS InsPolicyVerification_INDC,
            SUBSTRING(A.Record_TEXT, 188, 8) AS Begin_DATE,
            SUBSTRING(A.Record_TEXT, 196, 8) AS End_DATE,
            SUBSTRING(A.Record_TEXT, 204, 2) AS InsHolderRelationship_CODE,
            SUBSTRING(A.Record_TEXT, 206, 25) AS InsHolderEmployer_NAME,
            SUBSTRING(A.Record_TEXT, 231, 25) AS InsHolderEmpLine1Old_ADDR,
            SUBSTRING(A.Record_TEXT, 256, 25) AS InsHolderEmpLine2Old_ADDR,
            SUBSTRING(A.Record_TEXT, 281, 20) AS InsHolderEmpCityOld_ADDR,
            SUBSTRING(A.Record_TEXT, 301, 2) AS InsHolderEmpStateOld_ADDR,
            SUBSTRING(A.Record_TEXT, 303, 15) AS InsHolderEmpZipOld_ADDR,
            SUBSTRING(A.Record_TEXT, 318, 8) AS InsPolicyInfoAdd_DATE,
            SUBSTRING(A.Record_TEXT, 326, 8) AS InsPolicyInfoModify_DATE,
            SUBSTRING(A.Record_TEXT, 351, 1) AS InsHolderEmpAddrNormalization_CODE,
            SUBSTRING(A.Record_TEXT, 352, 50) AS InsHolderEmpLine1_ADDR,
            SUBSTRING(A.Record_TEXT, 402, 50) AS InsHolderEmpLine2_ADDR,
            SUBSTRING(A.Record_TEXT, 452, 28) AS InsHolderEmpCity_ADDR,
            SUBSTRING(A.Record_TEXT, 480, 2) AS InsHolderEmpState_ADDR,
            SUBSTRING(A.Record_TEXT, 482, 15) AS InsHolderEmpZip_ADDR,
            @Lc_ProcessN_INDC AS Process_INDC,
            @Ld_Run_DATE AS FileLoad_DATE
       FROM #LoadTpl_P1 A
      WHERE SUBSTRING(A.Record_TEXT, 1, 2) = @Lc_TypeRecordDt_CODE;

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;
    END;

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_LOAD_MEDICAID_TPL';
   COMMIT TRANSACTION TXN_LOAD_MEDICAID_TPL;

   SET @Ls_Sql_TEXT = 'DROP #LoadTpl_P1';
   DROP TABLE #LoadTpl_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_LOAD_MEDICAID_TPL;
    END;

   IF OBJECT_ID('tempdb..#LoadTpl_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadTpl_P1;
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
