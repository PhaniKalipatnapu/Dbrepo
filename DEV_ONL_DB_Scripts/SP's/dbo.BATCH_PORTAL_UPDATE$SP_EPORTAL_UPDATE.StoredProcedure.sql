/****** Object:  StoredProcedure [dbo].[BATCH_PORTAL_UPDATE$SP_EPORTAL_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
----------------------------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_PORTAL_UPDATE$SP_EPORTAL_UPDATE
Programmer Name 	: IMP Team
Description			: This batch will be used to update DECSS database tables with information provided by the Employer Portal (EPortal) 
					  during maintenance hours.
Frequency			: 'Daily'
Developed On		: 06/01/2012
Called BY			: None
Called On			: 
----------------------------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0	
----------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_PORTAL_UPDATE$SP_EPORTAL_UPDATE]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_SuccessStatus_CODE             CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE         CHAR(1) = 'A',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_TypeErrorE_CODE                CHAR(1) = 'E', 
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_Note_INDC                      CHAR(1) = 'N',
          @Lc_StatusGood_CODE                CHAR(1) = 'Y',
          @Lc_StatusBad_CODE                 CHAR(1) = 'B',
          @Lc_StatusVerified_CODE            CHAR(1) = 'Y',
          @Lc_NoticeOptionAccepted_CODE      CHAR(1) = 'Y',
          @Lc_NoticeOptionNotEmployed_CODE   CHAR(1) = 'H',
          @Lc_NoticeOptionNeverEmployed_CODE CHAR(1) = 'B',
          @Lc_VerificationSourceV_CODE       CHAR(2) = 'VT',
          @Lc_IncomeTypeEm_CODE              CHAR(2) = 'EM',
          @Lc_SourceVerifiedCot_CODE         CHAR(3) = 'E',
          @Lc_BateErrorE1424_CODE                CHAR(5) = 'E1424', 
          @Lc_BateErrorE0944_CODE                CHAR(5) = 'E0944', 
          @Lc_Job_ID                         CHAR(7) = 'DEB9023',
          @Lc_Successful_TEXT                CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT              CHAR(30) = 'BATCH',
          @Lc_ParmDateProblem_TEXT           CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME                 VARCHAR(60) = 'SP_EPORTAL_UPDATE',
          @Ls_Process_NAME                   VARCHAR(100) = 'BATCH_PORTAL_UPDATE',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB                      NUMERIC(5) = 0,
          @Ln_ErrorLine_NUMB                  NUMERIC(5) = 0,
          @Ln_FetchStatus_QNTY                NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY         NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0, 
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_Cursor_QNTY                     NUMERIC(10) = 0,
          @Ln_CursorMiwed_QNTY                NUMERIC(10) = 0,
          @Ln_CursorMepdt_QNTY                NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY       NUMERIC(11) = 0,
          @Ln_RowCount_QNTY                   NUMERIC(11) = 0,
          @Ln_TransactionEventSeqEhis_NUMB    NUMERIC(19) = 0,
          @Ln_TransactionEventSeqOthp_NUMB    NUMERIC(19) = 0,
          @Lc_Empty_TEXT                   CHAR = '',
          @Lc_Status_CODE                  CHAR(1),
          @Lc_BateError_CODE               CHAR(5),
          @Lc_Msg_CODE                     CHAR(5),
          @Ls_Sql_TEXT                     VARCHAR(100),
          @Ls_Sqldata_TEXT                 VARCHAR(1000),
          @Ls_DescriptionError_TEXT        VARCHAR(4000),
          @Ls_BateRecord_TEXT              VARCHAR(4000),
          @Ld_Run_DATE                     DATE,
          @Ld_LastRun_DATE                 DATE,
          @Ld_BeginEmployment_DATE         DATE,
          @Ld_EndEmployment_DATE           DATE,
          @Ld_Start_DATE                   DATETIME2;
  DECLARE @Lc_MiwedCur_IamUser_ID                  CHAR(30),
          @Ln_MiwedCur_OtherParty_IDNO             NUMERIC(9),
          @Lc_MiwedCur_Notice_ID                   CHAR(8),
          @Ln_MiwedCur_Barcode_NUMB                NUMERIC(12),
          @Ln_MiwedCur_MemberMCI_IDNO              NUMERIC(10),
          @Ln_MiwedCur_Case_IDNO                   NUMERIC(6),
          @Lc_MiwedCur_NoticeOption_CODE           CHAR(1),
          @Ld_MiwedCur_Response_DATE               DATE,
          @Lc_MiwedCur_EmploymentVerification_CODE CHAR(2),
          @Lc_MiwedCur_VerificationSource_CODE     CHAR(2),
          @Lc_MiwedCur_Process_INDC                CHAR(1),
          @Ld_MiwedCur_Process_DATE                DATE,
          @Ld_MiwedCur_BeginValidity_DATE          DATE,
          @Ld_MiwedCur_EndValidity_DATE            DATE,
          @Ln_MiwedCur_TransactionEventSeq_NUMB    NUMERIC(19),
          @Lc_MiwedCur_WorkerUpdate_ID             CHAR(30),
          @Ld_MiwedCur_Update_DTTM                 DATETIME2;
  DECLARE @Ln_MepdtCur_Seq_IDNO                     NUMERIC(19),
          @Lc_MepdtCur_IamUser_ID                   CHAR(30),
          @Ln_MepdtCur_Fein_IDNO                    NUMERIC(9),
          @Ln_MepdtCur_OtherParty_IDNO              NUMERIC(9),
          @Ls_MepdtCur_OtherParty_NAME              VARCHAR(60),
          @Ls_MepdtCur_OthpLine1_ADDR               VARCHAR(50),
          @Ls_MepdtCur_OthpLine2_ADDR               VARCHAR(50),
          @Lc_MepdtCur_OthpCity_ADDR                CHAR(28),
          @Lc_MepdtCur_OthpZip_ADDR                 CHAR(15),
          @Lc_MepdtCur_OthpState_ADDR               CHAR(2),
          @Lc_MepdtCur_OthpCountry_ADDR             CHAR(2),
          @Ls_MepdtCur_Contact_EML                  VARCHAR(100),
          @Lc_MepdtCur_DescriptionContactOther_TEXT CHAR(30),
          @Ln_MepdtCur_Phone_NUMB                   NUMERIC(15),
          @Ln_MepdtCur_Fax_NUMB                     NUMERIC(15),
          @Lc_MepdtCur_Aka_NAME                     CHAR(30),
          @Lc_MepdtCur_Enmsn_INDC                   CHAR(1),
          @Lc_MepdtCur_SendShort_INDC               CHAR(1),
          @Lc_MepdtCur_InsuranceProvided_INDC       CHAR(1),
          @Ln_MepdtCur_Sein_IDNO                    NUMERIC(12),
          @Lc_MepdtCur_ReceivePaperForms_INDC       CHAR(1),
          @Lc_MepdtCur_Status_CODE                  CHAR(1),
          @Ld_MepdtCur_BeginValidity_DATE           DATE,
          @Ld_MepdtCur_Update_DTTM                  DATETIME2,
          @Ln_MepdtCur_TransactionEventSeq_NUMB     NUMERIC(19),
          @Lc_MepdtCur_Process_INDC                 CHAR(1),
          @Ld_MepdtCur_Process_DATE                 DATE,
          @Lc_MepdtCur_WorkerUpdate_ID              CHAR(30),
          @Lc_MepdtCur_OthpAttn_ADDR                CHAR(40);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION EPORTAL_TRAN'; 
  SET @Ls_Sqldata_TEXT = '';
   BEGIN TRANSACTION EPORTAL_TRAN; 
    SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE; 

   /*Get the current run date and last run date from PARM_Y1 (Parameters table), and validate that the batch program was not executed for the current run date, 
   by ensuring that the run date is different from the last run date in the PARM table. Otherwise, an error message will be written into the Batch Status Log (BSTL) 
   screen/Batch Status Log (BSTL_Y1) table and the process terminate will terminate.*/
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   -- Check if the procedure executed properly	
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
      RAISERROR (50001,16,1);
    END

   SET @Ld_LastRun_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   IF @Ld_LastRun_DATE > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR(50001,16,1);
    END

   -- Select records from MIWED_Y1 table.      
   DECLARE Miwed_CUR INSENSITIVE CURSOR FOR
    SELECT a.IamUser_ID,
           a.OtherParty_IDNO,
           a.Notice_ID,
           a.Barcode_NUMB,
           a.MemberMCI_IDNO,
           a.Case_IDNO,
           a.NoticeOption_CODE,
           a.Response_DATE,
           a.EmploymentVerification_CODE,
           a.VerificationSource_CODE,
           a.Process_INDC,
           a.Process_DATE,
           a.BeginValidity_DATE,
           a.EndValidity_DATE,
           a.TransactionEventSeq_NUMB,
           a.WorkerUpdate_ID,
           a.Update_DTTM
      FROM MIWED_Y1 a
     WHERE a.Process_INDC = @Lc_No_INDC
       AND a.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN Miwed_CUR-1';
   SET @Ls_Sqldata_TEXT = '';
   OPEN Miwed_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Miwed_CUR-1';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM Miwed_CUR INTO @Lc_MiwedCur_IamUser_ID, @Ln_MiwedCur_OtherParty_IDNO, @Lc_MiwedCur_Notice_ID, @Ln_MiwedCur_Barcode_NUMB, @Ln_MiwedCur_MemberMCI_IDNO, @Ln_MiwedCur_Case_IDNO, @Lc_MiwedCur_NoticeOption_CODE, @Ld_MiwedCur_Response_DATE, @Lc_MiwedCur_EmploymentVerification_CODE, @Lc_MiwedCur_VerificationSource_CODE, @Lc_MiwedCur_Process_INDC, @Ld_MiwedCur_Process_DATE, @Ld_MiwedCur_BeginValidity_DATE, @Ld_MiwedCur_EndValidity_DATE, @Ln_MiwedCur_TransactionEventSeq_NUMB, @Lc_MiwedCur_WorkerUpdate_ID, @Ld_MiwedCur_Update_DTTM;

   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   --WHILE LOOP FOR MIWED_Y1 TABLE
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION EPORTAL_TRAN_MIWED_SAVE;

      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE; 
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1; 
      SET @Ls_BateRecord_TEXT = 'IamUser_ID = ' + CAST(@Lc_MiwedCur_IamUser_ID AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@Ln_MiwedCur_OtherParty_IDNO AS VARCHAR) + ', Notice_ID = ' + CAST(@Lc_MiwedCur_Notice_ID AS VARCHAR) + ', Barcode_NUMB = ' + CAST(@Ln_MiwedCur_Barcode_NUMB AS VARCHAR) + ', MemberMCI_IDNO = ' + CAST(@Ln_MiwedCur_MemberMCI_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_MiwedCur_Case_IDNO AS VARCHAR) + ', NoticeOption_CODE = ' + @Lc_MiwedCur_NoticeOption_CODE + ', Response_DATE = ' + CAST(@Ld_MiwedCur_Response_DATE AS VARCHAR) + ', EmploymentVerification_CODE = ' + @Lc_MiwedCur_EmploymentVerification_CODE + ', VerificationSource_CODE = ' + @Lc_MiwedCur_VerificationSource_CODE + ', Process_INDC = ' + @Lc_MiwedCur_Process_INDC + ', Process_DATE = ' + CAST(@Ld_MiwedCur_Process_DATE AS VARCHAR) + ', BeginValidity_DATE = ' + CAST(@Ld_MiwedCur_BeginValidity_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_MiwedCur_EndValidity_DATE AS VARCHAR) + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_MiwedCur_TransactionEventSeq_NUMB AS VARCHAR) + ', WorkerUpdate_ID = ' + CAST(@Lc_MiwedCur_WorkerUpdate_ID AS VARCHAR) + ', Update_DTTM = ' + CAST(@Ld_MiwedCur_Update_DTTM AS VARCHAR) + 'TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeqEhis_NUMB AS VARCHAR) + 'BeginEmployment_DATE = ' + CAST(@Ld_BeginEmployment_DATE AS VARCHAR) + 'EndEmployment_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorMiwed_QNTY = @Ln_Cursor_QNTY;
      
      SET @Ls_Sql_TEXT = 'SELECT FROM EHIS';
      SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeqEhis_NUMB AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_BeginEmployment_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MiwedCur_MemberMCI_IDNO AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_MiwedCur_OtherParty_IDNO AS VARCHAR), '');
           
      SELECT @Ln_TransactionEventSeqEhis_NUMB = EH.TransactionEventSeq_NUMB,
             @Ld_BeginEmployment_DATE = EH.BeginEmployment_DATE
        FROM EHIS_Y1 EH
       WHERE EH.MemberMci_IDNO = @Ln_MiwedCur_MemberMCI_IDNO
         AND EH.EndEmployment_DATE = @Ld_High_DATE
         AND EH.OthpPartyEmpl_IDNO = @Ln_MiwedCur_OtherParty_IDNO;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ln_TransactionEventSeqEhis_NUMB = 0;
       END

      IF @Lc_MiwedCur_VerificationSource_CODE = @Lc_VerificationSourceV_CODE
       BEGIN
         IF @Lc_MiwedCur_EmploymentVerification_CODE = @Lc_StatusVerified_CODE
        BEGIN
          SET @Lc_Status_CODE = @Lc_StatusGood_CODE;
          SET @Ld_EndEmployment_DATE = @Ld_High_DATE;
         END
        ELSE
         BEGIN
          SET @Lc_Status_CODE = @Lc_StatusBad_CODE;
          SET @Ld_EndEmployment_DATE = @Ld_MiwedCur_Update_DTTM;
         END
       END
      ELSE
       BEGIN
        IF @Lc_MiwedCur_NoticeOption_CODE = @Lc_NoticeOptionAccepted_CODE
         BEGIN
          SET @Lc_Status_CODE = @Lc_StatusGood_CODE;
          SET @Ld_EndEmployment_DATE = @Ld_High_DATE;
         END
        ELSE IF @Lc_MiwedCur_NoticeOption_CODE = @Lc_NoticeOptionNotEmployed_CODE
         BEGIN
          SET @Lc_Status_CODE = @Lc_StatusBad_CODE;
          SET @Ld_EndEmployment_DATE = @Ld_MiwedCur_Update_DTTM;
         END
        ELSE IF @Lc_MiwedCur_NoticeOption_CODE = @Lc_NoticeOptionNeverEmployed_CODE
         BEGIN
          SET @Lc_Status_CODE = @Lc_StatusBad_CODE;
          SET @Ld_EndEmployment_DATE = @Ld_MiwedCur_Update_DTTM;
         END
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MiwedCur_MemberMCI_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_MiwedCur_OtherParty_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_Status_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_IncomeTypeEm_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceVerifiedCot_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_BeginEmployment_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_EndEmployment_DATE AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceVerifiedCot_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeqEhis_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');
      
      EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
       @An_MemberMci_IDNO             = @Ln_MiwedCur_MemberMCI_IDNO,
       @An_OthpPartyEmpl_IDNO         = @Ln_MiwedCur_OtherParty_IDNO,
       @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
       @Ac_Status_CODE                = @Lc_Status_CODE,
       @Ad_Status_DATE                = @Ld_Run_DATE,
       @Ac_TypeIncome_CODE            = @Lc_IncomeTypeEm_CODE,
       @Ac_SourceLocConf_CODE         = @Lc_SourceVerifiedCot_CODE,
       @Ad_Run_DATE                   = @Ld_Run_DATE,
       @Ad_BeginEmployment_DATE       = @Ld_BeginEmployment_DATE,
       @Ad_EndEmployment_DATE         = @Ld_EndEmployment_DATE,
       @An_IncomeGross_AMNT           = 0,
       @An_IncomeNet_AMNT             = 0,
       @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
       @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
       @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
       @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
       @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
       @Ac_SourceLoc_CODE             = @Lc_SourceVerifiedCot_CODE,
       @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
       @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
       @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
       @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
       @An_CostInsurance_AMNT         = 0,
       @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
       @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
       @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
       @An_TransactionEventSeq_NUMB   = @Ln_TransactionEventSeqEhis_NUMB,
       @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
       @Ac_Process_ID                 = @Lc_Job_ID,
       @An_OfficeSignedOn_IDNO        = 0,
       @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'UPDATE MIWED_Y1 TABLE - CHANGE';
      SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_MiwedCur_OtherParty_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MiwedCur_MemberMCI_IDNO AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(CAST(@Lc_Yes_INDC AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(CAST(@Lc_Note_INDC AS VARCHAR), '') + ', Process_ID = ' + ISNULL(CAST(@Lc_Job_ID AS VARCHAR), '') + ', Process_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_MiwedCur_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Lc_BatchRunUser_TEXT AS VARCHAR), '');
      EXECUTE BATCH_EPORTAL_UPDATE$SP_EMPLOYMENT_DETAILS_UPDATE
       @An_OtherParty_IDNO          = @Ln_MiwedCur_OtherParty_IDNO,
       @An_MemberMci_IDNO           = @Ln_MiwedCur_MemberMCI_IDNO,
       @Ac_Process_INDC             = @Lc_Yes_INDC,
       @Ac_Note_INDC                = @Lc_Note_INDC,
       @Ac_Process_ID               = @Lc_Job_ID,
       @Ad_Process_DATE             = @Ld_Run_DATE,
       @An_TransactionEventSeq_NUMB = @Ln_MiwedCur_TransactionEventSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT;
	
	   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
		 RAISERROR (50001,16,1);
		END;
           
     END TRY

     BEGIN CATCH
      -- Committable transaction checking and Rolling back Savepoint
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION EPORTAL_TRAN_MIWED_SAVE 
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      IF CURSOR_STATUS ('VARIABLE', 'Miwed_CUR') IN (0, 1)
       BEGIN
        CLOSE Miwed_CUR;

        DEALLOCATE Miwed_CUR;
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      -- Process unknown errors
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
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

      SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END;
     
      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
      
     END CATCH

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY != 0
        
      BEGIN
       COMMIT TRANSACTION EPORTAL_TRAN;
    	SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY; 
		
       BEGIN TRANSACTION EPORTAL_TRAN;
       SET @Ln_CommitFreq_QNTY = 0;
      END
     SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD'; 
     SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);
          -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      
      BEGIN
       COMMIT TRANSACTION EPORTAL_TRAN;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY; 
       
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'FETCH Miwed_CUR-2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);;
     FETCH NEXT FROM Miwed_CUR INTO @Lc_MiwedCur_IamUser_ID, @Ln_MiwedCur_OtherParty_IDNO, @Lc_MiwedCur_Notice_ID, @Ln_MiwedCur_Barcode_NUMB, @Ln_MiwedCur_MemberMCI_IDNO, @Ln_MiwedCur_Case_IDNO, @Lc_MiwedCur_NoticeOption_CODE, @Ld_MiwedCur_Response_DATE, @Lc_MiwedCur_EmploymentVerification_CODE, @Lc_MiwedCur_VerificationSource_CODE, @Lc_MiwedCur_Process_INDC, @Ld_MiwedCur_Process_DATE, @Ld_MiwedCur_BeginValidity_DATE, @Ld_MiwedCur_EndValidity_DATE, @Ln_MiwedCur_TransactionEventSeq_NUMB, @Lc_MiwedCur_WorkerUpdate_ID, @Ld_MiwedCur_Update_DTTM;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Miwed_CUR';
   SET @Ls_Sqldata_TEXT = '';
   CLOSE Miwed_CUR;

   DEALLOCATE Miwed_CUR;

   IF @Ln_CursorMiwed_QNTY = 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE; 
     SET @Ls_Sql_TEXT = 'NO RECORD(S) TO PROCESS';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE, 
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   --Upon successful completion, update the last run date in PARM_Y1 with the current run date.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   --Log the error encountered or successful completion in BSTL/BSTL_Y1 for future references.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_SuccessStatus_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_SuccessStatus_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION EPORTAL_TRAN;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EPORTAL_TRAN; 
    END;
   IF CURSOR_STATUS ('LOCAL', 'Miwed_CUR') IN (0, 1)
    BEGIN
     CLOSE Miwed_CUR;

     DEALLOCATE Miwed_CUR;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

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

   --Log the Error encountered in the Batch Status Log (BSTL) screen/Batch Status Log (BSTL_Y1) table for future references
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   RAISERROR (50001,16,1);
  END CATCH
 END;


GO
