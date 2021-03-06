/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_IFMS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_IFMS 
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_IFMS is 
					  to
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_IFMS] (
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_Action_CODE           CHAR(1),
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Transaction25_AMNT    NUMERIC(2) = 25,
          @Lc_Space_TEXT            CHAR = ' ',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_No_INDC               CHAR(1) = 'N',
          @Lc_TransTypeU1_CODE      CHAR(1) = 'U',
          @Lc_RespondInitI1_TEXT    CHAR(1) = 'I',
          @Lc_TransTypeI1_CODE      CHAR(1) = 'I',
          @Lc_ActionP1_CODE         CHAR(1) = 'P',
          @Lc_TransTypeA1_CODE      CHAR(1) = 'A',
          @Lc_TransTypeD1_CODE      CHAR(1) = 'D',
          @Lc_InterceptI_CODE       CHAR(1) = 'I',
          @Lc_InterceptS_CODE       CHAR(1) = 'S',
          @Lc_InterceptB_CODE       CHAR(1) = 'B',
          @Lc_TypeTransactionA_CODE CHAR(1) = 'A',
          @Lc_TypeTransactionM_CODE CHAR(1) = 'M',
          @Lc_TypeTransactionR_CODE CHAR(1) = 'R',
          @Lc_FunctionCol_CODE      CHAR(3) = 'COL',
          @Lc_BatchRunUser_TEXT     CHAR(5) = 'BATCH',
          @Lc_ReasonCisub_CODE      CHAR(5) = 'CISUB',
          @Lc_Job_ID                CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME        VARCHAR(100) = 'SP_SAVE_IFMS',
          @Ld_Run_DATE              DATE = @Ad_Run_DATE,
          @Ld_High_DATE             DATE = '12/31/9999',
          @Ld_Low_DATE              DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
          @Ln_TaxYear_NUMB             NUMERIC(4) = @An_TaxYear_NUMB,
          @Ln_EventFunctionalSeq_NUMB  NUMERIC(4) = 0,
          @Ln_PendingCur_Case_IDNO     NUMERIC(6, 0) = 0,
          @Ln_RespondentMci_IDNO       NUMERIC(10) = 0,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TotalInterestOwed_AMNT   NUMERIC(11, 2) = 0,
          @Ln_TotalArrearsOwed_AMNT    NUMERIC(11, 2) = 0,
          @Ln_FetchStatus_QNTY         NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Lc_Note_INDC                CHAR(1) = '',
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_Process_ID               CHAR(10),
          @Lc_Worker_ID                CHAR(30),
          @Ls_Sql_TEXT                 VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(200),
          @Ls_SqlData_TEXT             VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ld_Temp_DATE                DATE,
          @Ld_ArrearComputed_DATE      DATE,
          @Ld_EffectiveEvent_DATE      DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @Ls_Sql_TEXT = 'INSERT - HCASE_Y1 Seq_IDNO CASE';
   SET @Ls_SqlData_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   INSERT INTO HCASE_Y1
               (Application_IDNO,
                ApplicationFee_CODE,
                AppReq_DATE,
                AppRetd_DATE,
                AppSent_DATE,
                AppSigned_DATE,
                AprvIvd_DATE,
                AssignedFips_CODE,
                BeginValidity_DATE,
                Case_IDNO,
                CaseCategory_CODE,
                ClientLitigantRole_CODE,
                County_IDNO,
                CpRelationshipToNcp_CODE,
                DescriptionComments_TEXT,
                Divorced_DATE,
                FeeCheckNo_TEXT,
                FeePaid_DATE,
                File_ID,
                GoodCause_CODE,
                GoodCause_DATE,
                Intercept_CODE,
                IvdApplicant_CODE,
                Jurisdiction_INDC,
                Marriage_DATE,
                MedicalOnly_INDC,
                NonCoop_CODE,
                NonCoop_DATE,
                Office_IDNO,
                Opened_DATE,
                ReasonFeeWaived_CODE,
                Referral_DATE,
                RespondInit_CODE,
                Restricted_INDC,
                RsnStatusCase_CODE,
                ServiceRequested_CODE,
                SourceRfrl_CODE,
                StatusCase_CODE,
                StatusCurrent_DATE,
                StatusEnforce_CODE,
                TransactionEventSeq_NUMB,
                TypeCase_CODE,
                Update_DTTM,
                Worker_ID,
                WorkerUpdate_ID,
                EndValidity_DATE)
   SELECT Application_IDNO,
          ApplicationFee_CODE,
          AppReq_DATE,
          AppRetd_DATE,
          AppSent_DATE,
          AppSigned_DATE,
          AprvIvd_DATE,
          AssignedFips_CODE,
          BeginValidity_DATE,
          Case_IDNO,
          CaseCategory_CODE,
          ClientLitigantRole_CODE,
          County_IDNO,
          CpRelationshipToNcp_CODE,
          DescriptionComments_TEXT,
          Divorced_DATE,
          FeeCheckNo_TEXT,
          FeePaid_DATE,
          File_ID,
          GoodCause_CODE,
          GoodCause_DATE,
          Intercept_CODE,
          IvdApplicant_CODE,
          Jurisdiction_INDC,
          Marriage_DATE,
          MedicalOnly_INDC,
          NonCoop_CODE,
          NonCoop_DATE,
          Office_IDNO,
          Opened_DATE,
          ReasonFeeWaived_CODE,
          Referral_DATE,
          RespondInit_CODE,
          Restricted_INDC,
          RsnStatusCase_CODE,
          ServiceRequested_CODE,
          SourceRfrl_CODE,
          StatusCase_CODE,
          StatusCurrent_DATE,
          StatusEnforce_CODE,
          TransactionEventSeq_NUMB,
          TypeCase_CODE,
          Update_DTTM,
          Worker_ID,
          WorkerUpdate_ID,
          @Ld_Run_DATE AS EndValidity_DATE
     FROM CASE_Y1 A
    WHERE Case_IDNO IN (SELECT a.Case_IDNO AS Case_IDNO
                          FROM PIFMS_Y1 a
                         WHERE a.TypeTransaction_CODE = @Lc_TransTypeU1_CODE
                         GROUP BY a.Case_IDNO
                        HAVING SUM(a.Transaction_AMNT) <= 0)
      AND NOT EXISTS (SELECT 1
                        FROM HCASE_Y1 B
                       WHERE B.BeginValidity_DATE = A.BeginValidity_DATE
                         AND B.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
                         AND B.Case_IDNO = A.Case_IDNO);

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_No_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1';
   SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeU1_CODE, '');

   UPDATE CASE_Y1
      SET Intercept_CODE = CASE dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(Intercept_CODE)
                            WHEN @Lc_InterceptI_CODE
                             THEN @Lc_No_INDC
                            ELSE @Lc_InterceptS_CODE
                           END,
          WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
          Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          BeginValidity_DATE = @Ld_Run_DATE
    WHERE Case_IDNO IN (SELECT a.Case_IDNO AS Case_IDNO

                          FROM PIFMS_Y1 a
                         WHERE a.TypeTransaction_CODE = @Lc_TransTypeU1_CODE
                         GROUP BY a.Case_IDNO
                        HAVING SUM(a.Transaction_AMNT) <= 0);

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
   SET @Ld_Temp_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   DECLARE Pending_Cur INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           a.Case_IDNO
      FROM PIFMS_Y1 a,
           CASE_Y1 b
     WHERE a.Case_IDNO = b.Case_IDNO
       AND b.RespondInit_CODE = @Lc_RespondInitI1_TEXT
       AND a.TypeTransaction_CODE = @Lc_TransTypeI1_CODE;

   SET @Ls_Sql_TEXT = 'Open Pending_Cur';

   OPEN Pending_Cur;

   SET @Ls_Sql_TEXT = 'Fetch Pending_Cur';

   FETCH NEXT FROM Pending_Cur INTO @Ln_PendingCur_Case_IDNO;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'While loop 1';

   --
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PendingCur_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_RespondentMci_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Lc_FunctionCol_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionP1_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonCisub_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Generated_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Form_ID = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FormWeb_URL = ' + ISNULL(@Lc_Space_TEXT, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', CaseFormer_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsCarrier_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsPolicyNo_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Hearing_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Dismissal_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', GeneticTest_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', PfNoShow_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Attachment_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', File_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearComputed_DATE = ' + ISNULL(CAST(@Ld_ArrearComputed_DATE AS VARCHAR), '') + ', TotalArrearsOwed_AMNT = ' + ISNULL(CAST(@Ln_TotalArrearsOwed_AMNT AS VARCHAR), '') + ', TotalInterestOwed_AMNT = ' + ISNULL(CAST(@Ln_TotalInterestOwed_AMNT AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Temp_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
      @An_Case_IDNO                    = @Ln_PendingCur_Case_IDNO,
      @An_RespondentMci_IDNO           = @Ln_RespondentMci_IDNO,
      @Ac_Function_CODE                = @Lc_FunctionCol_CODE,
      @Ac_Action_CODE                  = @Lc_ActionP1_CODE,
      @Ac_Reason_CODE                  = @Lc_ReasonCisub_CODE,
      @Ac_IVDOutOfStateFips_CODE       = @Lc_Space_TEXT,
      @Ac_IVDOutOfStateCountyFips_CODE = @Lc_Space_TEXT,
      @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_Space_TEXT,
      @Ac_IVDOutOfStateCase_ID         = @Lc_Space_TEXT,
      @Ad_Generated_DATE               = @Ld_Run_DATE,
      @Ac_Form_ID                      = @Ln_Zero_NUMB,
      @As_FormWeb_URL                  = @Lc_Space_TEXT,
      @An_TransHeader_IDNO             = @Ln_Zero_NUMB,
      @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
      @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
      @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
      @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
      @Ad_Hearing_DATE                 = @Ld_Low_DATE,
      @Ad_Dismissal_DATE               = @Ld_Low_DATE,
      @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
      @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
      @Ac_Attachment_INDC              = @Lc_No_INDC,
      @Ac_File_ID                      = @Lc_Space_TEXT,
      @Ad_ArrearComputed_DATE          = @Ld_ArrearComputed_DATE,
      @An_TotalArrearsOwed_AMNT        = @Ln_TotalArrearsOwed_AMNT,
      @An_TotalInterestOwed_AMNT       = @Ln_TotalInterestOwed_AMNT,
      @Ac_Process_ID                   = @Lc_Process_ID,
      @Ad_BeginValidity_DATE           = @Ld_Run_DATE,
      @Ac_SignedonWorker_ID            = @Lc_BatchRunUser_TEXT,
      @Ad_Update_DTTM                  = @Ld_Temp_DATE,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @As_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'Fetch Pending_Cur - 2';

     FETCH NEXT FROM Pending_Cur INTO @Ln_PendingCur_Case_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Pending_Cur;

   DEALLOCATE Pending_Cur;

   IF @Ac_Action_CODE = @Lc_TransTypeI1_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT - Seq_IDNO CASE FOR $25';
     SET @Ls_Sql_TEXT = 'INSERT - HCASE_Y1';
     SET @Ls_SqlData_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     INSERT INTO HCASE_Y1
                 (Application_IDNO,
                  ApplicationFee_CODE,
                  AppReq_DATE,
                  AppRetd_DATE,
                  AppSent_DATE,
                  AppSigned_DATE,
                  AprvIvd_DATE,
                  AssignedFips_CODE,
                  BeginValidity_DATE,
                  Case_IDNO,
                  CaseCategory_CODE,
                  ClientLitigantRole_CODE,
                  County_IDNO,
                  CpRelationshipToNcp_CODE,
                  DescriptionComments_TEXT,
                  Divorced_DATE,
                  FeeCheckNo_TEXT,
                  FeePaid_DATE,
                  File_ID,
                  GoodCause_CODE,
                  GoodCause_DATE,
                  Intercept_CODE,
                  IvdApplicant_CODE,
                  Jurisdiction_INDC,
                  Marriage_DATE,
                  MedicalOnly_INDC,
                  NonCoop_CODE,
                  NonCoop_DATE,
                  Office_IDNO,
                  Opened_DATE,
                  ReasonFeeWaived_CODE,
                  Referral_DATE,
                  RespondInit_CODE,
                  Restricted_INDC,
                  RsnStatusCase_CODE,
                  ServiceRequested_CODE,
                  SourceRfrl_CODE,
                  StatusCase_CODE,
                  StatusCurrent_DATE,
                  StatusEnforce_CODE,
                  TransactionEventSeq_NUMB,
                  TypeCase_CODE,
                  Update_DTTM,
                  Worker_ID,
                  WorkerUpdate_ID,
                  EndValidity_DATE)
     SELECT Application_IDNO,
            ApplicationFee_CODE,
            AppReq_DATE,
            AppRetd_DATE,
            AppSent_DATE,
            AppSigned_DATE,
            AprvIvd_DATE,
            AssignedFips_CODE,
            BeginValidity_DATE,
            Case_IDNO,
            CaseCategory_CODE,
            ClientLitigantRole_CODE,
            County_IDNO,
            CpRelationshipToNcp_CODE,
            DescriptionComments_TEXT,
            Divorced_DATE,
            FeeCheckNo_TEXT,
            FeePaid_DATE,
            File_ID,
            GoodCause_CODE,
            GoodCause_DATE,
            Intercept_CODE,
            IvdApplicant_CODE,
            Jurisdiction_INDC,
            Marriage_DATE,
            MedicalOnly_INDC,
            NonCoop_CODE,
            NonCoop_DATE,
            Office_IDNO,
            Opened_DATE,
            ReasonFeeWaived_CODE,
            Referral_DATE,
            RespondInit_CODE,
            Restricted_INDC,
            RsnStatusCase_CODE,
            ServiceRequested_CODE,
            SourceRfrl_CODE,
            StatusCase_CODE,
            StatusCurrent_DATE,
            StatusEnforce_CODE,
            TransactionEventSeq_NUMB,
            TypeCase_CODE,
            Update_DTTM,
            Worker_ID,
            WorkerUpdate_ID,
            @Ld_Run_DATE AS EndValidity_DATE
       FROM CASE_Y1 A
      WHERE Case_IDNO IN (SELECT DISTINCT
                                 a.Case_IDNO
                            FROM PIFMS_Y1 a
                           WHERE a.TypeTransaction_CODE = @Lc_TransTypeI1_CODE
                             AND a.Transaction_AMNT >= @Ln_Transaction25_AMNT)
        AND NOT EXISTS (SELECT 1
                          FROM HCASE_Y1 B
                         WHERE B.BeginValidity_DATE = A.BeginValidity_DATE
                           AND B.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
                           AND B.Case_IDNO = A.Case_IDNO);

     SET @Ls_Sql_TEXT = 'UPDATE - CASE_Y1 Seq_IDNO CASE';
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeI1_CODE, '');

     UPDATE CASE_Y1
        SET Intercept_CODE = CASE dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(CASE_Y1.Intercept_CODE)
                              WHEN @Lc_No_INDC
                               THEN @Lc_InterceptI_CODE
                              ELSE @Lc_InterceptB_CODE
                             END,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            BeginValidity_DATE = @Ld_Run_DATE
      WHERE CASE_Y1.Case_IDNO IN (SELECT DISTINCT

                                         a.Case_IDNO
                                    FROM PIFMS_Y1 a
                                   WHERE a.TypeTransaction_CODE = @Lc_TransTypeI1_CODE
                                     AND a.Transaction_AMNT >= @Ln_Transaction25_AMNT);

     /*
     Move the Main Table Records to the History, if it exists for this Run (ADD)
     */
     SET @Ls_Sql_TEXT = 'INSERT - HIFMS_Y1';
     SET @Ls_SqlData_TEXT = '';

     INSERT INTO HIFMS_Y1
                 (MemberMci_IDNO,
                  Case_IDNO,
                  MemberSsn_NUMB,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  TaxYear_NUMB,
                  TypeArrear_CODE,
                  Transaction_AMNT,
                  SubmitLast_DATE,
                  TypeTransaction_CODE,
                  CountyFips_CODE,
                  Certified_DATE,
                  StateAdministration_CODE,
                  ExcludeIrs_CODE,
                  ExcludeAdm_CODE,
                  ExcludeFin_CODE,
                  ExcludePas_CODE,
                  ExcludeRet_CODE,
                  ExcludeSal_CODE,
                  ExcludeDebt_CODE,
                  ExcludeVen_CODE,
                  ExcludeIns_CODE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB)
     SELECT a.MemberMci_IDNO,
            a.Case_IDNO,
            a.MemberSsn_NUMB,
            a.Last_NAME,
            a.First_NAME,
            a.Middle_NAME,
            a.TaxYear_NUMB,
            a.TypeArrear_CODE,
            a.Transaction_AMNT,
            a.SubmitLast_DATE,
            a.TypeTransaction_CODE,
            a.CountyFips_CODE,
            a.Certified_DATE,
            a.StateAdministration_CODE,
            a.ExcludeIrs_CODE,
            a.ExcludeAdm_CODE,
            a.ExcludeFin_CODE,
            a.ExcludePas_CODE,
            a.ExcludeRet_CODE,
            a.ExcludeSal_CODE,
            a.ExcludeDebt_CODE,
            a.ExcludeVen_CODE,
            a.ExcludeIns_CODE,
            a.WorkerUpdate_ID,
            a.Update_DTTM,
            a.TransactionEventSeq_NUMB
       FROM IFMS_Y1 a
      WHERE EXISTS(SELECT 1
                     FROM (SELECT a.Case_IDNO,
                                  a.MemberMci_IDNO,
                                  a.SubmitLast_DATE,
                                  a.TaxYear_NUMB,
                                  a.TransactionEventSeq_NUMB,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE
                             FROM IFMS_Y1 a,
                                  (SELECT DISTINCT
                                          s.MemberSsn_NUMB,
                                          s.MemberMci_IDNO,
                                          s.TypeArrear_CODE
                                     FROM FEDH_Y1 s
                                    WHERE s.TypeTransaction_CODE = @Lc_TransTypeA1_CODE
                                      AND s.SubmitLast_DATE = @Ld_Run_DATE) b
                            WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                              AND a.TypeArrear_CODE = b.TypeArrear_CODE
                           UNION
                           SELECT a.Case_IDNO,
                                  a.MemberMci_IDNO,
                                  a.SubmitLast_DATE,
                                  a.TaxYear_NUMB,
                                  a.TransactionEventSeq_NUMB,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE
                             FROM IFMS_Y1 a,
                                  (SELECT DISTINCT
                                          s.MemberSsn_NUMB,
                                          s.MemberMci_IDNO,
                                          s.TypeArrear_CODE
                                     FROM FEDH_Y1 s
                                    WHERE s.TypeTransaction_CODE = @Lc_TransTypeA1_CODE
                                      AND s.SubmitLast_DATE = @Ld_Run_DATE) b
                            WHERE b.MemberSsn_NUMB = a.MemberSsn_NUMB
                              AND b.TypeArrear_CODE = a.TypeArrear_CODE) B
                    WHERE a.Case_IDNO = b.Case_IDNO
                      AND a.MemberMci_IDNO = b.MemberMci_IDNO
                      AND a.SubmitLast_DATE = b.SubmitLast_DATE
                      AND a.TaxYear_NUMB = TaxYear_NUMB
                      AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB
                      AND a.TypeArrear_CODE = b.TypeArrear_CODE
                      AND a.TypeTransaction_CODE = b.TypeTransaction_CODE)
AND NOT EXISTS(SELECT 1 FROM HIFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)                      

     /*
     Remove the Main Table Records to the History, if it exists for this Run
     */
     SET @Ls_Sql_TEXT = 'DELETE - IFMS_Y1';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeA1_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeA1_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     DELETE a
       FROM IFMS_Y1 a
      WHERE EXISTS(SELECT 1
                     FROM (SELECT a.Case_IDNO,
                                  a.MemberMci_IDNO,
                                  a.SubmitLast_DATE,
                                  a.TaxYear_NUMB,
                                  a.TransactionEventSeq_NUMB,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE
                             FROM IFMS_Y1 a,
                                  (SELECT DISTINCT
                                          s.MemberSsn_NUMB,
                                          s.MemberMci_IDNO,
                                          s.TypeArrear_CODE
                                     FROM FEDH_Y1 s
                                    WHERE s.TypeTransaction_CODE = @Lc_TransTypeA1_CODE
                                      AND s.SubmitLast_DATE = @Ld_Run_DATE) b
                            WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                              AND a.TypeArrear_CODE = b.TypeArrear_CODE
                           UNION
                           SELECT a.Case_IDNO,
                                  a.MemberMci_IDNO,
                                  a.SubmitLast_DATE,
                                  a.TaxYear_NUMB,
                                  a.TransactionEventSeq_NUMB,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE
                             FROM IFMS_Y1 a,
                                  (SELECT DISTINCT
                                          s.MemberSsn_NUMB,
                                          s.MemberMci_IDNO,
                                          s.TypeArrear_CODE
                                     FROM FEDH_Y1 s
                                    WHERE s.TypeTransaction_CODE = @Lc_TransTypeA1_CODE
                                      AND s.SubmitLast_DATE = @Ld_Run_DATE) b
                            WHERE b.MemberSsn_NUMB = a.MemberSsn_NUMB
                              AND b.TypeArrear_CODE = a.TypeArrear_CODE) B
                    WHERE a.Case_IDNO = b.Case_IDNO
                      AND a.MemberMci_IDNO = b.MemberMci_IDNO
                      AND a.SubmitLast_DATE = b.SubmitLast_DATE
                      AND a.TaxYear_NUMB = TaxYear_NUMB
                      AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB
                      AND a.TypeArrear_CODE = b.TypeArrear_CODE
                      AND a.TypeTransaction_CODE = b.TypeTransaction_CODE);

     /*
     Insert current Run Records to the Main Table
     */
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT - IFMS';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeA1_CODE, '') + ', Certified_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

     INSERT IFMS_Y1
            (MemberMci_IDNO,
             Case_IDNO,
             MemberSsn_NUMB,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             TaxYear_NUMB,
             TypeArrear_CODE,
             Transaction_AMNT,
             SubmitLast_DATE,
             TypeTransaction_CODE,
             CountyFips_CODE,
             Certified_DATE,
             StateAdministration_CODE,
             ExcludeIrs_CODE,
             ExcludeAdm_CODE,
             ExcludeFin_CODE,
             ExcludePas_CODE,
             ExcludeRet_CODE,
             ExcludeSal_CODE,
             ExcludeDebt_CODE,
             ExcludeVen_CODE,
             ExcludeIns_CODE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB)
     SELECT d.MemberMci_IDNO,
            d.Case_IDNO,
            d.MemberSsn_NUMB,
            d.Last_NAME,
            d.First_NAME,
            d.Middle_NAME,
            d.TaxYear_NUMB,
            d.TypeArrear_CODE,
            d.Transaction_AMNT,
            d.SubmitLast_DATE,
            @Lc_TransTypeA1_CODE AS TypeTransaction_CODE,
            RIGHT(('000' + LTRIM(RTRIM(ISNULL(d.CountyFips_CODE, '0')))), 3) AS CountyFips_CODE,
            @Ld_Run_DATE AS Certified_DATE,
            d.StateAdministration_CODE,
            d.ExcludeIrs_CODE,
            d.ExcludeAdm_CODE,
            d.ExcludeFin_CODE,
            d.ExcludePas_CODE,
            d.ExcludeRet_CODE,
            d.ExcludeSal_CODE,
            d.ExcludeDebt_CODE,
            d.ExcludeVen_CODE,
            d.ExcludeIns_CODE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM(SELECT a.MemberMci_IDNO,
                   a.Case_IDNO,
                   a.MemberSsn_NUMB,
                   a.Last_NAME,
                   a.First_NAME,
                   a.Middle_NAME,
                   a.TaxYear_NUMB,
                   a.TypeArrear_CODE,
                   a.Transaction_AMNT,
                   a.SubmitLast_DATE,
                   a.TypeTransaction_CODE,
                   a.CountySubmitted_IDNO AS CountyFips_CODE,
                   a.StateAdministration_CODE,
                   a.ExcludeIrs_CODE,
                   a.ExcludeAdm_CODE,
                   a.ExcludeFin_CODE,
                   a.ExcludePas_CODE,
                   a.ExcludeRet_CODE,
                   a.ExcludeSal_CODE,
                   a.ExcludeDebt_CODE,
                   a.ExcludeVen_CODE,
                   a.ExcludeIns_CODE
              FROM PIFMS_Y1 a,
                   (SELECT f.MemberMci_IDNO,
                           f.TypeArrear_CODE
                      FROM FEDH_Y1 f
                     WHERE f.TypeTransaction_CODE = @Lc_TransTypeA1_CODE
                       AND f.SubmitLast_DATE = @Ld_Run_DATE) AS b
             WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
               AND b.TypeArrear_CODE = a.TypeArrear_CODE) d
WHERE NOT EXISTS(SELECT 1 FROM IFMS_Y1 X
WHERE X.Case_IDNO = d.Case_IDNO
AND X.MemberMci_IDNO = d.MemberMci_IDNO
AND X.SubmitLast_DATE = d.SubmitLast_DATE
AND X.TaxYear_NUMB = d.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = d.TypeArrear_CODE
AND X.TypeTransaction_CODE = @Lc_TransTypeA1_CODE)               
      ORDER BY d.MemberMci_IDNO,
               d.Case_IDNO,
               d.TypeArrear_CODE,
               d.SubmitLast_DATE;

     --'UPDATE IFMS_Y1 FOR ADD TO SET CERTIFIED_DATE, IF DELETE EXISTS IN SAME RUN';
     SET @Ls_Sql_TEXT = 'UPDATE -IFMS_Y1';
     SET @Ls_SqlData_TEXT = 'SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     UPDATE IFMS_Y1
        SET Certified_DATE = (SELECT ISNULL(MIN(b.Certified_DATE), @Ld_Run_DATE)
                                FROM IFMS_Y1 b
                               WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND b.SubmitLast_DATE < @Ld_Run_DATE
                                 AND EXISTS(SELECT 1
                                              FROM FEDH_Y1 c
                                             WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                                               AND c.TypeArrear_CODE = b.TypeArrear_CODE
                                               AND c.TypeTransaction_CODE = @Lc_TransTypeD1_CODE
                                               AND c.SubmitLast_DATE = @Ld_Run_DATE
                                               AND EXISTS(SELECT 1
                                                            FROM FEDH_Y1 d
                                                           WHERE d.MemberMci_IDNO = c.MemberMci_IDNO
                                                             AND d.TypeArrear_CODE <> c.TypeArrear_CODE
                                                             AND d.TypeTransaction_CODE = @Lc_TransTypeA1_CODE
                                                             AND d.SubmitLast_DATE = @Ld_Run_DATE)))
       FROM IFMS_Y1 a
      WHERE a.SubmitLast_DATE = @Ld_Run_DATE
AND 1 = (SELECT COUNT(1) FROM IFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)      

     /* 
     Move the records to history from ifms for the member and arrear type that are in fedh with type transaction as D in the current run
     */
     SET @Ls_Sql_TEXT = 'INSERT - HIFMS_Y1';
     SET @Ls_SqlData_TEXT = '';

     INSERT HIFMS_Y1
            (MemberMci_IDNO,
             Case_IDNO,
             MemberSsn_NUMB,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             TaxYear_NUMB,
             TypeArrear_CODE,
             Transaction_AMNT,
             SubmitLast_DATE,
             TypeTransaction_CODE,
             CountyFips_CODE,
             Certified_DATE,
             StateAdministration_CODE,
             ExcludeIrs_CODE,
             ExcludeAdm_CODE,
             ExcludeFin_CODE,
             ExcludePas_CODE,
             ExcludeRet_CODE,
             ExcludeSal_CODE,
             ExcludeDebt_CODE,
             ExcludeVen_CODE,
             ExcludeIns_CODE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB)
     SELECT c.MemberMci_IDNO,
            c.Case_IDNO,
            c.MemberSsn_NUMB,
            c.Last_NAME,
            c.First_NAME,
            c.Middle_NAME,
            c.TaxYear_NUMB,
            c.TypeArrear_CODE,
            c.Transaction_AMNT,
            c.SubmitLast_DATE,
            c.TypeTransaction_CODE,
            c.CountyFips_CODE,
            c.Certified_DATE,
            c.StateAdministration_CODE,
            c.ExcludeIrs_CODE,
            c.ExcludeAdm_CODE,
            c.ExcludeFin_CODE,
            c.ExcludePas_CODE,
            c.ExcludeRet_CODE,
            c.ExcludeSal_CODE,
            c.ExcludeDebt_CODE,
            c.ExcludeVen_CODE,
            c.ExcludeIns_CODE,
            c.WorkerUpdate_ID,
            c.Update_DTTM,
            c.TransactionEventSeq_NUMB
       FROM (SELECT a.MemberMci_IDNO,
                    a.Case_IDNO,
                    a.MemberSsn_NUMB,
                    a.Last_NAME,
                    a.First_NAME,
                    a.Middle_NAME,
                    a.TaxYear_NUMB,
                    a.TypeArrear_CODE,
                    a.Transaction_AMNT,
                    a.SubmitLast_DATE,
                    a.Certified_DATE,
                    a.TypeTransaction_CODE,
                    a.CountyFips_CODE,
                    a.StateAdministration_CODE,
                    a.ExcludeIrs_CODE,
                    a.ExcludeAdm_CODE,
                    a.ExcludeFin_CODE,
                    a.ExcludePas_CODE,
                    a.ExcludeRet_CODE,
                    a.ExcludeSal_CODE,
                    a.ExcludeDebt_CODE,
                    a.ExcludeVen_CODE,
                    a.ExcludeIns_CODE,
                    a.WorkerUpdate_ID,
                    a.Update_DTTM,
                    a.TransactionEventSeq_NUMB
               FROM IFMS_Y1 a,
                    (SELECT DISTINCT
                            s.MemberMci_IDNO,
                            s.TypeArrear_CODE
                       FROM FEDH_Y1 s
                      WHERE s.TypeTransaction_CODE = @Lc_TransTypeD1_CODE
                        AND s.SubmitLast_DATE = @Ld_Run_DATE) b
              WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                AND b.TypeArrear_CODE = a.TypeArrear_CODE
                AND a.Transaction_AMNT <> @Ln_Zero_NUMB) c
WHERE NOT EXISTS(SELECT 1 FROM HIFMS_Y1 X
WHERE X.Case_IDNO = c.Case_IDNO
AND X.MemberMci_IDNO = c.MemberMci_IDNO
AND X.SubmitLast_DATE = c.SubmitLast_DATE
AND X.TaxYear_NUMB = c.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = c.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = c.TypeArrear_CODE
AND X.TypeTransaction_CODE = c.TypeTransaction_CODE)                
      ORDER BY c.MemberMci_IDNO,
               c.Case_IDNO,
               c.TypeArrear_CODE,
               c.SubmitLast_DATE;

     /*  Remove the Main Table Records  if it exists for this Run */
     SET @Ls_Sql_TEXT = 'DELETE - IFMS';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeD1_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     DELETE a
       FROM IFMS_Y1 a,
            (SELECT DISTINCT
                    s.MemberMci_IDNO,
                    s.TypeArrear_CODE
               FROM FEDH_Y1 s
              WHERE s.TypeTransaction_CODE = @Lc_TransTypeD1_CODE
                AND s.SubmitLast_DATE = @Ld_Run_DATE) b
      WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
        AND b.TypeArrear_CODE = a.TypeArrear_CODE
        AND a.Transaction_AMNT <> @Ln_Zero_NUMB;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT - IFMS';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeD1_CODE, '') + ', Certified_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

     INSERT IFMS_Y1
            (MemberMci_IDNO,
             Case_IDNO,
             MemberSsn_NUMB,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             TaxYear_NUMB,
             TypeArrear_CODE,
             Transaction_AMNT,
             SubmitLast_DATE,
             TypeTransaction_CODE,
             CountyFips_CODE,
             Certified_DATE,
             StateAdministration_CODE,
             ExcludeIrs_CODE,
             ExcludeAdm_CODE,
             ExcludeFin_CODE,
             ExcludePas_CODE,
             ExcludeRet_CODE,
             ExcludeSal_CODE,
             ExcludeDebt_CODE,
             ExcludeVen_CODE,
             ExcludeIns_CODE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB)
     SELECT d.MemberMci_IDNO,
            d.Case_IDNO,
            d.MemberSsn_NUMB,
            d.Last_NAME,
            d.First_NAME,
            d.Middle_NAME,
            d.TaxYear_NUMB,
            d.TypeArrear_CODE,
            d.Transaction_AMNT,
            d.SubmitLast_DATE,
            @Lc_TransTypeD1_CODE AS TypeTransaction_CODE,
            RIGHT(('000' + LTRIM(RTRIM(ISNULL(d.CountyFips_CODE, '0')))), 3) AS CountyFips_CODE,
            @Ld_High_DATE AS Certified_DATE,
            d.StateAdministration_CODE,
            d.ExcludeIrs_CODE,
            d.ExcludeAdm_CODE,
            d.ExcludeFin_CODE,
            d.ExcludePas_CODE,
            d.ExcludeRet_CODE,
            d.ExcludeSal_CODE,
            d.ExcludeDebt_CODE,
            d.ExcludeVen_CODE,
            d.ExcludeIns_CODE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM(SELECT a.MemberMci_IDNO,
                   a.Case_IDNO,
                   a.MemberSsn_NUMB,
                   a.Last_NAME,
                   a.First_NAME,
                   a.Middle_NAME,
                   a.TaxYear_NUMB,
                   a.TypeArrear_CODE,
                   a.Transaction_AMNT,
                   a.SubmitLast_DATE,
                   a.TypeTransaction_CODE,
                   a.CountySubmitted_IDNO AS CountyFips_CODE,
                   a.StateAdministration_CODE,
                   a.ExcludeIrs_CODE,
                   a.ExcludeAdm_CODE,
                   a.ExcludeFin_CODE,
                   a.ExcludePas_CODE,
                   a.ExcludeRet_CODE,
                   a.ExcludeSal_CODE,
                   a.ExcludeDebt_CODE,
                   a.ExcludeVen_CODE,
                   a.ExcludeIns_CODE
              FROM PIFMS_Y1 a,
                   (SELECT DISTINCT
                           h.MemberMci_IDNO,
                           h.TypeArrear_CODE
                      FROM FEDH_Y1 h
                     WHERE h.TypeTransaction_CODE = @Lc_TransTypeD1_CODE
                       AND h.SubmitLast_DATE = @Ld_Run_DATE) b
             WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
               AND b.TypeArrear_CODE = a.TypeArrear_CODE
               AND NOT EXISTS(SELECT 1
                                FROM IFMS_Y1 c
                               WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND c.Case_IDNO = a.Case_IDNO
                                 AND c.TypeArrear_CODE = a.TypeArrear_CODE)) d
WHERE NOT EXISTS(SELECT 1 FROM IFMS_Y1 X
WHERE X.Case_IDNO = d.Case_IDNO
AND X.MemberMci_IDNO = d.MemberMci_IDNO
AND X.SubmitLast_DATE = d.SubmitLast_DATE
AND X.TaxYear_NUMB = d.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = d.TypeArrear_CODE
AND X.TypeTransaction_CODE = @Lc_TransTypeD1_CODE)                                 
      ORDER BY d.MemberMci_IDNO,
               d.Case_IDNO,
               d.TypeArrear_CODE,
               d.SubmitLast_DATE;

     /*
     The following update statment has been included to set the Certified Date to High Date 
     for all the cases and arrears for that Member, if DELETE went. 
     */
     SET @Ls_Sql_TEXT = 'UPDATE - IFMS';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TransTypeD1_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     UPDATE a
        SET TaxYear_NUMB = @Ln_TaxYear_NUMB,
            SubmitLast_DATE = @Ld_Run_DATE,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            Certified_DATE = @Ld_High_DATE,
            Transaction_AMNT = 0,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
       FROM IFMS_Y1 a
      WHERE EXISTS(SELECT 1
                     FROM FEDH_Y1 b
                    WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                      AND b.TypeArrear_CODE = a.TypeArrear_CODE
                      AND b.TypeTransaction_CODE = @Lc_TransTypeD1_CODE
                      AND b.SubmitLast_DATE = @Ld_Run_DATE)
AND 1 = (SELECT COUNT(1) FROM IFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)                      

     --delete from pifms for the records that are in fedh with type transaction as A / D in the current run
     SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
     SET @Ls_SqlData_TEXT = '';

     DELETE a
       FROM PIFMS_Y1 a
      WHERE EXISTS(SELECT 1
                     FROM FEDH_Y1 s
                    WHERE s.TypeTransaction_CODE IN (@Lc_TransTypeA1_CODE, @Lc_TransTypeD1_CODE)
                      AND s.SubmitLast_DATE = @Ld_Run_DATE
                      AND s.MemberMci_IDNO = a.MemberMci_IDNO
                      AND s.TypeArrear_CODE = a.TypeArrear_CODE);
    END
   ELSE
    BEGIN
     /*
     Move the Main Table Records to the History, if it exists for this Run
     */
     SET @Ls_Sql_TEXT = 'INSERT - HIFMS_Y1';
     SET @Ls_SqlData_TEXT = '';

     INSERT HIFMS_Y1
            (MemberMci_IDNO,
             Case_IDNO,
             MemberSsn_NUMB,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             TaxYear_NUMB,
             TypeArrear_CODE,
             Transaction_AMNT,
             SubmitLast_DATE,
             TypeTransaction_CODE,
             CountyFips_CODE,
             Certified_DATE,
             StateAdministration_CODE,
             ExcludeIrs_CODE,
             ExcludeAdm_CODE,
             ExcludeFin_CODE,
             ExcludePas_CODE,
             ExcludeRet_CODE,
             ExcludeSal_CODE,
             ExcludeDebt_CODE,
             ExcludeVen_CODE,
             ExcludeIns_CODE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB)
     SELECT c.MemberMci_IDNO,
            c.Case_IDNO,
            c.MemberSsn_NUMB,
            c.Last_NAME,
            c.First_NAME,
            c.Middle_NAME,
            c.TaxYear_NUMB,
            c.TypeArrear_CODE,
            c.Transaction_AMNT,
            c.SubmitLast_DATE,
            c.TypeTransaction_CODE,
            c.CountyFips_CODE,
            c.Certified_DATE,
            c.StateAdministration_CODE,
            c.ExcludeIrs_CODE,
            c.ExcludeAdm_CODE,
            c.ExcludeFin_CODE,
            c.ExcludePas_CODE,
            c.ExcludeRet_CODE,
            c.ExcludeSal_CODE,
            c.ExcludeDebt_CODE,
            c.ExcludeVen_CODE,
            c.ExcludeIns_CODE,
            c.WorkerUpdate_ID,
            c.Update_DTTM,
            c.TransactionEventSeq_NUMB
       FROM(SELECT a.MemberMci_IDNO,
                   a.Case_IDNO,
                   a.MemberSsn_NUMB,
                   a.Last_NAME,
                   a.First_NAME,
                   a.Middle_NAME,
                   a.TaxYear_NUMB,
                   a.TypeArrear_CODE,
                   a.Transaction_AMNT,
                   a.SubmitLast_DATE,
                   a.Certified_DATE,
                   a.TypeTransaction_CODE,
                   a.CountyFips_CODE,
                   a.StateAdministration_CODE,
                   a.ExcludeIrs_CODE,
                   a.ExcludeAdm_CODE,
                   a.ExcludeFin_CODE,
                   a.ExcludePas_CODE,
                   a.ExcludeRet_CODE,
                   a.ExcludeSal_CODE,
                   a.ExcludeDebt_CODE,
                   a.ExcludeVen_CODE,
                   a.ExcludeIns_CODE,
                   a.WorkerUpdate_ID,
                   a.Update_DTTM,
                   a.TransactionEventSeq_NUMB
              FROM PIFMS_Y1 b,
                   IFMS_Y1 a
             WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
               AND b.Case_IDNO = a.Case_IDNO
               AND b.TypeArrear_CODE = a.TypeArrear_CODE
               AND EXISTS(SELECT 1
                            FROM FEDH_Y1 X
                           WHERE X.MemberMci_IDNO = b.MemberMci_IDNO
                             AND X.TypeArrear_CODE = b.TypeArrear_CODE
                             AND (X.TypeTransaction_CODE = @Lc_TypeTransactionM_CODE
                                   OR (X.TypeTransaction_CODE = 'A'
                                       AND X.SubmitLast_DATE < @Ld_Run_DATE)))) c
WHERE NOT EXISTS(SELECT 1 FROM HIFMS_Y1 X
WHERE X.Case_IDNO = c.Case_IDNO
AND X.MemberMci_IDNO = c.MemberMci_IDNO
AND X.SubmitLast_DATE = c.SubmitLast_DATE
AND X.TaxYear_NUMB = c.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = c.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = c.TypeArrear_CODE
AND X.TypeTransaction_CODE = c.TypeTransaction_CODE)                                       
      ORDER BY c.MemberMci_IDNO,
               c.Case_IDNO,
               c.TypeArrear_CODE,
               c.SubmitLast_DATE;

     /*
     Remove the Main Table Records if it exists for this Run
     */
     SET @Ls_Sql_TEXT = 'DELETE - IFMS';
     SET @Ls_SqlData_TEXT = '';

     DELETE a
       FROM PIFMS_Y1 b,
            IFMS_Y1 a
      WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
        AND b.Case_IDNO = a.Case_IDNO
        AND b.TypeArrear_CODE = a.TypeArrear_CODE
AND 
(
	(
		A.TypeTransaction_CODE = 'R'
		AND EXISTS(SELECT 1 FROM IFMS_Y1 X 
		WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
		AND X.Case_IDNO = A.Case_IDNO
		AND X.TypeArrear_CODE = A.TypeArrear_CODE
		AND X.TypeTransaction_CODE <> A.TypeTransaction_CODE)
		AND EXISTS(SELECT 1 FROM FEDH_Y1 X
		WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
		AND X.TypeArrear_CODE = A.TypeArrear_CODE
		AND X.TypeTransaction_CODE <> A.TypeTransaction_CODE
		AND X.RejectInd_INDC = 'N')
	)
	OR	
	(
		EXISTS(SELECT 1 FROM FEDH_Y1 X
		WHERE X.MemberMci_IDNO = b.MemberMci_IDNO
		AND X.TypeArrear_CODE = b.TypeArrear_CODE
		AND X.TypeTransaction_CODE = @Lc_TypeTransactionM_CODE)
	)
)

     /*
     Insert current Run Records to the Main Table  - M Tran
     */
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END

     UPDATE A
        SET A.ExcludeIrs_CODE = B.ExcludeIrs_CODE,
            A.ExcludeAdm_CODE = B.ExcludeAdm_CODE,
            A.ExcludeFin_CODE = B.ExcludeFin_CODE,
            A.ExcludePas_CODE = B.ExcludePas_CODE,
            A.ExcludeRet_CODE = B.ExcludeRet_CODE,
            A.ExcludeSal_CODE = B.ExcludeSal_CODE,
            A.ExcludeDebt_CODE = B.ExcludeDebt_CODE,
            A.ExcludeVen_CODE = B.ExcludeVen_CODE,
            A.ExcludeIns_CODE = B.ExcludeIns_CODE,
            A.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
       FROM IFMS_Y1 A,
            PIFMS_Y1 B
      WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
        AND b.Case_IDNO = a.Case_IDNO
        AND b.TypeArrear_CODE = a.TypeArrear_CODE
        AND A.TypeTransaction_CODE = 'A'
        AND A.SubmitLast_DATE < @Ld_Run_DATE
AND 1 = (SELECT COUNT(1) FROM IFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

     SET @Ls_Sql_TEXT = 'INSERT - IFMS';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTransactionM_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

     INSERT IFMS_Y1
            (MemberMci_IDNO,
             Case_IDNO,
             MemberSsn_NUMB,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             TaxYear_NUMB,
             TypeArrear_CODE,
             Transaction_AMNT,
             SubmitLast_DATE,
             TypeTransaction_CODE,
             CountyFips_CODE,
             Certified_DATE,
             StateAdministration_CODE,
             ExcludeIrs_CODE,
             ExcludeAdm_CODE,
             ExcludeFin_CODE,
             ExcludePas_CODE,
             ExcludeRet_CODE,
             ExcludeSal_CODE,
             ExcludeDebt_CODE,
             ExcludeVen_CODE,
             ExcludeIns_CODE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB)
     SELECT c.MemberMci_IDNO,
            c.Case_IDNO,
            c.MemberSsn_NUMB,
            c.Last_NAME,
            c.First_NAME,
            c.Middle_NAME,
            c.TaxYear_NUMB,
            c.TypeArrear_CODE,
            c.Transaction_AMNT,
            c.SubmitLast_DATE,
            @Lc_TypeTransactionM_CODE AS TypeTransaction_CODE,
            RIGHT(('000' + LTRIM(RTRIM(ISNULL(c.CountyFips_CODE, '0')))), 3) AS CountyFips_CODE,
            c.Certified_DATE,
            c.StateAdministration_CODE,
            c.ExcludeIrs_CODE,
            c.ExcludeAdm_CODE,
            c.ExcludeFin_CODE,
            c.ExcludePas_CODE,
            c.ExcludeRet_CODE,
            c.ExcludeSal_CODE,
            c.ExcludeDebt_CODE,
            c.ExcludeVen_CODE,
            c.ExcludeIns_CODE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM(SELECT a.MemberMci_IDNO,
                   a.Case_IDNO,
                   a.MemberSsn_NUMB,
                   a.Last_NAME,
                   a.First_NAME,
                   a.Middle_NAME,
                   a.TaxYear_NUMB,
                   a.TypeArrear_CODE,
                   a.Transaction_AMNT,
                   a.SubmitLast_DATE,
                   a.Certified_DATE,
                   a.CountySubmitted_IDNO AS CountyFips_CODE,
                   a.StateAdministration_CODE,
                   a.ExcludeIrs_CODE,
                   a.ExcludeAdm_CODE,
                   a.ExcludeFin_CODE,
                   a.ExcludePas_CODE,
                   a.ExcludeRet_CODE,
                   a.ExcludeSal_CODE,
                   a.ExcludeDebt_CODE,
                   a.ExcludeVen_CODE,
                   a.ExcludeIns_CODE
              FROM PIFMS_Y1 a
             WHERE EXISTS(SELECT 1
                            FROM FEDH_Y1 b
                           WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                             AND b.TypeArrear_CODE = a.TypeArrear_CODE
                             AND b.TypeTransaction_CODE = @Lc_TypeTransactionM_CODE)) c
WHERE NOT EXISTS(SELECT 1 FROM IFMS_Y1 X
WHERE X.Case_IDNO = c.Case_IDNO
AND X.MemberMci_IDNO = c.MemberMci_IDNO
AND X.SubmitLast_DATE = c.SubmitLast_DATE
AND X.TaxYear_NUMB = c.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = c.TypeArrear_CODE
AND X.TypeTransaction_CODE = @Lc_TypeTransactionM_CODE)                             
      ORDER BY c.MemberMci_IDNO,
               c.Case_IDNO,
               c.TypeArrear_CODE,
               c.SubmitLast_DATE;

     /*
     Insert current Run Records to the Main Table  - R Transaction
     */
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT - IFMS';
     SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTransactionR_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

     INSERT IFMS_Y1
            (MemberMci_IDNO,
             Case_IDNO,
             MemberSsn_NUMB,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             TaxYear_NUMB,
             TypeArrear_CODE,
             Transaction_AMNT,
             SubmitLast_DATE,
             TypeTransaction_CODE,
             CountyFips_CODE,
             Certified_DATE,
             StateAdministration_CODE,
             ExcludeIrs_CODE,
             ExcludeAdm_CODE,
             ExcludeFin_CODE,
             ExcludePas_CODE,
             ExcludeRet_CODE,
             ExcludeSal_CODE,
             ExcludeDebt_CODE,
             ExcludeVen_CODE,
             ExcludeIns_CODE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB)
     SELECT c.MemberMci_IDNO,
            c.Case_IDNO,
            c.MemberSsn_NUMB,
            c.Last_NAME,
            c.First_NAME,
            c.Middle_NAME,
            c.TaxYear_NUMB,
            c.TypeArrear_CODE,
            c.Transaction_AMNT,
            c.SubmitLast_DATE,
            @Lc_TypeTransactionR_CODE AS TypeTransaction_CODE,
            RIGHT(('000' + LTRIM(RTRIM(ISNULL(c.CountyFips_CODE, '0')))), 3) AS CountyFips_CODE,
            c.Certified_DATE,
            c.StateAdministration_CODE,
            c.ExcludeIrs_CODE,
            c.ExcludeAdm_CODE,
            c.ExcludeFin_CODE,
            c.ExcludePas_CODE,
            c.ExcludeRet_CODE,
            c.ExcludeSal_CODE,
            c.ExcludeDebt_CODE,
            c.ExcludeVen_CODE,
            c.ExcludeIns_CODE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM(SELECT a.MemberMci_IDNO,
                   a.Case_IDNO,
                   a.MemberSsn_NUMB,
                   a.Last_NAME,
                   a.First_NAME,
                   a.Middle_NAME,
                   a.TaxYear_NUMB,
                   a.TypeArrear_CODE,
                   a.Transaction_AMNT,
                   a.SubmitLast_DATE,
                   a.Certified_DATE,
                   a.CountySubmitted_IDNO AS CountyFips_CODE,
                   a.StateAdministration_CODE,
                   a.ExcludeIrs_CODE,
                   a.ExcludeAdm_CODE,
                   a.ExcludeFin_CODE,
                   a.ExcludePas_CODE,
                   a.ExcludeRet_CODE,
                   a.ExcludeSal_CODE,
                   a.ExcludeDebt_CODE,
                   a.ExcludeVen_CODE,
                   a.ExcludeIns_CODE
              FROM PIFMS_Y1 a
             WHERE EXISTS(SELECT 1
                            FROM FEDH_Y1 b
                           WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                             AND b.TypeArrear_CODE = a.TypeArrear_CODE
                             AND b.TypeTransaction_CODE = @Lc_TypeTransactionR_CODE)
               AND EXISTS(SELECT 1
                            FROM IFMS_Y1 X
                           WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
                             AND X.Case_IDNO = a.Case_IDNO
                             AND X.TypeArrear_CODE = a.TypeArrear_CODE
                             AND X.TypeTransaction_CODE IN (@Lc_TypeTransactionA_CODE, @Lc_TypeTransactionM_CODE)
                             AND X.Transaction_AMNT > 0)) c
WHERE NOT EXISTS(SELECT 1 FROM IFMS_Y1 X
WHERE X.Case_IDNO = c.Case_IDNO
AND X.MemberMci_IDNO = c.MemberMci_IDNO
AND X.SubmitLast_DATE = c.SubmitLast_DATE
AND X.TaxYear_NUMB = c.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = c.TypeArrear_CODE
AND X.TypeTransaction_CODE = @Lc_TypeTransactionR_CODE)                              
      ORDER BY c.MemberMci_IDNO,
               c.Case_IDNO,
               c.TypeArrear_CODE,
               c.SubmitLast_DATE;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('Local', 'Pending_Cur') IN (0, 1)
    BEGIN
     CLOSE Pending_Cur;

     DEALLOCATE Pending_Cur;
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
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
