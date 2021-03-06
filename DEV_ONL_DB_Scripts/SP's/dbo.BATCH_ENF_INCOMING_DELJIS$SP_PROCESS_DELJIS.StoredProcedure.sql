/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_DELJIS$SP_PROCESS_DELJIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_INCOMING_DELJIS$SP_PROCESS_DELJIS
Programmer Name 	: IMP Team
Description			: The procedure BATCH_ENF_INCOMING_DELJIS$SP_PROCESS_DELJIS updates system with Ncp's demographic,
					  incarceration,parole,probation and address information.
					  If the Deljis Flag is 'Y; then the case is ready for eligibility criteria; then trigger the process
                      for enforcement remedy.
Frequency			: 'WEEKLY'
Developed On		: 05/05/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_DELJIS$SP_PROCESS_DELJIS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_OthpLicAgent_IDNO       NUMERIC(9) = '999999974',
          @Lc_No_INDC                 CHAR(1) = 'N',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE  CHAR(1) = 'A',
          @Lc_TypeErrorE_CODE         CHAR(1) = 'E',
          @Lc_ProcessY_INDC           CHAR(1) = 'Y',
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_Note_INDC               CHAR(1) = 'N',
          @Lc_TypeAddressM_CODE       CHAR(1) = 'M',
          @Lc_StatusP_CODE            CHAR(1) = 'P',
          @Lc_CaseRelationshipA_CODE  CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE  CHAR(1) = 'P',
          @Lc_StatusCaseO_CODE        CHAR(1) = 'O',
          @Lc_CaseMemberStatusA_CODE  CHAR(1) = 'A',
          @Lc_NegPosStartRemedy_CODE  CHAR(1) = 'P',
          @Lc_StatusEnforceO_CODE     CHAR(1) = 'O',
          @Lc_SourceVerifiedA_CODE    CHAR(1) = 'A',
--13774 - Update MDET, only when any of the key fields value changes -START-          
          @Lc_MdetUpdateFlag_INDC     CHAR(1) = 'N',
--13774 - Update MDET, only when any of the key fields value changes -END-          
          @Lc_CountryUs_ADDR          CHAR(2) = 'US',
          @Lc_TypeChangeLe_CODE       CHAR(2) = 'LE',
          @Lc_TypeIncomeEm_CODE       CHAR(2) = 'EM',
          @Lc_SubsystemEn_CODE        CHAR(2) = 'EN',
          @Lc_SubsystemLo_CODE        CHAR(2) = 'LO',
          @Lc_SourceLocDoc_CODE       CHAR(3) = 'DOC',
          @Lc_StatusEnforceWcap_CODE  CHAR(4) = 'WCAP',
          @Lc_StatusEnforceWork_CODE  CHAR(4) = 'WORK',
--13719 - For CR0432, declaring enforcement status code variable for UDOC -START-          
          @Lc_StatusEnforceUdoc_CODE  CHAR(4) = 'UDOC',
--13719 - For CR0432, declaring enforcement status code variable for UDOC -END-          
          @Lc_ProcessLsnr_ID          CHAR(4) = 'LSNR',
          @Lc_ActivityMajorCase_CODE  CHAR(4) = 'CASE',
          @Lc_TypeReferenceLic_CODE   CHAR(4) = 'LIC',
--13719 - For CR0432, declaring refm table id and sub id variables to refer behind bar facilities -START-          
          @Lc_TableOthp_ID            CHAR(4) = 'OTHP',
          @Lc_TableSubJail_ID         CHAR(4) = 'JAIL',
--13719 - For CR0432, declaring refm table id and sub id variables to refer behind bar facilities -END-
          @Lc_ActivityMinorRcapi_CODE CHAR(5) = 'RCAPI',
          @Lc_ActivityMinorRcapw_CODE CHAR(5) = 'RCAPW',
          @Lc_ActivityMinorRincr_CODE CHAR(5) = 'RINCR',
--13719 - For CR0432, declaring minor activity code variable to be used for cjnr entries -START-          
          @Lc_ActivityMinorNcchg_CODE CHAR(5) = 'NCCHG',
--13719 - For CR0432, declaring minor activity code variable to be used for cjnr entries -END-          
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE     CHAR(5) = 'E0944',
          @Lc_BateErrorE1424_CODE     CHAR(5) = 'E1424',
          @Lc_BateErrorE0971_CODE     CHAR(5) = 'E0971',
          @Lc_BateErrorE0043_CODE     CHAR(5) = 'E0043',
          @Lc_BateErrorE0530_CODE     CHAR(5) = 'E0530',
          @Lc_BateErrorE1089_CODE     CHAR(5) = 'E1089',
          @Lc_BateErrorE0958_CODE     CHAR(5) = 'E0958',
          @Lc_BateErrorE0907_CODE     CHAR(5) = 'E0907',
          @Lc_BateErrorE0085_CODE     CHAR(5) = 'E0085',
          @Lc_BateErrorE0073_CODE     CHAR(5) = 'E0073',
          @Lc_BateErrorE0891_CODE     CHAR(5) = 'E0891',
          @Lc_ReasonStatusErfsm_CODE  CHAR(5) = 'ERFSM',
          @Lc_ReasonStatusErfso_CODE  CHAR(5) = 'ERFSO',
          @Lc_ReasonStatusErfss_CODE  CHAR(5) = 'ERFSS',
          @Lc_Job_ID                  CHAR(7) = 'DEB8086',
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT    CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_PROCESS_DELJIS',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_ENF_INCOMING_DELJIS',
--13719 - For CR0432, declaring note description variables to be used for ncchg cjnr entries -START-  
          @Ls_DescriptionNoteW2U_TEXT VARCHAR(4000) = 'Enforcement status changed from WORK - WORKABLE to UDOC - NCP INCARCERATED',
          @Ls_DescriptionNoteU2W_TEXT VARCHAR(4000) = 'Enforcement status changed from UDOC - NCP INCARCERATED to WORK - WORKABLE',
