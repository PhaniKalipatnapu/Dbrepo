/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR_PAID]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR_PAID
Programmer Name 	: IMP Team
Description			: This Procedure loads all the Obligations at Bucket Level along with Current Support and Arrears
			          and sets up the priority for the same.  The Procedure also does the Proration based on the
                      Priority and Inserts into the Temporary Table TPAID_Y1 for Further Processing
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST
Called On			: BATCH_FIN_REG_DISTRIBUTION$SP_RETRO_DIST
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR_PAID]
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ad_Receipt_DATE          DATE,
 @Ac_SourceReceipt_CODE    CHAR(2),
 @Ac_Tanf_CODE             CHAR(1),
 @An_Receipt_AMNT          NUMERIC(11, 2),
 @An_Remaining_AMNT        NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE          DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_TypeOrderVoluntary_CODE              CHAR(1) = 'V',
           @Lc_No_INDC                              CHAR(1) = 'N',
           @Lc_Yes_INDC                             CHAR(1) = 'Y',
           @Lc_TypeError_CODE                       CHAR(1) = 'E',
           @Lc_StatusFailed_CODE                    CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE                   CHAR(1) = 'S',
           @Lc_CsTypeBucket_CODE                    CHAR(1) = 'C',
           @Lc_ExptTypeBucket_CODE                  CHAR(1) = 'E',
           @Lc_IrsReceipt_CODE                      CHAR(1) = 'I',
           @Lc_RegularReceipt_CODE                  CHAR(1) = 'R',
           @Lc_TypeExpt_CODE                        CHAR(1) = 'O',
           @Lc_SupportTypeDebt_CODE                 CHAR(1) = 'S',
           @Lc_TypeDebtChildSupp_CODE               CHAR(2) = 'CS',
           @Lc_TypeDebtMedicalSupp_CODE             CHAR(2) = 'MS',
           @Lc_TypeDebtSpousalSupp_CODE             CHAR(2) = 'SS',
           @Lc_TypeDebtGeneticTest_CODE             CHAR(2) = 'GT',
           @Lc_TypeDebtNcpNsfFee_CODE				CHAR(2) = 'NF',           
           @Lc_SourceReceiptSpecialCollection_CODE  CHAR(2) = 'SC',
           @Lc_DeStateFips_CODE                     CHAR(2) = '10',
           @Lc_ArrearBucketGroup_CODE               CHAR(3) = 'ARR',
           @Lc_NaaTypeBucket_CODE                   CHAR(5) = 'ANAA',
           @Lc_PaaTypeBucket_CODE                   CHAR(5) = 'APAA',
           @Lc_TaaTypeBucket_CODE                   CHAR(5) = 'ATAA',
           @Lc_CaaTypeBucket_CODE                   CHAR(5) = 'ACAA',
           @Lc_UdaTypeBucket_CODE                   CHAR(5) = 'AUDA',
           @Lc_UpaTypeBucket_CODE                   CHAR(5) = 'AUPA',
           @Lc_IvefTypeBucket_CODE                  CHAR(5) = 'AIVEF',
           @Lc_MediTypeBucket_CODE                  CHAR(5) = 'AMEDI',
           @Lc_NffcTypeBucket_CODE                  CHAR(5) = 'ANFFC',
           @Lc_NonIvdTypeBucket_CODE                CHAR(5) = 'ANIVD',
           @Ls_Procedure_NAME                       VARCHAR(100) = 'SP_EXPT_ARR_PAID',
           @Ld_High_DATE                            DATE = '12/31/9999';
  DECLARE  @Ln_MaxSeq_IDNO                    NUMERIC(3) = 0,
           @Ln_Case_QNTY                      NUMERIC(4),
           @Ln_Loop_QNTY                      NUMERIC(4),
           @Ln_CasePrev_IDNO                  NUMERIC(6),
           @Ln_Diff_AMNT                      NUMERIC(11,2) = 0,
           @Ln_TotArrear_AMNT                 NUMERIC(11,2) = 0,
           @Ln_Receipt_AMNT                   NUMERIC(11,2) = 0,
           @Ln_TotArrears_AMNT                NUMERIC(11,2),
           @Ln_RctCase_AMNT                   NUMERIC(11,2),
           @Ln_CaseUsed_AMNT                  NUMERIC(11,2),
           @Ln_ReceiptUsed_AMNT               NUMERIC(11,2),
           @Ln_RctEx_AMNT                     NUMERIC(11,2),
           @Ln_Error_NUMB                     NUMERIC(11),
           @Ln_ErrorLine_NUMB                 NUMERIC(11),
           @Ln_Cum_AMNT                       NUMERIC(13,2) = 0,
           @Li_FetchStatus_QNTY               SMALLINT,
           @Li_Rowcount_QNTY                  SMALLINT,
           @Lc_SrcRcpt_CODE                   CHAR(1),
           @Ls_Sql_TEXT                       VARCHAR(100) = '',
           @Ls_Sqldata_TEXT                   VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT              NVARCHAR(4000);
  DECLARE  @Ln_BumpArrCur_PrDistribute_QNTY   NUMERIC(5),
           @Ln_CarrExptCur_PrDistribute_QNTY  NUMERIC(5),
           @Ln_BumpExptCur_PrDistribute_QNTY  NUMERIC(5),
           @Ln_CarrCSCur_PrDistribute_QNTY    NUMERIC(5),
           @Ln_BumpArrCur_Case_IDNO           NUMERIC(6),
           @Ln_CarrCur_Case_IDNO              NUMERIC(6),
           @Ln_BumpArrCur_Pr_AMNT             NUMERIC(11,2),
           @Ln_CarrCur_Pr_AMNT                NUMERIC(11,2),
           @Ln_CarrExptCur_ArrToBePaid_AMNT   NUMERIC(11,2),
           @Ln_BumpExptCur_Pr_AMNT            NUMERIC(11,2),
           @Ln_CarrCSCur_ArrToBePaid_AMNT     NUMERIC(11,2);
    
  BEGIN TRY
   SET @Ac_Msg_CODE = '';

   IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollection_CODE
    BEGIN
     SET @Lc_SrcRcpt_CODE = @Lc_IrsReceipt_CODE;
    END;
   ELSE
    BEGIN
     SET @Lc_SrcRcpt_CODE = @Lc_RegularReceipt_CODE;
    END;

   SET @Ls_Sql_TEXT = 'INSERT_TOWED';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'');

   INSERT #Towed_P1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           ArrToBePaid_AMNT,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           MonthSupport_AMNT,
           MemberMci_IDNO,
           TypeDebt_CODE,
           ExptOrig_AMNT,
           Fips_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          b.TypeBucket_CODE,
          b.PrDistribute_QNTY,
          CASE LTRIM(RTRIM( (b.TypeBucket_CODE)))
           WHEN @Lc_CsTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_CsTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, 0, 0, c.MtdCurSupOwed_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_ExptTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_CALC_EXPT (c.Case_IDNO, c.OrderSeq_NUMB, a.MemberMci_IDNO, a.Fips_CODE, c.SupportYearMonth_NUMB, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.OweTotExptPay_AMNT, c.AppTotExptPay_AMNT, c.OweTotNaa_AMNT, c.AppTotNaa_AMNT, c.OweTotPaa_AMNT, c.AppTotPaa_AMNT, c.OweTotTaa_AMNT, c.AppTotTaa_AMNT, c.OweTotCaa_AMNT, c.AppTotCaa_AMNT, c.OweTotUpa_AMNT, c.AppTotUpa_AMNT, c.OweTotUda_AMNT, c.AppTotUda_AMNT, c.OweTotIvef_AMNT, c.AppTotIvef_AMNT, c.OweTotNffc_AMNT, c.AppTotNffc_AMNT, c.OweTotNonIvd_AMNT, c.AppTotNonIvd_AMNT, c.OweTotMedi_AMNT, c.AppTotMedi_AMNT, @Ac_SourceReceipt_CODE, @Ac_Tanf_CODE, c.TypeWelfare_CODE, a.TypeDebt_CODE, c.MtdCurSupOwed_AMNT, @Lc_ExptTypeBucket_CODE, a.ExpectToPay_CODE)
           WHEN @Lc_NaaTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_NaaTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotNaa_AMNT, c.AppTotNaa_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_PaaTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_PaaTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotPaa_AMNT, c.AppTotPaa_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_TaaTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_TaaTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotTaa_AMNT, c.AppTotTaa_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_CaaTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_CaaTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotCaa_AMNT, c.AppTotCaa_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_UdaTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_UdaTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotUda_AMNT, c.AppTotUda_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_UpaTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_UpaTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotUpa_AMNT, c.AppTotUpa_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_IvefTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_IvefTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotIvef_AMNT, c.AppTotIvef_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_MediTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_MediTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotMedi_AMNT, c.AppTotMedi_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_NffcTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_NffcTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotNffc_AMNT, c.AppTotNffc_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
           WHEN @Lc_NonIvdTypeBucket_CODE
            THEN dbo.BATCH_COMMON_DIST_FN$SF_BUCKET_ARREAR (@Lc_NonIvdTypeBucket_CODE, @Ac_SourceReceipt_CODE, a.TypeDebt_CODE, c.TypeWelfare_CODE, @Ac_Tanf_CODE, c.OweTotNonIvd_AMNT, c.AppTotNonIvd_AMNT, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.MtdCurSupOwed_AMNT)
          END AS ArrToBePaid_AMNT,
          a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          i.OrderType_CODE,
          c.TypeWelfare_CODE,
          CASE RTRIM (b.TypeBucket_CODE)
           WHEN @Lc_CsTypeBucket_CODE
            THEN c.MtdCurSupOwed_AMNT
           ELSE 0
          END AS MonthSupport_AMNT,
          a.MemberMci_IDNO,
          a.TypeDebt_CODE,
          dbo.BATCH_COMMON_DIST_FN$SF_CALC_EXPT (c.Case_IDNO, c.OrderSeq_NUMB, a.MemberMci_IDNO, a.Fips_CODE, c.SupportYearMonth_NUMB, c.OweTotCurSup_AMNT, c.AppTotCurSup_AMNT, c.OweTotExptPay_AMNT, c.AppTotExptPay_AMNT, c.OweTotNaa_AMNT, c.AppTotNaa_AMNT, c.OweTotPaa_AMNT, c.AppTotPaa_AMNT, c.OweTotTaa_AMNT, c.AppTotTaa_AMNT, c.OweTotCaa_AMNT, c.AppTotCaa_AMNT, c.OweTotUpa_AMNT, c.AppTotUpa_AMNT, c.OweTotUda_AMNT, c.AppTotUda_AMNT, c.OweTotIvef_AMNT, c.AppTotIvef_AMNT, c.OweTotNffc_AMNT, c.AppTotNffc_AMNT, c.OweTotNonIvd_AMNT, c.AppTotNonIvd_AMNT, c.OweTotMedi_AMNT, c.AppTotMedi_AMNT, @Ac_SourceReceipt_CODE, @Ac_Tanf_CODE, c.TypeWelfare_CODE, a.TypeDebt_CODE, c.MtdCurSupOwed_AMNT, @Lc_TypeExpt_CODE, a.ExpectToPay_CODE) AS ExptOrig_AMNT,
          a.Fips_CODE,
          @Ad_Batch_DATE AS Batch_DATE,
          @Ac_SourceBatch_CODE AS SourceBatch_CODE,
          @An_Batch_NUMB AS Batch_NUMB,
          @An_SeqReceipt_NUMB AS SeqReceipt_NUMB
     FROM OBLE_Y1  a,
          DBTP_Y1  b,
          LSUP_Y1  c,
          #Tcord_P1  i
    WHERE a.Case_IDNO = i.Case_IDNO
      AND a.OrderSeq_NUMB = i.OrderSeq_NUMB
      AND a.EndValidity_DATE = @Ld_High_DATE
      AND a.BeginObligation_DATE = (SELECT MAX (e.BeginObligation_DATE)
                                      FROM OBLE_Y1  e
                                     WHERE e.Case_IDNO = i.Case_IDNO
                                       AND e.OrderSeq_NUMB = i.OrderSeq_NUMB
                                       AND e.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                       AND e.BeginObligation_DATE <= dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Process_DATE)
                                       AND e.EndValidity_DATE = @Ld_High_DATE)
      AND c.Case_IDNO = i.Case_IDNO
      AND c.OrderSeq_NUMB = i.OrderSeq_NUMB
      AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
      AND c.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6) 
      AND c.EventGlobalSeq_NUMB = (SELECT MAX (d.EventGlobalSeq_NUMB)
                                     FROM LSUP_Y1  d
                                    WHERE d.Case_IDNO = i.Case_IDNO
                                      AND d.OrderSeq_NUMB = i.OrderSeq_NUMB
                                      AND d.ObligationSeq_NUMB = c.ObligationSeq_NUMB
                                      AND d.SupportYearMonth_NUMB = c.SupportYearMonth_NUMB)
      AND b.TypeDebt_CODE = a.TypeDebt_CODE
      AND b.SourceReceipt_CODE = @Lc_SrcRcpt_CODE
      AND b.Interstate_INDC = CASE SUBSTRING (a.Fips_CODE, 1, 2)
                               WHEN @Lc_DeStateFips_CODE
                                THEN @Lc_No_INDC
                               ELSE @Lc_Yes_INDC
                              END
      AND b.EndValidity_DATE = @Ld_High_DATE
      AND b.TypeWelfare_CODE = c.TypeWelfare_CODE
      AND b.PrDistribute_QNTY > 0;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_TypeError_CODE;

     RETURN;
    END

   SET @Ls_Sql_TEXT = 'UPDATE_TOWED';

   -- Expect_to_pay should be paid only upto the true arrears for the OBLE_Y1.
   SET @Ls_Sqldata_TEXT = 'TypeBucket_CODE = ' + ISNULL(@Lc_ExptTypeBucket_CODE,'');

   UPDATE #Towed_P1
      SET ArrToBePaid_AMNT = (SELECT ISNULL (dbo.BATCH_COMMON_SCALAR$SF_LEAST_FLOAT (a.ArrToBePaid_AMNT, SUM (b.ArrToBePaid_AMNT)), 0)
                                FROM #Towed_P1 AS b
                               WHERE b.Case_IDNO = a.Case_IDNO
                                 AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                 AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                 AND b.TypeBucket_CODE NOT IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE))
     FROM #Towed_P1 AS a
    WHERE a.TypeBucket_CODE = @Lc_ExptTypeBucket_CODE;

   SET @Ls_Sql_TEXT = ' UPDATE TOWED_Y1 ';

   SET @Ls_Sqldata_TEXT = '';

   UPDATE #Towed_P1
      SET ArrToBePaid_AMNT = 0
    WHERE #Towed_P1.ArrToBePaid_AMNT < 0;

   SET @Ls_Sql_TEXT = ' INSERT TOWED_TMP ';

   SET @Ls_Sqldata_TEXT = '';

   INSERT #Ttowd_P1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           ArrToBePaid_AMNT,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           MonthSupport_AMNT,
           MemberMci_IDNO,
           TypeDebt_CODE,
           Fips_CODE,
           ExptOrig_AMNT)
   SELECT Case_IDNO,
          OrderSeq_NUMB,
          ObligationSeq_NUMB,
          TypeBucket_CODE,
          PrDistribute_QNTY,
          ArrToBePaid_AMNT,
          CheckRecipient_ID,
          CheckRecipient_CODE,
          Batch_DATE,
          SourceBatch_CODE,
          Batch_NUMB,
          SeqReceipt_NUMB,
          TypeOrder_CODE,
          TypeWelfare_CODE,
          MonthSupport_AMNT,
          MemberMci_IDNO,
          TypeDebt_CODE,
          Fips_CODE,
          ExptOrig_AMNT
     FROM #Towed_P1 t;

   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record
   IF SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6) != SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
    BEGIN
     SET @Ln_TotArrear_AMNT = 0;
     SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_RETRO_DIST';

     SET @Ls_Sqldata_TEXT = '';

     EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_RETRO_DIST
      @An_TotArrear_AMNT        = @Ln_TotArrear_AMNT OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
      @Ad_Process_DATE          = @Ad_Process_DATE OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     IF @An_Receipt_AMNT > @Ln_TotArrear_AMNT
      BEGIN
	   SET @Ls_Sql_TEXT = 'SELECT @Ln_Receipt_AMNT, @An_Remaining_AMNT - 1';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_Receipt_AMNT = @Ln_TotArrear_AMNT,
              @An_Remaining_AMNT = @An_Receipt_AMNT - @Ln_TotArrear_AMNT;
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT @Ln_Receipt_AMNT, @An_Remaining_AMNT - 2';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_Receipt_AMNT = @An_Receipt_AMNT,
              @An_Remaining_AMNT = 0;
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT @Ln_Receipt_AMNT, @An_Remaining_AMNT - 3';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_Receipt_AMNT = @An_Receipt_AMNT,
            @An_Remaining_AMNT = 0;
    END

   SET @Ls_Sql_TEXT = 'INSERT_TEXPT';
   SET @Ls_Sqldata_TEXT = '';

   INSERT #Texpt_P1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           ArrToBePaid_AMNT,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Expt_AMNT,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           MonthSupport_AMNT,
           MemberMci_IDNO,
           TypeDebt_CODE)
   (SELECT Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           ArrToBePaid_AMNT,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           0,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           MonthSupport_AMNT,
           MemberMci_IDNO,
           TypeDebt_CODE
      FROM #Towed_P1 t
     WHERE TypeBucket_CODE IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE)
    UNION ALL
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.TypeBucket_CODE,
           a.PrDistribute_QNTY,
           a.ArrToBePaid_AMNT - dbo.BATCH_COMMON_DIST_FN$SF_CALL_EXP_SATIS (c.expt_amt, c.satis_exp, a.ArrToBePaid_AMNT),
           a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           dbo.BATCH_COMMON_DIST_FN$SF_CALL_EXP_SATIS (c.expt_amt, c.satis_exp, a.ArrToBePaid_AMNT),
           a.TypeOrder_CODE,
           a.TypeWelfare_CODE,
           a.MonthSupport_AMNT,
           a.MemberMci_IDNO,
           a.TypeDebt_CODE
      FROM #Towed_P1  a,
           (SELECT b.Case_IDNO,
                   b.OrderSeq_NUMB,
                   b.ObligationSeq_NUMB,
                   b.PrDistribute_QNTY,
                   ISNULL ((SELECT ISNULL (SUM (e.ArrToBePaid_AMNT), 0)
                              FROM #Towed_P1 e
                             WHERE e.Case_IDNO = b.Case_IDNO
                               AND e.OrderSeq_NUMB = b.OrderSeq_NUMB
                               AND e.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                               AND e.PrDistribute_QNTY < b.PrDistribute_QNTY
                               AND e.TypeBucket_CODE NOT IN ('C', 'E')), 0) satis_exp,
                   d.ArrToBePaid_AMNT AS expt_amt
              FROM #Towed_P1  b,
                   #Towed_P1  d
             WHERE b.TypeBucket_CODE NOT IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE)
               AND d.Case_IDNO = b.Case_IDNO
               AND d.OrderSeq_NUMB = b.OrderSeq_NUMB
               AND d.ObligationSeq_NUMB = b.ObligationSeq_NUMB
               AND d.TypeBucket_CODE = @Lc_ExptTypeBucket_CODE
             GROUP BY b.Case_IDNO,
                      b.OrderSeq_NUMB,
                      b.ObligationSeq_NUMB,
                      b.PrDistribute_QNTY,
                      d.ArrToBePaid_AMNT) AS c
     WHERE a.TypeBucket_CODE NOT IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE)
       AND a.Case_IDNO = c.Case_IDNO
       AND a.OrderSeq_NUMB = c.OrderSeq_NUMB
       AND a.ObligationSeq_NUMB = c.ObligationSeq_NUMB
       AND a.PrDistribute_QNTY = c.PrDistribute_QNTY
    UNION ALL
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.TypeBucket_CODE,
           a.PrDistribute_QNTY,
           a.ArrToBePaid_AMNT,
           a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           0,
           a.TypeOrder_CODE,
           a.TypeWelfare_CODE,
           a.MonthSupport_AMNT,
           a.MemberMci_IDNO,
           a.TypeDebt_CODE
      FROM #Towed_P1  a
     WHERE a.TypeBucket_CODE NOT IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE)
       AND NOT EXISTS (SELECT 1
                         FROM #Towed_P1  b
                        WHERE b.Case_IDNO = a.Case_IDNO
                          AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                          AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                          AND b.TypeBucket_CODE = @Lc_ExptTypeBucket_CODE));

   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record
   SET @Ls_Sql_TEXT = 'INSERT_TBUMP';

   SET @Ls_Sqldata_TEXT = '';

   INSERT #Tbump_P1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           ArrToBePaid_AMNT,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Expt_AMNT,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           MonthSupport_AMNT,
           MemberMci_IDNO,
           TypeDebt_CODE)
   (SELECT Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           ArrToBePaid_AMNT,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Expt_AMNT,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           MonthSupport_AMNT,
           MemberMci_IDNO,
           TypeDebt_CODE
      FROM #Texpt_P1 t
     WHERE ArrToBePaid_AMNT > 0);

   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record
   SET @Ls_Sql_TEXT = 'INSERT_TCARR_CS';
   SET @Ls_Sqldata_TEXT = '';

  DECLARE CarrCS_Cur INSENSITIVE CURSOR FOR
   SELECT t.PrDistribute_QNTY,
          SUM (t.ArrToBePaid_AMNT) AS ln_ArrToBePaid_AMNT
     FROM #Tbump_P1 t
    WHERE t.TypeBucket_CODE = 'C'
      AND t.TypeOrder_CODE != 'V'
      AND t.ArrToBePaid_AMNT > 0
    GROUP BY t.PrDistribute_QNTY
    ORDER BY t.PrDistribute_QNTY;
    
   SET @Ln_ReceiptUsed_AMNT = 0;
   SET @Ln_ReceiptUsed_AMNT = @Ln_Receipt_AMNT;
   SET @Ls_Sql_TEXT = 'OPEN CarrCS_Cur -1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN CarrCS_Cur;

   SET @Ls_Sql_TEXT = 'FETCH CarrCS_Cur -1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH CarrCS_Cur INTO @Ln_CarrCSCur_PrDistribute_QNTY, @Ln_CarrCSCur_ArrToBePaid_AMNT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -1';
   SET @Ls_Sqldata_TEXT = '';

