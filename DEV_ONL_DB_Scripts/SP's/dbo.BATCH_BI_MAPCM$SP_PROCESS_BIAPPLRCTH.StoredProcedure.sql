/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIAPPLRCTH]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIAPPLRCTH
Programmer Name	:	IMP Team.
Description		:	This process loads the collection details.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIAPPLRCTH]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY                  INT = 0,
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_WelfareTypeNonIve_CODE         CHAR(1) = 'F',
          @Lc_WelfareTypeFosterCare_CODE     CHAR(1) = 'J',
          @Lc_WelfareTypeTanf_CODE           CHAR(1) = 'A',
          @Lc_WelfareTypeNonTanf_CODE        CHAR(1) = 'N',
          @Lc_WelfareTypeMedicaid_CODE       CHAR(1) = 'M',
          @Lc_TypeRecordOriginal_CODE        CHAR(1) = 'O',
          @Lc_TypeError_CODE                 CHAR(1) = 'E',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_ReceiptSrcRegularPayment_CODE  CHAR(2) = 'RE',
          @Lc_ReceiptSrcEmployerwage_CODE    CHAR(2) = 'EW',
          @Lc_ReceiptSrcUib_CODE             CHAR(2) = 'UC',
          @Lc_ReceiptSrcCsln_CODE            CHAR(2) = 'WC',
          @Lc_ReceiptSrcInterstativdreg_CODE CHAR(2) = 'F4',
          @Lc_BateError_CODE                 CHAR(5) = 'E0944',
          @Lc_Job_ID                         CHAR(7) = 'DEB0820',
          @Lc_Process_NAME                   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME                 VARCHAR(50) = 'SP_PROCESS_BIAPPLRCTH',
          @Ld_Highdate_DATE                  DATE = '12/31/9999',
          @Ld_Lowdate_DATE                   DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                NUMERIC(1) = 0,
          @Ln_SupportYearMonth_NUMB    NUMERIC(6),
          @Ln_MaxSupportYearMonth_NUMB NUMERIC(6),
		  @Ln_MaxBsltLength_NUMB       NUMERIC(6) = 999999,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Lc_Msg_CODE                 CHAR(1),
          @Ls_Sql_TEXT                 VARCHAR(100),
          @Ls_Sqldata_TEXT             VARCHAR(1000),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ld_Mindate_DATE             DATE,
          @Ld_Maxdate_DATE             DATE,
          @Ld_Start_DATE               DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'RETRIEVE MAX AND MIN DATE DETAILS FROM BPDATE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   SELECT @Ln_SupportYearMonth_NUMB = MIN(a.SupportYearMonth_NUMB),
          @Ld_Mindate_DATE = MIN(a.End_DATE),
          @Ld_Maxdate_DATE = MAX(a.End_DATE),
          @Ln_MaxSupportYearMonth_NUMB = MAX(a.SupportYearMonth_NUMB)
     FROM BPDATE_Y1 a;

   SET @Ls_Sql_TEXT = 'DELETE FROM BPRCTA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPRCTA_Y1;

   SET @Ls_Sql_TEXT = 'INSERT ALL COLLECTIONS INTO BPRCTA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPRCTA_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           SourceBatch_CODE,
           Batch_DATE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           AppMtdIvaArr_AMNT,
           AppMtdCpArr_AMNT,
           TransactionCurSup_AMNT,
           AppLtdIvaArr_AMNT,
           AppLtdCpArr_AMNT,
           AppLtdCs_AMNT,
           Held_AMNT,
           Receipt_DATE,
           Receipt_AMNT,
           EndOfMonth_DATE,
           EventFunctionalSeq_NUMB,
           SourceReceipt_CODE,
           EventGlobalSeq_NUMB)
   SELECT DISTINCT
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.SupportYearMonth_NUMB,
          a.SourceBatch_CODE,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          ISNULL(CASE
                  WHEN a.TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE
                       AND a.AppTotIvef_AMNT <= a.OweTotIvef_AMNT
                       AND a.TransactionIvef_AMNT > a.TransactionCurSup_AMNT
                   THEN a.TransactionIvef_AMNT - a.TransactionCurSup_AMNT + a.TransactionNffc_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT
                  WHEN a.TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE
                       AND a.AppTotIvef_AMNT > a.OweTotIvef_AMNT
                       AND a.AppTotIvef_AMNT - a.TransactionIvef_AMNT >= a.OweTotIvef_AMNT - a.TransactionCurSup_AMNT
                       AND a.TransactionIvef_AMNT > a.TransactionCurSup_AMNT
                   THEN @Ln_Zero_NUMB + a.TransactionNffc_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT
                  WHEN a.TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE
                       AND a.AppTotIvef_AMNT > a.OweTotIvef_AMNT
                       AND a.AppTotIvef_AMNT - a.TransactionIvef_AMNT < a.OweTotIvef_AMNT - a.TransactionCurSup_AMNT
                       AND a.TransactionIvef_AMNT > a.TransactionCurSup_AMNT
                   THEN a.TransactionIvef_AMNT - a.TransactionCurSup_AMNT - (a.AppTotIvef_AMNT - a.OweTotIvef_AMNT) + a.TransactionNffc_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT
                  WHEN a.TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE
                       AND a.AppTotNffc_AMNT <= a.OweTotNffc_AMNT
                       AND a.TransactionNffc_AMNT > a.TransactionCurSup_AMNT
                   THEN a.TransactionNffc_AMNT - a.TransactionCurSup_AMNT + a.TransactionIvef_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT
                  WHEN a.TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE
                       AND a.AppTotNffc_AMNT > a.OweTotNffc_AMNT
                       AND a.AppTotNffc_AMNT - a.TransactionNffc_AMNT >= a.OweTotNffc_AMNT - a.TransactionCurSup_AMNT
                       AND a.TransactionNffc_AMNT > a.TransactionCurSup_AMNT
                   THEN @Ln_Zero_NUMB + a.TransactionIvef_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT
                  WHEN a.TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE
                       AND a.AppTotNffc_AMNT > a.OweTotNffc_AMNT
                       AND a.AppTotNffc_AMNT - a.TransactionNffc_AMNT < a.OweTotNffc_AMNT - a.TransactionCurSup_AMNT
                       AND a.TransactionNffc_AMNT > a.TransactionCurSup_AMNT
                   THEN a.TransactionNffc_AMNT - a.TransactionCurSup_AMNT - (a.AppTotNffc_AMNT - a.OweTotNffc_AMNT) + a.TransactionIvef_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT
                  WHEN a.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                   THEN a.TransactionIvef_AMNT + a.TransactionNffc_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT - a.TransactionCurSup_AMNT
                  ELSE a.TransactionIvef_AMNT + a.TransactionNffc_AMNT + a.TransactionMedi_AMNT + a.TransactionPaa_AMNT + a.TransactionTaa_AMNT
                 END, @Ln_Zero_NUMB) AS AppMtdIvaArr_AMNT,
          ISNULL(CASE
                  WHEN a.TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
                       AND a.AppTotNaa_AMNT <= a.OweTotNaa_AMNT
                       AND a.TransactionNaa_AMNT > a.TransactionCurSup_AMNT
                   THEN a.TransactionNaa_AMNT - a.TransactionCurSup_AMNT + a.TransactionUpa_AMNT + a.TransactionUda_AMNT
                  WHEN a.TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
                       AND a.AppTotNaa_AMNT > a.OweTotNaa_AMNT
                       AND a.AppTotNaa_AMNT - a.TransactionNaa_AMNT >= a.OweTotNaa_AMNT - a.TransactionCurSup_AMNT
                       AND a.TransactionNaa_AMNT > a.TransactionCurSup_AMNT
                   THEN @Ln_Zero_NUMB + a.TransactionUpa_AMNT + a.TransactionUda_AMNT
                  WHEN a.TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
                       AND a.AppTotNaa_AMNT > a.OweTotNaa_AMNT
                       AND a.AppTotNaa_AMNT - a.TransactionNaa_AMNT < a.OweTotNaa_AMNT - a.TransactionCurSup_AMNT
                       AND a.TransactionNaa_AMNT > a.TransactionCurSup_AMNT
                   THEN a.TransactionNaa_AMNT - a.TransactionCurSup_AMNT - (a.AppTotNaa_AMNT - a.OweTotNaa_AMNT) + a.TransactionUpa_AMNT + a.TransactionUda_AMNT
                  ELSE a.TransactionNaa_AMNT + a.TransactionUpa_AMNT + a.TransactionUda_AMNT
                 END, @Ln_Zero_NUMB) AS AppMtdCpArr_AMNT,
          a.TransactionCurSup_AMNT,
          @Ln_Zero_NUMB AS AppLtdIvaArr_AMNT,
          @Ln_Zero_NUMB AS AppLtdCpArr_AMNT,
          @Ln_Zero_NUMB AS AppLtdCs_AMNT,
          @Ln_Zero_NUMB AS Held_AMNT,
          a.Receipt_DATE,
          (a.TransactionNaa_AMNT + a.TransactionTaa_AMNT + a.TransactionPaa_AMNT + a.TransactionCaa_AMNT + a.TransactionUpa_AMNT + a.TransactionUda_AMNT + a.TransactionIvef_AMNT + a.TransactionNffc_AMNT + a.TransactionMedi_AMNT + a.TransactionFuture_AMNT) AS Receipt_AMNT,
          dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(a.Receipt_DATE) AS EndOfMonth_DATE,
          a.EventFunctionalSeq_NUMB,
          e.SourceReceipt_CODE AS SourceReceipt_CODE,
          a.EventGlobalSeq_NUMB
     FROM LSUP_Y1 a,
          (SELECT e.Batch_DATE,
                  e.SourceBatch_CODE,
                  e.Batch_NUMB,
                  e.SeqReceipt_NUMB,
                  e.SourceReceipt_CODE,
                  e.ToDistribute_AMNT,
                  e.StatusReceipt_CODE,
                  e.PayorMCI_IDNO,
                  ROW_NUMBER() OVER(PARTITION BY e.Batch_DATE, e.SourceBatch_CODE, e.Batch_NUMB, e.SeqReceipt_NUMB ORDER BY e.EventGlobalBeginSeq_NUMB DESC) AS rno
             FROM RCTH_Y1 e
            WHERE e.EndValidity_DATE = @Ld_Highdate_DATE) AS e
    WHERE a.SupportYearMonth_NUMB BETWEEN @Ln_SupportYearMonth_NUMB AND @Ln_MaxSupportYearMonth_NUMB
      AND a.Batch_DATE != @Ld_Lowdate_DATE
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND e.Batch_DATE = a.Batch_DATE
      AND e.SourceBatch_CODE = a.SourceBatch_CODE
      AND e.Batch_NUMB = a.Batch_NUMB
      AND e.SeqReceipt_NUMB = a.SeqReceipt_NUMB
      AND e.rno = 1;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   IF ((@An_RecordCount_NUMB + @Li_RowCount_QNTY) > 999999)
    BEGIN
		SET @An_RecordCount_NUMB = CAST(RIGHT(('000000' + (@An_RecordCount_NUMB + @Li_RowCount_QNTY)), 6) AS NUMERIC(6));
    END
   ELSE 
    BEGIN
		SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;
    END
	
   SET @Ls_Sql_TEXT = 'INSERT ALL UNDISTRIBUTED COLLECTIONS INTO BPRCTA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPRCTA_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           SourceBatch_CODE,
           Batch_DATE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           AppMtdIvaArr_AMNT,
           AppMtdCpArr_AMNT,
           TransactionCurSup_AMNT,
           AppLtdIvaArr_AMNT,
           AppLtdCpArr_AMNT,
           AppLtdCs_AMNT,
           Held_AMNT,
           Receipt_DATE,
           Receipt_AMNT,
           EndOfMonth_DATE,
           EventFunctionalSeq_NUMB,
           SourceReceipt_CODE,
           EventGlobalSeq_NUMB)
   SELECT DISTINCT
          a.Case_IDNO,
          @Ln_Zero_NUMB AS OrderSeq_NUMB,
          @Ln_Zero_NUMB AS ObligationSeq_NUMB,
          CAST(SUBSTRING(CONVERT(VARCHAR(6), b.Receipt_DATE, 112), 1, 6) AS NUMERIC(6)) AS SupportYearMonth_NUMB,
          b.SourceBatch_CODE,
          b.Batch_DATE,
          b.Batch_NUMB,
          b.SeqReceipt_NUMB,
          @Ln_Zero_NUMB AS AppMtdIvaArr_AMNT,
          @Ln_Zero_NUMB AS AppMtdCpArr_AMNT,
          @Ln_Zero_NUMB AS TransactionCurSup_AMNT,
          @Ln_Zero_NUMB AS AppLtdIvaArr_AMNT,
          @Ln_Zero_NUMB AS AppMtdCpArr_AMNT,
          @Ln_Zero_NUMB AS AppLtdCs_AMNT,
          b.UndistCollection_AMNT Held_AMNT,
          b.Receipt_DATE,
          b.UndistCollection_AMNT AS Receipt_AMNT,
          dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(b.Receipt_DATE) AS EndOfMonth_DATE,
          @Ln_Zero_NUMB AS EventFunctionalSeq_NUMB,
          b.SourceReceipt_CODE,
          b.EventGlobalBeginSeq_NUMB AS EventGlobalSeq_NUMB
     FROM BPCASE_Y1 a,
          BPUCOL_Y1 b
    WHERE ((LTRIM(RTRIM(b.Case_IDNO)) IS NOT NULL
            AND a.Case_IDNO = b.Case_IDNO)
            OR (LTRIM(RTRIM(b.Case_IDNO)) IS NULL
                AND LTRIM(RTRIM(b.PayorMCI_IDNO)) IS NOT NULL
                AND a.MemberMci_IDNO = b.PayorMCI_IDNO))
      AND b.Receipt_DATE BETWEEN @Ld_Mindate_DATE AND @Ld_Maxdate_DATE;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   IF ((@An_RecordCount_NUMB + @Li_RowCount_QNTY) > 999999)
    BEGIN
		SET @An_RecordCount_NUMB = CAST(RIGHT(('000000' + (@An_RecordCount_NUMB + @Li_RowCount_QNTY)), 6) AS NUMERIC(6));
    END
   ELSE 
    BEGIN
		SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BPAPPL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPAPPL_Y1;

   SET @Ls_Sql_TEXT = 'INSERT APPLIED Receipt_T1 INTO BPAPPL_Y1-STEP1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPAPPL_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           AppMtdIvaArr_AMNT,
           AppMtdCpArr_AMNT,
           AppMtdCs_AMNT,
           AppLtdIvaArr_AMNT,
           AppLtdCpArr_AMNT,
           AppLtdCs_AMNT,
           Held_AMNT,
           EventGlobalSeq_NUMB)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.SupportYearMonth_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          CASE
           WHEN a.AppMtdIvaArr_AMNT = a.TransactionCurSup_AMNT * -1
            THEN @Ln_Zero_NUMB
           ELSE a.AppMtdIvaArr_AMNT
          END AS AppMtdIvaArr_AMNT,
          CASE
           WHEN a.AppMtdCpArr_AMNT = a.TransactionCurSup_AMNT * -1
            THEN @Ln_Zero_NUMB
           ELSE a.AppMtdCpArr_AMNT
          END AS AppMtdCpArr_AMNT,
          a.TransactionCurSup_AMNT AppMtdCs_AMNT,
          @Ln_Zero_NUMB AS AppLtdIvaArr_AMNT,
          @Ln_Zero_NUMB AS AppLtdCpArr_AMNT,
          @Ln_Zero_NUMB AS AppLtdCs_AMNT,
          a.Held_AMNT,
          a.EventGlobalSeq_NUMB
     FROM BPRCTA_Y1 a;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END   

   SET @Ls_Sql_TEXT = 'DELETE FROM BPRCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPRCTH_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPRCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPRCTH_Y1
          (Case_IDNO,
           EndOfMonth_DATE,
           Receipt_AMNT,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           SourceReceipt_CODE,
           PayorMCI_IDNO,
           ToDistribute_AMNT,
           StatusReceipt_CODE,
           Receipt_DATE)
   SELECT DISTINCT
          a.Case_IDNO,
          a.EndOfMonth_DATE,
          SUM(a.Receipt_AMNT) AS Receipt_AMNT,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceReceipt_CODE,
          ISNULL(c.PayorMCI_IDNO, @Lc_Space_TEXT) AS PayorMCI_IDNO,
          SUM(c.UndistCollection_AMNT) AS ToDistribute_AMNT,
          c.StatusReceipt_CODE,
          a.Receipt_DATE
     FROM BPRCTA_Y1 a,
          BPDATE_Y1 b,
          BPUCOL_Y1 c
    WHERE a.EndOfMonth_DATE = b.End_DATE
      AND a.Case_IDNO = c.Case_IDNO
      AND a.Batch_DATE = c.Batch_DATE
      AND a.SourceBatch_CODE = c.SourceBatch_CODE
      AND a.Batch_NUMB = c.Batch_NUMB
      AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
      AND a.SourceReceipt_CODE IN (@Lc_ReceiptSrcRegularPayment_CODE, @Lc_ReceiptSrcEmployerwage_CODE, @Lc_ReceiptSrcUib_CODE, @Lc_ReceiptSrcCsln_CODE, @Lc_ReceiptSrcInterstativdreg_CODE)
      AND a.EventGlobalSeq_NUMB = c.EventGlobalBeginSeq_NUMB
    GROUP BY a.Case_IDNO,
             a.EndOfMonth_DATE,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB,
             a.Batch_DATE,
             a.SourceBatch_CODE,
             a.Batch_NUMB,
             a.SeqReceipt_NUMB,
             a.SourceReceipt_CODE,
             c.PayorMCI_IDNO,
             c.StatusReceipt_CODE,
             a.Receipt_DATE;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END    

   SET @Ls_Sql_TEXT = 'DELETE FROM BRCTA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BRCTA_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BRCTA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BRCTA_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           SourceBatch_CODE,
           Batch_DATE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           AppMtdIvaArr_AMNT,
           AppMtdCpArr_AMNT,
           TransactionCurSup_AMNT,
           AppLtdIvaArr_AMNT,
           AppLtdCpArr_AMNT,
           AppLtdCs_AMNT,
           Held_AMNT,
           Receipt_DATE,
           Receipt_AMNT,
           EndOfMonth_DATE,
           EventFunctionalSeq_NUMB,
           SourceReceipt_CODE,
           EventGlobalSeq_NUMB)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.SupportYearMonth_NUMB,
          a.SourceBatch_CODE,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.AppMtdIvaArr_AMNT,
          a.AppMtdCpArr_AMNT,
          a.TransactionCurSup_AMNT,
          a.AppLtdIvaArr_AMNT,
          a.AppLtdCpArr_AMNT,
          a.AppLtdCs_AMNT,
          a.Held_AMNT,
          a.Receipt_DATE,
          a.Receipt_AMNT,
          a.EndOfMonth_DATE,
          a.EventFunctionalSeq_NUMB,
          a.SourceReceipt_CODE,
          a.EventGlobalSeq_NUMB
     FROM BPRCTA_Y1 a;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
    
   SET @Ls_Sql_TEXT = 'DELETE FROM BAPPL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BAPPL_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BAPPL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BAPPL_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           AppMtdIvaArr_AMNT,
           AppMtdCpArr_AMNT,
           AppMtdCs_AMNT,
           AppLtdIvaArr_AMNT,
           AppLtdCpArr_AMNT,
           AppLtdCs_AMNT,
           Held_AMNT,
           EventGlobalSeq_NUMB)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.SupportYearMonth_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.AppMtdIvaArr_AMNT,
          a.AppMtdCpArr_AMNT,
          a.AppMtdCs_AMNT,
          a.AppLtdIvaArr_AMNT,
          a.AppLtdCpArr_AMNT,
          a.AppLtdCs_AMNT,
          a.Held_AMNT,
          a.EventGlobalSeq_NUMB
     FROM BPAPPL_Y1 a;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
	
   IF(@An_RecordCount_NUMB > @Ln_MaxBsltLength_NUMB)
    BEGIN
	 SET @An_RecordCount_NUMB = @Ln_MaxBsltLength_NUMB;
	END    
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
