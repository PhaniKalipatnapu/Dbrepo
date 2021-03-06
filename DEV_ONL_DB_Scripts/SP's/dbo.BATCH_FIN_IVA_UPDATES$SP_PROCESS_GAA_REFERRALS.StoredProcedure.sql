/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_GAA_REFERRALS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_GAA_REFERRALS
Programmer Name	:	IMP Team.
Description		:	This process reads the data from LGADT_Y1 table and updates the NCP's MeansTested_INDC in DEMO as well updates the address.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
					BATCH_COMMON$SP_ADDRESS_UPDATE,
					BATCH_COMMON$SP_GET_ERROR_DESCRIPTION,
					BATCH_COMMON$SP_BATCH_RESTART_UPDATE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_GAA_REFERRALS]
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_FetchStatus_QNTY            SMALLINT = 0,
          @Li_RowsCount_QNTY              SMALLINT = 0,
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_TypeErrorE_CODE             CHAR(1) = 'E',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
          @Lc_IndNote_TEXT                CHAR(1) = 'N',
          @Lc_TypeErrorWarning_CODE       CHAR(1) = 'W',
          @Lc_TypeError_CODE              CHAR(1) = 'E',
          @Lc_ProcessY_INDC               CHAR(1) = 'Y',
          @Lc_ProcessN_INDC               CHAR(1) = 'N',
          @Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipA_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE      CHAR(1) = 'P',
          @Lc_MeansTestedIncY_INDC        CHAR(1) = 'Y',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_MailingTypeAddress_CODE     CHAR(1) = 'M',
          @Lc_VerificationStatusP_CODE    CHAR(1) = 'P',
          @Lc_MemberSourceLoc_CODE        CHAR(3) = 'IVA',
          @Lc_Msg_CODE                    CHAR(5) = ' ',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_ErrorE0085_CODE             CHAR(5) = 'E0085',
          @Lc_ErrorE0944_CODE             CHAR(5) = 'E0944',
          @Lc_ErrorE1089_CODE             CHAR(5) = 'E1089',
          @Lc_BateError_CODE              CHAR(5) = ' ',
          @Lc_Job_ID                      CHAR(7) = 'DEB9904',
          @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
          @Ls_Err0001_TEXT                VARCHAR(50) = 'UPDATE NOT SUCCESSFUL',
          @Ls_ErrorE0944_TEXT             VARCHAR(50) = 'NO RECORDS(S) TO PROCESS',
          @Ls_ErrorE0085_TEXT             VARCHAR(50) = 'INVALID VALUE',
          @Ls_ParmDateProblem_TEXT        VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_PROCESS_GAA_REFERRALS',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = ' ',
          @Ls_Sql_TEXT                    VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = ' ',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = ' ',
          @Ls_BateError_TEXT              VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT                VARCHAR(5000) = ' ',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Lb_DemoRollbackTran_BIT        BIT = 0;
  DECLARE @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(6) = 0,
          @Ln_RecCount_NUMB               NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  --Cursor Variable Naming:
  DECLARE @Ln_GadtCur_Seq_IDNO               NUMERIC(19),
          @Lc_GadtCur_MemberMciIdno_TEXT     CHAR(10),
          @Lc_GadtCur_AddrNormalization_CODE CHAR(1),
          @Ls_GadtCur_Line1_ADDR             VARCHAR(50),
          @Ls_GadtCur_Line2_ADDR             VARCHAR(50),
          @Lc_GadtCur_City_ADDR              CHAR(28),
          @Lc_GadtCur_State_ADDR             CHAR(2),
          @Lc_GadtCur_Zip_ADDR               CHAR(15),
          @Ld_GadtCur_FileLoad_DATE          DATE,
          @Lc_GadtCur_Process_INDC           CHAR(1);
  DECLARE @Ln_GadtCurMemberMci_IDNO NUMERIC(10);

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
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --CURSOR Declaration
   DECLARE GADT_CUR INSENSITIVE CURSOR FOR
    SELECT l.Seq_IDNO,
           l.MemberMci_IDNO,
           l.AddrNormalization_CODE,
           l.Line1_ADDR,
           l.Line2_ADDR,
           l.City_ADDR,
           l.State_ADDR,
           l.Zip_ADDR,
           l.FileLoad_DATE,
           l.Process_INDC
      FROM LGADT_Y1 l
     WHERE l.Process_INDC = @Lc_ProcessN_INDC;

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = '';

   BEGIN TRANSACTION GADT_PROCESS;

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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveRun_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '');

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   -- Cursor starts 		
   SET @Ls_Sql_TEXT = 'OPEN GADT_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN GADT_CUR;

   SET @Ls_Sql_TEXT = 'FETCH GADT_CUR';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM GADT_CUR INTO @Ln_GadtCur_Seq_IDNO, @Lc_GadtCur_MemberMciIdno_TEXT, @Lc_GadtCur_AddrNormalization_CODE, @Ls_GadtCur_Line1_ADDR, @Ls_GadtCur_Line2_ADDR, @Lc_GadtCur_City_ADDR, @Lc_GadtCur_State_ADDR, @Lc_GadtCur_Zip_ADDR, @Ld_GadtCur_FileLoad_DATE, @Lc_GadtCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --When no records are selected to process.
   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
     SET @Ls_BateError_TEXT = @Ls_ErrorE0944_TEXT;
    END;

   --Updates MeansTested_INDC in demo and address for the matched NCP.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVEGADT_PROCESS;

      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_GadtCur_Seq_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(@Lc_GadtCur_MemberMciIdno_TEXT, '') + ', AddrNormalization_CODE = ' + ISNULL(@Lc_GadtCur_AddrNormalization_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_GadtCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_GadtCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_GadtCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_GadtCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_GadtCur_Zip_ADDR, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_GadtCur_FileLoad_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_GadtCur_Process_INDC, '');
      SET @Lc_BateError_CODE = @Lc_Space_TEXT;
      SET @Ln_RecCount_NUMB = @Ln_RecCount_NUMB + 1;
      SET @Ls_CursorLocation_TEXT = 'IVA CASE REFERRALS PROCESS - CURSOR COUNT - ' + CAST(@Ln_RecCount_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      IF ISNUMERIC (@Lc_GadtCur_MemberMciIdno_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
        SET @Ls_BateError_TEXT = @Ls_ErrorE0085_TEXT;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_GadtCurMemberMci_IDNO = CAST(@Lc_GadtCur_MemberMciIdno_TEXT AS NUMERIC);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
      SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

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
        RAISERROR (50001,16,1);
       END

      IF EXISTS (SELECT 1
                   FROM CMEM_Y1 CM,
                        CASE_Y1 CA
                  WHERE CA.Case_IDNO = CM.Case_IDNO
                    AND CA.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                    AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                    AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                    AND CM.MemberMci_IDNO = @Ln_GadtCurMemberMci_IDNO
                    AND EXISTS (SELECT 1
                                  FROM DEMO_Y1
                                 WHERE MemberMci_IDNO = @Ln_GadtCurMemberMci_IDNO
                                   AND MeansTestedInc_INDC <> @Lc_MeansTestedIncY_INDC))
       BEGIN
        SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_GadtCurMemberMci_IDNO AS VARCHAR), '');

        UPDATE DEMO_Y1
           SET MeansTestedInc_INDC = @Lc_MeansTestedIncY_INDC,
               TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
               WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
               BeginValidity_DATE = @Ld_Run_DATE,
               Update_DTTM = @Ld_Start_DATE
        OUTPUT Deleted.MemberMci_IDNO,
               Deleted.Individual_IDNO,
               Deleted.Last_NAME,
               Deleted.First_NAME,
               Deleted.Middle_NAME,
               Deleted.Suffix_NAME,
               Deleted.Title_NAME,
               Deleted.FullDisplay_NAME,
               Deleted.MemberSex_CODE,
               Deleted.MemberSsn_NUMB,
               Deleted.Birth_DATE,
               Deleted.Emancipation_DATE,
               Deleted.LastMarriage_DATE,
               Deleted.LastDivorce_DATE,
               Deleted.BirthCity_NAME,
               Deleted.BirthState_CODE,
               Deleted.BirthCountry_CODE,
               Deleted.DescriptionHeight_TEXT,
               Deleted.DescriptionWeightLbs_TEXT,
               Deleted.Race_CODE,
               Deleted.ColorHair_CODE,
               Deleted.ColorEyes_CODE,
               Deleted.FacialHair_INDC,
               Deleted.Language_CODE,
               Deleted.TypeProblem_CODE,
               Deleted.Deceased_DATE,
               Deleted.CerDeathNo_TEXT,
               Deleted.LicenseDriverNo_TEXT,
               Deleted.AlienRegistn_ID,
               Deleted.WorkPermitNo_TEXT,
               Deleted.BeginPermit_DATE,
               Deleted.EndPermit_DATE,
               Deleted.HomePhone_NUMB,
               Deleted.WorkPhone_NUMB,
               Deleted.CellPhone_NUMB,
               Deleted.Fax_NUMB,
               Deleted.Contact_EML,
               Deleted.Spouse_NAME,
               Deleted.Graduation_DATE,
               Deleted.EducationLevel_CODE,
               Deleted.Restricted_INDC,
               Deleted.Military_ID,
               Deleted.MilitaryBranch_CODE,
               Deleted.MilitaryStatus_CODE,
               Deleted.MilitaryBenefitStatus_CODE,
               Deleted.SecondFamily_INDC,
               Deleted.MeansTestedInc_INDC,
               Deleted.SsIncome_INDC,
               Deleted.VeteranComps_INDC,
               Deleted.Disable_INDC,
               Deleted.Assistance_CODE,
               Deleted.DescriptionIdentifyingMarks_TEXT,
               Deleted.Divorce_INDC,
               Deleted.BeginValidity_DATE,
               @Ld_Run_DATE AS EndValidity_DATE,
               Deleted.WorkerUpdate_ID,
               Deleted.TransactionEventSeq_NUMB,
               Deleted.Update_DTTM,
               Deleted.TypeOccupation_CODE,
               Deleted.CountyBirth_IDNO,
               Deleted.MotherMaiden_NAME,
               Deleted.FileLastDivorce_ID,
               Deleted.TribalAffiliations_CODE,
               Deleted.FormerMci_IDNO,
               Deleted.StateDivorce_CODE,
               Deleted.CityDivorce_NAME,
               Deleted.StateMarriage_CODE,
               Deleted.CityMarriage_NAME,
               Deleted.IveParty_IDNO
        INTO HDEMO_Y1
         WHERE MemberMci_IDNO = @Ln_GadtCurMemberMci_IDNO;

        SET @Li_RowsCount_QNTY = @@ROWCOUNT;

        IF @Li_RowsCount_QNTY = 0
         BEGIN
          SET @Lb_DemoRollbackTran_BIT = 1;
          SET @Ls_DescriptionError_TEXT = 'UPDATE DEMO_Y1 FAILED';

          RAISERROR (50001,16,1);
         END
       END

      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 3';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVEGADT_PROCESS2;

      --MEMBER AHIS UPDATE
      IF RTRIM(LTRIM(@Ls_GadtCur_Line1_ADDR)) <> ''
         AND RTRIM(LTRIM(@Lc_GadtCur_City_ADDR)) <> ''
         AND RTRIM(LTRIM(@Lc_GadtCur_State_ADDR)) <> ''
         AND RTRIM(LTRIM(@Lc_GadtCur_Zip_ADDR)) <> ''
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_GadtCurMemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Line1_ADDR = ' + ISNULL(@Ls_GadtCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_GadtCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_GadtCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_GadtCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_GadtCur_Zip_ADDR, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_MemberSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusP_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_GadtCur_AddrNormalization_CODE, '');

        EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
         @An_MemberMci_IDNO                   = @Ln_GadtCurMemberMci_IDNO,
         @Ad_Run_DATE                         = @Ld_Run_DATE,
         @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
         @Ad_Begin_DATE                       = @Ld_Run_DATE,
         @Ad_End_DATE                         = @Ld_High_DATE,
         @As_Line1_ADDR                       = @Ls_GadtCur_Line1_ADDR,
         @As_Line2_ADDR                       = @Ls_GadtCur_Line2_ADDR,
         @Ac_City_ADDR                        = @Lc_GadtCur_City_ADDR,
         @Ac_State_ADDR                       = @Lc_GadtCur_State_ADDR,
         @Ac_Zip_ADDR                         = @Lc_GadtCur_Zip_ADDR,
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
         @Ac_Normalization_CODE               = @Lc_GadtCur_AddrNormalization_CODE,
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
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
         AND @Lb_DemoRollbackTran_BIT = 0
       BEGIN
        ROLLBACK TRANSACTION SAVEGADT_PROCESS2;
       END
      ELSE IF XACT_STATE() = 1
         AND @Lb_DemoRollbackTran_BIT = 1
       BEGIN
        ROLLBACK TRANSACTION SAVEGADT_PROCESS;

        SET @Lb_DemoRollbackTran_BIT = 0;
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

      IF @Lc_BateError_CODE = @Lc_ErrorE0085_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorE0085_TEXT;
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
      SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_GadtCur_Seq_IDNO AS VARCHAR);

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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

      IF @Lc_Msg_CODE = @Lc_TypeError_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     -- Update the Process_INDC in the Load table with 'Y'.
     SET @Ls_Sql_TEXT = 'UPDATE LGADT_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_GadtCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LGADT_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_GadtCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Ls_Err0001_TEXT;

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

       --	Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:
       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       COMMIT TRANSACTION GADT_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       BEGIN TRANSACTION GADT_PROCESS;

       --After Transaction is committed AND again began set the commit frequency to 0                        
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_RecCount_NUMB;

       COMMIT TRANSACTION GADT_PROCESS;

       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM GADT_CUR INTO @Ln_GadtCur_Seq_IDNO, @Lc_GadtCur_MemberMciIdno_TEXT, @Lc_GadtCur_AddrNormalization_CODE, @Ls_GadtCur_Line1_ADDR, @Ls_GadtCur_Line2_ADDR, @Lc_GadtCur_City_ADDR, @Lc_GadtCur_State_ADDR, @Lc_GadtCur_Zip_ADDR, @Ld_GadtCur_FileLoad_DATE, @Lc_GadtCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Ls_BateError_TEXT;
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE GADT_CUR;

   DEALLOCATE GADT_CUR;

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
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --	Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:	
   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION GADT_PROCESS;
  END TRY

  BEGIN CATCH
   -- Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:			                              
   -- Close Transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION GADT_PROCESS;
    END

   -- CURSOR_STATUS implementation:
   IF CURSOR_STATUS ('LOCAL', 'GADT_CUR') IN (0, 1)
    BEGIN
     CLOSE GADT_CUR;

     DEALLOCATE GADT_CUR;
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
