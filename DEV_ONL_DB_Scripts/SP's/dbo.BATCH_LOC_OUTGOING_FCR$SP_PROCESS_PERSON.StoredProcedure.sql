/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON batch process is to extract 
					  Person details from DECSS database and insert into EFMEM_Y1.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON] (
 @Ad_Run_DATE                 DATE,
 @Ac_Process_INDC             CHAR(1),
 @Ac_TransType_CODE           CHAR(2),
 @An_Case_IDNO                NUMERIC(6),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT,
 @An_Batch_NUMB               NUMERIC(6),
 @Ac_Job_ID                   CHAR(7)
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_InputCase_IDNO                    NUMERIC(6) = @An_Case_IDNO,
          @Ln_InputMemberMci_IDNO               NUMERIC(10) = @An_MemberMci_IDNO,
          @Ln_TransactionEventSeq_NUMB          NUMERIC(19) = @An_TransactionEventSeq_NUMB,
          @Lc_Space_TEXT                        CHAR = ' ',
          @Lc_StatusCaseMemberActive_CODE       CHAR = 'A',
          @Lc_StringZero_TEXT                   CHAR = '0',
          @Lc_Yes_INDC                          CHAR = 'Y',
          @Lc_SkipRecord_INDC                   CHAR = 'N',
          @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
          @Lc_CaseTypeNonIvd_CODE               CHAR(1) = 'H',
          @Lc_CaseRelationshipDp_CODE           CHAR(1) = 'D',
          @Lc_CaseRelationshipCp_CODE           CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE          CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE           CHAR(1) = 'P',
          @Lc_ActionAdd_CODE                    CHAR(1) = 'A',
          @Lc_ActionChange_CODE                 CHAR(1) = 'C',
          @Lc_ActionDelete_CODE                 CHAR(1) = 'D',
          @Lc_CaseProcessFlag_INDC              CHAR(1) = 'C',
          @Lc_CaseStatusClosed_CODE             CHAR(1) = 'C',
          @Lc_No_INDC                           CHAR(1) = 'N',
          @Lc_Star_CODE                         CHAR(1) = '*',
          @Lc_Hyphen_TEXT                       CHAR(1) = '-',
          @Lc_CaseStatusOpen_CODE               CHAR(1) = 'O',
          @Lc_Mailing_ADDR                      CHAR(1) = 'M',
          @Lc_Residential_ADDR                  CHAR(1) = 'P',
          @Lc_ResidentialSecondary_ADDR         CHAR(1) = 'S',
          @Lc_StatusMemberMerged_CODE           CHAR(1) = 'M',
          @Lc_PersonLocProcessFlag_INDC         CHAR(1) = 'L',
          @Lc_ActionLocate_CODE                 CHAR(1) = 'L',
          @Lc_SexUnknown_CODE                   CHAR(1) = 'U',
          @Lc_SexMale_CODE                      CHAR(1) = 'M',
          @Lc_SexFemale_CODE                    CHAR(1) = 'F',
          @Lc_LocateStatusLocated_CODE          CHAR(1) = 'L',
          @Lc_StatusVerified_CODE               CHAR(1) = 'Y',
          @Lc_LocRequestForIvd_CODE             CHAR(2) = 'CS',
          @Lc_RecPerson_ID                      CHAR(2) = 'FP',
          @Lc_SubsystemLo_CODE                  CHAR(2) = 'LO',
          @Lc_CountryUs_CODE                    CHAR(2) = 'US',
          @Lc_TransTypePersonAdd_CODE           CHAR(2) = 'PA',
          @Lc_TransTypePersonChange_CODE        CHAR(2) = 'PC',
          @Lc_TransTypePersonDelete_CODE        CHAR(2) = 'PD',
          @Lc_TransTypePersonMerge_CODE         CHAR(2) = 'PM',
          @Lc_TransTypePersonLocate_CODE        CHAR(2) = 'PL',
          @Lc_FcrParticipantDp_CODE             CHAR(2) = 'CH',
          @Lc_FcrParticipantCp_CODE             CHAR(2) = 'CP',
          @Lc_FcrParticipantNcp_CODE            CHAR(2) = 'NP',
          @Lc_FcrParticipantPf_CODE             CHAR(2) = 'PF',
          @Lc_EfmemFamilyViolence_CODE          CHAR(2) = 'FV',
          @Lc_All_TEXT                          CHAR(3) = 'ALL',
          @Lc_ActivityMajorCase_CODE            CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO                CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT                 CHAR(5) = 'BATCH',
          @Lc_ActivityMinorStfcr_CODE           CHAR(5) = 'STFCR',
          @Lc_Job_ID                            CHAR(7) = @Ac_Job_ID,
          @Lc_DateFormatYyyymmdd_TEXT           CHAR(8) = 'YYYYMMDD',
          @Lc_Notice_ID                         CHAR(8) = NULL,
          @Lc_WorkerDelegate_ID                 CHAR(30) = ' ',
          @Lc_Reference_ID                      CHAR(30) = ' ',
          @Ls_Procedure_NAME                    VARCHAR(100) = 'SP_PROCESS_PERSON',
          @Ls_XmlIn_TEXT                        VARCHAR(4000) = ' ',
          @Ls_NoteDescriptionMemberAdd_TEXT     VARCHAR(4000) = 'MEMBER ADDITION SENT TO FCR',
          @Ls_NoteDescriptionMemberChange_TEXT  VARCHAR(4000) = 'MEMBER CHNAGES SENT TO FCR',
          @Ls_NoteDescriptionMemberDelete_TEXT  VARCHAR(4000) = 'MEMBER DELETION SENT TO FCR',
          @Ls_NoteDescriptionMemberMerge_TEXT   VARCHAR(4000) = 'MEMBER MERGE SENT TO FCR',
          @Ls_NoteDescriptionCaseSubmitted_TEXT VARCHAR(4000) = 'MEMBER SUBMITTED FOR FCR LOCATE',
          @Ld_High_DATE                         DATE = '12/31/9999',
          @Ld_Low_DATE                          DATE = '01/01/0001',
          @Ld_Run_DATE                          DATE = @Ad_Run_DATE;
  DECLARE @Ln_AkaxCount_QNTY                 NUMERIC(2) = 0,
          @Ln_AkaxPrevCount_QNTY             NUMERIC(2) = 0,
          @Ln_MssnCount_QNTY                 NUMERIC(2) = 0,
          @Ln_CaseCounty_IDNO                NUMERIC(5),
          @Ln_CaseOffice_IDNO                NUMERIC(5),
          @Ln_MajorIntSeq_NUMB               NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB               NUMERIC(5) = 0,
          @Ln_PscrmCase_IDNO                 NUMERIC(6),
          @Ln_PscrmPreviousMemberSsn_NUMB    NUMERIC(9),
          @Ln_PscrmMemberAdditional1Ssn_NUMB NUMERIC(9),
          @Ln_PscrmMemberAdditional2Ssn_NUMB NUMERIC(9),
          @Ln_DemoMemberSsn_NUMB             NUMERIC(9),
          @Ln_PscrmMemberSsn_NUMB            NUMERIC(9),
          @Ln_PscrmIrsUsedMemberSsn_NUMB     NUMERIC(9),
          @Ln_Exists_NUMB                    NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO                   NUMERIC(10) = 0,
          @Ln_Schedule_NUMB                  NUMERIC(10) = 0,
          @Ln_Topic_IDNO                     NUMERIC(10),
          @Ln_PscrmNewMemberMci_IDNO         NUMERIC(10),
          @Ln_MmrgMemberMci_IDNO             NUMERIC(10),
          @Ln_DemoMemberMci_IDNO             NUMERIC(10),
          @Ln_PscrmMemberMci_IDNO            NUMERIC(10),
          @Ln_AkaxMemberMci_IDNO             NUMERIC(10),
          @Ln_Error_NUMB                     NUMERIC(11),
          @Ln_ErrorLine_NUMB                 NUMERIC(11),
          @Li_FetchStatus_QNTY               SMALLINT,
          @Li_RowCount_QNTY                  SMALLINT,
          @Lc_Msg_CODE                       CHAR(5),
          @Lc_CaseTypeCase_CODE              CHAR(1),
          @Lc_CaseStatusCase_CODE            CHAR(1),
          @Lc_PscrmTypeAction_CODE           CHAR(1),
          @Lc_Null_TEXT                      CHAR(1) = '',
          @Lc_DemoMemberSex_CODE             CHAR(1),
          @Lc_DemoFv_INDC                    CHAR(1),
          @Lc_CmemCaseRelationship_CODE      CHAR(1),
          @Lc_CmemCaseMemberStatus_CODE      CHAR(1),
          @Lc_ActionType_CODE                CHAR(1),
          @Lc_PscrmCaseRelationship_CODE     CHAR(1),
          @Lc_PscrmBundleResults_INDC        CHAR(1),
          @Lc_PscrmMemberSex_CODE            CHAR(1),
          @Lc_PscrmIrs1099_INDC              CHAR(1),
          @Lc_EfmemTypeAction_CODE           CHAR(1),
          @Lc_EfmemBundleResults_INDC        CHAR(1),
          @Lc_EfmemMemberSex_CODE            CHAR(1),
          @Lc_EfmemMiddleFather_NAME         CHAR(1),
          @Lc_EfmemIrs1099_INDC              CHAR(1),
          @Lc_EfmemRec_ID                    CHAR(2),
          @Lc_DemoBirthState_CODE            CHAR(2),
          @Lc_DemoBirthCountry_CODE          CHAR(2),
          @Lc_PscrmRec_ID                    CHAR(2),
          @Lc_PscrmReservedFcr_CODE          CHAR(2),
          @Lc_PscrmTypeLocReq_CODE           CHAR(2),
          @Lc_PscrmTypeParticipant_CODE      CHAR(2),
          @Lc_PscrmFamilyViolence_CODE       CHAR(2),
          @Lc_PscrmBirthState_CODE           CHAR(2),
          @Lc_PscrmBirthCountry_CODE         CHAR(2),
          @Lc_EfmemReservedFcr_CODE          CHAR(2),
          @Lc_EfmemTypeLocReq_CODE           CHAR(2),
          @Lc_EfmemTypeParticipant_CODE      CHAR(2),
          @Lc_PscrmCountyFips_CODE           CHAR(3),
          @Lc_CaseCountyFips_CODE            CHAR(3),
          @Lc_PscrmSourceLoc1_CODE           CHAR(3),
          @Lc_PscrmSourceLoc2_CODE           CHAR(3),
          @Lc_PscrmSourceLoc3_CODE           CHAR(3),
          @Lc_PscrmSourceLoc4_CODE           CHAR(3),
          @Lc_PscrmSourceLoc5_CODE           CHAR(3),
          @Lc_PscrmSourceLoc6_CODE           CHAR(3),
          @Lc_PscrmSourceLoc7_CODE           CHAR(3),
          @Lc_PscrmSourceLoc8_CODE           CHAR(3),
          @Lc_EfmemCountyFips_CODE           CHAR(3),
          @Lc_EfmemLocateSource1_CODE        CHAR(3),
          @Lc_EfmemLocateSource2_CODE        CHAR(3),
          @Lc_EfmemLocateSource3_CODE        CHAR(3),
          @Lc_EfmemLocateSource4_CODE        CHAR(3),
          @Lc_EfmemLocateSource5_CODE        CHAR(3),
          @Lc_EfmemLocateSource6_CODE        CHAR(3),
          @Lc_EfmemLocateSource7_CODE        CHAR(3),
          @Lc_EfmemLocateSource8_CODE        CHAR(3),
          @Lc_EfmemStCountryBirth_CODE       CHAR(4),
          @Lc_EfmemCase_IDNO                 CHAR(6),
          @Lc_EfmemBirth_DATE                CHAR(8),
          @Lc_EfmemMemberSsn_NUMB            CHAR(9),
          @Lc_EfmemIrsUsedMemberSsn_NUMB     CHAR(9),
          @Lc_EfmemPreviousMemberSsn_NUMB    CHAR(9),
          @Lc_EfmemMemberAdditional1Ssn_NUMB CHAR(9),
          @Lc_EfmemMemberAdditional2Ssn_NUMB CHAR(9),
          @Lc_EfmemMemberMci_IDNO            CHAR(10),
          @Lc_EfmemNewMemberMci_IDNO         CHAR(10),
          @Lc_CaseFile_ID                    CHAR(15),
          @Lc_PscrmUserField_NAME            CHAR(15),
          @Lc_DemoFirst_NAME                 CHAR(15),
          @Lc_PscrmFirst_NAME                CHAR(15),
          @Lc_PscrmFirstFather_NAME          CHAR(15),
          @Lc_PscrmFirstMother_NAME          CHAR(15),
          @Lc_PscrmFirstAdditional1_NAME     CHAR(15),
          @Lc_PscrmFirstAdditional2_NAME     CHAR(15),
          @Lc_PscrmFirstAdditional3_NAME     CHAR(15),
          @Lc_PscrmFirstAdditional4_NAME     CHAR(15),
          @Lc_EfmemUserField_NAME            CHAR(15),
          @Lc_EfmemFirstMother_NAME          CHAR(15),
          @Lc_EfmemFirstAdditional1_NAME     CHAR(15),
          @Lc_EfmemFirstAdditional3_NAME     CHAR(15),
          @Lc_EfmemFirstAdditional4_NAME     CHAR(15),
          @Lc_EfmemFirst_NAME                CHAR(16),
          @Lc_EfmemCityBirth_NAME            CHAR(16),
          @Lc_EfmemFirstFather_NAME          CHAR(16),
          @Lc_EfmemLastFather_NAME           CHAR(16),
          @Lc_EfmemLastMother_NAME           CHAR(16),
          @Lc_EfmemFirstAdditional2_NAME     CHAR(16),
          @Lc_EfmemMiddleAdditional2_NAME    CHAR(16),
          @Lc_EfmemMiddleAdditional4_NAME    CHAR(16),
          @Lc_DemoLast_NAME                  CHAR(20),
          @Lc_DemoMiddle_NAME                CHAR(20),
          @Lc_PscrmMiddle_NAME               CHAR(20),
          @Lc_EfmemMiddle_NAME               CHAR(20),
          @Lc_PscrmLast_NAME                 CHAR(20),
          @Lc_PscrmMiddleFather_NAME         CHAR(20),
          @Lc_PscrmLastFather_NAME           CHAR(20),
          @Lc_PscrmMiddleMother_NAME         CHAR(20),
          @Lc_PscrmLastMother_NAME           CHAR(20),
          @Lc_PscrmMiddleAdditional1_NAME    CHAR(20),
          @Lc_PscrmLastAdditional1_NAME      CHAR(20),
          @Lc_PscrmMiddleAdditional2_NAME    CHAR(20),
          @Lc_PscrmLastAdditional2_NAME      CHAR(20),
          @Lc_PscrmMiddleAdditional3_NAME    CHAR(20),
          @Lc_PscrmLastAdditional3_NAME      CHAR(20),
          @Lc_PscrmMiddleAdditional4_NAME    CHAR(20),
          @Lc_PscrmLastAdditional4_NAME      CHAR(20),
          @Lc_EfmemMiddleMother_NAME         CHAR(20),
          @Lc_EfmemMiddleAdditional1_NAME    CHAR(20),
          @Lc_EfmemLastAdditional2_NAME      CHAR(20),
          @Lc_EfmemMiddleAdditional3_NAME    CHAR(20),
          @Lc_EfmemLastAdditional3_NAME      CHAR(20),
          @Lc_DemoBirthCity_ADDR             CHAR(28),
          @Lc_PscrmBirthCity_NAME            CHAR(28),
          @Lc_CaseWorker_IDNO                CHAR(30),
          @Lc_DemoMaidenMother_NAME          CHAR(30),
          @Lc_EfmemLast_NAME                 CHAR(30),
          @Lc_EfmemLastAdditional1_NAME      CHAR(30),
          @Lc_EfmemLastAdditional4_NAME      CHAR(30),
          @Ls_Sql_TEXT                       VARCHAR(100) = '',
          @Ls_DescriptionNote_TEXT           VARCHAR(100),
          @Ls_ErrorMessage_TEXT              VARCHAR(200),
          @Ls_SqlData_TEXT                   VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT          VARCHAR(4000),
          @Ld_PscrmBirth_DATE                DATE,
          @Ld_DemoBirth_DATE                 DATE,
          @Ld_Start_DATE                     DATETIME2;
  DECLARE @Lc_AkaxCur_LastAlias_NAME     CHAR(20),
          @Lc_AkaxCur_FirstAlias_NAME    CHAR(15),
          @Lc_AkaxCur_MiddleAlias_NAME   CHAR(20),
          @Ld_AkaxCur_BeginValidity_DATE DATE,
          @Ln_MssnCur_Ssn_NUMB           NUMERIC(9),
          @Lc_MssnCur_TypePrimary_CODE   CHAR(1),
          @Ln_MssnCur_SourceVerify_CODE  NUMERIC(2);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   --Get case details from CASE_Y1
   SET @Ls_Sql_TEXT = 'SELECT FROM CASE_Y1 - 1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '');

   SELECT @Lc_CaseStatusCase_CODE = a.StatusCase_CODE,
          @Lc_CaseTypeCase_CODE = a.TypeCase_CODE,
          @Ln_CaseCounty_IDNO = a.County_IDNO,
          @Ln_CaseOffice_IDNO = a.Office_IDNO,
          @Lc_CaseWorker_IDNO = a.Worker_ID,
          @Lc_CaseFile_ID = a.File_ID
     FROM CASE_Y1 a
    WHERE a.Case_IDNO = @Ln_InputCase_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'SELECT FROM CASE_Y1 - 1 - NO DATA FOUND';

     RAISERROR (50001,16,1);
    END

   --Get county fips code
   SET @Lc_CaseCountyFips_CODE = @Lc_Space_TEXT;

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ln_CaseCounty_IDNO) IS NOT NULL
    BEGIN
     SET @Lc_CaseCountyFips_CODE = (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(@Ln_CaseCounty_IDNO AS VARCHAR))), 3));
    END

   --case is closed for the member skip member 
   IF @Lc_CaseStatusCase_CODE = @Lc_CaseStatusClosed_CODE
    BEGIN
     SET @Lc_SkipRecord_INDC = 'Y';
     SET @Ls_ErrorMessage_TEXT = 'CASE IS CLOSED FOR THE MEMBER';

     RAISERROR(50001,16,1);
    END

   --Transaction type is member merge         
   IF @Ac_TransType_CODE = @Lc_TransTypePersonMerge_CODE
    BEGIN
     --Get member mci from MMRG
     SET @Ls_Sql_TEXT = 'SELECT MemberMciPrimary_IDNO FROM MMRG_Y1';
     SET @Ls_SqlData_TEXT = 'MemberMciSecondary_IDNO = ' + ISNULL(CAST(@Ln_InputMemberMci_IDNO AS VARCHAR), '') + ', StatusMerge_CODE = ' + ISNULL(@Lc_StatusMemberMerged_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_MmrgMemberMci_IDNO = X.MemberMciPrimary_IDNO
       FROM MMRG_Y1 X,
            CMEM_Y1 Y
      WHERE X.MemberMciSecondary_IDNO = @Ln_InputMemberMci_IDNO
        AND X.StatusMerge_CODE = @Lc_StatusMemberMerged_CODE
        AND X.EndValidity_DATE = @Ld_High_DATE
        AND Y.Case_IDNO = @Ln_InputCase_IDNO
        AND Y.MemberMci_IDNO = X.MemberMciPrimary_IDNO
        AND Y.CaseMemberStatus_CODE = 'A';

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Lc_SkipRecord_INDC = 'Y';
       SET @Ls_ErrorMessage_TEXT = 'MEMBER NOT IN MMRG';

       RAISERROR (50001,16,1);
      END

     SET @Lc_ActionType_CODE = @Lc_ActionChange_CODE;
     SET @Ln_PscrmNewMemberMci_IDNO = @Ln_MmrgMemberMci_IDNO;
     SET @Ln_DemoMemberMci_IDNO = @Ln_MmrgMemberMci_IDNO;
     SET @Ln_PscrmMemberMci_IDNO = @Ln_InputMemberMci_IDNO;
    END
   ELSE
    BEGIN
     SET @Ln_DemoMemberMci_IDNO = @Ln_InputMemberMci_IDNO;
     SET @Ln_PscrmMemberMci_IDNO = @Ln_DemoMemberMci_IDNO;
     SET @Ln_PscrmNewMemberMci_IDNO = @Lc_StringZero_TEXT;
    END

   --Get member details from demo
   SET @Ls_Sql_TEXT = 'GET MEMBER DETAILS FROM DEMO_Y1, CMEM_Y1';
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '');

   SELECT @Ln_DemoMemberMci_IDNO = a.MemberMci_IDNO,
          @Lc_DemoLast_NAME = SUBSTRING(a.Last_NAME, 1, 16),
          @Lc_DemoFirst_NAME = a.First_NAME,
          @Lc_DemoMiddle_NAME = a.Middle_NAME,
          @Lc_DemoMemberSex_CODE = a.MemberSex_CODE,
          @Ld_DemoBirth_DATE = a.Birth_DATE,
          @Ln_DemoMemberSsn_NUMB = a.MemberSsn_NUMB,
          @Lc_DemoBirthCity_ADDR = SUBSTRING(a.BirthCity_NAME, 1, 16),
          @Lc_DemoBirthState_CODE = a.BirthState_CODE,
          @Lc_DemoBirthCountry_CODE = a.BirthCountry_CODE,
          @Lc_DemoMaidenMother_NAME = SUBSTRING(a.MotherMaiden_NAME, 1, 16),
          @Lc_DemoFv_INDC = b.FamilyViolence_INDC,
          @Lc_CmemCaseRelationship_CODE = b.CaseRelationship_CODE,
          @Lc_CmemCaseMemberStatus_CODE = b.CaseMemberStatus_CODE
     FROM DEMO_Y1 a,
          CMEM_Y1 b
    WHERE a.MemberMci_IDNO = @Ln_DemoMemberMci_IDNO
      AND b.Case_IDNO = @Ln_InputCase_IDNO
      AND a.MemberMci_IDNO = b.MemberMci_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Lc_SkipRecord_INDC = 'Y';
     SET @Ls_ErrorMessage_TEXT = 'MEMBER NOT IN DEMO';

     RAISERROR (50001,16,1);
    END

   --If member relation case not valid skip member
   SET @Ls_Sql_TEXT = 'RELATION_CASE';

   IF @Lc_CmemCaseRelationship_CODE NOT IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE, @Lc_CaseRelationshipDp_CODE)
    BEGIN
     --Skip the record if relation case not valid 
     SET @Lc_SkipRecord_INDC = 'Y';
     SET @Ls_ErrorMessage_TEXT = 'MEMBER RELATION CASE NOT VALID';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECK TRANS TYPE AND SET ACTION TYPE';

   --Person Add
   IF @Ac_TransType_CODE = @Lc_TransTypePersonAdd_CODE
    BEGIN
     SET @Lc_ActionType_CODE = @Lc_ActionAdd_CODE;
     SET @Lc_PscrmTypeAction_CODE = @Lc_ActionAdd_CODE;
    END

   --Person Change
   IF @Ac_TransType_CODE = @Lc_TransTypePersonChange_CODE
    BEGIN
     SET @Lc_ActionType_CODE = @Lc_ActionChange_CODE;
     SET @Lc_PscrmTypeAction_CODE = @Lc_ActionChange_CODE;
    END

   --Person Delete
   IF @Ac_TransType_CODE = @Lc_TransTypePersonDelete_CODE
    BEGIN
     SET @Lc_ActionType_CODE = @Lc_ActionDelete_CODE;
     SET @Lc_PscrmTypeAction_CODE = @Lc_ActionDelete_CODE;
    END

   SET @Lc_PscrmCaseRelationship_CODE = @Lc_CmemCaseRelationship_CODE;
   SET @Lc_PscrmRec_ID = @Lc_RecPerson_ID;
   SET @Ln_PscrmCase_IDNO = @Ln_InputCase_IDNO;
   SET @Lc_PscrmUserField_NAME = CONVERT(VARCHAR(8), @Ld_Run_DATE, 112);
   SET @Lc_PscrmReservedFcr_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmCountyFips_CODE = @Lc_CaseCountyFips_CODE;
   SET @Lc_PscrmTypeLocReq_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmBundleResults_INDC = @Lc_No_INDC;
   --Derive Relation case of member
   SET @Ls_Sql_TEXT = 'DERIVE CASE RELATION';

   IF @Lc_CmemCaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
    BEGIN
     SET @Lc_PscrmTypeParticipant_CODE = @Lc_FcrParticipantDp_CODE;
    END
   ELSE IF @Lc_CmemCaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
    BEGIN
     SET @Lc_PscrmTypeParticipant_CODE = @Lc_FcrParticipantCp_CODE;
    END
   ELSE IF @Lc_CmemCaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
    BEGIN
     SET @Lc_PscrmTypeParticipant_CODE = @Lc_FcrParticipantNcp_CODE;
    END
   ELSE IF @Lc_CmemCaseRelationship_CODE = @Lc_CaseRelationshipPf_CODE
    BEGIN
     SET @Lc_PscrmTypeParticipant_CODE = @Lc_FcrParticipantPf_CODE;
    END

   --check for Family violence
   SET @Ls_Sql_TEXT = 'CHECK FOR FAMILY VIOLENCE';

   IF @Lc_PscrmTypeParticipant_CODE IN (@Lc_FcrParticipantDp_CODE, @Lc_FcrParticipantCp_CODE)
    BEGIN
     IF @Lc_DemoFv_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Lc_PscrmFamilyViolence_CODE = @Lc_EfmemFamilyViolence_CODE;
      END
     ELSE
      BEGIN
       SET @Lc_PscrmFamilyViolence_CODE = @Lc_Space_TEXT;
      END
    END
   ELSE
    BEGIN
     SET @Lc_PscrmFamilyViolence_CODE = @Lc_Space_TEXT;
    END

   /* Locate Member 
   Transaction type is member locate
   */
   IF @Ac_Process_INDC = @Lc_PersonLocProcessFlag_INDC
    BEGIN
     SET @Lc_ActionType_CODE = @Lc_ActionLocate_CODE;
     SET @Lc_PscrmTypeAction_CODE = @Lc_ActionLocate_CODE;
     SET @Lc_PscrmFamilyViolence_CODE = @Lc_Space_TEXT;
    END

   --Gender
   SET @Ls_Sql_TEXT = 'CHECK AND SET MEMBER GENDER';

   IF @Lc_DemoMemberSex_CODE = @Lc_SexUnknown_CODE
    BEGIN
     SET @Lc_PscrmMemberSex_CODE = @Lc_Space_TEXT;
    END
   ELSE
    BEGIN
     SET @Lc_PscrmMemberSex_CODE = @Lc_DemoMemberSex_CODE;
    END

   --Date of birth 
   SET @Ls_Sql_TEXT = 'CHECK AND SET MEMBER DOB';

   IF ISNULL(@Ld_DemoBirth_DATE, '') = '1900-01-01'
       OR @Ld_DemoBirth_DATE = @Ld_High_DATE
    BEGIN
     SET @Ld_PscrmBirth_DATE = @Ld_Low_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_PscrmBirth_DATE = @Ld_DemoBirth_DATE;
    END

   SET @Ln_PscrmPreviousMemberSsn_NUMB = @Lc_StringZero_TEXT;
   SET @Ls_Sql_TEXT = 'BIRTH CITY';
   SET @Lc_PscrmBirthCity_NAME = UPPER(@Lc_DemoBirthCity_ADDR);
   SET @Ls_Sql_TEXT = 'BIRTH STATE AND COUNTRY';

   IF @Lc_DemoBirthCountry_CODE = @Lc_CountryUs_CODE
    BEGIN
     SET @Lc_PscrmBirthState_CODE = UPPER(@Lc_DemoBirthState_CODE);
     SET @Lc_PscrmBirthCountry_CODE = @Lc_Space_TEXT;
    END
   ELSE IF (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Lc_DemoBirthState_CODE) IS NOT NULL
       AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Lc_DemoBirthCountry_CODE) IS NOT NULL
       AND @Lc_DemoBirthCountry_CODE <> @Lc_CountryUs_CODE)
    BEGIN
     SET @Lc_PscrmBirthState_CODE = @Lc_DemoBirthCountry_CODE;
     SET @Lc_PscrmBirthCountry_CODE = @Lc_Star_CODE;
    END
   ELSE IF (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Lc_DemoBirthState_CODE) IS NULL
       AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Lc_DemoBirthCountry_CODE) IS NOT NULL
       AND @Lc_DemoBirthCountry_CODE <> @Lc_CountryUs_CODE)
    BEGIN
     SET @Lc_PscrmBirthState_CODE = @Lc_DemoBirthCountry_CODE;
     SET @Lc_PscrmBirthCountry_CODE = @Lc_Star_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_PscrmBirthState_CODE = UPPER(@Lc_DemoBirthState_CODE);
     SET @Lc_PscrmBirthCountry_CODE = @Lc_Space_TEXT;
    END

   SET @Ls_Sql_TEXT = 'FATHER NAME';
   SET @Lc_PscrmFirstFather_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmLastFather_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmMiddleFather_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmFirstMother_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmLastMother_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmMiddleMother_NAME = @Lc_Space_TEXT;
   SET @Ln_PscrmIrsUsedMemberSsn_NUMB = @Lc_StringZero_TEXT;
   SET @Ls_Sql_TEXT = 'BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME - 1';
   SET @Lc_PscrmFirst_NAME = dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_DemoFirst_NAME);
   SET @Lc_PscrmFirst_NAME = REPLACE(@Lc_PscrmFirst_NAME, @Lc_Hyphen_TEXT, @Lc_Null_TEXT);
   SET @Lc_PscrmLast_NAME = dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_DemoLast_NAME);
   --Get first 16 characters of member middle name to write in Extract file
   SET @Lc_PscrmMiddle_NAME = SUBSTRING(@Lc_DemoMiddle_NAME, 1, 16);
   SET @Ln_AkaxMemberMci_IDNO = @Ln_DemoMemberMci_IDNO;
   --akax cursor to select member alias names  
   SET @Ls_Sql_TEXT = 'DECLARE Akax_CUR';

   DECLARE Akax_CUR INSENSITIVE CURSOR FOR
    SELECT A.LastAlias_NAME,
           A.FirstAlias_NAME,
           A.MiddleAlias_NAME,
           A.BeginValidity_DATE
      FROM AKAX_Y1 A
     WHERE A.MemberMci_IDNO = @Ln_AkaxMemberMci_IDNO
       AND A.EndValidity_DATE = @Ld_High_DATE
     ORDER BY A.BeginValidity_DATE DESC;

   SET @Ls_Sql_TEXT = 'OPEN Akax_CUR';

   OPEN Akax_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Akax_CUR - 1';

   FETCH NEXT FROM Akax_CUR INTO @Lc_AkaxCur_LastAlias_NAME, @Lc_AkaxCur_FirstAlias_NAME, @Lc_AkaxCur_MiddleAlias_NAME, @Ld_AkaxCur_BeginValidity_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Akax_CUR';
   SET @Lc_PscrmFirstAdditional1_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmLastAdditional1_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmMiddleAdditional1_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmFirstAdditional2_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmLastAdditional2_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmMiddleAdditional2_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmFirstAdditional3_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmLastAdditional3_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmMiddleAdditional3_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmFirstAdditional4_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmLastAdditional4_NAME = @Lc_Space_TEXT;
   SET @Lc_PscrmMiddleAdditional4_NAME = @Lc_Space_TEXT;
   SET @Ln_AkaxCount_QNTY = 1;

   --set member alias names
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     IF @Lc_AkaxCur_LastAlias_NAME = @Lc_DemoLast_NAME
        AND @Lc_AkaxCur_FirstAlias_NAME = @Lc_DemoFirst_NAME
        AND @Lc_AkaxCur_MiddleAlias_NAME = @Lc_DemoMiddle_NAME
      BEGIN
       SET @Ln_AkaxPrevCount_QNTY = @Ln_AkaxCount_QNTY;
       SET @Ln_AkaxCount_QNTY = 0;
      END

     IF @Ln_AkaxCount_QNTY = 1
      BEGIN
       SET @Lc_PscrmFirstAdditional1_NAME = dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_FirstAlias_NAME);
       SET @Lc_PscrmFirstAdditional1_NAME = ISNULL(REPLACE(@Lc_PscrmFirstAdditional1_NAME, @Lc_Hyphen_TEXT, @Lc_Null_TEXT), @Lc_Space_TEXT);
       SET @Lc_PscrmLastAdditional1_NAME = ISNULL(dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_LastAlias_NAME), @Lc_Space_TEXT);
       SET @Lc_PscrmMiddleAdditional1_NAME = ISNULL(SUBSTRING(@Lc_AkaxCur_MiddleAlias_NAME, 1, 16), @Lc_Space_TEXT);
      END

     IF @Ln_AkaxCount_QNTY = 2
      BEGIN
       SET @Lc_PscrmFirstAdditional2_NAME = dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_FirstAlias_NAME);
       SET @Lc_PscrmFirstAdditional2_NAME = ISNULL(REPLACE(@Lc_PscrmFirstAdditional2_NAME, @Lc_Hyphen_TEXT, @Lc_Null_TEXT), @Lc_Space_TEXT);
       SET @Lc_PscrmLastAdditional2_NAME = ISNULL(dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_LastAlias_NAME), @Lc_Space_TEXT);
       SET @Lc_PscrmMiddleAdditional2_NAME = ISNULL(SUBSTRING(@Lc_AkaxCur_MiddleAlias_NAME, 1, 16), @Lc_Space_TEXT);
      END

     IF @Ln_AkaxCount_QNTY = 3
      BEGIN
       SET @Lc_PscrmFirstAdditional3_NAME = dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_FirstAlias_NAME);
       SET @Lc_PscrmFirstAdditional3_NAME = ISNULL(REPLACE(@Lc_PscrmFirstAdditional3_NAME, @Lc_Hyphen_TEXT, @Lc_Null_TEXT), @Lc_Space_TEXT);
       SET @Lc_PscrmLastAdditional3_NAME = ISNULL(dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_LastAlias_NAME), @Lc_Space_TEXT);
       SET @Lc_PscrmMiddleAdditional3_NAME = ISNULL(SUBSTRING(@Lc_AkaxCur_MiddleAlias_NAME, 1, 16), @Lc_Space_TEXT);
      END

     IF @Ln_AkaxCount_QNTY = 4
      BEGIN
       SET @Lc_PscrmFirstAdditional4_NAME = dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_FirstAlias_NAME);
       SET @Lc_PscrmFirstAdditional4_NAME = ISNULL(REPLACE(@Lc_PscrmFirstAdditional4_NAME, @Lc_Hyphen_TEXT, @Lc_Null_TEXT), @Lc_Space_TEXT);
       SET @Lc_PscrmLastAdditional4_NAME = ISNULL(dbo.BATCH_LOC_OUTGOING_FCR$SF_VALIDATE_NAME(@Lc_AkaxCur_LastAlias_NAME), @Lc_Space_TEXT);
       SET @Lc_PscrmMiddleAdditional4_NAME = ISNULL(SUBSTRING(@Lc_AkaxCur_MiddleAlias_NAME, 1, 16), @Lc_Space_TEXT);
      END

     IF @Ln_AkaxCount_QNTY <> 0
      BEGIN
       SET @Ln_AkaxCount_QNTY = @Ln_AkaxCount_QNTY + 1;
      END
     ELSE
      BEGIN
       SET @Ln_AkaxCount_QNTY = @Ln_AkaxPrevCount_QNTY;
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Akax_CUR - 2';

     FETCH NEXT FROM Akax_CUR INTO @Lc_AkaxCur_LastAlias_NAME, @Lc_AkaxCur_FirstAlias_NAME, @Lc_AkaxCur_MiddleAlias_NAME, @Ld_AkaxCur_BeginValidity_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'Akax_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE Akax_CUR';

     CLOSE Akax_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Akax_CUR';

     DEALLOCATE Akax_CUR;
    END

   SET @Ln_PscrmMemberSsn_NUMB = @Lc_StringZero_TEXT;
   SET @Ln_PscrmMemberAdditional1Ssn_NUMB = @Lc_StringZero_TEXT;
   SET @Ln_PscrmMemberAdditional2Ssn_NUMB = @Lc_StringZero_TEXT;

   --Member Delete Transaction for Locate Member
   IF @Ac_TransType_CODE = @Lc_TransTypePersonDelete_CODE
    BEGIN
     SET @Ln_PscrmMemberAdditional1Ssn_NUMB = @Lc_StringZero_TEXT;
     SET @Ln_PscrmMemberAdditional2Ssn_NUMB = @Lc_StringZero_TEXT;
    END
   ELSE
    BEGIN
     --mssn cursor to select member ssn details. 
     SET @Ls_Sql_TEXT = 'DECLARE Mssn_CUR';

     DECLARE Mssn_CUR INSENSITIVE CURSOR FOR
      SELECT A.MemberSsn_NUMB,
             A.TypePrimary_CODE,
             CASE A.SourceVerify_CODE
              WHEN 'F' --To indicate SSN verification source FCR
               THEN 1
              WHEN 'S' --To indicate SSN verification source SSA
               THEN 2
              WHEN 'T' --To indicate SSN verification source Testimony
               THEN 3
              ELSE 4
             END AS SourceVerify_CODE
        FROM MSSN_Y1 A
       WHERE A.MemberMci_IDNO = @Ln_DemoMemberMci_IDNO
         AND A.Enumeration_CODE IN ('Y', 'P')
         AND A.TypePrimary_CODE <> 'I'
         AND A.MemberSsn_NUMB NOT IN (0, 999999999)
         AND A.EndValidity_DATE = @Ld_High_DATE
       ORDER BY A.Enumeration_CODE DESC,
                A.TypePrimary_CODE,
                SourceVerify_CODE;

     SET @Ls_Sql_TEXT = 'OPEN Mssn_CUR';

     OPEN Mssn_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Mssn_CUR - 1';

     FETCH NEXT FROM Mssn_CUR INTO @Ln_MssnCur_Ssn_NUMB, @Lc_MssnCur_TypePrimary_CODE, @Ln_MssnCur_SourceVerify_CODE;

     SET @Ln_PscrmMemberSsn_NUMB = @Lc_StringZero_TEXT;
     SET @Ln_PscrmMemberAdditional1Ssn_NUMB = @Lc_StringZero_TEXT;
     SET @Ln_PscrmMemberAdditional2Ssn_NUMB = @Lc_StringZero_TEXT;
     SET @Ln_MssnCount_QNTY = 1;
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH Mssn_CUR';

     --set member ssn details  
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       IF @Ln_MssnCount_QNTY = 1
        BEGIN
         SET @Ln_PscrmMemberSsn_NUMB = @Ln_MssnCur_Ssn_NUMB;
        END

       IF @Ln_MssnCount_QNTY = 2
        BEGIN
         SET @Ln_PscrmMemberAdditional1Ssn_NUMB = @Ln_MssnCur_Ssn_NUMB;
        END

       IF @Ln_MssnCount_QNTY = 3
        BEGIN
         SET @Ln_PscrmMemberAdditional2Ssn_NUMB = @Ln_MssnCur_Ssn_NUMB;
        END

       SET @Ln_MssnCount_QNTY = @Ln_MssnCount_QNTY + 1;
       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Mssn_CUR - 2';

       FETCH NEXT FROM Mssn_CUR INTO @Ln_MssnCur_Ssn_NUMB, @Lc_MssnCur_TypePrimary_CODE, @Ln_MssnCur_SourceVerify_CODE;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     IF CURSOR_STATUS('LOCAL', 'Mssn_CUR') IN (0, 1)
      BEGIN
       SET @Ls_Sql_TEXT = 'CLOSE Mssn_CUR';

       CLOSE Mssn_CUR;

       SET @Ls_Sql_TEXT = 'DEALLOCATE Mssn_CUR';

       DEALLOCATE Mssn_CUR;
      END
    END

   SET @Lc_PscrmIrs1099_INDC = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc1_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc2_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc3_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc4_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc5_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc6_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc7_CODE = @Lc_Space_TEXT;
   SET @Lc_PscrmSourceLoc8_CODE = @Lc_Space_TEXT;

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ln_PscrmMemberSsn_NUMB) IS NULL
      AND @Lc_PscrmTypeParticipant_CODE IN (@Lc_FcrParticipantPf_CODE, @Lc_FcrParticipantNcp_CODE)
      AND @Lc_PscrmTypeAction_CODE = @Lc_ActionAdd_CODE
    BEGIN
     --Get member ssn for CP
     SET @Ls_Sql_TEXT = 'GET SSN FOR CP';
     SET @Ln_PscrmIrsUsedMemberSsn_NUMB = (SELECT TOP 1 b.MemberSsn_NUMB
                                             FROM CMEM_Y1 a,
                                                  MSSN_Y1 b
                                            WHERE a.Case_IDNO = @Ln_InputCase_IDNO
                                              AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                                              AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                              AND a.MemberMci_IDNO = b.MemberMci_IDNO
                                              AND b.EndValidity_DATE = @Ld_High_DATE);
     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ln_PscrmIrsUsedMemberSsn_NUMB = @Lc_StringZero_TEXT;
      END
    END

   --validate  member ssn, dob, irs used member ssn
   SET @Ls_Sql_TEXT = 'VALIDATE MEMBER SSN, DOB, IRS USED MEMBER SSN';

   IF ((@Ln_PscrmMemberSsn_NUMB = @Lc_StringZero_TEXT)
       AND (@Ld_PscrmBirth_DATE = @Ld_Low_DATE)
       AND (@Ln_PscrmIrsUsedMemberSsn_NUMB = @Lc_StringZero_TEXT))
    BEGIN
     --Participant DT_BIRTH/SSN/IRS-U info missing
     SET @Lc_SkipRecord_INDC = 'Y';
     SET @Ls_ErrorMessage_TEXT = 'PARTICIPANT DT_BIRTH/SSN/IRS-U INFO MISSING';

     RAISERROR(50001,16,1);
    END

   --Validate first name
   SET @Ls_Sql_TEXT = 'VALIDATE FIRST NAME';

   IF @Lc_PscrmFirst_NAME IS NULL
    BEGIN
     --Participant first name is missing
     SET @Lc_SkipRecord_INDC = 'Y';
     SET @Ls_ErrorMessage_TEXT = 'PARTICIPANT FIRST NAME IS MISSING';

     RAISERROR(50001,16,1);
    END

   --Validate last name
   SET @Ls_Sql_TEXT = 'VALIDATE LAST NAME';

   IF @Lc_PscrmLast_NAME IS NULL
    BEGIN
     --Participant last name is missing
     SET @Lc_SkipRecord_INDC = 'Y';
     SET @Ls_ErrorMessage_TEXT = 'PARTICIPANT LAST NAME IS MISSING';

     RAISERROR(50001,16,1);
    END

   --Validate member sex 
   SET @Ls_Sql_TEXT = 'VALIDATE MEMBER SEX';

   IF @Lc_PscrmMemberSex_CODE NOT IN (@Lc_SexMale_CODE, @Lc_SexFemale_CODE, @Lc_Space_TEXT)
    BEGIN
     --MEM SEX code is invalid
     SET @Lc_SkipRecord_INDC = 'Y';
     SET @Ls_ErrorMessage_TEXT = 'MEM SEX CODE IS INVALID';

     RAISERROR(50001,16,1);
    END

   --Transaction from Case Add Process
   IF @Ac_Process_INDC = @Lc_CaseProcessFlag_INDC
    BEGIN
     --Insert into PSCRM
     SET @Ls_Sql_TEXT = 'INSERT INTO PSCRM_Y1';
     SET @Ls_SqlData_TEXT = 'CaseRelationship_CODE = ' + ISNULL(@Lc_PscrmCaseRelationship_CODE, '') + ', Rec_ID = ' + ISNULL(@Lc_PscrmRec_ID, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_PscrmTypeAction_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_PscrmCase_IDNO AS VARCHAR), '') + ', ReservedFcr_CODE = ' + ISNULL(@Lc_PscrmReservedFcr_CODE, '') + ', UserField_NAME = ' + ISNULL(@Lc_PscrmUserField_NAME, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_PscrmCountyFips_CODE, '') + ', TypeLocReq_CODE = ' + ISNULL(@Lc_PscrmTypeLocReq_CODE, '') + ', BundleResults_INDC = ' + ISNULL(@Lc_PscrmBundleResults_INDC, '') + ', TypeParticipant_CODE = ' + ISNULL(@Lc_PscrmTypeParticipant_CODE, '') + ', FamilyViolence_CODE = ' + ISNULL(@Lc_PscrmFamilyViolence_CODE, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrmMemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_PscrmMemberSsn_NUMB AS VARCHAR), '') + ', PreviousMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_PscrmPreviousMemberSsn_NUMB AS VARCHAR), '') + ', First_NAME = ' + ISNULL(@Lc_PscrmFirst_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_PscrmMiddle_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_PscrmLast_NAME, '') + ', BirthCity_NAME = ' + ISNULL(@Lc_PscrmBirthCity_NAME, '') + ', BirthState_CODE = ' + ISNULL(@Lc_PscrmBirthState_CODE, '') + ', BirthCountry_CODE = ' + ISNULL(@Lc_PscrmBirthCountry_CODE, '') + ', FirstFather_NAME = ' + ISNULL(@Lc_PscrmFirstFather_NAME, '') + ', MiddleFather_NAME = ' + ISNULL(@Lc_PscrmMiddleFather_NAME, '') + ', LastFather_NAME = ' + ISNULL(@Lc_PscrmLastFather_NAME, '') + ', FirstMother_NAME = ' + ISNULL(@Lc_PscrmFirstMother_NAME, '') + ', MiddleMother_NAME = ' + ISNULL(@Lc_PscrmMiddleMother_NAME, '') + ', LastMother_NAME = ' + ISNULL(@Lc_PscrmLastMother_NAME, '') + ', IrsUsedMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_PscrmIrsUsedMemberSsn_NUMB AS VARCHAR), '') + ', MemberAdditional1Ssn_NUMB = ' + ISNULL(CAST(@Ln_PscrmMemberAdditional1Ssn_NUMB AS VARCHAR), '') + ', MemberAdditional2Ssn_NUMB = ' + ISNULL(CAST(@Ln_PscrmMemberAdditional2Ssn_NUMB AS VARCHAR), '') + ', FirstAdditional1_NAME = ' + ISNULL(@Lc_PscrmFirstAdditional1_NAME, '') + ', MiddleAdditional1_NAME = ' + ISNULL(@Lc_PscrmMiddleAdditional1_NAME, '') + ', LastAdditional1_NAME = ' + ISNULL(@Lc_PscrmLastAdditional1_NAME, '') + ', FirstAdditional2_NAME = ' + ISNULL(@Lc_PscrmFirstAdditional2_NAME, '') + ', MiddleAdditional2_NAME = ' + ISNULL(@Lc_PscrmMiddleAdditional2_NAME, '') + ', LastAdditional2_NAME = ' + ISNULL(@Lc_PscrmLastAdditional2_NAME, '') + ', FirstAdditional3_NAME = ' + ISNULL(@Lc_PscrmFirstAdditional3_NAME, '') + ', MiddleAdditional3_NAME = ' + ISNULL(@Lc_PscrmMiddleAdditional3_NAME, '') + ', LastAdditional3_NAME = ' + ISNULL(@Lc_PscrmLastAdditional3_NAME, '') + ', FirstAdditional4_NAME = ' + ISNULL(@Lc_PscrmFirstAdditional4_NAME, '') + ', MiddleAdditional4_NAME = ' + ISNULL(@Lc_PscrmMiddleAdditional4_NAME, '') + ', LastAdditional4_NAME = ' + ISNULL(@Lc_PscrmLastAdditional4_NAME, '') + ', NewMemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrmNewMemberMci_IDNO AS VARCHAR), '') + ', Irs1099_INDC = ' + ISNULL(@Lc_PscrmIrs1099_INDC, '') + ', SourceLoc1_CODE = ' + ISNULL(@Lc_PscrmSourceLoc1_CODE, '') + ', SourceLoc2_CODE = ' + ISNULL(@Lc_PscrmSourceLoc2_CODE, '') + ', SourceLoc3_CODE = ' + ISNULL(@Lc_PscrmSourceLoc3_CODE, '') + ', SourceLoc4_CODE = ' + ISNULL(@Lc_PscrmSourceLoc4_CODE, '') + ', SourceLoc5_CODE = ' + ISNULL(@Lc_PscrmSourceLoc5_CODE, '') + ', SourceLoc6_CODE = ' + ISNULL(@Lc_PscrmSourceLoc6_CODE, '') + ', SourceLoc7_CODE = ' + ISNULL(@Lc_PscrmSourceLoc7_CODE, '') + ', SourceLoc8_CODE = ' + ISNULL(@Lc_PscrmSourceLoc8_CODE, '') + ', ChildNotPassed_INDC = ' + ISNULL(@Lc_No_INDC, '');

     INSERT PSCRM_Y1
            (CaseRelationship_CODE,
             Rec_ID,
             TypeAction_CODE,
             Case_IDNO,
             ReservedFcr_CODE,
             UserField_NAME,
             CountyFips_CODE,
             TypeLocReq_CODE,
             BundleResults_INDC,
             TypeParticipant_CODE,
             FamilyViolence_CODE,
             MemberMci_IDNO,
             MemberSex_CODE,
             Birth_DATE,
             MemberSsn_NUMB,
             PreviousMemberSsn_NUMB,
             First_NAME,
             Middle_NAME,
             Last_NAME,
             BirthCity_NAME,
             BirthState_CODE,
             BirthCountry_CODE,
             FirstFather_NAME,
             MiddleFather_NAME,
             LastFather_NAME,
             FirstMother_NAME,
             MiddleMother_NAME,
             LastMother_NAME,
             IrsUsedMemberSsn_NUMB,
             MemberAdditional1Ssn_NUMB,
             MemberAdditional2Ssn_NUMB,
             FirstAdditional1_NAME,
             MiddleAdditional1_NAME,
             LastAdditional1_NAME,
             FirstAdditional2_NAME,
             MiddleAdditional2_NAME,
             LastAdditional2_NAME,
             FirstAdditional3_NAME,
             MiddleAdditional3_NAME,
             LastAdditional3_NAME,
             FirstAdditional4_NAME,
             MiddleAdditional4_NAME,
             LastAdditional4_NAME,
             NewMemberMci_IDNO,
             Irs1099_INDC,
             SourceLoc1_CODE,
             SourceLoc2_CODE,
             SourceLoc3_CODE,
             SourceLoc4_CODE,
             SourceLoc5_CODE,
             SourceLoc6_CODE,
             SourceLoc7_CODE,
             SourceLoc8_CODE,
             ChildNotPassed_INDC)
     SELECT @Lc_PscrmCaseRelationship_CODE AS CaseRelationship_CODE,
            @Lc_PscrmRec_ID AS Rec_ID,
            @Lc_PscrmTypeAction_CODE AS TypeAction_CODE,
            @Ln_PscrmCase_IDNO AS Case_IDNO,
            @Lc_PscrmReservedFcr_CODE AS ReservedFcr_CODE,
            @Lc_PscrmUserField_NAME AS UserField_NAME,
            @Lc_PscrmCountyFips_CODE AS CountyFips_CODE,
            @Lc_PscrmTypeLocReq_CODE AS TypeLocReq_CODE,
            @Lc_PscrmBundleResults_INDC AS BundleResults_INDC,
            @Lc_PscrmTypeParticipant_CODE AS TypeParticipant_CODE,
            @Lc_PscrmFamilyViolence_CODE AS FamilyViolence_CODE,
            @Ln_PscrmMemberMci_IDNO AS MemberMci_IDNO,
            ISNULL(@Lc_PscrmMemberSex_CODE, '') AS MemberSex_CODE,
            CONVERT(CHAR(8), @Ld_PscrmBirth_DATE, 112) AS Birth_DATE,
            @Ln_PscrmMemberSsn_NUMB AS MemberSsn_NUMB,
            @Ln_PscrmPreviousMemberSsn_NUMB AS PreviousMemberSsn_NUMB,
            @Lc_PscrmFirst_NAME AS First_NAME,
            @Lc_PscrmMiddle_NAME AS Middle_NAME,
            @Lc_PscrmLast_NAME AS Last_NAME,
            @Lc_PscrmBirthCity_NAME AS BirthCity_NAME,
            @Lc_PscrmBirthState_CODE AS BirthState_CODE,
            @Lc_PscrmBirthCountry_CODE AS BirthCountry_CODE,
            @Lc_PscrmFirstFather_NAME AS FirstFather_NAME,
            @Lc_PscrmMiddleFather_NAME AS MiddleFather_NAME,
            @Lc_PscrmLastFather_NAME AS LastFather_NAME,
            @Lc_PscrmFirstMother_NAME AS FirstMother_NAME,
            @Lc_PscrmMiddleMother_NAME AS MiddleMother_NAME,
            @Lc_PscrmLastMother_NAME AS LastMother_NAME,
            @Ln_PscrmIrsUsedMemberSsn_NUMB AS IrsUsedMemberSsn_NUMB,
            @Ln_PscrmMemberAdditional1Ssn_NUMB AS MemberAdditional1Ssn_NUMB,
            @Ln_PscrmMemberAdditional2Ssn_NUMB AS MemberAdditional2Ssn_NUMB,
            @Lc_PscrmFirstAdditional1_NAME AS FirstAdditional1_NAME,
            @Lc_PscrmMiddleAdditional1_NAME AS MiddleAdditional1_NAME,
            @Lc_PscrmLastAdditional1_NAME AS LastAdditional1_NAME,
            @Lc_PscrmFirstAdditional2_NAME AS FirstAdditional2_NAME,
            @Lc_PscrmMiddleAdditional2_NAME AS MiddleAdditional2_NAME,
            @Lc_PscrmLastAdditional2_NAME AS LastAdditional2_NAME,
            @Lc_PscrmFirstAdditional3_NAME AS FirstAdditional3_NAME,
            @Lc_PscrmMiddleAdditional3_NAME AS MiddleAdditional3_NAME,
            @Lc_PscrmLastAdditional3_NAME AS LastAdditional3_NAME,
            @Lc_PscrmFirstAdditional4_NAME AS FirstAdditional4_NAME,
            @Lc_PscrmMiddleAdditional4_NAME AS MiddleAdditional4_NAME,
            @Lc_PscrmLastAdditional4_NAME AS LastAdditional4_NAME,
            @Ln_PscrmNewMemberMci_IDNO AS NewMemberMci_IDNO,
            @Lc_PscrmIrs1099_INDC AS Irs1099_INDC,
            @Lc_PscrmSourceLoc1_CODE AS SourceLoc1_CODE,
            @Lc_PscrmSourceLoc2_CODE AS SourceLoc2_CODE,
            @Lc_PscrmSourceLoc3_CODE AS SourceLoc3_CODE,
            @Lc_PscrmSourceLoc4_CODE AS SourceLoc4_CODE,
            @Lc_PscrmSourceLoc5_CODE AS SourceLoc5_CODE,
            @Lc_PscrmSourceLoc6_CODE AS SourceLoc6_CODE,
            @Lc_PscrmSourceLoc7_CODE AS SourceLoc7_CODE,
            @Lc_PscrmSourceLoc8_CODE AS SourceLoc8_CODE,
            @Lc_No_INDC AS ChildNotPassed_INDC;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO PSCRM_Y1 FAILED';

       RAISERROR(50001,16,1);
      END
    END
   --Get member details for existing case 
   ELSE
    BEGIN
     SET @Lc_EfmemRec_ID = @Lc_PscrmRec_ID;
     SET @Lc_EfmemTypeAction_CODE = @Lc_ActionType_CODE;
     SET @Lc_EfmemCase_IDNO = @Ln_PscrmCase_IDNO;
     SET @Lc_EfmemReservedFcr_CODE = @Lc_PscrmReservedFcr_CODE;
     SET @Lc_EfmemUserField_NAME = @Lc_PscrmUserField_NAME;
     SET @Lc_EfmemCountyFips_CODE = @Lc_PscrmCountyFips_CODE;
     SET @Lc_EfmemTypeLocReq_CODE = @Lc_PscrmTypeLocReq_CODE;
     SET @Lc_EfmemBundleResults_INDC = @Lc_PscrmBundleResults_INDC;
     SET @Lc_EfmemTypeParticipant_CODE = @Lc_PscrmTypeParticipant_CODE;
     SET @Lc_EfmemFamilyViolence_CODE = @Lc_PscrmFamilyViolence_CODE;
     SET @Lc_EfmemMemberMci_IDNO = @Ln_PscrmMemberMci_IDNO;
     SET @Lc_EfmemMemberSex_CODE = @Lc_PscrmMemberSex_CODE;
     SET @Lc_EfmemBirth_DATE = CONVERT(VARCHAR(8), @Ld_PscrmBirth_DATE, 112);
     SET @Lc_EfmemMemberSsn_NUMB = @Ln_PscrmMemberSsn_NUMB;
     SET @Lc_EfmemPreviousMemberSsn_NUMB = @Ln_PscrmPreviousMemberSsn_NUMB;

     IF @Lc_ActionType_CODE = @Lc_ActionChange_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT PREVIOUS SSN FROM FADT_Y1';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PscrmCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrmMemberMci_IDNO AS VARCHAR), '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecPerson_ID, '');

       SELECT @Lc_EfmemPreviousMemberSsn_NUMB = a.MemberSsn_NUMB
         FROM FADT_Y1 a
        WHERE a.Case_IDNO = @Ln_PscrmCase_IDNO
          AND a.MemberMci_IDNO = @Ln_PscrmMemberMci_IDNO
          AND a.MemberSsn_NUMB <> @Ln_PscrmMemberSsn_NUMB
          AND a.TypeTrans_CODE = @Lc_RecPerson_ID;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Lc_EfmemPreviousMemberSsn_NUMB = @Lc_StringZero_TEXT;
        END
      END

     SET @Lc_EfmemFirst_NAME = @Lc_PscrmFirst_NAME;
     SET @Lc_EfmemMiddle_NAME = @Lc_PscrmMiddle_NAME;
     SET @Lc_EfmemLast_NAME = @Lc_PscrmLast_NAME;
     SET @Lc_EfmemCityBirth_NAME = @Lc_PscrmBirthCity_NAME;
     SET @Lc_EfmemStCountryBirth_CODE = ISNULL(@Lc_PscrmBirthState_CODE, '') + ISNULL(@Lc_PscrmBirthCountry_CODE, '');
     SET @Lc_EfmemFirstFather_NAME = @Lc_PscrmFirstFather_NAME;
     SET @Lc_EfmemMiddleFather_NAME = @Lc_PscrmMiddleFather_NAME;
     SET @Lc_EfmemLastFather_NAME = @Lc_PscrmLastFather_NAME;
     SET @Lc_EfmemFirstMother_NAME = @Lc_PscrmFirstMother_NAME;
     SET @Lc_EfmemMiddleMother_NAME = @Lc_PscrmMiddleMother_NAME;
     SET @Lc_EfmemLastMother_NAME = @Lc_PscrmLastMother_NAME;
     SET @Lc_EfmemIrsUsedMemberSsn_NUMB = @Ln_PscrmIrsUsedMemberSsn_NUMB;
     SET @Lc_EfmemMemberAdditional1Ssn_NUMB = @Ln_PscrmMemberAdditional1Ssn_NUMB;
     SET @Lc_EfmemMemberAdditional2Ssn_NUMB = @Ln_PscrmMemberAdditional2Ssn_NUMB;
     SET @Lc_EfmemFirstAdditional1_NAME = @Lc_PscrmFirstAdditional1_NAME;
     SET @Lc_EfmemMiddleAdditional1_NAME = @Lc_PscrmMiddleAdditional1_NAME;
     SET @Lc_EfmemLastAdditional1_NAME = @Lc_PscrmLastAdditional1_NAME;
     SET @Lc_EfmemFirstAdditional2_NAME = @Lc_PscrmFirstAdditional2_NAME;
     SET @Lc_EfmemMiddleAdditional2_NAME = @Lc_PscrmMiddleAdditional2_NAME;
     SET @Lc_EfmemLastAdditional2_NAME = @Lc_PscrmLastAdditional2_NAME;
     SET @Lc_EfmemFirstAdditional3_NAME = @Lc_PscrmFirstAdditional3_NAME;
     SET @Lc_EfmemMiddleAdditional3_NAME = @Lc_PscrmMiddleAdditional3_NAME;
     SET @Lc_EfmemLastAdditional3_NAME = @Lc_PscrmLastAdditional3_NAME;
     SET @Lc_EfmemFirstAdditional4_NAME = @Lc_PscrmFirstAdditional4_NAME;
     SET @Lc_EfmemMiddleAdditional4_NAME = @Lc_PscrmMiddleAdditional4_NAME;
     SET @Lc_EfmemLastAdditional4_NAME = @Lc_PscrmLastAdditional4_NAME;
     SET @Lc_EfmemNewMemberMci_IDNO = @Ln_PscrmNewMemberMci_IDNO;
     SET @Lc_EfmemIrs1099_INDC = @Lc_PscrmIrs1099_INDC;
     SET @Lc_EfmemLocateSource1_CODE = @Lc_PscrmSourceLoc1_CODE;
     SET @Lc_EfmemLocateSource2_CODE = @Lc_PscrmSourceLoc2_CODE;
     SET @Lc_EfmemLocateSource3_CODE = @Lc_PscrmSourceLoc3_CODE;
     SET @Lc_EfmemLocateSource4_CODE = @Lc_PscrmSourceLoc4_CODE;
     SET @Lc_EfmemLocateSource5_CODE = @Lc_PscrmSourceLoc5_CODE;
     SET @Lc_EfmemLocateSource6_CODE = @Lc_PscrmSourceLoc6_CODE;
     SET @Lc_EfmemLocateSource7_CODE = @Lc_PscrmSourceLoc7_CODE;
     SET @Lc_EfmemLocateSource8_CODE = @Lc_PscrmSourceLoc8_CODE;

     IF @Lc_EfmemTypeParticipant_CODE IN (@Lc_FcrParticipantNcp_CODE, @Lc_FcrParticipantPf_CODE)
        AND @Lc_CaseTypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE
        AND @Lc_CaseStatusCase_CODE = @Lc_CaseStatusOpen_CODE
      BEGIN
       SET @Ln_Exists_NUMB = 0;
       SET @Ls_Sql_TEXT = 'CHECK 1 FOR NCP/PF IN LSTT_Y1';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_EfmemMemberMci_IDNO, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusVerified_CODE, '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusVerified_CODE, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM LSTT_Y1 a
        WHERE a.MemberMci_IDNO = @Lc_EfmemMemberMci_IDNO
          AND a.StatusLocate_CODE <> @Lc_LocateStatusLocated_CODE
          AND a.EndValidity_DATE = @Ld_High_DATE
          AND NOT EXISTS (SELECT 1
                            FROM AHIS_Y1 b
                           WHERE b.MemberMci_IDNO = @Ln_DemoMemberMci_IDNO
                             AND b.TypeAddress_CODE IN (@Lc_Mailing_ADDR, @Lc_Residential_ADDR, @Lc_ResidentialSecondary_ADDR)
                             AND b.Status_CODE = @Lc_StatusVerified_CODE
                             AND b.End_DATE = @Ld_High_DATE)
          AND NOT EXISTS (SELECT 1
                            FROM EHIS_Y1 c
                           WHERE c.MemberMci_IDNO = @Ln_DemoMemberMci_IDNO
                             AND c.Status_CODE = @Lc_StatusVerified_CODE
                             AND c.EmployerPrime_INDC = @Lc_Yes_INDC
                             AND c.EndEmployment_DATE = @Ld_High_DATE);

       IF @Ln_Exists_NUMB = 0
        BEGIN
         SET @Lc_EfmemTypeLocReq_CODE = @Lc_LocRequestforIvd_CODE;
         SET @Lc_EfmemLocateSource1_CODE = @Lc_All_TEXT;
         SET @Lc_EfmemBundleResults_INDC = @Lc_Yes_INDC;
        END
       ELSE
        BEGIN
         SET @Lc_EfmemTypeLocReq_CODE = @Lc_Space_TEXT;
         SET @Lc_EfmemLocateSource1_CODE = @Lc_Space_TEXT;
         SET @Lc_EfmemBundleResults_INDC = @Lc_Space_TEXT;
        END
      END

     IF @Ac_Process_INDC = @Lc_PersonLocProcessFlag_INDC
      BEGIN
       SET @Lc_EfmemTypeLocReq_CODE = @Lc_LocRequestforIvd_CODE;
       SET @Lc_EfmemLocateSource1_CODE = @Lc_All_TEXT;
       --For locate request the following suppose to be space.
       SET @Lc_EfmemBundleResults_INDC = @Lc_Space_TEXT;
       SET @Lc_EfmemTypeParticipant_CODE = @Lc_Space_TEXT;
      END

     --Insert extracted member details into EFMEM_Y1
     SET @Ls_Sql_TEXT = 'INSERT INTO EFMEM_Y1';
     SET @Ls_SqlData_TEXT = 'Rec_ID = ' + ISNULL(@Lc_EfmemRec_ID, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_EfmemTypeAction_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_EfmemCase_IDNO, '') + ', ReservedFcr_CODE = ' + ISNULL(@Lc_EfmemReservedFcr_CODE, '') + ', UserField_NAME = ' + ISNULL(@Lc_EfmemUserField_NAME, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_EfmemCountyFips_CODE, '') + ', TypeLocReq_CODE = ' + ISNULL(@Lc_EfmemTypeLocReq_CODE, '') + ', BundleResults_INDC = ' + ISNULL(@Lc_EfmemBundleResults_INDC, '') + ', TypeParticipant_CODE = ' + ISNULL(@Lc_EfmemTypeParticipant_CODE, '') + ', First_NAME = ' + ISNULL(@Lc_EfmemFirst_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_EfmemMiddle_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_EfmemLast_NAME, '') + ', CityBirth_NAME = ' + ISNULL(@Lc_EfmemCityBirth_NAME, '') + ', StCountryBirth_CODE = ' + ISNULL(@Lc_EfmemStCountryBirth_CODE, '') + ', FirstFather_NAME = ' + ISNULL(@Lc_EfmemFirstFather_NAME, '') + ', MiddleFather_NAME = ' + ISNULL(@Lc_EfmemMiddleFather_NAME, '') + ', LastFather_NAME = ' + ISNULL(@Lc_EfmemLastFather_NAME, '') + ', FirstMother_NAME = ' + ISNULL(@Lc_EfmemFirstMother_NAME, '') + ', MiddleMother_NAME = ' + ISNULL(@Lc_EfmemMiddleMother_NAME, '') + ', LastMother_NAME = ' + ISNULL(@Lc_EfmemLastMother_NAME, '') + ', FirstAdditional1_NAME = ' + ISNULL(@Lc_EfmemFirstAdditional1_NAME, '') + ', MiddleAdditional1_NAME = ' + ISNULL(@Lc_EfmemMiddleAdditional1_NAME, '') + ', LastAdditional1_NAME = ' + ISNULL(@Lc_EfmemLastAdditional1_NAME, '') + ', FirstAdditional2_NAME = ' + ISNULL(@Lc_EfmemFirstAdditional2_NAME, '') + ', MiddleAdditional2_NAME = ' + ISNULL(@Lc_EfmemMiddleAdditional2_NAME, '') + ', LastAdditional2_NAME = ' + ISNULL(@Lc_EfmemLastAdditional2_NAME, '') + ', FirstAdditional3_NAME = ' + ISNULL(@Lc_EfmemFirstAdditional3_NAME, '') + ', MiddleAdditional3_NAME = ' + ISNULL(@Lc_EfmemMiddleAdditional3_NAME, '') + ', LastAdditional3_NAME = ' + ISNULL(@Lc_EfmemLastAdditional3_NAME, '') + ', FirstAdditional4_NAME = ' + ISNULL(@Lc_EfmemFirstAdditional4_NAME, '') + ', MiddleAdditional4_NAME = ' + ISNULL(@Lc_EfmemMiddleAdditional4_NAME, '') + ', LastAdditional4_NAME = ' + ISNULL(@Lc_EfmemLastAdditional4_NAME, '') + ', Irs1099_INDC = ' + ISNULL(@Lc_EfmemIrs1099_INDC, '') + ', LocateSource1_CODE = ' + ISNULL(@Lc_EfmemLocateSource1_CODE, '') + ', LocateSource2_CODE = ' + ISNULL(@Lc_EfmemLocateSource2_CODE, '') + ', LocateSource3_CODE = ' + ISNULL(@Lc_EfmemLocateSource3_CODE, '') + ', LocateSource4_CODE = ' + ISNULL(@Lc_EfmemLocateSource4_CODE, '') + ', LocateSource5_CODE = ' + ISNULL(@Lc_EfmemLocateSource5_CODE, '') + ', LocateSource6_CODE = ' + ISNULL(@Lc_EfmemLocateSource6_CODE, '') + ', LocateSource7_CODE = ' + ISNULL(@Lc_EfmemLocateSource7_CODE, '') + ', LocateSource8_CODE = ' + ISNULL(@Lc_EfmemLocateSource8_CODE, '');

     INSERT EFMEM_Y1
            (Rec_ID,
             TypeAction_CODE,
             Case_IDNO,
             ReservedFcr_CODE,
             UserField_NAME,
             CountyFips_CODE,
             TypeLocReq_CODE,
             BundleResults_INDC,
             TypeParticipant_CODE,
             FamilyViolence_CODE,
             MemberMci_IDNO,
             Sex_CODE,
             Birth_DATE,
             MemberSsn_NUMB,
             PreviousMemberSsn_NUMB,
             First_NAME,
             Middle_NAME,
             Last_NAME,
             CityBirth_NAME,
             StCountryBirth_CODE,
             FirstFather_NAME,
             MiddleFather_NAME,
             LastFather_NAME,
             FirstMother_NAME,
             MiddleMother_NAME,
             LastMother_NAME,
             IrsUsedMemberSsn_NUMB,
             MemberAdditional1Ssn_NUMB,
             MemberAdditional2Ssn_NUMB,
             FirstAdditional1_NAME,
             MiddleAdditional1_NAME,
             LastAdditional1_NAME,
             FirstAdditional2_NAME,
             MiddleAdditional2_NAME,
             LastAdditional2_NAME,
             FirstAdditional3_NAME,
             MiddleAdditional3_NAME,
             LastAdditional3_NAME,
             FirstAdditional4_NAME,
             MiddleAdditional4_NAME,
             LastAdditional4_NAME,
             NewMemberMci_IDNO,
             Irs1099_INDC,
             LocateSource1_CODE,
             LocateSource2_CODE,
             LocateSource3_CODE,
             LocateSource4_CODE,
             LocateSource5_CODE,
             LocateSource6_CODE,
             LocateSource7_CODE,
             LocateSource8_CODE)
     SELECT @Lc_EfmemRec_ID AS Rec_ID,
            @Lc_EfmemTypeAction_CODE AS TypeAction_CODE,
            @Lc_EfmemCase_IDNO AS Case_IDNO,
            @Lc_EfmemReservedFcr_CODE AS ReservedFcr_CODE,
            @Lc_EfmemUserField_NAME AS UserField_NAME,
            @Lc_EfmemCountyFips_CODE AS CountyFips_CODE,
            @Lc_EfmemTypeLocReq_CODE AS TypeLocReq_CODE,
            @Lc_EfmemBundleResults_INDC AS BundleResults_INDC,
            @Lc_EfmemTypeParticipant_CODE AS TypeParticipant_CODE,
            CASE
             WHEN @Lc_EfmemFamilyViolence_CODE IS NULL
              THEN ''
             ELSE @Lc_EfmemFamilyViolence_CODE
            END AS FamilyViolence_CODE,
            CASE
             WHEN ISNUMERIC(@Lc_EfmemMemberMci_IDNO) = 0
              THEN 0
             ELSE @Lc_EfmemMemberMci_IDNO
            END AS MemberMci_IDNO,
            ISNULL(@Lc_EfmemMemberSex_CODE, '') AS Sex_CODE,
            CASE
             WHEN ISDATE(@Lc_EfmemBirth_DATE) = 0
              THEN @Lc_Space_TEXT
             ELSE @Lc_EfmemBirth_DATE
            END AS Birth_DATE,
            CASE
             WHEN ISNUMERIC(@Lc_EfmemMemberSsn_NUMB) = 0
              THEN 0
             ELSE @Lc_EfmemMemberSsn_NUMB
            END AS MemberSsn_NUMB,
            CASE
             WHEN ISNUMERIC(@Lc_EfmemPreviousMemberSsn_NUMB) = 0
              THEN 0
             ELSE @Lc_EfmemPreviousMemberSsn_NUMB
            END AS PreviousMemberSsn_NUMB,
            @Lc_EfmemFirst_NAME AS First_NAME,
            @Lc_EfmemMiddle_NAME AS Middle_NAME,
            @Lc_EfmemLast_NAME AS Last_NAME,
            @Lc_EfmemCityBirth_NAME AS CityBirth_NAME,
            @Lc_EfmemStCountryBirth_CODE AS StCountryBirth_CODE,
            @Lc_EfmemFirstFather_NAME AS FirstFather_NAME,
            @Lc_EfmemMiddleFather_NAME AS MiddleFather_NAME,
            @Lc_EfmemLastFather_NAME AS LastFather_NAME,
            @Lc_EfmemFirstMother_NAME AS FirstMother_NAME,
            @Lc_EfmemMiddleMother_NAME AS MiddleMother_NAME,
            @Lc_EfmemLastMother_NAME AS LastMother_NAME,
            CASE
             WHEN ISNUMERIC(@Lc_EfmemIrsUsedMemberSsn_NUMB) = 0
              THEN 0
             ELSE @Lc_EfmemIrsUsedMemberSsn_NUMB
            END AS IrsUsedMemberSsn_NUMB,
            CASE
             WHEN ISNUMERIC(@Lc_EfmemMemberAdditional1Ssn_NUMB) = 0
              THEN 0
             ELSE @Lc_EfmemMemberAdditional1Ssn_NUMB
            END AS MemberAdditional1Ssn_NUMB,
            CASE
             WHEN ISNUMERIC(@Lc_EfmemMemberAdditional2Ssn_NUMB) = 0
              THEN 0
             ELSE @Lc_EfmemMemberAdditional2Ssn_NUMB
            END AS MemberAdditional2Ssn_NUMB,
            @Lc_EfmemFirstAdditional1_NAME AS FirstAdditional1_NAME,
            @Lc_EfmemMiddleAdditional1_NAME AS MiddleAdditional1_NAME,
            @Lc_EfmemLastAdditional1_NAME AS LastAdditional1_NAME,
            @Lc_EfmemFirstAdditional2_NAME AS FirstAdditional2_NAME,
            @Lc_EfmemMiddleAdditional2_NAME AS MiddleAdditional2_NAME,
            @Lc_EfmemLastAdditional2_NAME AS LastAdditional2_NAME,
            @Lc_EfmemFirstAdditional3_NAME AS FirstAdditional3_NAME,
            @Lc_EfmemMiddleAdditional3_NAME AS MiddleAdditional3_NAME,
            @Lc_EfmemLastAdditional3_NAME AS LastAdditional3_NAME,
            @Lc_EfmemFirstAdditional4_NAME AS FirstAdditional4_NAME,
            @Lc_EfmemMiddleAdditional4_NAME AS MiddleAdditional4_NAME,
            @Lc_EfmemLastAdditional4_NAME AS LastAdditional4_NAME,
            CASE
             WHEN ISNUMERIC(@Lc_EfmemNewMemberMci_IDNO) = 0
              THEN 0
             ELSE @Lc_EfmemNewMemberMci_IDNO
            END AS NewMemberMci_IDNO,
            @Lc_EfmemIrs1099_INDC AS Irs1099_INDC,
            @Lc_EfmemLocateSource1_CODE AS LocateSource1_CODE,
            @Lc_EfmemLocateSource2_CODE AS LocateSource2_CODE,
            @Lc_EfmemLocateSource3_CODE AS LocateSource3_CODE,
            @Lc_EfmemLocateSource4_CODE AS LocateSource4_CODE,
            @Lc_EfmemLocateSource5_CODE AS LocateSource5_CODE,
            @Lc_EfmemLocateSource6_CODE AS LocateSource6_CODE,
            @Lc_EfmemLocateSource7_CODE AS LocateSource7_CODE,
            @Lc_EfmemLocateSource8_CODE AS LocateSource8_CODE;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO EFMEM_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ln_Exists_NUMB = 0;
     --Update fadt if member exists
     SET @Ls_Sql_TEXT = 'CHECK FOR MEMBER IN FADT_Y1 - 1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecPerson_ID, '');

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM FADT_Y1 A
      WHERE A.Case_IDNO = @Ln_InputCase_IDNO
        AND A.MemberMci_IDNO = @Ln_DemoMemberMci_IDNO
        AND A.TypeTrans_CODE = @Lc_RecPerson_ID;

     IF @Ln_Exists_NUMB > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE FADT_Y1 - 1';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecPerson_ID, '');

       UPDATE FADT_Y1
          SET TypeTrans_CODE = @Lc_EfmemRec_ID,
              Action_CODE = @Lc_EfmemTypeAction_CODE,
              Transmitted_DATE = @Ld_Run_DATE,
              MemberSsn_NUMB = CASE
                                WHEN ISNUMERIC(@Lc_EfmemMemberSsn_NUMB) = 0
                                 THEN 0
                                ELSE @Lc_EfmemMemberSsn_NUMB
                               END,
              Birth_DATE = @Ld_DemoBirth_DATE,
              Last_NAME = @Lc_DemoLast_NAME,
              First_NAME = @Lc_DemoFirst_NAME,
              CaseRelationship_CODE = @Lc_CmemCaseRelationship_CODE,
              CaseMemberStatus_CODE = @Lc_CmemCaseMemberStatus_CODE,
              Batch_NUMB = @An_Batch_NUMB
        WHERE Case_IDNO = @Ln_InputCase_IDNO
          AND MemberMci_IDNO = @Ln_DemoMemberMci_IDNO
          AND TypeTrans_CODE = @Lc_RecPerson_ID;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE FADT_Y1 - 1 FAILED';

         RAISERROR(50001,16,1);
        END
      END
     ELSE
      BEGIN
       --Insert record into fadt
       SET @Ls_Sql_TEXT = 'INSERT INTO FADT_Y1 - 1';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '') + ', Action_CODE = ' + ISNULL(@Lc_EfmemTypeAction_CODE, '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_EfmemRec_ID, '') + ', Transmitted_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', County_IDNO = ' + ISNULL(@Lc_StringZero_TEXT, '') + ', Order_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_DemoBirth_DATE AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_DemoLast_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_DemoFirst_NAME, '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CmemCaseRelationship_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CmemCaseMemberStatus_CODE, '') + ', Response_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ResponseFcr_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '');

       INSERT FADT_Y1
              (Case_IDNO,
               MemberMci_IDNO,
               Action_CODE,
               TypeTrans_CODE,
               Transmitted_DATE,
               TypeCase_CODE,
               StatusCase_CODE,
               County_IDNO,
               Order_INDC,
               MemberSsn_NUMB,
               Birth_DATE,
               Last_NAME,
               First_NAME,
               CaseRelationship_CODE,
               CaseMemberStatus_CODE,
               Response_DATE,
               ResponseFcr_CODE,
               Batch_NUMB)
       SELECT @Ln_InputCase_IDNO AS Case_IDNO,
              @Ln_DemoMemberMci_IDNO AS MemberMci_IDNO,
              @Lc_EfmemTypeAction_CODE AS Action_CODE,
              @Lc_EfmemRec_ID AS TypeTrans_CODE,
              @Ld_Run_DATE AS Transmitted_DATE,
              @Lc_Space_TEXT AS TypeCase_CODE,
              @Lc_Space_TEXT AS StatusCase_CODE,
              @Lc_StringZero_TEXT AS County_IDNO,
              @Lc_Space_TEXT AS Order_INDC,
              CASE
               WHEN ISNUMERIC(@Lc_EfmemMemberSsn_NUMB) = 0
                THEN 0
               ELSE @Lc_EfmemMemberSsn_NUMB
              END AS MemberSsn_NUMB,
              @Ld_DemoBirth_DATE AS Birth_DATE,
              @Lc_DemoLast_NAME AS Last_NAME,
              @Lc_DemoFirst_NAME AS First_NAME,
              @Lc_CmemCaseRelationship_CODE AS CaseRelationship_CODE,
              @Lc_CmemCaseMemberStatus_CODE AS CaseMemberStatus_CODE,
              @Ld_Low_DATE AS Response_DATE,
              @Lc_Space_TEXT AS ResponseFcr_CODE,
              @An_Batch_NUMB AS Batch_NUMB;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO FADT_Y1 - 1 FAILED';

         RAISERROR(50001,16,1);
        END
      END

     SET @Ln_Exists_NUMB = 0;
     --Delete member from fprj
     SET @Ls_Sql_TEXT = 'CHECK FOR MEMBER MCI IN FPRJ_Y1 - 1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '');

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM FPRJ_Y1 A
      WHERE A.Case_IDNO = @Ln_InputCase_IDNO
        AND A.MemberMci_IDNO = @Ln_DemoMemberMci_IDNO;

     IF @Ln_Exists_NUMB != 0
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE FROM FPRJ_Y1 - 1';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '');

       DELETE FPRJ_Y1
        WHERE Case_IDNO = @Ln_InputCase_IDNO
          AND MemberMci_IDNO = @Ln_DemoMemberMci_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'DELETE FROM FPRJ_Y1 - 1 FAILED';

         RAISERROR(50001,16,1);
        END
      END

     --write a case Journal entry for transactions submitted to FCR
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 3';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoMemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemLo_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Ln_InputCase_IDNO,
      @An_MemberMci_IDNO           = @Ln_DemoMemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorStfcr_CODE,
      @Ac_Subsystem_CODE           = @Lc_SubsystemLo_CODE,
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
      END;

     IF @Ac_TransType_CODE = @Lc_TransTypePersonAdd_CODE
      BEGIN
       SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionMemberAdd_TEXT;
      END
     ELSE IF @Ac_TransType_CODE = @Lc_TransTypePersonChange_CODE
      BEGIN
       SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionMemberChange_TEXT;
      END
     ELSE IF @Ac_TransType_CODE = @Lc_TransTypePersonDelete_CODE
      BEGIN
       SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionMemberDelete_TEXT;
      END
     ELSE IF @Ac_TransType_CODE = @Lc_TransTypePersonMerge_CODE
      BEGIN
       SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionMemberMerge_TEXT;
      END
     ELSE IF @Ac_TransType_CODE = @Lc_TransTypePersonLocate_CODE
      BEGIN
       SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionCaseSubmitted_TEXT;
      END

     --Notes added for corresponding case journal entry
     SET @Ls_Sql_TEXT = 'BATCH_COMMON_NOTE$SP_CREATE_NOTE - 3';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', DescriptionNote_TEXT = ' + ISNULL(@Ls_DescriptionNote_TEXT, '') + ', Category_CODE = ' + ISNULL(@Lc_SubsystemLo_CODE, '') + ', Subject_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', WorkerSignedOn_IDNO = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Topic_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '');

     EXECUTE BATCH_COMMON_NOTE$SP_CREATE_NOTE
      @Ac_Case_IDNO                = @Ln_InputCase_IDNO,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
      @Ac_Category_CODE            = @Lc_SubsystemLo_CODE,
      @Ac_Subject_CODE             = @Lc_ActivityMinorStfcr_CODE,
      @As_WorkerSignedOn_IDNO      = @Lc_BatchRunUser_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @An_Topic_IDNO               = @Ln_Topic_IDNO;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;

     --member merge trasaction delete merged member record from fadt
     IF @Ac_TransType_CODE = @Lc_TransTypePersonMerge_CODE
      BEGIN
       SET @Ln_Exists_NUMB = 0;
       SET @Ls_Sql_TEXT = 'CHECK FOR MEMBER MCI IN FADT_Y1 - 2';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_InputMemberMci_IDNO AS VARCHAR), '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecPerson_ID, '');

       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM FADT_Y1 A
        WHERE A.Case_IDNO = @Ln_InputCase_IDNO
          AND A.MemberMci_IDNO = @Ln_InputMemberMci_IDNO
          AND A.TypeTrans_CODE = @Lc_RecPerson_ID;

       IF @Ln_Exists_NUMB != 0
        BEGIN
         SET @Ls_Sql_TEXT = 'DELETE FROM FADT_Y1 - 2';
         SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_InputMemberMci_IDNO AS VARCHAR), '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecPerson_ID, '');

         DELETE FADT_Y1
          WHERE Case_IDNO = @Ln_InputCase_IDNO
            AND MemberMci_IDNO = @Ln_InputMemberMci_IDNO
            AND TypeTrans_CODE = @Lc_RecPerson_ID;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'DELETE FROM FADT_Y1 - 2 FAILED';

           RAISERROR(50001,16,1);
          END
        END

       SET @Ln_Exists_NUMB = 0;
       --Delete merged member from fprj
       SET @Ls_Sql_TEXT = 'CHECK FOR MEMBER IN FPRJ_Y1 - 3';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_InputMemberMci_IDNO AS VARCHAR), '');

       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM FPRJ_Y1 A
        WHERE A.Case_IDNO = @Ln_InputCase_IDNO
          AND A.MemberMci_IDNO = @Ln_InputMemberMci_IDNO;

       IF @Ln_Exists_NUMB != 0
        BEGIN
         SET @Ls_Sql_TEXT = 'DELETE FROM FPRJ_Y1 - 3';
         SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_InputMemberMci_IDNO AS VARCHAR), '');

         DELETE FPRJ_Y1
          WHERE Case_IDNO = @Ln_InputCase_IDNO
            AND MemberMci_IDNO = @Ln_InputMemberMci_IDNO;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'DELETE FROM FPRJ_Y1 - 3 FAILED';

           RAISERROR(50001,16,1);
          END
        END
      END
    END

   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('LOCAL', 'Akax_CUR') IN (0, 1)
    BEGIN
     CLOSE Akax_CUR;

     DEALLOCATE Akax_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'Mssn_CUR') IN (0, 1)
    BEGIN
     CLOSE Mssn_CUR;

     DEALLOCATE Mssn_CUR;
    END

   IF @Lc_SkipRecord_INDC = 'Y'
    BEGIN
     SET @Ac_Msg_CODE = NULL;
     SET @As_DescriptionError_TEXT = NULL;

     RETURN;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SELECT '@Ls_DescriptionError_TEXT  = ' + @Ls_DescriptionError_TEXT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
