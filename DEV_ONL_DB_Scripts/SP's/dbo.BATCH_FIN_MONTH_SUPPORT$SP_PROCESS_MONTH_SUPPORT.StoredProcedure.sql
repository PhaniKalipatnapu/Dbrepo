/****** Object:  StoredProcedure [dbo].[BATCH_FIN_MONTH_SUPPORT$SP_PROCESS_MONTH_SUPPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_MONTH_SUPPORT$SP_PROCESS_MONTH_SUPPORT

Programmer Name 	: IMP Team

Description			: This procedure calculates the MSO amount for the entire next month,
					  to be available on the first day of the month (next day).In addition,
					  this procedure carries forward the end of month arrears balances to
					  the next month for cases with end-dated obligations having non-zero
					  arrears as well as for all current cycling cases.

Frequency			: 'MONTHLY'

Developed On		: 11/29/2011

Called BY			: None

Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_MONTH_SUPPORT$SP_PROCESS_MONTH_SUPPORT]
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE @Ln_DateAcclExpt7_NUMB          NUMERIC (1) = 7,
           @Ln_DateAcclExpt3_NUMB          NUMERIC (1) = 3,
           @Ln_DateAcclExpt14_NUMB         NUMERIC (2) = 14,
           @Ln_DateAcclExpt16_NUMB         NUMERIC (2) = 16,
           @Ln_DateAcclExpt15_NUMB         NUMERIC (2) = 15,
           @Ln_DateAcclExpt12_NUMB         NUMERIC (2) = 12,
           @Li_MonthSupport1060_NUMB       INT = 1060,
           @Lc_CaseStatusClosed_CODE       CHAR (1) = 'C',
           @Lc_StatusFailed_CODE           CHAR (1) = 'F',
           @Lc_No_INDC                     CHAR (1) = 'N',
           @Lc_TypeWelfareNonIvd_CODE      CHAR (1) = 'H',
           @Lc_TypeWelfareNonTanf_CODE     CHAR (1) = 'N',
           @Lc_TypeOrderVoluntary_CODE     CHAR (1) = 'V',
           @Lc_Onetime_CODE                CHAR (1) = 'O',
           @Lc_Weekly_CODE                 CHAR (1) = 'W',
           @Lc_Biweekly_CODE               CHAR (1) = 'B',
           @Lc_Semimonthly_CODE            CHAR (1) = 'S',
           @Lc_Quarterly_CODE              CHAR (1) = 'Q',
           @Lc_Monthly_CODE                CHAR (1) = 'M',
           @Lc_Annual_CODE                 CHAR (1) = 'A',
           @Lc_Yes_INDC                    CHAR (1) = 'Y',
           @Lc_Space_TEXT                  CHAR (1) = ' ',
           @Lc_StatusSuccess_CODE          CHAR (1) = 'S',
           @Lc_StatusAbnormalend_CODE      CHAR (1) = 'A',
           @Lc_TypeErrorE_CODE             CHAR (1) = 'E',
           @Lc_DateAcclExpt16_NUMB         CHAR (2) = '16',
           @Lc_DateAcclExpt31_NUMB         CHAR (2) = '31',
           @Lc_DateAcclExpt02_NUMB         CHAR (2) = '2',
           @Lc_DateAcclExpt14_NUMB         CHAR (2) = '14',
           @Lc_DateAcclExpt15_NUMB         CHAR (2) = '15',
           @Lc_BateErrorE1424_CODE         CHAR (5) = 'E1424',
           @Lc_Job_ID                      CHAR (7) = 'DEB6300',
           @Lc_JobAccrual_ID               CHAR (7) = 'DEB0530',
           @Lc_Successful_TEXT             CHAR (20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT           CHAR (30) = 'BATCH',
           @Ls_Process_NAME                VARCHAR (100) = 'BATCH_FIN_MONTH_SUPPORT',
           @Ls_Procedure_NAME              VARCHAR (100) = 'SP_PROCESS_MONTH_SUPPORT',
           @Ld_High_DATE                   DATE = '12/31/9999',
           @Ld_Low_DATE                    DATE = '01/01/0001',
           @Ld_Create_DATE                 DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_Commit_QNTY                      NUMERIC (5) = 0,
           @Ln_CommitFreqParm_QNTY              NUMERIC (5),
           @Ln_ExceptionThresholdParm_QNTY      NUMERIC (5),
           @Ln_CommitFreq_QNTY                  NUMERIC (5),
           @Ln_ExceptionThreshold_QNTY          NUMERIC (5),
           @Ln_ExcpThreshold_QNTY               NUMERIC (5) = 0,
           @Ln_SupportYearMonth_NUMB            NUMERIC (6),
           @Ln_SupportYearPrevMonth_NUMB        NUMERIC (6),
           @Ln_ProcessedRecordCount_QNTY        NUMERIC (6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY  NUMERIC (6) = 0,
           @Ln_Cursor_QNTY                      NUMERIC (9) = 0,
           @Ln_FutureObligation_QNTY            NUMERIC (9) = 0,
           @Ln_Error_NUMB                       NUMERIC (11),
           @Ln_ErrorLine_NUMB                   NUMERIC (11),
           @Ln_TransactionExptPay_AMNT          NUMERIC (11,2) = 0,
           @Ln_OweTotNaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_AppTotNaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_OweTotTaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_AppTotTaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_OweTotPaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_AppTotPaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_OweTotCaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_AppTotCaa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_OweTotUpa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_AppTotUpa_AMNT                   NUMERIC (11,2) = 0,
           @Ln_OweTotUda_AMNT                   NUMERIC (11,2) = 0,
           @Ln_AppTotUda_AMNT                   NUMERIC (11,2) = 0,
           @Ln_OweTotIvef_AMNT                  NUMERIC (11,2) = 0,
           @Ln_AppTotIvef_AMNT                  NUMERIC (11,2) = 0,
           @Ln_OweTotMedi_AMNT                  NUMERIC (11,2) = 0,
           @Ln_AppTotMedi_AMNT                  NUMERIC (11,2) = 0,
           @Ln_OweTotNffc_AMNT                  NUMERIC (11,2) = 0,
           @Ln_AppTotNffc_AMNT                  NUMERIC (11,2) = 0,
           @Ln_OweTotNonIvd_AMNT                NUMERIC (11,2) = 0,
           @Ln_AppTotNonIvd_AMNT                NUMERIC (11,2) = 0,
           @Ln_AppTotFuture_AMNT                NUMERIC (11,2) = 0,
           @Ln_MtdOwed_AMNT                     NUMERIC (11,2),
           @Ln_TransactionCurSup_AMNT           NUMERIC (11,2),
           @Ln_Periodic_AMNT                    NUMERIC (11,2),
           @Ln_ExpectToPay_AMNT                 NUMERIC (11,2),
           @Ln_TransactionPaa_AMNT              NUMERIC (11,2) = 0,
           @Ln_TransactionNaa_AMNT              NUMERIC (11,2) = 0,
           @Ln_TransactionUda_AMNT              NUMERIC (11,2) = 0,
           @Ln_TransactionUpa_AMNT              NUMERIC (11,2) = 0,
           @Ln_TransactionTaa_AMNT              NUMERIC (11,2) = 0,
           @Ln_TransactionCaa_AMNT              NUMERIC (11,2) = 0,
           @Ln_TransactionMedi_AMNT             NUMERIC (11,2) = 0,
           @Ln_TransactionNonIvd_AMNT           NUMERIC (11,2) = 0,
           @Ln_TransactionNffc_AMNT             NUMERIC (11,2) = 0,
           @Ln_TransactionIvef_AMNT             NUMERIC (11,2) = 0,
           @Ln_EventGlobalSeq_NUMB              NUMERIC (19) = 0,
           @Ln_Rowcount_QNTY                    NUMERIC (19),
           @Li_FetchStatus_QNTY                 SMALLINT,
           @Lc_MemberStatus_CODE                CHAR (1) = '',
           @Lc_Msg_CODE                         CHAR (1),
           @Lc_MtdProcess_INDC                  CHAR (1),
           @Lc_FreqPeriodic_CODE                CHAR (1),
           @Lc_TypeWelfare_CODE                 CHAR (1),
           @Lc_ExpectToPay_CODE                 CHAR (1),
           @Lc_TypeError_CODE                   CHAR (1),
           @Lc_BateError_CODE                   CHAR (5),
           @Lc_DayBeginOble_TEXT                CHAR (12),
           @Ls_Sql_TEXT                         VARCHAR (100),
           @Ls_CursorLoc_TEXT                   VARCHAR (200),
           @Ls_Sqldata_TEXT                     VARCHAR (1000),
           @Ls_ErrorMessage_TEXT                VARCHAR (4000),
           @Ls_DescriptionError_TEXT            VARCHAR (4000),
           @Ls_BateRecord_TEXT                  VARCHAR (4000),
           @Ld_Run_DATE                         DATE,
           @Ld_LastRun_DATE                     DATE,
           @Ld_MonthFirst_DATE                  DATE,
           @Ld_AccrualNext_DATE                 DATE,
           @Ld_BeginObligation_DATE             DATE,
           @Ld_EndObligation_DATE               DATE,
           @Ld_AccrualCurrent_DATE              DATE,
           @Ld_AccrualLast_DATE                 DATE,
           @Ld_AcclExpt_DATE                    DATE,
           @Ld_ExptFirst_DATE                   DATE,
           @Ld_Accl_DATE                        DATE,
           @Ld_LastRunAccl_DATE                 DATE,
           @Ld_ObleEndObligation_DATE           DATE,
           @Ld_LastDayOfMonthFirst_DATE         DATE;
  DECLARE @Ln_OblxCur_Case_IDNO            NUMERIC (6),
          @Ln_OblxCur_OrderSeq_NUMB        NUMERIC(2),
          @Ln_OblxCur_ObligationSeq_NUMB   NUMERIC(2),
          @Ln_OblxCur_MemberMci_IDNO       NUMERIC (10),
          @Lc_OblxCur_FreqPeriodic_CODE    CHAR (1),
          @Ln_OblxCur_Periodic_AMNT        NUMERIC(11, 2),
          @Ln_OblxCur_ExpectToPay_AMNT     NUMERIC(11, 2),
          @Ld_OblxCur_BeginObligation_DATE DATE,
          @Ld_OblxCur_EndObligation_DATE   DATE,
          @Ld_OblxCur_AccrualLast_DATE     DATE,
          @Ld_OblxCur_AccrualNext_DATE     DATE,
          @Lc_OblxCur_CheckRecipient_ID    CHAR (10),
          @Lc_OblxCur_CheckRecipient_CODE  CHAR (1),
          @Lc_OblxCur_TypeDebt_CODE        CHAR (2),
          @Lc_OblxCur_Fips_IDNO            CHAR (7),
          @Lc_OblxCur_ExpectToPay_CODE     CHAR (1),
          @Lc_OblxCur_DirectPay_INDC       CHAR (1),
          @Lc_OblxCur_TypeOrder_CODE       CHAR (1);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;
   -- Batch should run on the last date of the month only
   SET @Ls_Sql_TEXT = 'BATCH SHOULD RUN ON THE LAST DATE OF THE MONTH ONLY';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_JobAccrual_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') +', LastDayOfMonth_DATE = ' + CAST(CONVERT(DATE,  DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @Ld_Run_DATE)+1,0))  ,102) AS VARCHAR);	
   IF @Ld_Run_DATE <> CONVERT(DATE,  DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @Ld_Run_DATE)+1,0))  ,102)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH SHOULD BE RUN ON THE LAST DATE OF THE MONTH ONLY';
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'GET THE RUN DATE FOR ACCRUAL BATCH ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_JobAccrual_ID;	
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobAccrual_ID,
    @Ad_Run_DATE                = @Ld_Accl_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRunAccl_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   -- Accrual should have be run beforehand
   SET @Ls_Sql_TEXT = 'ACCRUAL BATCH IS NOT RUN FOR THE RUN DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_JobAccrual_ID + ', LastRunAccl_DATE = ' + ISNULL(CAST(@Ld_LastRunAccl_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');	
   IF @Ld_LastRunAccl_DATE != @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ACCRUAL BATCH PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END;
    
   SET @Ls_Sql_TEXT = 'MONTH SUPPORT BATCH PARM DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_JobAccrual_ID + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');	
   IF DATEADD(d,1,@Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'MONTH SUPPORT PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END;

   SET @Ld_MonthFirst_DATE = DATEADD(d,1,@Ld_Run_DATE);
   SET @Ln_SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_MonthFirst_DATE,112),1,6);
   SET @Ln_SupportYearPrevMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_Run_DATE,112),1,6);
   SET @Ld_LastDayOfMonthFirst_DATE = CONVERT(DATE,  DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @Ld_MonthFirst_DATE) + 1, 0) )  ,102);
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_MonthSupport1060_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;
   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_MonthSupport1060_NUMB,
    @Ac_Process_ID              = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
    @Ac_Note_INDC               = @Lc_No_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ln_Commit_QNTY = 0;

   /*
   		The program processes all open cases having an obligation on Obligation (OBLE_Y1) table.
   */
   DECLARE Oblx_CUR INSENSITIVE CURSOR FOR
    -- Retrieve the Current Active obligation records
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.MemberMci_IDNO,
           a.FreqPeriodic_CODE,
           a.Periodic_AMNT,
           a.ExpectToPay_AMNT,
           a.BeginObligation_DATE,
           a.EndObligation_DATE,
           a.AccrualLast_DATE,
           a.AccrualNext_DATE,
           a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.TypeDebt_CODE,
           a.Fips_CODE,
           a.ExpectToPay_CODE,
           ISNULL (LTRIM(RTRIM((s.DirectPay_INDC))), @Lc_No_INDC) AS DirectPay_INDC,
           s.TypeOrder_CODE -- Carry forward voluntary obligation records
      FROM OBLE_Y1 a,
           CASE_Y1 b,
           SORD_Y1 s
     WHERE a.Case_IDNO = b.Case_IDNO 
	   AND b.StatusCase_CODE <> @Lc_CaseStatusClosed_CODE
       AND a.BeginObligation_DATE < @Ld_MonthFirst_DATE
       AND a.EndObligation_DATE = (SELECT MAX (d.EndObligation_DATE) 
                                     FROM OBLE_Y1 d
                                    WHERE d.Case_IDNO = a.Case_IDNO
                                      AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                      AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                      AND d.BeginObligation_DATE < @Ld_MonthFirst_DATE
                                      AND d.EndValidity_DATE = @Ld_High_DATE)
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND s.Case_IDNO = a.Case_IDNO
       AND s.OrderSeq_NUMB = a.OrderSeq_NUMB
       AND s.EndValidity_DATE = @Ld_High_DATE
       AND EXISTS (SELECT 1 
                     FROM LSUP_Y1 d
                    WHERE d.Case_IDNO = a.Case_IDNO
                      AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                      AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                      AND d.SupportYearMonth_NUMB = @Ln_SupportYearPrevMonth_NUMB)
    UNION ALL
    -- Retrieve the Future Active obligation records
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.MemberMci_IDNO,
           a.FreqPeriodic_CODE,
           a.Periodic_AMNT,
           a.ExpectToPay_AMNT,
           a.BeginObligation_DATE,
           a.EndObligation_DATE,
           a.AccrualLast_DATE,
           a.AccrualNext_DATE,
           a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.TypeDebt_CODE,
           a.Fips_CODE,
           a.ExpectToPay_CODE,
           ISNULL (LTRIM(RTRIM((s.DirectPay_INDC))), @Lc_No_INDC) AS DirectPay_INDC,
           s.TypeOrder_CODE -- Carry forward voluntary obligation records
      FROM OBLE_Y1 a,
           CASE_Y1 b,
           SORD_Y1 s
     WHERE a.Case_IDNO = b.Case_IDNO
        AND b.StatusCase_CODE <> @Lc_CaseStatusClosed_CODE
       AND a.BeginObligation_DATE BETWEEN @Ld_MonthFirst_DATE AND @Ld_LastDayOfMonthFirst_DATE
       AND a.EndObligation_DATE = (SELECT MIN (d.EndObligation_DATE) 
                                     FROM OBLE_Y1 d
                                    WHERE d.Case_IDNO = a.Case_IDNO
                                      AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                      AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                      AND d.BeginObligation_DATE >= @Ld_MonthFirst_DATE
                                      AND d.EndValidity_DATE = @Ld_High_DATE)
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND s.Case_IDNO = a.Case_IDNO
       AND s.OrderSeq_NUMB = a.OrderSeq_NUMB
       AND s.EndValidity_DATE = @Ld_High_DATE
       AND NOT EXISTS (SELECT 1 
                         FROM OBLE_Y1 e
                        WHERE e.Case_IDNO = a.Case_IDNO
                          AND e.OrderSeq_NUMB = a.OrderSeq_NUMB
                          AND e.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                          AND e.BeginObligation_DATE < @Ld_MonthFirst_DATE
                          AND e.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'OPEN Oblx_CUR';
   SET @Ls_Sqldata_TEXT = '';
   	
   OPEN Oblx_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Oblx_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   	
   FETCH NEXT FROM Oblx_CUR INTO @Ln_OblxCur_Case_IDNO, @Ln_OblxCur_OrderSeq_NUMB, @Ln_OblxCur_ObligationSeq_NUMB, @Ln_OblxCur_MemberMci_IDNO, @Lc_OblxCur_FreqPeriodic_CODE, @Ln_OblxCur_Periodic_AMNT, @Ln_OblxCur_ExpectToPay_AMNT, @Ld_OblxCur_BeginObligation_DATE, @Ld_OblxCur_EndObligation_DATE, @Ld_OblxCur_AccrualLast_DATE, @Ld_OblxCur_AccrualNext_DATE, @Lc_OblxCur_CheckRecipient_ID, @Lc_OblxCur_CheckRecipient_CODE, @Lc_OblxCur_TypeDebt_CODE, @Lc_OblxCur_Fips_IDNO, @Lc_OblxCur_ExpectToPay_CODE, @Lc_OblxCur_DirectPay_INDC, @Lc_OblxCur_TypeOrder_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN TRANSACTION MonthSupport;

   SET @Ls_Sql_TEXT = 'WHILE_LOOP1';
   SET @Ls_Sqldata_TEXT = '';
  -- Main loop started for month support	
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION MonthSupportSave;
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_BateRecord_TEXT = 'Case_IDNO = ' + CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR) + ', Order_SEQ = ' + CAST(@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR) + ', Obligation_SEQ = ' + CAST(@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_OblxCur_MemberMci_IDNO AS VARCHAR) + ', FreqPeriodic_CODE = ' + @Lc_OblxCur_FreqPeriodic_CODE + ', Periodic_AMNT = ' + CAST(@Ln_OblxCur_Periodic_AMNT AS VARCHAR) + ', ExpectToPay_AMNT = ' + CAST(@Ln_OblxCur_ExpectToPay_AMNT AS VARCHAR) + ', BeginObligation_DATE = ' + CAST(@Ld_OblxCur_BeginObligation_DATE AS VARCHAR) + ', EndObligation_DATE = ' + CAST(@Ld_OblxCur_EndObligation_DATE AS VARCHAR) + ', AccrualLast_DATE = ' + CAST(@Ld_OblxCur_AccrualLast_DATE AS VARCHAR) + ', AccrualNext_DATE = ' + CAST(@Ld_OblxCur_AccrualNext_DATE AS VARCHAR) + ', CheckRecipient_ID = ' + @Lc_OblxCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_OblxCur_CheckRecipient_CODE + ', TypeDebt_CODE = ' + @Lc_OblxCur_TypeDebt_CODE + ', Fips_IDNO = ' + @Lc_OblxCur_Fips_IDNO + ', ExpectToPay_CODE = ' + @Lc_OblxCur_ExpectToPay_CODE + ', DirectPay_INDC = ' + @Lc_OblxCur_DirectPay_INDC + ', TypeOrder_CODE = ' + @Lc_OblxCur_TypeOrder_CODE;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_Commit_QNTY = @Ln_Commit_QNTY + 1;
      SET @Ls_CursorLoc_TEXT = 'Cursor_COUNT ' + ISNULL (CAST (@Ln_Cursor_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR), '') + ', BeginObligation_DATE = ' + ISNULL (CAST (@Ld_OblxCur_BeginObligation_DATE AS VARCHAR), '') + ', EndObligation_DATE = ' + ISNULL (CAST (@Ld_OblxCur_EndObligation_DATE AS VARCHAR), '');
      SET @Lc_FreqPeriodic_CODE = @Lc_OblxCur_FreqPeriodic_CODE;
      SET @Ln_Periodic_AMNT = @Ln_OblxCur_Periodic_AMNT;
      SET @Ln_ExpectToPay_AMNT = @Ln_OblxCur_ExpectToPay_AMNT;
      SET @Ld_BeginObligation_DATE = @Ld_OblxCur_BeginObligation_DATE;
      SET @Lc_ExpectToPay_CODE = @Lc_OblxCur_ExpectToPay_CODE;
      SET @Ld_ObleEndObligation_DATE = @Ld_OblxCur_EndObligation_DATE;
      SET @Ln_TransactionExptPay_AMNT = 0;
      SET @Ln_OweTotNaa_AMNT = 0;
      SET @Ln_AppTotNaa_AMNT = 0;
      SET @Ln_OweTotTaa_AMNT = 0;
      SET @Ln_AppTotTaa_AMNT = 0;
      SET @Ln_OweTotPaa_AMNT = 0;
      SET @Ln_AppTotPaa_AMNT = 0;
      SET @Ln_OweTotCaa_AMNT = 0;
      SET @Ln_AppTotCaa_AMNT = 0;
      SET @Ln_OweTotUpa_AMNT = 0;
      SET @Ln_AppTotUpa_AMNT = 0;
      SET @Ln_OweTotUda_AMNT = 0;
      SET @Ln_AppTotUda_AMNT = 0;
      SET @Ln_OweTotIvef_AMNT = 0;
      SET @Ln_AppTotIvef_AMNT = 0;
      SET @Ln_OweTotMedi_AMNT = 0;
      SET @Ln_AppTotMedi_AMNT = 0;
      SET @Ln_OweTotNffc_AMNT = 0;
      SET @Ln_AppTotNffc_AMNT = 0;
      SET @Ln_OweTotNonIvd_AMNT = 0;
      SET @Ln_AppTotNonIvd_AMNT = 0;
      SET @Ln_AppTotFuture_AMNT = 0;
      SET @Ln_TransactionPaa_AMNT = 0;
      SET @Ln_TransactionNaa_AMNT = 0;
      SET @Ln_TransactionTaa_AMNT = 0;
      SET @Ln_TransactionCaa_AMNT = 0;
      SET @Ln_TransactionUpa_AMNT = 0;
      SET @Ln_TransactionUda_AMNT = 0;
      SET @Ln_TransactionMedi_AMNT = 0;
      SET @Ln_TransactionNffc_AMNT = 0;
      SET @Ln_TransactionNonIvd_AMNT = 0;
      SET @Ln_TransactionIvef_AMNT = 0;
      
      --Select LSUP_Y1 table records for previous month
      SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (CAST (@Ln_SupportYearPrevMonth_NUMB AS VARCHAR), '');
      SELECT @Ln_OweTotNaa_AMNT = a.OweTotNaa_AMNT,
             @Ln_AppTotNaa_AMNT = a.AppTotNaa_AMNT,
             @Ln_OweTotTaa_AMNT = a.OweTotTaa_AMNT,
             @Ln_AppTotTaa_AMNT = a.AppTotTaa_AMNT,
             @Ln_OweTotPaa_AMNT = a.OweTotPaa_AMNT,
             @Ln_AppTotPaa_AMNT = a.AppTotPaa_AMNT,
             @Ln_OweTotCaa_AMNT = a.OweTotCaa_AMNT,
             @Ln_AppTotCaa_AMNT = a.AppTotCaa_AMNT,
             @Ln_OweTotUpa_AMNT = a.OweTotUpa_AMNT,
             @Ln_AppTotUpa_AMNT = a.AppTotUpa_AMNT,
             @Ln_OweTotUda_AMNT = a.OweTotUda_AMNT,
             @Ln_AppTotUda_AMNT = a.AppTotUda_AMNT,
             @Ln_OweTotIvef_AMNT = a.OweTotIvef_AMNT,
             @Ln_AppTotIvef_AMNT = a.AppTotIvef_AMNT,
             @Ln_OweTotMedi_AMNT = a.OweTotMedi_AMNT,
             @Ln_AppTotMedi_AMNT = a.AppTotMedi_AMNT,
             @Ln_OweTotNffc_AMNT = a.OweTotNffc_AMNT,
             @Ln_AppTotNffc_AMNT = a.AppTotNffc_AMNT,
             @Ln_OweTotNonIvd_AMNT = a.OweTotNonIvd_AMNT,
             @Ln_AppTotNonIvd_AMNT = a.AppTotNonIvd_AMNT,
             @Ln_AppTotFuture_AMNT = a.AppTotFuture_AMNT,
             @Lc_TypeWelfare_CODE = a.TypeWelfare_CODE
        FROM LSUP_Y1 a
       WHERE a.Case_IDNO = @Ln_OblxCur_Case_IDNO
         AND a.OrderSeq_NUMB = @Ln_OblxCur_OrderSeq_NUMB
         AND a.ObligationSeq_NUMB = @Ln_OblxCur_ObligationSeq_NUMB
         AND a.SupportYearMonth_NUMB = @Ln_SupportYearPrevMonth_NUMB
         AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB) 
                                        FROM LSUP_Y1 b
                                       WHERE b.Case_IDNO = @Ln_OblxCur_Case_IDNO
                                         AND b.OrderSeq_NUMB = @Ln_OblxCur_OrderSeq_NUMB
                                         AND b.ObligationSeq_NUMB = @Ln_OblxCur_ObligationSeq_NUMB
                                         AND b.SupportYearMonth_NUMB = @Ln_SupportYearPrevMonth_NUMB);

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        IF @Ld_OblxCur_EndObligation_DATE < @Ld_MonthFirst_DATE
         BEGIN
          --Skip records when there is no LSUP records in the previous
          --month for an inactive OBLE_Y1
          GOTO SKIP_RECORD;
         END;

        SET @Ln_OweTotNaa_AMNT = 0;
        SET @Ln_AppTotNaa_AMNT = 0;
        SET @Ln_OweTotTaa_AMNT = 0;
        SET @Ln_AppTotTaa_AMNT = 0;
        SET @Ln_OweTotPaa_AMNT = 0;
        SET @Ln_AppTotPaa_AMNT = 0;
        SET @Ln_OweTotCaa_AMNT = 0;
        SET @Ln_AppTotCaa_AMNT = 0;
        SET @Ln_OweTotUpa_AMNT = 0;
        SET @Ln_AppTotUpa_AMNT = 0;
        SET @Ln_OweTotUda_AMNT = 0;
        SET @Ln_AppTotUda_AMNT = 0;
        SET @Ln_OweTotIvef_AMNT = 0;
        SET @Ln_AppTotIvef_AMNT = 0;
        SET @Ln_OweTotMedi_AMNT = 0;
        SET @Ln_AppTotMedi_AMNT = 0;
        SET @Ln_OweTotNffc_AMNT = 0;
        SET @Ln_AppTotNffc_AMNT = 0;
        SET @Ln_OweTotNonIvd_AMNT = 0;
        SET @Ln_AppTotNonIvd_AMNT = 0;
        SET @Ln_AppTotFuture_AMNT = 0;
       END;

      BEGIN
       --Intialize the future obligation count to zero
       SET @Ln_FutureObligation_QNTY = 0;

       --Check if the date end obligation is equal to last date of the month
       IF @Ld_OblxCur_EndObligation_DATE = CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0)) AS DATE) -- Last Day of Run Date
        BEGIN
         --Assign the count if there are future obligation exist
         SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1_FUTURE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL (CAST (@Ld_High_DATE AS VARCHAR), '') + ', BeginObligation_DATE = ' + ISNULL (CAST (@Ld_MonthFirst_DATE AS VARCHAR), '');
         SELECT @Ln_FutureObligation_QNTY = 1
           FROM OBLE_Y1 a
          WHERE a.Case_IDNO = @Ln_OblxCur_Case_IDNO
            AND a.OrderSeq_NUMB = @Ln_OblxCur_OrderSeq_NUMB
            AND a.ObligationSeq_NUMB = @Ln_OblxCur_ObligationSeq_NUMB
            AND a.EndValidity_DATE = @Ld_High_DATE
            AND a.BeginObligation_DATE = @Ld_MonthFirst_DATE;
        END;

       /*
        For IVD cases does not rollover if all bals are zero, obligs are end dated
        */
       IF @Ld_OblxCur_EndObligation_DATE < @Ld_MonthFirst_DATE
          -- Process the records if there is no future obligation exist			
          AND @Ln_FutureObligation_QNTY = 0
          AND @Lc_TypeWelfare_CODE <> @Lc_TypeWelfareNonIvd_CODE
          -- carry forward voluntary order records
          AND @Lc_OblxCur_TypeOrder_CODE <> @Lc_TypeOrderVoluntary_CODE
        BEGIN
         IF (@Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT) = 0
            AND (@Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT) = 0
            AND (@Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT) = 0
            AND (@Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT) = 0
            AND (@Ln_OweTotUda_AMNT - @Ln_AppTotUda_AMNT) = 0
            AND (@Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT) = 0
            AND (@Ln_OweTotIvef_AMNT - @Ln_AppTotIvef_AMNT) = 0
            AND (@Ln_OweTotMedi_AMNT - @Ln_AppTotMedi_AMNT) = 0
            AND (@Ln_OweTotNffc_AMNT - @Ln_AppTotNffc_AMNT) = 0
            AND (@Ln_OweTotNonIvd_AMNT - @Ln_AppTotNonIvd_AMNT) = 0
          BEGIN
           --Skip records when the arrears has become zero in the previous
           --month for an inactive obligation
           GOTO SKIP_RECORD;
          END;
        END;

       IF @Ld_OblxCur_AccrualNext_DATE <= @Ld_LastDayOfMonthFirst_DATE
        BEGIN
         SET @Ld_AccrualNext_DATE = @Ld_OblxCur_AccrualNext_DATE;

         IF @Ld_AccrualNext_DATE = @Ld_Low_DATE
          BEGIN
           SET @Ld_AccrualNext_DATE = @Ld_OblxCur_BeginObligation_DATE;
          END;

         SET @Ld_AccrualCurrent_DATE = @Ld_AccrualNext_DATE;
         SET @Ld_AccrualLast_DATE = @Ld_OblxCur_AccrualLast_DATE;

         IF @Ld_AccrualLast_DATE = @Ld_Low_DATE
          BEGIN
           SET @Ld_AccrualLast_DATE = @Ld_OblxCur_BeginObligation_DATE;
          END;
        END;

       SET @Ld_EndObligation_DATE = @Ld_OblxCur_EndObligation_DATE;

       IF @Ld_EndObligation_DATE > @Ld_LastDayOfMonthFirst_DATE
        BEGIN
         SET @Ld_EndObligation_DATE = @Ld_LastDayOfMonthFirst_DATE;
        END;

		/*
			The system checks for the member status as of the first of the next month from Member
			 Welfare Details (MHIS_Y1) for that obligation.
		*/
	   SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO  = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_MemberMci_IDNO AS VARCHAR), '') + ', MonthFirst_DATE = ' + ISNULL (CAST (@Ld_MonthFirst_DATE AS VARCHAR), '');
       SELECT @Lc_MemberStatus_CODE = ISNULL (a.TypeWelfare_CODE, @Lc_TypeWelfareNonTanf_CODE)
         FROM MHIS_Y1 a
        WHERE a.Case_IDNO = @Ln_OblxCur_Case_IDNO
          AND a.MemberMci_IDNO = @Ln_OblxCur_MemberMci_IDNO
          AND @Ld_MonthFirst_DATE BETWEEN a.Start_DATE AND a.End_DATE;

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
		--	If the member status record does not exist in MHIS is a NULL value, it is identified as 'N' - Non-TANF.
       IF @Ln_Rowcount_QNTY = 0
        BEGIN
         SET @Lc_MemberStatus_CODE = @Lc_TypeWelfareNonTanf_CODE;
        END;

       SET @Ld_AccrualCurrent_DATE = @Ld_AccrualNext_DATE;
       SET @Ln_MtdOwed_AMNT = 0;
	   --  To calculate MtdCurSupOwed_AMNT for obligations ending on the first day of the month
       IF @Ld_OblxCur_AccrualNext_DATE = @Ld_High_DATE
           OR @Ld_OblxCur_AccrualNext_DATE >= @Ld_OblxCur_EndObligation_DATE
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1 1';
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR), '') + ', BeginObligation_DATE = ' + ISNULL (CAST(DATEADD(d,1,@Ld_EndObligation_DATE) AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL (CAST (@Ld_High_DATE AS VARCHAR), '');
         SELECT @Lc_FreqPeriodic_CODE = o.FreqPeriodic_CODE,
                @Ln_Periodic_AMNT = o.Periodic_AMNT,
                @Ln_ExpectToPay_AMNT = o.ExpectToPay_AMNT,
                @Ld_BeginObligation_DATE = o.BeginObligation_DATE,
                @Ld_EndObligation_DATE = o.EndObligation_DATE,
                @Ld_AccrualNext_DATE = o.AccrualNext_DATE,
                @Ld_AccrualLast_DATE = o.AccrualLast_DATE,
                @Ld_ObleEndObligation_DATE = o.EndObligation_DATE
           FROM OBLE_Y1 o
          WHERE o.Case_IDNO = @Ln_OblxCur_Case_IDNO
            AND o.OrderSeq_NUMB = @Ln_OblxCur_OrderSeq_NUMB
            AND o.ObligationSeq_NUMB = @Ln_OblxCur_ObligationSeq_NUMB
            AND o.BeginObligation_DATE = DATEADD(d,1,@Ld_EndObligation_DATE)
            AND o.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
		 IF @Ln_Rowcount_QNTY > 0
          BEGIN
           IF @Ld_AccrualLast_DATE = @Ld_Low_DATE
            BEGIN
             SET @Ld_AccrualLast_DATE = @Ld_BeginObligation_DATE;
            END;

           IF @Ld_AccrualNext_DATE = @Ld_Low_DATE
            BEGIN
             SET @Ld_AccrualNext_DATE = @Ld_BeginObligation_DATE;
            END;

           IF @Ld_EndObligation_DATE > @Ld_LastDayOfMonthFirst_DATE
            BEGIN
             SET @Ld_EndObligation_DATE = @Ld_LastDayOfMonthFirst_DATE;
            END;
          END;
        END;

       -- Calculate MtdCurSupOwed_AMNT for obligations ending on the first day of the month
       IF @Ld_EndObligation_DATE >= @Ld_MonthFirst_DATE
        BEGIN
         IF @Ld_AccrualNext_DATE <= @Ld_LastDayOfMonthFirst_DATE 
          BEGIN
           SET @Ls_Sql_TEXT = 'WHIlE_LOOP2';
           SET @Ls_Sqldata_TEXT = '';	
            -- while loop started
           	WHILE SUBSTRING(CONVERT(VARCHAR, @Ld_AccrualNext_DATE, 112),1,6) = SUBSTRING(CONVERT(VARCHAR, @Ld_MonthFirst_DATE, 112),1,6) 
			AND @Ld_AccrualNext_DATE <= @Ld_EndObligation_DATE
                 AND @Lc_FreqPeriodic_CODE != @Lc_Onetime_CODE
            BEGIN
             /*
				 Program calculate next accrual date according to the Frequency of payment and
				 calculate accrual amount.
             */
             SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ACCRUAL ';
             SET @Ls_Sqldata_TEXT = 'FreqPeriodic_CODE = ' + ISNULL (@Lc_FreqPeriodic_CODE, '') + ', Periodic_AMNT = ' + ISNULL (CAST(@Ln_Periodic_AMNT AS VARCHAR), '') + ', ExpectToPay_AMNT = ' + ISNULL (CAST (@Ln_ExpectToPay_AMNT AS VARCHAR), '') + ', BeginObligation_DATE = ' + ISNULL (CAST (@Ld_BeginObligation_DATE AS VARCHAR), '') + ', ObleEndObligation_DATE = ' + ISNULL (CAST (@Ld_ObleEndObligation_DATE AS VARCHAR), '') + ', EndObligation_DATE = ' + ISNULL (CAST (@Ld_EndObligation_DATE AS VARCHAR), '');
             EXECUTE BATCH_COMMON$SP_ACCRUAL
              @Ac_FreqPeriodic_CODE       = @Lc_FreqPeriodic_CODE,
              @An_Periodic_AMNT           = @Ln_Periodic_AMNT,
              @An_ExpectToPay_AMNT        = @Ln_ExpectToPay_AMNT,
              @Ad_BeginObligation_DATE    = @Ld_BeginObligation_DATE,
              @Ad_EndObligation_DATE      = @Ld_ObleEndObligation_DATE,
              @Ad_AccrualEnd_DATE         = @Ld_EndObligation_DATE,
              @Ad_AccrualNext_DATE        = @Ld_AccrualNext_DATE OUTPUT,
              @Ad_AccrualLast_DATE        = @Ld_AccrualLast_DATE OUTPUT,
              @An_TransactionCurSup_AMNT  = @Ln_TransactionCurSup_AMNT OUTPUT,
              @An_TransactionExptPay_AMNT = @Ln_TransactionExptPay_AMNT OUTPUT,
              @An_MtdAccrual_AMNT         = @Ln_MtdOwed_AMNT OUTPUT,
              @Ac_MtdProcess_INDC         = @Lc_MtdProcess_INDC OUTPUT,
              @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;
               
              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR (50001,16,1);
              END;
		     IF @Ld_AccrualNext_DATE > @Ld_EndObligation_DATE
                AND @Ld_EndObligation_DATE < @Ld_LastDayOfMonthFirst_DATE
              BEGIN
               SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y11';
               SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR), '') + ', BeginObligation_DATE = ' + ISNULL (CAST(DATEADD(d,1,@Ld_EndObligation_DATE) AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL (CAST (@Ld_High_DATE AS VARCHAR), '');
				
               SELECT @Lc_FreqPeriodic_CODE = o.FreqPeriodic_CODE,
                      @Ln_Periodic_AMNT = o.Periodic_AMNT,
                      @Ln_ExpectToPay_AMNT = o.ExpectToPay_AMNT,
                      @Ld_BeginObligation_DATE = o.BeginObligation_DATE,
                      @Ld_EndObligation_DATE = o.EndObligation_DATE,
                      @Ld_AccrualNext_DATE = o.AccrualNext_DATE,
                      @Ld_AccrualLast_DATE = o.AccrualLast_DATE,
                      @Ld_ObleEndObligation_DATE = o.EndObligation_DATE
                 FROM OBLE_Y1 o
                WHERE o.Case_IDNO = @Ln_OblxCur_Case_IDNO
                  AND o.OrderSeq_NUMB = @Ln_OblxCur_OrderSeq_NUMB
                  AND o.ObligationSeq_NUMB = @Ln_OblxCur_ObligationSeq_NUMB
                  AND o.BeginObligation_DATE = DATEADD(d,1,@Ld_EndObligation_DATE)
                  AND o.EndValidity_DATE = @Ld_High_DATE;

               SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
               IF @Ln_Rowcount_QNTY > 0
                BEGIN
                 IF @Ld_AccrualLast_DATE = @Ld_Low_DATE
                  BEGIN
                   SET @Ld_AccrualLast_DATE = @Ld_BeginObligation_DATE;
                  END;

                 IF @Ld_AccrualNext_DATE = @Ld_Low_DATE
                  BEGIN
                   SET @Ld_AccrualNext_DATE = @Ld_BeginObligation_DATE;
                  END;

                 IF @Ld_EndObligation_DATE > @Ld_LastDayOfMonthFirst_DATE
                  BEGIN
                   SET @Ld_EndObligation_DATE = @Ld_LastDayOfMonthFirst_DATE;
                  END;
                END;
              END;
            END;
          END;
        END;

       --  Calculate OweTotExptPay_AMNT when freq is one time
       IF @Ln_ExpectToPay_AMNT > 0
        BEGIN
         IF @Lc_FreqPeriodic_CODE = @Lc_Onetime_CODE
          BEGIN
           SET @Ln_TransactionExptPay_AMNT = @Ln_ExpectToPay_AMNT;
          END;
         ELSE
          BEGIN
           -- Use the Obligation begin date to derive the day of charge for expect to pay
           SET @Lc_DayBeginOble_TEXT = DATENAME (WEEKDAY, @Ld_OblxCur_BeginObligation_DATE);

           IF @Ld_OblxCur_BeginObligation_DATE > @Ld_MonthFirst_DATE
            BEGIN
             SET @Ld_ExptFirst_DATE = @Ld_OblxCur_BeginObligation_DATE;
            END;
           ELSE
            BEGIN
             SET @Ld_ExptFirst_DATE = @Ld_MonthFirst_DATE;
            END;

           IF DATENAME (WEEKDAY, @Ld_ExptFirst_DATE) = @Lc_DayBeginOble_TEXT
            BEGIN
             SET @Ld_AcclExpt_DATE = @Ld_ExptFirst_DATE;
            END;
           ELSE
            BEGIN
             SET @Ld_AcclExpt_DATE = dbo.BATCH_COMMON_SCALAR$SF_NEXT_DAY (@Ld_ExptFirst_DATE, @Lc_DayBeginOble_TEXT);
            END;
		   
		   /*
				Program calculate next accrual Expt Date according to the Frequency.
           */
           SET @Ln_TransactionExptPay_AMNT = 0;
           SET @Ls_Sql_TEXT = 'WHILE Ld_AcclExpt_DATE';
           SET @Ls_Sqldata_TEXT = '';
           -- While loop for calculating accrual next date
		   WHILE SUBSTRING(CONVERT(VARCHAR(6),@Ld_AcclExpt_DATE,112),1,6) = SUBSTRING(CONVERT(VARCHAR(6),@Ld_MonthFirst_DATE,112),1,6)
            BEGIN
             SET @Ln_TransactionExptPay_AMNT = @Ln_TransactionExptPay_AMNT + @Ln_ExpectToPay_AMNT;

             IF @Lc_FreqPeriodic_CODE = @Lc_Weekly_CODE
              BEGIN
               SET @Ld_AcclExpt_DATE = DATEADD (d,@Ln_DateAcclExpt7_NUMB, @Ld_AcclExpt_DATE);
              END;
             ELSE
              BEGIN
               IF @Lc_FreqPeriodic_CODE = @Lc_Biweekly_CODE
                BEGIN
                 SET @Ld_AcclExpt_DATE = DATEADD (d,@Ln_DateAcclExpt14_NUMB, @Ld_AcclExpt_DATE);
                END;
               ELSE
                BEGIN
                 IF @Lc_FreqPeriodic_CODE = @Lc_Semimonthly_CODE
                  BEGIN
                   IF DATENAME(DAY,@Ld_AcclExpt_DATE) >= @Lc_DateAcclExpt16_NUMB
                    BEGIN
                     IF DATENAME(DAY,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CONVERT(DATE,@Ld_AcclExpt_DATE, 112))+1,0))) = @Lc_DateAcclExpt31_NUMB
                      BEGIN
                       SET @Ld_AcclExpt_DATE = DATEADD (d,@Ln_DateAcclExpt16_NUMB, @Ld_AcclExpt_DATE);
                      END;
                     ELSE
                      BEGIN
                       SET @Ld_AcclExpt_DATE = DATEADD (d,@Ln_DateAcclExpt15_NUMB, @Ld_AcclExpt_DATE);
                      END;
                    END;
                   ELSE
                    BEGIN
                     IF DATEPART(MONTH,@Ld_AcclExpt_DATE) = @Lc_DateAcclExpt02_NUMB
                        AND DATENAME(DAY,@Ld_AcclExpt_DATE) IN (@Lc_DateAcclExpt14_NUMB, @Lc_DateAcclExpt15_NUMB)
                      BEGIN
                       SET @Ld_AcclExpt_DATE = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CONVERT(DATE,@Ld_AcclExpt_DATE, 112))+1,0)) ;
                      END;
                     ELSE
                      BEGIN
                       SET @Ld_AcclExpt_DATE = DATEADD (d,@Ln_DateAcclExpt15_NUMB, @Ld_AcclExpt_DATE);
                      END;
                    END;
                  END;
                 ELSE
                  BEGIN
                   IF @Lc_FreqPeriodic_CODE = @Lc_Quarterly_CODE
                    BEGIN
                     SET @Ld_AcclExpt_DATE = DATEADD (m, @Ln_DateAcclExpt3_NUMB, @Ld_AcclExpt_DATE);
                    END;
                   ELSE
                    BEGIN
                     IF @Lc_FreqPeriodic_CODE = @Lc_Monthly_CODE
                      BEGIN
                       SET @Ld_AcclExpt_DATE = DATEADD (m, 1, @Ld_AcclExpt_DATE);
                      END;
                     ELSE
                      BEGIN
                       IF @Lc_FreqPeriodic_CODE = @Lc_Annual_CODE
                        BEGIN
                         SET @Ld_AcclExpt_DATE = DATEADD (m, @Ln_DateAcclExpt12_NUMB, @Ld_AcclExpt_DATE);
                        END;
                      END;
                    END;
                  END;
                END;
              END;
            END;
          END;
        END;
        
       IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareNonIvd_CODE
          AND @Lc_OblxCur_DirectPay_INDC = @Lc_Yes_INDC
        BEGIN
         SET @Ln_TransactionExptPay_AMNT = 0;
         SET @Ln_MtdOwed_AMNT = 0;
        END;
       /*
		The monthly support obligation, the Payback arrears derived for the month, the existing 
		arrear balances in each of the buckets from the current month and the new global sequence 
		will be inserted into Support Log (LSUP_Y1) table for the following month.
      */	
       SET @Ls_Sql_TEXT = 'INSERT_LSUP';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_OblxCur_Case_IDNO AS VARCHAR ),'') + ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OblxCur_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR ),'') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonth_NUMB AS VARCHAR ),'') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_MemberStatus_CODE,'') + ', MtdCurSupOwed_AMNT = ' + ISNULL(CAST( @Ln_MtdOwed_AMNT AS VARCHAR ),'') + ', TransactionCurSup_AMNT = ' + ISNULL('0','') + ', OweTotCurSup_AMNT = ' + ISNULL('0','') + ', AppTotCurSup_AMNT = ' + ISNULL('0','') + ', TransactionExptPay_AMNT = ' + ISNULL(CAST( @Ln_TransactionExptPay_AMNT AS VARCHAR ),'') + ', OweTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_TransactionExptPay_AMNT AS VARCHAR ),'') + ', AppTotExptPay_AMNT = ' + ISNULL('0','') + ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionNaa_AMNT AS VARCHAR ),'') + ', OweTotNaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotNaa_AMNT AS VARCHAR ),'') + ', AppTotNaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotNaa_AMNT AS VARCHAR ),'') + ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionTaa_AMNT AS VARCHAR ),'') + ', OweTotTaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotTaa_AMNT AS VARCHAR ),'') + ', AppTotTaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotTaa_AMNT AS VARCHAR ),'') + ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionPaa_AMNT AS VARCHAR ),'') + ', OweTotPaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotPaa_AMNT AS VARCHAR ),'') + ', AppTotPaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotPaa_AMNT AS VARCHAR ),'') + ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionCaa_AMNT AS VARCHAR ),'') + ', OweTotCaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotCaa_AMNT AS VARCHAR ),'') + ', AppTotCaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotCaa_AMNT AS VARCHAR ),'') + ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_TransactionUpa_AMNT AS VARCHAR ),'') + ', OweTotUpa_AMNT = ' + ISNULL(CAST( @Ln_OweTotUpa_AMNT AS VARCHAR ),'') + ', AppTotUpa_AMNT = ' + ISNULL(CAST( @Ln_AppTotUpa_AMNT AS VARCHAR ),'') + ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_TransactionUda_AMNT AS VARCHAR ),'') + ', OweTotUda_AMNT = ' + ISNULL(CAST( @Ln_OweTotUda_AMNT AS VARCHAR ),'') + ', AppTotUda_AMNT = ' + ISNULL(CAST( @Ln_AppTotUda_AMNT AS VARCHAR ),'') + ', TransactionIvef_AMNT = ' + ISNULL(CAST( @Ln_TransactionIvef_AMNT AS VARCHAR ),'') + ', OweTotIvef_AMNT = ' + ISNULL(CAST( @Ln_OweTotIvef_AMNT AS VARCHAR ),'') + ', AppTotIvef_AMNT = ' + ISNULL(CAST( @Ln_AppTotIvef_AMNT AS VARCHAR ),'') + ', TransactionMedi_AMNT = ' + ISNULL(CAST( @Ln_TransactionMedi_AMNT AS VARCHAR ),'') + ', OweTotMedi_AMNT = ' + ISNULL(CAST( @Ln_OweTotMedi_AMNT AS VARCHAR ),'') + ', AppTotMedi_AMNT = ' + ISNULL(CAST( @Ln_AppTotMedi_AMNT AS VARCHAR ),'') + ', TransactionNffc_AMNT = ' + ISNULL(CAST( @Ln_TransactionNffc_AMNT AS VARCHAR ),'') + ', OweTotNffc_AMNT = ' + ISNULL(CAST( @Ln_OweTotNffc_AMNT AS VARCHAR ),'') + ', AppTotNffc_AMNT = ' + ISNULL(CAST( @Ln_AppTotNffc_AMNT AS VARCHAR ),'') + ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( @Ln_TransactionNonIvd_AMNT AS VARCHAR ),'') + ', OweTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_OweTotNonIvd_AMNT AS VARCHAR ),'') + ', AppTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_AppTotNonIvd_AMNT AS VARCHAR ),'') + ', Batch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'') + ', Batch_NUMB = ' + ISNULL('0','') + ', SeqReceipt_NUMB = ' + ISNULL('0','') + ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'') + ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'') + ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'') + ', TypeRecord_CODE = ' + ISNULL(@Lc_Space_TEXT,'') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_MonthSupport1060_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'') + ', TransactionFuture_AMNT = ' + ISNULL('0','') + ', AppTotFuture_AMNT = ' + ISNULL(CAST( @Ln_AppTotFuture_AMNT AS VARCHAR ),'') + ', CheckRecipient_ID = ' + ISNULL(@Lc_OblxCur_CheckRecipient_ID,'') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_OblxCur_CheckRecipient_CODE,'');
       INSERT LSUP_Y1
              (Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               SupportYearMonth_NUMB,
               TypeWelfare_CODE,
               MtdCurSupOwed_AMNT,
               TransactionCurSup_AMNT,
               OweTotCurSup_AMNT,
               AppTotCurSup_AMNT,
               TransactionExptPay_AMNT,
               OweTotExptPay_AMNT,
               AppTotExptPay_AMNT,
               TransactionNaa_AMNT,
               OweTotNaa_AMNT,
               AppTotNaa_AMNT,
               TransactionTaa_AMNT,
               OweTotTaa_AMNT,
               AppTotTaa_AMNT,
               TransactionPaa_AMNT,
               OweTotPaa_AMNT,
               AppTotPaa_AMNT,
               TransactionCaa_AMNT,
               OweTotCaa_AMNT,
               AppTotCaa_AMNT,
               TransactionUpa_AMNT,
               OweTotUpa_AMNT,
               AppTotUpa_AMNT,
               TransactionUda_AMNT,
               OweTotUda_AMNT,
               AppTotUda_AMNT,
               TransactionIvef_AMNT,
               OweTotIvef_AMNT,
               AppTotIvef_AMNT,
               TransactionMedi_AMNT,
               OweTotMedi_AMNT,
               AppTotMedi_AMNT,
               TransactionNffc_AMNT,
               OweTotNffc_AMNT,
               AppTotNffc_AMNT,
               TransactionNonIvd_AMNT,
               OweTotNonIvd_AMNT,
               AppTotNonIvd_AMNT,
               Batch_DATE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               SourceBatch_CODE,
               Receipt_DATE,
               Distribute_DATE,
               TypeRecord_CODE,
               EventFunctionalSeq_NUMB,
               EventGlobalSeq_NUMB,
               TransactionFuture_AMNT,
               AppTotFuture_AMNT,
               CheckRecipient_ID,
               CheckRecipient_CODE)
       VALUES (@Ln_OblxCur_Case_IDNO,           --Case_IDNO               
               @Ln_OblxCur_OrderSeq_NUMB,       --OrderSeq_NUMB           
               @Ln_OblxCur_ObligationSeq_NUMB,  --ObligationSeq_NUMB      
               @Ln_SupportYearMonth_NUMB,       --SupportYearMonth_NUMB   
               @Lc_MemberStatus_CODE,           --TypeWelfare_CODE        
               @Ln_MtdOwed_AMNT,                --MtdCurSupOwed_AMNT      
               0,								--TransactionCurSup_AMNT  
               0,								--OweTotCurSup_AMNT       
               0,								--AppTotCurSup_AMNT       
               @Ln_TransactionExptPay_AMNT,     --TransactionExptPay_AMNT 
               @Ln_TransactionExptPay_AMNT,     --OweTotExptPay_AMNT      
               0,								--AppTotExptPay_AMNT      
               @Ln_TransactionNaa_AMNT,         --TransactionNaa_AMNT     
               @Ln_OweTotNaa_AMNT,              --OweTotNaa_AMNT          
               @Ln_AppTotNaa_AMNT,              --AppTotNaa_AMNT          
               @Ln_TransactionTaa_AMNT,         --TransactionTaa_AMNT     
               @Ln_OweTotTaa_AMNT,              --OweTotTaa_AMNT          
               @Ln_AppTotTaa_AMNT,              --AppTotTaa_AMNT          
               @Ln_TransactionPaa_AMNT,         --TransactionPaa_AMNT     
               @Ln_OweTotPaa_AMNT,              --OweTotPaa_AMNT          
               @Ln_AppTotPaa_AMNT,              --AppTotPaa_AMNT          
               @Ln_TransactionCaa_AMNT,         --TransactionCaa_AMNT     
               @Ln_OweTotCaa_AMNT,              --OweTotCaa_AMNT          
               @Ln_AppTotCaa_AMNT,              --AppTotCaa_AMNT          
               @Ln_TransactionUpa_AMNT,         --TransactionUpa_AMNT     
               @Ln_OweTotUpa_AMNT,              --OweTotUpa_AMNT          
               @Ln_AppTotUpa_AMNT,              --AppTotUpa_AMNT          
               @Ln_TransactionUda_AMNT,         --TransactionUda_AMNT     
               @Ln_OweTotUda_AMNT,              --OweTotUda_AMNT          
               @Ln_AppTotUda_AMNT,              --AppTotUda_AMNT          
               @Ln_TransactionIvef_AMNT,        --TransactionIvef_AMNT    
               @Ln_OweTotIvef_AMNT,             --OweTotIvef_AMNT         
               @Ln_AppTotIvef_AMNT,             --AppTotIvef_AMNT         
               @Ln_TransactionMedi_AMNT,        --TransactionMedi_AMNT    
               @Ln_OweTotMedi_AMNT,             --OweTotMedi_AMNT         
               @Ln_AppTotMedi_AMNT,             --AppTotMedi_AMNT         
               @Ln_TransactionNffc_AMNT,        --TransactionNffc_AMNT    
               @Ln_OweTotNffc_AMNT,             --OweTotNffc_AMNT         
               @Ln_AppTotNffc_AMNT,             --AppTotNffc_AMNT         
               @Ln_TransactionNonIvd_AMNT,      --TransactionNonIvd_AMNT  
               @Ln_OweTotNonIvd_AMNT,           --OweTotNonIvd_AMNT       
               @Ln_AppTotNonIvd_AMNT,           --AppTotNonIvd_AMNT       
               @Ld_Low_DATE,                    --Batch_DATE              
               0,								--Batch_NUMB              
               0,								--SeqReceipt_NUMB         
               @Lc_Space_TEXT,                  --SourceBatch_CODE        
               @Ld_Low_DATE,                    --Receipt_DATE            
               @Ld_Run_DATE,                    --Distribute_DATE         
               @Lc_Space_TEXT,                  --TypeRecord_CODE         
               @Li_MonthSupport1060_NUMB,       --EventFunctionalSeq_NUMB 
               @Ln_EventGlobalSeq_NUMB,         --EventGlobalSeq_NUMB     
               0,								--TransactionFuture_AMNT  
               @Ln_AppTotFuture_AMNT,           --AppTotFuture_AMNT       
               @Lc_OblxCur_CheckRecipient_ID,   --CheckRecipient_ID       
               @Lc_OblxCur_CheckRecipient_CODE);--CheckRecipient_CODE    

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_LSUP_Y1 FAILED';
         RAISERROR (50001,16,1);
        END
      END;
      
     END TRY

     BEGIN CATCH
       -- Rollback the save point
        IF XACT_STATE() = 1
	    BEGIN
	   	   ROLLBACK TRANSACTION MonthSupportSave
		END
		ELSE
		BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		END
      
      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + '. Error Description = ' + @Ls_DescriptionError_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      -- Checking if error type is 'E' then increment the threshold count
       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExcpThreshold_QNTY = @Ln_ExcpThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
     END CATCH
      
	 SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
	  
     IF @Ln_Commit_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       COMMIT TRANSACTION MonthSupport;
       BEGIN TRANSACTION MonthSupport;
       SET @Ln_Commit_QNTY = 0;
      END
      
      IF @Ln_ExcpThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION MonthSupport;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END
      
	 SKIP_RECORD:
	 
     SET @Ls_Sql_TEXT = 'FETCH Oblx_CUR - 2';
	 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR) + ', Order_SEQ = ' + CAST(@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR) + ', Obligation_SEQ = ' + CAST(@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_OblxCur_MemberMci_IDNO AS VARCHAR) + ', FreqPeriodic_CODE = ' + @Lc_OblxCur_FreqPeriodic_CODE + ', Periodic_AMNT = ' + CAST(@Ln_OblxCur_Periodic_AMNT AS VARCHAR) + ', ExpectToPay_AMNT = ' + CAST(@Ln_OblxCur_ExpectToPay_AMNT AS VARCHAR) + ', BeginObligation_DATE = ' + CAST(@Ld_OblxCur_BeginObligation_DATE AS VARCHAR) + ', EndObligation_DATE = ' + CAST(@Ld_OblxCur_EndObligation_DATE AS VARCHAR) + ', AccrualLast_DATE = ' + CAST(@Ld_OblxCur_AccrualLast_DATE AS VARCHAR) + ', AccrualNext_DATE = ' + CAST(@Ld_OblxCur_AccrualNext_DATE AS VARCHAR) + ', CheckRecipient_ID = ' + @Lc_OblxCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_OblxCur_CheckRecipient_CODE + ', TypeDebt_CODE = ' + @Lc_OblxCur_TypeDebt_CODE + ', Fips_IDNO = ' + @Lc_OblxCur_Fips_IDNO + ', ExpectToPay_CODE = ' + @Lc_OblxCur_ExpectToPay_CODE + ', DirectPay_INDC = ' + @Lc_OblxCur_DirectPay_INDC + ', TypeOrder_CODE = ' + @Lc_OblxCur_TypeOrder_CODE;
     FETCH NEXT FROM Oblx_CUR INTO @Ln_OblxCur_Case_IDNO, @Ln_OblxCur_OrderSeq_NUMB, @Ln_OblxCur_ObligationSeq_NUMB, @Ln_OblxCur_MemberMci_IDNO, @Lc_OblxCur_FreqPeriodic_CODE, @Ln_OblxCur_Periodic_AMNT, @Ln_OblxCur_ExpectToPay_AMNT, @Ld_OblxCur_BeginObligation_DATE, @Ld_OblxCur_EndObligation_DATE, @Ld_OblxCur_AccrualLast_DATE, @Ld_OblxCur_AccrualNext_DATE, @Lc_OblxCur_CheckRecipient_ID, @Lc_OblxCur_CheckRecipient_CODE, @Lc_OblxCur_TypeDebt_CODE, @Lc_OblxCur_Fips_IDNO, @Lc_OblxCur_ExpectToPay_CODE, @Lc_OblxCur_DirectPay_INDC, @Lc_OblxCur_TypeOrder_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Oblx_CUR;

   DEALLOCATE Oblx_CUR;
   
   /*
   		The Parameter (PARM_Y1) table will be updated after the successful processing of all obligations.
   */	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;
    
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'') + ', Start_DATE = ' + ISNULL(CAST( @Ld_Create_DATE AS VARCHAR ),'') + ', Job_ID = ' + ISNULL(@Lc_Job_ID,'') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'') + ', Procedure_NAME = ' + ISNULL(@Ls_Process_NAME,'') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT,'') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Create_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY	= @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION MonthSupport;
  END TRY

  BEGIN CATCH
  -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION MonthSupport;
    END;
   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS('LOCAL', 'Oblx_CUR') IN (0, 1)
    BEGIN
     CLOSE Oblx_CUR;
     DEALLOCATE Oblx_CUR;
    END
   -- Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE			  = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Create_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY	= @Ln_ProcessedRecordCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
