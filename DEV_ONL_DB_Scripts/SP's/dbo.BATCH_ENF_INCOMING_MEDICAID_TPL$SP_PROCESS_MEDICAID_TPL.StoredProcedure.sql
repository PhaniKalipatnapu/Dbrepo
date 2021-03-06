/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_TPL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_TPL
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_TPL finds the exact match 
					  for the member details provided by the Medicaid and if match found, the records are updated 
					  with the details of the members to the Member Insurance details (MINS_Y1) 
					  and Dependent Insurance detail (DINS_Y1) database tables.
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
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_TPL]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_INDC                        CHAR = 'Y',
          @Lc_No_INDC                         CHAR = 'N',
          @Lc_MedicalIns_INDC                 CHAR = 'N',
          @Lc_DentalIns_INDC                  CHAR = 'N',
          @Lc_VisionIns_INDC                  CHAR = 'N',
          @Lc_PrescptIns_INDC                 CHAR = 'N',
          @Lc_MentalIns_INDC                  CHAR = 'N',
          @Lc_OtherIns_INDC                   CHAR = 'N',
          @Lc_MedicalInsOld_INDC              CHAR = 'N',
          @Lc_DentalInsOld_INDC               CHAR = 'N',
          @Lc_VisionInsOld_INDC               CHAR = 'N',
          @Lc_PrescptInsOld_INDC              CHAR = 'N',
          @Lc_MentalInsOld_INDC               CHAR = 'N',
          @Lc_OtherInsOld_INDC                CHAR = 'N',
          @Lc_RecordExists_INDC               CHAR = 'N',
          @Lc_IsCoverageDifferent_INDC        CHAR = 'N',
          @Lc_StatusP_CODE                    CHAR = 'P',
          @Lc_Note_INDC                       CHAR(1) = 'N',
          @Lc_CaseJournalEntryReqd_INDC       CHAR(1) = 'N',
          @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE          CHAR(1) = 'A',
          @Lc_TypeErrorE_CODE                 CHAR(1) = 'E',
          @Lc_ProcessY_INDC                   CHAR(1) = 'Y',
          @Lc_ProcessN_INDC                   CHAR(1) = 'N',
          @Lc_Space_TEXT                      CHAR(1) = ' ',
          @Lc_CaseMemberStatusA_CODE          CHAR(1) = 'A',
          @Lc_StatusCaseO_CODE                CHAR(1) = 'O',
          @Lc_CaseRelationshipA_CODE          CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE          CHAR(1) = 'P',
          @Lc_CaseRelationshipD_CODE          CHAR(1) = 'D',
          @Lc_CaseRelationshipC_CODE          CHAR(1) = 'C',
          @Lc_TypeOthpE_CODE                  CHAR(1) = 'E',
          @Lc_MemberFound_INDC                CHAR(1) = 'N',
          @Lc_SpecialNeeds_INDC               CHAR(1) = 'N',
          @Lc_TypePolicyG_CODE                CHAR(1) = 'G',
          @Lc_StatusCg_CODE                   CHAR(2) = 'CG',
          @Lc_Country_ADDR                    CHAR(2) = 'US',
          @Lc_TypeIncomeEm_CODE               CHAR(2) = 'EM',
          @Lc_PolicyHolderRelationshipSf_CODE CHAR(2) = 'SF',
          @Lc_SourceLocMed_CODE               CHAR(3) = 'MED',
          @Lc_InsSourceMe_CODE                CHAR(3) = 'ME',
          @Lc_SubsystemEn_CODE                CHAR(3) = 'EN',
          @Lc_ProcessDmma_ID                  CHAR(4) = 'DMMA',
          @Lc_ActivityMajorCase_CODE          CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO              CHAR(4) = ' ',
          @Lc_ActivityMinorMiifm_CODE         CHAR(5) = 'MIIFM',
          @Lc_BatchRunUser_TEXT               CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE             CHAR(5) = 'E0944',
          @Lc_BateErrorE0012_CODE             CHAR(5) = 'E0012',
          @Lc_BateErrorE0907_CODE             CHAR(5) = 'E0907',
          @Lc_BateErrorE0043_CODE             CHAR(5) = 'E0043',
          @Lc_BateErrorE0728_CODE             CHAR(5) = 'E0728',
          @Lc_BateErrorE0912_CODE             CHAR(5) = 'E0912',
          @Lc_BateErrorE0102_CODE             CHAR(5) = 'E0102',
          @Lc_BateErrorE1420_CODE             CHAR(5) = 'E1420',
          @Lc_BateErrorE0075_CODE             CHAR(5) = 'E0075',
          @Lc_BateErrorE1561_CODE             CHAR(5) = 'E1561',
          @Lc_BateErrorE1562_CODE             CHAR(5) = 'E1562',
          @Lc_BateErrorE1563_CODE             CHAR(5) = 'E1563',
          @Lc_BateErrorE1424_CODE             CHAR(5) = 'E1424',
          @Lc_Job_ID                          CHAR(7) = 'DEB6280',
          @Lc_Notice_ID                       CHAR(8) = NULL,
          @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
          @Lc_WorkerDelegate_ID               CHAR(30) = ' ',
          @Lc_Reference_ID                    CHAR(30) = ' ',
          @Lc_ParmDateProblem_TEXT            CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Contact_NAME                    VARCHAR(45) = ' ',
          @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_ENF_INCOMING_MEDICAID_TPL',
          @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS_MEDICAID_TPL',
          @Ls_XmlIn_TEXT                      VARCHAR(4000) = ' ',
          @Ld_Low_DATE                        DATE = '01/01/0001',
          @Ld_High_DATE                       DATE = '12/31/9999',
          @Ld_Invalid_DATE                    DATE = '1900-01-01';
  DECLARE @Ln_Zero_NUMB                       NUMERIC = 0,
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
          @Ln_OthpPartyEmpl_IDNO              NUMERIC(9) = 0,
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_InsuredMemberMci_IDNO           NUMERIC(10) = 0,
          @Ln_InsHolderMemberMci_IDNO         NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO                    NUMERIC(10) = 0,
          @Ln_Schedule_NUMB                   NUMERIC(10) = 0,
          @Ln_Topic_IDNO                      NUMERIC(10),
          @Ln_ErrorLine_NUMB                  NUMERIC(11) = 0,
          @Ln_Error_NUMB                      NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB        NUMERIC(19) = 0,
          @Li_StartPosition_NUMB              INT = 0,
          @Li_LastNameFoundPosition_NUMB      INT = 0,
          @Li_FullNameLength_NUMB             INT = 0,
          @Li_SpaceFoundPosition_NUMB         INT = 0,
          @Li_FetchStatus_QNTY                SMALLINT,
          @Li_RowCount_QNTY                   SMALLINT,
          @Lc_NonQualifiedOld_CODE            CHAR,
          @Lc_Empty_TEXT                      CHAR = '',
          @Lc_InsSourceOld_CODE               CHAR(3),
          @Lc_Msg_CODE                        CHAR(5),
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_InsHolderLast_NAME              CHAR(20) = '',
          @Ls_InsHolderFull_NAME              VARCHAR(100) = '',
          @Ls_Sql_TEXT                        VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT             VARCHAR(200),
          @Ls_SqlData_TEXT                    VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(2000),
          @Ls_DescriptionError_TEXT           VARCHAR(4000),
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ld_BeginOld_DATE                   DATE,
          @Ld_EndOld_DATE                     DATE,
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Start_DATE                      DATETIME2;
  DECLARE @Ln_TplCur_Seq_IDNO                           NUMERIC(19),
          @Lc_TplCur_Case_IDNO                          CHAR(10),
          @Lc_TplCur_InsuredMemberMci_IDNO              CHAR(10),
          @Lc_TplCur_InsuredMemberSsn_NUMB              CHAR(9),
          @Lc_TplCur_BirthInsured_DATE                  CHAR(8),
          @Lc_TplCur_LastInsured_NAME                   CHAR(20),
          @Lc_TplCur_FirstInsured_NAME                  CHAR(16),
          @Lc_TplCur_InsCompanyCarrier_CODE             CHAR(5),
          @Lc_TplCur_InsCompanyLocation_CODE            CHAR(4),
          @Lc_TplCur_InsHolderFull_NAME                 CHAR(35),
          @Lc_TplCur_InsHolderMemberSsn_NUMB            CHAR(9),
          @Lc_TplCur_InsHolderBirth_DATE                CHAR(8),
          @Lc_TplCur_InsHolderMemberMci_IDNO            CHAR(10),
          @Lc_TplCur_PolicyInsNo_TEXT                   CHAR(18),
          @Lc_TplCur_InsuranceGroupNo_TEXT              CHAR(17),
          @Lc_TplCur_Coverage_CODE                      CHAR(4),
          @Lc_TplCur_InsPolicyStatus_CODE               CHAR(1),
          @Lc_TplCur_InsPolicyVerification_INDC         CHAR(1),
          @Lc_TplCur_Begin_DATE                         CHAR(8),
          @Lc_TplCur_End_DATE                           CHAR(8),
          @Lc_TplCur_InsHolderRelationship_CODE         CHAR(2),
          @Lc_TplCur_InsHolderEmployer_NAME             CHAR(25),
          @Lc_TplCur_InsPolicyInfoAdd_DATE              CHAR(8),
          @Lc_TplCur_InsPolicyInfoModify_DATE           CHAR(8),
          @Lc_TplCur_InsHolderEmpAddrNormalization_CODE CHAR(1) = 'N',
          @Ls_TplCur_InsHolderEmpLine1_ADDR             VARCHAR(50),
          @Ls_TplCur_InsHolderEmpLine2_ADDR             VARCHAR(50),
          @Lc_TplCur_InsHolderEmpCity_ADDR              CHAR(28),
          @Lc_TplCur_InsHolderEmpState_ADDR             CHAR(2),
          @Lc_TplCur_InsHolderEmpZip_ADDR               CHAR(15),
          @Lc_TplCur_Process_INDC                       CHAR(1);
  DECLARE @Ln_IvdCaseCur_Case_IDNO         NUMERIC(6),
          @Ln_CaseMemberCur_Case_IDNO      NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO NUMERIC(10);
  DECLARE @Ln_TplCur_Case_IDNO               NUMERIC(10),
          @Ld_TplCur_InsHolderBirth_DATE     DATE = '01/01/0001',
          @Ln_TplCur_InsuredMemberMci_IDNO   NUMERIC(10),
          @Ln_TplCur_InsHolderMemberSsn_NUMB NUMERIC(9) = 0,
          @Ln_TplCur_InsHolderMemberMci_IDNO NUMERIC(10),
          @Ld_TplCur_Begin_DATE              DATE,
          @Ld_TplCur_End_DATE                DATE;
  DECLARE Tpl_CUR INSENSITIVE CURSOR FOR
   SELECT Seq_IDNO,
          Case_IDNO,
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
          InsPolicyInfoAdd_DATE,
          InsPolicyInfoModify_DATE,
          InsHolderEmpAddrNormalization_CODE,
          InsHolderEmpLine1_ADDR,
          InsHolderEmpLine2_ADDR,
          InsHolderEmpCity_ADDR,
          InsHolderEmpState_ADDR,
          InsHolderEmpZip_ADDR,
          Process_INDC
     FROM LMTPL_Y1
    WHERE Process_INDC = @Lc_ProcessN_INDC
    ORDER BY Seq_IDNO;

  CREATE TABLE #IvdCases_P1
   (
     MemberMci_IDNO NUMERIC(10),
     Case_IDNO      NUMERIC(6),
     IvdCase_INDC   CHAR(1)
   );

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_MEDICAID_TPL';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_PROCESS_MEDICAID_TPL;

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

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO PROCESS FROM LMTPL_Y1';
   SET @Ls_SqlData_TEXT = '';

   IF EXISTS (SELECT 1
                FROM LMTPL_Y1 A
               WHERE A.Process_INDC = @Lc_ProcessN_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'OPEN Tpl_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN Tpl_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Tpl_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM Tpl_CUR INTO @Ln_TplCur_Seq_IDNO, @Lc_TplCur_Case_IDNO, @Lc_TplCur_InsuredMemberMci_IDNO, @Lc_TplCur_InsuredMemberSsn_NUMB, @Lc_TplCur_BirthInsured_DATE, @Lc_TplCur_LastInsured_NAME, @Lc_TplCur_FirstInsured_NAME, @Lc_TplCur_InsCompanyCarrier_CODE, @Lc_TplCur_InsCompanyLocation_CODE, @Lc_TplCur_InsHolderFull_NAME, @Lc_TplCur_InsHolderMemberSsn_NUMB, @Lc_TplCur_InsHolderBirth_DATE, @Lc_TplCur_InsHolderMemberMci_IDNO, @Lc_TplCur_PolicyInsNo_TEXT, @Lc_TplCur_InsuranceGroupNo_TEXT, @Lc_TplCur_Coverage_CODE, @Lc_TplCur_InsPolicyStatus_CODE, @Lc_TplCur_InsPolicyVerification_INDC, @Lc_TplCur_Begin_DATE, @Lc_TplCur_End_DATE, @Lc_TplCur_InsHolderRelationship_CODE, @Lc_TplCur_InsHolderEmployer_NAME, @Lc_TplCur_InsPolicyInfoAdd_DATE, @Lc_TplCur_InsPolicyInfoModify_DATE, @Lc_TplCur_InsHolderEmpAddrNormalization_CODE, @Ls_TplCur_InsHolderEmpLine1_ADDR, @Ls_TplCur_InsHolderEmpLine2_ADDR, @Lc_TplCur_InsHolderEmpCity_ADDR, @Lc_TplCur_InsHolderEmpState_ADDR, @Lc_TplCur_InsHolderEmpZip_ADDR, @Lc_TplCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH Tpl_CUR';
     SET @Ls_SqlData_TEXT = '';

     --Process incoming records
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       BEGIN TRY
        SAVE TRANSACTION SAVE_PROCESS_MEDICAID_TPL;

        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
        SET @Ls_ErrorMessage_TEXT = '';
        SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
        SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
        SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
        SET @Ls_CursorLocation_TEXT = 'Tpl - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
        SET @Lc_CaseJournalEntryReqd_INDC = 'N';
        SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_TplCur_Seq_IDNO AS VARCHAR) + ', Case_IDNO = ' + @Lc_TplCur_Case_IDNO + ', InsuredMemberMci_IDNO = ' + @Lc_TplCur_InsuredMemberMci_IDNO + ', InsuredMemberSsn_NUMB = ' + @Lc_TplCur_InsuredMemberSsn_NUMB + ', BirthInsured_DATE = ' + @Lc_TplCur_BirthInsured_DATE + ', LastInsured_NAME = ' + @Lc_TplCur_LastInsured_NAME + ', FirstInsured_NAME = ' + @Lc_TplCur_FirstInsured_NAME + ', InsCompanyCarrier_CODE = ' + @Lc_TplCur_InsCompanyCarrier_CODE + ', InsCompanyLocation_CODE = ' + @Lc_TplCur_InsCompanyLocation_CODE + ', InsHolderFull_NAME = ' + @Lc_TplCur_InsHolderFull_NAME + ', InsHolderMemberSsn_NUMB = ' + @Lc_TplCur_InsHolderMemberSsn_NUMB + ', InsHolderBirth_DATE = ' + @Lc_TplCur_InsHolderBirth_DATE + ', InsHolderMemberMci_IDNO = ' + @Lc_TplCur_InsHolderMemberMci_IDNO + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT + ', Coverage_CODE = ' + @Lc_TplCur_Coverage_CODE + ', InsPolicyStatus_CODE = ' + @Lc_TplCur_InsPolicyStatus_CODE + ', InsPolicyVerification_INDC = ' + @Lc_TplCur_InsPolicyVerification_INDC + ', Begin_DATE = ' + @Lc_TplCur_Begin_DATE + ', End_DATE = ' + @Lc_TplCur_End_DATE + ', InsHolderRelationship_CODE = ' + @Lc_TplCur_InsHolderRelationship_CODE + ', InsHolderEmployer_NAME = ' + @Lc_TplCur_InsHolderEmployer_NAME + ', InsPolicyInfoAdd_DATE = ' + @Lc_TplCur_InsPolicyInfoAdd_DATE + ', InsPolicyInfoModify_DATE = ' + @Lc_TplCur_InsPolicyInfoModify_DATE + ', InsHolderEmpAddrNormalization_CODE = ' + @Lc_TplCur_InsHolderEmpAddrNormalization_CODE + ', InsHolderEmpLine1_ADDR = ' + @Ls_TplCur_InsHolderEmpLine1_ADDR + ', InsHolderEmpLine2_ADDR = ' + @Ls_TplCur_InsHolderEmpLine2_ADDR + ', InsHolderEmpCity_ADDR = ' + @Lc_TplCur_InsHolderEmpCity_ADDR + ', InsHolderEmpState_ADDR = ' + @Lc_TplCur_InsHolderEmpState_ADDR + ', InsHolderEmpZip_ADDR = ' + @Lc_TplCur_InsHolderEmpZip_ADDR + ', Process_INDC = ' + @Lc_TplCur_Process_INDC;
        SET @Ls_Sql_TEXT = 'DELETE #IvdCases_P1';
        SET @Ls_SqlData_TEXT = '';

        DELETE FROM #IvdCases_P1;

        SET @Ls_Sql_TEXT = 'CHECK DEPENDENT MCI NUMBER';
        SET @Ls_SqlData_TEXT = 'InsuredMemberMci_IDNO = ' + @Lc_TplCur_InsuredMemberMci_IDNO;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsuredMemberMci_IDNO, @Lc_Empty_TEXT)))) = 0
            OR ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsuredMemberMci_IDNO, @Lc_Empty_TEXT)))) = 0
            OR CAST(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsuredMemberMci_IDNO, @Lc_Empty_TEXT))) AS NUMERIC) = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0102_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INPUT INSURED MEMBER MCI # IS INVALID';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          SET @Ln_TplCur_InsuredMemberMci_IDNO = CAST(LTRIM(RTRIM(@Lc_TplCur_InsuredMemberMci_IDNO)) AS NUMERIC);
         END;

        SET @Ls_Sql_TEXT = 'CHECK DEPENDENT MCI NUMBER IN DEMO';
        SET @Ls_SqlData_TEXT = 'InsuredMemberMci_IDNO = ' + CAST(@Ln_TplCur_InsuredMemberMci_IDNO AS VARCHAR);

        IF NOT EXISTS(SELECT 1
                        FROM DEMO_Y1 X
                       WHERE X.MemberMci_IDNO = @Ln_TplCur_InsuredMemberMci_IDNO)
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE;
          SET @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          SET @Ln_InsuredMemberMci_IDNO = @Ln_TplCur_InsuredMemberMci_IDNO;
         END;

        SET @Ls_Sql_TEXT = 'CHECK INCOMING INSURANCE HOLDER SSN';
        SET @Ls_SqlData_TEXT = 'InsHolderMemberSsn_NUMB = ' + @Lc_TplCur_InsHolderMemberSsn_NUMB;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderMemberSsn_NUMB, @Lc_Empty_TEXT)))) > 0
           AND ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderMemberSsn_NUMB, @Lc_Empty_TEXT)))) > 0
           AND CAST(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderMemberSsn_NUMB, @Lc_Empty_TEXT))) AS NUMERIC) > 0
         BEGIN
          SET @Ln_TplCur_InsHolderMemberSsn_NUMB = CAST(LTRIM(RTRIM(@Lc_TplCur_InsHolderMemberSsn_NUMB)) AS NUMERIC);
         END
        ELSE
         BEGIN
          SET @Ln_TplCur_InsHolderMemberSsn_NUMB = @Ln_Zero_NUMB;
         END

        SET @Ls_Sql_TEXT = 'CHECK INCOMING INSURANCE HOLDER DOB';
        SET @Ls_SqlData_TEXT = 'InsHolderBirth_DATE = ' + @Lc_TplCur_InsHolderBirth_DATE;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderBirth_DATE, @Lc_Empty_TEXT)))) > 0
           AND ISDATE(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderBirth_DATE, @Lc_Empty_TEXT)))) > 0
         BEGIN
          SET @Ld_TplCur_InsHolderBirth_DATE = LTRIM(RTRIM(@Lc_TplCur_InsHolderBirth_DATE));
         END
        ELSE
         BEGIN
          SET @Ld_TplCur_InsHolderBirth_DATE = @Ld_Low_DATE;
         END;

        SET @Ls_Sql_TEXT = 'CHECK DEPENDENT MEDICAID CASE NUMBER';
        SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + @Lc_TplCur_Case_IDNO;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_Case_IDNO, @Lc_Empty_TEXT)))) = 0
            OR ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_TplCur_Case_IDNO, @Lc_Empty_TEXT)))) = 0
            OR CAST(LTRIM(RTRIM(ISNULL(@Lc_TplCur_Case_IDNO, @Lc_Empty_TEXT))) AS NUMERIC(10)) = 0
         BEGIN
          SET @Ln_TplCur_Case_IDNO = 0;
         END;
        ELSE
         BEGIN
          SET @Ln_TplCur_Case_IDNO = CAST(LTRIM(RTRIM(@Lc_TplCur_Case_IDNO)) AS NUMERIC(10));
         END;

        SET @Ls_Sql_TEXT = 'INSERT #IvdCases_P1 FROM MHIS_Y1';
        SET @Ls_SqlData_TEXT ='InsuredMemberMci_IDNO = ' + CAST(@Ln_TplCur_InsuredMemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_TplCur_Case_IDNO AS VARCHAR);

        INSERT #IvdCases_P1
               (MemberMci_IDNO,
                Case_IDNO,
                IvdCase_INDC)
        SELECT DISTINCT
               X.MemberMci_IDNO,
               X.Case_IDNO,
               @Lc_Yes_INDC
          FROM MHIS_Y1 X
         WHERE X.WelfareMemberMci_IDNO = @Ln_TplCur_InsuredMemberMci_IDNO
           AND X.CaseWelfare_IDNO = @Ln_TplCur_Case_IDNO;

        SET @Li_RowCount_QNTY = @@ROWCOUNT;

        IF @Li_RowCount_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT #IvdCases_P1 FROM CMEM_Y1';
          SET @Ls_SqlData_TEXT ='InsuredMemberMci_IDNO = ' + CAST(@Ln_TplCur_InsuredMemberMci_IDNO AS VARCHAR);

          INSERT #IvdCases_P1
                 (MemberMci_IDNO,
                  Case_IDNO,
                  IvdCase_INDC)
          SELECT DISTINCT
                 X.MemberMci_IDNO,
                 X.Case_IDNO,
                 @Lc_Yes_INDC
            FROM CMEM_Y1 X
           WHERE X.MemberMci_IDNO = @Ln_TplCur_InsuredMemberMci_IDNO
             AND EXISTS (SELECT 1
                           FROM CASE_Y1 Y
                          WHERE Y.Case_IDNO = X.Case_IDNO
                            AND Y.StatusCase_CODE = @Lc_StatusCaseO_CODE);

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE;
            SET @Ls_ErrorMessage_TEXT = 'INSURED MEMBER NEITHER IN MHIS NOR IN CMEM';

            RAISERROR(50001,16,1);
           END;
         END;

        SET @Ls_Sql_TEXT = 'DECLARE CaseMember_CUR';
        SET @Ls_SqlData_TEXT = '';

        DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
         SELECT MemberMci_IDNO,
                Case_IDNO
           FROM #IvdCases_P1
          WHERE IvdCase_INDC = @Lc_Yes_INDC;

        SET @Ls_Sql_TEXT = 'OPEN CaseMember_CUR';
        SET @Ls_SqlData_TEXT = '';

        OPEN CaseMember_CUR;

        SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 1';
        SET @Ls_SqlData_TEXT = '';

        FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_MemberMci_IDNO, @Ln_CaseMemberCur_Case_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        SET @Ls_Sql_TEXT = 'LOOP THROUGH CaseMember_CUR';
        SET @Ls_SqlData_TEXT = '';

        --
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'UPDATE #IvdCases_P1 - 1';
          SET @Ls_SqlData_TEXT ='MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR);

          UPDATE #IvdCases_P1
             SET IvdCase_INDC = @Lc_No_INDC
            FROM #IvdCases_P1 X
           WHERE X.Case_IDNO = @Ln_CaseMemberCur_Case_IDNO
             AND X.MemberMci_IDNO = @Ln_CaseMemberCur_MemberMci_IDNO
             AND NOT EXISTS (SELECT 1
                               FROM CMEM_Y1 Y
                              WHERE Y.Case_IDNO = X.Case_IDNO
                                AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                AND Y.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
                                AND Y.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                                AND EXISTS (SELECT 1
                                              FROM CASE_Y1 Z
                                             WHERE Z.Case_IDNO = Y.Case_IDNO
                                               AND Z.StatusCase_CODE = @Lc_StatusCaseO_CODE));

          SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 2';
          SET @Ls_SqlData_TEXT = '';

          FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_MemberMci_IDNO, @Ln_CaseMemberCur_Case_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END;

        SET @Ls_Sql_TEXT = 'CLOSE CaseMember_CUR';
        SET @Ls_SqlData_TEXT = '';

        CLOSE CaseMember_CUR;

        SET @Ls_Sql_TEXT = 'DEALLOCATE CaseMember_CUR';
        SET @Ls_SqlData_TEXT = '';

        DEALLOCATE CaseMember_CUR;

        SET @Ls_Sql_TEXT = 'CHECK #IvdCases_P1 - 1';
        SET @Ls_SqlData_TEXT = '';

        IF NOT EXISTS(SELECT 1
                        FROM #IvdCases_P1
                       WHERE IvdCase_INDC = @Lc_Yes_INDC)
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0075_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INSURED MEMBER IS NOT IN THE ROLE OF "DP" AND IS NOT ACTIVE ON THE CASE';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK MCI OF THE PERSON PROVIDING THE INSURANCE COVERAGE FOR THE DEPENDENT';
        SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + @Lc_TplCur_InsHolderMemberMci_IDNO;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderMemberMci_IDNO, @Lc_Empty_TEXT)))) > 0
           AND ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderMemberMci_IDNO, @Lc_Empty_TEXT)))) > 0
           AND CAST(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderMemberMci_IDNO, @Lc_Empty_TEXT))) AS NUMERIC) > 0
         BEGIN
          SET @Ln_TplCur_InsHolderMemberMci_IDNO = CAST(LTRIM(RTRIM(@Lc_TplCur_InsHolderMemberMci_IDNO)) AS NUMERIC);
          SET @Ls_Sql_TEXT = 'CHECK INSURANCE HOLDER MCI IN DEMO';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_TplCur_InsHolderMemberMci_IDNO AS VARCHAR);

          IF NOT EXISTS(SELECT 1
                          FROM DEMO_Y1 X
                         WHERE X.MemberMci_IDNO = @Ln_TplCur_InsHolderMemberMci_IDNO)
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE;
            SET @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND';

            RAISERROR(50001,16,1);
           END;
          ELSE
           BEGIN
            SET @Ln_InsHolderMemberMci_IDNO = @Ln_TplCur_InsHolderMemberMci_IDNO;
           END;
         END;
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'CHECK FULL NAME OF THE PERSON PROVIDING THE INSURANCE COVERAGE FOR THE DEPENDENT';
          SET @Ls_SqlData_TEXT ='InsHolderFull_NAME = ' + @Lc_TplCur_InsHolderFull_NAME;

          IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsHolderFull_NAME, @Lc_Empty_TEXT)))) > 0
           BEGIN
            SET @Lc_MemberFound_INDC = 'N';
            SET @Ls_InsHolderFull_NAME = LTRIM(RTRIM(@Lc_TplCur_InsHolderFull_NAME));
            SET @Li_FullNameLength_NUMB = LEN(@Ls_InsHolderFull_NAME);
            SET @Ls_Sql_TEXT = 'CHECK SSN OF THE PERSON PROVIDING THE INSURANCE COVERAGE FOR THE DEPENDENT';
            SET @Ls_SqlData_TEXT ='InsHolderMemberSsn_NUMB = ' + CAST(@Ln_TplCur_InsHolderMemberSsn_NUMB AS VARCHAR);

            IF @Ln_TplCur_InsHolderMemberSsn_NUMB > 0
             BEGIN
              SET @Ls_Sql_TEXT = 'CHECK EACH WORD FROM FULL NAME WITH LAST NAME IN DECSS';
              SET @Ls_SqlData_TEXT = 'InsHolderFull_NAME = ' + @Ls_InsHolderFull_NAME;

              --
              WHILE @Lc_MemberFound_INDC = 'N'
                    AND @Li_FullNameLength_NUMB > 0
               BEGIN
                SET @Li_SpaceFoundPosition_NUMB = CHARINDEX(@Lc_Space_TEXT, @Ls_InsHolderFull_NAME);

                IF @Li_SpaceFoundPosition_NUMB > 0
                 BEGIN
                  SET @Lc_InsHolderLast_NAME = LEFT(@Ls_InsHolderFull_NAME, (@Li_SpaceFoundPosition_NUMB - 1));
                  SET @Li_FullNameLength_NUMB = @Li_FullNameLength_NUMB - @Li_SpaceFoundPosition_NUMB;
                  SET @Li_StartPosition_NUMB = (@Li_SpaceFoundPosition_NUMB + 1);
                  SET @Ls_InsHolderFull_NAME = SUBSTRING(@Ls_InsHolderFull_NAME, @Li_StartPosition_NUMB, @Li_FullNameLength_NUMB);
                 END;
                ELSE
                 BEGIN
                  SET @Lc_InsHolderLast_NAME = @Ls_InsHolderFull_NAME;
                  SET @Li_FullNameLength_NUMB = @Ln_Zero_NUMB;
                  SET @Ls_InsHolderFull_NAME = @Lc_Empty_TEXT;
                 END;

                SET @Ls_Sql_TEXT = 'CHECK LAST NAME AND SSN IN DEMO';
                SET @Ls_SqlData_TEXT ='InsHolderLast_NAME = ' + @Lc_InsHolderLast_NAME + ', InsHolderMemberSsn_NUMB = ' + CAST(@Ln_TplCur_InsHolderMemberSsn_NUMB AS VARCHAR);

                SELECT @Lc_MemberFound_INDC = 'Y',
                       @Ln_InsHolderMemberMci_IDNO = X.MemberMci_IDNO
                  FROM DEMO_Y1 X
                 WHERE ISNULL(X.MemberMci_IDNO, 0) > 0
                   AND ISNULL(X.MemberSsn_NUMB, 0) > 0
                   AND X.MemberSsn_NUMB = @Ln_TplCur_InsHolderMemberSsn_NUMB
                   AND LEN(LTRIM(RTRIM(ISNULL(X.Last_NAME, @Lc_Empty_TEXT)))) > 0
                   AND (CASE
                         WHEN LEN(LTRIM(RTRIM(X.Last_NAME))) >= 5
                          THEN SUBSTRING(UPPER(LTRIM(RTRIM(X.Last_NAME))), 1, 5)
                         ELSE UPPER(LTRIM(RTRIM(X.Last_NAME)))
                        END) = (CASE
                                 WHEN LEN(LTRIM(RTRIM(@Lc_InsHolderLast_NAME))) >= 5
                                  THEN SUBSTRING(UPPER(LTRIM(RTRIM(@Lc_InsHolderLast_NAME))), 1, 5)
                                 ELSE UPPER(LTRIM(RTRIM(@Lc_InsHolderLast_NAME)))
                                END);
               END;

              IF @Lc_MemberFound_INDC = 'N'
               BEGIN
                SET @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE;
                SET @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND';

                RAISERROR(50001,16,1);
               END;
             END;
            ELSE IF @Ld_TplCur_InsHolderBirth_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE)
             BEGIN
              SET @Ls_Sql_TEXT = 'CHECK EACH WORD FROM FULL NAME WITH LAST NAME IN DECSS';
              SET @Ls_SqlData_TEXT = 'InsHolderFull_NAME = ' + @Ls_InsHolderFull_NAME;

              --
              WHILE @Lc_MemberFound_INDC = 'N'
                    AND @Li_FullNameLength_NUMB > 0
               BEGIN
                SET @Li_SpaceFoundPosition_NUMB = CHARINDEX(@Lc_Space_TEXT, @Ls_InsHolderFull_NAME);

                IF @Li_SpaceFoundPosition_NUMB > 0
                 BEGIN
                  SET @Lc_InsHolderLast_NAME = LEFT(@Ls_InsHolderFull_NAME, (@Li_SpaceFoundPosition_NUMB - 1));
                  SET @Li_FullNameLength_NUMB = @Li_FullNameLength_NUMB - @Li_SpaceFoundPosition_NUMB;
                  SET @Li_StartPosition_NUMB = (@Li_SpaceFoundPosition_NUMB + 1);
                  SET @Ls_InsHolderFull_NAME = SUBSTRING(@Ls_InsHolderFull_NAME, @Li_StartPosition_NUMB, @Li_FullNameLength_NUMB);
                 END;
                ELSE
                 BEGIN
                  SET @Lc_InsHolderLast_NAME = @Ls_InsHolderFull_NAME;
                  SET @Li_FullNameLength_NUMB = @Ln_Zero_NUMB;
                  SET @Ls_InsHolderFull_NAME = @Lc_Empty_TEXT;
                 END;

                SET @Ls_Sql_TEXT = 'CHECK LAST NAME AND DOB IN DEMO';
                SET @Ls_SqlData_TEXT ='InsHolderLast_NAME = ' + @Lc_InsHolderLast_NAME + ', InsHolderBirth_DATE = ' + CAST(@Ld_TplCur_InsHolderBirth_DATE AS VARCHAR);

                SELECT @Lc_MemberFound_INDC = 'Y',
                       @Ln_InsHolderMemberMci_IDNO = X.MemberMci_IDNO
                  FROM DEMO_Y1 X
                 WHERE ISNULL(X.MemberMci_IDNO, 0) > 0
                   AND ISNULL(X.Birth_DATE, @Lc_Empty_TEXT) NOT IN (@Ld_High_DATE, @Ld_Low_DATE, @Ld_Invalid_DATE)
                   AND X.Birth_DATE = @Ld_TplCur_InsHolderBirth_DATE
                   AND LEN(LTRIM(RTRIM(ISNULL(X.Last_NAME, @Lc_Empty_TEXT)))) > 0
                   AND (CASE
                         WHEN LEN(LTRIM(RTRIM(X.Last_NAME))) >= 5
                          THEN SUBSTRING(UPPER(LTRIM(RTRIM(X.Last_NAME))), 1, 5)
                         ELSE UPPER(LTRIM(RTRIM(X.Last_NAME)))
                        END) = (CASE
                                 WHEN LEN(LTRIM(RTRIM(@Lc_InsHolderLast_NAME))) >= 5
                                  THEN SUBSTRING(UPPER(LTRIM(RTRIM(@Lc_InsHolderLast_NAME))), 1, 5)
                                 ELSE UPPER(LTRIM(RTRIM(@Lc_InsHolderLast_NAME)))
                                END);
               END;

              IF @Lc_MemberFound_INDC = 'N'
               BEGIN
                SET @Lc_BateError_CODE = @Lc_BateErrorE0907_CODE;
                SET @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND';

                RAISERROR(50001,16,1);
               END;
             END;
           END;
         END;

        SET @Ls_Sql_TEXT = 'DECLARE IvdCase_CUR';
        SET @Ls_SqlData_TEXT = '';

        DECLARE IvdCase_CUR INSENSITIVE CURSOR FOR
         SELECT DISTINCT
                Case_IDNO
           FROM #IvdCases_P1
          WHERE IvdCase_INDC = @Lc_Yes_INDC;

        SET @Ls_Sql_TEXT = 'OPEN IvdCase_CUR';
        SET @Ls_SqlData_TEXT = '';

        OPEN IvdCase_CUR;

        SET @Ls_Sql_TEXT = 'FETCH NEXT FROM IvdCase_CUR - 1';
        SET @Ls_SqlData_TEXT = '';

        FETCH NEXT FROM IvdCase_CUR INTO @Ln_IvdCaseCur_Case_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        SET @Ls_Sql_TEXT = 'LOOP THROUGH IvdCase_CUR';
        SET @Ls_SqlData_TEXT = '';

        --
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'UPDATE #IvdCases_P1 - 2';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', IvdCaseCur_Case_IDNO = ' + CAST(@Ln_IvdCaseCur_Case_IDNO AS VARCHAR);

          UPDATE #IvdCases_P1
             SET IvdCase_INDC = @Lc_No_INDC
            FROM #IvdCases_P1 X
           WHERE X.Case_IDNO = @Ln_IvdCaseCur_Case_IDNO
             AND NOT EXISTS (SELECT 1
                               FROM CMEM_Y1 Y
                              WHERE Y.Case_IDNO = X.Case_IDNO
                                AND Y.MemberMci_IDNO = @Ln_InsHolderMemberMci_IDNO
                                AND Y.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE, @Lc_CaseRelationshipC_CODE)
                                AND Y.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                                AND EXISTS (SELECT 1
                                              FROM CASE_Y1 Z
                                             WHERE Z.Case_IDNO = Y.Case_IDNO
                                               AND Z.StatusCase_CODE = @Lc_StatusCaseO_CODE));

          SET @Ls_Sql_TEXT = 'FETCH NEXT FROM IvdCase_CUR - 2';
          SET @Ls_SqlData_TEXT = '';

          FETCH NEXT FROM IvdCase_CUR INTO @Ln_IvdCaseCur_Case_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END;

        SET @Ls_Sql_TEXT = 'CLOSE IvdCase_CUR';
        SET @Ls_SqlData_TEXT = '';

        CLOSE IvdCase_CUR;

        SET @Ls_Sql_TEXT = 'DEALLOCATE IvdCase_CUR';
        SET @Ls_SqlData_TEXT = '';

        DEALLOCATE IvdCase_CUR;

        SET @Ls_Sql_TEXT = 'CHECK #IvdCases_P1 - 2';
        SET @Ls_SqlData_TEXT = '';

        IF NOT EXISTS(SELECT 1
                        FROM #IvdCases_P1
                       WHERE IvdCase_INDC = @Lc_Yes_INDC)
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0075_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INSURANCE HOLDER IS NOT IN THE ROLE OF "NCP" OR "CP" AND IS NOT ACTIVE ON THE CASE';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INSURANCE COMPANY CARRIER CODE';
        SET @Ls_SqlData_TEXT ='InsCompanyCarrier_CODE = ' + @Lc_TplCur_InsCompanyCarrier_CODE;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsCompanyCarrier_CODE, @Lc_Empty_TEXT)))) = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE1561_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INPUT INSURANCE COMPANY CARRIER CODE IS INVALID';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INSURANCE COMPANY LOCATION CODE';
        SET @Ls_SqlData_TEXT ='InsCompanyLocation_CODE = ' + @Lc_TplCur_InsCompanyLocation_CODE;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsCompanyLocation_CODE, @Lc_Empty_TEXT)))) = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE1562_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INPUT INSURANCE COMPANY LOCATION CODE IS INVALID';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INPUT CARRIER CODE AND LOCATION CODE IN OTHP REFERENCE TABLE';
        SET @Ls_SqlData_TEXT ='InsCompanyCarrier_CODE = ' + @Lc_TplCur_InsCompanyCarrier_CODE + ', InsCompanyLocation_CODE = ' + @Lc_TplCur_InsCompanyLocation_CODE;
        SET @Ln_OtherParty_IDNO = @Ln_Zero_NUMB;

        SELECT @Ln_OtherParty_IDNO = ISNULL(X.OtherParty_IDNO, @Ln_Zero_NUMB)
          FROM OTHR_Y1 X
         WHERE UPPER(LTRIM(RTRIM(X.InsCompanyCarrier_CODE))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsCompanyCarrier_CODE)))
           AND UPPER(LTRIM(RTRIM(X.InsCompanyLocation_CODE))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsCompanyLocation_CODE)));

        IF @Ln_OtherParty_IDNO = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE1563_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INPUT CARRIER CODE AND LOCATION CODE NOT FOUND IN OTHP REFERENCE TABLE';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK OTHER PARTY ID IN OTHP';
        SET @Ls_SqlData_TEXT ='OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR);

        IF NOT EXISTS(SELECT 1
                        FROM OTHP_Y1 X
                       WHERE X.OtherParty_IDNO = @Ln_OtherParty_IDNO)
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0012_CODE;
          SET @Ls_ErrorMessage_TEXT = 'NO MATCHING RECORD FOUND';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INSURANCE POLICY NUMBER';
        SET @Ls_SqlData_TEXT ='PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_PolicyInsNo_TEXT, @Lc_Empty_TEXT)))) = 0
           AND LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_InsuranceGroupNo_TEXT, @Lc_Empty_TEXT)))) = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0912_CODE;
          SET @Ls_ErrorMessage_TEXT = 'EITHER GROUP NUMBER OR POLICY NUMBER IS REQUIRED';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INSURANCE COVERAGE BEGIN DATE FOR THE DEPENDENT ON RECORD';
        SET @Ls_SqlData_TEXT ='Begin_DATE = ' + @Lc_TplCur_Begin_DATE;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_Begin_DATE, @Lc_Empty_TEXT)))) > 0
           AND ISDATE(LTRIM(RTRIM(ISNULL(@Lc_TplCur_Begin_DATE, @Lc_Empty_TEXT)))) > 0
           AND CAST(LTRIM(RTRIM(ISNULL(@Lc_TplCur_Begin_DATE, @Lc_Empty_TEXT))) AS DATE) NOT IN (@Ld_High_DATE, @Ld_Low_DATE, @Ld_Invalid_DATE)
         BEGIN
          SET @Ld_TplCur_Begin_DATE = @Lc_TplCur_Begin_DATE;
         END;
        ELSE
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0043_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INPUT INSURANCE COVERAGE BEGIN DATE IS INVALID';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INSURANCE COVERAGE END DATE FOR THE DEPENDENT ON RECORD';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + @Lc_TplCur_End_DATE;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_TplCur_End_DATE, @Lc_Empty_TEXT)))) > 0
           AND ISDATE(LTRIM(RTRIM(ISNULL(@Lc_TplCur_End_DATE, @Lc_Empty_TEXT)))) > 0
           AND CAST(LTRIM(RTRIM(ISNULL(@Lc_TplCur_End_DATE, @Lc_Empty_TEXT))) AS DATE) NOT IN (@Ld_Low_DATE, @Ld_Invalid_DATE)
         BEGIN
          SET @Ld_TplCur_End_DATE = @Lc_TplCur_End_DATE;
         END;
        ELSE
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0043_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INPUT INSURANCE COVERAGE END DATE IS INVALID';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'SET INSURANCE POLICY COVERAGE INDICATORS';
        SET @Ls_SqlData_TEXT = 'Coverage_CODE = ' + @Lc_TplCur_Coverage_CODE;

        SELECT @Lc_MedicalIns_INDC = @Lc_No_INDC,
               @Lc_DentalIns_INDC = @Lc_No_INDC,
               @Lc_VisionIns_INDC = @Lc_No_INDC,
               @Lc_PrescptIns_INDC = @Lc_No_INDC,
               @Lc_MentalIns_INDC = @Lc_No_INDC,
               @Lc_OtherIns_INDC = @Lc_No_INDC;

        IF LEN(LTRIM(RTRIM(@Lc_TplCur_Coverage_CODE))) > 0
         BEGIN
          IF CAST(LTRIM(RTRIM(@Lc_TplCur_Coverage_CODE)) AS NUMERIC) IN (1, 2, 3, 4,
                                                                         5, 19, 30, 31, 35)
           BEGIN
            SET @Lc_MentalIns_INDC = @Lc_Yes_INDC;
           END;

          IF CAST(LTRIM(RTRIM(@Lc_TplCur_Coverage_CODE)) AS NUMERIC) IN (29, 36, 37, 38,
                                                                         42, 43)
           BEGIN
            SET @Lc_OtherIns_INDC = @Lc_Yes_INDC;
           END;

          IF CAST(LTRIM(RTRIM(@Lc_TplCur_Coverage_CODE)) AS NUMERIC) IN (1, 2, 3, 13,
                                                                         19, 21, 26, 32, 33)
           BEGIN
            SET @Lc_VisionIns_INDC = @Lc_Yes_INDC;
           END;

          IF CAST(LTRIM(RTRIM(@Lc_TplCur_Coverage_CODE)) AS NUMERIC) IN (1, 4, 11, 21,
                                                                         24, 26, 30)
           BEGIN
            SET @Lc_DentalIns_INDC = @Lc_Yes_INDC;
           END;

          IF CAST(LTRIM(RTRIM(@Lc_TplCur_Coverage_CODE)) AS NUMERIC) IN (1, 2, 4, 5,
                                                                         12, 18, 19, 31,
                                                                         32, 33, 34)
           BEGIN
            SET @Lc_PrescptIns_INDC = @Lc_Yes_INDC;
           END;

          IF CAST(LTRIM(RTRIM(@Lc_TplCur_Coverage_CODE)) AS NUMERIC) IN (1, 2, 3, 4,
                                                                         5, 6, 7, 8,
                                                                         9, 10, 17, 18,
                                                                         19, 21, 23, 24,
                                                                         25, 26, 30, 31,
                                                                         32, 33, 34, 39)
           BEGIN
            SET @Lc_MedicalIns_INDC = @Lc_Yes_INDC;
           END;
         END;

        SET @Ls_Sql_TEXT = 'CHECK INSURANCE POLICY COVERAGE TYPE';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + @Lc_TplCur_End_DATE;

        IF @Lc_MedicalIns_INDC = @Lc_No_INDC
           AND @Lc_DentalIns_INDC = @Lc_No_INDC
           AND @Lc_VisionIns_INDC = @Lc_No_INDC
           AND @Lc_PrescptIns_INDC = @Lc_No_INDC
           AND @Lc_MentalIns_INDC = @Lc_No_INDC
           AND @Lc_OtherIns_INDC = @Lc_No_INDC
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0728_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INVALID COVERAGE CODE';

          RAISERROR(50001,16,1);
         END;

        /*
        	If the insurance coverage end date in the incoming record 
        		is less than or equal to the batch run date and 
        	member 
        		exists with 
        			same policy number, 
        			group number 
        				in the Member Insurance (MINS_Y1) database table, then 
        					end date the record 
        						from Member Insurance (MINS_Y1) database table 
        							and proceed to next record in the temporary table
        */
        SET @Lc_RecordExists_INDC = @Lc_No_INDC;
        SET @Ls_Sql_TEXT = 'SELECT MINS_Y1';
        SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT;

        SELECT @Lc_RecordExists_INDC = @Lc_Yes_INDC,
               @Lc_MedicalInsOld_INDC = X.MedicalIns_INDC,
               @Lc_DentalInsOld_INDC = X.DentalIns_INDC,
               @Lc_VisionInsOld_INDC = X.VisionIns_INDC,
               @Lc_PrescptInsOld_INDC = X.PrescptIns_INDC,
               @Lc_MentalInsOld_INDC = X.MentalIns_INDC,
               @Lc_OtherInsOld_INDC = X.OtherIns_INDC,
               @Lc_NonQualifiedOld_CODE = X.NonQualified_CODE,
               @Lc_InsSourceOld_CODE = X.InsSource_CODE,
               @Ld_BeginOld_DATE = X.Begin_DATE,
               @Ld_EndOld_DATE = X.End_DATE,
               @Ls_Contact_NAME = X.Contact_NAME,
               @Lc_SpecialNeeds_INDC = X.SpecialNeeds_INDC
          FROM MINS_Y1 X
         WHERE X.MemberMci_IDNO = @Ln_InsHolderMemberMci_IDNO
           AND X.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
           AND UPPER(LTRIM(RTRIM(X.PolicyInsNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)))
           AND UPPER(LTRIM(RTRIM(X.InsuranceGroupNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)))
           AND X.EndValidity_DATE = @Ld_High_DATE
           AND X.Begin_DATE = (SELECT MAX(Y.Begin_DATE)
                                 FROM MINS_Y1 Y
                                WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                  AND Y.OthpInsurance_IDNO = X.OthpInsurance_IDNO
                                  AND Y.PolicyInsNo_TEXT = X.PolicyInsNo_TEXT
                                  AND Y.InsuranceGroupNo_TEXT = X.InsuranceGroupNo_TEXT
                                  AND Y.EndValidity_DATE = @Ld_High_DATE);

        SET @Ls_Sql_TEXT = 'CHECK IF INSURANCE COVERAGE END DATE IS LESS THAN OR EQUAL TO BATCH RUN DATE';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        IF @Ld_TplCur_End_DATE <= @Ld_Run_DATE
           AND @Lc_RecordExists_INDC = @Lc_Yes_INDC
         BEGIN
          SET @Ls_Sql_TEXT = 'UPDATE MINS_Y1 - 1';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT;

          UPDATE MINS_Y1
             SET End_DATE = @Ld_Run_DATE,
                 EndValidity_DATE = @Ld_Run_DATE
            FROM MINS_Y1 X
           WHERE X.MemberMci_IDNO = @Ln_InsHolderMemberMci_IDNO
             AND X.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
             AND UPPER(LTRIM(RTRIM(X.PolicyInsNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)))
             AND UPPER(LTRIM(RTRIM(X.InsuranceGroupNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)))
             AND X.EndValidity_DATE = @Ld_High_DATE
             AND X.Begin_DATE = @Ld_BeginOld_DATE;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'UPDATE MINS_Y1 FAILED - 1';

            RAISERROR(50001,16,1);
           END;

          SET @Lc_CaseJournalEntryReqd_INDC = 'Y';
         END;

        /*
        	If the insurance coverage end date in the incoming record 
        		is greater than batch run date 
        	and member 
        		exists with 
        			same insurance policy number, 
        			group number 
        			but different coverage type 
        				in Member Insurance (MINS_Y1) database table then 
        					compare the insurance coverage begin date of incoming record 
        						with the insurance coverage begin date in the Member Insurance (MINS_Y1) database table. 
        					If begin date in the incoming record 
        						is most recent then 
        							end date the existing record in MINS_Y1 table and 
        							insert a new record in Member Insurance (MINS_Y1) database table, 
        						otherwise 
        							read next record from the temporary table.	
        */
        SET @Lc_IsCoverageDifferent_INDC = @Lc_No_INDC;
        SET @Ls_Sql_TEXT = 'CHECK IF INCOMING COVERAGE IS DIFFERENT FROM EXISTING COVERAGE';

        IF @Lc_MedicalInsOld_INDC <> @Lc_MedicalIns_INDC
            OR @Lc_DentalInsOld_INDC <> @Lc_DentalIns_INDC
            OR @Lc_VisionInsOld_INDC <> @Lc_VisionIns_INDC
            OR @Lc_PrescptInsOld_INDC <> @Lc_PrescptIns_INDC
            OR @Lc_MentalInsOld_INDC <> @Lc_MentalIns_INDC
            OR @Lc_OtherInsOld_INDC <> @Lc_OtherIns_INDC
         BEGIN
          SET @Lc_IsCoverageDifferent_INDC = @Lc_Yes_INDC;
         END;

        SET @Ls_Sql_TEXT = 'CHECK IF INSURANCE COVERAGE END DATE IS GREATER THAN BATCH RUN DATE - 1';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        IF @Ld_TplCur_End_DATE > @Ld_Run_DATE
           AND @Lc_RecordExists_INDC = @Lc_Yes_INDC
           AND @Lc_IsCoverageDifferent_INDC = @Lc_Yes_INDC
           AND DATEDIFF(D, @Ld_BeginOld_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) > DATEDIFF(D, @Ld_TplCur_Begin_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
         BEGIN
          SET @Ls_Sql_TEXT = 'UPDATE MINS_Y1 - 2';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT;

          UPDATE MINS_Y1
             SET End_DATE = @Ld_Run_DATE,
                 EndValidity_DATE = @Ld_Run_DATE
            FROM MINS_Y1 X
           WHERE X.MemberMci_IDNO = @Ln_InsHolderMemberMci_IDNO
             AND X.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
             AND UPPER(LTRIM(RTRIM(X.PolicyInsNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)))
             AND UPPER(LTRIM(RTRIM(X.InsuranceGroupNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)))
             AND X.EndValidity_DATE = @Ld_High_DATE
             AND X.Begin_DATE = @Ld_BeginOld_DATE;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'UPDATE MINS_Y1 FAILED - 2';

            RAISERROR(50001,16,1);
           END;

          --Generate Sequence 
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

          SET @Ls_Sql_TEXT = 'INSERT MINS_Y1';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT + ', Begin_DATE = ' + CAST(@Ld_TplCur_Begin_DATE AS VARCHAR) + ', End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', MedicalIns_INDC = ' + @Lc_MedicalIns_INDC + ', DentalIns_INDC = ' + @Lc_DentalIns_INDC + ', VisionIns_INDC = ' + @Lc_VisionIns_INDC + ', PrescptIns_INDC = ' + @Lc_PrescptIns_INDC + ', MentalIns_INDC = ' + @Lc_MentalIns_INDC + ', Status_CODE = ' + @Lc_StatusCg_CODE + ', InsSource_CODE = ' + @Lc_InsSourceMe_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR);

          INSERT MINS_Y1
                 (MemberMci_IDNO,
                  OthpInsurance_IDNO,
                  InsuranceGroupNo_TEXT,
                  PolicyInsNo_TEXT,
                  Begin_DATE,
                  End_DATE,
                  Status_DATE,
                  MedicalIns_INDC,
                  DentalIns_INDC,
                  VisionIns_INDC,
                  PrescptIns_INDC,
                  MentalIns_INDC,
                  OtherIns_INDC,
                  DescriptionOtherIns_TEXT,
                  Status_CODE,
                  NonQualified_CODE,
                  InsSource_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  SourceVerified_CODE,
                  PolicyHolderRelationship_CODE,
                  TypePolicy_CODE,
                  EmployerPaid_INDC,
                  DescriptionCoverage_TEXT,
                  MonthlyPremium_AMNT,
                  Contact_NAME,
                  SpecialNeeds_INDC,
                  CoPay_AMNT,
                  OthpEmployer_IDNO,
                  PolicyHolder_NAME,
                  PolicyHolderSsn_NUMB,
                  BirthPolicyHolder_DATE,
                  PolicyAnnivMonth_CODE)
          VALUES (@Ln_InsHolderMemberMci_IDNO,--MemberMci_IDNO
                  @Ln_OtherParty_IDNO,--OthpInsurance_IDNO
                  LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)),--InsuranceGroupNo_TEXT
                  LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)),--PolicyInsNo_TEXT
                  ISNULL(@Ld_TplCur_Begin_DATE, @Ld_Run_DATE),--Begin_DATE
                  ISNULL(@Ld_TplCur_End_DATE, @Ld_High_DATE),--End_DATE
                  @Ld_Run_DATE,--Status_DATE
                  @Lc_MedicalIns_INDC,--MedicalIns_INDC
                  @Lc_DentalIns_INDC,--DentalIns_INDC
                  @Lc_VisionIns_INDC,--VisionIns_INDC
                  @Lc_PrescptIns_INDC,--PrescptIns_INDC
                  @Lc_MentalIns_INDC,--MentalIns_INDC
                  @Lc_OtherIns_INDC,--OtherIns_INDC
                  @Lc_Space_TEXT,--DescriptionOtherIns_TEXT
                  @Lc_StatusCg_CODE,--Status_CODE
                  @Lc_NonQualifiedOld_CODE,--NonQualified_CODE
                  @Lc_InsSourceMe_CODE,--InsSource_CODE
                  @Ld_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                  @Ld_Start_DATE,--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  @Lc_InsSourceMe_CODE,--SourceVerified_CODE
                  @Lc_PolicyHolderRelationshipSf_CODE,--PolicyHolderRelationship_CODE
                  @Lc_TypePolicyG_CODE,--TypePolicy_CODE
                  @Lc_Space_TEXT,--EmployerPaid_INDC
                  @Lc_Space_TEXT,--DescriptionCoverage_TEXT
                  @Ln_Zero_NUMB,--MonthlyPremium_AMNT
                  @Ls_Contact_NAME,--Contact_NAME
                  @Lc_SpecialNeeds_INDC,--SpecialNeeds_INDC
                  @Ln_Zero_NUMB,--CoPay_AMNT
                  @Ln_Zero_NUMB,--OthpEmployer_IDNO
                  @Lc_TplCur_InsHolderFull_NAME,--PolicyHolder_NAME
                  @Ln_TplCur_InsHolderMemberSsn_NUMB,--PolicyHolderSsn_NUMB
                  @Ld_TplCur_InsHolderBirth_DATE,--BirthPolicyHolder_DATE
                  @Lc_Space_TEXT --PolicyAnnivMonth_CODE						
          );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT MINS_Y1 FAILED - 1';

            RAISERROR(50001,16,1);
           END;

          SET @Lc_CaseJournalEntryReqd_INDC = 'Y';
         END;

        /*
        	If the insurance coverage end date in the incoming record 
        		is greater 
        			than batch run date and 
        			member is not found with 
        				insurance policy number, 
        				group number 
        					in Member Insurance (MINS_Y1) database table then 
        						insert a new record in Member Insurance (MINS_Y1) database table
        */
        SET @Ls_Sql_TEXT = 'CHECK IF INSURANCE COVERAGE END DATE IS GREATER THAN BATCH RUN DATE - 2';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        IF @Ld_TplCur_End_DATE > @Ld_Run_DATE
           AND @Lc_RecordExists_INDC = @Lc_No_INDC
         BEGIN
          --Generate Sequence 
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

          SET @Ls_Sql_TEXT = 'INSERT MINS_Y1';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT + ', Begin_DATE = ' + CAST(@Ld_TplCur_Begin_DATE AS VARCHAR) + ', End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', MedicalIns_INDC = ' + @Lc_MedicalIns_INDC + ', DentalIns_INDC = ' + @Lc_DentalIns_INDC + ', VisionIns_INDC = ' + @Lc_VisionIns_INDC + ', PrescptIns_INDC = ' + @Lc_PrescptIns_INDC + ', MentalIns_INDC = ' + @Lc_MentalIns_INDC + ', Status_CODE = ' + @Lc_StatusCg_CODE + ', InsSource_CODE = ' + @Lc_InsSourceMe_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR);

          INSERT MINS_Y1
                 (MemberMci_IDNO,
                  OthpInsurance_IDNO,
                  InsuranceGroupNo_TEXT,
                  PolicyInsNo_TEXT,
                  Begin_DATE,
                  End_DATE,
                  Status_DATE,
                  MedicalIns_INDC,
                  DentalIns_INDC,
                  VisionIns_INDC,
                  PrescptIns_INDC,
                  MentalIns_INDC,
                  OtherIns_INDC,
                  DescriptionOtherIns_TEXT,
                  Status_CODE,
                  NonQualified_CODE,
                  InsSource_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  SourceVerified_CODE,
                  PolicyHolderRelationship_CODE,
                  TypePolicy_CODE,
                  EmployerPaid_INDC,
                  DescriptionCoverage_TEXT,
                  MonthlyPremium_AMNT,
                  Contact_NAME,
                  SpecialNeeds_INDC,
                  CoPay_AMNT,
                  OthpEmployer_IDNO,
                  PolicyHolder_NAME,
                  PolicyHolderSsn_NUMB,
                  BirthPolicyHolder_DATE,
                  PolicyAnnivMonth_CODE)
          VALUES (@Ln_InsHolderMemberMci_IDNO,--MemberMci_IDNO
                  @Ln_OtherParty_IDNO,--OthpInsurance_IDNO
                  LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)),--InsuranceGroupNo_TEXT
                  LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)),--PolicyInsNo_TEXT
                  ISNULL(@Ld_TplCur_Begin_DATE, @Ld_Run_DATE),--Begin_DATE
                  ISNULL(@Ld_TplCur_End_DATE, @Ld_High_DATE),--End_DATE
                  @Ld_Run_DATE,--Status_DATE
                  @Lc_MedicalIns_INDC,--MedicalIns_INDC
                  @Lc_DentalIns_INDC,--DentalIns_INDC
                  @Lc_VisionIns_INDC,--VisionIns_INDC
                  @Lc_PrescptIns_INDC,--PrescptIns_INDC
                  @Lc_MentalIns_INDC,--MentalIns_INDC
                  @Lc_OtherIns_INDC,--OtherIns_INDC
                  @Lc_Space_TEXT,--DescriptionOtherIns_TEXT
                  @Lc_StatusCg_CODE,--Status_CODE
                  @Lc_Space_TEXT,--NonQualified_CODE
                  @Lc_InsSourceMe_CODE,--InsSource_CODE
                  @Ld_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                  @Ld_Start_DATE,--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  @Lc_InsSourceMe_CODE,--SourceVerified_CODE
                  @Lc_PolicyHolderRelationshipSf_CODE,--PolicyHolderRelationship_CODE
                  @Lc_TypePolicyG_CODE,--TypePolicy_CODE
                  @Lc_Space_TEXT,--EmployerPaid_INDC
                  @Lc_Space_TEXT,--DescriptionCoverage_TEXT
                  @Ln_Zero_NUMB,--MonthlyPremium_AMNT
                  @Ls_Contact_NAME,--Contact_NAME
                  @Lc_SpecialNeeds_INDC,--SpecialNeeds_INDC
                  @Ln_Zero_NUMB,--CoPay_AMNT
                  @Ln_Zero_NUMB,--OthpEmployer_IDNO
                  @Lc_TplCur_InsHolderFull_NAME,--PolicyHolder_NAME
                  @Ln_TplCur_InsHolderMemberSsn_NUMB,--PolicyHolderSsn_NUMB
                  @Ld_TplCur_InsHolderBirth_DATE,--BirthPolicyHolder_DATE
                  @Lc_Space_TEXT --PolicyAnnivMonth_CODE						
          );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT MINS_Y1 FAILED - 2';

            RAISERROR(50001,16,1);
           END;

          SET @Lc_CaseJournalEntryReqd_INDC = 'Y';
         END;

        /*
        	If the insurance coverage end date in the incoming record 
        		is less than or equal to the batch run date and 
        	insured member 
        		exists with 
        			same policy number, 
        			group number 
        				in the Dependent Insurance (DINS_Y1) database table, then 
        					end date the record 
        						from Dependent Insurance (DINS_Y1) database table 
        							and proceed to next record in the temporary table
        */
        SET @Lc_RecordExists_INDC = @Lc_No_INDC;
        SET @Ls_Sql_TEXT = 'SELECT DINS';
        SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT;

        SELECT @Lc_RecordExists_INDC = @Lc_Yes_INDC,
               @Lc_MedicalInsOld_INDC = X.MedicalIns_INDC,
               @Lc_DentalInsOld_INDC = X.DentalIns_INDC,
               @Lc_VisionInsOld_INDC = X.VisionIns_INDC,
               @Lc_PrescptInsOld_INDC = X.PrescptIns_INDC,
               @Lc_MentalInsOld_INDC = X.MentalIns_INDC,
               @Lc_NonQualifiedOld_CODE = X.NonQualified_CODE,
               @Lc_InsSourceOld_CODE = X.InsSource_CODE,
               @Ld_BeginOld_DATE = X.Begin_DATE,
               @Ld_EndOld_DATE = X.End_DATE
          FROM DINS_Y1 X
         WHERE X.MemberMci_IDNO = @Ln_InsHolderMemberMci_IDNO
           AND X.ChildMCI_IDNO = @Ln_InsuredMemberMci_IDNO
           AND X.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
           AND UPPER(LTRIM(RTRIM(X.PolicyInsNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)))
           AND UPPER(LTRIM(RTRIM(X.InsuranceGroupNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)))
           AND X.EndValidity_DATE = @Ld_High_DATE
           AND X.Begin_DATE = (SELECT MAX(Y.Begin_DATE)
                                 FROM DINS_Y1 Y
                                WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                  AND Y.ChildMCI_IDNO = X.ChildMCI_IDNO
                                  AND Y.OthpInsurance_IDNO = X.OthpInsurance_IDNO
                                  AND Y.PolicyInsNo_TEXT = X.PolicyInsNo_TEXT
                                  AND Y.InsuranceGroupNo_TEXT = X.InsuranceGroupNo_TEXT
                                  AND Y.EndValidity_DATE = @Ld_High_DATE);

        SET @Ls_Sql_TEXT = 'CHECK IF INSURANCE COVERAGE END DATE IS LESS THAN OR EQUAL TO BATCH RUN DATE';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        IF @Ld_TplCur_End_DATE <= @Ld_Run_DATE
           AND @Lc_RecordExists_INDC = @Lc_Yes_INDC
         BEGIN
          SET @Ls_Sql_TEXT = 'UPDATE DINS - 1';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT;

          UPDATE DINS_Y1
             SET End_DATE = @Ld_Run_DATE,
                 EndValidity_DATE = @Ld_Run_DATE
            FROM DINS_Y1 X
           WHERE X.MemberMci_IDNO = @Ln_InsHolderMemberMci_IDNO
             AND X.ChildMCI_IDNO = @Ln_InsuredMemberMci_IDNO
             AND X.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
             AND UPPER(LTRIM(RTRIM(X.PolicyInsNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)))
             AND UPPER(LTRIM(RTRIM(X.InsuranceGroupNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)))
             AND X.EndValidity_DATE = @Ld_High_DATE
             AND X.Begin_DATE = @Ld_BeginOld_DATE;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'UPDATE DINS_Y1 FAILED - 1';

            RAISERROR(50001,16,1);
           END;

          SET @Lc_CaseJournalEntryReqd_INDC = 'Y';
         END;

        /*
        	If the insurance coverage end date in the incoming record 
        		is greater than batch run date 
        	and insured member 
        		exists with 
        			same insurance policy number, 
        			group number 
        			but different coverage type 
        				in Dependent Insurance (DINS_Y1) database table then 
        					compare the insurance coverage begin date of incoming record 
        						with the insurance coverage begin date in the Dependent Insurance (DINS_Y1) database table. 
        					If begin date in the incoming record 
        						is most recent then 
        							end date the existing record in DINS_Y1 table and 
        							insert a new record in Dependent Insurance (DINS_Y1) database table, 
        						otherwise 
        							read next record from the temporary table.	
        */
        SET @Lc_IsCoverageDifferent_INDC = @Lc_No_INDC;
        SET @Ls_Sql_TEXT = 'CHECK IF INCOMING COVERAGE IS DIFFERENT FROM EXISTING COVERAGE';

        IF @Lc_MedicalInsOld_INDC = @Lc_MedicalIns_INDC
            OR @Lc_DentalInsOld_INDC = @Lc_DentalIns_INDC
            OR @Lc_VisionInsOld_INDC = @Lc_VisionIns_INDC
            OR @Lc_PrescptInsOld_INDC = @Lc_PrescptIns_INDC
            OR @Lc_MentalInsOld_INDC = @Lc_MentalIns_INDC
         BEGIN
          SET @Lc_IsCoverageDifferent_INDC = @Lc_Yes_INDC;
         END;

        SET @Ls_Sql_TEXT = 'CHECK IF INSURANCE COVERAGE END DATE IS GREATER THAN BATCH RUN DATE - 1';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        IF @Ld_TplCur_End_DATE > @Ld_Run_DATE
           AND @Lc_RecordExists_INDC = @Lc_Yes_INDC
           AND @Lc_IsCoverageDifferent_INDC = @Lc_Yes_INDC
           AND DATEDIFF(D, @Ld_BeginOld_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) > DATEDIFF(D, @Ld_TplCur_Begin_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
         BEGIN
          SET @Ls_Sql_TEXT = 'UPDATE DINS - 2';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT;

          UPDATE DINS_Y1
             SET End_DATE = @Ld_Run_DATE,
                 EndValidity_DATE = @Ld_Run_DATE
            FROM DINS_Y1 X
           WHERE X.MemberMci_IDNO = @Ln_InsHolderMemberMci_IDNO
             AND X.ChildMCI_IDNO = @Ln_InsuredMemberMci_IDNO
             AND X.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
             AND UPPER(LTRIM(RTRIM(X.PolicyInsNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)))
             AND UPPER(LTRIM(RTRIM(X.InsuranceGroupNo_TEXT))) = UPPER(LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)))
             AND X.EndValidity_DATE = @Ld_High_DATE
             AND X.Begin_DATE = @Ld_BeginOld_DATE;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'UPDATE DINS_Y1 FAILED - 2';

            RAISERROR(50001,16,1);
           END;

          --Generate Sequence 
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

          SET @Ls_Sql_TEXT = 'INSERT DINS';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT + ', Begin_DATE = ' + CAST(@Ld_TplCur_Begin_DATE AS VARCHAR) + ', End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', MedicalIns_INDC = ' + @Lc_MedicalIns_INDC + ', DentalIns_INDC = ' + @Lc_DentalIns_INDC + ', VisionIns_INDC = ' + @Lc_VisionIns_INDC + ', PrescptIns_INDC = ' + @Lc_PrescptIns_INDC + ', MentalIns_INDC = ' + @Lc_MentalIns_INDC + ', Status_CODE = ' + @Lc_StatusCg_CODE + ', InsSource_CODE = ' + @Lc_InsSourceMe_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR);

          INSERT DINS_Y1
                 (MemberMci_IDNO,
                  OthpInsurance_IDNO,
                  InsuranceGroupNo_TEXT,
                  PolicyInsNo_TEXT,
                  ChildMCI_IDNO,
                  Begin_DATE,
                  End_DATE,
                  Status_DATE,
                  MedicalIns_INDC,
                  DentalIns_INDC,
                  VisionIns_INDC,
                  PrescptIns_INDC,
                  MentalIns_INDC,
                  DescriptionOthers_TEXT,
                  Status_CODE,
                  NonQualified_CODE,
                  InsSource_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB)
          VALUES (@Ln_InsHolderMemberMci_IDNO,--MemberMci_IDNO
                  @Ln_OtherParty_IDNO,--OthpInsurance_IDNO
                  LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)),--InsuranceGroupNo_TEXT
                  LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)),--PolicyInsNo_TEXT
                  @Ln_InsuredMemberMci_IDNO,--ChildMCI_IDNO
                  @Ld_TplCur_Begin_DATE,--Begin_DATE
                  @Ld_TplCur_End_DATE,--End_DATE
                  @Ld_Run_DATE,--Status_DATE
                  @Lc_MedicalIns_INDC,--MedicalIns_INDC
                  @Lc_DentalIns_INDC,--DentalIns_INDC
                  @Lc_VisionIns_INDC,--VisionIns_INDC
                  @Lc_PrescptIns_INDC,--PrescptIns_INDC
                  @Lc_MentalIns_INDC,--MentalIns_INDC
                  @Lc_Space_TEXT,--DescriptionOthers_TEXT
                  @Lc_StatusCg_CODE,--Status_CODE
                  @Lc_NonQualifiedOld_CODE,--NonQualified_CODE
                  @Lc_InsSourceMe_CODE,--InsSource_CODE
                  @Ld_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB --TransactionEventSeq_NUMB
          );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT DINS_Y1 FAILED - 1';

            RAISERROR(50001,16,1);
           END;

          SET @Lc_CaseJournalEntryReqd_INDC = 'Y';
         END;

        /*
        	If the insurance coverage end date in the incoming record 
        		is greater 
        			than run date and 
        			insured member not found with 
        				insurance policy number, 
        				group number 
        					in Dependent Insurance (DINS_Y1) database table then 
        						insert a new record in Dependent Insurance (DINS_Y1) database table
        */
        SET @Ls_Sql_TEXT = 'CHECK IF INSURANCE COVERAGE END DATE IS GREATER THAN BATCH RUN DATE - 2';
        SET @Ls_SqlData_TEXT ='End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        IF @Ld_TplCur_End_DATE > @Ld_Run_DATE
           AND @Lc_RecordExists_INDC = @Lc_No_INDC
         BEGIN
          --Generate Sequence 
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

          SET @Ls_Sql_TEXT = 'INSERT DINS';
          SET @Ls_SqlData_TEXT ='InsHolderMemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', InsuredMemberMci_IDNO = ' + CAST(@Ln_InsuredMemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR) + ', PolicyInsNo_TEXT = ' + @Lc_TplCur_PolicyInsNo_TEXT + ', InsuranceGroupNo_TEXT = ' + @Lc_TplCur_InsuranceGroupNo_TEXT + ', Begin_DATE = ' + CAST(@Ld_TplCur_Begin_DATE AS VARCHAR) + ', End_DATE = ' + CAST(@Ld_TplCur_End_DATE AS VARCHAR) + ', MedicalIns_INDC = ' + @Lc_MedicalIns_INDC + ', DentalIns_INDC = ' + @Lc_DentalIns_INDC + ', VisionIns_INDC = ' + @Lc_VisionIns_INDC + ', PrescptIns_INDC = ' + @Lc_PrescptIns_INDC + ', MentalIns_INDC = ' + @Lc_MentalIns_INDC + ', Status_CODE = ' + @Lc_StatusCg_CODE + ', InsSource_CODE = ' + @Lc_InsSourceMe_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR);

          INSERT DINS_Y1
                 (MemberMci_IDNO,
                  OthpInsurance_IDNO,
                  InsuranceGroupNo_TEXT,
                  PolicyInsNo_TEXT,
                  ChildMCI_IDNO,
                  Begin_DATE,
                  End_DATE,
                  Status_DATE,
                  MedicalIns_INDC,
                  DentalIns_INDC,
                  VisionIns_INDC,
                  PrescptIns_INDC,
                  MentalIns_INDC,
                  DescriptionOthers_TEXT,
                  Status_CODE,
                  NonQualified_CODE,
                  InsSource_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB)
          VALUES (@Ln_InsHolderMemberMci_IDNO,--MemberMci_IDNO
                  @Ln_OtherParty_IDNO,--OthpInsurance_IDNO
                  LTRIM(RTRIM(@Lc_TplCur_InsuranceGroupNo_TEXT)),--InsuranceGroupNo_TEXT
                  LTRIM(RTRIM(@Lc_TplCur_PolicyInsNo_TEXT)),--PolicyInsNo_TEXT
                  @Ln_InsuredMemberMci_IDNO,--ChildMCI_IDNO
                  @Ld_TplCur_Begin_DATE,--Begin_DATE
                  @Ld_TplCur_End_DATE,--End_DATE
                  @Ld_Run_DATE,--Status_DATE
                  @Lc_MedicalIns_INDC,--MedicalIns_INDC
                  @Lc_DentalIns_INDC,--DentalIns_INDC
                  @Lc_VisionIns_INDC,--VisionIns_INDC
                  @Lc_PrescptIns_INDC,--PrescptIns_INDC
                  @Lc_MentalIns_INDC,--MentalIns_INDC
                  @Lc_Space_TEXT,--DescriptionOthers_TEXT
                  @Lc_StatusCg_CODE,--Status_CODE
                  @Lc_Space_TEXT,--NonQualified_CODE
                  @Lc_InsSourceMe_CODE,--InsSource_CODE
                  @Ld_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB --TransactionEventSeq_NUMB
          );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT DINS_Y1 FAILED - 2';

            RAISERROR(50001,16,1);
           END;

          SET @Lc_CaseJournalEntryReqd_INDC = 'Y';
         END;

        IF @Lc_CaseJournalEntryReqd_INDC = 'Y'
         BEGIN
          SET @Ls_Sql_TEXT = 'DECLARE IvdCase_CUR';
          SET @Ls_SqlData_TEXT = '';

          DECLARE IvdCase_CUR INSENSITIVE CURSOR FOR
           SELECT DISTINCT
                  Case_IDNO
             FROM #IvdCases_P1
            WHERE IvdCase_INDC = @Lc_Yes_INDC;

          SET @Ls_Sql_TEXT = 'OPEN IvdCase_CUR';
          SET @Ls_SqlData_TEXT = '';

          OPEN IvdCase_CUR;

          SET @Ls_Sql_TEXT = 'FETCH NEXT FROM IvdCase_CUR - 1';
          SET @Ls_SqlData_TEXT = '';

          FETCH NEXT FROM IvdCase_CUR INTO @Ln_IvdCaseCur_Case_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
          SET @Ls_Sql_TEXT = 'LOOP THROUGH IvdCase_CUR';
          SET @Ls_SqlData_TEXT = '';

          --Make a case journal entry for each case of the member...
          WHILE @Li_FetchStatus_QNTY = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
            SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_InsHolderMemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_IvdCaseCur_Case_IDNO AS VARCHAR) + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorMiifm_CODE;

            EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
             @An_Case_IDNO                = @Ln_IvdCaseCur_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_InsHolderMemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorMiifm_CODE,
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

            SET @Ls_Sql_TEXT = 'FETCH NEXT FROM IvdCase_CUR - 2';
            SET @Ls_SqlData_TEXT = '';

            FETCH NEXT FROM IvdCase_CUR INTO @Ln_IvdCaseCur_Case_IDNO;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           END;

          SET @Ls_Sql_TEXT = 'CLOSE IvdCase_CUR';
          SET @Ls_SqlData_TEXT = '';

          CLOSE IvdCase_CUR;

          SET @Ls_Sql_TEXT = 'DEALLOCATE IvdCase_CUR';
          SET @Ls_SqlData_TEXT = '';

          DEALLOCATE IvdCase_CUR;
         END;
       END TRY

       BEGIN CATCH
        IF XACT_STATE() = 1
         BEGIN
          ROLLBACK TRANSACTION SAVE_PROCESS_MEDICAID_TPL;
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

        IF CURSOR_STATUS('Local', 'IvdCase_CUR') IN (0, 1)
         BEGIN
          CLOSE IvdCase_CUR;

          DEALLOCATE IvdCase_CUR;
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

       SET @Ls_Sql_TEXT = 'UPDATE LMTPL_Y1';
       SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + CAST(@Ln_TplCur_Seq_IDNO AS VARCHAR);

       UPDATE LMTPL_Y1
          SET Process_INDC = @Lc_ProcessY_INDC
        WHERE Seq_IDNO = @Ln_TplCur_Seq_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE LMTPL_Y1 FAILED';

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';
       SET @Ls_SqlData_TEXT = 'CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR) + ', CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR);

       IF @Ln_CommitFreq_QNTY <> 0
          AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_MEDICAID_TPL';
         SET @Ls_SqlData_TEXT = '';

         COMMIT TRANSACTION TXN_PROCESS_MEDICAID_TPL;

         SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
         SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_MEDICAID_TPL';
         SET @Ls_SqlData_TEXT = '';

         BEGIN TRANSACTION TXN_PROCESS_MEDICAID_TPL;

         SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_CommitFreq_QNTY = 0;
        END;

       SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';
       SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);

       IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        BEGIN
         COMMIT TRANSACTION TXN_PROCESS_MEDICAID_TPL;

         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
         SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Tpl_CUR - 2';
       SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

       FETCH NEXT FROM Tpl_CUR INTO @Ln_TplCur_Seq_IDNO, @Lc_TplCur_Case_IDNO, @Lc_TplCur_InsuredMemberMci_IDNO, @Lc_TplCur_InsuredMemberSsn_NUMB, @Lc_TplCur_BirthInsured_DATE, @Lc_TplCur_LastInsured_NAME, @Lc_TplCur_FirstInsured_NAME, @Lc_TplCur_InsCompanyCarrier_CODE, @Lc_TplCur_InsCompanyLocation_CODE, @Lc_TplCur_InsHolderFull_NAME, @Lc_TplCur_InsHolderMemberSsn_NUMB, @Lc_TplCur_InsHolderBirth_DATE, @Lc_TplCur_InsHolderMemberMci_IDNO, @Lc_TplCur_PolicyInsNo_TEXT, @Lc_TplCur_InsuranceGroupNo_TEXT, @Lc_TplCur_Coverage_CODE, @Lc_TplCur_InsPolicyStatus_CODE, @Lc_TplCur_InsPolicyVerification_INDC, @Lc_TplCur_Begin_DATE, @Lc_TplCur_End_DATE, @Lc_TplCur_InsHolderRelationship_CODE, @Lc_TplCur_InsHolderEmployer_NAME, @Lc_TplCur_InsPolicyInfoAdd_DATE, @Lc_TplCur_InsPolicyInfoModify_DATE, @Lc_TplCur_InsHolderEmpAddrNormalization_CODE, @Ls_TplCur_InsHolderEmpLine1_ADDR, @Ls_TplCur_InsHolderEmpLine2_ADDR, @Lc_TplCur_InsHolderEmpCity_ADDR, @Lc_TplCur_InsHolderEmpState_ADDR, @Lc_TplCur_InsHolderEmpZip_ADDR, @Lc_TplCur_Process_INDC;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     SET @Ls_Sql_TEXT = 'CLOSE Tpl_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE Tpl_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Tpl_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE Tpl_CUR;
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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_MEDICAID_TPL';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_PROCESS_MEDICAID_TPL;

   SET @Ls_Sql_TEXT = 'DROP TEMPORARY TABLE';
   SET @Ls_SqlData_TEXT = '';

   DROP TABLE #IvdCases_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_MEDICAID_TPL;
    END;

   IF OBJECT_ID('tempdb..#IvdCases_P1') IS NOT NULL
    BEGIN
     DROP TABLE #IvdCases_P1;
    END;

   IF CURSOR_STATUS('Local', 'Tpl_CUR') IN (0, 1)
    BEGIN
     CLOSE Tpl_CUR;

     DEALLOCATE Tpl_CUR;
    END;

   IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseMember_CUR;

     DEALLOCATE CaseMember_CUR;
    END;

   IF CURSOR_STATUS('Local', 'IvdCase_CUR') IN (0, 1)
    BEGIN
     CLOSE IvdCase_CUR;

     DEALLOCATE IvdCase_CUR;
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
