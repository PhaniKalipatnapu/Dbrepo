/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S20] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S20
  *     DESCRIPTION       : Retrieve Financial Details for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_TypeRecord_CODE             CHAR(1)		= 'O',
          @Li_ReceiptDistributed1820_NUMB INT			= 1820,
          @Li_ReceiptReversed1250_NUMB    INT			= 1250,
          @Li_DirectPayCredit1040_NUMB    INT			= 1040,
          @Li_ArrearAdjustment1030_NUMB   INT			= 1030;
  DECLARE @Ln_YearMonthFrom2Years_NUMB NUMERIC(6)		= CONVERT(NVARCHAR(6), DATEADD(year, -2, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), 112);

  SELECT X.SupportYearMonth_NUMB,
         X.OweTotCurSup_AMNT,
         SUM (X.OweTotCurSup_AMNT) OVER () AS TotalOweTotCurSup_AMNT,
         X.AppTotCurSup_AMNT,
         SUM (X.AppTotCurSup_AMNT) OVER () AS TotalAppTotCurSup_AMNT,
         X.ln_arrears_paid AS TransactionArrearsPaid_AMNT,
         SUM (X.ln_arrears_paid) OVER () AS TotalTransactionArrearsPaid_AMNT,
         X.ln_adjustments AS TransactionAdjustments_AMNT,
         SUM (X.ln_adjustments) OVER () AS TotalTransactionAdjustments_AMNT,
         X.ln_tot_paid AS TransactionPaid_AMNT,
         SUM (X.ln_tot_paid) OVER () AS TotalTransactionPaid_AMNT,
         X.ln_tot_arrears AS TotalArrears_AMNT
    FROM (SELECT B.SupportYearMonth_NUMB,
                 SUM (B.OweTotCurSup_AMNT) AS OweTotCurSup_AMNT,
                 SUM (B.AppTotCurSup_AMNT) AS AppTotCurSup_AMNT,
                 (SELECT SUM (C.TransactionNaa_AMNT + C.TransactionPaa_AMNT + C.TransactionTaa_AMNT + C.TransactionCaa_AMNT + C.TransactionUpa_AMNT + C.TransactionUda_AMNT + C.TransactionIvef_AMNT + C.TransactionNffc_AMNT + C.TransactionNonIvd_AMNT + C.TransactionMedi_AMNT - C.TransactionCurSup_AMNT)
                    FROM LSUP_Y1 C
                   WHERE C.Case_IDNO = @An_Case_IDNO
                     AND C.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB  , @Li_DirectPayCredit1040_NUMB)
                     AND C.TypeRecord_CODE = @Lc_TypeRecord_CODE
                     AND C.SupportYearMonth_NUMB = B.SupportYearMonth_NUMB) AS ln_arrears_paid,
                 (SELECT SUM (C.TransactionNaa_AMNT + C.TransactionPaa_AMNT + C.TransactionTaa_AMNT + C.TransactionCaa_AMNT + C.TransactionUpa_AMNT + C.TransactionUda_AMNT + C.TransactionIvef_AMNT + C.TransactionNffc_AMNT + C.TransactionNonIvd_AMNT + C.TransactionMedi_AMNT - C.TransactionCurSup_AMNT)
                    FROM LSUP_Y1 C
                   WHERE C.Case_IDNO = @An_Case_IDNO
                     AND C.EventFunctionalSeq_NUMB = @Li_ArrearAdjustment1030_NUMB
                     AND C.TypeRecord_CODE = @Lc_TypeRecord_CODE
                     AND C.SupportYearMonth_NUMB = B.SupportYearMonth_NUMB) AS ln_adjustments,
                 (SELECT SUM (C.TransactionNaa_AMNT + C.TransactionPaa_AMNT + C.TransactionTaa_AMNT + C.TransactionCaa_AMNT + C.TransactionUpa_AMNT + C.TransactionUda_AMNT + C.TransactionIvef_AMNT + C.TransactionNffc_AMNT + C.TransactionNonIvd_AMNT + C.TransactionMedi_AMNT)
                    FROM LSUP_Y1 C
                   WHERE C.Case_IDNO = @An_Case_IDNO
                     AND C.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB  , @Li_DirectPayCredit1040_NUMB)
                     AND C.TypeRecord_CODE = @Lc_TypeRecord_CODE
                     AND C.SupportYearMonth_NUMB = B.SupportYearMonth_NUMB) AS ln_tot_paid,
                 SUM ((B.OweTotNaa_AMNT - B.AppTotNaa_AMNT) + (B.OweTotPaa_AMNT - B.AppTotPaa_AMNT) + (B.OweTotTaa_AMNT - B.AppTotTaa_AMNT) + (B.OweTotCaa_AMNT - B.AppTotCaa_AMNT) + (B.OweTotUpa_AMNT - B.AppTotUpa_AMNT) + (B.OweTotUda_AMNT - B.AppTotUda_AMNT) + (B.OweTotIvef_AMNT - B.AppTotIvef_AMNT) + (B.OweTotNffc_AMNT - B.AppTotNffc_AMNT) + (B.OweTotNonIvd_AMNT - B.AppTotNonIvd_AMNT) + (B.OweTotMedi_AMNT - B.AppTotMedi_AMNT)) AS ln_tot_arrears
            FROM CASE_Y1 A
                 JOIN LSUP_Y1 B
                  ON B.Case_IDNO = A.Case_IDNO
                 AND B.SupportYearMonth_NUMB >= @Ln_YearMonthFrom2Years_NUMB
           WHERE A.Case_IDNO = @An_Case_IDNO
             AND B.EventGlobalSeq_NUMB = (SELECT MAX (D.EventGlobalSeq_NUMB)
                                            FROM LSUP_Y1 D
                                           WHERE D.Case_IDNO = B.Case_IDNO
                                             AND D.OrderSeq_NUMB = B.OrderSeq_NUMB
                                             AND D.ObligationSeq_NUMB = B.ObligationSeq_NUMB
                                             AND D.SupportYearMonth_NUMB = B.SupportYearMonth_NUMB)
           GROUP BY B.SupportYearMonth_NUMB) AS X
   ORDER BY X.SupportYearMonth_NUMB DESC;
 END; --End of LSUP_RETRIEVE_S20 

GO
