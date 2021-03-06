/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_DMV$SP_PROCESS_DMV]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_DMV$SP_PROCESS_DMV
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_DMV$SP_PROCESS_DMV reads LDMVL_Y1 and updates the NCP's address and license information in the system.
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
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_DMV$SP_PROCESS_DMV]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_OthpLicAgent_IDNO       NUMERIC(9) = '999999974',
          @Lc_Yes_INDC                CHAR = 'Y',
          @Lc_No_INDC                 CHAR = 'N',
          @Lc_LicenseUpdated_INDC     CHAR = 'N',
          @Lc_ActionM_CODE            CHAR = 'M',
          @Lc_ActionS_CODE            CHAR = 'S',
          @Lc_ActionL_CODE            CHAR = 'L',
          @Lc_TypeAliasA_CODE         CHAR = 'A',
          @Lc_NegPosCloseRemedy_CODE  CHAR = 'N',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE  CHAR(1) = 'A',
          @Lc_StatusP_CODE            CHAR(1) = 'P',
          @Lc_Note_INDC               CHAR(1) = 'N',
          @Lc_CaseMemberStatusA_CODE  CHAR(1) = 'A',
          @Lc_StatusCaseO_CODE        CHAR(1) = 'O',
          @Lc_StatusCaseC_CODE        CHAR(1) = 'C',
          @Lc_StatusEnforceO_CODE     CHAR(1) = 'O',
          @Lc_TypeErrorE_CODE         CHAR(1) = 'E',
          @Lc_ProcessY_INDC           CHAR(1) = 'Y',
          @Lc_ProcessN_INDC           CHAR(1) = 'N',
          @Lc_LicenseStatus_CODE      CHAR(1) = 'A',
          @Lc_LicenseStatusA_CODE     CHAR(1) = 'A',
          @Lc_LicenseStatusI_CODE     CHAR(1) = 'I',
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_CaseRelationshipA_CODE  CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE  CHAR(1) = 'P',
          @Lc_TypeAddressM_CODE       CHAR(1) = 'M',
          @Lc_TypeAddressR_CODE       CHAR(1) = 'R',
          @Lc_TypePrimaryP_CODE       CHAR(1) = 'P',
          @Lc_TypePrimaryS_CODE       CHAR(1) = 'S',
          @Lc_TypePrimaryT_CODE       CHAR(1) = 'T',
          @Lc_TypePrimaryI_CODE       CHAR(1) = 'I',
          @Lc_EnumerationY_CODE       CHAR(1) = 'Y',
          @Lc_EnumerationP_CODE       CHAR(1) = 'P',
          @Lc_SourceVerifiedA_CODE    CHAR(1) = 'A',
          @Lc_Country_ADDR            CHAR(2) = 'US',
          @Lc_StatusCg_CODE           CHAR(2) = 'CG',
          --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -START-
          @Lc_StatusCb_CODE           CHAR(2) = 'CB',
          --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -END-
          @Lc_IssuingStateDe_CODE     CHAR(2) = 'DE',
          @Lc_TypeChangeLe_CODE       CHAR(2) = 'LE',
          @Lc_RsnStatusCaseUb_CODE    CHAR(2) = 'UB',
          @Lc_SubsystemEn_CODE        CHAR(3) = 'EN',
          @Lc_SourceLocDmv_CODE       CHAR(3) = 'DMV',
          @Lc_SourceVerifiedDmv_CODE  CHAR(3) = 'DMV',
          @Lc_SourceVerifyDmv_CODE    CHAR(3) = 'DMV',
          @Lc_SourceDmv_CODE          CHAR(3) = 'DMV',
          @Lc_ActivityMajorCase_CODE  CHAR(4) = 'CASE',
          @Lc_ActivityMajorLsnr_CODE  CHAR(4) = 'LSNR',
          @Lc_StatusStrt_CODE         CHAR(4) = 'STRT',
          @Lc_TypeReference_IDNO      CHAR(4) = ' ',
          @Lc_TypeLicenseDr_CODE      CHAR(5) = 'DR',
          @Lc_TypeReferenceLic_CODE   CHAR(5) = 'LIC',
          @Lc_ProcessLsnr_ID          CHAR(4) = 'LSNR',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_BateErrorE0085_CODE     CHAR(5) = 'E0085',
          @Lc_BateErrorE0944_CODE     CHAR(5) = 'E0944',
          @Lc_BateErrorE0012_CODE     CHAR(5) = 'E0012',
          @Lc_ActivityMinorRrdmv_CODE CHAR(5) = 'RRDMV',
          @Lc_ActivityMinorMofre_CODE CHAR(5) = 'MOFRE',
          @Lc_ActivityMinorRncpl_CODE CHAR(5) = 'RNCPL',
          @Lc_BateErrorE0958_CODE     CHAR(5) = 'E0958',
          @Lc_BateErrorE0907_CODE     CHAR(5) = 'E0907',
          @Lc_BateErrorE0881_CODE     CHAR(5) = 'E0881',
          @Lc_BateErrorE1424_CODE     CHAR(5) = 'E1424',
          @Lc_BateErrorE1089_CODE     CHAR(5) = 'E1089',
          @Lc_BateErrorE1479_CODE     CHAR(5) = 'E1479',
          @Lc_Job_ID                  CHAR(7) = 'DEB5050',
          @Lc_Notice_ID               CHAR(8) = NULL,
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT    CHAR(30) = 'PARM DATE PROBLEM',
          @Lc_WorkerDelegate_ID       CHAR(30) = ' ',
          @Lc_Reference_ID            CHAR(30) = ' ',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_ENF_INCOMING_DMV',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_PROCESS_DMV',
          @Ls_XmlIn_TEXT              VARCHAR(4000) = ' ',
          @Ld_Low_DATE                DATE = '01/01/0001',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                       NUMERIC = 0,
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
          @Ln_AkaNcpSsn_NUMB                  NUMERIC(9),
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO                    NUMERIC(10) = 0,
          @Ln_Schedule_NUMB                   NUMERIC(10) = 0,
          @Ln_Topic_IDNO                      NUMERIC(10),
          @Ln_ErrorLine_NUMB                  NUMERIC(11) = 0,
          @Ln_Error_NUMB                      NUMERIC(11),
          @Ln_Sequence_NUMB                   NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB        NUMERIC(19) = 0,
          @Li_SpaceFoundPosition_NUMB         INT,
          @Li_NameLength_NUMB                 INT,
          @Li_FetchStatus_QNTY                SMALLINT,
          @Li_RowCount_QNTY                   SMALLINT,
          @Li_AliasNameCount_QNTY             SMALLINT,
          @Li_AliasSsnCount_QNTY              SMALLINT,
          @Lc_Empty_TEXT                      CHAR = '',
          @Lc_TypePrimary_CODE                CHAR(1),
          @Lc_AkaNcpSuffix_NAME               CHAR(4),
          @Lc_Msg_CODE                        CHAR(5),
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_AkaNcpSsn_NUMB                  CHAR(9),
          @Lc_AkaNcpFirst_NAME                CHAR(16),
          @Lc_AkaNcpLast_NAME                 CHAR(20),
          @Lc_AkaNcpMiddle_NAME               CHAR(20),
          @Lc_AkaNcp_NAME                     CHAR(32),
          @Ls_Sql_TEXT                        VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT             VARCHAR(200),
          @Ls_SqlData_TEXT                    VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(2000),
          @Ls_DescriptionError_TEXT           VARCHAR(4000),
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ld_SuspLicense_DATE                DATE,
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Start_DATE                      DATETIME2;
  DECLARE @Ln_DmvlCur_Seq_IDNO                               NUMERIC(19),
          @Lc_DmvlCur_RecId_TEXT                             CHAR(1),
          @Lc_DmvlCur_LastNcpName_TEXT                       CHAR(12),
          @Lc_DmvlCur_FirstNcpName_TEXT                      CHAR(11),
          @Lc_DmvlCur_MiddleNcpName_TEXT                     CHAR(1),
          @Lc_DmvlCur_BirthNcpDate_TEXT                      CHAR(8),
          @Lc_DmvlCur_NcpDriversLicenseNo_TEXT               CHAR(12),
          @Lc_DmvlCur_NcpSsnNumb_TEXT                        CHAR(9),
          @Lc_DmvlCur_NcpSexCode_TEXT                        CHAR(1),
          @Lc_DmvlCur_NcpMemberMciIdno_TEXT                  CHAR(10),
          @Lc_DmvlCur_SourceCode_TEXT                        CHAR(2),
          @Lc_DmvlCur_ActionCode_TEXT                        CHAR(1),
          @Lc_DmvlCur_NcpName_TEXT                           CHAR(32),
          @Lc_DmvlCur_SuffixNcpName_TEXT                     CHAR(3),
          @Lc_DmvlCur_DmvBirthNcpDate_TEXT                   CHAR(8),
          @Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT            CHAR(8),
          @Lc_DmvlCur_NcpDriversLicenseTypeCode_TEXT         CHAR(2),
          @Lc_DmvlCur_NcpDmvSsnNumb_TEXT                     CHAR(9),
          @Lc_DmvlCur_NcpDmvSexCode_TEXT                     CHAR(1),
          @Lc_DmvlCur_NcpAkaIndc_TEXT                        CHAR(1),
          @Lc_DmvlCur_AkaNcp1Name_TEXT                       CHAR(32),
          @Lc_DmvlCur_SuffixAkaNcp1Name_TEXT                 CHAR(3),
          @Lc_DmvlCur_AkaNcp2Name_TEXT                       CHAR(32),
          @Lc_DmvlCur_SuffixAkaNcp2Name_TEXT                 CHAR(3),
          @Lc_DmvlCur_AkaNcp3Name_TEXT                       CHAR(32),
          @Lc_DmvlCur_SuffixAkaNcp3Name_TEXT                 CHAR(3),
          @Lc_DmvlCur_AkaNcpSsn1Numb_TEXT                    CHAR(9),
          @Lc_DmvlCur_AkaNcpSsn2Numb_TEXT                    CHAR(9),
          @Lc_DmvlCur_AkaNcpSsn3Numb_TEXT                    CHAR(9),
          @Lc_DmvlCur_AkaBirthNcp1Date_TEXT                  CHAR(8),
          @Lc_DmvlCur_AkaBirthNcp2Date_TEXT                  CHAR(8),
          @Lc_DmvlCur_AkaBirthNcp3Date_TEXT                  CHAR(8),
          @Lc_DmvlCur_MatchLevelCode_TEXT                    CHAR(1),
          @Lc_DmvlCur_NcpSuspLicEffDate_TEXT                 CHAR(8),
          @Lc_DmvlCur_NcpLicLiftEffDate_TEXT                 CHAR(8),
          @Lc_DmvlCur_NcpDeceased_TEXT                       CHAR(13),
          @Lc_DmvlCur_MailingAddressNormalizationCode_TEXT   CHAR(1) = 'N',
          @Ls_DmvlCur_MailingLine1NcpAddr_TEXT               VARCHAR(50),
          @Ls_DmvlCur_MailingLine2NcpAddr_TEXT               VARCHAR(50),
          @Lc_DmvlCur_MailingCityNcpAddr_TEXT                CHAR(28),
          @Lc_DmvlCur_MailingStateNcpAddr_TEXT               CHAR(2),
          @Lc_DmvlCur_MailingZipNcpAddr_TEXT                 CHAR(15),
          @Lc_DmvlCur_ResidenceAddressNormalizationCode_TEXT CHAR(1) = 'N',
          @Ls_DmvlCur_ResidenceLine1NcpAddr_TEXT             VARCHAR(50),
          @Ls_DmvlCur_ResidenceLine2NcpAddr_TEXT             VARCHAR(50),
          @Lc_DmvlCur_ResidenceCityNcpAddr_TEXT              CHAR(28),
          @Lc_DmvlCur_ResidenceStateNcpAddr_TEXT             CHAR(2),
          @Lc_DmvlCur_ResidenceZipNcpAddr_TEXT               CHAR(15),
          @Lc_DmvlCur_Process_INDC                           CHAR(1),
          @Ld_DmvlCur_FileLoad_DATE                          DATE,
          @Ln_CaseMemberCur_Case_IDNO                        NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO                   NUMERIC(10),
          @Ln_OrderCaseCur_Case_IDNO                         NUMERIC(6),
          @Ln_OrderCaseCur_OrderSeq_NUMB                     NUMERIC(5, 2);
  DECLARE @Ln_DmvlCur_NcpSsn_NUMB       NUMERIC(9),
          @Ln_DmvlCur_NcpMemberMci_IDNO NUMERIC(10);
  DECLARE Dmvl_CUR INSENSITIVE CURSOR FOR
   SELECT A.Seq_IDNO,
          A.Rec_ID,
          A.LastNcp_NAME,
          A.FirstNcp_NAME,
          A.MiddleNcp_NAME,
          A.BirthNcp_DATE,
          A.NcpDriversLicenseNo_TEXT,
          A.NcpSsn_NUMB,
          A.NcpSex_CODE,
          A.NcpMemberMci_IDNO,
          A.Source_CODE,
          A.Action_CODE,
          A.Ncp_NAME,
          A.SuffixNcp_NAME,
          A.DmvBirthNcp_DATE,
          A.NcpDmvDriversLicenseNo_TEXT,
          A.NcpDriversLicenseType_CODE,
          A.NcpDmvSsn_NUMB,
          A.NcpDmvSex_CODE,
          A.NcpAka_INDC,
          A.AkaNcp1_NAME,
          A.SuffixAkaNcp1_NAME,
          A.AkaNcp2_NAME,
          A.SuffixAkaNcp2_NAME,
          A.AkaNcp3_NAME,
          A.SuffixAkaNcp3_NAME,
          A.AkaNcpSsn1_NUMB,
          A.AkaNcpSsn2_NUMB,
          A.AkaNcpSsn3_NUMB,
          A.AkaBirthNcp1_DATE,
          A.AkaBirthNcp2_DATE,
          A.AkaBirthNcp3_DATE,
          A.MatchLevel_CODE,
          A.NcpSuspLicEff_DATE,
          A.NcpLicLiftEff_DATE,
          A.NcpDeceased_TEXT,
          A.MailingAddressNormalization_CODE,
          A.MailingLine1Ncp_ADDR,
          A.MailingLine2Ncp_ADDR,
          A.MailingCityNcp_ADDR,
          A.MailingStateNcp_ADDR,
          A.MailingZipNcp_ADDR,
          A.ResidenceAddressNormalization_CODE,
          A.ResidenceLine1Ncp_ADDR,
          A.ResidenceLine2Ncp_ADDR,
          A.ResidenceCityNcp_ADDR,
          A.ResidenceStateNcp_ADDR,
          A.ResidenceZipNcp_ADDR,
          A.Process_INDC,
          A.FileLoad_DATE
     FROM LDMVL_Y1 A
    WHERE A.Process_INDC = @Lc_ProcessN_INDC
    ORDER BY A.Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_DMV';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_PROCESS_DMV;

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

   SET @Ls_Sql_TEXT = 'OPEN Dmvl_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN Dmvl_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Dmvl_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM Dmvl_CUR INTO @Ln_DmvlCur_Seq_IDNO, @Lc_DmvlCur_RecId_TEXT, @Lc_DmvlCur_LastNcpName_TEXT, @Lc_DmvlCur_FirstNcpName_TEXT, @Lc_DmvlCur_MiddleNcpName_TEXT, @Lc_DmvlCur_BirthNcpDate_TEXT, @Lc_DmvlCur_NcpDriversLicenseNo_TEXT, @Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_DmvlCur_NcpSexCode_TEXT, @Lc_DmvlCur_NcpMemberMciIdno_TEXT, @Lc_DmvlCur_SourceCode_TEXT, @Lc_DmvlCur_ActionCode_TEXT, @Lc_DmvlCur_NcpName_TEXT, @Lc_DmvlCur_SuffixNcpName_TEXT, @Lc_DmvlCur_DmvBirthNcpDate_TEXT, @Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT, @Lc_DmvlCur_NcpDriversLicenseTypeCode_TEXT, @Lc_DmvlCur_NcpDmvSsnNumb_TEXT, @Lc_DmvlCur_NcpDmvSexCode_TEXT, @Lc_DmvlCur_NcpAkaIndc_TEXT, @Lc_DmvlCur_AkaNcp1Name_TEXT, @Lc_DmvlCur_SuffixAkaNcp1Name_TEXT, @Lc_DmvlCur_AkaNcp2Name_TEXT, @Lc_DmvlCur_SuffixAkaNcp2Name_TEXT, @Lc_DmvlCur_AkaNcp3Name_TEXT, @Lc_DmvlCur_SuffixAkaNcp3Name_TEXT, @Lc_DmvlCur_AkaNcpSsn1Numb_TEXT, @Lc_DmvlCur_AkaNcpSsn2Numb_TEXT, @Lc_DmvlCur_AkaNcpSsn3Numb_TEXT, @Lc_DmvlCur_AkaBirthNcp1Date_TEXT, @Lc_DmvlCur_AkaBirthNcp2Date_TEXT, @Lc_DmvlCur_AkaBirthNcp3Date_TEXT, @Lc_DmvlCur_MatchLevelCode_TEXT, @Lc_DmvlCur_NcpSuspLicEffDate_TEXT, @Lc_DmvlCur_NcpLicLiftEffDate_TEXT, @Lc_DmvlCur_NcpDeceased_TEXT, @Lc_DmvlCur_MailingAddressNormalizationCode_TEXT, @Ls_DmvlCur_MailingLine1NcpAddr_TEXT, @Ls_DmvlCur_MailingLine2NcpAddr_TEXT, @Lc_DmvlCur_MailingCityNcpAddr_TEXT, @Lc_DmvlCur_MailingStateNcpAddr_TEXT, @Lc_DmvlCur_MailingZipNcpAddr_TEXT, @Lc_DmvlCur_ResidenceAddressNormalizationCode_TEXT, @Ls_DmvlCur_ResidenceLine1NcpAddr_TEXT, @Ls_DmvlCur_ResidenceLine2NcpAddr_TEXT, @Lc_DmvlCur_ResidenceCityNcpAddr_TEXT, @Lc_DmvlCur_ResidenceStateNcpAddr_TEXT, @Lc_DmvlCur_ResidenceZipNcpAddr_TEXT, @Lc_DmvlCur_Process_INDC, @Ld_DmvlCur_FileLoad_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Dmvl_CUR';
   SET @Ls_SqlData_TEXT = '';

   --Process the Court Address data received from FAMIS and make the appropriate updates in DECSS
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_DMV;

      SET @Lc_LicenseStatus_CODE = 'A';
      SET @Lc_LicenseUpdated_INDC = @Lc_No_INDC;
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'Dmvl - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_DmvlCur_Seq_IDNO AS VARCHAR) + ', Rec_ID = ' + @Lc_DmvlCur_RecId_TEXT + ', LastNcp_NAME = ' + @Lc_DmvlCur_LastNcpName_TEXT + ', FirstNcp_NAME = ' + @Lc_DmvlCur_FirstNcpName_TEXT + ', MiddleNcp_NAME = ' + @Lc_DmvlCur_MiddleNcpName_TEXT + ', BirthNcp_DATE = ' + @Lc_DmvlCur_BirthNcpDate_TEXT + ', NcpDriversLicenseNo_TEXT = ' + @Lc_DmvlCur_NcpDriversLicenseNo_TEXT + ', NcpSsn_NUMB = ' + @Lc_DmvlCur_NcpSsnNumb_TEXT + ', NcpSex_CODE = ' + @Lc_DmvlCur_NcpSexCode_TEXT + ', NcpMemberMci_IDNO = ' + @Lc_DmvlCur_NcpMemberMciIdno_TEXT + ', Source_CODE = ' + @Lc_DmvlCur_SourceCode_TEXT + ', Action_CODE = ' + @Lc_DmvlCur_ActionCode_TEXT + ', Ncp_NAME = ' + @Lc_DmvlCur_NcpName_TEXT + ', SuffixNcp_NAME = ' + @Lc_DmvlCur_SuffixNcpName_TEXT + ', DmvBirthNcp_DATE = ' + @Lc_DmvlCur_DmvBirthNcpDate_TEXT + ', NcpDmvDriversLicenseNo_TEXT = ' + @Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT + ', NcpDriversLicenseType_CODE = ' + @Lc_DmvlCur_NcpDriversLicenseTypeCode_TEXT + ', NcpDmvSsn_NUMB = ' + @Lc_DmvlCur_NcpDmvSsnNumb_TEXT + ', NcpDmvSex_CODE = ' + @Lc_DmvlCur_NcpDmvSexCode_TEXT + ', NcpAka_INDC = ' + @Lc_DmvlCur_NcpAkaIndc_TEXT + ', AkaNcp1_NAME = ' + @Lc_DmvlCur_AkaNcp1Name_TEXT + ', SuffixAkaNcp1_NAME = ' + @Lc_DmvlCur_SuffixAkaNcp1Name_TEXT + ', AkaNcp2_NAME = ' + @Lc_DmvlCur_AkaNcp2Name_TEXT + ', SuffixAkaNcp2_NAME = ' + @Lc_DmvlCur_SuffixAkaNcp2Name_TEXT + ', AkaNcp3_NAME = ' + @Lc_DmvlCur_AkaNcp3Name_TEXT + ', SuffixAkaNcp3_NAME = ' + @Lc_DmvlCur_SuffixAkaNcp3Name_TEXT + ', AkaNcpSsn1_NUMB = ' + @Lc_DmvlCur_AkaNcpSsn1Numb_TEXT + ', AkaNcpSsn2_NUMB = ' + @Lc_DmvlCur_AkaNcpSsn2Numb_TEXT + ', AkaNcpSsn3_NUMB = ' + @Lc_DmvlCur_AkaNcpSsn3Numb_TEXT + ', AkaBirthNcp1_DATE = ' + @Lc_DmvlCur_AkaBirthNcp1Date_TEXT + ', AkaBirthNcp2_DATE = ' + @Lc_DmvlCur_AkaBirthNcp2Date_TEXT + ', AkaBirthNcp3_DATE = ' + @Lc_DmvlCur_AkaBirthNcp3Date_TEXT + ', MatchLevel_CODE = ' + @Lc_DmvlCur_MatchLevelCode_TEXT + ', NcpSuspLicEff_DATE = ' + @Lc_DmvlCur_NcpSuspLicEffDate_TEXT + ', NcpLicLiftEff_DATE = ' + @Lc_DmvlCur_NcpLicLiftEffDate_TEXT + ', NcpDeceased_TEXT = ' + @Lc_DmvlCur_NcpDeceased_TEXT + ', MailingAddressNormalization_CODE = ' + @Lc_DmvlCur_MailingAddressNormalizationCode_TEXT + ', MailingLine1Ncp_ADDR = ' + @Ls_DmvlCur_MailingLine1NcpAddr_TEXT + ', MailingLine2Ncp_ADDR = ' + @Ls_DmvlCur_MailingLine2NcpAddr_TEXT + ', MailingCityNcp_ADDR = ' + @Lc_DmvlCur_MailingCityNcpAddr_TEXT + ', MailingStateNcp_ADDR = ' + @Lc_DmvlCur_MailingStateNcpAddr_TEXT + ', MailingZipNcp_ADDR = ' + @Lc_DmvlCur_MailingZipNcpAddr_TEXT + ', ResidenceAddressNormalization_CODE = ' + @Lc_DmvlCur_ResidenceAddressNormalizationCode_TEXT + ', ResidenceLine1Ncp_ADDR = ' + @Ls_DmvlCur_ResidenceLine1NcpAddr_TEXT + ', ResidenceLine2Ncp_ADDR = ' + @Ls_DmvlCur_ResidenceLine2NcpAddr_TEXT + ', ResidenceCityNcp_ADDR = ' + @Lc_DmvlCur_ResidenceCityNcpAddr_TEXT + ', ResidenceStateNcp_ADDR = ' + @Lc_DmvlCur_ResidenceStateNcpAddr_TEXT + ', ResidenceZipNcp_ADDR = ' + @Lc_DmvlCur_ResidenceZipNcpAddr_TEXT + ', Process_INDC = ' + @Lc_DmvlCur_Process_INDC + ', FileLoad_DATE = ' + CAST(@Ld_DmvlCur_FileLoad_DATE AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK DACSES-ACTION-CODE AND DMV-MATCH-LEVEL';
      SET @Ls_SqlData_TEXT = 'Action_CODE = ' + @Lc_DmvlCur_ActionCode_TEXT + ', MatchLevel_CODE = ' + @Lc_DmvlCur_MatchLevelCode_TEXT;

      IF (@Lc_DmvlCur_ActionCode_TEXT NOT IN (@Lc_ActionM_CODE, @Lc_ActionS_CODE, @Lc_ActionL_CODE)
           --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -START-
           OR @Lc_DmvlCur_MatchLevelCode_TEXT NOT IN ('1', '2', '5')
           --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -END-
           OR (@Lc_DmvlCur_ActionCode_TEXT = @Lc_ActionM_CODE
               --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -START-
               AND 
				(
					@Lc_DmvlCur_MatchLevelCode_TEXT NOT IN ('2', '5')
					OR 
					(
						@Lc_DmvlCur_MatchLevelCode_TEXT = '5'
						AND LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT, @Lc_Empty_TEXT)))) = 0
					)
				)
			)
               --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -END-
           OR (@Lc_DmvlCur_ActionCode_TEXT = @Lc_ActionS_CODE
               AND @Lc_DmvlCur_MatchLevelCode_TEXT != '1')
           OR (@Lc_DmvlCur_ActionCode_TEXT = @Lc_ActionL_CODE
               AND @Lc_DmvlCur_MatchLevelCode_TEXT != '1'))
       BEGIN
        GOTO SKIP_RECORD;
       END

      SET @Ls_Sql_TEXT = 'CHECK INPUT MEMBER MCI #';
      SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + @Lc_DmvlCur_NcpMemberMciIdno_TEXT;

      IF LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpMemberMciIdno_TEXT, @Lc_Empty_TEXT)))) = 0
          OR ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpMemberMciIdno_TEXT, @Lc_Empty_TEXT)))) = 0
          OR CAST(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpMemberMciIdno_TEXT, @Lc_Empty_TEXT))) AS NUMERIC) = 0
       BEGIN
        SET @Ln_DmvlCur_NcpMemberMci_IDNO = 0;
        SET @Ls_Sql_TEXT = 'GET MCI # FROM DEMO USING LAST NAME AND SSN';
        SET @Ls_SqlData_TEXT = 'LastNcp_NAME = ' + @Lc_DmvlCur_LastNcpName_TEXT + ', NcpSsn_NUMB = ' + @Lc_DmvlCur_NcpSsnNumb_TEXT;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_LastNcpName_TEXT, @Lc_Empty_TEXT)))) > 0
           AND LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_Empty_TEXT)))) > 0
           AND ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_Empty_TEXT)))) > 0
           AND CAST(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_Empty_TEXT))) AS NUMERIC) > 0
         BEGIN
          SELECT @Ln_DmvlCur_NcpMemberMci_IDNO = ISNULL((SELECT TOP 1 ISNULL((CASE
                                                                               WHEN LEN(LTRIM(RTRIM(ISNULL(X.MemberMci_IDNO, '')))) = 0
                                                                                THEN 0
                                                                               ELSE X.MemberMci_IDNO
                                                                              END), 0)
                                                           FROM DEMO_Y1 X
                                                          WHERE UPPER(LTRIM(RTRIM(ISNULL(X.Last_NAME, '')))) = UPPER(LTRIM(RTRIM(@Lc_DmvlCur_LastNcpName_TEXT)))
                                                            AND X.MemberSsn_NUMB = CAST(LTRIM(RTRIM(@Lc_DmvlCur_NcpSsnNumb_TEXT)) AS NUMERIC)), 0);
         END;

        IF @Ln_DmvlCur_NcpMemberMci_IDNO = 0
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0958_CODE,
                 @Ls_ErrorMessage_TEXT = 'KEY DATA NOT FOUND';

          RAISERROR(50001,16,1);
         END;
       END;
      ELSE
       BEGIN
        SET @Ln_DmvlCur_NcpMemberMci_IDNO = LTRIM(RTRIM(@Lc_DmvlCur_NcpMemberMciIdno_TEXT));
       END;

      --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -START-
      IF @Lc_DmvlCur_ActionCode_TEXT = @Lc_ActionM_CODE
         AND @Lc_DmvlCur_MatchLevelCode_TEXT = '5'
       BEGIN	         
			SET @Ls_Sql_TEXT = 'CHECK THE EXISTENCE OF THE NCP IN PLIC - M/5';
			SET @Ls_SqlData_TEXT = 'LicenseNo_TEXT = ' + ISNULL(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenseDr_CODE, '');

			IF EXISTS (SELECT 1
					   FROM PLIC_Y1 X
					  WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
						AND 1 = (SELECT CASE
										 WHEN ISNUMERIC(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT) = 0
										  THEN
										  CASE
										   WHEN UPPER(LTRIM(RTRIM(ISNULL(X.LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT)))
											THEN 1
										   ELSE 0
										  END
										 WHEN ISNUMERIC(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT) > 0
										  THEN
										  CASE
										   WHEN ISNUMERIC(ISNULL(X.LicenseNo_TEXT, '')) > 0
											THEN
											CASE
											 WHEN CAST(ISNULL(X.LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT AS NUMERIC)
											  THEN 1
											 ELSE 0
											END
										   ELSE 0
										  END
										 ELSE 0
										END)
						AND LTRIM(RTRIM(ISNULL(X.TypeLicense_CODE, @Lc_Empty_TEXT))) = @Lc_TypeLicenseDr_CODE
						AND X.EndValidity_DATE = @Ld_High_DATE)
			BEGIN
				SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - M/5';
				SET @Ls_SqlData_TEXT = 'Process_ID = ' + @Lc_Job_ID;

				EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
				@Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
				@Ac_Process_ID               = @Lc_Job_ID,
				@Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
				@Ac_Note_INDC                = @Lc_Note_INDC,
				@An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
				@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
				@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				BEGIN
				 SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

				 RAISERROR(50001,16,1);
				END;
	                  
				SET @Ls_Sql_TEXT = 'UPDATE PLIC - M/5';
				SET @Ls_SqlData_TEXT = 'LicenseNo_TEXT = ' + ISNULL(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenseDr_CODE, '');

				UPDATE PLIC_Y1
				  SET Status_CODE = @Lc_StatusCb_CODE,
					  Status_DATE = @Ld_Run_DATE,
					  SourceVerified_CODE = @Lc_SourceVerifiedDmv_CODE,
					  WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
					  BeginValidity_DATE = @Ld_Run_DATE,
					  Update_DTTM = @Ld_Start_DATE,
					  TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
				OUTPUT DELETED.MemberMci_IDNO,
					  DELETED.TypeLicense_CODE,
					  DELETED.LicenseNo_TEXT,
					  DELETED.IssuingState_CODE,
					  DELETED.LicenseStatus_CODE,
					  DELETED.OthpLicAgent_IDNO,
					  DELETED.IssueLicense_DATE,
					  DELETED.ExpireLicense_DATE,
					  DELETED.SuspLicense_DATE,
					  DELETED.Status_CODE,
					  DELETED.Status_DATE,
					  DELETED.SourceVerified_CODE,
					  DELETED.BeginValidity_DATE,
					  @Ld_Run_DATE AS EndValidity_DATE,
					  DELETED.WorkerUpdate_ID,
					  DELETED.Update_DTTM,
					  DELETED.TransactionEventSeq_NUMB,
					  DELETED.Profession_CODE,
					  DELETED.Business_NAME,
					  DELETED.Trade_NAME
				INTO PLIC_Y1
				WHERE 1 = (SELECT CASE
								   WHEN ISNUMERIC(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT) = 0
									THEN
									CASE
									 WHEN UPPER(LTRIM(RTRIM(ISNULL(LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT)))
									  THEN 1
									 ELSE 0
									END
								   WHEN ISNUMERIC(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT) > 0
									THEN
									CASE
									 WHEN ISNUMERIC(ISNULL(LicenseNo_TEXT, '')) > 0
									  THEN
									  CASE
									   WHEN CAST(ISNULL(LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Lc_DmvlCur_NcpDriversLicenseNo_TEXT AS NUMERIC)
										THEN 1
									   ELSE 0
									  END
									 ELSE 0
									END
								   ELSE 0
								  END)
				  AND MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
				  AND LTRIM(RTRIM(ISNULL(TypeLicense_CODE, @Lc_Empty_TEXT))) = @Lc_TypeLicenseDr_CODE
				  AND EndValidity_DATE = @Ld_High_DATE;

				SET @Li_RowCount_QNTY = @@ROWCOUNT;

				IF @Li_RowCount_QNTY = 0
				BEGIN
					SET @Ls_ErrorMessage_TEXT = 'UPDATE PLIC - M/5 FAILED!';

					RAISERROR(50001,16,1);
				END      
			END
			ELSE
			BEGIN
				SELECT @Lc_BateError_CODE = @Lc_BateErrorE1479_CODE,
					 @Ls_ErrorMessage_TEXT = 'DRIVERS LICENSE NOT FOUND FOR MEMBER - M/5';

				RAISERROR(50001,16,1);
			END;			
			GOTO SKIP_RECORD;
       END;
      --13649 - If Incoming Action Code is M and Match Level Code is 5 then Update the status in PLIC to Confirmed Bad. -END-

      SET @Ls_Sql_TEXT = 'CHECK MEMBER IN CMEM';
      SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR);

      IF NOT EXISTS (SELECT 1
                       FROM CMEM_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                        AND X.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                        AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                        AND (EXISTS (SELECT 1
                                       FROM CASE_Y1 Y
                                      WHERE Y.Case_IDNO = X.Case_IDNO
                                        AND Y.StatusCase_CODE = @Lc_StatusCaseO_CODE)
                              OR EXISTS (SELECT 1
                                           FROM CASE_Y1 Y
                                          WHERE Y.Case_IDNO = X.Case_IDNO
                                            AND Y.StatusCase_CODE = @Lc_StatusCaseC_CODE
                                            AND Y.RsnStatusCase_CODE = @Lc_RsnStatusCaseUb_CODE)))
       BEGIN
        SELECT @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE,
               @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND';

        RAISERROR(50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'CHECK INPUT MEMBER SSN';
      SET @Ls_SqlData_TEXT = 'NcpSsn_NUMB = ' + @Lc_DmvlCur_NcpSsnNumb_TEXT;

      IF LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_Empty_TEXT)))) = 0
          OR ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_Empty_TEXT)))) = 0
          OR CAST(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_Empty_TEXT))) AS NUMERIC) = 0
       BEGIN
        SELECT @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE,
               @Ls_ErrorMessage_TEXT = 'INVALID VALUE';

        RAISERROR(50001,16,1);
       END;
      ELSE
       BEGIN
        SET @Ln_DmvlCur_NcpSsn_NUMB = LTRIM(RTRIM(@Lc_DmvlCur_NcpSsnNumb_TEXT));
       END;

      SET @Ls_Sql_TEXT = 'CHECK MEMBER SSN IN MSSN';
      SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', NcpSsn_NUMB = ' + CAST(@Ln_DmvlCur_NcpSsn_NUMB AS VARCHAR);

      IF NOT EXISTS (SELECT 1
                       FROM MSSN_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                        AND X.MemberSsn_NUMB = @Ln_DmvlCur_NcpSsn_NUMB
                        AND X.EndValidity_DATE = @Ld_High_DATE
                        AND ((X.Enumeration_CODE IN (@Lc_EnumerationY_CODE, @Lc_EnumerationP_CODE)
                              AND X.TypePrimary_CODE = @Lc_TypePrimaryP_CODE)
                              OR (X.Enumeration_CODE = @Lc_EnumerationY_CODE
                                  AND X.TypePrimary_CODE = @Lc_TypePrimaryI_CODE)))
       BEGIN
        SELECT @Lc_BateError_CODE = @Lc_BateErrorE0881_CODE,
               @Ls_ErrorMessage_TEXT = 'SSN IS NOT MATCHED';

        RAISERROR(50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'CHECK INPUT NCP DMV DRIVERS LICENSE #';
      SET @Ls_SqlData_TEXT = 'LicenseNo_TEXT = ' + @Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT;

      IF LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT, @Lc_Empty_TEXT)))) = 0
       BEGIN
        SELECT @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE,
               @Ls_ErrorMessage_TEXT = 'INVALID VALUE';

        RAISERROR(50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'CHECK INPUT NCP DMV LICENSE SUSPENSION EFFECTIVE DATE';
      SET @Ls_SqlData_TEXT = 'NcpSuspLicEffDate_TEXT = ' + @Lc_DmvlCur_NcpSuspLicEffDate_TEXT;
      SET @Ld_SuspLicense_DATE = NULL;

      IF ISDATE(@Lc_DmvlCur_NcpSuspLicEffDate_TEXT) > 0
       BEGIN
        IF CAST(@Lc_DmvlCur_NcpSuspLicEffDate_TEXT AS DATE) IN ('01/01/1900', '12/31/9999')
         BEGIN
          SET @Ld_SuspLicense_DATE = @Ld_Run_DATE
         END
        ELSE
         BEGIN
          SET @Ld_SuspLicense_DATE = CAST(@Lc_DmvlCur_NcpSuspLicEffDate_TEXT AS DATE)
         END
       END;

      SET @Ls_Sql_TEXT = 'CHECK IF DACSES-ACTION-CODE EQUALS ''M'' AND DMV-MATCH-LEVEL EQUALS ''2''';
      SET @Ls_SqlData_TEXT = 'Action_CODE = ' + @Lc_DmvlCur_ActionCode_TEXT + ', MatchLevel_CODE = ' + @Lc_DmvlCur_MatchLevelCode_TEXT;

      IF @Lc_DmvlCur_ActionCode_TEXT = @Lc_ActionM_CODE
         AND @Lc_DmvlCur_MatchLevelCode_TEXT = '2'
       BEGIN
        SET @Ls_Sql_TEXT = 'CHECK THE EXISTENCE OF THE NCP IN THE SYSTEM - M/2';
        SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', NcpSsn_NUMB = ' + CAST(@Ln_DmvlCur_NcpSsn_NUMB AS VARCHAR) + ', LastNcp_NAME = ' + @Lc_DmvlCur_LastNcpName_TEXT;

        IF NOT EXISTS (SELECT 1
                         FROM DEMO_Y1 X
                        WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                          AND X.MemberSsn_NUMB = @Ln_DmvlCur_NcpSsn_NUMB
                          AND LTRIM(RTRIM(SUBSTRING(ISNULL(X.Last_NAME, REPLICATE(@Lc_Space_TEXT, 20)), 1, 5))) = LTRIM(RTRIM(SUBSTRING(@Lc_DmvlCur_LastNcpName_TEXT, 1, 5))))
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE,
                 @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND - M/2';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - M/2';
          SET @Ls_SqlData_TEXT = 'Process_ID = ' + @Lc_Job_ID;

          EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_Note_INDC,
           @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_LICENSE_UPDATE - DRIVING LICENSE - M/2';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenseDr_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', LicenseStatus_CODE = ' + ISNULL(@Lc_LicenseStatusA_CODE, '') + ', IssuingState_CODE = ' + ISNULL(@Lc_IssuingStateDe_CODE, '') + ', IssueLicense_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ExpireLicense_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', SuspLicense_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OthpLicAgent_IDNO AS VARCHAR), '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedDmv_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_COMMON$SP_LICENSE_UPDATE
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ac_LicenseNo_TEXT           = @Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT,
           @An_MemberMci_IDNO           = @Ln_DmvlCur_NcpMemberMci_IDNO,
           @Ac_TypeLicense_CODE         = @Lc_TypeLicenseDr_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_LicenseStatus_CODE       = @Lc_LicenseStatusA_CODE,
           @Ac_IssuingState_CODE        = @Lc_IssuingStateDe_CODE,
           @Ad_IssueLicense_DATE        = @Ld_Run_DATE,
           @Ad_ExpireLicense_DATE       = @Ld_High_DATE,
           @Ad_SuspLicense_DATE         = @Ld_SuspLicense_DATE,
           @An_OtherParty_IDNO          = @Ln_OthpLicAgent_IDNO,
           @Ac_SourceVerified_CODE      = @Lc_SourceVerifiedDmv_CODE,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;

          IF EXISTS (SELECT 1
                       FROM PLIC_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                        AND 1 = (SELECT CASE
                                         WHEN ISNUMERIC(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT) = 0
                                          THEN
                                          CASE
                                           WHEN UPPER(LTRIM(RTRIM(ISNULL(X.LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT)))
                                            THEN 1
                                           ELSE 0
                                          END
                                         WHEN ISNUMERIC(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT) > 0
                                          THEN
                                          CASE
                                           WHEN ISNUMERIC(ISNULL(X.LicenseNo_TEXT, '')) > 0
                                            THEN
                                            CASE
                                             WHEN CAST(ISNULL(X.LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT AS NUMERIC)
                                              THEN 1
                                             ELSE 0
                                            END
                                           ELSE 0
                                          END
                                         ELSE 0
                                        END)
                        AND LTRIM(RTRIM(ISNULL(X.TypeLicense_CODE, @Lc_Empty_TEXT))) = @Lc_TypeLicenseDr_CODE
                        AND X.BeginValidity_DATE = @Ld_Run_DATE
                        AND X.EndValidity_DATE = @Ld_High_DATE)
           BEGIN
            SET @Lc_LicenseUpdated_INDC = @Lc_Yes_INDC;
           END;

          IF @Lc_LicenseUpdated_INDC = @Lc_Yes_INDC
           BEGIN
            DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
             SELECT A.Case_IDNO,
                    A.MemberMci_IDNO
               FROM CMEM_Y1 A,
                    CASE_Y1 B
              WHERE A.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
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

            --Make a Case Journal Entry for each case of the member...          
            WHILE @Li_FetchStatus_QNTY = 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - M/2';
              SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR) + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorRrdmv_CODE;

              EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
               @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
               @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
               @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
               @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRrdmv_CODE,
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

                RAISERROR (50001,16,1);
               END
              ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
               BEGIN
                SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
                SET @Lc_BateError_CODE = @Lc_Msg_CODE;

                RAISERROR (50001,16,1);
               END

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

          SET @Ls_Sql_TEXT = 'CHECK NCP ALIAS INDICATOR';
          SET @Ls_SqlData_TEXT = 'NcpAka_INDC = ' + @Lc_DmvlCur_NcpAkaIndc_TEXT;

          IF LTRIM(RTRIM(@Lc_DmvlCur_NcpAkaIndc_TEXT)) = @Lc_Yes_INDC
           BEGIN
            SET @Ls_Sql_TEXT = 'DERIVING LAST NAME, FIRST NAME AND MIDDLE NAME FROM ALIAS NAME';
            SET @Ls_SqlData_TEXT = 'AkaNcp1_NAME = ' + @Lc_DmvlCur_AkaNcp1Name_TEXT + ', AkaNcp2_NAME = ' + @Lc_DmvlCur_AkaNcp2Name_TEXT + ', AkaNcp3_NAME = ' + @Lc_DmvlCur_AkaNcp3Name_TEXT;
            SET @Li_AliasNameCount_QNTY = 1;

            --Deriving Last Name, First Name and Middle Name from Alias Name...
            WHILE @Li_AliasNameCount_QNTY < 4
             BEGIN
              SELECT @Lc_AkaNcp_NAME = CASE @Li_AliasNameCount_QNTY
                                        WHEN 1
                                         THEN LTRIM(RTRIM(@Lc_DmvlCur_AkaNcp1Name_TEXT))
                                        WHEN 2
                                         THEN LTRIM(RTRIM(@Lc_DmvlCur_AkaNcp2Name_TEXT))
                                        WHEN 3
                                         THEN LTRIM(RTRIM(@Lc_DmvlCur_AkaNcp3Name_TEXT))
                                       END,
                     @Li_SpaceFoundPosition_NUMB = 0,
                     @Li_NameLength_NUMB = 0,
                     @Lc_AkaNcpLast_NAME = REPLICATE(@Lc_Space_TEXT, 20),
                     @Lc_AkaNcpFirst_NAME = REPLICATE(@Lc_Space_TEXT, 16),
                     @Lc_AkaNcpMiddle_NAME = REPLICATE(@Lc_Space_TEXT, 20),
                     @Lc_AkaNcpSuffix_NAME = CASE @Li_AliasNameCount_QNTY
                                              WHEN 1
                                               THEN LTRIM(RTRIM(@Lc_DmvlCur_SuffixAkaNcp1Name_TEXT))
                                              WHEN 2
                                               THEN LTRIM(RTRIM(@Lc_DmvlCur_SuffixAkaNcp2Name_TEXT))
                                              WHEN 3
                                               THEN LTRIM(RTRIM(@Lc_DmvlCur_SuffixAkaNcp3Name_TEXT))
                                             END;

              IF LEN(LTRIM(RTRIM(@Lc_AkaNcp_NAME))) > 0
               BEGIN
                SET @Li_SpaceFoundPosition_NUMB = CHARINDEX(@Lc_Space_TEXT, LTRIM(RTRIM(@Lc_AkaNcp_NAME)));

                IF @Li_SpaceFoundPosition_NUMB > 0
                 BEGIN
                  SET @Lc_AkaNcpLast_NAME = LEFT(LTRIM(RTRIM(@Lc_AkaNcp_NAME)), (@Li_SpaceFoundPosition_NUMB - 1));
                  SET @Li_NameLength_NUMB = LEN(@Lc_AkaNcp_NAME) - @Li_SpaceFoundPosition_NUMB;
                  SET @Lc_AkaNcp_NAME = SUBSTRING(@Lc_AkaNcp_NAME, (@Li_SpaceFoundPosition_NUMB + 1), @Li_NameLength_NUMB);
                  SET @Li_SpaceFoundPosition_NUMB = CHARINDEX(@Lc_Space_TEXT, LTRIM(RTRIM(@Lc_AkaNcp_NAME)));

                  IF @Li_SpaceFoundPosition_NUMB > 0
                   BEGIN
                    SET @Lc_AkaNcpFirst_NAME = LEFT(LTRIM(RTRIM(@Lc_AkaNcp_NAME)), (@Li_SpaceFoundPosition_NUMB - 1));
                    SET @Li_NameLength_NUMB = LEN(@Lc_AkaNcp_NAME) - @Li_SpaceFoundPosition_NUMB;
                    SET @Lc_AkaNcp_NAME = SUBSTRING(@Lc_AkaNcp_NAME, (@Li_SpaceFoundPosition_NUMB + 1), @Li_NameLength_NUMB);
                    SET @Li_SpaceFoundPosition_NUMB = CHARINDEX(@Lc_Space_TEXT, LTRIM(RTRIM(@Lc_AkaNcp_NAME)));

                    IF @Li_SpaceFoundPosition_NUMB > 0
                     BEGIN
                      SET @Lc_AkaNcpMiddle_NAME = LEFT(LTRIM(RTRIM(@Lc_AkaNcp_NAME)), (@Li_SpaceFoundPosition_NUMB - 1));
                     END;
                    ELSE
                     BEGIN
                      SET @Lc_AkaNcpMiddle_NAME = LTRIM(RTRIM(@Lc_AkaNcp_NAME));
                     END;
                   END;
                  ELSE
                   BEGIN
                    SET @Lc_AkaNcpFirst_NAME = LTRIM(RTRIM(@Lc_AkaNcp_NAME));
                   END;
                 END;
                ELSE
                 BEGIN
                  SET @Lc_AkaNcpFirst_NAME = LTRIM(RTRIM(@Lc_AkaNcp_NAME));
                 END;

                SET @Ls_Sql_TEXT = 'CHECK INPUT ALIAS NAME FOR THE MEMBER IN AKAX';
                SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', TypeAlias_CODE = ' + @Lc_TypeAliasA_CODE + ', AkaNcpLast_NAME = ' + @Lc_AkaNcpLast_NAME + ', AkaNcpFirst_NAME = ' + @Lc_AkaNcpFirst_NAME + ', AkaNcpMiddle_NAME = ' + @Lc_AkaNcpMiddle_NAME;

                IF NOT EXISTS (SELECT 1
                                 FROM AKAX_Y1 X
                                WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                                  AND X.TypeAlias_CODE = @Lc_TypeAliasA_CODE
                                  AND UPPER(LTRIM(RTRIM(ISNULL(X.LastAlias_NAME, @Lc_Empty_TEXT)))) = UPPER(LTRIM(RTRIM(@Lc_AkaNcpLast_NAME)))
                                  AND UPPER(LTRIM(RTRIM(ISNULL(X.FirstAlias_NAME, @Lc_Empty_TEXT)))) = UPPER(LTRIM(RTRIM(@Lc_AkaNcpFirst_NAME)))
                                  AND ((UPPER(LTRIM(RTRIM(ISNULL(X.MiddleAlias_NAME, @Lc_Empty_TEXT)))) = UPPER (LTRIM(RTRIM(@Lc_AkaNcpMiddle_NAME))))
                                        OR (UPPER(LTRIM(RTRIM(SUBSTRING(ISNULL(X.MiddleAlias_NAME, REPLICATE(@Lc_Space_TEXT, 20)), 1, 1)))) = UPPER(LTRIM(RTRIM(SUBSTRING(@Lc_AkaNcpMiddle_NAME, 1, 1))))))
                                  AND X.EndValidity_DATE = @Ld_High_DATE)
                 BEGIN
                  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
                  SET @Ls_SqlData_TEXT = 'Process_ID = ' + @Lc_Job_ID;

                  EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
                   @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
                   @Ac_Process_ID               = @Lc_Job_ID,
                   @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
                   @Ac_Note_INDC                = @Lc_Note_INDC,
                   @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
                   @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
                   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
                   @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

                  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                   BEGIN
                    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

                    RAISERROR(50001,16,1);
                   END;

                  SET @Ls_Sql_TEXT = 'GET NEXT SEQUENCE # FOR THE MEMBER FROM AKAX';
                  SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', TypeAlias_CODE = ' + @Lc_TypeAliasA_CODE;

                  SELECT @Ln_Sequence_NUMB = (ISNULL(MAX(X.Sequence_NUMB), 0) + 1)
                    FROM AKAX_Y1 X
                   WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                     AND X.TypeAlias_CODE = @Lc_TypeAliasA_CODE
                     AND X.EndValidity_DATE = @Ld_High_DATE;

                  SET @Ls_Sql_TEXT = 'INSERT INTO AKAX';
                  SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', TypeAlias_CODE = ' + @Lc_TypeAliasA_CODE + ', AkaNcpLast_NAME = ' + @Lc_AkaNcpLast_NAME + ', AkaNcpFirst_NAME = ' + @Lc_AkaNcpFirst_NAME + ', AkaNcpMiddle_NAME = ' + @Lc_AkaNcpMiddle_NAME + ', AkaNcpSuffix_NAME = ' + @Lc_AkaNcpSuffix_NAME + ', Source_CODE = ' + @Lc_SourceDmv_CODE + ', Sequence_NUMB = ' + CAST(@Ln_Sequence_NUMB AS VARCHAR);

                  INSERT INTO AKAX_Y1
                              (MemberMci_IDNO,
                               TypeAlias_CODE,
                               LastAlias_NAME,
                               FirstAlias_NAME,
                               MiddleAlias_NAME,
                               TitleAlias_NAME,
                               MaidenAlias_NAME,
                               SuffixAlias_NAME,
                               Source_CODE,
                               BeginValidity_DATE,
                               EndValidity_DATE,
                               Update_DTTM,
                               WorkerUpdate_ID,
                               TransactionEventSeq_NUMB,
                               Sequence_NUMB)
                  SELECT @Ln_DmvlCur_NcpMemberMci_IDNO AS MemberMci_IDNO,
                         @Lc_TypeAliasA_CODE AS TypeAlias_CODE,
                         LTRIM(RTRIM(@Lc_AkaNcpLast_NAME)) AS LastAlias_NAME,
                         LTRIM(RTRIM(@Lc_AkaNcpFirst_NAME)) AS FirstAlias_NAME,
                         LTRIM(RTRIM(@Lc_AkaNcpMiddle_NAME)) AS MiddleAlias_NAME,
                         @Lc_Space_TEXT AS TitleAlias_NAME,
                         @Lc_Space_TEXT AS MaidenAlias_NAME,
                         LTRIM(RTRIM(@Lc_AkaNcpSuffix_NAME)) AS SuffixAlias_NAME,
                         SUBSTRING(@Lc_SourceDmv_CODE, 1, 2) AS Source_CODE,
                         @Ld_Run_DATE AS BeginValidity_DATE,
                         @Ld_High_DATE AS EndValidity_DATE,
                         @Ld_Start_DATE AS Update_DTTM,
                         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                         @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                         @Ln_Sequence_NUMB AS Sequence_NUMB;

                  SET @Li_RowCount_QNTY = @@ROWCOUNT;

                  IF @Li_RowCount_QNTY = 0
                   BEGIN
                    SET @Ls_ErrorMessage_TEXT = 'INSERT AKAX_Y1 FAILED';

                    RAISERROR(50001,16,1);
                   END;
                 END;
               END;

              SET @Li_AliasNameCount_QNTY = @Li_AliasNameCount_QNTY + 1;
             END;

            SET @Ls_Sql_TEXT = 'GET SSN TYPE FOR ALIAS SSN';
            SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', AkaNcpSsn1_NUMB = ' + @Lc_DmvlCur_AkaNcpSsn1Numb_TEXT + ', AkaNcpSsn2_NUMB = ' + @Lc_DmvlCur_AkaNcpSsn2Numb_TEXT + ', AkaNcpSsn3_NUMB = ' + @Lc_DmvlCur_AkaNcpSsn3Numb_TEXT;

            IF LEN(LTRIM(RTRIM(@Lc_DmvlCur_AkaNcpSsn1Numb_TEXT))) > 0
                OR LEN(LTRIM(RTRIM(@Lc_DmvlCur_AkaNcpSsn2Numb_TEXT))) > 0
                OR LEN(LTRIM(RTRIM(@Lc_DmvlCur_AkaNcpSsn3Numb_TEXT))) > 0
             BEGIN
              SET @Li_AliasSsnCount_QNTY = 1;

              --Get SSN Type for Alias SSN
              WHILE @Li_AliasSsnCount_QNTY < 4
               BEGIN
                SELECT @Lc_AkaNcpSsn_NUMB = CASE @Li_AliasSsnCount_QNTY
                                             WHEN 1
                                              THEN @Lc_DmvlCur_AkaNcpSsn1Numb_TEXT
                                             WHEN 2
                                              THEN @Lc_DmvlCur_AkaNcpSsn2Numb_TEXT
                                             WHEN 3
                                              THEN @Lc_DmvlCur_AkaNcpSsn3Numb_TEXT
                                            END,
                       @Lc_TypePrimary_CODE = CASE @Li_AliasSsnCount_QNTY
                                               WHEN 1
                                                THEN
                                                CASE
                                                 WHEN NOT EXISTS (SELECT 1
                                                                    FROM MSSN_Y1 X
                                                                   WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                                                                     AND X.TypePrimary_CODE = @Lc_TypePrimaryS_CODE
                                                                     AND X.EndValidity_DATE = @Ld_High_DATE)
                                                  THEN @Lc_TypePrimaryS_CODE
                                                 ELSE @Lc_TypePrimaryT_CODE
                                                END
                                               WHEN 2
                                                THEN @Lc_TypePrimaryS_CODE
                                               WHEN 3
                                                THEN @Lc_TypePrimaryT_CODE
                                              END;

                SET @Ls_Sql_TEXT = 'CHECK INPUT ALIAS SSN';
                SET @Ls_SqlData_TEXT = 'AkaNcpSsn_NUMB = ' + @Lc_AkaNcpSsn_NUMB;

                IF LEN(LTRIM(RTRIM(ISNULL(@Lc_AkaNcpSsn_NUMB, @Lc_Empty_TEXT)))) > 0
                   AND ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_AkaNcpSsn_NUMB, @Lc_Empty_TEXT)))) = 1
                   AND CAST(LTRIM(RTRIM(ISNULL(@Lc_AkaNcpSsn_NUMB, @Lc_Empty_TEXT))) AS NUMERIC) > 0
                 BEGIN
                  SET @Ln_AkaNcpSsn_NUMB = LTRIM(RTRIM(@Lc_AkaNcpSsn_NUMB));
                  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
                  SET @Ls_SqlData_TEXT = 'Process_ID = ' + @Lc_Job_ID;

                  EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
                   @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
                   @Ac_Process_ID               = @Lc_Job_ID,
                   @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
                   @Ac_Note_INDC                = @Lc_Note_INDC,
                   @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
                   @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
                   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
                   @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

                  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                   BEGIN
                    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

                    RAISERROR(50001,16,1);
                   END;

                  SET @Ls_Sql_TEXT = 'INSERT INTO MSSN';
                  SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', AkaNcpSsn_NUMB = ' + CAST(@Ln_AkaNcpSsn_NUMB AS VARCHAR) + ', Enumeration_CODE = ' + @Lc_EnumerationP_CODE + ', TypePrimary_CODE = ' + @Lc_TypePrimary_CODE + ', SourceVerify_CODE = ' + @Lc_SourceVerifyDmv_CODE;

                  INSERT INTO MSSN_Y1
                              (MemberMci_IDNO,
                               MemberSsn_NUMB,
                               Enumeration_CODE,
                               TypePrimary_CODE,
                               SourceVerify_CODE,
                               Status_DATE,
                               BeginValidity_DATE,
                               EndValidity_DATE,
                               WorkerUpdate_ID,
                               TransactionEventSeq_NUMB,
                               Update_DTTM)
                  SELECT @Ln_DmvlCur_NcpMemberMci_IDNO AS MemberMci_IDNO,
                         @Ln_AkaNcpSsn_NUMB AS MemberSsn_NUMB,
                         @Lc_EnumerationP_CODE AS Enumeration_CODE,
                         @Lc_TypePrimary_CODE AS TypePrimary_CODE,
                         @Lc_SourceVerifyDmv_CODE AS SourceVerify_CODE,
                         @Ld_Run_DATE AS Status_DATE,
                         @Ld_Run_DATE AS BeginValidity_DATE,
                         @Ld_High_DATE AS EndValidity_DATE,
                         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                         @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                         @Ld_Start_DATE AS Update_DTTM;

                  SET @Li_RowCount_QNTY = @@ROWCOUNT;

                  IF @Li_RowCount_QNTY = 0
                   BEGIN
                    SET @Ls_ErrorMessage_TEXT = 'INSERT MSSN_Y1 FAILED';

                    RAISERROR(50001,16,1);
                   END;
                 END;

                SET @Li_AliasSsnCount_QNTY = @Li_AliasSsnCount_QNTY + 1;
               END;
             END;
           END;

          IF LEN(LTRIM(RTRIM(ISNULL(@Ls_DmvlCur_MailingLine1NcpAddr_TEXT, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_MailingCityNcpAddr_TEXT, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_MailingStateNcpAddr_TEXT, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_MailingZipNcpAddr_TEXT, '')))) > 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE - M';
            SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', TypeAddress_CODE = ' + @Lc_TypeAddressM_CODE + ', MailingAddressNormalization_CODE = ' + @Lc_DmvlCur_MailingAddressNormalizationCode_TEXT + ', MailingLine1Ncp_ADDR = ' + @Ls_DmvlCur_MailingLine1NcpAddr_TEXT + ', MailingLine2Ncp_ADDR = ' + @Ls_DmvlCur_MailingLine2NcpAddr_TEXT + ', MailingCityNcp_ADDR = ' + @Lc_DmvlCur_MailingCityNcpAddr_TEXT + ', MailingStateNcp_ADDR = ' + @Lc_DmvlCur_MailingStateNcpAddr_TEXT + ', MailingZipNcp_ADDR = ' + @Lc_DmvlCur_MailingZipNcpAddr_TEXT;

            EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
             @An_MemberMci_IDNO                   = @Ln_DmvlCur_NcpMemberMci_IDNO,
             @Ad_Run_DATE                         = @Ld_Run_DATE,
             @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
             @Ad_Begin_DATE                       = @Ld_Run_DATE,
             @Ad_End_DATE                         = @Ld_High_DATE,
             @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
             @As_Line1_ADDR                       = @Ls_DmvlCur_MailingLine1NcpAddr_TEXT,
             @As_Line2_ADDR                       = @Ls_DmvlCur_MailingLine2NcpAddr_TEXT,
             @Ac_City_ADDR                        = @Lc_DmvlCur_MailingCityNcpAddr_TEXT,
             @Ac_State_ADDR                       = @Lc_DmvlCur_MailingStateNcpAddr_TEXT,
             @Ac_Zip_ADDR                         = @Lc_DmvlCur_MailingZipNcpAddr_TEXT,
             @Ac_Country_ADDR                     = @Lc_Country_ADDR,
             @An_Phone_NUMB                       = @Ln_Zero_NUMB,
             @Ac_SourceLoc_CODE                   = @Lc_SourceLocDmv_CODE,
             @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
             @Ad_Status_DATE                      = @Ld_Run_DATE,
             @Ac_Status_CODE                      = @Lc_StatusP_CODE,
             @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
             @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
             @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
             @Ac_Process_ID                       = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
             @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
             @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
             @Ac_Normalization_CODE               = @Lc_DmvlCur_MailingAddressNormalizationCode_TEXT,
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
           END

          IF LEN(LTRIM(RTRIM(ISNULL(@Ls_DmvlCur_ResidenceLine1NcpAddr_TEXT, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_ResidenceCityNcpAddr_TEXT, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_ResidenceStateNcpAddr_TEXT, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DmvlCur_ResidenceZipNcpAddr_TEXT, '')))) > 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE - R';
            SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', TypeAddress_CODE = ' + @Lc_TypeAddressR_CODE + ', ResidenceAddressNormalization_CODE = ' + @Lc_DmvlCur_ResidenceAddressNormalizationCode_TEXT + ', ResidenceLine1Ncp_ADDR = ' + @Ls_DmvlCur_ResidenceLine1NcpAddr_TEXT + ', ResidenceLine2Ncp_ADDR = ' + @Ls_DmvlCur_ResidenceLine2NcpAddr_TEXT + ', ResidenceCityNcp_ADDR = ' + @Lc_DmvlCur_ResidenceCityNcpAddr_TEXT + ', ResidenceStateNcp_ADDR = ' + @Lc_DmvlCur_ResidenceStateNcpAddr_TEXT + ', ResidenceZipNcp_ADDR = ' + @Lc_DmvlCur_ResidenceZipNcpAddr_TEXT;

            EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
             @An_MemberMci_IDNO                   = @Ln_DmvlCur_NcpMemberMci_IDNO,
             @Ad_Run_DATE                         = @Ld_Run_DATE,
             @Ac_TypeAddress_CODE                 = @Lc_TypeAddressR_CODE,
             @Ad_Begin_DATE                       = @Ld_Run_DATE,
             @Ad_End_DATE                         = @Ld_High_DATE,
             @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
             @As_Line1_ADDR                       = @Ls_DmvlCur_ResidenceLine1NcpAddr_TEXT,
             @As_Line2_ADDR                       = @Ls_DmvlCur_ResidenceLine2NcpAddr_TEXT,
             @Ac_City_ADDR                        = @Lc_DmvlCur_ResidenceCityNcpAddr_TEXT,
             @Ac_State_ADDR                       = @Lc_DmvlCur_ResidenceStateNcpAddr_TEXT,
             @Ac_Zip_ADDR                         = @Lc_DmvlCur_ResidenceZipNcpAddr_TEXT,
             @Ac_Country_ADDR                     = @Lc_Country_ADDR,
             @An_Phone_NUMB                       = @Ln_Zero_NUMB,
             @Ac_SourceLoc_CODE                   = @Lc_SourceLocDmv_CODE,
             @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
             @Ad_Status_DATE                      = @Ld_Run_DATE,
             @Ac_Status_CODE                      = @Lc_StatusP_CODE,
             @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
             @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
             @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
             @Ac_Process_ID                       = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
             @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
             @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
             @Ac_Normalization_CODE               = @Lc_DmvlCur_ResidenceAddressNormalizationCode_TEXT,
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
           END;
         END
       END;
      ELSE IF @Lc_DmvlCur_ActionCode_TEXT IN (@Lc_ActionS_CODE, @Lc_ActionL_CODE)
         AND @Lc_DmvlCur_MatchLevelCode_TEXT = '1'
       BEGIN
        SET @Ls_Sql_TEXT = 'CHECK THE EXISTENCE OF THE NCP IN THE SYSTEM - S/L/1';
        SET @Ls_SqlData_TEXT = 'NcpMemberMci_IDNO = ' + CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR) + ', LastNcp_NAME = ' + @Lc_DmvlCur_LastNcpName_TEXT;

        IF NOT EXISTS (SELECT 1
                         FROM DEMO_Y1 X
                        WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                          AND LTRIM(RTRIM(SUBSTRING(ISNULL(X.Last_NAME, REPLICATE(@Lc_Space_TEXT, 20)), 1, 5))) = LTRIM(RTRIM(SUBSTRING(@Lc_DmvlCur_LastNcpName_TEXT, 1, 5))))
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0012_CODE,
                 @Ls_ErrorMessage_TEXT = 'NO MATCHING RECORDS FOUND - S/L/1';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          IF @Lc_DmvlCur_ActionCode_TEXT = @Lc_ActionS_CODE
           BEGIN
            SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusI_CODE;
           END;
          ELSE IF @Lc_DmvlCur_ActionCode_TEXT = @Lc_ActionL_CODE
           BEGIN
            SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusA_CODE;
           END

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - S/L/1';
          SET @Ls_SqlData_TEXT = 'Process_ID = ' + @Lc_Job_ID;

          EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_Note_INDC,
           @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_LICENSE_UPDATE - DRIVING LICENSE - S/L/1';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DmvlCur_NcpMemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenseDr_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', LicenseStatus_CODE = ' + ISNULL(@Lc_LicenseStatus_CODE, '') + ', IssuingState_CODE = ' + ISNULL(@Lc_IssuingStateDe_CODE, '') + ', IssueLicense_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ExpireLicense_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', SuspLicense_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OthpLicAgent_IDNO AS VARCHAR), '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedDmv_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_COMMON$SP_LICENSE_UPDATE
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ac_LicenseNo_TEXT           = @Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT,
           @An_MemberMci_IDNO           = @Ln_DmvlCur_NcpMemberMci_IDNO,
           @Ac_TypeLicense_CODE         = @Lc_TypeLicenseDr_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_LicenseStatus_CODE       = @Lc_LicenseStatus_CODE,
           @Ac_IssuingState_CODE        = @Lc_IssuingStateDe_CODE,
           @Ad_IssueLicense_DATE        = @Ld_Run_DATE,
           @Ad_ExpireLicense_DATE       = @Ld_High_DATE,
           @Ad_SuspLicense_DATE         = @Ld_SuspLicense_DATE,
           @An_OtherParty_IDNO          = @Ln_OthpLicAgent_IDNO,
           @Ac_SourceVerified_CODE      = @Lc_SourceVerifiedDmv_CODE,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;

          IF EXISTS (SELECT 1
                       FROM PLIC_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                        AND 1 = (SELECT CASE
                                         WHEN ISNUMERIC(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT) = 0
                                          THEN
                                          CASE
                                           WHEN UPPER(LTRIM(RTRIM(ISNULL(X.LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT)))
                                            THEN 1
                                           ELSE 0
                                          END
                                         WHEN ISNUMERIC(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT) > 0
                                          THEN
                                          CASE
                                           WHEN ISNUMERIC(ISNULL(X.LicenseNo_TEXT, '')) > 0
                                            THEN
                                            CASE
                                             WHEN CAST(ISNULL(X.LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT AS NUMERIC)
                                              THEN 1
                                             ELSE 0
                                            END
                                           ELSE 0
                                          END
                                         ELSE 0
                                        END)
                        AND LTRIM(RTRIM(ISNULL(X.TypeLicense_CODE, @Lc_Empty_TEXT))) = @Lc_TypeLicenseDr_CODE
                        AND X.BeginValidity_DATE = @Ld_Run_DATE
                        AND X.EndValidity_DATE = @Ld_High_DATE)
           BEGIN
            SET @Lc_LicenseUpdated_INDC = @Lc_Yes_INDC;
           END;

          IF @Lc_LicenseUpdated_INDC = @Lc_Yes_INDC
           BEGIN
            DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
             SELECT A.Case_IDNO,
                    A.MemberMci_IDNO
               FROM CMEM_Y1 A,
                    CASE_Y1 B
              WHERE A.MemberMci_IDNO = @Ln_DmvlCur_NcpMemberMci_IDNO
                AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
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

            --Make a Case Journal Entry for each case of the member...          
            WHILE @Li_FetchStatus_QNTY = 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - S/L/1';
              SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR) + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorRrdmv_CODE;

              EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
               @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
               @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
               @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
               @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRrdmv_CODE,
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

                RAISERROR (50001,16,1);
               END
              ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
               BEGIN
                SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
                SET @Lc_BateError_CODE = @Lc_Msg_CODE;

                RAISERROR (50001,16,1);
               END

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
      ELSE
       BEGIN
        SELECT @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE,
               @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND - OTHER';

        RAISERROR(50001,16,1);
       END;

      SKIP_RECORD:
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_DMV;
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

      IF CURSOR_STATUS('Local', 'OrderCase_CUR') IN (0, 1)
       BEGIN
        CLOSE OrderCase_CUR;

        DEALLOCATE OrderCase_CUR;
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

     SET @Ls_Sql_TEXT = 'UPDATE LDMVL_Y1';
     SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + CAST(@Ln_DmvlCur_Seq_IDNO AS VARCHAR);

     UPDATE LDMVL_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_DmvlCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE LDMVL_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';
     SET @Ls_SqlData_TEXT = 'CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR) + ', CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR);

     IF @Ln_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_DMV';
       SET @Ls_SqlData_TEXT = '';

       COMMIT TRANSACTION TXN_PROCESS_DMV;

       SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
       SET @Ls_SqlData_TEXT = '';
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_DMV';
       SET @Ls_SqlData_TEXT = '';

       BEGIN TRANSACTION TXN_PROCESS_DMV;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ls_SqlData_TEXT = '';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';
     SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION TXN_PROCESS_DMV;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Dmvl_CUR - 2';
     SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Dmvl_CUR INTO @Ln_DmvlCur_Seq_IDNO, @Lc_DmvlCur_RecId_TEXT, @Lc_DmvlCur_LastNcpName_TEXT, @Lc_DmvlCur_FirstNcpName_TEXT, @Lc_DmvlCur_MiddleNcpName_TEXT, @Lc_DmvlCur_BirthNcpDate_TEXT, @Lc_DmvlCur_NcpDriversLicenseNo_TEXT, @Lc_DmvlCur_NcpSsnNumb_TEXT, @Lc_DmvlCur_NcpSexCode_TEXT, @Lc_DmvlCur_NcpMemberMciIdno_TEXT, @Lc_DmvlCur_SourceCode_TEXT, @Lc_DmvlCur_ActionCode_TEXT, @Lc_DmvlCur_NcpName_TEXT, @Lc_DmvlCur_SuffixNcpName_TEXT, @Lc_DmvlCur_DmvBirthNcpDate_TEXT, @Lc_DmvlCur_NcpDmvDriversLicenseNo_TEXT, @Lc_DmvlCur_NcpDriversLicenseTypeCode_TEXT, @Lc_DmvlCur_NcpDmvSsnNumb_TEXT, @Lc_DmvlCur_NcpDmvSexCode_TEXT, @Lc_DmvlCur_NcpAkaIndc_TEXT, @Lc_DmvlCur_AkaNcp1Name_TEXT, @Lc_DmvlCur_SuffixAkaNcp1Name_TEXT, @Lc_DmvlCur_AkaNcp2Name_TEXT, @Lc_DmvlCur_SuffixAkaNcp2Name_TEXT, @Lc_DmvlCur_AkaNcp3Name_TEXT, @Lc_DmvlCur_SuffixAkaNcp3Name_TEXT, @Lc_DmvlCur_AkaNcpSsn1Numb_TEXT, @Lc_DmvlCur_AkaNcpSsn2Numb_TEXT, @Lc_DmvlCur_AkaNcpSsn3Numb_TEXT, @Lc_DmvlCur_AkaBirthNcp1Date_TEXT, @Lc_DmvlCur_AkaBirthNcp2Date_TEXT, @Lc_DmvlCur_AkaBirthNcp3Date_TEXT, @Lc_DmvlCur_MatchLevelCode_TEXT, @Lc_DmvlCur_NcpSuspLicEffDate_TEXT, @Lc_DmvlCur_NcpLicLiftEffDate_TEXT, @Lc_DmvlCur_NcpDeceased_TEXT, @Lc_DmvlCur_MailingAddressNormalizationCode_TEXT, @Ls_DmvlCur_MailingLine1NcpAddr_TEXT, @Ls_DmvlCur_MailingLine2NcpAddr_TEXT, @Lc_DmvlCur_MailingCityNcpAddr_TEXT, @Lc_DmvlCur_MailingStateNcpAddr_TEXT, @Lc_DmvlCur_MailingZipNcpAddr_TEXT, @Lc_DmvlCur_ResidenceAddressNormalizationCode_TEXT, @Ls_DmvlCur_ResidenceLine1NcpAddr_TEXT, @Ls_DmvlCur_ResidenceLine2NcpAddr_TEXT, @Lc_DmvlCur_ResidenceCityNcpAddr_TEXT, @Lc_DmvlCur_ResidenceStateNcpAddr_TEXT, @Lc_DmvlCur_ResidenceZipNcpAddr_TEXT, @Lc_DmvlCur_Process_INDC, @Ld_DmvlCur_FileLoad_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   SET @Ls_Sql_TEXT = 'CLOSE Dmvl_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE Dmvl_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Dmvl_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE Dmvl_CUR;

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_DMV';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_PROCESS_DMV;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_DMV;
    END;

   IF CURSOR_STATUS('Local', 'Dmvl_CUR') IN (0, 1)
    BEGIN
     CLOSE Dmvl_CUR;

     DEALLOCATE Dmvl_CUR;
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
