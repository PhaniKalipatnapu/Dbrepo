/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S58]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[LSUP_RETRIEVE_S58] 
		(
			 @An_Case_IDNO             NUMERIC(6, 0),
			 @An_OrderSeq_NUMB         NUMERIC(2, 0),
			 @An_ObligationSeq_NUMB    NUMERIC(2, 0),
			 @An_SupportYearMonth_NUMB NUMERIC(6, 0),
			 @Ac_TypeDebt_CODE         CHAR(2),
			 @Ai_RowFrom_NUMB          INT =1,
			 @Ai_RowTo_NUMB            INT=10
 		)
AS
 /*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S58
 *     DESCRIPTION       : Retrieves sum of other support amount for the given case id & month of the particular year.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-SEP-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_One_NUMB                                          SMALLINT = 1,
          @Ld_High_DATE                                         DATE ='12/31/9999',
          @Lc_Space_TEXT                                        CHAR(1) =' ',
          @Lc_TypeRecordOriginal_CODE                           CHAR(1) = 'O',
          @Ln_SupportYearMonth_NUMB                             NUMERIC(6,0)=999999,
          @Li_DirectPayCredit1040_NUMB                          INT = 1040,
		  @Li_Accrual1050_NUMB                                  INT = 1050,
		  @Li_ReceiptReversed1250_NUMB                          INT = 1250,
		  @Li_ManuallyDistributeReceipt1810_NUMB                INT = 1810,
		  @Li_ReceiptDistributed1820_NUMB                       INT = 1820,
		  @Li_FutureHoldRelease1825_NUMB                        INT = 1825,
		  @Li_InterestAssessed3150_NUMB                         INT = 3150,
		  @Li_AssessedInterestRevoked3180_NUMB                  INT = 3180,
		  @Li_InterestReassessed3190_NUMB                       INT = 3190,
		  @Li_AssessedInterestRevokedArrear500OrLess3200_NUMB	INT = 3200,
		  @Li_AssessedInterestRevokedMinimumPaid3210_NUMB       INT = 3210;

  WITH LSUP_TAB
       AS (SELECT a.SupportYearMonth_NUMB,
                  CASE WHEN  @An_ObligationSeq_NUMB IS NULL
                  THEN @Lc_Space_TEXT 
                  ELSE MAX(ProgramType_CODE)
                  END  AS ProgramType_CODE, 
                  SUM(a.OweTotCurSup_AMNT) AS CurrentSupport_AMNT,
                  SUM(a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) AS Naa_AMNT,
                  SUM(a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) AS Paa_AMNT,
                  SUM(a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) AS Taa_AMNT,
                  SUM(a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) AS Caa_AMNT,
                  SUM(a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) AS Upa_AMNT,
                  SUM(a.OweTotUda_AMNT - a.AppTotUda_AMNT) AS Uda_AMNT,
                  SUM(a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) AS Ivef_AMNT,
                  SUM(a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) AS Nffc_AMNT,
                  SUM(a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) AS NonIvd_AMNT,
                  SUM(a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) AS Medi_AMNT,
                  SUM(a.AppTotCurSup_AMNT) AS CsPaid_AMNT,
                  SUM(ArrearPaid_AMNT) AS ArrearPaid_AMNT,
                  SUM((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) + (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) - a.AppTotFuture_AMNT) AS Total_QNTY,
                  SUM(a.OweTotExptPay_AMNT) AS AotExptPay_AMNT,
                  SUM(MonthlyAdj_AMNT) AS MonthlyAdj_AMNT,
                  SUM(InterestCharges_AMNT) AS InterestCharges_AMNT,
                  COUNT(1) OVER() AS RowCount_NUMB,
                  ROW_NUMBER() OVER( ORDER BY a.SupportYearMonth_NUMB DESC) AS ORD_ROWNUM
             FROM (SELECT a.Case_IDNO,
						  a.OrderSeq_NUMB,
						  a.ObligationSeq_NUMB,
						  a.SupportYearMonth_NUMB,
						  a.TransactionCurSup_AMNT,
						  a.OweTotCurSup_AMNT,
						  a.AppTotCurSup_AMNT,
						  a.OweTotExptPay_AMNT,
						  a.TransactionNaa_AMNT,
						  a.OweTotNaa_AMNT,
						  a.AppTotNaa_AMNT,
						  a.TransactionPaa_AMNT,
						  a.OweTotPaa_AMNT,
						  a.AppTotPaa_AMNT,
						  a.TransactionTaa_AMNT,
						  a.OweTotTaa_AMNT,
						  a.AppTotTaa_AMNT,
						  a.TransactionCaa_AMNT,
						  a.OweTotCaa_AMNT,
						  a.AppTotCaa_AMNT,
						  a.TransactionUpa_AMNT,
						  a.OweTotUpa_AMNT,
						  a.AppTotUpa_AMNT,
						  a.TransactionUda_AMNT,
						  a.OweTotUda_AMNT,
						  a.AppTotUda_AMNT,
						  a.TransactionIvef_AMNT,
						  a.OweTotIvef_AMNT,
						  a.AppTotIvef_AMNT,
						  a.TransactionMedi_AMNT,
						  a.OweTotMedi_AMNT,
						  a.AppTotMedi_AMNT,
						  a.TransactionNffc_AMNT,
						  a.OweTotNffc_AMNT,
						  a.AppTotNffc_AMNT,
						  a.TransactionNonIvd_AMNT,
						  a.OweTotNonIvd_AMNT,
						  a.AppTotNonIvd_AMNT,
						  a.TypeRecord_CODE,
						  a.EventFunctionalSeq_NUMB,
						  a.EventGlobalSeq_NUMB,
						  a.AppTotFuture_AMNT,
						  a.TypeWelfare_code AS ProgramType_CODE,
                          ROW_NUMBER() OVER(PARTITION BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB ORDER BY a.EventGlobalSeq_NUMB DESC) rnm,
                          SUM(CASE
                               WHEN a.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB, @Li_DirectPayCredit1040_NUMB, @Li_FutureHoldRelease1825_NUMB)
                                    AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                THEN (a.TransactionNaa_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT + a.TransactionCaa_AMNT + a.TransactionUpa_AMNT + a.TransactionUda_AMNT + a.TransactionIvef_AMNT + a.TransactionNffc_AMNT + a.TransactionNonIvd_AMNT + a.TransactionMedi_AMNT - a.TransactionCurSup_AMNT)
                               ELSE 0
                              END) OVER(PARTITION BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB) ArrearPaid_AMNT,
                          SUM (CASE
                                WHEN a.EventFunctionalSeq_NUMB NOT IN (@Li_Accrual1050_NUMB, @Li_ReceiptReversed1250_NUMB, @Li_DirectPayCredit1040_NUMB, @Li_ManuallyDistributeReceipt1810_NUMB,
                                                                       @Li_ReceiptDistributed1820_NUMB, @Li_FutureHoldRelease1825_NUMB, @Li_InterestAssessed3150_NUMB, @Li_AssessedInterestRevoked3180_NUMB,
                                                                       @Li_InterestReassessed3190_NUMB, @Li_AssessedInterestRevokedArrear500OrLess3200_NUMB, @Li_AssessedInterestRevokedMinimumPaid3210_NUMB)
                                     AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                 THEN (a.TransactionNaa_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT + a.TransactionCaa_AMNT + a.TransactionUpa_AMNT + a.TransactionUda_AMNT + a.TransactionIvef_AMNT + a.TransactionNffc_AMNT + a.TransactionNonIvd_AMNT + a.TransactionMedi_AMNT - a.TransactionCurSup_AMNT)
                                ELSE 0
                               END) OVER(PARTITION BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB) MonthlyAdj_AMNT,
                          SUM (CASE
                                WHEN a.EventFunctionalSeq_NUMB IN (@Li_InterestAssessed3150_NUMB, @Li_AssessedInterestRevoked3180_NUMB, @Li_InterestReassessed3190_NUMB, @Li_AssessedInterestRevokedArrear500OrLess3200_NUMB, @Li_AssessedInterestRevokedMinimumPaid3210_NUMB)
                                     AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                 THEN (a.TransactionNaa_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT + a.TransactionCaa_AMNT + a.TransactionUpa_AMNT + a.TransactionUda_AMNT + a.TransactionIvef_AMNT + a.TransactionNffc_AMNT + a.TransactionNonIvd_AMNT + a.TransactionMedi_AMNT - a.TransactionCurSup_AMNT)
                                ELSE 0
                               END) OVER(PARTITION BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB) InterestCharges_AMNT
                     FROM LSUP_Y1 a
                    WHERE a.Case_IDNO = @An_Case_IDNO
                      AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                      AND a.ObligationSeq_NUMB IN(SELECT ObligationSeq_NUMB
                                                    FROM OBLE_Y1 o
                                                   WHERE o.Case_IDNO = @An_Case_IDNO
                                                     AND o.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE, o.TypeDebt_CODE)
                                                     AND o.ObligationSeq_NUMB = ISNULL(@An_ObligationSeq_NUMB, o.ObligationSeq_NUMB)
                                                     AND o.EndValidity_DATE = @Ld_High_DATE)
                      AND a.SupportYearMonth_NUMB <= ISNULL(@An_SupportYearMonth_NUMB, @Ln_SupportYearMonth_NUMB)) a
            WHERE a.rnm = @Li_One_NUMB
            GROUP BY SupportYearMonth_NUMB)

  SELECT x.SupportYearMonth_NUMB,
         x.CurrentSupport_AMNT,
         x.CsPaid_AMNT,
         x.Naa_AMNT,
         x.Paa_AMNT,
         x.Taa_AMNT,
         x.Caa_AMNT,
         x.Upa_AMNT,
         x.Uda_AMNT,
         x.Ivef_AMNT,
         x.Medi_AMNT,
         x.Nffc_AMNT,
         x.NonIvd_AMNT,
         x.ArrearPaid_AMNT,
         x.Total_QNTY,
         x.AotExptPay_AMNT,
         x.MonthlyAdj_AMNT,
         x.InterestCharges_AMNT,
         x.ProgramType_CODE,
         x.RowCount_NUMB
    FROM LSUP_TAB x
   WHERE x.ORD_ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END; --End of LSUP_RETRIEVE_S58


GO
