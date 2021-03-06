/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_IRS_TAX_OFFSET]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_IRS_TAX_OFFSET
Programmer Name 	: IMP Team
Description			: The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_IRS_TAX_OFFSET is 
					  to extract delinquent NCPs to IRS for FOP programs
Frequency			: 'WEEKLY'
Developed On		: 
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_IRS_TAX_OFFSET]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE     CHAR(1) = 'A',
          @Lc_TypeErrorE_CODE            CHAR(1) = 'E',
          @Lc_TableTaxi_ID               CHAR(4) = 'TAXI',
          @Lc_TableSub_ID                CHAR(4) = 'YEAR',
          @Lc_RestartKeyArc1_TEXT        CHAR(4) = 'ARC1',
          @Lc_BatchRunUser_TEXT          CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                     CHAR(7) = 'DEB5310',
          @Lc_RejectJob_ID               CHAR(7) = 'DEB5220',
          @Lc_Successful_TEXT            CHAR(20) = 'SUCCESSFUL',
          @Ls_Procedure_NAME             VARCHAR(100) = 'SP_EXTRACT_IRS_TAX_OFFSET',
          @Ls_Process_NAME               VARCHAR(100) = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET',
          @Ls_RestartKeyStart_TEXT       VARCHAR(200) = 'START',
          @Ls_RestartKeyValEnd_TEXT      VARCHAR(200) = 'VALEND',
          @Ls_RestartKeySaveData_TEXT    VARCHAR(200) = 'SAVE_DATA',
          @Ls_RestartKeyExtractFile_TEXT VARCHAR(200) = 'EXTRACT_FILE';
  DECLARE @Ln_Zero_NUMB                 NUMERIC = 0,
          @Ln_TaxYear_NUMB              NUMERIC(4),
          @Ln_CommitFreq_QNTY           NUMERIC(5),
          @Ln_RejectCommitFreq_QNTY     NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY   NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY NUMERIC(6) = 0,
          @Ln_Error_NUMB                NUMERIC(11),
          @Ln_ErrorLine_NUMB            NUMERIC(11),
          @Ln_RowCount_QNTY             NUMERIC(19),
          @Lc_Empty_TEXT                CHAR = '',
          @Lc_Msg_CODE                  CHAR(5),
          @Lc_BateError_CODE            CHAR(5),
          @Ls_File_NAME                 VARCHAR(50),
          @Ls_FileLocation_TEXT         VARCHAR(80),
          @Ls_Sql_TEXT                  VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT         VARCHAR(200),
          @Ls_RestartKey_TEXT           VARCHAR(200),
          @Ls_SqlData_TEXT              VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT     VARCHAR(4000),
          @Ld_Run_DATE                  DATE,
          @Ld_LastRun_DATE              DATE,
          @Ld_RejectRun_DATE            DATE,
          @Ld_RejectLastRun_DATE        DATE,
          @Ld_Start_DATE                DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TABLE #NoticeInfo_P1';

   CREATE TABLE #NoticeInfo_P1
    (
      Case_IDNO             NUMERIC(6),
      MemberMci_IDNO        NUMERIC(10),
      IrsEligible_INDC      CHAR(1),
      AdmEligible_INDC      CHAR(1),
      PasEligible_INDC      CHAR(1),
      Notice_ID             CHAR(8),
      WaitFor35Days_INDC    CHAR(1),
      SendNotice_INDC       CHAR(1),
      SendAnnualNotice_INDC CHAR(1),
      SendMemberInFile_INDC CHAR(1),
      DeleteFromPifms_INDC  CHAR(1),
      ConversionData_INDC   CHAR(1)
    );

   SET @Ls_Sql_TEXT = 'CREATE TABLE #PifmsDataForNotice_P1';
   SET @Ls_SqlData_TEXT = '';

   SELECT MemberMci_IDNO,
          Case_IDNO,
          MemberSsn_NUMB,
          Last_NAME,
          First_NAME,
          Middle_NAME,
          TaxYear_NUMB,
          TypeArrear_CODE,
          Transaction_AMNT,
          SubmitLast_DATE,
          TypeTransaction_CODE,
          CountySubmitted_IDNO,
          Certified_DATE,
          StateAdministration_CODE,
          ExcludeIrs_CODE,
          ExcludeAdm_CODE,
          ExcludeFin_CODE,
          ExcludePas_CODE,
          ExcludeRet_CODE,
          ExcludeSal_CODE,
          ExcludeDebt_CODE,
          ExcludeVen_CODE,
          ExcludeIns_CODE,
          Submit_INDC,
          CurrentAction_INDC
     INTO #PifmsDataForNotice_P1
     FROM PIFMS_Y1
    WHERE 1 = 2;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_RejectJob_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_RejectJob_ID,
    @Ad_Run_DATE                = @Ld_RejectRun_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_RejectLastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_RejectCommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
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
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECK WHETHER REJECT PROCESS RAN BEFORE THIS JOB';

   IF @Ld_RejectLastRun_DATE < DATEADD(D, 1, @Ld_LastRun_DATE)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'REJECT PROCESS SHOULD RUN BEFORE THIS JOB - (DEB5220)';

     RAISERROR (50001,16,1);
    END

   /*
    Calculating the Year Tax
    If the current month is DEC 2007 means then year tax is 2007 otherwise Year Tax is 2006
   */
   SET @Ls_Sql_TEXT = 'SET IRS TAX YEAR FROM RUN DATE';
   SET @Ln_TaxYear_NUMB = DATEPART(YYYY, @Ld_Run_DATE);

   IF DATEPART(MONTH, @Ld_Run_DATE) <> 12
    BEGIN
     SET @Ln_TaxYear_NUMB = @Ln_TaxYear_NUMB - 1;
    END

   SET @Ls_RestartKey_TEXT = @Ls_RestartKeyStart_TEXT;
   SET @Ls_Sql_TEXT = ' SELECT - RSTL_Y1 ';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ls_RestartKey_TEXT = RestartKey_TEXT
     FROM RSTL_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     BEGIN
      SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART';
      SET @Ls_SqlData_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Ls_RestartKeyStart_TEXT, '');

      EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
       @As_RestartKey_TEXT       = @Ls_RestartKeyStart_TEXT,
       @Ac_Job_ID                = @Lc_Job_ID,
       @Ad_Run_DATE              = @Ld_Run_DATE,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR(50001,16,1);
       END;
     END
    END
   ELSE
    BEGIN
     IF LEFT(UPPER(LTRIM(RTRIM(@Ls_RestartKey_TEXT))), 3) = 'VAL'
        AND @Ls_RestartKey_TEXT <> @Ls_RestartKeyValEnd_TEXT
      BEGIN
       GOTO VALIDATE_IFMS;
      END
     ELSE IF UPPER(LTRIM(RTRIM(@Ls_RestartKey_TEXT))) = @Ls_RestartKeyValEnd_TEXT
      BEGIN
       GOTO GATHER_NOTICE_INFO;
      END
     ELSE IF UPPER(LTRIM(RTRIM(@Ls_RestartKey_TEXT))) = @Ls_RestartKeySaveData_TEXT
      BEGIN
       GOTO SAVE_TRANSACTION_DATA;
      END
     ELSE IF UPPER(LTRIM(RTRIM(@Ls_RestartKey_TEXT))) = @Ls_RestartKeyExtractFile_TEXT
      BEGIN
       GOTO EXTRACT_FILE;
      END
    END

   IF @Ls_RestartKey_TEXT = @Ls_RestartKeyStart_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE PIFMS_Y1';
     SET @Ls_SqlData_TEXT = '';

     DELETE FROM PIFMS_Y1;

     SET @Ls_Sql_TEXT = 'DELETE PMCAR_Y1';
     SET @Ls_SqlData_TEXT = '';

     DELETE FROM PMCAR_Y1;

     SET @Ls_Sql_TEXT = 'DELETE EINCP_Y1';
     SET @Ls_SqlData_TEXT = '';

     DELETE FROM EINCP_Y1;

     SET @Ls_Sql_TEXT = 'DELETE RSTL_Y1';
     SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     DELETE FROM RSTL_Y1
      WHERE Job_ID = @Lc_Job_ID;
    END

   CALCULATE_NCP_ARREARS:

   IF @Ls_RestartKey_TEXT = @Ls_RestartKeyStart_TEXT
       OR @Ls_RestartKey_TEXT = @Lc_RestartKeyArc1_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_CALCULATE_NCP_ARREARS';
     SET @Ls_SqlData_TEXT = '';

     EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_CALCULATE_NCP_ARREARS
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @As_RestartKey_TEXT       = @Ls_RestartKey_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END
    END

   VALIDATE_IFMS:

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_VALIDATE_IFMS';
   SET @Ls_SqlData_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Ls_RestartKey_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_TaxYear_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_VALIDATE_IFMS
    @As_RestartKey_TEXT       = @Ls_RestartKey_TEXT,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   GATHER_NOTICE_INFO:

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GATHER_NOTICE_INFO';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GATHER_NOTICE_INFO
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   GENERATE_NOTICE:

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GENERATE_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GENERATE_NOTICE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART';
   SET @Ls_SqlData_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Ls_RestartKeySaveData_TEXT, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Ls_RestartKeySaveData_TEXT,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END;

   SAVE_TRANSACTION_DATA:

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET';

   BEGIN TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_TRANSACTION_DATA';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_TaxYear_NUMB AS VARCHAR), '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_TRANSACTION_DATA
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_LastRun_DATE          = @Ld_LastRun_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET';

   COMMIT TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET;

   SET @Ls_Sql_TEXT = 'DELETE PIRST_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM PIRST_Y1;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART';
   SET @Ls_SqlData_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Ls_RestartKeyExtractFile_TEXT, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Ls_RestartKeyExtractFile_TEXT,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END;

   EXTRACT_FILE:

   --13634 - Per CR0411, generate CSM-23 notice for cases added to IFMS_Y1 for the 1st time in it's life. -START-
   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GENERATE_CSM23_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GENERATE_CSM23_NOTICE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END
   --13634 - Per CR0411, generate CSM-23 notice for cases added to IFMS_Y1 for the 1st time in it's life. -END-
   
   SET @Ls_Sql_TEXT = 'GET PROCESSED RECORD COUNT';
   SET @Ls_SqlData_TEXT = 'SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT (1)
     FROM FEDH_Y1
    WHERE SubmitLast_DATE = @Ld_Run_DATE;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

     SELECT @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE,
            @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = '';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_FILE';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_FILE
    @As_File_NAME             = @Ls_File_NAME,
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET';

   BEGIN TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET;

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
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE RSTL_Y1';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM RSTL_Y1
    WHERE Job_ID = @Lc_Job_ID;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET';

   COMMIT TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET;

   SET @Ls_Sql_TEXT = 'DROP TEMPORARY TABLES';

   IF OBJECT_ID('tempdb..#NoticeInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #NoticeInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#PifmsDataForNotice_P1') IS NOT NULL
    BEGIN
     DROP TABLE #PifmsDataForNotice_P1;
    END;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_EXTRACT_IRS_TAX_OFFSET;
    END

   IF OBJECT_ID('tempdb..#NoticeInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #NoticeInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#PifmsDataForNotice_P1') IS NOT NULL
    BEGIN
     DROP TABLE #PifmsDataForNotice_P1;
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
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