-- Loop Started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_TCARR_CS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL('0','')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_CsTypeBucket_CODE,'')+ ', Arrear_AMNT = ' + ISNULL(CAST( @Ln_CarrCSCur_ArrToBePaid_AMNT AS VARCHAR ),'')+ ', PrDistribute_QNTY = ' + ISNULL(CAST( @Ln_CarrCSCur_PrDistribute_QNTY AS VARCHAR ),'');

     INSERT #Tcarr_P1
            (Case_IDNO,
             TypeBucket_CODE,
             Arrear_AMNT,
             Receipt_AMNT,
             PrDistribute_QNTY)
     (SELECT 0 AS Case_IDNO,
             @Lc_CsTypeBucket_CODE AS TypeBucket_CODE,
             @Ln_CarrCSCur_ArrToBePaid_AMNT AS Arrear_AMNT,
             CASE SIGN (@Ln_CarrCSCur_ArrToBePaid_AMNT - @Ln_ReceiptUsed_AMNT)
              WHEN -1
               THEN @Ln_CarrCSCur_ArrToBePaid_AMNT
              ELSE @Ln_ReceiptUsed_AMNT
             END AS Receipt_AMNT,
             @Ln_CarrCSCur_PrDistribute_QNTY AS PrDistribute_QNTY);

     -- No need to Handle the Exception here as the Batch can Proceed further even if the
     -- above Insert Fail to insert any record
     SET @Ln_ReceiptUsed_AMNT = @Ln_ReceiptUsed_AMNT - @Ln_CarrCSCur_ArrToBePaid_AMNT;

     IF @Ln_ReceiptUsed_AMNT < 0
      BEGIN
       SET @Ln_ReceiptUsed_AMNT = 0;

       BREAK;
      END

     SET @Ls_Sql_TEXT = 'FETCH CarrCS_Cur -2';
     SET @Ls_Sqldata_TEXT = '';
     
     FETCH CarrCS_Cur INTO @Ln_CarrCSCur_PrDistribute_QNTY, @Ln_CarrCSCur_ArrToBePaid_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE CarrCS_Cur;

   DEALLOCATE CarrCS_Cur;
  
   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record
   SET @Ln_ReceiptUsed_AMNT = 0;
   SET @Ln_ReceiptUsed_AMNT = @Ln_Receipt_AMNT;
   
   SET @Ls_Sql_TEXT = 'SELECT @Ln_ReceiptUsed_AMNT';
   SET @Ls_Sqldata_TEXT = 'TypeBucket_CODE = ' + ISNULL(@Lc_CsTypeBucket_CODE,'');

   SELECT @Ln_ReceiptUsed_AMNT = @Ln_ReceiptUsed_AMNT - ISNULL (SUM (t.Receipt_AMNT), 0)
     FROM #Tcarr_P1 t
    WHERE t.TypeBucket_CODE = @Lc_CsTypeBucket_CODE;

   IF @Ln_ReceiptUsed_AMNT < 0
    BEGIN
     SET @Ln_ReceiptUsed_AMNT = 0;
    END

   IF @Ln_ReceiptUsed_AMNT > 0
    BEGIN
     BEGIN
  
    DECLARE CarrExpt_Cur INSENSITIVE CURSOR FOR
     SELECT t.PrDistribute_QNTY,
            SUM (t.ArrToBePaid_AMNT) AS ArrToBePaid_AMNT
       FROM #Tbump_P1 t
      WHERE t.TypeBucket_CODE = 'E'
        AND t.TypeOrder_CODE != 'V'
        AND t.ArrToBePaid_AMNT > 0
      GROUP BY t.PrDistribute_QNTY
      ORDER BY t.PrDistribute_QNTY;

      SET @Ls_Sql_TEXT = 'OPEN CarrExpt_Cur -1';
      SET @Ls_Sqldata_TEXT = '';
      
      OPEN CarrExpt_Cur;

      SET @Ls_Sql_TEXT = 'FETCH CarrExpt_Cur -1';
      SET @Ls_Sqldata_TEXT = '';

      FETCH CarrExpt_Cur INTO @Ln_CarrExptCur_PrDistribute_QNTY, @Ln_CarrExptCur_ArrToBePaid_AMNT;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	  -- LOOP Started
      WHILE @Li_FetchStatus_QNTY = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT_TCARR_EXPT';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL('0','')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_ExptTypeBucket_CODE,'')+ ', Arrear_AMNT = ' + ISNULL(CAST( @Ln_CarrExptCur_ArrToBePaid_AMNT AS VARCHAR ),'')+ ', PrDistribute_QNTY = ' + ISNULL(CAST( @Ln_CarrExptCur_PrDistribute_QNTY AS VARCHAR ),'');

        INSERT #Tcarr_P1
               (Case_IDNO,
                TypeBucket_CODE,
                Arrear_AMNT,
                Receipt_AMNT,
                PrDistribute_QNTY)
        VALUES ( 0,   --Case_IDNO
                 @Lc_ExptTypeBucket_CODE,   --TypeBucket_CODE
                 @Ln_CarrExptCur_ArrToBePaid_AMNT,   --Arrear_AMNT
                 CASE SIGN (@Ln_CarrExptCur_ArrToBePaid_AMNT - @Ln_ReceiptUsed_AMNT)
                  WHEN -1
                   THEN @Ln_CarrExptCur_ArrToBePaid_AMNT
                  ELSE @Ln_ReceiptUsed_AMNT
                 END,   --Receipt_AMNT
                 @Ln_CarrExptCur_PrDistribute_QNTY  --PrDistribute_QNTY
                 );
        
        -- above Insert Fail to insert any record
        SET @Ln_ReceiptUsed_AMNT = @Ln_ReceiptUsed_AMNT - @Ln_CarrExptCur_ArrToBePaid_AMNT;

        IF @Ln_ReceiptUsed_AMNT < 0
         BEGIN
          SET @Ln_ReceiptUsed_AMNT = 0;

          BREAK;
         END

        SET @Ls_Sql_TEXT = 'FETCH CarrExpt_Cur -2';
        SET @Ls_Sqldata_TEXT = '';
        
        FETCH CarrExpt_Cur INTO @Ln_CarrExptCur_PrDistribute_QNTY, @Ln_CarrExptCur_ArrToBePaid_AMNT;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       END

      CLOSE CarrExpt_Cur;

      DEALLOCATE CarrExpt_Cur;
     END

     SELECT @Ln_CasePrev_IDNO = 0,
            @Ln_Cum_AMNT = 0;

     BEGIN

      DECLARE BumpExpt_Cur INSENSITIVE CURSOR FOR
       SELECT t.PrDistribute_QNTY,
              SUM (t.ArrToBePaid_AMNT) AS ln_amt_pr
         FROM #Tbump_P1 t
        WHERE t.TypeOrder_CODE != 'V'
          AND t.TypeBucket_CODE = 'E'
        GROUP BY t.PrDistribute_QNTY
        ORDER BY t.PrDistribute_QNTY;
          
      SET @Ls_Sql_TEXT = 'OPEN BumpExpt_Cur-1';
      SET @Ls_Sqldata_TEXT = '';
      
      OPEN BumpExpt_Cur;

      SET @Ls_Sql_TEXT = 'FETCH BumpExpt_Cur-1';
      SET @Ls_Sqldata_TEXT = '';

      FETCH BumpExpt_Cur INTO @Ln_BumpExptCur_PrDistribute_QNTY, @Ln_BumpExptCur_Pr_AMNT;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      SET @Ls_Sql_TEXT = 'WHILE-2';
	  SET @Ls_Sqldata_TEXT = '';
	  -- LOOP Started
      WHILE @Li_FetchStatus_QNTY = 0
       BEGIN
        IF @Ln_CasePrev_IDNO != @Ln_BumpExptCur_PrDistribute_QNTY
         BEGIN
          
          SELECT @Ln_Cum_AMNT = 0,
                 @Ln_CasePrev_IDNO = @Ln_BumpExptCur_PrDistribute_QNTY;
         END

        SET @Ls_Sql_TEXT = 'INSERT_TPRTL_EXPT';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL('0','')+ ', PrDistribute_QNTY = ' + ISNULL(CAST( @Ln_BumpExptCur_PrDistribute_QNTY AS VARCHAR ),'')+ ', PrArrToBePaid_AMNT = ' + ISNULL(CAST( @Ln_BumpExptCur_Pr_AMNT AS VARCHAR ),'')+ ', CumArrToBePaid_AMNT = ' + ISNULL(CAST( @Ln_Cum_AMNT AS VARCHAR ),'');

        INSERT #Tprtl_P1
               (Case_IDNO,
                PrDistribute_QNTY,
                PrArrToBePaid_AMNT,
                CumArrToBePaid_AMNT)
        VALUES (0,   --Case_IDNO
                @Ln_BumpExptCur_PrDistribute_QNTY,   --PrDistribute_QNTY
                @Ln_BumpExptCur_Pr_AMNT,   --PrArrToBePaid_AMNT
                @Ln_Cum_AMNT  --CumArrToBePaid_AMNT
				);
        
        SET @Ln_Cum_AMNT = @Ln_Cum_AMNT + @Ln_BumpExptCur_Pr_AMNT;

        FETCH BumpExpt_Cur INTO @Ln_BumpExptCur_PrDistribute_QNTY, @Ln_BumpExptCur_Pr_AMNT;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       END

      CLOSE BumpExpt_Cur;

      DEALLOCATE BumpExpt_Cur;
     END
    END

   SET @Ls_Sql_TEXT = 'SELECT @Ln_TotArrears_AMNT, @Ln_Case_QNTY';
   SET @Ls_Sqldata_TEXT = '';
   
   SELECT @Ln_TotArrears_AMNT = 0,
          @Ln_Case_QNTY = 0;

   SET @Ls_Sql_TEXT = 'SELECT @Ln_TotArrears_AMNT, @Ln_Case_QNTY';
   SET @Ls_Sqldata_TEXT = '';
   
   SELECT @Ln_TotArrears_AMNT = ISNULL (SUM (ArrToBePaid_AMNT), 0),
          @Ln_Case_QNTY = COUNT (1)
     FROM #Tbump_P1 t
    WHERE t.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
      AND t.TypeBucket_CODE NOT IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE)
      AND t.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, 
                            @Lc_TypeDebtGeneticTest_CODE,@Lc_TypeDebtNcpNsfFee_CODE);

   SET @Ln_Loop_QNTY = 0;

   IF @Ln_TotArrears_AMNT > 0
      AND @Ln_ReceiptUsed_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT @Ln_CaseUsed_AMNT,@Ln_RctCase_AMNT,@Ln_RctEx_AMNT';
     SET @Ls_Sqldata_TEXT = '';
     
     SELECT @Ln_CaseUsed_AMNT = 0,
            @Ln_RctCase_AMNT = 0,
            @Ln_RctEx_AMNT = 0;

     IF @Ln_ReceiptUsed_AMNT > @Ln_TotArrears_AMNT
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT @Ln_RctEx_AMNT';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_RctEx_AMNT = @Ln_ReceiptUsed_AMNT - @Ln_TotArrears_AMNT,
              @Ln_ReceiptUsed_AMNT = @Ln_TotArrears_AMNT;
      END

     BEGIN
  
    DECLARE Carr_Cur INSENSITIVE CURSOR FOR
     SELECT t.Case_IDNO,
            SUM (t.ArrToBePaid_AMNT) AS ln_amt_pr
       FROM #Tbump_P1 t
      WHERE t.TypeOrder_CODE != 'V'
        AND t.TypeBucket_CODE NOT IN ('C', 'E')
        AND t.TypeDebt_CODE IN ('CS', 'MS', 'SS', 'GT', 'NF')
      GROUP BY t.Case_IDNO
      ORDER BY t.Case_IDNO;

      SET @Ls_Sql_TEXT = 'OPEN Carr_Cur - 1';
      SET @Ls_Sqldata_TEXT = '';
      
      OPEN Carr_Cur;

      SET @Ls_Sql_TEXT = 'FETCH Carr_Cur - 1';
      SET @Ls_Sqldata_TEXT = '';

      FETCH Carr_Cur INTO @Ln_CarrCur_Case_IDNO, @Ln_CarrCur_Pr_AMNT;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	  -- LOOP Started
      WHILE @Li_FetchStatus_QNTY = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT @Ln_Loop_QNTY, @Ln_RctCase_AMNT';
        SET @Ls_Sqldata_TEXT = '';

        SELECT @Ln_Loop_QNTY = @Ln_Loop_QNTY + 1,
               @Ln_RctCase_AMNT = 0;

        IF @Ln_Loop_QNTY = @Ln_Case_QNTY
         BEGIN
          IF @Ln_CarrCur_Pr_AMNT >= (@Ln_ReceiptUsed_AMNT - @Ln_CaseUsed_AMNT)
           BEGIN
            SET @Ln_RctCase_AMNT = @Ln_ReceiptUsed_AMNT - @Ln_CaseUsed_AMNT;
           END
          ELSE
           BEGIN
            SET @Ln_RctCase_AMNT = @Ln_CarrCur_Pr_AMNT;
           END

          SET @Ln_CaseUsed_AMNT = @Ln_CaseUsed_AMNT + @Ln_RctCase_AMNT;
         END
        ELSE
         BEGIN
         SET @Ls_Sql_TEXT = 'SELECT @Ln_RctCase_AMNT, @Ln_CaseUsed_AMNT';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @Ln_RctCase_AMNT = ROUND (@Ln_CarrCur_Pr_AMNT * @Ln_ReceiptUsed_AMNT / @Ln_TotArrears_AMNT, 2),
                 @Ln_CaseUsed_AMNT = @Ln_CaseUsed_AMNT + @Ln_RctCase_AMNT;
         END

        SET @Ls_Sql_TEXT = 'INSERT_TCARR_ARR';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CarrCur_Case_IDNO AS VARCHAR ),'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_ArrearBucketGroup_CODE,'')+ ', Arrear_AMNT = ' + ISNULL(CAST( @Ln_CarrCur_Pr_AMNT AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_RctCase_AMNT AS VARCHAR ),'');

        INSERT #Tcarr_P1
               (Case_IDNO,
                TypeBucket_CODE,
                Arrear_AMNT,
                Receipt_AMNT)
        VALUES (@Ln_CarrCur_Case_IDNO,   --Case_IDNO
                @Lc_ArrearBucketGroup_CODE,   --TypeBucket_CODE
                @Ln_CarrCur_Pr_AMNT,   --Arrear_AMNT
                @Ln_RctCase_AMNT  --Receipt_AMNT
				);

        -- above Insert Fail to insert any record
        SET @Ls_Sql_TEXT = 'FETCH Carr_Cur - 2';
		SET @Ls_Sqldata_TEXT = '';
		
        FETCH Carr_Cur INTO @Ln_CarrCur_Case_IDNO, @Ln_CarrCur_Pr_AMNT;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       END

      CLOSE Carr_Cur;

      DEALLOCATE Carr_Cur;
     END

     SET @Ln_ReceiptUsed_AMNT = @Ln_ReceiptUsed_AMNT - @Ln_CaseUsed_AMNT;

     IF @Ln_ReceiptUsed_AMNT < 0
      BEGIN
       SET @Ln_ReceiptUsed_AMNT = 0;
      END

     IF @Ln_RctEx_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT @Ln_ReceiptUsed_AMNT, @Ln_RctEx_AMNT';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_ReceiptUsed_AMNT = @Ln_ReceiptUsed_AMNT + @Ln_RctEx_AMNT,
              @Ln_RctEx_AMNT = 0;
      END
    END

   SET @Ln_Cum_AMNT = 0;
   SET @Ln_CasePrev_IDNO = 0;

  DECLARE BumpArr_Cur INSENSITIVE CURSOR FOR
   SELECT t.Case_IDNO,
          t.PrDistribute_QNTY,
          SUM (t.ArrToBePaid_AMNT) AS ln_amt_pr
     FROM #Tbump_P1 t
    WHERE t.TypeOrder_CODE != 'V'
      AND t.TypeBucket_CODE NOT IN ('C', 'E')
      AND t.TypeDebt_CODE IN ('CS', 'MS', 'SS', 'GT', 'NF')
    GROUP BY t.Case_IDNO,
             t.PrDistribute_QNTY
    ORDER BY t.Case_IDNO,
             t.PrDistribute_QNTY;
             
   SET @Ls_Sql_TEXT = 'OPEN BumpArr_Cur-1';
   SET @Ls_Sqldata_TEXT = '';
   
   OPEN BumpArr_Cur;

   SET @Ls_Sql_TEXT = 'FETCH BumpArr_Cur-1';
   SET @Ls_Sqldata_TEXT = '';
   
   FETCH BumpArr_Cur INTO @Ln_BumpArrCur_Case_IDNO, @Ln_BumpArrCur_PrDistribute_QNTY, @Ln_BumpArrCur_Pr_AMNT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-3';
   SET @Ls_Sqldata_TEXT = '';
	  -- LOOP Started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     IF @Ln_CasePrev_IDNO != @Ln_BumpArrCur_Case_IDNO
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT @Ln_Cum_AMNT, @Ln_CasePrev_IDNO';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_Cum_AMNT = 0,
              @Ln_CasePrev_IDNO = @Ln_BumpArrCur_Case_IDNO;
      END

     SET @Ls_Sql_TEXT = 'INSERT_TPRTL_ARR';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_BumpArrCur_Case_IDNO AS VARCHAR ),'')+ ', PrDistribute_QNTY = ' + ISNULL(CAST( @Ln_BumpArrCur_PrDistribute_QNTY AS VARCHAR ),'')+ ', PrArrToBePaid_AMNT = ' + ISNULL(CAST( @Ln_BumpArrCur_Pr_AMNT AS VARCHAR ),'')+ ', CumArrToBePaid_AMNT = ' + ISNULL(CAST( @Ln_Cum_AMNT AS VARCHAR ),'');

     INSERT #Tprtl_P1
            (Case_IDNO,
             PrDistribute_QNTY,
             PrArrToBePaid_AMNT,
             CumArrToBePaid_AMNT)
     VALUES (@Ln_BumpArrCur_Case_IDNO,   --Case_IDNO
             @Ln_BumpArrCur_PrDistribute_QNTY,   --PrDistribute_QNTY
             @Ln_BumpArrCur_Pr_AMNT,   --PrArrToBePaid_AMNT
             @Ln_Cum_AMNT  --CumArrToBePaid_AMNT
			);

     -- above Insert Fail to insert any record
     SET @Ln_Cum_AMNT = @Ln_Cum_AMNT + @Ln_BumpArrCur_Pr_AMNT;
     SET @Ls_Sql_TEXT = 'FETCH BumpArr_Cur-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH BumpArr_Cur INTO @Ln_BumpArrCur_Case_IDNO, @Ln_BumpArrCur_PrDistribute_QNTY, @Ln_BumpArrCur_Pr_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE BumpArr_Cur;

   DEALLOCATE BumpArr_Cur;
   
   SET @Ls_Sql_TEXT = 'INSERT_TTPAD';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #Ttpad_P1
               (Seq_IDNO,
                TypeBucket_CODE,
                PrDistribute_QNTY,
                ArrPaid_AMNT,
                Rounded_AMNT,
                ArrToBePaid_AMNT,
                Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                TypeOrder_CODE,
                TypeWelfare_CODE,
                TypeDebt_CODE,
                Batch_DATE,
                SourceBatch_CODE,
                Batch_NUMB,
                SeqReceipt_NUMB)
   (SELECT ROW_NUMBER () OVER (ORDER BY rnm) AS Seq_IDNO,
           a.TypeBucket_CODE,
           a.PrDistribute_QNTY,
           dbo.BATCH_COMMON_DIST_FN$SF_CALL_ARR_PAID (d.Receipt_AMNT, ISNULL (c.CumArrToBePaid_AMNT, 0), c.PrArrToBePaid_AMNT, ArrToBePaid_AMNT) AS ArrPaid_AMNT,
           dbo.BATCH_COMMON_DIST_FN$SF_CAL_ROUND (d.Receipt_AMNT, ISNULL (c.CumArrToBePaid_AMNT, 0), c.PrArrToBePaid_AMNT, ArrToBePaid_AMNT) AS Rounded_AMNT,
           ArrToBePaid_AMNT,
           a.Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           TypeDebt_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB
      FROM #Tbump_P1 a,
           (SELECT t.PrDistribute_QNTY,
                   SUM (t.ArrToBePaid_AMNT) PrArrToBePaid_AMNT,
                   0 CumArrToBePaid_AMNT
              FROM #Tbump_P1 t
             WHERE t.TypeBucket_CODE = @Lc_CsTypeBucket_CODE
             GROUP BY t.PrDistribute_QNTY) c,
           #Tcarr_P1 d,
           (SELECT 0 AS rnm) AS e
     WHERE a.PrDistribute_QNTY = c.PrDistribute_QNTY
       AND a.TypeBucket_CODE = @Lc_CsTypeBucket_CODE
       AND a.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
       AND d.TypeBucket_CODE = @Lc_CsTypeBucket_CODE
       AND a.PrDistribute_QNTY = d.PrDistribute_QNTY
       AND d.Receipt_AMNT > 0)
   UNION
   (SELECT ROW_NUMBER () OVER (ORDER BY rnm) AS Seq_IDNO,
           a.TypeBucket_CODE,
           a.PrDistribute_QNTY,
           dbo.BATCH_COMMON_DIST_FN$SF_CALL_ARR_PAID (d.Receipt_AMNT, ISNULL (c.CumArrToBePaid_AMNT, 0), c.PrArrToBePaid_AMNT, ArrToBePaid_AMNT) AS ArrPaid_AMNT,
           dbo.BATCH_COMMON_DIST_FN$SF_CAL_ROUND (d.Receipt_AMNT, ISNULL (c.CumArrToBePaid_AMNT, 0), c.PrArrToBePaid_AMNT, ArrToBePaid_AMNT) AS Rounded_AMNT,
           ArrToBePaid_AMNT,
           a.Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           TypeDebt_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB
      FROM #Tbump_P1 a,
           #Tprtl_P1 c,
           #Tcarr_P1 d,
           (SELECT 0 AS rnm) AS e
     WHERE a.PrDistribute_QNTY = c.PrDistribute_QNTY
       AND a.TypeBucket_CODE = @Lc_ExptTypeBucket_CODE
       AND a.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
       AND d.TypeBucket_CODE = @Lc_ExptTypeBucket_CODE
       AND a.PrDistribute_QNTY = d.PrDistribute_QNTY
       AND d.Receipt_AMNT > 0)
   UNION
   (SELECT ROW_NUMBER () OVER (ORDER BY rnm) AS Seq_IDNO,
           a.TypeBucket_CODE,
           a.PrDistribute_QNTY,
           dbo.BATCH_COMMON_DIST_FN$SF_CALL_ARR_PAID (d.Receipt_AMNT, ISNULL (c.CumArrToBePaid_AMNT, 0), c.PrArrToBePaid_AMNT, ArrToBePaid_AMNT) AS ArrPaid_AMNT,
           dbo.BATCH_COMMON_DIST_FN$SF_CAL_ROUND (d.Receipt_AMNT, ISNULL (c.CumArrToBePaid_AMNT, 0), c.PrArrToBePaid_AMNT, ArrToBePaid_AMNT) AS Rounded_AMNT,
           ArrToBePaid_AMNT,
           a.Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           TypeDebt_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB
      FROM #Tbump_P1 a,
           #Tprtl_P1 c,
           #Tcarr_P1 d,
           (SELECT 0 AS rnm) AS e
     WHERE a.Case_IDNO = c.Case_IDNO
       AND c.Case_IDNO = d.Case_IDNO
       AND a.PrDistribute_QNTY = c.PrDistribute_QNTY
       AND a.TypeDebt_CODE IN
           (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE,
            @Lc_TypeDebtGeneticTest_CODE, @Lc_TypeDebtNcpNsfFee_CODE)
       AND a.TypeBucket_CODE NOT IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE)
       AND a.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
       AND d.TypeBucket_CODE = @Lc_ArrearBucketGroup_CODE
       AND d.Receipt_AMNT > 0);

   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record
   SET @Ls_Sql_TEXT = 'INSERT #TPAID';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #Tpaid_P1
               (Seq_IDNO,
                TypeBucket_CODE,
                PrDistribute_QNTY,
                ArrPaid_AMNT,
                Rounded_AMNT,
                ArrToBePaid_AMNT,
                Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                TypeOrder_CODE,
                TypeWelfare_CODE,
                TypeDebt_CODE,
                Batch_DATE,
                SourceBatch_CODE,
                Batch_NUMB,
                SeqReceipt_NUMB)
   (SELECT ROW_NUMBER () OVER (ORDER BY rnm) AS Seq_IDNO,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           ArrPaid_AMNT,
           Rounded_AMNT,
           ArrToBePaid_AMNT,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           TypeDebt_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB
      FROM #Ttpad_P1 t,
           (SELECT 0 AS rnm) AS a);

   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record
   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT_TPAID';
    SET @Ls_Sqldata_TEXT = '';

    SELECT @Ln_Diff_AMNT = (@Ln_Receipt_AMNT - ISNULL (SUM (t.ArrPaid_AMNT), 0))
      FROM #Tpaid_P1 t;
   END

   IF @Ln_Diff_AMNT < 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_TPAID1';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_MaxSeq_IDNO = ISNULL (MIN (a.Seq_IDNO), 0)
       FROM #Tpaid_P1  a
      WHERE a.Rounded_AMNT = .01
        AND ABS (@Ln_Diff_AMNT) = (SELECT SUM (b.Rounded_AMNT)
                                     FROM #Tpaid_P1  b
                                    WHERE b.Seq_IDNO <= a.Seq_IDNO
                                      AND b.ArrPaid_AMNT > 0);
    END

   IF @Ln_Diff_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_TPAID2';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_MaxSeq_IDNO = ISNULL (MIN (a.Seq_IDNO), 0)
       FROM #Tpaid_P1  a
      WHERE a.Rounded_AMNT = .01
        AND ABS (@Ln_Diff_AMNT) = (SELECT SUM (b.Rounded_AMNT)
                                     FROM #Tpaid_P1  b
                                    WHERE b.Seq_IDNO <= a.Seq_IDNO
                                      AND b.ArrPaid_AMNT < b.ArrToBePaid_AMNT);
    END

   IF @Ln_Diff_AMNT != 0
      AND @Ln_MaxSeq_IDNO > 0
    BEGIN
		SET @Ls_Sql_TEXT = 'Remaining Amount';
		SET @Ls_Sqldata_TEXT = '';
    END
   ELSE
    BEGIN
     SET @An_Remaining_AMNT = @An_Remaining_AMNT + @Ln_Diff_AMNT;
    END

   IF @Ln_MaxSeq_IDNO > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE_TPAID';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL (CAST (@Ln_MaxSeq_IDNO AS VARCHAR), '');

     UPDATE #Tpaid_P1
        SET ArrPaid_AMNT = ArrPaid_AMNT + .01
      WHERE Rounded_AMNT = .01
        AND Seq_IDNO <= @Ln_MaxSeq_IDNO
        AND @Ln_Diff_AMNT > 0
        AND ArrPaid_AMNT < ArrToBePaid_AMNT;

     SET @Ls_Sql_TEXT = 'UPDATE_TPAID';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL (CAST (@Ln_MaxSeq_IDNO AS VARCHAR), '');

     UPDATE #Tpaid_P1
        SET ArrPaid_AMNT = ArrPaid_AMNT - .01
      WHERE Rounded_AMNT = .01
        AND Seq_IDNO <= @Ln_MaxSeq_IDNO
        AND @Ln_Diff_AMNT < 0
        AND ArrPaid_AMNT > 0;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('LOCAL', 'BumpArr_Cur') IN (0, 1)
    BEGIN
     CLOSE BumpArr_Cur;

     DEALLOCATE BumpArr_Cur;
    END

   IF CURSOR_STATUS ('LOCAL', 'Carr_Cur') IN (0, 1)
    BEGIN
     CLOSE Carr_Cur;

     DEALLOCATE Carr_Cur;
    END

   IF CURSOR_STATUS ('LOCAL', 'CarrExpt_Cur') IN (0, 1)
    BEGIN
     CLOSE CarrExpt_Cur;

     DEALLOCATE CarrExpt_Cur;
    END

   IF CURSOR_STATUS ('LOCAL', 'BumpExpt_Cur') IN (0, 1)
    BEGIN
     CLOSE BumpExpt_Cur;

     DEALLOCATE BumpExpt_Cur;
    END

   IF CURSOR_STATUS ('LOCAL', 'CarrCS_Cur') IN (0, 1)
    BEGIN
     CLOSE CarrCS_Cur;

     DEALLOCATE CarrCS_Cur;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
