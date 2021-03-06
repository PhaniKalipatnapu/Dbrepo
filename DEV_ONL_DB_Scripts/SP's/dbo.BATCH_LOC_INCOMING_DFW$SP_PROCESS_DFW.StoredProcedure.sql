/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DFW$SP_PROCESS_DFW]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_DFW$SP_PROCESS_DFW
Programmer Name   :	IMP Team
Description       :	Populates the system Address History (AHIS_Y1) and Member Licenses (PLIC_Y1)tables for matched MEMBERs,
					and records a case journal entry.
Frequency         :	Weekly.
Developed On      :	09/27/2011
Called BY         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_INSERT_ACTIVITY,
					BATCH_COMMON$SP_ADDRESS_UPDATE,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        : 0.04
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DFW$SP_PROCESS_DFW]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_OtherParty999999971_IDNO    NUMERIC(9) = 999999971,
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
          @Lc_MailingTypeAddress_CODE     CHAR(1) = 'M',
          @Lc_PendingStatus_CODE          CHAR(1) = 'P',
          @Lc_IndNote_TEXT                CHAR(1) = 'N',
          @Lc_TypeError_CODE              CHAR(1) = 'E',
          @Lc_TypeErrorWarning_CODE       CHAR(1) = 'W',
          @Lc_ProcessY_INDC               CHAR(1) = 'Y',
          @Lc_ProcessN_INDC               CHAR(1) = 'N',
          @Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
          @Lc_StatusCaseClose_CODE        CHAR(1) = 'C',
          @Lc_TypeCaseNivd_CODE           CHAR(1) = 'H',
          @Lc_CaseRelationshipNcp_CODE    CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE     CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_ActiveCaseMemberStatus_CODE CHAR(1) = 'A',
          @Lc_LicenseStatusA_CODE         CHAR(1) = 'A',
          @Lc_LicenseStatusI_CODE         CHAR(1) = 'I',
          @Lc_Country_ADDR                CHAR(2) = 'US',
          @Lc_RsnStatusCaseUc_CODE        CHAR(2) = 'UC',
          @Lc_RsnStatusCaseUb_CODE        CHAR(2) = 'UB',
          @Lc_SourceVerified_CODE         CHAR(3) = 'A',
          @Lc_Subsystem_CODE              CHAR(3) = 'LO',
          @Lc_SourceVerifiedDfw_CODE      CHAR(3) = 'DFW',
          @Lc_ActivityMajor_CODE          CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO          CHAR(4) = ' ',
          @Lc_TypeLicenseHun_CODE         CHAR(5) = 'HUN',
          @Lc_TypeLicenseFis_CODE         CHAR(5) = 'FIS',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_ErrorE1405_CODE             CHAR(5) = 'E1405',
          @Lc_ErrorE0085_CODE             CHAR(5) = 'E0085',
          @Lc_ErrorE0944_CODE             CHAR(5) = 'E0944',
          @Lc_ErrorE0145_CODE             CHAR(5) = 'E0145',
          @Lc_ErrorE1089_CODE             CHAR(5) = 'E1089',
          @Lc_ActivityMinorRnewl_CODE     CHAR(5) = 'RNEWL',
          @Lc_LicenseStatusActive_TEXT    CHAR(6) = 'ACTIVE',
          @Lc_Job_ID                      CHAR(7) = 'DEB8092',
          @Lc_Process_ID                  CHAR(10) = 'BATCH',
          @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT                CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Lc_WorkerDelegate_ID           CHAR(30) = ' ',
          @Lc_Reference_ID                CHAR(30) = ' ',
          @Lc_ErrorE0944_TEXT             CHAR(35) = 'NO RECORDS(S) TO PROCESS',
          @Lc_Attn_ADDR                   CHAR(40) = ' ',
          @Ls_ParmDateProblem_TEXT        VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_ErrorE0085_TEXT             VARCHAR(50) = 'INVALID VALUE',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_LOC_INCOMING_DFW',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_PROCESS_DFW',
          @Ls_DescriptionComments_TEXT    VARCHAR(1000) = ' ',
          @Ls_XmlTextIn_TEXT              VARCHAR(8000) = ' ',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE @Ln_TopicIn_IDNO                     NUMERIC = 0,
          @Ln_Office_IDNO                      NUMERIC(3) = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5) = 0,
          @Ln_Zero_NUMB                        NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                 NUMERIC(5) = 0,
          @Ln_MajorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY      NUMERIC(6) = 0,
          @Ln_OthpSource_IDNO                  NUMERIC(9) = 0,
          @Ln_OthpLocation_IDNO                NUMERIC(9) = 0,
          @Ln_Schedule_NUMB                    NUMERIC(10) = 0,
          @Ln_MemberMci_IDNO                   NUMERIC(10)= 0,
          @Ln_RecordCount_QNTY                 NUMERIC(10) = 0,
          @Ln_Topic_IDNO                       NUMERIC(10) = 0,
          @Ln_Error_NUMB                       NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB                   NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB         NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Li_RowsCount_QNTY                   SMALLINT,
          @Lc_LicenseStatus_CODE               CHAR(1),
          @Lc_Space_TEXT                       CHAR(1) = '',
          @Lc_OthStateFips_CODE                CHAR(2) = '',
          @Lc_ReasonStatus_CODE                CHAR(2) = '',
          @Lc_Msg_CODE                         CHAR(5) = '',
          @Lc_BateError_CODE                   CHAR(5),
          @Lc_Notice_ID                        CHAR(8) = '',
          @Lc_Schedule_Member_IDNO             CHAR(10) = '',
          @Lc_Schedule_Worker_IDNO             CHAR(30) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200) = '',
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = '',
          @Ls_Sql_TEXT                         VARCHAR(2000) = '',
          @Ls_DescriptionError_TEXT            VARCHAR(4000),
          @Ls_BateRecord_TEXT                  VARCHAR(4000),
          @Ls_Sqldata_TEXT                     VARCHAR(5000) = '',
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2,
          @Ld_BeginSch_DTTM                    DATETIME2,
          @Lb_CaseJournalEntryHunting_CODE     BIT = 0,
          @Lb_CaseJournalEntryFishing_CODE     BIT = 0;
  --Cursor Variable Naming:  
  DECLARE @Ln_DfwCur_Seq_IDNO                      NUMERIC,
          @Lc_DfwCur_Rec_ID                        CHAR(1),
          @Lc_DfwCur_Last_NAME                     CHAR(20),
          @Lc_DfwCur_First_NAME                    CHAR(20),
          @Lc_DfwCur_Middle_NAME                   CHAR(1),
          @Lc_DfwCur_MemberSsnNumb_TEXT            CHAR(9),
          @Lc_DfwCur_BirthDate_TEXT                CHAR(8),
          @Lc_DfwCur_HuntingLicenseNo_TEXT         CHAR(20),
          @Lc_DfwCur_HuntingLicenseStatus_CODE     CHAR(10),
          @Lc_DfwCur_HuntingIssueLicenseDate_TEXT  CHAR(8),
          @Lc_DfwCur_HuntingExpireLicenseDate_TEXT CHAR(8),
          @Lc_DfwCur_FishingLicenseNo_TEXT         CHAR(20),
          @Lc_DfwCur_FishingLicenseStatus_CODE     CHAR(10),
          @Lc_DfwCur_FishingIssueLicenseDate_TEXT  CHAR(8),
          @Lc_DfwCur_FishingExpireLicenseDate_TEXT CHAR(8),
          @Lc_DfwCur_AddressNormalization_CODE     CHAR(1),
          @Ls_DfwCurLine1_ADDR                     VARCHAR(50),
          @Ls_DfwCurLine2_ADDR                     VARCHAR(50),
          @Lc_DfwCur_City_ADDR                     CHAR(28),
          @Lc_DfwCur_State_ADDR                    CHAR(2),
          @Lc_DfwCur_Zip_ADDR                      CHAR(15),
          @Ld_DfwCur_FileLoad_DATE                 DATE,
          @Lc_DfwCur_Process_INDC                  CHAR(1),
          @Lc_CaseMemberCur_Case_IDNO              CHAR(6),
          @Ln_CaseMemberCur_MemberMci_IDNO         NUMERIC(10);
  --Cursor Variable Naming:
  DECLARE @Ln_DfwCurMemberSsn_NUMB            NUMERIC(9),
          @Ld_DfwCurHuntingIssueLicense_DATE  DATE,
          @Ld_DfwCurHuntingExpireLicense_DATE DATE,
          @Ld_DfwCurFishingIssueLicense_DATE  DATE,
          @Ld_DfwCurFishingExpireLicense_DATE DATE;

  BEGIN TRY
   BEGIN TRANSACTION DFW_PROCESS

   -- The Batch start time to use while inserting in to the batch log
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
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

   --CURSOR Declaration
   DECLARE Dfw_CUR INSENSITIVE CURSOR FOR
    SELECT a.Seq_IDNO,
           a.Rec_ID,
           a.Last_NAME,
           a.First_NAME,
           a.Middle_NAME,
           a.MemberSsn_NUMB,
           a.Birth_DATE,
           a.HuntingLicenseNo_TEXT,
           a.HuntingLicenseStatus_CODE,
           a.HuntingIssueLicense_DATE,
           a.HuntingExpireLicense_DATE,
           a.FishingLicenseNo_TEXT,
           a.FishingLicenseStatus_CODE,
           a.FishingIssueLicense_DATE,
           a.FishingExpireLicense_DATE,
           a.AddressNormalization_CODE,
           a.Line1_ADDR,
           a.Line2_ADDR,
           a.City_ADDR,
           a.State_ADDR,
           a.Zip_ADDR,
           a.FileLoad_DATE,
           a.Process_INDC
      FROM LDFWL_Y1 a
     WHERE a.Process_INDC = @Lc_ProcessN_INDC
       AND a.MemberSsn_NUMB != 0
       AND EXISTS (SELECT 1
                     FROM DEMO_Y1 d
                    WHERE ISNUMERIC(a.MemberSsn_NUMB) = 1
                      AND d.MemberSsn_NUMB = a.MemberSsn_NUMB
                      AND SUBSTRING (d.Last_NAME, 1, 5) = SUBSTRING (a.Last_NAME, 1, 5)
                      AND EXISTS (SELECT 1 
									FROM CMEM_Y1 c 
								   WHERE c.MemberMci_IDNO = d.MemberMci_IDNO
								     AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE, @Lc_CaseRelationshipCp_CODE)
									 AND c.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE));

   -- Check if restart key exists in Restart table.
   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 r
    WHERE Job_ID = @Lc_Job_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   -- Check if restart key exists in Restart table.
   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Line Number = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   -- Cursor starts 		
   SET @Ls_Sql_TEXT = 'OPEN Dfw_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   OPEN Dfw_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Dfw_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   FETCH NEXT FROM Dfw_CUR INTO @Ln_DfwCur_Seq_IDNO, @Lc_DfwCur_Rec_ID, @Lc_DfwCur_Last_NAME, @Lc_DfwCur_First_NAME, @Lc_DfwCur_Middle_NAME, @Lc_DfwCur_MemberSsnNumb_TEXT, @Lc_DfwCur_BirthDate_TEXT, @Lc_DfwCur_HuntingLicenseNo_TEXT, @Lc_DfwCur_HuntingLicenseStatus_CODE, @Lc_DfwCur_HuntingIssueLicenseDate_TEXT, @Lc_DfwCur_HuntingExpireLicenseDate_TEXT, @Lc_DfwCur_FishingLicenseNo_TEXT, @Lc_DfwCur_FishingLicenseStatus_CODE, @Lc_DfwCur_FishingIssueLicenseDate_TEXT, @Lc_DfwCur_FishingExpireLicenseDate_TEXT, @Lc_DfwCur_AddressNormalization_CODE, @Ls_DfwCurLine1_ADDR, @Ls_DfwCurLine2_ADDR, @Lc_DfwCur_City_ADDR, @Lc_DfwCur_State_ADDR, @Lc_DfwCur_Zip_ADDR, @Ld_DfwCur_FileLoad_DATE, @Lc_DfwCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --When no records are selected.
   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORDS(S) TO PROCESS';
    END;

   -- Fetches each record.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

      SAVE TRANSACTION SAVEDFW_PROCESS;

      SET @Lc_BateError_CODE = @Lc_Space_TEXT;
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_DfwCur_Seq_IDNO AS VARCHAR), '') + ', Rec_ID = ' + ISNULL(@Lc_DfwCur_Rec_ID, '') + ', Last_NAME = ' + ISNULL(@Lc_DfwCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_DfwCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_DfwCur_Middle_NAME, '') + ', MemberSsnNumb_TEXT = ' + ISNULL(@Lc_DfwCur_MemberSsnNumb_TEXT, '') + ', BirthDate_TEXT = ' + ISNULL(@Lc_DfwCur_BirthDate_TEXT, '') + ', HuntingLicenseNo_TEXT = ' + ISNULL(@Lc_DfwCur_HuntingLicenseNo_TEXT, '') + ', HuntingLicenseStatus_CODE = ' + ISNULL(@Lc_DfwCur_HuntingLicenseStatus_CODE, '') + ', HuntingIssueLicenseDate_TEXT = ' + ISNULL(@Lc_DfwCur_HuntingIssueLicenseDate_TEXT, '') + ', HuntingExpireLicenseDate_TEXT = ' + ISNULL(@Lc_DfwCur_HuntingExpireLicenseDate_TEXT, '') + ', FishingLicenseNo_TEXT = ' + ISNULL(@Lc_DfwCur_FishingLicenseNo_TEXT, '') + ', FishingLicenseStatus_CODE = ' + ISNULL(@Lc_DfwCur_FishingLicenseStatus_CODE, '') + ', FishingIssueLicenseDate_TEXT = ' + ISNULL(@Lc_DfwCur_FishingIssueLicenseDate_TEXT, '') + ', FishingExpireLicenseDate_TEXT = ' + ISNULL(@Lc_DfwCur_FishingExpireLicenseDate_TEXT, '') + ', AddressNormalization_CODE = ' + ISNULL(@Lc_DfwCur_AddressNormalization_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DfwCurLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DfwCurLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DfwCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DfwCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DfwCur_Zip_ADDR, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_DfwCur_FileLoad_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_DfwCur_Process_INDC, '');
      SET @Ln_MemberMci_IDNO = 0;
      SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;
      SET @Lb_CaseJournalEntryFishing_CODE = 0;
      SET @Lb_CaseJournalEntryHunting_CODE = 0;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'DFW - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ',  MemberSsnNumb_TEXT = ' + ISNULL(@Lc_DfwCur_MemberSsnNumb_TEXT, '');
      SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusI_CODE;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_DfwCur_MemberSsnNumb_TEXT))) = 0
          OR (LTRIM(RTRIM(@Lc_DfwCur_HuntingLicenseNo_TEXT)) <> @Lc_Space_TEXT
              AND (ISDATE(@Lc_DfwCur_HuntingIssueLicenseDate_TEXT) = 0
                    OR ISDATE(@Lc_DfwCur_HuntingExpireLicenseDate_TEXT) = 0))
          OR (LTRIM(RTRIM(@Lc_DfwCur_FishingLicenseNo_TEXT)) <> @Lc_Space_TEXT
              AND (ISDATE(@Lc_DfwCur_FishingIssueLicenseDate_TEXT) = 0
                    OR ISDATE(@Lc_DfwCur_FishingExpireLicenseDate_TEXT) = 0))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
        SET @Ls_DescriptionError_TEXT = @Ls_ErrorE0085_TEXT;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_DfwCurMemberSsn_NUMB = CAST(@Lc_DfwCur_MemberSsnNumb_TEXT AS NUMERIC);
        SET @Ld_DfwCurHuntingIssueLicense_DATE = CAST(@Lc_DfwCur_HuntingIssueLicenseDate_TEXT AS DATE);
        SET @Ld_DfwCurHuntingExpireLicense_DATE = CAST(@Lc_DfwCur_HuntingExpireLicenseDate_TEXT AS DATE);
        SET @Ld_DfwCurFishingIssueLicense_DATE = CAST(@Lc_DfwCur_FishingIssueLicenseDate_TEXT AS DATE);
        SET @Ld_DfwCurFishingExpireLicense_DATE = CAST(@Lc_DfwCur_FishingExpireLicenseDate_TEXT AS DATE);
       END

      IF ((SELECT COUNT(1)
             FROM DEMO_Y1
            WHERE MemberSsn_NUMB = @Ln_DfwCurMemberSsn_NUMB) > 1)
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;
        SET @Ls_DescriptionError_TEXT = @Ls_Sqldata_TEXT + '. DUPLICATE RECORD EXISTS IN DEMO_Y1 FOR THE SSN.';

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ls_Sql_TEXT = 'MEMBER SSN AND NAME EXISTANCE IN DEMO_Y1';
        SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_DfwCurMemberSsn_NUMB AS VARCHAR), '');

        SELECT @Ln_MemberMci_IDNO = ISNULL(d.MemberMci_IDNO, 0)
          FROM DEMO_Y1 d
         WHERE d.MemberSsn_NUMB = @Ln_DfwCurMemberSsn_NUMB
           AND SUBSTRING (d.Last_NAME, 1, 5) = SUBSTRING (@Lc_DfwCur_Last_NAME, 1, 5);
       END;

      IF @Ln_MemberMci_IDNO != 0
       BEGIN
        IF NOT EXISTS(SELECT 1
                        FROM CASE_Y1 C
                             INNER JOIN CMEM_Y1 M
                              ON C.Case_IDNO = M.Case_IDNO
                       WHERE C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                         AND C.TypeCase_CODE <> @Lc_TypeCaseNivd_CODE
                         AND M.MemberMci_IDNO = @Ln_MemberMci_IDNO
                         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE, @Lc_CaseRelationshipCp_CODE))
           AND NOT EXISTS(SELECT 1
                            FROM CASE_Y1 C
                                 INNER JOIN CMEM_Y1 M
                                  ON C.CASE_IDNO = M.CASE_IDNO
                           WHERE C.StatusCase_CODE = @Lc_StatusCaseClose_CODE
                             AND C.TypeCase_CODE <> @Lc_TypeCaseNivd_CODE
                             AND C.RsnStatusCase_CODE IN (@Lc_RsnStatusCaseUc_CODE, @Lc_RsnStatusCaseUb_CODE)
                             AND M.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
                             AND M.MemberMci_IDNO = @Ln_MemberMci_IDNO)
         BEGIN
          SET @Ls_Sql_TEXT = 'CHECK VALID CASE FOUND TO LOAD DATA';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '');
          SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;
          SET @Ls_DescriptionError_TEXT = @Ls_Sqldata_TEXT + '. DATA REJECTED, NO VALID CASE FOUND TO LOAD DATA';

          RAISERROR (50001,16,1);
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
          SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_IndNote_TEXT,
           @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE -1';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_DfwCur_FileLoad_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DfwCurLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DfwCurLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DfwCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DfwCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DfwCur_Zip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceVerifiedDfw_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_DfwCur_FileLoad_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_PendingStatus_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerified_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_DfwCur_AddressNormalization_CODE, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
           @Ad_Begin_DATE                       = @Ld_DfwCur_FileLoad_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
           @As_Line1_ADDR                       = @Ls_DfwCurLine1_ADDR,
           @As_Line2_ADDR                       = @Ls_DfwCurLine2_ADDR,
           @Ac_City_ADDR                        = @Lc_DfwCur_City_ADDR,
           @Ac_State_ADDR                       = @Lc_DfwCur_State_ADDR,
           @Ac_Zip_ADDR                         = @Lc_DfwCur_Zip_ADDR,
           @Ac_Country_ADDR                     = @Lc_Country_ADDR,
           @An_Phone_NUMB                       = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_SourceVerifiedDfw_CODE,
           @Ad_SourceReceived_DATE              = @Ld_DfwCur_FileLoad_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_PendingStatus_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerified_CODE,
           @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
           @Ac_Process_ID                       = @Lc_Process_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
           @Ac_Normalization_CODE               = @Lc_DfwCur_AddressNormalization_CODE,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

		  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		   BEGIN
			  RAISERROR (50001,16,1);
		   END;
          ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

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
             END;
           END;

          IF (LTRIM(RTRIM(@Lc_DfwCur_HuntingLicenseNo_TEXT)) <> @Lc_Space_TEXT)
           BEGIN
            IF LTRIM(RTRIM(@Lc_DfwCur_HuntingLicenseStatus_CODE)) = @Lc_LicenseStatusActive_TEXT
             BEGIN
              SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusA_CODE;
             END
            ELSE
             BEGIN
              SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusI_CODE;
             END

            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_LICENSE_UPDATE - HUNTING LICENSE';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_DfwCur_HuntingLicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenseHun_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', LicenseStatus_CODE = ' + ISNULL(@Lc_DfwCur_HuntingLicenseStatus_CODE, '') + ', IssuingState_CODE = ' + ISNULL(@Lc_DfwCur_State_ADDR, '') + ', IssueLicense_DATE = ' + ISNULL(CAST(@Ld_DfwCurHuntingIssueLicense_DATE AS VARCHAR), '') + ', ExpireLicense_DATE = ' + ISNULL(CAST(@Ld_DfwCurHuntingExpireLicense_DATE AS VARCHAR), '') + ', SuspLicense_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty999999971_IDNO AS VARCHAR), '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedDfw_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

            EXECUTE BATCH_COMMON$SP_LICENSE_UPDATE
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ac_LicenseNo_TEXT           = @Lc_DfwCur_HuntingLicenseNo_TEXT,
             @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
             @Ac_TypeLicense_CODE         = @Lc_TypeLicenseHun_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_LicenseStatus_CODE       = @Lc_LicenseStatus_CODE,
             @Ac_IssuingState_CODE        = @Lc_DfwCur_State_ADDR,
             @Ad_IssueLicense_DATE        = @Ld_DfwCurHuntingIssueLicense_DATE,
             @Ad_ExpireLicense_DATE       = @Ld_DfwCurHuntingExpireLicense_DATE,
             @Ad_SuspLicense_DATE         = @Ld_Low_DATE,
             @An_OtherParty_IDNO          = @Ln_OtherParty999999971_IDNO,
             @Ac_SourceVerified_CODE      = @Lc_SourceVerifiedDfw_CODE,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_Process_ID               = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
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
               END;
             END;
            ELSE
             BEGIN
              SET @Lb_CaseJournalEntryHunting_CODE = 1;
             END;
           END;

          IF LTRIM(RTRIM(@Lc_DfwCur_FishingLicenseNo_TEXT)) <> @Lc_Space_TEXT
           BEGIN
            IF LTRIM(RTRIM(@Lc_DfwCur_FishingLicenseStatus_CODE)) = @Lc_LicenseStatusActive_TEXT
             BEGIN
              SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusA_CODE;
             END
            ELSE
             BEGIN
              SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusI_CODE;
             END

            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_LICENSE_UPDATE - FISHING LICENSE';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_DfwCur_FishingLicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenseFis_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', LicenseStatus_CODE = ' + ISNULL(@Lc_DfwCur_FishingLicenseStatus_CODE, '') + ', IssuingState_CODE = ' + ISNULL(@Lc_DfwCur_State_ADDR, '') + ', IssueLicense_DATE = ' + ISNULL(CAST(@Ld_DfwCurFishingIssueLicense_DATE AS VARCHAR), '') + ', ExpireLicense_DATE = ' + ISNULL(CAST(@Ld_DfwCurFishingExpireLicense_DATE AS VARCHAR), '') + ', SuspLicense_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty999999971_IDNO AS VARCHAR), '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedDfw_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');
 
            EXECUTE BATCH_COMMON$SP_LICENSE_UPDATE
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ac_LicenseNo_TEXT           = @Lc_DfwCur_FishingLicenseNo_TEXT,
             @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
             @Ac_TypeLicense_CODE         = @Lc_TypeLicenseFis_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_LicenseStatus_CODE       = @Lc_LicenseStatus_CODE,
             @Ac_IssuingState_CODE        = @Lc_DfwCur_State_ADDR,
             @Ad_IssueLicense_DATE        = @Ld_DfwCurFishingIssueLicense_DATE,
             @Ad_ExpireLicense_DATE       = @Ld_DfwCurFishingExpireLicense_DATE,
             @Ad_SuspLicense_DATE         = @Ld_Low_DATE,
             @An_OtherParty_IDNO          = @Ln_OtherParty999999971_IDNO,
             @Ac_SourceVerified_CODE      = @Lc_SourceVerifiedDfw_CODE,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_Process_ID               = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
 
            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
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
               END;
             END;
            ELSE
             BEGIN
              SET @Lb_CaseJournalEntryFishing_CODE = 1;
             END;
           END;
         END
       END
     END TRY

     BEGIN CATCH
      BEGIN
       -- Rollback Transaction if any opened.
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEDFW_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       -- CURSOR_STATUS implementation:
       IF CURSOR_STATUS ('LOCAL', 'CaseMember_Cur') IN (0, 1)
        BEGIN
         CLOSE CaseMember_Cur;

         DEALLOCATE CaseMember_Cur;
        END

       SET @Ln_Error_NUMB = ERROR_NUMBER ();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

       IF @Ln_Error_NUMB <> 50001
        BEGIN
         SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
        END

       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
        @As_Procedure_NAME        = @Ls_Procedure_NAME,
        @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
        @As_Sql_TEXT              = @Ls_Sql_TEXT,
        @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
        @An_Error_NUMB            = @Ln_Error_NUMB,
        @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_DfwCur_Seq_IDNO AS VARCHAR);

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_BateError_CODE,
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
      END
     END CATCH

     --Update the Process_INDC in the Load table with 'Y'.
     SET @Ls_Sql_TEXT = 'UPDATE LDFWL_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_DfwCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LDFWL_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_DfwCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Li_RowsCount_QNTY;

     --If the commit frequency is attained, Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', RestartKey_TEXT = ' + ISNULL(CAST(@Ln_RecordCount_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       COMMIT TRANSACTION DFW_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;

       BEGIN TRANSACTION DFW_PROCESS;

       --After Transaction is committed and again began set the commit frequency to 0                        
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_RecordCount_QNTY;

       COMMIT TRANSACTION DFW_PROCESS;

       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT RECORD FROM CURSOR';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Dfw_CUR INTO @Ln_DfwCur_Seq_IDNO, @Lc_DfwCur_Rec_ID, @Lc_DfwCur_Last_NAME, @Lc_DfwCur_First_NAME, @Lc_DfwCur_Middle_NAME, @Lc_DfwCur_MemberSsnNumb_TEXT, @Lc_DfwCur_BirthDate_TEXT, @Lc_DfwCur_HuntingLicenseNo_TEXT, @Lc_DfwCur_HuntingLicenseStatus_CODE, @Lc_DfwCur_HuntingIssueLicenseDate_TEXT, @Lc_DfwCur_HuntingExpireLicenseDate_TEXT, @Lc_DfwCur_FishingLicenseNo_TEXT, @Lc_DfwCur_FishingLicenseStatus_CODE, @Lc_DfwCur_FishingIssueLicenseDate_TEXT, @Lc_DfwCur_FishingExpireLicenseDate_TEXT, @Lc_DfwCur_AddressNormalization_CODE, @Ls_DfwCurLine1_ADDR, @Ls_DfwCurLine2_ADDR, @Lc_DfwCur_City_ADDR, @Lc_DfwCur_State_ADDR, @Lc_DfwCur_Zip_ADDR, @Ld_DfwCur_FileLoad_DATE, @Lc_DfwCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_ErrorE0944_TEXT,
      @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE Dfw_CUR;

   DEALLOCATE Dfw_CUR;

   --Update the Process_INDC in the Load table with 'Y' for non matched records as the file is BULK volume file.
   SET @Ls_Sql_TEXT = 'UPDATE LDFWL_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   UPDATE LDFWL_Y1
      SET Process_INDC = @Lc_ProcessY_INDC
    WHERE Process_INDC = @Lc_ProcessN_INDC;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @@ROWCOUNT;
   --Update the parameter table with the job run date as the current system date3
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

   --Log the Status of job in BSTL_Y1 as Success	
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

   --Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:	
   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION DFW_PROCESS;
  END TRY

  BEGIN CATCH
   --Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:			                              
   --Close Transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DFW_PROCESS;
    END

   --CURSOR_STATUS implementation:
   IF CURSOR_STATUS ('local', 'Dfw_CUR') IN (0, 1)
    BEGIN
     CLOSE Dfw_CUR;

     DEALLOCATE Dfw_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   --Update Status in Batch Log Table
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
  END CATCH
 END


GO
