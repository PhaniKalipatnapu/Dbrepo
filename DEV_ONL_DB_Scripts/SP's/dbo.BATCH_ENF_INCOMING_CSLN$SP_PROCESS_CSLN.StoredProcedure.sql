/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_CSLN$SP_PROCESS_CSLN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_CSLN$SP_PROCESS_CSLN
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_CSLN$SP_PROCESS_CSLN reads data from temporary table 
					  and updates the address database table and financial assets database table in DECSS
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
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_CSLN$SP_PROCESS_CSLN]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_INDC                 CHAR = 'Y',
          @Lc_ClaimTypeP_CODE          CHAR = 'P',
          @Lc_ClaimTypeW_CODE          CHAR = 'W',
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE   CHAR(1) = 'A',
          @Lc_Status_CODE              CHAR(1) = 'P',
          @Lc_TypeErrorE_CODE          CHAR(1) = 'E',
          @Lc_ProcessY_INDC            CHAR(1) = 'Y',
          @Lc_ProcessN_INDC            CHAR(1) = 'N',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_Note_INDC                CHAR(1) = 'N',
          @Lc_CaseMemberStatusA_CODE   CHAR(1) = 'A',
          @Lc_StatusCaseO_CODE         CHAR(1) = 'O',
          @Lc_CaseRelationshipA_CODE   CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE   CHAR(1) = 'P',
          @Lc_TypeAddressM_CODE        CHAR(1) = 'M',
          @Lc_TypeOthpI_CODE           CHAR(1) = 'I',
          @Lc_SourceVerifiedA_CODE     CHAR(1) = 'A',
          @Lc_CurrChar_TEXT            CHAR(1) = ' ',
          @Lc_Country_ADDR             CHAR(2) = 'US',
          @Lc_AcctTypePi_CODE          CHAR(2) = 'PI',
          @Lc_AcctTypeWc_CODE          CHAR(2) = 'WC',
          @Lc_SubsystemEn_CODE         CHAR(3) = 'EN',
          @Lc_SourceLocCsl_CODE        CHAR(3) = 'CSL',
          @Lc_AssetIns_CODE            CHAR(3) = 'INS',
          @Lc_ActivityMajorCase_CODE   CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO       CHAR(4) = ' ',
          @Lc_ProcessCsln_ID           CHAR(4) = 'CSLN',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE      CHAR(5) = 'E0944',
          @Lc_ActivityMinorCraif_CODE  CHAR(5) = 'CRAIF',
          @Lc_ActivityMinorCnlno_CODE  CHAR(5) = 'CNLNO',
          @Lc_ActivityMinorCnolv_CODE  CHAR(5) = 'CNOLV',
          @Lc_ActivityMinorCnrle_CODE  CHAR(5) = 'CNRLE',
          @Lc_ActivityMinorCcnle_CODE  CHAR(5) = 'CCNLE',
          @Lc_BateErrorE0958_CODE      CHAR(5) = 'E0958',
          @Lc_BateErrorE0759_CODE      CHAR(5) = 'E0759',
          @Lc_BateErrorE0085_CODE      CHAR(5) = 'E0085',
          @Lc_BateErrorE0043_CODE      CHAR(5) = 'E0043',
          @Lc_BateErrorE1424_CODE      CHAR(5) = 'E1424',
          @Lc_BateErrorE1089_CODE      CHAR(5) = 'E1089',
          @Lc_Job_ID                   CHAR(7) = 'DEB5230',
          @Lc_Notice_ID                CHAR(8) = NULL,
          @Lc_InsContactPhoneNumb_TEXT CHAR(15) = ' ',
          @Lc_InsFaxContactNumb_TEXT   CHAR(15) = ' ',
          @Lc_Successful_TEXT          CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT     CHAR(30) = 'PARM DATE PROBLEM',
          @Lc_WorkerDelegate_ID        CHAR(30) = ' ',
          @Lc_Reference_ID             CHAR(30) = ' ',
          @Ls_Process_NAME             VARCHAR(100) = 'BATCH_ENF_INCOMING_CSLN',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_PROCESS_CSLN',
          @Ls_XmlIn_TEXT               VARCHAR(4000) = ' ',
          @Ld_Low_DATE                 DATE = '01/01/0001',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                       NUMERIC = 0,
          @Ln_CharIndex_NUMB                  NUMERIC = 0,
          @Ln_Office_IDNO                     NUMERIC(3) = 0,
          @Ln_CommitFreqParm_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY         NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                NUMERIC(5),
          @Ln_MajorIntSeq_NUMB                NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB                NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY       NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
          @Ln_OtherParty_IDNO                 NUMERIC(9) = 0,
          @Ln_Schedule_NUMB                   NUMERIC(10) = 0,
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO                    NUMERIC(10) = 0,
          @Ln_Topic_IDNO                      NUMERIC(10),
          @Ln_ErrorLine_NUMB                  NUMERIC(11) = 0,
          @Ln_Error_NUMB                      NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB        NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY                SMALLINT,
          @Li_RowCount_QNTY                   SMALLINT,
          @Lc_Empty_TEXT                      CHAR = '',
          @Lc_Msg_CODE                        CHAR(5),
          @Lc_AcctType_CODE                   CHAR(2) = '',
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_ActivityMinor_CODE              CHAR(5),
          @Lc_DescriptionContactOther_TEXT    CHAR(30) = '',
          @Ls_Sql_TEXT                        VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT             VARCHAR(200),
          @Ls_SqlData_TEXT                    VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(2000),
          @Ls_DescriptionError_TEXT           VARCHAR(4000),
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ls_DescriptionNote_TEXT            VARCHAR(4000) = '',
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Start_DATE                      DATETIME2;
  DECLARE @Ln_CslnCur_Seq_IDNO                                NUMERIC(19),
          @Lc_CslnCur_NcpMemberMciIdno_TEXT                   CHAR(10),
          @Lc_CslnCur_LastNcpName_TEXT                        CHAR(15),
          @Lc_CslnCur_FirstNcpName_TEXT                       CHAR(11),
          @Lc_CslnCur_MiddleNcpName_TEXT                      CHAR(1),
          @Lc_CslnCur_SuffixNcpName_TEXT                      CHAR(3),
          @Lc_CslnCur_NcpSsnNumb_TEXT                         CHAR(9),
          @Lc_CslnCur_BirthNcpDate_TEXT                       CHAR(8),
          @Lc_CslnCur_LkcaAttnNcpAddr_TEXT                    CHAR(40),
          @Lc_CslnCur_LkcaLine1NcpAddr_TEXT                   CHAR(40),
          @Lc_CslnCur_LkcaLine2NcpAddr_TEXT                   CHAR(40),
          @Lc_CslnCur_LkcaCityNcpAddr_TEXT                    CHAR(30),
          @Lc_CslnCur_LkcaStateNcpAddr_TEXT                   CHAR(2),
          @Lc_CslnCur_LkcaZipNcpAddr_TEXT                     CHAR(9),
          @Lc_CslnCur_MailingAttnNcpAddr_TEXT                 CHAR(40),
          @Lc_CslnCur_HomePhoneNcpNumb_TEXT                   CHAR(25),
          @Lc_CslnCur_CellPhoneNcpNumb_TEXT                   CHAR(25),
          @Ls_CslnCur_InsCompanyName_TEXT                     VARCHAR(80),
          @Lc_CslnCur_InsClaimNumb_TEXT                       CHAR(30),
          @Lc_CslnCur_InsClaimTypeCode_TEXT                   CHAR(1),
          @Lc_CslnCur_InsClaimLossDate_TEXT                   CHAR(8),
          @Lc_CslnCur_InsContactFirstName_TEXT                CHAR(20),
          @Lc_CslnCur_InsContactLastName_TEXT                 CHAR(30),
          @Lc_CslnCur_InsContactPhoneNumb_TEXT                CHAR(25),
          @Lc_CslnCur_InsFaxContactNumb_TEXT                  CHAR(25),
          @Lc_CslnCur_CaseIdno_TEXT                           CHAR(6),
          @Lc_CslnCur_FileId_TEXT                             CHAR(11),
          @Lc_CslnCur_LastCourtOrderDate_TEXT                 CHAR(8),
          @Lc_CslnCur_CaseStateCode_TEXT                      CHAR(2),
          @Lc_CslnCur_TotalArrearsAmnt_TEXT                   CHAR(8),
          @Lc_CslnCur_TypeActionCode_TEXT                     CHAR(1),
          @Lc_CslnCur_ActionDate_TEXT                         CHAR(8),
          @Lc_CslnCur_MailingAddressNormalizationCode_TEXT    CHAR(1) = 'N',
          @Ls_CslnCur_MailingLine1NcpAddr_TEXT                VARCHAR(50),
          @Ls_CslnCur_MailingLine2NcpAddr_TEXT                VARCHAR(50),
          @Lc_CslnCur_MailingCityNcpAddr_TEXT                 CHAR(28),
          @Lc_CslnCur_MailingStateNcpAddr_TEXT                CHAR(2),
          @Lc_CslnCur_MailingZipNcpAddr_TEXT                  CHAR(15),
          @Lc_CslnCur_InsCompanyAddressNormalizationCode_TEXT CHAR(1) = 'N',
          @Ls_CslnCur_InsCompanyLine1Addr_TEXT                VARCHAR(50),
          @Ls_CslnCur_InsCompanyLine2Addr_TEXT                VARCHAR(50),
          @Lc_CslnCur_InsCompanyCityAddr_TEXT                 CHAR(28),
          @Lc_CslnCur_InsCompanyStateAddr_TEXT                CHAR(2),
          @Lc_CslnCur_InsCompanyZipAddr_TEXT                  CHAR(15),
          @Lc_CslnCur_Process_INDC                            CHAR(1),
          @Ld_CslnCur_FileLoad_DATE                           DATE,
          @Ln_CaseMemberCur_Case_IDNO                         NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO                    NUMERIC(10);
  DECLARE @Ln_CslnCur_Case_IDNO            NUMERIC(6),
          @Ln_CslnCur_NcpMemberMci_IDNO    NUMERIC(10),
          @Ln_CslnCur_InsContactPhone_NUMB NUMERIC(15),
          @Ln_CslnCur_InsFaxContact_NUMB   NUMERIC(15),
          @Ld_CslnCur_InsClaimLoss_DATE    DATE,
          @Ld_CslnCur_Action_DATE          DATE;
  DECLARE Csln_CUR INSENSITIVE CURSOR FOR
   SELECT A.Seq_IDNO,
          A.NcpMemberMci_IDNO,
          A.LastNcp_NAME,
          A.FirstNcp_NAME,
          A.MiddleNcp_NAME,
          A.SuffixNcp_NAME,
          A.NcpSsn_NUMB,
          A.BirthNcp_DATE,
          A.LkcaAttnNcp_ADDR,
          A.LkcaLine1Ncp_ADDR,
          A.LkcaLine2Ncp_ADDR,
          A.LkcaCityNcp_ADDR,
          A.LkcaStateNcp_ADDR,
          A.LkcaZipNcp_ADDR,
          A.MailingAttnNcp_ADDR,
          A.HomePhoneNcp_NUMB,
          A.CellPhoneNcp_NUMB,
          A.InsCompany_NAME,
          A.InsClaim_NUMB,
          A.InsClaimType_CODE,
          A.InsClaimLoss_DATE,
          A.InsContactFirst_NAME,
          A.InsContactLast_NAME,
          A.InsContactPhone_NUMB,
          A.InsFaxContact_NUMB,
          A.Case_IDNO,
          A.File_ID,
          A.LastCourtOrder_DATE,
          A.CaseState_CODE,
          A.TotalArrears_AMNT,
          A.TypeAction_CODE,
          A.Action_DATE,
          A.MailingAddressNormalization_CODE,
          A.MailingLine1Ncp_ADDR,
          A.MailingLine2Ncp_ADDR,
          A.MailingCityNcp_ADDR,
          A.MailingStateNcp_ADDR,
          A.MailingZipNcp_ADDR,
          A.InsCompanyAddressNormalization_CODE,
          A.InsCompanyLine1_ADDR,
          A.InsCompanyLine2_ADDR,
          A.InsCompanyCity_ADDR,
          A.InsCompanyState_ADDR,
          A.InsCompanyZip_ADDR,
          A.Process_INDC,
          A.FileLoad_DATE
     FROM LCSLN_Y1 A
    WHERE A.Process_INDC = @Lc_ProcessN_INDC
    ORDER BY A.Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_CSLN';

   BEGIN TRANSACTION TXN_PROCESS_CSLN;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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

   SET @Ls_Sql_TEXT = 'OPEN Csln_CUR';

   OPEN Csln_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Csln_CUR - 1';

   FETCH NEXT FROM Csln_CUR INTO @Ln_CslnCur_Seq_IDNO, @Lc_CslnCur_NcpMemberMciIdno_TEXT, @Lc_CslnCur_LastNcpName_TEXT, @Lc_CslnCur_FirstNcpName_TEXT, @Lc_CslnCur_MiddleNcpName_TEXT, @Lc_CslnCur_SuffixNcpName_TEXT, @Lc_CslnCur_NcpSsnNumb_TEXT, @Lc_CslnCur_BirthNcpDate_TEXT, @Lc_CslnCur_LkcaAttnNcpAddr_TEXT, @Lc_CslnCur_LkcaLine1NcpAddr_TEXT, @Lc_CslnCur_LkcaLine2NcpAddr_TEXT, @Lc_CslnCur_LkcaCityNcpAddr_TEXT, @Lc_CslnCur_LkcaStateNcpAddr_TEXT, @Lc_CslnCur_LkcaZipNcpAddr_TEXT, @Lc_CslnCur_MailingAttnNcpAddr_TEXT, @Lc_CslnCur_HomePhoneNcpNumb_TEXT, @Lc_CslnCur_CellPhoneNcpNumb_TEXT, @Ls_CslnCur_InsCompanyName_TEXT, @Lc_CslnCur_InsClaimNumb_TEXT, @Lc_CslnCur_InsClaimTypeCode_TEXT, @Lc_CslnCur_InsClaimLossDate_TEXT, @Lc_CslnCur_InsContactFirstName_TEXT, @Lc_CslnCur_InsContactLastName_TEXT, @Lc_CslnCur_InsContactPhoneNumb_TEXT, @Lc_CslnCur_InsFaxContactNumb_TEXT, @Lc_CslnCur_CaseIdno_TEXT, @Lc_CslnCur_FileId_TEXT, @Lc_CslnCur_LastCourtOrderDate_TEXT, @Lc_CslnCur_CaseStateCode_TEXT, @Lc_CslnCur_TotalArrearsAmnt_TEXT, @Lc_CslnCur_TypeActionCode_TEXT, @Lc_CslnCur_ActionDate_TEXT, @Lc_CslnCur_MailingAddressNormalizationCode_TEXT, @Ls_CslnCur_MailingLine1NcpAddr_TEXT, @Ls_CslnCur_MailingLine2NcpAddr_TEXT, @Lc_CslnCur_MailingCityNcpAddr_TEXT, @Lc_CslnCur_MailingStateNcpAddr_TEXT, @Lc_CslnCur_MailingZipNcpAddr_TEXT, @Lc_CslnCur_InsCompanyAddressNormalizationCode_TEXT, @Ls_CslnCur_InsCompanyLine1Addr_TEXT, @Ls_CslnCur_InsCompanyLine2Addr_TEXT, @Lc_CslnCur_InsCompanyCityAddr_TEXT, @Lc_CslnCur_InsCompanyStateAddr_TEXT, @Lc_CslnCur_InsCompanyZipAddr_TEXT, @Lc_CslnCur_Process_INDC, @Ld_CslnCur_FileLoad_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Csln_CUR';

   --Process incoming records and update the address database table and financial assets database table in DECSS
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_CSLN;

      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'Csln - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_CslnCur_Seq_IDNO AS VARCHAR) + ', NcpMemberMci_IDNO = ' + @Lc_CslnCur_NcpMemberMciIdno_TEXT + ', LastNcp_NAME = ' + @Lc_CslnCur_LastNcpName_TEXT + ', FirstNcp_NAME = ' + @Lc_CslnCur_FirstNcpName_TEXT + ', MiddleNcp_NAME = ' + @Lc_CslnCur_MiddleNcpName_TEXT + ', SuffixNcp_NAME = ' + @Lc_CslnCur_SuffixNcpName_TEXT + ', NcpSsn_NUMB = ' + @Lc_CslnCur_NcpSsnNumb_TEXT + ', BirthNcp_DATE = ' + @Lc_CslnCur_BirthNcpDate_TEXT + ', LkcaAttnNcp_ADDR = ' + @Lc_CslnCur_LkcaAttnNcpAddr_TEXT + ', LkcaLine1Ncp_ADDR = ' + @Lc_CslnCur_LkcaLine1NcpAddr_TEXT + ', LkcaLine2Ncp_ADDR = ' + @Lc_CslnCur_LkcaLine2NcpAddr_TEXT + ', LkcaCityNcp_ADDR = ' + @Lc_CslnCur_LkcaCityNcpAddr_TEXT + ', LkcaStateNcp_ADDR = ' + @Lc_CslnCur_LkcaStateNcpAddr_TEXT + ', LkcaZipNcp_ADDR = ' + @Lc_CslnCur_LkcaZipNcpAddr_TEXT + ', MailingAttnNcp_ADDR = ' + @Lc_CslnCur_MailingAttnNcpAddr_TEXT + ', HomePhoneNcp_NUMB = ' + @Lc_CslnCur_HomePhoneNcpNumb_TEXT + ', CellPhoneNcp_NUMB = ' + @Lc_CslnCur_CellPhoneNcpNumb_TEXT + ', InsCompany_NAME = ' + @Ls_CslnCur_InsCompanyName_TEXT + ', InsClaim_NUMB = ' + @Lc_CslnCur_InsClaimNumb_TEXT + ', InsClaimType_CODE = ' + @Lc_CslnCur_InsClaimTypeCode_TEXT + ', InsClaimLoss_DATE = ' + @Lc_CslnCur_InsClaimLossDate_TEXT + ', InsContactFirst_NAME = ' + @Lc_CslnCur_InsContactFirstName_TEXT + ', InsContactLast_NAME = ' + @Lc_CslnCur_InsContactLastName_TEXT + ', InsContactPhone_NUMB = ' + @Lc_CslnCur_InsContactPhoneNumb_TEXT + ', InsFaxContact_NUMB = ' + @Lc_CslnCur_InsFaxContactNumb_TEXT + ', Case_IDNO = ' + @Lc_CslnCur_CaseIdno_TEXT + ', File_ID = ' + @Lc_CslnCur_FileId_TEXT + ', LastCourtOrder_DATE = ' + @Lc_CslnCur_LastCourtOrderDate_TEXT + ', CaseState_CODE = ' + @Lc_CslnCur_CaseStateCode_TEXT + ', TotalArrears_AMNT = ' + @Lc_CslnCur_TotalArrearsAmnt_TEXT + ', TypeAction_CODE = ' + @Lc_CslnCur_TypeActionCode_TEXT + ', Action_DATE = ' + @Lc_CslnCur_ActionDate_TEXT + ', MailingAddressNormalization_CODE = ' + @Lc_CslnCur_MailingAddressNormalizationCode_TEXT + ', MailingLine1Ncp_ADDR = ' + @Ls_CslnCur_MailingLine1NcpAddr_TEXT + ', MailingLine2Ncp_ADDR = ' + @Ls_CslnCur_MailingLine2NcpAddr_TEXT + ', MailingCityNcp_ADDR = ' + @Lc_CslnCur_MailingCityNcpAddr_TEXT + ', MailingStateNcp_ADDR = ' + @Lc_CslnCur_MailingStateNcpAddr_TEXT + ', MailingZipNcp_ADDR = ' + @Lc_CslnCur_MailingZipNcpAddr_TEXT + ', InsCompanyAddressNormalization_CODE = ' + @Lc_CslnCur_InsCompanyAddressNormalizationCode_TEXT + ', InsCompanyLine1_ADDR = ' + @Ls_CslnCur_InsCompanyLine1Addr_TEXT + ', InsCompanyLine2_ADDR = ' + @Ls_CslnCur_InsCompanyLine2Addr_TEXT + ', InsCompanyCity_ADDR = ' + @Lc_CslnCur_InsCompanyCityAddr_TEXT + ', InsCompanyState_ADDR = ' + @Lc_CslnCur_InsCompanyStateAddr_TEXT + ', InsCompanyZip_ADDR = ' + @Lc_CslnCur_InsCompanyZipAddr_TEXT + ', Process_INDC = ' + @Lc_CslnCur_Process_INDC + ', FileLoad_DATE = ' + CAST(@Ld_CslnCur_FileLoad_DATE AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK INPUT MEMBER MCI #';

      IF ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_NcpMemberMciIdno_TEXT, @Lc_Empty_TEXT)))) = 0
          OR CAST(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_NcpMemberMciIdno_TEXT, @Lc_Empty_TEXT))) AS NUMERIC) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorE0958_CODE;
        SET @Ls_ErrorMessage_TEXT = 'KEY DATA NOT FOUND';

        RAISERROR(50001,16,1);
       END;
      ELSE
       BEGIN
        SET @Ln_CslnCur_NcpMemberMci_IDNO = @Lc_CslnCur_NcpMemberMciIdno_TEXT;
       END;

      SET @Ls_Sql_TEXT = 'CHECK WHETHER MEMBER IS AN ACTIVE NCP IN CMEM';

      IF NOT EXISTS (SELECT 1
                       FROM CMEM_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_CslnCur_NcpMemberMci_IDNO
                        AND X.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                        AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                        AND EXISTS (SELECT 1
                                      FROM CASE_Y1 Y
                                     WHERE Y.Case_IDNO = X.Case_IDNO
                                       AND Y.StatusCase_CODE = @Lc_StatusCaseO_CODE))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorE0759_CODE;
        SET @Ls_ErrorMessage_TEXT = 'NO CASE MEMBER RECORD FOR NON-CUSTODIAL';

        RAISERROR(50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'CHECK INPUT ACTION TYPE';

      IF LEN(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_TypeActionCode_TEXT, @Lc_Empty_TEXT)))) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE;
        SET @Ls_ErrorMessage_TEXT = 'INVALID VALUE';

        RAISERROR(50001,16,1);
       END;

      IF LTRIM(RTRIM(@Lc_CslnCur_TypeActionCode_TEXT)) = '0'
       BEGIN
        IF LEN(LTRIM(RTRIM(ISNULL(@Ls_CslnCur_MailingLine1NcpAddr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_MailingCityNcpAddr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_MailingStateNcpAddr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_MailingZipNcpAddr_TEXT, '')))) > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CslnCur_NcpMemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressM_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_CslnCur_MailingLine1NcpAddr_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Ls_CslnCur_MailingLine2NcpAddr_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_CslnCur_MailingCityNcpAddr_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_CslnCur_MailingStateNcpAddr_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_CslnCur_MailingZipNcpAddr_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocCsl_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_Status_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_CslnCur_MailingAddressNormalizationCode_TEXT, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_CslnCur_NcpMemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
           @As_Line1_ADDR                       = @Ls_CslnCur_MailingLine1NcpAddr_TEXT,
           @As_Line2_ADDR                       = @Ls_CslnCur_MailingLine2NcpAddr_TEXT,
           @Ac_City_ADDR                        = @Lc_CslnCur_MailingCityNcpAddr_TEXT,
           @Ac_State_ADDR                       = @Lc_CslnCur_MailingStateNcpAddr_TEXT,
           @Ac_Zip_ADDR                         = @Lc_CslnCur_MailingZipNcpAddr_TEXT,
           @Ac_Country_ADDR                     = @Lc_Country_ADDR,
           @An_Phone_NUMB                       = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_SourceLocCsl_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_Status_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
           @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
           @Ac_Process_ID                       = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
           @Ac_Normalization_CODE               = @Lc_CslnCur_MailingAddressNormalizationCode_TEXT,
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
            SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

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

            DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
             SELECT A.Case_IDNO,
                    A.MemberMci_IDNO
               FROM CMEM_Y1 A,
                    CASE_Y1 B
              WHERE MemberMci_IDNO = @Ln_CslnCur_NcpMemberMci_IDNO
                AND A.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                AND A.Case_IDNO = B.Case_IDNO
                AND B.StatusCase_CODE = @Lc_StatusCaseO_CODE;

            SET @Ls_Sql_TEXT = 'OPEN CaseMember_CUR';

            OPEN CaseMember_CUR;

            SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 1';

            FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
            SET @Ls_Sql_TEXT = 'LOOP THROUGH CaseMember_CUR';

            --Make a Case Journal Entry for each case of the member...          
            WHILE @Li_FetchStatus_QNTY = 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
              SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCraif_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemEn_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

              EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
               @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
               @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
               @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
               @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCraif_CODE,
               @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
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

              FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

              SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
             END;

            SET @Ls_Sql_TEXT = 'CLOSE CaseMember_CUR';

            CLOSE CaseMember_CUR;

            SET @Ls_Sql_TEXT = 'DEALLOCATE CaseMember_CUR';

            DEALLOCATE CaseMember_CUR;
           END
         END;

        SET @Ls_Sql_TEXT = 'CHECK INPUT INSURANCE CLAIM TYPE';
        SET @Ls_SqlData_TEXT = 'InsClaimTypeCode_TEXT = ' + @Lc_CslnCur_InsClaimTypeCode_TEXT;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_InsClaimTypeCode_TEXT, @Lc_Empty_TEXT)))) > 0
           AND LTRIM(RTRIM(@Lc_CslnCur_InsClaimTypeCode_TEXT)) IN (@Lc_ClaimTypeP_CODE, @Lc_ClaimTypeW_CODE)
         BEGIN
          SET @Ls_Sql_TEXT = 'DERIVE OTHER CONTACT DESCRIPTION FROM INPUT INSURANCE CONTACT FIRST NAME AND LAST NAME';
          SET @Ls_SqlData_TEXT = 'InsContactFirstName_TEXT = ' + @Lc_CslnCur_InsContactFirstName_TEXT + ', InsContactLastName_TEXT = ' + @Lc_CslnCur_InsContactLastName_TEXT;
          SET @Lc_DescriptionContactOther_TEXT = LTRIM(RTRIM(@Lc_CslnCur_InsContactFirstName_TEXT)) + @Lc_Space_TEXT + LTRIM(RTRIM(@Lc_CslnCur_InsContactLastName_TEXT));

          IF LEN(LTRIM(RTRIM(@Lc_CslnCur_InsContactLastName_TEXT))) = 0
              OR LEN(LTRIM(RTRIM(@Lc_CslnCur_InsContactFirstName_TEXT))) = 0
           BEGIN
            SET @Lc_DescriptionContactOther_TEXT = LTRIM(RTRIM(@Lc_DescriptionContactOther_TEXT));
           END;

          SET @Ls_Sql_TEXT = 'DERIVE PHONE NUMBER FROM INPUT INSURANCE CONTACT PHONE NUMBER';
          SET @Ls_SqlData_TEXT = 'InsContactPhoneNumb_TEXT = ' + @Lc_CslnCur_InsContactPhoneNumb_TEXT;

          IF LEN(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_InsContactPhoneNumb_TEXT, @Lc_Empty_TEXT)))) > 0
           BEGIN
            SET @Lc_InsContactPhoneNumb_TEXT = LTRIM(RTRIM(LEFT(@Lc_CslnCur_InsContactPhoneNumb_TEXT, 15)));
            SET @Ln_CharIndex_NUMB = 0;

            WHILE @Ln_CharIndex_NUMB <= 15
             BEGIN
              SET @Ln_CharIndex_NUMB = @Ln_CharIndex_NUMB + 1;
              SET @Lc_CurrChar_TEXT = SUBSTRING(@Lc_InsContactPhoneNumb_TEXT, @Ln_CharIndex_NUMB, 1);

              IF @Lc_CurrChar_TEXT NOT LIKE '[0-9]'
               BEGIN
                SET @Lc_InsContactPhoneNumb_TEXT = LEFT(@Lc_InsContactPhoneNumb_TEXT, @Ln_CharIndex_NUMB - 1)

                BREAK;
               END;
             END;

            IF LEN(LTRIM(RTRIM(ISNULL(@Lc_InsContactPhoneNumb_TEXT, @Lc_Empty_TEXT)))) > 0
             BEGIN
              SET @Ln_CslnCur_InsContactPhone_NUMB = @Lc_InsContactPhoneNumb_TEXT;
             END;
            ELSE
             BEGIN
              SET @Ln_CslnCur_InsContactPhone_NUMB = @Ln_Zero_NUMB;
             END;
           END;
          ELSE
           BEGIN
            SET @Ln_CslnCur_InsContactPhone_NUMB = @Ln_Zero_NUMB;
           END;

          SET @Ls_Sql_TEXT = 'DERIVE FAX NUMBER FROM INPUT INSURANCE CONTACT FAX NUMBER';
          SET @Ls_SqlData_TEXT = 'InsFaxContactNumb_TEXT = ' + @Lc_CslnCur_InsFaxContactNumb_TEXT;

          IF LEN(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_InsFaxContactNumb_TEXT, @Lc_Empty_TEXT)))) > 0
           BEGIN
            SET @Lc_InsFaxContactNumb_TEXT = LTRIM(RTRIM(LEFT(@Lc_CslnCur_InsFaxContactNumb_TEXT, 15)));
            SET @Ln_CharIndex_NUMB = 0;

            WHILE @Ln_CharIndex_NUMB <= 15
             BEGIN
              SET @Ln_CharIndex_NUMB = @Ln_CharIndex_NUMB + 1;
              SET @Lc_CurrChar_TEXT = SUBSTRING(@Lc_InsFaxContactNumb_TEXT, @Ln_CharIndex_NUMB, 1);

              IF @Lc_CurrChar_TEXT NOT LIKE '[0-9]'
               BEGIN
                SET @Lc_InsFaxContactNumb_TEXT = LEFT(@Lc_InsFaxContactNumb_TEXT, @Ln_CharIndex_NUMB - 1)

                BREAK;
               END;
             END;

            IF LEN(LTRIM(RTRIM(ISNULL(@Lc_InsFaxContactNumb_TEXT, @Lc_Empty_TEXT)))) > 0
             BEGIN
              SET @Ln_CslnCur_InsFaxContact_NUMB = @Lc_InsFaxContactNumb_TEXT;
             END;
            ELSE
             BEGIN
              SET @Ln_CslnCur_InsFaxContact_NUMB = @Ln_Zero_NUMB;
             END;
           END;
          ELSE
           BEGIN
            SET @Ln_CslnCur_InsFaxContact_NUMB = @Ln_Zero_NUMB;
           END;

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
          SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpI_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@Ls_CslnCur_InsCompanyName_TEXT, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_CslnCur_InsCompanyLine1Addr_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Ls_CslnCur_InsCompanyLine2Addr_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_CslnCur_InsCompanyCityAddr_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_CslnCur_InsCompanyStateAddr_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_CslnCur_InsCompanyZipAddr_TEXT, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_DescriptionContactOther_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_CslnCur_InsContactPhone_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Ln_CslnCur_InsFaxContact_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocCsl_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_CslnCur_InsCompanyAddressNormalizationCode_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');

          EXECUTE BATCH_COMMON$SP_GET_OTHP
           @Ad_Run_DATE                     = @Ld_Run_DATE,
           @An_Fein_IDNO                    = @Ln_Zero_NUMB,
           @Ac_TypeOthp_CODE                = @Lc_TypeOthpI_CODE,
           @As_OtherParty_NAME              = @Ls_CslnCur_InsCompanyName_TEXT,
           @Ac_Aka_NAME                     = @Lc_Space_TEXT,
           @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
           @As_Line1_ADDR                   = @Ls_CslnCur_InsCompanyLine1Addr_TEXT,
           @As_Line2_ADDR                   = @Ls_CslnCur_InsCompanyLine2Addr_TEXT,
           @Ac_City_ADDR                    = @Lc_CslnCur_InsCompanyCityAddr_TEXT,
           @Ac_State_ADDR                   = @Lc_CslnCur_InsCompanyStateAddr_TEXT,
           @Ac_Zip_ADDR                     = @Lc_CslnCur_InsCompanyZipAddr_TEXT,
           @Ac_Fips_CODE                    = @Lc_Space_TEXT,
           @Ac_Country_ADDR                 = @Lc_Country_ADDR,
           @Ac_DescriptionContactOther_TEXT = @Lc_DescriptionContactOther_TEXT,
           @An_Phone_NUMB                   = @Ln_CslnCur_InsContactPhone_NUMB,
           @An_Fax_NUMB                     = @Ln_CslnCur_InsFaxContact_NUMB,
           @As_Contact_EML                  = @Lc_Space_TEXT,
           @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
           @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
           @An_Sein_IDNO                    = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE               = @Lc_SourceLocCsl_CODE,
           @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
           @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
           @Ac_Normalization_CODE           = @Lc_CslnCur_InsCompanyAddressNormalizationCode_TEXT,
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

          IF @Ln_OtherParty_IDNO > 0
           BEGIN
            IF ISDATE(LTRIM(RTRIM(@Lc_CslnCur_InsClaimLossDate_TEXT))) = 1
             BEGIN
              SET @Ld_CslnCur_InsClaimLoss_DATE = @Lc_CslnCur_InsClaimLossDate_TEXT;
             END
            ELSE
             BEGIN
              SET @Ld_CslnCur_InsClaimLoss_DATE = @Ld_High_DATE;
             END

            SET @Lc_AcctType_CODE = CASE LTRIM(RTRIM(@Lc_CslnCur_InsClaimTypeCode_TEXT))
                                     WHEN @Lc_ClaimTypeP_CODE
                                      THEN @Lc_AcctTypePi_CODE
                                     WHEN @Lc_ClaimTypeW_CODE
                                      THEN @Lc_AcctTypeWc_CODE
                                    END;
            SET @Ls_Sql_TEXT = 'BATCH_ENF_INCOMING_CSLN$SP_UPDATE_ASFN';
            SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CslnCur_NcpMemberMci_IDNO AS VARCHAR), '') + ', OthpInsFin_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', AccountAssetNo_TEXT = ' + ISNULL(@Lc_CslnCur_InsClaimNumb_TEXT, '') + ', AcctType_CODE = ' + ISNULL(@Lc_AcctType_CODE, '') + ', Asset_CODE = ' + ISNULL(@Lc_AssetIns_CODE, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocCsl_CODE, '') + ', ClaimLoss_DATE = ' + ISNULL(CAST(@Ld_CslnCur_InsClaimLoss_DATE AS VARCHAR), '');

            EXECUTE BATCH_ENF_INCOMING_CSLN$SP_UPDATE_ASFN
             @Ad_Run_DATE              = @Ld_Run_DATE,
             @Ac_Job_ID                = @Lc_Job_ID,
             @An_MemberMci_IDNO        = @Ln_CslnCur_NcpMemberMci_IDNO,
             @An_OthpInsFin_IDNO       = @Ln_OtherParty_IDNO,
             @Ac_AccountAssetNo_TEXT   = @Lc_CslnCur_InsClaimNumb_TEXT,
             @Ac_AcctType_CODE         = @Lc_AcctType_CODE,
             @Ac_Asset_CODE            = @Lc_AssetIns_CODE,
             @Ac_SourceLoc_CODE        = @Lc_SourceLocCsl_CODE,
             @Ad_ClaimLoss_DATE        = @Ld_CslnCur_InsClaimLoss_DATE,
             @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

              RAISERROR(50001,16,1);
             END;

            IF LTRIM(RTRIM(@Lc_AcctType_CODE)) IN (@Lc_AcctTypeWc_CODE)
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
              SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CslnCur_NcpMemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_Yes_INDC, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_AcctTypeWc_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceLocCsl_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocCsl_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_ProcessCsln_ID, '');

              EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
               @An_MemberMci_IDNO             = @Ln_CslnCur_NcpMemberMci_IDNO,
               @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
               @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
               @Ac_Status_CODE                = @Lc_Yes_INDC,
               @Ad_Status_DATE                = @Ld_Run_DATE,
               @Ac_TypeIncome_CODE            = @Lc_AcctTypeWc_CODE,
               @Ac_SourceLocConf_CODE         = @Lc_SourceVerifiedA_CODE,
               @Ad_Run_DATE                   = @Ld_Run_DATE,
               @Ad_BeginEmployment_DATE       = @Ld_Run_DATE,
               @Ad_EndEmployment_DATE         = @Ld_High_DATE,
               @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
               @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
               @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
               @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
               @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
               @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
               @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
               @Ac_SourceLoc_CODE             = @Lc_SourceLocCsl_CODE,
               @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
               @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
               @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
               @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
               @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
               @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
               @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
               @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
               @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
               @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
               @Ac_Process_ID                 = @Lc_Job_ID,
               @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

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
             END;
           END;
         END;
       END;
      ELSE IF LTRIM(RTRIM(@Lc_CslnCur_TypeActionCode_TEXT)) IN ('1', '3', '4', '9')
       BEGIN
        IF ISDATE(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_ActionDate_TEXT, @Lc_Empty_TEXT)))) = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0043_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INVALID DATE';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          SET @Ld_CslnCur_Action_DATE = @Lc_CslnCur_ActionDate_TEXT;
         END;

        IF ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_CaseIdno_TEXT, @Lc_Empty_TEXT)))) = 0
            OR CAST(LTRIM(RTRIM(ISNULL(@Lc_CslnCur_CaseIdno_TEXT, @Lc_Empty_TEXT))) AS NUMERIC) = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INVALID VALUE';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          SET @Ln_CslnCur_Case_IDNO = @Lc_CslnCur_CaseIdno_TEXT;
         END;

        SET @Lc_ActivityMinor_CODE = CASE LTRIM(RTRIM(@Lc_CslnCur_TypeActionCode_TEXT))
                                      WHEN '1'
                                       THEN @Lc_ActivityMinorCnlno_CODE
                                      WHEN '3'
                                       THEN @Lc_ActivityMinorCnolv_CODE
                                      WHEN '4'
                                       THEN @Lc_ActivityMinorCnrle_CODE
                                      WHEN '9'
                                       THEN @Lc_ActivityMinorCcnle_CODE
                                     END;
        SET @Ls_DescriptionNote_TEXT = 'Action Date = ' + CONVERT(VARCHAR(10), @Ld_CslnCur_Action_DATE, 101);
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
        SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

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

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
        SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CslnCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(@Lc_CslnCur_NcpMemberMciIdno_TEXT, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', DescriptionNote_TEXT = ' + ISNULL(@Ls_DescriptionNote_TEXT, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemEn_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

        EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
         @An_Case_IDNO                = @Ln_CslnCur_Case_IDNO,
         @An_MemberMci_IDNO           = @Lc_CslnCur_NcpMemberMciIdno_TEXT,
         @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
         @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
         @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
         @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
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
       END;
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_CSLN;
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

     SET @Ls_Sql_TEXT = 'UPDATE LCSLN_Y1';
     SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CslnCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LCSLN_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_CslnCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE LCSLN_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';
     SET @Ls_SqlData_TEXT = 'CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR) + ', CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR);

     IF @Ln_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_CSLN';

       COMMIT TRANSACTION TXN_PROCESS_CSLN;

       SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_CSLN';

       BEGIN TRANSACTION TXN_PROCESS_CSLN;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';
     SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION TXN_PROCESS_CSLN;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Csln_CUR - 2';
     SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Csln_CUR INTO @Ln_CslnCur_Seq_IDNO, @Lc_CslnCur_NcpMemberMciIdno_TEXT, @Lc_CslnCur_LastNcpName_TEXT, @Lc_CslnCur_FirstNcpName_TEXT, @Lc_CslnCur_MiddleNcpName_TEXT, @Lc_CslnCur_SuffixNcpName_TEXT, @Lc_CslnCur_NcpSsnNumb_TEXT, @Lc_CslnCur_BirthNcpDate_TEXT, @Lc_CslnCur_LkcaAttnNcpAddr_TEXT, @Lc_CslnCur_LkcaLine1NcpAddr_TEXT, @Lc_CslnCur_LkcaLine2NcpAddr_TEXT, @Lc_CslnCur_LkcaCityNcpAddr_TEXT, @Lc_CslnCur_LkcaStateNcpAddr_TEXT, @Lc_CslnCur_LkcaZipNcpAddr_TEXT, @Lc_CslnCur_MailingAttnNcpAddr_TEXT, @Lc_CslnCur_HomePhoneNcpNumb_TEXT, @Lc_CslnCur_CellPhoneNcpNumb_TEXT, @Ls_CslnCur_InsCompanyName_TEXT, @Lc_CslnCur_InsClaimNumb_TEXT, @Lc_CslnCur_InsClaimTypeCode_TEXT, @Lc_CslnCur_InsClaimLossDate_TEXT, @Lc_CslnCur_InsContactFirstName_TEXT, @Lc_CslnCur_InsContactLastName_TEXT, @Lc_CslnCur_InsContactPhoneNumb_TEXT, @Lc_CslnCur_InsFaxContactNumb_TEXT, @Lc_CslnCur_CaseIdno_TEXT, @Lc_CslnCur_FileId_TEXT, @Lc_CslnCur_LastCourtOrderDate_TEXT, @Lc_CslnCur_CaseStateCode_TEXT, @Lc_CslnCur_TotalArrearsAmnt_TEXT, @Lc_CslnCur_TypeActionCode_TEXT, @Lc_CslnCur_ActionDate_TEXT, @Lc_CslnCur_MailingAddressNormalizationCode_TEXT, @Ls_CslnCur_MailingLine1NcpAddr_TEXT, @Ls_CslnCur_MailingLine2NcpAddr_TEXT, @Lc_CslnCur_MailingCityNcpAddr_TEXT, @Lc_CslnCur_MailingStateNcpAddr_TEXT, @Lc_CslnCur_MailingZipNcpAddr_TEXT, @Lc_CslnCur_InsCompanyAddressNormalizationCode_TEXT, @Ls_CslnCur_InsCompanyLine1Addr_TEXT, @Ls_CslnCur_InsCompanyLine2Addr_TEXT, @Lc_CslnCur_InsCompanyCityAddr_TEXT, @Lc_CslnCur_InsCompanyStateAddr_TEXT, @Lc_CslnCur_InsCompanyZipAddr_TEXT, @Lc_CslnCur_Process_INDC, @Ld_CslnCur_FileLoad_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   SET @Ls_Sql_TEXT = 'CLOSE Csln_CUR';

   CLOSE Csln_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Csln_CUR';

   DEALLOCATE Csln_CUR;

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '');

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
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

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
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_CSLN';

   COMMIT TRANSACTION TXN_PROCESS_CSLN;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_CSLN;
    END;

   IF CURSOR_STATUS('Local', 'Csln_CUR') IN (0, 1)
    BEGIN
     CLOSE Csln_CUR;

     DEALLOCATE Csln_CUR;
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
