/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_LSUP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_LSUP
Programmer Name 	: IMP Team
Description			: This Procedure will insert the Records in the LSUP_Y1 (LSUP_Y1) Table for the
					  Distributed RCTH_Y1.  It also takes care of Assign/Un-Assign, when dealing with the
					  Retro RCTH_Y1.
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: BATCH_FIN_REG_DISTRIBUTION$SF_DIST_AMT, BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR, 
				      BATCH_COMMON$SP_CIRCULAR_RULE, BATCH_FIN_REG_DISTRIBUTION$SP_INCREASE_OWED_4_VOL_RCPT
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_LSUP]
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ac_SourceReceipt_CODE    CHAR(2),
 @Ac_TypePosting_CODE      CHAR(1),
 @An_PayorMCI_IDNO         NUMERIC(10),
 @Ad_Receipt_DATE          DATE,
 @Ad_ReceiptOrig_DATE      DATETIME2,
 @An_EventGlobalSeq_NUMB   NUMERIC(19) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE          DATE OUTPUT,
 @Ac_ReleasedFrom_CODE     CHAR(4) OUTPUT,
 @Ac_VoluntaryProcess_INDC CHAR (1) OUTPUT,
 @Ad_Run_DATE              DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_ReceiptDistributed1820_NUMB  INT = 1820,
           @Li_CircularRuleRecord1070_NUMB  INT = 1070,
           @Lc_No_INDC                      CHAR (1) = 'N',
           @Lc_StatusFailed_CODE            CHAR (1) = 'F',
           @Lc_StatusSuccess_CODE           CHAR (1) = 'S',
           @Lc_TypeRecordOriginal_CODE      CHAR (1) = 'O',
           @Lc_Yes_INDC                     CHAR (1) = 'Y',
           @Lc_TypeWelfareNonTanf_CODE      CHAR (1) = 'N',
           @Lc_TypeWelfareMedicaid_CODE     CHAR (1) = 'M',
           @Lc_Space_TEXT                   CHAR (1) = ' ',
           @Lc_TypeWelfareTanf_CODE         CHAR (1) = 'A',
           @Lc_TypeWelfareNonIve_CODE       CHAR (1) = 'F',
           @Lc_TypeWelfareFosterCare_CODE   CHAR (1) = 'J',
           @Lc_TypeWelfareNonIvd_CODE       CHAR (1) = 'H',
           @Lc_TypeRecordPrior_CODE         CHAR (1) = 'P',
           @Lc_TypeDebtMedicaid_CODE        CHAR (2) = 'DS',
           @Lc_TypeDebtIntMedicaid_CODE     CHAR (2) = 'DI',
           @Lc_TypeDebtMedicalSupp_CODE     CHAR (2) = 'MS',
           @Lc_TypeDebtIntChildSupp_CODE    CHAR (2) = 'CI',
           @Lc_TypeDebtIntSpousalSupp_CODE  CHAR (2) = 'SI',
           @Lc_TypeDebtIntMedicalSupp_CODE  CHAR (2) = 'MI',
           @Lc_SourceReceiptVoluntary_CODE  CHAR (2) = 'VN',
           @Lc_TypeEntityCase_CODE          CHAR (4) = 'CASE',
           @Lc_TypeEntityRctno_CODE         CHAR (5) = 'RCTNO',
           @Lc_Job_ID                       CHAR (7) = 'DEB0560',
           @Lc_ProcessRdist_ID              CHAR (10) = 'DEB0560',
           @Lc_BatchRunUser_TEXT            CHAR (30) = 'BATCH',
           @Ls_Process_NAME                 VARCHAR (100) = 'BATCH_FIN_REG_DISTRIBUTION',
           @Ls_Procedure_NAME               VARCHAR (100) = 'SP_INSERT_LSUP',
           @Ld_High_DATE                    DATE = '12/31/9999',
           @Ld_Low_DATE                     DATE = '01/01/0001';
  DECLARE  @Ln_Value_NUMB                  NUMERIC (1),
           @Ln_Rec_QNTY                    NUMERIC (3) = 0,
           @Ln_MemberMci_IDNO              NUMERIC (10),
           @Ln_ArrPaa_AMNT                 NUMERIC (11,2) = 0,
           @Ln_ArrUda_AMNT                 NUMERIC (11,2) = 0,
           @Ln_ArrUpa_AMNT                 NUMERIC (11,2) = 0,
           @Ln_ArrCaa_AMNT                 NUMERIC (11,2) = 0,
           @Ln_ArrTaa_AMNT                 NUMERIC (11,2) = 0,
           @Ln_ArrNaa_AMNT                 NUMERIC (11,2) = 0,
           @Ln_TransactionPaa_AMNT         NUMERIC (11,2),
           @Ln_TransactionUda_AMNT         NUMERIC (11,2),
           @Ln_TransactionTaa_AMNT         NUMERIC (11,2),
           @Ln_TransactionCaa_AMNT         NUMERIC (11,2),
           @Ln_TransactionUpa_AMNT         NUMERIC (11,2),
           @Ln_TransactionNaa_AMNT         NUMERIC (11,2),
           @Ln_OweCur_AMNT                 NUMERIC (11,2),
           @Ln_OweExpt_AMNT                NUMERIC (11,2),
           @Ln_OwePaa_AMNT                 NUMERIC (11,2),
           @Ln_OweUda_AMNT                 NUMERIC (11,2),
           @Ln_OweUpa_AMNT                 NUMERIC (11,2),
           @Ln_OweTaa_AMNT                 NUMERIC (11,2),
           @Ln_OweCaa_AMNT                 NUMERIC (11,2),
           @Ln_OweNaa_AMNT                 NUMERIC (11,2),
           @Ln_OweIvef_AMNT                NUMERIC (11,2),
           @Ln_OweNffc_AMNT                NUMERIC (11,2),
           @Ln_OweNonIvd_AMNT              NUMERIC (11,2),
           @Ln_OweMedi_AMNT                NUMERIC (11,2),
           @Ln_AppCur_AMNT                 NUMERIC (11,2),
           @Ln_AppExpt_AMNT                NUMERIC (11,2),
           @Ln_AppPaa_AMNT                 NUMERIC (11,2),
           @Ln_AppUda_AMNT                 NUMERIC (11,2),
           @Ln_AppUpa_AMNT                 NUMERIC (11,2),
           @Ln_AppTaa_AMNT                 NUMERIC (11,2),
           @Ln_AppCaa_AMNT                 NUMERIC (11,2),
           @Ln_AppNaa_AMNT                 NUMERIC (11,2),
           @Ln_AppIvef_AMNT                NUMERIC (11,2),
           @Ln_AppNffc_AMNT                NUMERIC (11,2),
           @Ln_AppNonIvd_AMNT              NUMERIC (11,2),
           @Ln_AppMedi_AMNT                NUMERIC (11,2),
           @Ln_AppFuture_AMNT              NUMERIC (11,2),
           @Ln_MtdCurSup_AMNT              NUMERIC (11,2),
           @Ln_TransactionExpt_AMNT        NUMERIC (11,2),
           @Ln_TransactionIvef_AMNT        NUMERIC (11,2),
           @Ln_TransactionNffc_AMNT        NUMERIC (11,2),
           @Ln_TransactionNonIvd_AMNT      NUMERIC (11,2),
           @Ln_TransactionMedi_AMNT        NUMERIC (11,2),
           @Ln_TransactionPaaOrig_AMNT     NUMERIC (11,2),
           @Ln_TransactionUdaOrig_AMNT     NUMERIC (11,2),
           @Ln_TransactionTaaOrig_AMNT     NUMERIC (11,2),
           @Ln_TransactionCaaOrig_AMNT     NUMERIC (11,2),
           @Ln_TransactionUpaOrig_AMNT     NUMERIC (11,2),
           @Ln_TransactionNaaOrig_AMNT     NUMERIC (11,2),
           @Ln_TransactionIvefOrig_AMNT    NUMERIC (11,2),
           @Ln_TransactionMediOrig_AMNT    NUMERIC (11,2),
           @Ln_TransactionNffcOrig_AMNT    NUMERIC (11,2),
           @Ln_TransactionNonIvdOrig_AMNT  NUMERIC (11,2),
           @Ln_CurSup_NUMB                 NUMERIC (11,2) = 0,
           @Ln_Error_NUMB                  NUMERIC (11),
           @Ln_ErrorLine_NUMB              NUMERIC (11),
           @Ln_Order_IDNO                  NUMERIC (15),
           @Ln_EventGlobalSeqCrle_NUMB     NUMERIC (19),
           @Li_FetchStatus_QNTY            SMALLINT,
           @Li_Rowcount_QNTY               SMALLINT,
           @Lc_TypeWelfare_CODE            CHAR (1),
           @Lc_Rec_ID                      CHAR (1),
           @Lc_FirstTime_TEXT              CHAR (1),
           @Lc_TypeWelf_CODE               CHAR (1),
           @Lc_Msg_CODE                    CHAR (1),
           @Lc_CaseFlag_INDC               CHAR (1),
           @Lc_OrderFlag_INDC              CHAR (1),
           @Lc_ObleFlag_INDC               CHAR (1),
           @Lc_OrderType_CODE              CHAR (1),
           @Lc_TypeDebt_CODE               CHAR (2),
           @Lc_Fips_CODE                   CHAR (7),
           @Lc_Receipt_TEXT                CHAR (30),
           @Lc_ObleKey_TEXT                CHAR (30) = '',
           @Ls_Sql_TEXT                    VARCHAR (100) = '',
           @Ls_Sqldata_TEXT                VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT           NVARCHAR (4000),
           @Ld_Receipt_DATE                DATE;
  DECLARE @Ln_LsupCur_Case_IDNO           NUMERIC(6),
          @Ln_LsupCur_OrderSeq_NUMB       NUMERIC(2),
          @Ln_LsupCur_ObligationSeq_NUMB  NUMERIC(2),
          @Ln_LsupCur_Naa_AMNT            NUMERIC(11, 2),
          @Ln_LsupCur_Uda_AMNT            NUMERIC(11, 2),
          @Ln_LsupCur_Taa_AMNT            NUMERIC(11, 2),
          @Ln_LsupCur_Caa_AMNT            NUMERIC(11, 2),
          @Ln_LsupCur_Upa_AMNT            NUMERIC(11, 2),
          @Ln_LsupCur_Paa_AMNT            NUMERIC(11, 2),
          @Ln_LsupCur_Ivef_AMNT           NUMERIC(11, 2),
          @Ln_LsupCur_Medi_AMNT           NUMERIC(11, 2),
          @Ln_LsupCur_Curr_AMNT           NUMERIC(11, 2),
          @Ln_LsupCur_Fut_AMNT            NUMERIC(11, 2),
          @Ln_LsupCur_Expt_AMNT           NUMERIC(11, 2),
          @Ln_LsupCur_Nffc_AMNT           NUMERIC(11, 2),
          @Ln_LsupCur_Nivd_AMNT           NUMERIC(11, 2),
          @Lc_LsupCur_CheckRecipient_ID   CHAR(10),
          @Lc_LsupCur_CheckRecipient_CODE CHAR(1),
          @Lc_LsupCur_TypeWelfare_CODE    CHAR(1);

  CREATE TABLE #EsemTab_P1
   (
     TypeEntity_CODE CHAR(5),
     Entity_ID       CHAR(30)
   );

  DECLARE Lsup_CUR INSENSITIVE CURSOR FOR
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          (SELECT ISNULL (SUM (p.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 p
            WHERE p.Case_IDNO = a.Case_IDNO
              AND p.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND p.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND p.TypeBucket_CODE = 'ANAA') AS ln_amt_naa,
          (SELECT ISNULL (SUM (q.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 q
            WHERE q.Case_IDNO = a.Case_IDNO
              AND q.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND q.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND q.TypeBucket_CODE = 'AUDA') AS ln_amt_uda,
          (SELECT ISNULL (SUM (r.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 r
            WHERE r.Case_IDNO = a.Case_IDNO
              AND r.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND r.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND r.TypeBucket_CODE = 'ATAA') AS ln_amt_taa,
          (SELECT ISNULL (SUM (s.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 s
            WHERE s.Case_IDNO = a.Case_IDNO
              AND s.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND s.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND s.TypeBucket_CODE = 'ACAA') AS ln_amt_caa,
          (SELECT ISNULL (SUM (t.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 t
            WHERE t.Case_IDNO = a.Case_IDNO
              AND t.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND t.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND t.TypeBucket_CODE = 'AUPA') AS ln_amt_upa,
          (SELECT ISNULL (SUM (u.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 u
            WHERE u.Case_IDNO = a.Case_IDNO
              AND u.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND u.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND u.TypeBucket_CODE = 'APAA') AS ln_amt_paa,
          (SELECT ISNULL (SUM (v.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 v
            WHERE v.Case_IDNO = a.Case_IDNO
              AND v.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND v.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND v.TypeBucket_CODE = 'AIVEF') AS ln_amt_ivef,
          (SELECT ISNULL (SUM (x.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 x
            WHERE x.Case_IDNO = a.Case_IDNO
              AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND x.TypeBucket_CODE = 'AMEDI') AS ln_amt_medi,
          (SELECT ISNULL (SUM (y.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 y
            WHERE y.Case_IDNO = a.Case_IDNO
              AND y.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND y.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND y.TypeBucket_CODE = 'C') AS ln_amt_curr,
          0 AS ln_amt_fut,
          (SELECT ISNULL (SUM (z.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 z
            WHERE z.Case_IDNO = a.Case_IDNO
              AND z.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND z.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND z.TypeBucket_CODE = 'E') AS ln_amt_expt,
          (SELECT ISNULL (SUM (p.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 p
            WHERE p.Case_IDNO = a.Case_IDNO
              AND p.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND p.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND p.TypeBucket_CODE = 'ANFFC') AS ln_amt_nffc,
          (SELECT ISNULL (SUM (q.ArrPaid_AMNT), 0)
             FROM #Tpaid_P1 q
            WHERE q.Case_IDNO = a.Case_IDNO
              AND q.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND q.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND q.TypeBucket_CODE = 'ANIVD') AS ln_amt_nivd,
          a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.TypeWelfare_CODE
     FROM (SELECT DISTINCT t.Case_IDNO,
                  t.OrderSeq_NUMB,
                  t.ObligationSeq_NUMB,
                  t.CheckRecipient_ID,
                  t.CheckRecipient_CODE,
                  t.TypeWelfare_CODE
             FROM #Tpaid_P1 t
            WHERE (t.ArrPaid_AMNT > 0)) AS a
    WHERE NOT EXISTS (SELECT 1
                        FROM DISH_Y1 l
                       WHERE
                      ((l.CasePayorMCI_IDNO = @An_PayorMCI_IDNO
                        AND TypeHold_CODE = 'P'
                        AND @Ac_TypePosting_CODE = 'P'
                        AND l.ReasonHold_CODE <> @Ac_ReleasedFrom_CODE)
                        OR (l.CasePayorMCI_IDNO = a.Case_IDNO
                            AND TypeHold_CODE = 'C'
                            AND @Ac_TypePosting_CODE = 'C'
                            AND l.ReasonHold_CODE <> @Ac_ReleasedFrom_CODE)
                        OR (l.CasePayorMCI_IDNO = @An_PayorMCI_IDNO
                            AND TypeHold_CODE = 'P'
                            AND @Ac_TypePosting_CODE = 'C')
                        OR (l.CasePayorMCI_IDNO = a.Case_IDNO
                            AND TypeHold_CODE = 'C'
                            AND @Ac_TypePosting_CODE = 'P'))
                      AND l.SourceHold_CODE IN (@Ac_SourceReceipt_CODE, 'DH')
                      AND @Ad_Process_DATE >= l.Effective_DATE
                      AND @Ad_Process_DATE < l.Expiration_DATE
                      AND l.EndValidity_DATE =  @Ld_High_DATE)
    ORDER BY a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB;

  BEGIN TRY
  
   SET @An_EventGlobalSeq_NUMB = 0;
   SET @Ac_Msg_CODE = '';
   SET @Lc_Job_ID = ISNULL (@Lc_Job_ID, 'DEB0560');
   SET @Ls_Process_NAME = ISNULL (@Ls_Process_NAME, 'BATCH_FIN_REG_DISTRIBUTION');
   SET @Ls_Sql_TEXT = 'SELECT_TPAID_P1_CNT';   
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_Rec_QNTY = COUNT (1)
     FROM #Tpaid_P1 t
    WHERE (t.ArrPaid_AMNT > 0);

   SET @Ls_Sql_TEXT = 'DELETE FROM #EsemTab_P1'; 
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #EsemTab_P1;

   IF @Ln_Rec_QNTY > 0
    BEGIN
     SET @Lc_Receipt_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
	 SET @Ls_Sql_TEXT = 'INSERT INTO #EsemTab_P1 - 1';     
	 SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRctno_CODE,'')+ ', Entity_ID = ' + ISNULL(@Lc_Receipt_TEXT,'');

     INSERT INTO #EsemTab_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_TypeEntityRctno_CODE,      --TypeEntity_CODE
                  @Lc_Receipt_TEXT  --Entity_ID
  
				 );

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 2';     
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptDistributed1820_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReceiptDistributed1820_NUMB,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @An_EventGlobalSeq_NUMB     = @An_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'OPEN Lsup_CUR';
   SET @Ls_Sqldata_TEXT = '';
   
   OPEN Lsup_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Lsup_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   
   FETCH NEXT FROM Lsup_CUR INTO @Ln_LsupCur_Case_IDNO, @Ln_LsupCur_OrderSeq_NUMB, @Ln_LsupCur_ObligationSeq_NUMB, @Ln_LsupCur_Naa_AMNT, @Ln_LsupCur_Uda_AMNT, @Ln_LsupCur_Taa_AMNT, @Ln_LsupCur_Caa_AMNT, @Ln_LsupCur_Upa_AMNT, @Ln_LsupCur_Paa_AMNT, @Ln_LsupCur_Ivef_AMNT, @Ln_LsupCur_Medi_AMNT, @Ln_LsupCur_Curr_AMNT, @Ln_LsupCur_Fut_AMNT, @Ln_LsupCur_Expt_AMNT, @Ln_LsupCur_Nffc_AMNT, @Ln_LsupCur_Nivd_AMNT, @Lc_LsupCur_CheckRecipient_ID, @Lc_LsupCur_CheckRecipient_CODE, @Lc_LsupCur_TypeWelfare_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	--LOOP Started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     IF @Ln_LsupCur_Naa_AMNT > 0
         OR @Ln_LsupCur_Paa_AMNT > 0
         OR @Ln_LsupCur_Taa_AMNT > 0
         OR @Ln_LsupCur_Caa_AMNT > 0
         OR @Ln_LsupCur_Uda_AMNT > 0
         OR @Ln_LsupCur_Upa_AMNT > 0
         OR @Ln_LsupCur_Ivef_AMNT > 0
         OR @Ln_LsupCur_Medi_AMNT > 0
         OR @Ln_LsupCur_Curr_AMNT > 0
         OR @Ln_LsupCur_Expt_AMNT > 0
         OR @Ln_LsupCur_Nffc_AMNT > 0
         OR @Ln_LsupCur_Nivd_AMNT > 0
      BEGIN
       IF SUBSTRING(CONVERT(VARCHAR(6),@Ad_ReceiptOrig_DATE,112),1,6) <> SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'');

         SELECT TOP 1 @Ln_Value_NUMB = 1
           FROM LSUP_Y1 l
          WHERE l.Case_IDNO = @Ln_LsupCur_Case_IDNO
            AND l.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
            AND l.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
            AND l.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           GOTO No_Data_Found;
          END
        END

       SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1_SORD_Y1';       
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT TOP 1 @Lc_ObleKey_TEXT = ISNULL (CAST(a.MemberMci_IDNO AS VARCHAR), '') + ISNULL (a.TypeDebt_CODE, '') + ISNULL (a.Fips_CODE, ''),
                    @Ln_Order_IDNO = b.Order_IDNO,
                    @Lc_TypeDebt_CODE = a.TypeDebt_CODE,
                    @Ln_MemberMci_IDNO = a.MemberMci_IDNO,
                    @Lc_OrderType_CODE = b.TypeOrder_CODE,
                    @Lc_Fips_CODE = a.Fips_CODE
         FROM OBLE_Y1 a,
              SORD_Y1 b
        WHERE a.Case_IDNO = @Ln_LsupCur_Case_IDNO
          AND a.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
          AND a.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
          AND a.EndValidity_DATE = @Ld_High_DATE
          AND a.Case_IDNO = b.Case_IDNO
          AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
          AND b.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         GOTO No_Data_Found;
        END
	   SET @Ls_Sql_TEXT = 'SELECT @Ld_Receipt_DATE,@Lc_Rec_ID,@Lc_CaseFlag_INDC';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ld_Receipt_DATE = @Ad_Receipt_DATE,
              @Lc_Rec_ID = @Lc_TypeRecordOriginal_CODE,
              @Lc_CaseFlag_INDC = @Lc_No_INDC,
              @Lc_OrderFlag_INDC = @Lc_No_INDC,
              @Lc_ObleFlag_INDC = @Lc_No_INDC;

       IF EXISTS (SELECT 1
                    FROM #EsemTab_P1
                   WHERE TypeEntity_CODE = @Lc_TypeEntityCase_CODE
                     AND Entity_ID = @Ln_LsupCur_Case_IDNO)
        BEGIN
         SET @Lc_CaseFlag_INDC = @Lc_Yes_INDC;
        END

       IF @Lc_CaseFlag_INDC = @Lc_No_INDC
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT INTO #EsemTab_P1 - 2';         
         SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityCase_CODE,'')+ ', Entity_ID = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'');

         INSERT INTO #EsemTab_P1
                     (TypeEntity_CODE,
                      Entity_ID)
              VALUES ( @Lc_TypeEntityCase_CODE,      --TypeEntity_CODE
                       @Ln_LsupCur_Case_IDNO  --Entity_ID
  
					 );
        END

       SET @Lc_FirstTime_TEXT = @Lc_Yes_INDC;
       SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1';       
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'');

       SELECT @Lc_TypeWelfare_CODE = a.TypeWelfare_CODE,
              @Ln_MtdCurSup_AMNT = a.MtdCurSupOwed_AMNT,
              @Ln_OweCur_AMNT = a.OweTotCurSup_AMNT,
              @Ln_AppCur_AMNT = a.AppTotCurSup_AMNT,
              @Ln_OweExpt_AMNT = a.OweTotExptPay_AMNT,
              @Ln_AppExpt_AMNT = a.AppTotExptPay_AMNT,
              @Ln_OweNaa_AMNT = a.OweTotNaa_AMNT,
              @Ln_AppNaa_AMNT = a.AppTotNaa_AMNT,
              @Ln_OweTaa_AMNT = a.OweTotTaa_AMNT,
              @Ln_AppTaa_AMNT = a.AppTotTaa_AMNT,
              @Ln_OwePaa_AMNT = a.OweTotPaa_AMNT,
              @Ln_AppPaa_AMNT = a.AppTotPaa_AMNT,
              @Ln_OweCaa_AMNT = a.OweTotCaa_AMNT,
              @Ln_AppCaa_AMNT = a.AppTotCaa_AMNT,
              @Ln_OweUpa_AMNT = a.OweTotUpa_AMNT,
              @Ln_AppUpa_AMNT = a.AppTotUpa_AMNT,
              @Ln_OweUda_AMNT = a.OweTotUda_AMNT,
              @Ln_AppUda_AMNT = a.AppTotUda_AMNT,
              @Ln_OweIvef_AMNT = a.OweTotIvef_AMNT,
              @Ln_AppIvef_AMNT = a.AppTotIvef_AMNT,
              @Ln_OweNffc_AMNT = a.OweTotNffc_AMNT,
              @Ln_AppNffc_AMNT = a.AppTotNffc_AMNT,
              @Ln_OweNonIvd_AMNT = a.OweTotNonIvd_AMNT,
              @Ln_AppNonIvd_AMNT = a.AppTotNonIvd_AMNT,
              @Ln_OweMedi_AMNT = a.OweTotMedi_AMNT,
              @Ln_AppMedi_AMNT = a.AppTotMedi_AMNT,
              @Ln_AppFuture_AMNT = a.AppTotFuture_AMNT
         FROM LSUP_Y1 a
        WHERE a.Case_IDNO = @Ln_LsupCur_Case_IDNO
          AND a.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
          AND a.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
          AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6)
          AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                         FROM LSUP_Y1 c
                                        WHERE c.Case_IDNO = @Ln_LsupCur_Case_IDNO
                                          AND c.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
                                          AND c.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
                                          AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         GOTO No_Data_Found;
        END
	   SET @Ls_Sql_TEXT = 'SELECT amounts';  
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_TransactionPaa_AMNT = 0,
              @Ln_TransactionUda_AMNT = 0,
              @Ln_TransactionTaa_AMNT = 0,
              @Ln_TransactionCaa_AMNT = 0,
              @Ln_TransactionUpa_AMNT = 0,
              @Ln_TransactionNaa_AMNT = 0,
              @Ln_TransactionIvef_AMNT = 0,
              @Ln_TransactionNffc_AMNT = 0,
              @Ln_TransactionNonIvd_AMNT = 0,
              @Ln_TransactionMedi_AMNT = 0,
              @Ln_TransactionPaaOrig_AMNT = 0,
              @Ln_TransactionUdaOrig_AMNT = 0,
              @Ln_TransactionTaaOrig_AMNT = 0,
              @Ln_TransactionCaaOrig_AMNT = 0,
              @Ln_TransactionUpaOrig_AMNT = 0,
              @Ln_TransactionNaaOrig_AMNT = 0,
              @Ln_TransactionIvefOrig_AMNT = 0,
              @Ln_TransactionNffcOrig_AMNT = 0,
              @Ln_TransactionNonIvdOrig_AMNT = 0,
              @Ln_TransactionMediOrig_AMNT = 0,
              @Ln_TransactionExpt_AMNT = 0,
              @Ln_CurSup_NUMB = 0,
              @Ln_TransactionExpt_AMNT = @Ln_LsupCur_Expt_AMNT;

       IF @Ln_TransactionExpt_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR';         
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', TransactionExpt_AMNT = ' + ISNULL(CAST( @Ln_TransactionExpt_AMNT AS VARCHAR ),'');

         EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR
          @An_Case_IDNO              = @Ln_LsupCur_Case_IDNO,
          @An_OrderSeq_NUMB          = @Ln_LsupCur_OrderSeq_NUMB,
          @An_ObligationSeq_NUMB     = @Ln_LsupCur_ObligationSeq_NUMB,
          @An_TransactionExpt_AMNT   = @Ln_TransactionExpt_AMNT,
          @An_TransactionPaa_AMNT    = @Ln_TransactionPaaOrig_AMNT OUTPUT,
          @An_TransactionNaa_AMNT    = @Ln_TransactionNaaOrig_AMNT OUTPUT,
          @An_TransactionUda_AMNT    = @Ln_TransactionUdaOrig_AMNT OUTPUT,
          @An_TransactionCaa_AMNT    = @Ln_TransactionCaaOrig_AMNT OUTPUT,
          @An_TransactionUpa_AMNT    = @Ln_TransactionUpaOrig_AMNT OUTPUT,
          @An_TransactionTaa_AMNT    = @Ln_TransactionTaaOrig_AMNT OUTPUT,
          @An_TransactionIvef_AMNT   = @Ln_TransactionIvefOrig_AMNT OUTPUT,
          @An_TransactionNffc_AMNT   = @Ln_TransactionNffcOrig_AMNT OUTPUT,
          @An_TransactionNonIvd_AMNT = @Ln_TransactionNonIvdOrig_AMNT OUTPUT,
          @An_TransactionMedi_AMNT   = @Ln_TransactionMediOrig_AMNT OUTPUT,
          @Ac_Msg_CODE               = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT  = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END

       SET @Ln_TransactionPaaOrig_AMNT = @Ln_TransactionPaaOrig_AMNT + @Ln_LsupCur_Paa_AMNT;
       SET @Ln_TransactionNaaOrig_AMNT = @Ln_TransactionNaaOrig_AMNT + @Ln_LsupCur_Naa_AMNT;
       SET @Ln_TransactionUdaOrig_AMNT = @Ln_TransactionUdaOrig_AMNT + @Ln_LsupCur_Uda_AMNT;
       SET @Ln_TransactionTaaOrig_AMNT = @Ln_TransactionTaaOrig_AMNT + @Ln_LsupCur_Taa_AMNT;
       SET @Ln_TransactionCaaOrig_AMNT = @Ln_TransactionCaaOrig_AMNT + @Ln_LsupCur_Caa_AMNT;
       SET @Ln_TransactionUpaOrig_AMNT = @Ln_TransactionUpaOrig_AMNT + @Ln_LsupCur_Upa_AMNT;
       SET @Ln_TransactionIvefOrig_AMNT = @Ln_TransactionIvefOrig_AMNT + @Ln_LsupCur_Ivef_AMNT;
       SET @Ln_TransactionNffcOrig_AMNT = @Ln_TransactionNffcOrig_AMNT + @Ln_LsupCur_Nffc_AMNT;
       SET @Ln_TransactionNonIvdOrig_AMNT = @Ln_TransactionNonIvdOrig_AMNT + @Ln_LsupCur_Nivd_AMNT;
       SET @Ln_TransactionMediOrig_AMNT = @Ln_TransactionMediOrig_AMNT + @Ln_LsupCur_Medi_AMNT;
       SET @Ln_CurSup_NUMB = @Ln_LsupCur_Curr_AMNT;

       IF @Lc_TypeDebt_CODE NOT IN (@Lc_TypeDebtMedicaid_CODE, @Lc_TypeDebtIntMedicaid_CODE, @Lc_TypeDebtMedicalSupp_CODE)
        BEGIN
         IF @Lc_TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareMedicaid_CODE, @Lc_Space_TEXT)
          BEGIN
           SET @Ln_TransactionNaaOrig_AMNT = @Ln_TransactionNaaOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
           SET @Lc_TypeWelf_CODE = @Lc_TypeWelfareNonTanf_CODE;
          END
         ELSE
          BEGIN
           IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
            BEGIN
             SET @Ln_TransactionPaaOrig_AMNT = @Ln_TransactionPaaOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
             SET @Lc_TypeWelf_CODE = @Lc_TypeWelfareTanf_CODE;
            END
           ELSE
            BEGIN
             IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareNonIve_CODE
              BEGIN
               SET @Lc_TypeWelf_CODE = @Lc_TypeWelfare_CODE;
               SET @Ln_TransactionIvefOrig_AMNT = @Ln_TransactionIvefOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
              END
             ELSE
              BEGIN
               IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareFosterCare_CODE
                BEGIN
                 SET @Lc_TypeWelf_CODE = @Lc_TypeWelfare_CODE;
                 SET @Ln_TransactionNffcOrig_AMNT = @Ln_TransactionNffcOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
                END
               ELSE
                BEGIN
                 IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareNonIvd_CODE
                  BEGIN
                   SET @Lc_TypeWelf_CODE = @Lc_TypeWelfare_CODE;
                   SET @Ln_TransactionNonIvdOrig_AMNT = @Ln_TransactionNonIvdOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
                  END
                END
              END
            END
          END
        END
       ELSE
        BEGIN
         IF @Lc_TypeDebt_CODE IN (@Lc_TypeDebtMedicalSupp_CODE)
          BEGIN
           SET @Lc_TypeWelf_CODE = @Lc_TypeWelfare_CODE;

           IF @Lc_TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareTanf_CODE)
            BEGIN
             SET @Ln_TransactionMediOrig_AMNT = @Ln_TransactionMediOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
            END
           ELSE
            BEGIN
             IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareNonIve_CODE
              BEGIN
               SET @Ln_TransactionIvefOrig_AMNT = @Ln_TransactionIvefOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
              END
             ELSE IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareFosterCare_CODE
              BEGIN
               SET @Ln_TransactionNffcOrig_AMNT = @Ln_TransactionNffcOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
              END
             ELSE
              BEGIN
               IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareNonIvd_CODE
                BEGIN
                 SET @Ln_TransactionNonIvdOrig_AMNT = @Ln_TransactionNonIvdOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
                END
               ELSE
                BEGIN
                 SET @Ln_TransactionNaaOrig_AMNT = @Ln_TransactionNaaOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
                END
              END
            END
          END
         ELSE
          BEGIN
           IF @Lc_TypeDebt_CODE IN (@Lc_TypeDebtMedicaid_CODE, @Lc_TypeDebtIntMedicaid_CODE)
            BEGIN
             SET @Lc_TypeWelf_CODE = @Lc_TypeWelfareMedicaid_CODE;
             SET @Ln_TransactionMediOrig_AMNT = @Ln_TransactionMediOrig_AMNT + @Ln_LsupCur_Curr_AMNT;
            END
          END
        END
--LOOP STARTED
       WHILE SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6) <= SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
        BEGIN
         IF @Lc_TypeWelf_CODE = @Lc_TypeWelfareNonIvd_CODE
          BEGIN
           SET @Ln_TransactionNonIvd_AMNT = @Ln_TransactionNonIvdOrig_AMNT + ISNULL (CAST(@Ln_LsupCur_Fut_AMNT AS VARCHAR), 0);
          END
         ELSE
          BEGIN
           SET @Ln_TransactionNonIvd_AMNT = @Ln_TransactionNonIvdOrig_AMNT;
          END

         SET @Ln_TransactionNaa_AMNT = @Ln_TransactionNaaOrig_AMNT;
         SET @Ln_TransactionPaa_AMNT = @Ln_TransactionPaaOrig_AMNT;
         SET @Ln_TransactionUda_AMNT = @Ln_TransactionUdaOrig_AMNT;
         SET @Ln_TransactionTaa_AMNT = @Ln_TransactionTaaOrig_AMNT;
         SET @Ln_TransactionCaa_AMNT = @Ln_TransactionCaaOrig_AMNT;
         SET @Ln_TransactionUpa_AMNT = @Ln_TransactionUpaOrig_AMNT;
         SET @Ln_TransactionIvef_AMNT = @Ln_TransactionIvefOrig_AMNT;
         SET @Ln_TransactionNffc_AMNT = @Ln_TransactionNffcOrig_AMNT;
         SET @Ln_TransactionMedi_AMNT = @Ln_TransactionMediOrig_AMNT;

         SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';         
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_LsupCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_LsupCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6), '') + ', Receipt_DATE = ' + ISNULL (CAST(@Ld_Receipt_DATE AS VARCHAR), '');
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
                 CheckRecipient_ID,
                 CheckRecipient_CODE,
                 Batch_DATE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceBatch_CODE,
                 Receipt_DATE,
                 Distribute_DATE,
                 TypeRecord_CODE,
                 EventGlobalSeq_NUMB,
                 EventFunctionalSeq_NUMB)
         (SELECT @Ln_LsupCur_Case_IDNO AS Case_IDNO,
                 @Ln_LsupCur_OrderSeq_NUMB AS OrderSeq_NUMB,
                 @Ln_LsupCur_ObligationSeq_NUMB AS ObligationSeq_NUMB,
                 SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6) AS SupportYearMonth_NUMB,
                 a.TypeWelfare_CODE,
                 a.MtdCurSupOwed_AMNT,
                 @Ln_CurSup_NUMB AS TransactionCurSup_AMNT,
                 a.OweTotCurSup_AMNT,
                 a.AppTotCurSup_AMNT + @Ln_CurSup_NUMB AS AppTotCurSup_AMNT,
                 @Ln_TransactionExpt_AMNT AS TransactionExptPay_AMNT,
                 a.OweTotExptPay_AMNT + CASE @Lc_TypeDebt_CODE
                                         WHEN @Lc_TypeDebtIntChildSupp_CODE
                                          THEN @Ln_TransactionExpt_AMNT
                                         WHEN @Lc_TypeDebtIntSpousalSupp_CODE
                                          THEN @Ln_TransactionExpt_AMNT
                                         WHEN @Lc_TypeDebtIntMedicalSupp_CODE
                                          THEN @Ln_TransactionExpt_AMNT
                                         WHEN @Lc_TypeDebtIntMedicaid_CODE
                                          THEN @Ln_TransactionExpt_AMNT
                                         ELSE 0
                                        END AS OweTotExptPay_AMNT,
                 a.AppTotExptPay_AMNT + @Ln_TransactionExpt_AMNT AS AppTotExptPay_AMNT,
                 @Ln_TransactionNaa_AMNT AS TransactionNaa_AMNT,
                 a.OweTotNaa_AMNT,
                 a.AppTotNaa_AMNT + @Ln_TransactionNaa_AMNT AS AppTotNaa_AMNT,
                 @Ln_TransactionTaa_AMNT AS TransactionTaa_AMNT,
                 a.OweTotTaa_AMNT,
                 a.AppTotTaa_AMNT + @Ln_TransactionTaa_AMNT AS AppTotTaa_AMNT,
                 @Ln_TransactionPaa_AMNT AS TransactionPaa_AMNT,
                 a.OweTotPaa_AMNT,
                 a.AppTotPaa_AMNT + @Ln_TransactionPaa_AMNT AS AppTotPaa_AMNT,
                 @Ln_TransactionCaa_AMNT AS TransactionCaa_AMNT,
                 a.OweTotCaa_AMNT,
                 a.AppTotCaa_AMNT + @Ln_TransactionCaa_AMNT AS AppTotCaa_AMNT,
                 @Ln_TransactionUpa_AMNT AS TransactionUpa_AMNT,
                 a.OweTotUpa_AMNT,
                 a.AppTotUpa_AMNT + @Ln_TransactionUpa_AMNT AS AppTotUpa_AMNT,
                 @Ln_TransactionUda_AMNT AS TransactionUda_AMNT,
                 a.OweTotUda_AMNT,
                 a.AppTotUda_AMNT + @Ln_TransactionUda_AMNT AS AppTotUda_AMNT,
                 @Ln_TransactionIvef_AMNT AS TransactionIvef_AMNT,
                 a.OweTotIvef_AMNT,
                 a.AppTotIvef_AMNT + @Ln_TransactionIvef_AMNT AS AppTotIvef_AMNT,
                 @Ln_TransactionNffc_AMNT AS TransactionNffc_AMNT,
                 a.OweTotNffc_AMNT,
                 a.AppTotNffc_AMNT + @Ln_TransactionNffc_AMNT AS AppTotNffc_AMNT,
                 @Ln_TransactionNonIvd_AMNT AS TransactionNonIvd_AMNT,
                 a.OweTotNonIvd_AMNT,
                 a.AppTotNonIvd_AMNT + @Ln_TransactionNonIvd_AMNT AS AppTotNonIvd_AMNT,
                 @Ln_TransactionMedi_AMNT AS TransactionMedi_AMNT,
                 a.OweTotMedi_AMNT,
                 a.AppTotMedi_AMNT + @Ln_TransactionMedi_AMNT AS AppTotMedi_AMNT,
                 0 AS TransactionFuture_AMNT,
                 a.AppTotFuture_AMNT,
                 @Lc_LsupCur_CheckRecipient_ID AS CheckRecipient_ID,
                 @Lc_LsupCur_CheckRecipient_CODE AS CheckRecipient_CODE,
                 @Ad_Batch_DATE AS Batch_DATE,
                 @An_Batch_NUMB AS Batch_NUMB,
                 @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
                 @Ac_SourceBatch_CODE AS SourceBatch_CODE,
                 @Ad_ReceiptOrig_DATE AS Receipt_DATE,
                 @Ad_Process_DATE AS Distribute_DATE,
                 @Lc_Rec_ID AS TypeRecord_CODE,
                 @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                 @Li_ReceiptDistributed1820_NUMB AS EventFunctionalSeq_NUMB
            FROM LSUP_Y1 a
           WHERE a.Case_IDNO = @Ln_LsupCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
             AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6)
             AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                            FROM LSUP_Y1 c
                                           WHERE c.Case_IDNO = @Ln_LsupCur_Case_IDNO
                                             AND c.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
                                             AND c.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
                                             AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB));

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT_LSUP_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
         ELSE
          BEGIN 
           SET @Ls_Sql_TEXT = 'Update #Tpaid_P1';           
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'');

           UPDATE #Tpaid_P1
              SET LsupInsert_INDC = @Lc_Yes_INDC
            WHERE Case_IDNO = @Ln_LsupCur_Case_IDNO
              AND OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
              AND ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB;
          END

         SET @Ln_TransactionExpt_AMNT = 0;
         SET @Ln_CurSup_NUMB = 0;

         IF @Lc_TypeDebt_CODE NOT IN (@Lc_TypeDebtMedicaid_CODE, @Lc_TypeDebtIntMedicaid_CODE)
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1 - 1';           
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_LsupCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_LsupCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6), '') + ', Receipt_DATE = ' + ISNULL (CAST(@Ld_Receipt_DATE AS VARCHAR), '');

           SELECT @Lc_TypeWelfare_CODE = a.TypeWelfare_CODE,
                  @Ln_MtdCurSup_AMNT = a.MtdCurSupOwed_AMNT,
                  @Ln_OweCur_AMNT = a.OweTotCurSup_AMNT,
                  @Ln_AppCur_AMNT = a.AppTotCurSup_AMNT,
                  @Ln_OweExpt_AMNT = a.OweTotExptPay_AMNT,
                  @Ln_AppExpt_AMNT = a.AppTotExptPay_AMNT,
                  @Ln_OweNaa_AMNT = a.OweTotNaa_AMNT,
                  @Ln_AppNaa_AMNT = a.AppTotNaa_AMNT,
                  @Ln_OweTaa_AMNT = a.OweTotTaa_AMNT,
                  @Ln_AppTaa_AMNT = a.AppTotTaa_AMNT,
                  @Ln_OwePaa_AMNT = a.OweTotPaa_AMNT,
                  @Ln_AppPaa_AMNT = a.AppTotPaa_AMNT,
                  @Ln_OweCaa_AMNT = a.OweTotCaa_AMNT,
                  @Ln_AppCaa_AMNT = a.AppTotCaa_AMNT,
                  @Ln_OweUpa_AMNT = a.OweTotUpa_AMNT,
                  @Ln_AppUpa_AMNT = a.AppTotUpa_AMNT,
                  @Ln_OweUda_AMNT = a.OweTotUda_AMNT,
                  @Ln_AppUda_AMNT = a.AppTotUda_AMNT,
                  @Ln_OweIvef_AMNT = a.OweTotIvef_AMNT,
                  @Ln_AppIvef_AMNT = a.AppTotIvef_AMNT,
                  @Ln_OweNffc_AMNT = a.OweTotNffc_AMNT,
                  @Ln_AppNffc_AMNT = a.AppTotNffc_AMNT,
                  @Ln_OweNonIvd_AMNT = a.OweTotNonIvd_AMNT,
                  @Ln_AppNonIvd_AMNT = a.AppTotNonIvd_AMNT,
                  @Ln_OweMedi_AMNT = a.OweTotMedi_AMNT,
                  @Ln_AppMedi_AMNT = a.AppTotMedi_AMNT,
                  @Ln_AppFuture_AMNT = a.AppTotFuture_AMNT
             FROM LSUP_Y1 a
            WHERE a.Case_IDNO = @Ln_LsupCur_Case_IDNO
              AND a.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
              AND a.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
              AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6)
              AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                             FROM LSUP_Y1 c
                                            WHERE c.Case_IDNO = @Ln_LsupCur_Case_IDNO
                                              AND c.OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
                                              AND c.ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB
                                              AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             GOTO No_Data_Found;
            END

           SET @Ln_ArrPaa_AMNT = @Ln_OwePaa_AMNT - @Ln_AppPaa_AMNT;
           SET @Ln_ArrUda_AMNT = @Ln_OweUda_AMNT - @Ln_AppUda_AMNT;
           SET @Ln_ArrTaa_AMNT = @Ln_OweTaa_AMNT - @Ln_AppTaa_AMNT;
           SET @Ln_ArrCaa_AMNT = @Ln_OweCaa_AMNT - @Ln_AppCaa_AMNT;
           SET @Ln_ArrUpa_AMNT = @Ln_OweUpa_AMNT - @Ln_AppUpa_AMNT;
           SET @Ln_ArrNaa_AMNT = @Ln_OweNaa_AMNT - @Ln_AppNaa_AMNT;

           IF SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6) = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
            BEGIN
              -- Circular Rule calculation will be applied only for other than MS debt type.
              IF @Lc_TypeDebt_CODE <> @Lc_TypeDebtMedicalSupp_CODE
              BEGIN
               IF @Lc_TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareMedicaid_CODE)
                BEGIN
                 SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT - (@Ln_OweCur_AMNT - @Ln_AppCur_AMNT);
                END
               ELSE
                BEGIN
                 IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
                  BEGIN
                   SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT - (@Ln_OweCur_AMNT - @Ln_AppCur_AMNT);
                  END
                END
               END 
               ELSE
               BEGIN
                IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                BEGIN
                 SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT - (@Ln_OweCur_AMNT - @Ln_AppCur_AMNT);
                END                
               END
            END

           IF (@Ln_ArrPaa_AMNT < 0
                OR @Ln_ArrUda_AMNT < 0
                OR @Ln_ArrTaa_AMNT < 0
                OR @Ln_ArrCaa_AMNT < 0
                OR @Ln_ArrUpa_AMNT < 0
                OR @Ln_ArrNaa_AMNT < 0)
            BEGIN
             SET @Ln_TransactionPaa_AMNT = 0;
             SET @Ln_TransactionUda_AMNT = 0;
             SET @Ln_TransactionNaa_AMNT = 0;
             SET @Ln_TransactionCaa_AMNT = 0;
             SET @Ln_TransactionUpa_AMNT = 0;
             SET @Ln_TransactionTaa_AMNT = 0;
             SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CIRCULAR_RULE';
             SET @Ls_Sqldata_TEXT = '';

             EXECUTE BATCH_COMMON$SP_CIRCULAR_RULE
              @An_ArrPaa_AMNT         = @Ln_ArrPaa_AMNT OUTPUT,
              @An_TransactionPaa_AMNT = @Ln_TransactionPaa_AMNT OUTPUT,
              @An_ArrUda_AMNT         = @Ln_ArrUda_AMNT OUTPUT,
              @An_TransactionUda_AMNT = @Ln_TransactionUda_AMNT OUTPUT,
              @An_ArrNaa_AMNT         = @Ln_ArrNaa_AMNT OUTPUT,
              @An_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT OUTPUT,
              @An_ArrCaa_AMNT         = @Ln_ArrCaa_AMNT OUTPUT,
              @An_TransactionCaa_AMNT = @Ln_TransactionCaa_AMNT OUTPUT,
              @An_ArrUpa_AMNT         = @Ln_ArrUpa_AMNT OUTPUT,
              @An_TransactionUpa_AMNT = @Ln_TransactionUpa_AMNT OUTPUT,
              @An_ArrTaa_AMNT         = @Ln_ArrTaa_AMNT OUTPUT,
              @An_TransactionTaa_AMNT = @Ln_TransactionTaa_AMNT OUTPUT;

             IF @Ln_TransactionPaa_AMNT != 0
                 OR @Ln_TransactionUda_AMNT != 0
                 OR @Ln_TransactionNaa_AMNT != 0
                 OR @Ln_TransactionCaa_AMNT != 0
                 OR @Ln_TransactionUpa_AMNT != 0
                 OR @Ln_TransactionTaa_AMNT != 0
              BEGIN
               IF @Lc_FirstTime_TEXT = @Lc_Yes_INDC
                BEGIN
                 
                 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 3';                 
                 SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_CircularRuleRecord1070_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

                 EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
                  @An_EventFunctionalSeq_NUMB = @Li_CircularRuleRecord1070_NUMB,
                  @Ac_Process_ID              = @Lc_ProcessRdist_ID,
                  @Ad_EffectiveEvent_DATE     = @Ad_Process_DATE,
                  @Ac_Note_INDC               = @Lc_No_INDC,
                  @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
                  @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqCrle_NUMB OUTPUT,
                  @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
                  @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

                 IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                  BEGIN
                   RAISERROR (50001,16,1);
                  END

                 SET @Lc_FirstTime_TEXT = @Lc_No_INDC;
                END

               SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1 - 2';               
               SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', MtdCurSupOwed_AMNT = ' + ISNULL(CAST( @Ln_MtdCurSup_AMNT AS VARCHAR ),'')+ ', TransactionCurSup_AMNT = ' + ISNULL('0','')+ ', OweTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_OweCur_AMNT AS VARCHAR ),'')+ ', AppTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_AppCur_AMNT AS VARCHAR ),'')+ ', TransactionExptPay_AMNT = ' + ISNULL('0','')+ ', OweTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_OweExpt_AMNT AS VARCHAR ),'')+ ', AppTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_AppExpt_AMNT AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionNaa_AMNT AS VARCHAR ),'')+ ', AppTotNaa_AMNT = ' + ISNULL(CAST( @Ln_AppNaa_AMNT AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionTaa_AMNT AS VARCHAR ),'')+ ', AppTotTaa_AMNT = ' + ISNULL(CAST( @Ln_AppTaa_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionPaa_AMNT AS VARCHAR ),'')+ ', AppTotPaa_AMNT = ' + ISNULL(CAST( @Ln_AppPaa_AMNT AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionCaa_AMNT AS VARCHAR ),'')+ ', AppTotCaa_AMNT = ' + ISNULL(CAST( @Ln_AppCaa_AMNT AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_TransactionUpa_AMNT AS VARCHAR ),'')+ ', AppTotUpa_AMNT = ' + ISNULL(CAST( @Ln_AppUpa_AMNT AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_TransactionUda_AMNT AS VARCHAR ),'')+ ', AppTotUda_AMNT = ' + ISNULL(CAST( @Ln_AppUda_AMNT AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL('0','')+ ', OweTotIvef_AMNT = ' + ISNULL(CAST( @Ln_OweIvef_AMNT AS VARCHAR ),'')+ ', AppTotIvef_AMNT = ' + ISNULL(CAST( @Ln_AppIvef_AMNT AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL('0','')+ ', OweTotNffc_AMNT = ' + ISNULL(CAST( @Ln_OweNffc_AMNT AS VARCHAR ),'')+ ', AppTotNffc_AMNT = ' + ISNULL(CAST( @Ln_AppNffc_AMNT AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL('0','')+ ', OweTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_OweNonIvd_AMNT AS VARCHAR ),'')+ ', AppTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_AppNonIvd_AMNT AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL('0','')+ ', OweTotMedi_AMNT = ' + ISNULL(CAST( @Ln_OweMedi_AMNT AS VARCHAR ),'')+ ', AppTotMedi_AMNT = ' + ISNULL(CAST( @Ln_AppMedi_AMNT AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL('0','')+ ', AppTotFuture_AMNT = ' + ISNULL(CAST( @Ln_AppFuture_AMNT AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_LsupCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_LsupCur_CheckRecipient_CODE,'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL('0','')+ ', SeqReceipt_NUMB = ' + ISNULL('0','')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ad_ReceiptOrig_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_Rec_ID,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqCrle_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_CircularRuleRecord1070_NUMB AS VARCHAR ),'');

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
                       CheckRecipient_ID,
                       CheckRecipient_CODE,
                       Batch_DATE,
                       Batch_NUMB,
                       SeqReceipt_NUMB,
                       SourceBatch_CODE,
                       Receipt_DATE,
                       Distribute_DATE,
                       TypeRecord_CODE,
                       EventGlobalSeq_NUMB,
                       EventFunctionalSeq_NUMB)
               VALUES ( @Ln_LsupCur_Case_IDNO,      --Case_IDNO
                        @Ln_LsupCur_OrderSeq_NUMB,      --OrderSeq_NUMB
                        @Ln_LsupCur_ObligationSeq_NUMB,      --ObligationSeq_NUMB
                        SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6),      --SupportYearMonth_NUMB
                        ISNULL (@Lc_TypeWelfare_CODE, @Lc_Space_TEXT),      --TypeWelfare_CODE
                        @Ln_MtdCurSup_AMNT,      --MtdCurSupOwed_AMNT
                        0,      --TransactionCurSup_AMNT
                        @Ln_OweCur_AMNT,      --OweTotCurSup_AMNT
                        @Ln_AppCur_AMNT,      --AppTotCurSup_AMNT
                        0,      --TransactionExptPay_AMNT
                        @Ln_OweExpt_AMNT,      --OweTotExptPay_AMNT
                        @Ln_AppExpt_AMNT,      --AppTotExptPay_AMNT
                        @Ln_TransactionNaa_AMNT,      --TransactionNaa_AMNT
                        @Ln_OweNaa_AMNT + @Ln_TransactionNaa_AMNT,      --OweTotNaa_AMNT
                        @Ln_AppNaa_AMNT,      --AppTotNaa_AMNT
                        @Ln_TransactionTaa_AMNT,      --TransactionTaa_AMNT
                        @Ln_OweTaa_AMNT + @Ln_TransactionTaa_AMNT,      --OweTotTaa_AMNT
                        @Ln_AppTaa_AMNT,      --AppTotTaa_AMNT
                        @Ln_TransactionPaa_AMNT,      --TransactionPaa_AMNT
                        @Ln_OwePaa_AMNT + @Ln_TransactionPaa_AMNT,      --OweTotPaa_AMNT
                        @Ln_AppPaa_AMNT,      --AppTotPaa_AMNT
                        @Ln_TransactionCaa_AMNT,      --TransactionCaa_AMNT
                        @Ln_OweCaa_AMNT + @Ln_TransactionCaa_AMNT,      --OweTotCaa_AMNT
                        @Ln_AppCaa_AMNT,      --AppTotCaa_AMNT
                        @Ln_TransactionUpa_AMNT,      --TransactionUpa_AMNT
                        @Ln_OweUpa_AMNT + @Ln_TransactionUpa_AMNT,      --OweTotUpa_AMNT
                        @Ln_AppUpa_AMNT,      --AppTotUpa_AMNT
                        @Ln_TransactionUda_AMNT,      --TransactionUda_AMNT
                        @Ln_OweUda_AMNT + @Ln_TransactionUda_AMNT,      --OweTotUda_AMNT
                        @Ln_AppUda_AMNT,      --AppTotUda_AMNT
                        0,      --TransactionIvef_AMNT
                        @Ln_OweIvef_AMNT,      --OweTotIvef_AMNT
                        @Ln_AppIvef_AMNT,      --AppTotIvef_AMNT
                        0,      --TransactionNffc_AMNT
                        @Ln_OweNffc_AMNT,      --OweTotNffc_AMNT
                        @Ln_AppNffc_AMNT,      --AppTotNffc_AMNT
                        0,      --TransactionNonIvd_AMNT
                        @Ln_OweNonIvd_AMNT,      --OweTotNonIvd_AMNT
                        @Ln_AppNonIvd_AMNT,      --AppTotNonIvd_AMNT
                        0,      --TransactionMedi_AMNT
                        @Ln_OweMedi_AMNT,      --OweTotMedi_AMNT
                        @Ln_AppMedi_AMNT,      --AppTotMedi_AMNT
                        0,      --TransactionFuture_AMNT
                        @Ln_AppFuture_AMNT,      --AppTotFuture_AMNT
                        @Lc_LsupCur_CheckRecipient_ID,      --CheckRecipient_ID
                        @Lc_LsupCur_CheckRecipient_CODE,      --CheckRecipient_CODE
                        @Ld_Low_DATE,      --Batch_DATE
                        0,      --Batch_NUMB
                        0,      --SeqReceipt_NUMB
                        @Lc_Space_TEXT,      --SourceBatch_CODE
                        @Ad_ReceiptOrig_DATE,      --Receipt_DATE
                        @Ad_Process_DATE,      --Distribute_DATE
                        @Lc_Rec_ID,      --TypeRecord_CODE
                        @Ln_EventGlobalSeqCrle_NUMB,      --EventGlobalSeq_NUMB
                        @Li_CircularRuleRecord1070_NUMB  --EventFunctionalSeq_NUMB
  
					);

               SET @Li_Rowcount_QNTY = @@ROWCOUNT;

               IF @Li_Rowcount_QNTY = 0
                BEGIN
                 SET @Ls_ErrorMessage_TEXT = 'INSERT_LSUP_Y1 - 2 FAILED';

                 RAISERROR (50001,16,1);
                END
              END
            END
          END

         SET @Ld_Receipt_DATE = DATEADD (m, 1, @Ld_Receipt_DATE);
         
         SET @Lc_Rec_ID = @Lc_TypeRecordPrior_CODE;
        END

       -- Process to Increase the Owed Value_AMNT for the Voluntary Receipts
       -- Start
       IF @Ac_VoluntaryProcess_INDC = @Lc_Yes_INDC
          AND @Ac_SourceReceipt_CODE = @Lc_SourceReceiptVoluntary_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_INCREASE_OWED_4_VOL_RCPT';
         SET @Ls_Sqldata_TEXT = '';

         EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_INCREASE_OWED_4_VOL_RCPT
          @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
          @Ad_Process_DATE          = @Ad_Process_DATE OUTPUT;

         IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END

       NO_DATA_FOUND:

       -- End process to increase the Owed Value_AMNT for Voluntary Receipts
       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE #Tpaid_P1';         
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupCur_ObligationSeq_NUMB AS VARCHAR ),'');

         UPDATE #Tpaid_P1
            SET ObleFound_INDC = @Lc_No_INDC
          WHERE Case_IDNO = @Ln_LsupCur_Case_IDNO
            AND OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB
            AND ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB;
        END
      END

     SET @Ls_Sql_TEXT = 'FETCH Lsup_CUR - 2';  
     SET @Ls_Sqldata_TEXT = '';   
     
     FETCH NEXT FROM Lsup_CUR INTO @Ln_LsupCur_Case_IDNO, @Ln_LsupCur_OrderSeq_NUMB, @Ln_LsupCur_ObligationSeq_NUMB, @Ln_LsupCur_Naa_AMNT, @Ln_LsupCur_Uda_AMNT, @Ln_LsupCur_Taa_AMNT, @Ln_LsupCur_Caa_AMNT, @Ln_LsupCur_Upa_AMNT, @Ln_LsupCur_Paa_AMNT, @Ln_LsupCur_Ivef_AMNT, @Ln_LsupCur_Medi_AMNT, @Ln_LsupCur_Curr_AMNT, @Ln_LsupCur_Fut_AMNT, @Ln_LsupCur_Expt_AMNT, @Ln_LsupCur_Nffc_AMNT, @Ln_LsupCur_Nivd_AMNT, @Lc_LsupCur_CheckRecipient_ID, @Lc_LsupCur_CheckRecipient_CODE, @Lc_LsupCur_TypeWelfare_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Lsup_CUR;

   DEALLOCATE Lsup_CUR;

   IF EXISTS (SELECT 1
                FROM #EsemTab_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1';     
     SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptDistributed1820_NUMB AS VARCHAR ),'');

     INSERT INTO ESEM_Y1
                 (TypeEntity_CODE,
                  EventGlobalSeq_NUMB,
                  EventFunctionalSeq_NUMB,
                  Entity_ID)
     (SELECT a.TypeEntity_CODE,
             @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
             @Li_ReceiptDistributed1820_NUMB AS EventFunctionalSeq_NUMB,
             a.Entity_ID
        FROM #EsemTab_P1 a);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_ESEM_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('LOCAL', 'Lsup_CUR') IN (0, 1)
    BEGIN
     CLOSE Lsup_CUR;

     DEALLOCATE Lsup_CUR;
    END

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
