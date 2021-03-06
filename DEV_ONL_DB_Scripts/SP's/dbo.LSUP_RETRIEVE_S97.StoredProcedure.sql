/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S97]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S97](
 @An_Case_IDNO                 NUMERIC(6),
 @An_PayorMCI_IDNO             NUMERIC(10),
 @An_SupportYearMonth_NUMB     NUMERIC(6),
 @Ad_FirstPay_DATE             DATE           OUTPUT,
 @Ad_LastPay_DATE              DATE           OUTPUT,
 @An_CurSupToPay_AMNT          NUMERIC(11, 2) OUTPUT,
 @An_ExpectedPayOnArrears_AMNT NUMERIC(11, 2) OUTPUT,
 @An_Arrears_AMNT              NUMERIC(11, 2) OUTPUT,
 @An_Futures_AMNT              NUMERIC(11, 2) OUTPUT,
 @An_HeldReceipt_AMNT          NUMERIC(22, 2) OUTPUT,
 @An_DisbHold_AMNT             NUMERIC(11, 2) OUTPUT,
 @An_MonthToDate_AMNT          NUMERIC(11, 2) OUTPUT,
 @An_YearToDate_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_LifeToDateOwed_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_LifeToDatePaid_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_TotNonCashCredits_AMNT    NUMERIC(11, 2) OUTPUT
 )
