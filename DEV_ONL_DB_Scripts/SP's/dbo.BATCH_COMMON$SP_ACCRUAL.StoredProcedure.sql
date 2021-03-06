/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_ACCRUAL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_ACCRUAL.

Programmer Name		: IMP Team

Description			: This program calculate next accrual date according to the Frequency of payment and
					  calculate accrual amount.
					  
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_ACCRUAL]
 @Ac_FreqPeriodic_CODE       CHAR(1),
 @An_Periodic_AMNT           NUMERIC(11, 2),
 @An_ExpectToPay_AMNT        NUMERIC(11, 2),
 @Ad_BeginObligation_DATE    DATE,
 @Ad_EndObligation_DATE      DATE,
 @Ad_AccrualEnd_DATE         DATE,
 @Ad_AccrualNext_DATE        DATE OUTPUT,
 @Ad_AccrualLast_DATE        DATE OUTPUT,
 @An_TransactionCurSup_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_TransactionExptPay_AMNT NUMERIC(11, 2) OUTPUT,
 @An_MtdAccrual_AMNT         NUMERIC(11, 2) OUTPUT,
 @Ac_MtdProcess_INDC         CHAR(1) OUTPUT,
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  /*       
  FRQA	FRQ1		A	ANNUALLY
  FRQA	FRQ1		B	BIWEEKLY
  FRQA	FRQ1		M	MONTHLY
  FRQA	FRQ1		O	ONE TIME ONLY
  FRQA	FRQ1		Q	QUARTERLY
  FRQA	FRQ1		S	SEMI MONTHLY
  FRQA	FRQ1		W	WEEKLY 
  Frequency
  */
  DECLARE @Li_FirstDayOfMonth_NUMB      SMALLINT = 1,
          @Lc_FrequencyBiWeekly_CODE    CHAR(1) = 'B',
          @Lc_FrequencyMonthly_CODE     CHAR(1) = 'M',
          @Lc_FrequencyWeekly_CODE      CHAR(1) = 'W',
          @Lc_FrequencySemiMonthly_CODE CHAR(1) = 'S',
          @Lc_FrequencyAnnually_CODE    CHAR(1) = 'A',
          @Lc_FrequencyQuarterly_CODE   CHAR(1) = 'Q',
          @Lc_FrequencyOneTimeOnly_CODE CHAR(1) = 'O',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_Yes_INDC                  CHAR(1) = 'Y',
          @Lc_AccrualDay15_NUMB         CHAR(2) = '15',
          @Lc_AccrualDay01_NUMB         CHAR(2) = '01',
          @Ls_Routine_TEXT              VARCHAR(100) = 'BATCH_COMMON$SP_ACCRUAL',
          @Ld_High_DATE                 DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_Periodic_AMNT         NUMERIC(11, 2),
          @Ln_ExpectToPay_AMNT      NUMERIC(11, 2),
          @Li_DaysToAccure_NUMB     SMALLINT,
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_Sqldata_TEXT          VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '',
          @Ld_AccrualNext_DATE      DATE,
          @Ld_AccrualLast_DATE      DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_AccrualNext_DATE = @Ad_AccrualNext_DATE;
   SET @Ln_Periodic_AMNT = @An_Periodic_AMNT;
   SET @Ln_ExpectToPay_AMNT = @An_ExpectToPay_AMNT;
   SET @Ld_AccrualLast_DATE = ISNULL(@Ad_AccrualLast_DATE, @Ad_BeginObligation_DATE);

   /* IF condition added to stop deriving the accrual date is the OBLE_Y1 has ended.
      This will make sure that the calculation does not go for proration logic
    */
   IF(@Ad_AccrualNext_DATE <= @Ad_EndObligation_DATE)
    BEGIN
     IF (@Ac_FreqPeriodic_CODE = @Lc_FrequencyMonthly_CODE)
      BEGIN
      /* re-calculate the next accrual date for Monthly obligations,
              if the last accrual date is last day of Feb since February only has 28 days, 
              it changed the March and future accruals to the last day of each month */
      /*  monthly OBLE_Y1 date if it falls on the 
         30th of April, June, Sept and Nov. needs to be corrected 
         for 30 on May, Oct, Dec, July*/
       /*
       When the frequency is monthly, the Date Accrual Next is obtained by adding a month.
       
       If the next accrual date falls on an invalid date, the system should decrement the day of accrual e.g. 
       if the next accrual date falls on February 29th and 30th and all months that do not have a 31st.
       */
       IF (@Ld_AccrualNext_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_AccrualNext_DATE)
           AND MONTH(@Ld_AccrualNext_DATE) IN (2, 4, 6, 9, 11))
        BEGIN
         SET @Ld_AccrualNext_DATE = DATEADD(MONTH, 1, @Ad_AccrualNext_DATE);
         SET @Ld_AccrualNext_DATE = CAST(CAST(MONTH(@Ld_AccrualNext_DATE) AS VARCHAR) + '/' + CAST(DAY (@Ld_AccrualLast_DATE) AS VARCHAR) + '/' + CAST(YEAR (@Ld_AccrualNext_DATE) AS VARCHAR) AS DATE);
        END
       ELSE
        BEGIN
         SET @Ld_AccrualNext_DATE = DATEADD(MONTH, 1, @Ad_AccrualNext_DATE);
        END
      END
     ELSE IF @Ac_FreqPeriodic_CODE = @Lc_FrequencySemiMonthly_CODE
      BEGIN
       /*
       When the frequency is semi-monthly, the Date Accrual Next is either the 15th of current month or the 1st of the next month
       */
       IF DATEPART(dd, @Ad_AccrualNext_DATE) = @Li_FirstDayOfMonth_NUMB
        BEGIN
         SET @Ld_AccrualNext_DATE = CONVERT(DATE, CONVERT(VARCHAR, MONTH(@Ad_AccrualNext_DATE)) + '/' + @Lc_AccrualDay15_NUMB + '/' + CONVERT(VARCHAR, YEAR(@Ad_AccrualNext_DATE)));
        END
       ELSE
        BEGIN
         SET @Ld_AccrualNext_DATE = DATEADD(MONTH, 1, @Ad_AccrualNext_DATE);
         SET @Ld_AccrualNext_DATE = CONVERT(DATE, CONVERT(VARCHAR, MONTH(@Ld_AccrualNext_DATE)) + '/' + @Lc_AccrualDay01_NUMB + '/' + CONVERT(VARCHAR, YEAR(@Ld_AccrualNext_DATE)));
        END
      END
     ELSE
      BEGIN
       /*
       	When the frequency is weekly, the Date Accrual Next is obtained by adding 7 days. 
       	When the frequency is bi weekly, the Date Accrual Next is obtained by adding 14 days.
       	When the frequency is quarterly, the Date Accrual Next is obtained by adding three months
       	When the frequency is annual, the Date Accrual Next is obtained by adding 12 months.
       	If the Date Accrual Next falls in the obligation interval of the future obligation, the current
       	obligation record will have High dates (12/31/9999) updated in this field preventing any further accrual processing. 
       */
       SET @Ld_AccrualNext_DATE = CASE @Ac_FreqPeriodic_CODE
                                   WHEN @Lc_FrequencyWeekly_CODE
                                    THEN DATEADD(week, 1, @Ad_AccrualNext_DATE)
                                   WHEN @Lc_FrequencyBiWeekly_CODE
                                    THEN DATEADD(week, 2, @Ad_AccrualNext_DATE)
                                   WHEN @Lc_FrequencyAnnually_CODE
                                    THEN DATEADD(YEAR, 1, @Ad_AccrualNext_DATE)
                                   WHEN @Lc_FrequencyQuarterly_CODE
                                    THEN DATEADD(quarter, 1, @Ad_AccrualNext_DATE)
                                   WHEN @Lc_FrequencyOneTimeOnly_CODE
                                    THEN @Ld_High_DATE
                                  END;
      END
    END -- END of Obligation End date less than Accural date
   SET @Li_DaysToAccure_NUMB = 0;

   /*   Proration logic. The following IF condition must be executed only if there is a split in the 
   charging period. ld_accrual_next will always go the next CHARging period. So check must be done
   by putting ld_accrual_next - 1  which will check whether there is split in the CHARging period
   If only ld_accrual_next is checked , it will Result_TEXT in incorrect MSO calculation 
   */
   IF DATEADD(DAY, -1, @Ld_AccrualNext_DATE) > @Ad_EndObligation_DATE
    BEGIN
     SET @Li_DaysToAccure_NUMB = DATEDIFF(DD, @Ad_AccrualNext_DATE, @Ad_EndObligation_DATE) + 1;

     IF @Ac_FreqPeriodic_CODE = @Lc_FrequencyWeekly_CODE
      BEGIN
       SET @Ln_Periodic_AMNT = ROUND((@An_Periodic_AMNT / 7) * @Li_DaysToAccure_NUMB, 2);
       SET @Ln_ExpectToPay_AMNT = ROUND((@An_ExpectToPay_AMNT / 7) * @Li_DaysToAccure_NUMB, 2);
      END
     ELSE IF @Ac_FreqPeriodic_CODE = @Lc_FrequencyBiWeekly_CODE
      BEGIN
       SET @Ln_Periodic_AMNT = ROUND((@An_Periodic_AMNT / 14) * @Li_DaysToAccure_NUMB, 2);
       SET @Ln_ExpectToPay_AMNT = ROUND((@An_ExpectToPay_AMNT / 14) * @Li_DaysToAccure_NUMB, 2);
      END
     ELSE IF @Ac_FreqPeriodic_CODE = @Lc_FrequencySemiMonthly_CODE
      BEGIN
       SET @Ln_Periodic_AMNT = ROUND((@An_Periodic_AMNT * 24 / 365) * @Li_DaysToAccure_NUMB, 2);
       SET @Ln_ExpectToPay_AMNT = ROUND((@An_ExpectToPay_AMNT * 24 / 365) * @Li_DaysToAccure_NUMB, 2);
      END
     ELSE IF @Ac_FreqPeriodic_CODE = @Lc_FrequencyMonthly_CODE
      BEGIN
       SET @Ln_Periodic_AMNT = ROUND((@An_Periodic_AMNT * 12 / 365) * @Li_DaysToAccure_NUMB, 2);
       SET @Ln_ExpectToPay_AMNT = ROUND((@An_ExpectToPay_AMNT * 12 / 365) * @Li_DaysToAccure_NUMB, 2);
      END;
     ELSE IF @Ac_FreqPeriodic_CODE = @Lc_FrequencyQuarterly_CODE
      BEGIN
       SET @Ln_Periodic_AMNT = ROUND((@An_Periodic_AMNT * 4 / 365) * @Li_DaysToAccure_NUMB, 2);
       SET @Ln_ExpectToPay_AMNT = ROUND((@An_ExpectToPay_AMNT * 4 / 365) * @Li_DaysToAccure_NUMB, 2);
      END
     ELSE IF @Ac_FreqPeriodic_CODE = @Lc_FrequencyAnnually_CODE
      BEGIN
       SET @Ln_Periodic_AMNT = ROUND((@An_Periodic_AMNT / 365) * @Li_DaysToAccure_NUMB, 2);
       SET @Ln_ExpectToPay_AMNT = ROUND((@An_ExpectToPay_AMNT / 365) * @Li_DaysToAccure_NUMB, 2);
      END
    END -- END of Proration logic .
   IF @Ad_AccrualNext_DATE <= @Ad_AccrualEnd_DATE
    BEGIN
     SET @An_TransactionCurSup_AMNT = @An_TransactionCurSup_AMNT + @Ln_Periodic_AMNT;
    END;

   SET @An_MtdAccrual_AMNT = @An_MtdAccrual_AMNT + @Ln_Periodic_AMNT;
   SET @An_TransactionExptPay_AMNT = @An_TransactionExptPay_AMNT + @Ln_ExpectToPay_AMNT;

   IF @Ad_AccrualNext_DATE <= @Ad_AccrualEnd_DATE
    BEGIN
     SET @Ad_AccrualLast_DATE = @Ad_AccrualNext_DATE;
     SET @Ac_MtdProcess_INDC = @Lc_Yes_INDC;
    END;

   /*
          IF condition added to set the AccrualNext_DATE to high dates if OBLE_Y1 has ended and further
           accrual is not needed. If not the derived accrual next date is set
           
          If the Date Accrual Next falls in the obligation interval of the future obligation, the current obligation record will have High dates (12/31/9999) updated in this field preventing any further accrual processing.
           
          If the Date Accrual Next falls within the obligation begin and end dates, the Date Accrual Next will be updated to the current OBLE record
       */
   IF @Ad_AccrualNext_DATE >= @Ad_EndObligation_DATE
    BEGIN
     SET @Ad_AccrualNext_DATE = @Ld_High_DATE;
    END;
   ELSE
    BEGIN
     SET @Ad_AccrualNext_DATE = @Ld_AccrualNext_DATE;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
   
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END;


GO
