/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_EXTRACT_STATE_TAX_OFFSET]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_EXTRACT_STATE_TAX_OFFSET
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_EXTRACT_STATE_TAX_OFFSET is 
					  to send delinquent NCPs to DOR for State Tax Offset programs
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_EXTRACT_STATE_TAX_OFFSET]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT             CHAR = ' ',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_TypeRecordH_CODE       CHAR(1) = 'H',
          @Lc_Note_INDC              CHAR(1) = 'N',
          @Lc_StateTax_CODE          CHAR(1) = '2',
          @Lc_StateAgencyCsp_CODE    CHAR(3) = 'CSP',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateError_CODE         CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB5320',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_EXTRACT_STATE_TAX_OFFSET',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET',
          @Ls_BateError_TEXT         VARCHAR(4000) = 'NO RECORD(S) TO PROCESS',
          @Ld_High_DATE              DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_StateTaxYear_NUMB           NUMERIC(4),
          @Ln_CurrentTaxYear_NUMB         NUMERIC(4),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RestartLine_NUMB            NUMERIC(5, 0) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Li_RowCount_QNTY               SMALLINT,
          @Lc_Empty_TEXT                  CHAR = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##ExtractStateTaxOffset_P1';

   CREATE TABLE ##ExtractStateTaxOffset_P1
    (
      Record_TEXT CHAR(80)
    );

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TABLE #GetEligibleCases_P1';

   CREATE TABLE #GetEligibleCases_P1
    (
      MemberMci_IDNO        NUMERIC(10),
      Case_IDNO             NUMERIC(6),
      County_CODE           CHAR(3),
      Office_CODE           CHAR(3),
      TypeCase_CODE         CHAR(1),
      StatusCase_CODE       CHAR(1),
      RespondInit_CODE      CHAR(1),
      CaseRelationship_CODE CHAR(1),
      CaseMemberStatus_CODE CHAR(1),
      Last_NAME             CHAR(20),
      First_NAME            CHAR(15),
      Middle_NAME           CHAR(20),
      MemberSsn_NUMB        NUMERIC(9),
      TaxYear_NUMB          NUMERIC(4),
      Create_DATE           DATE
    );

   SET @Ls_Sql_TEXT = 'CREATE TABLE #CalculateCaseArrears_P1';

   CREATE TABLE #CalculateCaseArrears_P1
    (
      MemberMci_IDNO            NUMERIC(10),
      Case_IDNO                 NUMERIC(6),
      TanfArrear_AMNT           NUMERIC(11, 2),
      NonTanfArrear_AMNT        NUMERIC(11, 2),
      TanfManualExclude_INDC    CHAR(1),
      NonTanfManualExclude_INDC CHAR(1),
      TanfCertified_INDC        CHAR(1),
      NonTanfCertified_INDC     CHAR(1),
      Notice_DATE               DATE,
      Create_DATE               DATE
    );

   SET @Ls_Sql_TEXT = 'CREATE TABLE #InsertPreOffset_P1';

   CREATE TABLE #InsertPreOffset_P1
    (
      MemberMci_IDNO           NUMERIC(10),
      Case_IDNO                NUMERIC(6),
      MemberSsn_NUMB           NUMERIC(9),
      County_CODE              CHAR(3),
      TanfArrear_AMNT          NUMERIC(11, 2),
      NonTanfArrear_AMNT       NUMERIC(11, 2),
      Create_DATE              DATE,
      TransactionEventSeq_NUMB NUMERIC(19)
    );

   SET @Ls_Sql_TEXT = 'CREATE TABLE #IstxData_P1';
   SET @Ls_SqlData_TEXT = '';

   SELECT MemberMci_IDNO,
          Case_IDNO,
          MemberSsn_NUMB,
          TaxYear_NUMB,
          TypeTransaction_CODE,
          TypeArrear_CODE,
          Transaction_AMNT,
          SubmitLast_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          ExcludeState_CODE,
          CountyFips_CODE
     INTO #IstxData_P1
     FROM ISTX_Y1
    WHERE 1 = 2;

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
   SET @Ls_FileSource_TEXT = @Lc_Empty_TEXT + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = @Lc_Empty_TEXT
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE ESTXO_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM ESTXO_Y1;

   /*
    Calculating the Year Tax
    If the current month is DEC 2007 means then year tax is 2007 otherwise Year Tax is 2006
   */
   SET @Ls_Sql_TEXT = 'SET STATE TAX YEAR FROM RUN DATE';
   SET @Ln_CurrentTaxYear_NUMB = DATEPART(YYYY, @Ld_Run_DATE);

   IF DATEPART(MONTH, @Ld_Run_DATE) <> 12
    BEGIN
     SET @Ln_CurrentTaxYear_NUMB = @Ln_CurrentTaxYear_NUMB - 1;
    END

   SET @Ln_StateTaxYear_NUMB = @Ln_CurrentTaxYear_NUMB;
   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GET_ELIGIBLE_CASES';
   SET @Ls_SqlData_TEXT = '';

   EXEC BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GET_ELIGIBLE_CASES
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_StateTaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_CALC_CASE_ARREAR';
   SET @Ls_SqlData_TEXT = '';

   EXEC BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_CALC_CASE_ARREAR
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_StateTaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_OFFSET_PROCESS';
   SET @Ls_SqlData_TEXT = '';

   EXEC BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_OFFSET_PROCESS
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_StateTaxYear_NUMB,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_NMRQ_ENF26';
   SET @Ls_SqlData_TEXT = '';

   EXEC BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_NMRQ_ENF26
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_STATE_TAX_OFFSET';

   BEGIN TRANSACTION TXN_STATE_TAX_OFFSET;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_ISTX_SLST';
   SET @Ls_SqlData_TEXT = '';

   EXEC BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_ISTX_SLST
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @An_TaxYear_NUMB          = @Ln_StateTaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT ESTXO_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT ESTXO_Y1
          (NcpSsn_NUMB,
           LastNcp_NAME,
           FirstNcp_NAME,
           SpouseFirst_NAME,
           NcpOwed_AMNT,
           SecondarySsn_NUMB)
   SELECT (SELECT TOP 1 X.MemberSsn_NUMB
             FROM MSSN_Y1 X
            WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
              AND X.TypePrimary_CODE IN ('P', 'I')
              AND X.Enumeration_CODE = 'Y'
              AND X.EndValidity_DATE = @Ld_High_DATE
            ORDER BY X.MemberMci_IDNO ASC,
                     X.TypePrimary_CODE DESC) AS NcpSsn_NUMB,
          B.Last_NAME,
          SUBSTRING(B.First_NAME, 1, 12) AS FirstNcp_NAME,
          REPLICATE(@Lc_Space_TEXT, 12) AS SpouseFirst_NAME,
          A.TotalOwed_AMNT,
          ISNULL((SELECT TOP 1 X.MemberSsn_NUMB
                    FROM MSSN_Y1 X
                   WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                     AND X.TypePrimary_CODE = 'S'
                     AND X.Enumeration_CODE = 'Y'
                     AND X.EndValidity_DATE = @Ld_High_DATE), @Ln_Zero_NUMB) AS SecondarySsn_NUMB
     FROM (SELECT X.MemberMci_IDNO,
                  SUM(X.Arrears_AMNT) AS TotalOwed_AMNT
             FROM SLST_Y1 X
            WHERE X.TypeArrear_CODE IN ('A', 'N')
              AND X.TypeTransaction_CODE NOT IN ('A', 'L', 'D')
              AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                         FROM SLST_Y1 Y
                                        WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                          AND Y.TypeArrear_CODE = X.TypeArrear_CODE)
            GROUP BY X.MemberMci_IDNO) A,
          DEMO_Y1 B
    WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
      AND EXISTS (SELECT 1
                    FROM MSSN_Y1 X
                   WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                     AND X.TypePrimary_CODE IN ('P', 'I')
                     AND X.Enumeration_CODE = 'Y'
                     AND X.EndValidity_DATE = @Ld_High_DATE)
    ORDER BY A.MemberMci_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;
    END;

   --13634 - Per CR0411, generate CSM-23 notice for cases added to ISTX_Y1 for the 1st time in it's life. -START-
   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_STATE_TAX_OFFSET';

   COMMIT TRANSACTION TXN_STATE_TAX_OFFSET;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GENERATE_CSM23_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GENERATE_CSM23_NOTICE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END
   --13634 - Per CR0411, generate CSM-23 notice for cases added to ISTX_Y1 for the 1st time in it's life. -END-

   SET @Ls_Sql_TEXT = 'INSERT ##ExtractStateTaxOffset_P1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##ExtractStateTaxOffset_P1
               (Record_TEXT)
   SELECT (@Lc_TypeRecordH_CODE + @Lc_StateAgencyCsp_CODE + REPLICATE(@Lc_Space_TEXT, 76)) AS Record_TEXT
   UNION ALL
   SELECT (@Lc_StateTax_CODE + (RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(NcpSsn_NUMB)), 9)) + ISNULL(CAST(LEFT((LTRIM(RTRIM(LastNcp_NAME)) + REPLICATE(' ', 24)), 24) AS CHAR(24)), REPLICATE(@Lc_Space_TEXT, 24)) + ISNULL(CAST(LEFT((LTRIM(RTRIM(FirstNcp_NAME)) + REPLICATE(' ', 12)), 12) AS CHAR(12)), REPLICATE(@Lc_Space_TEXT, 12)) + REPLICATE(@Lc_Space_TEXT, 12) + REPLICATE(@Lc_Space_TEXT, 2) + (RIGHT(REPLICATE('0', 9) + REPLACE(LTRIM(RTRIM(NcpOwed_AMNT)), '.', ''), 9)) + (RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(SecondarySsn_NUMB)), 9)) + REPLICATE(@Lc_Space_TEXT, 2)) AS Record_TEXT
     FROM ESTXO_Y1;

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

