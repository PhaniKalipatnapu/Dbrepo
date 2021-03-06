/****** Object:  StoredProcedure [dbo].[PLSUP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLSUP_INSERT_S1] (
 @An_Case_IDNO               NUMERIC(6, 0),
 @An_OrderSeq_NUMB           NUMERIC(2, 0),
 @An_ObligationSeq_NUMB      NUMERIC(2, 0),
 @An_SupportYearMonth_NUMB   NUMERIC(6, 0),
 @An_EventGlobalSeq_NUMB     NUMERIC(19, 0),
 @Ac_Session_ID              CHAR(30),
 @Ac_TypeWelfare_CODE        CHAR(1),
 @An_TransactionCurSup_AMNT  NUMERIC(11, 2),
 @An_OweTotCurSup_AMNT       NUMERIC(11, 2),
 @An_AppTotCurSup_AMNT       NUMERIC(11, 2),
 @An_MtdCurSupOwed_AMNT      NUMERIC(11, 2),
 @An_TransactionExptPay_AMNT NUMERIC(11, 2),
 @An_OweTotExptPay_AMNT      NUMERIC(11, 2),
 @An_AppTotExptPay_AMNT      NUMERIC(11, 2),
 @An_TransactionNaa_AMNT     NUMERIC(11, 2),
 @An_OweTotNaa_AMNT          NUMERIC(11, 2),
 @An_AppTotNaa_AMNT          NUMERIC(11, 2),
 @An_TransactionPaa_AMNT     NUMERIC(11, 2),
 @An_OweTotPaa_AMNT          NUMERIC(11, 2),
 @An_AppTotPaa_AMNT          NUMERIC(11, 2),
 @An_TransactionTaa_AMNT     NUMERIC(11, 2),
 @An_OweTotTaa_AMNT          NUMERIC(11, 2),
 @An_AppTotTaa_AMNT          NUMERIC(11, 2),
 @An_TransactionCaa_AMNT     NUMERIC(11, 2),
 @An_OweTotCaa_AMNT          NUMERIC(11, 2),
 @An_AppTotCaa_AMNT          NUMERIC(11, 2),
 @An_TransactionUpa_AMNT     NUMERIC(11, 2),
 @An_OweTotUpa_AMNT          NUMERIC(11, 2),
 @An_AppTotUpa_AMNT          NUMERIC(11, 2),
 @An_TransactionUda_AMNT     NUMERIC(11, 2),
 @An_OweTotUda_AMNT          NUMERIC(11, 2),
 @An_AppTotUda_AMNT          NUMERIC(11, 2),
 @An_TransactionIvef_AMNT    NUMERIC(11, 2),
 @An_OweTotIvef_AMNT         NUMERIC(11, 2),
 @An_AppTotIvef_AMNT         NUMERIC(11, 2),
 @An_TransactionMedi_AMNT    NUMERIC(11, 2),
 @An_OweTotMedi_AMNT         NUMERIC(11, 2),
 @An_AppTotMedi_AMNT         NUMERIC(11, 2),
 @An_TransactionFuture_AMNT  NUMERIC(11, 2),
 @An_AppTotFuture_AMNT       NUMERIC(11, 2),
 @An_TransactionNffc_AMNT    NUMERIC(11, 2),
 @An_OweTotNffc_AMNT         NUMERIC(11, 2),
 @An_AppTotNffc_AMNT         NUMERIC(11, 2),
 @An_TransactionNonIvd_AMNT  NUMERIC(11, 2),
 @An_OweTotNonIvd_AMNT       NUMERIC(11, 2),
 @An_AppTotNonIvd_AMNT       NUMERIC(11, 2),
 @Ac_CheckRecipient_ID       CHAR(10),
 @Ac_CheckRecipient_CODE     CHAR(1),
 @Ad_Batch_DATE              DATE,
 @Ac_SourceBatch_CODE        CHAR(3),
 @An_Batch_NUMB              NUMERIC(4, 0),
 @An_SeqReceipt_NUMB         NUMERIC(6, 0),
 @Ad_Receipt_DATE            DATE,
 @Ad_Distribute_DATE         DATE,
 @Ac_TypeRecord_CODE         CHAR(1),
 @An_EventFunctionalSeq_NUMB NUMERIC(4, 0),
 @Ac_SignedOnWorker_ID       CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : PLSUP_INSERT_S1
  *     DESCRIPTION       : Insert the log support and arrear amount for child obligation to display in popup window.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  INSERT PLSUP_Y1
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
          CheckRecipient_ID,
          CheckRecipient_CODE,
          Batch_DATE,
          SourceBatch_CODE,
          Batch_NUMB,
          SeqReceipt_NUMB,
          Receipt_DATE,
          Distribute_DATE,
          TypeRecord_CODE,
          EventFunctionalSeq_NUMB,
          EventGlobalSeq_NUMB,
          Worker_ID,
          Session_ID)
  VALUES ( @An_Case_IDNO,--Case_IDNO 
           @An_OrderSeq_NUMB,--OrderSeq_NUMB 
           @An_ObligationSeq_NUMB,--ObligationSeq_NUMB 
           @An_SupportYearMonth_NUMB,--SupportYearMonth_NUMB 
           @Ac_TypeWelfare_CODE,--TypeWelfare_CODE 
           @An_TransactionCurSup_AMNT,--TransactionCurSup_AMNT 
           @An_OweTotCurSup_AMNT,--OweTotCurSup_AMNT 
           @An_AppTotCurSup_AMNT,--AppTotCurSup_AMNT 
           @An_MtdCurSupOwed_AMNT,--MtdCurSupOwed_AMNT 
           @An_TransactionExptPay_AMNT,--TransactionExptPay_AMNT 
           @An_OweTotExptPay_AMNT,--OweTotExptPay_AMNT 
           @An_AppTotExptPay_AMNT,--AppTotExptPay_AMNT 
           @An_TransactionNaa_AMNT,--TransactionNaa_AMNT 
           @An_OweTotNaa_AMNT,--OweTotNaa_AMNT 
           @An_AppTotNaa_AMNT,--AppTotNaa_AMNT 
           @An_TransactionPaa_AMNT,--TransactionPaa_AMNT 
           @An_OweTotPaa_AMNT,--OweTotPaa_AMNT 
           @An_AppTotPaa_AMNT,--AppTotPaa_AMNT 
           @An_TransactionTaa_AMNT,--TransactionTaa_AMNT 
           @An_OweTotTaa_AMNT,--OweTotTaa_AMNT 
           @An_AppTotTaa_AMNT,--AppTotTaa_AMNT 
           @An_TransactionCaa_AMNT,--TransactionCaa_AMNT 
           @An_OweTotCaa_AMNT,--OweTotCaa_AMNT 
           @An_AppTotCaa_AMNT,--AppTotCaa_AMNT 
           @An_TransactionUpa_AMNT,--TransactionUpa_AMNT 
           @An_OweTotUpa_AMNT,--OweTotUpa_AMNT 
           @An_AppTotUpa_AMNT,--AppTotUpa_AMNT 
           @An_TransactionUda_AMNT,--TransactionUda_AMNT 
           @An_OweTotUda_AMNT,--OweTotUda_AMNT 
           @An_AppTotUda_AMNT,--AppTotUda_AMNT 
           @An_TransactionIvef_AMNT,--TransactionIvef_AMNT 
           @An_OweTotIvef_AMNT,--OweTotIvef_AMNT 
           @An_AppTotIvef_AMNT,--AppTotIvef_AMNT 
           @An_TransactionMedi_AMNT,--TransactionMedi_AMNT 
           @An_OweTotMedi_AMNT,--OweTotMedi_AMNT 
           @An_AppTotMedi_AMNT,--AppTotMedi_AMNT 
           @An_TransactionFuture_AMNT,--TransactionFuture_AMNT 
           @An_AppTotFuture_AMNT,--AppTotFuture_AMNT 
           @An_TransactionNffc_AMNT,--TransactionNffc_AMNT 
           @An_OweTotNffc_AMNT,--OweTotNffc_AMNT 
           @An_AppTotNffc_AMNT,--AppTotNffc_AMNT 
           @An_TransactionNonIvd_AMNT,--TransactionNonIvd_AMNT 
           @An_OweTotNonIvd_AMNT,--OweTotNonIvd_AMNT 
           @An_AppTotNonIvd_AMNT,--AppTotNonIvd_AMNT 
           @Ac_CheckRecipient_ID,--CheckRecipient_ID 
           @Ac_CheckRecipient_CODE,-- CheckRecipient_CODE
           @Ad_Batch_DATE,--Batch_DATE 
           @Ac_SourceBatch_CODE,--SourceBatch_CODE 
           @An_Batch_NUMB,--Batch_NUMB 
           @An_SeqReceipt_NUMB,--SeqReceipt_NUMB 
           @Ad_Receipt_DATE,--Receipt_DATE
           @Ad_Distribute_DATE,--Distribute_DATE
           @Ac_TypeRecord_CODE,--TypeRecord_CODE
           @An_EventFunctionalSeq_NUMB,--EventFunctionalSeq_NUMB 
           @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB 
           @Ac_SignedOnWorker_ID,--SignedOnWorker_ID
           @Ac_Session_ID --Session_ID
  );
 END; --END OF PLSUP_RETRIEVE_S1

GO
