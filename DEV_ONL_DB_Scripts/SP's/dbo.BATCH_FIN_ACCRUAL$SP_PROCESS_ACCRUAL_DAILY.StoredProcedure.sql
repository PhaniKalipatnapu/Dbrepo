/****** Object:  StoredProcedure [dbo].[BATCH_FIN_ACCRUAL$SP_PROCESS_ACCRUAL_DAILY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_FIN_ACCRUAL$SP_PROCESS_ACCRUAL_DAILY]
AS
 /*
 -------------------------------------------------------------------------------------------------------------------
 Procedure Name 	: BATCH_FIN_ACCRUAL$SP_PROCESS_ACCRUAL_DAILY
 Programmer Name	: IMP Team
 Description		: This procedure considers all open cases and obligations where the obligation end date is equal to or 
 					  greater than the current date.The program will then process each obligation due for accrual and accrue 
 					  for the given day and frequency. The Daily Accrual Batch Program processes all open cases with open 
 					  obligations (where the obligation end date is equal to or greater than the current date). The program
 					  will take each OBLE_Y1 due for accrual and accrue for the period specified on the obligation by means
 					  of the frequency. The Support Log (SLOG screen)LSUP table will be updated with the new charge Value 
 					  towards the current support owed.
 Frequency   		: DAILY
 Developed On  		: 4/12/2011
 Called By   		: None
 Called On			: BATCH_COMMON$SP_GET_BATCH_DETAILS2, BATCH_COMMON$SP_UPDATE_PARM_DATE, BATCH_COMMON$SP_BSTL_LOG,
 					 BATCH_COMMON$SP_GET_ERROR_DESCRIPTION,BATCH_COMMON$SP_ACCRUAL, BATCH_COMMON$SP_CIRCULAR_RULE
 --------------------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No		    : 1.0
 --------------------------------------------------------------------------------------------------------------------
 */
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Accrual1050_NUMB            INT = 1050,
          @Lc_TypeErrorE_CODE             CHAR(1) = 'E',
          @Lc_ElogEntry_INDC              CHAR(1) = 'N',
          @Lc_No_INDC                     CHAR(1) = 'N',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_CaseStatusOpen_CODE         CHAR(1) = 'O',
          @Lc_WelfareTypeNonTanf_CODE     CHAR(1) = 'N',
          @Lc_WelfareTypeTanf_CODE        CHAR(1) = 'A',
          @Lc_WelfareTypeMedicaid_CODE    CHAR(1) = 'M',
          @Lc_WelfareTypeFosterCare_CODE  CHAR(1) = 'F',
          @Lc_WelfareTypeNffc_CODE        CHAR(1) = 'J',
          @Lc_WelfareTypeNonIvd_CODE      CHAR(1) = 'H',
          @Lc_TypeRecordOriginal_CODE     CHAR(1) = 'O',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_DebtTypeMedicalSupport_CODE CHAR(2) = 'MS',
          @Lc_DebtTypeGeneticTest_CODE    CHAR(2) = 'GT',
          @Lc_DebtTypeChildSupport_CODE   CHAR(2) = 'CS',
          @Lc_DebtTypeSpousalSupport_CODE CHAR(2) = 'SS',
          @Lc_TypeEntityCase_CODE         CHAR(4) = 'CASE',
          @Lc_TypeEntityDtacl_CODE        CHAR(5) = 'DTACL',
          @Lc_BateErrorUnknown_CODE       CHAR(5) = 'E1424',
          @Lc_Job_ID                      CHAR(7) = 'DEB0530',
          @Lc_JobMonthSupport_IDNO        CHAR(7) = 'DEB6300',
          @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_ID             CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_PROCESS_ACCRUAL_DAILY',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_FIN_ACCRUAL',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_Create_DATE                 DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_CommitFreqParm_QNTY             NUMERIC(5) =0,
          @Ln_CommitFreqMonthSupportParm_QNTY NUMERIC(5) =0,
          @Ln_ExceptionThreshold_QNTY         NUMERIC(5) =0,
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5) =0,
          @Ln_ExceptionThresholdMSupParm_QNTY NUMERIC(5) =0,
          @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
          @Ln_PreviousCase_IDNO               NUMERIC(6)=0,
          @Ln_MtdAccrual_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_CursorPosition_QNTY             NUMERIC(11) = 0,
          @Ln_ProcessedRecordCount_QNTY       NUMERIC(11) = 0,
          @Ln_Error_NUMB                      NUMERIC(11),
          @Ln_ErrorLine_NUMB                  NUMERIC(11),
          @Ln_TransactionPaa_AMNT             NUMERIC(11, 2) = 0,
          @Ln_TransactionNaa_AMNT             NUMERIC(11, 2) = 0,
          @Ln_TransactionMedi_AMNT            NUMERIC(11, 2) = 0,
          @Ln_TransactionIvef_AMNT            NUMERIC(11, 2) = 0,
          @Ln_TransactionUda_AMNT             NUMERIC(11, 2) = 0,
          @Ln_TransactionUpa_AMNT             NUMERIC(11, 2) = 0,
          @Ln_TransactionTaa_AMNT             NUMERIC(11, 2) = 0,
          @Ln_TransactionCaa_AMNT             NUMERIC(11, 2) = 0,
          @Ln_TransactionNffc_AMNT            NUMERIC(11, 2) = 0,
          @Ln_TransactionNonIvd_AMNT          NUMERIC(11, 2) = 0,
          @Ln_TransactionExptPay_AMNT         NUMERIC(11, 2) = 0,
          @Ln_TransactionCurSup_AMNT          NUMERIC(11, 2) = 0,
          @Ln_ArrPaa_AMNT                     NUMERIC(11, 2) = 0,
          @Ln_ArrNaa_AMNT                     NUMERIC(11, 2) = 0,
          @Ln_ArrCaa_AMNT                     NUMERIC(11, 2) = 0,
          @Ln_ArrTaa_AMNT                     NUMERIC(11, 2) = 0,
          @Ln_ArrUpa_AMNT                     NUMERIC(11, 2) = 0,
          @Ln_ArrUda_AMNT                     NUMERIC(11, 2) = 0,
          @Ln_OweTotExptPay_AMNT              NUMERIC(11, 2) = 0,
          @Ln_AppTotExptPay_AMNT              NUMERIC(11, 2) = 0,
          @Ln_OweTotNaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_AppTotNaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_OweTotTaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_AppTotTaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_OweTotPaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_AppTotPaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_OweTotCaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_AppTotCaa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_OweTotUpa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_AppTotUpa_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_OweTotUda_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_AppTotUda_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_OweTotIvef_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_AppTotIvef_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_OweTotNffc_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_AppTotNffc_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_OweTotNonIvd_AMNT               NUMERIC(11, 2) = 0,
          @Ln_AppTotNonIvd_AMNT               NUMERIC(11, 2) = 0,
          @Ln_OweTotMedi_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_AppTotMedi_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_AppTotFuture_AMNT               NUMERIC(11, 2) = 0,
          @Ln_OweTotCurSup_AMNT               NUMERIC(11, 2) = 0,
          @Ln_AppTotCurSup_AMNT               NUMERIC(11, 2) = 0,
          @Ln_MtdCurSupOwed_AMNT              NUMERIC(11, 2) = 0,
          @Ln_EventGlobalSeq_NUMB             NUMERIC(19),
          @Li_FetchStatus_QNTY                SMALLINT,
          @Li_Rowcount_QNTY                   SMALLINT,
          @Lc_AcclInserted_INDC               CHAR(1),
          @Lc_TypeWelfare_CODE                CHAR(1),
          @Lc_MtdProcess_CODE                 CHAR(1),
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_Msg_CODE                        CHAR(5) = '',
          @Ls_Sql_TEXT                        VARCHAR(100) = '',
          @Ls_CursorLocation_TEXT             VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                    VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT           VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT                 VARCHAR(4000) = '',
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Processing_DATE                 DATE,
          @Ld_MonthFirst_DATE                 DATE,
          @Ld_RunMonthSupport_DATE            DATE,
          @Ld_LastRunMonthsupport_DATE        DATE,
          @Ld_AccrualNext_DATE                DATE,
          @Ld_AccrualCurrent_DATE             DATE,
          @Ld_AccrualLast_DATE                DATE,
          @Ld_EndObligation_DATE              DATE;
  DECLARE @Ln_ObleCur_Case_IDNO            NUMERIC(6),
          @Ln_ObleCur_OrderSeq_NUMB        NUMERIC(2),
          @Ln_ObleCur_ObligationSeq_NUMB   NUMERIC(2),
          @Ln_ObleCur_MemberMci_IDNO       NUMERIC(10),
          @Lc_ObleCur_FreqPeriodic_CODE    CHAR(1),
          @Ln_ObleCur_Periodic_AMNT        NUMERIC(11, 2),
          @Ln_ObleCur_ExpectToPay_AMNT     NUMERIC(11, 2),
          @Ld_ObleCur_BeginObligation_DATE DATE,
          @Ld_ObleCur_EndObligation_DATE   DATE,
          @Ld_ObleCur_AccrualLast_DATE     DATE,
          @Ld_ObleCur_AccrualNext_DATE     DATE,
          @Lc_ObleCur_CheckRecipient_ID    CHAR(10),
          @Lc_ObleCur_CheckRecipient_CODE  CHAR(1),
          @Lc_ObleCur_TypeDebt_CODE        CHAR(2),
          @Lc_ObleCur_Fips_CODE            CHAR(7);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

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

   SET @Ls_Sql_TEXT = 'PARM DATE checking';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ld_Processing_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);

   BEGIN TRANSACTION ACCRUAL;

   -- cursor loop1 Starts
   SET @Ls_Sql_TEXT='WHILE 1';
   SET @Ls_Sqldata_TEXT ='Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Processing_DATE = ' + CAST(@Ld_Processing_DATE AS VARCHAR);

   /*If for some reason, the process was skipped on any day, the process accrues for the skipped days until the current date.*/
   WHILE @Ld_Processing_DATE <= @Ld_Run_DATE
    BEGIN
     SET @Ld_MonthFirst_DATE = DATEADD(DAY, 1 - (DATEPART(DAY, @Ld_Processing_DATE)), @Ld_Processing_DATE);

     IF @Ld_Processing_DATE = @Ld_MonthFirst_DATE
      BEGIN
       SET @Ls_Sql_TEXT = 'GET THE RUN DATE FOR MONTH SUPPORT BATCH ';
       SET @Ls_Sqldata_TEXT = 'JobMonthSupport_IDNO = ' + @Lc_JobMonthSupport_IDNO;

       EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
        @Ac_Job_ID                  = @Lc_JobMonthSupport_IDNO,
        @Ad_Run_DATE                = @Ld_RunMonthSupport_DATE OUTPUT,
        @Ad_LastRun_DATE            = @Ld_LastRunMonthsupport_DATE OUTPUT,
        @An_CommitFreq_QNTY         = @Ln_CommitFreqMonthSupportParm_QNTY OUTPUT,
        @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdMSupParm_QNTY OUTPUT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT ='MONTH SUPPORT VALIDATION';
       SET @Ls_Sqldata_TEXT = 'LastRunMonthsupport_DATE = ' + CAST(@Ld_LastRunMonthsupport_DATE AS VARCHAR) + ', MonthFirst_DATE = ' + CAST(@Ld_MonthFirst_DATE AS VARCHAR);

       IF @Ld_LastRunMonthsupport_DATE <> DATEADD (DAY, -1, @Ld_MonthFirst_DATE)
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'MONTH SUPPORT BATCH WAS NOT RUN FOR PREVIOUS MONTH';

         RAISERROR (50001,16,1);
        END;
      END;

     SET @Ls_CursorLocation_TEXT = ' Processing_DATE = ' + ISNULL (CAST (@Ld_Processing_DATE AS VARCHAR), '');
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_Accrual1050_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Lc_Job_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Processing_DATE AS VARCHAR) + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_ID;

     /*
     	For the accruals to be viewed from the Event Log- ELOG screen the Global Sequence ID is used to identify the 
     	accrual for each individual day
     	
     	All obligations, which accrue on the same day, will have the same Sequence Event Global ID
     */
     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB =@Li_Accrual1050_NUMB,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Processing_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Lc_AcclInserted_INDC = @Lc_No_INDC;
     SET @Ln_PreviousCase_IDNO = 0;

     /*
     	For a one time frequency obligation with a future effective date (entered using the OWIZ screen), the system selects 
     	the obligation to charge, when the charge date equals to the processing date.
     */
     DECLARE Oble_CUR INSENSITIVE CURSOR FOR
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
             a.Fips_CODE
        FROM OBLE_Y1 a,
             CASE_Y1 b
       WHERE b.Case_IDNO = a.Case_IDNO
         AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
         --Process date should fall between begin and end date of the obligation 
         AND @Ld_Processing_DATE BETWEEN a.BeginObligation_DATE AND a.EndObligation_DATE
         --The next accrual date on the obligation records must be equal to the process date 
         AND a.AccrualNext_DATE = @Ld_Processing_DATE
         -- Must have at least one active obligation(CS - Child Support, MS - Medical Support, SS - Spousal Support, GT - Genetic Test)
         AND a.TypeDebt_CODE IN (@Lc_DebtTypeChildSupport_CODE, @Lc_DebtTypeMedicalSupport_CODE, @Lc_DebtTypeSpousalSupport_CODE, @Lc_DebtTypeGeneticTest_CODE)
         AND a.EndValidity_DATE = @Ld_High_DATE
       ORDER BY a.Case_IDNO,
                a.OrderSeq_NUMB,
                a.ObligationSeq_NUMB;

     SET @Ls_Sql_TEXT = 'OPEN Oble_CUR';
     SET @Ls_Sqldata_TEXT ='';

     OPEN Oble_CUR;

     SET @Ls_Sql_TEXT = 'FETCH Oble_CUR - 1';
     SET @Ls_Sqldata_TEXT ='';

     FETCH NEXT FROM Oble_CUR INTO @Ln_ObleCur_Case_IDNO, @Ln_ObleCur_OrderSeq_NUMB, @Ln_ObleCur_ObligationSeq_NUMB, @Ln_ObleCur_MemberMci_IDNO, @Lc_ObleCur_FreqPeriodic_CODE, @Ln_ObleCur_Periodic_AMNT, @Ln_ObleCur_ExpectToPay_AMNT, @Ld_ObleCur_BeginObligation_DATE, @Ld_ObleCur_EndObligation_DATE, @Ld_ObleCur_AccrualLast_DATE, @Ld_ObleCur_AccrualNext_DATE, @Lc_ObleCur_CheckRecipient_ID, @Lc_ObleCur_CheckRecipient_CODE, @Lc_ObleCur_TypeDebt_CODE, @Lc_ObleCur_Fips_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'WHILE - 2';
     SET @Ls_Sqldata_TEXT ='';

     /*If for some reason, the process was skipped on any day, the process accrues for the skipped days until the current date.*/
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       BEGIN TRY
        SAVE TRANSACTION ACCRUAL_SAVE

        SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
        SET @Ln_CursorPosition_QNTY = @Ln_CursorPosition_QNTY + 1;
        SET @Ls_CursorLocation_TEXT = 'Processing_DATE = ' + CAST(@Ld_Processing_DATE AS VARCHAR) + ', CursorPosition_QNTY = ' + ISNULL (CAST (@Ln_CursorPosition_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST (@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_ObleCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObleCur_ObligationSeq_NUMB AS VARCHAR), '');
        SET @Ls_BateRecord_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', ORDER SEQUENCE NUMBER = ' + ISNULL(CAST(@Ln_ObleCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST(@Ln_ObleCur_ObligationSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ObleCur_MemberMci_IDNO AS VARCHAR), '') + ', FreqPeriodic_CODE = ' + ISNULL(CAST(@Lc_ObleCur_FreqPeriodic_CODE AS VARCHAR), '') + ', Periodic_AMNT = ' + ISNULL(CAST(@Ln_ObleCur_Periodic_AMNT AS VARCHAR), '') + ', ExpectToPay_AMNT = ' + ISNULL(CAST(@Ln_ObleCur_ExpectToPay_AMNT AS VARCHAR), '') + ', BeginObligation_DATE = ' + ISNULL(CAST(@Ld_ObleCur_BeginObligation_DATE AS VARCHAR), '') + ', EndObligation_DATE = ' + ISNULL(CAST(@Ld_ObleCur_EndObligation_DATE AS VARCHAR), '') + ', AccrualLast_DATE = ' + ISNULL(CAST(@Ld_ObleCur_AccrualLast_DATE AS VARCHAR), '') + ', AccrualNext_DATE = ' + ISNULL(CAST(@Ld_ObleCur_AccrualNext_DATE AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_ObleCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(CAST(@Lc_ObleCur_CheckRecipient_CODE AS VARCHAR), '') + ', TypeDebt_CODE = ' + ISNULL(CAST(@Lc_ObleCur_TypeDebt_CODE AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(CAST(@Lc_ObleCur_Fips_CODE AS VARCHAR), '');
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_ErrorMessage_TEXT ='';

        IF @Ln_PreviousCase_IDNO = 0
            OR @Ln_PreviousCase_IDNO != @Ln_ObleCur_Case_IDNO
         BEGIN
          SET @Ln_PreviousCase_IDNO = @Ln_ObleCur_Case_IDNO;
          SET @Lc_ElogEntry_INDC = @Lc_No_INDC;
         END;

        SET @Ld_AccrualNext_DATE = @Ld_ObleCur_AccrualNext_DATE;
        SET @Ld_AccrualCurrent_DATE = @Ld_AccrualNext_DATE;
        SET @Ld_AccrualLast_DATE = @Ld_ObleCur_AccrualLast_DATE;

        IF @Ld_ObleCur_AccrualLast_DATE = @Ld_Low_DATE
         BEGIN
          SET @Ld_AccrualLast_DATE = @Ld_ObleCur_BeginObligation_DATE;
         END;

        SET @Ld_EndObligation_DATE = @Ld_ObleCur_EndObligation_DATE;

        IF @Ld_EndObligation_DATE > @Ld_Processing_DATE
         BEGIN
          SET @Ld_EndObligation_DATE = @Ld_Processing_DATE;
         END;

        SET @Ln_TransactionNaa_AMNT = 0;
        SET @Ln_TransactionExptPay_AMNT = 0;
        SET @Ln_TransactionPaa_AMNT = 0;
        SET @Ln_TransactionCaa_AMNT = 0;
        SET @Ln_TransactionTaa_AMNT = 0;
        SET @Ln_TransactionUda_AMNT = 0;
        SET @Ln_TransactionUpa_AMNT = 0;
        SET @Ln_TransactionIvef_AMNT = 0;
        SET @Ln_TransactionMedi_AMNT = 0;
        SET @Ln_TransactionNffc_AMNT = 0;
        SET @Ln_TransactionNonIvd_AMNT = 0;
        SET @Ln_ArrPaa_AMNT = 0;
        SET @Ln_ArrNaa_AMNT = 0;
        SET @Ln_ArrCaa_AMNT = 0;
        SET @Ln_ArrTaa_AMNT = 0;
        SET @Ln_ArrUpa_AMNT = 0;
        SET @Ln_ArrUda_AMNT = 0;

        IF @Ld_AccrualNext_DATE <= @Ld_EndObligation_DATE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT_VMHIS';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST (@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_ObleCur_MemberMci_IDNO AS VARCHAR), '') + ', Processing_DATE = ' + ISNULL (CAST (@Ld_Processing_DATE AS VARCHAR), '');

          --Get the member program status as of the accrual date from MHIS-Member Welfare Details for the obligation
          SELECT TOP 1 @Lc_TypeWelfare_CODE = ISNULL (a.TypeWelfare_CODE, @Lc_WelfareTypeNonTanf_CODE)
            FROM MHIS_Y1 a
           WHERE a.Case_IDNO = @Ln_ObleCur_Case_IDNO
             AND a.MemberMci_IDNO = @Ln_ObleCur_MemberMci_IDNO
             AND @Ld_Processing_DATE BETWEEN a.Start_DATE AND a.End_DATE;

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          /*If there is no record in MHIS_Y1 for the current date for that case and member combination then the member status is
            defaulted to be ‘N’ (Non-TANF).
           */
          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonTanf_CODE;
           END;

          SET @Ln_TransactionCurSup_AMNT = 0;
          SET @Ln_TransactionExptPay_AMNT = 0;
          SET @Ln_OweTotCurSup_AMNT = 0;
          SET @Ln_AppTotCurSup_AMNT = 0;
          SET @Ln_OweTotExptPay_AMNT = 0;
          SET @Ln_AppTotExptPay_AMNT = 0;
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
          SET @Ln_TransactionNaa_AMNT = 0;
          SET @Ln_TransactionPaa_AMNT = 0;
          SET @Ln_TransactionTaa_AMNT = 0;
          SET @Ln_TransactionCaa_AMNT = 0;
          SET @Ln_TransactionUpa_AMNT = 0;
          SET @Ln_TransactionUda_AMNT = 0;
          SET @Ln_TransactionIvef_AMNT = 0;
          SET @Ln_TransactionMedi_AMNT = 0;
          SET @Ln_TransactionNffc_AMNT = 0;
          SET @Ln_TransactionNonIvd_AMNT = 0;
          SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST (@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_ObleCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObleCur_ObligationSeq_NUMB AS VARCHAR), '');

          /*
          The latest balances (as of accrual run date) for each obligation is obtained from Support Log (SLOG screen) LSUP_Y1 table by passing the Obligation Key (Case ID, sequence order and sequence obligation). 
          */
          SELECT @Ln_OweTotCurSup_AMNT = a.OweTotCurSup_AMNT,
                 @Ln_AppTotCurSup_AMNT = a.AppTotCurSup_AMNT,
                 @Ln_MtdCurSupOwed_AMNT = a.MtdCurSupOwed_AMNT,
                 @Ln_OweTotExptPay_AMNT = a.OweTotExptPay_AMNT,
                 @Ln_AppTotExptPay_AMNT = a.AppTotExptPay_AMNT,
                 @Ln_OweTotNaa_AMNT = a.OweTotNaa_AMNT,
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
                 @Ln_AppTotFuture_AMNT = a.AppTotFuture_AMNT
            FROM LSUP_Y1 a
           WHERE a.Case_IDNO = @Ln_ObleCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_ObleCur_OrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_ObleCur_ObligationSeq_NUMB
             AND a.SupportYearMonth_NUMB = (SELECT MAX (b.SupportYearMonth_NUMB)
                                              FROM LSUP_Y1 b
                                             WHERE b.Case_IDNO = @Ln_ObleCur_Case_IDNO
                                               AND b.OrderSeq_NUMB = @Ln_ObleCur_OrderSeq_NUMB
                                               AND b.ObligationSeq_NUMB = @Ln_ObleCur_ObligationSeq_NUMB)
             AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB)
                                            FROM LSUP_Y1 b
                                           WHERE b.Case_IDNO = @Ln_ObleCur_Case_IDNO
                                             AND b.OrderSeq_NUMB = @Ln_ObleCur_OrderSeq_NUMB
                                             AND b.ObligationSeq_NUMB = @Ln_ObleCur_ObligationSeq_NUMB
                                             AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

          SET @Ld_AccrualCurrent_DATE = @Ld_AccrualNext_DATE;
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ACCRUAL';
          SET @Ls_Sqldata_TEXT = 'FreqPeriodic_CODE = ' + @Lc_ObleCur_FreqPeriodic_CODE + ', Periodic_AMNT = ' + CAST (@Ln_ObleCur_Periodic_AMNT AS VARCHAR) + ', ExpectToPay_AMNT = ' + CAST (@Ln_ObleCur_ExpectToPay_AMNT AS VARCHAR) + ', BeginObligation_DATE = ' + CAST (@Ld_ObleCur_BeginObligation_DATE AS VARCHAR) + ', EndObligation_DATE = ' + CAST (@Ld_ObleCur_EndObligation_DATE AS VARCHAR) + ', EndObligation_DATE = ' + CAST (@Ld_EndObligation_DATE AS VARCHAR);

          EXECUTE BATCH_COMMON$SP_ACCRUAL
           @Ac_FreqPeriodic_CODE       = @Lc_ObleCur_FreqPeriodic_CODE,
           @An_Periodic_AMNT           = @Ln_ObleCur_Periodic_AMNT,
           @An_ExpectToPay_AMNT        = @Ln_ObleCur_ExpectToPay_AMNT,
           @Ad_BeginObligation_DATE    = @Ld_ObleCur_BeginObligation_DATE,
           @Ad_EndObligation_DATE      = @Ld_ObleCur_EndObligation_DATE,
           @Ad_AccrualEnd_DATE         = @Ld_EndObligation_DATE,
           @Ad_AccrualNext_DATE        = @Ld_AccrualNext_DATE OUTPUT,
           @Ad_AccrualLast_DATE        = @Ld_AccrualLast_DATE OUTPUT,
           @An_TransactionCurSup_AMNT  = @Ln_TransactionCurSup_AMNT OUTPUT,
           @An_TransactionExptPay_AMNT = @Ln_TransactionExptPay_AMNT OUTPUT,
           @An_MtdAccrual_AMNT         = @Ln_MtdAccrual_AMNT OUTPUT,
           @Ac_MtdProcess_INDC         = @Lc_MtdProcess_CODE OUTPUT,
           @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END;

         /*
         When debt type is GT (Genetic Testing), the total obligation accrued for the day will be added to the total NAA amount owed in LSUP_Y1 table. 
         */
          -- GT - Start -- 	
          IF @Lc_ObleCur_TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
           BEGIN
            SET @Ln_TransactionNaa_AMNT = @Ln_TransactionCurSup_AMNT;
           END
          -- GT - End --
          /*
          When the obligation debt type code is equal to Medical Support (MS) and the member program type is TANF (A) or
          Medicaid (M) or Foster Care (F), the obligation charged amount will be added to the total Medicaid amount owed in 
          LSUP_Y1 MEDI bucket for the obligation debt type.
          */
          -- MS - Start --
          ELSE IF @Lc_ObleCur_TypeDebt_CODE = @Lc_DebtTypeMedicalSupport_CODE
             AND @Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeMedicaid_CODE, @Lc_WelfareTypeFosterCare_CODE)
           BEGIN
            SET @Ln_TransactionMedi_AMNT = @Ln_TransactionCurSup_AMNT;
            SET @Ln_OweTotMedi_AMNT = @Ln_OweTotMedi_AMNT + @Ln_TransactionCurSup_AMNT;
           END
          -- MS - End -- 
          ELSE
           -- CS, SS - Start -- 	
           BEGIN
            /*
            If the member program type is TANF (A) and debt type is not equal to MS, the total obligation accrued will be added
            to the total PAA amount owed in LSUP_Y1 table for the obligation debt type.
            */
            IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
             BEGIN
              SET @Ln_TransactionPaa_AMNT = @Ln_TransactionCurSup_AMNT;
             END

            /*
            If the member program type is Foster Care (F), the total obligation accrued will be added to the total IVEF amount
            owed in LSUP_Y1 table for the obligation debt type.
            */
            IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE
             BEGIN
              SET @Ln_TransactionIvef_AMNT = @Ln_TransactionCurSup_AMNT;
              SET @Ln_OweTotIvef_AMNT = @Ln_OweTotIvef_AMNT + @Ln_TransactionIvef_AMNT;
             END;

            /*
            If the member program type is Non IV-D (H), the total obligation accrued will be added to the total NIVD amount
            owed in LSUP_Y1 table for the obligation debt type.
            */
            IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIvd_CODE
             BEGIN
              SET @Ln_TransactionNonIvd_AMNT = @Ln_TransactionCurSup_AMNT;
              SET @Ln_OweTotNonIvd_AMNT = @Ln_OweTotNonIvd_AMNT + @Ln_TransactionNonIvd_AMNT;
             END;

            IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNffc_CODE
             BEGIN
              SET @Ln_TransactionNffc_AMNT = @Ln_TransactionCurSup_AMNT;
              SET @Ln_OweTotNffc_AMNT = @Ln_OweTotNffc_AMNT + @Ln_TransactionNffc_AMNT;
             END;

            /*
            When the member status is Non TANF (N) or Medicaid (M) and debt type is not equal to MS, the total obligation accrued will be added to the
            total NAA amount owed in LSUP_Y1 table for the obligation debt type.
            */
            IF @Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
             BEGIN
              SET @Ln_TransactionNaa_AMNT = @Ln_TransactionCurSup_AMNT;
             END
           END

          -- CS, SS - End -- 
          SET @Ln_ArrPaa_AMNT = @Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT;
          SET @Ln_ArrNaa_AMNT = @Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT;
          SET @Ln_ArrCaa_AMNT = @Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT;
          SET @Ln_ArrUpa_AMNT = @Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT;
          SET @Ln_ArrUda_AMNT = @Ln_OweTotUda_AMNT - @Ln_AppTotUda_AMNT;
          SET @Ln_ArrTaa_AMNT = @Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT;
		
		-- Circular Rule calculation will be applied only for other than MS debt type.
		IF @Lc_ObleCur_TypeDebt_CODE NOT IN(@Lc_DebtTypeMedicalSupport_CODE)
		BEGIN
		
          IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
           BEGIN
            SET @Ln_ArrPaa_AMNT = (@Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT) + @Ln_TransactionPaa_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
           END;
          ELSE
           BEGIN
            IF @Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
             BEGIN
              SET @Ln_ArrNaa_AMNT = (@Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT) + @Ln_TransactionNaa_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
             END;
           END;

          IF @Ln_ArrPaa_AMNT < 0
              OR @Ln_ArrUda_AMNT < 0
              OR @Ln_ArrNaa_AMNT < 0
              OR @Ln_ArrCaa_AMNT < 0
              OR @Ln_ArrUpa_AMNT < 0
              OR @Ln_ArrTaa_AMNT < 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CIRCULAR_RULE';
            SET @Ls_Sqldata_TEXT = '';

            EXECUTE BATCH_COMMON$SP_CIRCULAR_RULE
             @An_ArrPaa_AMNT         = @Ln_ArrPaa_AMNT OUTPUT,
             @An_TransactionPaa_AMNT = @Ln_TransactionPaa_AMNT OUTPUT,
             @An_ArrUda_AMNT         = @Ln_ArrUda_AMNT OUTPUT,
             @An_TransactionUda_AMNT = @Ln_TransactionUda_AMNT OUTPUT,
             @An_ArrNaa_AMNT         = @Ln_ArrNaa_AMNT OUTPUT,
             @An_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT OUTPUT,
             @An_ArrCaa_AMNT         = @Ln_ArrCaa_AMNT OUTPUT,
             @An_TransactionCaa_AMNT = @Ln_TransactionCaa_AMNT OUTPUT,
             @An_ArrUpa_AMNT         = @Ln_ArrUpa_AMNT OUTPUT,
             @An_TransactionUpa_AMNT = @Ln_TransactionUpa_AMNT OUTPUT,
             @An_ArrTaa_AMNT         = @Ln_ArrTaa_AMNT OUTPUT,
             @An_TransactionTaa_AMNT = @Ln_TransactionTaa_AMNT OUTPUT;
           END;
		END;
          SET @Ln_OweTotUda_AMNT = @Ln_OweTotUda_AMNT + @Ln_TransactionUda_AMNT;
          SET @Ln_OweTotCaa_AMNT = @Ln_OweTotCaa_AMNT + @Ln_TransactionCaa_AMNT;
          SET @Ln_OweTotTaa_AMNT = @Ln_OweTotTaa_AMNT + @Ln_TransactionTaa_AMNT;
          SET @Ln_OweTotUpa_AMNT = @Ln_OweTotUpa_AMNT + @Ln_TransactionUpa_AMNT;
          SET @Ln_OweTotPaa_AMNT = @Ln_OweTotPaa_AMNT + @Ln_TransactionPaa_AMNT;
          SET @Ln_OweTotNaa_AMNT = @Ln_OweTotNaa_AMNT + @Ln_TransactionNaa_AMNT;

          IF @Ln_TransactionPaa_AMNT > 0
              OR @Ln_TransactionNaa_AMNT > 0
              OR @Ln_TransactionCaa_AMNT > 0
              OR @Ln_TransactionTaa_AMNT > 0
              OR @Ln_TransactionUda_AMNT > 0
              OR @Ln_TransactionUpa_AMNT > 0
              OR @Ln_TransactionIvef_AMNT > 0
              OR @Ln_TransactionMedi_AMNT > 0
              OR @Ln_TransactionNffc_AMNT > 0
              OR @Ln_TransactionNonIvd_AMNT > 0
           BEGIN
            SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_ObligationSeq_NUMB AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE, '') + ', MtdCurSupOwed_AMNT = ' + ISNULL(CAST(@Ln_MtdCurSupOwed_AMNT AS VARCHAR), '') + ', TransactionCurSup_AMNT = ' + ISNULL(CAST(@Ln_TransactionCurSup_AMNT AS VARCHAR), '') + ', AppTotCurSup_AMNT = ' + ISNULL(CAST(@Ln_AppTotCurSup_AMNT AS VARCHAR), '') + ', TransactionExptPay_AMNT = ' + ISNULL(CAST(@Ln_TransactionExptPay_AMNT AS VARCHAR), '') + ', OweTotExptPay_AMNT = ' + ISNULL(CAST(@Ln_OweTotExptPay_AMNT AS VARCHAR), '') + ', AppTotExptPay_AMNT = ' + ISNULL(CAST(@Ln_AppTotExptPay_AMNT AS VARCHAR), '') + ', TransactionNaa_AMNT = ' + ISNULL(CAST(@Ln_TransactionNaa_AMNT AS VARCHAR), '') + ', OweTotNaa_AMNT = ' + ISNULL(CAST(@Ln_OweTotNaa_AMNT AS VARCHAR), '') + ', AppTotNaa_AMNT = ' + ISNULL(CAST(@Ln_AppTotNaa_AMNT AS VARCHAR), '') + ', TransactionTaa_AMNT = ' + ISNULL(CAST(@Ln_TransactionTaa_AMNT AS VARCHAR), '') + ', OweTotTaa_AMNT = ' + ISNULL(CAST(@Ln_OweTotTaa_AMNT AS VARCHAR), '') + ', AppTotTaa_AMNT = ' + ISNULL(CAST(@Ln_AppTotTaa_AMNT AS VARCHAR), '') + ', TransactionPaa_AMNT = ' + ISNULL(CAST(@Ln_TransactionPaa_AMNT AS VARCHAR), '') + ', OweTotPaa_AMNT = ' + ISNULL(CAST(@Ln_OweTotPaa_AMNT AS VARCHAR), '') + ', AppTotPaa_AMNT = ' + ISNULL(CAST(@Ln_AppTotPaa_AMNT AS VARCHAR), '') + ', TransactionCaa_AMNT = ' + ISNULL(CAST(@Ln_TransactionCaa_AMNT AS VARCHAR), '') + ', OweTotCaa_AMNT = ' + ISNULL(CAST(@Ln_OweTotCaa_AMNT AS VARCHAR), '') + ', AppTotCaa_AMNT = ' + ISNULL(CAST(@Ln_AppTotCaa_AMNT AS VARCHAR), '') + ', TransactionUpa_AMNT = ' + ISNULL(CAST(@Ln_TransactionUpa_AMNT AS VARCHAR), '') + ', OweTotUpa_AMNT = ' + ISNULL(CAST(@Ln_OweTotUpa_AMNT AS VARCHAR), '') + ', AppTotUpa_AMNT = ' + ISNULL(CAST(@Ln_AppTotUpa_AMNT AS VARCHAR), '') + ', TransactionUda_AMNT = ' + ISNULL(CAST(@Ln_TransactionUda_AMNT AS VARCHAR), '') + ', OweTotUda_AMNT = ' + ISNULL(CAST(@Ln_OweTotUda_AMNT AS VARCHAR), '') + ', AppTotUda_AMNT = ' + ISNULL(CAST(@Ln_AppTotUda_AMNT AS VARCHAR), '') + ', TransactionIvef_AMNT = ' + ISNULL(CAST(@Ln_TransactionIvef_AMNT AS VARCHAR), '') + ', OweTotIvef_AMNT = ' + ISNULL(CAST(@Ln_OweTotIvef_AMNT AS VARCHAR), '') + ', AppTotIvef_AMNT = ' + ISNULL(CAST(@Ln_AppTotIvef_AMNT AS VARCHAR), '') + ', TransactionMedi_AMNT = ' + ISNULL(CAST(@Ln_TransactionMedi_AMNT AS VARCHAR), '') + ', OweTotMedi_AMNT = ' + ISNULL(CAST(@Ln_OweTotMedi_AMNT AS VARCHAR), '') + ', AppTotMedi_AMNT = ' + ISNULL(CAST(@Ln_AppTotMedi_AMNT AS VARCHAR), '') + ', TransactionNffc_AMNT = ' + ISNULL(CAST(@Ln_TransactionNffc_AMNT AS VARCHAR), '') + ', OweTotNffc_AMNT = ' + ISNULL(CAST(@Ln_OweTotNffc_AMNT AS VARCHAR), '') + ', AppTotNffc_AMNT = ' + ISNULL(CAST(@Ln_AppTotNffc_AMNT AS VARCHAR), '') + ', TransactionNonIvd_AMNT = ' + ISNULL(CAST(@Ln_TransactionNonIvd_AMNT AS VARCHAR), '') + ', OweTotNonIvd_AMNT = ' + ISNULL(CAST(@Ln_OweTotNonIvd_AMNT AS VARCHAR), '') + ', AppTotNonIvd_AMNT = ' + ISNULL(CAST(@Ln_AppTotNonIvd_AMNT AS VARCHAR), '') + ', AppTotFuture_AMNT = ' + ISNULL(CAST(@Ln_AppTotFuture_AMNT AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Distribute_DATE = ' + ISNULL(CAST(@Ld_Processing_DATE AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_Accrual1050_NUMB AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

            /*
              The accrued amounts in current support, new arrears, Sequence Global Event ID, are then inserted into the LSUP_Y1 table.
            */
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
                    TransactionFuture_AMNT,
                    AppTotFuture_AMNT,
                    Batch_DATE,
                    Batch_NUMB,
                    SeqReceipt_NUMB,
                    SourceBatch_CODE,
                    Receipt_DATE,
                    Distribute_DATE,
                    TypeRecord_CODE,
                    EventGlobalSeq_NUMB,
                    EventFunctionalSeq_NUMB,
                    CheckRecipient_ID,
                    CheckRecipient_CODE)
            VALUES ( @Ln_ObleCur_Case_IDNO,--Case_IDNO
                     @Ln_ObleCur_OrderSeq_NUMB,--OrderSeq_NUMB
                     @Ln_ObleCur_ObligationSeq_NUMB,--ObligationSeq_NUMB
                     CAST (CONVERT(VARCHAR(6), @Ld_AccrualCurrent_DATE, 112) AS NUMERIC(6)),--SupportYearMonth_NUMB
                     @Lc_TypeWelfare_CODE,--TypeWelfare_CODE
                     @Ln_MtdCurSupOwed_AMNT,--MtdCurSupOwed_AMNT
                     @Ln_TransactionCurSup_AMNT,--TransactionCurSup_AMNT
                     @Ln_OweTotCurSup_AMNT + @Ln_TransactionCurSup_AMNT,--OweTotCurSup_AMNT
                     @Ln_AppTotCurSup_AMNT,--AppTotCurSup_AMNT
                     0,--TransactionExptPay_AMNT
                     @Ln_OweTotExptPay_AMNT,--OweTotExptPay_AMNT
                     @Ln_AppTotExptPay_AMNT,--AppTotExptPay_AMNT
                     @Ln_TransactionNaa_AMNT,--TransactionNaa_AMNT
                     @Ln_OweTotNaa_AMNT,--OweTotNaa_AMNT
                     @Ln_AppTotNaa_AMNT,--AppTotNaa_AMNT
                     @Ln_TransactionTaa_AMNT,--TransactionTaa_AMNT
                     @Ln_OweTotTaa_AMNT,--OweTotTaa_AMNT
                     @Ln_AppTotTaa_AMNT,--AppTotTaa_AMNT
                     @Ln_TransactionPaa_AMNT,--TransactionPaa_AMNT
                     @Ln_OweTotPaa_AMNT,--OweTotPaa_AMNT
                     @Ln_AppTotPaa_AMNT,--AppTotPaa_AMNT
                     @Ln_TransactionCaa_AMNT,--TransactionCaa_AMNT
                     @Ln_OweTotCaa_AMNT,--OweTotCaa_AMNT
                     @Ln_AppTotCaa_AMNT,--AppTotCaa_AMNT
                     @Ln_TransactionUpa_AMNT,--TransactionUpa_AMNT
                     @Ln_OweTotUpa_AMNT,--OweTotUpa_AMNT
                     @Ln_AppTotUpa_AMNT,--AppTotUpa_AMNT
                     @Ln_TransactionUda_AMNT,--TransactionUda_AMNT
                     @Ln_OweTotUda_AMNT,--OweTotUda_AMNT
                     @Ln_AppTotUda_AMNT,--AppTotUda_AMNT
                     @Ln_TransactionIvef_AMNT,--TransactionIvef_AMNT
                     @Ln_OweTotIvef_AMNT,--OweTotIvef_AMNT
                     @Ln_AppTotIvef_AMNT,--AppTotIvef_AMNT
                     @Ln_TransactionMedi_AMNT,--TransactionMedi_AMNT
                     @Ln_OweTotMedi_AMNT,--OweTotMedi_AMNT
                     @Ln_AppTotMedi_AMNT,--AppTotMedi_AMNT
                     @Ln_TransactionNffc_AMNT,--TransactionNffc_AMNT
                     @Ln_OweTotNffc_AMNT,--OweTotNffc_AMNT
                     @Ln_AppTotNffc_AMNT,--AppTotNffc_AMNT
                     @Ln_TransactionNonIvd_AMNT,--TransactionNonIvd_AMNT
                     @Ln_OweTotNonIvd_AMNT,--OweTotNonIvd_AMNT
                     @Ln_AppTotNonIvd_AMNT,--AppTotNonIvd_AMNT
                     0,--TransactionFuture_AMNT		
                     @Ln_AppTotFuture_AMNT,--AppTotFuture_AMNT
                     @Ld_Low_DATE,--Batch_DATE					
                     0,--Batch_NUMB					
                     0,--SeqReceipt_NUMB			
                     @Lc_Space_TEXT,--SourceBatch_CODE			
                     @Ld_Low_DATE,--Receipt_DATE				
                     @Ld_Processing_DATE,--Distribute_DATE		
                     @Lc_TypeRecordOriginal_CODE,--TypeRecord_CODE	
                     @Ln_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                     @Li_Accrual1050_NUMB,--EventFunctionalSeq_NUMB
                     0,--CheckRecipient_ID						
                     @Lc_Space_TEXT); --CheckRecipient_CODE		

            SET @Li_Rowcount_QNTY = @@ROWCOUNT;

            IF @Li_Rowcount_QNTY = 0
             BEGIN
              SET @Ls_ErrorMessage_TEXT = 'INSERT LSUP_Y1 FAILED';

              RAISERROR (50001,16,1);
             END;
           END;
         END;

        IF @Ld_AccrualNext_DATE > @Ld_ObleCur_EndObligation_DATE
         BEGIN
          SET @Ld_AccrualNext_DATE = @Ld_High_DATE;
         END;

        SET @Ls_Sql_TEXT = 'UPDATE_OBLE_Y1';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_ObligationSeq_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

        /*
           If the Date Accrual Next falls within the obligation begin and end dates, the Date Accrual Next will be updated
           to the current OBLE record
        */
        UPDATE OBLE_Y1
           SET AccrualNext_DATE = @Ld_AccrualNext_DATE,
               AccrualLast_DATE = @Ld_AccrualLast_DATE
         WHERE Case_IDNO = @Ln_ObleCur_Case_IDNO
           AND OrderSeq_NUMB = @Ln_ObleCur_OrderSeq_NUMB
           AND ObligationSeq_NUMB = @Ln_ObleCur_ObligationSeq_NUMB
           AND @Ld_Processing_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE
           AND EndValidity_DATE = @Ld_High_DATE;

        SET @Li_Rowcount_QNTY = @@ROWCOUNT;

        IF @Li_Rowcount_QNTY = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'UPDATE OBLE_Y1 FAILED';

          RAISERROR (50001,16,1);
         END;

        IF @Ln_ObleCur_Periodic_AMNT > 0
           AND @Lc_ElogEntry_INDC = @Lc_No_INDC
         BEGIN
          SET @Ls_Sql_TEXT = ' INSERT INTO ESEM_Y1 1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST (@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', TypeEntity_CODE = ' + @Lc_TypeEntityCase_CODE + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_Accrual1050_NUMB AS VARCHAR), '');

          /*
           A record is inserted into the Event Sequence Matrix (ELOG screen) ESEM_Y1 table for every case accrued to display the accrual
           event in ELOG. If there is more than one obligation accrued for a given case, total sum of all obligation accruals for the 
           case are displayed on ELOG as a single entry. The details of each obligation accrual will be viewed from the ELOG details 
           pop-up.   
                 */
          INSERT INTO ESEM_Y1
                      (Entity_ID,
                       TypeEntity_CODE,
                       EventGlobalSeq_NUMB,
                       EventFunctionalSeq_NUMB)
               VALUES (@Ln_ObleCur_Case_IDNO,--Entity_ID
                       @Lc_TypeEntityCase_CODE,--TypeEntity_CODE
                       @Ln_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                       @Li_Accrual1050_NUMB); --EventFunctionalSeq_NUMB

          IF @Lc_AcclInserted_INDC = @Lc_No_INDC
           BEGIN
            SET @Ls_Sql_TEXT = ' INSERT INTO ESEM_Y1 2';
            SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + CAST (@Ld_Processing_DATE AS VARCHAR) + ', TypeEntity_CODE = ' + ISNULL (CAST (@Lc_TypeEntityDtacl_CODE AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_Accrual1050_NUMB AS VARCHAR), '');

            INSERT INTO ESEM_Y1
                        (Entity_ID,
                         TypeEntity_CODE,
                         EventGlobalSeq_NUMB,
                         EventFunctionalSeq_NUMB)
                 VALUES (CAST (@Ld_Processing_DATE AS VARCHAR),--Entity_ID
                         @Lc_TypeEntityDtacl_CODE,--TypeEntity_CODE
                         @Ln_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                         @Li_Accrual1050_NUMB); --EventFunctionalSeq_NUMB

            SET @Lc_AcclInserted_INDC = @Lc_Yes_INDC;
           END;

          SET @Lc_ElogEntry_INDC = @Lc_Yes_INDC;
         END;
       END TRY

       BEGIN CATCH
        IF XACT_STATE() = 1
         BEGIN
          ROLLBACK TRANSACTION ACCRUAL_SAVE
         END
        ELSE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

          RAISERROR( 50001,16,1);
         END

        SET @Ln_Error_NUMB = ERROR_NUMBER();
        SET @Ln_ErrorLine_NUMB = ERROR_LINE();

        IF @Ln_Error_NUMB <> 50001
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
          SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
         END

        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = @Ln_Error_NUMB,
         @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
        SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CursorPosition_QNTY = ' + CAST(@Ln_CursorPosition_QNTY AS VARCHAR) + ', BateError_CODE = ' + @Lc_BateError_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
         @An_Line_NUMB                = @Ln_CursorPosition_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
         @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
         BEGIN
          SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
         END
       END CATCH

       IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
         COMMIT TRANSACTION ACCRUAL;

         BEGIN TRANSACTION ACCRUAL;

         SET @Ln_ProcessedRecordCount_QNTY =@Ln_CursorPosition_QNTY;
         SET @Ln_CommitFreq_QNTY = 0;
        END;

       SET @Ls_Sql_TEXT = 'ExceptionThreshold Check -1';
       SET @Ls_Sqldata_TEXT ='ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

       IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        BEGIN
         COMMIT TRANSACTION ACCRUAL;

         SET @Ln_ProcessedRecordCount_QNTY =@Ln_CursorPosition_QNTY;
         SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'FETCH Oble_CUR - 2';
       SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

       FETCH NEXT FROM Oble_CUR INTO @Ln_ObleCur_Case_IDNO, @Ln_ObleCur_OrderSeq_NUMB, @Ln_ObleCur_ObligationSeq_NUMB, @Ln_ObleCur_MemberMci_IDNO, @Lc_ObleCur_FreqPeriodic_CODE, @Ln_ObleCur_Periodic_AMNT, @Ln_ObleCur_ExpectToPay_AMNT, @Ld_ObleCur_BeginObligation_DATE, @Ld_ObleCur_EndObligation_DATE, @Ld_ObleCur_AccrualLast_DATE, @Ld_ObleCur_AccrualNext_DATE, @Lc_ObleCur_CheckRecipient_ID, @Lc_ObleCur_CheckRecipient_CODE, @Lc_ObleCur_TypeDebt_CODE, @Lc_ObleCur_Fips_CODE;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END; -- cursor loop2 Ends                                    

     CLOSE Oble_CUR;

     DEALLOCATE Oble_CUR;

     SET @Ls_Sql_TEXT = 'UPDATE_PARM_DATE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Processing_DATE AS VARCHAR);

     /*
        Update the last run date in the PARM_Y1 table with the run date, upon successful completion
     */
     EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Processing_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;

     COMMIT TRANSACTION ACCRUAL;

     BEGIN TRANSACTION ACCRUAL;

     SET @Ld_Processing_DATE = DATEADD (DAY, 1, @Ld_Processing_DATE);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG - Successes';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Create_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_ID, '');
   SET @Ln_ProcessedRecordCount_QNTY =@Ln_CursorPosition_QNTY;

   /*
   Log the error encountered or successful completion in Batch Status Log (BSTL) screen /  BSTL_Y1 
   table for future references.
   */
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Create_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_ID;

   COMMIT TRANSACTION ACCRUAL;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ACCRUAL;
    END

   IF CURSOR_STATUS ('LOCAL', 'Oble_CUR') IN (0, 1)
    BEGIN
     CLOSE Oble_CUR;

     DEALLOCATE Oble_CUR;
    END;

   --Check for Exception information to log the description text based on the error
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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Create_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_ID;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