--13840 - DOR tax offset job is not placing the header record at the beginning of the file -START-      
   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractStateTaxOffset_P1 ORDER BY LEFT(Record_TEXT, 1) DESC, SUBSTRING(Record_TEXT, 1, 10)';
--13840 - DOR tax offset job is not placing the header record at the beginning of the file -END-   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_Query_TEXT, '');

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_STATE_TAX_OFFSET';

   BEGIN TRANSACTION TXN_STATE_TAX_OFFSET;

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
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_STATE_TAX_OFFSET';

   COMMIT TRANSACTION TXN_STATE_TAX_OFFSET;

   SET @Ls_Sql_TEXT = 'DROP ALL TEMPORARY TABLES';

   IF OBJECT_ID('tempdb..##ExtractStateTaxOffset_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractStateTaxOffset_P1;
    END;

   IF OBJECT_ID('tempdb..#GetEligibleCases_P1') IS NOT NULL
    BEGIN
     DROP TABLE #GetEligibleCases_P1;
    END;

   IF OBJECT_ID('tempdb..#CalculateCaseArrears_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CalculateCaseArrears_P1;
    END;

   IF OBJECT_ID('tempdb..#InsertPreOffset_P1') IS NOT NULL
    BEGIN
     DROP TABLE #InsertPreOffset_P1;
    END;

   IF OBJECT_ID('tempdb..#IstxData_P1') IS NOT NULL
    BEGIN
     DROP TABLE #IstxData_P1;
    END;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_STATE_TAX_OFFSET;
    END;

   IF OBJECT_ID('tempdb..##ExtractStateTaxOffset_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractStateTaxOffset_P1;
    END;

   IF OBJECT_ID('tempdb..#GetEligibleCases_P1') IS NOT NULL
    BEGIN
     DROP TABLE #GetEligibleCases_P1;
    END;

   IF OBJECT_ID('tempdb..#CalculateCaseArrears_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CalculateCaseArrears_P1;
    END;

   IF OBJECT_ID('tempdb..#InsertPreOffset_P1') IS NOT NULL
    BEGIN
     DROP TABLE #InsertPreOffset_P1;
    END;

   IF OBJECT_ID('tempdb..#IstxData_P1') IS NOT NULL
    BEGIN
     DROP TABLE #IstxData_P1;
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
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