--13719 - For CR0432, declaring note description variables to be used for ncchg cjnr entries -START-            
          @Ld_Low_DATE                DATE = '01/01/0001',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                       NUMERIC = 0,
          @Ln_OrderSeq_NUMB                   NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY         NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY       NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
          @Ln_Case_IDNO                       NUMERIC(6) = 0,
          @Ln_Institution_IDNO                NUMERIC(9) = 0,
          @Ln_OthpPartyEmpl_IDNO              NUMERIC(9) = 0,
          @Ln_OthpPartyProbation_IDNO         NUMERIC(9) = 0,
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_MemberMci_IDNO                  NUMERIC(10) = 0,
          @Ln_Count_NUMB                      NUMERIC(10, 0) = 0,
          @Ln_Topic_NUMB                      NUMERIC(10, 0),
          @Ln_InstSbin_IDNO                   NUMERIC(10),
          @Ln_ErrorLine_NUMB                  NUMERIC(11) = 0,
          @Ln_Error_NUMB                      NUMERIC(11),
          @Ln_PhoneParoleOffice_NUMB          NUMERIC(15) = 0,
          @Ln_TransactionEventSeq_NUMB        NUMERIC(19) = 0,
          @Ln_RowCount_QNTY                   NUMERIC,
          @Ln_FetchStatus_QNTY                NUMERIC,
          @Lc_Empty_TEXT                      CHAR = '',
          @Lc_GoodCause_CODE                  CHAR(1),
          @Lc_NonCoop_CODE                    CHAR(1),
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_Msg_CODE                        CHAR(5),
          @Ls_Sql_TEXT                        VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT             VARCHAR(200),
          @Ls_SqlData_TEXT                    VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(2000),
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ls_DescriptionError_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Incarceration_DATE              DATE,
          @Ld_Release_DATE                    DATE,
          @Ld_NonCoop_DATE                    DATE,
          @Ld_MaxRelease_DATE                 DATE,
          @Ld_Start_DATE                      DATETIME2;
  DECLARE @Ln_DeljisCur_Seq_IDNO                      NUMERIC(19),
          @Lc_DeljisCur_MemberMciIdno_TEXT            CHAR(10),
          @Lc_DeljisCur_CaseIdno_TEXT                 CHAR(6),
          @Lc_DeljisCur_MemberSsn_TEXT                CHAR(9),
          @Ls_DeljisCur_DeljisOfficer_NAME            VARCHAR(50),
          @Lc_DeljisCur_DeljisOfficerPhoneNumb_TEXT   CHAR(10),
          @Lc_DeljisCur_DeljisWarrant_INDC            CHAR(1),
          @Lc_DeljisCur_DeljisIdno_TEXT               CHAR(8),
          @Lc_DeljisCur_DeljisLicenseNo_TEXT          CHAR(25),
          @Lc_DeljisCur_DeljisIncarcerationDate_TEXT  CHAR(8),
          @Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT CHAR(8),
          @Lc_DeljisCur_DeljisTypeSentence_CODE       CHAR(1)='',
          @Lc_DeljisCur_DeljisReleaseDate_TEXT        CHAR(8),
          @Lc_DeljisCur_DeljisInstitution_CODE        CHAR(2),
          @Ls_DeljisCur_DeljisFacility_NAME           VARCHAR(50),
          @Lc_DeljisCur_DeljisEmployer_NAME           CHAR(40),
          @Lc_DeljisCur_DeljisNormalization_CODE      CHAR(1),
          @Ls_DeljisCur_DeljisLine1_ADDR              VARCHAR(50),
          @Ls_DeljisCur_DeljisLine2_ADDR              VARCHAR(50),
          @Lc_DeljisCur_DeljisCity_ADDR               CHAR(28),
          @Lc_DeljisCur_DeljisState_ADDR              CHAR(2),
          @Lc_DeljisCur_DeljisZip_ADDR                CHAR(15),
          @Lc_DeljisCur_OfficerNormalization_CODE     CHAR(1),
          @Ls_DeljisCur_DeljisOfficerLine1_ADDR       VARCHAR(50),
          @Ls_DeljisCur_DeljisOfficerLine2_ADDR       VARCHAR(50),
          @Lc_DeljisCur_DeljisOfficerCity_ADDR        CHAR(28),
          @Lc_DeljisCur_DeljisOfficerState_ADDR       CHAR(2),
          @Lc_DeljisCur_DeljisOfficerZip_ADDR         CHAR(15),
          @Lc_DeljisCur_NcpNormalization_CODE         CHAR(1),
          @Ls_DeljisCur_DeljisLine1Ncp_ADDR           VARCHAR(50),
          @Ls_DeljisCur_DeljisLine2Ncp_ADDR           VARCHAR(50),
          @Lc_DeljisCur_DeljisCityNcp_ADDR            CHAR(28),
          @Lc_DeljisCur_DeljisStateNcp_ADDR           CHAR(2),
          @Lc_DeljisCur_DeljisZipNcp_ADDR             CHAR(15),
          @Lc_DeljisCur_EmployerNormalization_CODE    CHAR(1),
          @Ls_DeljisCur_DeljisEmployerLine1_ADDR      VARCHAR(50),
          @Ls_DeljisCur_DeljisEmployerLine2_ADDR      VARCHAR(50),
          @Lc_DeljisCur_DeljisEmployerCity_ADDR       CHAR(28),
          @Lc_DeljisCur_DeljisEmployerState_ADDR      CHAR(2),
          @Lc_DeljisCur_DeljisEmployerZip_ADDR        CHAR(15),
          @Lc_DeljisCur_DeljisWorkRelease_INDC        CHAR(1);
  DECLARE @Ln_OpenCasesCur_Case_IDNO NUMERIC(6);
  DECLARE Deljis_CUR INSENSITIVE CURSOR FOR
   SELECT L.Seq_IDNO,
          L.MemberMci_IDNO,
          L.Case_IDNO,
          L.MemberSsn_NUMB,
          L.DeljisOfficer_NAME,
          L.DeljisOfficerPhone_NUMB,
          L.DeljisWarrant_INDC,
          L.Deljis_IDNO,
          L.DeljisLicenseNo_TEXT,
          L.DeljisIncarceration_DATE,
          L.DeljisMaximumRelease_DATE,
          L.DeljisTypeSentence_CODE,
          L.DeljisRelease_DATE,
          L.DeljisInstitution_CODE,
          L.Deljisfacility_NAME,
          L.DeljisEmployer_NAME,
          L.DeljisNormalization_CODE,
          L.DeljisLine1_ADDR,
          L.DeljisLine2_ADDR,
          L.DeljisCity_ADDR,
          L.DeljisState_ADDR,
          L.DeljisZip_ADDR,
          L.OfficerNormalization_CODE,
          L.DeljisOfficerLine1_ADDR,
          L.DeljisOfficerLine2_ADDR,
          L.DeljisOfficerCity_ADDR,
          L.DeljisOfficerState_ADDR,
          L.DeljisOfficerZip_ADDR,
          L.NcpNormalization_CODE,
          L.DeljisLine1Ncp_ADDR,
          L.DeljisLine2Ncp_ADDR,
          L.DeljisCityNcp_ADDR,
          L.DeljisStateNcp_ADDR,
          L.DeljisZipNcp_ADDR,
          L.EmployerNormalization_CODE,
          L.DeljisEmployerLine1_ADDR,
          L.DeljisEmployerLine2_ADDR,
          L.DeljisEmployerCity_ADDR,
          L.DeljisEmployerState_ADDR,
          L.DeljisEmployerZip_ADDR,
          L.DeljisWorkRelease_INDC
     FROM LDLJS_Y1 L
    WHERE L.Process_INDC = @Lc_No_INDC
    ORDER BY L.Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_DELJIS';

   BEGIN TRANSACTION TXN_PROCESS_DELJIS;

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

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN Deljis_CUR';

   OPEN Deljis_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Deljis_CUR - 1';

   FETCH NEXT FROM Deljis_CUR INTO @Ln_DeljisCur_Seq_IDNO, @Lc_DeljisCur_MemberMciIdno_TEXT, @Lc_DeljisCur_CaseIdno_TEXT, @Lc_DeljisCur_MemberSsn_TEXT, @Ls_DeljisCur_DeljisOfficer_NAME, @Lc_DeljisCur_DeljisOfficerPhoneNumb_TEXT, @Lc_DeljisCur_DeljisWarrant_INDC, @Lc_DeljisCur_DeljisIdno_TEXT, @Lc_DeljisCur_DeljisLicenseNo_TEXT, @Lc_DeljisCur_DeljisIncarcerationDate_TEXT, @Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT, @Lc_DeljisCur_DeljisTypeSentence_CODE, @Lc_DeljisCur_DeljisReleaseDate_TEXT, @Lc_DeljisCur_DeljisInstitution_CODE, @Ls_DeljisCur_DeljisFacility_NAME, @Lc_DeljisCur_DeljisEmployer_NAME, @Lc_DeljisCur_DeljisNormalization_CODE, @Ls_DeljisCur_DeljisLine1_ADDR, @Ls_DeljisCur_DeljisLine2_ADDR, @Lc_DeljisCur_DeljisCity_ADDR, @Lc_DeljisCur_DeljisState_ADDR, @Lc_DeljisCur_DeljisZip_ADDR, @Lc_DeljisCur_OfficerNormalization_CODE, @Ls_DeljisCur_DeljisOfficerLine1_ADDR, @Ls_DeljisCur_DeljisOfficerLine2_ADDR, @Lc_DeljisCur_DeljisOfficerCity_ADDR, @Lc_DeljisCur_DeljisOfficerState_ADDR, @Lc_DeljisCur_DeljisOfficerZip_ADDR, @Lc_DeljisCur_NcpNormalization_CODE, @Ls_DeljisCur_DeljisLine1Ncp_ADDR, @Ls_DeljisCur_DeljisLine2Ncp_ADDR, @Lc_DeljisCur_DeljisCityNcp_ADDR, @Lc_DeljisCur_DeljisStateNcp_ADDR, @Lc_DeljisCur_DeljisZipNcp_ADDR, @Lc_DeljisCur_EmployerNormalization_CODE, @Ls_DeljisCur_DeljisEmployerLine1_ADDR, @Ls_DeljisCur_DeljisEmployerLine2_ADDR, @Lc_DeljisCur_DeljisEmployerCity_ADDR, @Lc_DeljisCur_DeljisEmployerState_ADDR, @Lc_DeljisCur_DeljisEmployerZip_ADDR, @Lc_DeljisCur_DeljisWorkRelease_INDC;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Deljis_CUR';

   --Process incoming records and update the address database table and financial assets database table in DECSS
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_DELJIS;

      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'DELJIS - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_DeljisCur_Seq_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + @Lc_DeljisCur_MemberMciIdno_TEXT + ', Case_IDNO = ' + @Lc_DeljisCur_CaseIdno_TEXT + ', MemberSsn_NUMB = ' + @Lc_DeljisCur_MemberSsn_TEXT + ', DeljisOfficer_NAME = ' + @Ls_DeljisCur_DeljisOfficer_NAME + ', DeljisOfficerPhone_NUMB = ' + @Lc_DeljisCur_DeljisOfficerPhoneNumb_TEXT + ', DeljisWarrant_INDC = ' + @Lc_DeljisCur_DeljisWarrant_INDC + ', Deljis_IDNO = ' + @Lc_DeljisCur_DeljisIdno_TEXT + ', DeljisLicenseNo_TEXT = ' + @Lc_DeljisCur_DeljisLicenseNo_TEXT + ', DeljisIncarceration_DATE = ' + @Lc_DeljisCur_DeljisIncarcerationDate_TEXT + ', DeljisMaximumRelease_DATE = ' + @Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT + ', DeljisTypeSentence_CODE = ' + @Lc_DeljisCur_DeljisTypeSentence_CODE + ', DeljisRelease_DATE = ' + @Lc_DeljisCur_DeljisReleaseDate_TEXT + ', DeljisInstitution_CODE = ' + @Lc_DeljisCur_DeljisInstitution_CODE + ', Deljisfacility_NAME = ' + @Ls_DeljisCur_DeljisFacility_NAME + ', DeljisEmployer_NAME = ' + @Lc_DeljisCur_DeljisEmployer_NAME + ', DeljisNormalization_CODE = ' + @Lc_DeljisCur_DeljisNormalization_CODE + ', DeljisLine1_ADDR = ' + @Ls_DeljisCur_DeljisLine1_ADDR + ', DeljisLine2_ADDR = ' + @Ls_DeljisCur_DeljisLine2_ADDR + ', DeljisCity_ADDR = ' + @Lc_DeljisCur_DeljisCity_ADDR + ', DeljisState_ADDR = ' + @Lc_DeljisCur_DeljisState_ADDR + ', DeljisZip_ADDR = ' + @Lc_DeljisCur_DeljisZip_ADDR + ', OfficerNormalization_CODE = ' + @Lc_DeljisCur_OfficerNormalization_CODE + ', DeljisOfficerLine1_ADDR = ' + @Ls_DeljisCur_DeljisOfficerLine1_ADDR + ', DeljisOfficerLine2_ADDR = ' + @Ls_DeljisCur_DeljisOfficerLine2_ADDR + ', DeljisOfficerCity_ADDR = ' + @Lc_DeljisCur_DeljisOfficerCity_ADDR + ', DeljisOfficerState_ADDR = ' + @Lc_DeljisCur_DeljisOfficerState_ADDR + ', DeljisOfficerZip_ADDR = ' + @Lc_DeljisCur_DeljisOfficerZip_ADDR + ', NcpNormalization_CODE = ' + @Lc_DeljisCur_NcpNormalization_CODE + ', DeljisLine1Ncp_ADDR = ' + @Ls_DeljisCur_DeljisLine1Ncp_ADDR + ', DeljisLine2Ncp_ADDR = ' + @Ls_DeljisCur_DeljisLine2Ncp_ADDR + ', DeljisCityNcp_ADDR = ' + @Lc_DeljisCur_DeljisCityNcp_ADDR + ', DeljisStateNcp_ADDR = ' + @Lc_DeljisCur_DeljisStateNcp_ADDR + ', DeljisZipNcp_ADDR = ' + @Lc_DeljisCur_DeljisZipNcp_ADDR + ', EmployerNormalization_CODE = ' + @Lc_DeljisCur_EmployerNormalization_CODE + ', DeljisEmployerLine1_ADDR = ' + @Ls_DeljisCur_DeljisEmployerLine1_ADDR + ', DeljisEmployerLine2_ADDR = ' + @Ls_DeljisCur_DeljisEmployerLine2_ADDR + ', DeljisEmployerCity_ADDR = ' + @Lc_DeljisCur_DeljisEmployerCity_ADDR + ', DeljisEmployerState_ADDR = ' + @Lc_DeljisCur_DeljisEmployerState_ADDR + ', DeljisEmployerZip_ADDR = ' + @Lc_DeljisCur_DeljisEmployerZip_ADDR + ', DeljisWorkRelease_INDC = ' + @Lc_DeljisCur_DeljisWorkRelease_INDC;
      SET @Ln_Case_IDNO = 0;
      SET @Ln_Institution_IDNO = 0;
      SET @Ln_OthpPartyEmpl_IDNO = 0;
      SET @Ln_OthpPartyProbation_IDNO = 0;
