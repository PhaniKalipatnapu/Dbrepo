/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S69]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE
 	[dbo].[LSUP_RETRIEVE_S69]
 		(
     		@An_Case_IDNO		                    NUMERIC(6,0) 	      ,
     		@An_SupportYearMonthFrom_NUMB           NUMERIC(6,0) 	      ,
     		@An_SupportYearMonthTo_NUMB             NUMERIC(6,0) 	      ,
     		@An_TotArrAdj_AMNT                      NUMERIC(15,2)	OUTPUT,
     		@An_TotDirPayCredit_AMNT                NUMERIC(15,2)	OUTPUT,
     		@An_TotMonthlyDiff_AMNT                 NUMERIC(15,2)	OUTPUT,
     		@An_TotMonthlyPayment_AMNT              NUMERIC(15,2)	OUTPUT,
     		@An_TotMonthToDate_AMNT                 NUMERIC(15,2)	OUTPUT,
     		@An_TotDisburseCp_AMNT                  NUMERIC(15,2)	OUTPUT,
     		@An_TotDisburseAgency_AMNT              NUMERIC(15,2)	OUTPUT,
     		@An_TotEndingBal_AMNT                   NUMERIC(15,2)	OUTPUT
     	)
AS

/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S69
 *     DESCRIPTION       : Retrieves the sum of payments made,direct pay credits,amt_paid_to_custondian/FIPS,amt_paid_to_agency,arrears adjustments for the given case id & support month.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-SEP-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
    BEGIN

   SELECT @An_TotArrAdj_AMNT = NULL,
          @An_TotDirPayCredit_AMNT = NULL,
          @An_TotEndingBal_AMNT = NULL,
          @An_TotMonthlyDiff_AMNT = NULL,
          @An_TotMonthlyPayment_AMNT = NULL,
          @An_TotMonthToDate_AMNT = NULL,
          @An_TotDisburseCp_AMNT = NULL,
          @An_TotDisburseAgency_AMNT = NULL;
   DECLARE
       @Li_Zero_NUMB                    SMALLINT = 0,
       @Li_Conversion9999_NUMB          INT = 9999,
       @Lc_ColumnP_TEXT                 CHAR(1) = 'P',
       @Lc_ColumnC_TEXT                 CHAR(1) = 'C',
       @Lc_ColumnA_TEXT                 CHAR(1) = 'A',
       @Lc_ColumnD_TEXT                 CHAR(1) = 'D',
       @Lc_ColumnR_TEXT                 CHAR(1) = 'R';


      SELECT @An_TotMonthToDate_AMNT = SUM(a.MtdCurSupOwed_AMNT),
         @An_TotMonthlyPayment_AMNT = SUM(dbo.BATCH_COMMON$SF_GET_REPORT_AMOUNTS(
           	 a.Case_IDNO,
           	 a.OrderSeq_NUMB,
           	 a.ObligationSeq_NUMB,
           	 a.SupportYearMonth_NUMB,
           	 @Lc_ColumnP_TEXT)),
         @An_TotDisburseCp_AMNT = SUM(dbo.BATCH_COMMON$SF_GET_REPORT_AMOUNTS(
            a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.SupportYearMonth_NUMB,
            @Lc_ColumnC_TEXT)),
         @An_TotDisburseAgency_AMNT = SUM(dbo.BATCH_COMMON$SF_GET_REPORT_AMOUNTS(
            a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.SupportYearMonth_NUMB,
            @Lc_ColumnA_TEXT)),
         @An_TotDirPayCredit_AMNT = SUM(dbo.BATCH_COMMON$SF_GET_REPORT_AMOUNTS(
            a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.SupportYearMonth_NUMB,
            @Lc_ColumnD_TEXT)),
         @An_TotArrAdj_AMNT = SUM(dbo.BATCH_COMMON$SF_GET_REPORT_AMOUNTS(
            a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.SupportYearMonth_NUMB,
            @Lc_ColumnR_TEXT)),
         @An_TotMonthlyDiff_AMNT = SUM(a.MtdCurSupOwed_AMNT) - SUM(dbo.BATCH_COMMON$SF_GET_REPORT_AMOUNTS(
            a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.SupportYearMonth_NUMB,
            @Lc_ColumnP_TEXT)),
         @An_TotEndingBal_AMNT = SUM(
            (a.OweTotNaa_AMNT - a.AppTotNaa_AMNT)
             +
            (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT)
             +
            (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT)
             +
            (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT)
             +
            (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT)
             +
            (a.OweTotUda_AMNT - a.AppTotUda_AMNT)
             +
            (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT)
             +
            (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT)
             +
            (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT)
             +
            (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT)
             -
            a.AppTotFuture_AMNT)
      FROM LSUP_Y1 a
      WHERE
         a.Case_IDNO = @An_Case_IDNO 
      AND a.SupportYearMonth_NUMB BETWEEN @An_SupportYearMonthFrom_NUMB AND @An_SupportYearMonthTo_NUMB 
      AND a.SupportYearMonth_NUMB >=
         (
            SELECT ISNULL(MIN(b.SupportYearMonth_NUMB), @Li_Zero_NUMB) 
            FROM LSUP_Y1  b
            WHERE
               a.Case_IDNO = b.Case_IDNO 
            AND a.OrderSeq_NUMB = b.OrderSeq_NUMB 
            AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB 
            AND b.EventFunctionalSeq_NUMB = @Li_Conversion9999_NUMB
         ) 
      AND a.EventGlobalSeq_NUMB =
         (
            SELECT MAX(c.EventGlobalSeq_NUMB) 
            FROM LSUP_Y1 c
            WHERE
               c.Case_IDNO = a.Case_IDNO 
            AND c.OrderSeq_NUMB = a.OrderSeq_NUMB 
            AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
            AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB
         );


END;  --End of LSUP_RETRIEVE_S69

GO
