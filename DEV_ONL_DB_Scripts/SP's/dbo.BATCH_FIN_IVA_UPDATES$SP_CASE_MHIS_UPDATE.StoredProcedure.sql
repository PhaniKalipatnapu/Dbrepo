/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE
Programmer Name	:	IMP Team.
Description		:	This process re-opens closed cases and/or adds child to existing case and/or changes child's/cp's program type.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS,
					BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS,
Called On		:	BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO,
					BATCH_COMMON$SP_INSERT_MSSN,
					BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM,
					BATCH_COMMON$SP_ALERT_WORKER,
					BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS,
					BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE] (
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_Count_QNTY                        INT = 0,
          @Li_Zero_NUMB                         SMALLINT = 0,
          @Li_FetchStatus_QNTY                  SMALLINT = 0,
          @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
          @Lc_TypeErrorE_CODE                   CHAR(1) = 'E',
          @Lc_TypeWelfareTANF_CODE              CHAR(1) = 'A',
          @Lc_Percenatage_TEXT                  CHAR(1) = '%',
          @Lc_CaseRelationshipCp_CODE           CHAR(1) = 'C',
          @Lc_CaseRelationshipChild_CODE        CHAR(1) = 'D',
          @Lc_TypeWelfareMedicaid_CODE          CHAR(1) = 'M',
          @Lc_TypeWelfareNonTanf_CODE           CHAR(1) = 'N',
          @Lc_Note_INDC                         CHAR(1) = 'N',
          @Lc_TypeWelfareIVAPurchaseOfCare_CODE CHAR(1) = 'C',
          @Lc_StatusEstablishOpen_CODE          CHAR(1) = 'O',
          @Lc_StatusCaseOpen_CODE               CHAR(1) = 'O',
          @Lc_StatusEstablishClosed_CODE        CHAR(1) = 'C',
          @Lc_StatusCaseClosed_CODE             CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE       CHAR(1) = 'A',
          @Lc_CaseMemberStatusInActive_CODE     CHAR(1) = 'I',
          @Lc_Enumeration_CODE                  CHAR(1) = 'P',
          @Lc_StatusEstablish_CODE              CHAR(1) = ' ',
          @Lc_Space_TEXT                        CHAR(1) = ' ',
          @Lc_TypeWelfareF_CODE                 CHAR(1) = 'F',
          @Lc_TypeWelfareH_CODE                 CHAR(1) = 'H',
          @Lc_CaseRelationshipA_CODE            CHAR(1) = 'A',
          @Lc_CommaSpace_TEXT                   CHAR(2) = ', ',
          @Lc_ReasonStatusSI_CODE               CHAR(2) = 'SI',
          @Lc_SubsystemCI_CODE                  CHAR(2) = 'CI',
          @Lc_ActivityMajorCase_CODE            CHAR(4) = 'CASE',
          @Lc_Msg_CODE                          CHAR(5) = ' ',
          @Lc_ActivityMinorCcrcc_CODE           CHAR(5) = 'CCRCR',
          @Lc_ActivityMinorCcrcm_CODE           CHAR(5) = 'CCRCM',
          @Lc_ActivityMinorCam2c_CODE           CHAR(5) = 'CAM2C',
          @Lc_ActivityMinorTmrrc_CODE           CHAR(5) = 'TMRRC',
		  --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -START-
		  @Lc_ActivityMinorCcrnd_CODE           CHAR(5) = 'CCRND',
		  @Lc_ActivityMinorPscta_CODE           CHAR(5) = 'PSCTA',
		  @Lc_ActivityMinorDscta_CODE           CHAR(5) = 'DSCTA',
		  --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -END-
          @Lc_BatchRunUser_TEXT                 CHAR(5) = 'BATCH',
          @Lc_WorkerRole_ID                     CHAR(5) = 'RT001',
          @Ls_DescriptionComments_TEXT          VARCHAR(60) = 'CASE REOPENED BY IV-A REFERRAL BATCH',
          @Ls_Process_NAME                      VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_Procedure_NAME                    VARCHAR(100) = 'SP_CASE_MHIS_UPDATE',
          @Ls_Sql_TEXT                          VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT             VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT                 VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT                      VARCHAR(5000) = ' ',
          @Ld_Low_DATE                          DATE = '01/01/0001',
          @Ld_High_DATE                         DATE = '12/31/9999';
  DECLARE @Ln_ChildSsn_NUMB               NUMERIC(9),
          @Ln_CpMci_IDNO                  NUMERIC(10),
          @Ln_NcpMci_IDNO                 NUMERIC(10),
          @Ln_CaseWelfare_IDNO            NUMERIC(10),
          @Ln_ChildMci_IDNO               NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19, 0) = 0,
          @Lc_ChildSex_CODE               CHAR(1),
          @Lc_IvaProgamType_CODE          CHAR(1),
          @Lc_CpProgamType_CODE           CHAR(1),
          @Lc_ChildRace_CODE              CHAR(1),
          @Lc_CpRelationshipToChild_CODE  CHAR(3),
          @Lc_NcpRelationshipToChild_CODE CHAR(3),
          @Lc_ChildSuffix_NAME            CHAR(4),
          @Lc_ChildFirst_NAME             CHAR(16),
          @Lc_ChildMiddle_NAME            CHAR(20),
          @Lc_ChildLast_NAME              CHAR(20),
          @Ls_ChildFullDisplay_NAME       VARCHAR(60),
          @Ld_Run_DATE                    DATE,
          @Ld_ChildBirth_DATE             DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Lb_IsCaseClosed_BIT            BIT = 0,
          @Lb_ChildExistsInDemo_BIT       BIT = 0,
          @Lb_ChildExistsInMssn_BIT       BIT = 0;
  --CURSOR VARIABLE DECLARATION:
  DECLARE @Ln_MhisCaseCur_Seq_IDNO  NUMERIC(19),
          @Ln_MhisCaseCur_Case_IDNO NUMERIC(6);

  BEGIN TRY
   --Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ld_Run_DATE = @Ad_Run_DATE;

   DECLARE MhisCase_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           b.Seq_IDNO,
           b.Case_IDNO
      FROM ##TempCaseReopenAddUpdateChild_P1 b;

   SET @Ls_Sql_TEXT = 'OPEN MhisCase_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   OPEN MhisCase_CUR;

   SET @Ls_Sql_TEXT = 'FETCH MhisCase_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM MhisCase_CUR INTO @Ln_MhisCaseCur_Seq_IDNO, @Ln_MhisCaseCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --Update Program Type and/or Add extra child in MHIS
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_Note_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'SET PARAMETER VALUES';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Seq_IDNO AS VARCHAR), '');

     SELECT @Ln_CpMci_IDNO = l.CpMci_IDNO,
            @Ln_NcpMci_IDNO = l.NcpMci_IDNO,
            @Ln_ChildMci_IDNO = l.ChildMci_IDNO,
            @Ln_CaseWelfare_IDNO = l.CaseWelfare_IDNO,
            @Lc_ChildFirst_NAME = l.ChildFirst_NAME,
            @Lc_ChildMiddle_NAME = l.ChildMiddle_NAME,
            @Lc_ChildLast_NAME = l.ChildLast_NAME,
            @Lc_ChildSuffix_NAME = l.ChildSuffix_NAME,
            @Ld_ChildBirth_DATE = CASE
                                   WHEN ISDATE(l.ChildBirth_DATE) = @Li_Zero_NUMB
                                    THEN @Ld_Low_DATE
                                   ELSE CAST(l.ChildBirth_DATE AS DATE)
                                  END,
            @Ln_ChildSsn_NUMB = CASE
                                 WHEN ISNUMERIC(l.ChildSsn_NUMB) = @Li_Zero_NUMB
                                  THEN @Li_Zero_NUMB
                                 ELSE CAST(l.ChildSsn_NUMB AS NUMERIC)
                                END,
            @Lc_ChildSex_CODE = l.ChildSex_CODE,
            @Lc_ChildRace_CODE = ISNULL(dbo.BATCH_FIN_IVA_UPDATES$SF_GET_RACE_CODE_ONE_CHAR(l.ChildRace_CODE), @Lc_Space_TEXT),
            @Lc_CpRelationshipToChild_CODE = l.CpRelationshipToChild_CODE,
            @Lc_NcpRelationshipToChild_CODE = l.NcpRelationshipToChild_CODE,
            @Lc_IvaProgamType_CODE = CASE
                                      WHEN l.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                                       THEN @Lc_TypeWelfareTANF_CODE
                                      WHEN l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                                       THEN @Lc_TypeWelfareMedicaid_CODE
                                      WHEN l.Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
                                       THEN @Lc_TypeWelfareNonTanf_CODE
                                     END
       FROM LIVAR_Y1 l
      WHERE l.Seq_IDNO = @Ln_MhisCaseCur_Seq_IDNO;

     SET @Ls_ChildFullDisplay_NAME = LTRIM (RTRIM (@Lc_ChildLast_NAME)) + (CASE
                                                                            WHEN LTRIM (RTRIM (@Lc_ChildSuffix_NAME)) = ''
                                                                             THEN ''
                                                                            ELSE @Lc_Space_TEXT
                                                                           END) + LTRIM (RTRIM (@Lc_ChildSuffix_NAME)) + @Lc_CommaSpace_TEXT + LTRIM (RTRIM (@Lc_ChildFirst_NAME)) + @Lc_Space_TEXT + LTRIM (RTRIM (@Lc_ChildMiddle_NAME));
     SET @Lb_ChildExistsInMssn_BIT = ISNULL((SELECT TOP 1 1
                                               FROM MSSN_Y1
                                              WHERE MemberMci_IDNO = @Ln_ChildMci_IDNO), 0);
     SET @Lb_ChildExistsInDemo_BIT = ISNULL((SELECT TOP 1 1
                                               FROM DEMO_Y1
                                              WHERE MemberMci_IDNO = @Ln_ChildMci_IDNO), 0);
     --CHECKS WHETHER CASE IS CLOSED OR NOT		
     SET @Lb_IsCaseClosed_BIT = ISNULL((SELECT TOP 1 1
                                          FROM CASE_Y1
                                         WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                                           AND StatusCase_CODE = @Lc_StatusCaseClosed_CODE), 0);

     --CHILD DEMO
     IF @Lb_ChildExistsInDemo_BIT = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT DEMO_Y1 FOR ADD CHILD ON EXISTING CASE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_ChildLast_NAME, '') + ', Suffix_NAME = ' + ISNULL(@Lc_ChildSuffix_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_ChildFirst_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_ChildMiddle_NAME, '') + ', FullDisplay_NAME = ' + ISNULL(@Ls_ChildFullDisplay_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_ChildSex_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_ChildSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_ChildBirth_DATE AS VARCHAR), '') + ', Race_CODE = ' + ISNULL(@Lc_ChildRace_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

       EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO
        @An_MemberMci_IDNO           = @Ln_ChildMci_IDNO,
        @Ac_Last_NAME                = @Lc_ChildLast_NAME,
        @Ac_Suffix_NAME              = @Lc_ChildSuffix_NAME,
        @Ac_First_NAME               = @Lc_ChildFirst_NAME,
        @Ac_Middle_NAME              = @Lc_ChildMiddle_NAME,
        @As_FullDisplay_NAME         = @Ls_ChildFullDisplay_NAME,
        @Ac_MemberSex_CODE           = @Lc_ChildSex_CODE,
        @An_MemberSsn_NUMB           = @Ln_ChildSsn_NUMB,
        @Ad_Birth_DATE               = @Ld_ChildBirth_DATE,
        @Ac_Race_CODE                = @Lc_ChildRace_CODE,
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
         AND @Ln_ChildSsn_NUMB != 0)
        AND NOT EXISTS (SELECT 1
                          FROM MSSN_Y1
                         WHERE EndValidity_DATE = @Ld_High_DATE
                           AND MemberSsn_NUMB = @Ln_ChildSsn_NUMB
                           AND MemberMci_IDNO != @Ln_ChildMci_IDNO
                           AND Enumeration_CODE NOT IN ('B'))
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR ADD CHILD ON EXISTING CASE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_ChildSsn_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Lc_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

       EXECUTE BATCH_COMMON$SP_INSERT_MSSN
        @An_MemberMci_IDNO        = @Ln_ChildMci_IDNO,
        @An_MemberSsn_NUMB        = @Ln_ChildSsn_NUMB,
        @Ac_Enumeration_CODE      = @Lc_Enumeration_CODE,
        @Ad_BeginValidity_DATE    = @Ld_Run_DATE,
        @Ac_Process_ID            = @Ac_Job_ID,
        @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

     --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -START-
	 IF EXISTS (SELECT 1
                  FROM CMEM_Y1 c
                 WHERE c.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                   AND c.MemberMci_IDNO = @Ln_ChildMci_IDNO
                   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE)
      BEGIN
	   --DSCTA - INSERT ACTIVITY FOR DEPENDENT STATUS HAS BEEN CHANGED TO ACTIVE
       SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR DEPENDENT STATUS HAS BEEN CHANGED TO ACTIVE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorDscta_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

       INSERT ##InsertActivity_P1
              (Case_IDNO,
               MemberMci_IDNO,
               ActivityMajor_CODE,
               ActivityMinor_CODE,
               Subsystem_CODE)
       SELECT DISTINCT
              @Ln_MhisCaseCur_Case_IDNO AS Case_IDNO,
              @Ln_ChildMci_IDNO AS MemberMci_IDNO,
              @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
              @Lc_ActivityMinorDscta_CODE AS ActivityMinor_CODE,
              @Lc_SubsystemCI_CODE AS Subsystem_CODE;
	  END

     IF EXISTS (SELECT 1
                  FROM CMEM_Y1 c
                 WHERE c.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                   AND @Lb_IsCaseClosed_BIT = 1
                   AND c.MemberMci_IDNO = @Ln_NcpMci_IDNO
                   AND NOT EXISTS (SELECT 1
                                     FROM CMEM_Y1 cm
                                    WHERE cm.CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE
                                      AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
                   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE)
      BEGIN
	   --PSCTA - INSERT ACTIVITY FOR PUTATIVE FATHER STATUS HAS BEEN CHANGED TO ACTIVE
       SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR PUTATIVE FATHER STATUS HAS BEEN CHANGED TO ACTIVE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NcpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorPscta_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

       INSERT ##InsertActivity_P1
              (Case_IDNO,
               MemberMci_IDNO,
               ActivityMajor_CODE,
               ActivityMinor_CODE,
               Subsystem_CODE)
       SELECT DISTINCT
              @Ln_MhisCaseCur_Case_IDNO AS Case_IDNO,
              @Ln_NcpMci_IDNO AS MemberMci_IDNO,
              @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
              @Lc_ActivityMinorPscta_CODE AS ActivityMinor_CODE,
              @Lc_SubsystemCI_CODE AS Subsystem_CODE;
	  END
	 --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -END-

	 --Change the CHILD/CP/NCP status to Active if Inactive.
     IF EXISTS (SELECT 1
                  FROM CMEM_Y1 c
                 WHERE c.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                   AND (c.MemberMci_IDNO = @Ln_ChildMci_IDNO
                         OR c.MemberMci_IDNO = @Ln_CpMci_IDNO
                         OR (@Lb_IsCaseClosed_BIT = 1
                             AND c.MemberMci_IDNO = @Ln_NcpMci_IDNO
                             AND NOT EXISTS (SELECT 1
                                               FROM CMEM_Y1 cm
                                              WHERE cm.CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE
                                                AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)))
                   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CMEM_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', ChildMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_CpMci_IDNO AS VARCHAR), '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_NcpMci_IDNO AS VARCHAR), '');

       UPDATE CMEM_Y1
          SET CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE,
              BeginValidity_DATE = @Ld_Run_DATE,
              WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
              ReasonMemberStatus_CODE = @Lc_Space_TEXT,
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
         FROM CMEM_Y1 c
        WHERE c.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
          AND (c.MemberMci_IDNO = @Ln_ChildMci_IDNO
                OR c.MemberMci_IDNO = @Ln_CpMci_IDNO
                OR (@Lb_IsCaseClosed_BIT = 1
                    AND c.MemberMci_IDNO = @Ln_NcpMci_IDNO
                    AND NOT EXISTS (SELECT 1
                                      FROM CMEM_Y1 cm
                                     WHERE cm.Case_IDNO = c.Case_IDNO
                                       AND CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE
                                       AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)))
          AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusInActive_CODE;

       SET @Li_Count_QNTY = @@ROWCOUNT;

       IF @Li_Count_QNTY = @Li_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'UPDATE CMEM_Y1 FAILED';

         RAISERROR (50001,16,1);
        END
      END

     --CHILD CMEM ENTRY
     IF NOT EXISTS (SELECT 1
                      FROM CMEM_Y1 c
                     WHERE c.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                       AND c.MemberMci_IDNO = @Ln_ChildMci_IDNO
                       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
      BEGIN
       --CHECK CHILD'S ENTRY IN CMEM FOR ADDING A NEW CHILD
       SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipChild_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', CpRelationshipToChild_CODE = ' + ISNULL(@Lc_CpRelationshipToChild_CODE, '') + ', NcpRelationshipToChild_CODE = ' + ISNULL(@Lc_NcpRelationshipToChild_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM
        @An_Case_IDNO                   = @Ln_MhisCaseCur_Case_IDNO,
        @An_MemberMci_IDNO              = @Ln_ChildMci_IDNO,
        @Ac_CaseRelationship_CODE       = @Lc_CaseRelationshipChild_CODE,
        @Ac_CaseMemberStatus_CODE       = @Lc_CaseMemberStatusActive_CODE,
        @Ac_CpRelationshipToChild_CODE  = @Lc_CpRelationshipToChild_CODE,
        @Ac_NcpRelationshipToChild_CODE = @Lc_NcpRelationshipToChild_CODE,
        @Ac_WorkerUpdate_ID             = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB    = @Ln_TransactionEventSeq_NUMB,
        @Ac_Msg_CODE                    = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT       = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -START-
	   --CCRND - INSERT ACTIVITY FOR DEPENDENT ADDED TO CASE
       SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR DEPENDENT ADDED TO CASE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCcrnd_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

       INSERT ##InsertActivity_P1
              (Case_IDNO,
               MemberMci_IDNO,
               ActivityMajor_CODE,
               ActivityMinor_CODE,
               Subsystem_CODE)
       SELECT DISTINCT
              @Ln_MhisCaseCur_Case_IDNO AS Case_IDNO,
              @Ln_ChildMci_IDNO AS MemberMci_IDNO,
              @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
              @Lc_ActivityMinorCcrnd_CODE AS ActivityMinor_CODE,
              @Lc_SubsystemCI_CODE AS Subsystem_CODE;
	   --13733 - CR0435 Add Case Journal Entry and Alert 20141120 -END-
      END

     --CHILD MPAT
     IF NOT EXISTS (SELECT 1
                      FROM MPAT_Y1 m
                     WHERE m.MemberMci_IDNO = @Ln_ChildMci_IDNO)
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT MPAT_Y1 : ADD CHILD/CHANGE PROGRAM TYPE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

       EXEC BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT
        @An_MemberMci_IDNO           = @Ln_ChildMci_IDNO,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     --RE-OPEN THE CASE		
     IF @Lb_IsCaseClosed_BIT = 1
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1 - REOPEN CASE AND CREATE HISTORY RECORD';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '');

       UPDATE CASE_Y1
          SET StatusCase_CODE = @Lc_StatusCaseOpen_CODE,
              RsnStatusCase_CODE = @Lc_Space_TEXT,
              Opened_DATE = @Ld_Run_DATE,
              StatusCurrent_DATE = @Ld_Run_DATE,
              BeginValidity_DATE = @Ld_Run_DATE,
              Update_DTTM = @Ld_Start_DATE,
              WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
              TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              DescriptionComments_TEXT = @Ls_DescriptionComments_TEXT
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
        WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO;

       SET @Li_Count_QNTY = @@ROWCOUNT;

       IF @Li_Count_QNTY = @Li_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'UPDATE CASE_Y1 FAILED';

         RAISERROR (50001,16,1);
        END

       --UPDATE ESTABLISHMENT STATUS
       SET @Lc_StatusEstablish_CODE = @Lc_Space_TEXT;
       SET @Ls_Sql_TEXT = 'SELECT StatusEstablish_CODE FOR CURRENT ESTABLISHMENT STATUS';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Lc_StatusEstablish_CODE = ISNULL(a.StatusEstablish_CODE, @Lc_Space_TEXT)
         FROM ACES_Y1 a
        WHERE a.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
          AND a.EndValidity_DATE = @Ld_High_DATE;

       IF @Lc_StatusEstablish_CODE = @Lc_StatusEstablishClosed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE ACES_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE ACES_Y1
            SET BeginEstablishment_DATE = @Ad_Run_DATE,
                StatusEstablish_CODE = @Lc_StatusEstablishOpen_CODE,
                ReasonStatus_CODE = @Lc_ReasonStatusSI_CODE,
                BeginValidity_DATE = @Ad_Run_DATE,
                WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                Update_DTTM = @Ld_Start_DATE,
                TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
         OUTPUT DELETED.Case_IDNO,
                DELETED.BeginEstablishment_DATE,
                DELETED.StatusEstablish_CODE,
                DELETED.ReasonStatus_CODE,
                DELETED.BeginValidity_DATE,
                @Ad_Run_DATE AS EndValidity_DATE,
                DELETED.WorkerUpdate_ID,
                DELETED.Update_DTTM,
                DELETED.TransactionEventSeq_NUMB
         INTO ACES_Y1
          WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Count_QNTY = @@ROWCOUNT;

         IF @Li_Count_QNTY = @Li_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE ACES_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
        END

       --CASE REASSIGNMENT FOR REOPENED CASE AND ALERT WORKER
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ALERT_WORKER';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Role_ID = ' + ISNULL(@Lc_WorkerRole_ID, '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '');

       EXECUTE BATCH_COMMON$SP_ALERT_WORKER
        @An_Case_IDNO                = @Ln_MhisCaseCur_Case_IDNO,
        @Ac_SignedonWorker_ID        = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_Role_ID                  = @Lc_WorkerRole_ID,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
            OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
        BEGIN
         RAISERROR (50001,16,1);
        END
       ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Process_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_Job_ID,
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
          @An_Line_NUMB                = 0,
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

     --END OF RE-OPEN THE CASE
     --Childs MHIS
     IF EXISTS (SELECT 1
                  FROM MHIS_Y1 a
                 WHERE a.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                   AND a.MemberMci_IDNO = @Ln_ChildMci_IDNO
                   AND ((a.TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                         AND @Lc_IvaProgamType_CODE IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE))
                         OR (a.TypeWelfare_CODE = @Lc_TypeWelfareMedicaid_CODE
                             AND @Lc_IvaProgamType_CODE IN (@Lc_TypeWelfareTANF_CODE)))
                   AND a.End_DATE = @Ld_High_DATE)
         OR NOT EXISTS (SELECT 1
                          FROM MHIS_Y1 a
                         WHERE a.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                           AND a.MemberMci_IDNO = @Ln_ChildMci_IDNO)
      BEGIN
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS';
       SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildMci_IDNO AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_IvaProgamType_CODE, '');

       EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ad_Start_DATE            = @Ld_Run_DATE,
        @Ac_Job_ID                = @Ac_Job_ID,
        @An_Case_IDNO             = @Ln_MhisCaseCur_Case_IDNO,
        @An_MemberMci_IDNO        = @Ln_ChildMci_IDNO,
        @An_CaseWelfare_IDNO      = @Ln_CaseWelfare_IDNO,
        @Ac_TypeWelfare_CODE      = @Lc_IvaProgamType_CODE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

     --END Childs MHIS
     --CP MHIS UPDATE CALL
     SET @Lc_CpProgamType_CODE = ISNULL((SELECT a.TypeWelfare_CODE
                                           FROM (SELECT DISTINCT TOP 1
                                                        TypeWelfare_CODE AS TypeWelfare_CODE
                                                   FROM MHIS_Y1
                                                  WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                                                    AND MemberMci_IDNO IN (SELECT DISTINCT
                                                                                  MemberMci_IDNO
                                                                             FROM CMEM_Y1
                                                                            WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                                                                              AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                                              AND CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE)
                                                    AND End_DATE = @Ld_High_DATE
                                                    AND TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE)
                                                  ORDER BY TypeWelfare_CODE)a,
                                                (SELECT DISTINCT
                                                        TypeWelfare_CODE AS TypeWelfare_CODE
                                                   FROM MHIS_Y1
                                                  WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                                                    AND MemberMci_IDNO = @Ln_CpMci_IDNO
                                                    AND End_DATE = @Ld_High_DATE)b
                                          WHERE (b.TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                                             AND a.TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE))
                                             OR (b.TypeWelfare_CODE = @Lc_TypeWelfareMedicaid_CODE
                                                 AND a.TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE))), @Lc_Space_TEXT);

     IF @Lc_CpProgamType_CODE != @Lc_Space_TEXT
        AND NOT EXISTS (SELECT 1
                          FROM ##TempCaseReopenAddUpdateChild_P1 t
                         WHERE t.Seq_IDNO > @Ln_MhisCaseCur_Seq_IDNO
                           AND t.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO)
      BEGIN
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS FOR CP';
       SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CpMci_IDNO AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_CpProgamType_CODE, '');

       EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ad_Start_DATE            = @Ld_Run_DATE,
        @Ac_Job_ID                = @Ac_Job_ID,
        @An_Case_IDNO             = @Ln_MhisCaseCur_Case_IDNO,
        @An_MemberMci_IDNO        = @Ln_CpMci_IDNO,
        @An_CaseWelfare_IDNO      = @Ln_CaseWelfare_IDNO,
        @Ac_TypeWelfare_CODE      = @Lc_CpProgamType_CODE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

     IF @Lb_IsCaseClosed_BIT = 1
      BEGIN
       --INSERT ACTIVITY FOR CASE REOPENED
       SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CASE REOPENED';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NcpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCcrcc_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

       INSERT ##InsertActivity_P1
              (Case_IDNO,
               MemberMci_IDNO,
               ActivityMajor_CODE,
               ActivityMinor_CODE,
               Subsystem_CODE)
       SELECT DISTINCT
              @Ln_MhisCaseCur_Case_IDNO AS Case_IDNO,
              @Ln_NcpMci_IDNO AS MemberMci_IDNO,
              @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
              @Lc_ActivityMinorCcrcc_CODE AS ActivityMinor_CODE,
              @Lc_SubsystemCI_CODE AS Subsystem_CODE;

       --INSERT ACTIVITY FOR CASE COMMENTS ADDED
       SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1 FOR CASE COMMENTS ADDED';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NcpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCcrcm_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

       INSERT ##InsertActivity_P1
              (Case_IDNO,
               MemberMci_IDNO,
               ActivityMajor_CODE,
               ActivityMinor_CODE,
               Subsystem_CODE)
       SELECT DISTINCT
              @Ln_MhisCaseCur_Case_IDNO AS Case_IDNO,
              @Ln_NcpMci_IDNO AS MemberMci_IDNO,
              @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
              @Lc_ActivityMinorCcrcm_CODE AS ActivityMinor_CODE,
              @Lc_SubsystemCI_CODE AS Subsystem_CODE;
      END

     --1ST ALERT CASE
     SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1';
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
      WHERE m.Case_IDNO <> @Ln_MhisCaseCur_Case_IDNO
        AND m.MemberMci_IDNO = @Ln_ChildMci_IDNO
        AND m.End_DATE = @Ld_High_DATE
        AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareF_CODE, @Lc_TypeWelfareH_CODE)
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
      WHERE ca.Case_IDNO <> @Ln_MhisCaseCur_Case_IDNO
        AND ca.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
        AND cm.Case_IDNO = ca.Case_IDNO
        AND cm.MemberMci_IDNO = @Ln_ChildMci_IDNO
        AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
        AND cm.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
        AND c.Case_IDNO = ca.Case_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
        AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;

     -------NEXT CASE ID FETCH			
     FETCH NEXT FROM MhisCase_CUR INTO @Ln_MhisCaseCur_Seq_IDNO, @Ln_MhisCaseCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE MhisCase_CUR;

   DEALLOCATE MhisCase_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --CLOSE & DEALLOCATE CURSORS
   IF CURSOR_STATUS ('LOCAL', 'MhisCase_CUR') IN (0, 1)
    BEGIN
     CLOSE MhisCase_CUR;

     DEALLOCATE MhisCase_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = ISNULL(@Lc_Msg_CODE, @Lc_StatusFailed_CODE);
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
