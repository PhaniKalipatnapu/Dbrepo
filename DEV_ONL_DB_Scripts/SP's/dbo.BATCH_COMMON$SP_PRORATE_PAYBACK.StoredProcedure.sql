/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_PRORATE_PAYBACK]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_PRORATE_PAYBACK
Programmer Name		: IMP Team
Description			: Procedure is used to proreate payback amount
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_PRORATE_PAYBACK] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC (2, 0) = NULL,
 @An_EventGlobalBeginSeq_NUMB NUMERIC (19, 0),
 @An_Payback_AMNT             NUMERIC(11, 2),
 @Ac_PaybackType_CODE         CHAR(1),
 @Ac_PaybackFreq_TEXT         CHAR(1),
 @Ad_Process_DATE             DATE,
 @Ac_ObleUpdated_TEXT         CHAR(1),
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_PaybackProrate1100_NUMB  INT = 1100,
           @Lc_No_TEXT                  CHAR(1) = 'N',
           @Lc_Space_TEXT               CHAR(1) = ' ',
           @Lc_StringZero_TEXT          CHAR(1) = '0',
           @Lc_TypeRecordOriginal_CODE  CHAR(1) = 'O',
           @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
           @Lc_StatusFailure_CODE       CHAR(1) = 'F',
           @Lc_Quote_TEXT               CHAR(1) = '~',
           @Ls_Routine_TEXT             VARCHAR(400) = ' BATCH_COMMON$SP_PRORATE_PAYBACK ',
           @Ld_Highdate_DATE            DATE = '12/31/9999',
           @Ld_Lowdate_DATE             DATE = '01/01/0001';
  DECLARE  @Ln_RowCount_QNTY          NUMERIC,
           @Ln_FLAG_NUMB              NUMERIC,
           @Ln_Error_NUMB             NUMERIC,
           @Ln_SupportYearMonth_NUMB  NUMERIC(6),
           @Ln_Zero_NUMB              NUMERIC(9,0) = 0,
           @Ln_ErrorLine_NUMB         NUMERIC(11,0),
           @Ln_RowCountUpd_NUMB       NUMERIC(19,0),
           @Ln_RowCountIns_NUMB       NUMERIC(19,0),
           @Ls_Sql_TEXT               VARCHAR(400),
           @Ls_Sqldata_TEXT           VARCHAR(400),
           @Ls_Errormessage_TEXT      VARCHAR(4000),
           @Ld_Process_DATE           DATETIME;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Process_DATE = @Ad_Process_DATE;
   SET @Ln_SupportYearMonth_NUMB = ISNULL(CONVERT(CHAR(6), @Ad_Process_DATE, 112), '');
   SET @Ls_Sql_TEXT = 'SELECT FROM OBLE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', CD_EXPT = ' + ISNULL(@Ac_PaybackType_CODE, '') + ', EXPT = ' + ISNULL(CAST(@An_Payback_AMNT AS VARCHAR), '');

   CREATE TABLE #Prorate_P1
    (
      OrderSeq_NUMB                 NUMERIC(2, 0),
      ObligationSeq_NUMB            NUMERIC(2, 0),
      AmtExptPrev_CODE              VARCHAR(10),
      CdExpt_CODE                   VARCHAR(10),
      CdFreq_CODE                   VARCHAR(10),
      oble_BeginObligation_DATE     DATETIME2(0),
      oble_Case_IDNO                VARCHAR(6),
      oble_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
      oble_ObligationSeq_NUMB       NUMERIC(2, 0),
      oble_OrderSeq_NUMB            NUMERIC(2, 0),
      lsup_Case_IDNO                NUMERIC(6, 0),
      lsup_EventGlobalSeq_NUMB      NUMERIC(19, 0),
      lsup_ObligationSeq_NUMB       NUMERIC(2, 0),
      lsup_OrderSeq_NUMB            NUMERIC(2, 0),
      lsup_SupportYearMonth_NUMB    NUMERIC(6, 0),
      oble_rowvalid                 CHAR(1),
      lsup_rowvalid                 CHAR(1),
      AmntExptNew_CODE              VARCHAR(10),
      AmntExptMso_CODE              VARCHAR(10)
    );

   INSERT INTO #Prorate_P1
               (OrderSeq_NUMB,
                ObligationSeq_NUMB,
                AmtExptPrev_CODE,
                CdExpt_CODE,
                CdFreq_CODE,
                oble_BeginObligation_DATE,
                oble_Case_IDNO,
                oble_EventGlobalBeginSeq_NUMB,
                oble_ObligationSeq_NUMB,
                oble_OrderSeq_NUMB,
                lsup_Case_IDNO,
                lsup_EventGlobalSeq_NUMB,
                lsup_ObligationSeq_NUMB,
                lsup_OrderSeq_NUMB,
                lsup_SupportYearMonth_NUMB,
                oble_rowvalid,
                lsup_rowvalid,
                AmntExptNew_CODE,
                AmntExptMso_CODE)
   SELECT ee.OrderSeq_NUMB,
          ee.ObligationSeq_NUMB,
          ee.Payback_AMNT,
          ee.TypePayback_CODE,
          ee.Freq_CODE,
          ee.oble_BeginObligation_DATE,
          ee.oble_Case_IDNO,
          ee.oble_EventGlobalBeginSeq_NUMB,
          ee.oble_ObligationSeq_NUMB,
          ee.oble_OrderSeq_NUMB,
          ee.lsup_Case_IDNO,
          ee.lsup_EventGlobalSeq_NUMB,
          ee.lsup_ObligationSeq_NUMB,
          ee.lsup_OrderSeq_NUMB,
          ee.lsup_SupportYearMonth_NUMB,
          ee.oble_rowvalid,
          ee.lsup_rowvalid,
          dbo.BATCH_COMMON$SF_PRORATE_PAYBACK_CALC_FINAL_AO(@Ac_PaybackFreq_TEXT, ee.Freq_CODE, ee.prorated_ao) AS AmntExptNew_CODE,
          dbo.BATCH_COMMON$SF_PRORATE_PAYBACK_CALC_PAYBACK_MSO(ee.Freq_CODE, ee.dt_beg, dbo.BATCH_COMMON$SF_PRORATE_PAYBACK_CALC_FINAL_AO(@Ac_PaybackFreq_TEXT, ee.Freq_CODE, EE.prorated_ao), @Ad_Process_DATE) AS AmntExptMso_CODE
     FROM (SELECT dd.OrderSeq_NUMB,
                  dd.ObligationSeq_NUMB,
                  dd.Payback_AMNT,
                  dd.TypePayback_CODE,
                  dd.Freq_CODE,
                  dd.dt_beg,
                  dd.oble_BeginObligation_DATE,
                  dd.oble_Case_IDNO,
                  dd.oble_EventGlobalBeginSeq_NUMB,
                  dd.oble_ObligationSeq_NUMB,
                  dd.oble_OrderSeq_NUMB,
                  dd.lsup_Case_IDNO,
                  dd.lsup_EventGlobalSeq_NUMB,
                  dd.lsup_ObligationSeq_NUMB,
                  dd.lsup_OrderSeq_NUMB,
                  dd.lsup_SupportYearMonth_NUMB,
                  dd.oble_rowvalid,
                  dd.lsup_rowvalid,
                  CASE
                   WHEN dd.Rounded_AMNT <> 0
                    THEN CAST(dd.ao AS NUMERIC(19, 0)) + CASE
                                                          WHEN dd.Rounded_AMNT > 0
                                                               AND (CAST(dd.Rounded_AMNT AS NUMERIC(19, 0)) - CAST(dd.cum_round AS NUMERIC(19, 0))) >= 0
                                                           THEN 0.01
                                                          WHEN dd.Rounded_AMNT < 0
                                                               AND (CAST(dd.Rounded_AMNT AS NUMERIC(19, 0)) - CAST(dd.cum_round1 AS NUMERIC(19, 0))) <= 0
                                                           THEN -0.01
                                                          ELSE 0
                                                         END
                   ELSE dd.ao
                  END AS prorated_ao
             FROM (SELECT cc.ObligationSeq_NUMB,
                          cc.OrderSeq_NUMB,
                          cc.Fips_CODE,
                          cc.MemberMci_IDNO,
                          cc.Payback_AMNT,
                          cc.TypePayback_CODE,
                          cc.TypeDebt_CODE,
                          cc.Freq_CODE,
                          cc.dt_beg,
                          cc.Cs_AMNT,
                          cc.sum_cs,
                          cc.Cs_Arr,
                          cc.sum_Arr,
                          cc.oble_BeginObligation_DATE,
                          cc.oble_Case_IDNO,
                          cc.oble_EventGlobalBeginSeq_NUMB,
                          cc.oble_ObligationSeq_NUMB,
                          cc.oble_OrderSeq_NUMB,
                          cc.lsup_Case_IDNO,
                          cc.lsup_EventGlobalSeq_NUMB,
                          cc.lsup_ObligationSeq_NUMB,
                          cc.lsup_OrderSeq_NUMB,
                          cc.lsup_SupportYearMonth_NUMB,
                          cc.oble_rowvalid,
                          cc.lsup_rowvalid,
                          cc.rn,
                          cc.tot_rec,
                          CASE
                           WHEN cc.sum_cs > 0
                            THEN ROUND((cc.Cs_AMNT / cc.sum_cs) * @An_Payback_AMNT, 2)
                           WHEN cc.sum_Arr > 0
                            THEN ROUND((cc.Cs_Arr / cc.sum_Arr) * @An_Payback_AMNT, 2)
                           ELSE ROUND(@An_Payback_AMNT / cc.tot_rec, 2)
                          /*When all the balances are zero re-prorate across all obligations--check if this is correct*/
                          END AS ao,
                          (@An_Payback_AMNT - CASE
                                               /*To avoid negative AO entries
                                                         Instead of checking at the group sum - check for each instance
                                               If all the sum_amounts are zero, then rounded shud be zero*/
                                               WHEN (cc.Cs_AMNT <= 0
                                                     AND cc.Cs_Arr <= 0)
                                                    AND (cc.sum_cs > 0
                                                          OR cc.sum_Arr > 0)
                                                THEN @An_Payback_AMNT
                                               ELSE SUM(CASE
                                                         WHEN cc.sum_cs > 0
                                                          THEN ROUND((cc.Cs_AMNT / cc.sum_cs) * @An_Payback_AMNT, 2)
                                                         WHEN cc.sum_Arr > 0
                                                          THEN ROUND((cc.Cs_Arr / cc.sum_Arr) * @An_Payback_AMNT, 2)
                                                         ELSE ROUND(@An_Payback_AMNT / cc.tot_rec, 2)
                                                        END) OVER()
                                              END) AS Rounded_AMNT,
                          SUM (CASE
                                WHEN (cc.Cs_AMNT > 0
                                       OR cc.Cs_Arr > 0)
                                      OR (cc.sum_cs > 0
                                           OR cc.sum_Arr > 0)
                                 THEN 0.01
                                ELSE 0
                               END) OVER(PARTITION BY OrderSeq_NUMB, Fips_CODE, MemberMci_IDNO, TypeDebt_CODE ) AS cum_round,
                          SUM (CASE
                                WHEN (cc.Cs_AMNT > 0
                                       OR cc.Cs_Arr > 0)
                                      OR (cc.sum_cs > 0
                                           OR cc.sum_Arr > 0)
                                 THEN -0.01
                                ELSE 0
                               END) OVER(PARTITION BY OrderSeq_NUMB, Fips_CODE, MemberMci_IDNO, TypeDebt_CODE ) AS cum_round1
                     FROM (SELECT MAX(CASE
                                       --OWIZ/OBAA - Genetic Test arrears and payee updating 
                                       --Included GT debt type in the following CASe conditions
                                       WHEN (debt = 'S'
                                              OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                        THEN bb.ObligationSeq_NUMB
                                       ELSE NULL
                                      END) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS ObligationSeq_NUMB,
                                  bb.OrderSeq_NUMB,
                                  bb.Fips_CODE,
                                  bb.MemberMci_IDNO,
                                  MAX(CASE
                                       WHEN (debt = 'S'
                                              OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                        THEN bb.ExpectToPay_AMNT
                                       ELSE NULL
                                      END) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS Payback_AMNT,
                                  MAX(CASE
                                       WHEN (debt = 'S'
                                              OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                        THEN bb.ExpectToPay_CODE
                                       ELSE NULL
                                      END) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS TypePayback_CODE,
                                  MAX(CASE
                                       WHEN (debt = 'S'
                                              OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                        THEN bb.TypeDebt_CODE
                                       ELSE NULL
                                      END) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS TypeDebt_CODE,
                                  MAX(CASE
                                       WHEN (debt = 'S'
                                              OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                        THEN bb.Freq_CODE
                                       ELSE NULL
                                      END) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS Freq_CODE,
                                  MAX(CAST(CASE
                                            WHEN (debt = 'S'
                                                   OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                             THEN bb.dt_beg
                                            ELSE NULL
                                           END AS DATETIME)) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS dt_beg,
                                  bb.oble_BeginObligation_DATE,
                                  bb.oble_Case_IDNO,
                                  bb.oble_EventGlobalBeginSeq_NUMB,
                                  bb.oble_ObligationSeq_NUMB,
                                  bb.oble_OrderSeq_NUMB,
                                  bb.lsup_Case_IDNO,
                                  bb.lsup_EventGlobalSeq_NUMB,
                                  bb.lsup_ObligationSeq_NUMB,
                                  bb.lsup_OrderSeq_NUMB,
                                  bb.lsup_SupportYearMonth_NUMB,
                                  MAX(CAST(CASE
                                            WHEN (debt = 'S'
                                                   OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                             THEN 'Y'
                                            ELSE NULL
                                           END AS VARCHAR)) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS oble_rowvalid,
                                  MAX(CAST(CASE
                                            WHEN (debt = 'S'
                                                   OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                             THEN 'Y'
                                            ELSE NULL
                                           END AS VARCHAR)) OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS lsup_rowvalid,
                                  SUM(dbo.BATCH_COMMON_SCALAR$SF_GREATEST_FLOAT(CAST(bb.Cs_AMNT AS NUMERIC(11, 2)), @Ln_Zero_NUMB)) OVER ( PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS Cs_AMNT,
                                  SUM(dbo.BATCH_COMMON_SCALAR$SF_GREATEST_FLOAT(CAST(bb.Cs_AMNT AS NUMERIC(11, 2)), @Ln_Zero_NUMB)) OVER () AS sum_cs,
                                  SUM(dbo.BATCH_COMMON_SCALAR$SF_GREATEST_FLOAT(CAST(bb.Cs_Arr AS NUMERIC(11, 2)), @Ln_Zero_NUMB)) OVER( PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1) AS Cs_Arr,
                                  SUM(dbo.BATCH_COMMON_SCALAR$SF_GREATEST_FLOAT(CAST(bb.Cs_Arr AS NUMERIC(11, 2)), @Ln_Zero_NUMB)) OVER( ) AS sum_Arr,
                                  ROW_NUMBER() OVER(PARTITION BY bb.OrderSeq_NUMB, bb.Fips_CODE, bb.MemberMci_IDNO, bb.TypeDebt_CODE, debt1 ORDER BY OrderSeq_NUMB) AS rn,
                                  SUM(CASE
                                       WHEN (debt = 'S'
                                              OR bb.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                        THEN 1
                                       ELSE 0
                                      END) OVER() AS tot_rec
                             FROM (SELECT aa.OrderSeq_NUMB,
                                          aa.ObligationSeq_NUMB,
                                          aa.TypeDebt_CODE,
                                          aa.Fips_CODE,
                                          aa.ExpectToPay_AMNT,
                                          aa.ExpectToPay_CODE,
                                          aa.MemberMci_IDNO,
                                          aa.debt,
                                          aa.debt1,
                                          aa.arr,
                                          aa.Freq_CODE,
                                          aa.dt_beg,
                                          aa.oble_BeginObligation_DATE,
                                          aa.oble_Case_IDNO,
                                          aa.oble_EventGlobalBeginSeq_NUMB,
                                          aa.oble_ObligationSeq_NUMB,
                                          aa.oble_OrderSeq_NUMB,
                                          aa.lsup_Case_IDNO,
                                          aa.lsup_EventGlobalSeq_NUMB,
                                          aa.lsup_ObligationSeq_NUMB,
                                          aa.lsup_OrderSeq_NUMB,
                                          aa.lsup_SupportYearMonth_NUMB,
                                          CASE
                                           WHEN (debt = 'S'
                                                  OR aa.TypeDebt_CODE IN ('AL', 'CM', 'GT'))
                                            THEN aa.arr
                                           ELSE 0
                                          END AS Cs_AMNT,
                                          CASE
                                           WHEN debt = 'I'
                                            THEN aa.arr
                                           ELSE 0
                                          END AS Cs_Arr
                                     FROM (SELECT oble.OrderSeq_NUMB,
                                                  oble.ObligationSeq_NUMB,
                                                  oble.TypeDebt_CODE,
                                                  oble.Fips_CODE,
                                                  oble.ExpectToPay_AMNT,
                                                  oble.ExpectToPay_CODE,
                                                  oble.MemberMci_IDNO,
                                                  oble.debt,
                                                  oble.debt1,
                                                  ISNULL(lsup.arr, 0) AS arr,
                                                  oble.FreqPeriodic_CODE AS Freq_CODE,
                                                  oble.BeginObligation_DATE AS dt_beg,
                                                  oble.oble_BeginObligation_DATE,
                                                  oble.oble_Case_IDNO,
                                                  oble.oble_EventGlobalBeginSeq_NUMB,
                                                  oble.oble_ObligationSeq_NUMB,
                                                  oble.oble_OrderSeq_NUMB,
                                                  lsup.lsup_Case_IDNO,
                                                  lsup.lsup_EventGlobalSeq_NUMB,
                                                  lsup.lsup_ObligationSeq_NUMB,
                                                  lsup.lsup_OrderSeq_NUMB,
                                                  lsup.lsup_SupportYearMonth_NUMB
                                             FROM (SELECT a.OrderSeq_NUMB,
                                                          a.ObligationSeq_NUMB,
                                                          a.TypeDebt_CODE,
                                                          a.Fips_CODE,
                                                          a.ExpectToPay_AMNT,
                                                          a.ExpectToPay_CODE,
                                                          a.MemberMci_IDNO,
                                                          ISNULL(SUBSTRING(a.TypeDebt_CODE, 2, 1), '') AS debt,
                                                          ISNULL(SUBSTRING(a.TypeDebt_CODE, 1, 1), '') AS debt1,
                                                          a.FreqPeriodic_CODE,
                                                          a.BeginObligation_DATE,
                                                          a.BeginObligation_DATE AS oble_BeginObligation_DATE,
                                                          Case_IDNO AS oble_Case_IDNO,
                                                          EventGlobalBeginSeq_NUMB AS oble_EventGlobalBeginSeq_NUMB,
                                                          ObligationSeq_NUMB AS oble_ObligationSeq_NUMB,
                                                          OrderSeq_NUMB AS oble_OrderSeq_NUMB
                                                     FROM OBLE_Y1 a
                                                    WHERE a.Case_IDNO = @An_Case_IDNO
                                                      AND a.OrderSeq_NUMB = ISNULL(@An_OrderSeq_NUMB, a.OrderSeq_NUMB)
                                                      AND a.EndValidity_DATE =  @Ld_Highdate_DATE
                                                      AND a.BeginObligation_DATE <= @Ad_Process_DATE
                                                      AND EXISTS (SELECT 1
                                                                    FROM DBTP_Y1 b
                                                                   WHERE b.TypeDebt_CODE = a.TypeDebt_CODE
                                                                     AND b.TypeBucket_CODE = 'E'
                                                                     AND b.PrDistribute_QNTY > 0
                                                                     AND b.EndValidity_DATE =  @Ld_Highdate_DATE)
                                                      AND a.EndObligation_DATE = (SELECT MAX(d.EndObligation_DATE)
                                                                                    FROM OBLE_Y1 d
                                                                                   WHERE d.Case_IDNO = a.Case_IDNO
                                                                                     AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                                                     AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                                                     AND d.BeginObligation_DATE <= @Ad_Process_DATE
                                                                                     AND d.EndValidity_DATE =  @Ld_Highdate_DATE)) oble
                                                  LEFT OUTER JOIN (SELECT s.OrderSeq_NUMB,
                                                                          s.ObligationSeq_NUMB,
                                                                          Case_IDNO lsup_Case_IDNO,
                                                                          EventGlobalSeq_NUMB lsup_EventGlobalSeq_NUMB,
                                                                          ObligationSeq_NUMB lsup_ObligationSeq_NUMB,
                                                                          OrderSeq_NUMB lsup_OrderSeq_NUMB,
                                                                          SupportYearMonth_NUMB lsup_SupportYearMonth_NUMB,
                                                                          (s.OweTotNaa_AMNT + s.OweTotTaa_AMNT + s.OweTotUpa_AMNT + s.OweTotPaa_AMNT + s.OweTotCaa_AMNT + s.OweTotUda_AMNT + s.OweTotIvef_AMNT + s.OweTotNffc_AMNT + s.OweTotNonIvd_AMNT + s.OweTotMedi_AMNT + s.AppTotCurSup_AMNT) - (s.AppTotNaa_AMNT + s.AppTotTaa_AMNT + s.AppTotUpa_AMNT + s.AppTotPaa_AMNT + s.AppTotCaa_AMNT + s.AppTotUda_AMNT + s.AppTotIvef_AMNT + s.AppTotNffc_AMNT + s.AppTotNonIvd_AMNT + s.AppTotMedi_AMNT + s.OweTotCurSup_AMNT) AS arr
                                                                     FROM LSUP_Y1 s
                                                                    WHERE s.Case_IDNO = @An_Case_IDNO
                                                                      AND s.OrderSeq_NUMB = ISNULL(@An_OrderSeq_NUMB, s.OrderSeq_NUMB)
                                                                      AND s.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
                                                                      AND s.EventGlobalSeq_NUMB = (SELECT MAX(c.EventGlobalSeq_NUMB)
                                                                                                     FROM LSUP_Y1 c
                                                                                                    WHERE c.Case_IDNO = s.Case_IDNO
                                                                                                      AND c.OrderSeq_NUMB = s.OrderSeq_NUMB
                                                                                                      AND c.ObligationSeq_NUMB = s.ObligationSeq_NUMB
                                                                                                      AND c.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB)) lsup
                                                   /*Outer Join to fetch OBLE records, not having LSUP records in the current month.
                                                   AO for CS obligation not having current month balance should be set to zero
                                                   not joining id_case since it is used to query in the inner level itself*/
                                                   ON oble.OrderSeq_NUMB = lsup.OrderSeq_NUMB
                                                      AND oble.ObligationSeq_NUMB = lsup.ObligationSeq_NUMB) aa) bb) cc
                    WHERE (oble_rowvalid = 'Y'
                            OR lsup_rowvalid = 'Y')
                      AND cc.rn = 1) dd) ee;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
   SET @Ln_FLAG_NUMB =1;

   IF (EXISTS (SELECT 1
                 FROM #Prorate_P1))
    BEGIN
     OBLE_LOGICAL_UPDATE:;

     IF @Ac_ObleUpdated_TEXT = @Lc_No_TEXT
      BEGIN
       /*pass indicator if OBLE table was updated already before invoking prorate
       --End date the current OBLE using the ROWID
       --Insert into OBLE with the new AO information*/
       SET @Ls_Sql_TEXT = 'UPDATE_OBLE_Y1';
       SET @Ls_Sqldata_TEXT = '';

       UPDATE O
          SET O.EndValidity_DATE = @Ad_Process_DATE,
              O.EventGlobalEndSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
         FROM OBLE_Y1 O,
              #Prorate_P1 P
        WHERE O.BeginObligation_DATE = P.oble_BeginObligation_DATE
          AND O.Case_IDNO = P.oble_Case_IDNO
          AND O.EventGlobalBeginSeq_NUMB = P.oble_EventGlobalBeginSeq_NUMB
          AND O.ObligationSeq_NUMB = P.oble_ObligationSeq_NUMB
          AND O.OrderSeq_NUMB = P.oble_OrderSeq_NUMB
          AND P.oble_rowvalid = 'Y'
          AND (P.AmntExptNew_CODE <> P.AmtExptPrev_CODE
                OR ISNULL(P.CdExpt_CODE, @Lc_Quote_TEXT) <> @Ac_PaybackType_CODE);

       SET @Ln_RowCountUpd_NUMB = @@ROWCOUNT;
       SET @Ln_FLAG_NUMB = @Ln_FLAG_NUMB + 1;

       SET @Ls_Sql_TEXT = 'INSERT_OBLE_Y1 1';
       SET @Ls_Sqldata_TEXT = 'EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_Highdate_DATE AS VARCHAR ),'')+ ', ExpectToPay_CODE = ' + ISNULL(@Ac_PaybackType_CODE,'');

       INSERT INTO OBLE_Y1
                   (Case_IDNO,
                    OrderSeq_NUMB,
                    ObligationSeq_NUMB,
                    MemberMci_IDNO,
                    TypeDebt_CODE,
                    Fips_CODE,
                    FreqPeriodic_CODE,
                    Periodic_AMNT,
                    ExpectToPay_AMNT,
                    ReasonChange_CODE,
                    BeginObligation_DATE,
                    EndObligation_DATE,
                    AccrualLast_DATE,
                    AccrualNext_DATE,
                    CheckRecipient_ID,
                    CheckRecipient_CODE,
                    EventGlobalBeginSeq_NUMB,
                    EventGlobalEndSeq_NUMB,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    ExpectToPay_CODE)
       SELECT O.Case_IDNO,
              O.OrderSeq_NUMB,
              O.ObligationSeq_NUMB,
              O.MemberMci_IDNO,
              O.TypeDebt_CODE,
              O.Fips_CODE,
              O.FreqPeriodic_CODE,
              O.Periodic_AMNT,
              AmntExptNew_CODE,
              ReasonChange_CODE,
              BeginObligation_DATE,
              EndObligation_DATE,
              AccrualLast_DATE,
              AccrualNext_DATE,
              CheckRecipient_ID,
              CheckRecipient_CODE,
              @An_EventGlobalBeginSeq_NUMB AS EventGlobalBeginSeq_NUMB,
              @Ln_Zero_NUMB AS EventGlobalEndSeq_NUMB,
              @Ad_Process_DATE AS BeginValidity_DATE,
              @Ld_Highdate_DATE AS EndValidity_DATE,
              @Ac_PaybackType_CODE AS ExpectToPay_CODE
         FROM OBLE_Y1 O,
              #Prorate_P1 P
        WHERE O.BeginObligation_DATE = P.oble_BeginObligation_DATE
          AND O.Case_IDNO = P.oble_Case_IDNO
          AND O.EventGlobalBeginSeq_NUMB = P.oble_EventGlobalBeginSeq_NUMB
          AND O.ObligationSeq_NUMB = P.oble_ObligationSeq_NUMB
          AND O.OrderSeq_NUMB = P.oble_OrderSeq_NUMB
          AND oble_rowvalid = 'Y'
          AND (AmntExptNew_CODE <> AmtExptPrev_CODE
                OR ISNULL(CdExpt_CODE, @Lc_Quote_TEXT) <> @Ac_PaybackType_CODE);

       SET @Ln_RowCountIns_NUMB = @@ROWCOUNT;

       IF @Ln_RowCountIns_NUMB <> @Ln_RowCountUpd_NUMB
        BEGIN
         RAISERROR(50001,16,1);
        END
      END
     ELSE
      BEGIN
       /*start Special processing for OWIZ, OBAA records
       If the new seq_Event_global matches the seq_Event_global, then do physical update
       Skip records having the same SEG*/
       SET @Ln_FLAG_NUMB = 1;
       
       SET @Ls_Sql_TEXT = 'UPDATE_OBLE_Y1';
       SET @Ls_Sqldata_TEXT = '';
       
       UPDATE O
          SET EndValidity_DATE = CASE
                                  WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                   THEN o.EndValidity_DATE
                                  ELSE @Ad_Process_DATE
                                 END,
              EventGlobalEndSeq_NUMB = CASE
                                        WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                         THEN o.EventGlobalEndSeq_NUMB
                                        ELSE @An_EventGlobalBeginSeq_NUMB
                                       END,
              ExpectToPay_CODE = CASE
                                  WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                   THEN @Ac_PaybackType_CODE
                                  ELSE o.ExpectToPay_CODE
                                 END,
              ExpectToPay_AMNT = CASE
                                  WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                   THEN AmntExptNew_CODE
                                  ELSE o.ExpectToPay_AMNT
                                 END
         FROM OBLE_Y1 O,
              #Prorate_P1 P
        WHERE O.BeginObligation_DATE = P.oble_BeginObligation_DATE
          AND O.Case_IDNO = P.oble_Case_IDNO
          AND O.EventGlobalBeginSeq_NUMB = P.oble_EventGlobalBeginSeq_NUMB
          AND O.ObligationSeq_NUMB = P.oble_ObligationSeq_NUMB
          AND O.OrderSeq_NUMB = P.oble_OrderSeq_NUMB
          AND oble_rowvalid = 'Y'
          AND (P.AmntExptNew_CODE <> P.AmtExptPrev_CODE
                OR ISNULL(CdExpt_CODE, @Lc_Quote_TEXT) <> @Ac_PaybackType_CODE);

       SET @Ls_Sql_TEXT = 'INSERT_OBLE_Y1 2';
       SET @Ls_Sqldata_TEXT = 'EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_Highdate_DATE AS VARCHAR ),'')+ ', ExpectToPay_CODE = ' + ISNULL(@Ac_PaybackType_CODE,'');

       INSERT INTO OBLE_Y1
                   (Case_IDNO,
                    OrderSeq_NUMB,
                    ObligationSeq_NUMB,
                    MemberMci_IDNO,
                    TypeDebt_CODE,
                    Fips_CODE,
                    FreqPeriodic_CODE,
                    Periodic_AMNT,
                    ExpectToPay_AMNT,
                    ReasonChange_CODE,
                    BeginObligation_DATE,
                    EndObligation_DATE,
                    AccrualLast_DATE,
                    AccrualNext_DATE,
                    CheckRecipient_ID,
                    CheckRecipient_CODE,
                    EventGlobalBeginSeq_NUMB,
                    EventGlobalEndSeq_NUMB,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    ExpectToPay_CODE)
       SELECT O.Case_IDNO,
              O.OrderSeq_NUMB,
              O.ObligationSeq_NUMB,
              MemberMci_IDNO,
              TypeDebt_CODE,
              Fips_CODE,
              FreqPeriodic_CODE,
              Periodic_AMNT,
              AmntExptNew_CODE,
              ReasonChange_CODE,
              BeginObligation_DATE,
              EndObligation_DATE,
              AccrualLast_DATE,
              AccrualNext_DATE,
              CheckRecipient_ID,
              CheckRecipient_CODE,
              @An_EventGlobalBeginSeq_NUMB AS EventGlobalBeginSeq_NUMB,
              @Ln_Zero_NUMB AS EventGlobalEndSeq_NUMB,
              @Ad_Process_DATE AS BeginValidity_DATE,
              @Ld_Highdate_DATE AS EndValidity_DATE,
              @Ac_PaybackType_CODE AS ExpectToPay_CODE
         FROM OBLE_Y1 O,
              #Prorate_P1 P
        WHERE O.BeginObligation_DATE = P.oble_BeginObligation_DATE
          AND O.Case_IDNO = P.oble_Case_IDNO
          AND O.EventGlobalBeginSeq_NUMB = P.oble_EventGlobalBeginSeq_NUMB
          AND O.ObligationSeq_NUMB = P.oble_ObligationSeq_NUMB
          AND O.OrderSeq_NUMB = P.oble_OrderSeq_NUMB
          AND P.oble_rowvalid = 'Y'
          AND (AmntExptNew_CODE <> AmtExptPrev_CODE
                OR ISNULL(CdExpt_CODE, @Lc_Quote_TEXT) <> @Ac_PaybackType_CODE)
          AND EventGlobalBeginSeq_NUMB <> @An_EventGlobalBeginSeq_NUMB;
      END

     SET @Ls_Sql_TEXT = 'INSERT_OBLE_Y1 3';
     SET @Ls_Sqldata_TEXT = 'EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_Highdate_DATE AS VARCHAR ),'')+ ', ExpectToPay_CODE = ' + ISNULL(@Ac_PaybackType_CODE,'');

     INSERT INTO OBLE_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  MemberMci_IDNO,
                  TypeDebt_CODE,
                  Fips_CODE,
                  FreqPeriodic_CODE,
                  Periodic_AMNT,
                  ExpectToPay_AMNT,
                  ReasonChange_CODE,
                  BeginObligation_DATE,
                  EndObligation_DATE,
                  AccrualLast_DATE,
                  AccrualNext_DATE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  ExpectToPay_CODE)
     SELECT Case_IDNO,
            O.OrderSeq_NUMB,
            O.ObligationSeq_NUMB,
            MemberMci_IDNO,
            TypeDebt_CODE,
            Fips_CODE,
            FreqPeriodic_CODE,
            Periodic_AMNT,
            AmntExptNew_CODE,
            ReasonChange_CODE,
            BeginObligation_DATE,
            EndObligation_DATE,
            AccrualLast_DATE,
            AccrualNext_DATE,
            CheckRecipient_ID,
            CheckRecipient_CODE,
            @An_EventGlobalBeginSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            @Ln_Zero_NUMB AS EventGlobalEndSeq_NUMB,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_Highdate_DATE AS EndValidity_DATE,
            @Ac_PaybackType_CODE AS ExpectToPay_CODE
       FROM OBLE_Y1 O,
            #Prorate_P1 P
      WHERE O.Case_IDNO = @An_Case_IDNO
        AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND O.ObligationSeq_NUMB = P.ObligationSeq_NUMB
        AND P.oble_rowvalid = 'Y'
        AND O.EndValidity_DATE = @Ld_Highdate_DATE
        AND O.BeginObligation_DATE > @Ad_Process_DATE
        AND O.EventGlobalBeginSeq_NUMB <> @An_EventGlobalBeginSeq_NUMB;

     SET @Ls_Sql_TEXT = 'UPDATE_OBLE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_Highdate_DATE AS VARCHAR ),'');

     UPDATE o
        SET EndValidity_DATE = CASE
                                WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                 THEN o.EndValidity_DATE
                                ELSE @Ad_Process_DATE
                               END,
            EventGlobalEndSeq_NUMB = CASE
                                      WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                       THEN o.EventGlobalEndSeq_NUMB
                                      ELSE @An_EventGlobalBeginSeq_NUMB
                                     END,
            ExpectToPay_CODE = CASE
                                WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                 THEN @Ac_PaybackType_CODE
                                ELSE o.ExpectToPay_CODE
                               END,
            ExpectToPay_AMNT = CASE
                                WHEN o.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
                                 THEN P.AmntExptNew_CODE
                                ELSE o.ExpectToPay_AMNT
                               END
       FROM OBLE_Y1 o,
            #Prorate_P1 P
      WHERE o.Case_IDNO = @An_Case_IDNO
        AND o.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND P.oble_rowvalid = 'Y'
        AND o.ObligationSeq_NUMB = P.ObligationSeq_NUMB
        AND o.EndValidity_DATE = @Ld_Highdate_DATE
        AND o.BeginObligation_DATE > @Ad_Process_DATE;

     IF @Ac_ObleUpdated_TEXT = @Lc_No_TEXT
      BEGIN
       SET @Ln_FLAG_NUMB = 1;
       SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';
       SET @Ls_Sqldata_TEXT = 'TransactionCurSup_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Lowdate_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(@Lc_StringZero_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Lowdate_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Li_PaybackProrate1100_NUMB AS VARCHAR ),'');

       INSERT INTO LSUP_Y1
                   (Case_IDNO,
                    OrderSeq_NUMB,
                    ObligationSeq_NUMB,
                    SupportYearMonth_NUMB,
                    TypeWelfare_CODE,
                    TransactionCurSup_AMNT,
                    OweTotCurSup_AMNT,
                    AppTotCurSup_AMNT,
                    MtdCurSupOwed_AMNT,
                    TransactionExptPay_AMNT,
                    OweTotExptPay_AMNT,
                    AppTotExptPay_AMNT,
                    TransactionNaa_AMNT,
                    OweTotNaa_AMNT,
                    AppTotNaa_AMNT,
                    TransactionPaa_AMNT,
                    OweTotPaa_AMNT,
                    AppTotPaa_AMNT,
                    TransactionTaa_AMNT,
                    OweTotTaa_AMNT,
                    AppTotTaa_AMNT,
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
                    TransactionFuture_AMNT,
                    AppTotFuture_AMNT,
                    TransactionNffc_AMNT,
                    OweTotNffc_AMNT,
                    AppTotNffc_AMNT,
                    TransactionNonIvd_AMNT,
                    OweTotNonIvd_AMNT,
                    AppTotNonIvd_AMNT,
                    Batch_DATE,
                    SourceBatch_CODE,
                    Batch_NUMB,
                    SeqReceipt_NUMB,
                    Receipt_DATE,
                    Distribute_DATE,
                    TypeRecord_CODE,
                    EventFunctionalSeq_NUMB,
                    EventGlobalSeq_NUMB,
                    CheckRecipient_ID,
                    CheckRecipient_CODE)
       SELECT L.Case_IDNO,
              L.OrderSeq_NUMB,
              L.ObligationSeq_NUMB,
              SupportYearMonth_NUMB,
              TypeWelfare_CODE,
              @Ln_Zero_NUMB AS TransactionCurSup_AMNT,
              OweTotCurSup_AMNT,
              AppTotCurSup_AMNT,
              MtdCurSupOwed_AMNT,
              CASE
               WHEN AppTotExptPay_AMNT > AmntExptMso_CODE
                THEN AppTotExptPay_AMNT - OweTotExptPay_AMNT
               ELSE AmntExptMso_CODE - OweTotExptPay_AMNT
              END AS TransactionExptPay_AMNT,
              CASE
               WHEN AppTotExptPay_AMNT > AmntExptMso_CODE
                THEN AppTotExptPay_AMNT
               ELSE AmntExptMso_CODE
              END AS OweTotExptPay_AMNT,
              AppTotExptPay_AMNT,
              @Ln_Zero_NUMB AS TransactionNaa_AMNT,
              OweTotNaa_AMNT,
              AppTotNaa_AMNT,
              @Ln_Zero_NUMB AS TransactionPaa_AMNT,
              OweTotPaa_AMNT,
              AppTotPaa_AMNT,
              @Ln_Zero_NUMB AS TransactionTaa_AMNT,
              OweTotTaa_AMNT,
              AppTotTaa_AMNT,
              @Ln_Zero_NUMB AS TransactionCaa_AMNT,
              OweTotCaa_AMNT,
              AppTotCaa_AMNT,
              @Ln_Zero_NUMB AS TransactionUpa_AMNT,
              OweTotUpa_AMNT,
              AppTotUpa_AMNT,
              @Ln_Zero_NUMB AS TransactionUda_AMNT,
              OweTotUda_AMNT,
              AppTotUda_AMNT,
              @Ln_Zero_NUMB AS TransactionIvef_AMNT,
              OweTotIvef_AMNT,
              AppTotIvef_AMNT,
              @Ln_Zero_NUMB AS TransactionMedi_AMNT,
              OweTotMedi_AMNT,
              AppTotMedi_AMNT,
              @Ln_Zero_NUMB AS TransactionFuture_AMNT,
              AppTotFuture_AMNT,
              @Ln_Zero_NUMB AS TransactionNffc_AMNT,
              OweTotNffc_AMNT,
              AppTotNffc_AMNT,
              @Ln_Zero_NUMB AS TransactionNonIvd_AMNT,
              OweTotNonIvd_AMNT,
              AppTotNonIvd_AMNT,
              @Ld_Lowdate_DATE AS Batch_DATE,
              @Lc_Space_TEXT AS SourceBatch_CODE,
              @Ln_Zero_NUMB AS Batch_NUMB,
              @Lc_StringZero_TEXT AS SeqReceipt_NUMB,
              @Ld_Lowdate_DATE AS Receipt_DATE,
              @Ad_Process_DATE AS Distribute_DATE,
              @Lc_TypeRecordOriginal_CODE AS TypeRecord_CODE,
              @Ln_Zero_NUMB AS EventFunctionalSeq_NUMB,
              @Li_PaybackProrate1100_NUMB AS EventGlobalSeq_NUMB,
              CheckRecipient_ID,
              CheckRecipient_CODE
         FROM LSUP_Y1 L,
              #Prorate_P1 P
        WHERE L.Case_IDNO = P.Lsup_Case_IDNO
          AND L.EventGlobalSeq_NUMB = P.lsup_EventGlobalSeq_NUMB
          AND L.ObligationSeq_NUMB = P.lsup_ObligationSeq_NUMB
          AND L.OrderSeq_NUMB = P.lsup_OrderSeq_NUMB
          AND L.SupportYearMonth_NUMB = P.lsup_SupportYearMonth_NUMB
          AND P.Lsup_rowvalid = 'Y'
          AND AmntExptMso_CODE <> OweTotExptPay_AMNT;
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';
       SET @Ls_Sqldata_TEXT = 'TransactionCurSup_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Lowdate_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(@Lc_StringZero_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Lowdate_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_PaybackProrate1100_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

       INSERT INTO LSUP_Y1
                   (Case_IDNO,
                    OrderSeq_NUMB,
                    ObligationSeq_NUMB,
                    SupportYearMonth_NUMB,
                    TypeWelfare_CODE,
                    TransactionCurSup_AMNT,
                    OweTotCurSup_AMNT,
                    AppTotCurSup_AMNT,
                    MtdCurSupOwed_AMNT,
                    TransactionExptPay_AMNT,
                    OweTotExptPay_AMNT,
                    AppTotExptPay_AMNT,
                    TransactionNaa_AMNT,
                    OweTotNaa_AMNT,
                    AppTotNaa_AMNT,
                    TransactionPaa_AMNT,
                    OweTotPaa_AMNT,
                    AppTotPaa_AMNT,
                    TransactionTaa_AMNT,
                    OweTotTaa_AMNT,
                    AppTotTaa_AMNT,
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
                    TransactionFuture_AMNT,
                    AppTotFuture_AMNT,
                    TransactionNffc_AMNT,
                    OweTotNffc_AMNT,
                    AppTotNffc_AMNT,
                    TransactionNonIvd_AMNT,
                    OweTotNonIvd_AMNT,
                    AppTotNonIvd_AMNT,
                    Batch_DATE,
                    SourceBatch_CODE,
                    Batch_NUMB,
                    SeqReceipt_NUMB,
                    Receipt_DATE,
                    Distribute_DATE,
                    TypeRecord_CODE,
                    EventFunctionalSeq_NUMB,
                    EventGlobalSeq_NUMB,
                    CheckRecipient_ID,
                    CheckRecipient_CODE)
       SELECT Case_IDNO,
              L.OrderSeq_NUMB,
              L.ObligationSeq_NUMB,
              SupportYearMonth_NUMB,
              TypeWelfare_CODE,
              @Ln_Zero_NUMB AS TransactionCurSup_AMNT,
              OweTotCurSup_AMNT,
              AppTotCurSup_AMNT,
              MtdCurSupOwed_AMNT,
              CASE
               WHEN AppTotExptPay_AMNT > AmntExptMso_CODE
                THEN AppTotExptPay_AMNT - OweTotExptPay_AMNT
               ELSE AmntExptMso_CODE - OweTotExptPay_AMNT
              END AS TransactionExptPay_AMNT,
              CASE
               WHEN AppTotExptPay_AMNT > AmntExptMso_CODE
                THEN AppTotExptPay_AMNT
               ELSE AmntExptMso_CODE
              END AS OweTotExptPay_AMNT,
              AppTotExptPay_AMNT,
              @Ln_Zero_NUMB AS TransactionNaa_AMNT,
              OweTotNaa_AMNT,
              AppTotNaa_AMNT,
              @Ln_Zero_NUMB AS TransactionPaa_AMNT,
              OweTotPaa_AMNT,
              AppTotPaa_AMNT,
              @Ln_Zero_NUMB AS TransactionTaa_AMNT,
              OweTotTaa_AMNT,
              AppTotTaa_AMNT,
              @Ln_Zero_NUMB AS TransactionCaa_AMNT,
              OweTotCaa_AMNT,
              AppTotCaa_AMNT,
              @Ln_Zero_NUMB AS TransactionUpa_AMNT,
              OweTotUpa_AMNT,
              AppTotUpa_AMNT,
              @Ln_Zero_NUMB AS TransactionUda_AMNT,
              OweTotUda_AMNT,
              AppTotUda_AMNT,
              @Ln_Zero_NUMB AS TransactionIvef_AMNT,
              OweTotIvef_AMNT,
              AppTotIvef_AMNT,
              @Ln_Zero_NUMB AS TransactionMedi_AMNT,
              OweTotMedi_AMNT,
              AppTotMedi_AMNT,
              @Ln_Zero_NUMB AS TransactionFuture_AMNT,
              AppTotFuture_AMNT,
              @Ln_Zero_NUMB AS TransactionNffc_AMNT,
              OweTotNffc_AMNT,
              AppTotNffc_AMNT,
              @Ln_Zero_NUMB AS TransactionNonIvd_AMNT,
              OweTotNonIvd_AMNT,
              AppTotNonIvd_AMNT,
              @Ld_Lowdate_DATE AS Batch_DATE,
              @Lc_Space_TEXT AS SourceBatch_CODE,
              @Ln_Zero_NUMB AS Batch_NUMB,
              @Lc_StringZero_TEXT AS SeqReceipt_NUMB,
              @Ld_Lowdate_DATE AS Receipt_DATE,
              @Ad_Process_DATE AS Distribute_DATE,
              @Lc_TypeRecordOriginal_CODE AS TypeRecord_CODE,
              @Li_PaybackProrate1100_NUMB AS EventFunctionalSeq_NUMB,
              @An_EventGlobalBeginSeq_NUMB AS EventGlobalSeq_NUMB,
              CheckRecipient_ID,
              CheckRecipient_CODE
         FROM LSUP_Y1 L,
              #Prorate_P1 P
        WHERE L.Case_IDNO = P.lsup_Case_IDNO
          AND L.EventGlobalSeq_NUMB = P.lsup_EventGlobalSeq_NUMB
          AND L.ObligationSeq_NUMB = P.lsup_ObligationSeq_NUMB
          AND L.OrderSeq_NUMB = P.lsup_OrderSeq_NUMB
          AND L.SupportYearMonth_NUMB = P.lsup_SupportYearMonth_NUMB
          AND lsup_rowvalid = 'Y'
          AND EventGlobalSeq_NUMB < @An_EventGlobalBeginSeq_NUMB
          AND AmntExptMso_CODE <> OweTotExptPay_AMNT;

       SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';
       SET @Ls_Sqldata_TEXT = '';

       UPDATE L
          SET TransactionExptPay_AMNT = CASE
                                         WHEN l.AppTotExptPay_AMNT > AmntExptMso_CODE
                                          THEN l.AppTotExptPay_AMNT - l.OweTotExptPay_AMNT
                                         ELSE AmntExptMso_CODE - l.OweTotExptPay_AMNT
                                        END,
              OweTotExptPay_AMNT = CASE
                                    WHEN l.AppTotExptPay_AMNT > AmntExptMso_CODE
                                     THEN l.AppTotExptPay_AMNT
                                    ELSE AmntExptMso_CODE
                                   END
         FROM LSUP_Y1 L,
              #Prorate_P1 P
        WHERE L.Case_IDNO = P.lsup_Case_IDNO
          AND L.EventGlobalSeq_NUMB = P.lsup_EventGlobalSeq_NUMB
          AND L.ObligationSeq_NUMB = P.lsup_ObligationSeq_NUMB
          AND L.OrderSeq_NUMB = P.lsup_OrderSeq_NUMB
          AND L.SupportYearMonth_NUMB = P.lsup_SupportYearMonth_NUMB
          AND lsup_rowvalid = 'Y'
          AND l.EventGlobalSeq_NUMB >= @An_EventGlobalBeginSeq_NUMB
          AND AmntExptMso_CODE <> l.OweTotExptPay_AMNT;

       IF OBJECT_ID(N'TEMPDB.dbo.#Prorate_P1') IS NOT NULL
        BEGIN
         DROP TABLE #Prorate_P1;
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   IF OBJECT_ID('tempdb..#Prorate_P1') IS NOT NULL
    BEGIN
     DROP TABLE #Prorate_P1;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailure_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_Errormessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
