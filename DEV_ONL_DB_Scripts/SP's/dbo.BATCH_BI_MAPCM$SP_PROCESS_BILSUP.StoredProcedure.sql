/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BILSUP]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BILSUP
Programmer Name	:	IMP Team.
Description		:	This process loads the Log support Information.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BILSUP]
 @An_RecordCount_NUMB	   NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY  INT = 0,
          @Lc_Space_TEXT     CHAR(1) = ' ',
          @Lc_Failed_CODE    CHAR(1) = 'F',
          @Lc_Success_CODE   CHAR(1) = 'S',
          @Lc_TypeError_CODE CHAR(1) = 'E',
          @Lc_BateError_CODE CHAR(5) = 'E0944',
          @Lc_Job_ID         CHAR(7) = 'DEB0833',
          @Lc_Process_NAME   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME VARCHAR(50) = 'SP_PROCESS_BILSUP';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_SupportYearMonth_NUMB NUMERIC(6),
          @Ln_Curmthsup_NUMB        NUMERIC(6),
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'RETRIEVE SUPPORT YEAR MONTH NUMBER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   SELECT @Ln_SupportYearMonth_NUMB = MIN(a.SupportYearMonth_NUMB),
          @Ln_Curmthsup_NUMB = MAX(a.SupportYearMonth_NUMB)
     FROM BPDATE_Y1 a;

   SET @Ls_Sql_TEXT = 'DELETE FROM BPLSUP_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPLSUP_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPLSUP_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPLSUP_Y1
          (Case_IDNO,
           SupportYearMonth_NUMB,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           IvefArrear_AMNT,
           MedicAidArrear_AMNT,
           NonIvdArrear_AMNT,
           NffcArrear_AMNT,
           NffmArrear_AMNT,
           IvA1Arrear_AMNT,
           CpArrear_AMNT,
           TotalOwed_AMNT,
           TotalPaid_AMNT,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           OweTotCurSup_AMNT,
           TypeDebt_CODE,
           Distribute_DATE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           TypeRecord_CODE,
           EventGlobalSeq_NUMB,
           CurSupOwed_AMNT,
           AppTotCurSup_AMNT,
           OweTotExptPay_AMNT,
           AppTotExptPay_AMNT)
   SELECT DISTINCT
          a.Case_IDNO,
          CAST(a.SupportYearMonth_NUMB AS CHAR(6)) AS SupportYearMonth_NUMB,
          ((a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT)) AS TanfArrear_AMNT,
          ((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT)) AS NonTanfArrear_AMNT,
          (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) AS IvefArrear_AMNT,
          (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) AS MedicAidArrear_AMNT,
          (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) AS NonIvdArrear_AMNT,
          (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) AS NffcArrear_AMNT,
          @Ln_Zero_NUMB AS NffmArrear_AMNT,
          ((a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT)) AS IvA1Arrear_AMNT,
          ((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) + (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT)) AS CpArrear_AMNT,
          (a.OweTotCaa_AMNT + a.OweTotIvef_AMNT + a.OweTotMedi_AMNT + a.OweTotNaa_AMNT + a.OweTotNffc_AMNT + a.OweTotNonIvd_AMNT + a.OweTotPaa_AMNT + a.OweTotTaa_AMNT + a.OweTotUda_AMNT + a.OweTotUpa_AMNT) AS TotalOwed_AMNT,
          (a.AppTotCaa_AMNT + a.AppTotIvef_AMNT + a.AppTotMedi_AMNT + a.AppTotNaa_AMNT + a.AppTotNffc_AMNT + a.AppTotNonIvd_AMNT + a.AppTotPaa_AMNT + a.AppTotTaa_AMNT + a.AppTotUda_AMNT + a.AppTotUpa_AMNT) AS TotalPaid_AMNT,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.MtdCurSupOwed_AMNT,
          c.TypeDebt_CODE,
          a.Distribute_DATE,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.TypeRecord_CODE,
          a.EventGlobalSeq_NUMB,
          @Ln_Zero_NUMB AS CurSupOwed_AMNT,
          a.AppTotCurSup_AMNT,
          a.OweTotExptPay_AMNT,
          a.AppTotExptPay_AMNT
     FROM (SELECT y.Case_IDNO,
                  y.OrderSeq_NUMB,
                  y.ObligationSeq_NUMB,
                  y.SupportYearMonth_NUMB,
                  y.TypeWelfare_CODE,
                  y.TransactionCurSup_AMNT,
                  y.OweTotCurSup_AMNT,
                  y.AppTotCurSup_AMNT,
                  y.MtdCurSupOwed_AMNT,
                  y.TransactionExptPay_AMNT,
                  y.OweTotExptPay_AMNT,
                  y.AppTotExptPay_AMNT,
                  y.TransactionNaa_AMNT,
                  y.OweTotNaa_AMNT,
                  y.AppTotNaa_AMNT,
                  y.TransactionPaa_AMNT,
                  y.OweTotPaa_AMNT,
                  y.AppTotPaa_AMNT,
                  y.TransactionTaa_AMNT,
                  y.OweTotTaa_AMNT,
                  y.AppTotTaa_AMNT,
                  y.TransactionCaa_AMNT,
                  y.OweTotCaa_AMNT,
                  y.AppTotCaa_AMNT,
                  y.TransactionUpa_AMNT,
                  y.OweTotUpa_AMNT,
                  y.AppTotUpa_AMNT,
                  y.TransactionUda_AMNT,
                  y.OweTotUda_AMNT,
                  y.AppTotUda_AMNT,
                  y.TransactionIvef_AMNT,
                  y.OweTotIvef_AMNT,
                  y.AppTotIvef_AMNT,
                  y.TransactionMedi_AMNT,
                  y.OweTotMedi_AMNT,
                  y.AppTotMedi_AMNT,
                  y.TransactionNffc_AMNT,
                  y.OweTotNffc_AMNT,
                  y.AppTotNffc_AMNT,
                  y.TransactionNonIvd_AMNT,
                  y.OweTotNonIvd_AMNT,
                  y.AppTotNonIvd_AMNT,
                  y.Batch_DATE,
                  y.SourceBatch_CODE,
                  y.Batch_NUMB,
                  y.SeqReceipt_NUMB,
                  y.Receipt_DATE,
                  y.Distribute_DATE,
                  y.TypeRecord_CODE,
                  y.EventFunctionalSeq_NUMB,
                  y.EventGlobalSeq_NUMB,
                  y.TransactionFuture_AMNT,
                  y.AppTotFuture_AMNT,
                  y.CheckRecipient_ID,
                  y.CheckRecipient_CODE,
                  ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB, y.SupportYearMonth_NUMB ORDER BY y.EventGlobalSeq_NUMB DESC) AS rnm
             FROM LSUP_Y1 y
            WHERE y.SupportYearMonth_NUMB BETWEEN @Ln_SupportYearMonth_NUMB AND @Ln_Curmthsup_NUMB) a,
          (SELECT y.Case_IDNO,
                  y.OrderSeq_NUMB,
                  y.ObligationSeq_NUMB,
                  y.MemberMci_IDNO,
                  y.TypeDebt_CODE,
                  y.Fips_CODE,
                  y.FreqPeriodic_CODE,
                  y.Periodic_AMNT,
                  y.ExpectToPay_AMNT,
                  y.ExpectToPay_CODE,
                  y.BeginObligation_DATE,
                  y.EndObligation_DATE,
                  y.AccrualLast_DATE,
                  y.AccrualNext_DATE,
                  y.CheckRecipient_ID,
                  y.CheckRecipient_CODE,
                  y.EventGlobalBeginSeq_NUMB,
                  y.EventGlobalEndSeq_NUMB,
                  y.BeginValidity_DATE,
                  y.EndValidity_DATE,
                  ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB ORDER BY y.BeginObligation_DATE DESC, y.EventGlobalBeginSeq_NUMB DESC) AS rnm
             FROM OBLE_Y1 y) c
    WHERE a.Case_IDNO = c.Case_IDNO
      AND a.OrderSeq_NUMB = c.OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = c.ObligationSeq_NUMB
      AND c.rnm = 1
      AND a.rnm = 1
      AND EXISTS (SELECT 1
                    FROM BPCASE_Y1 x
                   WHERE x.Case_IDNO = a.Case_IDNO);

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
    
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_Failed_CODE;
    SET @An_RecordCount_NUMB = 0;
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
   END
  END CATCH
 END 

GO
