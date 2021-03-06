/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_CBOR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
--------------------------------------------------------------------------------------------------------------------  
Procedure Name		: BATCH_COMMON$SP_INSERT_CBOR  
Programmer Name		: IMP Team
Description			: Procedure inserts records in CBOR_Y1 table
Frequency			: 
Developed On		: 04/12/2011
Called By			: 
Called On			:  
--------------------------------------------------------------------------------------------------------------------  
Modified By			: 
Modified On			:
Version No			: 1.0  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_CBOR]
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(5),
 @Ac_StatusAccount_CODE       CHAR(2) = ' ',
 @Ac_Referral_CODE            CHAR(1) = ' ',
 @Ac_ReasonExclude_CODE       CHAR(2) = ' ',
 @Ac_TypeTransCbor_CODE       CHAR(1) = ' ',
 @An_SupObligationMm_AMNT     NUMERIC(11, 2) = 0,
 @An_Arrear_AMNT              NUMERIC(11, 2) = 0,
 @Ad_SubmitForm_DATE          DATE = '01/01/0001',
 @Ad_PaymentLast_DATE         DATE = '01/01/0001',
 @Ad_SubmitLast_DATE          DATE = '01/01/0001',
 @Ac_Merged_INDC              CHAR(1) = ' ',
 @Ac_Form_INDC                CHAR(1) = 'N',
 @An_HighestArrear_AMNT       NUMERIC(11, 2) = 0,
 @Ad_LastDelinquent_DATE      DATE = '01/01/0001',
 @Ad_BeginValidity_DATE       DATE = '01/01/0001',
 @Ad_EndValidity_DATE         DATE = '01/01/0001',
 @Ac_SignedonWorker_ID        CHAR(30) = ' ',
 @An_WorkerUpdate_ID          CHAR(30) = NULL,
 @Ad_Update_DTTM              DATETIME2(0) = '01/01/0001',
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ad_Run_DATE                 DATE,
 @Ac_Support_INDC             CHAR(1) = 'E',
 @Ac_Msg_CODE                 CHAR(1) = 'F' OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) = ' ' OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_Space_TEXT                   CHAR(1) = ' ',
           @Lc_CbrSupportProcess_TEXT       CHAR(1) = 'C',
           @Lc_Daily_TEXT                   CHAR(1) = 'D',
           @Lc_Weekly_TEXT                  CHAR(1) = 'W',
           @Lc_Monthly_TEXT                 CHAR(1) = 'M',
           @Lc_Biweekly_TEXT                CHAR(1) = 'B',
           @Lc_Semimonthly_TEXT             CHAR(1) = 'S',
           @Lc_Annual_TEXT                  CHAR(1) = 'A',
           @Lc_Yes_TEXT                     CHAR(1) = 'Y',
           @Lc_No_TEXT                      CHAR(1) = 'N',
           @Lc_Referral_CODE                CHAR(1) = 'R',
           @Lc_TypeTransCbor_CODE           CHAR(1) = ' ',
           @Lc_Merged_INDC                  CHAR(1) = ' ',
           @Lc_Form_INDC                    CHAR(1) = ' ',
           @Lc_TypeDebtChildSupport_CODE    CHAR(2) = 'CS',
           @Lc_TypeDebtMedicalSupport_CODE  CHAR(2) = 'MS',
           @Lc_TypeDebtSpousalSupport_CODE  CHAR(2) = 'SS',
           @Lc_TypeDebtNcpNsfFee_CODE       CHAR(2) = 'NF',
           @Lc_TypeDebtGeneticTest_CODE     CHAR(2) = 'GT',
           @Lc_StatusAccount_CODE           CHAR(2) = ' ',
           @Lc_ReasonExclude_CODE           CHAR(2) = ' ',
           @Ls_Procedure_NAME               VARCHAR(100) = 'SP_INSERT_CBOR',
           @Ld_EndValidity_DATE             DATE = '12/31/9999',
           @Ld_Low_DATE                     DATE = '01/01/0001',
           @Ld_High_DATE                    DATE = '12/31/9999';
  DECLARE  @Ln_Zero_NUMB		     NUMERIC(1) = 0,
		   @Ln_Error_NUMB            NUMERIC(11),
           @Ln_ErrorLine_NUMB        NUMERIC(11) = 0,
           @Ln_RowCount_NUMB         NUMERIC(11),
           @Ln_SupObligationMm_AMNT  NUMERIC(11,2) = 0,
           @Ln_Arrear_AMNT           NUMERIC(11,2) = 0,
           @Ln_HighestArrear_AMNT    NUMERIC(11,2) = 0,
           @Li_RowCounty_NUMB        INT,
           @Lc_Empty_TEXT            CHAR(1) = '',
           @Ls_Sql_TEXT              VARCHAR(200) = '',
           @Ls_SqlData_TEXT          VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT        VARCHAR(4000),
           @Ld_SubmitForm_DATE       DATE,
           @Ld_PaymentLast_DATE      DATE,
           @Ld_SubmitLast_DATE       DATE,
           @Ld_LastDelinquent_DATE   DATE,
           @Ld_BeginValidity_DATE    DATE,
           @Ld_Update_DTTM           DATETIME2;

  BEGIN TRY
   SET @Ld_BeginValidity_DATE = @Ad_Run_DATE;
   SET @Ld_Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = ' CALCULATE Arrear_AMNT';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   IF (@Ac_Support_INDC <> @Lc_CbrSupportProcess_TEXT)
    BEGIN
     SELECT @Ln_Arrear_AMNT = ROUND(SUM(ISNULL((s.OweTotNaa_AMNT - s.AppTotNaa_AMNT), 0) + ISNULL((s.OweTotPaa_AMNT - s.AppTotPaa_AMNT), 0) + ISNULL((s.OweTotTaa_AMNT - s.AppTotTaa_AMNT), 0) + ISNULL((s.OweTotCaa_AMNT - s.AppTotCaa_AMNT), 0) + ISNULL((s.OweTotUpa_AMNT - s.AppTotUpa_AMNT), 0) + ISNULL((s.OweTotUda_AMNT - s.AppTotUda_AMNT), 0) + ISNULL((s.OweTotIvef_AMNT - s.AppTotIvef_AMNT), 0) + ISNULL((s.OweTotNffc_AMNT - s.AppTotNffc_AMNT), 0) + ISNULL((s.OweTotMedi_AMNT - s.AppTotMedi_AMNT), 0) + ISNULL((s.OweTotNonIvd_AMNT - s.AppTotNonIvd_AMNT), 0) - (s.OweTotCurSup_AMNT - s.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                WHEN s.MtdCurSupOwed_AMNT < s.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 THEN s.AppTotCurSup_AMNT - s.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               END)), 2) -- FullArrears_AMNT in ENSD_Y1 table  
       FROM LSUP_Y1 s
      WHERE s.Case_IDNO = @An_Case_IDNO
        AND s.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND s.SupportYearMonth_NUMB = (SELECT CONVERT(VARCHAR(6), @Ad_Run_DATE, 112))
        AND s.EventGlobalSeq_NUMB = (SELECT MAX(h.EventGlobalSeq_NUMB)
                                       FROM LSUP_Y1 h
                                      WHERE s.Case_IDNO = h.Case_IDNO
                                        AND s.OrderSeq_NUMB = h.OrderSeq_NUMB
                                        AND s.ObligationSeq_NUMB = h.ObligationSeq_NUMB
                                        AND s.SupportYearMonth_NUMB = h.SupportYearMonth_NUMB)        
        AND EXISTS (SELECT 1 
                      FROM OBLE_Y1 o
                     WHERE s.Case_IDNO = o.Case_IDNO
                       AND s.OrderSeq_NUMB = o.OrderSeq_NUMB
                       AND s.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                       AND o.TypeDebt_CODE NOT IN(@Lc_TypeDebtNcpNsfFee_CODE, @Lc_TypeDebtGeneticTest_CODE)
                       AND o.EndValidity_DATE = @Ld_High_DATE);

     SET @Ls_Sql_TEXT = ' CALCULATE SupObligationMm_AMNT';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_SupObligationMm_AMNT = SUM(CASE x.FreqPeriodic_CODE
                                            WHEN @Lc_Daily_TEXT
                                             THEN (x.Periodic_AMNT * 365) / 12
                                            WHEN @Lc_Weekly_TEXT
                                             THEN (x.Periodic_AMNT * 52) / 12
                                            WHEN @Lc_Monthly_TEXT
                                             THEN (x.Periodic_AMNT * 12) / 12
                                            WHEN @Lc_Biweekly_TEXT
                                             THEN (x.Periodic_AMNT * 26) / 12
                                            WHEN @Lc_Semimonthly_TEXT
                                             THEN (x.Periodic_AMNT * 24) / 12
                                            WHEN @Lc_Annual_TEXT
                                             THEN (x.Periodic_AMNT / 12)
                                            ELSE x.Periodic_AMNT
                                           END)
       FROM OBLE_Y1 x
      WHERE x.Case_IDNO = @An_Case_IDNO
        AND x.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND x.TypeDebt_CODE IN (@Lc_TypeDebtChildSupport_CODE, @Lc_TypeDebtMedicalSupport_CODE, @Lc_TypeDebtSpousalSupport_CODE)
        AND x.Periodic_AMNT > 0
        AND @Ad_Run_DATE BETWEEN x.BeginObligation_DATE AND x.EndObligation_DATE
        AND x.EndValidity_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = ' SELECT Receipt_DATE';
     SET @Ls_SqlData_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', BackOut_INDC = ' + ISNULL(@Lc_Yes_TEXT,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ld_PaymentLast_DATE = ISNULL(MAX(r.Receipt_DATE), @Ld_Low_DATE)
       FROM RCTH_Y1 r
      WHERE r.PayorMCI_IDNO = @An_MemberMci_IDNO
        AND r.Case_IDNO = @An_Case_IDNO        
        AND r.EndValidity_DATE = @Ld_High_DATE
        AND NOT EXISTS (SELECT 1
                          FROM RCTH_Y1 x
                         WHERE r.Receipt_DATE = x.Receipt_DATE
                           AND r.SourceBatch_CODE = x.SourceBatch_CODE
                           AND r.Batch_NUMB = x.Batch_NUMB
                           AND r.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                           AND x.BackOut_INDC = @Lc_Yes_TEXT
                           AND x.EndValidity_DATE = @Ld_High_DATE);

     SET @Ls_Sql_TEXT = ' SELECT Active CBOR_Y1 Records';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_HighestArrear_AMNT = CASE
                                      WHEN ISNULL(LTRIM(RTRIM(e.HighestArrear_AMNT)), 0) < @Ln_Arrear_AMNT
                                       THEN e.Arrear_AMNT
                                      ELSE @Ln_Arrear_AMNT
                                     END,
            @Lc_StatusAccount_CODE = ISNULL(e.StatusAccount_CODE, @Lc_Space_TEXT),
            @Lc_ReasonExclude_CODE = @Lc_Space_TEXT,
            @Lc_TypeTransCbor_CODE = ISNULL(e.TypeTransCbor_CODE, @Lc_Space_TEXT),
            @Ld_SubmitForm_DATE = ISNULL(e.SubmitForm_DATE, @Ad_Run_DATE),
            @Ld_SubmitLast_DATE = ISNULL(e.SubmitLast_DATE, @Ad_Run_DATE),
            @Lc_Merged_INDC = ISNULL(e.Merged_INDC, @Lc_Space_TEXT),
            @Lc_Form_INDC = ISNULL(e.Form_INDC, @Lc_No_TEXT),
            @Ld_LastDelinquent_DATE = ISNULL(e.LastDelinquent_DATE, @Ld_Low_DATE)
       FROM CBOR_Y1 e
      WHERE e.Case_IDNO = @An_Case_IDNO
        AND e.MemberMci_IDNO = @An_MemberMci_IDNO
        AND e.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND e.EndValidity_DATE = @Ld_High_DATE;

     SET @Li_RowCounty_NUMB = @@ROWCOUNT;

     IF(@Li_RowCounty_NUMB = 0)
      BEGIN
       SET @Ln_HighestArrear_AMNT= dbo.BATCH_COMMON$SF_GET_ARREARS_ENF_ELIGIBLE(@An_Case_IDNO, @An_OrderSeq_NUMB, @Ad_Run_DATE);
       SET @Ld_SubmitLast_DATE = @Ad_Run_DATE;
       SET @Ld_LastDelinquent_DATE = @Ld_Low_DATE;
       SET @Ld_SubmitForm_DATE = @Ad_Run_DATE;
       SET @Lc_StatusAccount_CODE = @Lc_Space_TEXT;
       SET @Lc_ReasonExclude_CODE = @Lc_Space_TEXT;
       SET @Lc_Merged_INDC = @Lc_Space_TEXT;
       SET @Lc_Form_INDC = @Lc_No_TEXT;
      END
    END

   SET @Ls_Sql_TEXT = ' END DATE THE CBOR_Y1 RECORD';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ln_RowCount_NUMB = COUNT(1)
     FROM CBOR_Y1 a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.MemberMci_IDNO = @An_MemberMci_IDNO
      AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND a.EndValidity_DATE = @Ld_High_DATE;

   IF(@Ln_RowCount_NUMB > 0)
    BEGIN
	 SET @Ls_Sql_TEXT = 'UPDATE CBOR_Y1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     
     UPDATE CBOR_Y1
        SET EndValidity_DATE = @Ad_Run_DATE
      WHERE Case_IDNO = @An_Case_IDNO
        AND MemberMci_IDNO = @An_MemberMci_IDNO
        AND OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowCount_NUMB = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE CBOR_Y1 TABLE FAILED';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = ' INSERT THE RECORD IN CBOR_Y1 TO SEND STATUS';
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'');

   INSERT INTO CBOR_Y1
               (MemberMci_IDNO,
                Case_IDNO,
                OrderSeq_NUMB,
                StatusAccount_CODE,
                Referral_CODE,
                ReasonExclude_CODE,
                TypeTransCbor_CODE,
                SupObligationMm_AMNT,
                Arrear_AMNT,
                SubmitForm_DATE,
                PaymentLast_DATE,
                SubmitLast_DATE,
                Merged_INDC,
                Form_INDC,
                HighestArrear_AMNT,
                LastDelinquent_DATE,
                BeginValidity_DATE,
                EndValidity_DATE,
                WorkerUpdate_ID,
                Update_DTTM,
                TransactionEventSeq_NUMB)
        VALUES ( @An_MemberMci_IDNO,-- MemberMci_IDNO
                 @An_Case_IDNO,-- Case_IDNO
                 @An_OrderSeq_NUMB,-- OrderSeq_NUMB
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ac_StatusAccount_CODE
                  ELSE @Lc_StatusAccount_CODE
                 END,-- StatusAccount_CODE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ac_Referral_CODE
                  ELSE @Lc_Referral_CODE
                 END,-- Referral_CODE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ac_ReasonExclude_CODE
                  ELSE @Lc_ReasonExclude_CODE
                 END,-- ReasonExclude_CODE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ac_TypeTransCbor_CODE
                  ELSE @Lc_TypeTransCbor_CODE
                 END,-- TypeTransCbor_CODE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @An_SupObligationMm_AMNT
                  ELSE ISNULL(@Ln_SupObligationMm_AMNT, @Ln_Zero_NUMB)
                 END,-- SupObligationMm_AMNT
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @An_Arrear_AMNT
                  ELSE @Ln_Arrear_AMNT
                 END,-- Arrear_AMNT
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ad_SubmitForm_DATE
                  ELSE @Ld_SubmitForm_DATE
                 END,-- SubmitForm_DATE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ad_PaymentLast_DATE
                  ELSE @Ld_PaymentLast_DATE
                 END,-- PaymentLast_DATE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ad_SubmitLast_DATE
                  ELSE @Ld_SubmitLast_DATE
                 END,-- SubmitLast_DATE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ac_Merged_INDC
                  ELSE @Lc_Merged_INDC
                 END,-- Merged_INDC
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ac_Form_INDC
                  ELSE @Lc_Form_INDC
                 END,-- Form_INDC
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @An_HighestArrear_AMNT
                  ELSE @Ln_HighestArrear_AMNT
                 END,-- HighestArrear_AMNT
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ad_LastDelinquent_DATE
                  ELSE @Ld_LastDelinquent_DATE
                 END,-- LastDelinquent_DATE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ad_BeginValidity_DATE
                  ELSE @Ld_BeginValidity_DATE
                 END,-- BeginValidity_DATE
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ad_EndValidity_DATE
                  ELSE @Ld_EndValidity_DATE
                 END,-- EndValidity_DATE
                 CASE
                  WHEN ((LTRIM(RTRIM(@Ac_SignedonWorker_ID)) IS NOT NULL)
                        AND (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) != @Lc_Empty_TEXT))
                   THEN @Ac_SignedonWorker_ID
                  ELSE @An_WorkerUpdate_ID
                 END,-- WorkerUpdate_ID
                 CASE
                  WHEN @Ac_Support_INDC = @Lc_CbrSupportProcess_TEXT
                   THEN @Ad_Update_DTTM
                  ELSE @Ld_Update_DTTM
                 END,-- Update_DTTM
                 @An_TransactionEventSeq_NUMB); -- TransactionEventSeq_NUMB
   SET @Ln_RowCount_NUMB = @@ROWCOUNT;

   IF @Ln_RowCount_NUMB = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT INTO CBOR_Y1 TABLE FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END
	   
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH;
 END; 

GO
