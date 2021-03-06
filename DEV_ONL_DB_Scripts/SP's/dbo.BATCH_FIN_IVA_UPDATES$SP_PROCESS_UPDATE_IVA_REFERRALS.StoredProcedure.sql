/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Programmer Name	:	IMP Team.
Description		:	This process updates the welfare case type for the incoming child(ren) and/or adds a child to existing case and/or creates new cases.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
					BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO,
					BATCH_COMMON$SP_INSERT_MSSN,
					BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM,
					BATCH_COMMON$SP_ALERT_WORKER,
					BATCH_COMMON$SP_ADDRESS_UPDATE,
					BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS]
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  --Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_ParticipantTanfStatusChange2720_NUMB INT = 2720,
          @Li_FetchStatus_QNTY                     SMALLINT = 0,
          @Li_RowsCount_QNTY                       SMALLINT = 0,
          @Li_ChildAge12_NUMB                      SMALLINT = 12,
          @Lc_StatusFailed_CODE                    CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                   CHAR(1) = 'S',
          @Lc_SexF_CODE                            CHAR(1) = 'F',
          @Lc_TypeWelfareTANF_CODE                 CHAR(1) = 'A',
          @Lc_Percenatage_TEXT                     CHAR(1) = '%',
          @Lc_CaseRelationshipCp_CODE              CHAR(1) = 'C',
          @Lc_CaseRelationshipChild_CODE           CHAR(1) = 'D',
          @Lc_CaseRelationshipNcpA_CODE            CHAR(1) = 'A',
          @Lc_CaseRelationshipNcpP_CODE            CHAR(1) = 'P',
          @Lc_NcpCaseRelationship_CODE             CHAR(1) = ' ',
          @Lc_TypeCaseNonIVD_CODE                  CHAR(1) = 'H',
          @Lc_TypeCaseIVEFosterCare_CODE           CHAR(1) = 'F',
          @Lc_TypeCaseNonFederalFosterCare_CODE    CHAR(1) = 'J',
          @Lc_TypeWelfareMedicaid_CODE             CHAR(1) = 'M',
          @Lc_TypeWelfareNonTanf_CODE              CHAR(1) = 'N',
          @Lc_TypeWelfareIVAPurchaseOfCare_CODE    CHAR(1) = 'C',
          @Lc_StatusCaseOpen_CODE                  CHAR(1) = 'O',
          @Lc_StatusEstablishOpen_CODE             CHAR(1) = 'O',
          @Lc_StatusCaseClosed_CODE                CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE          CHAR(1) = 'A',
          @Lc_CaseMemberStatusInActive_CODE        CHAR(1) = 'I',
          @Lc_RespondInitR_CODE                    CHAR(1) = 'R',
          @Lc_RespondInitY_CODE                    CHAR(1) = 'Y',
          @Lc_RespondInitS_CODE                    CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE               CHAR(1) = 'A',
          @Lc_MemberSexMale_CODE                   CHAR(1) = 'M',
          @Lc_IndNote_TEXT                         CHAR(1) = 'N',
          @Lc_TypeError_CODE                       CHAR(1) = ' ',
          @Lc_TypeErrorE_CODE                      CHAR(1) = 'E',
          @Lc_TypeErrorI_CODE                      CHAR(1) = 'I',
          @Lc_ProcessY_CODE                        CHAR(1) = 'Y',
          @Lc_ProcessN_CODE                        CHAR(1) = 'N',
          @Lc_BenchWarrant_INDC                    CHAR(1) = 'N',
          @Lc_Enumeration_CODE                     CHAR(1) = 'P',
          @Lc_StatusLocate_CODE                    CHAR(1) = 'L',
          @Lc_Space_TEXT                           CHAR(1) = ' ',
          @Lc_MailingTypeAddress_CODE              CHAR(1) = 'M',
          @Lc_VerificationStatusP_CODE             CHAR(1) = 'P',
          @Lc_ReasonFeeWaived_CODE                 CHAR(2) = ' ',
          @Lc_CommaSpace_TEXT                      CHAR(2) = ', ',
          @Lc_ReasonFeeWaivedTA_CODE               CHAR(2) = 'TA',
          @Lc_ReasonFeeWaivedCM_CODE               CHAR(2) = 'CM',
          @Lc_ReasonFeeWaivedCC_CODE               CHAR(2) = 'CC',
          @Lc_PurchaseOfCare_CODE                  CHAR(2) = 'CC',
          @Lc_ReasonStatusSI_CODE                  CHAR(2) = 'SI',
          @Lc_CaseCategoryMO_CODE                  CHAR(2) = 'MO',
          @Lc_CaseCategoryPO_CODE                  CHAR(2) = 'PO',
          @Lc_CaseCategoryFS_CODE                  CHAR(2) = 'FS',
          @Lc_ReasonPA_CODE                        CHAR(2) = 'PA',
          @Lc_TypeActionCP_CODE                    CHAR(2) = 'CP',
          @Lc_TypeActionAA_CODE                    CHAR(2) = 'AA',
          @Lc_TypeActionAC_CODE                    CHAR(2) = 'AC',
          @Lc_SubsystemCI_CODE                     CHAR(2) = 'CI',
          @Lc_SubsystemCM_CODE                     CHAR(2) = 'CM',
          @Lc_SubsystemES_CODE                     CHAR(2) = 'ES',
		  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
		  @Lc_ReasonForPending_CODE                CHAR(2) = '',
		  @Lc_ReasonForPendingAN_CODE              CHAR(2) = 'AN',
		  @Lc_ReasonForPendingFN_CODE              CHAR(2) = 'FN',
		  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
          @Lc_RelationshipToChildMTR_CODE          CHAR(3) = 'MTR',
          @Lc_RelationshipToChildFTR_CODE          CHAR(3) = 'FTR',
          @Lc_MemberSourceLoc_CODE                 CHAR(3) = 'IVA',
          @Lc_ActivityMajorCase_CODE               CHAR(4) = 'CASE',
          @Lc_ActivityMajorEstp_CODE               CHAR(4) = 'ESTP',
          @Lc_ActivityMinorCcrcc_CODE              CHAR(5) = 'CCRCC',
          @Lc_ActivityMinorTmrrc_CODE              CHAR(5) = 'TMRRC',
          @Lc_ActivityMinorClfcc_CODE              CHAR(5) = 'CLFCC',
          @Lc_ActivityMinorCam2c_CODE              CHAR(5) = 'CAM2C',
          @Lc_ActivityMinorCelpc_CODE              CHAR(5) = 'CELPC',
          @Lc_ActivityMinorCsppc_CODE              CHAR(5) = 'CSPPC',
          @Lc_ActivityMinorFcm1n_CODE              CHAR(5) = 'FCM1N',
          @Lc_ActivityMinorCam1c_CODE              CHAR(5) = 'CAM1C',
          @Lc_ActivityMinorNewrk_CODE              CHAR(5) = 'NEWRK',
		  --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -START-
		  @Lc_ActivityMinorPscta_CODE              CHAR(5) = 'PSCTA',
		  @Lc_ActivityMinorCcrnp_CODE              CHAR(5) = 'CCRNP',
		  @Lc_ActivityMinorCcrnd_CODE              CHAR(5) = 'CCRND',
		  --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -END-
          @Lc_BatchRunUser_TEXT                    CHAR(5) = 'BATCH',
          @Lc_ErrorE0085_CODE                      CHAR(5) = 'E0085',
          @Lc_ErrorE0944_CODE                      CHAR(5) = 'E0944',
          @Lc_ErrorE1424_CODE                      CHAR(5) = 'E1424',
          @Lc_ErrorE1089_CODE                      CHAR(5) = 'E1089',
          @Lc_ErrorE1176_CODE                      CHAR(5) = 'E1176',
          @Lc_WorkerRole_ID                        CHAR(5) = 'RT001',
          @Lc_Msg_CODE                             CHAR(5) = ' ',
          @Lc_BateError_CODE                       CHAR(5) = ' ',
          @Lc_Job_ID                               CHAR(7) = 'DEB9902',
          @Lc_Successful_TEXT                      CHAR(20) = 'SUCCESSFUL',
          @Lc_ErrorE0001_TEXT                      CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Lc_ErrorE0944_TEXT                      CHAR(35) = 'NO RECORDS(S) TO PROCESS',
          @Lc_ErrorE0085_TEXT                      CHAR(35) = 'INVALID VALUE',
          @Ls_ParmDateProblem_TEXT                 VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                         VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_Procedure_NAME                       VARCHAR(100) = 'SP_PROCESS_UPDATE_IVA_REFERRALS',
          @Ls_CursorLocation_TEXT                  VARCHAR(200) = ' ',
          @Ls_Sql_TEXT                             VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT                    VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT                VARCHAR(4000) = ' ',
          @Ls_BateRecord_TEXT                      VARCHAR(4000) = ' ',
          @Ls_BateError_TEXT                       VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT                         VARCHAR(5000) = ' ',
          @Ld_Low_DATE                             DATE = '01/01/0001',
          @Ld_High_DATE                            DATE = '12/31/9999',
          @Lb_CommitSkipTransaction_BIT            BIT = 1;
  DECLARE @Ln_ExceptionThreshold_QNTY        NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY    NUMERIC(5),
          @Ln_CommitFreq_QNTY                NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY            NUMERIC(5) = 0,
          @Ln_Zero_NUMB                      NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB               NUMERIC(5) = 0,
          @Ln_NewlyCreatedCase_IDNO          NUMERIC(6),
          @Ln_ProcessedRecordCount_QNTY      NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY    NUMERIC(6) = 0,
          @Ln_MemberFein_IDNO                NUMERIC(9),
          @Ln_CpSsn_NUMB                     NUMERIC(9),
          @Ln_NcpSsn_NUMB                    NUMERIC(9),
          @Ln_RecCount_NUMB                  NUMERIC(10) = 0,
          @Ln_UnknownNcpMci_IDNO             NUMERIC(10) = 999995,
          @Ln_Error_NUMB                     NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB                 NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB       NUMERIC(19) = 0,
          @Ln_EventGlobalSeq_NUMB            NUMERIC(19) = 0,
          @Lc_CpMappedRace_CODE              CHAR(1),
          @Lc_NcpMappedRace_CODE             CHAR(1),
          @Lc_ChildMappedRace_CODE           CHAR(1),
          @Lc_IVACaseType_CODE               CHAR(1),
          @Lc_TypeCase_CODE                  CHAR(1),
          @Lc_CpSex_CODE                     CHAR(1),
          @Lc_NcpSex_CODE                    CHAR(1),
          @Lc_CpAddrNormalization_CODE       CHAR(1),
          @Lc_CpEmpAddrNormalization_CODE    CHAR(1),
          @Lc_NcpAddrNormalization_CODE      CHAR(1),
          @Lc_NcpEmpAddrNormalization_CODE   CHAR(1),
          @Lc_CaseCategory_CODE              CHAR(2),
          @Lc_CpState_ADDR                   CHAR(2),
          @Lc_CpEmployerState_ADDR           CHAR(2),
          @Lc_NcpState_ADDR                  CHAR(2),
          @Lc_NcpEmployerState_ADDR          CHAR(2),
          @Lc_CpSuffix_NAME                  CHAR(4),
          @Lc_NcpSuffix_NAME                 CHAR(4),
          @Lc_BirthDate_TEXT                 CHAR(8),
          @Lc_CpEmployerZip_ADDR             CHAR(15),
          @Lc_CpZip_ADDR                     CHAR(15),
          @Lc_NcpEmployerZip_ADDR            CHAR(15),
          @Lc_NcpZip_ADDR                    CHAR(15),
          @Lc_CpFirst_NAME                   CHAR(16),
          @Lc_NcpFirst_NAME                  CHAR(16),
          @Lc_CpLast_NAME                    CHAR(20),
          @Lc_CpMiddle_NAME                  CHAR(20),
          @Lc_NcpLast_NAME                   CHAR(20),
          @Lc_NcpMiddle_NAME                 CHAR(20),
          @Lc_CpEmployerCity_ADDR            CHAR(28),
          @Lc_CpCity_ADDR                    CHAR(28),
          @Lc_NcpEmployerCity_ADDR           CHAR(28),
          @Lc_NcpCity_ADDR                   CHAR(28),
          @Ls_CpLine1_ADDR                   VARCHAR(50),
          @Ls_CpLine2_ADDR                   VARCHAR(50),
          @Ls_CpEmployerLine1_ADDR           VARCHAR(50),
          @Ls_CpEmployerLine2_ADDR           VARCHAR(50),
          @Ls_NcpLine1_ADDR                  VARCHAR(50),
          @Ls_NcpLine2_ADDR                  VARCHAR(50),
          @Ls_NcpEmployerLine1_ADDR          VARCHAR(50),
          @Ls_NcpEmployerLine2_ADDR          VARCHAR(50),
          @Ls_ChildFullDisplay_NAME          VARCHAR(60),
          @Ls_CpFullDisplay_NAME             VARCHAR(60),
          @Ls_NcpFullDisplay_NAME            VARCHAR(60),
          @Ls_CpEmployer_NAME                VARCHAR(60),
          @Ls_NcpEmployer_NAME               VARCHAR(60),
          @Ld_Run_DATE                       DATE,
          @Ld_LastRun_DATE                   DATE,
          @Ld_CpBirth_DATE                   DATE,
          @Ld_NcpBirth_DATE                  DATE,
          @Ld_Start_DATE                     DATETIME2,
          @Lb_ChildExistsInDemo_BIT          BIT,
          @Lb_CpExistsInDemo_BIT             BIT,
          @Lb_NcpExistsInDemo_BIT            BIT,
          @Lb_ChildExistsInMssn_BIT          BIT,
          @Lb_CpExistsInMssn_BIT             BIT,
          @Lb_NcpExistsInMssn_BIT            BIT,
          @Lb_ChildAndNcpAgeGreateThan12_BIT BIT,
          @Lb_ChangeChildsProgramType_BIT    BIT,
          @Lb_AddAbsentParentOnTheCase_BIT   BIT,
          @Lb_AddChildOnExistingIVDCase_BIT  BIT,
		  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
		  @Lb_WriteToCpdr_BIT                BIT,
          --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
		  @Lb_CreateCase1_BIT                BIT,
          @Lb_CreateCase4_BIT                BIT,
          @Lb_CreateCaseCommon_BIT           BIT,
          @Lb_CreateActionAlert1_BIT         BIT,
          @Lb_CreateActionAlert2_BIT         BIT;
  --Cursor Variable Naming:
  DECLARE @Ln_ReferralsCur_Seq_IDNO                    NUMERIC(19),
          @Lc_ReferralsCur_CaseWelfareIdno_TEXT        CHAR(10),
          @Lc_ReferralsCur_CpMciIdno_TEXT              CHAR(10),
          @Lc_ReferralsCur_NcpMciIdno_TEXT             CHAR(10),
          @Lc_ReferralsCur_AgSequenceNumb_TEXT         CHAR(4),
          @Lc_ReferralsCur_StatusCase_CODE             CHAR(1),
          @Lc_ReferralsCur_ChildMciIdno_TEXT           CHAR(10),
          @Lc_ReferralsCur_Program_CODE                CHAR(3),
          @Lc_ReferralsCur_SubProgram_CODE             CHAR(1),
          @Lc_ReferralsCur_IntactFamilyStatus_CODE     CHAR(1),
          @Lc_ReferralsCur_ChildEligDate_TEXT          CHAR(8),
          @Lc_ReferralsCur_WelfareCaseCountyIdno_TEXT  CHAR(3),
          @Lc_ReferralsCur_ChildFirst_NAME             CHAR(30),
          @Lc_ReferralsCur_ChildMiddle_NAME            CHAR(1),
          @Lc_ReferralsCur_ChildLast_NAME              CHAR(20),
          @Lc_ReferralsCur_ChildSuffix_NAME            CHAR(4),
          @Lc_ReferralsCur_ChildBirthDate_TEXT         CHAR(8),
          @Lc_ReferralsCur_ChildSsnNumb_TEXT           CHAR(9),
          @Lc_ReferralsCur_ChildSex_CODE               CHAR(1),
          @Lc_ReferralsCur_ChildRace_CODE              CHAR(2),
          @Lc_ReferralsCur_ChildPaternityStatus_CODE   CHAR(1),
          @Lc_ReferralsCur_CpRelationshipToChild_CODE  CHAR(3),
          @Lc_ReferralsCur_NcpRelationshipToChild_CODE CHAR(3),
          @Ld_ReferralsCur_FileLoad_DATE               DATE,
          @Lc_ReferralsCur_Process_INDC                CHAR(1);
  DECLARE @Ln_ReferralsCurWelfareCaseCounty_IDNO NUMERIC(3),
          @Ln_ReferralsCurAgSequence_NUMB        NUMERIC(4),
          @Ln_ReferralsCurChildSsn_NUMB          NUMERIC(9),
          @Ln_ReferralsCurCaseWelfare_IDNO       NUMERIC(10),
          @Ln_ReferralsCurCpMci_IDNO             NUMERIC(10),
          @Ln_ReferralsCurNcpMci_IDNO            NUMERIC(10),
          @Ln_ReferralsCurChildMci_IDNO          NUMERIC(10),
          @Ld_ReferralsCurChildElig_DATE         DATE,
          @Ld_ReferralsCurChildBirth_DATE        DATE;

  IF OBJECT_ID('tempdb..##TempCaseReopenAddUpdateChild_P1') IS NOT NULL
   BEGIN
    DROP TABLE ##TempCaseReopenAddUpdateChild_P1;
   END;

  IF OBJECT_ID('tempdb..##InsertActivity_P1') IS NOT NULL
   BEGIN
    DROP TABLE ##InsertActivity_P1;
   END;

  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
  IF OBJECT_ID('tempdb..##TempSeqIdno_P1') IS NOT NULL
   BEGIN
    DROP TABLE ##TempSeqIdno_P1;
   END;

  --TEMP TABLES TO PROCESS AND SKIP THE RECORDS
  CREATE TABLE ##TempSeqIdno_P1
   (
     Seq_IDNO NUMERIC(19, 0)
   );
  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

  --Create temp table for the case numbers and Seq_idno
  CREATE TABLE ##TempCaseReopenAddUpdateChild_P1
   (
     Seq_IDNO       NUMERIC(19),
     Case_IDNO      NUMERIC(6),
     MemberMci_IDNO NUMERIC(10)
   );

  --Create temp table for the case numbers and Seq_idno
  CREATE TABLE ##InsertActivity_P1
   (
     Seq_IDNO           NUMERIC(19),
     Case_IDNO          NUMERIC(6),
     MemberMci_IDNO     NUMERIC(10),
     ActivityMajor_CODE CHAR(4),
     ActivityMinor_CODE CHAR(5),
     Subsystem_CODE     CHAR(2)
   );

  DECLARE @CreatedCaseAndCp_P1 TABLE (
   Case_IDNO      NUMERIC(6),
   MemberMci_IDNO NUMERIC(10));
  DECLARE @TempIVDCaseAndChildStatus_P1 TABLE (
   Case_IDNO             NUMERIC(6),
   CaseMemberStatus_CODE CHAR(1),
   TypeAction_CODE       CHAR(2)--This is to identify 'CP'-Change Program Type, 'AA' - Add Absent Parent and 'AC' - Add Child
  );

  BEGIN TRY
   --Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Selecting date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     RAISERROR (50001,16,1);
    END

   -- Validation: Whether The Job already ran for the day	
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'TRASACTION IVACASEREFERRALS_SKIP_PROCESS BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION IVACASEREFERRALS_SKIP_PROCESS;

   SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     SET @Lb_CommitSkipTransaction_BIT = 0;

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'TRASACTION IVACASEREFERRALS_SKIP_PROCESS COMMITS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION IVACASEREFERRALS_SKIP_PROCESS;

   --CURSOR STARTS
   DECLARE Referrals_CUR INSENSITIVE CURSOR FOR
    SELECT l.Seq_IDNO,
           l.CaseWelfare_IDNO,
           l.CpMci_IDNO,
           l.NcpMci_IDNO,
           l.AgSequence_NUMB,
           l.StatusCase_CODE,
           l.ChildMci_IDNO,
           l.Program_CODE,
           l.SubProgram_CODE,
           l.IntactFamilyStatus_CODE,
           l.ChildElig_DATE,
           l.WelfareCaseCounty_IDNO,
           l.ChildFirst_NAME,
           l.ChildMiddle_NAME,
           l.ChildLast_NAME,
           l.ChildSuffix_NAME,
           l.ChildBirth_DATE,
           l.ChildSsn_NUMB,
           l.ChildSex_CODE,
           l.ChildRace_CODE,
           l.ChildPaternityStatus_CODE,
           l.CpRelationshipToChild_CODE,
           l.NcpRelationshipToChild_CODE,
           l.FileLoad_DATE,
           l.Process_CODE
      FROM LIVAR_Y1 l
     WHERE l.Process_CODE = @Lc_ProcessN_CODE
     ORDER BY CASE
               WHEN l.Program_CODE LIKE 'A%'
                THEN 'A'
               WHEN l.Program_CODE LIKE 'M%'
                THEN 'B'
               WHEN l.Program_CODE LIKE 'C%'
                THEN 'C'
              END,
              l.FileLoad_DATE,
              l.Seq_IDNO;

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION IVACASEREFERRALS_PROCESS;

   -- Check if restart key exists in Restart table.
   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Lc_Job_ID
      AND r.Run_DATE = @Ld_Run_DATE;

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   --DELETE DUPLICATE BATE RECORDS
   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveRun_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   -- Cursor starts 		
   SET @Ls_Sql_TEXT = 'OPEN Referrals_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   OPEN Referrals_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Referrals_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   FETCH NEXT FROM Referrals_CUR INTO @Ln_ReferralsCur_Seq_IDNO, @Lc_ReferralsCur_CaseWelfareIdno_TEXT, @Lc_ReferralsCur_CpMciIdno_TEXT, @Lc_ReferralsCur_NcpMciIdno_TEXT, @Lc_ReferralsCur_AgSequenceNumb_TEXT, @Lc_ReferralsCur_StatusCase_CODE, @Lc_ReferralsCur_ChildMciIdno_TEXT, @Lc_ReferralsCur_Program_CODE, @Lc_ReferralsCur_SubProgram_CODE, @Lc_ReferralsCur_IntactFamilyStatus_CODE, @Lc_ReferralsCur_ChildEligDate_TEXT, @Lc_ReferralsCur_WelfareCaseCountyIdno_TEXT, @Lc_ReferralsCur_ChildFirst_NAME, @Lc_ReferralsCur_ChildMiddle_NAME, @Lc_ReferralsCur_ChildLast_NAME, @Lc_ReferralsCur_ChildSuffix_NAME, @Lc_ReferralsCur_ChildBirthDate_TEXT, @Lc_ReferralsCur_ChildSsnNumb_TEXT, @Lc_ReferralsCur_ChildSex_CODE, @Lc_ReferralsCur_ChildRace_CODE, @Lc_ReferralsCur_ChildPaternityStatus_CODE, @Lc_ReferralsCur_CpRelationshipToChild_CODE, @Lc_ReferralsCur_NcpRelationshipToChild_CODE, @Ld_ReferralsCur_FileLoad_DATE, @Lc_ReferralsCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --When no records are selected to process.
   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
     SET @Ls_BateError_TEXT = @Lc_ErrorE0944_TEXT;
    END;

   --Create case if the conditions met, adds child to existing case, change program type and/or Adding absent parent as an extra PF on the case
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVEIVACASEREFERRALS_PROCESS;

      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCur_Seq_IDNO AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(RTRIM(@Lc_ReferralsCur_CaseWelfareIdno_TEXT), '') + ', CpMci_IDNO = ' + ISNULL(RTRIM(@Lc_ReferralsCur_CpMciIdno_TEXT), '') + ', NcpMci_IDNO = ' + ISNULL(RTRIM(@Lc_ReferralsCur_NcpMciIdno_TEXT), '') + ', AgSequence_NUMB = ' + ISNULL(RTRIM(@Lc_ReferralsCur_AgSequenceNumb_TEXT), '') + ', StatusCase_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_StatusCase_CODE), '') + ', ChildMci_IDNO = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildMciIdno_TEXT), '') + ', Program_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_Program_CODE), '') + ', SubProgram_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_SubProgram_CODE), '') + ', IntactFamilyStatus_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_IntactFamilyStatus_CODE), '') + ', ChildElig_DATE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildEligDate_TEXT), '') + ', WelfareCaseCounty_IDNO = ' + ISNULL(RTRIM(@Lc_ReferralsCur_WelfareCaseCountyIdno_TEXT), '') + ', ChildFirst_NAME = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildFirst_NAME), '') + ', ChildMiddle_NAME = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildMiddle_NAME), '') + ', ChildLast_NAME = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildLast_NAME), '') + ', ChildSuffix_NAME = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildSuffix_NAME), '') + ', ChildBirth_DATE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildBirthDate_TEXT), '') + ', ChildSsn_NUMB = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildSsnNumb_TEXT), '') + ', ChildSex_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildSex_CODE), '') + ', ChildRace_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildRace_CODE), '') + ', ChildPaternityStatus_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_ChildPaternityStatus_CODE), '') + ', CpRelationshipToChild_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_CpRelationshipToChild_CODE), '') + ', NcpRelationshipToChild_CODE = ' + ISNULL(RTRIM(@Lc_ReferralsCur_NcpRelationshipToChild_CODE), '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_ReferralsCur_FileLoad_DATE AS VARCHAR), '') + ', Process_CODE = ' + ISNULL(@Lc_ReferralsCur_Process_INDC, '');
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Ln_RecCount_NUMB = @Ln_RecCount_NUMB + 1;
      SET @Ls_CursorLocation_TEXT = 'IVA CASE REFERRALS PROCESS - CURSOR COUNT - ' + CAST(@Ln_RecCount_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      IF ISNUMERIC (@Lc_ReferralsCur_CaseWelfareIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_ReferralsCur_CpMciIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_ReferralsCur_NcpMciIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_ReferralsCur_ChildMciIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_ReferralsCur_WelfareCaseCountyIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_ReferralsCur_ChildSsnNumb_TEXT) = 0
          OR ISNUMERIC(@Lc_ReferralsCur_AgSequenceNumb_TEXT) = 0
          OR ISDATE(@Lc_ReferralsCur_ChildEligDate_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
        SET @Ls_BateError_TEXT = @Lc_ErrorE0085_TEXT;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_ReferralsCurCaseWelfare_IDNO = CAST(@Lc_ReferralsCur_CaseWelfareIdno_TEXT AS NUMERIC);
        SET @Ln_ReferralsCurCpMci_IDNO = CAST(@Lc_ReferralsCur_CpMciIdno_TEXT AS NUMERIC);
        SET @Ln_ReferralsCurNcpMci_IDNO = CAST(@Lc_ReferralsCur_NcpMciIdno_TEXT AS NUMERIC);
        SET @Ln_ReferralsCurChildMci_IDNO = CAST(@Lc_ReferralsCur_ChildMciIdno_TEXT AS NUMERIC);
        SET @Ln_ReferralsCurWelfareCaseCounty_IDNO = CAST(@Lc_ReferralsCur_WelfareCaseCountyIdno_TEXT AS NUMERIC);
        SET @Ln_ReferralsCurChildSsn_NUMB = CAST(@Lc_ReferralsCur_ChildSsnNumb_TEXT AS NUMERIC);
        SET @Ln_ReferralsCurAgSequence_NUMB = CAST(@Lc_ReferralsCur_AgSequenceNumb_TEXT AS NUMERIC);
        SET @Ld_ReferralsCurChildElig_DATE = CAST(@Lc_ReferralsCur_ChildEligDate_TEXT AS DATE);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
      SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '');

      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID               = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
       @Ac_Note_INDC                = @Lc_IndNote_TEXT,
       @An_EventFunctionalSeq_NUMB  = 0,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'DELETE @TempIVDCaseAndChildStatus_P1 - 1';
      SET @Ls_Sqldata_TEXT = '';

      DELETE @TempIVDCaseAndChildStatus_P1;
	  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
	  DELETE ##TempSeqIdno_P1;
	  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

      SET @Lb_ChildExistsInDemo_BIT = 0;
      SET @Lb_CpExistsInDemo_BIT = 0;
      SET @Lb_NcpExistsInDemo_BIT = 0;
      SET @Lb_ChildExistsInMssn_BIT = 0;
      SET @Lb_CpExistsInMssn_BIT = 0;
      SET @Lb_NcpExistsInMssn_BIT = 0;
      SET @Lb_ChildAndNcpAgeGreateThan12_BIT = 0;
      SET @Lb_ChangeChildsProgramType_BIT = 0;
      SET @Lb_AddAbsentParentOnTheCase_BIT = 0;
      SET @Lb_AddChildOnExistingIVDCase_BIT = 0;
      SET @Lb_CreateCase1_BIT = 0;
      SET @Lb_CreateCase4_BIT = 0;
      SET @Lb_CreateCaseCommon_BIT = 0;
      SET @Lb_CreateActionAlert1_BIT = 0;
      SET @Lb_CreateActionAlert2_BIT = 0;
      SET @Ln_NewlyCreatedCase_IDNO = 0;
	  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
	  SET @Lb_WriteToCpdr_BIT = 0;
	  SET @Lc_ReasonForPending_CODE = '';
      --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

	  --Set IV-A program type to IV-D's program type
      SET @Lc_IVACaseType_CODE = CASE
                                  WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                                   THEN @Lc_TypeWelfareTANF_CODE
                                  WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                                   THEN @Lc_TypeWelfareMedicaid_CODE
                                  WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
                                   THEN @Lc_TypeWelfareNonTanf_CODE
                                 END;
      --CHECK NCP,CP AND CHILD EXISTS IN DEMO AND MPAT
      SET @Lb_ChildExistsInDemo_BIT = ISNULL((SELECT TOP 1 1
                                                FROM DEMO_Y1
                                               WHERE MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO), 0);
      SET @Lb_CpExistsInDemo_BIT = ISNULL((SELECT TOP 1 1
                                             FROM DEMO_Y1
                                            WHERE MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO), 0);
      SET @Lb_NcpExistsInDemo_BIT = ISNULL((SELECT TOP 1 1
                                              FROM DEMO_Y1
                                             WHERE MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO), 0);
      --CHECK NCP,CP AND CHILD EXISTS IN MSSN
      SET @Lb_ChildExistsInMssn_BIT = ISNULL((SELECT TOP 1 1
                                                FROM MSSN_Y1
                                               WHERE MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO), 0);
      SET @Lb_CpExistsInMssn_BIT = ISNULL((SELECT TOP 1 1
                                             FROM MSSN_Y1
                                            WHERE MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO), 0);
      SET @Lb_NcpExistsInMssn_BIT = ISNULL((SELECT TOP 1 1
                                              FROM MSSN_Y1
                                             WHERE MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO), 0);
      --SET CHILD'S FULL NAME AND RACE CODE
      SET @Ls_ChildFullDisplay_NAME = LTRIM (RTRIM (@Lc_ReferralsCur_ChildLast_NAME)) + (CASE
                                                                                          WHEN LTRIM (RTRIM (@Lc_ReferralsCur_ChildSuffix_NAME)) = ''
                                                                                           THEN ''
                                                                                          ELSE @Lc_Space_TEXT
                                                                                         END) + LTRIM (RTRIM (@Lc_ReferralsCur_ChildSuffix_NAME)) + @Lc_CommaSpace_TEXT + LTRIM (RTRIM (@Lc_ReferralsCur_ChildFirst_NAME)) + @Lc_Space_TEXT + LTRIM (RTRIM (@Lc_ReferralsCur_ChildMiddle_NAME));
      SET @Lc_ChildMappedRace_CODE = ISNULL(dbo.BATCH_FIN_IVA_UPDATES$SF_GET_RACE_CODE_ONE_CHAR(@Lc_ReferralsCur_ChildRace_CODE), @Lc_Space_TEXT);
      --SET CP AND NCP DETAILS
      SET @Ls_Sql_TEXT = 'SET CP/NCP DETAILS';
      SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCaseWelfare_IDNO AS VARCHAR), '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', AgSequence_NUMB = ' + ISNULL(@Lc_ReferralsCur_AgSequenceNumb_TEXT, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_ReferralsCur_FileLoad_DATE AS VARCHAR), '');

      SELECT DISTINCT TOP 1
             @Lc_CpMappedRace_CODE = ISNULL(dbo.BATCH_FIN_IVA_UPDATES$SF_GET_RACE_CODE_ONE_CHAR(l.CpRace_CODE), @Lc_Space_TEXT),
             @Ls_CpFullDisplay_NAME = LTRIM (RTRIM (l.CpLast_NAME)) + (CASE
                                                                        WHEN LTRIM (RTRIM (l.CpSuffix_NAME)) = ''
                                                                         THEN ''
                                                                        ELSE @Lc_Space_TEXT
                                                                       END) + LTRIM (RTRIM (l.CpSuffix_NAME)) + @Lc_CommaSpace_TEXT + LTRIM (RTRIM (l.CpFirst_NAME)) + @Lc_Space_TEXT + LTRIM (RTRIM (l.CpMiddle_NAME)),
             @Lc_CpLast_NAME = l.CpLast_NAME,
             @Lc_CpSuffix_NAME = l.CpSuffix_NAME,
             @Lc_CpFirst_NAME = l.CpFirst_NAME,
             @Lc_CpMiddle_NAME = l.CpMiddle_NAME,
             @Lc_CpSex_CODE = l.CpSex_CODE,
             @Ln_CpSsn_NUMB = CASE
                               WHEN ISNUMERIC(l.CpSsn_NUMB) = @Ln_Zero_NUMB
                                THEN @Ln_Zero_NUMB
                               ELSE CAST(l.CpSsn_NUMB AS NUMERIC(9))
                              END,
             @Ld_CpBirth_DATE = CASE
                                 WHEN ISDATE(l.CpBirth_DATE) = @Ln_Zero_NUMB
                                  THEN @Ld_Low_DATE
                                 ELSE CAST(l.CpBirth_DATE AS DATE)
                                END,
             @Lc_CpAddrNormalization_CODE = l.CpAddrNormalization_CODE,
             @Ls_CpLine1_ADDR = l.CpLine1_ADDR,
             @Ls_CpLine2_ADDR = l.CpLine2_ADDR,
             @Lc_CpCity_ADDR = l.CpCity_ADDR,
             @Lc_CpState_ADDR = l.CpState_ADDR,
             @Lc_CpZip_ADDR = l.CpZip_ADDR,
             @Ls_CpEmployer_NAME = l.CpEmployer_NAME,
             @Ln_MemberFein_IDNO = l.CpEmployerFein_IDNO,
             @Lc_CpEmpAddrNormalization_CODE = l.CpEmpAddrNormalization_CODE,
             @Ls_CpEmployerLine1_ADDR = l.CpEmployerLine1_ADDR,
             @Ls_CpEmployerLine2_ADDR = l.CpEmployerLine2_ADDR,
             @Lc_CpEmployerCity_ADDR = l.CpEmployerCity_ADDR,
             @Lc_CpEmployerState_ADDR = l.CpEmployerState_ADDR,
             @Lc_CpEmployerZip_ADDR = l.CpEmployerZip_ADDR,
             @Lc_NcpMappedRace_CODE = ISNULL(dbo.BATCH_FIN_IVA_UPDATES$SF_GET_RACE_CODE_ONE_CHAR(l.NcpRace_CODE), @Lc_Space_TEXT),
             @Ls_NcpFullDisplay_NAME = LTRIM (RTRIM (l.NcpLast_NAME)) + (CASE
                                                                          WHEN LTRIM (RTRIM (l.NcpSuffix_NAME)) = ''
                                                                           THEN ''
                                                                          ELSE @Lc_Space_TEXT
                                                                         END) + LTRIM (RTRIM (l.NcpSuffix_NAME)) + @Lc_CommaSpace_TEXT + LTRIM (RTRIM (l.NcpFirst_NAME)) + @Lc_Space_TEXT + LTRIM (RTRIM (l.NcpMiddle_NAME)),
             @Lc_NcpLast_NAME = l.NcpLast_NAME,
             @Lc_NcpSuffix_NAME = l.NcpSuffix_NAME,
             @Lc_NcpFirst_NAME = l.NcpFirst_NAME,
             @Lc_NcpMiddle_NAME = l.NcpMiddle_NAME,
             @Lc_NcpSex_CODE = l.NcpSex_CODE,
             @Ln_NcpSsn_NUMB = CASE
                                WHEN ISNUMERIC(l.NcpSsn_NUMB) = @Ln_Zero_NUMB
                                 THEN @Ln_Zero_NUMB
                                ELSE CAST(l.NcpSsn_NUMB AS NUMERIC(9))
                               END,
             @Lc_BirthDate_TEXT = l.NcpBirth_DATE,
             @Lc_NcpAddrNormalization_CODE = l.NcpAddrNormalization_CODE,
             @Ls_NcpLine1_ADDR = l.NcpLine1_ADDR,
             @Ls_NcpLine2_ADDR = l.NcpLine2_ADDR,
             @Lc_NcpCity_ADDR = l.NcpCity_ADDR,
             @Lc_NcpState_ADDR = l.NcpState_ADDR,
             @Lc_NcpZip_ADDR = l.NcpZip_ADDR,
             @Ls_NcpEmployer_NAME = l.NcpEmployer_NAME,
             @Lc_NcpEmpAddrNormalization_CODE = l.NcpEmpAddrNormalization_CODE,
             @Ls_NcpEmployerLine1_ADDR = l.NcpEmployerLine1_ADDR,
             @Ls_NcpEmployerLine2_ADDR = l.NcpEmployerLine2_ADDR,
             @Lc_NcpEmployerCity_ADDR = l.NcpEmployerCity_ADDR,
             @Lc_NcpEmployerState_ADDR = l.NcpEmployerState_ADDR,
             @Lc_NcpEmployerZip_ADDR = l.NcpEmployerZip_ADDR
        FROM LIVAD_Y1 l
       WHERE l.CaseWelfare_IDNO = @Ln_ReferralsCurCaseWelfare_IDNO
         AND l.CpMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
         AND l.NcpMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
         AND l.AgSequence_NUMB = @Lc_ReferralsCur_AgSequenceNumb_TEXT
         AND l.FileLoad_DATE = @Ld_ReferralsCur_FileLoad_DATE;

      --SETTING THE NCP & CHILD'S BIRTHDATE
      SET @Ld_ReferralsCurChildBirth_DATE = CASE
                                             WHEN ISDATE(@Lc_ReferralsCur_ChildBirthDate_TEXT) = @Ln_Zero_NUMB
                                              THEN @Ld_Low_DATE
                                             ELSE CAST(@Lc_ReferralsCur_ChildBirthDate_TEXT AS DATE)
                                            END;
      SET @Ld_NcpBirth_DATE = CASE
                               WHEN ISDATE(@Lc_BirthDate_TEXT) = @Ln_Zero_NUMB
                                THEN @Ld_Low_DATE
                               ELSE CAST(@Lc_BirthDate_TEXT AS DATE)
                              END;
      SET @Lc_NcpCaseRelationship_CODE = CASE
                                          WHEN @Lc_NcpSex_CODE = @Lc_SexF_CODE
                                               AND @Ln_ReferralsCurNcpMci_IDNO != @Ln_UnknownNcpMci_IDNO
                                           THEN @Lc_CaseRelationshipNcpA_CODE
                                          ELSE @Lc_CaseRelationshipNcpP_CODE
                                         END;
      --CHANGE CHILDS PROGRAM TYPE
      SET @Ls_Sql_TEXT = 'INSERT @TempIVDCaseAndChildStatus_P1 : CHANGE CHILDS PROGRAM TYPE';
      SET @Ls_Sqldata_TEXT = 'TypeAction_CODE = ' + ISNULL(@Lc_TypeActionCP_CODE, '');

      INSERT @TempIVDCaseAndChildStatus_P1
             (Case_IDNO,
              CaseMemberStatus_CODE,
              TypeAction_CODE)
      SELECT DISTINCT
             m.Case_IDNO,
             Dp.CaseMemberStatus_CODE,
             @Lc_TypeActionCP_CODE AS TypeAction_CODE
        FROM MHIS_Y1 m,
             CASE_Y1 c,
             CMEM_Y1 Cp,
             CMEM_Y1 Dp,
             CMEM_Y1 Ncp
       WHERE c.Case_IDNO = Cp.Case_IDNO
         AND c.Case_IDNO = Dp.Case_IDNO
         AND c.Case_IDNO = Ncp.Case_IDNO
         AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
		 --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
		 AND c.RespondInit_CODE NOT IN (@Lc_RespondInitR_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitS_CODE)
		 --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
         AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
         AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
         AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
         AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
         AND Dp.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
         AND m.End_DATE = @Ld_High_DATE
         AND m.Case_IDNO = Dp.Case_IDNO
         AND m.MemberMci_IDNO = Dp.MemberMci_IDNO
         AND ((@Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
               AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE)
               AND Ncp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO)
               OR (@Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                   AND m.TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                   AND Ncp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO)
               OR (@Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                   AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE)
                   AND Ncp.MemberMci_IDNO <> @Ln_ReferralsCurNcpMci_IDNO
                   AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
               OR (@Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                   AND m.TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                   AND Ncp.MemberMci_IDNO <> @Ln_ReferralsCurNcpMci_IDNO
                   AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE));

      IF EXISTS(SELECT 1
                  FROM @TempIVDCaseAndChildStatus_P1
                 WHERE TypeAction_CODE = @Lc_TypeActionCP_CODE)
       BEGIN
        SET @Lb_ChangeChildsProgramType_BIT = 1;
       END

      --ADDING ABSENT PARENT ON THE CASE
      SET @Ls_Sql_TEXT = 'INSERT @TempIVDCaseAndChildStatus_P1 : ADDING ABSENT PARENT ON THE CASE';
      SET @Ls_Sqldata_TEXT = 'CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_TypeActionAA_CODE, '');

      INSERT @TempIVDCaseAndChildStatus_P1
             (Case_IDNO,
              CaseMemberStatus_CODE,
              TypeAction_CODE)
      SELECT DISTINCT
             c.Case_IDNO,
             @Lc_CaseMemberStatusActive_CODE AS CaseMemberStatus_CODE,--Never used
             @Lc_TypeActionAA_CODE AS TypeAction_CODE
        FROM CASE_Y1 c,
             CMEM_Y1 Cp,
             CMEM_Y1 Dp,
             CMEM_Y1 Ncp
       WHERE c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
	     --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
         AND c.RespondInit_CODE NOT IN (@Lc_RespondInitR_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitS_CODE)
		 --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
		 AND (c.TypeCase_CODE = CASE
                                 WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                                  THEN @Lc_TypeWelfareTANF_CODE
                                 WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                                  THEN @Lc_TypeWelfareNonTanf_CODE
                                 WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
                                  THEN @Lc_TypeWelfareNonTanf_CODE
                                END
              AND (c.CaseCategory_CODE LIKE CASE
                                             WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                                              THEN @Lc_Percenatage_TEXT
                                             WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                                              THEN @Lc_CaseCategoryMO_CODE
                                             WHEN @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
                                              THEN @Lc_CaseCategoryPO_CODE
                                            END))
         AND c.Case_IDNO = Cp.Case_IDNO
         AND c.Case_IDNO = Dp.Case_IDNO
         AND c.Case_IDNO = Ncp.Case_IDNO
         AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
         AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
         AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
		 --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
         AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpP_CODE, @Lc_CaseRelationshipNcpA_CODE)
		 --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
         AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
         AND Dp.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
         AND Ncp.MemberMci_IDNO <> @Ln_ReferralsCurNcpMci_IDNO
         AND NOT EXISTS (SELECT 1
                           FROM SORD_Y1 s
                          WHERE s.Case_IDNO = c.Case_IDNO
                            AND s.EndValidity_DATE = @Ld_High_DATE
                            AND s.OrderEnd_DATE >= @Ld_Run_DATE)
         AND (Dp.CpRelationshipToChild_CODE = @Lc_RelationshipToChildMTR_CODE
               OR (Dp.CpRelationshipToChild_CODE <> @Lc_RelationshipToChildMTR_CODE
                   AND EXISTS (SELECT 1
                                 FROM DEMO_Y1 d
                                WHERE d.MemberMci_IDNO = Ncp.MemberMci_IDNO
                                  AND d.MemberSex_CODE = @Lc_MemberSexMale_CODE)
                   AND EXISTS (SELECT 1
                                 FROM LIVAD_Y1 l
                                WHERE l.NcpMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                                  AND l.NcpSex_CODE = @Lc_MemberSexMale_CODE)));

      IF EXISTS(SELECT 1
                  FROM @TempIVDCaseAndChildStatus_P1
                 WHERE TypeAction_CODE = @Lc_TypeActionAA_CODE)
       BEGIN
        --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
		IF @Ln_ReferralsCurNcpMci_IDNO = @Ln_UnknownNcpMci_IDNO
		 BEGIN
		  SET @Lb_ChangeChildsProgramType_BIT = 0;
          SET @Lb_AddAbsentParentOnTheCase_BIT = 0;
          SET @Lb_AddChildOnExistingIVDCase_BIT = 0;
		  GOTO SKIPREFERRAL;
		 END
		IF @Lc_NcpSex_CODE = @Lc_SexF_CODE
		 BEGIN
		  SET @Lb_ChangeChildsProgramType_BIT = 0;
          SET @Lb_AddAbsentParentOnTheCase_BIT = 0;
          SET @Lb_AddChildOnExistingIVDCase_BIT = 0;
		  SET @Lb_WriteToCpdr_BIT = 1;
		  SET @Lc_ReasonForPending_CODE = @Lc_ReasonForPendingFN_CODE;
		  GOTO WRITECPDR;
		 END
		IF EXISTS(SELECT 1
		            FROM CMEM_Y1 m,
					     @TempIVDCaseAndChildStatus_P1 t
                   WHERE t.TypeAction_CODE = @Lc_TypeActionAA_CODE
				     AND t.Case_IDNO = m.Case_IDNO
					 AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                     AND m.CaseRelationship_CODE = @Lc_CaseRelationshipNcpA_CODE)
		 BEGIN
		  SET @Lb_ChangeChildsProgramType_BIT = 0;
          SET @Lb_AddAbsentParentOnTheCase_BIT = 0;
          SET @Lb_AddChildOnExistingIVDCase_BIT = 0;
		  SET @Lb_WriteToCpdr_BIT = 1;
		  SET @Lc_ReasonForPending_CODE = @Lc_ReasonForPendingAN_CODE;
		  GOTO WRITECPDR;
		 END
		SET @Lb_AddAbsentParentOnTheCase_BIT = 1;
		--13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
       END

      --Adding the Child ON THE CASE
      SET @Ls_Sql_TEXT = 'INSERT @TempIVDCaseAndChildStatus_P1 : Adding the Child ON THE CASE';
      SET @Ls_Sqldata_TEXT = 'CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_TypeActionAC_CODE, '');

      INSERT @TempIVDCaseAndChildStatus_P1
             (Case_IDNO,
              CaseMemberStatus_CODE,
              TypeAction_CODE)
      SELECT DISTINCT
             c.Case_IDNO,
             @Lc_CaseMemberStatusActive_CODE AS CaseMemberStatus_CODE,--Never used
             @Lc_TypeActionAC_CODE AS TypeAction_CODE
        FROM CASE_Y1 c,
             CMEM_Y1 Cp,
             CMEM_Y1 Ncp
       WHERE c.Case_IDNO = Cp.Case_IDNO
         AND c.Case_IDNO = Ncp.Case_IDNO
         AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
		 --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
         AND c.RespondInit_CODE NOT IN (@Lc_RespondInitR_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitS_CODE)
		 --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
		 AND ((c.TypeCase_CODE = @Lc_TypeWelfareTANF_CODE)
               OR (c.TypeCase_CODE = @Lc_TypeWelfareNonTanf_CODE
                   AND c.CaseCategory_CODE IN(@Lc_CaseCategoryMO_CODE, @Lc_CaseCategoryPO_CODE)))
         AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
         AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpP_CODE, @Lc_CaseRelationshipNcpA_CODE)
         AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
         AND Ncp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO;

      IF EXISTS(SELECT 1
                  FROM @TempIVDCaseAndChildStatus_P1
                 WHERE TypeAction_CODE = @Lc_TypeActionAC_CODE)
       BEGIN
        SET @Lb_AddChildOnExistingIVDCase_BIT = 1;
       END

      IF @Lb_ChangeChildsProgramType_BIT = 1
          OR @Lb_AddAbsentParentOnTheCase_BIT = 1
          OR @Lb_AddChildOnExistingIVDCase_BIT = 1
       BEGIN
        GOTO SKIPCREATENEWCASE;
       END

      --Create new Case Scenario 1
      SET @Ls_Sql_TEXT = 'SET @Lb_CreateCase1_BIT : Create new Case Scenario 1';
      SET @Ls_Sqldata_TEXT = 'ChildMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '');
      SET @Lb_CreateCase1_BIT = ISNULL((SELECT TOP 1 1
                                          FROM CMEM_Y1 Cp,
                                               CMEM_Y1 Ncp
                                         WHERE Cp.Case_IDNO = Ncp.Case_IDNO
                                           AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                           AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                                           AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                           AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpP_CODE, @Lc_CaseRelationshipNcpA_CODE)
                                           AND Cp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                                           AND Ncp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO), 0);

      IF @Lb_CreateCase1_BIT = 1
       BEGIN
        GOTO CREATENEWCASE;
       END

      --Create new Case Scenario 4
      SET @Ls_Sql_TEXT = 'SET @Lb_CreateCase4_BIT : Create new Case Scenario 4';
      SET @Ls_Sqldata_TEXT = 'ChildMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '');
      SET @Lb_CreateCase4_BIT = ISNULL((SELECT TOP 1 1
                                          FROM CASE_Y1 b,
                                               CMEM_Y1 Dp
                                         WHERE b.Case_IDNO = Dp.Case_IDNO
                                           AND b.TypeCase_CODE IN (@Lc_TypeCaseIVEFosterCare_CODE, @Lc_TypeCaseNonFederalFosterCare_CODE)
                                           AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                           AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
                                           AND Dp.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO), 0);

      IF @Lb_CreateCase4_BIT = 1
       BEGIN
        GOTO CREATENEWCASE;
       END

      --CREATE CASE COMBINED SCENARIO 2,3,5,6,7	
      SET @Ls_Sql_TEXT = 'SET @Lb_CreateCaseCommon_BIT : CREATE CASE COMBINED SCENARIO 2,3,5,6,7';
      SET @Ls_Sqldata_TEXT = 'ChildMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '');
      SET @Lb_CreateCaseCommon_BIT = ISNULL((SELECT TOP 1 1
                                               FROM CASE_Y1 b,
                                                    CMEM_Y1 Cp,
                                                    CMEM_Y1 Dp,
                                                    CMEM_Y1 Ncp
                                              WHERE b.Case_IDNO = Cp.Case_IDNO
                                                AND b.Case_IDNO = Dp.Case_IDNO
                                                AND b.Case_IDNO = Ncp.Case_IDNO
                                                AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                                                AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
                                                AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
                                                AND Dp.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
                                                AND ((--ADDED AFTERWARDS
                                                     Ncp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                                                     AND Cp.MemberMci_IDNO <> @Ln_ReferralsCurCpMci_IDNO
                                                     AND Dp.NcpRelationshipToChild_CODE = @Lc_ReferralsCur_NcpRelationshipToChild_CODE)
                                                      OR (--2ND
                                                         @Lc_ReferralsCur_CpRelationshipToChild_CODE = @Lc_RelationshipToChildFTR_CODE
                                                         AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
                                                         AND Ncp.MemberMci_IDNO <> @Ln_ReferralsCurNcpMci_IDNO)
                                                      OR (--5TH
                                                         b.StatusCase_CODE = @Lc_StatusCaseClosed_CODE
                                                         AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
                                                         AND b.RespondInit_CODE IN (@Lc_RespondInitR_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitS_CODE)
                                                         AND Ncp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO)
                                                      OR (--6TH
                                                         b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                                                         AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
                                                         AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE
                                                         AND Ncp.MemberMci_IDNO <> @Ln_ReferralsCurNcpMci_IDNO)
                                                      OR (--7TH
                                                         b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                                                         AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
                                                         AND @Lc_ReferralsCur_CpRelationshipToChild_CODE NOT IN(@Lc_RelationshipToChildFTR_CODE, @Lc_RelationshipToChildMTR_CODE)
                                                         AND Ncp.MemberMci_IDNO <> @Ln_ReferralsCurNcpMci_IDNO
                                                         AND (EXISTS (SELECT 1
                                                                        FROM SORD_Y1 s
                                                                       WHERE s.Case_IDNO = b.Case_IDNO
                                                                         AND s.EndValidity_DATE = @Ld_High_DATE
                                                                         AND s.OrderEnd_DATE >= @Ld_Run_DATE)
                                                               OR EXISTS (SELECT 1
                                                                            FROM LIVAD_Y1
                                                                           WHERE NcpMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                                                                             AND NcpSex_CODE <> @Lc_MemberSexMale_CODE))))), 0);

      IF @Lb_CreateCaseCommon_BIT = 1
       BEGIN
        GOTO CREATENEWCASE;
       END

      --Create new Case Scenarios 8,9,10 AND 11 
      --Check NCP and child's birth date, if unknown process set the child's age is greater than 12 as true
      IF ISDATE(@Lc_BirthDate_TEXT) = @Ln_Zero_NUMB
          OR ISDATE(@Lc_ReferralsCur_ChildBirthDate_TEXT) = @Ln_Zero_NUMB
       BEGIN
        SET @Lb_ChildAndNcpAgeGreateThan12_BIT = 1;
       END
      ELSE
       BEGIN
        SET @Lb_ChildAndNcpAgeGreateThan12_BIT = ISNULL((SELECT 1
                                                          WHERE (DATEDIFF(YY, @Lc_BirthDate_TEXT, @Lc_ReferralsCur_ChildBirthDate_TEXT) - CASE
                                                                                                                                           WHEN DATEADD(YY, DATEDIFF(YY, @Lc_BirthDate_TEXT, @Lc_ReferralsCur_ChildBirthDate_TEXT), @Lc_BirthDate_TEXT) > @Lc_ReferralsCur_ChildBirthDate_TEXT
                                                                                                                                            THEN 1
                                                                                                                                           ELSE 0
                                                                                                                                          END) > @Li_ChildAge12_NUMB), 0);
       END

      --CREATE NEW CASE
      CREATENEWCASE:;

      IF ((@Lb_ChildAndNcpAgeGreateThan12_BIT = 1
           AND ((@Lb_CpExistsInDemo_BIT = 1
                 AND @Lb_ChildExistsInDemo_BIT = 0
                 AND @Lb_NcpExistsInDemo_BIT = 0)
                 OR (@Lb_NcpExistsInDemo_BIT = 1
                     AND @Lb_ChildExistsInDemo_BIT = 0
                     AND @Lb_CpExistsInDemo_BIT = 0)
                 OR (@Lb_ChildExistsInDemo_BIT = 1
                     AND @Lb_CpExistsInDemo_BIT = 0
                     AND @Lb_NcpExistsInDemo_BIT = 0)
                 OR (@Lb_ChildExistsInDemo_BIT = 0
                     AND @Lb_CpExistsInDemo_BIT = 0
                     AND @Lb_NcpExistsInDemo_BIT = 0)))
           OR @Lb_CreateCase1_BIT = 1
           OR @Lb_CreateCase4_BIT = 1
           OR @Lb_CreateCaseCommon_BIT = 1)
       BEGIN
        --CHILD DEMO
        IF @Lb_ChildExistsInDemo_BIT = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT DEMO_Y1 FOR CHILD CREATE CASE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_ReferralsCur_ChildLast_NAME, '') + ', Suffix_NAME = ' + ISNULL(@Lc_ReferralsCur_ChildSuffix_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_ReferralsCur_ChildFirst_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_ReferralsCur_ChildMiddle_NAME, '') + ', FullDisplay_NAME = ' + ISNULL(@Ls_ChildFullDisplay_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_ReferralsCur_ChildSex_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_ReferralsCurChildSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_ReferralsCurChildBirth_DATE AS VARCHAR), '') + ', Race_CODE = ' + ISNULL(@Lc_ChildMappedRace_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO
           @An_MemberMci_IDNO           = @Ln_ReferralsCurChildMci_IDNO,
           @Ac_Last_NAME                = @Lc_ReferralsCur_ChildLast_NAME,
           @Ac_Suffix_NAME              = @Lc_ReferralsCur_ChildSuffix_NAME,
           @Ac_First_NAME               = @Lc_ReferralsCur_ChildFirst_NAME,
           @Ac_Middle_NAME              = @Lc_ReferralsCur_ChildMiddle_NAME,
           @As_FullDisplay_NAME         = @Ls_ChildFullDisplay_NAME,
           @Ac_MemberSex_CODE           = @Lc_ReferralsCur_ChildSex_CODE,
           @An_MemberSsn_NUMB           = @Ln_ReferralsCurChildSsn_NUMB,
           @Ad_Birth_DATE               = @Ld_ReferralsCurChildBirth_DATE,
           @Ac_Race_CODE                = @Lc_ChildMappedRace_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        --CHILD MSSN	
        IF (@Lb_ChildExistsInMssn_BIT = 0
            AND @Ln_ReferralsCurChildSsn_NUMB != 0)
           AND NOT EXISTS (SELECT 1
                             FROM MSSN_Y1
                            WHERE EndValidity_DATE = @Ld_High_DATE
                              AND MemberSsn_NUMB = @Ln_ReferralsCurChildSsn_NUMB
                              AND MemberMci_IDNO != @Ln_ReferralsCurChildMci_IDNO
                              AND Enumeration_CODE NOT IN ('B'))
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR CHILD CREATE CASE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_ReferralsCurChildSsn_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Lc_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_COMMON$SP_INSERT_MSSN
           @An_MemberMci_IDNO        = @Ln_ReferralsCurChildMci_IDNO,
           @An_MemberSsn_NUMB        = @Ln_ReferralsCurChildSsn_NUMB,
           @Ac_Enumeration_CODE      = @Lc_Enumeration_CODE,
           @Ad_BeginValidity_DATE    = @Ld_Run_DATE,
           @Ac_Process_ID            = @Lc_Job_ID,
           @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        --CP DEMO
        IF @Lb_CpExistsInDemo_BIT = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT DEMO_Y1 FOR CP CREATE CASE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_CpLast_NAME, '') + ', Suffix_NAME = ' + ISNULL(@Lc_CpSuffix_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_CpFirst_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_CpMiddle_NAME, '') + ', FullDisplay_NAME = ' + ISNULL(@Ls_CpFullDisplay_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_CpSex_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_CpSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_CpBirth_DATE AS VARCHAR), '') + ', Race_CODE = ' + ISNULL(@Lc_CpMappedRace_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO
           @An_MemberMci_IDNO           = @Ln_ReferralsCurCpMci_IDNO,
           @Ac_Last_NAME                = @Lc_CpLast_NAME,
           @Ac_Suffix_NAME              = @Lc_CpSuffix_NAME,
           @Ac_First_NAME               = @Lc_CpFirst_NAME,
           @Ac_Middle_NAME              = @Lc_CpMiddle_NAME,
           @As_FullDisplay_NAME         = @Ls_CpFullDisplay_NAME,
           @Ac_MemberSex_CODE           = @Lc_CpSex_CODE,
           @An_MemberSsn_NUMB           = @Ln_CpSsn_NUMB,
           @Ad_Birth_DATE               = @Ld_CpBirth_DATE,
           @Ac_Race_CODE                = @Lc_CpMappedRace_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        --CP MSSN	
        IF (@Lb_CpExistsInMssn_BIT = 0
            AND @Ln_CpSsn_NUMB != 0)
           AND NOT EXISTS (SELECT 1
                             FROM MSSN_Y1
                            WHERE EndValidity_DATE = @Ld_High_DATE
                              AND MemberSsn_NUMB = @Ln_CpSsn_NUMB
                              AND MemberMci_IDNO != @Ln_ReferralsCurCpMci_IDNO
                              AND Enumeration_CODE NOT IN ('B'))
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR CP CREATE CASE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_CpSsn_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Lc_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_COMMON$SP_INSERT_MSSN
           @An_MemberMci_IDNO        = @Ln_ReferralsCurCpMci_IDNO,
           @An_MemberSsn_NUMB        = @Ln_CpSsn_NUMB,
           @Ac_Enumeration_CODE      = @Lc_Enumeration_CODE,
           @Ad_BeginValidity_DATE    = @Ld_Run_DATE,
           @Ac_Process_ID            = @Lc_Job_ID,
           @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        --NCP DEMO
        IF @Lb_NcpExistsInDemo_BIT = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT DEMO_Y1 FOR NCP CREATE CASE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_NcpLast_NAME, '') + ', Suffix_NAME = ' + ISNULL(@Lc_NcpSuffix_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_NcpFirst_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_NcpMiddle_NAME, '') + ', FullDisplay_NAME = ' + ISNULL(@Ls_NcpFullDisplay_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_NcpSex_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_NcpBirth_DATE AS VARCHAR), '') + ', Race_CODE = ' + ISNULL(@Lc_NcpMappedRace_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO
           @An_MemberMci_IDNO           = @Ln_ReferralsCurNcpMci_IDNO,
           @Ac_Last_NAME                = @Lc_NcpLast_NAME,
           @Ac_Suffix_NAME              = @Lc_NcpSuffix_NAME,
           @Ac_First_NAME               = @Lc_NcpFirst_NAME,
           @Ac_Middle_NAME              = @Lc_NcpMiddle_NAME,
           @As_FullDisplay_NAME         = @Ls_NcpFullDisplay_NAME,
           @Ac_MemberSex_CODE           = @Lc_NcpSex_CODE,
           @An_MemberSsn_NUMB           = @Ln_NcpSsn_NUMB,
           @Ad_Birth_DATE               = @Ld_NcpBirth_DATE,
           @Ac_Race_CODE                = @Lc_NcpMappedRace_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        --NCP MSSN	
        IF (@Lb_NcpExistsInMssn_BIT = 0
            AND @Ln_NcpSsn_NUMB != 0)
           AND NOT EXISTS (SELECT 1
                             FROM MSSN_Y1
                            WHERE EndValidity_DATE = @Ld_High_DATE
                              AND MemberSsn_NUMB = @Ln_NcpSsn_NUMB
                              AND MemberMci_IDNO != @Ln_ReferralsCurNcpMci_IDNO
                              AND Enumeration_CODE NOT IN ('B'))
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR NCP CREATE CASE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpSsn_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Lc_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_COMMON$SP_INSERT_MSSN
           @An_MemberMci_IDNO        = @Ln_ReferralsCurNcpMci_IDNO,
           @An_MemberSsn_NUMB        = @Ln_NcpSsn_NUMB,
           @Ac_Enumeration_CODE      = @Lc_Enumeration_CODE,
           @Ad_BeginValidity_DATE    = @Ld_Run_DATE,
           @Ac_Process_ID            = @Lc_Job_ID,
           @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        --Create CASE and Get Case_IDNO
        SET @Lc_TypeCase_CODE = CASE
                                 WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareTANF_CODE
                                  THEN @Lc_TypeWelfareTANF_CODE
                                 WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareMedicaid_CODE
                                  THEN @Lc_TypeWelfareNonTanf_CODE
                                 WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareNonTanf_CODE
                                  THEN @Lc_TypeWelfareNonTanf_CODE
                                END
        SET @Lc_CaseCategory_CODE = CASE
                                     WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareTANF_CODE
                                      THEN @Lc_CaseCategoryFS_CODE
                                     WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareMedicaid_CODE
                                      THEN @Lc_CaseCategoryMO_CODE
                                     WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareNonTanf_CODE
                                      THEN @Lc_CaseCategoryPO_CODE
                                    END
        SET @Lc_ReasonFeeWaived_CODE = CASE
                                        WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareTANF_CODE
                                         THEN @Lc_ReasonFeeWaivedTA_CODE
                                        WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareMedicaid_CODE
                                         THEN @Lc_ReasonFeeWaivedCM_CODE
                                        WHEN @Lc_IVACaseType_CODE = @Lc_TypeWelfareNonTanf_CODE
                                         THEN @Lc_ReasonFeeWaivedCC_CODE
                                       END
        -- Use newly created case_idno to create CMEM,MHIS and elsewhere entry
        SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CASE';
        SET @Ls_Sqldata_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_ReferralsCur_StatusCase_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCase_CODE, '') + ', County_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurWelfareCaseCounty_IDNO AS VARCHAR), '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_ReferralsCur_FileLoad_DATE AS VARCHAR), '') + ', CaseCategory_CODE = ' + ISNULL(@Lc_CaseCategory_CODE, '') + ', ReasonFeeWaived_CODE = ' + ISNULL(@Lc_ReasonFeeWaived_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CASE
         @Ac_StatusCase_CODE          = @Lc_ReferralsCur_StatusCase_CODE,
         @Ac_TypeCase_CODE            = @Lc_TypeCase_CODE,
         @An_County_IDNO              = @Ln_ReferralsCurWelfareCaseCounty_IDNO,
         @Ad_FileLoad_DATE            = @Ld_ReferralsCur_FileLoad_DATE,
         @Ac_CaseCategory_CODE        = @Lc_CaseCategory_CODE,
         @Ac_ReasonFeeWaived_CODE     = @Lc_ReasonFeeWaived_CODE,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @An_Case_IDNO                = @Ln_NewlyCreatedCase_IDNO OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        --CREATES ESTABLISHMENT STATUS FOR NEWLY CREATED CASE
        SET @Ls_Sql_TEXT = 'INSERT ACES_Y1 FOR ESTABLISHMENT';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', BeginEstablishment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', StatusEstablish_CODE = ' + ISNULL(@Lc_StatusEstablishOpen_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSI_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

        INSERT ACES_Y1
               (Case_IDNO,
                BeginEstablishment_DATE,
                StatusEstablish_CODE,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                WorkerUpdate_ID,
                Update_DTTM,
                TransactionEventSeq_NUMB)
        VALUES ( @Ln_NewlyCreatedCase_IDNO,--Case_IDNO
                 @Ld_Run_DATE,--BeginEstablishment_DATE
                 @Lc_StatusEstablishOpen_CODE,--StatusEstablish_CODE
                 @Lc_ReasonStatusSI_CODE,--ReasonStatus_CODE
                 @Ld_Run_DATE,--BeginValidity_DATE
                 @Ld_High_DATE,--EndValidity_DATE
                 @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                 @Ld_Start_DATE,--Update_DTTM
                 @Ln_TransactionEventSeq_NUMB --TransactionEventSeq_NUMB
        );

        SET @Li_RowsCount_QNTY = @@ROWCOUNT;

        IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'INSERT ACES_Y1 FAILED';

          RAISERROR (50001,16,1);
         END

        --CHILD-CMEM
        SET @Ls_Sql_TEXT = 'EXECUTE	BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM FOR NEWLY CREATED CASE CHILD';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipChild_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', CpRelationshipToChild_CODE = ' + ISNULL(@Lc_ReferralsCur_CpRelationshipToChild_CODE, '') + ', NcpRelationshipToChild_CODE = ' + ISNULL(@Lc_ReferralsCur_NcpRelationshipToChild_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM
         @An_Case_IDNO                   = @Ln_NewlyCreatedCase_IDNO,
         @An_MemberMci_IDNO              = @Ln_ReferralsCurChildMci_IDNO,
         @Ac_CaseRelationship_CODE       = @Lc_CaseRelationshipChild_CODE,
         @Ac_CaseMemberStatus_CODE       = @Lc_CaseMemberStatusActive_CODE,
         @Ac_CpRelationshipToChild_CODE  = @Lc_ReferralsCur_CpRelationshipToChild_CODE,
         @Ac_NcpRelationshipToChild_CODE = @Lc_ReferralsCur_NcpRelationshipToChild_CODE,
         @Ac_WorkerUpdate_ID             = @Lc_BatchRunUser_TEXT,
         @An_TransactionEventSeq_NUMB    = @Ln_TransactionEventSeq_NUMB,
         @Ac_Msg_CODE                    = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT       = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        --CP-CMEM
        SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM FOR NEWLY CREATED CASE CP';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM
         @An_Case_IDNO                = @Ln_NewlyCreatedCase_IDNO,
         @An_MemberMci_IDNO           = @Ln_ReferralsCurCpMci_IDNO,
         @Ac_CaseRelationship_CODE    = @Lc_CaseRelationshipCp_CODE,
         @Ac_CaseMemberStatus_CODE    = @Lc_CaseMemberStatusActive_CODE,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        --NCP-CMEM
        SET @Ls_Sql_TEXT = 'EXECUTE	BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM FOR NEWLY CREATED CASE NCP';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_NcpCaseRelationship_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM
         @An_Case_IDNO                = @Ln_NewlyCreatedCase_IDNO,
         @An_MemberMci_IDNO           = @Ln_ReferralsCurNcpMci_IDNO,
         @Ac_CaseRelationship_CODE    = @Lc_NcpCaseRelationship_CODE,
         @Ac_CaseMemberStatus_CODE    = @Lc_CaseMemberStatusActive_CODE,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
        SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ParticipantTanfStatusChange2720_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

        EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
         @An_EventFunctionalSeq_NUMB = @Li_ParticipantTanfStatusChange2720_NUMB,
         @Ac_Process_ID              = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
         @Ac_Note_INDC               = @Lc_IndNote_TEXT,
         @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
         @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        --CHILD-MHIS
        SET @Ls_Sql_TEXT = 'EXECUTE	BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS FOR NEWLY CREATED CASE CHILD';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_IVACaseType_CODE, '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCaseWelfare_IDNO AS VARCHAR), '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonPA_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS
         @An_MemberMci_IDNO           = @Ln_ReferralsCurChildMci_IDNO,
         @An_Case_IDNO                = @Ln_NewlyCreatedCase_IDNO,
         @Ad_Start_DATE               = @Ld_Run_DATE,
         @Ac_TypeWelfare_CODE         = @Lc_IVACaseType_CODE,
         @An_CaseWelfare_IDNO         = @Ln_ReferralsCurCaseWelfare_IDNO,
         @Ac_Reason_CODE              = @Lc_ReasonPA_CODE,
         @An_EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        --CP-MHIS
        SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS FOR NEWLY CREATED CASE CP';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_IVACaseType_CODE, '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCaseWelfare_IDNO AS VARCHAR), '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonPA_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS
         @An_MemberMci_IDNO           = @Ln_ReferralsCurCpMci_IDNO,
         @An_Case_IDNO                = @Ln_NewlyCreatedCase_IDNO,
         @Ad_Start_DATE               = @Ld_Run_DATE,
         @Ac_TypeWelfare_CODE         = @Lc_IVACaseType_CODE,
         @An_CaseWelfare_IDNO         = @Ln_ReferralsCurCaseWelfare_IDNO,
         @Ac_Reason_CODE              = @Lc_ReasonPA_CODE,
         @An_EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        --Generate Alert and Assign Worker on newly created case.
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ALERT_WORKER FOR NEWLY CREATED CASE';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Role_ID = ' + ISNULL(@Lc_WorkerRole_ID, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

        EXECUTE BATCH_COMMON$SP_ALERT_WORKER
         @An_Case_IDNO                = @Ln_NewlyCreatedCase_IDNO,
         @Ac_SignedonWorker_ID        = @Lc_BatchRunUser_TEXT,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_Role_ID                  = @Lc_WorkerRole_ID,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
             OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                 AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
         BEGIN
          SET @Lc_BateError_CODE = @Lc_Msg_CODE;

          RAISERROR (50001,16,1);
         END
        ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
          EXECUTE BATCH_COMMON$SP_BATE_LOG
           @As_Process_NAME             = @Ls_Process_NAME,
           @As_Procedure_NAME           = @Ls_Procedure_NAME,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
           @An_Line_NUMB                = @Ln_RestartLine_NUMB,
           @Ac_Error_CODE               = @Lc_Msg_CODE,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
           @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        --CP AHIS
        IF RTRIM(LTRIM(@Ls_CpLine1_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_CpCity_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_CpState_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_CpZip_ADDR)) <> ''
		   AND @Ln_ReferralsCurCpMci_IDNO != @Ln_UnknownNcpMci_IDNO
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE, NEWLY CREATED CASE FOR CP';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Line1_ADDR = ' + ISNULL(@Ls_CpLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_CpLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_CpCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_CpState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_CpZip_ADDR, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_MemberSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusP_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_CpAddrNormalization_CODE, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_ReferralsCurCpMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @As_Line1_ADDR                       = @Ls_CpLine1_ADDR,
           @As_Line2_ADDR                       = @Ls_CpLine2_ADDR,
           @Ac_City_ADDR                        = @Lc_CpCity_ADDR,
           @Ac_State_ADDR                       = @Lc_CpState_ADDR,
           @Ac_Zip_ADDR                         = @Lc_CpZip_ADDR,
           @Ac_SourceLoc_CODE                   = @Lc_MemberSourceLoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_VerificationStatusP_CODE,
           @Ac_SourceVerified_CODE              = @Lc_CaseRelationshipCp_CODE,
           @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
           @Ac_Process_ID                       = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @Ac_Normalization_CODE               = @Lc_CpAddrNormalization_CODE,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

          IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
               OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                   AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
           BEGIN
            EXECUTE BATCH_COMMON$SP_BATE_LOG
             @As_Process_NAME             = @Ls_Process_NAME,
             @As_Procedure_NAME           = @Ls_Procedure_NAME,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
             @An_Line_NUMB                = @Ln_RestartLine_NUMB,
             @Ac_Error_CODE               = @Lc_Msg_CODE,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
             @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END
         END

        --CP EHIS
        IF RTRIM(LTRIM(@Ls_CpEmployer_NAME)) <> ''
           AND RTRIM(LTRIM(@Ls_CpEmployerLine1_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_CpEmployerCity_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_CpEmployerState_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_CpEmployerZip_ADDR)) <> ''
		   AND @Ln_ReferralsCurCpMci_IDNO != @Ln_UnknownNcpMci_IDNO
         BEGIN
          -- OTHP ID Insert, Employer address insertion
          SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE, NEWLY CREATED CASE FOR CP';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', OtherParty_NAME = ' + ISNULL(@Ls_CpEmployer_NAME, '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_MemberFein_IDNO AS VARCHAR), '') + ', AddrNormalization_CODE = ' + ISNULL(@Lc_CpEmpAddrNormalization_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_CpEmployerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_CpEmployerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_CpEmployerCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_CpEmployerState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_CpEmployerZip_ADDR, '');

          EXECUTE BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE
           @An_MemberMci_IDNO         = @Ln_ReferralsCurCpMci_IDNO,
           @Ad_Run_DATE               = @Ld_Run_DATE,
           @Ac_Job_ID                 = @Lc_Job_ID,
           @As_OtherParty_NAME        = @Ls_CpEmployer_NAME,
           @An_Fein_IDNO              = @Ln_MemberFein_IDNO,
           @Ac_AddrNormalization_CODE = @Lc_CpEmpAddrNormalization_CODE,
           @As_Line1_ADDR             = @Ls_CpEmployerLine1_ADDR,
           @As_Line2_ADDR             = @Ls_CpEmployerLine2_ADDR,
           @Ac_City_ADDR              = @Lc_CpEmployerCity_ADDR,
           @Ac_State_ADDR             = @Lc_CpEmployerState_ADDR,
           @Ac_Zip_ADDR               = @Lc_CpEmployerZip_ADDR,
           @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

          IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
               OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                   AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            EXECUTE BATCH_COMMON$SP_BATE_LOG
             @As_Process_NAME             = @Ls_Process_NAME,
             @As_Procedure_NAME           = @Ls_Procedure_NAME,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
             @An_Line_NUMB                = @Ln_RestartLine_NUMB,
             @Ac_Error_CODE               = @Lc_Msg_CODE,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
             @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END
         END

        --NCP AHIS
        IF RTRIM(LTRIM(@Ls_NcpLine1_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_NcpCity_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_NcpState_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_NcpZip_ADDR)) <> ''
		   AND @Ln_ReferralsCurNcpMci_IDNO != @Ln_UnknownNcpMci_IDNO
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE, NEWLY CREATED CASE FOR NCP';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Line1_ADDR = ' + ISNULL(@Ls_NcpLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_NcpLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_NcpCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_NcpState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_NcpZip_ADDR, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_MemberSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusP_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_CaseRelationshipNcpP_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_NcpAddrNormalization_CODE, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_ReferralsCurNcpMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @As_Line1_ADDR                       = @Ls_NcpLine1_ADDR,
           @As_Line2_ADDR                       = @Ls_NcpLine2_ADDR,
           @Ac_City_ADDR                        = @Lc_NcpCity_ADDR,
           @Ac_State_ADDR                       = @Lc_NcpState_ADDR,
           @Ac_Zip_ADDR                         = @Lc_NcpZip_ADDR,
           @Ac_SourceLoc_CODE                   = @Lc_MemberSourceLoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_VerificationStatusP_CODE,
           @Ac_SourceVerified_CODE              = @Lc_CaseRelationshipNcpP_CODE,
           @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
           @Ac_Process_ID                       = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @Ac_Normalization_CODE               = @Lc_NcpAddrNormalization_CODE,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

          IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
               OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                   AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
           BEGIN
            EXECUTE BATCH_COMMON$SP_BATE_LOG
             @As_Process_NAME             = @Ls_Process_NAME,
             @As_Procedure_NAME           = @Ls_Procedure_NAME,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
             @An_Line_NUMB                = @Ln_RestartLine_NUMB,
             @Ac_Error_CODE               = @Lc_Msg_CODE,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
             @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END
         END

        --NCP EHIS
        IF RTRIM(LTRIM(@Ls_NcpEmployer_NAME)) <> ''
           AND RTRIM(LTRIM(@Ls_NcpEmployerLine1_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_NcpEmployerCity_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_NcpEmployerState_ADDR)) <> ''
           AND RTRIM(LTRIM(@Lc_NcpEmployerZip_ADDR)) <> ''
		   AND @Ln_ReferralsCurNcpMci_IDNO != @Ln_UnknownNcpMci_IDNO
         BEGIN
          -- OTHP ID Insert, Employer address insertion
          SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE, NEWLY CREATED CASE FOR NCP';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', OtherParty_NAME = ' + ISNULL(@Ls_NcpEmployer_NAME, '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', AddrNormalization_CODE = ' + ISNULL(@Lc_NcpEmpAddrNormalization_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_NcpEmployerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_NcpEmployerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_NcpEmployerCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_NcpEmployerState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_NcpEmployerZip_ADDR, '');

          EXECUTE BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE
           @An_MemberMci_IDNO         = @Ln_ReferralsCurNcpMci_IDNO,
           @Ad_Run_DATE               = @Ld_Run_DATE,
           @Ac_Job_ID                 = @Lc_Job_ID,
           @As_OtherParty_NAME        = @Ls_NcpEmployer_NAME,
           @An_Fein_IDNO              = @Ln_Zero_NUMB,
           @Ac_AddrNormalization_CODE = @Lc_NcpEmpAddrNormalization_CODE,
           @As_Line1_ADDR             = @Ls_NcpEmployerLine1_ADDR,
           @As_Line2_ADDR             = @Ls_NcpEmployerLine2_ADDR,
           @Ac_City_ADDR              = @Lc_NcpEmployerCity_ADDR,
           @Ac_State_ADDR             = @Lc_NcpEmployerState_ADDR,
           @Ac_Zip_ADDR               = @Lc_NcpEmployerZip_ADDR,
           @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

          IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
               OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                   AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            EXECUTE BATCH_COMMON$SP_BATE_LOG
             @As_Process_NAME             = @Ls_Process_NAME,
             @As_Procedure_NAME           = @Ls_Procedure_NAME,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
             @An_Line_NUMB                = @Ln_RestartLine_NUMB,
             @Ac_Error_CODE               = @Lc_Msg_CODE,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
             @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END
         END

        --CP LSTT
        IF NOT EXISTS (SELECT TOP 1 1
                         FROM LSTT_Y1
                        WHERE MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO)
         BEGIN
          SET @Ls_Sql_TEXT = 'EXECUTE LSTT_INSERT_S1 - 1';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_MemberSourceLoc_CODE, '');

          EXECUTE LSTT_INSERT_S1
           @An_MemberMci_IDNO           = @Ln_ReferralsCurCpMci_IDNO,
           @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_SourceLoc_CODE           = @Lc_MemberSourceLoc_CODE;

          SET @Li_RowsCount_QNTY = @@ROWCOUNT;

          IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'INSERT LSTT_Y1 FAILED FOR CP MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '');

            RAISERROR (50001,16,1);
           END
         END

        --NCP LSTT
        IF NOT EXISTS (SELECT TOP 1 1
                         FROM LSTT_Y1
                        WHERE MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO)
         BEGIN
          SET @Ls_Sql_TEXT = 'EXECUTE LSTT_INSERT_S1 - 2';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_MemberSourceLoc_CODE, '');

          EXECUTE LSTT_INSERT_S1
           @An_MemberMci_IDNO           = @Ln_ReferralsCurNcpMci_IDNO,
           @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_SourceLoc_CODE           = @Lc_MemberSourceLoc_CODE;

          SET @Li_RowsCount_QNTY = @@ROWCOUNT;

          IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'INSERT LSTT_Y1 FAILED FOR NCP MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '');

            RAISERROR (50001,16,1);
           END
         END

        --NCP LOCATED THEN ELFC FOR ESTP MINOR ACTIVITY
        IF EXISTS (SELECT 1
                     FROM LSTT_Y1 l
                    WHERE l.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                      AND l.StatusLocate_CODE = @Lc_StatusLocate_CODE
                      AND l.EndValidity_DATE = @Ld_High_DATE)
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_ENF_ELFC$SP_INITIATE_REMEDY FOR ESTP';
          SET @Ls_Sqldata_TEXT = 'TypeChange_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', TypeOthpSource_CODE = ' + ISNULL(@Lc_CaseRelationshipNcpA_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemES_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reference_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');

          EXECUTE BATCH_ENF_ELFC$SP_INITIATE_REMEDY
           @Ac_TypeChange_CODE          = @Lc_Space_TEXT,
           @An_Case_IDNO                = @Ln_NewlyCreatedCase_IDNO,
           @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
           @An_MemberMci_IDNO           = @Ln_ReferralsCurNcpMci_IDNO,
           @An_OthpSource_IDNO          = @Ln_ReferralsCurNcpMci_IDNO,
           @Ac_TypeOthpSource_CODE      = @Lc_CaseRelationshipNcpA_CODE,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorEstp_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemES_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeReference_CODE       = @Lc_Space_TEXT,
           @Ac_Reference_ID             = @Lc_Space_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
               OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                   AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            EXECUTE BATCH_COMMON$SP_BATE_LOG
             @As_Process_NAME             = @Ls_Process_NAME,
             @As_Procedure_NAME           = @Ls_Procedure_NAME,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
             @An_Line_NUMB                = @Ln_RestartLine_NUMB,
             @Ac_Error_CODE               = @Lc_Msg_CODE,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
             @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END
         END

        SET @Ls_Sql_TEXT = 'INSERT @CreatedCaseAndCp_P1 FOR SP_INSERT_ACTIVITY FOR CSI-14';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '');

        INSERT @CreatedCaseAndCp_P1
               (Case_IDNO,
                MemberMci_IDNO)
        SELECT DISTINCT
               @Ln_NewlyCreatedCase_IDNO AS Case_IDNO,
               @Ln_ReferralsCurCpMci_IDNO AS MemberMci_IDNO;

        --INSERT ACTIVITY FOR CASE CREATED
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CASE CREATED';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCcrcc_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               @Ln_NewlyCreatedCase_IDNO AS Case_IDNO,
               @Ln_ReferralsCurNcpMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorCcrcc_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE;

        -- 13213 Bug fix, The alert 'NEWRK' should be created to the new worker after the case is assigned to the worker from case creation
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CASE NEWLY ASSIGNED TO WORKER';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorNewrk_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCM_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               @Ln_NewlyCreatedCase_IDNO AS Case_IDNO,
               @Ln_ReferralsCurCpMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorNewrk_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCM_CODE AS Subsystem_CODE;

        -- 13213 End
        --SEND ALERTS 
        --1ST
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 - 1';
        SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorTmrrc_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               c.Case_IDNO,
               cm.MemberMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorTmrrc_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE
          FROM MHIS_Y1 m,
               CMEM_Y1 c,
               CASE_Y1 ca,
               CMEM_Y1 cm
         WHERE m.Case_IDNO <> @Ln_NewlyCreatedCase_IDNO
           AND m.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
           AND m.End_DATE = @Ld_High_DATE
           AND m.TypeWelfare_CODE IN (@Lc_TypeCaseIVEFosterCare_CODE, @Lc_TypeCaseNonIVD_CODE)
           AND m.Case_IDNO = c.Case_IDNO
           AND m.Case_IDNO = ca.Case_IDNO
           AND ca.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
           AND m.MemberMci_IDNO = c.MemberMci_IDNO
           AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND c.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
           AND cm.Case_IDNO = m.Case_IDNO
           AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND cm.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;

        --3RD
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 - 2';
        SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCam2c_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               ca.Case_IDNO,
               c.MemberMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorCam2c_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE
          FROM CMEM_Y1 cm,
               CASE_Y1 ca,
               CMEM_Y1 c
         WHERE ca.Case_IDNO <> @Ln_NewlyCreatedCase_IDNO
           AND ca.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
           AND cm.Case_IDNO = ca.Case_IDNO
           AND cm.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
           AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND cm.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
           AND c.Case_IDNO = ca.Case_IDNO
           AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;

        --2nd Case
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CLFCC MinorActivity';
        SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorClfcc_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               c.Case_IDNO,
               cm.MemberMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorClfcc_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE
          FROM MHIS_Y1 m,
               CMEM_Y1 c,
               CASE_Y1 ca,
               CMEM_Y1 cm
         WHERE m.Case_IDNO <> @Ln_NewlyCreatedCase_IDNO
           AND m.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
           AND m.End_DATE = @Ld_High_DATE
           AND m.TypeWelfare_CODE IN (@Lc_TypeCaseIVEFosterCare_CODE, @Lc_TypeCaseNonFederalFosterCare_CODE, @Lc_TypeCaseNonIVD_CODE)
           AND m.Case_IDNO = c.Case_IDNO
           AND m.Case_IDNO = ca.Case_IDNO
           AND ca.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
           AND m.MemberMci_IDNO = c.MemberMci_IDNO
           AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND c.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
           AND cm.Case_IDNO = m.Case_IDNO
           AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
           AND (@Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                 OR @Lc_ReferralsCur_Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT);

        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CELPC MinorActivity';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NewlyCreatedCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCelpc_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               @Ln_NewlyCreatedCase_IDNO AS Case_IDNO,
               @Ln_ReferralsCurCpMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorCelpc_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE
          FROM LIVAR_Y1 l
         WHERE l.CaseWelfare_IDNO = @Ln_ReferralsCurCaseWelfare_IDNO
           AND l.CpMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
           AND l.NcpMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
           AND l.ChildMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
           AND l.FileLoad_DATE = @Ld_ReferralsCur_FileLoad_DATE
           AND l.Program_CODE = @Lc_PurchaseOfCare_CODE
           AND @Lc_ReferralsCur_Program_CODE <> @Lc_PurchaseOfCare_CODE;

        --5th Case
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CSPPC MinorActivity';
        SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCsppc_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               ca.Case_IDNO,
               Cp.MemberMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorCsppc_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE
          FROM CMEM_Y1 Cp,
               CMEM_Y1 Ncp,
               CMEM_Y1 Child,
               CASE_Y1 ca
         WHERE @Lb_CreateCase1_BIT = 1
           AND Cp.Case_IDNO = Ncp.Case_IDNO
           AND Cp.Case_IDNO = ca.Case_IDNO
           AND Child.Case_IDNO = ca.Case_IDNO
           AND ca.Case_IDNO != @Ln_NewlyCreatedCase_IDNO
           AND ca.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
           AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
           AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpP_CODE, @Lc_CaseRelationshipNcpA_CODE)
           AND Child.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND Child.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
           AND Child.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
           AND Cp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
           AND Ncp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO;

        --6th Case
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR FCM1N MinorActivity';
        SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorFcm1n_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               b.Case_IDNO,
               Ncp.MemberMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorFcm1n_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE
          FROM CASE_Y1 b,
               CMEM_Y1 Cp,
               CMEM_Y1 Dp,
               CMEM_Y1 Ncp
         WHERE b.Case_IDNO = Cp.Case_IDNO
           AND b.Case_IDNO = Dp.Case_IDNO
           AND b.Case_IDNO = Ncp.Case_IDNO
           AND b.Case_IDNO != @Ln_NewlyCreatedCase_IDNO
           AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
           AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
           AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
           AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
           AND Dp.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
           AND @Lc_ReferralsCur_CpRelationshipToChild_CODE = @Lc_RelationshipToChildFTR_CODE
           AND Cp.MemberMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
           AND Ncp.MemberMci_IDNO <> @Ln_ReferralsCurNcpMci_IDNO;

        --7th Case
        SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CAM1C MinorActivity';
        SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCam1c_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

        INSERT ##InsertActivity_P1
               (Case_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                Subsystem_CODE)
        SELECT DISTINCT
               b.Case_IDNO,
               Cp.MemberMci_IDNO AS MemberMci_IDNO,
               @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
               @Lc_ActivityMinorCam1c_CODE AS ActivityMinor_CODE,
               @Lc_SubsystemCI_CODE AS Subsystem_CODE
          FROM CASE_Y1 b,
               CMEM_Y1 Cp,
               CMEM_Y1 Dp,
               CMEM_Y1 Ncp
         WHERE b.Case_IDNO = Cp.Case_IDNO
           AND b.Case_IDNO = Dp.Case_IDNO
           AND b.Case_IDNO = Ncp.Case_IDNO
           AND b.Case_IDNO != @Ln_NewlyCreatedCase_IDNO
           AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
           AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
           AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
           AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
           AND Dp.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO
           AND Ncp.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
           AND Dp.NcpRelationshipToChild_CODE = @Lc_ReferralsCur_NcpRelationshipToChild_CODE
           AND Cp.MemberMci_IDNO <> @Ln_ReferralsCurCpMci_IDNO;
       END
      ELSE
       BEGIN
        --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
		SKIPREFERRAL:;
		SET @Ls_DescriptionError_TEXT = 'Referrals did not meet any business rules.';
		--13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorI_CODE,
         @An_Line_NUMB                = @Ln_RestartLine_NUMB,
         @Ac_Error_CODE               = @Lc_ErrorE1176_CODE,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
         @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
       END

      SKIPCREATENEWCASE:;

      IF @Lb_ChangeChildsProgramType_BIT = 1
          OR @Lb_AddAbsentParentOnTheCase_BIT = 1
          OR @Lb_AddChildOnExistingIVDCase_BIT = 1
       BEGIN
        --ADDING additional ABSENT PARENT as PF ON THE CASE	
        IF @Lb_AddAbsentParentOnTheCase_BIT = 1
         BEGIN
          IF @Lb_NcpExistsInDemo_BIT = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'INSERT DEMO_Y1 FOR ADDING NCP AS EXTRA AP ON EXISTING CASE';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_NcpLast_NAME, '') + ', Suffix_NAME = ' + ISNULL(@Lc_NcpSuffix_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_NcpFirst_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_NcpMiddle_NAME, '') + ', FullDisplay_NAME = ' + ISNULL(@Ls_NcpFullDisplay_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_NcpSex_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_NcpBirth_DATE AS VARCHAR), '') + ', Race_CODE = ' + ISNULL(@Lc_NcpMappedRace_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

            EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO
             @An_MemberMci_IDNO           = @Ln_ReferralsCurNcpMci_IDNO,
             @Ac_Last_NAME                = @Lc_NcpLast_NAME,
             @Ac_Suffix_NAME              = @Lc_NcpSuffix_NAME,
             @Ac_First_NAME               = @Lc_NcpFirst_NAME,
             @Ac_Middle_NAME              = @Lc_NcpMiddle_NAME,
             @As_FullDisplay_NAME         = @Ls_NcpFullDisplay_NAME,
             @Ac_MemberSex_CODE           = @Lc_NcpSex_CODE,
             @An_MemberSsn_NUMB           = @Ln_NcpSsn_NUMB,
             @Ad_Birth_DATE               = @Ld_NcpBirth_DATE,
             @Ac_Race_CODE                = @Lc_NcpMappedRace_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END

          IF (@Lb_NcpExistsInMssn_BIT = 0
              AND @Ln_NcpSsn_NUMB != 0)
             AND NOT EXISTS (SELECT 1
                               FROM MSSN_Y1
                              WHERE EndValidity_DATE = @Ld_High_DATE
                                AND MemberSsn_NUMB = @Ln_NcpSsn_NUMB
                                AND MemberMci_IDNO != @Ln_ReferralsCurNcpMci_IDNO
                                AND Enumeration_CODE NOT IN ('B'))
           BEGIN
            SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR ADDING NCP AS EXTRA AP ON EXISTING CASE';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpSsn_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Lc_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

            EXECUTE BATCH_COMMON$SP_INSERT_MSSN
             @An_MemberMci_IDNO        = @Ln_ReferralsCurNcpMci_IDNO,
             @An_MemberSsn_NUMB        = @Ln_NcpSsn_NUMB,
             @Ac_Enumeration_CODE      = @Lc_Enumeration_CODE,
             @Ad_BeginValidity_DATE    = @Ld_Run_DATE,
             @Ac_Process_ID            = @Lc_Job_ID,
             @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT,
             @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END

          IF NOT EXISTS(SELECT 1
                          FROM CMEM_Y1 a,
                               @TempIVDCaseAndChildStatus_P1 b
                         WHERE a.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                           AND b.TypeAction_CODE = @Lc_TypeActionAA_CODE
                           AND a.Case_IDNO = b.Case_IDNO)
           BEGIN
            --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -START-
		    --CCRNP - INSERT ACTIVITY FOR NEW PUTATIVE FATHER ADDED TO THE CASE
		    SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR NEW PUTATIVE FATHER ADDED TO THE CASE';
		    SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCcrnp_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

		    INSERT ##InsertActivity_P1
				   (Case_IDNO,
				    MemberMci_IDNO,
				    ActivityMajor_CODE,
				    ActivityMinor_CODE,
				    Subsystem_CODE)
		    SELECT DISTINCT
				   a.Case_IDNO AS Case_IDNO,
				   @Ln_ReferralsCurNcpMci_IDNO AS MemberMci_IDNO,
				   @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
				   @Lc_ActivityMinorCcrnp_CODE AS ActivityMinor_CODE,
			 	   @Lc_SubsystemCI_CODE AS Subsystem_CODE
              FROM @TempIVDCaseAndChildStatus_P1 a
             WHERE a.TypeAction_CODE = @Lc_TypeActionAA_CODE
               AND NOT EXISTS(SELECT 1
                                FROM CMEM_Y1 c
                               WHERE c.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                                 AND a.Case_IDNO = c.Case_IDNO);
		    --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -END-

			SET @Ls_Sql_TEXT = 'INSERT CMEM_Y1 FOR AddAbsentParentOnTheCase ';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_NcpCaseRelationship_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', CpRelationshipToChild_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', NcpRelationshipToChild_CODE = ' + ISNULL(@Lc_ReferralsCur_NcpRelationshipToChild_CODE, '') + ', BenchWarrant_INDC = ' + ISNULL(@Lc_BenchWarrant_INDC, '') + ', ReasonMemberStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Applicant_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', FamilyViolence_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', FamilyViolence_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeFamilyViolence_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

            INSERT CMEM_Y1
                   (Case_IDNO,
                    MemberMci_IDNO,
                    CaseRelationship_CODE,
                    CaseMemberStatus_CODE,
                    CpRelationshipToChild_CODE,
                    NcpRelationshipToChild_CODE,
                    BenchWarrant_INDC,
                    ReasonMemberStatus_CODE,
                    Applicant_CODE,
                    BeginValidity_DATE,
                    WorkerUpdate_ID,
                    TransactionEventSeq_NUMB,
                    Update_DTTM,
                    FamilyViolence_DATE,
                    FamilyViolence_INDC,
                    TypeFamilyViolence_CODE)
            SELECT DISTINCT
                   a.Case_IDNO,
                   @Ln_ReferralsCurNcpMci_IDNO AS MemberMci_IDNO,
                   @Lc_NcpCaseRelationship_CODE AS CaseRelationship_CODE,
                   @Lc_CaseMemberStatusActive_CODE AS CaseMemberStatus_CODE,
                   @Lc_Space_TEXT AS CpRelationshipToChild_CODE,
                   @Lc_ReferralsCur_NcpRelationshipToChild_CODE AS NcpRelationshipToChild_CODE,
                   @Lc_BenchWarrant_INDC AS BenchWarrant_INDC,
                   @Lc_Space_TEXT AS ReasonMemberStatus_CODE,
                   @Lc_Space_TEXT AS Applicant_CODE,
                   @Ld_Run_DATE AS BeginValidity_DATE,
                   @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                   @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                   @Ld_Start_DATE AS Update_DTTM,
                   @Ld_Low_DATE AS FamilyViolence_DATE,
                   @Lc_Space_TEXT AS FamilyViolence_INDC,
                   @Lc_Space_TEXT AS TypeFamilyViolence_CODE
              FROM @TempIVDCaseAndChildStatus_P1 a
             WHERE a.TypeAction_CODE = @Lc_TypeActionAA_CODE
               AND NOT EXISTS(SELECT 1
                                FROM CMEM_Y1 c
                               WHERE c.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                                 AND a.Case_IDNO = c.Case_IDNO);
		   END

          IF EXISTS (SELECT 1
                       FROM CMEM_Y1 a,
                            @TempIVDCaseAndChildStatus_P1 b
                      WHERE a.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
                        AND b.TypeAction_CODE = @Lc_TypeActionAA_CODE
                        AND a.Case_IDNO = b.Case_IDNO
                        AND a.CaseRelationship_CODE = @Lc_CaseRelationshipNcpP_CODE
                        AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE)
           BEGIN
            --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -START-
		    --CCRNP - INSERT ACTIVITY FOR PUTATIVE FATHER STATUS HAS BEEN CHANGED TO ACTIVE
		    SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR PUTATIVE FATHER STATUS HAS BEEN CHANGED TO ACTIVE';
		    SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorPscta_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

		    INSERT ##InsertActivity_P1
				  (Case_IDNO,
				   MemberMci_IDNO,
				   ActivityMajor_CODE,
				   ActivityMinor_CODE,
				   Subsystem_CODE)
		    SELECT DISTINCT
				   b.Case_IDNO AS Case_IDNO,
				   @Ln_ReferralsCurNcpMci_IDNO AS MemberMci_IDNO,
				   @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
				   @Lc_ActivityMinorPscta_CODE AS ActivityMinor_CODE,
			 	   @Lc_SubsystemCI_CODE AS Subsystem_CODE
			  FROM CMEM_Y1 c,
                   @TempIVDCaseAndChildStatus_P1 b
             WHERE c.Case_IDNO = b.Case_IDNO
               AND b.TypeAction_CODE = @Lc_TypeActionAA_CODE
               AND c.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
               AND c.CaseRelationship_CODE = @Lc_CaseRelationshipNcpP_CODE
               AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE;
		    --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -END-      
			
			SET @Ls_Sql_TEXT = 'UPDATE CMEM_Y1 FOR AddAbsentParentOnTheCase ';
            SET @Ls_Sqldata_TEXT = 'TypeAction_CODE = ' + ISNULL(@Lc_TypeActionAA_CODE, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipNcpP_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusInActive_CODE, '');

            UPDATE CMEM_Y1
               SET CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE,
                   BeginValidity_DATE = @Ld_Run_DATE,
                   WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                   TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                   Update_DTTM = @Ld_Start_DATE
            OUTPUT Deleted.Case_IDNO,
                   Deleted.MemberMci_IDNO,
                   Deleted.CaseRelationship_CODE,
                   Deleted.CaseMemberStatus_CODE,
                   Deleted.CpRelationshipToChild_CODE,
                   Deleted.NcpRelationshipToChild_CODE,
                   Deleted.BenchWarrant_INDC,
                   Deleted.ReasonMemberStatus_CODE,
                   Deleted.Applicant_CODE,
                   Deleted.BeginValidity_DATE,
                   @Ld_Run_DATE AS EndValidity_DATE,
                   Deleted.WorkerUpdate_ID,
                   Deleted.TransactionEventSeq_NUMB,
                   Deleted.Update_DTTM,
                   Deleted.FamilyViolence_DATE,
                   Deleted.FamilyViolence_INDC,
                   Deleted.TypeFamilyViolence_CODE
            INTO HCMEM_Y1
              FROM CMEM_Y1 c,
                   @TempIVDCaseAndChildStatus_P1 b
             WHERE c.Case_IDNO = b.Case_IDNO
               AND b.TypeAction_CODE = @Lc_TypeActionAA_CODE
               AND c.MemberMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
               AND c.CaseRelationship_CODE = @Lc_CaseRelationshipNcpP_CODE
               AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE;
		   END

          --NCP AHIS
          IF RTRIM(LTRIM(@Ls_NcpLine1_ADDR)) <> ''
             AND RTRIM(LTRIM(@Lc_NcpCity_ADDR)) <> ''
             AND RTRIM(LTRIM(@Lc_NcpState_ADDR)) <> ''
             AND RTRIM(LTRIM(@Lc_NcpZip_ADDR)) <> ''
			 AND @Ln_ReferralsCurNcpMci_IDNO != @Ln_UnknownNcpMci_IDNO
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE, ADDING AP ON EXISTING CASE';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Line1_ADDR = ' + ISNULL(@Ls_NcpLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_NcpLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_NcpCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_NcpState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_NcpZip_ADDR, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_MemberSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusP_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_CaseRelationshipNcpP_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_NcpAddrNormalization_CODE, '');

            EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
             @An_MemberMci_IDNO                   = @Ln_ReferralsCurNcpMci_IDNO,
             @Ad_Run_DATE                         = @Ld_Run_DATE,
             @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
             @Ad_Begin_DATE                       = @Ld_Run_DATE,
             @Ad_End_DATE                         = @Ld_High_DATE,
             @As_Line1_ADDR                       = @Ls_NcpLine1_ADDR,
             @As_Line2_ADDR                       = @Ls_NcpLine2_ADDR,
             @Ac_City_ADDR                        = @Lc_NcpCity_ADDR,
             @Ac_State_ADDR                       = @Lc_NcpState_ADDR,
             @Ac_Zip_ADDR                         = @Lc_NcpZip_ADDR,
             @Ac_SourceLoc_CODE                   = @Lc_MemberSourceLoc_CODE,
             @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
             @Ad_Status_DATE                      = @Ld_Run_DATE,
             @Ac_Status_CODE                      = @Lc_VerificationStatusP_CODE,
             @Ac_SourceVerified_CODE              = @Lc_CaseRelationshipNcpP_CODE,
             @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
             @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
             @Ac_Process_ID                       = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
             @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
             @Ac_Normalization_CODE               = @Lc_NcpAddrNormalization_CODE,
             @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

            IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
                 OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                     AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
             BEGIN
              SET @Lc_BateError_CODE = @Lc_Msg_CODE;

              RAISERROR (50001,16,1);
             END
            ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
             BEGIN
              EXECUTE BATCH_COMMON$SP_BATE_LOG
               @As_Process_NAME             = @Ls_Process_NAME,
               @As_Procedure_NAME           = @Ls_Procedure_NAME,
               @Ac_Job_ID                   = @Lc_Job_ID,
               @Ad_Run_DATE                 = @Ld_Run_DATE,
               @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
               @An_Line_NUMB                = @Ln_RestartLine_NUMB,
               @Ac_Error_CODE               = @Lc_Msg_CODE,
               @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
               @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
               @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END
             END
           END

          --NCP EHIS & OTHP	
          IF RTRIM(LTRIM(@Ls_NcpEmployer_NAME)) <> ''
             AND RTRIM(LTRIM(@Ls_NcpEmployerLine1_ADDR)) <> ''
             AND RTRIM(LTRIM(@Lc_NcpEmployerCity_ADDR)) <> ''
             AND RTRIM(LTRIM(@Lc_NcpEmployerState_ADDR)) <> ''
             AND RTRIM(LTRIM(@Lc_NcpEmployerZip_ADDR)) <> ''
			 AND @Ln_ReferralsCurNcpMci_IDNO != @Ln_UnknownNcpMci_IDNO
           BEGIN
            -- OTHP ID Insert, Employer address insertion
            SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE, ADDING AP ON EXISTING CASE';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', OtherParty_NAME = ' + ISNULL(@Ls_NcpEmployer_NAME, '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', AddrNormalization_CODE = ' + ISNULL(@Lc_NcpEmpAddrNormalization_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_NcpEmployerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_NcpEmployerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_NcpEmployerCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_NcpEmployerState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_NcpEmployerZip_ADDR, '');

            EXECUTE BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE
             @An_MemberMci_IDNO         = @Ln_ReferralsCurNcpMci_IDNO,
             @Ad_Run_DATE               = @Ld_Run_DATE,
             @Ac_Job_ID                 = @Lc_Job_ID,
             @As_OtherParty_NAME        = @Ls_NcpEmployer_NAME,
             @An_Fein_IDNO              = @Ln_Zero_NUMB,
             @Ac_AddrNormalization_CODE = @Lc_NcpEmpAddrNormalization_CODE,
             @As_Line1_ADDR             = @Ls_NcpEmployerLine1_ADDR,
             @As_Line2_ADDR             = @Ls_NcpEmployerLine2_ADDR,
             @Ac_City_ADDR              = @Lc_NcpEmployerCity_ADDR,
             @Ac_State_ADDR             = @Lc_NcpEmployerState_ADDR,
             @Ac_Zip_ADDR               = @Lc_NcpEmployerZip_ADDR,
             @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

            IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
                 OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                     AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
             BEGIN
              SET @Lc_BateError_CODE = @Lc_Msg_CODE;

              RAISERROR (50001,16,1);
             END
            ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
             BEGIN
              EXECUTE BATCH_COMMON$SP_BATE_LOG
               @As_Process_NAME             = @Ls_Process_NAME,
               @As_Procedure_NAME           = @Ls_Procedure_NAME,
               @Ac_Job_ID                   = @Lc_Job_ID,
               @Ad_Run_DATE                 = @Ld_Run_DATE,
               @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
               @An_Line_NUMB                = @Ln_RestartLine_NUMB,
               @Ac_Error_CODE               = @Lc_Msg_CODE,
               @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
               @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
               @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END
             END
           END
         END

        --Update Program Type AND/OR Adds the Child ON THE CASE
        IF @Lb_ChangeChildsProgramType_BIT = 1
            OR @Lb_AddChildOnExistingIVDCase_BIT = 1
         BEGIN
          SET @Ls_Sql_TEXT = 'DELETE ##TempCaseReopenAddUpdateChild_P1';
          SET @Ls_Sqldata_TEXT = '';

          DELETE ##TempCaseReopenAddUpdateChild_P1;

          SET @Ls_Sql_TEXT = 'INSERT ##TempCaseReopenAddUpdateChild_P1';
          SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCur_Seq_IDNO AS VARCHAR), '');

          INSERT ##TempCaseReopenAddUpdateChild_P1
                 (Seq_IDNO,
                  Case_IDNO)
          SELECT DISTINCT
                 @Ln_ReferralsCur_Seq_IDNO AS Seq_IDNO,
                 Case_IDNO
            FROM @TempIVDCaseAndChildStatus_P1 t
           WHERE t.TypeAction_CODE IN(@Lc_TypeActionCP_CODE, @Lc_TypeActionAC_CODE);

          SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE FOR ADD CHILD/CHANGE PROGRAM TYPE';
          SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

          EXECUTE BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE
           @Ad_Run_DATE              = @Ld_Run_DATE,
           @Ac_Job_ID                = @Lc_Job_ID,
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            RAISERROR(50001,16,1);
           END
         END
       END

      --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
	  WRITECPDR:;

	  IF @Lb_WriteToCpdr_BIT = 1
	   BEGIN
	    INSERT ##TempSeqIdno_P1
		SELECT @Ln_ReferralsCur_Seq_IDNO;

		SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals';
        SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPending_CODE, '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
         @Ad_Run_DATE              = @Ld_Run_DATE,
         @Ac_Job_ID                = @Lc_Job_ID,
         @Ac_ReasonForPending_CODE = @Lc_ReasonForPending_CODE,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END
	   END
	  --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

	  --CHILD MPAT
      IF NOT EXISTS(SELECT 1
                      FROM MPAT_Y1 m
                     WHERE m.MemberMci_IDNO = @Ln_ReferralsCurChildMci_IDNO)
         AND (@Lb_ChangeChildsProgramType_BIT = 1
               OR @Lb_AddChildOnExistingIVDCase_BIT = 1
               OR @Ln_NewlyCreatedCase_IDNO != 0)
       BEGIN
        SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurChildMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

        EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT
         @An_MemberMci_IDNO           = @Ln_ReferralsCurChildMci_IDNO,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVEIVACASEREFERRALS_PROCESS;
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER ();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
      SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
      SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_ReferralsCur_Seq_IDNO AS VARCHAR);

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_RestartLine_NUMB,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LIVAD_Y1';
     SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCaseWelfare_IDNO AS VARCHAR), '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurCpMci_IDNO AS VARCHAR), '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCurNcpMci_IDNO AS VARCHAR), '') + ', AgSequence_NUMB = ' + ISNULL(@Lc_ReferralsCur_AgSequenceNumb_TEXT, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_ReferralsCur_FileLoad_DATE AS VARCHAR), '');

     UPDATE LIVAD_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE CaseWelfare_IDNO = @Ln_ReferralsCurCaseWelfare_IDNO
        AND CpMci_IDNO = @Ln_ReferralsCurCpMci_IDNO
        AND NcpMci_IDNO = @Ln_ReferralsCurNcpMci_IDNO
        AND AgSequence_NUMB = @Lc_ReferralsCur_AgSequenceNumb_TEXT
        AND FileLoad_DATE = @Ld_ReferralsCur_FileLoad_DATE;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_ErrorE0001_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_ReferralsCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE Seq_IDNO = @Ln_ReferralsCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_ErrorE0001_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Li_RowsCount_QNTY;

     -- If the commit frequency is attained, Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', RestartKey_TEXT = ' + ISNULL(CAST(@Ln_RecCount_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecCount_NUMB,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       --Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:
       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       COMMIT TRANSACTION IVACASEREFERRALS_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       BEGIN TRANSACTION IVACASEREFERRALS_PROCESS;

       --After Transaction is committed AND again began set the commit frequency to 0                        
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_RecCount_NUMB;

       COMMIT TRANSACTION IVACASEREFERRALS_PROCESS;

       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM Referrals_CUR INTO @Ln_ReferralsCur_Seq_IDNO, @Lc_ReferralsCur_CaseWelfareIdno_TEXT, @Lc_ReferralsCur_CpMciIdno_TEXT, @Lc_ReferralsCur_NcpMciIdno_TEXT, @Lc_ReferralsCur_AgSequenceNumb_TEXT, @Lc_ReferralsCur_StatusCase_CODE, @Lc_ReferralsCur_ChildMciIdno_TEXT, @Lc_ReferralsCur_Program_CODE, @Lc_ReferralsCur_SubProgram_CODE, @Lc_ReferralsCur_IntactFamilyStatus_CODE, @Lc_ReferralsCur_ChildEligDate_TEXT, @Lc_ReferralsCur_WelfareCaseCountyIdno_TEXT, @Lc_ReferralsCur_ChildFirst_NAME, @Lc_ReferralsCur_ChildMiddle_NAME, @Lc_ReferralsCur_ChildLast_NAME, @Lc_ReferralsCur_ChildSuffix_NAME, @Lc_ReferralsCur_ChildBirthDate_TEXT, @Lc_ReferralsCur_ChildSsnNumb_TEXT, @Lc_ReferralsCur_ChildSex_CODE, @Lc_ReferralsCur_ChildRace_CODE, @Lc_ReferralsCur_ChildPaternityStatus_CODE, @Lc_ReferralsCur_CpRelationshipToChild_CODE, @Lc_ReferralsCur_NcpRelationshipToChild_CODE, @Ld_ReferralsCur_FileLoad_DATE, @Lc_ReferralsCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateError_TEXT,
      @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE Referrals_CUR;

   DEALLOCATE Referrals_CUR;

   IF EXISTS (SELECT 1
                FROM @CreatedCaseAndCp_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR NOPRI';
     SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

     INSERT ##InsertActivity_P1
            (Case_IDNO,
             MemberMci_IDNO,
             ActivityMajor_CODE,
             ActivityMinor_CODE,
             Subsystem_CODE)
     SELECT DISTINCT
            Case_IDNO,
            MemberMci_IDNO AS MemberMci_IDNO,
            @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
            'NOPRI' AS ActivityMinor_CODE,
            @Lc_SubsystemCI_CODE AS Subsystem_CODE
       FROM @CreatedCaseAndCp_P1;
    END

   IF EXISTS (SELECT 1
                FROM ##InsertActivity_P1)
    BEGIN
     --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -START-
	 SET @Ls_Sql_TEXT = 'DELETE ##InsertActivity_P1 FOR NEWLY ADDED DEP ON NEWLY CREATED CASE';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');
	 DELETE t
	   FROM ##InsertActivity_P1 t
	  WHERE EXISTS (SELECT 1
	                  FROM @CreatedCaseAndCp_P1 x
					 WHERE x.Case_IDNO = t.Case_IDNO
					   AND t.ActivityMinor_CODE = @Lc_ActivityMinorCcrnd_CODE);
	 --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -END-

	 SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_ACTIVITY FOR NON SKIPPED RECORDS';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_ACTIVITY
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = 'NOPRI',
      @Ac_Subsystem_CODE           = @Lc_SubsystemCI_CODE,
      @An_TransactionEventSeq_NUMB = 0,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   -- Update the parameter table with the job run date as the current system date3
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Log the successful completion in the Batch Status Log (BSTL) screen/Batch Status Log (BSTL_Y1) table for future references	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   --DROP TEMP TABLES
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
   IF OBJECT_ID('tempdb..##TempSeqIdno_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##TempSeqIdno_P1;
    END
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

   IF OBJECT_ID('tempdb..##TempCaseReopenAddUpdateChild_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##TempCaseReopenAddUpdateChild_P1;
    END

   IF OBJECT_ID('tempdb..##InsertActivity_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##InsertActivity_P1;
    END;

   --Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:	
   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION IVACASEREFERRALS_PROCESS;
  END TRY

  BEGIN CATCH
   --ROLLBACK TRANSACTION SAVEREFERRALS_SKIP_PROCESS;
   IF @Lb_CommitSkipTransaction_BIT = 0
    BEGIN
     ROLLBACK TRANSACTION IVACASEREFERRALS_SKIP_PROCESS;
    END

   --Rollback Transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVACASEREFERRALS_PROCESS;
    END

   -- CURSOR_STATUS implementation:
   IF CURSOR_STATUS ('LOCAL', 'Referrals_CUR') IN (0, 1)
    BEGIN
     CLOSE Referrals_CUR;

     DEALLOCATE Referrals_CUR;
    END

   --DROP TEMP TABLES
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
   IF OBJECT_ID('tempdb..##TempSeqIdno_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##TempSeqIdno_P1;
    END
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

   IF OBJECT_ID('tempdb..##TempCaseReopenAddUpdateChild_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##TempCaseReopenAddUpdateChild_P1;
    END

   IF OBJECT_ID('tempdb..##InsertActivity_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##InsertActivity_P1;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   -- Update Status in Batch Log Table
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