--13774 - Update MDET, only when any of the key fields value changes -START-            
	  SET @Lc_MdetUpdateFlag_INDC = 'N';
--13774 - Update MDET, only when any of the key fields value changes -END-            
      
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

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

        RAISERROR (50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'CHECK INPUT MEMBER MCI #';

      IF ISNUMERIC(@Lc_DeljisCur_MemberMciIdno_TEXT) = 0
          OR CAST(@Lc_DeljisCur_MemberMciIdno_TEXT AS NUMERIC) = 0
       BEGIN
        SELECT @Lc_BateError_CODE = @Lc_BateErrorE0958_CODE,
               @Ls_ErrorMessage_TEXT = 'KEY DATA NOT FOUND';

        RAISERROR(50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_MemberMci_IDNO = LTRIM(RTRIM(@Lc_DeljisCur_MemberMciIdno_TEXT));
       END

      SET @Ls_Sql_TEXT = 'CHECK THE MEMBER IN DEMO_Y1';

      IF NOT EXISTS (SELECT 1
                       FROM DEMO_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_MemberMci_IDNO)
       BEGIN
        SELECT @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE,
               @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND IN DEMO_Y1';

        RAISERROR(50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ls_Sql_TEXT = 'CHECK WHETHER THE MEMBER''S SSN IN DEMO_Y1 IS NON END DATED IN MSSN_Y1';

        IF NOT EXISTS (SELECT 1
                         FROM DEMO_Y1 X
                        WHERE X.MemberMci_IDNO = @Ln_MemberMci_IDNO
                          AND ISNULL(X.MemberSsn_NUMB, 0) > 0
                          AND EXISTS (SELECT 1
                                        FROM MSSN_Y1 Y
                                       WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                         AND Y.MemberSsn_NUMB = X.MemberSsn_NUMB
                                         AND Y.EndValidity_DATE = '12/31/9999'))
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0530_CODE,
                 @Ls_ErrorMessage_TEXT = 'ENTERED MEMBER ID, SSN COMBINATION DOES NOT EXIST.';

          RAISERROR(50001,16,1);
         END
       END

      SET @Ls_Sql_TEXT = 'CHECK FOR THE NCP''S DATE-OF-DEATH IN DEMO_Y1';

      IF EXISTS (SELECT 1
                   FROM DEMO_Y1 X
                  WHERE X.MemberMci_IDNO = @Ln_MemberMci_IDNO
                    AND ISNULL(X.Deceased_DATE, '') IN ('01/01/0001', '01/01/1900'))
       BEGIN
        IF LEN(LTRIM(RTRIM(ISNULL(@Ls_DeljisCur_DeljisLine1_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisCity_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisState_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisZip_ADDR, '')))) > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE - DELJIS NCP ADDRESS';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressM_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisZip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_CountryUs_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocDoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusP_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_DeljisCur_DeljisNormalization_CODE, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
           @As_Line1_ADDR                       = @Ls_DeljisCur_DeljisLine1_ADDR,
           @As_Line2_ADDR                       = @Ls_DeljisCur_DeljisLine2_ADDR,
           @Ac_City_ADDR                        = @Lc_DeljisCur_DeljisCity_ADDR,
           @Ac_State_ADDR                       = @Lc_DeljisCur_DeljisState_ADDR,
           @Ac_Zip_ADDR                         = @Lc_DeljisCur_DeljisZip_ADDR,
           @Ac_Country_ADDR                     = @Lc_CountryUs_ADDR,
           @An_Phone_NUMB                       = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_SourceLocDoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_StatusP_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
           @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
           @Ac_Process_ID                       = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Zero_NUMB,
           @Ac_Normalization_CODE               = @Lc_DeljisCur_DeljisNormalization_CODE,
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
       END

      SET @Ls_Sql_TEXT = 'CHECK DELJIS WARRANT FLAG';

      IF LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisWarrant_INDC, ''))) = 'Y'
       BEGIN
        SET @Ls_Sql_TEXT = 'CHECK INPUT SYSTEM CASE ID';

        IF ISNUMERIC(@Lc_DeljisCur_CaseIdno_TEXT) = 0
            OR CAST(@Lc_DeljisCur_CaseIdno_TEXT AS NUMERIC) = 0
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE,
                 @Ls_ErrorMessage_TEXT = 'INVALID VALUE';

          RAISERROR(50001,16,1);
         END
        ELSE
         BEGIN
          SET @Ln_Case_IDNO = LTRIM(RTRIM(@Lc_DeljisCur_CaseIdno_TEXT));
         END

        SET @Ls_Sql_TEXT = 'CHECK WHETHER THE CASE EXISTS IN CASE_Y1';
        SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '');

        IF NOT EXISTS (SELECT 1
                         FROM CASE_Y1 Y
                        WHERE Y.Case_IDNO = @Ln_Case_IDNO)
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0891_CODE,
                 @Ls_ErrorMessage_TEXT = 'CASE RECORD NOT FOUND IN CASE TABLE';

          RAISERROR(50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'CHECK WHETHER THE CASE IS AN OPEN IV-D CASE IN CASE_Y1';
        SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '');

        IF NOT EXISTS (SELECT 1
                         FROM CASE_Y1 Y
                        WHERE Y.Case_IDNO = @Ln_Case_IDNO
                          AND Y.StatusCase_CODE = @Lc_StatusCaseO_CODE
                          AND Y.TypeCase_CODE <> 'H')
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0073_CODE,
                 @Ls_ErrorMessage_TEXT = 'CASE IS NOT AN OPEN IV-D CASE';

          RAISERROR(50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'CHECK WHETHER THE CASE IS EITHER AN INSTATE CASE OR A RESPONDING INTERGOVERNMENTAL CASE';
        SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '');

        IF EXISTS (SELECT 1
                     FROM CASE_Y1 Y
                    WHERE Y.Case_IDNO = @Ln_Case_IDNO
                      AND (Y.RespondInit_CODE NOT IN ('N', 'R', 'S', 'Y')
                            OR (Y.RespondInit_CODE IN ('R', 'S', 'Y')
                                AND EXISTS (SELECT 1
                                              FROM ICAS_Y1 Z
                                             WHERE Z.Case_IDNO = Y.Case_IDNO
                                               AND Z.Reason_CODE IN (@Lc_ReasonStatusErfsm_CODE, @Lc_ReasonStatusErfso_CODE, @Lc_ReasonStatusErfss_CODE)
                                               AND Z.Status_CODE = @Lc_StatusCaseO_CODE
                                               AND Z.End_DATE = @Ld_High_DATE
                                               AND Z.EndValidity_DATE = @Ld_High_DATE))))
         BEGIN
          GOTO SKIP_RECORD;
         END

        --SET @Ls_Sql_TEXT = 'CHECK WHETHER THERE IS ORDER ON THE CASE IN SORD_Y1';
        --SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '');
        --IF NOT EXISTS (SELECT 1
        --                 FROM SORD_Y1 Z
        --                WHERE Z.Case_IDNO = @Ln_Case_IDNO
        --                  AND Z.EndValidity_DATE = @Ld_High_DATE
        --                  AND @Ld_Run_DATE BETWEEN Z.OrderEffective_DATE AND Z.OrderEnd_DATE)
        -- BEGIN
        --  GOTO SKIP_RECORD;
        -- END
        --SET @Ls_Sql_TEXT = 'CHECK WHETHER THERE IS CHARGING OBLIGATION OR ARREARS ON THE CASE IN OBLE_Y1';
        --SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '');
        --IF NOT EXISTS (SELECT 1
        --                 FROM OBLE_Y1 Z
        --                WHERE Z.Case_IDNO = @Ln_Case_IDNO
        --                  AND Z.EndValidity_DATE = @Ld_High_DATE
        --                  AND ((Z.Periodic_AMNT > 0
        --                        AND @Ld_Run_DATE BETWEEN Z.BeginObligation_DATE AND Z.EndObligation_DATE)
        --                        OR (Z.Periodic_AMNT = 0
        --                            AND Z.ExpectToPay_AMNT > 0)))
        -- BEGIN
        --  GOTO SKIP_RECORD;
        -- END
        SET @Ls_Sql_TEXT = 'CHECK WHETHER THE MEMBER IS AN ACTIVE NCP/PF FOR THE CASE IN CMEM_Y1';
        SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '')

        IF NOT EXISTS (SELECT 1
                         FROM CMEM_Y1 X
                        WHERE X.MemberMci_IDNO = @Ln_MemberMci_IDNO
                          AND X.Case_IDNO = @Ln_Case_IDNO
                          AND X.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                          AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE,
                 @Ls_ErrorMessage_TEXT = 'MEMBER IS NOT AN ACTIVE NCP/PF IN CMEM_Y1';

          RAISERROR(50001,16,1);
         END

        IF EXISTS(SELECT 1
                    FROM CASE_Y1 A
                   WHERE A.Case_IDNO = @Ln_Case_IDNO
                     AND A.StatusEnforce_CODE <> @Lc_StatusEnforceWcap_CODE)
         BEGIN
--13719 - As part of CR0432, changing the way enforcement status is updated from <> wcap to wcap -START-             
            SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1 - ENF STATUS - <> WCAP TO WCAP';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR);

            UPDATE c
               SET c.StatusEnforce_CODE = @Lc_StatusEnforceWcap_CODE,
                   c.BeginValidity_DATE = @Ld_Run_DATE,
                   c.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                   c.Update_DTTM = @Ld_Start_DATE,
                   c.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB --Generated TransactioneventSeqNumb
            OUTPUT Deleted.Case_IDNO,
                   Deleted.StatusCase_CODE,
                   Deleted.TypeCase_CODE,
                   Deleted.RsnStatusCase_CODE,
                   Deleted.RespondInit_CODE,
                   Deleted.SourceRfrl_CODE,
                   Deleted.Opened_DATE,
                   Deleted.Marriage_DATE,
                   Deleted.Divorced_DATE,
                   Deleted.StatusCurrent_DATE,
                   Deleted.AprvIvd_DATE,
                   Deleted.County_IDNO,
                   Deleted.Office_IDNO,
                   Deleted.AssignedFips_CODE,
                   Deleted.GoodCause_CODE,
                   Deleted.GoodCause_DATE,
                   Deleted.Restricted_INDC,
                   Deleted.MedicalOnly_INDC,
                   Deleted.Jurisdiction_INDC,
                   Deleted.IvdApplicant_CODE,
                   Deleted.Application_IDNO,
                   Deleted.AppSent_DATE,
                   Deleted.AppReq_DATE,
                   Deleted.AppRetd_DATE,
                   Deleted.CpRelationshipToNcp_CODE,
                   Deleted.Worker_ID,
                   Deleted.AppSigned_DATE,
                   Deleted.ClientLitigantRole_CODE,
                   Deleted.DescriptionComments_TEXT,
                   Deleted.NonCoop_CODE,
                   Deleted.NonCoop_DATE,
                   Deleted.BeginValidity_DATE,
                   @Ld_Run_DATE AS EndValidity_DATE,
                   Deleted.WorkerUpdate_ID,
                   Deleted.TransactionEventSeq_NUMB,
                   Deleted.Update_DTTM,
                   Deleted.Referral_DATE,
                   Deleted.CaseCategory_CODE,
                   Deleted.File_ID,
                   Deleted.ApplicationFee_CODE,
                   Deleted.FeePaid_DATE,
                   Deleted.ServiceRequested_CODE,
                   Deleted.StatusEnforce_CODE,
                   Deleted.FeeCheckNo_TEXT,
                   Deleted.ReasonFeeWaived_CODE,
                   Deleted.Intercept_CODE
            INTO HCASE_Y1
              FROM CASE_Y1 c
             WHERE c.Case_IDNO = @Ln_Case_IDNO
               AND c.StatusEnforce_CODE <> @Lc_StatusEnforceWcap_CODE
--13719 - As part of CR0432, changing the way enforcement status is updated from <> wcap to wcap -END-

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - WCAP - RCAPI - EN';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRcapi_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
--13719 - As part of CR0432, including run date in insert activity call for case journal entry -START-           
           @Ad_Run_DATE                 = @Ld_Run_DATE,
--13719 - As part of CR0432, including run date in insert activity call for case journal entry -END-           
           @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR (50001,16,1);
           END;
         END
       END
      ELSE
       BEGIN
        SET @Ls_Sql_TEXT = 'CHECK INPUT SYSTEM CASE ID - 2';

        IF ISNUMERIC(@Lc_DeljisCur_CaseIdno_TEXT) > 0
           AND CAST(@Lc_DeljisCur_CaseIdno_TEXT AS NUMERIC) > 0
         BEGIN
          SET @Ln_Case_IDNO = LTRIM(RTRIM(@Lc_DeljisCur_CaseIdno_TEXT));

          IF EXISTS (SELECT 1
                       FROM CASE_Y1 Y
                      WHERE Y.Case_IDNO = @Ln_Case_IDNO
                        AND Y.StatusCase_CODE = @Lc_StatusCaseO_CODE
                        AND Y.TypeCase_CODE <> 'H'
                        AND Y.StatusEnforce_CODE = @Lc_StatusEnforceWcap_CODE
                        AND EXISTS (SELECT 1
                                      FROM CMEM_Y1 X
                                     WHERE X.MemberMci_IDNO = @Ln_MemberMci_IDNO
                                       AND X.Case_IDNO = @Ln_Case_IDNO
                                       AND X.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                                       AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE))
           BEGIN
            SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1 - ENF STATUS - WCAP TO WORK';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR);

            UPDATE c
               SET c.StatusEnforce_CODE = @Lc_StatusEnforceWork_CODE,
                   c.BeginValidity_DATE = @Ld_Run_DATE,
                   c.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                   c.Update_DTTM = @Ld_Start_DATE,
                   c.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB --Generated TransactioneventSeqNumb
            OUTPUT Deleted.Case_IDNO,
                   Deleted.StatusCase_CODE,
                   Deleted.TypeCase_CODE,
                   Deleted.RsnStatusCase_CODE,
                   Deleted.RespondInit_CODE,
                   Deleted.SourceRfrl_CODE,
                   Deleted.Opened_DATE,
                   Deleted.Marriage_DATE,
                   Deleted.Divorced_DATE,
                   Deleted.StatusCurrent_DATE,
                   Deleted.AprvIvd_DATE,
                   Deleted.County_IDNO,
                   Deleted.Office_IDNO,
                   Deleted.AssignedFips_CODE,
                   Deleted.GoodCause_CODE,
                   Deleted.GoodCause_DATE,
                   Deleted.Restricted_INDC,
                   Deleted.MedicalOnly_INDC,
                   Deleted.Jurisdiction_INDC,
                   Deleted.IvdApplicant_CODE,
                   Deleted.Application_IDNO,
                   Deleted.AppSent_DATE,
                   Deleted.AppReq_DATE,
                   Deleted.AppRetd_DATE,
                   Deleted.CpRelationshipToNcp_CODE,
                   Deleted.Worker_ID,
                   Deleted.AppSigned_DATE,
                   Deleted.ClientLitigantRole_CODE,
                   Deleted.DescriptionComments_TEXT,
                   Deleted.NonCoop_CODE,
                   Deleted.NonCoop_DATE,
                   Deleted.BeginValidity_DATE,
                   @Ld_Run_DATE AS EndValidity_DATE,
                   Deleted.WorkerUpdate_ID,
                   Deleted.TransactionEventSeq_NUMB,
                   Deleted.Update_DTTM,
                   Deleted.Referral_DATE,
                   Deleted.CaseCategory_CODE,
                   Deleted.File_ID,
                   Deleted.ApplicationFee_CODE,
                   Deleted.FeePaid_DATE,
                   Deleted.ServiceRequested_CODE,
                   Deleted.StatusEnforce_CODE,
                   Deleted.FeeCheckNo_TEXT,
                   Deleted.ReasonFeeWaived_CODE,
                   Deleted.Intercept_CODE
            INTO HCASE_Y1
              FROM CASE_Y1 c
             WHERE c.Case_IDNO = @Ln_Case_IDNO
               AND c.StatusEnforce_CODE = @Lc_StatusEnforceWcap_CODE
               AND c.StatusCase_CODE = 'O'
               AND c.TypeCase_CODE <> 'H'

            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - WCAP - RCAPW - EN';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

            EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
             @An_Case_IDNO                = @Ln_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRcapw_CODE,
             @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
--13719 - As part of CR0432, including run date in insert activity call for case journal entry -START-             
             @Ad_Run_DATE                 = @Ld_Run_DATE,
--13719 - As part of CR0432, including run date in insert activity call for case journal entry -END-             
             @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

              RAISERROR (50001,16,1);
             END;
           END
         END
       END

      SET @Ls_Sql_TEXT = 'CHECK DELJIS Facility NAME';

      IF LEN(LTRIM(RTRIM(ISNULL(@Ls_DeljisCur_DeljisFacility_NAME, @Lc_Empty_TEXT)))) > 0
       BEGIN
        SET @Ls_Sql_TEXT = 'GET THE OTHP ID FOR JAIL/INSTITUTIONS';
        SET @Ln_Institution_IDNO = ISNULL ((SELECT TOP 1 ISNULL(A.OtherParty_IDNO, 0)
                                              FROM OTHP_Y1 A
                                             WHERE A.TypeOthp_CODE = 'J'
--13774 - Match Institution with 5 five characters of Institution name on DELJIS -START-                                             
                                               AND LEFT(UPPER(LTRIM(RTRIM(A.OtherParty_NAME))), 5) = LEFT(UPPER(LTRIM(RTRIM(@Ls_DeljisCur_DeljisFacility_NAME))), 5)
--13774 - Match Institution with 5 five characters of Institution name on DELJIS -END-                                               
                                               AND A.EndValidity_DATE = '12/31/9999'), 0);

        SET @Ls_Sql_TEXT = 'CHECK THE MEMBER IN MDET_Y1';
        SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

        SELECT @Ln_Count_NUMB = COUNT(1)
          FROM MDET_Y1 A
         WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND A.EndValidity_DATE = @Ld_High_DATE;

        IF @Ln_Count_NUMB > 1
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0971_CODE,
                 @Ls_ErrorMessage_TEXT = 'MORE THAN ONE MEMBER DETENTION FOUND IN THE SYSTEM FOR THE MEMBER';

          RAISERROR(50001,16,1);
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'CHECK INPUT STATE BUREAU OF IDENTIFICATION NUMBER';

          IF ISNUMERIC(@Lc_DeljisCur_DeljisIdno_TEXT) > 0
           BEGIN
            SET @Ln_InstSbin_IDNO = @Lc_DeljisCur_DeljisIdno_TEXT;
           END
          ELSE
           BEGIN
            SET @Ln_InstSbin_IDNO = 0;
           END

          SET @Ls_Sql_TEXT = 'CHECK INPUT INMATE''S DATE OF INCARCERATION';

          IF ISDATE(@Lc_DeljisCur_DeljisIncarcerationDate_TEXT) > 0
             AND CAST(@Lc_DeljisCur_DeljisIncarcerationDate_TEXT AS DATE) NOT IN ('01/01/1900', '12/31/9999')
           BEGIN
            SET @Ld_Incarceration_DATE = CAST(@Lc_DeljisCur_DeljisIncarcerationDate_TEXT AS DATE);
           END
          ELSE
           BEGIN
            SELECT @Lc_BateError_CODE = @Lc_BateErrorE0043_CODE,
                   @Ls_ErrorMessage_TEXT = 'INVALID DATE';

            RAISERROR(50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'CHECK INPUT INMATE''S MAXIMUM RELEASE DATE';
          SET @Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT = LTRIM(RTRIM(@Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT)) + '01';

          IF ISDATE(@Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT) > 0
             AND CAST(@Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT AS DATE) NOT IN ('01/01/1900', '12/31/9999')
           BEGIN
            SET @Ld_MaxRelease_DATE = CAST(@Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT AS DATE);
           END
          ELSE
           BEGIN
            SET @Ld_MaxRelease_DATE = @Ld_High_DATE;
           END

          SET @Ls_Sql_TEXT = 'CHECK INPUT INMATE''S DATE OF RELEASE';

          IF ISDATE(@Lc_DeljisCur_DeljisReleaseDate_TEXT) > 0
             AND CAST(@Lc_DeljisCur_DeljisReleaseDate_TEXT AS DATE) NOT IN ('01/01/1900')
           BEGIN
            SET @Ld_Release_DATE = CAST(@Lc_DeljisCur_DeljisReleaseDate_TEXT AS DATE);
           END
          ELSE
           BEGIN
            SET @Ld_Release_DATE = @Ld_High_DATE;
           END

          SET @Ls_Sql_TEXT = 'CHANGE RELEASE DATE BASED ON INCARCERATION DATE';

          IF @Ld_Release_DATE < @Ld_Incarceration_DATE
           BEGIN
            SET @Ld_Release_DATE = @Ld_High_DATE;
           END

          SET @Ls_Sql_TEXT = 'CHECK INPUT PROBATION OR PAROLE OFFICER''S PHONE NUMBER';

          IF ISNUMERIC(@Lc_DeljisCur_DeljisOfficerPhoneNumb_TEXT) > 0
           BEGIN
            SET @Ln_PhoneParoleOffice_NUMB = @Lc_DeljisCur_DeljisOfficerPhoneNumb_TEXT;
           END
          ELSE
           BEGIN
            SET @Ln_PhoneParoleOffice_NUMB = 0;
           END

          IF LEN(LTRIM(RTRIM(ISNULL(@Ls_DeljisCur_DeljisOfficerLine1_ADDR, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisOfficerCity_ADDR, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisOfficerState_ADDR, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisOfficerZip_ADDR, '')))) > 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP - GET THE OTHP ID FOR THE PROBATION/PAROLE OFFICE';
            SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', OtherParty_NAME = ' + ISNULL(@Ls_DeljisCur_DeljisOfficer_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisOfficerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisOfficerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisOfficerCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisOfficerState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisOfficerZip_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_CountryUs_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_PhoneParoleOffice_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocDoc_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_DeljisCur_OfficerNormalization_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');

            EXECUTE BATCH_COMMON$SP_GET_OTHP
             @Ad_Run_DATE                     = @Ld_Run_DATE,
             @An_Fein_IDNO                    = @Ln_Zero_NUMB,
             @Ac_TypeOthp_CODE                = 'K',
             @As_OtherParty_NAME              = @Ls_DeljisCur_DeljisOfficer_NAME,
             @Ac_Aka_NAME                     = @Lc_Space_TEXT,
             @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
             @As_Line1_ADDR                   = @Ls_DeljisCur_DeljisOfficerLine1_ADDR,
             @As_Line2_ADDR                   = @Ls_DeljisCur_DeljisOfficerLine2_ADDR,
             @Ac_City_ADDR                    = @Lc_DeljisCur_DeljisOfficerCity_ADDR,
             @Ac_State_ADDR                   = @Lc_DeljisCur_DeljisOfficerState_ADDR,
             @Ac_Zip_ADDR                     = @Lc_DeljisCur_DeljisOfficerZip_ADDR,
             @Ac_Fips_CODE                    = @Lc_Space_TEXT,
             @Ac_Country_ADDR                 = @Lc_CountryUs_ADDR,
             @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
             @An_Phone_NUMB                   = @Ln_PhoneParoleOffice_NUMB,
             @An_Fax_NUMB                     = @Ln_Zero_NUMB,
             @As_Contact_EML                  = @Lc_Space_TEXT,
             @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
             @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
             @An_Sein_IDNO                    = @Ln_Zero_NUMB,
             @Ac_SourceLoc_CODE               = @Lc_SourceLocDoc_CODE,
             @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
             @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
             @Ac_Normalization_CODE           = @Lc_DeljisCur_OfficerNormalization_CODE,
             @Ac_Process_ID                   = @Lc_Job_ID,
             @An_OtherParty_IDNO              = @Ln_OthpPartyProbation_IDNO OUTPUT,
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
           END

          IF @Ln_Count_NUMB = 1
--13774 - Update MDET, only when any of the key fields value changes -START- 
			 AND @Lc_MdetUpdateFlag_INDC = 'N'
			 AND EXISTS
			 (
				SELECT 1
				FROM MDET_Y1 X
				WHERE X.MemberMci_IDNO = @Ln_MemberMci_IDNO
				AND X.EndValidity_DATE = @Ld_High_DATE
				AND
				(
					X.InstSbin_IDNO <> @Ln_InstSbin_IDNO
					OR (@Ln_Institution_IDNO > 0 AND X.Institution_IDNO <> @Ln_Institution_IDNO)
					OR UPPER(LTRIM(RTRIM(X.Institution_NAME))) <> LEFT(UPPER(LTRIM(RTRIM(@Ls_DeljisCur_DeljisFacility_NAME))), 30)
					OR X.Incarceration_DATE <> @Ld_Incarceration_DATE
					OR X.MaxRelease_DATE <> @Ld_MaxRelease_DATE
					OR X.WorkRelease_INDC <> @Lc_DeljisCur_DeljisWorkRelease_INDC
					OR X.Sentence_CODE <> RIGHT(('00' + LTRIM(RTRIM(@Lc_DeljisCur_DeljisTypeSentence_CODE))), 2)
					OR X.Release_DATE <> @Ld_Release_DATE
					OR X.OthpPartyProbation_IDNO <> @Ln_OthpPartyProbation_IDNO
				)
			 )
--13774 - Update MDET, only when any of the key fields value changes -END- 			 
           BEGIN
            SET @Ls_Sql_TEXT ='UPDATE MDET_Y1';
            SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

            UPDATE MDET_Y1
               SET EndValidity_DATE = @Ld_Run_DATE
             WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
               AND EndValidity_DATE = @Ld_High_DATE;

            SET @Ln_RowCount_QNTY = @@ROWCOUNT;

            IF @Ln_RowCount_QNTY = @Ln_Zero_NUMB
             BEGIN
              SET @Ls_ErrorMessage_TEXT = 'UPDATE MDET_Y1 FAILED!';

              RAISERROR(50001,16,1);
             END
--13774 - Update MDET, only when any of the key fields value changes -START-            
            SET @Lc_MdetUpdateFlag_INDC = 'Y';
--13774 - Update MDET, only when any of the key fields value changes -END-            
           END

--13774 - Update MDET, only when any of the key fields value changes -START-          
          IF @Ln_Count_NUMB = 0
			 OR @Lc_MdetUpdateFlag_INDC = 'Y'
           BEGIN
--13774 - Update MDET, only when any of the key fields value changes -END-			 
			  SET @Ls_Sql_TEXT = 'INSERT MDET_Y1';
			  SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Institution_IDNO = ' + ISNULL(CAST(@Ln_Institution_IDNO AS VARCHAR), '') + ', Institution_NAME = ' + ISNULL(@Ls_DeljisCur_DeljisFacility_NAME, '') + ', TypeInst_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', PoliceDept_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Institutionalized_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Incarceration_DATE = ' + ISNULL(CAST(@Ld_Incarceration_DATE AS VARCHAR), '') + ', Release_DATE = ' + ISNULL(CAST(@Ld_Release_DATE AS VARCHAR), '') + ', EligParole_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', MoveType_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Inmate_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', ParoleReason_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', InstSbin_IDNO = ' + ISNULL(CAST(@Ln_InstSbin_IDNO AS VARCHAR), '') + ', InstFbin_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', ParoleOfficer_NAME = ' + ISNULL(@Ls_DeljisCur_DeljisOfficer_NAME, '') + ', PhoneParoleOffice_NUMB = ' + ISNULL(CAST(@Ln_PhoneParoleOffice_NUMB AS VARCHAR), '') + ', DescriptionHold_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Sentence_CODE = ' + ISNULL(@Lc_DeljisCur_DeljisTypeSentence_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', ProbationOfficer_NAME = ' + ISNULL(@Ls_DeljisCur_DeljisOfficer_NAME, '') + ', MaxRelease_DATE = ' + ISNULL(CAST(@Ld_MaxRelease_DATE AS VARCHAR), '') + ', OthpPartyProbation_IDNO = ' + ISNULL(CAST(@Ln_OthpPartyProbation_IDNO AS VARCHAR), '') + ', WorkRelease_INDC = ' + ISNULL(@Lc_DeljisCur_DeljisWorkRelease_INDC, '') + ', InstitutionStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReleaseReason_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

			  INSERT INTO MDET_Y1
						  (MemberMci_IDNO,
						   Institution_IDNO,
						   Institution_NAME,
						   TypeInst_CODE,
						   PoliceDept_IDNO,
						   Institutionalized_DATE,
						   Incarceration_DATE,
						   Release_DATE,
						   EligParole_DATE,
						   MoveType_CODE,
						   Inmate_NUMB,
						   ParoleReason_CODE,
						   InstSbin_IDNO,
						   InstFbin_IDNO,
						   ParoleOfficer_NAME,
						   PhoneParoleOffice_NUMB,
						   DescriptionHold_TEXT,
						   Sentence_CODE,
						   WorkerUpdate_ID,
						   TransactionEventSeq_NUMB,
						   Update_DTTM,
						   BeginValidity_DATE,
						   EndValidity_DATE,
						   ProbationOfficer_NAME,
						   MaxRelease_DATE,
						   OthpPartyProbation_IDNO,
						   WorkRelease_INDC,
						   InstitutionStatus_CODE,
						   ReleaseReason_CODE)
			  SELECT @Ln_MemberMci_IDNO AS MemberMci_IDNO,
					 @Ln_Institution_IDNO AS Institution_IDNO,
					 CASE
					  WHEN LEN(LTRIM(RTRIM(@Ls_DeljisCur_DeljisFacility_NAME))) > 30
					   THEN LEFT(LTRIM(RTRIM(@Ls_DeljisCur_DeljisFacility_NAME)), 30)
					  ELSE LTRIM(RTRIM(@Ls_DeljisCur_DeljisFacility_NAME))
					 END AS Institution_NAME,
					 @Lc_Space_TEXT AS TypeInst_CODE,
					 @Ln_Zero_NUMB AS PoliceDept_IDNO,
					 @Ld_Low_DATE AS Institutionalized_DATE,
					 @Ld_Incarceration_DATE AS Incarceration_DATE,
					 @Ld_Release_DATE AS Release_DATE,
					 @Ld_Low_DATE AS EligParole_DATE,
					 @Lc_Space_TEXT AS MoveType_CODE,
					 @Ln_Zero_NUMB AS Inmate_NUMB,
					 @Lc_Space_TEXT AS ParoleReason_CODE,
					 @Ln_InstSbin_IDNO AS InstSbin_IDNO,
					 @Ln_Zero_NUMB AS InstFbin_IDNO,
					 @Ls_DeljisCur_DeljisOfficer_NAME AS ParoleOfficer_NAME,
					 @Ln_PhoneParoleOffice_NUMB AS PhoneParoleOffice_NUMB,
					 @Lc_Space_TEXT AS DescriptionHold_TEXT,
					 RIGHT(('00' + LTRIM(RTRIM(@Lc_DeljisCur_DeljisTypeSentence_CODE))), 2) AS Sentence_CODE,
					 @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
					 @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
					 @Ld_Start_DATE AS Update_DTTM,
					 @Ld_Run_DATE AS BeginValidity_DATE,
					 @Ld_High_DATE AS EndValidity_DATE,
					 @Ls_DeljisCur_DeljisOfficer_NAME AS ProbationOfficer_NAME,
					 @Ld_MaxRelease_DATE AS MaxRelease_DATE,
					 @Ln_OthpPartyProbation_IDNO AS OthpPartyProbation_IDNO,
					 @Lc_DeljisCur_DeljisWorkRelease_INDC AS WorkRelease_INDC,
					 @Lc_Space_TEXT AS InstitutionStatus_CODE,
					 @Lc_Space_TEXT AS ReleaseReason_CODE

			  SET @Ln_RowCount_QNTY = @@ROWCOUNT;

			  IF @Ln_RowCount_QNTY = @Ln_Zero_NUMB
			   BEGIN
				SET @Ls_ErrorMessage_TEXT = 'INSERT MDET_Y1 FAILED!';

				RAISERROR(50001,16,1);
			   END
--13774 - Update MDET, only when any of the key fields value changes -START- 			   
           END
--13774 - Update MDET, only when any of the key fields value changes -END-
           
          IF @Ln_Count_NUMB = 1
--13774 - Update MDET, only when any of the key fields value changes -START-          
			 AND @Lc_MdetUpdateFlag_INDC = 'Y'
--13774 - Update MDET, only when any of the key fields value changes -END-
             AND EXISTS(SELECT 1
                          FROM MDET_Y1 A
                         WHERE A.BeginValidity_DATE = @Ld_Run_DATE
                           AND A.EndValidity_DATE = @Ld_High_DATE
                           AND EXISTS(SELECT 1
                                        FROM MDET_Y1 X
                                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                         AND X.EndValidity_DATE = @Ld_Run_DATE
                                         AND (X.Incarceration_DATE <> A.Incarceration_DATE
                                               OR (A.Institution_IDNO > 0
                                                   AND X.Institution_IDNO <> A.Institution_IDNO))))
           BEGIN
            DECLARE OpenCasesCur INSENSITIVE CURSOR FOR
             SELECT DISTINCT
                    b.Case_IDNO
               FROM CMEM_Y1 a,
                    CASE_Y1 b
              WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
                AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                AND a.Case_IDNO = b.Case_IDNO
                AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                AND b.StatusCase_CODE = @Lc_StatusCaseO_CODE

            SET @Ls_Sql_TEXT = 'OPEN OpenCasesCur';

            OPEN OpenCasesCur;

            SET @Ls_Sql_TEXT = 'FETCH OpenCasesCur - 1';

            FETCH NEXT FROM OpenCasesCur INTO @Ln_OpenCasesCur_Case_IDNO;

            SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

            WHILE @Ln_FetchStatus_QNTY = 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - MDET - RINCR - LO';
              SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_OpenCasesCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

              EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
               @An_Case_IDNO                = @Ln_OpenCasesCur_Case_IDNO,
               @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
               @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
               @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRincr_CODE,
               @Ac_Subsystem_CODE           = @Lc_SubsystemLo_CODE,
               @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
               @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
--13719 - As part of CR0432, including run date in insert activity call for case journal entry -START-               
               @Ad_Run_DATE                 = @Ld_Run_DATE,
--13719 - As part of CR0432, including run date in insert activity call for case journal entry -END-               
               @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
               @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

                RAISERROR (50001,16,1);
               END;

              SET @Ls_Sql_TEXT = 'FETCH OpenCasesCur - 2';

              FETCH NEXT FROM OpenCasesCur INTO @Ln_OpenCasesCur_Case_IDNO;

              SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
             END

            CLOSE OpenCasesCur;

            DEALLOCATE OpenCasesCur;
           END

--13719 - Per CR0432, update enforcement status from WORK to UDOC when NCP is Incarcerated in any of these behind bars facilities -START-
			IF EXISTS
			(
				SELECT 1 FROM CASE_Y1 C
				WHERE C.Case_IDNO = @Ln_Case_IDNO
				AND C.StatusEnforce_CODE = @Lc_StatusEnforceWork_CODE
				AND EXISTS
				(
					SELECT 1 FROM MDET_Y1 A
					WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
					AND A.Institution_IDNO > 0
					AND EXISTS
					(
						SELECT 1 FROM REFM_Y1 X
						WHERE X.Table_ID = @Lc_TableOthp_ID
						AND X.TableSub_ID = @Lc_TableSubJail_ID
						AND CAST(X.Value_CODE AS NUMERIC) = A.Institution_IDNO
					)
					--AND A.BeginValidity_DATE = @Ld_Run_DATE
					AND A.EndValidity_DATE = @Ld_High_DATE
					AND A.Incarceration_DATE = @Ld_Incarceration_DATE
					AND A.Release_DATE = @Ld_High_DATE
				)
			)
			BEGIN
				SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1 - ENF STATUS - WORK TO UDOC';
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR);

				UPDATE c
				   SET c.StatusEnforce_CODE = @Lc_StatusEnforceUdoc_CODE,
					   c.BeginValidity_DATE = @Ld_Run_DATE,
					   c.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
					   c.Update_DTTM = @Ld_Start_DATE,
					   c.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB --Generated TransactioneventSeqNumb
				OUTPUT Deleted.Case_IDNO,
					   Deleted.StatusCase_CODE,
					   Deleted.TypeCase_CODE,
					   Deleted.RsnStatusCase_CODE,
					   Deleted.RespondInit_CODE,
					   Deleted.SourceRfrl_CODE,
					   Deleted.Opened_DATE,
					   Deleted.Marriage_DATE,
					   Deleted.Divorced_DATE,
					   Deleted.StatusCurrent_DATE,
					   Deleted.AprvIvd_DATE,
					   Deleted.County_IDNO,
					   Deleted.Office_IDNO,
					   Deleted.AssignedFips_CODE,
					   Deleted.GoodCause_CODE,
					   Deleted.GoodCause_DATE,
					   Deleted.Restricted_INDC,
					   Deleted.MedicalOnly_INDC,
					   Deleted.Jurisdiction_INDC,
					   Deleted.IvdApplicant_CODE,
					   Deleted.Application_IDNO,
					   Deleted.AppSent_DATE,
					   Deleted.AppReq_DATE,
					   Deleted.AppRetd_DATE,
					   Deleted.CpRelationshipToNcp_CODE,
					   Deleted.Worker_ID,
					   Deleted.AppSigned_DATE,
					   Deleted.ClientLitigantRole_CODE,
					   Deleted.DescriptionComments_TEXT,
					   Deleted.NonCoop_CODE,
					   Deleted.NonCoop_DATE,
					   Deleted.BeginValidity_DATE,
					   @Ld_Run_DATE AS EndValidity_DATE,
					   Deleted.WorkerUpdate_ID,
					   Deleted.TransactionEventSeq_NUMB,
					   Deleted.Update_DTTM,
					   Deleted.Referral_DATE,
					   Deleted.CaseCategory_CODE,
					   Deleted.File_ID,
					   Deleted.ApplicationFee_CODE,
					   Deleted.FeePaid_DATE,
					   Deleted.ServiceRequested_CODE,
					   Deleted.StatusEnforce_CODE,
					   Deleted.FeeCheckNo_TEXT,
					   Deleted.ReasonFeeWaived_CODE,
					   Deleted.Intercept_CODE
				INTO HCASE_Y1
				  FROM CASE_Y1 c
				 WHERE c.Case_IDNO = @Ln_Case_IDNO
				   AND c.StatusEnforce_CODE = @Lc_StatusEnforceWork_CODE

				SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - WORK TO UDOC - NCCHG - EN';
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

				EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
				 @An_Case_IDNO                = @Ln_Case_IDNO,
				 @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
				 @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
				 @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorNcchg_CODE,
				 @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
				 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				 @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
--13719 - As part of CR0432, including run date and note description in insert activity call for case journal entry -START-				 
				 @Ad_Run_DATE                 = @Ld_Run_DATE,
				 @As_DescriptionNote_TEXT     = @Ls_DescriptionNoteW2U_TEXT,
--13719 - As part of CR0432, including run date and note description in insert activity call for case journal entry -END-				 
                 @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
				 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				 BEGIN
				  SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

				  RAISERROR (50001,16,1);
				 END;
			END
--13719 - Per CR0432, update enforcement status from WORK to UDOC when NCP is Incarcerated in any of these behind bars facilities -END-
--13719 - Per CR0432, update enforcement status from UDOC to WORK when NCP is Released from any of these behind bars facilities -START-
			ELSE IF EXISTS
			(
				SELECT 1 FROM CASE_Y1 C
				WHERE C.Case_IDNO = @Ln_Case_IDNO
				AND C.StatusEnforce_CODE = @Lc_StatusEnforceUdoc_CODE
				AND EXISTS
				(
					SELECT 1 FROM MDET_Y1 A
					WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
					AND A.Institution_IDNO > 0
					AND EXISTS
					(
						SELECT 1 FROM REFM_Y1 X
						WHERE X.Table_ID = @Lc_TableOthp_ID
						AND X.TableSub_ID = @Lc_TableSubJail_ID
						AND CAST(X.Value_CODE AS NUMERIC) = A.Institution_IDNO
					)
					--AND A.BeginValidity_DATE = @Ld_Run_DATE
					AND A.EndValidity_DATE = @Ld_High_DATE
					AND A.Incarceration_DATE = @Ld_Incarceration_DATE
					AND A.Release_DATE <> @Ld_High_DATE
				)
			)
			BEGIN
				SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1 - ENF STATUS - UDOC TO WORK';
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR);

				UPDATE c
				   SET c.StatusEnforce_CODE = @Lc_StatusEnforceWork_CODE,
					   c.BeginValidity_DATE = @Ld_Run_DATE,
					   c.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
					   c.Update_DTTM = @Ld_Start_DATE,
					   c.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB --Generated TransactioneventSeqNumb
				OUTPUT Deleted.Case_IDNO,
					   Deleted.StatusCase_CODE,
					   Deleted.TypeCase_CODE,
					   Deleted.RsnStatusCase_CODE,
					   Deleted.RespondInit_CODE,
					   Deleted.SourceRfrl_CODE,
					   Deleted.Opened_DATE,
					   Deleted.Marriage_DATE,
					   Deleted.Divorced_DATE,
					   Deleted.StatusCurrent_DATE,
					   Deleted.AprvIvd_DATE,
					   Deleted.County_IDNO,
					   Deleted.Office_IDNO,
					   Deleted.AssignedFips_CODE,
					   Deleted.GoodCause_CODE,
					   Deleted.GoodCause_DATE,
					   Deleted.Restricted_INDC,
					   Deleted.MedicalOnly_INDC,
					   Deleted.Jurisdiction_INDC,
					   Deleted.IvdApplicant_CODE,
					   Deleted.Application_IDNO,
					   Deleted.AppSent_DATE,
					   Deleted.AppReq_DATE,
					   Deleted.AppRetd_DATE,
					   Deleted.CpRelationshipToNcp_CODE,
					   Deleted.Worker_ID,
					   Deleted.AppSigned_DATE,
					   Deleted.ClientLitigantRole_CODE,
					   Deleted.DescriptionComments_TEXT,
					   Deleted.NonCoop_CODE,
					   Deleted.NonCoop_DATE,
					   Deleted.BeginValidity_DATE,
					   @Ld_Run_DATE AS EndValidity_DATE,
					   Deleted.WorkerUpdate_ID,
					   Deleted.TransactionEventSeq_NUMB,
					   Deleted.Update_DTTM,
					   Deleted.Referral_DATE,
					   Deleted.CaseCategory_CODE,
					   Deleted.File_ID,
					   Deleted.ApplicationFee_CODE,
					   Deleted.FeePaid_DATE,
					   Deleted.ServiceRequested_CODE,
					   Deleted.StatusEnforce_CODE,
					   Deleted.FeeCheckNo_TEXT,
					   Deleted.ReasonFeeWaived_CODE,
					   Deleted.Intercept_CODE
				INTO HCASE_Y1
				  FROM CASE_Y1 c
				 WHERE c.Case_IDNO = @Ln_Case_IDNO
				   AND c.StatusEnforce_CODE = @Lc_StatusEnforceUdoc_CODE

				SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - UDOC TO WORK - NCCHG - EN';
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

				EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
				 @An_Case_IDNO                = @Ln_Case_IDNO,
				 @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
				 @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
				 @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorNcchg_CODE,
				 @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
				 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				 @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
--13719 - As part of CR0432, including run date and note description in insert activity call for case journal entry -START-				 
				 @Ad_Run_DATE                 = @Ld_Run_DATE,
				 @As_DescriptionNote_TEXT     = @Ls_DescriptionNoteU2W_TEXT,
--13719 - As part of CR0432, including run date and note description in insert activity call for case journal entry -END-				 
                 @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
				 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				 BEGIN
				  SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

				  RAISERROR (50001,16,1);
				 END;
			END
--13719 - Per CR0432, update enforcement status from UDOC to WORK when NCP is Released from any of these behind bars facilities -END-
         
         END

        IF LEN(LTRIM(RTRIM(ISNULL(@Ls_DeljisCur_DeljisLine1Ncp_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisCityNcp_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisStateNcp_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisZipNcp_ADDR, '')))) > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE - SUBJECT''S KNOWN ADDRESS';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressM_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisLine1Ncp_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisLine2Ncp_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisCityNcp_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisStateNcp_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisZipNcp_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_CountryUs_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocDoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusP_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_DeljisCur_NcpNormalization_CODE, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
           @As_Line1_ADDR                       = @Ls_DeljisCur_DeljisLine1Ncp_ADDR,
           @As_Line2_ADDR                       = @Ls_DeljisCur_DeljisLine2Ncp_ADDR,
           @Ac_City_ADDR                        = @Lc_DeljisCur_DeljisCityNcp_ADDR,
           @Ac_State_ADDR                       = @Lc_DeljisCur_DeljisStateNcp_ADDR,
           @Ac_Zip_ADDR                         = @Lc_DeljisCur_DeljisZipNcp_ADDR,
           @Ac_Country_ADDR                     = @Lc_CountryUs_ADDR,
           @An_Phone_NUMB                       = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_SourceLocDoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_StatusP_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
           @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
           @Ac_Process_ID                       = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Zero_NUMB,
           @Ac_Normalization_CODE               = @Lc_DeljisCur_NcpNormalization_CODE,
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

        IF LEN(LTRIM(RTRIM(ISNULL(@Ls_DeljisCur_DeljisEmployerLine1_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisEmployerCity_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisEmployerState_ADDR, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_DeljisCur_DeljisEmployerZip_ADDR, '')))) > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP - GET THE OTHP ID FOR THE SUBJECT''S EMPLOYER';
          SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', OtherParty_NAME = ' + ISNULL(@Lc_DeljisCur_DeljisEmployer_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisEmployerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DeljisCur_DeljisEmployerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisEmployerCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisEmployerState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DeljisCur_DeljisEmployerZip_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_CountryUs_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocDoc_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_DeljisCur_EmployerNormalization_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');

          EXECUTE BATCH_COMMON$SP_GET_OTHP
           @Ad_Run_DATE                     = @Ld_Run_DATE,
           @An_Fein_IDNO                    = @Ln_Zero_NUMB,
           @Ac_TypeOthp_CODE                = 'E',
           @As_OtherParty_NAME              = @Lc_DeljisCur_DeljisEmployer_NAME,
           @Ac_Aka_NAME                     = @Lc_Space_TEXT,
           @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
           @As_Line1_ADDR                   = @Ls_DeljisCur_DeljisEmployerLine1_ADDR,
           @As_Line2_ADDR                   = @Ls_DeljisCur_DeljisEmployerLine2_ADDR,
           @Ac_City_ADDR                    = @Lc_DeljisCur_DeljisEmployerCity_ADDR,
           @Ac_State_ADDR                   = @Lc_DeljisCur_DeljisEmployerState_ADDR,
           @Ac_Zip_ADDR                     = @Lc_DeljisCur_DeljisEmployerZip_ADDR,
           @Ac_Fips_CODE                    = @Lc_Space_TEXT,
           @Ac_Country_ADDR                 = @Lc_CountryUs_ADDR,
           @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
           @An_Phone_NUMB                   = @Ln_Zero_NUMB,
           @An_Fax_NUMB                     = @Ln_Zero_NUMB,
           @As_Contact_EML                  = @Lc_Space_TEXT,
           @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
           @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
           @An_Sein_IDNO                    = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE               = @Lc_SourceLocDoc_CODE,
           @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
           @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
           @Ac_Normalization_CODE           = @Lc_DeljisCur_EmployerNormalization_CODE,
           @Ac_Process_ID                   = @Lc_Job_ID,
           @An_OtherParty_IDNO              = @Ln_OthpPartyEmpl_IDNO OUTPUT,
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

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusP_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceLocDoc_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocDoc_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');

          EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
           @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
           @An_OthpPartyEmpl_IDNO         = @Ln_OthpPartyEmpl_IDNO,
           @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
           @Ac_Status_CODE                = @Lc_StatusP_CODE,
           @Ad_Status_DATE                = @Ld_Run_DATE,
           @Ac_TypeIncome_CODE            = @Lc_TypeIncomeEm_CODE,
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
           @Ac_SourceLoc_CODE             = @Lc_SourceLocDoc_CODE,
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
         END
       END

      SKIP_RECORD:
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_DELJIS;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

        RAISERROR(50001,16,1);
       END

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

     SET @Ls_Sql_TEXT = 'UPDATE LDLJS_Y1';
     SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_DeljisCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LDLJS_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_DeljisCur_Seq_IDNO;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE LDLJS_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';

     IF @Ln_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_DELJIS';

       COMMIT TRANSACTION TXN_PROCESS_DELJIS;

       SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_DELJIS';

       BEGIN TRANSACTION TXN_PROCESS_DELJIS;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION TXN_PROCESS_DELJIS;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Deljis_CUR - 2';

     FETCH NEXT FROM Deljis_CUR INTO @Ln_DeljisCur_Seq_IDNO, @Lc_DeljisCur_MemberMciIdno_TEXT, @Lc_DeljisCur_CaseIdno_TEXT, @Lc_DeljisCur_MemberSsn_TEXT, @Ls_DeljisCur_DeljisOfficer_NAME, @Lc_DeljisCur_DeljisOfficerPhoneNumb_TEXT, @Lc_DeljisCur_DeljisWarrant_INDC, @Lc_DeljisCur_DeljisIdno_TEXT, @Lc_DeljisCur_DeljisLicenseNo_TEXT, @Lc_DeljisCur_DeljisIncarcerationDate_TEXT, @Lc_DeljisCur_DeljisMaximumReleaseDate_TEXT, @Lc_DeljisCur_DeljisTypeSentence_CODE, @Lc_DeljisCur_DeljisReleaseDate_TEXT, @Lc_DeljisCur_DeljisInstitution_CODE, @Ls_DeljisCur_DeljisFacility_NAME, @Lc_DeljisCur_DeljisEmployer_NAME, @Lc_DeljisCur_DeljisNormalization_CODE, @Ls_DeljisCur_DeljisLine1_ADDR, @Ls_DeljisCur_DeljisLine2_ADDR, @Lc_DeljisCur_DeljisCity_ADDR, @Lc_DeljisCur_DeljisState_ADDR, @Lc_DeljisCur_DeljisZip_ADDR, @Lc_DeljisCur_OfficerNormalization_CODE, @Ls_DeljisCur_DeljisOfficerLine1_ADDR, @Ls_DeljisCur_DeljisOfficerLine2_ADDR, @Lc_DeljisCur_DeljisOfficerCity_ADDR, @Lc_DeljisCur_DeljisOfficerState_ADDR, @Lc_DeljisCur_DeljisOfficerZip_ADDR, @Lc_DeljisCur_NcpNormalization_CODE, @Ls_DeljisCur_DeljisLine1Ncp_ADDR, @Ls_DeljisCur_DeljisLine2Ncp_ADDR, @Lc_DeljisCur_DeljisCityNcp_ADDR, @Lc_DeljisCur_DeljisStateNcp_ADDR, @Lc_DeljisCur_DeljisZipNcp_ADDR, @Lc_DeljisCur_EmployerNormalization_CODE, @Ls_DeljisCur_DeljisEmployerLine1_ADDR, @Ls_DeljisCur_DeljisEmployerLine2_ADDR, @Lc_DeljisCur_DeljisEmployerCity_ADDR, @Lc_DeljisCur_DeljisEmployerState_ADDR, @Lc_DeljisCur_DeljisEmployerZip_ADDR, @Lc_DeljisCur_DeljisWorkRelease_INDC;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Deljis_CUR';

   CLOSE Deljis_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Deljis_CUR';

   DEALLOCATE Deljis_CUR;

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SELECT @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE,
            @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_DELJIS';

   COMMIT TRANSACTION TXN_PROCESS_DELJIS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_DELJIS;
    END;

   IF CURSOR_STATUS ('LOCAL', 'OpenCasesCur') IN (0, 1)
    BEGIN
     CLOSE OpenCasesCur;

     DEALLOCATE OpenCasesCur;
    END

   IF CURSOR_STATUS('Local', 'Deljis_CUR') IN (0, 1)
    BEGIN
     CLOSE Deljis_CUR;

     DEALLOCATE Deljis_CUR;
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
