/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DOR$SP_PROCESS_DOR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_INCOMING_DOR$SP_PROCESS_DOR
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_LOC_INCOMING_DOR$SP_PROCESS_RESPONSE Process the data received from DOR and 
					loads into PLIC_Y1 for further processing.
Frequency		:	DAILY
Developed On	:	5/10/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS ,
                    BATCH_COMMON$BATE_LOG,  
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_GET_BATCH_DETAILS,
					BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT,
					BATCH_COMMON$SP_GET_OTHP,
					BATCH_COMMON$SP_INSERT_ACTIVITY,
					BATCH_COMMON$SP_ADDRESS_UPDATE,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
					BATCH_COMMON$SP_BATCH_RESTART_UPDATE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DOR$SP_PROCESS_DOR]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_OtherPartyDor_IDNO     NUMERIC(9) = 999999973,
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_TypeAddress_CODE       CHAR(1) = 'M',
          @Lc_StatusP_CODE           CHAR(1) = 'P',
		  @Lc_StatusY_CODE           CHAR(1) = 'Y',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_ErrorFound_INDC        CHAR(1) = 'N',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_NoteN_INDC             CHAR(1) = 'N',
          @Lc_StatusCaseO_CODE       CHAR(1) = 'O',
          @Lc_StatusCaseC_CODE       CHAR(1) = 'C',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_CaseRelationshipC_CODE CHAR(1) = 'C',
          @Lc_CaseRelationshipA_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE CHAR(1) = 'P',
          @Lc_TypeCaseH_CODE         CHAR(1) = 'H',
          @Lc_TypeOthp_CODE          CHAR(1) = 'E',
          @Lc_CaseMemberStatusA_CODE CHAR(1) = 'A',
          @Lc_LicenseStatusA_CODE    CHAR(1) = 'A',
          @Lc_LicenseStatusI_CODE    CHAR(1) = 'I',
          @Lc_SourceVerifiedA_CODE   CHAR(1) = 'A',
          @Lc_Country_ADDR           CHAR(2) = 'US',
          @Lc_IssuingStateDe_CODE    CHAR(2) = 'DE',
          @Lc_ReasonStatusUB_CODE    CHAR(2) = 'UB',
          @Lc_ReasonStatusUC_CODE    CHAR(2) = 'UC',
          @Lc_TypeIncomeSE_CODE      CHAR(2) = 'SE',
          @Lc_SourceVerified_CODE    CHAR(3) = 'DOR',
          @Lc_SourceLocation_CODE    CHAR(3) = 'DOR',
          @Lc_TypeLicense9500_CODE   CHAR(5) = '9500',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_ErrorE1424_CODE        CHAR(5) = 'E1424',
          @Lc_ErrorE1089_CODE        CHAR(5) = 'E1089',
          @Lc_ErrorE0002_TEXT        CHAR(5) = 'E0002',
          @Lc_ErrorE0145_CODE        CHAR(5) = 'E0145',
          @Lc_ErrorE0012_CODE        CHAR(5) = 'E0012',
          @Lc_ErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_ErrorE1405_CODE        CHAR(5) = 'E1405',
          @Lc_ErrorE0085_CODE        CHAR(5) = 'E0085',
          @Lc_Job_ID                 CHAR(7) = 'DEB8041',
          @Lc_Process_ID             CHAR(10) = 'BATCH',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_WorkerUpdate_ID        CHAR(30) = 'BATCH',
          @Ls_ErrorE0085_TEXT        VARCHAR(50) = 'INVALID VALUE',
          @Ls_ErrorE0944_TEXT        VARCHAR(50) = 'NO RECORDS(S) TO PROCESS',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_DOR',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_DOR',
          @Ld_High_DATE              DATE = '12/31/9999',
          @Ld_Low_DATE               DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                        NUMERIC(1) = 0,
          @Ln_Office_IDNO                      NUMERIC(3),
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5),
          @Ln_RestartLine_NUMB                 NUMERIC(5),
          @Ln_ProcessedRecordsCommit_QNTY      NUMERIC(6) = 0,
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_OtherParty_IDNO                  NUMERIC(9),
          @Ln_MemberSsn_NUMB                   NUMERIC(9),
          @Ln_OwnerSsn_NUMB                    NUMERIC(9),
          @Ln_MemberMci_IDNO                   NUMERIC(10),
          @Ln_RowsCount_NUMB                   NUMERIC(10) = 0,
          @Ln_Error_NUMB                       NUMERIC(10),
          @Ln_ErrorLine_NUMB                   NUMERIC(10),
          @Ln_Sein_IDNO                        NUMERIC(12),
          @Ln_Phone_NUMB                       NUMERIC(15),
          @Ln_TransactionEventSeq_NUMB         NUMERIC(19) = 0,
          @Ln_RecordCount_NUMB                 NUMERIC(20) = 0,
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Lc_LicenseStatus_CODE               CHAR(1),
          @Lc_Msg_CODE                         CHAR(5),
          @Lc_BateError_CODE                   CHAR(5),
          @Lc_Fips_CODE                        CHAR(7),
          @Lc_DescriptionContactOther_TEXT     CHAR(30),
          @Lc_Aka_NAME                         CHAR(30),
          @Lc_Attn_ADDR                        CHAR(40),
          @Ls_Contact_EML                      VARCHAR(60) = '',
          @Ls_Sql_TEXT                         VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200),
          @Ls_DescriptionComments_TEXT         VARCHAR(1000),
          @Ls_Sqldata_TEXT                     VARCHAR(1000) = '',
          @Ls_BateRecord_TEXT                  VARCHAR(1000),
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT            VARCHAR(4000),
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2;
  --Cursor Variable Naming:
  DECLARE @Ln_ProcessDorCur_Seq_IDNO                   NUMERIC(19),
          @Lc_ProcessDorCur_PrefixSsnNumb_TEXT         CHAR(1),
          @Lc_ProcessDorCur_MemberSsnNumb_TEXT         CHAR(9),
          @Lc_ProcessDorCur_SuffixSsnNumb_TEXT         CHAR(3),
          @Lc_ProcessDorCur_Business_NAME              CHAR(32),
          @Lc_ProcessDorCur_Trade_NAME                 CHAR(32),
          @Lc_ProcessDorCur_Business_CODE              CHAR(3),
          @Lc_ProcessDorCur_OwnershipType_CODE         CHAR(2),
          @Lc_ProcessDorCur_LicenseNo_TEXT             CHAR(10),
          @Lc_ProcessDorCur_LocationNormalization_CODE CHAR(1),
          @Ls_ProcessDorCur_LocationLine1_ADDR         VARCHAR(50),
          @Ls_ProcessDorCur_LocationLine2_ADDR         VARCHAR(50),
          @Lc_ProcessDorCur_LocationCity_ADDR          CHAR(28),
          @Lc_ProcessDorCur_LocationState_ADDR         CHAR(2),
          @Lc_ProcessDorCur_LocationZip_ADDR           CHAR(15),
          @Lc_ProcessDorCur_MultiEmployer_INDC         CHAR(1),
          @Lc_ProcessDorCur_OwnerPrefixSsnNumb_TEXT    CHAR(1),
          @Lc_ProcessDorCur_OwnerSsnNumb_TEXT          CHAR(9),
          @Lc_ProcessDorCur_Owner_NAME                 CHAR(32),
          @Lc_ProcessDorCur_LicenseStatus_CODE         CHAR(1),
          @Lc_ProcessDorCur_MailingNormalization_CODE  CHAR(1),
          @Ls_ProcessDorCur_MailingLine1_ADDR          VARCHAR(50),
          @Ls_ProcessDorCur_MailingLine2_ADDR          VARCHAR(50),
          @Lc_ProcessDorCur_MailingCity_ADDR           CHAR(28),
          @Lc_ProcessDorCur_MailingState_ADDR          CHAR(2),
          @Lc_ProcessDorCur_MailingZip_ADDR            CHAR(15),
          @Ld_ProcessDorCur_FileLoad_DATE              DATE,
          @Lc_ProcessDorCur_Process_INDC               CHAR(1);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Selecting date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
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

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END

   --CURSOR DECLARATION
   DECLARE ProcessDor_CUR INSENSITIVE CURSOR FOR
    SELECT DOR.Seq_IDNO,
           DOR.PrefixSsn_NUMB,
           DOR.MemberSsn_NUMB,
           DOR.SuffixSsn_NUMB,
           DOR.Business_NAME,
           DOR.Trade_NAME,
           DOR.Business_CODE,
           DOR.OwnershipType_CODE,
           DOR.LicenseNo_TEXT,
           DOR.LocationNormalization_CODE,
           DOR.LocationLine1_ADDR,
           DOR.LocationLine2_ADDR,
           DOR.LocationCity_ADDR,
           DOR.LocationState_ADDR,
           DOR.LocationZip_ADDR,
           DOR.MultiEmployer_INDC,
           DOR.OwnerPrefixSsn_NUMB,
           DOR.OwnerSsn_NUMB,
           DOR.Owner_NAME,
           DOR.LicenseStatus_CODE,
           DOR.MailingNormalization_CODE,
           DOR.MailingLine1_ADDR,
           DOR.MailingLine2_ADDR,
           DOR.MailingCity_ADDR,
           DOR.MailingState_ADDR,
           DOR.MailingZip_ADDR,
           DOR.FileLoad_DATE,
           DOR.Process_INDC
      FROM LDSPL_Y1 DOR
     WHERE DOR.Process_INDC = @Lc_ProcessN_INDC
       AND EXISTS(SELECT 1
                    FROM DEMO_Y1 D
                   WHERE ISNUMERIC(DOR.OwnerSsn_NUMB) = 1
                     AND D.MemberSsn_NUMB = DOR.OwnerSsn_NUMB
                     AND LEFT (D.Last_NAME, 5) = LEFT(SUBSTRING(Owner_NAME, 0, CHARINDEX(',', Owner_NAME)), 5));

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = '';

   BEGIN TRANSACTION DorProcess

   -- Check if restart key exists in Restart table.
   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   SELECT @Ln_RestartLine_NUMB = CAST (RST.RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 RST
    WHERE RST.Job_ID = @Lc_Job_ID
      AND RST.Run_DATE = @Ld_Run_DATE;

   SET @Ln_RowsCount_NUMB = @@ROWCOUNT;

   IF @Ln_RowsCount_NUMB = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   --DELETE DUPLICATE BATE RECORDS
   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveRun_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   -- Cursor starts 		
   SET @Ls_Sql_TEXT = 'OPEN ProcessDor_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN ProcessDor_CUR;

   SET @Ls_Sql_TEXT = 'FETCH ProcessDor_CUR';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM ProcessDor_CUR INTO @Ln_ProcessDorCur_Seq_IDNO, @Lc_ProcessDorCur_PrefixSsnNumb_TEXT, @Lc_ProcessDorCur_MemberSsnNumb_TEXT, @Lc_ProcessDorCur_SuffixSsnNumb_TEXT, @Lc_ProcessDorCur_Business_NAME, @Lc_ProcessDorCur_Trade_NAME, @Lc_ProcessDorCur_Business_CODE, @Lc_ProcessDorCur_OwnershipType_CODE, @Lc_ProcessDorCur_LicenseNo_TEXT, @Lc_ProcessDorCur_LocationNormalization_CODE, @Ls_ProcessDorCur_LocationLine1_ADDR, @Ls_ProcessDorCur_LocationLine2_ADDR, @Lc_ProcessDorCur_LocationCity_ADDR, @Lc_ProcessDorCur_LocationState_ADDR, @Lc_ProcessDorCur_LocationZip_ADDR, @Lc_ProcessDorCur_MultiEmployer_INDC, @Lc_ProcessDorCur_OwnerPrefixSsnNumb_TEXT, @Lc_ProcessDorCur_OwnerSsnNumb_TEXT, @Lc_ProcessDorCur_Owner_NAME, @Lc_ProcessDorCur_LicenseStatus_CODE, @Lc_ProcessDorCur_MailingNormalization_CODE, @Ls_ProcessDorCur_MailingLine1_ADDR, @Ls_ProcessDorCur_MailingLine2_ADDR, @Lc_ProcessDorCur_MailingCity_ADDR, @Lc_ProcessDorCur_MailingState_ADDR, @Lc_ProcessDorCur_MailingZip_ADDR, @Ld_ProcessDorCur_FileLoad_DATE, @Lc_ProcessDorCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --When no records are selected to process.
   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Fetch the data from cursor
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVEDorProcess;

      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_ProcessDorCur_Seq_IDNO AS VARCHAR), '') + ', PrefixSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_PrefixSsnNumb_TEXT, '') + ', MemberSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_MemberSsnNumb_TEXT, '') + ', SuffixSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_SuffixSsnNumb_TEXT, '') + ', Business_NAME = ' + ISNULL(@Lc_ProcessDorCur_Business_NAME, '') + ', Trade_NAME = ' + ISNULL(@Lc_ProcessDorCur_Trade_NAME, '') + ', Business_CODE = ' + ISNULL(@Lc_ProcessDorCur_Business_CODE, '') + ', OwnershipType_CODE = ' + ISNULL(@Lc_ProcessDorCur_OwnershipType_CODE, '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_ProcessDorCur_LicenseNo_TEXT, '') + ', LocationLine1_ADDR = ' + ISNULL(@Ls_ProcessDorCur_LocationLine1_ADDR, '') + ', LocationLine2_ADDR = ' + ISNULL(@Ls_ProcessDorCur_LocationLine2_ADDR, '') + ', LocationCity_ADDR = ' + ISNULL(@Lc_ProcessDorCur_LocationCity_ADDR, '') + ', LocationState_ADDR = ' + ISNULL(@Lc_ProcessDorCur_LocationState_ADDR, '') + ', LocationZip_ADDR = ' + ISNULL(@Lc_ProcessDorCur_LocationZip_ADDR, '') + ', MultiEmployer_INDC = ' + ISNULL(@Lc_ProcessDorCur_MultiEmployer_INDC, '') + ', OwnerPrefixSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_OwnerPrefixSsnNumb_TEXT, '') + ', OwnerSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_OwnerSsnNumb_TEXT, '') + ', Owner_NAME = ' + ISNULL(@Lc_ProcessDorCur_Owner_NAME, '') + ', LicenseStatus_CODE = ' + ISNULL(@Lc_ProcessDorCur_LicenseStatus_CODE, '') + ', MailingNormalization_CODE = ' + ISNULL(@Lc_ProcessDorCur_MailingNormalization_CODE, '') + ', MailingLine1_ADDR = ' + ISNULL(@Ls_ProcessDorCur_MailingLine1_ADDR, '') + ', MailingLine2_ADDR = ' + ISNULL(@Ls_ProcessDorCur_MailingLine2_ADDR, '') + ', MailingCity_ADDR = ' + ISNULL(@Lc_ProcessDorCur_MailingCity_ADDR, '') + ', MailingState_ADDR = ' + ISNULL(@Lc_ProcessDorCur_MailingState_ADDR, '') + ', MailingZip_ADDR = ' + ISNULL(@Lc_ProcessDorCur_MailingZip_ADDR, '') + ', FileLoadDate_TEXT = ' + ISNULL(CAST(@Ld_ProcessDorCur_FileLoad_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_ProcessDorCur_Process_INDC, '');
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_ErrorFound_INDC = 'N';
      SET @Ln_RecordCount_NUMB = @Ln_RecordCount_NUMB + 1;
      SET @Ls_CursorLocation_TEXT ='DOR - CURSOR COUNT - ' + CAST (@Ln_RecordCount_NUMB AS VARCHAR);
      SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusI_CODE;
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', DORSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_MemberSsnNumb_TEXT, '') + ', OwnerSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_OwnerSsnNumb_TEXT, '');

      IF ISNUMERIC (@Lc_ProcessDorCur_MemberSsnNumb_TEXT) = 0
          OR ISNUMERIC (@Lc_ProcessDorCur_OwnerSsnNumb_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
        SET @Ls_DescriptionError_TEXT = @Ls_ErrorE0085_TEXT;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_MemberSsn_NUMB = CAST(@Lc_ProcessDorCur_MemberSsnNumb_TEXT AS NUMERIC);
        SET @Ln_OwnerSsn_NUMB = CAST(@Lc_ProcessDorCur_OwnerSsnNumb_TEXT AS NUMERIC);
       END

      SET @Ls_Sql_TEXT = 'CHECK MEMBER EXISTS IN DEMO';
      SET @Ls_Sqldata_TEXT = 'OwnerSsnNumb_TEXT = ' + ISNULL(@Lc_ProcessDorCur_OwnerSsnNumb_TEXT, '');

      SELECT @Ln_RowsCount_NUMB = COUNT(D.MemberMci_IDNO)
        FROM DEMO_Y1 D
       WHERE D.MemberSsn_NUMB = @Ln_OwnerSsn_NUMB;

      IF (@Ln_RowsCount_NUMB > 1)
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'DUPLICATE RECORD EXISTS';
        SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

        RAISERROR(50001,16,1);
       END
      ELSE IF (@Ln_RowsCount_NUMB = 0)
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0012_CODE;
        SET @Ls_DescriptionError_TEXT = 'No matching records found for ' + @Ls_Sqldata_TEXT;

        RAISERROR(50001,16,1);
       END
      ELSE
       BEGIN
        -- Check If SSN exists in Demo Table
        -- If Exists Match the first 5 characters of the last name to get the Member Id
        SET @Ls_Sql_TEXT = 'GET MEMBER ID FROM DEMO';
        SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(@Lc_ProcessDorCur_OwnerSsnNumb_TEXT, '') + ', Last_NAME = ' + ISNULL(@Lc_ProcessDorCur_Owner_NAME, '');

        SELECT @Ln_MemberMci_IDNO = D.MemberMci_IDNO
          FROM DEMO_Y1 D
         WHERE D.MemberSsn_NUMB = @Ln_OwnerSsn_NUMB
           AND LEFT (D.Last_NAME, 5) = LEFT(SUBSTRING(@Lc_ProcessDorCur_Owner_NAME, 0, CHARINDEX(',', @Lc_ProcessDorCur_Owner_NAME)), 5);

        -- Check if Member is Active NCP/PF
        SET @Ls_Sql_TEXT = ' CHECK MEMBER IS ACTIVE NCP/PF';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '');

        IF EXISTS (SELECT 1
                     FROM CASE_Y1 CA
                          JOIN CMEM_Y1 CM
                           ON CA.Case_IDNO = CM.Case_IDNO
                    WHERE CM.MemberMci_IDNO = @Ln_MemberMci_IDNO
                      AND CA.TypeCase_CODE <> @Lc_TypeCaseH_CODE
                      AND ((CA.StatusCase_CODE = @Lc_StatusCaseO_CODE
                            AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                            AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipP_CODE, @Lc_CaseRelationshipA_CODE))
                            OR (CA.StatusCase_CODE = @Lc_StatusCaseC_CODE
                                AND CA.RsnStatusCase_CODE IN (@Lc_ReasonStatusUB_CODE, @Lc_ReasonStatusUC_CODE)
                                AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipP_CODE, @Lc_CaseRelationshipA_CODE))))
         BEGIN
          -- Generate Sequence 
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
          SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_NoteN_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_NoteN_INDC,
           @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END

          -- Begin Member NCP
          -- Update Address using common Address Update Routine
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE ';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_ProcessDorCur_MailingLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_ProcessDorCur_MailingLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_ProcessDorCur_MailingCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_ProcessDorCur_MailingState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_ProcessDorCur_MailingZip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Phone_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocation_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusP_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedA_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_ProcessDorCur_MailingNormalization_CODE, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_TypeAddress_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
           @As_Line1_ADDR                       = @Ls_ProcessDorCur_MailingLine1_ADDR,
           @As_Line2_ADDR                       = @Ls_ProcessDorCur_MailingLine2_ADDR,
           @Ac_City_ADDR                        = @Lc_ProcessDorCur_MailingCity_ADDR,
           @Ac_State_ADDR                       = @Lc_ProcessDorCur_MailingState_ADDR,
           @Ac_Zip_ADDR                         = @Lc_ProcessDorCur_MailingZip_ADDR,
           @Ac_Country_ADDR                     = @Lc_Country_ADDR,
           @An_Phone_NUMB                       = @Ln_Phone_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_SourceLocation_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_StatusP_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
           @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
           @Ac_Process_ID                       = @Lc_Process_ID,
           @Ac_SignedOnWorker_ID                = @Lc_WorkerUpdate_ID,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
           @Ac_Normalization_CODE               = @Lc_ProcessDorCur_MailingNormalization_CODE,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
             @As_Procedure_NAME        = @Ls_Procedure_NAME,
             @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
             @As_Sql_TEXT              = @Ls_Sql_TEXT,
             @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
             @An_Error_NUMB            = 50001,
             @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
             @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

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
            ELSE IF @Lc_Msg_CODE = @Lc_TypeError_CODE
             BEGIN
              SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
             END
           END

          IF LTRIM(RTRIM(@Lc_ProcessDorCur_LicenseStatus_CODE)) = @Lc_LicenseStatusA_CODE
           BEGIN
            -- Generate OTHP_IDNO for the Owner SSN,EIN or ITIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
            SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@Lc_ProcessDorCur_Business_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Aka_NAME, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_ProcessDorCur_LocationLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_ProcessDorCur_LocationLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_ProcessDorCur_LocationCity_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_ProcessDorCur_LocationZip_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_ProcessDorCur_LocationState_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_DescriptionContactOther_TEXT, '') + ', Phone_NUMB = ' + ISNULL('0', '') + ', Fax_NUMB = ' + ISNULL('0', '') + ', Contact_EML = ' + ISNULL(@Ls_Contact_EML, '') + ', ReferenceOthp_IDNO = ' + ISNULL('0', '') + ', BarAtty_NUMB = ' + ISNULL('0', '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Sein_IDNO AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocation_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', DchCarrier_IDNO = ' + ISNULL('0', '') + ', Normalization_CODE = ' + ISNULL(@Lc_ProcessDorCur_LocationNormalization_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');

            EXECUTE BATCH_COMMON$SP_GET_OTHP
             @Ad_Run_DATE                     = @Ld_Run_DATE,
             @An_Fein_IDNO                    = @Ln_MemberSsn_NUMB,
             @Ac_TypeOthp_CODE                = @Lc_TypeOthp_CODE,
             @As_OtherParty_NAME              = @Lc_ProcessDorCur_Business_NAME,
             @Ac_Aka_NAME                     = @Lc_Aka_NAME,
             @Ac_Attn_ADDR                    = @Lc_Attn_ADDR,
             @As_Line1_ADDR                   = @Ls_ProcessDorCur_LocationLine1_ADDR,
             @As_Line2_ADDR                   = @Ls_ProcessDorCur_LocationLine2_ADDR,
             @Ac_City_ADDR                    = @Lc_ProcessDorCur_LocationCity_ADDR,
             @Ac_Zip_ADDR                     = @Lc_ProcessDorCur_LocationZip_ADDR,
             @Ac_State_ADDR                   = @Lc_ProcessDorCur_LocationState_ADDR,
             @Ac_Fips_CODE                    = @Lc_Fips_CODE,
             @Ac_Country_ADDR                 = @Lc_Country_ADDR,
             @Ac_DescriptionContactOther_TEXT = @Lc_DescriptionContactOther_TEXT,
             @An_Phone_NUMB                   = 0,
             @An_Fax_NUMB                     = 0,
             @As_Contact_EML                  = @Ls_Contact_EML,
             @An_ReferenceOthp_IDNO           = 0,
             @An_BarAtty_NUMB                 = 0,
             @An_Sein_IDNO                    = @Ln_Sein_IDNO,
             @Ac_SourceLoc_CODE               = @Lc_SourceLocation_CODE,
             @Ac_WorkerUpdate_ID              = @Lc_WorkerUpdate_ID,
             @An_DchCarrier_IDNO              = 0,
             @Ac_Normalization_CODE           = @Lc_ProcessDorCur_LocationNormalization_CODE,
             @Ac_Process_ID                   = @Lc_Job_ID,
             @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
             @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
            ELSE IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
             BEGIN
              SET @Lc_BateError_CODE = @Lc_Msg_CODE;

              EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
               @As_Procedure_NAME        = @Ls_Procedure_NAME,
               @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
               @As_Sql_TEXT              = @Ls_Sql_TEXT,
               @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
               @An_Error_NUMB            = 50001,
               @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
               @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

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
              ELSE IF @Lc_Msg_CODE = @Lc_TypeError_CODE
               BEGIN
                SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;

                GOTO LICENSEUPDATE;
               END
             END
            ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
               AND @Ln_OtherParty_IDNO > 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
              SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR (10)), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusY_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR (20)), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncomeSE_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceVerifiedA_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR (20)), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR (20)), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR(20)), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocation_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(@Lc_Space_TEXT, '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

              EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
               @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
               @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
               @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
               @Ac_Status_CODE                = @Lc_StatusY_CODE,
               @Ad_Status_DATE                = @Ld_Run_DATE,
               @Ac_TypeIncome_CODE            = @Lc_TypeIncomeSE_CODE,
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
               @Ac_SourceLoc_CODE             = @Lc_SourceLocation_CODE,
               @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
               @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
               @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
               @Ad_EligCoverage_DATE          = @Ld_Run_DATE,
               @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
               @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
               @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
               @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
               @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
               @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
               @Ac_Process_ID                 = @Lc_Job_ID,
               @An_OfficeSignedOn_IDNO        = @Ln_Zero_NUMB,
               @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END;
              ELSE IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
               BEGIN
                SET @Lc_BateError_CODE = @Lc_Msg_CODE;

                EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
                 @As_Procedure_NAME        = @Ls_Procedure_NAME,
                 @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
                 @As_Sql_TEXT              = @Ls_Sql_TEXT,
                 @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
                 @An_Error_NUMB            = 50001,
                 @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
                 @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

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
                ELSE IF @Lc_Msg_CODE = @Lc_TypeError_CODE
                 BEGIN
                  SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
                 END
               END
             END
           END

          LICENSEUPDATE:;

          IF LTRIM(RTRIM(@Lc_ProcessDorCur_LicenseStatus_CODE)) = @Lc_LicenseStatusA_CODE
           BEGIN
            SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusA_CODE;
           END
          ELSE
           BEGIN
            SET @Lc_LicenseStatus_CODE = @Lc_LicenseStatusI_CODE;
           END

          IF ((@Lc_LicenseStatus_CODE = @Lc_LicenseStatusA_CODE)
               OR EXISTS(SELECT 1
                           FROM PLIC_Y1 P
                          WHERE P.LicenseNo_TEXT = @Lc_ProcessDorCur_LicenseNo_TEXT
                            AND P.MemberMci_IDNO = @Ln_MemberMci_IDNO
                            AND P.LicenseStatus_CODE = @Lc_LicenseStatusA_CODE
                            AND P.EndValidity_DATE = @Ld_High_DATE
                            AND @Lc_LicenseStatus_CODE = @Lc_LicenseStatusI_CODE))
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_LICENSE_UPDATE';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_ProcessDorCur_LicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_ProcessDorCur_OwnershipType_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR(20)), '') + ', LicenseStatus_CODE = ' + ISNULL(@Lc_ProcessDorCur_LicenseStatus_CODE, '') + ', IssuingState_CODE = ' + ISNULL(@Lc_IssuingStateDe_CODE, '') + ', IssueLicense_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '') + ', ExpireLicense_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR(20)), '') + ', SuspLicense_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR(20)), '') + ', OtherParty_IDNO = ' + ISNULL('999999973', '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerified_CODE, '') + ', Profession_CODE = ' + ISNULL(@Lc_ProcessDorCur_Business_CODE, '') + ', Business_NAME = ' + ISNULL(@Lc_ProcessDorCur_Business_NAME, '') + ', Trade_NAME = ' + ISNULL(@Lc_ProcessDorCur_Trade_NAME, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

            EXECUTE BATCH_COMMON$SP_LICENSE_UPDATE
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ac_LicenseNo_TEXT           = @Lc_ProcessDorCur_LicenseNo_TEXT,
             @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
             @Ac_TypeLicense_CODE         = @Lc_TypeLicense9500_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_LicenseStatus_CODE       = @Lc_LicenseStatus_CODE,
             @Ac_IssuingState_CODE        = @Lc_IssuingStateDe_CODE,
             @Ad_IssueLicense_DATE        = @Ld_Run_DATE,
             @Ad_ExpireLicense_DATE       = @Ld_High_DATE,
             @Ad_SuspLicense_DATE         = @Ld_Low_DATE,
             @An_OtherParty_IDNO          = @Ln_OtherPartyDor_IDNO,
             @Ac_SourceVerified_CODE      = @Lc_SourceVerified_CODE,
             @Ac_Profession_CODE          = @Lc_ProcessDorCur_Business_CODE,
             @As_Business_NAME            = @Lc_ProcessDorCur_Business_NAME,
             @As_Trade_NAME               = @Lc_ProcessDorCur_Trade_NAME,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_Process_ID               = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
            ELSE IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
             BEGIN
              SET @Lc_BateError_CODE = @Lc_Msg_CODE;

              EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
               @As_Procedure_NAME        = @Ls_Procedure_NAME,
               @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
               @As_Sql_TEXT              = @Ls_Sql_TEXT,
               @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
               @An_Error_NUMB            = 50001,
               @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
               @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

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
              ELSE IF @Lc_Msg_CODE = @Lc_TypeError_CODE
               BEGIN
                SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
               END
             END

            IF NOT EXISTS (SELECT 1
                             FROM DSPT_Y1
                            WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
                              AND LicenseNo_TEXT = @Lc_ProcessDorCur_LicenseNo_TEXT)
             BEGIN
              SET @Ls_Sql_TEXT = 'INSERT DSPT_Y1';
              SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_ProcessDorCur_LicenseNo_TEXT, '') + ', TaxPayor_ID = ' + ISNULL(CAST(@Lc_ProcessDorCur_PrefixSsnNumb_TEXT + @Lc_ProcessDorCur_MemberSsnNumb_TEXT AS VARCHAR), '') + ', SuffixSsnNo_TEXT = ' + ISNULL(@Lc_ProcessDorCur_SuffixSsnNumb_TEXT, '') + ', OwnerShipType_CODE = ' + ISNULL(@Lc_ProcessDorCur_OwnershipType_CODE, '');

              INSERT DSPT_Y1
                     (MemberMci_IDNO,
                      LicenseNo_TEXT,
                      TaxPayor_ID,
                      SuffixSsnNo_TEXT,
                      OwnerShipType_CODE)
              SELECT @Ln_MemberMci_IDNO AS MemberMci_IDNO,
                     @Lc_ProcessDorCur_LicenseNo_TEXT AS LicenseNo_TEXT,
                     LTRIM(RTRIM(@Lc_ProcessDorCur_PrefixSsnNumb_TEXT)) + LTRIM(RTRIM(@Lc_ProcessDorCur_MemberSsnNumb_TEXT)) AS TaxPayor_ID,
                     @Lc_ProcessDorCur_SuffixSsnNumb_TEXT AS SuffixSsnNo_TEXT,
                     @Lc_ProcessDorCur_OwnershipType_CODE AS OwnerShipType_CODE;

              SET @Ln_RowsCount_NUMB = @@ROWCOUNT;

              IF @Ln_RowsCount_NUMB = 0
               BEGIN
                SET @Ls_DescriptionError_TEXT = 'INSERT DSPT_Y1 FAILED';

                RAISERROR(50001,16,1);
               END
             END
           END
         END
        ELSE
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'DATA REJECTED, NO VALID CASE FOUND TO LOAD DATA ';
          SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;

          RAISERROR(50001,16,1);
         END
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVEDorProcess;
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '');

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
     SET @Ls_Sql_TEXT = 'UPDATE LDSPL_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_ProcessDorCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LDSPL_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_ProcessDorCur_Seq_IDNO;

     SET @Ln_RowsCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowsCount_NUMB = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_ErrorE0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_RowsCount_NUMB;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Ln_RowsCount_NUMB;

     -- If the commit frequency is attained, Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR (20)), '') + ', RestartKey_TEXT = ' + ISNULL(CAST(@Ln_RecordCount_NUMB AS VARCHAR(20)), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_NUMB,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       COMMIT TRANSACTION DorProcess;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;

       BEGIN TRANSACTION DorProcess;

       --After Transaction is committed and again began set the commit frequency to 0                        
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION DorProcess;

       SET @Ls_DescriptionError_TEXT = 'REACHED THRESHOLD';

       RAISERROR (50001,16,1);
      END;

     FETCH NEXT FROM ProcessDor_Cur INTO @Ln_ProcessDorCur_Seq_IDNO, @Lc_ProcessDorCur_PrefixSsnNumb_TEXT, @Lc_ProcessDorCur_MemberSsnNumb_TEXT, @Lc_ProcessDorCur_SuffixSsnNumb_TEXT, @Lc_ProcessDorCur_Business_NAME, @Lc_ProcessDorCur_Trade_NAME, @Lc_ProcessDorCur_Business_CODE, @Lc_ProcessDorCur_OwnershipType_CODE, @Lc_ProcessDorCur_LicenseNo_TEXT, @Lc_ProcessDorCur_LocationNormalization_CODE, @Ls_ProcessDorCur_LocationLine1_ADDR, @Ls_ProcessDorCur_LocationLine2_ADDR, @Lc_ProcessDorCur_LocationCity_ADDR, @Lc_ProcessDorCur_LocationState_ADDR, @Lc_ProcessDorCur_LocationZip_ADDR, @Lc_ProcessDorCur_MultiEmployer_INDC, @Lc_ProcessDorCur_OwnerPrefixSsnNumb_TEXT, @Lc_ProcessDorCur_OwnerSsnNumb_TEXT, @Lc_ProcessDorCur_Owner_NAME, @Lc_ProcessDorCur_LicenseStatus_CODE, @Lc_ProcessDorCur_MailingNormalization_CODE, @Ls_ProcessDorCur_MailingLine1_ADDR, @Ls_ProcessDorCur_MailingLine2_ADDR, @Lc_ProcessDorCur_MailingCity_ADDR, @Lc_ProcessDorCur_MailingState_ADDR, @Lc_ProcessDorCur_MailingZip_ADDR, @Ld_ProcessDorCur_FileLoad_DATE, @Lc_ProcessDorCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_ErrorE0944_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_ErrorE0944_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE ProcessDor_CUR;

   DEALLOCATE ProcessDor_CUR;

   -- Update the Process_INDC in the Load table with 'Y' for non matched records as the file is BULK volume file.
   SET @Ls_Sql_TEXT = 'UPDATE LDSPL_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   UPDATE LDSPL_Y1
      SET Process_INDC = @Lc_ProcessY_INDC
    WHERE Process_INDC = @Lc_ProcessN_INDC;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @@ROWCOUNT;
   -- Update the parameter table with the job run date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success	
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

   COMMIT TRANSACTION DorProcess;
  END TRY

  -- If any exception is raised, it is handled in this catch block.
  BEGIN CATCH
   -- Close Transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DorProcess;
    END

   -- Close the Cursor
   IF CURSOR_STATUS ('local', 'ProcessDor_CUR') IN (0, 1)
    BEGIN
     CLOSE ProcessDor_CUR;

     DEALLOCATE ProcessDor_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   -- Retrieve and log the Error Description.
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
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
  END CATCH
 END


GO
