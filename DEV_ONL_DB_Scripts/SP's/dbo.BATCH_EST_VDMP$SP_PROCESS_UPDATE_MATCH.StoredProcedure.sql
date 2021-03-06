/****** Object:  StoredProcedure [dbo].[BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH
Programmer Name	:	IMP Team.
Description		:	This procedure is used to update the MPAT_Y1 and VAPP_Y1 table when we get a match using the VAPP record
Frequency		:	'WEEKLY'
Developed On	:	3/16/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH]
 @Ac_Job_ID                          CHAR(7),
 @An_ChildMemberMci_IDNO             NUMERIC,
 @An_EstablishedFatherMci_IDNO       NUMERIC,
 @An_DisEstablishedFatherMci_IDNO    NUMERIC,
 @An_EstablishedMotherMci_IDNO       NUMERIC,
 @Ac_DopAttached_CODE                CHAR(1),
 @Ac_EstablishedMother_CODE          CHAR(1),
 @Ac_EstablishedFather_CODE          CHAR(1),
 @Ac_DisEstablishedFather_CODE       CHAR(1),
 @Ac_EstablishedFatherSuffix_NAME    CHAR(4),
 @Ac_DisEstablishedFatherSuffix_NAME CHAR(4),
 @Ac_EstablishedMotherSuffix_NAME    CHAR(4),
 @Ac_ChildBirthCertificate_ID        CHAR(7),
 @Ac_EstablishedFatherFirst_NAME     CHAR(16),
 @Ac_DisEstablishedFatherFirst_NAME  CHAR(16),
 @Ac_EstablishedMotherFirst_NAME     CHAR(16),
 @Ac_EstablishedFatherLast_NAME      CHAR(20),
 @Ac_EstablishedFatherMiddle_NAME    CHAR(20),
 @Ac_DisEstablishedFatherLast_NAME   CHAR(20),
 @Ac_DisEstablishedFatherMiddle_NAME CHAR(20),
 @Ac_EstablishedMotherLast_NAME      CHAR(20),
 @Ac_EstablishedMotherMiddle_NAME    CHAR(20),
 @Ad_PaternityEst_DATE               DATE,
 @Ad_Disestablish_DATE               DATE = NULL,
 @Ac_StateDisestablish_CODE          CHAR(2) = ' ',
 @Ad_Run_DATE                        DATE,
 @Ac_Msg_CODE                        CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT           VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
          @Lc_DOPAttachedYes_CODE               CHAR(1) = 'Y',
          @Lc_DOPAttachedNo_CODE                CHAR(1) = 'N',
          @Lc_UpdateE_StatusEstablish_CODE      CHAR(1) = 'E',
          @Lc_UpdateY_PaternityEst_INDC         CHAR(1) = 'Y',
          @Lc_DataRecordStatusComplete_CODE     CHAR(1) = 'C',
          @Lc_UpdateY_VapImage_CODE             CHAR(1) = 'Y',
          @Lc_Note_INDC                         CHAR(1) = 'N',
          @Lc_QiStatusL_CODE                    CHAR(1) = 'L',
          @Lc_CaseMemberStatusA_CODE            CHAR(1) = 'A',
          @Lc_CaseRelationshipA_CODE            CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE            CHAR(1) = 'P',
          @Lc_StatusCaseO_CODE                  CHAR(1) = 'O',
          @Lc_BirthStateDe_CODE             CHAR(2) = 'DE',
          @Lc_BirthCountryUs_CODE             CHAR(2) = 'US',
          @Lc_StateEstablishDe_CODE             CHAR(2) = 'DE',
          @Lc_UpdateNO_BornOfMarriage_CODE      CHAR(2) = 'N',
          @Lc_UpdateVP_MethodEstablish_CODE     CHAR(2) = 'VP',
          @Lc_UpdateRCP_MethodDisestablish_CODE CHAR(3) = 'RCP',
          @Lc_TypeDocumentVap_CODE              CHAR(3) = 'VAP',
          @Lc_Subsystem_CODE                    CHAR(3) = 'ES',
          @Lc_TypeReference_IDNO                CHAR(4) = ' ',
          @Lc_ActivityMajorCase_CODE            CHAR(4) = 'CASE',
          @Lc_ActivityMinorChmvr_CODE           CHAR(5) = 'CHMVR',
          @Lc_Job_ID                            CHAR(7) = @Ac_Job_ID,
          @Lc_Notice_ID                         CHAR(8) = NULL,
          @Lc_BatchRunUser_TEXT                 CHAR(30) = 'BATCH',
          @Lc_WorkerDelegate_ID                 CHAR(30) = ' ',
          @Lc_Reference_ID                      CHAR(30) = ' ',
          @Ls_Procedure_NAME                    VARCHAR(100) = 'SP_PROCESS_UPDATE_MATCH',
          @Ls_XmlIn_TEXT                        VARCHAR(MAX) = ' ',
          @Ld_Low_DATE                          DATE = '01/01/0001',
          @Ld_Run_DATE                          DATE = @Ad_Run_DATE;
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
          @Ln_MajorIntSeq_NUMB         NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB         NUMERIC(5) = 0,
          @Ln_Case_IDNO                NUMERIC(6),
          @Ln_UnIdentifiedMci_IDNO     NUMERIC(10) = 999995,
          @Ln_TopicIn_IDNO             NUMERIC(10) = 0,
          @Ln_Schedule_NUMB            NUMERIC(10) = 0,
          @Ln_Topic_IDNO               NUMERIC(10),
          @Ln_MemberMciPf_IDNO         NUMERIC(10),
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Li_ChildrenCount_QNTY       INT,
          @Li_FetchStatus_QNTY         SMALLINT,
          @Li_Rowcount_QNTY            SMALLINT,
          @Lc_Msg_CODE                 CHAR(5) = '',
          @Ls_Sql_TEXT                 VARCHAR(100),
          @Ls_Sqldata_TEXT             VARCHAR(1000),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT    VARCHAR(4000) = '',
          @Ld_Start_DATE               DATETIME2;
  DECLARE @Ln_CaseCur_Case_IDNO            NUMERIC(6),
          @Ln_CaseMemberCur_Case_IDNO      NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO NUMERIC(10);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
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
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '');

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
    WHERE UPPER(LTRIM(RTRIM(A.ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID)))
      AND UPPER(LTRIM(RTRIM(A.TypeDocument_CODE))) = @Lc_TypeDocumentVap_CODE
      AND A.DataRecordStatus_CODE = @Lc_DataRecordStatusComplete_CODE
      AND A.DopAttached_CODE = @Ac_DopAttached_CODE
      AND A.Match_DATE = @Ld_Low_DATE
      AND A.ImageLink_INDC = 'Y';

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT HVAPP_Y1 FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'UPDATE VAPP_Y1';
   SET @Ls_Sqldata_TEXT = 'DataRecordStatus_CODE = ' + ISNULL(@Lc_DataRecordStatusComplete_CODE, '') + ', DopAttached_CODE = ' + ISNULL(@Ac_DopAttached_CODE, '') + ', Match_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '');

   UPDATE VAPP_Y1
      SET ChildMemberMci_IDNO = @An_ChildMemberMci_IDNO,
          FatherMemberMci_IDNO = @An_EstablishedFatherMci_IDNO,
          MotherMemberMci_IDNO = @An_EstablishedMotherMci_IDNO,
          Match_DATE = @Ld_Run_DATE,
          BeginValidity_DATE = @Ld_Run_DATE,
          WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
          TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          Update_DTTM = @Ld_Start_DATE
    WHERE UPPER(LTRIM(RTRIM(ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID)))
      AND UPPER(LTRIM(RTRIM(TypeDocument_CODE))) = @Lc_TypeDocumentVap_CODE
      AND DataRecordStatus_CODE = @Lc_DataRecordStatusComplete_CODE
      AND DopAttached_CODE = @Ac_DopAttached_CODE
      AND Match_DATE = @Ld_Low_DATE
      AND ImageLink_INDC = 'Y';

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE VAPP_Y1 FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT HMPAT_Y1';
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   INSERT HMPAT_Y1
          (MemberMci_IDNO,
           BirthCertificate_ID,
           BornOfMarriage_CODE,
           Conception_DATE,
           ConceptionCity_NAME,
           ConceptionCounty_IDNO,
           ConceptionState_CODE,
           ConceptionCountry_CODE,
           EstablishedMother_CODE,
           EstablishedMotherMci_IDNO,
           EstablishedMotherLast_NAME,
           EstablishedMotherFirst_NAME,
           EstablishedMotherMiddle_NAME,
           EstablishedMotherSuffix_NAME,
           EstablishedFather_CODE,
           EstablishedFatherMci_IDNO,
           EstablishedFatherLast_NAME,
           EstablishedFatherFirst_NAME,
           EstablishedFatherMiddle_NAME,
           EstablishedFatherSuffix_NAME,
           DisEstablishedFather_CODE,
           DisEstablishedFatherMci_IDNO,
           DisEstablishedFatherLast_NAME,
           DisEstablishedFatherFirst_NAME,
           DisEstablishedFatherMiddle_NAME,
           DisEstablishedFatherSuffix_NAME,
           PaternityEst_INDC,
           StatusEstablish_CODE,
           StateEstablish_CODE,
           FileEstablish_ID,
           PaternityEst_CODE,
           PaternityEst_DATE,
           StateDisestablish_CODE,
           FileDisestablish_ID,
           MethodDisestablish_CODE,
           Disestablish_DATE,
           DescriptionProfile_TEXT,
           QiStatus_CODE,
           VapImage_CODE,
           WorkerUpdate_ID,
           BeginValidity_DATE,
           EndValidity_DATE,
           Update_DTTM,
           TransactionEventSeq_NUMB)
   SELECT MemberMci_IDNO,
          BirthCertificate_ID,
          BornOfMarriage_CODE,
          Conception_DATE,
          ConceptionCity_NAME,
          ConceptionCounty_IDNO,
          ConceptionState_CODE,
          ConceptionCountry_CODE,
          EstablishedMother_CODE,
          EstablishedMotherMci_IDNO,
          EstablishedMotherLast_NAME,
          EstablishedMotherFirst_NAME,
          EstablishedMotherMiddle_NAME,
          EstablishedMotherSuffix_NAME,
          EstablishedFather_CODE,
          EstablishedFatherMci_IDNO,
          EstablishedFatherLast_NAME,
          EstablishedFatherFirst_NAME,
          EstablishedFatherMiddle_NAME,
          EstablishedFatherSuffix_NAME,
          DisEstablishedFather_CODE,
          DisEstablishedFatherMci_IDNO,
          DisEstablishedFatherLast_NAME,
          DisEstablishedFatherFirst_NAME,
          DisEstablishedFatherMiddle_NAME,
          DisEstablishedFatherSuffix_NAME,
          PaternityEst_INDC,
          StatusEstablish_CODE,
          StateEstablish_CODE,
          FileEstablish_ID,
          PaternityEst_CODE,
          PaternityEst_DATE,
          StateDisestablish_CODE,
          FileDisestablish_ID,
          MethodDisestablish_CODE,
          Disestablish_DATE,
          DescriptionProfile_TEXT,
          QiStatus_CODE,
          VapImage_CODE,
          WorkerUpdate_ID,
          BeginValidity_DATE,
          @Ld_Run_DATE AS EndValidity_DATE,
          dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
          TransactionEventSeq_NUMB
     FROM MPAT_Y1
    WHERE MemberMci_IDNO = @An_ChildMemberMci_IDNO;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT HMPAT_Y1 FAILED';

     RAISERROR (50001,16,1);
    END;

   IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE MPAT_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_ChildMemberMci_IDNO AS VARCHAR), '');

     UPDATE MPAT_Y1
        SET BirthCertificate_ID = @Ac_ChildBirthCertificate_ID,
            BornOfMarriage_CODE = @Lc_UpdateNO_BornOfMarriage_CODE,
            StatusEstablish_CODE = @Lc_UpdateE_StatusEstablish_CODE,
            PaternityEst_CODE = @Lc_UpdateVP_MethodEstablish_CODE,
            PaternityEst_DATE = @Ad_PaternityEst_DATE,
            MethodDisestablish_CODE = @Lc_UpdateRCP_MethodDisestablish_CODE,
            PaternityEst_INDC = @Lc_UpdateY_PaternityEst_INDC,
            QiStatus_CODE = @Lc_QiStatusL_CODE,
            Disestablish_DATE = @Ad_Disestablish_DATE,
            StateEstablish_CODE = @Lc_StateEstablishDe_CODE,
            StateDisestablish_CODE = @Ac_StateDisestablish_CODE,
            VapImage_CODE = @Lc_UpdateY_VapImage_CODE,
            EstablishedMother_CODE = @Ac_EstablishedMother_CODE,
            EstablishedMotherMci_IDNO = @An_EstablishedMotherMci_IDNO,
            EstablishedMotherLast_NAME = @Ac_EstablishedMotherLast_NAME,
            EstablishedMotherFirst_NAME = @Ac_EstablishedMotherFirst_NAME,
            EstablishedMotherMiddle_NAME = @Ac_EstablishedMotherMiddle_NAME,
            EstablishedMotherSuffix_NAME = @Ac_EstablishedMotherSuffix_NAME,
            EstablishedFather_CODE = CASE
                                      WHEN @Ac_EstablishedFather_CODE = @Lc_CaseRelationshipP_CODE
                                       THEN @Lc_CaseRelationshipA_CODE
                                      ELSE @Ac_EstablishedFather_CODE
                                     END,
            EstablishedFatherMci_IDNO = @An_EstablishedFatherMci_IDNO,
            EstablishedFatherLast_NAME = @Ac_EstablishedFatherLast_NAME,
            EstablishedFatherFirst_NAME = @Ac_EstablishedFatherFirst_NAME,
            EstablishedFatherMiddle_NAME = @Ac_EstablishedFatherMiddle_NAME,
            EstablishedFatherSuffix_NAME = @Ac_EstablishedFatherSuffix_NAME,
            DisEstablishedFather_CODE = ISNULL(@Ac_DisEstablishedFather_CODE, DisEstablishedFather_CODE),
            DisEstablishedFatherMci_IDNO = ISNULL(@An_DisEstablishedFatherMci_IDNO, DisEstablishedFatherMci_IDNO),
            DisEstablishedFatherLast_NAME = ISNULL(@Ac_DisEstablishedFatherLast_NAME, DisEstablishedFatherLast_NAME),
            DisEstablishedFatherFirst_NAME = ISNULL(@Ac_DisEstablishedFatherFirst_NAME, DisEstablishedFatherFirst_NAME),
            DisEstablishedFatherMiddle_NAME = ISNULL(@Ac_DisEstablishedFatherMiddle_NAME, DisEstablishedFatherMiddle_NAME),
            DisEstablishedFatherSuffix_NAME = ISNULL(@Ac_DisEstablishedFatherSuffix_NAME, DisEstablishedFatherSuffix_NAME),
            BeginValidity_DATE = @Ld_Run_DATE,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = @Ld_Start_DATE
      WHERE MemberMci_IDNO = @An_ChildMemberMci_IDNO;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE MPAT_Y1 - 1 FAILED';

       RAISERROR (50001,16,1);
      END;
    END
   ELSE IF (@Ac_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE MPAT - 2';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_ChildMemberMci_IDNO AS VARCHAR), '');

     UPDATE MPAT_Y1
        SET BirthCertificate_ID = @Ac_ChildBirthCertificate_ID,
            BornOfMarriage_CODE = @Lc_UpdateNO_BornOfMarriage_CODE,
            StatusEstablish_CODE = @Lc_UpdateE_StatusEstablish_CODE,
            PaternityEst_CODE = @Lc_UpdateVP_MethodEstablish_CODE,
            PaternityEst_DATE = @Ad_PaternityEst_DATE,
            PaternityEst_INDC = @Lc_UpdateY_PaternityEst_INDC,
            QiStatus_CODE = @Lc_QiStatusL_CODE,
            Disestablish_DATE = @Ad_Disestablish_DATE,
            StateEstablish_CODE = @Lc_StateEstablishDe_CODE,
            StateDisestablish_CODE = @Ac_StateDisestablish_CODE,
            VapImage_CODE = @Lc_UpdateY_VapImage_CODE,
            EstablishedMother_CODE = @Ac_EstablishedMother_CODE,
            EstablishedMotherMci_IDNO = @An_EstablishedMotherMci_IDNO,
            EstablishedMotherLast_NAME = @Ac_EstablishedMotherLast_NAME,
            EstablishedMotherFirst_NAME = @Ac_EstablishedMotherFirst_NAME,
            EstablishedMotherMiddle_NAME = @Ac_EstablishedMotherMiddle_NAME,
            EstablishedMotherSuffix_NAME = @Ac_EstablishedMotherSuffix_NAME,
            EstablishedFather_CODE = CASE
                                      WHEN @Ac_EstablishedFather_CODE = @Lc_CaseRelationshipP_CODE
                                       THEN @Lc_CaseRelationshipA_CODE
                                      ELSE @Ac_EstablishedFather_CODE
                                     END,
            EstablishedFatherMci_IDNO = @An_EstablishedFatherMci_IDNO,
            EstablishedFatherLast_NAME = @Ac_EstablishedFatherLast_NAME,
            EstablishedFatherFirst_NAME = @Ac_EstablishedFatherFirst_NAME,
            EstablishedFatherMiddle_NAME = @Ac_EstablishedFatherMiddle_NAME,
            EstablishedFatherSuffix_NAME = @Ac_EstablishedFatherSuffix_NAME,
            BeginValidity_DATE = @Ld_Run_DATE,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = @Ld_Start_DATE
      WHERE MemberMci_IDNO = @An_ChildMemberMci_IDNO;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE MPAT_Y1 - 2 FAILED';

       RAISERROR (50001,16,1);
      END;
    END

     SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1';
     SET @Ls_SqlData_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@An_ChildMemberMci_IDNO AS VARCHAR), '');

	UPDATE C
        SET C.BirthState_CODE = @Lc_BirthStateDe_CODE,
            C.BirthCountry_CODE = @Lc_BirthCountryUs_CODE,
            C.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            C.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            C.BeginValidity_DATE = @Ld_Run_DATE,
            C.Update_DTTM = @Ld_Start_DATE
     OUTPUT 
			DELETED.MemberMci_IDNO
			, DELETED.Individual_IDNO
			, DELETED.Last_NAME
			, DELETED.First_NAME
			, DELETED.Middle_NAME
			, DELETED.Suffix_NAME
			, DELETED.Title_NAME
			, DELETED.FullDisplay_NAME
			, DELETED.MemberSex_CODE
			, DELETED.MemberSsn_NUMB
			, DELETED.Birth_DATE
			, DELETED.Emancipation_DATE
			, DELETED.LastMarriage_DATE
			, DELETED.LastDivorce_DATE
			, DELETED.BirthCity_NAME
			, DELETED.BirthState_CODE
			, DELETED.BirthCountry_CODE
			, DELETED.DescriptionHeight_TEXT
			, DELETED.DescriptionWeightLbs_TEXT
			, DELETED.Race_CODE
			, DELETED.ColorHair_CODE
			, DELETED.ColorEyes_CODE
			, DELETED.FacialHair_INDC
			, DELETED.Language_CODE
			, DELETED.TypeProblem_CODE
			, DELETED.Deceased_DATE
			, DELETED.CerDeathNo_TEXT
			, DELETED.LicenseDriverNo_TEXT
			, DELETED.AlienRegistn_ID
			, DELETED.WorkPermitNo_TEXT
			, DELETED.BeginPermit_DATE
			, DELETED.EndPermit_DATE
			, DELETED.HomePhone_NUMB
			, DELETED.WorkPhone_NUMB
			, DELETED.CellPhone_NUMB
			, DELETED.Fax_NUMB
			, DELETED.Contact_EML
			, DELETED.Spouse_NAME
			, DELETED.Graduation_DATE
			, DELETED.EducationLevel_CODE
			, DELETED.Restricted_INDC
			, DELETED.Military_ID
			, DELETED.MilitaryBranch_CODE
			, DELETED.MilitaryStatus_CODE
			, DELETED.MilitaryBenefitStatus_CODE
			, DELETED.SecondFamily_INDC
			, DELETED.MeansTestedInc_INDC
			, DELETED.SsIncome_INDC
			, DELETED.VeteranComps_INDC
			, DELETED.Disable_INDC
			, DELETED.Assistance_CODE
			, DELETED.DescriptionIdentifyingMarks_TEXT
			, DELETED.Divorce_INDC
			, DELETED.BeginValidity_DATE
			, @Ld_Run_DATE AS EndValidity_DATE
			, DELETED.WorkerUpdate_ID
			, DELETED.TransactionEventSeq_NUMB
			, DELETED.Update_DTTM
			, DELETED.TypeOccupation_CODE
			, DELETED.CountyBirth_IDNO
			, DELETED.MotherMaiden_NAME
			, DELETED.FileLastDivorce_ID
			, DELETED.TribalAffiliations_CODE
			, DELETED.FormerMci_IDNO
			, DELETED.StateDivorce_CODE
			, DELETED.CityDivorce_NAME
			, DELETED.StateMarriage_CODE
			, DELETED.CityMarriage_NAME
			, DELETED.IveParty_IDNO     
       INTO HDEMO_Y1
       FROM DEMO_Y1 C
      WHERE C.MemberMci_IDNO = @An_ChildMemberMci_IDNO;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE DEMO_Y1 FAILED!';

       RAISERROR (50001,16,1);
      END;
            
   SET @Ls_Sql_TEXT = 'DECLARE Case_CUR';
   SET @Ls_SqlData_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@An_ChildMemberMci_IDNO AS VARCHAR), '');

   DECLARE Case_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           B.Case_IDNO
      FROM CMEM_Y1 A,
           CASE_Y1 B
     WHERE A.MemberMci_IDNO = @An_ChildMemberMci_IDNO
       AND B.Case_IDNO = A.Case_IDNO
       AND B.StatusCase_CODE = 'O'
       AND 1 = (SELECT COUNT(DISTINCT(X.MemberMci_IDNO))
                  FROM CMEM_Y1 X
                 WHERE X.Case_IDNO = B.Case_IDNO
                   AND X.CaseRelationship_CODE = 'D'
                   AND X.CaseMemberStatus_CODE = 'A')
       AND 1 = (SELECT COUNT(DISTINCT(X.MemberMci_IDNO))
                  FROM CMEM_Y1 X
                 WHERE X.Case_IDNO = B.Case_IDNO
                   AND X.CaseRelationship_CODE = 'P'
                   AND X.CaseMemberStatus_CODE = 'A'
                   AND X.MemberMci_IDNO <> @Ln_UnIdentifiedMci_IDNO)

   SET @Ls_Sql_TEXT = 'OPEN Case_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN Case_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Case_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Case_CUR';
   SET @Ls_SqlData_TEXT = '';

   --create informational alert for each case of the member...
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'GET THE ACTIVE PUTATIVE FATHER''S MCI';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL('P', '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_MemberMciPf_IDNO = A.MemberMci_IDNO
       FROM CMEM_Y1 A
      WHERE A.Case_IDNO = @Ln_CaseCur_Case_IDNO
        AND A.CaseRelationship_CODE = 'P'
        AND A.CaseMemberStatus_CODE = 'A'
        AND A.MemberMci_IDNO <> @Ln_UnIdentifiedMci_IDNO;

     SET @Ls_Sql_TEXT = 'MOVE THE ACTIVE PUTATIVE FATHER''S RECORD TO HCMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMciPf_IDNO AS VARCHAR), '');

     INSERT INTO HCMEM_Y1
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
                  EndValidity_DATE,
                  WorkerUpdate_ID,
                  TransactionEventSeq_NUMB,
                  Update_DTTM,
                  FamilyViolence_DATE,
                  FamilyViolence_INDC,
                  TypeFamilyViolence_CODE)
     SELECT A.Case_IDNO,
            A.MemberMci_IDNO,
            A.CaseRelationship_CODE,
            A.CaseMemberStatus_CODE,
            A.CpRelationshipToChild_CODE,
            A.NcpRelationshipToChild_CODE,
            A.BenchWarrant_INDC,
            A.ReasonMemberStatus_CODE,
            A.Applicant_CODE,
            A.BeginValidity_DATE,
            @Ld_Run_DATE AS EndValidity_DATE,
            A.WorkerUpdate_ID,
            A.TransactionEventSeq_NUMB,
            @Ld_Start_DATE AS Update_DTTM,
            A.FamilyViolence_DATE,
            A.FamilyViolence_INDC,
            A.TypeFamilyViolence_CODE
       FROM CMEM_Y1 A
      WHERE A.Case_IDNO = @Ln_CaseCur_Case_IDNO
        AND A.MemberMci_IDNO = @Ln_MemberMciPf_IDNO;

     SET @Ls_Sql_TEXT = 'UPDATE PUTATIVE FATHER''S CASE RELATIONSHIP CODE TO NCP IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMciPf_IDNO AS VARCHAR), '');

     UPDATE CMEM_Y1
        SET CaseRelationship_CODE = 'A',
            BeginValidity_DATE = @Ld_Run_DATE,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = @Ld_Start_DATE
      WHERE Case_IDNO = @Ln_CaseCur_Case_IDNO
        AND MemberMci_IDNO = @Ln_MemberMciPf_IDNO;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Case_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Case_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE Case_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Case_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE Case_CUR;

   --The case worker assigned to the child's cases will receive an informational alert that reads "CHILD HAS BEEN MATCHED TO A VAP RECORD"
   SET @Ls_Sql_TEXT = 'DECLARE CaseMember_CUR';
   SET @Ls_SqlData_TEXT = 'ChildMemberMci_IDNO = ' + CAST(@An_ChildMemberMci_IDNO AS VARCHAR);

   DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
    SELECT A.Case_IDNO,
           A.MemberMci_IDNO
      FROM CMEM_Y1 A,
           CASE_Y1 B
     WHERE A.MemberMci_IDNO = @An_ChildMemberMci_IDNO
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

   --create informational alert for each case of the member...
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorChmvr_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
      @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorChmvr_CODE,
      @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
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

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseMember_CUR;

     DEALLOCATE CaseMember_CUR;
    END;

   IF CURSOR_STATUS('Local', 'Case_CUR') IN (0, 1)
    BEGIN
     CLOSE Case_CUR;

     DEALLOCATE Case_CUR;
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

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
