/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_LOG_SUPPORT_ACCL_ADJ_OWIZ]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_LOG_SUPPORT_ACCL_ADJ_OWIZ
Programmer Name		: IMP Team
Description			: Procedure which processes all the adjustment amounts and recalculates the accrual amounts
					  when an obligation is modified
Frequency			:
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_LOG_SUPPORT_ACCL_ADJ_OWIZ] (
 @An_Case_IDNO               NUMERIC(6, 0),
 @An_OrderSeq_NUMB           NUMERIC(2, 0),
 @An_ObligationSeq_NUMB      NUMERIC(2, 0),
 @An_MemberMci_IDNO          NUMERIC(10, 0),
 @Ac_TypeDebt_CODE           CHAR(2),
 @Ac_Fips_CODE               CHAR(7),
 @An_EventGlobalSeq_NUMB     NUMERIC(19, 0),
 @Ad_BeginObligationMin_DATE DATE,
 @Ad_EndObligationMax_DATE   DATE,
 @An_OblmArrayRowsRhs_NUMB   INT,
 @As_OblmArrayRhs_TEXT       VARCHAR(4000),
 @An_OblmArrayRowsLhs_NUMB   INT,
 @As_OblmArrayLhs_TEXT       VARCHAR(4000),
 @Ac_CheckRecipient_ID       CHAR(10),
 @Ac_CheckRecipient_CODE     CHAR(1),
 @Ad_Run_DATE                DATE,
 @Ad_Begin_DATE              DATE OUTPUT,
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ObligationModification1020_NUMB INT = 1020,
          @Li_Zero_NUMB                       SMALLINT = 0,
          @Lc_No_INDC                         CHAR(1) = 'N',
          @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_Yes_INDC                        CHAR(1) = 'Y',
          @Lc_WelfareTypeTanf_CODE            CHAR(1) = 'A',
          @Lc_WelfareTypeMedicaid_CODE        CHAR(1) = 'M',
          @Lc_WelfareEligNonIve_CODE          CHAR(1) = 'F',
          @Lc_WelfareEligFosterCare_CODE      CHAR(1) = 'J',
          @Lc_WelfareEligNonIvd_CODE          CHAR(1) = 'H',
          @Lc_WelfareEligNonTanf_CODE         CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
          @Lc_Lhs_INDC                        CHAR(1) = 'L',
          @Lc_Rhs_INDC                        CHAR(1) = 'R',
          @Lc_DesnPoint_TEXT                  CHAR(1) = 'N',
          @Lc_TypeObligationC_CODE            CHAR(1) = 'C',
          @Lc_TypeObligationF_CODE            CHAR(1) = 'F',
          @Lc_TypeDebtMedicalSupp_CODE        CHAR(2) = 'MS',
          @Lc_DelawareFips_CODE               CHAR(2) = '10',
          @Lc_DateFormatYyyymm_TEXT           CHAR(6) = 'YYYYMM',
          @Lc_DateFormatMmDdYyyy_TEXT         CHAR(10) = 'MM/DD/YYYY',
          @Ld_High_DATE                       DATE = '12/31/9999',
          @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE @Ln_RowCount_QNTY             NUMERIC,
		  @Ln_RowCountLsup_QNTY			NUMERIC,
          @Ln_Identifier_NUMB           NUMERIC(1),
          @Ln_SupportYearMonth_NUMB     NUMERIC(6),
          @Ln_ErrorLine_NUMB            NUMERIC(11),
          @Ln_RowLhs_QNTY               NUMERIC(11, 2),
          @Ln_RowRhs_QNTY               NUMERIC(11, 2),
          @Ln_ArrayPositionLhs_NUMB     NUMERIC(11, 2),
          @Ln_ArrayPositionRhs_NUMB     NUMERIC(11, 2),
          @Ln_PeriodicLhs_AMNT          NUMERIC(11, 2),
          @Ln_PeriodicRhs_AMNT          NUMERIC(11, 2),
          @Ln_TransactionCurSupLhs_AMNT NUMERIC(11, 2),
          @Ln_TransactionCurSupRhs_AMNT NUMERIC(11, 2),
          @Ln_Adjustment_AMNT           NUMERIC(11, 2),
          @Ln_AdjustmentNaa_AMNT        NUMERIC(11, 2),
          @Ln_AdjustmentTaa_AMNT        NUMERIC(11, 2),
          @Ln_AdjustmentPaa_AMNT        NUMERIC(11, 2),
          @Ln_AdjustmentCaa_AMNT        NUMERIC(11, 2),
          @Ln_AdjustmentUpa_AMNT        NUMERIC(11, 2),
          @Ln_AdjustmentUda_AMNT        NUMERIC(11, 2),
          @Ln_AdjustmentIvef_AMNT       NUMERIC(11, 2),
          @Ln_AdjustmentNffc_AMNT       NUMERIC(11, 2),
          @Ln_AdjustmentNonIvd_AMNT     NUMERIC(11, 2),
          @Ln_AdjustmentMedi_AMNT       NUMERIC(11, 2),
          @Ln_TransactionCurSup_AMNT    NUMERIC(11, 2),
          @Ln_OweTotCurSup_AMNT         NUMERIC(11, 2),
          @Ln_AppTotCurSup_AMNT         NUMERIC(11, 2),
          @Ln_TransactionExptPay_AMNT   NUMERIC(11, 2),
          @Ln_OweTotExptPay_AMNT        NUMERIC(11, 2),
          @Ln_AppTotExptPay_AMNT        NUMERIC(11, 2),
          @Ln_TransactionNaa_AMNT       NUMERIC(11, 2),
          @Ln_OweTotNaa_AMNT            NUMERIC(11, 2),
          @Ln_AppTotNaa_AMNT            NUMERIC(11, 2),
          @Ln_TransactionTaa_AMNT       NUMERIC(11, 2),
          @Ln_OweTotTaa_AMNT            NUMERIC(11, 2),
          @Ln_AppTotTaa_AMNT            NUMERIC(11, 2),
          @Ln_TransactionPaa_AMNT       NUMERIC(11, 2),
          @Ln_OweTotPaa_AMNT            NUMERIC(11, 2),
          @Ln_AppTotPaa_AMNT            NUMERIC(11, 2),
          @Ln_TransactionCaa_AMNT       NUMERIC(11, 2),
          @Ln_OweTotCaa_AMNT            NUMERIC(11, 2),
          @Ln_AppTotCaa_AMNT            NUMERIC(11, 2),
          @Ln_TransactionUpa_AMNT       NUMERIC(11, 2),
          @Ln_OweTotUpa_AMNT            NUMERIC(11, 2),
          @Ln_AppTotUpa_AMNT            NUMERIC(11, 2),
          @Ln_TransactionUda_AMNT       NUMERIC(11, 2),
          @Ln_OweTotUda_AMNT            NUMERIC(11, 2),
          @Ln_AppTotUda_AMNT            NUMERIC(11, 2),
          @Ln_TransactionIvef_AMNT      NUMERIC(11, 2),
          @Ln_OweTotIvef_AMNT           NUMERIC(11, 2),
          @Ln_AppTotIvef_AMNT           NUMERIC(11, 2),
          @Ln_TransactionNffc_AMNT      NUMERIC(11, 2),
          @Ln_OweTotNffc_AMNT           NUMERIC(11, 2),
          @Ln_AppTotNffc_AMNT           NUMERIC(11, 2),
          @Ln_TransactionNonIvd_AMNT    NUMERIC(11, 2),
          @Ln_OweTotNonIvd_AMNT         NUMERIC(11, 2),
          @Ln_AppTotNonIvd_AMNT         NUMERIC(11, 2),
          @Ln_TransactionMedi_AMNT      NUMERIC(11, 2),
          @Ln_OweTotMedi_AMNT           NUMERIC(11, 2),
          @Ln_AppTotMedi_AMNT           NUMERIC(11, 2),
          @Ln_TransactionFuture_AMNT    NUMERIC(11, 2),
          @Ln_AppTotFuture_AMNT         NUMERIC(11, 2),
          @Ln_AdjustmentMeds_AMNT       NUMERIC(11, 2),
          @Ln_MtdAccrualRhs_NUMB        NUMERIC(11, 2),
          @Ln_MtdAccrualLhs_NUMB        NUMERIC(11, 2),
          @Ln_MtdAccrual_NUMB           NUMERIC(11, 2),
          @Ln_ArrPaa_AMNT               NUMERIC(11, 2),
          @Ln_ArrNaa_AMNT               NUMERIC(11, 2),
          @Ln_ArrCaa_AMNT               NUMERIC(11, 2),
          @Ln_ArrTaa_AMNT               NUMERIC(11, 2),
          @Ln_ArrUda_AMNT               NUMERIC(11, 2),
          @Ln_ArrUpa_AMNT               NUMERIC(11, 2),
          @Ln_ArrNonIvd_AMNT            NUMERIC(11, 2),
          @Li_Error_NUMB                INT,
          @Lc_FreqPeriodicLhs_CODE      CHAR(1),
          @Lc_FreqPeriodicRhs_CODE      CHAR(1),
          @Lc_WelfareElig_CODE          CHAR(1),
          @Lc_TypeObligation_CODE       CHAR(1),
          @Lc_MtdProcessRhs_INDC        CHAR(1),
          @Lc_DirectPay_INDC            CHAR(1),
          @Lc_DummyEntry_TEXT           CHAR(1),
          @Lc_MtdProcessLhs_INDC        CHAR(1),
          @Lc_ChgObligation_CODE        CHAR(2),
          @Ls_ErrorMessage_TEXT         VARCHAR(4000),
          @Ld_AccrualNext_DATE          DATE,
          @Ld_Run_DATE                  DATE,
          @Ld_ProcessingFirstDay_DATE   DATETIME2(0),
          @Ld_ProcessingLastDay_DATE    DATETIME2(0),
          @Ld_EndProcessingMonth_DATE   DATETIME2(0),
          @Ld_CurrentMonth_DATE         DATETIME2(0),
          @Ld_MonthEndObleLhs_DATE      DATETIME2(0),
          @Ld_MonthEndObleRhs_DATE      DATETIME2(0),
          @Ld_BeginObligationLhs_DATE   DATETIME2(0),
          @Ld_EndObligationLhs_DATE     DATETIME2(0),
          @Ld_ObleEndObligationLhs_DATE DATETIME2(0),
          @Ld_BeginObligationRhs_DATE   DATETIME2(0),
          @Ld_EndObligationRhs_DATE     DATETIME2(0),
          @Ld_ObleEndObligationRhs_DATE DATETIME2(0),
          @Ld_AccrualNextLhs_DATE       DATETIME2(0),
          @Ld_AccrualNextRhs_DATE       DATETIME2(0),
          @Ld_EndOble_DATE              DATETIME2(0),
          @Ld_TmpAcclNext_DATE          DATETIME2(0),
          @Ld_AccrualLastLhs_DATE       DATETIME2(0),
          @Ld_AccrualLastRhs_DATE       DATETIME2(0),
          @Ld_MonthFirst_DATE           DATETIME2(0),
          @Ld_AccrualNextUpd_DATE       DATETIME2(0);
  DECLARE @Ln_Count_QNTY				NUMERIC(11) = 0,
          @Ln_Accrual_AMNT				NUMERIC(11, 2) = 0,
          @Lc_Space_TEXT				CHAR(1) = '',
          @Ls_Routine_TEXT				VARCHAR(400) = '',
          @Ls_Sql_TEXT					VARCHAR(400) = '',
          @Ls_SqlData_TEXT				VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ad_Begin_DATE = NULL;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Run_DATE = ISNULL(@Ad_Run_DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @Ls_Routine_TEXT = ' BATCH_COMMON$SP_LOG_SUPPORT_ACCL_ADJ_OWIZ ';
   SET @Ln_RowRhs_QNTY = 1;
   SET @Ln_ArrayPositionLhs_NUMB = 1;
   SET @Ln_ArrayPositionRhs_NUMB = 1;
   SET @Ld_MonthFirst_DATE = @Ad_BeginObligationMin_DATE;
   SET @Ld_CurrentMonth_DATE = @Ld_Run_DATE;
   SET @Ld_ProcessingFirstDay_DATE = @Ad_BeginObligationMin_DATE;
   SET @Ld_EndProcessingMonth_DATE = @Ad_EndObligationMax_DATE;
   SET @Ld_ProcessingFirstDay_DATE =  DATEADD(DAY, -(DAY(@Ad_BeginObligationMin_DATE) - 1), @Ad_BeginObligationMin_DATE);
   SET @Ld_ProcessingLastDay_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ad_BeginObligationMin_DATE);
   
   IF @Ad_EndObligationMax_DATE >= @Ld_CurrentMonth_DATE
    BEGIN
     SET @Ld_EndProcessingMonth_DATE = @Ld_CurrentMonth_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_EndProcessingMonth_DATE = @Ad_EndObligationMax_DATE;
    END

   IF @An_OblmArrayRowsLhs_NUMB > @Li_Zero_NUMB
    BEGIN
    
     SET @Ln_RowLhs_QNTY = 1;
     SET @Ln_PeriodicLhs_AMNT = SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB AS NUMERIC(11, 2)), 10);
     SET @Lc_FreqPeriodicLhs_CODE = SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB + 10 AS NUMERIC(11, 2)), 1);
     SET @Ld_BeginObligationLhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB + 11 AS NUMERIC(11, 2)), 10), @Lc_DateFormatMmDdYyyy_TEXT);
     SET @Ld_EndObligationLhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB + 21 AS NUMERIC(11, 2)), 10), @Lc_DateFormatMmDdYyyy_TEXT);
     SET @Ld_ObleEndObligationLhs_DATE = @Ld_EndObligationLhs_DATE;
     SET @Ld_AccrualNextLhs_DATE = @Ld_BeginObligationLhs_DATE;
     SET @Ld_MonthEndObleLhs_DATE = @Ld_EndObligationLhs_DATE;

     IF @Ld_EndObligationLhs_DATE > @Ld_Run_DATE
      BEGIN
       SET @Ld_EndObligationLhs_DATE = @Ld_Run_DATE;
      END

     IF @Ld_MonthEndObleLhs_DATE > dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE)
      BEGIN
       SET @Ld_MonthEndObleLhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE);
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ_1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ld_BeginObligationLhs_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_Lhs_INDC,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

     EXECUTE BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ
      @An_Case_IDNO             = @An_Case_IDNO,
      @An_OrderSeq_NUMB         = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB    = @An_ObligationSeq_NUMB,
      @Ad_BeginObligation_DATE  = @Ld_BeginObligationLhs_DATE,
      @Ac_Process_INDC          = @Lc_Lhs_INDC,
      @An_EventGlobalSeq_NUMB   = @An_EventGlobalSeq_NUMB,
      @Ac_FreqPeriodic_CODE     = @Lc_FreqPeriodicLhs_CODE OUTPUT,
      @An_Periodic_AMNT         = @Ln_PeriodicLhs_AMNT OUTPUT,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ln_RowLhs_QNTY = @Li_Zero_NUMB;
    END

   IF @An_OblmArrayRowsRhs_NUMB > @Li_Zero_NUMB
    BEGIN
     SET @Ln_RowRhs_QNTY = 1;
     SET @Ln_PeriodicRhs_AMNT = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB AS NUMERIC(11, 2)), 10);
     SET @Lc_FreqPeriodicRhs_CODE = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 10 AS NUMERIC(11, 2)), 1);
     SET @Ld_BeginObligationRhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 11 AS NUMERIC(11, 2)), 10), @Lc_DateFormatMmDdYyyy_TEXT);
     SET @Ld_EndObligationRhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 21 AS NUMERIC(11, 2)), 10), @Lc_DateFormatMmDdYyyy_TEXT);
     SET @Ld_ObleEndObligationRhs_DATE = @Ld_EndObligationRhs_DATE;
     SET @Lc_ChgObligation_CODE = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 31 AS NUMERIC(11, 2)), 2);
     SET @Lc_TypeObligation_CODE = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 33 AS NUMERIC(11, 2)), 1);
     SET @Ld_AccrualNextRhs_DATE = @Ld_BeginObligationRhs_DATE;
     SET @Ld_MonthEndObleRhs_DATE = @Ld_EndObligationRhs_DATE;
     SET @Ld_EndOble_DATE = @Ld_EndObligationRhs_DATE;

     IF @Ld_EndObligationRhs_DATE > @Ld_Run_DATE
      BEGIN
       SET @Ld_EndObligationRhs_DATE = @Ld_Run_DATE;
      END

     IF @Ld_MonthEndObleRhs_DATE > dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE)
      BEGIN
       SET @Ld_MonthEndObleRhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE);
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ_2';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ld_BeginObligationRhs_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_Rhs_INDC,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

     EXECUTE BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ
      @An_Case_IDNO             = @An_Case_IDNO,
      @An_OrderSeq_NUMB         = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB    = @An_ObligationSeq_NUMB,
      @Ad_BeginObligation_DATE  = @Ld_BeginObligationRhs_DATE,
      @Ac_Process_INDC          = @Lc_Rhs_INDC,
      @An_EventGlobalSeq_NUMB   = @An_EventGlobalSeq_NUMB,
      @Ac_FreqPeriodic_CODE     = @Lc_FreqPeriodicRhs_CODE OUTPUT,
      @An_Periodic_AMNT         = @Ln_PeriodicRhs_AMNT OUTPUT,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ln_RowRhs_QNTY = @Li_Zero_NUMB;
    END

   SET @Ln_Adjustment_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentNaa_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentTaa_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentPaa_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentCaa_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentUpa_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentUda_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentIvef_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentNffc_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentNonIvd_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentMedi_AMNT = @Li_Zero_NUMB;
   SET @Ln_AdjustmentMeds_AMNT = @Li_Zero_NUMB;

   --Process the obligations on montlhy basis starting from first processing month till end processing month
   WHILE (CONVERT(VARCHAR(6), @Ld_ProcessingFirstDay_DATE, 112) >= CONVERT(VARCHAR(6), @Ad_BeginObligationMin_DATE, 112))
         AND (CONVERT(VARCHAR(6), @Ld_ProcessingFirstDay_DATE, 112) <= CONVERT(VARCHAR(6), @Ld_Run_DATE, 112))
         AND (@An_OblmArrayRowsRhs_NUMB > @Li_Zero_NUMB
               OR @An_OblmArrayRowsLhs_NUMB > @Li_Zero_NUMB)
    BEGIN
     SET @Ln_TransactionCurSupLhs_AMNT = @Li_Zero_NUMB;
     SET @Ln_MtdAccrualLhs_NUMB = @Li_Zero_NUMB;

     --Accrue all the LHS obligation in the current month 
     WHILE (CONVERT(VARCHAR(6), @Ld_AccrualNextLhs_DATE, 112) <= CONVERT(VARCHAR(6), @Ld_ProcessingLastDay_DATE, 112))
           AND (CONVERT(VARCHAR(6), @Ld_AccrualNextLhs_DATE, 112) <= CONVERT(VARCHAR(6), @Ld_Run_DATE, 112))
           AND (@Ln_RowLhs_QNTY <= @An_OblmArrayRowsLhs_NUMB
                AND @An_OblmArrayRowsLhs_NUMB > @Li_Zero_NUMB)
      BEGIN
       IF @Ld_AccrualNextLhs_DATE > @Ld_MonthEndObleLhs_DATE
        BEGIN
         SET @Ln_PeriodicLhs_AMNT = @Li_Zero_NUMB;
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ACCRUAL_LHS';
       SET @Ls_SqlData_TEXT = 'FreqPeriodic_CODE = ' + ISNULL(@Lc_FreqPeriodicLhs_CODE,'')+ ', Periodic_AMNT = ' + ISNULL(CAST( @Ln_PeriodicLhs_AMNT AS VARCHAR ),'')+ ', ExpectToPay_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ld_BeginObligationLhs_DATE AS VARCHAR ),'')+ ', EndObligation_DATE = ' + ISNULL(CAST( @Ld_ObleEndObligationLhs_DATE AS VARCHAR ),'')+ ', AccrualEnd_DATE = ' + ISNULL(CAST( @Ld_EndObligationLhs_DATE AS VARCHAR ),'');

       EXECUTE BATCH_COMMON$SP_ACCRUAL
        @Ac_FreqPeriodic_CODE       = @Lc_FreqPeriodicLhs_CODE,
        @An_Periodic_AMNT           = @Ln_PeriodicLhs_AMNT,
        @An_ExpectToPay_AMNT        = @Li_Zero_NUMB,
        @Ad_BeginObligation_DATE    = @Ld_BeginObligationLhs_DATE,
        @Ad_EndObligation_DATE      = @Ld_ObleEndObligationLhs_DATE,
        @Ad_AccrualEnd_DATE         = @Ld_EndObligationLhs_DATE,
        @Ad_AccrualNext_DATE        = @Ld_AccrualNextLhs_DATE OUTPUT,
        @Ad_AccrualLast_DATE        = @Ld_AccrualLastLhs_DATE OUTPUT,
        @An_TransactionCurSup_AMNT  = @Ln_TransactionCurSupLhs_AMNT OUTPUT,
        @An_TransactionExptPay_AMNT = @Ln_TransactionExptPay_AMNT OUTPUT,
        @An_MtdAccrual_AMNT         = @Ln_MtdAccrualLhs_NUMB OUTPUT,
        @Ac_MtdProcess_INDC         = @Lc_MtdProcessLhs_INDC OUTPUT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       IF @Ld_AccrualNextLhs_DATE > @Ld_MonthEndObleLhs_DATE
        BEGIN
         SET @Ln_RowLhs_QNTY = @Ln_RowLhs_QNTY + 1;

         IF @Ln_RowLhs_QNTY <= @An_OblmArrayRowsLhs_NUMB
          BEGIN
           SET @Ln_ArrayPositionLhs_NUMB = @Ln_ArrayPositionLhs_NUMB + 31;
           SET @Ln_PeriodicLhs_AMNT = SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB AS NUMERIC(11, 2)), 10);
           SET @Lc_FreqPeriodicLhs_CODE = SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB + 10 AS NUMERIC(11, 2)), 1);
           SET @Ld_BeginObligationLhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB + 11 AS NUMERIC(11, 2)), 10), @Lc_DateFormatMmDdYyyy_TEXT);
           SET @Ld_EndObligationLhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayLhs_TEXT, CAST(@Ln_ArrayPositionLhs_NUMB + 21 AS NUMERIC(11, 2)), 10), @Lc_DateFormatMmDdYyyy_TEXT);
           SET @Ld_ObleEndObligationLhs_DATE = @Ld_EndObligationLhs_DATE;
           SET @Ld_AccrualNextLhs_DATE = @Ld_BeginObligationLhs_DATE;
           SET @Ld_MonthEndObleLhs_DATE = @Ld_EndObligationLhs_DATE;

           IF @Ld_EndObligationLhs_DATE > @Ld_Run_DATE
            BEGIN
             SET @Ld_EndObligationLhs_DATE = @Ld_Run_DATE;
            END

           IF @Ld_MonthEndObleLhs_DATE > dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE)
            BEGIN
             SET @Ld_MonthEndObleLhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE);
            END
          END
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ_3';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ld_BeginObligationLhs_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_Lhs_INDC,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

       EXECUTE BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ
        @An_Case_IDNO             = @An_Case_IDNO,
        @An_OrderSeq_NUMB         = @An_OrderSeq_NUMB,
        @An_ObligationSeq_NUMB    = @An_ObligationSeq_NUMB,
        @Ad_BeginObligation_DATE  = @Ld_BeginObligationLhs_DATE,
        @Ac_Process_INDC          = @Lc_Lhs_INDC,
        @An_EventGlobalSeq_NUMB   = @An_EventGlobalSeq_NUMB,
        @Ac_FreqPeriodic_CODE     = @Lc_FreqPeriodicLhs_CODE OUTPUT,
        @An_Periodic_AMNT         = @Ln_PeriodicLhs_AMNT OUTPUT,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

	 SET @Ls_Sql_TEXT = 'SELECT COUNT QNTY - 1';
	 SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', AccrualNext_DATE = ' + ISNULL(CAST( @Ld_AccrualLastLhs_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Row_NUMB = ' + ISNULL('1','');
	 
     SELECT @Ln_Count_QNTY = COUNT(1)
       FROM (SELECT Case_IDNO,
                    OrderSeq_NUMB,
                    ObligationSeq_NUMB,
                    MemberMci_IDNO,
                    AccrualNext_DATE,
                    BeginObligation_DATE,
                    EndObligation_DATE,
                    EndValidity_DATE,
                    EventGlobalEndSeq_NUMB,
                    ROW_NUMBER() OVER( ORDER BY bCOLUMN) AS Row_NUMB
               FROM (SELECT o.Case_IDNO,
                            o.OrderSeq_NUMB,
                            o.ObligationSeq_NUMB,
                            o.MemberMci_IDNO,
                            o.AccrualNext_DATE,
                            o.BeginObligation_DATE,
                            o.EndObligation_DATE,
                            o.EndValidity_DATE,
                            o.EventGlobalEndSeq_NUMB,
                            0 AS bCOLUMN
                       FROM OBLE_Y1 o
                      WHERE o.Case_IDNO = @An_Case_IDNO
                        AND o.OrderSeq_NUMB = @An_OrderSeq_NUMB
                        AND o.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
                        AND o.MemberMci_IDNO = @An_MemberMci_IDNO
                        AND o.AccrualNext_DATE = @Ld_AccrualLastLhs_DATE
                        AND @Ld_AccrualNextLhs_DATE > @Ld_Run_DATE
                        AND o.BeginObligation_DATE < @Ld_Run_DATE
                        AND o.EndObligation_DATE >= @Ld_Run_DATE
                        AND o.AccrualNext_DATE <= @Ld_Run_DATE
                        AND o.EndValidity_DATE = @Ld_Run_DATE
                        AND o.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
                        AND 1 = 1) AS b) AS a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
        AND a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.AccrualNext_DATE = @Ld_AccrualLastLhs_DATE
        AND @Ld_AccrualNextLhs_DATE > @Ld_Run_DATE
        AND a.BeginObligation_DATE < @Ld_Run_DATE
        AND a.EndObligation_DATE >= @Ld_Run_DATE
        AND a.AccrualNext_DATE <= @Ld_Run_DATE
        AND a.EndValidity_DATE = @Ld_Run_DATE
        AND a.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.Row_NUMB = 1;

     IF @Ln_Count_QNTY = 1
      BEGIN
       SET @Ln_TransactionCurSupLhs_AMNT = @Ln_TransactionCurSupLhs_AMNT - @Ln_PeriodicLhs_AMNT;
       SET @Ln_PeriodicLhs_AMNT = @Li_Zero_NUMB;
      END

     SET @Ln_TransactionCurSupRhs_AMNT = @Li_Zero_NUMB;
     SET @Ln_MtdAccrualRhs_NUMB = @Li_Zero_NUMB;
     SET @Lc_MtdProcessRhs_INDC = @Lc_No_INDC;
     SET @Ln_TransactionExptPay_AMNT = @Li_Zero_NUMB;

     --Accrue all the RHS obligation in the current month 
     WHILE (CONVERT(VARCHAR(6), @Ld_AccrualNextRhs_DATE, 112) <= CONVERT(VARCHAR(6), @Ld_ProcessingLastDay_DATE, 112))
           AND (CONVERT(VARCHAR(6), @Ld_AccrualNextRhs_DATE, 112) <= CONVERT(VARCHAR(6), @Ld_Run_DATE, 112))
           AND (@Ln_RowRhs_QNTY <= @An_OblmArrayRowsRhs_NUMB
                AND @An_OblmArrayRowsRhs_NUMB > @Li_Zero_NUMB)
      BEGIN
       IF @Ld_AccrualNextRhs_DATE > @Ld_MonthEndObleRhs_DATE
        BEGIN
         SET @Ln_PeriodicRhs_AMNT = @Li_Zero_NUMB;
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ACCRUAL_RHS';
       SET @Ls_SqlData_TEXT = 'FreqPeriodic_CODE = ' + ISNULL(@Lc_FreqPeriodicRhs_CODE,'')+ ', Periodic_AMNT = ' + ISNULL(CAST( @Ln_PeriodicRhs_AMNT AS VARCHAR ),'')+ ', ExpectToPay_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ld_BeginObligationRhs_DATE AS VARCHAR ),'')+ ', EndObligation_DATE = ' + ISNULL(CAST( @Ld_ObleEndObligationRhs_DATE AS VARCHAR ),'')+ ', AccrualEnd_DATE = ' + ISNULL(CAST( @Ld_EndObligationRhs_DATE AS VARCHAR ),'');

       EXECUTE BATCH_COMMON$SP_ACCRUAL
        @Ac_FreqPeriodic_CODE       = @Lc_FreqPeriodicRhs_CODE,
        @An_Periodic_AMNT           = @Ln_PeriodicRhs_AMNT,
        @An_ExpectToPay_AMNT        = @Li_Zero_NUMB,
        @Ad_BeginObligation_DATE    = @Ld_BeginObligationRhs_DATE,
        @Ad_EndObligation_DATE      = @Ld_ObleEndObligationRhs_DATE,
        @Ad_AccrualEnd_DATE         = @Ld_EndObligationRhs_DATE,
        @Ad_AccrualNext_DATE        = @Ld_AccrualNextRhs_DATE OUTPUT,
        @Ad_AccrualLast_DATE        = @Ld_AccrualLastRhs_DATE OUTPUT,
        @An_TransactionCurSup_AMNT  = @Ln_TransactionCurSupRhs_AMNT OUTPUT,
        @An_TransactionExptPay_AMNT = @Ln_TransactionExptPay_AMNT OUTPUT,
        @An_MtdAccrual_AMNT         = @Ln_MtdAccrualRhs_NUMB OUTPUT,
        @Ac_MtdProcess_INDC         = @Lc_MtdProcessRhs_INDC OUTPUT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       IF @Ld_AccrualNextRhs_DATE > @Ld_EndObligationRhs_DATE
          AND @Lc_MtdProcessRhs_INDC = @Lc_Yes_INDC
        BEGIN
         SET @Ld_TmpAcclNext_DATE = @Ld_AccrualNextRhs_DATE;
         SET @Lc_MtdProcessRhs_INDC = @Lc_No_INDC;
        END

       IF @Ld_AccrualNextRhs_DATE > @Ld_MonthEndObleRhs_DATE
        BEGIN
         SET @Ln_RowRhs_QNTY = @Ln_RowRhs_QNTY + 1;

         IF @Ln_RowRhs_QNTY <= @An_OblmArrayRowsRhs_NUMB
          BEGIN
           IF @Ld_BeginObligationRhs_DATE > @Ld_Run_DATE
            BEGIN
             SET @Ld_TmpAcclNext_DATE = @Ld_BeginObligationRhs_DATE;
             SET @Ld_AccrualLastRhs_DATE = @Ld_BeginObligationRhs_DATE;
            END

           IF @Ld_TmpAcclNext_DATE > @Ld_EndOble_DATE
            BEGIN
             SET @Ld_AccrualNextUpd_DATE = @Ld_High_DATE;
            END
           ELSE
            BEGIN
             SET @Ld_AccrualNextUpd_DATE = @Ld_TmpAcclNext_DATE;
            END

           SET @Ls_Sql_TEXT = 'UPDATE_VOBLE1';
           SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

           UPDATE OBLE_Y1
              SET AccrualNext_DATE = @Ld_AccrualNextUpd_DATE,
                  AccrualLast_DATE = @Ld_AccrualLastRhs_DATE
            WHERE Case_IDNO = @An_Case_IDNO
              AND OrderSeq_NUMB = @An_OrderSeq_NUMB
              AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
              AND @Ld_BeginObligationRhs_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE
              AND EndValidity_DATE = @Ld_High_DATE;

           SET @Ln_RowCount_QNTY = @@ROWCOUNT;

           IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
            BEGIN
             SET @Ls_ErrorMessage_TEXT = 'UPDATE OBLE_Y1 FAILED';             
             RAISERROR(50001,16,1);
            END

           SET @Ln_ArrayPositionRhs_NUMB = @Ln_ArrayPositionRhs_NUMB + 34;
           SET @Ln_PeriodicRhs_AMNT = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB AS NUMERIC(11, 2)), 10);
           SET @Lc_FreqPeriodicRhs_CODE = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 10 AS NUMERIC(11, 2)), 1);
           SET @Ld_BeginObligationRhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 11 AS NUMERIC(11, 2)), 10), @Lc_DateFormatMmDdYyyy_TEXT);
           SET @Ld_EndObligationRhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(SUBSTRING(@As_OblmArrayRhs_TEXT, CAST (@Ln_ArrayPositionRhs_NUMB + 21 AS INT), 10), @Lc_DateFormatMmDdYyyy_TEXT);
           SET @Ld_ObleEndObligationRhs_DATE = @Ld_EndObligationRhs_DATE;
           SET @Lc_ChgObligation_CODE = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST(@Ln_ArrayPositionRhs_NUMB + 31 AS NUMERIC(11, 2)), 2);
           SET @Lc_TypeObligation_CODE = SUBSTRING(@As_OblmArrayRhs_TEXT, CAST (@Ln_ArrayPositionRhs_NUMB + 33 AS NUMERIC(11, 2)), 1);
           SET @Ld_AccrualNextRhs_DATE = @Ld_BeginObligationRhs_DATE;
           SET @Ld_MonthEndObleRhs_DATE = @Ld_EndObligationRhs_DATE;

           IF @Ld_EndObligationRhs_DATE > @Ld_Run_DATE
            BEGIN
             SET @Ld_EndOble_DATE = @Ld_EndObligationRhs_DATE;
             SET @Ld_EndObligationRhs_DATE = @Ld_Run_DATE;
            END

           IF @Ld_MonthEndObleRhs_DATE > dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE)
            BEGIN
             SET @Ld_MonthEndObleRhs_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE);
            END
          END
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ_4';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ld_BeginObligationRhs_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_Rhs_INDC,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

       EXECUTE BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ
        @An_Case_IDNO             = @An_Case_IDNO,
        @An_OrderSeq_NUMB         = @An_OrderSeq_NUMB,
        @An_ObligationSeq_NUMB    = @An_ObligationSeq_NUMB,
        @Ad_BeginObligation_DATE  = @Ld_BeginObligationRhs_DATE,
        @Ac_Process_INDC          = @Lc_Rhs_INDC,
        @An_EventGlobalSeq_NUMB   = @An_EventGlobalSeq_NUMB,
        @Ac_FreqPeriodic_CODE     = @Lc_FreqPeriodicRhs_CODE OUTPUT,
        @An_Periodic_AMNT         = @Ln_PeriodicRhs_AMNT OUTPUT,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

     IF @Ln_RowLhs_QNTY = 1
        AND @Lc_FreqPeriodicLhs_CODE = @Lc_FreqPeriodicRhs_CODE
        AND @Ln_PeriodicLhs_AMNT = @Ln_PeriodicRhs_AMNT
        AND @Ld_BeginObligationLhs_DATE = @Ld_BeginObligationRhs_DATE
        AND @Ln_TransactionCurSupLhs_AMNT = @Ln_TransactionCurSupRhs_AMNT
      BEGIN
       IF @Ld_EndObligationLhs_DATE > @Ld_EndObligationRhs_DATE
        BEGIN
         IF @Ld_AccrualLastLhs_DATE < @Ld_EndObligationRhs_DATE
          BEGIN
           GOTO process_next_mth;
          END
        END
       ELSE
        BEGIN
         IF @Ld_EndObligationLhs_DATE = @Ld_EndObligationRhs_DATE
          BEGIN
           GOTO process_next_mth;
          END
         ELSE
          BEGIN
           IF @Ld_EndObligationLhs_DATE < @Ld_EndObligationRhs_DATE
            BEGIN
             IF @Ld_AccrualLastRhs_DATE < @Ld_EndObligationLhs_DATE
              BEGIN
               GOTO process_next_mth;
              END
            END
          END
        END
      END

     SET @Ln_Adjustment_AMNT = @Ln_TransactionCurSupRhs_AMNT - @Ln_TransactionCurSupLhs_AMNT;
     SET @Ln_MtdAccrual_NUMB = ISNULL(@Ln_MtdAccrualRhs_NUMB, @Li_Zero_NUMB);

     IF (@Ld_EndProcessingMonth_DATE < @Ld_AccrualNextLhs_DATE
          OR @Ld_EndProcessingMonth_DATE < @Ld_AccrualNextRhs_DATE)
        AND @Ld_EndProcessingMonth_DATE < @Ld_Run_DATE
      BEGIN
       SET @Ld_TmpAcclNext_DATE = @Ld_High_DATE;
      END

     SET @Lc_DummyEntry_TEXT = @Lc_No_INDC;

     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SELECT_VMHIS';
      SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'');

      SELECT @Lc_WelfareElig_CODE = a.TypeWelfare_CODE
        FROM MHIS_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO
         AND a.MemberMci_IDNO = @An_MemberMci_IDNO
         AND @Ld_ProcessingLastDay_DATE BETWEEN a.Start_DATE AND a.End_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
       BEGIN
        SET @Lc_WelfareElig_CODE = DBO.BATCH_COMMON_GETS$SF_GETCASETYPE(@An_Case_IDNO);
       END

      SET @Ln_SupportYearMonth_NUMB = CONVERT(VARCHAR(6), @Ld_ProcessingFirstDay_DATE, 112);
      SET @Ln_OweTotCurSup_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotCurSup_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotExptPay_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotExptPay_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotNaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotNaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotTaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotTaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotPaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotPaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotCaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotCaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotUpa_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotUpa_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotUda_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotUda_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotIvef_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotIvef_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotNffc_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotNffc_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotNonIvd_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotNonIvd_AMNT = @Li_Zero_NUMB;
      SET @Ln_OweTotMedi_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotMedi_AMNT = @Li_Zero_NUMB;
      SET @Ln_AppTotFuture_AMNT = @Li_Zero_NUMB;
      SET @Ln_Accrual_AMNT = @Li_Zero_NUMB;
      
      SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y11';
      SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonth_NUMB AS VARCHAR ),'');

      SELECT @Ln_OweTotCurSup_AMNT = ISNULL(a.OweTotCurSup_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotCurSup_AMNT = ISNULL(a.AppTotCurSup_AMNT, @Li_Zero_NUMB),
             @Ln_Accrual_AMNT = ISNULL(a.MtdCurSupOwed_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotExptPay_AMNT = ISNULL(a.OweTotExptPay_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotExptPay_AMNT = ISNULL(a.AppTotExptPay_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotNaa_AMNT = ISNULL(a.OweTotNaa_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotNaa_AMNT = ISNULL(a.AppTotNaa_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotTaa_AMNT = ISNULL(a.OweTotTaa_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotTaa_AMNT = ISNULL(a.AppTotTaa_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotPaa_AMNT = ISNULL(a.OweTotPaa_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotPaa_AMNT = ISNULL(a.AppTotPaa_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotCaa_AMNT = ISNULL(a.OweTotCaa_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotCaa_AMNT = ISNULL(a.AppTotCaa_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotUpa_AMNT = ISNULL(a.OweTotUpa_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotUpa_AMNT = ISNULL(a.AppTotUpa_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotUda_AMNT = ISNULL(a.OweTotUda_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotUda_AMNT = ISNULL(a.AppTotUda_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotIvef_AMNT = ISNULL(a.OweTotIvef_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotIvef_AMNT = ISNULL(a.AppTotIvef_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotNffc_AMNT = ISNULL(a.OweTotNffc_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotNffc_AMNT = ISNULL(a.AppTotNffc_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotNonIvd_AMNT = ISNULL(a.OweTotNonIvd_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotNonIvd_AMNT = ISNULL(a.AppTotNonIvd_AMNT, @Li_Zero_NUMB),
             @Ln_OweTotMedi_AMNT = ISNULL(a.OweTotMedi_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotMedi_AMNT = ISNULL(a.AppTotMedi_AMNT, @Li_Zero_NUMB),
             @Ln_AppTotFuture_AMNT = ISNULL(a.AppTotFuture_AMNT, @Li_Zero_NUMB)
        FROM LSUP_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
         AND a.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
         AND a.EventGlobalSeq_NUMB = (SELECT MAX(c.EventGlobalSeq_NUMB) AS EventGlobalSeq_NUMB
                                        FROM LSUP_Y1 c
                                       WHERE c.Case_IDNO = a.Case_IDNO
                                         AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                         AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                         AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;
      
      --13781 - OWIZ - Regular Distribution, APDFI050. DEB0560 failed -START-
      SET @Ln_RowCountLsup_QNTY = @Ln_RowCount_QNTY;
      --13781 - OWIZ - Regular Distribution, APDFI050. DEB0560 failed -END-

      IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y12';
        SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'');

        SELECT @Ln_OweTotCurSup_AMNT = @Li_Zero_NUMB,
               @Ln_AppTotCurSup_AMNT = @Li_Zero_NUMB,
               @Ln_Accrual_AMNT = @Li_Zero_NUMB,
               @Ln_OweTotExptPay_AMNT = @Li_Zero_NUMB,
               @Ln_AppTotExptPay_AMNT = @Li_Zero_NUMB,
               @Ln_OweTotNaa_AMNT = ISNULL(a.OweTotNaa_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentNaa_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotNaa_AMNT = ISNULL(a.AppTotNaa_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotTaa_AMNT = ISNULL(a.OweTotTaa_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentTaa_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotTaa_AMNT = ISNULL(a.AppTotTaa_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotPaa_AMNT = ISNULL(a.OweTotPaa_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentPaa_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotPaa_AMNT = ISNULL(a.AppTotPaa_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotCaa_AMNT = ISNULL(a.OweTotCaa_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentCaa_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotCaa_AMNT = ISNULL(a.AppTotCaa_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotUpa_AMNT = ISNULL(a.OweTotUpa_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentUpa_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotUpa_AMNT = ISNULL(a.AppTotUpa_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotUda_AMNT = ISNULL(a.OweTotUda_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentUda_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotUda_AMNT = ISNULL(a.AppTotUda_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotIvef_AMNT = ISNULL(a.OweTotIvef_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentIvef_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotIvef_AMNT = ISNULL(a.AppTotIvef_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotNffc_AMNT = ISNULL(a.OweTotNffc_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentNffc_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotNffc_AMNT = ISNULL(a.AppTotNffc_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotNonIvd_AMNT = ISNULL(a.OweTotNonIvd_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentNonIvd_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotNonIvd_AMNT = ISNULL(a.AppTotNonIvd_AMNT, @Li_Zero_NUMB),
               @Ln_OweTotMedi_AMNT = ISNULL(a.OweTotMedi_AMNT, @Li_Zero_NUMB) - ISNULL(@Ln_AdjustmentMedi_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotMedi_AMNT = ISNULL(a.AppTotMedi_AMNT, @Li_Zero_NUMB),
               @Ln_AppTotFuture_AMNT = ISNULL(a.AppTotFuture_AMNT, @Li_Zero_NUMB)
          FROM LSUP_Y1 a
         WHERE a.Case_IDNO = @An_Case_IDNO
           AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
           AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
           AND a.SupportYearMonth_NUMB = (SELECT MAX(b.SupportYearMonth_NUMB) AS SupportYearMonth_NUMB
                                            FROM LSUP_Y1 b
                                           WHERE b.Case_IDNO = a.Case_IDNO
                                             AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                             AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                             AND b.SupportYearMonth_NUMB <= @Ln_SupportYearMonth_NUMB)
           AND a.EventGlobalSeq_NUMB = (SELECT MAX(c.EventGlobalSeq_NUMB) AS EventGlobalSeq_NUMB
                                          FROM LSUP_Y1 c
                                         WHERE c.Case_IDNO = a.Case_IDNO
                                           AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                           AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                           AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);
    SET @Ln_RowCount_QNTY = @@ROWCOUNT;                                           
    
    IF @Ln_RowCount_QNTY <> 0
     BEGIN
        IF (@Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotUda_AMNT - @Ln_AppTotUda_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotIvef_AMNT - @Ln_AppTotIvef_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotNffc_AMNT - @Ln_AppTotNffc_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotNonIvd_AMNT - @Ln_AppTotNonIvd_AMNT) = @Li_Zero_NUMB
           AND (@Ln_OweTotMedi_AMNT - @Ln_AppTotMedi_AMNT) = @Li_Zero_NUMB
           AND @Ln_Adjustment_AMNT = @Li_Zero_NUMB
         BEGIN
          SET @Ln_Identifier_NUMB = 1;
          SET @Lc_DummyEntry_TEXT = @Lc_Yes_INDC;
         END
        
        END

        IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
         BEGIN
          SET @Ln_Identifier_NUMB = 1;

          IF @Ln_Adjustment_AMNT = @Li_Zero_NUMB
           BEGIN
            SET @Lc_DummyEntry_TEXT = @Lc_Yes_INDC;
           END

          SET @Ln_Accrual_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotCurSup_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotCurSup_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotExptPay_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotExptPay_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotNaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotNaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotTaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotTaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotPaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotPaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotCaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotCaa_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotUpa_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotUpa_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotUda_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotUda_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotIvef_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotIvef_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotNffc_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotNffc_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotNonIvd_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotNonIvd_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotMedi_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotMedi_AMNT = @Li_Zero_NUMB;
          SET @Ln_AppTotFuture_AMNT = @Li_Zero_NUMB;
         END

        IF @Lc_DummyEntry_TEXT = @Lc_Yes_INDC
         BEGIN
          SET @Ln_Adjustment_AMNT = @Li_Zero_NUMB;
         END

        SET @Ln_Identifier_NUMB = @Li_Zero_NUMB;
       END
	
      SET @Ln_TransactionNaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionPaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionCaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionUpa_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionUda_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionTaa_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionIvef_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionNffc_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionNonIvd_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionMedi_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionFuture_AMNT = @Li_Zero_NUMB;
      SET @Ln_TransactionCurSup_AMNT = @Li_Zero_NUMB;

      IF @Lc_TypeObligation_CODE NOT IN (@Lc_TypeObligationC_CODE, @Lc_TypeObligationF_CODE)
       BEGIN
        SET @Ln_TransactionExptPay_AMNT = @Li_Zero_NUMB;
       END

      IF @Ac_TypeDebt_CODE = @Lc_TypeDebtMedicalSupp_CODE
       BEGIN
        IF @Lc_WelfareElig_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
         BEGIN
          SET @Ln_AdjustmentMedi_AMNT = @Ln_AdjustmentMedi_AMNT + @Ln_Adjustment_AMNT;
          SET @Ln_TransactionMedi_AMNT = @Ln_AdjustmentMedi_AMNT;
         END
        ELSE
         BEGIN
          IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIve_CODE
           BEGIN
            SET @Ln_AdjustmentIvef_AMNT = @Ln_AdjustmentIvef_AMNT + @Ln_Adjustment_AMNT;
            SET @Ln_TransactionNffc_AMNT = @Ln_AdjustmentNffc_AMNT;
            SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
            SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
            SET @Ln_TransactionTaa_AMNT = @Ln_AdjustmentTaa_AMNT;
            SET @Ln_TransactionCaa_AMNT = @Ln_AdjustmentCaa_AMNT;
            SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
            SET @Ln_TransactionUpa_AMNT = @Ln_AdjustmentUpa_AMNT;
            SET @Ln_TransactionUda_AMNT = @Ln_AdjustmentUda_AMNT;
            SET @Ln_TransactionIvef_AMNT = @Ln_AdjustmentIvef_AMNT;
           END
          ELSE
           BEGIN
            IF @Lc_WelfareElig_CODE = @Lc_WelfareEligFosterCare_CODE
             BEGIN
              SET @Ln_AdjustmentNffc_AMNT = @Ln_AdjustmentNffc_AMNT + @Ln_Adjustment_AMNT;
              SET @Ln_TransactionNffc_AMNT = @Ln_AdjustmentNffc_AMNT;
              SET @Ln_TransactionIvef_AMNT = @Ln_AdjustmentIvef_AMNT;
              SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
              SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
              SET @Ln_TransactionTaa_AMNT = @Ln_AdjustmentTaa_AMNT;
              SET @Ln_TransactionCaa_AMNT = @Ln_AdjustmentCaa_AMNT;
              SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
              SET @Ln_TransactionUpa_AMNT = @Ln_AdjustmentUpa_AMNT;
              SET @Ln_TransactionUda_AMNT = @Ln_AdjustmentUda_AMNT;
             END
            ELSE
             BEGIN
              IF @Lc_WelfareElig_CODE IN (@Lc_WelfareEligNonIvd_CODE)
               BEGIN
                IF @Lc_DummyEntry_TEXT = @Lc_Yes_INDC
                 BEGIN
                  SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                  SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
                 END
                ELSE
                 BEGIN
                  SET @Ls_Sql_TEXT = 'SELECT_SORD_Y1 - 1';
                  SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

                  SELECT @Lc_DirectPay_INDC = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.DirectPay_INDC), @Lc_No_INDC)
                    FROM SORD_Y1 a
                   WHERE a.Case_IDNO = @An_Case_IDNO
                     AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                     AND a.EndValidity_DATE = @Ld_High_DATE;

                  IF @Lc_DirectPay_INDC = @Lc_No_INDC
                   BEGIN
                    SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                    SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
                   END
                  ELSE
                   BEGIN
                    SET @Ln_AdjustmentNonIvd_AMNT = @Li_Zero_NUMB;
                    SET @Ln_TransactionNonIvd_AMNT = @Li_Zero_NUMB;
                    SET @Ln_MtdAccrual_NUMB = @Li_Zero_NUMB;
                    SET @Ln_TransactionExptPay_AMNT = @Li_Zero_NUMB;
                   END
                 END

                SET @Ln_TransactionIvef_AMNT = @Ln_AdjustmentIvef_AMNT;
                SET @Ln_TransactionNffc_AMNT = @Ln_AdjustmentNffc_AMNT;
                SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
                SET @Ln_TransactionTaa_AMNT = @Ln_AdjustmentTaa_AMNT;
                SET @Ln_TransactionCaa_AMNT = @Ln_AdjustmentCaa_AMNT;
                SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
                SET @Ln_TransactionUpa_AMNT = @Ln_AdjustmentUpa_AMNT;
                SET @Ln_TransactionUda_AMNT = @Ln_AdjustmentUda_AMNT;
               END
              ELSE
               BEGIN
                SET @Ln_AdjustmentNaa_AMNT = @Ln_AdjustmentNaa_AMNT + @Ln_Adjustment_AMNT;
                SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
               END
             END
           END
         END
       END
      ELSE
       BEGIN
        IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIve_CODE
         BEGIN
          SET @Ln_AdjustmentIvef_AMNT = @Ln_AdjustmentIvef_AMNT + @Ln_Adjustment_AMNT;
          SET @Ln_TransactionNffc_AMNT = @Ln_AdjustmentNffc_AMNT;
          SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
          SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
          SET @Ln_TransactionTaa_AMNT = @Ln_AdjustmentTaa_AMNT;
          SET @Ln_TransactionCaa_AMNT = @Ln_AdjustmentCaa_AMNT;
          SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
          SET @Ln_TransactionUpa_AMNT = @Ln_AdjustmentUpa_AMNT;
          SET @Ln_TransactionUda_AMNT = @Ln_AdjustmentUda_AMNT;
          SET @Ln_TransactionIvef_AMNT = @Ln_AdjustmentIvef_AMNT;
         END
        ELSE
         BEGIN
          IF @Lc_WelfareElig_CODE = @Lc_WelfareEligFosterCare_CODE
           BEGIN
            SET @Ln_AdjustmentNffc_AMNT = @Ln_AdjustmentNffc_AMNT + @Ln_Adjustment_AMNT;
            SET @Ln_TransactionNffc_AMNT = @Ln_AdjustmentNffc_AMNT;
            SET @Ln_TransactionIvef_AMNT = @Ln_AdjustmentIvef_AMNT;
            SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
            SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
            SET @Ln_TransactionTaa_AMNT = @Ln_AdjustmentTaa_AMNT;
            SET @Ln_TransactionCaa_AMNT = @Ln_AdjustmentCaa_AMNT;
            SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
            SET @Ln_TransactionUpa_AMNT = @Ln_AdjustmentUpa_AMNT;
            SET @Ln_TransactionUda_AMNT = @Ln_AdjustmentUda_AMNT;
           END
          ELSE
           BEGIN
            IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIvd_CODE
             BEGIN
              IF @Lc_DummyEntry_TEXT = @Lc_Yes_INDC
               BEGIN
                SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
               END
              ELSE
               BEGIN
                SET @Ls_Sql_TEXT = 'SELECT_SORD_Y1 - 2';
                SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

                SELECT @Lc_DirectPay_INDC = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.DirectPay_INDC), @Lc_No_INDC)
                  FROM SORD_Y1 a
                 WHERE a.Case_IDNO = @An_Case_IDNO
                   AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                   AND a.EndValidity_DATE = @Ld_High_DATE;

                IF @Lc_DirectPay_INDC = @Lc_No_INDC
                 BEGIN
                  SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                  SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
                 END
                ELSE
                 BEGIN
                  SET @Ln_AdjustmentNonIvd_AMNT = @Li_Zero_NUMB;
                  SET @Ln_TransactionNonIvd_AMNT = @Li_Zero_NUMB;
                  SET @Ln_MtdAccrual_NUMB = @Li_Zero_NUMB;
                  SET @Ln_TransactionExptPay_AMNT = @Li_Zero_NUMB;
                 END
               END

              SET @Ln_TransactionIvef_AMNT = @Ln_AdjustmentIvef_AMNT;
              SET @Ln_TransactionNffc_AMNT = @Ln_AdjustmentNffc_AMNT;
              SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
              SET @Ln_TransactionTaa_AMNT = @Ln_AdjustmentTaa_AMNT;
              SET @Ln_TransactionCaa_AMNT = @Ln_AdjustmentCaa_AMNT;
              SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
              SET @Ln_TransactionUpa_AMNT = @Ln_AdjustmentUpa_AMNT;
              SET @Ln_TransactionUda_AMNT = @Ln_AdjustmentUda_AMNT;
             END
           END
         END
       END

      IF SUBSTRING(@Ac_Fips_CODE, 1, 2) != @Lc_DelawareFips_CODE
         AND @Ac_TypeDebt_CODE != @Lc_TypeDebtMedicalSupp_CODE
       BEGIN
        IF @Lc_WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
         BEGIN
          SET @Ln_AdjustmentPaa_AMNT = @Ln_AdjustmentPaa_AMNT + @Ln_Adjustment_AMNT;
          SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
         END
        ELSE
         BEGIN
          IF @Lc_WelfareElig_CODE IN (@Lc_WelfareEligNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
           BEGIN
            SET @Ln_AdjustmentNaa_AMNT = @Ln_AdjustmentNaa_AMNT + @Ln_Adjustment_AMNT;
            SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
           END
         END
       END

      IF @Lc_WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
         AND SUBSTRING(@Ac_Fips_CODE, 1, 2) = @Lc_DelawareFips_CODE
       BEGIN
        IF @Lc_DesnPoint_TEXT = @Lc_No_INDC
         BEGIN
          SET @Ad_Begin_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(CAST(@Ln_SupportYearMonth_NUMB AS NUMERIC(6, 0)), @Lc_DateFormatYyyymm_TEXT);
         END

        SET @Lc_DesnPoint_TEXT = @Lc_Yes_INDC;
       END

      IF @Lc_WelfareElig_CODE != @Lc_WelfareEligNonIvd_CODE
       BEGIN
        SET @Ln_TransactionCurSup_AMNT = @Ln_Adjustment_AMNT;
        SET @Ln_OweTotCurSup_AMNT = @Ln_OweTotCurSup_AMNT + @Ln_TransactionCurSup_AMNT;
       END
      ELSE
       BEGIN
        IF @Lc_DirectPay_INDC = @Lc_No_INDC
         BEGIN
          SET @Ln_TransactionCurSup_AMNT = @Ln_Adjustment_AMNT;
          SET @Ln_OweTotCurSup_AMNT = @Ln_OweTotCurSup_AMNT + @Ln_TransactionCurSup_AMNT;
         END
        ELSE
         BEGIN
          SET @Ln_TransactionCurSup_AMNT = @Li_Zero_NUMB;
          SET @Ln_OweTotCurSup_AMNT = @Li_Zero_NUMB;
         END
       END

      IF @Ac_TypeDebt_CODE != @Lc_TypeDebtMedicalSupp_CODE
         AND @Lc_WelfareElig_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareEligNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
         AND SUBSTRING(@Ac_Fips_CODE, 1, 2) = @Lc_DelawareFips_CODE
       BEGIN
        SET @Ln_TransactionIvef_AMNT = @Ln_AdjustmentIvef_AMNT;
        SET @Ln_TransactionNffc_AMNT = @Ln_AdjustmentNffc_AMNT;
        SET @Ln_TransactionNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT;
        SET @Ln_TransactionPaa_AMNT = @Ln_AdjustmentPaa_AMNT;
        SET @Ln_TransactionTaa_AMNT = @Ln_AdjustmentTaa_AMNT;
        SET @Ln_TransactionCaa_AMNT = @Ln_AdjustmentCaa_AMNT;
        SET @Ln_TransactionNaa_AMNT = @Ln_AdjustmentNaa_AMNT;
        SET @Ln_TransactionUpa_AMNT = @Ln_AdjustmentUpa_AMNT;
        SET @Ln_TransactionUda_AMNT = @Ln_AdjustmentUda_AMNT;

        IF @Lc_WelfareElig_CODE IN (@Lc_WelfareEligNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
         BEGIN
          SET @Ln_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT + @Ln_Adjustment_AMNT;
          SET @Ln_AdjustmentNaa_AMNT = @Ln_AdjustmentNaa_AMNT + @Ln_Adjustment_AMNT;
         END
        ELSE
         BEGIN
          IF @Lc_WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
           BEGIN
            SET @Ln_TransactionPaa_AMNT = @Ln_TransactionPaa_AMNT + @Ln_Adjustment_AMNT;
            SET @Ln_AdjustmentPaa_AMNT = @Ln_AdjustmentPaa_AMNT + @Ln_Adjustment_AMNT;
           END
         END

        SET @Ln_ArrPaa_AMNT = @Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT + @Ln_AdjustmentPaa_AMNT;
        SET @Ln_ArrNaa_AMNT = @Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT + @Ln_AdjustmentNaa_AMNT;
        SET @Ln_ArrCaa_AMNT = @Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT + @Ln_AdjustmentCaa_AMNT;
        SET @Ln_ArrTaa_AMNT = @Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT + @Ln_AdjustmentTaa_AMNT;
        SET @Ln_ArrUda_AMNT = @Ln_OweTotUda_AMNT - @Ln_AppTotUda_AMNT + @Ln_AdjustmentUda_AMNT;
        SET @Ln_ArrUpa_AMNT = @Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT + @Ln_AdjustmentUpa_AMNT;
        SET @Ln_ArrNonIvd_AMNT = @Ln_OweTotNonIvd_AMNT - @Ln_AppTotNonIvd_AMNT;

        IF CONVERT(VARCHAR(6), @Ld_ProcessingFirstDay_DATE, 112) = CONVERT(VARCHAR(6), @Ld_Run_DATE, 112)
         BEGIN
          IF @Lc_WelfareElig_CODE IN (@Lc_WelfareEligNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
           BEGIN
            SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
           END
          ELSE
           BEGIN
            IF @Lc_WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
             BEGIN
              SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
             END
           END
         END

        IF @Ln_ArrPaa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrUda_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrNaa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrCaa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrUpa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrTaa_AMNT < @Li_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CIRCULAR_RULE - 1';
          SET @Ls_SqlData_TEXT = '';
         
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
         END
       END

      IF @Lc_WelfareElig_CODE NOT IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareEligNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
         AND SUBSTRING(@Ac_Fips_CODE, 1, 2) = @Lc_DelawareFips_CODE
       BEGIN
        SET @Ln_ArrPaa_AMNT = @Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT + @Ln_AdjustmentPaa_AMNT;
        SET @Ln_ArrNaa_AMNT = @Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT + @Ln_AdjustmentNaa_AMNT;
        SET @Ln_ArrCaa_AMNT = @Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT + @Ln_AdjustmentCaa_AMNT;
        SET @Ln_ArrTaa_AMNT = @Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT + @Ln_AdjustmentTaa_AMNT;
        SET @Ln_ArrUda_AMNT = @Ln_OweTotUda_AMNT - @Ln_AppTotUda_AMNT + @Ln_AdjustmentUda_AMNT;
        SET @Ln_ArrUpa_AMNT = @Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT + @Ln_AdjustmentUpa_AMNT;

        IF @Ln_ArrPaa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrUda_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrNaa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrCaa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrUpa_AMNT < @Li_Zero_NUMB
            OR @Ln_ArrTaa_AMNT < @Li_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CIRCULAR_RULE - 2';
          SET @Ls_SqlData_TEXT = '';
          
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
         END
       END

	  --13781 - OWIZ - Regular Distribution, APDFI050. DEB0560 failed -START-
      IF @Ln_Adjustment_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentNaa_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentTaa_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentPaa_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentCaa_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentUpa_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentUda_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentIvef_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentNffc_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentNonIvd_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentMedi_AMNT != @Li_Zero_NUMB
          OR @Ln_AdjustmentMeds_AMNT != @Li_Zero_NUMB
          OR @Lc_DummyEntry_TEXT = @Lc_Yes_INDC
          OR @Ln_MtdAccrualRhs_NUMB != @Ln_MtdAccrualLhs_NUMB
		  OR @Ln_RowCountLsup_QNTY = @Li_Zero_NUMB
       BEGIN
        SET @Ln_OweTotNaa_AMNT = @Ln_OweTotNaa_AMNT + @Ln_TransactionNaa_AMNT;
        SET @Ln_OweTotTaa_AMNT = @Ln_OweTotTaa_AMNT + @Ln_TransactionTaa_AMNT;
        SET @Ln_OweTotPaa_AMNT = @Ln_OweTotPaa_AMNT + @Ln_TransactionPaa_AMNT;
        SET @Ln_OweTotCaa_AMNT = @Ln_OweTotCaa_AMNT + @Ln_TransactionCaa_AMNT;
        SET @Ln_OweTotUpa_AMNT = @Ln_OweTotUpa_AMNT + @Ln_TransactionUpa_AMNT;
        SET @Ln_OweTotUda_AMNT = @Ln_OweTotUda_AMNT + @Ln_TransactionUda_AMNT;
        SET @Ln_OweTotIvef_AMNT = @Ln_OweTotIvef_AMNT + @Ln_TransactionIvef_AMNT;
        SET @Ln_OweTotMedi_AMNT = @Ln_OweTotMedi_AMNT + @Ln_TransactionMedi_AMNT;
        SET @Ln_OweTotNffc_AMNT = @Ln_OweTotNffc_AMNT + @Ln_TransactionNffc_AMNT;
        SET @Ln_OweTotNonIvd_AMNT = @Ln_OweTotNonIvd_AMNT + @Ln_TransactionNonIvd_AMNT;
        
        SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';
        SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareElig_CODE,'')+ ', MtdCurSupOwed_AMNT = ' + ISNULL(CAST( @Ln_MtdAccrual_NUMB AS VARCHAR ),'')+ ', TransactionCurSup_AMNT = ' + ISNULL(CAST( @Ln_TransactionCurSup_AMNT AS VARCHAR ),'')+ ', OweTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_OweTotCurSup_AMNT AS VARCHAR ),'')+ ', AppTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_AppTotCurSup_AMNT AS VARCHAR ),'')+ ', TransactionExptPay_AMNT = ' + ISNULL(CAST( @Ln_TransactionExptPay_AMNT AS VARCHAR ),'')+ ', OweTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_OweTotExptPay_AMNT AS VARCHAR ),'')+ ', AppTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_AppTotExptPay_AMNT AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionNaa_AMNT AS VARCHAR ),'')+ ', OweTotNaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotNaa_AMNT AS VARCHAR ),'')+ ', AppTotNaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotNaa_AMNT AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionTaa_AMNT AS VARCHAR ),'')+ ', OweTotTaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotTaa_AMNT AS VARCHAR ),'')+ ', AppTotTaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotTaa_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionPaa_AMNT AS VARCHAR ),'')+ ', OweTotPaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotPaa_AMNT AS VARCHAR ),'')+ ', AppTotPaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotPaa_AMNT AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionCaa_AMNT AS VARCHAR ),'')+ ', OweTotCaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotCaa_AMNT AS VARCHAR ),'')+ ', AppTotCaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotCaa_AMNT AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_TransactionUpa_AMNT AS VARCHAR ),'')+ ', OweTotUpa_AMNT = ' + ISNULL(CAST( @Ln_OweTotUpa_AMNT AS VARCHAR ),'')+ ', AppTotUpa_AMNT = ' + ISNULL(CAST( @Ln_AppTotUpa_AMNT AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_TransactionUda_AMNT AS VARCHAR ),'')+ ', OweTotUda_AMNT = ' + ISNULL(CAST( @Ln_OweTotUda_AMNT AS VARCHAR ),'')+ ', AppTotUda_AMNT = ' + ISNULL(CAST( @Ln_AppTotUda_AMNT AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL(CAST( @Ln_TransactionIvef_AMNT AS VARCHAR ),'')+ ', OweTotIvef_AMNT = ' + ISNULL(CAST( @Ln_OweTotIvef_AMNT AS VARCHAR ),'')+ ', AppTotIvef_AMNT = ' + ISNULL(CAST( @Ln_AppTotIvef_AMNT AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL(CAST( @Ln_TransactionNffc_AMNT AS VARCHAR ),'')+ ', OweTotNffc_AMNT = ' + ISNULL(CAST( @Ln_OweTotNffc_AMNT AS VARCHAR ),'')+ ', AppTotNffc_AMNT = ' + ISNULL(CAST( @Ln_AppTotNffc_AMNT AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( @Ln_TransactionNonIvd_AMNT AS VARCHAR ),'')+ ', OweTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_OweTotNonIvd_AMNT AS VARCHAR ),'')+ ', AppTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_AppTotNonIvd_AMNT AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL(CAST( @Ln_TransactionMedi_AMNT AS VARCHAR ),'')+ ', OweTotMedi_AMNT = ' + ISNULL(CAST( @Ln_OweTotMedi_AMNT AS VARCHAR ),'')+ ', AppTotMedi_AMNT = ' + ISNULL(CAST( @Ln_AppTotMedi_AMNT AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL(CAST( @Ln_TransactionFuture_AMNT AS VARCHAR ),'')+ ', AppTotFuture_AMNT = ' + ISNULL(CAST( @Ln_AppTotFuture_AMNT AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ObligationModification1020_NUMB AS VARCHAR ),'');

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
                TransactionNffc_AMNT,
                OweTotNffc_AMNT,
                AppTotNffc_AMNT,
                TransactionNonIvd_AMNT,
                OweTotNonIvd_AMNT,
                AppTotNonIvd_AMNT,
                TransactionMedi_AMNT,
                OweTotMedi_AMNT,
                AppTotMedi_AMNT,
                TransactionFuture_AMNT,
                AppTotFuture_AMNT,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Receipt_DATE,
                Distribute_DATE,
                TypeRecord_CODE,
                EventGlobalSeq_NUMB,
                EventFunctionalSeq_NUMB)
        VALUES ( @An_Case_IDNO,--Case_IDNO
                 @An_OrderSeq_NUMB,--OrderSeq_NUMB
                 @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
                 @Ln_SupportYearMonth_NUMB,--SupportYearMonth_NUMB
                 @Lc_WelfareElig_CODE,--TypeWelfare_CODE
                 @Ln_MtdAccrual_NUMB,--MtdCurSupOwed_AMNT
                 @Ln_TransactionCurSup_AMNT,--TransactionCurSup_AMNT
                 @Ln_OweTotCurSup_AMNT,--OweTotCurSup_AMNT
                 @Ln_AppTotCurSup_AMNT,--AppTotCurSup_AMNT
                 @Ln_TransactionExptPay_AMNT,--TransactionExptPay_AMNT
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
                 @Ln_TransactionNffc_AMNT,--TransactionNffc_AMNT
                 @Ln_OweTotNffc_AMNT,--OweTotNffc_AMNT
                 @Ln_AppTotNffc_AMNT,--AppTotNffc_AMNT
                 @Ln_TransactionNonIvd_AMNT,--TransactionNonIvd_AMNT
                 @Ln_OweTotNonIvd_AMNT,--OweTotNonIvd_AMNT
                 @Ln_AppTotNonIvd_AMNT,--AppTotNonIvd_AMNT
                 @Ln_TransactionMedi_AMNT,--TransactionMedi_AMNT
                 @Ln_OweTotMedi_AMNT,--OweTotMedi_AMNT
                 @Ln_AppTotMedi_AMNT,--AppTotMedi_AMNT
                 @Ln_TransactionFuture_AMNT,--TransactionFuture_AMNT
                 @Ln_AppTotFuture_AMNT,--AppTotFuture_AMNT
                 @Ac_CheckRecipient_ID,--CheckRecipient_ID
                 @Ac_CheckRecipient_CODE,--CheckRecipient_CODE
                 @Ld_Low_DATE,--Batch_DATE
                 @Li_Zero_NUMB,--Batch_NUMB
                 @Li_Zero_NUMB,--SeqReceipt_NUMB
                 @Lc_Space_TEXT,--SourceBatch_CODE
                 @Ld_Low_DATE,--Receipt_DATE
                 @Ld_Run_DATE,--Distribute_DATE
                 @Lc_Space_TEXT,--TypeRecord_CODE
                 @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                 @Li_ObligationModification1020_NUMB--EventFunctionalSeq_NUMB
        );

        SET @Ln_RowCount_QNTY = @@ROWCOUNT;

        IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'INSERT_LSUP_Y1 FAILED';
          
          RAISERROR(50001,16,1);
         END
       END
       
       --13781 - OWIZ - Regular Distribution, APDFI050. DEB0560 failed -END-
     END TRY

     BEGIN CATCH
      IF @Ln_Identifier_NUMB = 1
       BEGIN
        IF @Ac_TypeDebt_CODE = @Lc_TypeDebtMedicalSupp_CODE
         BEGIN
          IF @Lc_WelfareElig_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
           BEGIN
            SET @Ln_AdjustmentMedi_AMNT = @Ln_AdjustmentMedi_AMNT + @Ln_Adjustment_AMNT;
            SET @Ln_TransactionMedi_AMNT = @Ln_AdjustmentMedi_AMNT;
           END
          ELSE
           BEGIN
            IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIve_CODE
             BEGIN
              SET @Ln_AdjustmentIvef_AMNT = @Ln_AdjustmentIvef_AMNT + @Ln_Adjustment_AMNT;
             END
            ELSE
             BEGIN
              IF @Lc_WelfareElig_CODE = @Lc_WelfareEligFosterCare_CODE
               BEGIN
                SET @Ln_AdjustmentNffc_AMNT = @Ln_AdjustmentNffc_AMNT + @Ln_Adjustment_AMNT;
               END
              ELSE
               BEGIN
                IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIvd_CODE
                 BEGIN
                  IF @Lc_DummyEntry_TEXT = @Lc_Yes_INDC
                   BEGIN
                    SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                   END
                  ELSE
                   BEGIN
                    SET @Ls_Sql_TEXT = ' SELECT_SORD_Y1 ';
                    SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(2)), '');

                    SELECT @Lc_DirectPay_INDC = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.DirectPay_INDC), @Lc_No_INDC)
                      FROM SORD_Y1 a
                     WHERE a.Case_IDNO = @An_Case_IDNO
                       AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                       AND a.EndValidity_DATE = @Ld_High_DATE;

                    IF @Lc_DirectPay_INDC = @Lc_No_INDC
                     BEGIN
                      SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                     END
                    ELSE
                     BEGIN
                      SET @Ln_AdjustmentNonIvd_AMNT = @Li_Zero_NUMB;
                     END
                   END
                 END
                ELSE
                 BEGIN
                  IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIve_CODE
                   BEGIN
                    SET @Ln_AdjustmentIvef_AMNT = @Ln_AdjustmentIvef_AMNT + @Ln_Adjustment_AMNT;
                   END
                  ELSE
                   BEGIN
                    IF @Lc_WelfareElig_CODE = @Lc_WelfareEligFosterCare_CODE
                     BEGIN
                      SET @Ln_AdjustmentNffc_AMNT = @Ln_AdjustmentNffc_AMNT + @Ln_Adjustment_AMNT;
                     END
                    ELSE
                     BEGIN
                      IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIvd_CODE
                       BEGIN
                        IF @Lc_DummyEntry_TEXT = @Lc_Yes_INDC
                         BEGIN
                          SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                         END
                        ELSE
                         BEGIN
                          SET @Ls_Sql_TEXT = ' SELECT_SORD_Y1 ';
                          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(2)), '');

                          SELECT @Lc_DirectPay_INDC = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.DirectPay_INDC), @Lc_No_INDC)
                            FROM SORD_Y1 a
                           WHERE a.Case_IDNO = @An_Case_IDNO
                             AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                             AND a.EndValidity_DATE = @Ld_High_DATE;

                          IF @Lc_DirectPay_INDC = @Lc_No_INDC
                           BEGIN
                            SET @Ln_AdjustmentNonIvd_AMNT = @Ln_AdjustmentNonIvd_AMNT + @Ln_Adjustment_AMNT;
                           END
                          ELSE
                           BEGIN
                            SET @Ln_AdjustmentNonIvd_AMNT = @Li_Zero_NUMB;
                           END
                         END
                       END
                      ELSE
                       BEGIN
                        IF @Lc_WelfareElig_CODE IN (@Lc_WelfareEligNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
                         BEGIN
                          SET @Ln_AdjustmentNaa_AMNT = @Ln_AdjustmentNaa_AMNT + @Ln_Adjustment_AMNT;
                          SET @Ln_AdjustmentCaa_AMNT = @Ln_AdjustmentCaa_AMNT + @Ln_AdjustmentTaa_AMNT;
                          SET @Ln_AdjustmentTaa_AMNT = @Li_Zero_NUMB;
                         END
                        ELSE
                         BEGIN
                          IF @Lc_WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
                           BEGIN
                            IF @Lc_DesnPoint_TEXT = @Lc_No_INDC
                             BEGIN
                              SET @Ad_Begin_DATE = dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2(CAST(@Ln_SupportYearMonth_NUMB AS NUMERIC(6, 0)), @Lc_DateFormatYyyymm_TEXT);
                             END

                            SET @Lc_DesnPoint_TEXT = @Lc_Yes_INDC;
                            SET @Ln_AdjustmentPaa_AMNT = @Ln_AdjustmentPaa_AMNT + @Ln_Adjustment_AMNT;
                            SET @Ln_AdjustmentTaa_AMNT = @Ln_AdjustmentTaa_AMNT + @Ln_AdjustmentCaa_AMNT + @Ln_AdjustmentUpa_AMNT;
                            SET @Ln_AdjustmentCaa_AMNT = @Li_Zero_NUMB;
                            SET @Ln_AdjustmentUpa_AMNT = @Li_Zero_NUMB;
                           END
                         END
                       END
                     END
                   END
                 END
               END
             END
           END
         END
       END
     END CATCH

     PROCESS_NEXT_MTH:

     SET @Ld_ProcessingFirstDay_DATE = DATEADD(m, 1, @Ld_ProcessingFirstDay_DATE);
     SET @Ld_ProcessingLastDay_DATE = DATEADD(m, 1, @Ld_ProcessingLastDay_DATE);

     IF CONVERT(VARCHAR(6), @Ld_ProcessingLastDay_DATE, 112) = CONVERT(VARCHAR(6), @Ld_Run_DATE, 112)
      BEGIN
       SET @Ld_ProcessingLastDay_DATE = @Ld_Run_DATE;
      END

     SET @Ln_MtdAccrual_NUMB = @Li_Zero_NUMB;
     SET @Ln_Adjustment_AMNT = @Li_Zero_NUMB;

     IF @Ln_Identifier_NUMB = 1
      BEGIN
       SET @Ln_Identifier_NUMB = @Li_Zero_NUMB;
       SET @Lc_DummyEntry_TEXT = @Lc_No_INDC;
      END

     IF @Ld_TmpAcclNext_DATE = @Ld_High_DATE
        AND CONVERT(VARCHAR(6), @Ld_ProcessingFirstDay_DATE, 112) <= CONVERT(VARCHAR(6), @Ld_Run_DATE, 112)
      BEGIN
       SET @Lc_DummyEntry_TEXT = @Lc_Yes_INDC;
      END
     ELSE
      BEGIN
       SET @Lc_DummyEntry_TEXT = @Lc_No_INDC;
      END
    END

   IF @An_OblmArrayRowsRhs_NUMB > @Li_Zero_NUMB
    BEGIN
     IF @Ld_TmpAcclNext_DATE > @Ld_EndOble_DATE
      BEGIN
       SET @Ld_TmpAcclNext_DATE = @Ld_High_DATE;
      END

     IF @Ld_BeginObligationRhs_DATE > @Ld_Run_DATE
      BEGIN
       SET @Ld_TmpAcclNext_DATE = @Ld_BeginObligationRhs_DATE;
       SET @Ld_AccrualLastRhs_DATE = @Ld_BeginObligationRhs_DATE;
      END

     IF @Ld_TmpAcclNext_DATE > @Ld_EndOble_DATE
      BEGIN
       SET @Ld_AccrualNextUpd_DATE = @Ld_High_DATE;
      END
     ELSE
      BEGIN
       SET @Ld_AccrualNextUpd_DATE = @Ld_TmpAcclNext_DATE;
      END

     IF @Lc_WelfareElig_CODE = @Lc_WelfareEligNonIvd_CODE
        AND @Lc_DirectPay_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Ld_AccrualNextUpd_DATE = @Ld_High_DATE;
      END

     SET @Ld_AccrualNext_DATE = @Ld_AccrualNextRhs_DATE;
     SET @Ls_Sql_TEXT = 'UPDATE OBLE_Y1 - 2';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE OBLE_Y1
        SET AccrualNext_DATE = @Ld_AccrualNextUpd_DATE,
            AccrualLast_DATE = ISNULL(@Ld_AccrualLastRhs_DATE, @Ld_Low_DATE)
      WHERE Case_IDNO = @An_Case_IDNO
        AND OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
        AND @Ld_BeginObligationRhs_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE OBLE_Y1 FAILED - 2';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Li_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
