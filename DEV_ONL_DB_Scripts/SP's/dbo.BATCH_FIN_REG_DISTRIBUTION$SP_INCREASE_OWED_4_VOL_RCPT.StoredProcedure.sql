/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INCREASE_OWED_4_VOL_RCPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_INCREASE_OWED_4_VOL_RCPT
Programmer Name 	: IMP Team
Description			: This Procedure Increases the Owed Value_AMNT when the Arrears goes Negative if RCTH_Y1
					  Source is Voluntary and it is applied towards the Voluntary Order
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INCREASE_OWED_4_VOL_RCPT]
 @Ad_Process_DATE          DATE OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  CREATE TABLE #Tlsup1030Rec_P1
   (
     Case_IDNO               NUMERIC(6),
     OrderSeq_NUMB           NUMERIC(2),
     ObligationSeq_NUMB      NUMERIC(2),
     SupportYearMonth_NUMB   NUMERIC(6),
     TypeWelfare_CODE        CHAR(1),
     TransactionCurSup_AMNT  NUMERIC(11, 2),
     OweTotCurSup_AMNT       NUMERIC(11, 2),
     AppTotCurSup_AMNT       NUMERIC(11, 2),
     MtdCurSupOwed_AMNT      NUMERIC(11, 2),
     TransactionExptPay_AMNT NUMERIC(11, 2),
     OweTotExptPay_AMNT      NUMERIC(11, 2),
     AppTotExptPay_AMNT      NUMERIC(11, 2),
     TransactionNaa_AMNT     NUMERIC(11, 2),
     OweTotNaa_AMNT          NUMERIC(11, 2),
     AppTotNaa_AMNT          NUMERIC(11, 2),
     TransactionPaa_AMNT     NUMERIC(11, 2),
     OweTotPaa_AMNT          NUMERIC(11, 2),
     AppTotPaa_AMNT          NUMERIC(11, 2),
     TransactionTaa_AMNT     NUMERIC(11, 2),
     OweTotTaa_AMNT          NUMERIC(11, 2),
     AppTotTaa_AMNT          NUMERIC(11, 2),
     TransactionCaa_AMNT     NUMERIC(11, 2),
     OweTotCaa_AMNT          NUMERIC(11, 2),
     AppTotCaa_AMNT          NUMERIC(11, 2),
     TransactionUpa_AMNT     NUMERIC(11, 2),
     OweTotUpa_AMNT          NUMERIC(11, 2),
     AppTotUpa_AMNT          NUMERIC(11, 2),
     TransactionUda_AMNT     NUMERIC(11, 2),
     OweTotUda_AMNT          NUMERIC(11, 2),
     AppTotUda_AMNT          NUMERIC(11, 2),
     TransactionIvef_AMNT    NUMERIC(11, 2),
     OweTotIvef_AMNT         NUMERIC(11, 2),
     AppTotIvef_AMNT         NUMERIC(11, 2),
     TransactionMedi_AMNT    NUMERIC(11, 2),
     OweTotMedi_AMNT         NUMERIC(11, 2),
     AppTotMedi_AMNT         NUMERIC(11, 2),
     TransactionNffc_AMNT    NUMERIC(11, 2),
     OweTotNffc_AMNT         NUMERIC(11, 2),
     AppTotNffc_AMNT         NUMERIC(11, 2),
     TransactionNonIvd_AMNT  NUMERIC(11, 2),
     OweTotNonIvd_AMNT       NUMERIC(11, 2),
     AppTotNonIvd_AMNT       NUMERIC(11, 2),
     Batch_DATE              DATE,
     SourceBatch_CODE        CHAR(3),
     Batch_NUMB              NUMERIC(4),
     SeqReceipt_NUMB         NUMERIC(6),
     Receipt_DATE            DATE,
     Distribute_DATE         DATE,
     TypeRecord_CODE         CHAR(1),
     EventFunctionalSeq_NUMB NUMERIC(4),
     EventGlobalSeq_NUMB     NUMERIC(19),
     TransactionFuture_AMNT  NUMERIC(11, 2),
     AppTotFuture_AMNT       NUMERIC(11, 2),
     CheckRecipient_ID       CHAR(10),
     CheckRecipient_CODE     CHAR(1)
   );

  DECLARE  @Li_ArrearAdjustment1030_NUMB	INT = 1030, 
           @Lc_Space_TEXT                   CHAR (1) = ' ',
           @Lc_TypeRecordOriginal_CODE      CHAR (1) = 'O',
           @Lc_No_INDC                      CHAR (1) = 'N',
           @Lc_StatusFailed_CODE            CHAR (1) = 'F',
           @Lc_StatusSuccess_CODE           CHAR (1) = 'S',
           @Lc_ProcessRdist_ID              CHAR (10) = 'DEB0560',
           @Lc_BatchRunUser_TEXT            CHAR (30) = 'BATCH',
           @Ls_Procedure_NAME               VARCHAR (100) = 'SP_INCREASE_OWED_4_VOL_RCPT',
           @Ld_Low_DATE                     DATE = '01/01/0001';
  DECLARE  @Ln_Error_NUMB               NUMERIC (11),
           @Ln_ErrorLine_NUMB           NUMERIC (11),
           @Ln_EventGlobalSeq_NUMB  NUMERIC (19,0),
           @Lc_Msg_CODE                 CHAR (1),
           @Ls_Sql_TEXT                 VARCHAR (100) = '',
           @Ls_Sqldata_TEXT             VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT        VARCHAR (2000);
          
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'INSERT INTO #Tlsup1030Rec_P1';   
   SET @Ls_Sqldata_TEXT = 'TransactionCurSup_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', TransactionExptPay_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Batch_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ArrearAdjustment1030_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'');

   INSERT INTO #Tlsup1030Rec_P1 (
				Case_IDNO ,
				OrderSeq_NUMB ,
				ObligationSeq_NUMB,
				SupportYearMonth_NUMB ,
				TypeWelfare_CODE,
				TransactionCurSup_AMNT,
				OweTotCurSup_AMNT ,
				AppTotCurSup_AMNT ,
				MtdCurSupOwed_AMNT,
				TransactionExptPay_AMNT ,
				OweTotExptPay_AMNT,
				AppTotExptPay_AMNT,
				TransactionNaa_AMNT ,
				OweTotNaa_AMNT,
				AppTotNaa_AMNT,
				TransactionPaa_AMNT ,
				OweTotPaa_AMNT,
				AppTotPaa_AMNT,
				TransactionTaa_AMNT ,
				OweTotTaa_AMNT,
				AppTotTaa_AMNT,
				TransactionCaa_AMNT ,
				OweTotCaa_AMNT,
				AppTotCaa_AMNT,
				TransactionUpa_AMNT ,
				OweTotUpa_AMNT,
				AppTotUpa_AMNT,
				TransactionUda_AMNT ,
				OweTotUda_AMNT,
				AppTotUda_AMNT,
				TransactionIvef_AMNT,
				OweTotIvef_AMNT ,
				AppTotIvef_AMNT ,
				TransactionMedi_AMNT,
				OweTotMedi_AMNT ,
				AppTotMedi_AMNT ,
				TransactionNffc_AMNT,
				OweTotNffc_AMNT ,
				AppTotNffc_AMNT ,
				TransactionNonIvd_AMNT,
				OweTotNonIvd_AMNT ,
				AppTotNonIvd_AMNT ,
				Batch_DATE,
				SourceBatch_CODE,
				Batch_NUMB,
				SeqReceipt_NUMB ,
				Receipt_DATE,
				Distribute_DATE ,
				TypeRecord_CODE ,
				EventFunctionalSeq_NUMB ,
				EventGlobalSeq_NUMB ,
				TransactionFuture_AMNT,
				AppTotFuture_AMNT ,
				CheckRecipient_ID ,
				CheckRecipient_CODE 
   )
   SELECT o.Case_IDNO,
          o.OrderSeq_NUMB,
          o.ObligationSeq_NUMB,
          l.SupportYearMonth_NUMB,
          l.TypeWelfare_CODE,
          0 AS TransactionCurSup_AMNT,
          l.OweTotCurSup_AMNT,
          l.AppTotCurSup_AMNT,
          l.MtdCurSupOwed_AMNT,
          0 AS TransactionExptPay_AMNT,
          l.OweTotExptPay_AMNT,
          l.AppTotExptPay_AMNT,
          CASE
           WHEN l.AppTotNaa_AMNT - l.OweTotNaa_AMNT > 0
            THEN l.AppTotNaa_AMNT - l.OweTotNaa_AMNT
           ELSE 0
          END AS TransactionNaa_AMNT,
          CASE
           WHEN l.AppTotNaa_AMNT - l.OweTotNaa_AMNT > 0
            THEN l.AppTotNaa_AMNT
           ELSE l.OweTotNaa_AMNT
          END AS OweTotNaa_AMNT,
          l.AppTotNaa_AMNT,
          CASE
           WHEN l.AppTotPaa_AMNT - l.OweTotPaa_AMNT > 0
            THEN l.AppTotPaa_AMNT - l.OweTotPaa_AMNT
           ELSE 0
          END AS TransactionPaa_AMNT,
          CASE
           WHEN l.AppTotPaa_AMNT - l.OweTotPaa_AMNT > 0
            THEN l.AppTotPaa_AMNT
           ELSE l.OweTotPaa_AMNT
          END AS OweTotPaa_AMNT,
          l.AppTotPaa_AMNT,
          CASE
           WHEN l.AppTotTaa_AMNT - l.OweTotTaa_AMNT > 0
            THEN l.AppTotTaa_AMNT - l.OweTotTaa_AMNT
           ELSE 0
          END AS TransactionTaa_AMNT,
          CASE
           WHEN l.AppTotTaa_AMNT - l.OweTotTaa_AMNT > 0
            THEN l.AppTotTaa_AMNT
           ELSE l.OweTotTaa_AMNT
          END AS OweTotTaa_AMNT,
          l.AppTotTaa_AMNT,
          CASE
           WHEN l.AppTotCaa_AMNT - l.OweTotCaa_AMNT > 0
            THEN l.AppTotCaa_AMNT - l.OweTotCaa_AMNT
           ELSE 0
          END AS TransactionCaa_AMNT,
          CASE
           WHEN l.AppTotCaa_AMNT - l.OweTotCaa_AMNT > 0
            THEN l.AppTotCaa_AMNT
           ELSE l.OweTotCaa_AMNT
          END AS OweTotCaa_AMNT,
          l.AppTotCaa_AMNT,
          CASE
           WHEN l.AppTotUpa_AMNT - l.OweTotUpa_AMNT > 0
            THEN l.AppTotUpa_AMNT - l.OweTotUpa_AMNT
           ELSE 0
          END AS TransactionUpa_AMNT,
          CASE
           WHEN l.AppTotUpa_AMNT - l.OweTotUpa_AMNT > 0
            THEN l.AppTotUpa_AMNT
           ELSE l.OweTotUpa_AMNT
          END AS OweTotUpa_AMNT,
          l.AppTotUpa_AMNT,
          CASE
           WHEN l.AppTotUda_AMNT - l.OweTotUda_AMNT > 0
            THEN l.AppTotUda_AMNT - l.OweTotUda_AMNT
           ELSE 0
          END AS TransactionUda_AMNT,
          CASE
           WHEN l.AppTotUda_AMNT - l.OweTotUda_AMNT > 0
            THEN l.AppTotUda_AMNT
           ELSE l.OweTotUda_AMNT
          END AS OweTotUda_AMNT,
          l.AppTotUda_AMNT,
          CASE
           WHEN l.AppTotIvef_AMNT - l.OweTotIvef_AMNT > 0
            THEN l.AppTotIvef_AMNT - l.OweTotIvef_AMNT
           ELSE 0
          END AS TransactionIvef_AMNT,
          CASE
           WHEN l.AppTotIvef_AMNT - l.OweTotIvef_AMNT > 0
            THEN l.AppTotIvef_AMNT
           ELSE l.OweTotIvef_AMNT
          END AS OweTotIvef_AMNT,
          l.AppTotIvef_AMNT,
          CASE
           WHEN l.AppTotMedi_AMNT - l.OweTotMedi_AMNT > 0
            THEN l.AppTotMedi_AMNT - l.OweTotMedi_AMNT
           ELSE 0
          END AS TransactionMedi_AMNT,
          CASE
           WHEN l.AppTotMedi_AMNT - l.OweTotMedi_AMNT > 0
            THEN l.AppTotMedi_AMNT
           ELSE l.OweTotMedi_AMNT
          END AS OweTotMedi_AMNT,
          l.AppTotMedi_AMNT,
          CASE
           WHEN l.AppTotNffc_AMNT - l.OweTotNffc_AMNT > 0
            THEN l.AppTotNffc_AMNT - l.OweTotNffc_AMNT
           ELSE 0
          END AS TransactionNffc_AMNT,
          CASE
           WHEN l.AppTotNffc_AMNT - l.OweTotNffc_AMNT > 0
            THEN l.AppTotNffc_AMNT
           ELSE l.OweTotNffc_AMNT
          END AS OweTotNffc_AMNT,
          l.AppTotNffc_AMNT,
          CASE
           WHEN l.AppTotNonIvd_AMNT - l.OweTotNonIvd_AMNT > 0
            THEN l.AppTotNonIvd_AMNT - l.OweTotNonIvd_AMNT
           ELSE 0
          END AS TransactionNonIvd_AMNT,
          CASE
           WHEN l.AppTotNonIvd_AMNT - l.OweTotNonIvd_AMNT > 0
            THEN l.AppTotNonIvd_AMNT
           ELSE l.OweTotNonIvd_AMNT
          END AS OweTotNonIvd_AMNT,
          l.AppTotNonIvd_AMNT,
          @Ld_Low_DATE AS Batch_DATE,
          @Lc_Space_TEXT AS SourceBatch_CODE,
          0 AS Batch_NUMB,
          0 AS SeqReceipt_NUMB,
          @Ld_Low_DATE AS Receipt_DATE,
          @Ad_Process_DATE AS Distribute_DATE,
          @Lc_TypeRecordOriginal_CODE AS TypeRecord_CODE,
          @Li_ArrearAdjustment1030_NUMB AS EventFunctionalSeq_NUMB,
          0 AS EventGlobalSeq_NUMB,
          0 AS TransactionFuture_AMNT,
          l.AppTotFuture_AMNT,
          o.CheckRecipient_ID,
          o.CheckRecipient_CODE
     FROM (SELECT DISTINCT
                  a.Case_IDNO,
                  a.OrderSeq_NUMB,
                  a.ObligationSeq_NUMB,
                  a.TypeDebt_CODE,
                  a.CheckRecipient_ID,
                  a.CheckRecipient_CODE,
                  a.Batch_DATE,
                  a.SourceBatch_CODE,
                  a.Batch_NUMB,
                  a.SeqReceipt_NUMB
             FROM #Tpaid_P1 a) AS o,
          LSUP_Y1 l
    WHERE o.Case_IDNO = l.Case_IDNO
      AND o.OrderSeq_NUMB = l.OrderSeq_NUMB
      AND o.ObligationSeq_NUMB = l.ObligationSeq_NUMB
      AND l.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
      AND l.EventGlobalSeq_NUMB = (SELECT MAX (p.EventGlobalSeq_NUMB)
                                     FROM LSUP_Y1 p
                                    WHERE l.Case_IDNO = p.Case_IDNO
                                      AND l.OrderSeq_NUMB = p.OrderSeq_NUMB
                                      AND l.ObligationSeq_NUMB = p.ObligationSeq_NUMB
                                      AND l.SupportYearMonth_NUMB = p.SupportYearMonth_NUMB)
      AND (l.AppTotNaa_AMNT > l.OweTotNaa_AMNT
            OR l.AppTotPaa_AMNT > l.OweTotPaa_AMNT
            OR l.AppTotTaa_AMNT > l.OweTotTaa_AMNT
            OR l.AppTotCaa_AMNT > l.OweTotCaa_AMNT
            OR l.AppTotUpa_AMNT > l.OweTotUpa_AMNT
            OR l.AppTotUda_AMNT > l.OweTotUda_AMNT
            OR l.AppTotMedi_AMNT > l.OweTotMedi_AMNT
            OR l.AppTotIvef_AMNT > l.OweTotIvef_AMNT
            OR l.AppTotNffc_AMNT > l.OweTotNffc_AMNT
            OR l.AppTotNonIvd_AMNT > l.OweTotNonIvd_AMNT);

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 7';   
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ArrearAdjustment1030_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_ArrearAdjustment1030_NUMB,
    @Ac_Process_ID              = @Lc_ProcessRdist_ID,
    @Ad_EffectiveEvent_DATE     = @Ad_Process_DATE,
    @Ac_Note_INDC               = @Lc_No_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SET 1030 EventGlobalSeq_NUMB';   
   SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR);

   UPDATE #Tlsup1030Rec_P1
      SET EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

   SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1_1030';   
   SET @Ls_Sqldata_TEXT = '';

   INSERT LSUP_Y1
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
           TransactionFuture_AMNT,
           AppTotFuture_AMNT,
           CheckRecipient_ID,
           CheckRecipient_CODE)
   SELECT  l.Case_IDNO,
			l.OrderSeq_NUMB,
			l.ObligationSeq_NUMB,
			l.SupportYearMonth_NUMB,
			l.TypeWelfare_CODE,
			l.TransactionCurSup_AMNT,
			l.OweTotCurSup_AMNT,
			l.AppTotCurSup_AMNT,
			l.MtdCurSupOwed_AMNT,
			l.TransactionExptPay_AMNT,
			l.OweTotExptPay_AMNT,
			l.AppTotExptPay_AMNT,
			l.TransactionNaa_AMNT,
			l.OweTotNaa_AMNT,
			l.AppTotNaa_AMNT,
			l.TransactionPaa_AMNT,
			l.OweTotPaa_AMNT,
			l.AppTotPaa_AMNT,
			l.TransactionTaa_AMNT,
			l.OweTotTaa_AMNT,
			l.AppTotTaa_AMNT,
			l.TransactionCaa_AMNT,
			l.OweTotCaa_AMNT,
			l.AppTotCaa_AMNT,
			l.TransactionUpa_AMNT,
			l.OweTotUpa_AMNT,
			l.AppTotUpa_AMNT,
			l.TransactionUda_AMNT,
			l.OweTotUda_AMNT,
			l.AppTotUda_AMNT,
			l.TransactionIvef_AMNT,
			l.OweTotIvef_AMNT,
			l.AppTotIvef_AMNT,
			l.TransactionMedi_AMNT,
			l.OweTotMedi_AMNT,
			l.AppTotMedi_AMNT,
			l.TransactionNffc_AMNT,
			l.OweTotNffc_AMNT,
			l.AppTotNffc_AMNT,
			l.TransactionNonIvd_AMNT,
			l.OweTotNonIvd_AMNT,
			l.AppTotNonIvd_AMNT,
			l.Batch_DATE,
			l.SourceBatch_CODE,
			l.Batch_NUMB,
			l.SeqReceipt_NUMB,
			l.Receipt_DATE,
			l.Distribute_DATE,
			l.TypeRecord_CODE,
			l.EventFunctionalSeq_NUMB,
			l.EventGlobalSeq_NUMB,
			l.TransactionFuture_AMNT,
			l.AppTotFuture_AMNT,
			l.CheckRecipient_ID,
			l.CheckRecipient_CODE
     FROM #Tlsup1030Rec_P1 l;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY
  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
