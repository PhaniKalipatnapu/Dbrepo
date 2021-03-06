/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S66]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE
 	[dbo].[LSUP_RETRIEVE_S66]
 		(
     		@An_Case_IDNO		 NUMERIC(6,0)
     	)
AS

/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S66
 *     DESCRIPTION       : Retrieves arrear amount, arrears payback amount, type debt code, order issued date, effective date for the given case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-SEP-2011
 *     MODIFIED BY		 : 
 *     MODIFIED ON		 : 
 *     VERSION NO        : 1
 */		

    BEGIN


      DECLARE
         @Ld_High_DATE		DATE = '12/31/9999',
         @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

        SELECT a.OrderIssued_DATE ,
         a.OrderEffective_DATE ,
         x.TypeDebt_CODE ,
         x.Frequency_CODE ,
         x.Periodic_AMNT ,
         x.Arrears_AMNT,
		 --13187 - SLOG - Modify SLOG Account Statement to Include Payment on Arrears 20120123 - REMOVED
		 --13773 - SLOG - SLOG screen the Arrears Payback box is not populated correctly - START
		  x.ArrearsPayback_AMNT As ExpectToPay_AMNT 
		 --13773 - SLOG - SLOG screen the Arrears Payback box is not populated correctly - END
	  FROM SORD_Y1   a,
         (
            SELECT a.Case_IDNO,
               --13654 - SLOG - Slog Account Statement does not include cumulative total for all dependants on a case - START
			   SUM(a.ExpectToPay_AMNT) As ArrearsPayback_AMNT,
			   --13654 - SLOG - Slog Account Statement does not include cumulative total for all dependants on a case - END
			   a.TypeDebt_CODE,
               SUM(
                             CASE
                                WHEN a.EndObligation_DATE >  @Ld_Current_DATE THEN a.Periodic_AMNT
                                ELSE 0
                             END) AS Periodic_AMNT,
               a.FreqPeriodic_CODE AS Frequency_CODE,
               SUM((
                  b.OweTotNaa_AMNT
                   +
                  b.OweTotTaa_AMNT
                   +
                  b.OweTotPaa_AMNT
                   +
                  b.OweTotCaa_AMNT
                   +
                  b.OweTotUda_AMNT
                   +
                  b.OweTotUpa_AMNT
                   +
                  b.OweTotIvef_AMNT
                   +
                  b.OweTotNffc_AMNT
                   +
                  b.OweTotNonIvd_AMNT
                   +
                  b.OweTotMedi_AMNT) - (
                  b.AppTotNaa_AMNT
                   +
                  b.AppTotTaa_AMNT
                   +
                  b.AppTotPaa_AMNT
                   +
                  b.AppTotCaa_AMNT
                   +
                  b.AppTotUda_AMNT
                   +
                  b.AppTotUpa_AMNT
                   +
                  b.AppTotIvef_AMNT
                   +
                  b.AppTotNffc_AMNT
                   +
                  b.AppTotNonIvd_AMNT
                   +
                  b.AppTotMedi_AMNT
                   +
                  b.AppTotFuture_AMNT)) AS Arrears_AMNT
				  --13654 - SLOG - Slog Account Statement does not include cumulative total for all dependants on a case - REMOVED
            FROM OBLE_Y1   a
            JOIN LSUP_Y1   b
            ON
            b.Case_IDNO = a.Case_IDNO 
            AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
            AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
            WHERE
               a.Case_IDNO = @An_Case_IDNO 
            AND a.EndValidity_DATE = @Ld_High_DATE 
            AND b.SupportYearMonth_NUMB =
               (
                  SELECT MAX(c.SupportYearMonth_NUMB)
                  FROM LSUP_Y1   c
                  WHERE
                     c.Case_IDNO = b.Case_IDNO 
                  AND c.OrderSeq_NUMB = b.OrderSeq_NUMB 
                  AND c.ObligationSeq_NUMB = b.ObligationSeq_NUMB
               ) 
            AND b.EventGlobalSeq_NUMB =
               (
                  SELECT MAX(d.EventGlobalSeq_NUMB)
                  FROM LSUP_Y1   d
                  WHERE
                     d.Case_IDNO = b.Case_IDNO 
                  AND d.OrderSeq_NUMB = b.OrderSeq_NUMB 
                  AND d.ObligationSeq_NUMB = b.ObligationSeq_NUMB 
                  AND d.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB
               ) 
            AND a.EndObligation_DATE =
               (
              SELECT MAX(b.EndObligation_DATE)
                  FROM OBLE_Y1   b
                  WHERE
                     b.Case_IDNO = a.Case_IDNO 
                  AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
                  AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
                  AND b.BeginObligation_DATE <= @Ld_Current_DATE 
                  AND b.EndValidity_DATE = @Ld_High_DATE
               )
            GROUP BY
               a.Case_IDNO,
               a.TypeDebt_CODE,
               a.FreqPeriodic_CODE
			   --13654 - SLOG - Slog Account Statement does not include cumulative total for all dependants on a case - REMOVED
         )  AS x
      WHERE a.Case_IDNO = x.Case_IDNO 
      AND a.EndValidity_DATE = @Ld_High_DATE;


END; --End of LSUP_RETRIEVE_S66


GO
