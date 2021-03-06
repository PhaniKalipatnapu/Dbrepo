/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_FIDM$SP_PROCESS_FIDM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_FIDM$SP_PROCESS_FIDM
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_FIDM$SP_PROCESS_FIDM reads the data from the temporary tables (LFIIR_Y1, LACHL_Y1 ) 
					  and updates the database tables with address and account information and starts the FIDM enforcement remedy
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
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_FIDM$SP_PROCESS_FIDM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_INDC                      CHAR = 'Y',
          @Lc_No_INDC                       CHAR = 'N',
          @Lc_TypeAddressM_CODE             CHAR(1) = 'M',
          @Lc_TypeOthp_CODE                 CHAR(1) = 'H',
          @Lc_Comma_TEXT                    CHAR(1) = ',',
          @Lc_JointAcct_INDC                CHAR(1) = 'N',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE        CHAR(1) = 'A',
          @Lc_StatusP_CODE                  CHAR(1) = 'P',
          @Lc_TypeErrorE_CODE               CHAR(1) = 'E',
          @Lc_ProcessY_INDC                 CHAR(1) = 'Y',
          @Lc_ProcessN_INDC                 CHAR(1) = 'N',
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_Note_INDC                     CHAR(1) = 'N',
          @Lc_CaseMemberStatusA_CODE        CHAR(1) = 'A',
          @Lc_StatusCaseO_CODE              CHAR(1) = 'O',
          @Lc_StatusCaseC_CODE              CHAR(1) = 'C',
          @Lc_CaseRelationshipA_CODE        CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE        CHAR(1) = 'P',
          @Lc_SourceVerifiedA_CODE          CHAR(1) = 'A',
          @Lc_DirectPaymentCredit_CODE      CHAR(2) = 'CD',
          @Lc_DisabilityInsurance_CODE      CHAR(2) = 'DB',
          @Lc_EmployerWage_CODE             CHAR(2) = 'EW',
          @Lc_RegularPaymentFromNcp_CODE    CHAR(2) = 'RE',
          @Lc_UnemploymentCompensation_CODE CHAR(2) = 'UC',
          @Lc_WorkersCompensation_CODE      CHAR(2) = 'WC',
          @Lc_Voluntary_CODE                CHAR(2) = 'VN',
          @Lc_Country_ADDR                  CHAR(2) = 'US',
          @Lc_RsnStatusCaseUb_CODE          CHAR(2) = 'UB',
          @Lc_RsnStatusCaseUc_CODE          CHAR(2) = 'UC',
          @Lc_SourceLoc_CODE                CHAR(3) = 'FID',
          @Lc_Subsystem_CODE                CHAR(3) = 'LO',
          @Lc_TableMast_ID                  CHAR(4) = 'MAST',
          @Lc_TableSubFina_ID               CHAR(4) = 'FINA',
          @Lc_ActivityMajorFidm_CODE        CHAR(4) = 'FIDM',
          @Lc_ActivityMajorCase_CODE        CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO            CHAR(4) = ' ',
          @Lc_BateErrorE0012_CODE           CHAR(5) = 'E0012',
          @Lc_ActivityMinorRadfd_CODE       CHAR(5) = 'RADFD',
          @Lc_BateErrorE0759_CODE           CHAR(5) = 'E0759',
          @Lc_BateErrorE0085_CODE           CHAR(5) = 'E0085',
          @Lc_BateErrorE1373_CODE           CHAR(5) = 'E1373',
          @Lc_BateErrorE1095_CODE           CHAR(5) = 'E1095',
          @Lc_BateErrorE1138_CODE           CHAR(5) = 'E1138',
          @Lc_BateErrorE0073_CODE           CHAR(5) = 'E0073',
          @Lc_BateErrorE0102_CODE           CHAR(5) = 'E0102',
          @Lc_BateErrorE1564_CODE           CHAR(5) = 'E1564',
          @Lc_BateErrorE1565_CODE           CHAR(5) = 'E1565',
          @Lc_BateErrorE1566_CODE           CHAR(5) = 'E1566',
          @Lc_BateErrorE1567_CODE           CHAR(5) = 'E1567',
          @Lc_BateErrorE1568_CODE           CHAR(5) = 'E1568',
          @Lc_BateErrorE1569_CODE           CHAR(5) = 'E1569',
          @Lc_BateErrorE1570_CODE           CHAR(5) = 'E1570',
          @Lc_BateErrorE1571_CODE           CHAR(5) = 'E1571',
          @Lc_BateErrorE1424_CODE           CHAR(5) = 'E1424',
          @Lc_BateErrorE1089_CODE           CHAR(5) = 'E1089',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE           CHAR(5) = 'E0944',
          @Lc_Job_ID                        CHAR(7) = 'DEB5240',
          @Lc_Notice_ID                     CHAR(8) = NULL,
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT          CHAR(30) = 'PARM DATE PROBLEM',
          @Lc_WorkerDelegate_ID             CHAR(30) = ' ',
          @Lc_Reference_ID                  CHAR(30) = ' ',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_ENF_INCOMING_FIDM',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_PROCESS_FIDM',
          @Ls_XmlIn_TEXT                    VARCHAR(4000) = ' ',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Low_DATE                      DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                             NUMERIC = 0,
          @Ln_LastNameFoundPosition_NUMB            NUMERIC = 0,
          @Ln_LastNameLength_NUMB                   NUMERIC = 0,
          @Ln_CommaFoundPosition_NUMB               NUMERIC = 0,
          @Ln_SpaceFoundPosition_NUMB               NUMERIC = 0,
          @Ln_Office_IDNO                           NUMERIC(3) = 0,
          @Ln_CommitFreqParm_QNTY                   NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY           NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                       NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY               NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                      NUMERIC(5),
          @Ln_MajorIntSeq_NUMB                      NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB                      NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY             NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY       NUMERIC(6) = 0,
          @Ln_OtherParty_IDNO                       NUMERIC(9) = 0,
          @Ln_RecordCount_QNTY                      NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO                          NUMERIC(10) = 0,
          @Ln_Topic_IDNO                            NUMERIC(10),
          @Ln_Schedule_NUMB                         NUMERIC(10) = 0,
          @Ln_ActiveMemberOpenCaseCount_QNTY        NUMERIC(11),
          @Ln_ActiveMemberOpenCaseClosingCount_QNTY NUMERIC(11),
          @Ln_ErrorLine_NUMB                        NUMERIC(11) = 0,
          @Ln_Error_NUMB                            NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB              NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY                      SMALLINT,
          @Li_RowCount_QNTY                         SMALLINT,
          @Lc_Msg_CODE                              CHAR(5),
          @Lc_BateError_CODE                        CHAR(5),
          @Lc_Last_NAME                             CHAR(40) = '',
          @Ls_Sql_TEXT                              VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT                   VARCHAR(200),
          @Ls_SqlData_TEXT                          VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT                     VARCHAR(2000),
          @Ls_DescriptionError_TEXT                 VARCHAR(4000),
          @Ls_BateRecord_TEXT                       VARCHAR(4000),
          @Ld_Run_DATE                              DATE,
          @Ld_LastRun_DATE                          DATE,
          @Ld_Start_DATE                            DATETIME2;
  DECLARE @Ln_FidmCur_SeqA_IDNO                             NUMERIC(19),
          @Lc_FidmCur_RecAId_TEXT                           CHAR(1),
          @Lc_FidmCur_TapeReelNumb_TEXT                     CHAR(3),
          @Lc_FidmCur_FinancialInstitutionEINIdno_TEXT      CHAR(9),
          @Lc_FidmCur_InstitutionControlName_TEXT           CHAR(4),
          @Lc_FidmCur_FileGeneratedDateA_TEXT               CHAR(6),
          @Lc_FidmCur_ReceivedFileTypeCode_TEXT             CHAR(1),
          @Lc_FidmCur_ServiceBureauCode_TEXT                CHAR(1),
          @Lc_FidmCur_MagneticTapeCode_TEXT                 CHAR(2),
          @Lc_FidmCur_ForeignCorrespondenceCode_TEXT        CHAR(1),
          @Lc_FidmCur_InstitutionName_TEXT                  CHAR(40),
          @Lc_FidmCur_InstitutionSecondName_TEXT            CHAR(40),
          @Lc_FidmCur_TransferAgentCode_TEXT                CHAR(1),
          @Lc_FidmCur_ReportingAgentEINIdno_TEXT            CHAR(9),
          @Ls_FidmCur_ReportingAgentName_TEXT               VARCHAR(71),
          @Lc_FidmCur_ReportingAgentStreetAddr_TEXT         CHAR(40),
          @Lc_FidmCur_ReportingAgentCityAddr_TEXT           CHAR(29),
          @Lc_FidmCur_ReportingAgentStateAddr_TEXT          CHAR(2),
          @Lc_FidmCur_ReportingAgentZipAddr_TEXT            CHAR(9),
          @Lc_FidmCur_DataMatchCode_TEXT                    CHAR(1),
          @Lc_FidmCur_InstitutionAddrNormalizationCode_TEXT CHAR(1) = 'N',
          @Ls_FidmCur_InstitutionLine1Addr_TEXT             VARCHAR(50),
          @Ls_FidmCur_InstitutionLine2Addr_TEXT             VARCHAR(50),
          @Lc_FidmCur_InstitutionCityAddr_TEXT              CHAR(28),
          @Lc_FidmCur_InstitutionStateAddr_TEXT             CHAR(2),
          @Lc_FidmCur_InstitutionZipAddr_TEXT               CHAR(15),
          @Ln_FidmCur_FidmFiirSeq_IDNO                      NUMERIC(19),
          @Ln_FidmCur_SeqB_IDNO                             NUMERIC(19),
          @Lc_FidmCur_RecBId_TEXT                           CHAR(1),
          @Lc_FidmCur_FileGeneratedDateB_TEXT               CHAR(6),
          @Lc_FidmCur_PayeeLastName_TEXT                    CHAR(4),
          @Lc_FidmCur_MatchedSsnNumb_TEXT                   CHAR(9),
          @Lc_FidmCur_PayeeAccountNumb_TEXT                 CHAR(20),
          @Ls_FidmCur_FullAccountTitle_TEXT                 VARCHAR(100),
          @Lc_FidmCur_ForeignCountryCode_TEXT               CHAR(1),
          @Lc_FidmCur_MatchedName_TEXT                      CHAR(40),
          @Lc_FidmCur_SecondPayeeName_TEXT                  CHAR(40),
          @Lc_FidmCur_FipsPassBackCode_TEXT                 CHAR(5),
          @Lc_FidmCur_AdditionalStatePassBack_TEXT          CHAR(23),
          @Lc_FidmCur_AccountBalanceAmnt_TEXT               CHAR(7),
          @Lc_FidmCur_AccountMatchCode_TEXT                 CHAR(1),
          @Lc_FidmCur_TrustFundCode_TEXT                    CHAR(1),
          @Lc_FidmCur_AccountBalanceCode_TEXT               CHAR(1),
          @Lc_FidmCur_AccountUpdateCode_TEXT                CHAR(1),
          @Lc_FidmCur_AccountHolderBirthDate_TEXT           CHAR(8),
          @Lc_FidmCur_StatePassBack_TEXT                    CHAR(10),
          @Lc_FidmCur_AccountTypeCode_TEXT                  CHAR(2),
          @Lc_FidmCur_CasePassBack_TEXT                     CHAR(15),
          @Lc_FidmCur_PayeeCode_TEXT                        CHAR(1),
          @Lc_FidmCur_PrimarySsnNumb_TEXT                   CHAR(9),
          @Lc_FidmCur_SecondPayeeSsnNumb_TEXT               CHAR(9),
          @Lc_FidmCur_MatchedAddrNormalizationCode_TEXT     CHAR(1) = 'N',
          @Ls_FidmCur_MatchedLine1Addr_TEXT                 VARCHAR(50),
          @Ls_FidmCur_MatchedLine2Addr_TEXT                 VARCHAR(50),
          @Lc_FidmCur_MatchedCityAddr_TEXT                  CHAR(28),
          @Lc_FidmCur_MatchedStateAddr_TEXT                 CHAR(2),
          @Lc_FidmCur_MatchedZipAddr_TEXT                   CHAR(15),
          @Ln_CaseMemberCur_Case_IDNO                       NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO                  NUMERIC(10);
  DECLARE @Ln_FidmCur_FinancialInstitutionEIN_IDNO NUMERIC(9),
          @Ln_FidmCur_MatchedSsn_NUMB              NUMERIC(9),
          @Ln_FidmCur_StatePassBack_IDNO           NUMERIC(10),
          @Ln_FidmCur_AccountBalance_AMNT          NUMERIC(11, 2) = 0;
  DECLARE Fidm_CUR INSENSITIVE CURSOR FOR
   SELECT A.Seq_IDNO AS SeqA_IDNO,
          A.Rec_ID AS RecA_ID,
          A.TapeReel_NUMB,
          A.FinancialInstitutionEIN_IDNO,
          A.InstitutionControl_NAME,
          A.FileGenerated_DATE,
          A.ReceivedFileType_CODE,
          A.ServiceBureau_CODE,
          A.MagneticTape_CODE,
          A.ForeignCorrespondence_CODE,
          A.Institution_NAME,
          A.InstitutionSecond_NAME,
          A.TransferAgent_CODE,
          A.ReportingAgentEIN_IDNO,
          A.ReportingAgent_NAME,
          A.ReportingAgentStreet_ADDR,
          A.ReportingAgentCity_ADDR,
          A.ReportingAgentState_ADDR,
          A.ReportingAgentZip_ADDR,
          A.DataMatch_CODE,
          A.InstitutionAddrNormalization_CODE,
          A.InstitutionLine1_ADDR,
          A.InstitutionLine2_ADDR,
          A.InstitutionCity_ADDR,
          A.InstitutionState_ADDR,
          A.InstitutionZip_ADDR,
          B.FidmFiirSeq_IDNO,
          B.Seq_IDNO AS SeqB_IDNO,
          B.Rec_ID AS RecB_ID,
          B.FileGenerated_DATE,
          B.PayeeLast_NAME,
          B.MatchedSsn_NUMB,
          B.PayeeAccount_NUMB,
          B.FullAccountTitle_TEXT,
          B.ForeignCountry_CODE,
          B.Matched_NAME,
          B.SecondPayee_NAME,
          B.FipsPassBack_CODE,
          B.AdditionalStatePassBack_TEXT,
          B.AccountBalance_AMNT,
          B.AccountMatch_CODE,
          B.TrustFund_CODE,
          B.AccountBalance_CODE,
          B.AccountUpdate_CODE,
          B.AccountHolderBirth_DATE,
          B.StatePassBack_TEXT,
          B.AccountType_CODE,
          B.CasePassBack_TEXT,
          B.Payee_CODE,
          B.PrimarySsn_NUMB,
          B.SecondPayeeSsn_NUMB,
          B.MatchedAddrNormalization_CODE,
          B.MatchedLine1_ADDR,
          B.MatchedLine2_ADDR,
          B.MatchedCity_ADDR,
          B.MatchedState_ADDR,
          B.MatchedZip_ADDR
     FROM LFIIR_Y1 A,
          LACHL_Y1 B
    WHERE A.Process_INDC = @Lc_ProcessN_INDC
      AND B.FidmFiirSeq_IDNO = A.Seq_IDNO
      AND B.Process_INDC = @Lc_ProcessN_INDC
    ORDER BY A.Seq_IDNO,
             B.FidmFiirSeq_IDNO,
             B.Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_FIDM';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_PROCESS_FIDM;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
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

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO PROCESS FROM LFIIR_Y1';
   SET @Ls_SqlData_TEXT = '';

   IF EXISTS (SELECT 1
                FROM LFIIR_Y1 A,
                     LACHL_Y1 B
               WHERE A.Process_INDC = @Lc_ProcessN_INDC
                 AND B.FidmFiirSeq_IDNO = A.Seq_IDNO
                 AND B.Process_INDC = @Lc_ProcessN_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'OPEN Fidm_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN Fidm_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Fidm_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM Fidm_CUR INTO @Ln_FidmCur_SeqA_IDNO, @Lc_FidmCur_RecAId_TEXT, @Lc_FidmCur_TapeReelNumb_TEXT, @Lc_FidmCur_FinancialInstitutionEINIdno_TEXT, @Lc_FidmCur_InstitutionControlName_TEXT, @Lc_FidmCur_FileGeneratedDateA_TEXT, @Lc_FidmCur_ReceivedFileTypeCode_TEXT, @Lc_FidmCur_ServiceBureauCode_TEXT, @Lc_FidmCur_MagneticTapeCode_TEXT, @Lc_FidmCur_ForeignCorrespondenceCode_TEXT, @Lc_FidmCur_InstitutionName_TEXT, @Lc_FidmCur_InstitutionSecondName_TEXT, @Lc_FidmCur_TransferAgentCode_TEXT, @Lc_FidmCur_ReportingAgentEINIdno_TEXT, @Ls_FidmCur_ReportingAgentName_TEXT, @Lc_FidmCur_ReportingAgentStreetAddr_TEXT, @Lc_FidmCur_ReportingAgentCityAddr_TEXT, @Lc_FidmCur_ReportingAgentStateAddr_TEXT, @Lc_FidmCur_ReportingAgentZipAddr_TEXT, @Lc_FidmCur_DataMatchCode_TEXT, @Lc_FidmCur_InstitutionAddrNormalizationCode_TEXT, @Ls_FidmCur_InstitutionLine1Addr_TEXT, @Ls_FidmCur_InstitutionLine2Addr_TEXT, @Lc_FidmCur_InstitutionCityAddr_TEXT, @Lc_FidmCur_InstitutionStateAddr_TEXT, @Lc_FidmCur_InstitutionZipAddr_TEXT, @Ln_FidmCur_FidmFiirSeq_IDNO, @Ln_FidmCur_SeqB_IDNO, @Lc_FidmCur_RecBId_TEXT, @Lc_FidmCur_FileGeneratedDateB_TEXT, @Lc_FidmCur_PayeeLastName_TEXT, @Lc_FidmCur_MatchedSsnNumb_TEXT, @Lc_FidmCur_PayeeAccountNumb_TEXT, @Ls_FidmCur_FullAccountTitle_TEXT, @Lc_FidmCur_ForeignCountryCode_TEXT, @Lc_FidmCur_MatchedName_TEXT, @Lc_FidmCur_SecondPayeeName_TEXT, @Lc_FidmCur_FipsPassBackCode_TEXT, @Lc_FidmCur_AdditionalStatePassBack_TEXT, @Lc_FidmCur_AccountBalanceAmnt_TEXT, @Lc_FidmCur_AccountMatchCode_TEXT, @Lc_FidmCur_TrustFundCode_TEXT, @Lc_FidmCur_AccountBalanceCode_TEXT, @Lc_FidmCur_AccountUpdateCode_TEXT, @Lc_FidmCur_AccountHolderBirthDate_TEXT, @Lc_FidmCur_StatePassBack_TEXT, @Lc_FidmCur_AccountTypeCode_TEXT, @Lc_FidmCur_CasePassBack_TEXT, @Lc_FidmCur_PayeeCode_TEXT, @Lc_FidmCur_PrimarySsnNumb_TEXT, @Lc_FidmCur_SecondPayeeSsnNumb_TEXT, @Lc_FidmCur_MatchedAddrNormalizationCode_TEXT, @Ls_FidmCur_MatchedLine1Addr_TEXT, @Ls_FidmCur_MatchedLine2Addr_TEXT, @Lc_FidmCur_MatchedCityAddr_TEXT, @Lc_FidmCur_MatchedStateAddr_TEXT, @Lc_FidmCur_MatchedZipAddr_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH Fidm_CUR';
     SET @Ls_SqlData_TEXT = '';

     --Process records in LFIIR_Y1 and LACHL_Y1 and update the database tables with address and account information
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       BEGIN TRY
        SAVE TRANSACTION SAVE_PROCESS_FIDM;

        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
        SET @Ls_ErrorMessage_TEXT = '';
        SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
        SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
        SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
        SET @Ls_CursorLocation_TEXT = 'Fidm - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
        SET @Ls_BateRecord_TEXT = 'SeqA_IDNO = ' + CAST(@Ln_FidmCur_SeqA_IDNO AS VARCHAR) + ', RecA_ID = ' + @Lc_FidmCur_RecAId_TEXT + ', TapeReel_NUMB = ' + LTRIM(RTRIM(@Lc_FidmCur_TapeReelNumb_TEXT)) + ', FinancialInstitutionEINIdno_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_FinancialInstitutionEINIdno_TEXT)) + ', InstitutionControl_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionControlName_TEXT)) + ', FileGeneratedDateA_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_FileGeneratedDateA_TEXT)) + ', ReceivedFileType_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_ReceivedFileTypeCode_TEXT)) + ', ServiceBureau_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_ServiceBureauCode_TEXT)) + ', MagneticTape_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_MagneticTapeCode_TEXT)) + ', ForeignCorrespondence_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_ForeignCorrespondenceCode_TEXT)) + ', Institution_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionName_TEXT)) + ', InstitutionSecond_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionSecondName_TEXT)) + ', TransferAgent_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_TransferAgentCode_TEXT)) + ', ReportingAgentEINIdno_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_ReportingAgentEINIdno_TEXT)) + ', ReportingAgent_NAME = ' + LTRIM(RTRIM(@Ls_FidmCur_ReportingAgentName_TEXT)) + ', ReportingAgentStreet_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_ReportingAgentStreetAddr_TEXT)) + ', ReportingAgentCity_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_ReportingAgentCityAddr_TEXT)) + ', ReportingAgentState_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_ReportingAgentStateAddr_TEXT)) + ', ReportingAgentZip_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_ReportingAgentZipAddr_TEXT)) + ', DataMatch_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_DataMatchCode_TEXT)) + ', InstitutionAddrNormalization_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionAddrNormalizationCode_TEXT)) + ', InstitutionLine1_ADDR = ' + LTRIM(RTRIM(@Ls_FidmCur_InstitutionLine1Addr_TEXT)) + ', InstitutionLine2_ADDR = ' + LTRIM(RTRIM(@Ls_FidmCur_InstitutionLine2Addr_TEXT)) + ', InstitutionCity_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionCityAddr_TEXT)) + ', InstitutionState_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionStateAddr_TEXT)) + ', InstitutionZip_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionZipAddr_TEXT)) + ', FidmFiirSeq_IDNO = ' + CAST(@Ln_FidmCur_FidmFiirSeq_IDNO AS VARCHAR) + ', SeqB_IDNO = ' + CAST(@Ln_FidmCur_SeqB_IDNO AS VARCHAR) + ', RecB_ID = ' + @Lc_FidmCur_RecBId_TEXT + ', FileGeneratedDateB_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_FileGeneratedDateB_TEXT)) + ', PayeeLast_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_PayeeLastName_TEXT)) + ', MatchedSsnNumb_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedSsnNumb_TEXT)) + ', PayeeAccountNumb_TEXT = ' + LTRIM (RTRIM(@Lc_FidmCur_PayeeAccountNumb_TEXT)) + ', FullAccountTitle_TEXT = ' + LTRIM(RTRIM(@Ls_FidmCur_FullAccountTitle_TEXT)) + ', ForeignCountry_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_ForeignCountryCode_TEXT)) + ', Matched_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedName_TEXT)) + ', SecondPayee_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_SecondPayeeName_TEXT)) + ', FipsPassBack_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_FipsPassBackCode_TEXT)) + ', AdditionalStatePassBack_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_AdditionalStatePassBack_TEXT)) + ', AccountBalanceAmnt_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountBalanceAmnt_TEXT)) + ', AccountMatch_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountMatchCode_TEXT)) + ', TrustFund_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_TrustFundCode_TEXT)) + ', AccountBalance_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountBalanceCode_TEXT)) + ', AccountUpdate_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountUpdateCode_TEXT)) + ', AccountHolderBirthDate_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountHolderBirthDate_TEXT)) + ', StatePassBack_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_StatePassBack_TEXT)) + ', AccountType_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT)) + ', CasePassBack_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_CasePassBack_TEXT)) + ', Payee_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_PayeeCode_TEXT)) + ', PrimarySsnNumb_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_PrimarySsnNumb_TEXT)) + ', SecondPayeeSsnNumb_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_SecondPayeeSsnNumb_TEXT)) + ', MatchedAddrNormalization_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedAddrNormalizationCode_TEXT)) + ', MatchedLine1_ADDR = ' + LTRIM(RTRIM(@Ls_FidmCur_MatchedLine1Addr_TEXT)) + ', MatchedLine2_ADDR = ' + LTRIM(RTRIM(@Ls_FidmCur_MatchedLine2Addr_TEXT)) + ', MatchedCity_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedCityAddr_TEXT)) + ', MatchedState_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedStateAddr_TEXT)) + ', MatchedZip_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedZipAddr_TEXT));
        SET @Ls_Sql_TEXT = 'CHECK ACCOUNT MATCH FLAG';
        SET @Ls_SqlData_TEXT = 'AccountMatch_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountMatchCode_TEXT));

        IF LTRIM(RTRIM(@Lc_FidmCur_AccountMatchCode_TEXT)) <> '1'
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE1373_CODE;
          SET @Ls_ErrorMessage_TEXT = 'MEMBER NAME DOES NOT MATCH';

          RAISERROR(50001,16,1);
         END;

        IF ISNUMERIC(LTRIM(RTRIM(@Lc_FidmCur_StatePassBack_TEXT))) = 1
           AND CAST(LTRIM(RTRIM(@Lc_FidmCur_StatePassBack_TEXT)) AS NUMERIC) > 0
         BEGIN
          SET @Ln_FidmCur_StatePassBack_IDNO = LTRIM(RTRIM(@Lc_FidmCur_StatePassBack_TEXT));
          SET @Ls_Sql_TEXT = 'LOOK FOR NCP IN DEMO USING MCI #';
          SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR);

          IF NOT EXISTS (SELECT 1
                           FROM DEMO_Y1 X
                          WHERE X.MemberMci_IDNO = @Ln_FidmCur_StatePassBack_IDNO)
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE0012_CODE;
            SET @Ls_ErrorMessage_TEXT = 'NO MATCHING RECORDS FOUND';

            RAISERROR(50001,16,1);
           END;
         END;
        ELSE
         BEGIN
          SET @Ln_LastNameFoundPosition_NUMB = 0;
          SET @Ln_LastNameLength_NUMB = 0;
          SET @Ln_CommaFoundPosition_NUMB = 0;
          SET @Ln_SpaceFoundPosition_NUMB = 0;
          SET @Ls_Sql_TEXT = 'DERIVING LAST NAME FROM CONTROL LAST NAME, MATCHED NAME & SECOND PAYEE NAME';
          SET @Ls_SqlData_TEXT = 'PayeeLast_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_PayeeLastName_TEXT)) + ', Matched_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedName_TEXT)) + ', SecondPayee_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_SecondPayeeName_TEXT));

          IF LEN(LTRIM(RTRIM(@Lc_FidmCur_PayeeLastName_TEXT))) > 0
             AND (LEN(LTRIM(RTRIM(@Lc_FidmCur_MatchedName_TEXT))) > 0
                   OR LEN(LTRIM(RTRIM(@Lc_FidmCur_SecondPayeeName_TEXT))) > 0)
           BEGIN
            SET @Ln_LastNameFoundPosition_NUMB = CHARINDEX(LTRIM(RTRIM(@Lc_FidmCur_PayeeLastName_TEXT)), LTRIM(RTRIM(@Lc_FidmCur_MatchedName_TEXT)));

            IF @Ln_LastNameFoundPosition_NUMB = 0
             BEGIN
              SET @Ln_LastNameFoundPosition_NUMB = CHARINDEX(LTRIM(RTRIM(@Lc_FidmCur_PayeeLastName_TEXT)), LTRIM(RTRIM(@Lc_FidmCur_SecondPayeeName_TEXT)));
              SET @Lc_Last_NAME = LTRIM(RTRIM(@Lc_FidmCur_SecondPayeeName_TEXT));
             END;
            ELSE
             BEGIN
              SET @Lc_Last_NAME = LTRIM(RTRIM(@Lc_FidmCur_MatchedName_TEXT));
             END;

            SET @Ln_LastNameLength_NUMB = LEN(@Lc_Last_NAME) - (@Ln_LastNameFoundPosition_NUMB - 1);
            SET @Lc_Last_NAME = SUBSTRING(@Lc_Last_NAME, @Ln_LastNameFoundPosition_NUMB, @Ln_LastNameLength_NUMB);
            SET @Ln_CommaFoundPosition_NUMB = CHARINDEX(@Lc_Comma_TEXT, @Lc_Last_NAME);

            IF @Ln_CommaFoundPosition_NUMB = 0
             BEGIN
              SET @Ln_SpaceFoundPosition_NUMB = CHARINDEX(@Lc_Space_TEXT, @Lc_Last_NAME);

              IF @Ln_SpaceFoundPosition_NUMB > 0
               BEGIN
                SET @Lc_Last_NAME = LEFT(@Lc_Last_NAME, (@Ln_SpaceFoundPosition_NUMB - 1));
               END;
             END;
            ELSE IF @Ln_CommaFoundPosition_NUMB > 0
             BEGIN
              SET @Lc_Last_NAME = LEFT(@Lc_Last_NAME, (@Ln_CommaFoundPosition_NUMB - 1));
             END;
           END;
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE1564_CODE;
            SET @Ls_ErrorMessage_TEXT = 'INPUT LAST NAME IS EMPTY';

            RAISERROR(50001,16,1);
           END;

          IF ISNUMERIC(LTRIM(RTRIM(@Lc_FidmCur_MatchedSsnNumb_TEXT))) = 0
              OR CAST(LTRIM(RTRIM(@Lc_FidmCur_MatchedSsnNumb_TEXT)) AS NUMERIC) = 0
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE1565_CODE;
            SET @Ls_ErrorMessage_TEXT = 'INPUT SSN IS EMPTY';

            RAISERROR(50001,16,1);
           END;
          ELSE
           BEGIN
            SET @Ln_FidmCur_MatchedSsn_NUMB = LTRIM(RTRIM(@Lc_FidmCur_MatchedSsnNumb_TEXT));
           END;

          SET @Ls_Sql_TEXT = 'LOOK FOR NCP IN DEMO USING LAST NAME AND SSN';
          SET @Ls_SqlData_TEXT = 'Last_NAME = ' + @Lc_Last_NAME + ', MatchedSsn_NUMB = ' + CAST(@Ln_FidmCur_MatchedSsn_NUMB AS VARCHAR);

          IF LEN(LTRIM(RTRIM(@Lc_Last_NAME))) > 0
             AND @Ln_FidmCur_MatchedSsn_NUMB > 0
           BEGIN
            IF NOT EXISTS (SELECT 1
                             FROM DEMO_Y1 X
                            WHERE UPPER(LTRIM(RTRIM(ISNULL(X.Last_NAME, '')))) = UPPER(LTRIM(RTRIM(@Lc_Last_NAME)))
                              AND X.MemberSsn_NUMB = @Ln_FidmCur_MatchedSsn_NUMB)
             BEGIN
              SET @Lc_BateError_CODE = @Lc_BateErrorE0012_CODE;
              SET @Ls_ErrorMessage_TEXT = 'NO MATCHING RECORDS FOUND';

              RAISERROR(50001,16,1);
             END;
            ELSE
             BEGIN
              SET @Ls_Sql_TEXT = 'GET MCI # FROM DEMO USING LAST NAME AND SSN';
              SET @Ls_SqlData_TEXT = 'Last_NAME = ' + LTRIM(RTRIM(@Lc_Last_NAME)) + ', MatchedSsn_NUMB = ' + CAST(@Ln_FidmCur_MatchedSsn_NUMB AS VARCHAR);

              SELECT @Ln_FidmCur_StatePassBack_IDNO = CASE
                                                       WHEN LEN(LTRIM(RTRIM(ISNULL(X.MemberMci_IDNO, '')))) = 0
                                                        THEN 0
                                                       ELSE X.MemberMci_IDNO
                                                      END
                FROM DEMO_Y1 X
               WHERE UPPER(LTRIM(RTRIM(ISNULL(X.Last_NAME, '')))) = UPPER(LTRIM(RTRIM(@Lc_Last_NAME)))
                 AND X.MemberSsn_NUMB = @Ln_FidmCur_MatchedSsn_NUMB;

              IF @Ln_FidmCur_StatePassBack_IDNO = 0
               BEGIN
                SET @Lc_BateError_CODE = @Lc_BateErrorE0102_CODE;
                SET @Ls_ErrorMessage_TEXT = 'MCI # IN DEMO IS EMPTY';

                RAISERROR(50001,16,1);
               END;
             END;
           END;
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE;
            SET @Ls_ErrorMessage_TEXT = 'INPUT LAST NAME AND SSN ARE EMPTY';

            RAISERROR(50001,16,1);
           END;
         END;

        IF @Ln_FidmCur_StatePassBack_IDNO > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'CHECK WHETHER MEMBER IS AN ACTIVE NCP IN CMEM';
          SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR);

          IF NOT EXISTS (SELECT 1
                           FROM CMEM_Y1 X
                          WHERE X.MemberMci_IDNO = @Ln_FidmCur_StatePassBack_IDNO
                            AND X.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                            AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE0759_CODE;
            SET @Ls_ErrorMessage_TEXT = 'NO CASE MEMBER RECORD FOR NCP';

            RAISERROR(50001,16,1);
           END;
         END;

        IF LEN(LTRIM(RTRIM(ISNULL(@Ls_FidmCur_MatchedLine1Addr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_FidmCur_MatchedCityAddr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_FidmCur_MatchedStateAddr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_FidmCur_MatchedZipAddr_TEXT, '')))) > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE ';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR) + ', Normalization_CODE = ' + @Lc_FidmCur_MatchedAddrNormalizationCode_TEXT + ', Line1_ADDR = ' + @Ls_FidmCur_MatchedLine1Addr_TEXT + ', Line2_ADDR = ' + @Ls_FidmCur_MatchedLine2Addr_TEXT + ', City_ADDR = ' + @Lc_FidmCur_MatchedCityAddr_TEXT + ', State_ADDR = ' + @Lc_FidmCur_MatchedStateAddr_TEXT + ', Zip_ADDR = ' + @Lc_FidmCur_MatchedZipAddr_TEXT;

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_FidmCur_StatePassBack_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
           @As_Line1_ADDR                       = @Ls_FidmCur_MatchedLine1Addr_TEXT,
           @As_Line2_ADDR                       = @Ls_FidmCur_MatchedLine2Addr_TEXT,
           @Ac_City_ADDR                        = @Lc_FidmCur_MatchedCityAddr_TEXT,
           @Ac_State_ADDR                       = @Lc_FidmCur_MatchedStateAddr_TEXT,
           @Ac_Zip_ADDR                         = @Lc_FidmCur_MatchedZipAddr_TEXT,
           @Ac_Country_ADDR                     = @Lc_Country_ADDR,
           @An_Phone_NUMB                       = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_SourceLoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_StatusP_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
           @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
           @Ac_Process_ID                       = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
           @Ac_Normalization_CODE               = @Lc_FidmCur_MatchedAddrNormalizationCode_TEXT,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_BateErrorE1089_CODE)
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END

          IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
            SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

            EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
             @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
             @Ac_Process_ID               = @Lc_Job_ID,
             @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
             @Ac_Note_INDC                = @Lc_Note_INDC,
             @An_EventFunctionalSeq_NUMB  = 0,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

              RAISERROR(50001,16,1);
             END;

            IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
             BEGIN
              DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
               SELECT A.Case_IDNO,
                      A.MemberMci_IDNO
                 FROM CMEM_Y1 A,
                      CASE_Y1 B
                WHERE MemberMci_IDNO = @Ln_FidmCur_StatePassBack_IDNO
                  AND A.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                  AND A.Case_IDNO = B.Case_IDNO
                  AND B.StatusCase_CODE = @Lc_StatusCaseO_CODE;

              SET @Ls_Sql_TEXT = 'OPEN CaseMember_CUR';
              SET @Ls_SqlData_TEXT = '';

              OPEN CaseMember_CUR;

              SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 1';
              SET @Ls_SqlData_TEXT = '';

              FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

              SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
              SET @Ls_Sql_TEXT = 'LOOP THROUGH CaseMember_CUR';
              SET @Ls_SqlData_TEXT = '';

              --Insert activity for each open active member
              WHILE @Li_FetchStatus_QNTY = 0
               BEGIN
                SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
                SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR) + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorRadfd_CODE;

                EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
                 @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
                 @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
                 @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
                 @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRadfd_CODE,
                 @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
                 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                 @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
                 @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
                 @Ad_Run_DATE                 = @Ld_Run_DATE,
                 @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
                 @Ac_Reference_ID             = @Lc_Reference_ID,
                 @Ac_Notice_ID                = @Lc_Notice_ID,
                 @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
                 @Ac_Job_ID                   = @Lc_Job_ID,
                 @As_Xml_TEXT                 = @Ls_XmlIn_TEXT,
                 @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
                 @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
                 @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
                 @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
                 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
                 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

                IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                 BEGIN
                  SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

                  RAISERROR(50001,16,1);
                 END;

                SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 2';
                SET @Ls_SqlData_TEXT = '';

                FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

                SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
               END;

              SET @Ls_Sql_TEXT = 'CLOSE CaseMember_CUR';
              SET @Ls_SqlData_TEXT = '';

              CLOSE CaseMember_CUR;

              SET @Ls_Sql_TEXT = 'DEALLOCATE CaseMember_CUR';
              SET @Ls_SqlData_TEXT = '';

              DEALLOCATE CaseMember_CUR;
             END;
           END;
         END;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
        SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR) + ', Fein_IDNO = ' + LTRIM(RTRIM(@Lc_FidmCur_FinancialInstitutionEINIdno_TEXT)) + ', OtherParty_NAME = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionName_TEXT)) + ', Normalization_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionAddrNormalizationCode_TEXT)) + ', Line1_ADDR = ' + LTRIM(RTRIM(@Ls_FidmCur_InstitutionLine1Addr_TEXT)) + ', Line2_ADDR = ' + LTRIM(RTRIM(@Ls_FidmCur_InstitutionLine2Addr_TEXT)) + ', City_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionCityAddr_TEXT)) + ', State_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionStateAddr_TEXT)) + ', Zip_ADDR = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionZipAddr_TEXT));

        IF LEN(LTRIM(RTRIM(@Lc_FidmCur_FinancialInstitutionEINIdno_TEXT))) = 0
            OR ISNUMERIC(LTRIM(RTRIM(@Lc_FidmCur_FinancialInstitutionEINIdno_TEXT))) = 0
            OR CAST(LTRIM(RTRIM(@Lc_FidmCur_FinancialInstitutionEINIdno_TEXT)) AS NUMERIC) <= 0
         BEGIN
          SET @Ln_FidmCur_FinancialInstitutionEIN_IDNO = @Ln_Zero_NUMB;
         END;
        ELSE
         BEGIN
          SET @Ln_FidmCur_FinancialInstitutionEIN_IDNO = LTRIM(RTRIM(@Lc_FidmCur_FinancialInstitutionEINIdno_TEXT));
         END;

        EXECUTE BATCH_COMMON$SP_GET_OTHP
         @Ad_Run_DATE                     = @Ld_Run_DATE,
         @An_Fein_IDNO                    = @Ln_FidmCur_FinancialInstitutionEIN_IDNO,
         @Ac_TypeOthp_CODE                = @Lc_TypeOthp_CODE,
         @As_OtherParty_NAME              = @Lc_FidmCur_InstitutionName_TEXT,
         @Ac_Aka_NAME                     = @Lc_FidmCur_InstitutionSecondName_TEXT,
         @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
         @As_Line1_ADDR                   = @Ls_FidmCur_InstitutionLine1Addr_TEXT,
         @As_Line2_ADDR                   = @Ls_FidmCur_InstitutionLine2Addr_TEXT,
         @Ac_City_ADDR                    = @Lc_FidmCur_InstitutionCityAddr_TEXT,
         @Ac_Zip_ADDR                     = @Lc_FidmCur_InstitutionZipAddr_TEXT,
         @Ac_State_ADDR                   = @Lc_FidmCur_InstitutionStateAddr_TEXT,
         @Ac_Fips_CODE                    = @Lc_Space_TEXT,
         @Ac_Country_ADDR                 = @Lc_Country_ADDR,
         @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
         @An_Phone_NUMB                   = @Ln_Zero_NUMB,
         @An_Fax_NUMB                     = @Ln_Zero_NUMB,
         @As_Contact_EML                  = @Lc_Space_TEXT,
         @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
         @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
         @An_Sein_IDNO                    = @Ln_Zero_NUMB,
         @Ac_SourceLoc_CODE               = @Lc_SourceLoc_CODE,
         @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
         @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
         @Ac_Normalization_CODE           = @Lc_FidmCur_InstitutionAddrNormalizationCode_TEXT,
         @Ac_Process_ID                   = @Lc_Job_ID,
         @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
         @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR (50001,16,1);
         END
        ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
          SET @Lc_BateError_CODE = @Lc_Msg_CODE;

          RAISERROR (50001,16,1);
         END

        IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
           AND @Ln_OtherParty_IDNO > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'CHECK INPUT ACCOUNT BALANCE';
          SET @Ls_SqlData_TEXT = 'AccountBalanceAmnt_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountBalanceAmnt_TEXT));

          IF LEN(LTRIM(RTRIM(@Lc_FidmCur_AccountBalanceAmnt_TEXT))) = 0
           BEGIN
            SET @Ln_FidmCur_AccountBalance_AMNT = @Ln_Zero_NUMB;
           END;
          ELSE
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_CONVERT_AMT_SIGN';
            SET @Ls_SqlData_TEXT = 'AmountSigned_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountBalanceAmnt_TEXT));
            SET @Ln_FidmCur_AccountBalance_AMNT = dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN(LTRIM(RTRIM(@Lc_FidmCur_AccountBalanceAmnt_TEXT)));
           END;

          SET @Ls_Sql_TEXT = 'DERIVE JOINT ACCOUNT INDICATOR';
          SET @Ls_SqlData_TEXT = 'Payee_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_PayeeCode_TEXT));
          SET @Lc_JointAcct_INDC = CASE LTRIM(RTRIM(@Lc_FidmCur_PayeeCode_TEXT))
                                    WHEN '0'
                                     THEN @Lc_No_INDC
                                    WHEN '1'
                                     THEN @Lc_Yes_INDC
                                    WHEN '2'
                                     THEN @Lc_Yes_INDC
                                    ELSE @Lc_Space_TEXT
                                   END;
          SET @Ls_Sql_TEXT = 'ASSET CODE VALIDATION IN REFM';
          SET @Ls_SqlData_TEXT = 'Value_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT));

          IF NOT EXISTS (SELECT 1
                           FROM REFM_Y1
                          WHERE Table_ID = @Lc_TableMast_ID
                            AND TableSub_ID = @Lc_TableSubFina_ID
                            AND Value_CODE = LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT)))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE1095_CODE;
            SET @Ls_ErrorMessage_TEXT = 'INVALID ASSET CODE';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'ACCOUNT NUMBER VALIDATION';
          SET @Ls_SqlData_TEXT = 'PayeeAccountNumb_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_PayeeAccountNumb_TEXT));

          IF LEN(LTRIM(RTRIM(ISNULL(@Lc_FidmCur_PayeeAccountNumb_TEXT, '')))) = 0
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE1138_CODE;
            SET @Ls_ErrorMessage_TEXT = 'INVALID ACCOUNT NUMBER';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'ACCOUNT VALIDATION';
          SET @Ls_SqlData_TEXT = 'TrustFund_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_TrustFundCode_TEXT)) + ', AccountType_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT));

          IF (LTRIM(RTRIM(@Lc_FidmCur_TrustFundCode_TEXT)) IN ('1', '2', '3', '4', '5')
               OR LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT)) IN ('12', '14'))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE1566_CODE;
            SET @Ls_ErrorMessage_TEXT = 'INVALID ACCOUNT';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'CHECK IF LIEN WAS PLACED AGAINST SAME BANK ACCOUNT WITHIN THE LAST 3 MONTHS';
          SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR) + ', ActivityMajorFidm_CODE = ' + @Lc_ActivityMajorFidm_CODE + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', AccountType_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT)) + ', PayeeAccountNumb_TEXT = ' + LTRIM (RTRIM(@Lc_FidmCur_PayeeAccountNumb_TEXT)) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR);

          IF EXISTS (SELECT 1
                       FROM DMJR_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_FidmCur_StatePassBack_IDNO
                        AND X.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
                        AND X.OthpSource_IDNO = @Ln_OtherParty_IDNO
                        AND X.TypeReference_CODE = LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT))
                        AND X.Reference_ID = LTRIM(RTRIM(@Lc_FidmCur_PayeeAccountNumb_TEXT))
                        AND X.Entered_DATE >= DATEADD(M, -3, @Ld_Start_DATE))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE1567_CODE;
            SET @Ls_ErrorMessage_TEXT = 'LIEN WAS PLACED AGAINST SAME BANK ACCOUNT WITHIN THE LAST 3 MONTHS';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'CHECK IF NCP HAS MADE A VOLUNTARY PAYMENT SINCE FILE WAS CREATED';
          SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR);

          IF EXISTS (SELECT 1
                       FROM ENSD_Y1 X
                      WHERE X.NcpPf_IDNO = @Ln_FidmCur_StatePassBack_IDNO
                        AND EXISTS (SELECT 1
                                      FROM CASE_Y1 Z
                                     WHERE Z.Case_IDNO = X.Case_IDNO
                                       AND Z.StatusCase_CODE = @Lc_StatusCaseO_CODE)
                        AND EXISTS (SELECT 1
                                      FROM RCTH_Y1 Y
                                     WHERE Y.Case_IDNO = X.Case_IDNO
                                       AND Y.PayorMCI_IDNO = X.NcpPf_IDNO
                                       AND Y.EndValidity_DATE = @Ld_High_DATE
                                       AND Y.SourceReceipt_CODE IN (@Lc_DirectPaymentCredit_CODE, @Lc_DisabilityInsurance_CODE, @Lc_EmployerWage_CODE, @Lc_RegularPaymentFromNcp_CODE,
                                                                    @Lc_UnemploymentCompensation_CODE, @Lc_WorkersCompensation_CODE, @Lc_Voluntary_CODE)
                                       AND Y.Batch_DATE >= DATEADD(D, -30, @Ld_Run_DATE)))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE1568_CODE;
            SET @Ls_ErrorMessage_TEXT = 'NCP HAS MADE A VOLUNTARY PAYMENT SINCE FILE WAS CREATED';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'GETTING THE COUNT OF ALL OPEN CASES FOR THE MEMBER (IN ENSD_Y1) WHO IS AN ACTIVE NCP/PF IN CMEM';
          SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR);

          SELECT @Ln_ActiveMemberOpenCaseCount_QNTY = COUNT(DISTINCT(X.Case_IDNO))
            FROM ENSD_Y1 X
           WHERE X.NcpPf_IDNO = @Ln_FidmCur_StatePassBack_IDNO
             AND X.Case_IDNO IN (SELECT DISTINCT
                                        Y.Case_IDNO
                                   FROM CMEM_Y1 Y
                                  WHERE Y.MemberMci_IDNO = X.NcpPf_IDNO
                                    AND Y.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                                    AND Y.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                                    AND (EXISTS (SELECT 1
                                                   FROM CASE_Y1 Z
                                                  WHERE Z.Case_IDNO = Y.Case_IDNO
                                                    AND Z.StatusCase_CODE = @Lc_StatusCaseO_CODE)
                                          OR EXISTS (SELECT 1
                                                       FROM CASE_Y1 Z
                                                      WHERE Z.Case_IDNO = Y.Case_IDNO
                                                        AND Z.StatusCase_CODE = @Lc_StatusCaseC_CODE
                                                        AND Z.RsnStatusCase_CODE IN (@Lc_RsnStatusCaseUb_CODE, @Lc_RsnStatusCaseUc_CODE))));

          SET @Ls_Sql_TEXT = 'CHECK THE COUNT OF ALL OPEN CASES FOR THE MEMBER (IN ENSD_Y1) WHO IS AN ACTIVE NCP/PF IN CMEM';
          SET @Ls_SqlData_TEXT = 'ActiveMemberOpenCaseCount_QNTY = ' + CAST(@Ln_ActiveMemberOpenCaseCount_QNTY AS VARCHAR);

          IF @Ln_ActiveMemberOpenCaseCount_QNTY > 0
           BEGIN
            SET @Ls_Sql_TEXT = 'GETTING THE COUNT OF ALL OPEN CASES FOR THE MEMBER THAT ARE IN CASE CLOSURE PROCESS';
            SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR);

            SELECT @Ln_ActiveMemberOpenCaseClosingCount_QNTY = COUNT(DISTINCT(X.Case_IDNO))
              FROM ENSD_Y1 X
             WHERE X.CcloStrt_INDC = @Lc_Yes_INDC
               AND X.NcpPf_IDNO = @Ln_FidmCur_StatePassBack_IDNO
               AND X.Case_IDNO IN (SELECT DISTINCT
                                          Y.Case_IDNO
                                     FROM CMEM_Y1 Y
                                    WHERE Y.MemberMci_IDNO = X.NcpPf_IDNO
                                      AND Y.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                                      AND Y.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                                      AND EXISTS (SELECT 1
                                                    FROM CASE_Y1 Z
                                                   WHERE Z.Case_IDNO = Y.Case_IDNO
                                                     AND Z.StatusCase_CODE = @Lc_StatusCaseO_CODE));

            SET @Ls_Sql_TEXT = 'CHECK THE COUNT OF ALL OPEN CASES FOR THE MEMBER THAT ARE IN CASE CLOSURE PROCESS';
            SET @Ls_SqlData_TEXT = 'ActiveMemberOpenCaseClosingCount_QTY = ' + CAST(@Ln_ActiveMemberOpenCaseClosingCount_QNTY AS VARCHAR);

            IF @Ln_ActiveMemberOpenCaseClosingCount_QNTY > 0
             BEGIN
              IF @Ln_ActiveMemberOpenCaseCount_QNTY = @Ln_ActiveMemberOpenCaseClosingCount_QNTY
               BEGIN
                SET @Lc_BateError_CODE = @Lc_BateErrorE1569_CODE;
                SET @Ls_ErrorMessage_TEXT = 'CASE IS IN PROCESS OF CLOSING';

                RAISERROR(50001,16,1);
               END;
             END;
           END;
          ELSE IF @Ln_ActiveMemberOpenCaseCount_QNTY = 0
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE0073_CODE;
            SET @Ls_ErrorMessage_TEXT = 'NO OPEN CASE FOR THE MEMBER IN ENSD_Y1';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'CHECK IF THE BANK ACCOUNT IS A JOINT ACCOUNT';
          SET @Ls_SqlData_TEXT = 'JointAcct_INDC = ' + @Lc_JointAcct_INDC;

          IF @Lc_JointAcct_INDC = @Lc_Yes_INDC
           BEGIN
            SET @Ls_Sql_TEXT = 'CHECK IF THE MEMBER IS INCARCERATED IN ANY OPEN CASE';
            SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR);

            IF EXISTS (SELECT 1
                         FROM ENSD_Y1 X
                        WHERE X.NcpPf_IDNO = @Ln_FidmCur_StatePassBack_IDNO
                          AND X.Incarceration_DATE NOT IN (@Ld_Low_DATE, '01/01/1900')
                          AND @Ld_Run_DATE >= X.Incarceration_DATE
                          AND @Ld_Run_DATE < X.Released_DATE
                          AND EXISTS (SELECT 1
                                        FROM CASE_Y1 Z
                                       WHERE Z.Case_IDNO = X.Case_IDNO
                                         AND Z.StatusCase_CODE = @Lc_StatusCaseO_CODE))
             BEGIN
              SET @Lc_BateError_CODE = @Lc_BateErrorE1570_CODE;
              SET @Ls_ErrorMessage_TEXT = 'THE BANK ACCOUNT IS A JOINT ACCOUNT AND NCP IS INCARCERATED';

              RAISERROR(50001,16,1);
             END;
           END;

          SET @Ls_Sql_TEXT = 'CHECK IF BANK ACCOUNT BALANCE IS LESS THAN $350.00';
          SET @Ls_SqlData_TEXT = 'AccountBalance_AMNT = ' + CAST(@Ln_FidmCur_AccountBalance_AMNT AS VARCHAR);

          IF @Ln_FidmCur_AccountBalance_AMNT < 350
           BEGIN
            SET @Ls_Sql_TEXT = 'CHECK IN MAST, IF ANY OF THE BANK ACCOUNTS OWNED BY THE NCP HAS A BALANCE OF $350 OR MORE';
            SET @Ls_SqlData_TEXT = 'StatePassBack_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR);

            IF NOT EXISTS(SELECT 1
                            FROM ASFN_Y1 X
                           WHERE X.MemberMci_IDNO = @Ln_FidmCur_StatePassBack_IDNO
                             AND X.OthpInsFin_IDNO = @Ln_OtherParty_IDNO
                             AND X.EndValidity_DATE = @Ld_High_DATE
                             AND ISNULL(X.ValueAsset_AMNT, 0) >= 350)
             BEGIN
              SET @Lc_BateError_CODE = @Lc_BateErrorE1571_CODE;
              SET @Ls_ErrorMessage_TEXT = 'BANK ACCOUNT BALANCE IS LESS THAN $350.00';

              RAISERROR(50001,16,1);
             END;
           END;

          SET @Ls_Sql_TEXT = 'BATCH_ENF_INCOMING_FIDM$SP_UPDATE_ASFN';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FidmCur_StatePassBack_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', Response_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', AcctAssetNo_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_PayeeAccountNumb_TEXT)) + ', ValueAsset_AMNT = ' + CAST(@Ln_FidmCur_AccountBalance_AMNT AS VARCHAR) + ', AcctType_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_AccountTypeCode_TEXT)) + ', AcctLegalTitle_TEXT = ' + LTRIM(RTRIM(@Ls_FidmCur_FullAccountTitle_TEXT)) + ', JointAcct_INDC = ' + @Lc_JointAcct_INDC + ', LocateState_CODE = ' + LTRIM(RTRIM(@Lc_FidmCur_InstitutionStateAddr_TEXT)) + ', SourceLoc_CODE = ' + @Lc_SourceLoc_CODE + ', NameAcctPrimaryNo_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_MatchedName_TEXT)) + ', NameAcctSecondaryNo_TEXT = ' + LTRIM(RTRIM(@Lc_FidmCur_SecondPayeeName_TEXT));

          EXECUTE BATCH_ENF_INCOMING_FIDM$SP_UPDATE_ASFN
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @An_MemberMci_IDNO           = @Ln_FidmCur_StatePassBack_IDNO,
           @An_OtherParty_IDNO          = @Ln_OtherParty_IDNO,
           @Ad_Response_DATE            = @Ld_Run_DATE,
           @Ac_AccountAssetNo_TEXT      = @Lc_FidmCur_PayeeAccountNumb_TEXT,
           @An_ValueAsset_AMNT          = @Ln_FidmCur_AccountBalance_AMNT,
           @Ac_AcctType_CODE            = @Lc_FidmCur_AccountTypeCode_TEXT,
           @As_FullAccountTitle_TEXT    = @Ls_FidmCur_FullAccountTitle_TEXT,
           @Ac_JointAcct_INDC           = @Lc_JointAcct_INDC,
           @Ac_LocateState_CODE         = @Lc_FidmCur_InstitutionStateAddr_TEXT,
           @Ac_SourceLoc_CODE           = @Lc_SourceLoc_CODE,
           @Ac_NameAcctPrimaryNo_TEXT   = @Lc_FidmCur_MatchedName_TEXT,
           @Ac_NameAcctSecondaryNo_TEXT = @Lc_FidmCur_SecondPayeeName_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;
         END;
       END TRY

       BEGIN CATCH
        IF XACT_STATE() = 1
         BEGIN
          ROLLBACK TRANSACTION SAVE_PROCESS_FIDM;
         END
        ELSE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

          RAISERROR(50001,16,1);
         END

        IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0, 1)
         BEGIN
          CLOSE CaseMember_CUR;

          DEALLOCATE CaseMember_CUR;
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

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
        SET @Ls_SqlData_TEXT = '';

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
         @An_Line_NUMB                = @Ln_RecordCount_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
         @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;

        IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
         BEGIN
          SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
         END
       END CATCH;

       SET @Ls_Sql_TEXT = 'UPDATE LACHL_Y1';
       SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + CAST(@Ln_FidmCur_SeqB_IDNO AS VARCHAR);

       UPDATE LACHL_Y1
          SET Process_INDC = @Lc_ProcessY_INDC
        WHERE Seq_IDNO = @Ln_FidmCur_SeqB_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE LACHL_Y1 FAILED';

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'SELECT LFIIR_Y1';
       SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + CAST(@Ln_FidmCur_SeqA_IDNO AS VARCHAR);

       IF EXISTS (SELECT 1
                    FROM LFIIR_Y1 A
                   WHERE A.Seq_IDNO = @Ln_FidmCur_SeqA_IDNO
                     AND NOT EXISTS (SELECT 1
                                       FROM LACHL_Y1 X
                                      WHERE X.FidmFiirSeq_IDNO = A.Seq_IDNO
                                        AND X.Process_INDC = @Lc_ProcessN_INDC))
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE LFIIR_Y1';
         SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + CAST(@Ln_FidmCur_SeqA_IDNO AS VARCHAR);

         UPDATE LFIIR_Y1
            SET Process_INDC = @Lc_ProcessY_INDC
          WHERE Seq_IDNO = @Ln_FidmCur_SeqA_IDNO;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'UPDATE LFIIR_Y1 FAILED';

           RAISERROR (50001,16,1);
          END;
        END;

       SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';
       SET @Ls_SqlData_TEXT = 'CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR) + ', CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR);

       IF @Ln_CommitFreq_QNTY <> 0
          AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_FIDM';
         SET @Ls_SqlData_TEXT = '';

         COMMIT TRANSACTION TXN_PROCESS_FIDM;

         SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
         SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_FIDM';
         SET @Ls_SqlData_TEXT = '';

         BEGIN TRANSACTION TXN_PROCESS_FIDM;

         SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_CommitFreq_QNTY = 0;
        END;

       SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';
       SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);

       IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        BEGIN
         COMMIT TRANSACTION TXN_PROCESS_FIDM;

         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
         SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Fidm_CUR - 2';
       SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

       FETCH NEXT FROM Fidm_CUR INTO @Ln_FidmCur_SeqA_IDNO, @Lc_FidmCur_RecAId_TEXT, @Lc_FidmCur_TapeReelNumb_TEXT, @Lc_FidmCur_FinancialInstitutionEINIdno_TEXT, @Lc_FidmCur_InstitutionControlName_TEXT, @Lc_FidmCur_FileGeneratedDateA_TEXT, @Lc_FidmCur_ReceivedFileTypeCode_TEXT, @Lc_FidmCur_ServiceBureauCode_TEXT, @Lc_FidmCur_MagneticTapeCode_TEXT, @Lc_FidmCur_ForeignCorrespondenceCode_TEXT, @Lc_FidmCur_InstitutionName_TEXT, @Lc_FidmCur_InstitutionSecondName_TEXT, @Lc_FidmCur_TransferAgentCode_TEXT, @Lc_FidmCur_ReportingAgentEINIdno_TEXT, @Ls_FidmCur_ReportingAgentName_TEXT, @Lc_FidmCur_ReportingAgentStreetAddr_TEXT, @Lc_FidmCur_ReportingAgentCityAddr_TEXT, @Lc_FidmCur_ReportingAgentStateAddr_TEXT, @Lc_FidmCur_ReportingAgentZipAddr_TEXT, @Lc_FidmCur_DataMatchCode_TEXT, @Lc_FidmCur_InstitutionAddrNormalizationCode_TEXT, @Ls_FidmCur_InstitutionLine1Addr_TEXT, @Ls_FidmCur_InstitutionLine2Addr_TEXT, @Lc_FidmCur_InstitutionCityAddr_TEXT, @Lc_FidmCur_InstitutionStateAddr_TEXT, @Lc_FidmCur_InstitutionZipAddr_TEXT, @Ln_FidmCur_FidmFiirSeq_IDNO, @Ln_FidmCur_SeqB_IDNO, @Lc_FidmCur_RecBId_TEXT, @Lc_FidmCur_FileGeneratedDateB_TEXT, @Lc_FidmCur_PayeeLastName_TEXT, @Lc_FidmCur_MatchedSsnNumb_TEXT, @Lc_FidmCur_PayeeAccountNumb_TEXT, @Ls_FidmCur_FullAccountTitle_TEXT, @Lc_FidmCur_ForeignCountryCode_TEXT, @Lc_FidmCur_MatchedName_TEXT, @Lc_FidmCur_SecondPayeeName_TEXT, @Lc_FidmCur_FipsPassBackCode_TEXT, @Lc_FidmCur_AdditionalStatePassBack_TEXT, @Lc_FidmCur_AccountBalanceAmnt_TEXT, @Lc_FidmCur_AccountMatchCode_TEXT, @Lc_FidmCur_TrustFundCode_TEXT, @Lc_FidmCur_AccountBalanceCode_TEXT, @Lc_FidmCur_AccountUpdateCode_TEXT, @Lc_FidmCur_AccountHolderBirthDate_TEXT, @Lc_FidmCur_StatePassBack_TEXT, @Lc_FidmCur_AccountTypeCode_TEXT, @Lc_FidmCur_CasePassBack_TEXT, @Lc_FidmCur_PayeeCode_TEXT, @Lc_FidmCur_PrimarySsnNumb_TEXT, @Lc_FidmCur_SecondPayeeSsnNumb_TEXT, @Lc_FidmCur_MatchedAddrNormalizationCode_TEXT, @Ls_FidmCur_MatchedLine1Addr_TEXT, @Ls_FidmCur_MatchedLine2Addr_TEXT, @Lc_FidmCur_MatchedCityAddr_TEXT, @Lc_FidmCur_MatchedStateAddr_TEXT, @Lc_FidmCur_MatchedZipAddr_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     SET @Ls_Sql_TEXT = 'CLOSE Fidm_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE Fidm_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Fidm_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE Fidm_CUR;
    END;
   ELSE
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
     SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';
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

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Status_CODE = ' + @Lc_StatusSuccess_CODE;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_FIDM';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_PROCESS_FIDM;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_FIDM;
    END;

   IF CURSOR_STATUS('Local', 'Fidm_CUR') IN (0, 1)
    BEGIN
     CLOSE Fidm_CUR;

     DEALLOCATE Fidm_CUR;
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
