/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_EIWO$SP_PROCESS_EIWO_ACK]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_EIWO$SP_PROCESS_EIWO_ACK
Programmer Name	:	IMP Team.
Description		:	This process reads the acknowledgements received in the file and processes the rejected e-IWO records.
Frequency		:	
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS,
                    BATCH_COMMON$BATE_LOG,  
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_GET_BATCH_DETAILS,
				    BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT,
				    BATCH_COMMON$SP_EMPLOYER_UPDATE,
				    BATCH_COMMON$SP_INSERT_ACTIVITY,
				    BATCH_COMMON$SP_UPDATE_PARM_DATE,
				    BATCH_COMMON$SP_BATCH_RESTART_UPDATE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_EIWO$SP_PROCESS_EIWO_ACK]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_FetchStatus_QNTY            SMALLINT = 0,
          @Li_RowsCount_QNTY              SMALLINT = 0,
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_TypeError_CODE              CHAR(1) = 'E',
          @Lc_DispCodeR_CODE              CHAR(1) = 'R',
          @Lc_RejectReasonN_CODE          CHAR(1) = 'N',
          @Lc_RejectReasonU_CODE          CHAR(1) = 'U',
          @Lc_No_INDC                     CHAR(1) = 'N',
          @Lc_RejectReasonX_CODE          CHAR(1) = 'X',
          @Lc_RejectReasonO_CODE          CHAR(1) = 'O',
          @Lc_RejectReasonB_CODE          CHAR(1) = 'B',
          @Lc_RejectReasonS_CODE          CHAR(1) = 'S',
          @Lc_RejectReasonM_CODE          CHAR(1) = 'M',
          @Lc_RejectReasonW_CODE          CHAR(1) = 'W',
          @Lc_Resend_INDC                 CHAR(1) = 'N',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_TypeErrorE_CODE             CHAR(1) = 'E',
          @Lc_TypeErrorW_CODE             CHAR(1) = 'W',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipA_CODE      CHAR(1) = 'A',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
          @Lc_TypeOthpE_CODE              CHAR(1) = 'E',
          @Lc_SubsystemEN_CODE            CHAR(2) = 'EN',
          @Lc_ActivityMajorCASE_CODE      CHAR(4) = 'CASE',
          @Lc_RemedyStatusSTRT_CODE       CHAR(4) = 'STRT',
          @Lc_ActivityMajorIMIW_CODE      CHAR(4) = 'IMIW',
          @Lc_BateErrorE1424_CODE         CHAR(5) = 'E1424',
          @Lc_BateErrorE0944_CODE         CHAR(5) = 'E0944',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_ActivityMinorAEIWO_CODE     CHAR(5) = 'AEIWO',
          @Lc_ActivityMinorMEIWO_CODE     CHAR(5) = 'MEIWO',
          @Lc_ActivityMinorCEIWO_CODE     CHAR(5) = 'CEIWO',
          @Lc_ActivityMinor_CODE          CHAR(5) = '',
          @Lc_Job_ID                      CHAR(7) = 'DEB1310',
          @Lc_Successful_TEXT             CHAR(10) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT        VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_ErrorE0944_TEXT             VARCHAR(50) = 'NO RECORDS(S) TO PROCESS',
          @Ls_OtherParty_NAME             VARCHAR(60) = '',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_PROCESS_EIWO_ACK',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_ENF_INCOMING_EIWO',
          @Ls_BateError_TEXT              VARCHAR(4000) = ' ',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_Low_DATE                    DATE = '01/01/0001';
  DECLARE @Ln_RecCount_NUMB                    NUMERIC = 0,
          @Ln_Zero_NUMB                        NUMERIC = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC(6) = 0,
          @Ln_Case_IDNO                        NUMERIC(6),
          @Ln_OthpSource_IDNO                  NUMERIC(9),
          @Ln_Topic_IDNO                       NUMERIC(10) = 0,
          @Ln_MemberMci_IDNO                   NUMERIC(10),
          @Ln_Error_NUMB                       NUMERIC(11),
          @Ln_ErrorLine_NUMB                   NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB         NUMERIC(19),
          @Lc_Space_TEXT                       CHAR(1) = '',
		  @Lc_Msg_CODE                         CHAR(5),
          @Lc_BateError_CODE                   CHAR(5) = '',
          @Ls_Sql_TEXT                         VARCHAR(200) = '',
          @Ls_CursorLoc_TEXT                   VARCHAR(200),
          @Ls_CursorLocation_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT                     VARCHAR(1000) = '',
          @Ls_BateRecord_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT            VARCHAR(4000) = '',
          @Ls_DescriptionNote_TEXT             VARCHAR(MAX),
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATETIME2,
          @Ld_Start_DATE                       DATETIME2;
  DECLARE @Ln_EiwoAckCur_Seq_IDNO          NUMERIC(19),
          @Lc_EiwoAckCur_RejReason_CODE    CHAR(3),
          @Lc_EiwoAckCur_Case_IDNO         CHAR(6),
          @Ln_EiwoAckCur_Fein_IDNO         CHAR(9),
          @Lc_EiwoAckCur_DispCode_CODE     CHAR(2),
          @Lc_EiwoAckCur_DocTrackNo_TEXT   CHAR(30),
          @Ld_EiwoAckCur_FinalPayment_DATE CHAR(10),
          @Ln_EiwoAckCur_LumpSumPay_AMNT   CHAR(11),
          @Ld_EiwoAckCur_Termination_DATE  CHAR(10),
          @Ln_EiwoAckCur_FinalPay_AMNT     CHAR(11),
          @Ld_EiwoAckCur_LumpSumPay_DATE   CHAR(10),
          @Ln_EiwoAckCur_CorrectFein_IDNO  CHAR(9);
  DECLARE @Ln_EhisCur_MemberMci_IDNO             NUMERIC(10),
          @Ln_EhisCur_OthpPartyEmpl_IDNO         NUMERIC(9),
          @Ld_EhisCur_BeginEmployment_DATE       DATE,
          @Ld_EhisCur_EndEmployment_DATE         DATE,
          @Lc_EhisCur_TypeIncome_CODE            CHAR(2),
          @Lc_EhisCur_DescriptionOccupation_TEXT CHAR(32),
          @Ln_EhisCur_IncomeNet_AMNT             NUMERIC(11, 2),
          @Ln_EhisCur_IncomeGross_AMNT           NUMERIC(11, 2),
          @Lc_EhisCur_FreqIncome_CODE            CHAR(1),
          @Lc_EhisCur_FreqPay_CODE               CHAR(1),
          @Lc_EhisCur_SourceLoc_CODE             CHAR(3),
          @Ld_EhisCur_SourceReceived_DATE        DATE,
          @Lc_EhisCur_Status_CODE                CHAR(1),
          @Ld_EhisCur_Status_DATE                DATE,
          @Lc_EhisCur_SourceLocConf_CODE         CHAR(3),
          @Lc_EhisCur_InsProvider_INDC           CHAR(1),
          @Ln_EhisCur_CostInsurance_AMNT         NUMERIC(11, 2),
          @Lc_EhisCur_FreqInsurance_CODE         CHAR(1),
          @Lc_EhisCur_DpCoverageAvlb_INDC        CHAR(1),
          @Lc_EhisCur_EmployerPrime_INDC         CHAR(1),
          @Lc_EhisCur_DpCovered_INDC             CHAR(1),
          @Ld_EhisCur_EligCoverage_DATE          DATE,
          @Lc_EhisCur_InsReasonable_INDC         CHAR(1),
          @Lc_EhisCur_LimitCcpa_INDC             CHAR(1),
          @Ld_EhisCur_PlsLastSearch_DATE         DATE,
          @Ld_EhisCur_BeginValidity_DATE         DATE,
          @Lc_EhisCur_WorkerUpdate_ID            CHAR(30),
          @Ld_EhisCur_Update_DTTM                DATETIME2,
          @Ln_EhisCur_TransactionEventSeq_NUMB   NUMERIC(19);

  BEGIN TRY
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
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   DECLARE EiwoAck_CUR INSENSITIVE CURSOR FOR
    SELECT l.Seq_IDNO,
           ISNULL (l.RejReason_CODE, @Lc_Space_TEXT),
           l.Case_IDNO,
           l.Fein_IDNO,
           ISNULL (l.Disp_CODE, @Lc_Space_TEXT),
           l.DocTrackNo_TEXT,
           l.Termination_DATE,
           l.FinalPayment_DATE,
           l.FinalPay_AMNT,
           l.LumpSumPay_DATE,
           l.LumpSumPay_AMNT,
           l.CorrectFein_IDNO
      FROM LEACK_Y1 l
     WHERE l.Process_INDC = @Lc_No_INDC
     ORDER BY Fein_IDNO;

   BEGIN TRANSACTION EiwoAckTran;

   SET @Ls_Sql_TEXT = 'OPEN CURSOR - EiwoAck_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN EiwoAck_CUR;

   SET @Ls_Sql_TEXT = 'FETCH EiwoAck_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM EiwoAck_CUR INTO @Ln_EiwoAckCur_Seq_IDNO, @Lc_EiwoAckCur_RejReason_CODE, @Lc_EiwoAckCur_Case_IDNO, @Ln_EiwoAckCur_Fein_IDNO, @Lc_EiwoAckCur_DispCode_CODE, @Lc_EiwoAckCur_DocTrackNo_TEXT, @Ld_EiwoAckCur_Termination_DATE, @Ld_EiwoAckCur_FinalPayment_DATE, @Ln_EiwoAckCur_FinalPay_AMNT, @Ld_EiwoAckCur_LumpSumPay_DATE, @Ln_EiwoAckCur_LumpSumPay_AMNT, @Ln_EiwoAckCur_CorrectFein_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
     SET @Ls_BateError_TEXT = @Ls_ErrorE0944_TEXT;
    END;

   -- Cursor loop Started     
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION EiwoAckTranSave;

      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_EiwoAckCur_Seq_IDNO AS VARCHAR), '') + ', RejReason_CODE = ' + ISNULL(@Lc_EiwoAckCur_RejReason_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Lc_EiwoAckCur_Case_IDNO AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_EiwoAckCur_Fein_IDNO AS VARCHAR), '') + ', DispCode_CODE = ' + ISNULL(@Lc_EiwoAckCur_DispCode_CODE, '') + ', DocTrackNo_TEXT = ' + ISNULL(@Lc_EiwoAckCur_DocTrackNo_TEXT, '') + ', Termination_DATE = ' + ISNULL(CAST(@Ld_EiwoAckCur_Termination_DATE AS VARCHAR), '') + ', FinalPayment_DATE = ' + ISNULL(CAST(@Ld_EiwoAckCur_FinalPayment_DATE AS VARCHAR), '') + ', FinalPay_AMNT = ' + ISNULL(CAST(@Ln_EiwoAckCur_FinalPay_AMNT AS VARCHAR), '') + ', LumpSumPay_DATE = ' + ISNULL(CAST(@Ld_EiwoAckCur_LumpSumPay_DATE AS VARCHAR), '') + ', LumpSumPay_AMNT = ' + ISNULL(CAST(@Ln_EiwoAckCur_LumpSumPay_AMNT AS VARCHAR), '');
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ln_RecCount_NUMB = @Ln_RecCount_NUMB + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Lc_Resend_INDC = @Lc_No_INDC;
      SET @Lc_ActivityMinor_CODE = '';
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_EiwoAckCur_Case_IDNO, '');

      IF ISNUMERIC (@Lc_EiwoAckCur_Case_IDNO) = 0
       BEGIN
        SET @Lc_BateError_CODE = 'E0008';
        SET @Ls_DescriptionError_TEXT = 'Invalid Case ID';

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_Case_IDNO = CAST(@Lc_EiwoAckCur_Case_IDNO AS NUMERIC);
       END

      SET @Ls_Sql_TEXT = 'SELECT Active NCP on Case';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_EiwoAckCur_Case_IDNO, '');
      SET @Ln_MemberMci_IDNO = ISNULL((SELECT TOP 1 c.MemberMci_IDNO
                                         FROM CMEM_Y1 c
                                        WHERE c.Case_IDNO = @Ln_Case_IDNO
                                          AND c.CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE
                                          AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE), 0);

      IF @Ln_MemberMci_IDNO = 0
       BEGIN
        SET @Lc_BateError_CODE = 'E0759';
        SET @Ls_DescriptionError_TEXT = 'No case member record found.'

        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'SELECT EIWT RECORD';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_EiwoAckCur_Case_IDNO, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(@Ln_EiwoAckCur_Fein_IDNO, '') + ', DocTrackNo_TEXT = ' + ISNULL(@Lc_EiwoAckCur_DocTrackNo_TEXT, '');

      SELECT @Ln_OthpSource_IDNO = e.OthpSource_IDNO,
             @Ls_OtherParty_NAME = o.OtherParty_NAME
        FROM EIWT_Y1 E,
             OTHP_Y1 o
       WHERE E.Case_IDNO = @Ln_Case_IDNO
         AND E.MemberMci_IDNO = @Ln_MemberMci_IDNO
         AND E.Fein_IDNO = @Ln_EiwoAckCur_Fein_IDNO
         AND E.DocTrackNo_TEXT = @Lc_EiwoAckCur_DocTrackNo_TEXT
         AND o.OtherParty_IDNO = e.OthpSource_IDNO
         AND o.EndValidity_DATE = @Ld_High_DATE;

      SET @Li_RowsCount_QNTY = @@ROWCOUNT;

      IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
       BEGIN
        SET @Lc_BateError_CODE = 'E0012';
        SET @Ls_DescriptionError_TEXT = 'EIWT RECORD NOT FOUND';

        RAISERROR(50001,16,1);
       END

      IF @Lc_EiwoAckCur_RejReason_CODE = 'N'
       BEGIN
        SET @Ls_DescriptionNote_TEXT = @Lc_EiwoAckCur_RejReason_CODE + ' - NCP no longer at the employer';
       END
      ELSE IF @Lc_EiwoAckCur_RejReason_CODE = 'U'
       BEGIN
        SET @Ls_DescriptionNote_TEXT = @Lc_EiwoAckCur_RejReason_CODE + ' - NCP not known to employer';
       END
      ELSE IF @Lc_EiwoAckCur_RejReason_CODE = 'X'
       BEGIN
        SET @Ls_DescriptionNote_TEXT = @Lc_EiwoAckCur_RejReason_CODE + ' - Employer unable to electronically process record';
       END
      ELSE IF @Lc_EiwoAckCur_RejReason_CODE = 'O'
       BEGIN
        SET @Ls_DescriptionNote_TEXT = @Lc_EiwoAckCur_RejReason_CODE + ' - Other';
       END
      ELSE IF @Lc_EiwoAckCur_RejReason_CODE = 'B'
       BEGIN
        SET @Ls_DescriptionNote_TEXT = @Lc_EiwoAckCur_RejReason_CODE + ' - Name mismatch';
       END
      ELSE IF @Lc_EiwoAckCur_RejReason_CODE = 'S'
       BEGIN
        SET @Ls_DescriptionNote_TEXT = @Lc_EiwoAckCur_RejReason_CODE + ' - Employee in suspense status';
       END
      ELSE IF @Lc_EiwoAckCur_RejReason_CODE = 'M'
       BEGIN
        SET @Ls_DescriptionNote_TEXT = @Lc_EiwoAckCur_RejReason_CODE + ' - IWO received from multiple states';
       END

      IF @Lc_EiwoAckCur_DispCode_CODE = @Lc_DispCodeR_CODE
         AND @Lc_EiwoAckCur_RejReason_CODE IN (@Lc_RejectReasonN_CODE, @Lc_RejectReasonU_CODE, @Lc_RejectReasonW_CODE)
       BEGIN
        DECLARE Ehis_CUR INSENSITIVE CURSOR FOR
         SELECT MemberMci_IDNO,
                OthpPartyEmpl_IDNO,
                BeginEmployment_DATE,
                EndEmployment_DATE,
                TypeIncome_CODE,
                DescriptionOccupation_TEXT,
                IncomeNet_AMNT,
                IncomeGross_AMNT,
                FreqIncome_CODE,
                FreqPay_CODE,
                SourceLoc_CODE,
                SourceReceived_DATE,
                Status_CODE,
                Status_DATE,
                SourceLocConf_CODE,
                InsProvider_INDC,
                CostInsurance_AMNT,
                FreqInsurance_CODE,
                DpCoverageAvlb_INDC,
                EmployerPrime_INDC,
                DpCovered_INDC,
                EligCoverage_DATE,
                InsReasonable_INDC,
                LimitCcpa_INDC,
                PlsLastSearch_DATE,
                BeginValidity_DATE,
                WorkerUpdate_ID,
                Update_DTTM,
                TransactionEventSeq_NUMB
           FROM EHIS_Y1 B
          WHERE B.MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND B.OthpPartyEmpl_IDNO = @Ln_OthpSource_IDNO
            AND B.EndEmployment_DATE > @Ld_Run_DATE;

        OPEN Ehis_CUR;

        FETCH NEXT FROM Ehis_CUR INTO @Ln_EhisCur_MemberMci_IDNO, @Ln_EhisCur_OthpPartyEmpl_IDNO, @Ld_EhisCur_BeginEmployment_DATE, @Ld_EhisCur_EndEmployment_DATE, @Lc_EhisCur_TypeIncome_CODE, @Lc_EhisCur_DescriptionOccupation_TEXT, @Ln_EhisCur_IncomeNet_AMNT, @Ln_EhisCur_IncomeGross_AMNT, @Lc_EhisCur_FreqIncome_CODE, @Lc_EhisCur_FreqPay_CODE, @Lc_EhisCur_SourceLoc_CODE, @Ld_EhisCur_SourceReceived_DATE, @Lc_EhisCur_Status_CODE, @Ld_EhisCur_Status_DATE, @Lc_EhisCur_SourceLocConf_CODE, @Lc_EhisCur_InsProvider_INDC, @Ln_EhisCur_CostInsurance_AMNT, @Lc_EhisCur_FreqInsurance_CODE, @Lc_EhisCur_DpCoverageAvlb_INDC, @Lc_EhisCur_EmployerPrime_INDC, @Lc_EhisCur_DpCovered_INDC, @Ld_EhisCur_EligCoverage_DATE, @Lc_EhisCur_InsReasonable_INDC, @Lc_EhisCur_LimitCcpa_INDC, @Ld_EhisCur_PlsLastSearch_DATE, @Ld_EhisCur_BeginValidity_DATE, @Lc_EhisCur_WorkerUpdate_ID, @Ld_EhisCur_Update_DTTM, @Ln_EhisCur_TransactionEventSeq_NUMB;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

        --Cursor for Employer Update
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_EhisCur_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_EhisCur_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_EhisCur_SourceReceived_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_EhisCur_Status_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_EhisCur_Status_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_EhisCur_TypeIncome_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_EhisCur_SourceLocConf_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_EhisCur_BeginEmployment_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Ln_EhisCur_IncomeGross_AMNT AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Ln_EhisCur_IncomeNet_AMNT AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_EhisCur_FreqIncome_CODE, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_EhisCur_FreqPay_CODE, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_EhisCur_LimitCcpa_INDC, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_EhisCur_InsReasonable_INDC, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_EhisCur_InsReasonable_INDC, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_EhisCur_SourceLoc_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_EhisCur_InsProvider_INDC, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_EhisCur_DpCovered_INDC, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_EhisCur_DpCoverageAvlb_INDC, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_EhisCur_EligCoverage_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Ln_EhisCur_CostInsurance_AMNT AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_EhisCur_FreqInsurance_CODE, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_EhisCur_DescriptionOccupation_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_EhisCur_TransactionEventSeq_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_EhisCur_PlsLastSearch_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');

          EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
           @An_MemberMci_IDNO             = @Ln_EhisCur_MemberMci_IDNO,
           @An_OthpPartyEmpl_IDNO         = @Ln_EhisCur_OthpPartyEmpl_IDNO,
           @Ad_SourceReceived_DATE        = @Ld_EhisCur_SourceReceived_DATE,
           @Ac_Status_CODE                = @Lc_EhisCur_Status_CODE,
           @Ad_Status_DATE                = @Ld_EhisCur_Status_DATE,
           @Ac_TypeIncome_CODE            = @Lc_EhisCur_TypeIncome_CODE,
           @Ac_SourceLocConf_CODE         = @Lc_EhisCur_SourceLocConf_CODE,
           @Ad_Run_DATE                   = @Ld_Run_DATE,
           @Ad_BeginEmployment_DATE       = @Ld_EhisCur_BeginEmployment_DATE,
           @Ad_EndEmployment_DATE         = @Ld_Run_DATE,
           @An_IncomeGross_AMNT           = @Ln_EhisCur_IncomeGross_AMNT,
           @An_IncomeNet_AMNT             = @Ln_EhisCur_IncomeNet_AMNT,
           @Ac_FreqIncome_CODE            = @Lc_EhisCur_FreqIncome_CODE,
           @Ac_FreqPay_CODE               = @Lc_EhisCur_FreqPay_CODE,
           @Ac_LimitCcpa_INDC             = @Lc_EhisCur_LimitCcpa_INDC,
           @Ac_EmployerPrime_INDC         = @Lc_EhisCur_InsReasonable_INDC,
           @Ac_InsReasonable_INDC         = @Lc_EhisCur_InsReasonable_INDC,
           @Ac_SourceLoc_CODE             = @Lc_EhisCur_SourceLoc_CODE,
           @Ac_InsProvider_INDC           = @Lc_EhisCur_InsProvider_INDC,
           @Ac_DpCovered_INDC             = @Lc_EhisCur_DpCovered_INDC,
           @Ac_DpCoverageAvlb_INDC        = @Lc_EhisCur_DpCoverageAvlb_INDC,
           @Ad_EligCoverage_DATE          = @Ld_EhisCur_EligCoverage_DATE,
           @An_CostInsurance_AMNT         = @Ln_EhisCur_CostInsurance_AMNT,
           @Ac_FreqInsurance_CODE         = @Lc_EhisCur_FreqInsurance_CODE,
           @Ac_DescriptionOccupation_TEXT = @Lc_EhisCur_DescriptionOccupation_TEXT,
           @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB   = @Ln_EhisCur_TransactionEventSeq_NUMB,
           @Ad_PlsLastSearch_DATE         = @Ld_EhisCur_PlsLastSearch_DATE,
           @Ac_Process_ID                 = @Lc_Job_ID,
           @An_OfficeSignedOn_IDNO        = NULL,
           @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

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
             @An_Line_NUMB                = @Ln_CommitFreq_QNTY,
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

          FETCH NEXT FROM Ehis_CUR INTO @Ln_EhisCur_MemberMci_IDNO, @Ln_EhisCur_OthpPartyEmpl_IDNO, @Ld_EhisCur_BeginEmployment_DATE, @Ld_EhisCur_EndEmployment_DATE, @Lc_EhisCur_TypeIncome_CODE, @Lc_EhisCur_DescriptionOccupation_TEXT, @Ln_EhisCur_IncomeNet_AMNT, @Ln_EhisCur_IncomeGross_AMNT, @Lc_EhisCur_FreqIncome_CODE, @Lc_EhisCur_FreqPay_CODE, @Lc_EhisCur_SourceLoc_CODE, @Ld_EhisCur_SourceReceived_DATE, @Lc_EhisCur_Status_CODE, @Ld_EhisCur_Status_DATE, @Lc_EhisCur_SourceLocConf_CODE, @Lc_EhisCur_InsProvider_INDC, @Ln_EhisCur_CostInsurance_AMNT, @Lc_EhisCur_FreqInsurance_CODE, @Lc_EhisCur_DpCoverageAvlb_INDC, @Lc_EhisCur_EmployerPrime_INDC, @Lc_EhisCur_DpCovered_INDC, @Ld_EhisCur_EligCoverage_DATE, @Lc_EhisCur_InsReasonable_INDC, @Lc_EhisCur_LimitCcpa_INDC, @Ld_EhisCur_PlsLastSearch_DATE, @Ld_EhisCur_BeginValidity_DATE, @Lc_EhisCur_WorkerUpdate_ID, @Ld_EhisCur_Update_DTTM, @Ln_EhisCur_TransactionEventSeq_NUMB;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE Ehis_CUR;

        DEALLOCATE Ehis_CUR;
       END
      ELSE IF @Lc_EiwoAckCur_DispCode_CODE = @Lc_DispCodeR_CODE
         AND @Lc_EiwoAckCur_RejReason_CODE = @Lc_RejectReasonX_CODE
       BEGIN
        --Set the Resend Indicator if the member already has employment history 
        IF EXISTS (SELECT 1
                     FROM EHIS_Y1 E
                    WHERE E.MemberMci_IDNO = @Ln_MemberMci_IDNO
                      AND E.OthpPartyEmpl_IDNO = @Ln_OthpSource_IDNO
                      AND E.EndEmployment_DATE > @Ld_Run_DATE)
           AND EXISTS (SELECT 1
                         FROM DMJR_Y1 d
                        WHERE D.Case_IDNO = @Ln_Case_IDNO
                          AND D.MemberMci_IDNO = @Ln_MemberMci_IDNO
                          AND D.OthpSource_IDNO = @Ln_OthpSource_IDNO
                          AND D.Status_CODE = @Lc_RemedyStatusSTRT_CODE
                          AND D.ActivityMajor_CODE = @Lc_ActivityMajorIMIW_CODE)
         BEGIN
          SET @Lc_Resend_INDC = @Lc_Yes_INDC;
         END
       END

      --Given new employer information is to be used.
      SET @Ls_Sql_TEXT = 'UPDATE EIWT_Y1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_EiwoAckCur_Case_IDNO, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(@Ln_EiwoAckCur_Fein_IDNO, '') + ', DocTrackNo_TEXT = ' + ISNULL(@Lc_EiwoAckCur_DocTrackNo_TEXT, '');

      UPDATE EIWT_Y1
         SET Resend_INDC = @Lc_Resend_INDC,
             ReceivedAcknowledgement_DATE = @Ld_Run_DATE,
             RejReason_CODE = @Lc_EiwoAckCur_RejReason_CODE,
             Disp_CODE = @Lc_EiwoAckCur_DispCode_CODE,
             FinalPay_AMNT = @Ln_EiwoAckCur_FinalPay_AMNT,
             LumpSumPay_AMNT = @Ln_EiwoAckCur_LumpSumPay_AMNT,
             Termination_DATE = CASE
                                 WHEN ISDATE(@Ld_EiwoAckCur_Termination_DATE) = 0
                                  THEN @Ld_Low_DATE
                                 ELSE CAST(@Ld_EiwoAckCur_Termination_DATE AS DATE)
                                END,
             FinalPayment_DATE = CASE
                                  WHEN ISDATE(@Ld_EiwoAckCur_FinalPayment_DATE) = 0
                                   THEN @Ld_Low_DATE
                                  ELSE CAST(@Ld_EiwoAckCur_FinalPayment_DATE AS DATE)
                                 END,
             LumpSumPay_DATE = CASE
                                WHEN ISDATE(@Ld_EiwoAckCur_LumpSumPay_DATE) = 0
                                 THEN @Ld_Low_DATE
                                ELSE CAST(@Ld_EiwoAckCur_LumpSumPay_DATE AS DATE)
                               END
       WHERE Case_IDNO = @Ln_Case_IDNO
         AND MemberMci_IDNO = @Ln_MemberMci_IDNO
         AND Fein_IDNO = @Ln_EiwoAckCur_Fein_IDNO
         AND DocTrackNo_TEXT = @Lc_EiwoAckCur_DocTrackNo_TEXT;

      SET @Li_RowsCount_QNTY = @@ROWCOUNT;

      IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE EIWT_Y1 FAILED';

        RAISERROR (50001,16,1);
       END

      --If the reason code is O - Other or B - Name mismatch E-iwo Or S - Employee in suspense status	
      IF @Lc_EiwoAckCur_DispCode_CODE = @Lc_DispCodeR_CODE
         AND (@Lc_EiwoAckCur_RejReason_CODE IN (@Lc_RejectReasonO_CODE, @Lc_RejectReasonB_CODE, @Lc_RejectReasonS_CODE, @Lc_RejectReasonN_CODE,
                                                @Lc_RejectReasonU_CODE, @Lc_RejectReasonW_CODE, @Lc_RejectReasonM_CODE))
       BEGIN
        IF @Lc_EiwoAckCur_RejReason_CODE IN (@Lc_RejectReasonO_CODE, @Lc_RejectReasonB_CODE, @Lc_RejectReasonS_CODE, @Lc_RejectReasonN_CODE, @Lc_RejectReasonU_CODE)
         BEGIN
          SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorAEIWO_CODE
         END
        ELSE IF @Lc_EiwoAckCur_RejReason_CODE IN (@Lc_RejectReasonW_CODE)
         BEGIN
          SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorCEIWO_CODE;
          SET @Ls_DescriptionNote_TEXT = 'Current FEIN ' + ISNULL(CAST(@Ln_EiwoAckCur_Fein_IDNO AS VARCHAR), '') + '. Received corrected FEIN ' + ISNULL(CAST(@Ln_EiwoAckCur_CorrectFein_IDNO AS VARCHAR), '') + ' (' + LTRIM(RTRIM(@Ls_OtherParty_NAME)) + ') for MCI ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + '- review and correct records.';
         END
        ELSE IF @Lc_EiwoAckCur_RejReason_CODE IN (@Lc_RejectReasonM_CODE)
         BEGIN
          SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorMEIWO_CODE;
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
        SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

        EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_No_INDC,
         @An_EventFunctionalSeq_NUMB  = 0,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END

        SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_INSERT_ACTIVITY';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCASE_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemEN_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reference_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionNote_TEXT = ' + ISNULL(@Ls_DescriptionNote_TEXT, '');

        EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
         @An_Case_IDNO                = @Ln_Case_IDNO,
         @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
         @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCASE_CODE,
         @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
         @Ac_Subsystem_CODE           = @Lc_SubsystemEN_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeReference_CODE       = @Lc_Space_TEXT,
         @Ac_Reference_ID             = @Lc_Space_TEXT,
         @An_TopicIn_IDNO             = @Ln_Zero_NUMB,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @As_Xml_TEXT                 = @Lc_Space_TEXT,
         @An_MajorIntSeq_NUMB         = @Ln_Zero_NUMB,
         @An_MinorIntSeq_NUMB         = @Ln_Zero_NUMB,
         @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
         @Ac_IVDOutOfStateFips_CODE   = @Lc_Space_TEXT,
         @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
         @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
         BEGIN
          SET @Lc_BateError_CODE = @Lc_Msg_CODE;

          RAISERROR (50001,16,1);
         END
       END
     END TRY

     BEGIN CATCH
      -- Committable transaction checking and Rolling back Save point
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION EiwoAckTranSave
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      -- Check for Exception information to log the description text based on the error
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

      SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_CommitFreq_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
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

     SET @Ls_Sql_TEXT = 'UPDATE LEACK_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_EiwoAckCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LEACK_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Seq_IDNO = @Ln_EiwoAckCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE LEACK_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Li_RowsCount_QNTY;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION EiwoAckTran;

       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       BEGIN TRANSACTION EiwoAckTran;

       SET @Ln_CommitFreq_QNTY = 0;
      END

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_RecCount_NUMB;

       COMMIT TRANSACTION EiwoAckTran;

       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH EiwoAck_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM EiwoAck_CUR INTO @Ln_EiwoAckCur_Seq_IDNO, @Lc_EiwoAckCur_RejReason_CODE, @Lc_EiwoAckCur_Case_IDNO, @Ln_EiwoAckCur_Fein_IDNO, @Lc_EiwoAckCur_DispCode_CODE, @Lc_EiwoAckCur_DocTrackNo_TEXT, @Ld_EiwoAckCur_Termination_DATE, @Ld_EiwoAckCur_FinalPayment_DATE, @Ln_EiwoAckCur_FinalPay_AMNT, @Ld_EiwoAckCur_LumpSumPay_DATE, @Ln_EiwoAckCur_LumpSumPay_AMNT, @Ln_EiwoAckCur_CorrectFein_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorW_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorW_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sqldata_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE EiwoAck_CUR;

   DEALLOCATE EiwoAck_CUR;

   -- Update the parameter table with the job run date as the current system date
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

   -- Log the Status of job in BSTL_Y1 as Success	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION EiwoAckTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EiwoAckTran;
    END

   IF CURSOR_STATUS ('local', 'EiwoAck_CUR') IN (0, 1)
    BEGIN
     CLOSE EiwoAck_CUR;

     DEALLOCATE EiwoAck_CUR;
    END

   IF CURSOR_STATUS ('local', 'Ehis_CUR') IN (0, 1)
    BEGIN
     CLOSE Ehis_CUR;

     DEALLOCATE Ehis_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
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
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
