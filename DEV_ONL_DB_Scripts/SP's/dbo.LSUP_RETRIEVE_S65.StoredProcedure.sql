/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S65] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @An_OrderSeq_NUMB          NUMERIC(2, 0),
 @An_ObligationSeq_NUMB     NUMERIC(2, 0),
 @An_SupportYearMonth_NUMB  NUMERIC(6, 0),
 @Ac_TypeDebt_CODE          CHAR(2),
 @An_TotAppCurrentHold_AMNT NUMERIC(15, 2) OUTPUT,
 @An_TotAppFuturesHold_AMNT NUMERIC(15, 2) OUTPUT,
 @An_TotAppArrearsHold_AMNT NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S65
  *     DESCRIPTION       : Retrieves sum of current support, futures support amount for the given case id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 15-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE                  DATE = '12/31/9999',
          @Lc_Yes_INDC                   CHAR(1) = 'Y',
          @Lc_TypeRecordO_CODE           CHAR(1) = 'O',
          @Li_FutureHoldRelease1825_NUMB INT = 1825;

  SELECT @An_TotAppCurrentHold_AMNT = SUM(a.TransactionCurSup_AMNT),
         @An_TotAppFuturesHold_AMNT = SUM(a.TransactionFuture_AMNT),
         @An_TotAppArrearsHold_AMNT = SUM(a.TransactionNaa_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT + a.TransactionCaa_AMNT + a.TransactionUda_AMNT + a.TransactionUpa_AMNT + a.TransactionIvef_AMNT + a.TransactionMedi_AMNT + a.TransactionNffc_AMNT + a.TransactionNonIvd_AMNT - a.TransactionCurSup_AMNT)
    FROM LSUP_Y1 a
   WHERE A.Case_IDNO = @An_Case_IDNO
     AND A.OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND A.ObligationSeq_NUMB IN (SELECT DISTINCT ObligationSeq_NUMB
                                    FROM OBLE_Y1 o
                                   WHERE o.Case_IDNO = @An_Case_IDNO
                                     AND o.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE, o.TypeDebt_CODE)
                                     AND o.ObligationSeq_NUMB = ISNULL(@An_ObligationSeq_NUMB, o.ObligationSeq_NUMB)
                                     AND o.EndValidity_DATE = @Ld_High_DATE)
     AND a.EventFunctionalSeq_NUMB = @Li_FutureHoldRelease1825_NUMB
     AND a.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
     AND NOT EXISTS (SELECT 1
                       FROM RCTH_Y1 z
                      WHERE z.Batch_DATE = a.Batch_DATE
                        AND z.Batch_NUMB = a.Batch_NUMB
                        AND z.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                        AND z.SourceBatch_CODE = a.SourceBatch_CODE
                        AND z.BackOut_INDC = @Lc_Yes_INDC
                        AND z.EndValidity_DATE = @Ld_High_DATE)
     AND a.TypeRecord_CODE = @Lc_TypeRecordO_CODE;
 END; --End of LSUP_RETRIEVE_S65


GO
