/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_REASSIGN_ARREARS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_REASSIGN_ARREARS
Programmer Name		: IMP Team
Description			: REASSIGNING THE ARREARS
Frequency			: 
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_REASSIGN_ARREARS]
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @An_ObligationSeq_NUMB    NUMERIC(2),
 @An_SupportYearMonth_NUMB NUMERIC(6),
 @An_CpMci_IDNO            NUMERIC(10),
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ac_Screen_ID             CHAR(4) = '',
 @Ad_Process_DATE          DATE
AS
 BEGIN 
  SET NOCOUNT ON;
  DECLARE  @Li_TanfGrantSplit2730_NUMB	 INT = 2730,
		   @Lc_TypeWelfareTanf_CODE      CHAR(1) = 'A',
           @Lc_No_INDC                   CHAR(1) = 'N',
           @Lc_TypeWelfareMedicaid_CODE  CHAR(1) = 'M',
           @Lc_StatusFailed_CODE         CHAR(1) = 'F',
           @Lc_TypeWelfareNonIve_CODE    CHAR(1) = 'F',
           @Lc_Space_TEXT                CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
           @Lc_DateFormatYyyymm_TEXT     CHAR(6) = 'YYYYMM',
           @Lc_DateFormatDdMonYyyy_TEXT  CHAR(11) = 'DD-MON-YYYY',
           @Lc_WorkerConver_ID           CHAR(30) = 'CNVRSON',
           @Ls_Routine_TEXT              VARCHAR(100) = 'BATCH_COMMON$SP_REASSIGN_ARREARS',
           @Ld_High_DATE                 DATE = '12/31/9999',
           @Ld_Low_DATE                  DATE = '01/01/0001';
  DECLARE  @Ln_Value_NUMB               NUMERIC,
           @Ln_MemberMci_IDNO           NUMERIC(10),
           @Ln_Adjustment_AMNT          NUMERIC(11,2),
           @Ln_AdjustmentNaa_AMNT       NUMERIC(11,2),
           @Ln_AdjustmentTaa_AMNT       NUMERIC(11,2),
           @Ln_Error_NUMB               NUMERIC(11),
           @Ln_ErrorLine_NUMB           NUMERIC(11),
           @Ln_AdjustmentPaa_AMNT       NUMERIC(11,2),
           @Ln_AdjustmentCaa_AMNT       NUMERIC(11,2),
           @Ln_AdjustmentUpa_AMNT       NUMERIC(11,2),
           @Ln_AdjustmentUda_AMNT       NUMERIC(11,2),
           @Ln_OweTotCurSup_AMNT        NUMERIC(11,2),
           @Ln_AppTotCurSup_AMNT        NUMERIC(11,2),
           @Ln_OweTotExptPay_AMNT       NUMERIC(11,2),
           @Ln_AppTotExptPay_AMNT       NUMERIC(11,2),
           @Ln_TransactionNaa_AMNT      NUMERIC(11,2),
           @Ln_OweTotNaa_AMNT           NUMERIC(11,2),
           @Ln_AppTotNaa_AMNT           NUMERIC(11,2),
           @Ln_TransactionTaa_AMNT      NUMERIC(11,2),
           @Ln_OweTotTaa_AMNT           NUMERIC(11,2),
           @Ln_AppTotTaa_AMNT           NUMERIC(11,2),
           @Ln_TransactionPaa_AMNT      NUMERIC(11,2),
           @Ln_OweTotPaa_AMNT           NUMERIC(11,2),
           @Ln_AppTotPaa_AMNT           NUMERIC(11,2),
           @Ln_TransactionCaa_AMNT      NUMERIC(11,2),
           @Ln_OweTotCaa_AMNT           NUMERIC(11,2),
           @Ln_AppTotCaa_AMNT           NUMERIC(11,2),
           @Ln_TransactionUpa_AMNT      NUMERIC(11,2),
           @Ln_OweTotUpa_AMNT           NUMERIC(11,2),
           @Ln_AppTotUpa_AMNT           NUMERIC(11,2),
           @Ln_TransactionUda_AMNT      NUMERIC(11,2),
           @Ln_OweTotUda_AMNT           NUMERIC(11,2),
           @Ln_AppTotUda_AMNT           NUMERIC(11,2),
           @Ln_OweTotIvef_AMNT          NUMERIC(11,2),
           @Ln_AppTotIvef_AMNT          NUMERIC(11,2),
           @Ln_OweTotNffc_AMNT          NUMERIC(11,2),
           @Ln_AppTotNffc_AMNT          NUMERIC(11,2),
           @Ln_OweTotNonIvd_AMNT        NUMERIC(11,2),
           @Ln_AppTotNonIvd_AMNT        NUMERIC(11,2),
           @Ln_OweTotMedi_AMNT          NUMERIC(11,2),
           @Ln_AppTotMedi_AMNT          NUMERIC(11,2),
           @Ln_AppTotFuture_AMNT        NUMERIC(11,2),
           @Ln_MtdAccrual_NUMB          NUMERIC(11,2),
           @Li_Rowcount_QNTY            SMALLINT,
           @Lc_TypeWelfare_CODE         CHAR(1),
           @Lc_MemberStatus_INDC        CHAR(1),
           @Lc_Msg_CODE                 CHAR(1) = '',
           @Lc_Worker_ID                CHAR(30),
           @Ls_Sql_TEXT                 VARCHAR(200),
           @Ls_Sqldata_TEXT             VARCHAR(1000),
           @Ls_ErrorMessage_TEXT        VARCHAR(4000),
           @Ld_Process_DATE             DATE,
           @Ld_Sep1998_DATE             DATE,
           @Ld_Oct1998_DATE             DATE,
           @Ld_Value_DATE               DATETIME2(0);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ld_Sep1998_DATE = '09/30/1998';
   SET @Ld_Oct1998_DATE = '10/01/1998';
   
   -- IVA Updates need to use effetive date instead of Sysdate - Starts
   SET @Ld_Process_DATE = ISNULL (@Ad_Process_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1';
    SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

    SELECT DISTINCT
           @Ln_MemberMci_IDNO = a.MemberMci_IDNO
      FROM OBLE_Y1 a
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
       AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
       AND a.EndValidity_DATE = @Ld_High_DATE;

    SET @Li_Rowcount_QNTY = @@ROWCOUNT;

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      --  OWIZ - cannot update NON IVD obligations - PRD
      SET @Lc_TypeWelfare_CODE = dbo.BATCH_COMMON_GETS$SF_GETCASETYPE (@An_Case_IDNO);
     END
    ELSE
     BEGIN
      IF @An_SupportYearMonth_NUMB = CONVERT(VARCHAR(6), @Ld_Process_DATE, 112)
       BEGIN
        SET @Ld_Value_DATE = @Ld_Process_DATE;
       END
      ELSE
       BEGIN
        SET @Ld_Value_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2 (CAST (@An_SupportYearMonth_NUMB AS NVARCHAR (6)), @Lc_DateFormatYyyymm_TEXT));
       END

      SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y1';
      SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ' MEMBER ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ' SupportYearMonth_NUMB ' + ISNULL (CAST (@An_SupportYearMonth_NUMB AS NVARCHAR (6)), '');

      SELECT TOP 1 @Lc_TypeWelfare_CODE = TypeWelfare_CODE
        FROM MHIS_Y1 m
       WHERE m.Case_IDNO = @An_Case_IDNO
         AND m.MemberMci_IDNO = @Ln_MemberMci_IDNO
         AND @Ld_Value_DATE BETWEEN m.Start_DATE AND m.End_DATE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;

      IF @Li_Rowcount_QNTY = 0
       BEGIN
        --  OWIZ - cannot update NON IVD obligations - PRD - Starts
        SET @Lc_TypeWelfare_CODE = dbo.BATCH_COMMON_GETS$SF_GETCASETYPE (@An_Case_IDNO);
       -- Ends
       END
     END
   END

   SET @Ln_MtdAccrual_NUMB = 0;
   SET @Ln_OweTotCurSup_AMNT = 0;
   SET @Ln_AppTotCurSup_AMNT = 0;
   SET @Ln_OweTotExptPay_AMNT = 0;
   SET @Ln_AppTotExptPay_AMNT = 0;
   SET @Ln_OweTotNaa_AMNT = 0;
   SET @Ln_AppTotNaa_AMNT = 0;
   SET @Ln_OweTotTaa_AMNT = 0;
   SET @Ln_AppTotTaa_AMNT = 0;
   SET @Ln_OweTotPaa_AMNT = 0;
   SET @Ln_AppTotPaa_AMNT = 0;
   SET @Ln_OweTotCaa_AMNT = 0;
   SET @Ln_AppTotCaa_AMNT = 0;
   SET @Ln_OweTotUpa_AMNT = 0;
   SET @Ln_AppTotUpa_AMNT = 0;
   SET @Ln_OweTotUda_AMNT = 0;
   SET @Ln_AppTotUda_AMNT = 0;
   SET @Ln_OweTotIvef_AMNT = 0;
   SET @Ln_AppTotIvef_AMNT = 0;
   SET @Ln_OweTotNffc_AMNT = 0;
   SET @Ln_AppTotNffc_AMNT = 0;
   SET @Ln_OweTotNonIvd_AMNT = 0;
   SET @Ln_AppTotNonIvd_AMNT = 0;
   SET @Ln_OweTotMedi_AMNT = 0;
   SET @Ln_AppTotMedi_AMNT = 0;
   SET @Ln_AppTotFuture_AMNT = 0;

   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1-1';
    SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB ' + ISNULL (CAST (@An_OrderSeq_NUMB AS NVARCHAR (5)), '') + 'Seq_IDNO OBLE_Y1 ' + ISNULL (CAST (@An_ObligationSeq_NUMB AS NVARCHAR (5)), '') + ' SupportYearMonth_NUMB ' + ISNULL (CAST (@An_SupportYearMonth_NUMB AS NVARCHAR (6)), '');

    SELECT @Ln_MtdAccrual_NUMB = a.MtdCurSupOwed_AMNT,
           @Ln_OweTotCurSup_AMNT = ISNULL (a.OweTotCurSup_AMNT, 0),
           @Ln_AppTotCurSup_AMNT = ISNULL (a.AppTotCurSup_AMNT, 0),
           @Ln_OweTotExptPay_AMNT = ISNULL (a.OweTotExptPay_AMNT, 0),
           @Ln_AppTotExptPay_AMNT = ISNULL (a.AppTotExptPay_AMNT, 0),
           @Ln_OweTotNaa_AMNT = ISNULL (a.OweTotNaa_AMNT, 0),
           @Ln_AppTotNaa_AMNT = ISNULL (a.AppTotNaa_AMNT, 0),
           @Ln_OweTotTaa_AMNT = ISNULL (a.OweTotTaa_AMNT, 0),
           @Ln_AppTotTaa_AMNT = ISNULL (a.AppTotTaa_AMNT, 0),
           @Ln_OweTotPaa_AMNT = ISNULL (a.OweTotPaa_AMNT, 0),
           @Ln_AppTotPaa_AMNT = ISNULL (a.AppTotPaa_AMNT, 0),
           @Ln_OweTotCaa_AMNT = ISNULL (a.OweTotCaa_AMNT, 0),
           @Ln_AppTotCaa_AMNT = ISNULL (a.AppTotCaa_AMNT, 0),
           @Ln_OweTotUpa_AMNT = ISNULL (a.OweTotUpa_AMNT, 0),
           @Ln_AppTotUpa_AMNT = ISNULL (a.AppTotUpa_AMNT, 0),
           @Ln_OweTotUda_AMNT = ISNULL (a.OweTotUda_AMNT, 0),
           @Ln_AppTotUda_AMNT = ISNULL (a.AppTotUda_AMNT, 0),
           @Ln_OweTotIvef_AMNT = ISNULL (a.OweTotIvef_AMNT, 0),
           @Ln_AppTotIvef_AMNT = ISNULL (a.AppTotIvef_AMNT, 0),
           @Ln_OweTotNffc_AMNT = ISNULL (a.OweTotNffc_AMNT, 0),
           @Ln_AppTotNffc_AMNT = ISNULL (a.AppTotNffc_AMNT, 0),
           @Ln_OweTotNonIvd_AMNT = ISNULL (a.OweTotNonIvd_AMNT, 0),
           @Ln_AppTotNonIvd_AMNT = ISNULL (a.AppTotNonIvd_AMNT, 0),
           @Ln_OweTotMedi_AMNT = ISNULL (a.OweTotMedi_AMNT, 0),
           @Ln_AppTotMedi_AMNT = ISNULL (a.AppTotMedi_AMNT, 0),
           @Ln_AppTotFuture_AMNT = ISNULL (a.AppTotFuture_AMNT, 0)
      FROM LSUP_Y1 a
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
       AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
       AND a.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
       AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                      FROM LSUP_Y1 c
                                     WHERE c.Case_IDNO = a.Case_IDNO
                                       AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                       AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                       AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

    SET @Li_Rowcount_QNTY = @@ROWCOUNT;

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1-2';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB ' + ISNULL (CAST (@An_OrderSeq_NUMB AS NVARCHAR (5)), '') + 'Seq_IDNO OBLE_Y1 ' + ISNULL (CAST (@An_ObligationSeq_NUMB AS NVARCHAR (5)), '') + ' SupportYearMonth_NUMB ' + ISNULL (CAST (@An_SupportYearMonth_NUMB AS NVARCHAR (6)), '');

      SELECT @Ln_MtdAccrual_NUMB = a.MtdCurSupOwed_AMNT,
             @Ln_OweTotCurSup_AMNT = ISNULL (a.OweTotCurSup_AMNT, 0),
             @Ln_AppTotCurSup_AMNT = ISNULL (a.AppTotCurSup_AMNT, 0),
             @Ln_OweTotExptPay_AMNT = ISNULL (a.OweTotExptPay_AMNT, 0),
             @Ln_AppTotExptPay_AMNT = ISNULL (a.AppTotExptPay_AMNT, 0),
             @Ln_OweTotNaa_AMNT = ISNULL (a.OweTotNaa_AMNT, 0),
             @Ln_AppTotNaa_AMNT = ISNULL (a.AppTotNaa_AMNT, 0),
             @Ln_OweTotTaa_AMNT = ISNULL (a.OweTotTaa_AMNT, 0),
             @Ln_AppTotTaa_AMNT = ISNULL (a.AppTotTaa_AMNT, 0),
             @Ln_OweTotPaa_AMNT = ISNULL (a.OweTotPaa_AMNT, 0),
             @Ln_AppTotPaa_AMNT = ISNULL (a.AppTotPaa_AMNT, 0),
             @Ln_OweTotCaa_AMNT = ISNULL (a.OweTotCaa_AMNT, 0),
             @Ln_AppTotCaa_AMNT = ISNULL (a.AppTotCaa_AMNT, 0),
             @Ln_OweTotUpa_AMNT = ISNULL (a.OweTotUpa_AMNT, 0),
             @Ln_AppTotUpa_AMNT = ISNULL (a.AppTotUpa_AMNT, 0),
             @Ln_OweTotUda_AMNT = ISNULL (a.OweTotUda_AMNT, 0),
             @Ln_AppTotUda_AMNT = ISNULL (a.AppTotUda_AMNT, 0),
             @Ln_OweTotIvef_AMNT = ISNULL (a.OweTotIvef_AMNT, 0),
             @Ln_AppTotIvef_AMNT = ISNULL (a.AppTotIvef_AMNT, 0),
             @Ln_OweTotNffc_AMNT = ISNULL (a.OweTotNffc_AMNT, 0),
             @Ln_AppTotNffc_AMNT = ISNULL (a.AppTotNffc_AMNT, 0),
             @Ln_OweTotNonIvd_AMNT = ISNULL (a.OweTotNonIvd_AMNT, 0),
             @Ln_AppTotNonIvd_AMNT = ISNULL (a.AppTotNonIvd_AMNT, 0),
             @Ln_OweTotMedi_AMNT = ISNULL (a.OweTotMedi_AMNT, 0),
             @Ln_AppTotMedi_AMNT = ISNULL (a.AppTotMedi_AMNT, 0),
             @Ln_AppTotFuture_AMNT = ISNULL (a.AppTotFuture_AMNT, 0)
        FROM LSUP_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
         AND a.SupportYearMonth_NUMB = (SELECT MAX (b.SupportYearMonth_NUMB)
                                          FROM LSUP_Y1 b
                                         WHERE b.Case_IDNO = a.Case_IDNO
                                           AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                           AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                           AND b.SupportYearMonth_NUMB <= @An_SupportYearMonth_NUMB)
         AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                        FROM LSUP_Y1 c
                                       WHERE c.Case_IDNO = a.Case_IDNO
                                         AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                         AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                         AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);
     END
   END

   SET @Ln_AdjustmentNaa_AMNT = 0;
   SET @Ln_AdjustmentTaa_AMNT = 0;
   SET @Ln_AdjustmentPaa_AMNT = 0;
   SET @Ln_AdjustmentCaa_AMNT = 0;
   SET @Ln_AdjustmentUpa_AMNT = 0;
   SET @Ln_AdjustmentUda_AMNT = 0;
   SET @Ln_Adjustment_AMNT = 0;
   SET @Ln_TransactionNaa_AMNT = 0;
   SET @Ln_TransactionTaa_AMNT = 0;
   SET @Ln_TransactionPaa_AMNT = 0;
   SET @Ln_TransactionCaa_AMNT = 0;
   SET @Ln_TransactionUpa_AMNT = 0;
   SET @Ln_TransactionUda_AMNT = 0;

   IF @Lc_TypeWelfare_CODE IN (@Lc_TypeWelfareTanf_CODE, @Lc_No_INDC, @Lc_TypeWelfareMedicaid_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ASSIGN_ARREARS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @An_CpMci_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', OweCur_AMNT = ' + ISNULL(CAST( @Ln_OweTotCurSup_AMNT AS VARCHAR ),'')+ ', AppCur_AMNT = ' + ISNULL(CAST( @Ln_AppTotCurSup_AMNT AS VARCHAR ),'')+ ', Adjust_AMNT = ' + ISNULL(CAST( @Ln_Adjustment_AMNT AS VARCHAR ),'')+ ', OweNaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotNaa_AMNT AS VARCHAR ),'')+ ', AppNaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotNaa_AMNT AS VARCHAR ),'')+ ', OwePaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotPaa_AMNT AS VARCHAR ),'')+ ', AppPaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotPaa_AMNT AS VARCHAR ),'')+ ', OweTaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotTaa_AMNT AS VARCHAR ),'')+ ', AppTaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotTaa_AMNT AS VARCHAR ),'')+ ', OweCaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotCaa_AMNT AS VARCHAR ),'')+ ', AppCaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotCaa_AMNT AS VARCHAR ),'')+ ', OweUpa_AMNT = ' + ISNULL(CAST( @Ln_OweTotUpa_AMNT AS VARCHAR ),'')+ ', AppUpa_AMNT = ' + ISNULL(CAST( @Ln_AppTotUpa_AMNT AS VARCHAR ),'')+ ', OweUda_AMNT = ' + ISNULL(CAST( @Ln_OweTotUda_AMNT AS VARCHAR ),'')+ ', AppUda_AMNT = ' + ISNULL(CAST( @Ln_AppTotUda_AMNT AS VARCHAR ),'')+ ', Process_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'');

     EXECUTE BATCH_COMMON$SP_ASSIGN_ARREARS
      @An_Case_IDNO             = @An_Case_IDNO,
      @An_OrderSeq_NUMB         = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB    = @An_ObligationSeq_NUMB,
      @An_CpMci_IDNO            = @An_CpMci_IDNO,
      @Ac_TypeWelfare_CODE      = @Lc_TypeWelfare_CODE,
      @An_SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB,
      @An_OweCur_AMNT           = @Ln_OweTotCurSup_AMNT,
      @An_AppCur_AMNT           = @Ln_AppTotCurSup_AMNT,
      @An_Adjust_AMNT           = @Ln_Adjustment_AMNT,
      @An_OweNaa_AMNT           = @Ln_OweTotNaa_AMNT,
      @An_AppNaa_AMNT           = @Ln_AppTotNaa_AMNT,
      @An_TransactionNaa_AMNT   = @Ln_TransactionNaa_AMNT OUTPUT,
      @An_AdjustNaa_AMNT        = @Ln_AdjustmentNaa_AMNT OUTPUT,
      @An_OwePaa_AMNT           = @Ln_OweTotPaa_AMNT,
      @An_AppPaa_AMNT           = @Ln_AppTotPaa_AMNT,
      @An_TransactionPaa_AMNT   = @Ln_TransactionPaa_AMNT OUTPUT,
      @An_AdjustPaa_AMNT        = @Ln_AdjustmentPaa_AMNT OUTPUT,
      @An_OweTaa_AMNT           = @Ln_OweTotTaa_AMNT,
      @An_AppTaa_AMNT           = @Ln_AppTotTaa_AMNT,
      @An_TransactionTaa_AMNT   = @Ln_TransactionTaa_AMNT OUTPUT,
      @An_AdjustTaa_AMNT        = @Ln_AdjustmentTaa_AMNT OUTPUT,
      @An_OweCaa_AMNT           = @Ln_OweTotCaa_AMNT,
      @An_AppCaa_AMNT           = @Ln_AppTotCaa_AMNT,
      @An_TransactionCaa_AMNT   = @Ln_TransactionCaa_AMNT OUTPUT,
      @An_AdjustCaa_AMNT        = @Ln_AdjustmentCaa_AMNT OUTPUT,
      @An_OweUpa_AMNT           = @Ln_OweTotUpa_AMNT,
      @An_AppUpa_AMNT           = @Ln_AppTotUpa_AMNT,
      @An_TransactionUpa_AMNT   = @Ln_TransactionUpa_AMNT OUTPUT,
      @An_AdjustUpa_AMNT        = @Ln_AdjustmentUpa_AMNT OUTPUT,
      @An_OweUda_AMNT           = @Ln_OweTotUda_AMNT,
      @An_AppUda_AMNT           = @Ln_AppTotUda_AMNT,
      @An_TransactionUda_AMNT   = @Ln_TransactionUda_AMNT OUTPUT,
      @An_AdjustUda_AMNT        = @Ln_AdjustmentUda_AMNT OUTPUT,
      @Ac_NipaFlag_INDC         = NULL,
      @Ad_Process_DATE          = @Ad_Process_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = ' SELECT_WORKER ';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'');

     SELECT TOP 1 @Lc_Worker_ID = Worker_ID
       FROM OBLE_Y1 a,
            GLEV_Y1 c
      WHERE Case_IDNO = @An_Case_IDNO
        AND OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
        AND BeginObligation_DATE = (SELECT MIN (BeginObligation_DATE)
                                      FROM OBLE_Y1 b
                                     WHERE b.Case_IDNO = @An_Case_IDNO
                                       AND b.OrderSeq_NUMB = @An_OrderSeq_NUMB
                                       AND b.ObligationSeq_NUMB = @An_ObligationSeq_NUMB)
        AND c.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB;

     IF @Lc_Worker_ID = @Lc_WorkerConver_ID
      BEGIN
       BEGIN
        SET @Ls_Sql_TEXT = ' SELECT__MEMBER_STATUS_1 ';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'');

        SELECT @Lc_MemberStatus_INDC = a.TypeWelfare_CODE
          FROM MHIS_Y1 a
         WHERE a.Case_IDNO = @An_Case_IDNO
           AND a.MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND a.Start_DATE = (SELECT MAX (b.Start_DATE)
                                 FROM MHIS_Y1 b
                                WHERE b.Case_IDNO = @An_Case_IDNO
                                  AND b.MemberMci_IDNO = @Ln_MemberMci_IDNO
                                  AND b.Start_DATE <= @Ld_Sep1998_DATE
                                  AND b.End_DATE > @Ld_Sep1998_DATE);

        SET @Li_Rowcount_QNTY = @@ROWCOUNT;

        IF @Li_Rowcount_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = ' SELECT__MEMBER_STATUS_2 ';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'');

          SELECT @Lc_MemberStatus_INDC = a.TypeWelfare_CODE
            FROM MHIS_Y1 a
           WHERE a.Case_IDNO = @An_Case_IDNO
             AND a.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND a.Start_DATE = (SELECT MIN (b.Start_DATE)
                                   FROM MHIS_Y1 b
                                  WHERE b.Case_IDNO = @An_Case_IDNO
                                    AND b.MemberMci_IDNO = @Ln_MemberMci_IDNO
                                    AND b.Start_DATE > @Ld_Sep1998_DATE);

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Lc_MemberStatus_INDC = dbo.BATCH_COMMON_GETS$SF_GETCASETYPE (@An_Case_IDNO);
           END
         END
       END

       IF @Lc_MemberStatus_INDC IN (@Lc_TypeWelfareTanf_CODE, @Lc_TypeWelfareNonIve_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = ' SELECT_MHIS1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'');

         SELECT TOP 1 @Ln_Value_NUMB = 1
           FROM MHIS_Y1 a
          WHERE Case_IDNO = @An_Case_IDNO
            AND MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND TypeWelfare_CODE NOT IN (@Lc_TypeWelfareTanf_CODE, @Lc_TypeWelfareNonIve_CODE)
            AND Start_DATE BETWEEN dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2 (@Ld_Oct1998_DATE, @Lc_DateFormatDdMonYyyy_TEXT) AND @Ld_Process_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           ---If the dependant is on TANF/FC since 199810 Then Move
           ---Excess over the grant to UPA          
           SET @Ln_TransactionUpa_AMNT = 0;
          END
        END
      END
    END

   SET @Ln_OweTotNaa_AMNT = @Ln_OweTotNaa_AMNT + @Ln_TransactionNaa_AMNT;
   SET @Ln_OweTotTaa_AMNT = @Ln_OweTotTaa_AMNT + @Ln_TransactionTaa_AMNT;
   SET @Ln_OweTotPaa_AMNT = @Ln_OweTotPaa_AMNT + @Ln_TransactionPaa_AMNT;
   SET @Ln_OweTotCaa_AMNT = @Ln_OweTotCaa_AMNT + @Ln_TransactionCaa_AMNT;
   SET @Ln_OweTotUpa_AMNT = @Ln_OweTotUpa_AMNT + @Ln_TransactionUpa_AMNT;
   SET @Ln_OweTotUda_AMNT = @Ln_OweTotUda_AMNT + @Ln_TransactionUda_AMNT;

   IF @Ln_TransactionNaa_AMNT != 0
       OR @Ln_TransactionTaa_AMNT != 0
       OR @Ln_TransactionPaa_AMNT != 0
       OR @Ln_TransactionCaa_AMNT != 0
       OR @Ln_TransactionUpa_AMNT != 0
       OR @Ln_TransactionUda_AMNT != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE,'')+ ', MtdCurSupOwed_AMNT = ' + ISNULL(CAST( @Ln_MtdAccrual_NUMB AS VARCHAR ),'')+ ', TransactionCurSup_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', OweTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_OweTotCurSup_AMNT AS VARCHAR ),'')+ ', AppTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_AppTotCurSup_AMNT AS VARCHAR ),'')+ ', TransactionExptPay_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', OweTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_OweTotExptPay_AMNT AS VARCHAR ),'')+ ', AppTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_AppTotExptPay_AMNT AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionNaa_AMNT AS VARCHAR ),'')+ ', OweTotNaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotNaa_AMNT AS VARCHAR ),'')+ ', AppTotNaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotNaa_AMNT AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionTaa_AMNT AS VARCHAR ),'')+ ', OweTotTaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotTaa_AMNT AS VARCHAR ),'')+ ', AppTotTaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotTaa_AMNT AS VARCHAR ),'')+ ', OweTotPaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotPaa_AMNT AS VARCHAR ),'')+ ', AppTotPaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotPaa_AMNT AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionCaa_AMNT AS VARCHAR ),'')+ ', OweTotCaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotCaa_AMNT AS VARCHAR ),'')+ ', AppTotCaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotCaa_AMNT AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_TransactionUpa_AMNT AS VARCHAR ),'')+ ', OweTotUpa_AMNT = ' + ISNULL(CAST( @Ln_OweTotUpa_AMNT AS VARCHAR ),'')+ ', AppTotUpa_AMNT = ' + ISNULL(CAST( @Ln_AppTotUpa_AMNT AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_TransactionUda_AMNT AS VARCHAR ),'')+ ', OweTotUda_AMNT = ' + ISNULL(CAST( @Ln_OweTotUda_AMNT AS VARCHAR ),'')+ ', AppTotUda_AMNT = ' + ISNULL(CAST( @Ln_AppTotUda_AMNT AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', OweTotIvef_AMNT = ' + ISNULL(CAST( @Ln_OweTotIvef_AMNT AS VARCHAR ),'')+ ', AppTotIvef_AMNT = ' + ISNULL(CAST( @Ln_AppTotIvef_AMNT AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', OweTotNffc_AMNT = ' + ISNULL(CAST( @Ln_OweTotNffc_AMNT AS VARCHAR ),'')+ ', AppTotNffc_AMNT = ' + ISNULL(CAST( @Ln_AppTotNffc_AMNT AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', OweTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_OweTotNonIvd_AMNT AS VARCHAR ),'')+ ', AppTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_AppTotNonIvd_AMNT AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', OweTotMedi_AMNT = ' + ISNULL(CAST( @Ln_OweTotMedi_AMNT AS VARCHAR ),'')+ ', AppTotMedi_AMNT = ' + ISNULL(CAST( @Ln_AppTotMedi_AMNT AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', AppTotFuture_AMNT = ' + ISNULL(CAST( @Ln_AppTotFuture_AMNT AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfGrantSplit2730_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

     INSERT LSUP_Y1
            (Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             SupportYearMonth_NUMB,
             TypeWelfare_CODE,
             MtdCurSupOwed_AMNT,
             TransactionCurSup_AMNT,
             OweTotCurSup_AMNT,
             AppTotCurSup_AMNT,
             TransactionExptPay_AMNT,
             OweTotExptPay_AMNT,
             AppTotExptPay_AMNT,
             TransactionNaa_AMNT,
             OweTotNaa_AMNT,
             AppTotNaa_AMNT,
             TransactionTaa_AMNT,
             OweTotTaa_AMNT,
             AppTotTaa_AMNT,
             TransactionPaa_AMNT,
             OweTotPaa_AMNT,
             AppTotPaa_AMNT,
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
             TransactionNffc_AMNT,
             OweTotNffc_AMNT,
             AppTotNffc_AMNT,
             TransactionNonIvd_AMNT,
             OweTotNonIvd_AMNT,
             AppTotNonIvd_AMNT,
             TransactionMedi_AMNT,
             OweTotMedi_AMNT,
             AppTotMedi_AMNT,
             TransactionFuture_AMNT,
             AppTotFuture_AMNT,
             Batch_DATE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceBatch_CODE,
             Receipt_DATE,
             Distribute_DATE,
             TypeRecord_CODE,
             EventGlobalSeq_NUMB,
             EventFunctionalSeq_NUMB,
             CheckRecipient_ID,
             CheckRecipient_CODE)
     VALUES (@An_Case_IDNO,   --Case_IDNO
             @An_OrderSeq_NUMB,   --OrderSeq_NUMB
             @An_ObligationSeq_NUMB,   --ObligationSeq_NUMB
             @An_SupportYearMonth_NUMB,   --SupportYearMonth_NUMB
             @Lc_TypeWelfare_CODE,   --TypeWelfare_CODE
             @Ln_MtdAccrual_NUMB,   --MtdCurSupOwed_AMNT
             0,   --TransactionCurSup_AMNT
             @Ln_OweTotCurSup_AMNT,   --OweTotCurSup_AMNT
             @Ln_AppTotCurSup_AMNT,   --AppTotCurSup_AMNT
             0,   --TransactionExptPay_AMNT
             @Ln_OweTotExptPay_AMNT,   --OweTotExptPay_AMNT
             @Ln_AppTotExptPay_AMNT,   --AppTotExptPay_AMNT
             @Ln_TransactionNaa_AMNT,   --TransactionNaa_AMNT
             @Ln_OweTotNaa_AMNT,   --OweTotNaa_AMNT
             @Ln_AppTotNaa_AMNT,   --AppTotNaa_AMNT
             @Ln_TransactionTaa_AMNT,   --TransactionTaa_AMNT
             @Ln_OweTotTaa_AMNT,   --OweTotTaa_AMNT
             @Ln_AppTotTaa_AMNT,   --AppTotTaa_AMNT
             ISNULL (@Ln_TransactionPaa_AMNT, 0),   --TransactionPaa_AMNT
             @Ln_OweTotPaa_AMNT,   --OweTotPaa_AMNT
             @Ln_AppTotPaa_AMNT,   --AppTotPaa_AMNT
             @Ln_TransactionCaa_AMNT,   --TransactionCaa_AMNT
             @Ln_OweTotCaa_AMNT,   --OweTotCaa_AMNT
             @Ln_AppTotCaa_AMNT,   --AppTotCaa_AMNT
             @Ln_TransactionUpa_AMNT,   --TransactionUpa_AMNT
             @Ln_OweTotUpa_AMNT,   --OweTotUpa_AMNT
             @Ln_AppTotUpa_AMNT,   --AppTotUpa_AMNT
             @Ln_TransactionUda_AMNT,   --TransactionUda_AMNT
             @Ln_OweTotUda_AMNT,   --OweTotUda_AMNT
             @Ln_AppTotUda_AMNT,   --AppTotUda_AMNT
             0,   --TransactionIvef_AMNT
             @Ln_OweTotIvef_AMNT,   --OweTotIvef_AMNT
             @Ln_AppTotIvef_AMNT,   --AppTotIvef_AMNT
             0,   --TransactionNffc_AMNT
             @Ln_OweTotNffc_AMNT,   --OweTotNffc_AMNT
             @Ln_AppTotNffc_AMNT,   --AppTotNffc_AMNT
             0,   --TransactionNonIvd_AMNT
             @Ln_OweTotNonIvd_AMNT,   --OweTotNonIvd_AMNT
             @Ln_AppTotNonIvd_AMNT,   --AppTotNonIvd_AMNT
             0,   --TransactionMedi_AMNT
             @Ln_OweTotMedi_AMNT,   --OweTotMedi_AMNT
             @Ln_AppTotMedi_AMNT,   --AppTotMedi_AMNT
             0,   --TransactionFuture_AMNT
             @Ln_AppTotFuture_AMNT,   --AppTotFuture_AMNT
             @Ld_Low_DATE,   --Batch_DATE
             0,   --Batch_NUMB
             0,   --SeqReceipt_NUMB
             @Lc_Space_TEXT,   --SourceBatch_CODE
             @Ld_Low_DATE,   --Receipt_DATE
             @Ld_Process_DATE,   --Distribute_DATE
             @Lc_Space_TEXT,   --TypeRecord_CODE
             @An_EventGlobalSeq_NUMB,   --EventGlobalSeq_NUMB
             @Li_TanfGrantSplit2730_NUMB,   --EventFunctionalSeq_NUMB
             0,   --CheckRecipient_ID
             @Lc_Space_TEXT  --CheckRecipient_CODE
			 );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_LSUP_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
    
  END CATCH
 END


GO
