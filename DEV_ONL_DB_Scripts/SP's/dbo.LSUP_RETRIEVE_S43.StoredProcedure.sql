/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S43] (
     @An_Case_IDNO			NUMERIC(6,0),
     @An_OrderSeq_NUMB		NUMERIC(2,0)
 )                  
AS
/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S43
 *     DESCRIPTION       : Retrieve the log support and arrear amount detials from LSUP_Y1 for insert into PLSUP_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SELECT a.Case_IDNO , 
			 a.OrderSeq_NUMB , 
			 a.ObligationSeq_NUMB, 
			 a.SupportYearMonth_NUMB , 
			 a.TypeWelfare_CODE , 
			 a.TransactionCurSup_AMNT , 
			 a.OweTotCurSup_AMNT , 
			 a.AppTotCurSup_AMNT , 
			 a.MtdCurSupOwed_AMNT , 
			 a.TransactionExptPay_AMNT , 
			 a.OweTotExptPay_AMNT , 
			 a.AppTotExptPay_AMNT , 
			 a.TransactionNaa_AMNT , 
			 a.OweTotNaa_AMNT , 
			 a.AppTotNaa_AMNT , 
			 a.TransactionPaa_AMNT , 
			 a.OweTotPaa_AMNT , 
			 a.AppTotPaa_AMNT , 
			 a.TransactionTaa_AMNT , 
			 a.OweTotTaa_AMNT , 
			 a.AppTotTaa_AMNT , 
			 a.TransactionCaa_AMNT , 
			 a.OweTotCaa_AMNT , 
			 a.AppTotCaa_AMNT , 
			 a.TransactionUpa_AMNT , 
			 a.OweTotUpa_AMNT , 
			 a.AppTotUpa_AMNT , 
			 a.TransactionUda_AMNT , 
			 a.OweTotUda_AMNT , 
			 a.AppTotUda_AMNT , 
			 a.TransactionIvef_AMNT , 
			 a.OweTotIvef_AMNT , 
			 a.AppTotIvef_AMNT , 
			 a.TransactionMedi_AMNT , 
			 a.OweTotMedi_AMNT , 
			 a.AppTotMedi_AMNT , 
			 a.TransactionFuture_AMNT , 
			 a.AppTotFuture_AMNT , 
			 a.TransactionNffc_AMNT , 
			 a.OweTotNffc_AMNT , 
			 a.AppTotNffc_AMNT , 
			 a.TransactionNonIvd_AMNT , 
			 a.OweTotNonIvd_AMNT , 
			 a.AppTotNonIvd_AMNT , 
			 a.CheckRecipient_ID , 
			 a.CheckRecipient_CODE , 
			 a.Batch_DATE , 
			 a.SourceBatch_CODE , 
			 a.Batch_NUMB , 
			 a.SeqReceipt_NUMB , 
			 a.Receipt_DATE , 
			 a.Distribute_DATE , 
			 a.TypeRecord_CODE , 
			 a.EventFunctionalSeq_NUMB , 
			 a.EventGlobalSeq_NUMB 
        FROM LSUP_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.EventGlobalSeq_NUMB = 
						 (
							SELECT MAX(b.EventGlobalSeq_NUMB) 
							  FROM LSUP_Y1  b
							 WHERE b.Case_IDNO = a.Case_IDNO 
							   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
							   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
							   AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB
						 );

END;-- End of LSUP_RETRIEVE_S43


GO
