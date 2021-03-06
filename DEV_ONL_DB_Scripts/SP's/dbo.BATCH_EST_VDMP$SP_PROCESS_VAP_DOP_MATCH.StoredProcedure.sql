/****** Object:  StoredProcedure [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MATCH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MATCH
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MATCH processes uses key member data 
					  available on the VAPP - Voluntary Acknowledgment of Paternity Process screen to identify 
					  if that member is active on a case in DECSS.
Frequency		:	'DAILY'
Developed On	:	3/16/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MATCH]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_FourPoints_NUMB               NUMERIC = 4,
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_DepCaseRelationship_CODE      CHAR(1) = 'D',
          @Lc_CPCaseRelationship_CODE       CHAR(1) = 'C',
          @Lc_NCPCaseRelationship_CODE      CHAR(1) = 'A',
          @Lc_PNCPCaseRelationship_CODE     CHAR(1) = 'P',
          @Lc_DataRecordStatusComplete_CODE CHAR(1) = 'C',
          @Lc_DOPAttachedYes_CODE           CHAR(1) = 'Y',
          @Lc_DOPAttachedNo_CODE            CHAR(1) = 'N',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_MTRMemberSex_CODE             CHAR(1) = 'F',
          @Lc_FTRMemberSex_CODE             CHAR(1) = 'M',
          @Lc_TypeErrorE_CODE               CHAR(1) = 'E',
          @Lc_Note_INDC                     CHAR(1) = 'N',
          @Lc_MatchFound_INDC               CHAR(1) = 'N',
          @Lc_StateDisestablish_CODE        CHAR(2) = ' ',
          @Lc_TypeDocumentVap_CODE          CHAR(3) = 'VAP',
          @Lc_DopTypeDocument_CODE          CHAR(3) = 'DOP',
          @Lc_Relation_Mother_CODE          CHAR(3) = 'MTR',
          @Lc_Relation_Father_CODE          CHAR(3) = 'FTR',
          @Lc_BateErrorE0944_CODE           CHAR(5) = 'E0944',
          @Lc_BateErrorE1424_CODE           CHAR(5) = 'E1424',
          @Lc_Job_ID                        CHAR(7) = 'DEB9002',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT             CHAR(30) = 'BATCH',
          @Lc_ParmDateProblem_TEXT          CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_EST_VDMP',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_PROCESS_VAP_DOP_MATCH',
          @Ld_Low_DATE                      DATE = '01/01/0001',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Disestablish_DATE             DATE = NULL;
  DECLARE @Ln_ErrorLine_NUMB                             NUMERIC,
          @Ln_ChildPointsCounter_NUMB                    NUMERIC = 0,
          @Ln_ParentPointsCounter_NUMB                   NUMERIC = 0,
          @Ln_RowsCount_QNTY                             NUMERIC,
          @Ln_CaseCur_Case_IDNO                          NUMERIC,
          @Ln_DemoCur_MemberMci_IDNO                     NUMERIC,
          @Ln_ParentsCur_MemberMci_IDNO                  NUMERIC,
          @Ln_ChildDemo_MemberMci_IDNO                   NUMERIC,
          @Ln_MotherDemo_MemberMci_IDNO                  NUMERIC,
          @Ln_MotherDemo_MemberSsn_NUMB                  NUMERIC,
          @Ln_EstFatherDemo_MemberMci_IDNO               NUMERIC,
          @Ln_EstFatherDemo_MemberSsn_NUMB               NUMERIC,
          @Ln_DisEstFatherDemo_MemberMci_IDNO            NUMERIC,
          @Ln_Zero_NUMB                                  NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY                        NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY                NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                            NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY                    NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                           NUMERIC(5),
          @Ln_ExistingMatchPoint_QNTY                    NUMERIC(5),
          @Ln_UpdateMatchPoint_QNTY                      NUMERIC(5),
          @Ln_Case_IDNO                                  NUMERIC(6),
          @Ln_ProcessedRecordCount_QNTY                  NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY            NUMERIC(6) = 0,
          @Ln_ChildMemberSsn_NUMB                        NUMERIC(9),
          @Ln_ChildMemberMci_IDNO                        NUMERIC(10),
          @Ln_RecordCount_QNTY                           NUMERIC(10) = 0,
          @Ln_Error_NUMB                                 NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB                   NUMERIC(19) = 0,
          @Li_VappFetchStatus_QNTY                       INT,
          @Li_CaseFetchStatus_QNTY                       INT,
          @Li_DemoFetchStatus_QNTY                       INT,
          @Li_ParentFetchStatus_QNTY                     INT,
          @Li_ChildFirstProcessChildDataMatchPoint_QNTY  INT = 0,
          @Li_ChildFirstProcessParentDataMatchPoint_QNTY INT = 0,
          @Li_CfpChildDataMatchPoint_QNTY                INT,
          @Li_CfpParentDataMatchPoint_QNTY               INT,
          @Li_MfpChildDataMatchPoint_QNTY                INT,
          @Li_MfpParentDataMatchPoint_QNTY               INT,
          @Li_FfpChildDataMatchPoint_QNTY                INT,
          @Li_FfpParentDataMatchPoint_QNTY               INT,
          @Li_PfpChildDataMatchPoint_QNTY                INT,
          @Li_PfpParentDataMatchPoint_QNTY               INT,
          @Li_RowCount_QNTY                              SMALLINT,
          @Li_FetchStatus_QNTY                           SMALLINT,
          @Lc_Empty_TEXT                                 CHAR = '',
          @Lc_ChildRace_CODE                             CHAR(1),
          @Lc_MTRCaseRelationship_CODE                   CHAR(1),
          @Lc_EFTRCaseRelationship_CODE                  CHAR(1),
          @Lc_DisEstablishedFather_CODE                  CHAR(1),
          @Lc_ParentsCur_CaseRelationship_CODE           CHAR(1),
          @Lc_ParentsCur_MemberSex_CODE                  CHAR(1),
          @Lc_VappMatchFound_INDC                        CHAR(1),
          @Lc_Process_NAME                               CHAR(3),
          @Lc_CpRelationshipToChild_CODE                 CHAR(3),
          @Lc_NcpRelationshipToChild_CODE                CHAR(3),
          @Lc_Relation_CPRelationshipToChild_CODE        CHAR(3),
          @Lc_Relation_NCPRelationshipToChild_CODE       CHAR(3),
          @Lc_MotherDemo_Suffix_NAME                     CHAR(4),
          @Lc_EstFatherDemo_Suffix_NAME                  CHAR(4),
          @Lc_DisEstFatherDemo_Suffix_NAME               CHAR(4),
          @Lc_Msg_CODE                                   CHAR(5) = '',
          @Lc_BateError_CODE                             CHAR(5),
          @Lc_ChildBirthCertificate_ID                   CHAR(7),
          @Lc_ChildFirst_NAME                            CHAR(16),
          @Lc_MotherDemo_First_NAME                      CHAR(16),
          @Lc_EstFatherDemo_First_NAME                   CHAR(16),
          @Lc_DisEstFatherDemo_First_NAME                CHAR(16),
          @Lc_ChildLast_NAME                             CHAR(20),
          @Lc_MotherDemo_Last_NAME                       CHAR(20),
          @Lc_MotherDemo_Middle_NAME                     CHAR(20),
          @Lc_EstFatherDemo_Last_NAME                    CHAR(20),
          @Lc_EstFatherDemo_Middle_NAME                  CHAR(20),
          @Lc_DisEstFatherDemo_Last_NAME                 CHAR(20),
          @Lc_DisEstFatherDemo_Middle_NAME               CHAR(20),
          @Ls_Sql_TEXT                                   VARCHAR(100) = '',
          @Ls_CursorLocation_TEXT                        VARCHAR(200),
          @Ls_Sqldata_TEXT                               VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT                          VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT                      VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT                            VARCHAR(4000),
          @Ld_ChildBirth_DATE                            DATE,
          @Ld_Run_DATE                                   DATE,
          @Ld_DOPMotherSig_DATE                          DATE,
          @Ld_DOPFatherSig_DATE                          DATE,
          @Ld_UpdateEstDate_DATE                         DATE,
          @Ld_MotherDemo_Birth_DATE                      DATE,
          @Ld_EstFatherDemo_Birth_DATE                   DATE,
          @Ld_LastRun_DATE                               DATETIME,
          @Ld_Start_DATE                                 DATETIME2,
          @Lb_DemoMultipleMatch_BIT                      BIT = 0,
          @Lb_UpdateMTRDemoVapp_BIT                      BIT = 0,
          @Lb_UpdateFTRDemoVapp_BIT                      BIT = 0,
          @Lb_UpdateDFTRDemoVapp_BIT                     BIT = 0;
  DECLARE @Ln_VappCur_ChildMemberMci_IDNO      NUMERIC,
          @Ln_VappCur_ChildMemberSsn_NUMB      NUMERIC,
          @Ln_VappCur_FatherMemberMci_IDNO     NUMERIC,
          @Ln_VappCur_FatherMemberSsn_NUMB     NUMERIC,
          @Ln_VappCur_MotherMemberMci_IDNO     NUMERIC,
          @Ln_VappCur_MotherMemberSsn_NUMB     NUMERIC,
          @Ln_VappCur_DisFatherMemberMci_IDNO  NUMERIC,
          @Ln_VappCur_DisFatherMemberSsn_NUMB  NUMERIC,
          @Ln_VappCur_MatchPoint_QNTY          NUMERIC(5),
          @Lc_VappCur_DopAttached_CODE         CHAR(1),
          @Lc_VappCur_DataRecordStatus_CODE    CHAR(1),
          @Lc_VappCur_TypeDocument_CODE        CHAR(3),
          @Lc_VappCur_ChildBirthCertificate_ID CHAR(7),
          @Lc_VappCur_ChildMemberSsnNumb_TEXT  CHAR(9),
          @Lc_VappCur_MotherMemberSsnNumb_TEXT CHAR(9),
          @Lc_VappCur_FatherMemberSsnNumb_TEXT CHAR(9),
          @Lc_VappCur_ChildMemberMciIdno_TEXT  CHAR(10),
          @Lc_VappCur_FatherMemberMciIdno_TEXT CHAR(10),
          @Lc_VappCur_MotherMemberMciIdno_TEXT CHAR(10),
          @Lc_VappCur_ChildFirst_NAME          CHAR(16),
          @Lc_VappCur_FatherFirst_NAME         CHAR(16),
          @Lc_VappCur_MotherFirst_NAME         CHAR(16),
          @Lc_VappCur_DisFatherFirst_NAME      CHAR(16),
          @Lc_VappCur_ChildLast_NAME           CHAR(20),
          @Lc_VappCur_FatherLast_NAME          CHAR(20),
          @Lc_VappCur_MotherLast_NAME          CHAR(20),
          @Lc_VappCur_DisFatherLast_NAME       CHAR(20),
          @Ld_VappCur_ChildBirth_DATE          DATE,
          @Ld_VappCur_MotherSignature_DATE     DATE,
          @Ld_VappCur_FatherSignature_DATE     DATE,
          @Ld_VappCur_Match_DATE               DATE,
          @Ld_VappCur_FatherBirth_DATE         DATE,
          @Ld_VappCur_MotherBirth_DATE         DATE,
          @Ld_VappCur_DisFatherBirth_DATE      DATE;
  DECLARE Vapp_CUR INSENSITIVE CURSOR FOR
   SELECT v.ChildBirthCertificate_ID,
          v.TypeDocument_CODE,
          v.ChildMemberMci_IDNO,
          v.ChildLast_NAME,
          v.ChildFirst_NAME,
          v.ChildBirth_DATE,
          v.ChildMemberSsn_NUMB,
          v.DopAttached_CODE,
          v.MotherSignature_DATE,
          v.FatherSignature_DATE,
          v.Match_DATE,
          v.DataRecordStatus_CODE,
          v.FatherMemberMci_IDNO,
          v.FatherLast_NAME,
          v.FatherFirst_NAME,
          v.FatherBirth_DATE,
          v.FatherMemberSsn_NUMB,
          v.MotherMemberMci_IDNO,
          v.MotherLast_NAME,
          v.MotherFirst_NAME,
          v.MotherBirth_DATE,
          v.MotherMemberSsn_NUMB,
          v.MatchPoint_QNTY
     FROM VAPP_Y1 v
    WHERE v.TypeDocument_CODE = @Lc_TypeDocumentVap_CODE
      AND v.DataRecordStatus_CODE = @Lc_DataRecordStatusComplete_CODE
      AND v.DopAttached_CODE IN (@Lc_DOPAttachedYes_CODE, @Lc_DOPAttachedNo_CODE)
      AND v.Match_DATE = @Ld_Low_DATE
      AND v.ImageLink_INDC = 'Y'
    ORDER BY v.ChildBirthCertificate_ID,
             v.TypeDocument_CODE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_VAP_DOP_MATCH';

   BEGIN TRANSACTION TXN_PROCESS_VAP_DOP_MATCH;

   SET @Ls_Sql_TEXT = 'DROP #CfpMatchPointQntyInfo_P1';

   IF OBJECT_ID('tempdb..#CfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CfpMatchPointQntyInfo_P1;
    END;

   SET @Ls_Sql_TEXT = 'CREATE #CfpMatchPointQntyInfo_P1';

   CREATE TABLE #CfpMatchPointQntyInfo_P1
    (
      ChildBirthCertificate_ID    CHAR(7),
      ChildMemberMci_IDNO         NUMERIC(10) NULL,
      ChildLast_NAME              CHAR(20) NULL,
      ChildFirst_NAME             CHAR(16) NULL,
      ChildBirth_DATE             DATE NULL,
      ChildMemberSsn_NUMB         NUMERIC(9) NULL,
      ChildCase_IDNO              NUMERIC(6) NULL,
      CpRelationshipToChild_CODE  CHAR(3) NULL,
      NcpRelationshipToChild_CODE CHAR(3) NULL,
      ChildDataMatchPoint_QNTY    INT NULL,
      ParentDataMatchPoint_QNTY   INT NULL
    );

   SET @Ls_Sql_TEXT = 'DROP #MfpMatchPointQntyInfo_P1';

   IF OBJECT_ID('tempdb..#MfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #MfpMatchPointQntyInfo_P1;
    END;

   SET @Ls_Sql_TEXT = 'CREATE #MfpMatchPointQntyInfo_P1';

   CREATE TABLE #MfpMatchPointQntyInfo_P1
    (
      ChildBirthCertificate_ID     CHAR(7),
      MotherMemberMci_IDNO         NUMERIC(10) NULL,
      MotherLast_NAME              CHAR(20) NULL,
      MotherFirst_NAME             CHAR(16) NULL,
      MotherMemberSsn_NUMB         NUMERIC(9) NULL,
      MotherCase_IDNO              NUMERIC(6) NULL,
      ChildMemberMci_IDNO          NUMERIC(10) NULL,
      CpRelationshipToChild_CODE   CHAR(3) NULL,
      NcpRelationshipToChild_CODE  CHAR(3) NULL,
      ChildLast_NAME               CHAR(20) NULL,
      ChildFirst_NAME              CHAR(16) NULL,
      ChildBirth_DATE              DATE NULL,
      ChildMemberSsn_NUMB          NUMERIC(9) NULL,
      ChildDemoBirthCertificate_ID CHAR(20) NULL,
      ChildDataMatchPoint_QNTY     INT NULL,
      MotherDataMatchPoint_QNTY    INT NULL,
      ParentDataMatchPoint_QNTY    INT NULL
    );

   SET @Ls_Sql_TEXT = 'DROP #FfpMatchPointQntyInfo_P1';

   IF OBJECT_ID('tempdb..#FfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #FfpMatchPointQntyInfo_P1;
    END;

   SET @Ls_Sql_TEXT = 'CREATE #FfpMatchPointQntyInfo_P1';

   CREATE TABLE #FfpMatchPointQntyInfo_P1
    (
      ChildBirthCertificate_ID     CHAR(7),
      FatherMemberMci_IDNO         NUMERIC(10) NULL,
      FatherLast_NAME              CHAR(20) NULL,
      FatherFirst_NAME             CHAR(16) NULL,
      FatherMemberSsn_NUMB         NUMERIC(9) NULL,
      FatherCase_IDNO              NUMERIC(6) NULL,
      ChildMemberMci_IDNO          NUMERIC(10) NULL,
      CpRelationshipToChild_CODE   CHAR(3) NULL,
      NcpRelationshipToChild_CODE  CHAR(3) NULL,
      ChildLast_NAME               CHAR(20) NULL,
      ChildFirst_NAME              CHAR(16) NULL,
      ChildBirth_DATE              DATE NULL,
      ChildMemberSsn_NUMB          NUMERIC(9) NULL,
      ChildDemoBirthCertificate_ID CHAR(20) NULL,
      ChildDataMatchPoint_QNTY     INT NULL,
      FatherDataMatchPoint_QNTY    INT NULL,
      ParentDataMatchPoint_QNTY    INT NULL
    );

   SET @Ls_Sql_TEXT = 'DROP #VappMappPointQntyInfo_P1';

   IF OBJECT_ID('tempdb..#VappMappPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #VappMappPointQntyInfo_P1;
    END;

   SET @Ls_Sql_TEXT = 'CREATE #VappMappPointQntyInfo_P1';

   CREATE TABLE #VappMappPointQntyInfo_P1
    (
      ChildBirthCertificate_ID                    CHAR(7),
      ExistingMatchPoint_QNTY                     NUMERIC(5),
      ChildFirstProcessChildDataMatchPoint_QNTY   INT NULL,
      ChildFirstProcessParentDataMatchPoint_QNTY  INT NULL,
      ParentFirstProcessChildDataMatchPoint_QNTY  INT NULL,
      ParentFirstProcessParentDataMatchPoint_QNTY INT NULL,
      MatchFound_INDC                             CHAR(1) NULL
    );

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
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN Vapp_CUR';

   OPEN Vapp_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Vapp_CUR - 1';

   FETCH NEXT FROM Vapp_CUR INTO @Lc_VappCur_ChildBirthCertificate_ID, @Lc_VappCur_TypeDocument_CODE, @Lc_VappCur_ChildMemberMciIdno_TEXT, @Lc_VappCur_ChildLast_NAME, @Lc_VappCur_ChildFirst_NAME, @Ld_VappCur_ChildBirth_DATE, @Lc_VappCur_ChildMemberSsnNumb_TEXT, @Lc_VappCur_DopAttached_CODE, @Ld_VappCur_MotherSignature_DATE, @Ld_VappCur_FatherSignature_DATE, @Ld_VappCur_Match_DATE, @Lc_VappCur_DataRecordStatus_CODE, @Lc_VappCur_FatherMemberMciIdno_TEXT, @Lc_VappCur_FatherLast_NAME, @Lc_VappCur_FatherFirst_NAME, @Ld_VappCur_FatherBirth_DATE, @Lc_VappCur_FatherMemberSsnNumb_TEXT, @Lc_VappCur_MotherMemberMciIdno_TEXT, @Lc_VappCur_MotherLast_NAME, @Lc_VappCur_MotherFirst_NAME, @Ld_VappCur_MotherBirth_DATE, @Lc_VappCur_MotherMemberSsnNumb_TEXT, @Ln_VappCur_MatchPoint_QNTY;

   SET @Li_VappFetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Vapp_CUR';

   --
   WHILE @Li_VappFetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_VAP_DOP_MATCH;

      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'Vdmp - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_BateRecord_TEXT = 'ChildBirthCertificate_ID  = ' + @Lc_VappCur_ChildBirthCertificate_ID + ', TypeDocument_CODE = ' + @Lc_VappCur_TypeDocument_CODE + ', ChildMemberMci_IDNO = ' + @Lc_VappCur_ChildMemberMciIdno_TEXT + ', ChildLast_NAME = ' + @Lc_VappCur_ChildLast_NAME + ', ChildFirst_NAME = ' + @Lc_VappCur_ChildFirst_NAME + ', ChildBirth_DATE = ' + CAST(@Ld_VappCur_ChildBirth_DATE AS VARCHAR) + ', ChildMemberSsn_NUMB = ' + @Lc_VappCur_ChildMemberSsnNumb_TEXT + ', DopAttached_CODE = ' + @Lc_VappCur_DopAttached_CODE + ', MotherSignature_DATE = ' + CAST(@Ld_VappCur_MotherSignature_DATE AS VARCHAR) + ', FatherSignature_DATE = ' + CAST(@Ld_VappCur_FatherSignature_DATE AS VARCHAR) + ', Match_DATE = ' + CAST(@Ld_VappCur_Match_DATE AS VARCHAR) + ', DataRecordStatus_CODE = ' + @Lc_VappCur_DataRecordStatus_CODE + ', FatherMemberMci_IDNO = ' + @Lc_VappCur_FatherMemberMciIdno_TEXT + ', FatherLast_NAME = ' + @Lc_VappCur_FatherLast_NAME + ', FatherFirst_NAME = ' + @Lc_VappCur_FatherFirst_NAME + ', FatherBirth_DATE = ' + CAST(@Ld_VappCur_FatherBirth_DATE AS VARCHAR) + ', FatherMemberSsn_NUMB = ' + @Lc_VappCur_FatherMemberSsnNumb_TEXT + ', MotherMemberMci_IDNO = ' + @Lc_VappCur_MotherMemberMciIdno_TEXT + ', MotherLast_NAME = ' + @Lc_VappCur_MotherLast_NAME + ', MotherFirst_NAME = ' + @Lc_VappCur_MotherFirst_NAME + ', MotherBirth_DATE = ' + CAST(@Ld_VappCur_MotherBirth_DATE AS VARCHAR) + ', MotherMemberSsn_NUMB = ' + @Lc_VappCur_MotherMemberSsnNumb_TEXT + ', MatchPoint_QNTY = ' + CAST(@Ln_VappCur_MatchPoint_QNTY AS VARCHAR);
      SET @Ls_Sql_TEXT = 'DELETE #CfpMatchPointQntyInfo_P1';
      SET @Ls_Sqldata_TEXT = '';

      DELETE FROM #CfpMatchPointQntyInfo_P1

      SET @Ls_Sql_TEXT = 'DELETE #MfpMatchPointQntyInfo_P1';
      SET @Ls_Sqldata_TEXT = '';

      DELETE FROM #MfpMatchPointQntyInfo_P1

      SET @Ls_Sql_TEXT = 'DELETE #FfpMatchPointQntyInfo_P1';
      SET @Ls_Sqldata_TEXT = '';

      DELETE FROM #FfpMatchPointQntyInfo_P1

      SET @Ls_Sql_TEXT = 'DELETE #VappMappPointQntyInfo_P1';
      SET @Ls_Sqldata_TEXT = '';

      DELETE FROM #VappMappPointQntyInfo_P1

      SET @Ls_Sql_TEXT = 'INSERT #VappMappPointQntyInfo_P1';
      SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', ExistingMatchPoint_QNTY = ' + ISNULL(CAST(@Ln_VappCur_MatchPoint_QNTY AS VARCHAR), '') + ', MatchFound_INDC = ' + ISNULL(@Lc_No_INDC, '');

      INSERT #VappMappPointQntyInfo_P1
             (ChildBirthCertificate_ID,
              ExistingMatchPoint_QNTY,
              MatchFound_INDC)
      VALUES ( @Lc_VappCur_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
               @Ln_VappCur_MatchPoint_QNTY,--ExistingMatchPoint_QNTY
               @Lc_No_INDC --MatchFound_INDC
      );

      SELECT @Ln_ChildDemo_MemberMci_IDNO = 0,
             @Li_ChildFirstProcessChildDataMatchPoint_QNTY = 0,
             @Lb_DemoMultipleMatch_BIT = 0,
             @Ln_DemoCur_MemberMci_IDNO = 0,
             @Li_DemoFetchStatus_QNTY = -1,
             @Lc_MatchFound_INDC = @Lc_No_INDC,
             @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
             @Ln_CaseCur_Case_IDNO = 0,
             @Li_CaseFetchStatus_QNTY = -1,
             @Lc_Relation_CPRelationshipToChild_CODE = '',
             @Lc_Relation_NCPRelationshipToChild_CODE = '',
             @Ln_ParentsCur_MemberMci_IDNO = 0,
             @Lc_ParentsCur_CaseRelationship_CODE = '',
             @Lc_ParentsCur_MemberSex_CODE = '',
             @Li_ParentFetchStatus_QNTY = -1,
             @Lc_MTRCaseRelationship_CODE = '',
             @Ln_MotherDemo_MemberMci_IDNO = 0,
             @Ln_MotherDemo_MemberSsn_NUMB = 0,
             @Lc_MotherDemo_Last_NAME = '',
             @Lc_MotherDemo_First_NAME = '',
             @Lc_MotherDemo_Middle_NAME = '',
             @Lc_MotherDemo_Suffix_NAME = '',
             @Ld_MotherDemo_Birth_DATE = @Ld_Low_DATE,
             @Ln_RowsCount_QNTY = 0,
             @Lb_UpdateMTRDemoVapp_BIT = 0,
             @Lc_EFTRCaseRelationship_CODE = '',
             @Ln_EstFatherDemo_MemberMci_IDNO = 0,
             @Ln_EstFatherDemo_MemberSsn_NUMB = 0,
             @Lc_EstFatherDemo_Last_NAME = '',
             @Lc_EstFatherDemo_First_NAME = '',
             @Lc_EstFatherDemo_Middle_NAME = '',
             @Lc_EstFatherDemo_Suffix_NAME = '',
             @Ld_EstFatherDemo_Birth_DATE = @Ld_Low_DATE,
             @Lb_UpdateFTRDemoVapp_BIT = 0,
             @Ln_VappCur_DisFatherMemberMci_IDNO = 0,
             @Lc_VappCur_DisFatherLast_NAME = '',
             @Lc_VappCur_DisFatherFirst_NAME = '',
             @Ld_VappCur_DisFatherBirth_DATE = @Ld_Low_DATE,
             @Ln_VappCur_DisFatherMemberSsn_NUMB = 0,
             @Ln_DisEstFatherDemo_MemberMci_IDNO = 0,
             @Lc_DisEstFatherDemo_Last_NAME = '',
             @Lc_DisEstFatherDemo_First_NAME = '',
             @Lc_DisEstFatherDemo_Middle_NAME = '',
             @Lc_DisEstFatherDemo_Suffix_NAME = '',
             @Lb_UpdateDFTRDemoVapp_BIT = 0,
             @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
             @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
             @Lc_StateDisestablish_CODE = '',
             @Lc_DisEstablishedFather_CODE = '',
             @Ld_UpdateEstDate_DATE = @Ld_Low_DATE,
             @Ld_Disestablish_DATE = @Ld_Low_DATE

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_ChildMemberMciIdno_TEXT))) = 1
       BEGIN
        SET @Ln_VappCur_ChildMemberMci_IDNO = CAST(@Lc_VappCur_ChildMemberMciIdno_TEXT AS NUMERIC);
       END
      ELSE
       BEGIN
        SET @Ln_VappCur_ChildMemberMci_IDNO = 0;
       END

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_ChildMemberSsnNumb_TEXT))) = 1
       BEGIN
        SET @Ln_VappCur_ChildMemberSsn_NUMB = CAST(@Lc_VappCur_ChildMemberSsnNumb_TEXT AS NUMERIC);
       END
      ELSE
       BEGIN
        SET @Ln_VappCur_ChildMemberSsn_NUMB = 0;
       END

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_FatherMemberMciIdno_TEXT))) = 1
       BEGIN
        SET @Ln_VappCur_FatherMemberMci_IDNO = CAST(@Lc_VappCur_FatherMemberMciIdno_TEXT AS NUMERIC);
       END
      ELSE
       BEGIN
        SET @Ln_VappCur_FatherMemberMci_IDNO = 0;
       END

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_FatherMemberSsnNumb_TEXT))) = 1
       BEGIN
        SET @Ln_VappCur_FatherMemberSsn_NUMB = CAST(@Lc_VappCur_FatherMemberSsnNumb_TEXT AS NUMERIC);
       END
      ELSE
       BEGIN
        SET @Ln_VappCur_FatherMemberSsn_NUMB = 0;
       END

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_MotherMemberMciIdno_TEXT))) = 1
       BEGIN
        SET @Ln_VappCur_MotherMemberMci_IDNO = CAST(@Lc_VappCur_MotherMemberMciIdno_TEXT AS NUMERIC);
       END
      ELSE
       BEGIN
        SET @Ln_VappCur_MotherMemberMci_IDNO = 0;
       END

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_MotherMemberSsnNumb_TEXT))) = 1
       BEGIN
        SET @Ln_VappCur_MotherMemberSsn_NUMB = CAST(@Lc_VappCur_MotherMemberSsnNumb_TEXT AS NUMERIC);
       END
      ELSE
       BEGIN
        SET @Ln_VappCur_MotherMemberSsn_NUMB = 0;
       END

      IF @Ln_VappCur_ChildMemberMci_IDNO > 0
         AND (ISNUMERIC(@Ln_VappCur_ChildMemberMci_IDNO) = 1
              AND EXISTS(SELECT 1
                           FROM DEMO_Y1 d
                          WHERE MemberMci_IDNO = @Ln_VappCur_ChildMemberMci_IDNO
                            AND EXISTS (SELECT 1
                                          FROM CMEM_Y1 X
                                         WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                           AND X.CaseRelationship_CODE = 'D'
                                           AND X.CaseMemberStatus_CODE = 'A')))
       BEGIN
        SET @Ls_Sql_TEXT = 'Select DEMO details of child';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_ChildMemberMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL('D', '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

        SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO
          FROM DEMO_Y1 d
         WHERE d.MemberMci_IDNO = @Ln_VappCur_ChildMemberMci_IDNO
           AND EXISTS (SELECT 1
                         FROM CMEM_Y1 X
                        WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                          AND X.CaseRelationship_CODE = 'D'
                          AND X.CaseMemberStatus_CODE = 'A');

        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 4; --MCI 				= 4 points

        INSERT INTO #CfpMatchPointQntyInfo_P1
                    (ChildBirthCertificate_ID,
                     ChildMemberMci_IDNO,
                     ChildDataMatchPoint_QNTY)
             VALUES ( @Lc_VappCur_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                      @Ln_VappCur_ChildMemberMci_IDNO,--ChildMemberMci_IDNO
                      @Li_ChildFirstProcessChildDataMatchPoint_QNTY --ChildDataMatchPoint_QNTY
        )
       END
      ELSE IF LEN(LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))) > 0
         AND (EXISTS (SELECT 1
                        FROM MPAT_Y1 m
                             JOIN DEMO_Y1 d
                              ON d.MemberMci_IDNO = m.MemberMci_IDNO
                       WHERE m.BirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID
                         AND EXISTS (SELECT 1
                                       FROM CMEM_Y1 X
                                      WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                        AND X.CaseRelationship_CODE = 'D'
                                        AND X.CaseMemberStatus_CODE = 'A')))
       BEGIN
        SET @Ls_Sql_TEXT = 'Select DEMO details of child';
        SET @Ls_Sqldata_TEXT = 'BirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', CaseRelationship_CODE = ' + ISNULL('D', '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

        SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO
          FROM DEMO_Y1 d
               JOIN MPAT_Y1 m
                ON d.MemberMci_IDNO = m.MemberMci_IDNO
         WHERE m.BirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID
           AND EXISTS (SELECT 1
                         FROM CMEM_Y1 X
                        WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                          AND X.CaseRelationship_CODE = 'D'
                          AND X.CaseMemberStatus_CODE = 'A');

        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 4; --Birth Certificate 			= 4 points

        INSERT INTO #CfpMatchPointQntyInfo_P1
                    (ChildBirthCertificate_ID,
                     ChildMemberMci_IDNO,
                     ChildDataMatchPoint_QNTY)
             VALUES ( @Lc_VappCur_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                      @Ln_ChildDemo_MemberMci_IDNO,--ChildMemberMci_IDNO
                      @Li_ChildFirstProcessChildDataMatchPoint_QNTY --ChildDataMatchPoint_QNTY
        )
       END
      ELSE IF @Ln_VappCur_ChildMemberSsn_NUMB > 0
         AND (ISNUMERIC(@Ln_VappCur_ChildMemberSsn_NUMB) = 1
              AND EXISTS (SELECT 1
                            FROM DEMO_Y1 d
                           WHERE d.MemberSsn_NUMB = @Ln_VappCur_ChildMemberSsn_NUMB
                             AND EXISTS (SELECT 1
                                           FROM CMEM_Y1 X
                                          WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                            AND X.CaseRelationship_CODE = 'D'
                                            AND X.CaseMemberStatus_CODE = 'A')))
       BEGIN
        SET @Ls_Sql_TEXT = 'Select DEMO details of child';
        SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_VappCur_ChildMemberSsn_NUMB AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL('D', '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

        SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO
          FROM DEMO_Y1 d
         WHERE d.MemberSsn_NUMB = @Ln_VappCur_ChildMemberSsn_NUMB
           AND EXISTS (SELECT 1
                         FROM CMEM_Y1 X
                        WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                          AND X.CaseRelationship_CODE = 'D'
                          AND X.CaseMemberStatus_CODE = 'A');

        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 4; --SSN 				= 4 points

        INSERT INTO #CfpMatchPointQntyInfo_P1
                    (ChildBirthCertificate_ID,
                     ChildMemberMci_IDNO,
                     ChildMemberSsn_NUMB,
                     ChildDataMatchPoint_QNTY)
             VALUES ( @Lc_VappCur_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                      @Ln_ChildDemo_MemberMci_IDNO,--ChildMemberMci_IDNO
                      @Ln_VappCur_ChildMemberSsn_NUMB,--ChildMemberSsn_NUMB
                      @Li_ChildFirstProcessChildDataMatchPoint_QNTY --ChildDataMatchPoint_QNTY
        )
       END
      ELSE IF (LEN(LTRIM(RTRIM(@Lc_VappCur_ChildLast_NAME))) > 0
          AND LEN(LTRIM(RTRIM(@Lc_VappCur_ChildFirst_NAME))) > 0
          AND @Ld_VappCur_ChildBirth_DATE NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
         AND 1 < (SELECT COUNT(DISTINCT(d.MemberMci_IDNO))
                    FROM DEMO_Y1 d
                   WHERE Last_NAME = @Lc_VappCur_ChildLast_NAME
                     AND First_NAME = @Lc_VappCur_ChildFirst_NAME
                     AND Birth_DATE = @Ld_VappCur_ChildBirth_DATE
                     AND EXISTS (SELECT 1
                                   FROM CMEM_Y1 X
                                  WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND X.CaseRelationship_CODE = 'D'
                                    AND X.CaseMemberStatus_CODE = 'A'))
       BEGIN
        SET @Lb_DemoMultipleMatch_BIT=1;

        DECLARE Demo_CUR INSENSITIVE CURSOR FOR
         SELECT d.MemberMci_IDNO
           FROM DEMO_Y1 d
          WHERE Last_NAME = @Lc_VappCur_ChildLast_NAME
            AND First_NAME = @Lc_VappCur_ChildFirst_NAME
            AND Birth_DATE = @Ld_VappCur_ChildBirth_DATE
            AND EXISTS (SELECT 1
                          FROM CMEM_Y1 X
                         WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                           AND X.CaseRelationship_CODE = 'D'
                           AND X.CaseMemberStatus_CODE = 'A');

        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 2; --DOB 				= 2 points
        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 2; --Last Name 				= 2 points
        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 1; --First Name				= 1 point		

        INSERT INTO #CfpMatchPointQntyInfo_P1
                    (ChildBirthCertificate_ID,
                     ChildLast_NAME,
                     ChildFirst_NAME,
                     ChildBirth_DATE,
                     ChildDataMatchPoint_QNTY)
             VALUES ( @Lc_VappCur_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                      @Lc_VappCur_ChildLast_NAME,--ChildLast_NAME
                      @Lc_VappCur_ChildFirst_NAME,--ChildFirst_NAME
                      @Ld_VappCur_ChildBirth_DATE,--ChildBirth_DATE
                      @Li_ChildFirstProcessChildDataMatchPoint_QNTY --ChildDataMatchPoint_QNTY
        )
       END
      ELSE IF (LEN(LTRIM(RTRIM(@Lc_VappCur_ChildLast_NAME))) > 0
          AND LEN(LTRIM(RTRIM(@Lc_VappCur_ChildFirst_NAME))) > 0
          AND @Ld_VappCur_ChildBirth_DATE NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
         AND 1 = (SELECT COUNT(DISTINCT(d.MemberMci_IDNO))
                    FROM DEMO_Y1 d
                   WHERE Last_NAME = @Lc_VappCur_ChildLast_NAME
                     AND First_NAME = @Lc_VappCur_ChildFirst_NAME
                     AND Birth_DATE = @Ld_VappCur_ChildBirth_DATE
                     AND EXISTS (SELECT 1
                                   FROM CMEM_Y1 X
                                  WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND X.CaseRelationship_CODE = 'D'
                                    AND X.CaseMemberStatus_CODE = 'A'))
       BEGIN
        SET @Lb_DemoMultipleMatch_BIT=0;
        SET @Ls_Sql_TEXT = 'Select DEMO details of child';
        SET @Ls_Sqldata_TEXT = 'Last_NAME = ' + ISNULL(@Lc_VappCur_ChildLast_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_VappCur_ChildFirst_NAME, '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_VappCur_ChildBirth_DATE AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL('D', '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

        SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO
          FROM DEMO_Y1 d
         WHERE Last_NAME = @Lc_VappCur_ChildLast_NAME
           AND First_NAME = @Lc_VappCur_ChildFirst_NAME
           AND Birth_DATE = @Ld_VappCur_ChildBirth_DATE
           AND EXISTS (SELECT 1
                         FROM CMEM_Y1 X
                        WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                          AND X.CaseRelationship_CODE = 'D'
                          AND X.CaseMemberStatus_CODE = 'A');

        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 2; --DOB 				= 2 points
        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 2; --Last Name 				= 2 points
        SET @Li_ChildFirstProcessChildDataMatchPoint_QNTY += 1; --First Name				= 1 point

        INSERT INTO #CfpMatchPointQntyInfo_P1
                    (ChildBirthCertificate_ID,
                     ChildMemberMci_IDNO,
                     ChildLast_NAME,
                     ChildFirst_NAME,
                     ChildBirth_DATE,
                     ChildDataMatchPoint_QNTY)
             VALUES ( @Lc_VappCur_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                      @Ln_ChildDemo_MemberMci_IDNO,--ChildMemberMci_IDNO
                      @Lc_VappCur_ChildLast_NAME,--ChildLast_NAME
                      @Lc_VappCur_ChildFirst_NAME,--ChildFirst_NAME
                      @Ld_VappCur_ChildBirth_DATE,--ChildBirth_DATE
                      @Li_ChildFirstProcessChildDataMatchPoint_QNTY --ChildDataMatchPoint_QNTY
        )
       END
      ELSE
       BEGIN
        GOTO PARENT_PROCESS;
       END

      IF(@Lb_DemoMultipleMatch_BIT = 1)
       BEGIN
        SELECT @Ln_DemoCur_MemberMci_IDNO = 0,
               @Li_DemoFetchStatus_QNTY = -1,
               @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
               @Lc_MatchFound_INDC = @Lc_No_INDC

        SET @Ls_Sql_TEXT ='OPEN Demo_CUR 1';

        OPEN Demo_CUR;

        SET @Ls_Sql_TEXT ='FETCH Demo_CUR 1';

        FETCH NEXT FROM Demo_CUR INTO @Ln_DemoCur_MemberMci_IDNO;

        SET @Li_DemoFetchStatus_QNTY = @@FETCH_STATUS;
        SET @Ls_Sql_TEXT ='WHILE Demo_CUR 1';

        --loop through the cursor...
        WHILE @Li_DemoFetchStatus_QNTY = 0
              AND @Lc_MatchFound_INDC = @Lc_No_INDC
         BEGIN
          IF EXISTS(SELECT 1
                      FROM #CfpMatchPointQntyInfo_P1 A
                     WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
                       AND A.ChildMemberMci_IDNO IS NULL)
           BEGIN
            UPDATE #CfpMatchPointQntyInfo_P1
               SET ChildMemberMci_IDNO = @Ln_DemoCur_MemberMci_IDNO
             WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
           END
          ELSE
           BEGIN
            INSERT INTO #CfpMatchPointQntyInfo_P1
                        (ChildBirthCertificate_ID,
                         ChildMemberMci_IDNO,
                         ChildLast_NAME,
                         ChildFirst_NAME,
                         ChildBirth_DATE,
                         ChildDataMatchPoint_QNTY)
            SELECT TOP 1 A.ChildBirthCertificate_ID,
                         @Ln_DemoCur_MemberMci_IDNO AS ChildMemberMci_IDNO,
                         A.ChildLast_NAME,
                         A.ChildFirst_NAME,
                         A.ChildBirth_DATE,
                         A.ChildDataMatchPoint_QNTY
              FROM #CfpMatchPointQntyInfo_P1 A
             WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
           END

          SELECT @Ln_CaseCur_Case_IDNO = 0,
                 @Li_CaseFetchStatus_QNTY = -1,
                 @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
                 @Lc_MatchFound_INDC = @Lc_No_INDC

          SET @Ls_Sql_TEXT ='SET Case_CUR 2';

          DECLARE Case_CUR INSENSITIVE CURSOR FOR
           SELECT c.Case_IDNO
             FROM CMEM_Y1 c
            WHERE c.MemberMci_IDNO = @Ln_DemoCur_MemberMci_IDNO
              AND c.CaseRelationship_CODE = 'D'
              AND c.CaseMemberStatus_CODE = 'A'
              AND EXISTS (SELECT 1
                            FROM CASE_Y1 X
                           WHERE X.Case_IDNO = c.Case_IDNO
                             AND X.StatusCase_CODE = 'O');

          SET @Ls_Sql_TEXT ='OPEN Case_CUR 2';

          OPEN Case_CUR;

          SET @Ls_Sql_TEXT ='FETCH Case_CUR 2';

          FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

          SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
          SET @Ls_Sql_TEXT ='WHILE Case_CUR 2';

          --loop through the cursor...
          WHILE @Li_CaseFetchStatus_QNTY = 0
                AND @Lc_MatchFound_INDC = @Lc_No_INDC
           BEGIN
            SELECT @Lc_Relation_CPRelationshipToChild_CODE = '',
                   @Lc_Relation_NCPRelationshipToChild_CODE = '',
                   @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
                   @Lc_MatchFound_INDC = @Lc_No_INDC

            SET @Ls_Sql_TEXT ='Select Child CMEM Details';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoCur_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_DepCaseRelationship_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

            SELECT @Lc_Relation_CPRelationshipToChild_CODE = c.CpRelationshipToChild_CODE,
                   @Lc_Relation_NCPRelationshipToChild_CODE = c.NcpRelationshipToChild_CODE
              FROM CMEM_Y1 c
             WHERE c.MemberMci_IDNO = @Ln_DemoCur_MemberMci_IDNO
               AND c.Case_IDNO = @Ln_CaseCur_Case_IDNO
               AND c.CaseRelationship_CODE = @Lc_DepCaseRelationship_CODE
               AND c.CaseMemberStatus_CODE = 'A';

            IF EXISTS(SELECT 1
                        FROM #CfpMatchPointQntyInfo_P1 A
                       WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
                         AND A.ChildMemberMci_IDNO = @Ln_DemoCur_MemberMci_IDNO
                         AND A.ChildCase_IDNO IS NULL)
             BEGIN
              UPDATE #CfpMatchPointQntyInfo_P1
                 SET ChildCase_IDNO = @Ln_CaseCur_Case_IDNO,
                     CpRelationshipToChild_CODE = @Lc_Relation_CPRelationshipToChild_CODE,
                     NcpRelationshipToChild_CODE = @Lc_Relation_NCPRelationshipToChild_CODE
               WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
                 AND ChildMemberMci_IDNO = @Ln_DemoCur_MemberMci_IDNO
             END
            ELSE
             BEGIN
              INSERT INTO #CfpMatchPointQntyInfo_P1
                          (ChildBirthCertificate_ID,
                           ChildMemberMci_IDNO,
                           ChildLast_NAME,
                           ChildFirst_NAME,
                           ChildBirth_DATE,
                           ChildCase_IDNO,
                           CpRelationshipToChild_CODE,
                           NcpRelationshipToChild_CODE,
                           ChildDataMatchPoint_QNTY)
              SELECT TOP 1 A.ChildBirthCertificate_ID,
                           A.ChildMemberMci_IDNO,
                           A.ChildLast_NAME,
                           A.ChildFirst_NAME,
                           A.ChildBirth_DATE,
                           @Ln_CaseCur_Case_IDNO AS ChildCase_IDNO,
                           @Lc_Relation_CPRelationshipToChild_CODE AS CpRelationshipToChild_CODE,
                           @Lc_Relation_NCPRelationshipToChild_CODE AS NcpRelationshipToChild_CODE,
                           A.ChildDataMatchPoint_QNTY
                FROM #CfpMatchPointQntyInfo_P1 A
               WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
                 AND A.ChildMemberMci_IDNO = @Ln_DemoCur_MemberMci_IDNO
             END

            SELECT @Ln_ParentsCur_MemberMci_IDNO = 0,
                   @Lc_ParentsCur_CaseRelationship_CODE = '',
                   @Lc_ParentsCur_MemberSex_CODE = '',
                   @Li_ParentFetchStatus_QNTY = -1,
                   @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
                   @Lc_MatchFound_INDC = @Lc_No_INDC

              SELECT @Lc_MTRCaseRelationship_CODE = '',
                     @Ln_MotherDemo_MemberMci_IDNO = 0,
                     @Ln_MotherDemo_MemberSsn_NUMB = 0,
                     @Lc_MotherDemo_Last_NAME = '',
                     @Lc_MotherDemo_First_NAME = '',
                     @Lc_MotherDemo_Middle_NAME = '',
                     @Lc_MotherDemo_Suffix_NAME = '',
                     @Ld_MotherDemo_Birth_DATE = @Ld_Low_DATE,
                     @Ln_RowsCount_QNTY = 0,
                     @Lb_UpdateMTRDemoVapp_BIT = 0,
                     @Lc_EFTRCaseRelationship_CODE = '',
                     @Ln_EstFatherDemo_MemberMci_IDNO = 0,
                     @Ln_EstFatherDemo_MemberSsn_NUMB = 0,
                     @Lc_EstFatherDemo_Last_NAME = '',
                     @Lc_EstFatherDemo_First_NAME = '',
                     @Lc_EstFatherDemo_Middle_NAME = '',
                     @Lc_EstFatherDemo_Suffix_NAME = '',
                     @Ld_EstFatherDemo_Birth_DATE = @Ld_Low_DATE,
                     @Lb_UpdateFTRDemoVapp_BIT = 0,
                     @Ln_VappCur_DisFatherMemberMci_IDNO = 0,
                     @Lc_VappCur_DisFatherLast_NAME = '',
                     @Lc_VappCur_DisFatherFirst_NAME = '',
                     @Ld_VappCur_DisFatherBirth_DATE = @Ld_Low_DATE,
                     @Ln_VappCur_DisFatherMemberSsn_NUMB = 0,
                     @Ln_DisEstFatherDemo_MemberMci_IDNO = 0,
                     @Lc_DisEstFatherDemo_Last_NAME = '',
                     @Lc_DisEstFatherDemo_First_NAME = '',
                     @Lc_DisEstFatherDemo_Middle_NAME = '',
                     @Lc_DisEstFatherDemo_Suffix_NAME = '',
                     @Lb_UpdateDFTRDemoVapp_BIT = 0,
                     @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                     @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                     @Lc_StateDisestablish_CODE = '',
                     @Lc_DisEstablishedFather_CODE = '',
                     @Ld_UpdateEstDate_DATE = @Ld_Low_DATE,
                     @Ld_Disestablish_DATE = @Ld_Low_DATE
                     
            SET @Ls_Sql_TEXT ='SET Parents_CUR 2';

            DECLARE Parents_CUR INSENSITIVE CURSOR FOR
             SELECT c.MemberMci_IDNO,
                    c.CaseRelationship_CODE,
                    d.MemberSex_CODE
               FROM CMEM_Y1 c
                    JOIN DEMO_Y1 d
                     ON c.MemberMci_IDNO = d.MemberMci_IDNO
              WHERE Case_IDNO = @Ln_CaseCur_Case_IDNO
                AND CaseRelationship_CODE IN (@Lc_CPCaseRelationship_CODE, @Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
                AND CaseMemberStatus_CODE = 'A';

            SET @Ls_Sql_TEXT ='OPEN Parents_CUR 2';

            OPEN Parents_CUR;

            SET @Ls_Sql_TEXT ='FETCH Parents_CUR 2';

            FETCH NEXT FROM Parents_CUR INTO @Ln_ParentsCur_MemberMci_IDNO, @Lc_ParentsCur_CaseRelationship_CODE, @Lc_ParentsCur_MemberSex_CODE;

            SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
            SET @Ls_Sql_TEXT ='WHILE Parent_CUR 2';

            --loop through the cursor...
            WHILE @Li_ParentFetchStatus_QNTY = 0
             BEGIN
              IF(@Lc_Relation_CPRelationshipToChild_CODE = @Lc_Relation_Mother_CODE
                 AND @Lc_ParentsCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
                 AND @Lc_ParentsCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
               BEGIN
                SET @Lc_MTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;
                SET @Ls_Sql_TEXT ='Select Mother details from DEMO 2';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                       @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                       @Lc_MotherDemo_First_NAME = d.First_NAME,
                       @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                       @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateMTRDemoVapp_BIT = 1;
                 END
               END
              ELSE IF(@Lc_Relation_CPRelationshipToChild_CODE = @Lc_Relation_Father_CODE
                 AND @Lc_ParentsCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
                 AND @Lc_ParentsCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
               BEGIN
                SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;

                IF(@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
                 BEGIN
                  SET @Ls_Sql_TEXT ='Select EstFather details from DEMO 2';
                  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                  SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                         @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                         @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                         @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                         @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                         @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                         @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                    FROM DEMO_Y1 d
                   WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                  SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                  IF(@Ln_RowsCount_QNTY = 0)
                   BEGIN
                    SET @Lb_UpdateFTRDemoVapp_BIT=1;
                   END

                  SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Child First Process 2';
                  SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

                  SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                         @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                         @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                         @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                         @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
                    FROM VAPP_Y1 v
                   WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID
                     AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

                  SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 2';
                  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

                  SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                         @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                         @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                         @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                         @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
                    FROM DEMO_Y1 d
                   WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

                  SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                  IF(@Ln_RowsCount_QNTY = 0)
                   BEGIN
                    SET @Lb_UpdateDFTRDemoVapp_BIT =1;
                   END
                 END
                ELSE IF (@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
                 BEGIN
                  SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 3';
                  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                  SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                         @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                         @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                         @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                         @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                         @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                         @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                    FROM DEMO_Y1 d
                   WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                  SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                  IF(@Ln_RowsCount_QNTY = 0)
                   BEGIN
                    SET @Lb_UpdateFTRDemoVapp_BIT=1;
                   END
                 END
               END

              IF(@Lc_Relation_NCPRelationshipToChild_CODE = @Lc_Relation_Mother_CODE
                 AND @Lc_ParentsCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
                 AND @Lc_ParentsCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
               BEGIN
                SET @Lc_MTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;
                SET @Ls_Sql_TEXT ='Select Mother details from DEMO 3';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                       @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                       @Lc_MotherDemo_First_NAME = d.First_NAME,
                       @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                       @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateMTRDemoVapp_BIT =1;
                 END
               END
              ELSE IF(@Lc_Relation_NCPRelationshipToChild_CODE = @Lc_Relation_Father_CODE
                 AND @Lc_ParentsCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
                 AND @Lc_ParentsCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
               BEGIN
                SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;

                IF(@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
                 BEGIN
                  SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 4';
                  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                  SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                         @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                         @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                         @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                         @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                         @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                         @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                    FROM DEMO_Y1 d
                   WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                  SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                  IF(@Ln_RowsCount_QNTY = 0)
                   BEGIN
                    SET @Lb_UpdateFTRDemoVapp_BIT=1;
                   END

                  SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Child First Process 3';
                  SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

                  SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                         @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                         @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                         @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                         @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
                    FROM VAPP_Y1 v
                   WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID
                     AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

                  SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 3';
                  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

                  SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                         @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                         @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                         @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                         @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
                    FROM DEMO_Y1 d
                   WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

                  SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                  IF(@Ln_RowsCount_QNTY = 0)
                   BEGIN
                    SET @Lb_UpdateDFTRDemoVapp_BIT =1;
                   END
                 END
                ELSE IF (@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
                 BEGIN
                  SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 5';
                  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                  SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                         @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                         @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                         @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                         @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                         @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                         @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                    FROM DEMO_Y1 d
                   WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                  SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                  IF(@Ln_RowsCount_QNTY = 0)
                   BEGIN
                    SET @Lb_UpdateFTRDemoVapp_BIT=1;
                   END
                 END
               END

              SET @Ls_Sql_TEXT ='FETCH NEXT @Parent_CUR 2';

              FETCH NEXT FROM Parents_CUR INTO @Ln_ParentsCur_MemberMci_IDNO, @Lc_ParentsCur_CaseRelationship_CODE, @Lc_ParentsCur_MemberSex_CODE;

              SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
             END

            CLOSE Parents_CUR;

            DEALLOCATE Parents_CUR;

            SET @Ls_Sql_TEXT ='Verify NCP Mother details with DEMO in Child First Process 2';

            IF((ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) > 0
                 OR ISNULL(@Ln_VappCur_MotherMemberMci_IDNO, 0) > 0)
               AND @Ln_MotherDemo_MemberMci_IDNO = @Ln_VappCur_MotherMemberMci_IDNO)
             BEGIN
              SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Mother MCI 			= 4 points
             END
            ELSE IF ((ISNULL(@Ln_MotherDemo_MemberSsn_NUMB, 0) > 0
                  OR ISNULL(@Ln_VappCur_MotherMemberSsn_NUMB, 0) > 0)
                AND @Ln_MotherDemo_MemberSsn_NUMB = @Ln_VappCur_MotherMemberSsn_NUMB)
             BEGIN
              SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Mother SSN 			= 4 points				
             END
            ELSE
             BEGIN
              IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) > 0
                   OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherLast_NAME, '')))) > 0)
                 AND @Lc_MotherDemo_Last_NAME = @Lc_VappCur_MotherLast_NAME
               BEGIN
                SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Mother Last Name 			= 2 points
               END

              IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) > 0
                   OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherFirst_NAME, '')))) > 0)
                 AND @Lc_MotherDemo_First_NAME = @Lc_VappCur_MotherFirst_NAME
               BEGIN
                SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 1; --Mother First Name			= 1 point
               END

              IF (ISNULL(@Ld_MotherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                   OR ISNULL(@Ld_VappCur_MotherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
                 AND @Ld_MotherDemo_Birth_DATE = @Ld_VappCur_MotherBirth_DATE
               BEGIN
                SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Mother DOB 			= 2 points
               END
             END;

            SET @Ls_Sql_TEXT ='Verify NCP EstFather details with DEMO in Child First Process 2';

            IF((ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) > 0
                 OR ISNULL(@Ln_VappCur_FatherMemberMci_IDNO, 0) > 0)
               AND @Ln_EstFatherDemo_MemberMci_IDNO = @Ln_VappCur_FatherMemberMci_IDNO)
             BEGIN
              SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Father MCI	 			= 4 points
             END
            ELSE IF ((ISNULL(@Ln_EstFatherDemo_MemberSsn_NUMB, 0) > 0
                  OR ISNULL(@Ln_VappCur_FatherMemberSsn_NUMB, 0) > 0)
                AND @Ln_EstFatherDemo_MemberSsn_NUMB = @Ln_VappCur_FatherMemberSsn_NUMB)
             BEGIN
              SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Father SSN 			= 4 points					
             END
            ELSE
             BEGIN
              IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) > 0
                   OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherLast_NAME, '')))) > 0)
                 AND @Lc_EstFatherDemo_Last_NAME = @Lc_VappCur_FatherLast_NAME
               BEGIN
                SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Father Last Name 			= 2 points
               END

              IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) > 0
                   OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherFirst_NAME, '')))) > 0)
                 AND @Lc_EstFatherDemo_First_NAME = @Lc_VappCur_FatherFirst_NAME
               BEGIN
                SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 1; --Father First Name			= 1 point
               END

              IF (ISNULL(@Ld_EstFatherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                   OR ISNULL(@Ld_VappCur_FatherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
                 AND @Ld_EstFatherDemo_Birth_DATE = @Ld_VappCur_FatherBirth_DATE
               BEGIN
                SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Father DOB 			= 2 points
               END
             END;

            UPDATE #CfpMatchPointQntyInfo_P1
               SET ParentDataMatchPoint_QNTY = @Li_ChildFirstProcessParentDataMatchPoint_QNTY
             WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
               AND ChildMemberMci_IDNO = @Ln_DemoCur_MemberMci_IDNO
               AND ChildCase_IDNO = @Ln_CaseCur_Case_IDNO

            IF (@Li_ChildFirstProcessChildDataMatchPoint_QNTY >= 4
                AND @Li_ChildFirstProcessParentDataMatchPoint_QNTY >= 4)
             BEGIN
              SET @Lc_MatchFound_INDC = 'Y';
              SET @Ls_Sql_TEXT = 'UPDATE #VappMappPointQntyInfo_P1 - 1'
              SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

              UPDATE #VappMappPointQntyInfo_P1
                 SET ChildFirstProcessChildDataMatchPoint_QNTY = @Li_ChildFirstProcessChildDataMatchPoint_QNTY,
                     ChildFirstProcessParentDataMatchPoint_QNTY = @Li_ChildFirstProcessParentDataMatchPoint_QNTY,
                     MatchFound_INDC = @Lc_MatchFound_INDC
               WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;

              IF(@Lb_UpdateMTRDemoVapp_BIT = 1)
               BEGIN
                SET @Ln_MotherDemo_MemberMci_IDNO = @Ln_VappCur_MotherMemberMci_IDNO;
                SET @Lc_MotherDemo_Last_NAME = @Lc_VappCur_MotherLast_NAME;
                SET @Lc_MotherDemo_First_NAME = @Lc_VappCur_MotherFirst_NAME;
                SET @Lc_MotherDemo_Middle_NAME = @Lc_Empty_TEXT;
                SET @Lc_MotherDemo_Suffix_NAME = @Lc_Empty_TEXT;
               END

              IF(@Lb_UpdateFTRDemoVapp_BIT = 1)
               BEGIN
                SET @Ln_EstFatherDemo_MemberMci_IDNO = @Ln_VappCur_FatherMemberMci_IDNO;
                SET @Lc_EstFatherDemo_Last_NAME = @Lc_VappCur_FatherLast_NAME;
                SET @Lc_EstFatherDemo_First_NAME = @Lc_VappCur_FatherFirst_NAME;
                SET @Lc_EstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
                SET @Lc_EstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
               END

              IF(@Lb_UpdateDFTRDemoVapp_BIT = 1)
               BEGIN
                SET @Ln_DisEstFatherDemo_MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;
                SET @Lc_DisEstFatherDemo_Last_NAME = @Lc_VappCur_DisFatherLast_NAME;
                SET @Lc_DisEstFatherDemo_First_NAME = @Lc_VappCur_DisFatherFirst_NAME;
                SET @Lc_DisEstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
                SET @Lc_DisEstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
               END

              IF NOT EXISTS(SELECT 1
                              FROM VAPP_Y1
                             WHERE TypeDocument_CODE = @Lc_DopTypeDocument_CODE
                               AND ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID)
               BEGIN
                SELECT @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                       @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                       @Lc_StateDisestablish_CODE = ' ';
               END
              ELSE
               BEGIN
                SET @Ls_Sql_TEXT = 'SET UPDATE MATCH DATA - 1'
                SET @Ls_Sqldata_TEXT = 'TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

                SELECT @Ld_DOPMotherSig_DATE = v.MotherSignature_DATE,
                       @Ld_DOPFatherSig_DATE = v.FatherSignature_DATE,
                       @Lc_StateDisestablish_CODE = 'DE',
                       @Lc_DisEstablishedFather_CODE = CASE
                                                        WHEN @Lb_UpdateDFTRDemoVapp_BIT = 1
                                                         THEN
                                                         CASE
                                                          WHEN ISNULL(v.FatherMemberMci_IDNO, 0) > 0
                                                           THEN
                                                           CASE
                                                            WHEN EXISTS (SELECT 1
                                                                           FROM CMEM_Y1 A
                                                                          WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                             THEN (SELECT ISNULL(A.CaseRelationship_CODE, 'O')
                                                                     FROM CMEM_Y1 A
                                                                    WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                            ELSE 'O'
                                                           END
                                                          ELSE 'O'
                                                         END
                                                        ELSE ' '
                                                       END
                  FROM VAPP_Y1 v
                 WHERE v.TypeDocument_CODE = @Lc_DopTypeDocument_CODE
                   AND v.ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;
               END

              IF(@Ld_VappCur_MotherSignature_DATE > @Ld_VappCur_FatherSignature_DATE)
               BEGIN
                SET @Ld_UpdateEstDate_DATE = @Ld_VappCur_MotherSignature_DATE;
               END
              ELSE
               SET @Ld_UpdateEstDate_DATE = @Ld_VappCur_FatherSignature_DATE;

              IF(@Ld_DOPMotherSig_DATE > @Ld_DOPFatherSig_DATE)
               BEGIN
                IF(@Ld_DOPMotherSig_DATE > @Ld_UpdateEstDate_DATE)
                 BEGIN
                  SET @Ld_UpdateEstDate_DATE = @Ld_DOPMotherSig_DATE;
                 END

                SET @Ld_Disestablish_DATE = @Ld_DOPMotherSig_DATE;
               END
              ELSE
               BEGIN
                IF(@Ld_DOPFatherSig_DATE > @Ld_UpdateEstDate_DATE)
                 BEGIN
                  SET @Ld_UpdateEstDate_DATE = @Ld_DOPFatherSig_DATE;
                 END

                SET @Ld_Disestablish_DATE = @Ld_DOPFatherSig_DATE;
               END

              SELECT @Ln_EstFatherDemo_MemberMci_IDNO = CASE
                                                         WHEN ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) = 0
                                                          THEN @Ln_VappCur_FatherMemberMci_IDNO
                                                         ELSE @Ln_EstFatherDemo_MemberMci_IDNO
                                                        END,
                     @Lc_EstFatherDemo_Last_NAME = CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) = 0
                                                     THEN @Lc_VappCur_FatherLast_NAME
                                                    ELSE @Lc_EstFatherDemo_Last_NAME
                                                   END,
                     @Lc_EstFatherDemo_First_NAME = CASE
                                                     WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) = 0
                                                      THEN @Lc_VappCur_FatherFirst_NAME
                                                     ELSE @Lc_EstFatherDemo_First_NAME
                                                    END,
                     @Lc_EstFatherDemo_Middle_NAME = CASE
                                                      WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Middle_NAME, '')))) = 0
                                                       THEN @Lc_Empty_TEXT
                                                      ELSE @Lc_EstFatherDemo_Middle_NAME
                                                     END,
                     @Lc_EstFatherDemo_Suffix_NAME = CASE
                                                      WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '')))) = 0
                                                       THEN @Lc_Empty_TEXT
                                                      ELSE @Lc_EstFatherDemo_Suffix_NAME
                                                     END,
                     @Lc_EFTRCaseRelationship_CODE = CASE
                                                      WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EFTRCaseRelationship_CODE, '')))) = 0
                                                       THEN 'O'
                                                      ELSE @Lc_EFTRCaseRelationship_CODE
                                                     END,
                     @Ln_MotherDemo_MemberMci_IDNO = CASE
                                                      WHEN ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) = 0
                                                       THEN @Ln_VappCur_MotherMemberMci_IDNO
                                                      ELSE @Ln_MotherDemo_MemberMci_IDNO
                                                     END,
                     @Lc_MotherDemo_Last_NAME = CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) = 0
                                                  THEN @Lc_VappCur_MotherLast_NAME
                                                 ELSE @Lc_MotherDemo_Last_NAME
                                                END,
                     @Lc_MotherDemo_First_NAME = CASE
                                                  WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) = 0
                                                   THEN @Lc_VappCur_MotherFirst_NAME
                                                  ELSE @Lc_MotherDemo_First_NAME
                                                 END,
                     @Lc_MotherDemo_Middle_NAME = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Middle_NAME, '')))) = 0
                                                    THEN @Lc_Empty_TEXT
                                                   ELSE @Lc_MotherDemo_Middle_NAME
                                                  END,
                     @Lc_MotherDemo_Suffix_NAME = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Suffix_NAME, '')))) = 0
                                                    THEN @Lc_Empty_TEXT
                                                   ELSE @Lc_MotherDemo_Suffix_NAME
                                                  END,
                     @Lc_MTRCaseRelationship_CODE = CASE
                                                     WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MTRCaseRelationship_CODE, '')))) = 0
                                                      THEN 'O'
                                                     ELSE @Lc_MTRCaseRelationship_CODE
                                                    END,
                     @Ln_DisEstFatherDemo_MemberMci_IDNO = CASE
                                                            WHEN ISNULL(@Ln_DisEstFatherDemo_MemberMci_IDNO, 0) = 0
                                                             THEN @Ln_VappCur_DisFatherMemberMci_IDNO
                                                            ELSE @Ln_DisEstFatherDemo_MemberMci_IDNO
                                                           END,
                     @Lc_DisEstFatherDemo_Last_NAME = CASE
                                                       WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '')))) = 0
                                                        THEN @Lc_VappCur_DisFatherLast_NAME
                                                       ELSE @Lc_DisEstFatherDemo_Last_NAME
                                                      END,
                     @Lc_DisEstFatherDemo_First_NAME = CASE
                                                        WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_First_NAME, '')))) = 0
                                                         THEN @Lc_VappCur_DisFatherFirst_NAME
                                                        ELSE @Lc_DisEstFatherDemo_First_NAME
                                                       END,
                     @Lc_DisEstFatherDemo_Middle_NAME = CASE
                                                         WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '')))) = 0
                                                          THEN @Lc_Empty_TEXT
                                                         ELSE @Lc_DisEstFatherDemo_Middle_NAME
                                                        END,
                     @Lc_DisEstFatherDemo_Suffix_NAME = CASE
                                                         WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '')))) = 0
                                                          THEN @Lc_Empty_TEXT
                                                         ELSE @Lc_DisEstFatherDemo_Suffix_NAME
                                                        END

              SET @Ls_Sql_TEXT = 'BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH - 1';
              SET @Ls_Sqldata_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@Ln_DemoCur_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_EstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DisEstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_DisEstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedMotherMci_IDNO = ' + ISNULL(CAST(@Ln_MotherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DopAttached_CODE = ' + ISNULL(@Lc_VappCur_DopAttached_CODE, '') + ', EstablishedMother_CODE = ' + ISNULL(@Lc_MTRCaseRelationship_CODE, '') + ', EstablishedFather_CODE = ' + ISNULL(@Lc_EFTRCaseRelationship_CODE, '') + ', DisEstablishedFather_CODE = ' + ISNULL(@Lc_DisEstablishedFather_CODE, '') + ', EstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '') + ', DisEstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '') + ', EstablishedMotherSuffix_NAME = ' + ISNULL(@Lc_MotherDemo_Suffix_NAME, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', EstablishedFatherFirst_NAME = ' + ISNULL(@Lc_EstFatherDemo_First_NAME, '') + ', DisEstablishedFatherFirst_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_First_NAME, '') + ', EstablishedMotherFirst_NAME = ' + ISNULL(@Lc_MotherDemo_First_NAME, '') + ', EstablishedFatherLast_NAME = ' + ISNULL(@Lc_EstFatherDemo_Last_NAME, '') + ', EstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_EstFatherDemo_Middle_NAME, '') + ', DisEstablishedFatherLast_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '') + ', DisEstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '') + ', EstablishedMotherLast_NAME = ' + ISNULL(@Lc_MotherDemo_Last_NAME, '') + ', EstablishedMotherMiddle_NAME = ' + ISNULL(@Lc_MotherDemo_Middle_NAME, '') + ', PaternityEst_DATE = ' + ISNULL(CAST(@Ld_UpdateEstDate_DATE AS VARCHAR), '') + ', Disestablish_DATE = ' + ISNULL(CAST(@Ld_Disestablish_DATE AS VARCHAR), '') + ', StateDisestablish_CODE = ' + ISNULL(@Lc_StateDisestablish_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

              EXECUTE BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH
               @Ac_Job_ID                          = @Lc_Job_ID,
               @An_ChildMemberMci_IDNO             = @Ln_DemoCur_MemberMci_IDNO,
               @An_EstablishedFatherMci_IDNO       = @Ln_EstFatherDemo_MemberMci_IDNO,
               @An_DisEstablishedFatherMci_IDNO    = @Ln_DisEstFatherDemo_MemberMci_IDNO,
               @An_EstablishedMotherMci_IDNO       = @Ln_MotherDemo_MemberMci_IDNO,
               @Ac_DopAttached_CODE                = @Lc_VappCur_DopAttached_CODE,
               @Ac_EstablishedMother_CODE          = @Lc_MTRCaseRelationship_CODE,
               @Ac_EstablishedFather_CODE          = @Lc_EFTRCaseRelationship_CODE,
               @Ac_DisEstablishedFather_CODE       = @Lc_DisEstablishedFather_CODE,
               @Ac_EstablishedFatherSuffix_NAME    = @Lc_EstFatherDemo_Suffix_NAME,
               @Ac_DisEstablishedFatherSuffix_NAME = @Lc_DisEstFatherDemo_Suffix_NAME,
               @Ac_EstablishedMotherSuffix_NAME    = @Lc_MotherDemo_Suffix_NAME,
               @Ac_ChildBirthCertificate_ID        = @Lc_VappCur_ChildBirthCertificate_ID,
               @Ac_EstablishedFatherFirst_NAME     = @Lc_EstFatherDemo_First_NAME,
               @Ac_DisEstablishedFatherFirst_NAME  = @Lc_DisEstFatherDemo_First_NAME,
               @Ac_EstablishedMotherFirst_NAME     = @Lc_MotherDemo_First_NAME,
               @Ac_EstablishedFatherLast_NAME      = @Lc_EstFatherDemo_Last_NAME,
               @Ac_EstablishedFatherMiddle_NAME    = @Lc_EstFatherDemo_Middle_NAME,
               @Ac_DisEstablishedFatherLast_NAME   = @Lc_DisEstFatherDemo_Last_NAME,
               @Ac_DisEstablishedFatherMiddle_NAME = @Lc_DisEstFatherDemo_Middle_NAME,
               @Ac_EstablishedMotherLast_NAME      = @Lc_MotherDemo_Last_NAME,
               @Ac_EstablishedMotherMiddle_NAME    = @Lc_MotherDemo_Middle_NAME,
               @Ad_PaternityEst_DATE               = @Ld_UpdateEstDate_DATE,
               @Ad_Disestablish_DATE               = @Ld_Disestablish_DATE,
               @Ac_StateDisestablish_CODE          = @Lc_StateDisestablish_CODE,
               @Ad_Run_DATE                        = @Ld_Run_DATE,
               @Ac_Msg_CODE                        = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT           = @Ls_DescriptionError_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

                RAISERROR(50001,16,1);
               END

              CLOSE Case_CUR;

              DEALLOCATE Case_CUR;

              CLOSE Demo_CUR;

              DEALLOCATE Demo_CUR;

              GOTO EXIT_CFP_DUPLICATE_LOOP;
             END

            SET @Ls_Sql_TEXT ='FETCH NEXT Case_CUR 2';

            FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

            SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
           END

          CLOSE Case_CUR;

          DEALLOCATE Case_CUR;

          SET @Ls_Sql_TEXT ='FETCH NEXT Demo_CUR 2';

          FETCH NEXT FROM Demo_CUR INTO @Ln_DemoCur_MemberMci_IDNO;

          SET @Li_DemoFetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE Demo_CUR;

        DEALLOCATE Demo_CUR;

        EXIT_CFP_DUPLICATE_LOOP:;

        SET @Ls_Sql_TEXT = 'SELECT #VappMappPointQntyInfo_P1';
        SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

        SELECT @Li_ChildFirstProcessChildDataMatchPoint_QNTY = A.ChildFirstProcessChildDataMatchPoint_QNTY,
               @Li_ChildFirstProcessParentDataMatchPoint_QNTY = A.ChildFirstProcessParentDataMatchPoint_QNTY,
               @Lc_MatchFound_INDC = A.MatchFound_INDC
          FROM #VappMappPointQntyInfo_P1 A
         WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;

        IF @Lc_MatchFound_INDC = 'Y'
           AND @Li_ChildFirstProcessChildDataMatchPoint_QNTY >= 4
           AND @Li_ChildFirstProcessParentDataMatchPoint_QNTY >= 4
         BEGIN
          GOTO NEXT_RECORD;
         END
        ELSE
         BEGIN
          GOTO PARENT_PROCESS;
         END;
       END
      ELSE
       BEGIN
        SELECT @Ln_CaseCur_Case_IDNO = 0,
               @Li_CaseFetchStatus_QNTY = -1,
               @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
               @Lc_MatchFound_INDC = @Lc_No_INDC

        SET @Ls_Sql_TEXT ='SET Case_CUR 2';

        DECLARE Case_CUR INSENSITIVE CURSOR FOR
         SELECT c.Case_IDNO
           FROM CMEM_Y1 c
          WHERE c.MemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO
            AND c.CaseRelationship_CODE = 'D'
            AND c.CaseMemberStatus_CODE = 'A'
            AND EXISTS (SELECT 1
                          FROM CASE_Y1 X
                         WHERE X.Case_IDNO = c.Case_IDNO
                           AND X.StatusCase_CODE = 'O');

        SET @Ls_Sql_TEXT ='OPEN Case_CUR 2';

        OPEN Case_CUR;

        SET @Ls_Sql_TEXT ='FETCH Case_CUR 2';

        FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

        SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
        SET @Ls_Sql_TEXT ='WHILE Case_CUR 2';

        --loop through the cursor...
        WHILE @Li_CaseFetchStatus_QNTY = 0
              AND @Lc_MatchFound_INDC = @Lc_No_INDC
         BEGIN
          SELECT @Lc_Relation_CPRelationshipToChild_CODE = '',
                 @Lc_Relation_NCPRelationshipToChild_CODE = '',
                 @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
                 @Lc_MatchFound_INDC = @Lc_No_INDC

          SET @Ls_Sql_TEXT ='Select Child CMEM Details';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildDemo_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_DepCaseRelationship_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

          SELECT @Lc_Relation_CPRelationshipToChild_CODE = c.CpRelationshipToChild_CODE,
                 @Lc_Relation_NCPRelationshipToChild_CODE = c.NcpRelationshipToChild_CODE
            FROM CMEM_Y1 c
           WHERE c.MemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO
             AND c.Case_IDNO = @Ln_CaseCur_Case_IDNO
             AND c.CaseRelationship_CODE = @Lc_DepCaseRelationship_CODE
             AND c.CaseMemberStatus_CODE = 'A';

          IF EXISTS(SELECT 1
                      FROM #CfpMatchPointQntyInfo_P1 A
                     WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
                       AND A.ChildMemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO
                       AND A.ChildCase_IDNO IS NULL)
           BEGIN
            UPDATE #CfpMatchPointQntyInfo_P1
               SET ChildCase_IDNO = @Ln_CaseCur_Case_IDNO,
                   CpRelationshipToChild_CODE = @Lc_Relation_CPRelationshipToChild_CODE,
                   NcpRelationshipToChild_CODE = @Lc_Relation_NCPRelationshipToChild_CODE
             WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
               AND ChildMemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO
           END
          ELSE
           BEGIN
            INSERT INTO #CfpMatchPointQntyInfo_P1
                        (ChildBirthCertificate_ID,
                         ChildMemberMci_IDNO,
                         ChildLast_NAME,
                         ChildFirst_NAME,
                         ChildBirth_DATE,
                         ChildMemberSsn_NUMB,
                         ChildCase_IDNO,
                         CpRelationshipToChild_CODE,
                         NcpRelationshipToChild_CODE,
                         ChildDataMatchPoint_QNTY)
            SELECT TOP 1 A.ChildBirthCertificate_ID,
                         A.ChildMemberMci_IDNO,
                         A.ChildLast_NAME,
                         A.ChildFirst_NAME,
                         A.ChildBirth_DATE,
                         A.ChildMemberSsn_NUMB,
                         @Ln_CaseCur_Case_IDNO AS ChildCase_IDNO,
                         @Lc_Relation_CPRelationshipToChild_CODE AS CpRelationshipToChild_CODE,
                         @Lc_Relation_NCPRelationshipToChild_CODE AS NcpRelationshipToChild_CODE,
                         A.ChildDataMatchPoint_QNTY
              FROM #CfpMatchPointQntyInfo_P1 A
             WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
               AND A.ChildMemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO
           END

          SELECT @Ln_ParentsCur_MemberMci_IDNO = 0,
                 @Lc_ParentsCur_CaseRelationship_CODE = '',
                 @Lc_ParentsCur_MemberSex_CODE = '',
                 @Li_ParentFetchStatus_QNTY = -1,
                 @Li_ChildFirstProcessParentDataMatchPoint_QNTY = 0,
                 @Lc_MatchFound_INDC = @Lc_No_INDC

            SELECT @Lc_MTRCaseRelationship_CODE = '',
                   @Ln_MotherDemo_MemberMci_IDNO = 0,
                   @Ln_MotherDemo_MemberSsn_NUMB = 0,
                   @Lc_MotherDemo_Last_NAME = '',
                   @Lc_MotherDemo_First_NAME = '',
                   @Lc_MotherDemo_Middle_NAME = '',
                   @Lc_MotherDemo_Suffix_NAME = '',
                   @Ld_MotherDemo_Birth_DATE = @Ld_Low_DATE,
                   @Ln_RowsCount_QNTY = 0,
                   @Lb_UpdateMTRDemoVapp_BIT = 0,
                   @Lc_EFTRCaseRelationship_CODE = '',
                   @Ln_EstFatherDemo_MemberMci_IDNO = 0,
                   @Ln_EstFatherDemo_MemberSsn_NUMB = 0,
                   @Lc_EstFatherDemo_Last_NAME = '',
                   @Lc_EstFatherDemo_First_NAME = '',
                   @Lc_EstFatherDemo_Middle_NAME = '',
                   @Lc_EstFatherDemo_Suffix_NAME = '',
                   @Ld_EstFatherDemo_Birth_DATE = @Ld_Low_DATE,
                   @Lb_UpdateFTRDemoVapp_BIT = 0,
                   @Ln_VappCur_DisFatherMemberMci_IDNO = 0,
                   @Lc_VappCur_DisFatherLast_NAME = '',
                   @Lc_VappCur_DisFatherFirst_NAME = '',
                   @Ld_VappCur_DisFatherBirth_DATE = @Ld_Low_DATE,
                   @Ln_VappCur_DisFatherMemberSsn_NUMB = 0,
                   @Ln_DisEstFatherDemo_MemberMci_IDNO = 0,
                   @Lc_DisEstFatherDemo_Last_NAME = '',
                   @Lc_DisEstFatherDemo_First_NAME = '',
                   @Lc_DisEstFatherDemo_Middle_NAME = '',
                   @Lc_DisEstFatherDemo_Suffix_NAME = '',
                   @Lb_UpdateDFTRDemoVapp_BIT = 0,
                   @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                   @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                   @Lc_StateDisestablish_CODE = '',
                   @Lc_DisEstablishedFather_CODE = '',
                   @Ld_UpdateEstDate_DATE = @Ld_Low_DATE,
                   @Ld_Disestablish_DATE = @Ld_Low_DATE

          SET @Ls_Sql_TEXT ='SET Parents_CUR 2';

          DECLARE Parents_CUR INSENSITIVE CURSOR FOR
           SELECT c.MemberMci_IDNO,
                  c.CaseRelationship_CODE,
                  d.MemberSex_CODE
             FROM CMEM_Y1 c
                  JOIN DEMO_Y1 d
                   ON c.MemberMci_IDNO = d.MemberMci_IDNO
            WHERE Case_IDNO = @Ln_CaseCur_Case_IDNO
              AND CaseRelationship_CODE IN (@Lc_CPCaseRelationship_CODE, @Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
              AND CaseMemberStatus_CODE = 'A';

          SET @Ls_Sql_TEXT ='OPEN Parents_CUR 2';

          OPEN Parents_CUR;

          SET @Ls_Sql_TEXT ='FETCH Parents_CUR 2';

          FETCH NEXT FROM Parents_CUR INTO @Ln_ParentsCur_MemberMci_IDNO, @Lc_ParentsCur_CaseRelationship_CODE, @Lc_ParentsCur_MemberSex_CODE;

          SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
          SET @Ls_Sql_TEXT ='WHILE Parent_CUR 2';

          --Execute logic for each parent of the above cases
          WHILE @Li_ParentFetchStatus_QNTY = 0
           BEGIN
            IF(@Lc_Relation_CPRelationshipToChild_CODE = @Lc_Relation_Mother_CODE
               AND @Lc_ParentsCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
               AND @Lc_ParentsCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
             BEGIN
              SET @Lc_MTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;
              SET @Ls_Sql_TEXT ='Select Mother details from DEMO 2';
              SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

              SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                     @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                     @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                     @Lc_MotherDemo_First_NAME = d.First_NAME,
                     @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                     @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                     @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
                FROM DEMO_Y1 d
               WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

              SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

              IF(@Ln_RowsCount_QNTY = 0)
               BEGIN
                SET @Lb_UpdateMTRDemoVapp_BIT = 1;
               END
             END
            ELSE IF(@Lc_Relation_CPRelationshipToChild_CODE = @Lc_Relation_Father_CODE
               AND @Lc_ParentsCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
               AND @Lc_ParentsCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
             BEGIN
              SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;

              IF(@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
               BEGIN
                SET @Ls_Sql_TEXT ='Select EstFather details from DEMO 2';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                       @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                       @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                       @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                       @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateFTRDemoVapp_BIT=1;
                 END

                SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Child First Process 2';
                SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

                SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                       @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                       @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                       @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                       @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
                  FROM VAPP_Y1 v
                 WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID
                   AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

                SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 2';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                       @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                       @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateDFTRDemoVapp_BIT =1;
                 END
               END
              ELSE IF (@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
               BEGIN
                SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 3';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                       @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                       @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                       @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                       @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateFTRDemoVapp_BIT=1;
                 END
               END
             END

            IF(@Lc_Relation_NCPRelationshipToChild_CODE = @Lc_Relation_Mother_CODE
               AND @Lc_ParentsCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
               AND @Lc_ParentsCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
             BEGIN
              SET @Lc_MTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;
              SET @Ls_Sql_TEXT ='Select Mother details from DEMO 3';
              SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

              SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                     @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                     @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                     @Lc_MotherDemo_First_NAME = d.First_NAME,
                     @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                     @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                     @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
                FROM DEMO_Y1 d
               WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

              SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

              IF(@Ln_RowsCount_QNTY = 0)
               BEGIN
                SET @Lb_UpdateMTRDemoVapp_BIT =1;
               END
             END
            ELSE IF(@Lc_Relation_NCPRelationshipToChild_CODE = @Lc_Relation_Father_CODE
               AND @Lc_ParentsCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
               AND @Lc_ParentsCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
             BEGIN
              SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParentsCur_CaseRelationship_CODE;

              IF(@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
               BEGIN
                SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 4';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                       @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                       @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                       @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                       @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateFTRDemoVapp_BIT=1;
                 END

                SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Child First Process 3';
                SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

                SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                       @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                       @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                       @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                       @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
                  FROM VAPP_Y1 v
                 WHERE v.ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID
                   AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

                SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 3';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                       @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                       @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateDFTRDemoVapp_BIT =1;
                 END
               END
              ELSE IF (@Lc_VappCur_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
               BEGIN
                SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 5';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentsCur_MemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                       @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                       @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                       @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                       @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                       @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                       @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                  FROM DEMO_Y1 d
                 WHERE d.MemberMci_IDNO = @Ln_ParentsCur_MemberMci_IDNO;

                SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

                IF(@Ln_RowsCount_QNTY = 0)
                 BEGIN
                  SET @Lb_UpdateFTRDemoVapp_BIT=1;
                 END
               END
             END

            SET @Ls_Sql_TEXT ='FETCH NEXT @Parent_CUR 2';

            FETCH NEXT FROM Parents_CUR INTO @Ln_ParentsCur_MemberMci_IDNO, @Lc_ParentsCur_CaseRelationship_CODE, @Lc_ParentsCur_MemberSex_CODE;

            SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
           END

          CLOSE Parents_CUR;

          DEALLOCATE Parents_CUR;

          SET @Ls_Sql_TEXT ='Verify NCP Mother details with DEMO in Child First Process 2';

          IF((ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) > 0
               OR ISNULL(@Ln_VappCur_MotherMemberMci_IDNO, 0) > 0)
             AND @Ln_MotherDemo_MemberMci_IDNO = @Ln_VappCur_MotherMemberMci_IDNO)
           BEGIN
            SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
            SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Mother MCI 			= 4 points
           END
          ELSE IF ((ISNULL(@Ln_MotherDemo_MemberSsn_NUMB, 0) > 0
                OR ISNULL(@Ln_VappCur_MotherMemberSsn_NUMB, 0) > 0)
              AND @Ln_MotherDemo_MemberSsn_NUMB = @Ln_VappCur_MotherMemberSsn_NUMB)
           BEGIN
            SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
            SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Mother SSN 			= 4 points
           END
          ELSE
           BEGIN
            IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) > 0
                 OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherLast_NAME, '')))) > 0)
               AND @Lc_MotherDemo_Last_NAME = @Lc_VappCur_MotherLast_NAME
             BEGIN
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Mother Last Name 			= 2 points
             END

            IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) > 0
                 OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherFirst_NAME, '')))) > 0)
               AND @Lc_MotherDemo_First_NAME = @Lc_VappCur_MotherFirst_NAME
             BEGIN
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 1; --Mother First Name			= 1 point
             END

            IF (ISNULL(@Ld_MotherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                 OR ISNULL(@Ld_VappCur_MotherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
               AND @Ld_MotherDemo_Birth_DATE = @Ld_VappCur_MotherBirth_DATE
             BEGIN
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Mother DOB 			= 2 points
             END
           END;

          SET @Ls_Sql_TEXT ='Verify NCP EstFather details with DEMO in Child First Process 2';

          IF((ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) > 0
               OR ISNULL(@Ln_VappCur_FatherMemberMci_IDNO, 0) > 0)
             AND @Ln_EstFatherDemo_MemberMci_IDNO = @Ln_VappCur_FatherMemberMci_IDNO)
           BEGIN
            SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
            SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Father MCI	 			= 4 points
           END
          ELSE IF ((ISNULL(@Ln_EstFatherDemo_MemberSsn_NUMB, 0) > 0
                OR ISNULL(@Ln_VappCur_FatherMemberSsn_NUMB, 0) > 0)
              AND @Ln_EstFatherDemo_MemberSsn_NUMB = @Ln_VappCur_FatherMemberSsn_NUMB)
           BEGIN
            SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
            SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 4; --Father SSN 			= 4 points
           END
          ELSE
           BEGIN
            IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) > 0
                 OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherLast_NAME, '')))) > 0)
               AND @Lc_EstFatherDemo_Last_NAME = @Lc_VappCur_FatherLast_NAME
             BEGIN
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Father Last Name 			= 2 points
             END

            IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) > 0
                 OR LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherFirst_NAME, '')))) > 0)
               AND @Lc_EstFatherDemo_First_NAME = @Lc_VappCur_FatherFirst_NAME
             BEGIN
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 1; --Father First Name			= 1 point
             END

            IF (ISNULL(@Ld_EstFatherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                 OR ISNULL(@Ld_VappCur_FatherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
               AND @Ld_EstFatherDemo_Birth_DATE = @Ld_VappCur_FatherBirth_DATE
             BEGIN
              SET @Li_ChildFirstProcessParentDataMatchPoint_QNTY += 2; --Father DOB 			= 2 points
             END
           END;

          UPDATE #CfpMatchPointQntyInfo_P1
             SET ParentDataMatchPoint_QNTY = @Li_ChildFirstProcessParentDataMatchPoint_QNTY
           WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
             AND ChildMemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO
             AND ChildCase_IDNO = @Ln_CaseCur_Case_IDNO

          IF(@Li_ChildFirstProcessChildDataMatchPoint_QNTY >= 4
             AND @Li_ChildFirstProcessParentDataMatchPoint_QNTY >= 4)
           BEGIN
            SET @Lc_MatchFound_INDC = 'Y';
            SET @Ls_Sql_TEXT = 'UPDATE #VappMappPointQntyInfo_P1 - 2';
            SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

            UPDATE #VappMappPointQntyInfo_P1
               SET ChildFirstProcessChildDataMatchPoint_QNTY = @Li_ChildFirstProcessChildDataMatchPoint_QNTY,
                   ChildFirstProcessParentDataMatchPoint_QNTY = @Li_ChildFirstProcessParentDataMatchPoint_QNTY,
                   MatchFound_INDC = @Lc_MatchFound_INDC
             WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;

            IF(@Lb_UpdateMTRDemoVapp_BIT = 1)
             BEGIN
              SET @Ln_MotherDemo_MemberMci_IDNO = @Ln_VappCur_MotherMemberMci_IDNO;
              SET @Lc_MotherDemo_Last_NAME = @Lc_VappCur_MotherLast_NAME;
              SET @Lc_MotherDemo_First_NAME = @Lc_VappCur_MotherFirst_NAME;
              SET @Lc_MotherDemo_Middle_NAME = @Lc_Empty_TEXT;
              SET @Lc_MotherDemo_Suffix_NAME = @Lc_Empty_TEXT;
             END

            IF(@Lb_UpdateFTRDemoVapp_BIT = 1)
             BEGIN
              SET @Ln_EstFatherDemo_MemberMci_IDNO = @Ln_VappCur_FatherMemberMci_IDNO;
              SET @Lc_EstFatherDemo_Last_NAME = @Lc_VappCur_FatherLast_NAME;
              SET @Lc_EstFatherDemo_First_NAME = @Lc_VappCur_FatherFirst_NAME;
              SET @Lc_EstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
              SET @Lc_EstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
             END

            IF(@Lb_UpdateDFTRDemoVapp_BIT = 1)
             BEGIN
              SET @Ln_DisEstFatherDemo_MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;
              SET @Lc_DisEstFatherDemo_Last_NAME = @Lc_VappCur_DisFatherLast_NAME;
              SET @Lc_DisEstFatherDemo_First_NAME = @Lc_VappCur_DisFatherFirst_NAME;
              SET @Lc_DisEstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
              SET @Lc_DisEstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
             END

            IF NOT EXISTS(SELECT 1
                            FROM VAPP_Y1
                           WHERE TypeDocument_CODE = @Lc_DopTypeDocument_CODE
                             AND ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID)
             BEGIN
              SELECT @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                     @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                     @Lc_StateDisestablish_CODE = ' ';
             END
            ELSE
             BEGIN
              SET @Ls_Sql_TEXT = 'SET UPDATE MATCH DATA - 2';
              SET @Ls_Sqldata_TEXT = 'TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

              SELECT @Ld_DOPMotherSig_DATE = v.MotherSignature_DATE,
                     @Ld_DOPFatherSig_DATE = v.FatherSignature_DATE,
                     @Lc_StateDisestablish_CODE = 'DE',
                     @Lc_DisEstablishedFather_CODE = CASE
                                                      WHEN @Lb_UpdateDFTRDemoVapp_BIT = 1
                                                       THEN
                                                       CASE
                                                        WHEN ISNULL(v.FatherMemberMci_IDNO, 0) > 0
                                                         THEN
                                                         CASE
                                                          WHEN EXISTS (SELECT 1
                                                                         FROM CMEM_Y1 A
                                                                        WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                           THEN (SELECT ISNULL(A.CaseRelationship_CODE, 'O')
                                                                   FROM CMEM_Y1 A
                                                                  WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                          ELSE 'O'
                                                         END
                                                        ELSE 'O'
                                                       END
                                                      ELSE ' '
                                                     END
                FROM VAPP_Y1 v
               WHERE v.TypeDocument_CODE = @Lc_DopTypeDocument_CODE
                 AND v.ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;
             END

            IF(@Ld_VappCur_MotherSignature_DATE > @Ld_VappCur_FatherSignature_DATE)
             BEGIN
              SET @Ld_UpdateEstDate_DATE = @Ld_VappCur_MotherSignature_DATE;
             END
            ELSE
             SET @Ld_UpdateEstDate_DATE = @Ld_VappCur_FatherSignature_DATE;

            IF (@Ld_DOPMotherSig_DATE > @Ld_DOPFatherSig_DATE)
             BEGIN
              IF(@Ld_DOPMotherSig_DATE > @Ld_UpdateEstDate_DATE)
               BEGIN
                SET @Ld_UpdateEstDate_DATE = @Ld_DOPMotherSig_DATE;
               END

              SET @Ld_Disestablish_DATE = @Ld_DOPMotherSig_DATE;
             END
            ELSE
             BEGIN
              IF(@Ld_DOPFatherSig_DATE > @Ld_UpdateEstDate_DATE)
               BEGIN
                SET @Ld_UpdateEstDate_DATE = @Ld_DOPFatherSig_DATE;
               END

              SET @Ld_Disestablish_DATE = @Ld_DOPFatherSig_DATE;
             END

            SELECT @Ln_EstFatherDemo_MemberMci_IDNO = CASE
                                                       WHEN ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) = 0
                                                        THEN @Ln_VappCur_FatherMemberMci_IDNO
                                                       ELSE @Ln_EstFatherDemo_MemberMci_IDNO
                                                      END,
                   @Lc_EstFatherDemo_Last_NAME = CASE
                                                  WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) = 0
                                                   THEN @Lc_VappCur_FatherLast_NAME
                                                  ELSE @Lc_EstFatherDemo_Last_NAME
                                                 END,
                   @Lc_EstFatherDemo_First_NAME = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) = 0
                                                    THEN @Lc_VappCur_FatherFirst_NAME
                                                   ELSE @Lc_EstFatherDemo_First_NAME
                                                  END,
                   @Lc_EstFatherDemo_Middle_NAME = CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Middle_NAME, '')))) = 0
                                                     THEN @Lc_Empty_TEXT
                                                    ELSE @Lc_EstFatherDemo_Middle_NAME
                                                   END,
                   @Lc_EstFatherDemo_Suffix_NAME = CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '')))) = 0
                                                     THEN @Lc_Empty_TEXT
                                                    ELSE @Lc_EstFatherDemo_Suffix_NAME
                                                   END,
                   @Lc_EFTRCaseRelationship_CODE = CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EFTRCaseRelationship_CODE, '')))) = 0
                                                     THEN 'O'
                                                    ELSE @Lc_EFTRCaseRelationship_CODE
                                                   END,
                   @Ln_MotherDemo_MemberMci_IDNO = CASE
                                                    WHEN ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) = 0
                                                     THEN @Ln_VappCur_MotherMemberMci_IDNO
                                                    ELSE @Ln_MotherDemo_MemberMci_IDNO
                                                   END,
                   @Lc_MotherDemo_Last_NAME = CASE
                                               WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) = 0
                                                THEN @Lc_VappCur_MotherLast_NAME
                                               ELSE @Lc_MotherDemo_Last_NAME
                                              END,
                   @Lc_MotherDemo_First_NAME = CASE
                                                WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) = 0
                                                 THEN @Lc_VappCur_MotherFirst_NAME
                                                ELSE @Lc_MotherDemo_First_NAME
                                               END,
                   @Lc_MotherDemo_Middle_NAME = CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Middle_NAME, '')))) = 0
                                                  THEN @Lc_Empty_TEXT
                                                 ELSE @Lc_MotherDemo_Middle_NAME
                                                END,
                   @Lc_MotherDemo_Suffix_NAME = CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Suffix_NAME, '')))) = 0
                                                  THEN @Lc_Empty_TEXT
                                                 ELSE @Lc_MotherDemo_Suffix_NAME
                                                END,
                   @Lc_MTRCaseRelationship_CODE = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MTRCaseRelationship_CODE, '')))) = 0
                                                    THEN 'O'
                                                   ELSE @Lc_MTRCaseRelationship_CODE
                                                  END,
                   @Ln_DisEstFatherDemo_MemberMci_IDNO = CASE
                                                          WHEN ISNULL(@Ln_DisEstFatherDemo_MemberMci_IDNO, 0) = 0
                                                           THEN @Ln_VappCur_DisFatherMemberMci_IDNO
                                                          ELSE @Ln_DisEstFatherDemo_MemberMci_IDNO
                                                         END,
                   @Lc_DisEstFatherDemo_Last_NAME = CASE
                                                     WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '')))) = 0
                                                      THEN @Lc_VappCur_DisFatherLast_NAME
                                                     ELSE @Lc_DisEstFatherDemo_Last_NAME
                                                    END,
                   @Lc_DisEstFatherDemo_First_NAME = CASE
                                                      WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_First_NAME, '')))) = 0
                                                       THEN @Lc_VappCur_DisFatherFirst_NAME
                                                      ELSE @Lc_DisEstFatherDemo_First_NAME
                                                     END,
                   @Lc_DisEstFatherDemo_Middle_NAME = CASE
                                                       WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '')))) = 0
                                                        THEN @Lc_Empty_TEXT
                                                       ELSE @Lc_DisEstFatherDemo_Middle_NAME
                                                      END,
                   @Lc_DisEstFatherDemo_Suffix_NAME = CASE
                                                       WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '')))) = 0
                                                        THEN @Lc_Empty_TEXT
                                                       ELSE @Lc_DisEstFatherDemo_Suffix_NAME
                                                      END

            SET @Ls_Sql_TEXT = 'BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH - 2';
            SET @Ls_Sqldata_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildDemo_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_EstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DisEstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_DisEstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedMotherMci_IDNO = ' + ISNULL(CAST(@Ln_MotherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DopAttached_CODE = ' + ISNULL(@Lc_VappCur_DopAttached_CODE, '') + ', EstablishedMother_CODE = ' + ISNULL(@Lc_MTRCaseRelationship_CODE, '') + ', EstablishedFather_CODE = ' + ISNULL(@Lc_EFTRCaseRelationship_CODE, '') + ', DisEstablishedFather_CODE = ' + ISNULL(@Lc_DisEstablishedFather_CODE, '') + ', EstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '') + ', DisEstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '') + ', EstablishedMotherSuffix_NAME = ' + ISNULL(@Lc_MotherDemo_Suffix_NAME, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', EstablishedFatherFirst_NAME = ' + ISNULL(@Lc_EstFatherDemo_First_NAME, '') + ', DisEstablishedFatherFirst_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_First_NAME, '') + ', EstablishedMotherFirst_NAME = ' + ISNULL(@Lc_MotherDemo_First_NAME, '') + ', EstablishedFatherLast_NAME = ' + ISNULL(@Lc_EstFatherDemo_Last_NAME, '') + ', EstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_EstFatherDemo_Middle_NAME, '') + ', DisEstablishedFatherLast_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '') + ', DisEstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '') + ', EstablishedMotherLast_NAME = ' + ISNULL(@Lc_MotherDemo_Last_NAME, '') + ', EstablishedMotherMiddle_NAME = ' + ISNULL(@Lc_MotherDemo_Middle_NAME, '') + ', PaternityEst_DATE = ' + ISNULL(CAST(@Ld_UpdateEstDate_DATE AS VARCHAR), '') + ', Disestablish_DATE = ' + ISNULL(CAST(@Ld_Disestablish_DATE AS VARCHAR), '') + ', StateDisestablish_CODE = ' + ISNULL(@Lc_StateDisestablish_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

            EXECUTE BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH
             @Ac_Job_ID                          = @Lc_Job_ID,
             @An_ChildMemberMci_IDNO             = @Ln_ChildDemo_MemberMci_IDNO,
             @An_EstablishedFatherMci_IDNO       = @Ln_EstFatherDemo_MemberMci_IDNO,
             @An_DisEstablishedFatherMci_IDNO    = @Ln_DisEstFatherDemo_MemberMci_IDNO,
             @An_EstablishedMotherMci_IDNO       = @Ln_MotherDemo_MemberMci_IDNO,
             @Ac_DopAttached_CODE                = @Lc_VappCur_DopAttached_CODE,
             @Ac_EstablishedMother_CODE          = @Lc_MTRCaseRelationship_CODE,
             @Ac_EstablishedFather_CODE          = @Lc_EFTRCaseRelationship_CODE,
             @Ac_DisEstablishedFather_CODE       = @Lc_DisEstablishedFather_CODE,
             @Ac_EstablishedFatherSuffix_NAME    = @Lc_EstFatherDemo_Suffix_NAME,
             @Ac_DisEstablishedFatherSuffix_NAME = @Lc_DisEstFatherDemo_Suffix_NAME,
             @Ac_EstablishedMotherSuffix_NAME    = @Lc_MotherDemo_Suffix_NAME,
             @Ac_ChildBirthCertificate_ID        = @Lc_VappCur_ChildBirthCertificate_ID,
             @Ac_EstablishedFatherFirst_NAME     = @Lc_EstFatherDemo_First_NAME,
             @Ac_DisEstablishedFatherFirst_NAME  = @Lc_DisEstFatherDemo_First_NAME,
             @Ac_EstablishedMotherFirst_NAME     = @Lc_MotherDemo_First_NAME,
             @Ac_EstablishedFatherLast_NAME      = @Lc_EstFatherDemo_Last_NAME,
             @Ac_EstablishedFatherMiddle_NAME    = @Lc_EstFatherDemo_Middle_NAME,
             @Ac_DisEstablishedFatherLast_NAME   = @Lc_DisEstFatherDemo_Last_NAME,
             @Ac_DisEstablishedFatherMiddle_NAME = @Lc_DisEstFatherDemo_Middle_NAME,
             @Ac_EstablishedMotherLast_NAME      = @Lc_MotherDemo_Last_NAME,
             @Ac_EstablishedMotherMiddle_NAME    = @Lc_MotherDemo_Middle_NAME,
             @Ad_PaternityEst_DATE               = @Ld_UpdateEstDate_DATE,
             @Ad_Disestablish_DATE               = @Ld_Disestablish_DATE,
             @Ac_StateDisestablish_CODE          = @Lc_StateDisestablish_CODE,
             @Ad_Run_DATE                        = @Ld_Run_DATE,
             @Ac_Msg_CODE                        = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT           = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

              RAISERROR(50001,16,1);
             END

            CLOSE Case_CUR;

            DEALLOCATE Case_CUR;

            GOTO EXIT_CFP_SINGLE_LOOP;
           END

          SET @Ls_Sql_TEXT ='FETCH NEXT Case_CUR 2';

          FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

          SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE Case_CUR;

        DEALLOCATE Case_CUR;

        EXIT_CFP_SINGLE_LOOP:;

        SET @Ls_Sql_TEXT = 'SELECT #VappMappPointQntyInfo_P1';
        SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

        SELECT @Li_ChildFirstProcessChildDataMatchPoint_QNTY = A.ChildFirstProcessChildDataMatchPoint_QNTY,
               @Li_ChildFirstProcessParentDataMatchPoint_QNTY = A.ChildFirstProcessParentDataMatchPoint_QNTY,
               @Lc_MatchFound_INDC = A.MatchFound_INDC
          FROM #VappMappPointQntyInfo_P1 A
         WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;

        IF @Lc_MatchFound_INDC = 'Y'
           AND @Li_ChildFirstProcessChildDataMatchPoint_QNTY >= 4
           AND @Li_ChildFirstProcessParentDataMatchPoint_QNTY >= 4
         BEGIN
          GOTO NEXT_RECORD;
         END
        ELSE
         BEGIN
          GOTO PARENT_PROCESS;
         END;
       END

      PARENT_PROCESS:;

      SET @Ls_Sql_TEXT = 'SELECT #VappMappPointQntyInfo_P1';
      SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

      SELECT @Li_ChildFirstProcessChildDataMatchPoint_QNTY = A.ChildFirstProcessChildDataMatchPoint_QNTY,
             @Li_ChildFirstProcessParentDataMatchPoint_QNTY = A.ChildFirstProcessParentDataMatchPoint_QNTY,
             @Lc_MatchFound_INDC = A.MatchFound_INDC
        FROM #VappMappPointQntyInfo_P1 A
       WHERE ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;

      IF @Lc_MatchFound_INDC = 'N'
          OR @Li_ChildFirstProcessChildDataMatchPoint_QNTY < 4
          OR @Li_ChildFirstProcessParentDataMatchPoint_QNTY < 4
       BEGIN
        SET @Ls_Sqldata_TEXT = '';
        --SELECT 'No Match Found in CHILD Process, Moving to Parent First Process';
        SET @Ls_Sql_TEXT = 'BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_PARENT_MATCH';
        SET @Ls_Sqldata_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_ChildMemberMci_IDNO AS VARCHAR), '') + ', ChildMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_VappCur_ChildMemberSsn_NUMB AS VARCHAR), '') + ', MotherMemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_MotherMemberMci_IDNO AS VARCHAR), '') + ', MotherMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_VappCur_MotherMemberSsn_NUMB AS VARCHAR), '') + ', FatherMemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_FatherMemberMci_IDNO AS VARCHAR), '') + ', FatherMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_VappCur_FatherMemberSsn_NUMB AS VARCHAR), '') + ', DopAttached_CODE = ' + ISNULL(@Lc_VappCur_DopAttached_CODE, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '') + ', ChildFirst_NAME = ' + ISNULL(@Lc_VappCur_ChildFirst_NAME, '') + ', MotherFirst_NAME = ' + ISNULL(@Lc_VappCur_MotherFirst_NAME, '') + ', FatherFirst_NAME = ' + ISNULL(@Lc_VappCur_FatherFirst_NAME, '') + ', ChildLast_NAME = ' + ISNULL(@Lc_VappCur_ChildLast_NAME, '') + ', MotherLast_NAME = ' + ISNULL(@Lc_VappCur_MotherLast_NAME, '') + ', FatherLast_NAME = ' + ISNULL(@Lc_VappCur_FatherLast_NAME, '') + ', ChildBirth_DATE = ' + ISNULL(CAST(@Ld_VappCur_ChildBirth_DATE AS VARCHAR), '') + ', MotherBirth_DATE = ' + ISNULL(CAST(@Ld_VappCur_MotherBirth_DATE AS VARCHAR), '') + ', FatherBirth_DATE = ' + ISNULL(CAST(@Ld_VappCur_FatherBirth_DATE AS VARCHAR), '') + ', MotherSignature_DATE = ' + ISNULL(CAST(@Ld_VappCur_MotherSignature_DATE AS VARCHAR), '') + ', FatherSignature_DATE = ' + ISNULL(CAST(@Ld_VappCur_FatherSignature_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

        EXECUTE BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_PARENT_MATCH
         @Ac_Job_ID                   = @Lc_Job_ID,
         @An_ChildMemberMci_IDNO      = @Ln_VappCur_ChildMemberMci_IDNO,
         @An_ChildMemberSsn_NUMB      = @Ln_VappCur_ChildMemberSsn_NUMB,
         @An_MotherMemberMci_IDNO     = @Ln_VappCur_MotherMemberMci_IDNO,
         @An_MotherMemberSsn_NUMB     = @Ln_VappCur_MotherMemberSsn_NUMB,
         @An_FatherMemberMci_IDNO     = @Ln_VappCur_FatherMemberMci_IDNO,
         @An_FatherMemberSsn_NUMB     = @Ln_VappCur_FatherMemberSsn_NUMB,
         @Ac_DopAttached_CODE         = @Lc_VappCur_DopAttached_CODE,
         @Ac_ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID,
         @Ac_ChildFirst_NAME          = @Lc_VappCur_ChildFirst_NAME,
         @Ac_MotherFirst_NAME         = @Lc_VappCur_MotherFirst_NAME,
         @Ac_FatherFirst_NAME         = @Lc_VappCur_FatherFirst_NAME,
         @Ac_ChildLast_NAME           = @Lc_VappCur_ChildLast_NAME,
         @Ac_MotherLast_NAME          = @Lc_VappCur_MotherLast_NAME,
         @Ac_FatherLast_NAME          = @Lc_VappCur_FatherLast_NAME,
         @Ad_ChildBirth_DATE          = @Ld_VappCur_ChildBirth_DATE,
         @Ad_MotherBirth_DATE         = @Ld_VappCur_MotherBirth_DATE,
         @Ad_FatherBirth_DATE         = @Ld_VappCur_FatherBirth_DATE,
         @Ad_MotherSignature_DATE     = @Ld_VappCur_MotherSignature_DATE,
         @Ad_FatherSignature_DATE     = @Ld_VappCur_FatherSignature_DATE,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END
       END;

      NEXT_RECORD:;

      SET @Ls_Sql_TEXT = 'CHECK WHETHER A MATCH IS FOUND';
      SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Lc_VappCur_ChildBirthCertificate_ID, '');

      SELECT @Lc_ChildBirthCertificate_ID = A.ChildBirthCertificate_ID,
             @Ln_ExistingMatchPoint_QNTY = A.ExistingMatchPoint_QNTY,
             @Lc_VappMatchFound_INDC = A.MatchFound_INDC
        FROM #VappMappPointQntyInfo_P1 A
       WHERE A.ChildBirthCertificate_ID = @Lc_VappCur_ChildBirthCertificate_ID;

      IF @Lc_VappMatchFound_INDC = @Lc_No_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'CHECK AND UPDATE MATCH POINT QUANTITY IN #VappMappPointQntyInfo_P1';
        SET @Ls_Sqldata_TEXT = '';

        SELECT @Lc_Process_NAME = C.Process_NAME,
               @Lc_ChildBirthCertificate_ID = LTRIM(RTRIM(C.ChildBirthCertificate_ID)),
               @Ln_Case_IDNO = ISNULL(C.Case_IDNO, @Ln_Zero_NUMB),
               @Lc_CpRelationshipToChild_CODE = ISNULL(C.CpRelationshipToChild_CODE, ISNULL(E.CpRelationshipToChild_CODE, @Lc_Empty_TEXT)),
               @Lc_NcpRelationshipToChild_CODE = ISNULL(C.NcpRelationshipToChild_CODE, ISNULL(E.NcpRelationshipToChild_CODE, @Lc_Empty_TEXT)),
               @Ln_ChildMemberMci_IDNO = ISNULL(C.ChildMemberMci_IDNO, @Ln_Zero_NUMB),
               @Lc_ChildLast_NAME = ISNULL(C.ChildLast_NAME, ISNULL(D.Last_NAME, @Lc_Empty_TEXT)),
               @Lc_ChildFirst_NAME = ISNULL(C.ChildFirst_NAME, ISNULL(D.First_NAME, @Lc_Empty_TEXT)),
               @Ld_ChildBirth_DATE = ISNULL(C.ChildBirth_DATE, ISNULL(D.Birth_DATE, @Ld_Low_DATE)),
               @Ln_ChildMemberSsn_NUMB = ISNULL(C.ChildMemberSsn_NUMB, ISNULL(D.MemberSsn_NUMB, @Ln_Zero_NUMB)),
               @Lc_ChildRace_CODE = ISNULL(D.Race_CODE, @Lc_Empty_TEXT),
               @Ln_UpdateMatchPoint_QNTY = ISNULL(C.UpdateMatchPoint_QNTY, @Ln_Zero_NUMB)
          FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY B.ChildBirthCertificate_ID ORDER BY B.ChildBirthCertificate_ID, B.UpdateMatchPoint_QNTY DESC, B.ChildMemberMci_IDNO DESC ),
                       B.Process_NAME,
                       B.ChildBirthCertificate_ID,
                       B.Case_IDNO,
                       B.CpRelationshipToChild_CODE,
                       B.NcpRelationshipToChild_CODE,
                       B.ChildMemberMci_IDNO,
                       B.ChildLast_NAME,
                       B.ChildFirst_NAME,
                       B.ChildBirth_DATE,
                       B.ChildMemberSsn_NUMB,
                       B.UpdateMatchPoint_QNTY
                  FROM (SELECT 'CFP' AS Process_NAME,
                               A.ChildBirthCertificate_ID,
                               A.ChildCase_IDNO AS Case_IDNO,
                               A.CpRelationshipToChild_CODE,
                               A.NcpRelationshipToChild_CODE,
                               A.ChildMemberMci_IDNO,
                               A.ChildLast_NAME,
                               A.ChildFirst_NAME,
                               A.ChildBirth_DATE,
                               A.ChildMemberSsn_NUMB,
                               ISNULL(A.ParentDataMatchPoint_QNTY, 0) AS UpdateMatchPoint_QNTY
                          FROM #CfpMatchPointQntyInfo_P1 A
                        UNION
                        SELECT 'MFP' AS Process_NAME,
                               A.ChildBirthCertificate_ID,
                               A.MotherCase_IDNO,
                               A.CpRelationshipToChild_CODE,
                               A.NcpRelationshipToChild_CODE,
                               A.ChildMemberMci_IDNO,
                               A.ChildLast_NAME,
                               A.ChildFirst_NAME,
                               A.ChildBirth_DATE,
                               A.ChildMemberSsn_NUMB,
                               ISNULL(A.ChildDataMatchPoint_QNTY, 0)
                          FROM #MfpMatchPointQntyInfo_P1 A
                        UNION
                        SELECT 'FFP' AS Process_NAME,
                               A.ChildBirthCertificate_ID,
                               A.FatherCase_IDNO,
                               A.CpRelationshipToChild_CODE,
                               A.NcpRelationshipToChild_CODE,
                               A.ChildMemberMci_IDNO,
                               A.ChildLast_NAME,
                               A.ChildFirst_NAME,
                               A.ChildBirth_DATE,
                               A.ChildMemberSsn_NUMB,
                               ISNULL(A.ChildDataMatchPoint_QNTY, 0)
                          FROM #FfpMatchPointQntyInfo_P1 A) B) C
               LEFT OUTER JOIN DEMO_Y1 D
                ON D.MemberMci_IDNO = C.ChildMemberMci_IDNO
               LEFT OUTER JOIN CMEM_Y1 E
                ON E.MemberMci_IDNO = C.ChildMemberMci_IDNO
                   AND E.Case_IDNO = C.Case_IDNO
                   AND E.CaseRelationship_CODE = 'D'
         WHERE LTRIM(RTRIM(C.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID))
           AND C.Row_NUMB = 1

        IF @Ln_UpdateMatchPoint_QNTY > @Ln_Zero_NUMB
           AND @Ln_UpdateMatchPoint_QNTY > @Ln_ExistingMatchPoint_QNTY
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
          SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

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

          SET @Ls_Sql_TEXT = 'INSERT HVAPP_Y1';
          SET @Ls_Sqldata_TEXT = '';

          INSERT INTO HVAPP_Y1
                      (ChildBirthCertificate_ID,
                       TypeDocument_CODE,
                       ChildMemberMci_IDNO,
                       ChildLast_NAME,
                       ChildFirst_NAME,
                       ChildBirth_DATE,
                       ChildMemberSsn_NUMB,
                       ChildBirthState_CODE,
                       ChildBirthCity_INDC,
                       ChildBirthCounty_INDC,
                       PlaceOfAck_CODE,
                       PlaceOfAck_NAME,
                       Declaration_INDC,
                       GeneticTest_INDC,
                       NoPresumedFather_CODE,
                       VapPresumedFather_CODE,
                       DopPresumedFather_CODE,
                       VapAttached_CODE,
                       DopAttached_CODE,
                       MotherSignature_DATE,
                       FatherSignature_DATE,
                       Match_DATE,
                       DataRecordStatus_CODE,
                       ImageLink_INDC,
                       FatherMemberMci_IDNO,
                       FatherLast_NAME,
                       FatherFirst_NAME,
                       FatherBirth_DATE,
                       FatherMemberSsn_NUMB,
                       FatherAddrExist_INDC,
                       MotherMemberMci_IDNO,
                       MotherLast_NAME,
                       MotherFirst_NAME,
                       MotherBirth_DATE,
                       MotherMemberSsn_NUMB,
                       MotherAddrExist_INDC,
                       Note_TEXT,
                       BeginValidity_DATE,
                       EndValidity_DATE,
                       WorkerUpdate_ID,
                       TransactionEventSeq_NUMB,
                       Update_DTTM,
                       MatchPoint_QNTY)
          SELECT A.ChildBirthCertificate_ID,
                 A.TypeDocument_CODE,
                 A.ChildMemberMci_IDNO,
                 A.ChildLast_NAME,
                 A.ChildFirst_NAME,
                 A.ChildBirth_DATE,
                 A.ChildMemberSsn_NUMB,
                 A.ChildBirthState_CODE,
                 A.ChildBirthCity_INDC,
                 A.ChildBirthCounty_INDC,
                 A.PlaceOfAck_CODE,
                 A.PlaceOfAck_NAME,
                 A.Declaration_INDC,
                 A.GeneticTest_INDC,
                 A.NoPresumedFather_CODE,
                 A.VapPresumedFather_CODE,
                 A.DopPresumedFather_CODE,
                 A.VapAttached_CODE,
                 A.DopAttached_CODE,
                 A.MotherSignature_DATE,
                 A.FatherSignature_DATE,
                 A.Match_DATE,
                 A.DataRecordStatus_CODE,
                 A.ImageLink_INDC,
                 A.FatherMemberMci_IDNO,
                 A.FatherLast_NAME,
                 A.FatherFirst_NAME,
                 A.FatherBirth_DATE,
                 A.FatherMemberSsn_NUMB,
                 A.FatherAddrExist_INDC,
                 A.MotherMemberMci_IDNO,
                 A.MotherLast_NAME,
                 A.MotherFirst_NAME,
                 A.MotherBirth_DATE,
                 A.MotherMemberSsn_NUMB,
                 A.MotherAddrExist_INDC,
                 A.Note_TEXT,
                 A.BeginValidity_DATE,
                 @Ld_Run_DATE AS EndValidity_DATE,
                 A.WorkerUpdate_ID,
                 A.TransactionEventSeq_NUMB,
                 @Ld_Start_DATE AS Update_DTTM,
                 A.MatchPoint_QNTY
            FROM VAPP_Y1 A
           WHERE UPPER(LTRIM(RTRIM(A.ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID)))
             AND UPPER(LTRIM(RTRIM(A.TypeDocument_CODE))) = @Lc_TypeDocumentVap_CODE
             AND A.DataRecordStatus_CODE = @Lc_DataRecordStatusComplete_CODE
             AND A.DopAttached_CODE IN (@Lc_DOPAttachedYes_CODE, @Lc_DOPAttachedNo_CODE)
             AND A.Match_DATE = @Ld_Low_DATE
             AND A.ImageLink_INDC = 'Y';

          SET @Li_Rowcount_QNTY = @@ROWCOUNT

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT HVAPP_Y1 FAILED!'

            RAISERROR(50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'UPDATE VAPP_Y1';
          SET @Ls_Sqldata_TEXT = '';

          UPDATE VAPP_Y1
             SET MatchPoint_QNTY = @Ln_UpdateMatchPoint_QNTY,
                 BeginValidity_DATE = @Ld_Run_DATE,
                 WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                 TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                 Update_DTTM = @Ld_Start_DATE
           WHERE UPPER(LTRIM(RTRIM(ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificate_ID)))
             AND UPPER(LTRIM(RTRIM(TypeDocument_CODE))) = @Lc_TypeDocumentVap_CODE
             AND DataRecordStatus_CODE = @Lc_DataRecordStatusComplete_CODE
             AND DopAttached_CODE IN (@Lc_DOPAttachedYes_CODE, @Lc_DOPAttachedNo_CODE)
             AND Match_DATE = @Ld_Low_DATE
             AND ImageLink_INDC = 'Y';

          SET @Li_Rowcount_QNTY = @@ROWCOUNT

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'UPDATE VAPP_Y1 FAILED!'

            RAISERROR(50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'INSERT BVPOM_Y1';
          SET @Ls_Sqldata_TEXT = 'DataRecordStatus_CODE = ' + ISNULL(@Lc_DataRecordStatusComplete_CODE, '');

          INSERT INTO BVPOM_Y1
                      (ChildBirthCertificate_ID,
                       Case_IDNO,
                       CpRelationshipToChild_CODE,
                       NcpRelationshipToChild_CODE,
                       ChildMemberMci_IDNO,
                       ChildLast_NAME,
                       ChildFirst_NAME,
                       ChildBirth_DATE,
                       ChildMemberSsn_NUMB,
                       ChildRace_CODE,
                       Generate_DATE,
                       TransactionEventSeq_NUMB)
          SELECT @Lc_ChildBirthCertificate_ID AS ChildBirthCertificate_ID,
                 @Ln_Case_IDNO AS Case_IDNO,
                 @Lc_CpRelationshipToChild_CODE AS CpRelationshipToChild_CODE,
                 @Lc_NcpRelationshipToChild_CODE AS NcpRelationshipToChild_CODE,
                 @Ln_ChildMemberMci_IDNO AS ChildMemberMci_IDNO,
                 @Lc_ChildLast_NAME AS ChildLast_NAME,
                 @Lc_ChildFirst_NAME AS ChildFirst_NAME,
                 @Ld_ChildBirth_DATE AS ChildBirth_DATE,
                 @Ln_ChildMemberSsn_NUMB AS ChildMemberSsn_NUMB,
                 @Lc_ChildRace_CODE AS ChildRace_CODE,
                 @Ld_Run_DATE AS Generate_DATE,
                 @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB

          SET @Li_Rowcount_QNTY = @@ROWCOUNT

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT BVPOM_Y1 FAILED!'

            RAISERROR(50001,16,1);
           END
         END
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_VAP_DOP_MATCH;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

        RAISERROR(50001,16,1);
       END

      IF CURSOR_STATUS ('Local', 'Case_CUR') IN (0, 1)
       BEGIN
        CLOSE Case_CUR;

        DEALLOCATE Case_CUR;
       END

      IF CURSOR_STATUS ('Local', 'Demo_CUR') IN (0, 1)
       BEGIN
        CLOSE Demo_CUR;

        DEALLOCATE Demo_CUR;
       END

      IF CURSOR_STATUS ('Local', 'Parents_CUR') IN (0, 1)
       BEGIN
        CLOSE Parents_CUR;

        DEALLOCATE Parents_CUR;
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

     SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';

     IF @Ln_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_VAP_DOP_MATCH';

       COMMIT TRANSACTION TXN_PROCESS_VAP_DOP_MATCH;

       SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_VAP_DOP_MATCH';

       BEGIN TRANSACTION TXN_PROCESS_VAP_DOP_MATCH;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION TXN_PROCESS_VAP_DOP_MATCH;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ln_ParentPointsCounter_NUMB = 0;
     SET @Ln_ChildPointsCounter_NUMB = 0;
     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Vapp_CUR - 2';
     SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Vapp_CUR INTO @Lc_VappCur_ChildBirthCertificate_ID, @Lc_VappCur_TypeDocument_CODE, @Lc_VappCur_ChildMemberMciIdno_TEXT, @Lc_VappCur_ChildLast_NAME, @Lc_VappCur_ChildFirst_NAME, @Ld_VappCur_ChildBirth_DATE, @Lc_VappCur_ChildMemberSsnNumb_TEXT, @Lc_VappCur_DopAttached_CODE, @Ld_VappCur_MotherSignature_DATE, @Ld_VappCur_FatherSignature_DATE, @Ld_VappCur_Match_DATE, @Lc_VappCur_DataRecordStatus_CODE, @Lc_VappCur_FatherMemberMciIdno_TEXT, @Lc_VappCur_FatherLast_NAME, @Lc_VappCur_FatherFirst_NAME, @Ld_VappCur_FatherBirth_DATE, @Lc_VappCur_FatherMemberSsnNumb_TEXT, @Lc_VappCur_MotherMemberMciIdno_TEXT, @Lc_VappCur_MotherLast_NAME, @Lc_VappCur_MotherFirst_NAME, @Ld_VappCur_MotherBirth_DATE, @Lc_VappCur_MotherMemberSsnNumb_TEXT, @Ln_VappCur_MatchPoint_QNTY;

     SET @Li_VappFetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Vapp_CUR;

   DEALLOCATE Vapp_CUR;

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE,
            @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '');

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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_VAP_DOP_MATCH';

   COMMIT TRANSACTION TXN_PROCESS_VAP_DOP_MATCH;

   IF OBJECT_ID('tempdb..#VappMappPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #VappMappPointQntyInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#CfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CfpMatchPointQntyInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#MfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #MfpMatchPointQntyInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#FfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #FfpMatchPointQntyInfo_P1;
    END;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_VAP_DOP_MATCH;
    END

   IF CURSOR_STATUS ('Local', 'Vapp_CUR') IN (0, 1)
    BEGIN
     CLOSE Vapp_CUR;

     DEALLOCATE Vapp_CUR;
    END

   IF CURSOR_STATUS ('Local', 'Case_CUR') IN (0, 1)
    BEGIN
     CLOSE Case_CUR;

     DEALLOCATE Case_CUR;
    END

   IF CURSOR_STATUS ('Local', 'Demo_CUR') IN (0, 1)
    BEGIN
     CLOSE Demo_CUR;

     DEALLOCATE Demo_CUR;
    END

   IF CURSOR_STATUS ('Local', 'Parents_CUR') IN (0, 1)
    BEGIN
     CLOSE Parents_CUR;

     DEALLOCATE Parents_CUR;
    END

   IF OBJECT_ID('tempdb..#VappMappPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #VappMappPointQntyInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#CfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CfpMatchPointQntyInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#MfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #MfpMatchPointQntyInfo_P1;
    END;

   IF OBJECT_ID('tempdb..#FfpMatchPointQntyInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #FfpMatchPointQntyInfo_P1;
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
