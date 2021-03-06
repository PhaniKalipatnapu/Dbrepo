/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_INITIAL_N_RECENT_ORDER_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_GET_INITIAL_N_RECENT_ORDER_DTLS
Programmer Name	:	IMP Team.
Description		:	This function is used to fetch the initial order and recent order details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_INITIAL_N_RECENT_ORDER_DTLS] (
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @Ad_Run_DATE              DATE,
 @Ac_Notice_ID			   CHAR(8),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Error_NUMB                 INT = NULL,
          @Li_ErrorLine_NUMB             INT = NULL,
          @Lc_FreqDaily_CODE             CHAR(1) = 'D',
          @Lc_FreqWeekly_CODE            CHAR(1) = 'W',
          @Lc_FreqMonthly_CODE           CHAR(1) = 'M',
          @Lc_FreqBiweekly_CODE          CHAR(1) = 'B',
          @Lc_FreqSemiMonthly_CODE       CHAR(1) = 'S',
          @Lc_FreqAnnually_CODE          CHAR(1) = 'A',
          @Lc_FreqQuarterly_CODE         CHAR(1) = 'Q',
          @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_TypeDebtSS_CODE            CHAR(2) = 'SS',
          @Lc_TypeDebtCS_CODE            CHAR(2) = 'CS',
          @Lc_TypeDebtGT_CODE            CHAR(2) = 'GT',
          @Lc_TypeDebtAlimonyAL_CODE     CHAR (2) = 'AL',
          @Lc_TypeDebtIntAlimonyAI_CODE  CHAR (2) = 'AI',
          @Lc_TypeDebtGeneticTestGT_CODE CHAR (2) = 'GT',
          @Lc_TableFRQA_ID               CHAR(4) = 'FRQA',
          @Lc_TableSubFRQ3_ID            CHAR(4) = 'FRQ3',
          @Ld_Highdate_DATE              DATE = '12/31/9999',
          @Ld_System_DATE                DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_RecentOrder_ChildCount_NUMB NUMERIC(2) = 0,
          @Ln_ExpectToPay_AMNT            NUMERIC(11, 2) = 0,
          @Ln_Periodic_AMNT               NUMERIC(11, 2) = 0,
          @Ln_totalorderedsupport_amnt    NUMERIC(11, 2) = 0,
          @Ln_ExpectToPay1_AMNT           NUMERIC(11, 2) = 0,
          @Ln_Periodic1_AMNT              NUMERIC(11, 2) = 0,
          @Ln_CsPeriodic_AMNT             NUMERIC(11, 2) = 0,
          @Ln_SsPeriodic_AMNT             NUMERIC(11, 2) = 0,
          @Ls_FrequencyPeriodic1_CODE     VARCHAR(73) = '',
          @Ls_FrequencyPeriodic_CODE      VARCHAR(73) = '',
          @Ls_Procedure_NAME              VARCHAR(100) = '',
          @Ls_Sql_TEXT                    VARCHAR(400) = '',
          @Ls_Sqldata_TEXT                VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000);
  DECLARE  @Ld_RecentOrder_DATE   DATE,
           @Ld_InitialOrder_DATE  DATE,
           @Ld_InitialOblicationBegin_DATE  DATE;    

  BEGIN TRY
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICE_FIN$SP_GET_INITIAL_N_RECENT_ORDER_DTLS';
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' SELECT Owiz_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6));

   SELECT @Ln_ExpectToPay_AMNT = Y.ExpectToPay_AMNT,
          @Ln_Periodic_AMNT = Y.Periodic_AMNT,
          @Ln_totalorderedsupport_amnt=(Y.ExpectToPay_AMNT+Y.Periodic_AMNT),
          @Ls_FrequencyPeriodic_CODE = Y.freq_periodic,
          @Ln_CsPeriodic_AMNT = Y.CS_Monthly_AMNT,
          @Ln_SsPeriodic_AMNT = Y.SS_Monthly_AMNT
   FROM(SELECT fci.CS_Monthly_AMNT,
                 fci.SS_Monthly_AMNT,
                 CASE
                  WHEN fci.freq_periodic = @Lc_FreqDaily_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 365
                  WHEN fci.freq_periodic = @Lc_FreqWeekly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 52
                  WHEN fci.freq_periodic = @Lc_FreqMonthly_CODE
                   THEN fci.ExpectToPay_AMNT
                  WHEN fci.freq_periodic = @Lc_FreqBiweekly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 26
                  WHEN fci.freq_periodic = @Lc_FreqSemiMonthly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 24
                  WHEN fci.freq_periodic = @Lc_FreqAnnually_CODE
                   THEN (fci.ExpectToPay_AMNT * 12)
                  WHEN fci.freq_periodic = @Lc_FreqQuarterly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 4
                  ELSE fci.ExpectToPay_AMNT
                 END ExpectToPay_AMNT,
                 CASE
                  WHEN fci.freq_periodic = @Lc_FreqDaily_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 365
                  WHEN fci.freq_periodic = @Lc_FreqWeekly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 52
                  WHEN fci.freq_periodic = @Lc_FreqMonthly_CODE
                   THEN fci.Monthly_AMNT
                  WHEN fci.freq_periodic = @Lc_FreqBiweekly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 26
                  WHEN fci.freq_periodic = @Lc_FreqSemiMonthly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 24
                  WHEN fci.freq_periodic = @Lc_FreqAnnually_CODE
                   THEN fci.Monthly_AMNT * 12
                  WHEN fci.freq_periodic = @Lc_FreqQuarterly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 4
                  ELSE fci.Monthly_AMNT
                 END Periodic_AMNT,
                 dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_TableFRQA_ID, @Lc_TableSubFRQ3_ID, fci.freq_periodic) AS freq_periodic
            FROM (SELECT ISNULL(CASE MAX(CASE x.FreqPeriodic_CODE
                                          WHEN @Lc_FreqDaily_CODE
                                           THEN 365
                                          WHEN @Lc_FreqWeekly_CODE
                                           THEN 52
                                          WHEN @Lc_FreqMonthly_CODE
                                           THEN 12
                                          WHEN @Lc_FreqBiweekly_CODE
                                           THEN 26
                                          WHEN @Lc_FreqSemiMonthly_CODE
                                           THEN 24
                                          WHEN @Lc_FreqAnnually_CODE
                                           THEN 1
                                          WHEN @Lc_FreqQuarterly_CODE
                                           THEN 4
                                         END)
                                 WHEN 365
                                  THEN @Lc_FreqDaily_CODE
                                 WHEN 52
                                  THEN @Lc_FreqWeekly_CODE
                                 WHEN 12
                                  THEN @Lc_FreqMonthly_CODE
                                 WHEN 26
                                  THEN @Lc_FreqBiweekly_CODE
                                 WHEN 24
                                  THEN @Lc_FreqSemiMonthly_CODE
                                 WHEN 1
                                  THEN @Lc_FreqAnnually_CODE
                                 WHEN 4
                                  THEN @Lc_FreqQuarterly_CODE
                                END, @Lc_Space_TEXT) AS freq_periodic,
                         ISNULL(SUM(CASE x.FreqPeriodic_CODE
                                     WHEN @Lc_FreqDaily_CODE
                                      THEN (x.ExpectToPay_AMNT * 365) / 12
                                     WHEN @Lc_FreqWeekly_CODE
                                      THEN (x.ExpectToPay_AMNT * 52) / 12
                                     WHEN @Lc_FreqMonthly_CODE
                                      THEN (x.ExpectToPay_AMNT * 12) / 12
                                     WHEN @Lc_FreqBiweekly_CODE
                                      THEN (x.ExpectToPay_AMNT * 26) / 12
                                     WHEN @Lc_FreqSemiMonthly_CODE
                                      THEN (x.ExpectToPay_AMNT * 24) / 12
                                     WHEN @Lc_FreqAnnually_CODE
                                      THEN (x.ExpectToPay_AMNT * 1) / 12
                                     WHEN @Lc_FreqQuarterly_CODE
                                      THEN (x.ExpectToPay_AMNT * 4) / 12
                                    END), 0) AS ExpectToPay_AMNT,
                         ISNULL(SUM(
									CASE  
									WHEN x.Periodic_AMNT > 0 AND x.EndObligation_DATE >= @Ld_System_DATE  
									THEN
										CASE x.FreqPeriodic_CODE
										 WHEN @Lc_FreqDaily_CODE
										  THEN (x.Periodic_AMNT * 365) / 12
										 WHEN @Lc_FreqWeekly_CODE
										  THEN (x.Periodic_AMNT * 52) / 12
										 WHEN @Lc_FreqMonthly_CODE
										  THEN (x.Periodic_AMNT * 12) / 12
										 WHEN @Lc_FreqBiweekly_CODE
										  THEN (x.Periodic_AMNT * 26) / 12
										 WHEN @Lc_FreqSemiMonthly_CODE
										  THEN (x.Periodic_AMNT * 24) / 12
										 WHEN @Lc_FreqAnnually_CODE
										  THEN (x.Periodic_AMNT * 1) / 12
										 WHEN @Lc_FreqQuarterly_CODE
										  THEN (x.Periodic_AMNT * 4) / 12
										  ELSE 0
										END    
                                    END), 0) AS Monthly_AMNT,
                         ISNULL(SUM(
									CASE  
									WHEN x.Periodic_AMNT > 0 AND x.EndObligation_DATE >= @Ld_System_DATE  
									THEN  
										CASE
										 WHEN x.FreqPeriodic_CODE = @Lc_FreqDaily_CODE
											  AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE
										  THEN (x.Periodic_AMNT * 365) / 12
										 WHEN x.FreqPeriodic_CODE = @Lc_FreqWeekly_CODE
											  AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE
										  THEN (x.Periodic_AMNT * 52) / 12
										 WHEN x.FreqPeriodic_CODE = @Lc_FreqMonthly_CODE
											  AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE
										  THEN (x.Periodic_AMNT * 12) / 12
										 WHEN x.FreqPeriodic_CODE = @Lc_FreqBiweekly_CODE
											  AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE
										  THEN (x.Periodic_AMNT * 26) / 12
										 WHEN x.FreqPeriodic_CODE = @Lc_FreqSemiMonthly_CODE
											  AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE
										  THEN (x.Periodic_AMNT * 24) / 12
										 WHEN x.FreqPeriodic_CODE = @Lc_FreqAnnually_CODE
											  AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE
										  THEN (x.Periodic_AMNT * 1) / 12
										 WHEN x.FreqPeriodic_CODE = @Lc_FreqQuarterly_CODE
											  AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE
										  THEN (x.Periodic_AMNT * 4) / 12
										   END  
										ELSE 0  
										END), 0) AS CS_Monthly_AMNT,
                         ISNULL(SUM(
								CASE  
									WHEN x.Periodic_AMNT > 0 AND x.EndObligation_DATE >= @Ld_System_DATE  
									THEN
									CASE
                                     WHEN x.FreqPeriodic_CODE = @Lc_FreqDaily_CODE
                                          AND x.TypeDebt_CODE = @Lc_TypeDebtSS_CODE
                                      THEN (x.Periodic_AMNT * 365) / 12
                                     WHEN x.FreqPeriodic_CODE = @Lc_FreqWeekly_CODE
                                          AND x.TypeDebt_CODE = @Lc_TypeDebtSS_CODE
                                      THEN (x.Periodic_AMNT * 52) / 12
                                     WHEN x.FreqPeriodic_CODE = @Lc_FreqMonthly_CODE
                                          AND x.TypeDebt_CODE = @Lc_TypeDebtSS_CODE
                                      THEN (x.Periodic_AMNT * 12) / 12
                                     WHEN x.FreqPeriodic_CODE = @Lc_FreqBiweekly_CODE
                                          AND x.TypeDebt_CODE = @Lc_TypeDebtSS_CODE
                                      THEN (x.Periodic_AMNT * 26) / 12
                                     WHEN x.FreqPeriodic_CODE = @Lc_FreqSemiMonthly_CODE
                                          AND x.TypeDebt_CODE = @Lc_TypeDebtSS_CODE
                                      THEN (x.Periodic_AMNT * 24) / 12
                                     WHEN x.FreqPeriodic_CODE = @Lc_FreqAnnually_CODE
                                          AND x.TypeDebt_CODE = @Lc_TypeDebtSS_CODE
                                      THEN (x.Periodic_AMNT * 1) / 12
                                     WHEN x.FreqPeriodic_CODE = @Lc_FreqQuarterly_CODE
                                          AND x.TypeDebt_CODE = @Lc_TypeDebtSS_CODE
                                      THEN (x.Periodic_AMNT * 4) / 12
                                      END  
                                    END), 0) AS SS_Monthly_AMNT
				FROM OBLE_Y1  x
                   WHERE x.Case_IDNO = @An_Case_IDNO
                     AND x.EndValidity_DATE = @Ld_Highdate_DATE
                     AND x.TypeDebt_CODE <> @Lc_TypeDebtGT_CODE
                     AND ((x.BeginObligation_DATE <= @Ld_System_DATE
					 AND x.EndObligation_DATE = (SELECT MAX(b.EndObligation_DATE)
                                                 FROM OBLE_Y1 b
                                                WHERE b.Case_IDNO = x.Case_IDNO
                                                  AND b.OrderSeq_NUMB = x.OrderSeq_NUMB
                                                  AND b.ObligationSeq_NUMB = x.ObligationSeq_NUMB
                                                  AND b.BeginObligation_DATE <= @Ld_System_DATE
                                                  AND b.EndValidity_DATE = @Ld_Highdate_DATE))
					OR (x.BeginObligation_DATE > @Ld_System_DATE
                       AND x.EndObligation_DATE = (SELECT MIN(b.EndObligation_DATE)
                                                     FROM OBLE_Y1 b
                                                    WHERE b.Case_IDNO = x.Case_IDNO
                                                      AND b.OrderSeq_NUMB = x.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = x.ObligationSeq_NUMB
                                                      AND b.BeginObligation_DATE > @Ld_System_DATE
                                                      AND b.EndValidity_DATE = @Ld_Highdate_DATE)
					  AND NOT EXISTS (SELECT 1
                                         FROM OBLE_Y1 c
                                        WHERE c.Case_IDNO = x.Case_IDNO
                                          AND c.OrderSeq_NUMB = x.OrderSeq_NUMB
                                          AND c.ObligationSeq_NUMB = x.ObligationSeq_NUMB
                                          AND c.BeginObligation_DATE <= @Ld_System_DATE
                                          AND c.EndValidity_DATE = @Ld_Highdate_DATE))))fci)y                                                                                                       
                     
   SET @Ls_Sql_TEXT = ' SELECT Owiz_Y1_1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6));

   SELECT @Ln_ExpectToPay1_AMNT = y.ExpectToPay_AMNT,
          @Ln_Periodic1_AMNT = y.Periodic_AMNT,
          @Ld_InitialOblicationBegin_DATE = y.InitialOblicationBegin_DATE,
          @Ls_FrequencyPeriodic1_CODE = y.freq_periodic
     FROM(SELECT CASE fci.freq_periodic
                  WHEN @Lc_FreqDaily_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 365
                  WHEN @Lc_FreqWeekly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 52
                  WHEN @Lc_FreqMonthly_CODE
                   THEN fci.ExpectToPay_AMNT
                  WHEN @Lc_FreqBiweekly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 26
                  WHEN @Lc_FreqSemiMonthly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 24
                  WHEN @Lc_FreqAnnually_CODE
                   THEN (fci.ExpectToPay_AMNT * 12)
                  WHEN @Lc_FreqQuarterly_CODE
                   THEN CAST((fci.ExpectToPay_AMNT * 12) AS NUMERIC(11, 2)) / 4
                  ELSE fci.ExpectToPay_AMNT
                 END AS ExpectToPay_AMNT,
                 CASE fci.freq_periodic
                  WHEN @Lc_FreqDaily_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 365
                  WHEN @Lc_FreqWeekly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 52
                  WHEN @Lc_FreqMonthly_CODE
                   THEN fci.Monthly_AMNT
                  WHEN @Lc_FreqBiweekly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 26
                  WHEN @Lc_FreqSemiMonthly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 24
                  WHEN @Lc_FreqAnnually_CODE
                   THEN fci.Monthly_AMNT * 12
                  WHEN @Lc_FreqQuarterly_CODE
                   THEN CAST((fci.Monthly_AMNT * 12) AS NUMERIC(11, 2)) / 4
                  ELSE fci.Monthly_AMNT
                 END AS Periodic_AMNT,
                 fci.InitialOblicationBegin_DATE,
                 dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_TableFRQA_ID, @Lc_TableSubFRQ3_ID, fci.freq_periodic) AS freq_periodic
            FROM (SELECT ISNULL(CASE MAX(CASE x.FreqPeriodic_CODE
                                          WHEN @Lc_FreqDaily_CODE
                                           THEN 365
                                          WHEN @Lc_FreqWeekly_CODE
                                           THEN 52
                                          WHEN @Lc_FreqMonthly_CODE
                                           THEN 12
                                          WHEN @Lc_FreqBiweekly_CODE
                                           THEN 26
                                          WHEN @Lc_FreqSemiMonthly_CODE
                                           THEN 24
                                          WHEN @Lc_FreqAnnually_CODE
                                           THEN 1
                                          WHEN @Lc_FreqQuarterly_CODE
                                           THEN 4
                                         END)
                                 WHEN 365
                                  THEN @Lc_FreqDaily_CODE
                                 WHEN 52
                                  THEN @Lc_FreqWeekly_CODE
                                 WHEN 12
                                  THEN @Lc_FreqMonthly_CODE
                                 WHEN 26
                                  THEN @Lc_FreqBiweekly_CODE
                                 WHEN 24
                                  THEN @Lc_FreqSemiMonthly_CODE
                                 WHEN 1
                                  THEN @Lc_FreqAnnually_CODE
                                 WHEN 4
                                  THEN @Lc_FreqQuarterly_CODE
                                END, @Lc_Space_TEXT) AS freq_periodic,
                         ISNULL(SUM(CASE x.FreqPeriodic_CODE
                                     WHEN @Lc_FreqDaily_CODE
                                      THEN (x.ExpectToPay_AMNT * 365) / 12
                                     WHEN @Lc_FreqWeekly_CODE
                                      THEN (x.ExpectToPay_AMNT * 52) / 12
                                     WHEN @Lc_FreqMonthly_CODE
                                      THEN (x.ExpectToPay_AMNT * 12) / 12
                                     WHEN @Lc_FreqBiweekly_CODE
                                      THEN (x.ExpectToPay_AMNT * 26) / 12
                                     WHEN @Lc_FreqSemiMonthly_CODE
                                      THEN (x.ExpectToPay_AMNT * 24) / 12
                                     WHEN @Lc_FreqAnnually_CODE
                                      THEN (x.ExpectToPay_AMNT * 1) / 12
                                     WHEN @Lc_FreqQuarterly_CODE
                                      THEN (x.ExpectToPay_AMNT * 4) / 12
                                    END), 0) AS ExpectToPay_AMNT,
                         ISNULL(SUM(CASE x.FreqPeriodic_CODE
                                     WHEN @Lc_FreqDaily_CODE
                                      THEN (x.Periodic_AMNT * 365) / 12
                                     WHEN @Lc_FreqWeekly_CODE
                                      THEN (x.Periodic_AMNT * 52) / 12
                                     WHEN @Lc_FreqMonthly_CODE
                                      THEN (x.Periodic_AMNT * 12) / 12
                                     WHEN @Lc_FreqBiweekly_CODE
                                      THEN (x.Periodic_AMNT * 26) / 12
                                     WHEN @Lc_FreqSemiMonthly_CODE
                                      THEN (x.Periodic_AMNT * 24) / 12
                                     WHEN @Lc_FreqAnnually_CODE
                                      THEN (x.Periodic_AMNT * 1) / 12
                                     WHEN @Lc_FreqQuarterly_CODE
                                      THEN (x.Periodic_AMNT * 4) / 12
                                    END), 0) AS Monthly_AMNT,
                         MIN(BeginObligation_DATE) AS InitialOblicationBegin_DATE
                    FROM OBLE_Y1  x
                   WHERE x.Case_IDNO = @An_Case_IDNO
                     AND x.EndValidity_DATE = @Ld_Highdate_DATE
                     AND x.TypeDebt_CODE <> @Lc_TypeDebtGT_CODE
                     AND x.BeginObligation_DATE <= (SELECT MIN(BeginObligation_DATE)
                                                      FROM OBLE_Y1  x
                                                     WHERE x.Case_IDNO = @An_Case_IDNO
                                                       AND x.EndValidity_DATE = @Ld_Highdate_DATE)) fci) y;

   SELECT @Ln_RecentOrder_ChildCount_NUMB = COUNT(DISTINCT x.MemberMci_IDNO)
     FROM OBLE_Y1 x
    WHERE x.Case_IDNO = @An_Case_IDNO
      AND x.Endvalidity_DATE = @Ld_Highdate_DATE
      AND CONVERT(VARCHAR(10), @Ad_Run_DATE, 101) BETWEEN x.BeginObligation_DATE AND x.EndObligation_DATE
      AND x.TypeDebt_CODE = @Lc_TypeDebtCS_CODE;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CAST(a.RecentOrderExpectToPay_AMNT AS VARCHAR(100)) RecentOrderExpectToPay_AMNT,
                   CAST(a.RecentOrderCurrentSupport_AMNT AS VARCHAR(100)) RecentOrderCurrentSupport_AMNT,
                   CAST(a.TotalOrderedSupport_AMNT AS VARCHAR(100)) TotalOrderedSupport_AMNT,
                   CAST(a.InitialOrderExpectToPay_AMNT AS VARCHAR(100)) InitialOrderExpectToPay_AMNT,
                   CAST(a.InitialOrderCurrentSupport_AMNT AS VARCHAR(100)) InitialOrderCurrentSupport_AMNT,
                   CAST(a.InitialOrder_Date AS VARCHAR(100)) InitialOrder_Date,
                   CAST(a.RecentOrderFrequencyPeriodic_CODE AS VARCHAR(100)) RecentOrderFrequencyPeriodic_CODE,
                   CAST(a.InitialOrderFrequencyPeriodic_CODE AS VARCHAR(100)) InitialOrderFrequencyPeriodic_CODE,
                   CAST(a.RecentOrderChildSupport_AMNT AS VARCHAR(100)) RecentOrderChildSupport_AMNT,
                   CAST(a.RecentOrderSpousalSupport_AMNT AS VARCHAR(100)) RecentOrderSpousalSupport_AMNT,
                   CAST(a.RecentOrder_ChildCount_NUMB AS VARCHAR(100)) RecentOrder_ChildCount_NUMB
              FROM (SELECT ISNULL(@Ln_ExpectToPay_AMNT, 0) AS RecentOrderExpectToPay_AMNT,
                           ISNULL(@Ln_Periodic_AMNT, 0) AS RecentOrderCurrentSupport_AMNT,
                           ISNULL(@Ln_totalorderedsupport_amnt, 0) AS TotalOrderedSupport_AMNT,
                           ISNULL(@Ln_ExpectToPay1_AMNT, 0) AS InitialOrderExpectToPay_AMNT,
                           ISNULL(@Ln_Periodic1_AMNT, 0) AS InitialOrderCurrentSupport_AMNT,
                           ISNULL(@Ld_InitialOblicationBegin_DATE, '') AS InitialOrder_Date,
                           ISNULL(@Ls_FrequencyPeriodic_CODE, '') AS RecentOrderFrequencyPeriodic_CODE,
                           ISNULL(@Ls_FrequencyPeriodic1_CODE, '') AS InitialOrderFrequencyPeriodic_CODE,
                           ISNULL(@Ln_CsPeriodic_AMNT, '') AS RecentOrderChildSupport_AMNT,
                           ISNULL(@Ln_SsPeriodic_AMNT, '') AS RecentOrderSpousalSupport_AMNT,
                           ISNULL(@Ln_RecentOrder_ChildCount_NUMB, 0) AS RecentOrder_ChildCount_NUMB)a) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( RecentOrderExpectToPay_AMNT, RecentOrderCurrentSupport_AMNT,TotalOrderedSupport_AMNT, InitialOrderExpectToPay_AMNT, InitialOrderCurrentSupport_AMNT, /*RecentOrder_DATE, */InitialOrder_Date, RecentOrderFrequencyPeriodic_CODE, InitialOrderFrequencyPeriodic_CODE, RecentOrderChildSupport_AMNT, RecentOrderSpousalSupport_AMNT, RecentOrder_ChildCount_NUMB )) AS pvt);

  
  
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CAST(a.InitialOrderArrears_AMNT AS VARCHAR(100)) InitialOrderArrears_AMNT
              FROM (SELECT ISNULL (SUM ((s.OweTotNaa_AMNT - s.AppTotNaa_AMNT) + (s.OweTotPaa_AMNT - s.AppTotPaa_AMNT) + (s.OweTotTaa_AMNT - s.AppTotTaa_AMNT) + (s.OweTotCaa_AMNT - s.AppTotCaa_AMNT) + (s.OweTotUpa_AMNT - s.AppTotUpa_AMNT) + (s.OweTotUda_AMNT - s.AppTotUda_AMNT) + (s.OweTotIvef_AMNT - s.AppTotIvef_AMNT) + (s.OweTotNffc_AMNT - s.AppTotNffc_AMNT) + (s.OweTotMedi_AMNT - s.AppTotMedi_AMNT) + (s.OweTotNonIvd_AMNT - s.AppTotNonIvd_AMNT) - (s.OweTotCurSup_AMNT - s.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  WHEN s.MtdCurSupOwed_AMNT < s.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   THEN s.AppTotCurSup_AMNT - s.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 END)), 0) InitialOrderArrears_AMNT
                      FROM LSUP_Y1 s
                     WHERE s.Case_IDNO = @An_Case_IDNO
                       AND s.OrderSeq_NUMB = @An_OrderSeq_NUMB
                       AND s.SupportYearMonth_NUMB = ISNULL ((SELECT MAX(SupportYearMonth_NUMB)
                                                                FROM LSUP_Y1 l
                                                               WHERE Case_IDNO = @An_Case_IDNO
                                                                 AND OrderSeq_NUMB = @An_OrderSeq_NUMB
                                                                 AND SupportYearMonth_NUMB <= CAST(CONVERT(VARCHAR(6), @Ld_InitialOblicationBegin_DATE, 112) AS NUMERIC)), (SELECT MIN(SupportYearMonth_NUMB)
                                                                                                                                                                              FROM LSUP_Y1 l
                                                                                                                                                                             WHERE Case_IDNO = @An_Case_IDNO
                                                                                                                                                                               AND OrderSeq_NUMB = @An_OrderSeq_NUMB
                                                                                                                                                                               AND SupportYearMonth_NUMB >= CAST(CONVERT(VARCHAR(6), @Ld_InitialOblicationBegin_DATE, 112) AS NUMERIC)))
                       AND s.EventGlobalSeq_NUMB = (SELECT MAX (h.EventGlobalSeq_NUMB)
                                                      FROM LSUP_Y1  h
                                                     WHERE s.Case_IDNO = h.Case_IDNO
                                                       AND s.OrderSeq_NUMB = h.OrderSeq_NUMB
                                                       AND s.ObligationSeq_NUMB = h.ObligationSeq_NUMB
                                                       AND s.SupportYearMonth_NUMB = h.SupportYearMonth_NUMB)
                       --  To check the exist condition for obligation               
                       AND EXISTS (SELECT 1 --AS expr
                                     FROM OBLE_Y1  o
                                    WHERE s.Case_IDNO = o.Case_IDNO
                                      AND s.OrderSeq_NUMB = o.OrderSeq_NUMB
                                      AND s.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                      AND o.TypeDebt_CODE NOT IN (@Lc_TypeDebtAlimonyAL_CODE, @Lc_TypeDebtIntAlimonyAI_CODE, @Lc_TypeDebtGeneticTestGT_CODE)
                                      AND o.EndValidity_DATE = @Ld_Highdate_DATE))a) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( InitialOrderArrears_AMNT )) AS pvt);

     
              SELECT @Ld_RecentOrder_DATE = MAX(s.OrderIssued_DATE), 
                     @Ld_InitialOrder_DATE =MIN (s.OrderIssued_DATE)                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
                 FROM SORD_Y1 s
               WHERE s.Case_IDNO = @An_Case_IDNO
                 AND s.OrderSeq_NUMB = @An_OrderSeq_NUMB
                      
			INSERT INTO #NoticeElementsData_P1
						   (Element_NAME,
							Element_VALUE)
			   (SELECT Element_NAME,
					   Element_VALUE
				  FROM (SELECT 
							   CAST(a.RecentOrder_DATE AS VARCHAR(100)) RecentOrder_DATE,
							   CAST(a.OrderInitial_DATE AS VARCHAR(100)) OrderInitial_Date
							FROM (SELECT 
									   ISNULL(@Ld_RecentOrder_DATE, '') AS RecentOrder_DATE,
									   ISNULL(@Ld_InitialOrder_DATE, '') AS OrderInitial_DATE)a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (RecentOrder_DATE, OrderInitial_Date)) AS pvt);

			  

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
