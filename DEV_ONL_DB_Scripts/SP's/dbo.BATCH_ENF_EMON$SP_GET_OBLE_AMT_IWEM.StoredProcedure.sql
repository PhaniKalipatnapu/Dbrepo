/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_GET_OBLE_AMT_IWEM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_EMON$SP_GET_OBLE_AMT_IWEM
Programmer Name		: IMP Team
Description			: This procedure get obligation amount for the given Case.
Frequency			: 
Developed On		: 04/7/2011
Called By			: None
Called On	        : 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_GET_OBLE_AMT_IWEM]
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @Ad_Run_DATE              DATE,
 @An_CurCs_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_CurMd_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_CurSs_AMNT            NUMERIC(11, 2) OUTPUT,
 @Ac_FreqPeriodicCs_CODE   CHAR(1) OUTPUT,
 @Ac_FreqPeriodicMd_CODE   CHAR(1) OUTPUT,
 @Ac_FreqPeriodicSs_CODE   CHAR(1) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Weekly_TEXT              CHAR(1) = 'W',
          @Lc_Monthly_TEXT             CHAR(1) = 'M',
          @Lc_Semimonthly_TEXT         CHAR(1) = 'S',
          @Lc_Quarterly_TEXT           CHAR(1) = 'Q',
          @Lc_Annual_TEXT              CHAR(1) = 'A',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_Daily_TEXT               CHAR(1) = 'D',
          @Lc_OnRequest_TEXT           CHAR(1) = 'O',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_Biweekly_TEXT            CHAR(1) = 'B',
          @Lc_DebtTypeChildSupp_CODE   CHAR(2) = 'CS',
          @Lc_DebtTypeMedicalSupp_CODE CHAR(2) = 'MS',
          @Lc_DebtTypeMedicaid_CODE    CHAR(2) = 'DS',
          @Lc_DebtTypeCashMedical_CODE CHAR(2) = 'CM',
          @Lc_DebtTypeSpousalSupp_CODE CHAR(2) = 'SS',
          @Lc_DebtTypeAlimony_CODE     CHAR(2) = 'AL',
          @Ls_Routine_TEXT             VARCHAR(100) = 'BATCH_ENF_EMON$SP_GET_OBLE_AMT_IWEM',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Li_Error_NUMB            INT,
          @Li_ErrorLine_NUMB        INT,
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @An_CurCs_AMNT = NULL;
   SET @An_CurMd_AMNT = NULL;
   SET @An_CurSs_AMNT = NULL;
   SET @Ac_FreqPeriodicCs_CODE = NULL;
   SET @Ac_FreqPeriodicMd_CODE = NULL;
   SET @Ac_FreqPeriodicSs_CODE = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'ELFC0150 : SELECT CURRENT CHILD SUPPORT DETAILS FROM OBLE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(2)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(20)), '') + ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeChildSupp_CODE, '');

   SELECT @Ac_FreqPeriodicCs_CODE = fci.freq_periodic,
          @An_CurCs_AMNT = CASE fci.freq_periodic
                            WHEN @Lc_Weekly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 52
                            WHEN @Lc_Monthly_TEXT
                             THEN fci.Monthly_AMNT
                            WHEN @Lc_Biweekly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 26
                            WHEN @Lc_Semimonthly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 24
                            WHEN @Lc_Quarterly_TEXT
                             THEN (fci.Monthly_AMNT * 3)
                            WHEN @Lc_Annual_TEXT
                             THEN (fci.Monthly_AMNT * 12)
                            ELSE fci.Monthly_AMNT
                           END
     FROM (SELECT ISNULL(CASE MAX(CASE x.FreqPeriodic_CODE
                                   WHEN @Lc_Weekly_TEXT
                                    THEN 52
                                   WHEN @Lc_Monthly_TEXT
                                    THEN 12
                                   WHEN @Lc_Biweekly_TEXT
                                    THEN 26
                                   WHEN @Lc_Semimonthly_TEXT
                                    THEN 24
                                   WHEN @Lc_Quarterly_TEXT
                                    THEN 4
                                   WHEN @Lc_Annual_TEXT
                                    THEN 1
                                  END)
                          WHEN 52
                           THEN @Lc_Weekly_TEXT
                          WHEN 12
                           THEN @Lc_Monthly_TEXT
                          WHEN 26
                           THEN @Lc_Biweekly_TEXT
                          WHEN 24
                           THEN @Lc_Semimonthly_TEXT
                          WHEN 4
                           THEN @Lc_Quarterly_TEXT
                          WHEN 1
                           THEN @Lc_Annual_TEXT
                         END, @Lc_Space_TEXT) AS freq_periodic,
                  ISNULL(SUM(CASE x.FreqPeriodic_CODE
                              WHEN @Lc_Daily_TEXT
                               THEN (x.Periodic_AMNT * 365) / 12
                              WHEN @Lc_Weekly_TEXT
                               THEN (x.Periodic_AMNT * 52) / 12
                              WHEN @Lc_Monthly_TEXT
                               THEN (x.Periodic_AMNT * 12) / 12
                              WHEN @Lc_Biweekly_TEXT
                               THEN (x.Periodic_AMNT * 26) / 12
                              WHEN @Lc_Semimonthly_TEXT
                               THEN (x.Periodic_AMNT * 24) / 12
                              WHEN @Lc_Quarterly_TEXT
                               THEN (x.Periodic_AMNT * 4) / 12
                              WHEN @Lc_Annual_TEXT
                               THEN x.Periodic_AMNT / 12
                              ELSE x.Periodic_AMNT
                             END), 0) AS Monthly_AMNT
             FROM (SELECT y.Case_IDNO,
							   y.OrderSeq_NUMB,
							   y.ObligationSeq_NUMB,
							   y.MemberMci_IDNO,
							   y.TypeDebt_CODE,
							   y.Fips_CODE,
							   y.FreqPeriodic_CODE,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - START
							   CASE WHEN @Ad_Run_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE 
										THEN  y.Periodic_AMNT 
									ELSE 0 
								END AS Periodic_AMNT,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - END
							   y.ExpectToPay_AMNT,
							   y.ExpectToPay_CODE,
							   y.BeginObligation_DATE,
							   y.EndObligation_DATE,
							   y.EventGlobalBeginSeq_NUMB,
							   y.EventGlobalEndSeq_NUMB,
							   y.BeginValidity_DATE,
							   y.EndValidity_DATE,
						   ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB ORDER BY y.BeginObligation_DATE DESC, y.EventGlobalBeginSeq_NUMB DESC) AS rnm
									  FROM OBLE_Y1 AS y 
									 WHERE y.Case_IDNO = @An_Case_IDNO
									   AND y.BeginObligation_DATE <= @Ad_Run_DATE
									   AND y.EndValidity_DATE = @Ld_High_DATE) x
            WHERE x.Case_IDNO = @An_Case_IDNO
			  AND x.rnm = 1
              AND x.OrderSeq_NUMB = @An_OrderSeq_NUMB
              AND x.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE)
              AND x.EndValidity_DATE = @Ld_High_DATE
              AND x.FreqPeriodic_CODE != @Lc_OnRequest_TEXT
              AND ( ( @Ad_Run_DATE BETWEEN x.BeginObligation_DATE AND x.EndObligation_DATE )
					OR 
					x.ExpectToPay_AMNT > 0
				  )
              AND x.Periodic_AMNT > 0) AS fci;

   SET @Ls_Sql_TEXT = 'ELFC0151 : SELECT CURRENT MEDICAL SUPPORT DETAILS FROM OBLE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(2)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(20)), '');

   SELECT @Ac_FreqPeriodicMd_CODE = fci.freq_periodic,
          @An_CurMd_AMNT = CASE fci.freq_periodic
                            WHEN @Lc_Daily_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 365
                            WHEN @Lc_Weekly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 52
                            WHEN @Lc_Monthly_TEXT
                             THEN fci.Monthly_AMNT
                            WHEN @Lc_Biweekly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 26
                            WHEN @Lc_Semimonthly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 24
                            WHEN @Lc_Quarterly_TEXT
                             THEN (fci.Monthly_AMNT * 3)
                            WHEN @Lc_Annual_TEXT
                             THEN (fci.Monthly_AMNT * 12)
                            ELSE fci.Monthly_AMNT
                           END
     FROM (SELECT ISNULL(CASE MAX(CASE x.FreqPeriodic_CODE
                                   WHEN @Lc_Weekly_TEXT
                                    THEN 52
                                   WHEN @Lc_Monthly_TEXT
                                    THEN 12
                                   WHEN @Lc_Biweekly_TEXT
                                    THEN 26
                                   WHEN @Lc_Semimonthly_TEXT
                                    THEN 24
                                   WHEN @Lc_Quarterly_TEXT
                                    THEN 4
                                   WHEN @Lc_Annual_TEXT
                                    THEN 1
                                  END)
                          WHEN 52
                           THEN @Lc_Weekly_TEXT
                          WHEN 12
                           THEN @Lc_Monthly_TEXT
                          WHEN 26
                           THEN @Lc_Biweekly_TEXT
                          WHEN 24
                           THEN @Lc_Semimonthly_TEXT
                          WHEN 4
                           THEN @Lc_Quarterly_TEXT
                          WHEN 1
                           THEN @Lc_Annual_TEXT
                         END, @Lc_Space_TEXT) AS freq_periodic,
                  ISNULL(SUM(CASE x.FreqPeriodic_CODE
                              WHEN @Lc_Daily_TEXT
                               THEN (x.Periodic_AMNT * 365) / 12
                              WHEN @Lc_Weekly_TEXT
                               THEN (x.Periodic_AMNT * 52) / 12
                              WHEN @Lc_Monthly_TEXT
                               THEN (x.Periodic_AMNT * 12) / 12
                              WHEN @Lc_Biweekly_TEXT
                               THEN (x.Periodic_AMNT * 26) / 12
                              WHEN @Lc_Semimonthly_TEXT
                               THEN (x.Periodic_AMNT * 24) / 12
                              WHEN @Lc_Quarterly_TEXT
                               THEN (x.Periodic_AMNT * 4) / 12
                              WHEN @Lc_Annual_TEXT
                               THEN x.Periodic_AMNT / 12
                              ELSE x.Periodic_AMNT
                             END), 0) AS Monthly_AMNT
             FROM (SELECT y.Case_IDNO,
							   y.OrderSeq_NUMB,
							   y.ObligationSeq_NUMB,
							   y.MemberMci_IDNO,
							   y.TypeDebt_CODE,
							   y.Fips_CODE,
							   y.FreqPeriodic_CODE,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - START
							   CASE WHEN @Ad_Run_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE 
										THEN  y.Periodic_AMNT 
									ELSE 0 
								END AS Periodic_AMNT,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - END
							   y.ExpectToPay_AMNT,
							   y.ExpectToPay_CODE,
							   y.BeginObligation_DATE,
							   y.EndObligation_DATE,
							   y.EventGlobalBeginSeq_NUMB,
							   y.EventGlobalEndSeq_NUMB,
							   y.BeginValidity_DATE,
							   y.EndValidity_DATE,
						   ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB ORDER BY y.BeginObligation_DATE DESC, y.EventGlobalBeginSeq_NUMB DESC) AS rnm
									  FROM OBLE_Y1 AS y 
									 WHERE y.Case_IDNO = @An_Case_IDNO
									   AND y.BeginObligation_DATE <= @Ad_Run_DATE
									   AND y.EndValidity_DATE = @Ld_High_DATE) x
            WHERE x.Case_IDNO = @An_Case_IDNO
			  AND x.rnm = 1
              AND x.OrderSeq_NUMB = @An_OrderSeq_NUMB
              AND x.TypeDebt_CODE IN (@Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeMedicaid_CODE, @Lc_DebtTypeCashMedical_CODE)
              AND x.EndValidity_DATE = @Ld_High_DATE
              AND x.FreqPeriodic_CODE != @Lc_OnRequest_TEXT
              AND ( ( @Ad_Run_DATE BETWEEN x.BeginObligation_DATE AND x.EndObligation_DATE )
					OR 
					x.ExpectToPay_AMNT > 0
				  )
              AND x.Periodic_AMNT > 0) AS fci;

   SET @Ls_Sql_TEXT = 'ELFC0152 : SELECT CURRENT SPOUSAL SUPPORT DETAILS FROM OBLE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(2)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(20)), '') + ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeSpousalSupp_CODE, '');

   SELECT @Ac_FreqPeriodicSs_CODE = fci.freq_periodic,
          @An_CurSs_AMNT = CASE fci.freq_periodic
                            WHEN @Lc_Daily_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 365
                            WHEN @Lc_Weekly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 52
                            WHEN @Lc_Monthly_TEXT
                             THEN fci.Monthly_AMNT
                            WHEN @Lc_Biweekly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 26
                            WHEN @Lc_Semimonthly_TEXT
                             THEN CAST((fci.Monthly_AMNT * 12) AS FLOAT(53)) / 24
                            WHEN @Lc_Quarterly_TEXT
                             THEN (fci.Monthly_AMNT * 3)
                            WHEN @Lc_Annual_TEXT
                             THEN (fci.Monthly_AMNT * 12)
                            ELSE fci.Monthly_AMNT
                           END
     FROM (SELECT ISNULL(CASE MAX(CASE x.FreqPeriodic_CODE
                                   WHEN @Lc_Weekly_TEXT
                                    THEN 52
                                   WHEN @Lc_Monthly_TEXT
                                    THEN 12
                                   WHEN @Lc_Biweekly_TEXT
                                    THEN 26
                                   WHEN @Lc_Semimonthly_TEXT
                                    THEN 24
                                   WHEN @Lc_Quarterly_TEXT
                                    THEN 4
                                   WHEN @Lc_Annual_TEXT
                                    THEN 1
                                  END)
                          WHEN 52
                           THEN @Lc_Weekly_TEXT
                          WHEN 12
                           THEN @Lc_Monthly_TEXT
                          WHEN 26
                           THEN @Lc_Biweekly_TEXT
                          WHEN 24
                           THEN @Lc_Semimonthly_TEXT
                          WHEN 4
                           THEN @Lc_Quarterly_TEXT
                          WHEN 1
                           THEN @Lc_Annual_TEXT
                         END, @Lc_Space_TEXT) AS freq_periodic,
                  ISNULL(SUM(CASE x.FreqPeriodic_CODE
                              WHEN @Lc_Daily_TEXT
                               THEN (x.Periodic_AMNT * 365) / 12
                              WHEN @Lc_Weekly_TEXT
                               THEN (x.Periodic_AMNT * 52) / 12
                              WHEN @Lc_Monthly_TEXT
                               THEN (x.Periodic_AMNT * 12) / 12
                              WHEN @Lc_Biweekly_TEXT
                               THEN (x.Periodic_AMNT * 26) / 12
                              WHEN @Lc_Semimonthly_TEXT
                               THEN (x.Periodic_AMNT * 24) / 12
                              WHEN @Lc_Quarterly_TEXT
                               THEN (x.Periodic_AMNT * 4) / 12
                              WHEN @Lc_Annual_TEXT
                               THEN x.Periodic_AMNT / 12
                              ELSE x.Periodic_AMNT
                             END), 0) AS Monthly_AMNT
             FROM (SELECT y.Case_IDNO,
							   y.OrderSeq_NUMB,
							   y.ObligationSeq_NUMB,
							   y.MemberMci_IDNO,
							   y.TypeDebt_CODE,
							   y.Fips_CODE,
							   y.FreqPeriodic_CODE,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - START
							   CASE WHEN @Ad_Run_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE 
										THEN  y.Periodic_AMNT 
									ELSE 0 
								END AS Periodic_AMNT,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - END
							   y.ExpectToPay_AMNT,
							   y.ExpectToPay_CODE,
							   y.BeginObligation_DATE,
							   y.EndObligation_DATE,
							   y.EventGlobalBeginSeq_NUMB,
							   y.EventGlobalEndSeq_NUMB,
							   y.BeginValidity_DATE,
							   y.EndValidity_DATE,
						   ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB ORDER BY y.BeginObligation_DATE DESC, y.EventGlobalBeginSeq_NUMB DESC) AS rnm
									  FROM OBLE_Y1 AS y 
									 WHERE y.Case_IDNO = @An_Case_IDNO
									   AND y.BeginObligation_DATE <= @Ad_Run_DATE
									   AND y.EndValidity_DATE = @Ld_High_DATE) x
            WHERE x.Case_IDNO = @An_Case_IDNO
			  AND x.rnm = 1
              AND x.OrderSeq_NUMB = @An_OrderSeq_NUMB
              -- Alimony Debt Type is added for calculating Income Withholding amount
              AND x.TypeDebt_CODE IN (@Lc_DebtTypeSpousalSupp_CODE, @Lc_DebtTypeAlimony_CODE)
              AND x.EndValidity_DATE = @Ld_High_DATE
              AND x.FreqPeriodic_CODE != @Lc_OnRequest_TEXT
              AND ( ( @Ad_Run_DATE BETWEEN x.BeginObligation_DATE AND x.EndObligation_DATE )
					OR 
					x.ExpectToPay_AMNT > 0
				  )
              AND x.Periodic_AMNT > 0) AS fci;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END



GO
