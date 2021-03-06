/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_BILLING$SP_CALCULATE_MONTH_SUPPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*------------------------------------------------------------------------------
  Procedure Name 	: BATCH_FIN_EXT_BILLING$SP_CALCULATE_MONTH_SUPPORT
  Programmer Name	: IMP Team
  Description		:  Calculate month support amount
  Frequency   		: 
  Developed On  	: 11/2/2011
  Called By   		: BATCH_FIN_EXT_BILLING$SP_EXTRACT_QUARTERLY_BILLING
					  BATCH_FIN_EXT_BILLING$SP_EXTRACT_MONTLY_BILLING 
  Called On			: 
  ------------------------------------------------------------------------------
  Modified By   :
  Modified On   :
  Version No    : 1.0
  ------------------------------------------------------------------------------
   */
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_BILLING$SP_CALCULATE_MONTH_SUPPORT](
 @An_Case_IDNO             NUMERIC(6),
 @An_SupportYearMonth_NUMB NUMERIC(6),
 @An_ExpectToPay_AMNT      NUMERIC(11, 2) OUTPUT,
 @An_MtdCurSupOwed_AMNT    NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Accrual1050_NUMB            INT = 1050,
          @Li_MonthSupportl1060_NUMB      INT = 1060,
          @Ln_One_NUMB                    NUMERIC(1) = 1,
          @Ln_DateAcclExpt7_NUMB          NUMERIC(1) = 7,
          @Ln_DateAcclExpt3_NUMB          NUMERIC(1) = 3,
          @Ln_DateAcclExpt14_NUMB         NUMERIC(2) = 14,
          @Ln_DateAcclExpt16_NUMB         NUMERIC(2) = 16,
          @Ln_DateAcclExpt15_NUMB         NUMERIC(2) = 15,
          @Ln_DateAcclExpt12_NUMB         NUMERIC(2) = 12,
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_Onetime_CODE                CHAR(1) = 'O',
          @Lc_Weekly_CODE                 CHAR(1) = 'W',
          @Lc_Biweekly_CODE               CHAR(1) = 'B',
          @Lc_Semimonthly_CODE            CHAR(1) = 'S',
          @Lc_Quarterly_CODE              CHAR(1) = 'Q',
          @Lc_Monthly_CODE                CHAR(1) = 'M',
          @Lc_FrequencyOneTimeOnly_CODE   CHAR(1) = 'O',
          @Lc_StatusCaseClosed_CODE       CHAR(1) = 'C',
          @Lc_Annual_CODE                 CHAR(1) = 'A',
          @Lc_ComplianceTypeBond_CODE     CHAR(2) = 'BD',
          @Lc_ComplianceTypeLumpSum_CODE  CHAR(2) = 'LS',
          @Lc_ComplianceTypePeriodic_CODE CHAR(2) = 'PA',
          @Lc_ComplianceTypePayment_CODE  CHAR(2) = 'PP',
          @Lc_TypeDebtChildSupport_CODE   CHAR(2) = 'CS',
          @Lc_ComplianceStatusActive_CODE CHAR(2) = 'AC',
          @Lc_DateAcclExpt16_NUMB         CHAR(2) = '16',
          @Lc_DateAcclExpt31_NUMB         CHAR(2) = '31',
          @Lc_DateAcclExpt02_NUMB         CHAR(2) = '02',
          @Lc_DateAcclExpt14_NUMB         CHAR(2) = '14',
          @Lc_DateAcclExpt15_NUMB         CHAR(2) = '15',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_BATCH_MONTH_SUPPORT',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_Low_DATE                    DATE = '01/01/0001';
  DECLARE @Ln_FetchStatus_QNTY        NUMERIC(2),
          @Ln_Rowcount_QNTY           NUMERIC(11),
          @Ln_Error_NUMB              NUMERIC(11),
          @Ln_ErrorLine_NUMB          NUMERIC(11),
          @Ln_TransactionExptPay_AMNT NUMERIC(11, 2) = 0,
          @Ln_MtdOwed_NUMB            NUMERIC(11, 2) =0,
          @Ln_TransactionCurSup_AMNT  NUMERIC(11, 2) =0,
          @Ln_Periodic_AMNT           NUMERIC(11, 2) =0,
          @Ln_ExpectToPay_AMNT        NUMERIC(11, 2) =0,
          @Lc_Msg_CODE                CHAR(1),
          @Lc_MtdProcess_CODE         CHAR(1),
          @Lc_FreqPeriodic_CODE       CHAR(1),
          @Lc_ExpectToPay_CODE        CHAR(1),
          @Lc_DayBeginOble_TEXT       CHAR(12),
          @Ls_Sql_TEXT                VARCHAR(100),
          @Ls_Sqldata_TEXT            VARCHAR(1000),
          @Ld_MonthFirst_DATE         DATE,
          @Ld_MonthLast_DATE          DATE,
          @Ld_AccrualNext_DATE        DATE,
          @Ld_BeginObligation_DATE    DATE,
          @Ld_EndObligation_DATE      DATE,
          @Ld_AccrualCurrent_DATE     DATE,
          @Ld_AccrualLast_DATE        DATE,
          @Ld_AcclExpt_DATE           DATE,
          @Ld_ExptFirst_DATE          DATE,
          @Ld_ObleEndObligation_DATE  DATE;
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
          @Lc_OblxCur_ExpectToPay_CODE     CHAR (1),
          @Lc_OblxCur_ComplianceType_CODE  CHAR (2);

  BEGIN TRY
   SET @Ld_MonthFirst_DATE = CONVERT(DATE, CAST(@An_SupportYearMonth_NUMB AS VARCHAR) + '01', 112);
   SET @Ld_MonthLast_DATE = DATEADD(D, -1, DATEADD(M, 1, @Ld_MonthFirst_DATE));
   SET @An_MtdCurSupOwed_AMNT =0;
   SET @An_ExpectToPay_AMNT =0;

   /*
   The program processes all open cases having an obligation on Obligation (OBLE_Y1) table.
    If there are active plans, calculate the monthly support order by using the compliance amount and frequency
           code.
   */
   DECLARE Oblx_CUR INSENSITIVE CURSOR FOR
    -- Retrieve the Current Active obligation records
    SELECT aa.Case_IDNO,
           aa.OrderSeq_NUMB,
           aa.ObligationSeq_NUMB,
           aa.MemberMci_IDNO,
           CASE
            WHEN c.ComplianceType_CODE IS NULL
             THEN aa.FreqPeriodic_CODE
            WHEN c.ComplianceType_CODE = @Lc_ComplianceTypeBond_CODE
             THEN @Lc_FrequencyOneTimeOnly_CODE
            WHEN c.ComplianceType_CODE = @Lc_ComplianceTypeLumpSum_CODE
             THEN @Lc_FrequencyOneTimeOnly_CODE
            WHEN c.ComplianceType_CODE = @Lc_ComplianceTypePeriodic_CODE
             THEN c.Freq_CODE
            WHEN c.ComplianceType_CODE = @Lc_ComplianceTypePayment_CODE
             THEN c.Freq_CODE
            ELSE (SELECT TOP 1 FreqPeriodic_CODE
                    FROM OBLE_Y1 o
                   WHERE o.Case_IDNO = aa.Case_IDNO
                     AND O.TypeDebt_CODE = @Lc_TypeDebtChildSupport_CODE
                     AND o.BeginObligation_DATE <= @Ld_MonthLast_DATE
                     AND o.EndObligation_DATE >= @Ld_MonthFirst_DATE
                     AND o.EndValidity_DATE = @Ld_High_DATE)
           END FreqPeriodic_CODE,
           ISNULL(c.Compliance_AMNT, aa.Periodic_AMNT)Periodic_AMNT,
           CASE
            WHEN c.Case_IDNO IS NULL
             THEN aa.ExpectToPay_AMNT
            ELSE 0
           END ExpectToPay_AMNT,
           ISNULL(c.Effective_DATE, aa.BeginObligation_DATE)BeginObligation_DATE,
           ISNULL (c.END_DATE, aa.EndObligation_DATE) EndObligation_DATE,
           CASE
            WHEN c.Effective_DATE IS NULL
             THEN aa.AccrualLast_DATE
            ELSE @Ld_Low_DATE
           END AccrualLast_DATE,
           ISNULL(c.Effective_DATE, aa.AccrualNext_DATE)AccrualNext_DATE,
           aa.ExpectToPay_CODE,
           c.ComplianceType_CODE
      FROM (SELECT a.Case_IDNO,
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
                   a.ExpectToPay_CODE,
                   ROW_NUMBER() OVER(PARTITION BY A.Case_IDNO ORDER BY A.TypeDebt_CODE) AS Seq_NUMB,
                   ROW_NUMBER() OVER(PARTITION BY A.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB ORDER BY A.BeginObligation_DATE) AS Seq1_NUMB
              FROM CASE_Y1 b,
                   OBLE_Y1 a
             WHERE a.Case_IDNO = b.Case_IDNO
               AND a.Case_IDNO = @An_Case_IDNO
               AND b.StatusCase_CODE <> @Lc_StatusCaseClosed_CODE
               AND a.BeginObligation_DATE <= @Ld_MonthLast_DATE
               AND (a.EndObligation_DATE >= @Ld_MonthFirst_DATE
                     OR (a.ExpectToPay_AMNT > 0
                         AND a.EndObligation_DATE = (SELECT MAX(x.EndObligation_DATE)
                                                       FROM OBLE_Y1 X
                                                      WHERE a.Case_IDNO = X.Case_IDNO
                                                        AND a.OrderSeq_NUMB = X.OrderSeq_NUMB
                                                        AND a.ObligationSeq_NUMB = X.ObligationSeq_NUMB
                                                        AND X.EndValidity_DATE = @Ld_High_DATE
                                                        AND x.BeginObligation_DATE <= @Ld_MonthLast_DATE)))
               AND a.EndValidity_DATE = @Ld_High_DATE
               AND a.EndObligation_DATE IN (SELECT x.EndObligation_DATE
                                              FROM OBLE_Y1 X
                                             WHERE a.Case_IDNO = X.Case_IDNO
                                               AND a.OrderSeq_NUMB = X.OrderSeq_NUMB
                                               AND a.ObligationSeq_NUMB = X.ObligationSeq_NUMB
                                               AND X.EndValidity_DATE = @Ld_High_DATE
                                               AND x.BeginObligation_DATE <= @Ld_MonthLast_DATE))AA
           LEFT OUTER JOIN COMP_Y1 C
            ON C.Case_IDNO = aa.Case_IDNO
               AND c.Effective_DATE <= @Ld_MonthLast_DATE
               AND c.End_DATE >= DATEADD(M, 1, @Ld_MonthLast_DATE)
               AND c.EndValidity_DATE = @Ld_High_DATE
               AND c.ComplianceStatus_CODE = @Lc_ComplianceStatusActive_CODE
     WHERE ((C.Case_IDNO IS NULL
         AND aa.Seq1_NUMB = 1)
         OR AA.Seq_NUMB = 1);

   SET @Ls_Sql_TEXT = 'OPEN Oblx_Cur';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Oblx_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Oblx_Cur - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Oblx_CUR INTO @Ln_OblxCur_Case_IDNO, @Ln_OblxCur_OrderSeq_NUMB, @Ln_OblxCur_ObligationSeq_NUMB, @Ln_OblxCur_MemberMci_IDNO, @Lc_OblxCur_FreqPeriodic_CODE, @Ln_OblxCur_Periodic_AMNT, @Ln_OblxCur_ExpectToPay_AMNT, @Ld_OblxCur_BeginObligation_DATE, @Ld_OblxCur_EndObligation_DATE, @Ld_OblxCur_AccrualLast_DATE, @Ld_OblxCur_AccrualNext_DATE, @Lc_OblxCur_ExpectToPay_CODE, @Lc_OblxCur_ComplianceType_CODE;

   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE_LOOP1';
   SET @Ls_Sqldata_TEXT = '';

   --Calculate month support amount
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_FreqPeriodic_CODE = @Lc_OblxCur_FreqPeriodic_CODE;
     SET @Ln_Periodic_AMNT = @Ln_OblxCur_Periodic_AMNT;
     SET @Ln_ExpectToPay_AMNT = @Ln_OblxCur_ExpectToPay_AMNT;
     SET @Ld_BeginObligation_DATE = @Ld_OblxCur_BeginObligation_DATE;
     SET @Lc_ExpectToPay_CODE = @Lc_OblxCur_ExpectToPay_CODE;
     SET @Ld_ObleEndObligation_DATE = @Ld_OblxCur_EndObligation_DATE;
     SET @Ln_TransactionExptPay_AMNT = 0;

     IF @Ld_OblxCur_AccrualNext_DATE <= @Ld_MonthLast_DATE
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

     IF @Ld_EndObligation_DATE > @Ld_MonthLast_DATE
      BEGIN
       SET @Ld_EndObligation_DATE =@Ld_MonthLast_DATE;
      END;

     SET @Ld_AccrualCurrent_DATE = @Ld_AccrualNext_DATE;
     SET @Ln_MtdOwed_NUMB = 0;

     --  To calculate MtdCurSupOwed_AMNT for obligations ending on the first day of the month
     IF @Ld_OblxCur_AccrualNext_DATE = @Ld_High_DATE
         OR @Ld_OblxCur_AccrualNext_DATE >= @Ld_OblxCur_EndObligation_DATE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1 1';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR), '') + ', EndObligation_DATE = ' + CAST(@Ld_EndObligation_DATE AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

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
          AND o.BeginObligation_DATE = DATEADD(d, 1, @Ld_EndObligation_DATE)
          AND o.EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_Rowcount_QNTY=@@ROWCOUNT;

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

         IF @Ld_EndObligation_DATE > @Ld_MonthLast_DATE
          BEGIN
           SET @Ld_EndObligation_DATE = @Ld_MonthLast_DATE;
          END;
        END;
      END;

     -- Changed to calculate MtdCurSupOwed_AMNT for obligations ending on the first day of the month
     IF @Ld_EndObligation_DATE >= @Ld_MonthFirst_DATE
      BEGIN
       IF @Ld_AccrualNext_DATE <= @Ld_MonthLast_DATE
        BEGIN
         SET @Ls_Sql_TEXT = 'WHIlE_LOOP2';
         SET @Ls_Sqldata_TEXT = '';

         --calculate accrual amount	
         WHILE @Ld_AccrualNext_DATE <= @Ld_MonthLast_DATE
               AND @Ld_AccrualNext_DATE <= @Ld_EndObligation_DATE
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ACCRUAL ';
           SET @Ls_Sqldata_TEXT = ' FreqPeriodic_CODE = ' + ISNULL (@Lc_FreqPeriodic_CODE, '') + ', Periodic_AMNT = ' + ISNULL (CAST(@Ln_Periodic_AMNT AS VARCHAR), '') + ', ExpectToPay_AMNT = ' + ISNULL (CAST (@Ln_ExpectToPay_AMNT AS VARCHAR), '') + ', BeginObligation_DATE = ' + ISNULL (CAST (@Ld_BeginObligation_DATE AS VARCHAR), '') + ', ObleEndObligation_DATE = ' + ISNULL (CAST (@Ld_ObleEndObligation_DATE AS VARCHAR), '') + ', EndObligation_DATE = ' + ISNULL (CAST (@Ld_EndObligation_DATE AS VARCHAR), '');

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
            @An_MtdAccrual_AMNT         = @Ln_MtdOwed_NUMB OUTPUT,
            @Ac_MtdProcess_INDC         = @Lc_MtdProcess_CODE OUTPUT,
            @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @As_DescriptionError_TEXT = 'BATCH_COMMON$SP_ACCRUAL FAILED';

             RAISERROR (50001,16,1);
            END;

           IF @Ld_AccrualLast_DATE < @Ld_MonthFirst_DATE
              AND @Lc_FreqPeriodic_CODE <> @Lc_Onetime_CODE
            BEGIN
             SET @Ln_MtdOwed_NUMB=0;
             SET @Ln_TransactionExptPay_AMNT =0;

             IF @Ld_AccrualNext_DATE <= @Ld_EndObligation_DATE
              BEGIN
               CONTINUE;
              END
            END

           IF @Ld_AccrualNext_DATE > @Ld_EndObligation_DATE
              AND @Ld_EndObligation_DATE < @Ld_MonthLast_DATE
            BEGIN
             SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y11';
             SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR (MAX)), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR), '') + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', EndObligation_DATE = ' + CAST(@Ld_EndObligation_DATE AS VARCHAR);

             SELECT @Lc_FreqPeriodic_CODE = o.FreqPeriodic_CODE,
                    @Ln_Periodic_AMNT = o.Periodic_AMNT,
                    @Ln_ExpectToPay_AMNT = o.ExpectToPay_AMNT,
                    @Ld_BeginObligation_DATE = o.BeginObligation_DATE,
                    @Ld_EndObligation_DATE = o.EndObligation_DATE,
                    @Ld_AccrualNext_DATE = o.AccrualNext_DATE,
                    @Ld_AccrualLast_DATE = o.AccrualLast_DATE,
                    @Ld_ObleEndObligation_DATE = o.EndObligation_DATE,
                    @Lc_OblxCur_ComplianceType_CODE = NULL
               FROM OBLE_Y1 o
              WHERE o.Case_IDNO = @Ln_OblxCur_Case_IDNO
                AND o.OrderSeq_NUMB = @Ln_OblxCur_OrderSeq_NUMB
                AND o.ObligationSeq_NUMB = @Ln_OblxCur_ObligationSeq_NUMB
                AND (o.BeginObligation_DATE = DATEADD(d, 1, @Ld_EndObligation_DATE)
                      OR @Lc_OblxCur_ComplianceType_CODE IS NOT NULL)
                AND o.EndValidity_DATE = @Ld_High_DATE;

             SET @Ln_Rowcount_QNTY=@@ROWCOUNT;

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

               IF @Ld_EndObligation_DATE > @Ld_MonthLast_DATE
                BEGIN
                 SET @Ld_EndObligation_DATE =@Ld_MonthLast_DATE;
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

         SET @Ln_TransactionExptPay_AMNT = 0;
         SET @Ls_Sql_TEXT = 'WHILE Ld_AcclExpt_DATE';
         SET @Ls_Sqldata_TEXT = '';

         -- While loop for calculating accrual next date
         WHILE SUBSTRING(CONVERT(VARCHAR(6), @Ld_AcclExpt_DATE, 112), 1, 6) = SUBSTRING(CONVERT(VARCHAR(6), @Ld_MonthFirst_DATE, 112), 1, 6)
          BEGIN
           SET @Ln_TransactionExptPay_AMNT = @Ln_TransactionExptPay_AMNT + @Ln_ExpectToPay_AMNT;

           IF @Lc_FreqPeriodic_CODE = @Lc_Weekly_CODE
            BEGIN
             SET @Ld_AcclExpt_DATE = DATEADD (d, @Ln_DateAcclExpt7_NUMB, @Ld_AcclExpt_DATE);
            END;
           ELSE
            BEGIN
             IF @Lc_FreqPeriodic_CODE = @Lc_Biweekly_CODE
              BEGIN
               SET @Ld_AcclExpt_DATE = DATEADD (d, @Ln_DateAcclExpt14_NUMB, @Ld_AcclExpt_DATE);
              END;
             ELSE
              BEGIN
               IF @Lc_FreqPeriodic_CODE = @Lc_Semimonthly_CODE
                BEGIN
                 IF DATENAME(DAY, @Ld_AcclExpt_DATE) >= @Lc_DateAcclExpt16_NUMB
                  BEGIN
                   IF DATENAME(DAY, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CONVERT(DATE, @Ld_AcclExpt_DATE, 112)) + 1, 0))) = @Lc_DateAcclExpt31_NUMB
                    BEGIN
                     SET @Ld_AcclExpt_DATE = DATEADD (d, @Ln_DateAcclExpt16_NUMB, @Ld_AcclExpt_DATE);
                    END;
                   ELSE
                    BEGIN
                     SET @Ld_AcclExpt_DATE = DATEADD (d, @Ln_DateAcclExpt15_NUMB, @Ld_AcclExpt_DATE);
                    END;
                  END;
                 ELSE
                  BEGIN
                   IF DATEPART(MONTH, @Ld_AcclExpt_DATE) = @Lc_DateAcclExpt02_NUMB
                      AND DATENAME(DAY, @Ld_AcclExpt_DATE) IN (@Lc_DateAcclExpt14_NUMB, @Lc_DateAcclExpt15_NUMB)
                    BEGIN
                     SET @Ld_AcclExpt_DATE = DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CONVERT(DATE, @Ld_AcclExpt_DATE, 112)) + 1, 0));
                    END;
                   ELSE
                    BEGIN
                     SET @Ld_AcclExpt_DATE = DATEADD (d, @Ln_DateAcclExpt15_NUMB, @Ld_AcclExpt_DATE);
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
                     SET @Ld_AcclExpt_DATE = DATEADD (m, @Ln_One_NUMB, @Ld_AcclExpt_DATE);
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

     SET @An_MtdCurSupOwed_AMNT = @An_MtdCurSupOwed_AMNT + @Ln_MtdOwed_NUMB;
     SET @An_ExpectToPay_AMNT = @An_ExpectToPay_AMNT + @Ln_TransactionExptPay_AMNT;

     IF @Lc_OblxCur_ComplianceType_CODE IS NULL
      BEGIN
       SET @Ls_Sql_TEXT = 'FETCH LSUP_Y1 - 1';
       SET @Ls_Sqldata_TEXT = 'MtdCurSupOwed_AMNT = ' + CAST(@An_MtdCurSupOwed_AMNT AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_OblxCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@Ln_OblxCur_OrderSeq_NUMB AS VARCHAR) + ', ObligationSeq_NUMB = ' + CAST(@Ln_OblxCur_ObligationSeq_NUMB AS VARCHAR) + ', Accrual1050_NUMB = ' + CAST(@Li_Accrual1050_NUMB AS VARCHAR) + ', SupportYearMonth_NUMB = ' + CAST(@An_SupportYearMonth_NUMB AS VARCHAR);

       SELECT @An_MtdCurSupOwed_AMNT = @An_MtdCurSupOwed_AMNT + ISNULL(SUM(L.TransactionCurSup_AMNT), 0)
         FROM LSUP_Y1 L
        WHERE L.Case_IDNO = @Ln_OblxCur_Case_IDNO
          AND L.OrderSeq_NUMB = @Ln_OblxCur_OrderSeq_NUMB
          AND L.ObligationSeq_NUMB = @Ln_OblxCur_ObligationSeq_NUMB
          AND L.EventFunctionalSeq_NUMB = @Li_Accrual1050_NUMB
          AND L.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB;
      END

     SET @Ls_Sql_TEXT = 'FETCH Oblx_Cur - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Oblx_CUR INTO @Ln_OblxCur_Case_IDNO, @Ln_OblxCur_OrderSeq_NUMB, @Ln_OblxCur_ObligationSeq_NUMB, @Ln_OblxCur_MemberMci_IDNO, @Lc_OblxCur_FreqPeriodic_CODE, @Ln_OblxCur_Periodic_AMNT, @Ln_OblxCur_ExpectToPay_AMNT, @Ld_OblxCur_BeginObligation_DATE, @Ld_OblxCur_EndObligation_DATE, @Ld_OblxCur_AccrualLast_DATE, @Ld_OblxCur_AccrualNext_DATE, @Lc_OblxCur_ExpectToPay_CODE, @Lc_OblxCur_ComplianceType_CODE;

     SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
    END;

   CLOSE Oblx_CUR;

   DEALLOCATE Oblx_CUR;

   IF @An_ExpectToPay_AMNT = 0
      AND @An_MtdCurSupOwed_AMNT = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'FETCH LSUP_Y1 - 2';
     SET @Ls_Sqldata_TEXT = 'MtdCurSupOwed_AMNT = ' + CAST(@An_MtdCurSupOwed_AMNT AS VARCHAR) + ', Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Accrual1050_NUMB = ' + CAST(@Li_Accrual1050_NUMB AS VARCHAR) + ', SupportYearMonth_NUMB = ' + CAST(@An_SupportYearMonth_NUMB AS VARCHAR);

     SELECT @An_MtdCurSupOwed_AMNT = @An_MtdCurSupOwed_AMNT + ISNULL(SUM(L.TransactionCurSup_AMNT), 0)
       FROM LSUP_Y1 L
      WHERE L.Case_IDNO = @An_Case_IDNO
        AND L.EventFunctionalSeq_NUMB = @Li_Accrual1050_NUMB
        AND L.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB;

     SET @Ls_Sql_TEXT = 'FETCH LSUP_Y1 - 3';
     SET @Ls_Sqldata_TEXT = '@An_ExpectToPay_AMNT = ' + CAST(@An_ExpectToPay_AMNT AS VARCHAR) + ', Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', MonthSupportl1060_NUMB = ' + CAST(@Li_MonthSupportl1060_NUMB AS VARCHAR) + ', SupportYearMonth_NUMB = ' + CAST(@An_SupportYearMonth_NUMB AS VARCHAR);

     SELECT @An_ExpectToPay_AMNT = @An_ExpectToPay_AMNT + ISNULL(SUM(L.TransactionExptPay_AMNT), 0)
       FROM LSUP_Y1 L
      WHERE L.Case_IDNO = @An_Case_IDNO
        AND L.EventFunctionalSeq_NUMB = @Li_MonthSupportl1060_NUMB
        AND L.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'Oblx_CUR') IN (0, 1)
    BEGIN
     CLOSE Oblx_CUR;

     DEALLOCATE Oblx_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END


GO
