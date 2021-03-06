/****** Object:  StoredProcedure [dbo].[BATCH_CI_CSENET_FEDERAL_TIMERS$SP_PROCESS_INTERGOV_COMM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_CSENET_FEDERAL_TIMERS$SP_PROCESS_INTERGOV_COMM
Programmer Name	:	IMP Team.
Description		:	This procedure is used to handle CSENET Timers
Frequency		:	'DAILY'
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_CSENET_FEDERAL_TIMERS$SP_PROCESS_INTERGOV_COMM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC                         CHAR(1) = 'N',
          @Lc_Space_TEXT                      CHAR(1) = ' ',
          @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_CaseStatusOpen_CODE             CHAR(1) = 'O',
          @Lc_ActionRequest_CODE              CHAR(1) = 'R',
          @Lc_Yes_INDC                        CHAR(1) = 'Y',
          @Lc_ActionCancel_CODE               CHAR(1) = 'C',
          @Lc_ActionAcknowledgment_CODE       CHAR(1) = 'A',
          @Lc_CaseStatusClosed_CODE           CHAR(1) = 'C',
          @Lc_ActionProvide_CODE              CHAR(1) = 'P',
          @Lc_RespondingState_CODE            CHAR(1) = 'R',
          @Lc_InitiateState_CODE              CHAR(1) = 'I',
          @Lc_InitiateInternational_CODE      CHAR(1) = 'C',
          @Lc_InitiateTribal_CODE             CHAR(1) = 'T',
          @Lc_RespondingInternational_CODE    CHAR(1) = 'Y',
          @Lc_RespondingTribal_CODE           CHAR(1) = 'S',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
          @Lc_RefAssistReferal_CODE           CHAR(1) = 'R',
          @Lc_ActivityMinorEnforcement_CODE   CHAR(1) = 'N',
          @Lc_ActivityMinorEstablishment_CODE CHAR(1) = 'S',
          @Lc_ActivityMinorPaternity_CODE     CHAR(1) = 'P',
          @Lc_CaseClosed_TEXT                 CHAR(1) = 'N',
          @Lc_ReferralCancelled_TEXT          CHAR(1) = 'N',
          @Lc_PendingRequest_TEXT             CHAR(1) = 'N',
          @Lc_ResetTimer_TEXT                 CHAR(1) = 'N',
          @Lc_InsertTimer_TEXT                CHAR(1) = 'N',
          @Lc_InsertInfo_TEXT                 CHAR(1) = 'N',
          @Lc_Attachment_INDC                 CHAR(1) = 'N',
          @Lc_OutputDirection_TEXT            CHAR(1) = 'O',
          @Lc_InputDirection_TEXT             CHAR(1) = 'I',
          @Lc_TypeErrorE_CODE                 CHAR(1) = 'E',
          @Lc_TranStatusSr_CODE               CHAR(2) = 'SR',
          @Lc_FunctionEnforcement_CODE        CHAR(3) = 'ENF',
          @Lc_FunctionEstablishment_CODE      CHAR(3) = 'EST',
          @Lc_FunctionPaternity_CODE          CHAR(3) = 'PAT',
          @Lc_FunctionManagestcases_CODE      CHAR(3) = 'MSC',
          @Lc_RemedyStatusStart_CODE          CHAR(4) = 'STRT',
          @Lc_ActivityMinorCox11_CODE         CHAR(5) = 'COX11',
          @Lc_ActivityMinorCax20_CODE         CHAR(5) = 'CAX20',
          @Lc_ActivityMinorCox90_CODE         CHAR(5) = 'COX90',
          @Lc_ActivityMinorCxr30_CODE         CHAR(5) = 'CXR30',
          @Lc_ActivityMinorCxi30_CODE         CHAR(5) = 'CXI30',
          @Lc_ActivityMinorCix30_CODE         CHAR(5) = 'CIX30',
          @Lc_ActivityMinorCix90_CODE         CHAR(5) = 'CIX90',
          @Lc_ActivityMinorCx090_CODE         CHAR(5) = 'CX090',
          @Lc_ActivityMinorCx180_CODE         CHAR(5) = 'CX180',
          @Lc_ActivityMinorSx180_CODE         CHAR(5) = 'SX180',
          @Lc_ActivityMinorCx091_CODE         CHAR(5) = 'CX091',
          @Lc_ActivityMinorCon11_CODE         CHAR(5) = 'CON11',
          @Lc_ActivityMinorCos11_CODE         CHAR(5) = 'COS11',
          @Lc_ActivityMinorCop11_CODE         CHAR(5) = 'COP11',
          @Lc_ActivityMinorCan20_CODE         CHAR(5) = 'CAN20',
          @Lc_ActivityMinorCas20_CODE         CHAR(5) = 'CAS20',
          @Lc_ActivityMinorCap20_CODE         CHAR(5) = 'CAP20',
          @Lc_ActivityMinorCon90_CODE         CHAR(5) = 'CON90',
          @Lc_ActivityMinorCos90_CODE         CHAR(5) = 'COS90',
          @Lc_ActivityMinorCop90_CODE         CHAR(5) = 'COP90',
          @Lc_ActivityMinorCnr30_CODE         CHAR(5) = 'CNR30',
          @Lc_ActivityMinorCsr30_CODE         CHAR(5) = 'CSR30',
          @Lc_ActivityMinorCpr30_CODE         CHAR(5) = 'CPR30',
          @Lc_ActivityMinorCin30_CODE         CHAR(5) = 'CIN30',
          @Lc_ActivityMinorCis30_CODE         CHAR(5) = 'CIS30',
          @Lc_ActivityMinorCip30_CODE         CHAR(5) = 'CIP30',
          @Lc_ActivityMinorCin90_CODE         CHAR(5) = 'CIN90',
          @Lc_ActivityMinorCis90_CODE         CHAR(5) = 'CIS90',
          @Lc_ActivityMinorCip90_CODE         CHAR(5) = 'CIP90',
          @Lc_ActivityMinorCn090_CODE         CHAR(5) = 'CN090',
          @Lc_ActivityMinorCs090_CODE         CHAR(5) = 'CS090',
          @Lc_ActivityMinorCp090_CODE         CHAR(5) = 'CP090',
          @Lc_ActivityMinorCn180_CODE         CHAR(5) = 'CN180',
          @Lc_ActivityMinorCs180_CODE         CHAR(5) = 'CS180',
          @Lc_ActivityMinorCp180_CODE         CHAR(5) = 'CP180',
          @Lc_ReasonAnoad_CODE                CHAR(5) = 'ANOAD',
          @Lc_ReasonAadin_CODE                CHAR(5) = 'AADIN',
          @Lc_ReasonGspud_CODE                CHAR(5) = 'GSPUD',
          @Lc_ReasonGsupd_CODE                CHAR(5) = 'GSUPD',
          @Lc_ReasonGrupd_CODE                CHAR(5) = 'GRUPD',
          @Lc_ReasonSradj_CODE                CHAR(5) = 'SRADJ',
          @Lc_ReasonSrmod_CODE                CHAR(5) = 'SRMOD',
          @Lc_BateErrorE1424_CODE             CHAR(5) = 'E1424',
          @Lc_BatchRunUser_TEXT               CHAR(5) = 'BATCH',
          @Lc_Job_ID                          CHAR(7) = 'DEB0745',
          @Lc_Successful_TEXT                 CHAR(10) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT            VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_CI_CSENET_FEDERAL_TIMERS',
          @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS_INTERGOV_COMM',
          @Ld_High_DATE                       DATE = '12/31/9999',
          @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE @Ln_CommitFreqParm_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY         NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY       NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
          @Ln_Topic_IDNO                      NUMERIC(10) = 0,
          @Ln_Value_QNTY                      NUMERIC(10) = 0,
          @Ln_FetchStatus_QNTY                NUMERIC(10, 0),
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB                  NUMERIC(11),
          @Ln_Error_NUMB                      NUMERIC(11),
		  @Ln_Zero_NUMB                       SMALLINT = 0,
          @Lc_Empty_TEXT                      CHAR(1) = '',
          @Lc_Action_CODE                     CHAR(1),
          @Lc_Function_CODE                   CHAR(3),
          @Lc_MinorActivity_CODE              CHAR(5),
          @Lc_MinorActivityOld_CODE           CHAR(5),
          @Lc_MinorActivityInfo_CODE          CHAR(5),
          @Lc_Msg_CODE                        CHAR(5),
          @Lc_ReasonPend_CODE                 CHAR(5),
          @Lc_Reason_CODE                     CHAR(5) = '',
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_Case_IDNO                       CHAR(6),
          @Lc_Fips_CODE                       CHAR(7),
          @Ls_CursorLocation_TEXT             VARCHAR(200),
          @Ls_Sql_TEXT                        VARCHAR(400) = '',
          @Ls_Sqldata_TEXT                    VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT           VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(4000),
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Start_DATE                      DATETIME2;
  DECLARE @Ln_ReferalOutCur_Case_IDNO                    NUMERIC(6),
          @Ln_ReferalOutCur_RespondentMci_IDNO           NUMERIC(10),
          @Lc_ReferalOutCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_ReferalOutCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_ReferalOutCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Ln_ReferalOutCur_TransHeader_IDNO             NUMERIC(12),
          @Lc_ReferalOutCur_Message_ID                   CHAR(11),
          @Ld_ReferalOutCur_Transaction_DATE             DATE,
          @Lc_ReferalOutCur_Function_CODE                CHAR(3);
  DECLARE @Ln_TimerCur_Case_IDNO                    NUMERIC(6),
          @Ln_TimerCur_OrderSeq_NUMB                NUMERIC(2),
          @Ln_TimerCur_OthpSource_IDNO              NUMERIC(9),
          @Ln_TimerCur_MemberMci_IDNO               NUMERIC(10),
          @Lc_TimerCur_ActivityMajor_CODE           CHAR(4),
          @Lc_TimerCur_ActivityMinor_CODE           CHAR(5),
          @Ln_TimerCur_MajorIntSeq_NUMB             NUMERIC(5),
          @Ln_TimerCur_MinorIntSeq_NUMB             NUMERIC(5),
          @Ln_TimerCur_Forum_IDNO                   NUMERIC(10),
          @Ld_TimerCur_Entered_DATE                 DATE,
          @Ln_TimerCur_TransactionEventSeq_NUMB     NUMERIC(19),
          @Lc_TimerCur_Reference_ID                 CHAR(30),
          @Lc_TimerCur_ActivityMinorNext_CODE       CHAR(5),
          @Ld_TimerCur_End_DATE                     DATE,
          @Ld_TimerCur_Due_DATE                     DATE,
          @Lc_TimerCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_TimerCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_TimerCur_IVDOutOfStateCase_ID         CHAR(15),
          @Lc_TimerCur_Message_ID                   CHAR(11),
          @Ln_TimerCur_TransHeader_IDNO             NUMERIC(12),
          @Lc_TimerCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_TimerCur_Function_CODE                CHAR(3),
          @Ld_TimerCur_Transaction_DATE             DATE,
          @Lc_TimerCur_Reason_CODE                  CHAR(5);
  DECLARE @Lc_ReferalInCur_Case_IDNO                    CHAR(6),
          @Lc_ReferalInCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_ReferalInCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_ReferalInCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Ln_ReferalInCur_TransHeader_IDNO             NUMERIC(12),
          @Lc_ReferalInCur_Message_ID                   CHAR(11),
          @Ld_ReferalInCur_Transaction_DATE             DATE,
          @Lc_ReferalInCur_Function_CODE                CHAR(3),
          @Ld_ReferalInCur_End_DATE                     DATE,
          @Lc_ReferalInCur_Reason_CODE                  CHAR(5),
          @Lc_ReferalInCur_RespondInit_CODE             CHAR(1);
  DECLARE @Ln_TimerCur_Case2_IDNO                    NUMERIC(6),
          @Ln_TimerCur_OrderSeq2_NUMB                NUMERIC(2, 0),
          @Lc_TimerCur_OthpSource2_IDNO              CHAR(10),
          @Lc_TimerCur_MemberMci2_IDNO               CHAR(10),
          @Lc_TimerCur_ActivityMajor2_CODE           CHAR(4),
          @Lc_TimerCur_ActivityMinor2_CODE           CHAR(5),
          @Ln_TimerCur_MajorIntSeq2_NUMB             NUMERIC(2, 0),
          @Ln_TimerCur_MinorIntSeq2_NUMB             NUMERIC(5, 0),
          @Ln_TimerCur_Forum2_IDNO                   NUMERIC(10, 0),
          @Ld_TimerCur_Entered2_DATE                 DATETIME2(6),
          @Ln_TimerCur_TransactionEventSeq2_NUMB     NUMERIC(19, 0),
          @Lc_TimerCur_Reference2_IDNO               CHAR(30),
          @Lc_TimerCur_ActivityMinorNext2_CODE       CHAR(5),
          @Ld_TimerCur_End2_DATE                     DATE,
          @Ld_TimerCur_Due2_DATE                     DATE,
          @Lc_TimerCur_IVDOutOfStateCountyFips2_CODE CHAR(3),
          @Lc_TimerCur_IVDOutOfStateOfficeFips2_CODE CHAR(2),
          @Lc_TimerCur_IVDOutOfStateCase2_IDNO       CHAR(15),
          @Lc_TimerCur_Message2_IDNO                 CHAR(11),
          @Lc_TimerCur_TransHeader2_IDNO             CHAR(12),
          @Lc_TimerCur_IVDOutOfStateFips2_CODE       CHAR(2),
          @Ld_TimerCur_Transaction2_DATE             DATETIME2(6),
          @Lc_TimerCur_Function2_CODE                CHAR(3),
          @Lc_TimerCur_Action_CODE                   CHAR(1),
          @Lc_TimerCur_Reason2_CODE                  CHAR(5);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   BEGIN TRANSACTION TIMERS;

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
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --New Referral Initiating
   DECLARE ReferalOut_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           a.Case_IDNO,
           c.RespondentMci_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.TransHeader_IDNO,
           a.Message_ID,
           a.Transaction_DATE,
           a.Function_CODE
      FROM CTHB_Y1 a,
           CASE_Y1 b,
           ICAS_Y1 c
     WHERE a.IoDirection_CODE = @Lc_OutputDirection_TEXT
       AND a.Case_IDNO = b.Case_IDNO
       AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
       AND b.RespondInit_CODE IN (@Lc_InitiateState_CODE, @Lc_InitiateInternational_CODE, @Lc_InitiateTribal_CODE)
       AND (a.End_DATE) BETWEEN (DATEADD(D, 1, @Ld_LastRun_DATE)) AND @Ld_Run_DATE
       AND a.Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
       AND a.Action_CODE = @Lc_ActionRequest_CODE
       AND a.Reason_CODE IN (SELECT d.Reason_CODE
                               FROM CFAR_Y1 d
                              WHERE a.Function_CODE = d.Function_CODE
                                AND a.Action_CODE = d.Action_CODE
                                AND d.RefAssist_CODE = @Lc_RefAssistReferal_CODE)
       AND a.Case_IDNO = c.Case_IDNO
       AND c.Status_CODE = @Lc_CaseStatusOpen_CODE
       AND c.RespondInit_CODE = b.RespondInit_CODE
       AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN ReferalOut_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN ReferalOut_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ReferalOut_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM ReferalOut_CUR INTO @Ln_ReferalOutCur_Case_IDNO, @Ln_ReferalOutCur_RespondentMci_IDNO, @Lc_ReferalOutCur_IVDOutOfStateFips_CODE, @Lc_ReferalOutCur_IVDOutOfStateCountyFips_CODE, @Lc_ReferalOutCur_IVDOutOfStateOfficeFips_CODE, @Ln_ReferalOutCur_TransHeader_IDNO, @Lc_ReferalOutCur_Message_ID, @Ld_ReferalOutCur_Transaction_DATE, @Lc_ReferalOutCur_Function_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Referral cursor - close and insert
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_TIMERS;

      SET @Ln_CommitFreq_QNTY += 1;
      SET @Ln_RecordCount_QNTY += 1;
      SET @Ln_ProcessedRecordCount_QNTY += 1;
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_CursorLocation_TEXT = 'ReferalOut_CUR - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ln_Value_QNTY = @Ln_Value_QNTY + 1;
      SET @Ln_Topic_IDNO = 0;
      SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS - 1';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_ReferalOutCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_ReferalOutCur_Transaction_DATE AS VARCHAR), '') + ', Message_ID = ' + ISNULL(@Lc_ReferalOutCur_Message_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_ReferalOutCur_Case_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_ReferalOutCur_IVDOutOfStateFips_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_ReferalOutCur_Function_CODE, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_InitiateState_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

      EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS
       @An_TransHeader_IDNO       = @Ln_ReferalOutCur_TransHeader_IDNO,
       @Ad_Transaction_DATE       = @Ld_ReferalOutCur_Transaction_DATE,
       @Ac_Message_ID             = @Lc_ReferalOutCur_Message_ID,
       @An_Case_IDNO              = @Ln_ReferalOutCur_Case_IDNO,
       @Ac_IVDOutOfStateFips_CODE = @Lc_ReferalOutCur_IVDOutOfStateFips_CODE,
       @Ac_Function_CODE          = @Lc_ReferalOutCur_Function_CODE,
       @Ac_RespondInit_CODE       = @Lc_InitiateState_CODE,
       @Ad_Run_DATE               = @Ld_Run_DATE,
       @Ac_Job_ID                 = @Lc_Job_ID,
       @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR(50001,16,1);
       END;

      IF @Lc_ReferalOutCur_Function_CODE = @Lc_FunctionEnforcement_CODE
       BEGIN
        SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCon11_CODE;
       END
      ELSE IF @Lc_ReferalOutCur_Function_CODE = @Lc_FunctionEstablishment_CODE
       BEGIN
        SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCos11_CODE;
       END;
      ELSE IF @Lc_ReferalOutCur_Function_CODE = @Lc_FunctionPaternity_CODE
       BEGIN
        SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCop11_CODE;
       END;

      SET @Lc_Fips_CODE = @Lc_ReferalOutCur_IVDOutOfStateFips_CODE + @Lc_ReferalOutCur_IVDOutOfStateCountyFips_CODE + @Lc_ReferalOutCur_IVDOutOfStateOfficeFips_CODE;
      SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS - ' + @Lc_ReferalOutCur_Function_CODE + ' - ' + @Lc_MinorActivity_CODE;
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_ReferalOutCur_TransHeader_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_ReferalOutCur_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_ReferalOutCur_RespondentMci_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivity_CODE, '') + ', ActivityMinorOld_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Timer_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '');

      EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS
       @An_TransHeader_IDNO         = @Ln_ReferalOutCur_TransHeader_IDNO,
       @An_Case_IDNO                = @Ln_ReferalOutCur_Case_IDNO,
       @An_RespondentMci_IDNO       = @Ln_ReferalOutCur_RespondentMci_IDNO,
       @Ac_Fips_CODE                = @Lc_Fips_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
       @Ac_ActivityMinorOld_CODE    = @Lc_Space_TEXT,
       @An_TransactionEventSeq_NUMB = @Ln_Zero_NUMB,
       @Ac_Timer_INDC               = @Lc_Yes_INDC,
       @Ac_BatchRunUser_TEXT        = @Lc_BatchRunUser_TEXT,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @As_Process_NAME             = @Ls_Process_NAME,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR(50001,16,1);
       END;
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_TIMERS;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB != 50001
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

     IF @Ln_CommitFreq_QNTY != 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TIMERS';

       COMMIT TRANSACTION TIMERS;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TIMERS';

       BEGIN TRANSACTION TIMERS;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;

       COMMIT TRANSACTION TIMERS;

       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ReferalOut_CUR - 2';

     FETCH NEXT FROM ReferalOut_CUR INTO @Ln_ReferalOutCur_Case_IDNO, @Ln_ReferalOutCur_RespondentMci_IDNO, @Lc_ReferalOutCur_IVDOutOfStateFips_CODE, @Lc_ReferalOutCur_IVDOutOfStateCountyFips_CODE, @Lc_ReferalOutCur_IVDOutOfStateOfficeFips_CODE, @Ln_ReferalOutCur_TransHeader_IDNO, @Lc_ReferalOutCur_Message_ID, @Ld_ReferalOutCur_Transaction_DATE, @Lc_ReferalOutCur_Function_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   --CLOSE ReferalOut_CUR
   IF CURSOR_STATUS('LOCAL', 'ReferalOut_CUR') IN (0, 1)
    BEGIN
     CLOSE ReferalOut_CUR;

     DEALLOCATE ReferalOut_CUR;
    END

   DECLARE Timer_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           j.Case_IDNO,
           j.OrderSeq_NUMB,
           j.OthpSource_IDNO,
           n.MemberMci_IDNO,
           j.ActivityMajor_CODE,
           n.ActivityMinor_CODE,
           j.MajorIntSEQ_NUMB,
           n.MinorIntSeq_NUMB,
           j.Forum_IDNO,
           n.Entered_DATE,
           j.TransactionEventSeq_NUMB,
           j.Reference_ID,
           n.ActivityMinorNext_CODE,
           c.End_DATE,
           n.Due_DATE,
           c.IVDOutOfStateCountyFips_CODE,
           c.IVDOutOfStateOfficeFips_CODE,
           c.IVDOutOfStateCase_ID,
           c.Message_ID,
           c.TransHeader_IDNO,
           c.IVDOutOfStateFips_CODE,
           c.Function_CODE,
           c.Transaction_DATE,
           c.Reason_CODE
      FROM DMNR_Y1 n,
           DMJR_Y1 j,
           CTHB_Y1 c
     WHERE j.Status_CODE = @Lc_RemedyStatusStart_CODE
       AND j.Status_DATE = @Ld_High_DATE
       AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
       AND n.Status_DATE = @Ld_High_DATE
       AND n.Entered_DATE < @Ld_Run_DATE
       AND j.Case_IDNO = n.Case_IDNO
       AND j.OrderSeq_NUMB = n.OrderSeq_NUMB
       AND j.MajorIntSEQ_NUMB = n.MajorIntSEQ_NUMB
       AND CAST(n.Topic_IDNO AS VARCHAR(10)) = c.Transaction_IDNO
       AND n.ActivityMinor_CODE IN (@Lc_ActivityMinorCon11_CODE, @Lc_ActivityMinorCos11_CODE, @Lc_ActivityMinorCop11_CODE, @Lc_ActivityMinorCan20_CODE,
                                    @Lc_ActivityMinorCas20_CODE, @Lc_ActivityMinorCap20_CODE, @Lc_ActivityMinorCon90_CODE, @Lc_ActivityMinorCos90_CODE,
                                    @Lc_ActivityMinorCop90_CODE, @Lc_ActivityMinorCnr30_CODE, @Lc_ActivityMinorCsr30_CODE, @Lc_ActivityMinorCpr30_CODE)
       AND n.ActivityMinorNext_CODE = c.IVDOutOfStateFips_CODE
       AND n.Case_IDNO = c.Case_IDNO
       AND (c.End_DATE) < (@Ld_Run_DATE)
       AND c.Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
       AND c.Action_CODE = @Lc_ActionRequest_CODE
       AND c.IoDirection_CODE = @Lc_OutputDirection_TEXT
       AND c.Reason_CODE IN (SELECT b.Reason_CODE
                               FROM CFAR_Y1 b
                              WHERE c.Function_CODE = b.Function_CODE
                                AND c.Action_CODE = b.Action_CODE
                                AND b.RefAssist_CODE = @Lc_RefAssistReferal_CODE);

   SET @Ls_Sql_TEXT = 'OPEN Timer_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Timer_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Timer_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Timer_CUR INTO @Ln_TimerCur_Case_IDNO, @Ln_TimerCur_OrderSeq_NUMB, @Ln_TimerCur_OthpSource_IDNO, @Ln_TimerCur_MemberMci_IDNO, @Lc_TimerCur_ActivityMajor_CODE, @Lc_TimerCur_ActivityMinor_CODE, @Ln_TimerCur_MajorIntSeq_NUMB, @Ln_TimerCur_MinorIntSeq_NUMB, @Ln_TimerCur_Forum_IDNO, @Ld_TimerCur_Entered_DATE, @Ln_TimerCur_TransactionEventSeq_NUMB, @Lc_TimerCur_Reference_ID, @Lc_TimerCur_ActivityMinorNext_CODE, @Ld_TimerCur_End_DATE, @Ld_TimerCur_Due_DATE, @Lc_TimerCur_IVDOutOfStateCountyFips_CODE, @Lc_TimerCur_IVDOutOfStateOfficeFips_CODE, @Lc_TimerCur_IVDOutOfStateCase_ID, @Lc_TimerCur_Message_ID, @Ln_TimerCur_TransHeader_IDNO, @Lc_TimerCur_IVDOutOfStateFips_CODE, @Lc_TimerCur_Function_CODE, @Ld_TimerCur_Transaction_DATE, @Lc_TimerCur_Reason_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Initiating Monitoring cursor 
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_TIMERS;

      SET @Ln_CommitFreq_QNTY += 1;
      SET @Ln_RecordCount_QNTY += 1;
      SET @Ln_ProcessedRecordCount_QNTY += 1;
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_CursorLocation_TEXT = 'Timer_CUR - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Lc_CaseClosed_TEXT = @Lc_No_INDC;
      SET @Lc_ReferralCancelled_TEXT = @Lc_No_INDC;
      SET @Lc_PendingRequest_TEXT = @Lc_No_INDC;
      SET @Lc_ResetTimer_TEXT = @Lc_No_INDC;
      SET @Lc_InsertTimer_TEXT = @Lc_No_INDC;
      SET @Lc_InsertInfo_TEXT = @Lc_No_INDC;
      SET @Lc_ReasonPend_CODE = @Lc_Space_TEXT;
      SET @Lc_Function_CODE = @Lc_Space_TEXT;
      SET @Lc_Action_CODE = @Lc_Space_TEXT;
      SET @Lc_Case_IDNO = @Lc_Space_TEXT;
      SET @Lc_Reason_CODE = @Lc_Space_TEXT;
      SET @Lc_ActivityMinorCox11_CODE = 'COX11';
      SET @Lc_ActivityMinorCax20_CODE = 'CAX20';
      SET @Lc_ActivityMinorCox90_CODE = 'COX90';
      SET @Lc_ActivityMinorCxr30_CODE = 'CXR30';
      SET @Lc_ActivityMinorCxi30_CODE = 'CXI30';
      SET @Ls_Sql_TEXT = 'SELECT CTHB_Y1 FOR CANCEL REFERRAL FOR - ' + ISNULL(@Lc_TimerCur_Function_CODE, '');
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', IoDirection_CODE = ' + ISNULL(@Lc_OutputDirection_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_TimerCur_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionCancel_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', IoDirection_CODE = ' + ISNULL(@Lc_InputDirection_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_TimerCur_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionAcknowledgment_CODE, '');

      SELECT TOP 1 @Lc_ReferralCancelled_TEXT = CASE LTRIM(a.TransHeader_IDNO)
                                                 WHEN ''
                                                  THEN @Lc_No_INDC
                                                 ELSE @Lc_Yes_INDC
                                                END
        FROM CTHB_Y1 a
       WHERE a.Case_IDNO = @Ln_TimerCur_Case_IDNO
         AND a.IoDirection_CODE = @Lc_OutputDirection_TEXT
         AND a.IVDOutOfStateFips_CODE = @Lc_TimerCur_ActivityMinorNext_CODE
         AND a.Function_CODE = @Lc_TimerCur_Function_CODE
         AND a.Action_CODE = @Lc_ActionCancel_CODE
         AND LTRIM(a.Reason_CODE) = ''
         AND (a.End_DATE) > (@Ld_TimerCur_End_DATE)
         AND NOT EXISTS (SELECT 1
                           FROM CTHB_Y1 b
                          WHERE b.Case_IDNO = @Ln_TimerCur_Case_IDNO
                            AND b.IoDirection_CODE = @Lc_InputDirection_TEXT
                            AND b.IVDOutOfStateFips_CODE = @Lc_TimerCur_ActivityMinorNext_CODE
                            AND b.Function_CODE = @Lc_TimerCur_Function_CODE
                            AND b.Action_CODE = @Lc_ActionAcknowledgment_CODE
                            AND b.Reason_CODE IN (@Lc_ReasonAnoad_CODE, @Lc_ReasonAadin_CODE)
                            AND (b.End_DATE) > (@Ld_TimerCur_End_DATE)
                            AND (b.End_DATE) <= (a.End_DATE))
       ORDER BY a.End_DATE DESC;

      SET @Ls_Sql_TEXT = 'SELECT CASE_Y1,ICAS_Y1 FOR CLOSED CASE FOR - ' + ISNULL(@Lc_TimerCur_Function_CODE, '');
      SET @Ls_Sqldata_TEXT = '';

      SELECT TOP (1) @Lc_CaseClosed_TEXT = CASE z.Status_CODE
                                            WHEN @Lc_CaseStatusClosed_CODE
                                             THEN @Lc_Yes_INDC
                                            ELSE @Lc_No_INDC
                                           END
        FROM (SELECT ISNULL(a.StatusCase_CODE, @Lc_CaseStatusClosed_CODE) AS Status_CODE
                FROM CASE_Y1 a
               WHERE a.Case_IDNO = @Ln_TimerCur_Case_IDNO
              UNION ALL
              SELECT TOP 1 @Lc_CaseStatusClosed_CODE AS Status_CODE
                FROM ICAS_Y1 b
               WHERE b.Case_IDNO = @Ln_TimerCur_Case_IDNO
                 AND b.EndValidity_DATE = @Ld_High_DATE
                 AND NOT EXISTS (SELECT 1
                                   FROM ICAS_Y1 c
                                  WHERE c.Case_IDNO = @Ln_TimerCur_Case_IDNO
                                    AND c.Status_CODE = @Lc_CaseStatusOpen_CODE
                                    AND c.EndValidity_DATE = @Ld_High_DATE)) z
       ORDER BY Status_CODE ASC;

      IF @Lc_ReferralCancelled_TEXT = @Lc_Yes_INDC
          OR @Lc_CaseClosed_TEXT = @Lc_Yes_INDC
          OR EXISTS (SELECT 1
                       FROM CASE_Y1 c
                      WHERE c.Case_IDNO = @Ln_TimerCur_Case_IDNO
                        AND c.RespondInit_CODE = 'N')
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS - CASE CLOSED/REFERRAL CANCELLED';
        SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_TimerCur_Transaction_DATE AS VARCHAR), '') + ', Message_ID = ' + ISNULL(@Lc_TimerCur_Message_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_TimerCur_Function_CODE, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_InitiateState_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

        EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS
         @An_TransHeader_IDNO       = @Ln_TimerCur_TransHeader_IDNO,
         @Ad_Transaction_DATE       = @Ld_TimerCur_Transaction_DATE,
         @Ac_Message_ID             = @Lc_TimerCur_Message_ID,
         @An_Case_IDNO              = @Ln_TimerCur_Case_IDNO,
         @Ac_IVDOutOfStateFips_CODE = @Lc_TimerCur_ActivityMinorNext_CODE,
         @Ac_Function_CODE          = @Lc_TimerCur_Function_CODE,
         @Ac_RespondInit_CODE       = @Lc_InitiateState_CODE,
         @Ad_Run_DATE               = @Ld_Run_DATE,
         @Ac_Job_ID                 = @Lc_Job_ID,
         @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;
       END;
      ELSE
       BEGIN
        IF @Lc_TimerCur_Function_CODE = @Lc_FunctionEnforcement_CODE
         BEGIN
          SET @Lc_ActivityMinorCox11_CODE = REPLACE(@Lc_ActivityMinorCox11_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCax20_CODE = REPLACE(@Lc_ActivityMinorCax20_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCox90_CODE = REPLACE(@Lc_ActivityMinorCox90_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCxr30_CODE = REPLACE(@Lc_ActivityMinorCxr30_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCxi30_CODE = REPLACE(@Lc_ActivityMinorCxi30_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
         END;
        ELSE IF @Lc_TimerCur_Function_CODE = @Lc_FunctionEstablishment_CODE
         BEGIN
          SET @Lc_ActivityMinorCox11_CODE = REPLACE(@Lc_ActivityMinorCox11_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCax20_CODE = REPLACE(@Lc_ActivityMinorCax20_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCox90_CODE = REPLACE(@Lc_ActivityMinorCox90_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCxr30_CODE = REPLACE(@Lc_ActivityMinorCxr30_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCxi30_CODE = REPLACE(@Lc_ActivityMinorCxi30_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
         END;
        ELSE IF @Lc_TimerCur_Function_CODE = @Lc_FunctionPaternity_CODE
         BEGIN
          SET @Lc_ActivityMinorCox11_CODE = REPLACE(@Lc_ActivityMinorCox11_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCax20_CODE = REPLACE(@Lc_ActivityMinorCax20_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCox90_CODE = REPLACE(@Lc_ActivityMinorCox90_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCxr30_CODE = REPLACE(@Lc_ActivityMinorCxr30_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCxi30_CODE = REPLACE(@Lc_ActivityMinorCxi30_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
         END;

        IF @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCox11_CODE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT CTHB_Y1 FOR REASON CODE AADIN/ANOAD FOR - ' + ISNULL(@Lc_TimerCur_Function_CODE, '');
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', IoDirection_CODE = ' + ISNULL(@Lc_InputDirection_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_TimerCur_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionAcknowledgment_CODE, '');

          SELECT TOP (1) @Lc_Reason_CODE = b.Reason_CODE
            FROM CTHB_Y1 b
           WHERE (b.Case_IDNO = @Ln_TimerCur_Case_IDNO
              AND b.IoDirection_CODE = @Lc_InputDirection_TEXT
              AND b.IVDOutOfStateFips_CODE = @Lc_TimerCur_ActivityMinorNext_CODE
              AND b.Function_CODE = @Lc_TimerCur_Function_CODE
              AND b.Action_CODE = @Lc_ActionAcknowledgment_CODE
              AND b.Reason_CODE IN (@Lc_ReasonAnoad_CODE, @Lc_ReasonAadin_CODE)
              AND (b.End_DATE) > (@Ld_TimerCur_End_DATE))
           ORDER BY b.End_DATE DESC;

          IF @Lc_Reason_CODE = @Lc_ReasonAnoad_CODE
              OR (LTRIM(@Lc_Reason_CODE) = @Lc_Empty_TEXT
                  AND @Ld_TimerCur_Due_DATE <= @Ld_Run_DATE)
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS - COX90 - ' + ISNULL(@Lc_TimerCur_Function_CODE, '');
            SET @Lc_ResetTimer_TEXT = @Lc_Yes_INDC;
            SET @Lc_MinorActivityOld_CODE = @Lc_TimerCur_ActivityMinor_CODE;
            SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCox90_CODE;
           END
          ELSE IF @Lc_Reason_CODE = @Lc_ReasonAadin_CODE
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS -  CAX20  - ' + ISNULL(@Lc_TimerCur_Function_CODE, '');
            SET @Lc_ResetTimer_TEXT = @Lc_Yes_INDC;
            SET @Lc_MinorActivityOld_CODE = @Lc_TimerCur_ActivityMinor_CODE;
            SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCax20_CODE;
           END;
         END;

        IF @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCax20_CODE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT Reason_CODE GSPUD/GSUPD - FOR TIMER CAX20';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', IoDirection_CODE = ' + ISNULL(@Lc_OutputDirection_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_FunctionManagestcases_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionProvide_CODE, '');

          SELECT TOP 1 @Lc_Reason_CODE = b.Reason_CODE
            FROM CTHB_Y1 b
           WHERE b.Case_IDNO = @Ln_TimerCur_Case_IDNO
             AND b.IoDirection_CODE = @Lc_OutputDirection_TEXT
             AND b.IVDOutOfStateFips_CODE = @Lc_TimerCur_ActivityMinorNext_CODE
             AND b.Function_CODE = @Lc_FunctionManagestcases_CODE
             AND b.Action_CODE = @Lc_ActionProvide_CODE
             AND b.Reason_CODE IN (@Lc_ReasonGspud_CODE, @Lc_ReasonGsupd_CODE)
             AND (b.End_DATE) > (@Ld_TimerCur_End_DATE)
           ORDER BY b.End_DATE DESC;

          IF @Lc_Reason_CODE != @Lc_Space_TEXT
           BEGIN
            SET @Lc_ResetTimer_TEXT = @Lc_Yes_INDC;
            SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCax20_CODE;
            SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCox90_CODE;
           END;
         END;

        IF @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCox90_CODE
            OR @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCxr30_CODE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT CTHB_Y1 FOR TIMER COX90/CXR30';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', IoDirection_CODE = ' + ISNULL(@Lc_InputDirection_TEXT, '');

          SELECT TOP 1 @Lc_Reason_CODE = b.Reason_CODE
            FROM CTHB_Y1 b
           WHERE b.Case_IDNO = @Ln_TimerCur_Case_IDNO
             AND b.IoDirection_CODE = @Lc_InputDirection_TEXT
             AND (b.End_DATE) > (@Ld_TimerCur_Entered_DATE)
           ORDER BY b.End_DATE DESC;

          IF @Lc_Reason_CODE = @Lc_Space_TEXT
           BEGIN
            SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1 FOR TIMER COX90/CXR30';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

            SELECT TOP 1 @Lc_Case_IDNO = SUBSTRING(CAST(a.PayorMCI_IDNO AS VARCHAR), 1, 6)
              FROM RCTH_Y1 a
             WHERE a.PayorMCI_IDNO IN (SELECT MemberMci_IDNO
                                         FROM CMEM_Y1
                                        WHERE Case_IDNO = @Ln_TimerCur_Case_IDNO
                                          AND CaseRelationship_CODE IN ('A', 'P')
                                          AND CaseMemberStatus_CODE = 'A')
               AND a.SourceReceipt_CODE = 'F4'
               AND a.Receipt_DATE >= (@Ld_TimerCur_Entered_DATE)
               AND a.EndValidity_DATE = @Ld_High_DATE
             ORDER BY a.Receipt_DATE DESC;
           END;

          IF @Lc_Reason_CODE != @Lc_Space_TEXT
              OR @Lc_Case_IDNO != @Lc_Space_TEXT
           BEGIN
            SET @Lc_ResetTimer_TEXT = @Lc_Yes_INDC;

            IF @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCox90_CODE
             BEGIN
              SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCox90_CODE;
              SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCox90_CODE;
             END
            ELSE IF @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCxr30_CODE
             BEGIN
              SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCxr30_CODE;
              SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCox90_CODE;
             END
           END;
          ELSE IF (@Lc_Reason_CODE = @Lc_Space_TEXT
              AND @Lc_Case_IDNO = @Lc_Space_TEXT)
           BEGIN
            IF @Ld_TimerCur_Due_DATE <= @Ld_Run_DATE
             BEGIN
              SET @Lc_ResetTimer_TEXT = @Lc_Yes_INDC;

              IF @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCox90_CODE
               BEGIN
                SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCox90_CODE;
                SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCxr30_CODE;
                SET @Lc_PendingRequest_TEXT = @Lc_Yes_INDC;
                SET @Lc_Function_CODE = @Lc_FunctionManagestcases_CODE;
                SET @Lc_Action_CODE = @Lc_ActionRequest_CODE;
                SET @Lc_ReasonPend_CODE = @Lc_ReasonGrupd_CODE;
               END
              ELSE IF @Lc_TimerCur_ActivityMinor_CODE = @Lc_ActivityMinorCxr30_CODE
               BEGIN
                SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCxr30_CODE;
                SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCox90_CODE;
                SET @Lc_InsertInfo_TEXT = @Lc_Yes_INDC;
                SET @Lc_MinorActivityInfo_CODE = @Lc_ActivityMinorCxi30_CODE;
               END
             END;
           END;
         END;

        IF @Lc_PendingRequest_TEXT = @Lc_Yes_INDC
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST -' + ISNULL(@Lc_TimerCur_Function_CODE, '');
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_MemberMci_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Lc_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonPend_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext_CODE, '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(@Lc_TimerCur_IVDOutOfStateCountyFips_CODE, '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(@Lc_TimerCur_IVDOutOfStateOfficeFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_TimerCur_IVDOutOfStateCase_ID, '') + ', Generated_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Form_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', FormWeb_URL = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', CaseFormer_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsCarrier_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsPolicyNo_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Hearing_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Dismissal_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', GeneticTest_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', PfNoShow_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Attachment_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', ArrearComputed_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
           @An_Case_IDNO                    = @Ln_TimerCur_Case_IDNO,
           @An_RespondentMci_IDNO           = @Ln_TimerCur_MemberMci_IDNO,
           @Ac_Function_CODE                = @Lc_Function_CODE,
           @Ac_Action_CODE                  = @Lc_Action_CODE,
           @Ac_Reason_CODE                  = @Lc_ReasonPend_CODE,
           @Ac_IVDOutOfStateFips_CODE       = @Lc_TimerCur_ActivityMinorNext_CODE,
           @Ac_IVDOutOfStateCountyFips_CODE = @Lc_TimerCur_IVDOutOfStateCountyFips_CODE,
           @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_TimerCur_IVDOutOfStateOfficeFips_CODE,
           @Ac_IVDOutOfStateCase_ID         = @Lc_TimerCur_IVDOutOfStateCase_ID,
           @Ad_Generated_DATE               = @Ld_Run_DATE,
           @Ac_Form_ID                      = @Lc_Space_TEXT,
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
           @Ac_File_ID                      = @Ln_Zero_NUMB,
           @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
           @An_TotalArrearsOwed_AMNT        = @Ln_Zero_NUMB,
           @An_TotalInterestOwed_AMNT       = @Ln_Zero_NUMB,
           @Ac_Process_ID                   = @Lc_Job_ID,
           @Ad_BeginValidity_DATE           = @Ld_Start_DATE,
           @Ac_SignedonWorker_ID            = @Lc_BatchRunUser_TEXT,
           @Ad_Update_DTTM                  = @Ld_Start_DATE,
           @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;
         END;

        IF @Lc_InsertInfo_TEXT = @Lc_Yes_INDC
         BEGIN
          SET @Lc_Fips_CODE = @Lc_TimerCur_IVDOutOfStateFips_CODE + @Lc_TimerCur_IVDOutOfStateCountyFips_CODE + @Lc_TimerCur_IVDOutOfStateOfficeFips_CODE;
          SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS - ' + ISNULL(@Lc_TimerCur_Function_CODE, '') + ' - ' + ISNULL(@Lc_MinorActivityInfo_CODE, '');
          SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_TransHeader_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_MemberMci_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityInfo_CODE, '') + ', ActivityMinorOld_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Timer_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '');

          EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS
           @An_TransHeader_IDNO         = @Ln_TimerCur_TransHeader_IDNO,
           @An_Case_IDNO                = @Ln_TimerCur_Case_IDNO,
           @An_RespondentMci_IDNO       = @Ln_TimerCur_MemberMci_IDNO,
           @Ac_Fips_CODE                = @Lc_Fips_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivityInfo_CODE,
           @Ac_ActivityMinorOld_CODE    = @Lc_Space_TEXT,
           @An_TransactionEventSeq_NUMB = @Ln_Zero_NUMB,
           @Ac_Timer_INDC               = @Lc_No_INDC,
           @Ac_BatchRunUser_TEXT        = @Lc_BatchRunUser_TEXT,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @As_Process_NAME             = @Ls_Process_NAME,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;
         END
        --Defect 13623 Federal Timers batch error due to same timer being completed twice Fix
        IF @Lc_ResetTimer_TEXT = @Lc_Yes_INDC
         BEGIN
          SET @Lc_Fips_CODE = @Lc_TimerCur_IVDOutOfStateFips_CODE + @Lc_TimerCur_IVDOutOfStateCountyFips_CODE + @Lc_TimerCur_IVDOutOfStateOfficeFips_CODE;
          SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS -  ' + ISNULL(@Lc_TimerCur_Function_CODE, '') + ' - ' + ' - ' + ISNULL(@Lc_MinorActivity_CODE, '');
          SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_TransHeader_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_MemberMci_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivity_CODE, '') + ', ActivityMinorOld_CODE = ' + ISNULL(@Lc_MinorActivityOld_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TimerCur_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Timer_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '');

          EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS
           @An_TransHeader_IDNO         = @Ln_TimerCur_TransHeader_IDNO,
           @An_Case_IDNO                = @Ln_TimerCur_Case_IDNO,
           @An_RespondentMci_IDNO       = @Ln_TimerCur_MemberMci_IDNO,
           @An_MajorIntSeq_NUMB         = @Ln_TimerCur_MajorIntSeq_NUMB,
           @An_MinorIntSeq_NUMB         = @Ln_TimerCur_MinorIntSeq_NUMB,
           @Ac_Fips_CODE                = @Lc_Fips_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
           @Ac_ActivityMinorOld_CODE    = @Lc_MinorActivityOld_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TimerCur_TransactionEventSeq_NUMB,
           @Ac_Timer_INDC               = @Lc_Yes_INDC,
           @Ac_BatchRunUser_TEXT        = @Lc_BatchRunUser_TEXT,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @As_Process_NAME             = @Ls_Process_NAME,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;
         END;
       END;
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_TIMERS;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB != 50001
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

     IF @Ln_CommitFreq_QNTY != 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TIMERS';

       COMMIT TRANSACTION TIMERS;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TIMERS';

       BEGIN TRANSACTION TIMERS;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;

       COMMIT TRANSACTION TIMERS;

       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Timer_CUR - 2';

     FETCH NEXT FROM Timer_CUR INTO @Ln_TimerCur_Case_IDNO, @Ln_TimerCur_OrderSeq_NUMB, @Ln_TimerCur_OthpSource_IDNO, @Ln_TimerCur_MemberMci_IDNO, @Lc_TimerCur_ActivityMajor_CODE, @Lc_TimerCur_ActivityMinor_CODE, @Ln_TimerCur_MajorIntSeq_NUMB, @Ln_TimerCur_MinorIntSeq_NUMB, @Ln_TimerCur_Forum_IDNO, @Ld_TimerCur_Entered_DATE, @Ln_TimerCur_TransactionEventSeq_NUMB, @Lc_TimerCur_Reference_ID, @Lc_TimerCur_ActivityMinorNext_CODE, @Ld_TimerCur_End_DATE, @Ld_TimerCur_Due_DATE, @Lc_TimerCur_IVDOutOfStateCountyFips_CODE, @Lc_TimerCur_IVDOutOfStateOfficeFips_CODE, @Lc_TimerCur_IVDOutOfStateCase_ID, @Lc_TimerCur_Message_ID, @Ln_TimerCur_TransHeader_IDNO, @Lc_TimerCur_IVDOutOfStateFips_CODE, @Lc_TimerCur_Function_CODE, @Ld_TimerCur_Transaction_DATE, @Lc_TimerCur_Reason_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Timer_CUR') IN (0, 1)
    BEGIN
     CLOSE Timer_CUR;

     DEALLOCATE Timer_CUR;
    END

   --NEW REFERRAL CURSOR - Responding
   DECLARE ReferalIn_CUR INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.TransHeader_IDNO,
           a.Message_ID,
           a.Transaction_DATE,
           a.Function_CODE,
           a.End_DATE,
           a.Reason_CODE,
           b.RespondInit_CODE
      FROM CTHB_Y1 a,
           CASE_Y1 b
     WHERE a.IoDirection_CODE = @Lc_InputDirection_TEXT
       AND a.Case_IDNO = b.Case_IDNO
       AND a.Case_IDNO != 0
       AND a.TranStatus_CODE = @Lc_TranStatusSr_CODE
       AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
       AND b.RespondInit_CODE IN (@Lc_RespondingState_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
       AND a.Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
       AND a.Action_CODE = @Lc_ActionRequest_CODE
       AND a.Reason_CODE IN (SELECT b.Reason_CODE
                               FROM CFAR_Y1 b
                              WHERE a.Function_CODE = b.Function_CODE
                                AND a.Action_CODE = b.Action_CODE
                                AND b.RefAssist_CODE = @Lc_RefAssistReferal_CODE)
       AND a.Reason_CODE NOT IN (@Lc_ReasonSradj_CODE, @Lc_ReasonSrmod_CODE)
       AND a.Transaction_DATE = (SELECT MAX(c.Transaction_DATE)
                                   FROM CTHB_Y1 c
                                  WHERE c.Case_IDNO = a.Case_IDNO
                                    AND c.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE
                                    AND c.Function_CODE = a.Function_CODE
                                    AND c.Action_CODE = a.Action_CODE
                                    AND c.Reason_CODE = a.Reason_CODE
                                    AND c.IoDirection_CODE = @Lc_InputDirection_TEXT
                                    AND EXISTS (SELECT 1
                                                  FROM CTHB_Y1 d
                                                 WHERE d.Case_IDNO = a.Case_IDNO
                                                   AND d.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE
                                                   AND d.Function_CODE = a.Function_CODE
                                                   AND d.Action_CODE = @Lc_ActionAcknowledgment_CODE
                                                   AND d.Reason_CODE IN (@Lc_ReasonAadin_CODE, @Lc_ReasonAnoad_CODE)
                                                   AND d.IoDirection_CODE = @Lc_OutputDirection_TEXT
                                                   AND (d.End_DATE) BETWEEN (DATEADD(D, 1, @Ld_LastRun_DATE)) AND @Ld_Run_DATE
                                                   AND (c.End_DATE) < (d.End_DATE)))
       AND EXISTS (SELECT 1
                     FROM CTHB_Y1 b
                    WHERE a.Case_IDNO = b.Case_IDNO
                      AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                      AND a.Function_CODE = b.Function_CODE
                      AND b.Action_CODE = @Lc_ActionAcknowledgment_CODE
                      AND b.Reason_CODE IN (@Lc_ReasonAadin_CODE, @Lc_ReasonAnoad_CODE)
                      AND b.IoDirection_CODE = @Lc_OutputDirection_TEXT
                      AND (b.End_DATE) BETWEEN (DATEADD(D, 1, @Ld_LastRun_DATE)) AND @Ld_Run_DATE
                      AND (a.End_DATE) < (b.End_DATE))
    UNION ALL
    SELECT a.Case_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.TransHeader_IDNO,
           a.Message_ID,
           a.Transaction_DATE,
           a.Function_CODE,
           a.End_DATE,
           a.Reason_CODE,
           b.RespondInit_CODE
      FROM CTHB_Y1 a,
           CASE_Y1 b
     WHERE a.IoDirection_CODE = @Lc_InputDirection_TEXT
       AND a.Case_IDNO = b.Case_IDNO
       AND a.Case_IDNO != 0
       AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
       AND b.RespondInit_CODE IN (@Lc_RespondingState_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
       AND a.Function_CODE = @Lc_FunctionEstablishment_CODE
       AND a.Action_CODE = @Lc_ActionRequest_CODE
       AND a.Reason_CODE IN (@Lc_ReasonSradj_CODE, @Lc_ReasonSrmod_CODE)
       AND (a.End_DATE) BETWEEN (DATEADD(D, 1, @Ld_LastRun_DATE)) AND @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'OPEN ReferalIn_CUR';

   OPEN ReferalIn_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ReferalIn_CUR - 1';

   FETCH NEXT FROM ReferalIn_CUR INTO @Lc_ReferalInCur_Case_IDNO, @Lc_ReferalInCur_IVDOutOfStateFips_CODE, @Lc_ReferalInCur_IVDOutOfStateCountyFips_CODE, @Lc_ReferalInCur_IVDOutOfStateOfficeFips_CODE, @Ln_ReferalInCur_TransHeader_IDNO, @Lc_ReferalInCur_Message_ID, @Ld_ReferalInCur_Transaction_DATE, @Lc_ReferalInCur_Function_CODE, @Ld_ReferalInCur_End_DATE, @Lc_ReferalInCur_Reason_CODE, @Lc_ReferalInCur_RespondInit_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Referral cursor 
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_TIMERS;

      SET @Ln_CommitFreq_QNTY += 1;
      SET @Ln_RecordCount_QNTY += 1;
      SET @Ln_ProcessedRecordCount_QNTY += 1;
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_CursorLocation_TEXT = 'ReferalIn_CUR - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ln_Topic_IDNO = 0;
      SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS - 3';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_ReferalInCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_ReferalInCur_Transaction_DATE AS VARCHAR), '') + ', Message_ID = ' + ISNULL(@Lc_ReferalInCur_Message_ID, '') + ', Case_IDNO = ' + ISNULL(@Lc_ReferalInCur_Case_IDNO, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_ReferalInCur_IVDOutOfStateFips_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_ReferalInCur_Function_CODE, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_ReferalInCur_RespondInit_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

      EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS
       @An_TransHeader_IDNO       = @Ln_ReferalInCur_TransHeader_IDNO,
       @Ad_Transaction_DATE       = @Ld_ReferalInCur_Transaction_DATE,
       @Ac_Message_ID             = @Lc_ReferalInCur_Message_ID,
       @An_Case_IDNO              = @Lc_ReferalInCur_Case_IDNO,
       @Ac_IVDOutOfStateFips_CODE = @Lc_ReferalInCur_IVDOutOfStateFips_CODE,
       @Ac_Function_CODE          = @Lc_ReferalInCur_Function_CODE,
       @Ac_RespondInit_CODE       = @Lc_ReferalInCur_RespondInit_CODE,
       @Ad_Run_DATE               = @Ld_Run_DATE,
       @Ac_Job_ID                 = @Lc_Job_ID,
       @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR(50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'SELCT Reason_CODE FROM CTHB_Y1 FOR RESPONDING - ' + ISNULL(@Lc_ReferalInCur_Function_CODE, '');
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_ReferalInCur_Case_IDNO, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_ReferalInCur_IVDOutOfStateFips_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_ReferalInCur_Function_CODE, '') + ', IoDirection_CODE = ' + ISNULL(@Lc_OutputDirection_TEXT, '');

      SELECT TOP 1 @Lc_Reason_CODE = a.Reason_CODE
        FROM CTHB_Y1 a
       WHERE a.Case_IDNO = @Lc_ReferalInCur_Case_IDNO
         AND a.IVDOutOfStateFips_CODE = @Lc_ReferalInCur_IVDOutOfStateFips_CODE
         AND a.Function_CODE = @Lc_ReferalInCur_Function_CODE
         AND a.IoDirection_CODE = @Lc_OutputDirection_TEXT
         AND a.Reason_CODE IN (@Lc_ReasonAadin_CODE, @Lc_ReasonAnoad_CODE)
         AND (a.End_DATE) > @Ld_ReferalInCur_End_DATE
         AND (a.End_DATE) BETWEEN (DATEADD(D, 1, @Ld_LastRun_DATE)) AND @Ld_Run_DATE
       ORDER BY a.End_DATE DESC;

      IF @Lc_Reason_CODE = @Lc_ReasonAadin_CODE
       BEGIN
        IF @Lc_ReferalInCur_Function_CODE = @Lc_FunctionEnforcement_CODE
         BEGIN
          SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCin30_CODE;
         END;
        ELSE IF @Lc_ReferalInCur_Function_CODE = @Lc_FunctionEstablishment_CODE
         BEGIN
          SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCis30_CODE;
         END;
        ELSE IF @Lc_ReferalInCur_Function_CODE = @Lc_FunctionPaternity_CODE
         BEGIN
          SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCip30_CODE;
         END;
       END;
      ELSE IF @Lc_Reason_CODE = @Lc_ReasonAnoad_CODE
       BEGIN
        IF @Lc_ReferalInCur_Function_CODE = @Lc_FunctionEnforcement_CODE
         BEGIN
          SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCin90_CODE;
         END;
        ELSE IF @Lc_ReferalInCur_Function_CODE = @Lc_FunctionEstablishment_CODE
         BEGIN
          SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCis90_CODE;
         END;
        ELSE IF @Lc_ReferalInCur_Function_CODE = @Lc_FunctionPaternity_CODE
         BEGIN
          SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCip90_CODE;
         END;
       END;

      SET @Lc_Fips_CODE = @Lc_ReferalInCur_IVDOutOfStateFips_CODE + @Lc_ReferalInCur_IVDOutOfStateCountyFips_CODE + @Lc_ReferalInCur_IVDOutOfStateOfficeFips_CODE;
      SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS - RESPONDING ' + @Lc_ReferalInCur_Function_CODE + ' - ' + @Lc_MinorActivity_CODE;
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_ReferalInCur_TransHeader_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(@Lc_ReferalInCur_Case_IDNO, '') + ', RespondentMci_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivity_CODE, '') + ', ActivityMinorOld_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Timer_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '');

      EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS
       @An_TransHeader_IDNO         = @Ln_ReferalInCur_TransHeader_IDNO,
       @An_Case_IDNO                = @Lc_ReferalInCur_Case_IDNO,
       @An_RespondentMci_IDNO       = @Ln_Zero_NUMB,
       @Ac_Fips_CODE                = @Lc_Fips_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
       @Ac_ActivityMinorOld_CODE    = @Lc_Space_TEXT,
       @An_TransactionEventSeq_NUMB = @Ln_Zero_NUMB,
       @Ac_Timer_INDC               = @Lc_Yes_INDC,
       @Ac_BatchRunUser_TEXT        = @Lc_BatchRunUser_TEXT,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @As_Process_NAME             = @Ls_Process_NAME,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR(50001,16,1);
       END;
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_TIMERS;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB != 50001
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

     IF @Ln_CommitFreq_QNTY != 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TIMERS';

       COMMIT TRANSACTION TIMERS;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TIMERS';

       BEGIN TRANSACTION TIMERS;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;

       COMMIT TRANSACTION TIMERS;

       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ReferalIn_CUR - 2';

     FETCH NEXT FROM ReferalIn_CUR INTO @Lc_ReferalInCur_Case_IDNO, @Lc_ReferalInCur_IVDOutOfStateFips_CODE, @Lc_ReferalInCur_IVDOutOfStateCountyFips_CODE, @Lc_ReferalInCur_IVDOutOfStateOfficeFips_CODE, @Ln_ReferalInCur_TransHeader_IDNO, @Lc_ReferalInCur_Message_ID, @Ld_ReferalInCur_Transaction_DATE, @Lc_ReferalInCur_Function_CODE, @Ld_ReferalInCur_End_DATE, @Lc_ReferalInCur_Reason_CODE, @Lc_ReferalInCur_RespondInit_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   SET @Ls_Sql_TEXT = 'CLOSE ReferalIn_CUR';

   IF CURSOR_STATUS('LOCAL', 'ReferalIn_CUR') IN (0, 1)
    BEGIN
     CLOSE ReferalIn_CUR;

     DEALLOCATE ReferalIn_CUR;
    END;

   DECLARE Timer_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           j.Case_IDNO,
           j.OrderSeq_NUMB,
           j.OthpSource_IDNO,
           n.MemberMci_IDNO,
           j.ActivityMajor_CODE,
           n.ActivityMinor_CODE,
           j.MajorIntSEQ_NUMB,
           n.MinorIntSeq_NUMB,
           j.Forum_IDNO,
           n.Entered_DATE,
           j.TransactionEventSeq_NUMB,
           j.Reference_ID,
           n.ActivityMinorNext_CODE,
           c.End_DATE,
           n.Due_DATE,
           c.IVDOutOfStateCountyFips_CODE,
           c.IVDOutOfStateOfficeFips_CODE,
           c.IVDOutOfStateCase_ID,
           c.Message_ID,
           c.TransHeader_IDNO,
           c.IVDOutOfStateFips_CODE,
           c.Transaction_DATE,
           c.Function_CODE,
           c.Action_CODE,
           c.Reason_CODE
      FROM DMNR_Y1 n,
           DMJR_Y1 j,
           CTHB_Y1 c
     WHERE j.Status_CODE = @Lc_RemedyStatusStart_CODE
       AND j.Status_DATE = @Ld_High_DATE
       AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
       AND n.Status_DATE = @Ld_High_DATE
       AND j.Case_IDNO = n.Case_IDNO
       AND j.OrderSeq_NUMB = n.OrderSeq_NUMB
       AND j.MajorIntSEQ_NUMB = n.MajorIntSEQ_NUMB
       AND CAST(n.Topic_IDNO AS NUMERIC(10, 0)) = c.Transaction_IDNO
       AND n.Entered_DATE < @Ld_Run_DATE
       AND n.ActivityMinor_CODE IN (@Lc_ActivityMinorCin30_CODE, @Lc_ActivityMinorCis30_CODE, @Lc_ActivityMinorCip30_CODE, @Lc_ActivityMinorCin90_CODE,
                                    @Lc_ActivityMinorCis90_CODE, @Lc_ActivityMinorCip90_CODE, @Lc_ActivityMinorCn090_CODE, @Lc_ActivityMinorCs090_CODE,
                                    @Lc_ActivityMinorCp090_CODE, @Lc_ActivityMinorCn180_CODE, @Lc_ActivityMinorCs180_CODE, @Lc_ActivityMinorCp180_CODE)
       AND n.ActivityMinorNext_CODE = c.IVDOutOfStateFips_CODE
       AND n.Case_IDNO = c.Case_IDNO
       AND (c.End_DATE) < @Ld_Run_DATE
       AND c.Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
       AND c.Action_CODE = @Lc_ActionRequest_CODE
       AND c.IoDirection_CODE = @Lc_InputDirection_TEXT
       AND c.Reason_CODE IN (SELECT b.Reason_CODE
                               FROM CFAR_Y1 b
                              WHERE c.Function_CODE = b.Function_CODE
                                AND c.Action_CODE = b.Action_CODE
                                AND b.RefAssist_CODE = @Lc_RefAssistReferal_CODE);

   SET @Ls_Sql_TEXT = 'OPEN Timer_CUR';

   OPEN Timer_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Timer_CUR - 1';

   FETCH NEXT FROM Timer_CUR INTO @Ln_TimerCur_Case2_IDNO, @Ln_TimerCur_OrderSeq2_NUMB, @Lc_TimerCur_OthpSource2_IDNO, @Lc_TimerCur_MemberMci2_IDNO, @Lc_TimerCur_ActivityMajor2_CODE, @Lc_TimerCur_ActivityMinor2_CODE, @Ln_TimerCur_MajorIntSeq2_NUMB, @Ln_TimerCur_MinorIntSeq2_NUMB, @Ln_TimerCur_Forum2_IDNO, @Ld_TimerCur_Entered2_DATE, @Ln_TimerCur_TransactionEventSeq2_NUMB, @Lc_TimerCur_Reference2_IDNO, @Lc_TimerCur_ActivityMinorNext2_CODE, @Ld_TimerCur_End2_DATE, @Ld_TimerCur_Due2_DATE, @Lc_TimerCur_IVDOutOfStateCountyFips2_CODE, @Lc_TimerCur_IVDOutOfStateOfficeFips2_CODE, @Lc_TimerCur_IVDOutOfStateCase2_IDNO, @Lc_TimerCur_Message2_IDNO, @Lc_TimerCur_TransHeader2_IDNO, @Lc_TimerCur_IVDOutOfStateFips2_CODE, @Ld_TimerCur_Transaction2_DATE, @Lc_TimerCur_Function2_CODE, @Lc_TimerCur_Action_CODE, @Lc_TimerCur_Reason2_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Assist cursor
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVE_PROCESS_TIMERS;

      SET @Ln_CommitFreq_QNTY += 1;
      SET @Ln_RecordCount_QNTY += 1;
      SET @Ln_ProcessedRecordCount_QNTY += 1;
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_CursorLocation_TEXT = 'Timer_CUR - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Lc_CaseClosed_TEXT = @Lc_No_INDC;
      SET @Lc_ReferralCancelled_TEXT = @Lc_No_INDC;
      SET @Lc_PendingRequest_TEXT = @Lc_No_INDC;
      SET @Lc_ResetTimer_TEXT = @Lc_No_INDC;
      SET @Lc_InsertTimer_TEXT = @Lc_No_INDC;
      SET @Lc_InsertInfo_TEXT = @Lc_No_INDC;
      SET @Lc_ReasonPend_CODE = @Lc_Space_TEXT;
      SET @Lc_Function_CODE = @Lc_Space_TEXT;
      SET @Lc_Action_CODE = @Lc_Space_TEXT;
      SET @Lc_Case_IDNO = @Lc_Space_TEXT;
      SET @Lc_ActivityMinorCix30_CODE = 'CIX30';
      SET @Lc_ActivityMinorCix90_CODE = 'CIX90';
      SET @Lc_ActivityMinorCx090_CODE = 'CX090';
      SET @Lc_ActivityMinorCx180_CODE = 'CX180';
      SET @Lc_ActivityMinorSx180_CODE = 'SX180';
      SET @Lc_ActivityMinorCx091_CODE = 'CX091';
      SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 OR ICAS_Y1 FOR RESPONDING - ' + ISNULL(@Lc_TimerCur_Function2_CODE, '');
      SET @Ls_Sqldata_TEXT = '';

      SELECT TOP (1) @Lc_CaseClosed_TEXT = CASE z.Status_CODE
                                            WHEN @Lc_CaseStatusClosed_CODE
                                             THEN @Lc_Yes_INDC
                                            ELSE @Lc_No_INDC
                                           END
        FROM (SELECT ISNULL(a.StatusCase_CODE, @Lc_CaseStatusClosed_CODE) AS Status_CODE
                FROM CASE_Y1 a
               WHERE a.Case_IDNO = @Ln_TimerCur_Case2_IDNO
              UNION ALL
              SELECT TOP 1 @Lc_CaseStatusClosed_CODE AS Status_CODE
                FROM ICAS_Y1 b
               WHERE b.Case_IDNO = @Ln_TimerCur_Case2_IDNO
                 AND b.EndValidity_DATE = @Ld_High_DATE
                 AND NOT EXISTS (SELECT 1
                                   FROM ICAS_Y1 c
                                  WHERE c.Case_IDNO = @Ln_TimerCur_Case2_IDNO
                                    AND c.Status_CODE = @Lc_CaseStatusOpen_CODE
                                    AND c.EndValidity_DATE = @Ld_High_DATE)) z
       ORDER BY Status_CODE ASC;

      IF (@Lc_CaseClosed_TEXT = @Lc_Yes_INDC
           OR EXISTS (SELECT 1
                        FROM CASE_Y1 c
                       WHERE c.Case_IDNO = @Ln_TimerCur_Case2_IDNO
                         AND c.RespondInit_CODE = 'N'))
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS - CASE CLOSED';
        SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(@Lc_TimerCur_TransHeader2_IDNO, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_TimerCur_Transaction2_DATE AS VARCHAR), '') + ', Message_ID = ' + ISNULL(@Lc_TimerCur_Message2_IDNO, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case2_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext2_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_TimerCur_Function2_CODE, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_RespondingState_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

        EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS
         @An_TransHeader_IDNO       = @Lc_TimerCur_TransHeader2_IDNO,
         @Ad_Transaction_DATE       = @Ld_TimerCur_Transaction2_DATE,
         @Ac_Message_ID             = @Lc_TimerCur_Message2_IDNO,
         @An_Case_IDNO              = @Ln_TimerCur_Case2_IDNO,
         @Ac_IVDOutOfStateFips_CODE = @Lc_TimerCur_ActivityMinorNext2_CODE,
         @Ac_Function_CODE          = @Lc_TimerCur_Function2_CODE,
         @Ac_RespondInit_CODE       = @Lc_RespondingState_CODE,
         @Ad_Run_DATE               = @Ld_Run_DATE,
         @Ac_Job_ID                 = @Lc_Job_ID,
         @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;
       END;
      ELSE
       BEGIN
        IF @Lc_TimerCur_Function2_CODE = @Lc_FunctionEnforcement_CODE
         BEGIN
          SET @Lc_ActivityMinorCix30_CODE = REPLACE(@Lc_ActivityMinorCix30_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCix90_CODE = REPLACE(@Lc_ActivityMinorCix90_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCx090_CODE = REPLACE(@Lc_ActivityMinorCx090_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCx180_CODE = REPLACE(@Lc_ActivityMinorCx180_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorSx180_CODE = REPLACE(@Lc_ActivityMinorSx180_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
          SET @Lc_ActivityMinorCx091_CODE = REPLACE(@Lc_ActivityMinorCx091_CODE, 'X', @Lc_ActivityMinorEnforcement_CODE);
         END;
        ELSE IF @Lc_TimerCur_Function2_CODE = @Lc_FunctionEstablishment_CODE
         BEGIN
          SET @Lc_ActivityMinorCix30_CODE = REPLACE(@Lc_ActivityMinorCix30_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCix90_CODE = REPLACE(@Lc_ActivityMinorCix90_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCx090_CODE = REPLACE(@Lc_ActivityMinorCx090_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCx180_CODE = REPLACE(@Lc_ActivityMinorCx180_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorSx180_CODE = REPLACE(@Lc_ActivityMinorSx180_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
          SET @Lc_ActivityMinorCx091_CODE = REPLACE(@Lc_ActivityMinorCx091_CODE, 'X', @Lc_ActivityMinorEstablishment_CODE);
         END;
        ELSE IF @Lc_TimerCur_Function2_CODE = @Lc_FunctionPaternity_CODE
         BEGIN
          SET @Lc_ActivityMinorCix30_CODE = REPLACE(@Lc_ActivityMinorCix30_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCix90_CODE = REPLACE(@Lc_ActivityMinorCix90_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCx090_CODE = REPLACE(@Lc_ActivityMinorCx090_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCx180_CODE = REPLACE(@Lc_ActivityMinorCx180_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorSx180_CODE = REPLACE(@Lc_ActivityMinorSx180_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
          SET @Lc_ActivityMinorCx091_CODE = REPLACE(@Lc_ActivityMinorCx091_CODE, 'X', @Lc_ActivityMinorPaternity_CODE);
         END;

        IF @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCix30_CODE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT CAIN_Y1 FOR ATTACHMENT :' + ISNULL(@Lc_TimerCur_ActivityMinor2_CODE, '');
          SET @Lc_Attachment_INDC = @Lc_Yes_INDC;
          SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(@Lc_TimerCur_TransHeader2_IDNO, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_IVDOutOfStateFips2_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_TimerCur_Transaction2_DATE AS VARCHAR), '') + ', Received_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

          SELECT TOP 1 @Lc_Attachment_INDC = ISNULL(a.Received_INDC, @Lc_Yes_INDC)
            FROM CAIN_Y1 a
           WHERE a.TransHeader_IDNO = @Lc_TimerCur_TransHeader2_IDNO
             AND a.IVDOutOfStateFips_CODE = @Lc_TimerCur_IVDOutOfStateFips2_CODE
             AND a.Transaction_DATE = @Ld_TimerCur_Transaction2_DATE
             AND a.Received_INDC = @Lc_No_INDC
             AND a.EndValidity_DATE = @Ld_High_DATE;

          IF (@Lc_Attachment_INDC != @Lc_Yes_INDC
              AND @Ld_TimerCur_Due2_DATE <= @Ld_Run_DATE)
              OR @Lc_Attachment_INDC = @Lc_Yes_INDC
           BEGIN
            SET @Lc_ResetTimer_TEXT = @Lc_Yes_INDC;
            SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCix30_CODE;
            SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCix90_CODE;
           END;
         END;

        IF (@Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCix90_CODE
             OR @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCx090_CODE
             OR @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCx180_CODE)
         BEGIN
          IF ((@Ld_TimerCur_Due2_DATE <= @Ld_Run_DATE
               AND (@Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCix90_CODE
                     OR @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCx090_CODE))
               OR @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCx180_CODE)
             AND EXISTS (SELECT 1
                           FROM SORD_Y1 b
                          WHERE b.Case_IDNO = @Ln_TimerCur_Case2_IDNO
                            AND @Ld_Run_DATE BETWEEN b.OrderEffective_DATE AND b.OrderEnd_DATE
                            AND b.EndValidity_DATE = @Ld_High_DATE)
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS - CASE CLOSED';
            SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(@Lc_TimerCur_TransHeader2_IDNO, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_TimerCur_Transaction2_DATE AS VARCHAR), '') + ', Message_ID = ' + ISNULL(@Lc_TimerCur_Message2_IDNO, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case2_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TimerCur_ActivityMinorNext2_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_TimerCur_Function2_CODE, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_RespondingState_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

            EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS
             @An_TransHeader_IDNO       = @Lc_TimerCur_TransHeader2_IDNO,
             @Ad_Transaction_DATE       = @Ld_TimerCur_Transaction2_DATE,
             @Ac_Message_ID             = @Lc_TimerCur_Message2_IDNO,
             @An_Case_IDNO              = @Ln_TimerCur_Case2_IDNO,
             @Ac_IVDOutOfStateFips_CODE = @Lc_TimerCur_ActivityMinorNext2_CODE,
             @Ac_Function_CODE          = @Lc_TimerCur_Function2_CODE,
             @Ac_RespondInit_CODE       = @Lc_RespondingState_CODE,
             @Ad_Run_DATE               = @Ld_Run_DATE,
             @Ac_Job_ID                 = @Lc_Job_ID,
             @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

              RAISERROR(50001,16,1);
             END;
           END
          ELSE IF (@Ld_TimerCur_Due2_DATE <= @Ld_Run_DATE
              AND (@Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCix90_CODE
                    OR @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCx090_CODE))
           BEGIN
            SET @Lc_ResetTimer_TEXT = @Lc_Yes_INDC;

            IF @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCix90_CODE
             BEGIN
              SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCix90_CODE;
              SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCx090_CODE;
              SET @Lc_InsertInfo_TEXT = @Lc_Yes_INDC;
              SET @Lc_MinorActivityInfo_CODE = @Lc_ActivityMinorCx091_CODE;
             END

            IF @Lc_TimerCur_ActivityMinor2_CODE = @Lc_ActivityMinorCx090_CODE
             BEGIN
              SET @Lc_MinorActivityOld_CODE = @Lc_ActivityMinorCx090_CODE;
              SET @Lc_MinorActivity_CODE = @Lc_ActivityMinorCx180_CODE;
              SET @Lc_InsertInfo_TEXT = @Lc_Yes_INDC;
              SET @Lc_MinorActivityInfo_CODE = @Lc_ActivityMinorSx180_CODE;
             END
           END;
         END;

        IF @Lc_InsertInfo_TEXT = @Lc_Yes_INDC
         BEGIN
          SET @Lc_Fips_CODE = @Lc_TimerCur_IVDOutOfStateFips2_CODE + @Lc_TimerCur_IVDOutOfStateCountyFips2_CODE + @Lc_TimerCur_IVDOutOfStateOfficeFips2_CODE;
          SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS - ENF - ' + ISNULL(@Lc_MinorActivityInfo_CODE, '');
          SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(@Lc_TimerCur_TransHeader2_IDNO, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case2_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Lc_TimerCur_MemberMci2_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityInfo_CODE, '') + ', ActivityMinorOld_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Timer_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '');

          EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS
           @An_TransHeader_IDNO         = @Lc_TimerCur_TransHeader2_IDNO,
           @An_Case_IDNO                = @Ln_TimerCur_Case2_IDNO,
           @An_RespondentMci_IDNO       = @Lc_TimerCur_MemberMci2_IDNO,
           @Ac_Fips_CODE                = @Lc_Fips_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivityInfo_CODE,
           @Ac_ActivityMinorOld_CODE    = @Lc_Space_TEXT,
           @An_TransactionEventSeq_NUMB = 0,
           @Ac_Timer_INDC               = @Lc_No_INDC,
           @Ac_BatchRunUser_TEXT        = @Lc_BatchRunUser_TEXT,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @As_Process_NAME             = @Ls_Process_NAME,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;
         END;

        IF @Lc_ResetTimer_TEXT = @Lc_Yes_INDC
         BEGIN
          SET @Lc_Fips_CODE = @Lc_TimerCur_IVDOutOfStateFips2_CODE + @Lc_TimerCur_IVDOutOfStateCountyFips2_CODE + @Lc_TimerCur_IVDOutOfStateOfficeFips2_CODE;
          SET @Ls_Sql_TEXT = 'BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS - ENF - ' + ISNULL(@Lc_MinorActivity_CODE, '');
          SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(@Lc_TimerCur_TransHeader2_IDNO, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TimerCur_Case2_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Lc_TimerCur_MemberMci2_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivity_CODE, '') + ', ActivityMinorOld_CODE = ' + ISNULL(@Lc_MinorActivityOld_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TimerCur_TransactionEventSeq2_NUMB AS VARCHAR), '') + ', Timer_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '');

          EXECUTE BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS
           @An_TransHeader_IDNO         = @Lc_TimerCur_TransHeader2_IDNO,
           @An_Case_IDNO                = @Ln_TimerCur_Case2_IDNO,
           @An_RespondentMci_IDNO       = @Lc_TimerCur_MemberMci2_IDNO,
           @An_MajorIntSeq_NUMB         = @Ln_TimerCur_MajorIntSeq2_NUMB,
           @An_MinorIntSeq_NUMB         = @Ln_TimerCur_MinorIntSeq2_NUMB,
           @Ac_Fips_CODE                = @Lc_Fips_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
           @Ac_ActivityMinorOld_CODE    = @Lc_MinorActivityOld_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TimerCur_TransactionEventSeq2_NUMB,
           @Ac_Timer_INDC               = @Lc_Yes_INDC,
           @Ac_BatchRunUser_TEXT        = @Lc_BatchRunUser_TEXT,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @As_Process_NAME             = @Ls_Process_NAME,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;
         END;
       END;
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PROCESS_TIMERS;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB != 50001
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

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH;

     IF @Ln_CommitFreq_QNTY != 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TIMERS';

       COMMIT TRANSACTION TIMERS;

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TIMERS';

       BEGIN TRANSACTION TIMERS;

       SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;

       COMMIT TRANSACTION TIMERS;

       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Timer_CUR - 2';

     FETCH NEXT FROM Timer_CUR INTO @Ln_TimerCur_Case2_IDNO, @Ln_TimerCur_OrderSeq2_NUMB, @Lc_TimerCur_OthpSource2_IDNO, @Lc_TimerCur_MemberMci2_IDNO, @Lc_TimerCur_ActivityMajor2_CODE, @Lc_TimerCur_ActivityMinor2_CODE, @Ln_TimerCur_MajorIntSeq2_NUMB, @Ln_TimerCur_MinorIntSeq2_NUMB, @Ln_TimerCur_Forum2_IDNO, @Ld_TimerCur_Entered2_DATE, @Ln_TimerCur_TransactionEventSeq2_NUMB, @Lc_TimerCur_Reference2_IDNO, @Lc_TimerCur_ActivityMinorNext2_CODE, @Ld_TimerCur_End2_DATE, @Ld_TimerCur_Due2_DATE, @Lc_TimerCur_IVDOutOfStateCountyFips2_CODE, @Lc_TimerCur_IVDOutOfStateOfficeFips2_CODE, @Lc_TimerCur_IVDOutOfStateCase2_IDNO, @Lc_TimerCur_Message2_IDNO, @Lc_TimerCur_TransHeader2_IDNO, @Lc_TimerCur_IVDOutOfStateFips2_CODE, @Ld_TimerCur_Transaction2_DATE, @Lc_TimerCur_Function2_CODE, @Lc_TimerCur_Action_CODE, @Lc_TimerCur_Reason2_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   SET @Ls_Sql_TEXT = 'CLOSE Timer_CUR';

   IF CURSOR_STATUS('LOCAL', 'Timer_CUR') IN (0, 1)
    BEGIN
     CLOSE Timer_CUR;

     DEALLOCATE Timer_CUR;
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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TIMERS';

   COMMIT TRANSACTION TIMERS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TIMERS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Timer_CUR') IN (0, 1)
    BEGIN
     CLOSE Timer_CUR;

     DEALLOCATE Timer_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'ReferalIn_CUR') IN (0, 1)
    BEGIN
     CLOSE ReferalIn_CUR;

     DEALLOCATE ReferalIn_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'ReferalOut_CUR') IN (0, 1)
    BEGIN
     CLOSE ReferalOut_CUR;

     DEALLOCATE ReferalOut_CUR;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB != 50001
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