AS
 /*
  *    PROCEDURE NAME   : LSUP_RETRIEVE_S97
  *    DESCRIPTION      : This Procedure is used to populate data for 'CFIN' pop-up screen .
                          This CFIN  pop-up screen is a financial summary of the IV-D case. In the upper portion of
                          the screen the month, year and total to date paid, total to date owed, total direct pay credits 
                          issued and total arrears are displayed. This part of the screen also displays the date of the
                          first and last payments for the case. The middle portion of the screen displays the current 
                          support due for the month, the expected pay amount on the arrears obligation and any amount held for
                          futures. The last line of the screen displays any held receipts and held disbursements.
  *    DEVELOPED BY     : IMP Team
  *    DEVELOPED ON     : 30/11/2011
  *    MODIFIED BY      : 
  *    MODIFIED ON      : 
  *    VERSION NO       : 1
  */
 BEGIN
  SELECT @Ad_FirstPay_DATE		       = NULL,
         @Ad_LastPay_DATE		       = NULL,
         @An_Arrears_AMNT		       = NULL,
         @An_CurSupToPay_AMNT	   = NULL,
         @An_ExpectedPayOnArrears_AMNT = NULL,
         @An_Futures_AMNT		       = NULL,
         @An_DisbHold_AMNT	   = NULL,
         @An_HeldReceipt_AMNT		   = NULL,
         @An_LifeToDateOwed_AMNT	   = NULL,
         @An_LifeToDatePaid_AMNT	   = NULL,
         @An_MonthToDate_AMNT		   = NULL,
         @An_TotNonCashCredits_AMNT	   = NULL,
         @An_YearToDate_AMNT		   = NULL;

  DECLARE @Li_ManuallyDistributeReceipt1810_NUMB INT       = 1810,
          @Li_ReceiptDistributed1820_NUMB        INT       = 1820,
          @Li_One_NUMB                           INT       =  1,
          @Li_Zero_AMNT                          SMALLINT  =  0,
          @Lc_Yes_INDC                           CHAR(1)   = 'Y',
          @Lc_TypeRecordO_CODE                   CHAR(1)   = 'O',
          @Lc_StatusReceiptHeld_CODE             CHAR(1)   = 'H',
          @Lc_TypePostingCase_CODE               CHAR(1)   = 'C',
          @Lc_TypePostingPayor_CODE              CHAR(1)   = 'P',
          @Lc_TypeHoldP_CODE                     CHAR(1)   = 'P',
          @Lc_ReasonStatusSnfx_CODE              CHAR(6)   = 'SNFX',
          @Lc_Month_TEXT                         CHAR(8)   = 'MONTH',
          @Lc_Year_TEXT                          CHAR(8)   = 'YEAR',
          @Ld_High_DATE                          DATE	   = '12/31/9999',
          @Ld_Low_DATE                           DATE	   = '01/01/0001';
          
  DECLARE @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  WITH rcth_tab
       AS (SELECT ISNULL(SUM(R.ToDistribute_AMNT), @Li_Zero_AMNT) AS HeldReceipt_AMNT,
                  ISNULL(SUM(CASE
                              WHEN R.ReasonStatus_CODE = @Lc_ReasonStatusSnfx_CODE
                               THEN R.ToDistribute_AMNT
                              ELSE 0
                             END), @Li_Zero_AMNT) AS Futures_AMNT
             FROM RCTH_Y1 R
            WHERE R.PayorMCI_IDNO = @An_PayorMCI_IDNO
              AND (R.TypePosting_CODE = @Lc_TypePostingPayor_CODE
                    OR (R.TypePosting_CODE = @Lc_TypePostingCase_CODE
                        AND R.Case_IDNO = @An_Case_IDNO))
              AND R.Distribute_DATE = @Ld_Low_DATE
              AND R.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
              AND R.EndValidity_DATE = @Ld_High_DATE),
       dhld_tab
       AS (SELECT SUM(ISNULL(DH.Transaction_AMNT, @Li_Zero_AMNT)) AS HeldDisbursement_AMNT
             FROM DHLD_Y1 DH
            WHERE DH.Case_IDNO = @An_Case_IDNO
              AND DH.Status_CODE = @Lc_StatusReceiptHeld_CODE
              AND DH.TypeHold_CODE = @Lc_TypeHoldP_CODE
              AND DH.EndValidity_DATE = @Ld_High_DATE),
       lsup_tab
       AS (SELECT LSU.Case_IDNO,
				  LSU.OrderSeq_NUMB,
				  LSU.ObligationSeq_NUMB,
				  LSU.SupportYearMonth_NUMB,
				  LSU.TypeWelfare_CODE,
				  LSU.TransactionCurSup_AMNT,
				  LSU.OweTotCurSup_AMNT,
				  LSU.AppTotCurSup_AMNT,
				  LSU.MtdCurSupOwed_AMNT,
				  LSU.TransactionExptPay_AMNT,
				  LSU.OweTotExptPay_AMNT,
				  LSU.AppTotExptPay_AMNT,
				  LSU.TransactionNaa_AMNT,
				  LSU.OweTotNaa_AMNT,
				  LSU.AppTotNaa_AMNT,
				  LSU.TransactionPaa_AMNT,
				  LSU.OweTotPaa_AMNT,
				  LSU.AppTotPaa_AMNT,
				  LSU.TransactionTaa_AMNT,
				  LSU.OweTotTaa_AMNT,
				  LSU.AppTotTaa_AMNT,
				  LSU.TransactionCaa_AMNT,
				  LSU.OweTotCaa_AMNT,
				  LSU.AppTotCaa_AMNT,
				  LSU.TransactionUpa_AMNT,
				  LSU.OweTotUpa_AMNT,
				  LSU.AppTotUpa_AMNT,
				  LSU.TransactionUda_AMNT,
				  LSU.OweTotUda_AMNT,
				  LSU.AppTotUda_AMNT,
				  LSU.TransactionIvef_AMNT,
				  LSU.OweTotIvef_AMNT,
				  LSU.AppTotIvef_AMNT,
				  LSU.TransactionMedi_AMNT,
				  LSU.OweTotMedi_AMNT,
				  LSU.AppTotMedi_AMNT,
				  LSU.TransactionNffc_AMNT,
				  LSU.OweTotNffc_AMNT,
				  LSU.AppTotNffc_AMNT,
				  LSU.TransactionNonIvd_AMNT,
				  LSU.OweTotNonIvd_AMNT,
				  LSU.AppTotNonIvd_AMNT,
				  LSU.Batch_DATE,
				  LSU.SourceBatch_CODE,
				  LSU.Batch_NUMB,
				  LSU.SeqReceipt_NUMB,
				  LSU.Receipt_DATE,
				  LSU.Distribute_DATE,
				  LSU.TypeRecord_CODE,
				  LSU.EventFunctionalSeq_NUMB,
				  LSU.EventGlobalSeq_NUMB,
				  LSU.TransactionFuture_AMNT,
				  LSU.AppTotFuture_AMNT,
				  LSU.CheckRecipient_ID,
				  LSU.CheckRecipient_CODE,
                  MIN(Pay_DATE) OVER() FirstPay_DATE,
                  MAX(Pay_DATE) OVER() LastPay_DATE,
                  ROW_NUMBER() OVER(PARTITION BY LSU.Case_IDNO, LSU.OrderSeq_NUMB, LSU.ObligationSeq_NUMB ORDER BY LSU.SupportYearMonth_NUMB DESC, LSU.EventGlobalSeq_NUMB DESC) AS Row_NUMB
             FROM (SELECT	LS1.Case_IDNO,
							LS1.OrderSeq_NUMB,
							LS1.ObligationSeq_NUMB,
							LS1.SupportYearMonth_NUMB,
							LS1.TypeWelfare_CODE,
							LS1.TransactionCurSup_AMNT,
							LS1.OweTotCurSup_AMNT,
							LS1.AppTotCurSup_AMNT,
							LS1.MtdCurSupOwed_AMNT,
							LS1.TransactionExptPay_AMNT,
							LS1.OweTotExptPay_AMNT,
							LS1.AppTotExptPay_AMNT,
							LS1.TransactionNaa_AMNT,
							LS1.OweTotNaa_AMNT,
							LS1.AppTotNaa_AMNT,
							LS1.TransactionPaa_AMNT,
							LS1.OweTotPaa_AMNT,
							LS1.AppTotPaa_AMNT,
							LS1.TransactionTaa_AMNT,
							LS1.OweTotTaa_AMNT,
							LS1.AppTotTaa_AMNT,
							LS1.TransactionCaa_AMNT,
							LS1.OweTotCaa_AMNT,
							LS1.AppTotCaa_AMNT,
							LS1.TransactionUpa_AMNT,
							LS1.OweTotUpa_AMNT,
							LS1.AppTotUpa_AMNT,
							LS1.TransactionUda_AMNT,
							LS1.OweTotUda_AMNT,
							LS1.AppTotUda_AMNT,
							LS1.TransactionIvef_AMNT,
							LS1.OweTotIvef_AMNT,
							LS1.AppTotIvef_AMNT,
							LS1.TransactionMedi_AMNT,
							LS1.OweTotMedi_AMNT,
							LS1.AppTotMedi_AMNT,
							LS1.TransactionNffc_AMNT,
							LS1.OweTotNffc_AMNT,
							LS1.AppTotNffc_AMNT,
							LS1.TransactionNonIvd_AMNT,
							LS1.OweTotNonIvd_AMNT,
							LS1.AppTotNonIvd_AMNT,
							LS1.Batch_DATE,
							LS1.SourceBatch_CODE,
							LS1.Batch_NUMB,
							LS1.SeqReceipt_NUMB,
							LS1.Receipt_DATE,
							LS1.Distribute_DATE,
							LS1.TypeRecord_CODE,
							LS1.EventFunctionalSeq_NUMB,
							LS1.EventGlobalSeq_NUMB,
							LS1.TransactionFuture_AMNT,
							LS1.AppTotFuture_AMNT,
							LS1.CheckRecipient_ID,
							LS1.CheckRecipient_CODE,
                          CASE
                           WHEN (LS1.Batch_DATE <> @Ld_Low_DATE
                                 AND LS1.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB)
                                 AND LS1.TypeRecord_CODE = @Lc_TypeRecordO_CODE
                                 AND NOT EXISTS (SELECT 1
                                                   FROM RCTH_Y1 b
                                                  WHERE b.Batch_DATE = LS1.Batch_DATE
                                                    AND b.SourceBatch_CODE = LS1.SourceBatch_CODE
                                                    AND b.Batch_NUMB = LS1.Batch_NUMB
                                                    AND b.SeqReceipt_NUMB = LS1.SeqReceipt_NUMB
                                                    AND b.EndValidity_DATE = @Ld_High_DATE
                                                    AND b.BackOut_INDC = @Lc_Yes_INDC))
                            THEN LS1.Receipt_DATE
                          END Pay_DATE
                     FROM LSUP_Y1 LS1
                    WHERE LS1.Case_IDNO = @An_Case_IDNO) LSU
            WHERE LSU.SupportYearMonth_NUMB <= @An_SupportYearMonth_NUMB)
  SELECT @Ad_FirstPay_DATE = LS.FirstPay_DATE,
         @An_LifeToDatePaid_AMNT = LS.LifeToDatePaid_AMNT,
         @An_YearToDate_AMNT =  DBO.BATCH_COMMON$SF_AMT_TO_DATE_PAID_OWED(@An_Case_IDNO, @Ld_Current_DATE, @Lc_Year_TEXT),
         @An_MonthToDate_AMNT = DBO.BATCH_COMMON$SF_AMT_TO_DATE_PAID_OWED(@An_Case_IDNO, @Ld_Current_DATE, @Lc_Month_TEXT),
         @Ad_LastPay_DATE = LS.LastPay_DATE,
         @An_LifeToDateOwed_AMNT = LS.LifeToDateOwed_AMNT,
         @An_HeldReceipt_AMNT = R.HeldReceipt_AMNT,
         @An_DisbHold_AMNT = DH.HeldDisbursement_AMNT,
         @An_TotNonCashCredits_AMNT = DBO.BATCH_COMMON$SF_TOT_NON_CASH_CREDIT(@An_Case_IDNO),
         @An_ExpectedPayOnArrears_AMNT = LS.ExpectedPayOnArrears_AMNT,
         @An_CurSupToPay_AMNT = LS.CurrentSupportDue_AMNT,
         @An_Futures_AMNT = R.Futures_AMNT,
         @An_Arrears_AMNT = LS.Arrears_AMNT
    FROM (SELECT MIN(LS.FirstPay_DATE) FirstPay_DATE,
                 SUM(LS.AppTotTaa_AMNT + LS.AppTotPaa_AMNT + LS.AppTotCaa_AMNT + LS.AppTotUpa_AMNT + LS.AppTotUda_AMNT + LS.AppTotIvef_AMNT + LS.AppTotMedi_AMNT + LS.AppTotNffc_AMNT + LS.AppTotNonIvd_AMNT + LS.AppTotFuture_AMNT + LS.AppTotNaa_AMNT) AS LifeToDatePaid_AMNT,
                 MAX(LS.LastPay_DATE) LastPay_DATE,
                 SUM(LS.OweTotTaa_AMNT + LS.OweTotPaa_AMNT + LS.OweTotCaa_AMNT + LS.OweTotUpa_AMNT + LS.OweTotUda_AMNT + LS.OweTotIvef_AMNT + LS.OweTotMedi_AMNT + LS.OweTotNffc_AMNT + LS.OweTotNonIvd_AMNT + LS.OweTotNaa_AMNT) AS LifeToDateOwed_AMNT,
                 SUM(LS.OweTotExptPay_AMNT - LS.AppTotExptPay_AMNT) ExpectedPayOnArrears_AMNT,
                 SUM(CASE LS.SupportYearMonth_NUMB
                      WHEN @An_SupportYearMonth_NUMB
                       THEN LS.MtdCurSupOwed_AMNT
                      ELSE 0
                     END) CurrentSupportDue_AMNT,
                 SUM(LS.OweTotNaa_AMNT - LS.AppTotNaa_AMNT + LS.OweTotPaa_AMNT - LS.AppTotPaa_AMNT + LS.OweTotTaa_AMNT - LS.AppTotTaa_AMNT + LS.OweTotCaa_AMNT - LS.AppTotCaa_AMNT + LS.OweTotUpa_AMNT - LS.AppTotUpa_AMNT + LS.OweTotUda_AMNT - LS.AppTotUda_AMNT + LS.OweTotIvef_AMNT - LS.AppTotIvef_AMNT + LS.OweTotMedi_AMNT - LS.AppTotMedi_AMNT + LS.OweTotNffc_AMNT - LS.AppTotNffc_AMNT + LS.OweTotNonIvd_AMNT - LS.AppTotNonIvd_AMNT - LS.AppTotFuture_AMNT) AS Arrears_AMNT
            FROM lsup_tab LS
           WHERE LS.Row_NUMB = @Li_One_NUMB) LS
         CROSS JOIN rcth_tab R
         CROSS JOIN dhld_tab DH;
         
 END; --End Of Procedure LSUP_RETRIEVE_S97 


GO
