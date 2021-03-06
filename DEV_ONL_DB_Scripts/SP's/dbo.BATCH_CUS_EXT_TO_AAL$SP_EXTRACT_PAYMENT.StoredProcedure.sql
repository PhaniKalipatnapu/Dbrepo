/****** Object:  StoredProcedure [dbo].[BATCH_CUS_EXT_TO_AAL$SP_EXTRACT_PAYMENT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_CUS_EXT_TO_AAL$SP_EXTRACT_PAYMENT
Programmer Name 	: IMP Team
Description			: This process extracts all the open cases and their obligation, payment, and disbursement 
					  information for AAL (Automated Assistance Line) process.
Frequency			: 'DAILY'
Developed On		: 5/12/2011
Called BY			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CUS_EXT_TO_AAL$SP_EXTRACT_PAYMENT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ReceiptDistributed1820_NUMB        INT = 1820,
          @Lc_Space_TEXT                         CHAR(1) = ' ',
          @Lc_Seprator_TEXT                      CHAR(1) = '|',
          @Lc_StatusAbnormalend_CODE             CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE                 CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                  CHAR(1) = 'F',
          @Lc_ErrorTypeWarning_CODE              CHAR(1) = 'W',
          @Lc_StatusCaseOpen_CODE                CHAR(1) = 'O',
          @Lc_TypeRecordOriginal_CODE			 CHAR(1) = 'O',
          @Lc_IrsCertAdd_CODE                    CHAR(1) = 'A',
          @Lc_IrsCertMod_CODE                    CHAR(1) = 'M',
		  @Lc_IrsCertDel_CODE                    CHAR(1) = 'D',
          @Lc_TypeTransactionI_CODE              CHAR(1) = 'I',
          @Lc_TypeTransactionC_CODE              CHAR(1) = 'C',
		  @Lc_TypeTransactionD_CODE              CHAR(1) = 'D',
          @Lc_No_INDC                            CHAR(1) = 'N',
          @Lc_Yes_INDC                           CHAR(1) = 'Y',
          @Lc_TypeCaseNonIVD_CODE                CHAR(1) = 'H',
          @Lc_CaseCategoryCollectionOnly_CODE    CHAR(2) = 'CO',
          @Lc_CaseCategoryPfaCollectionOnly_CODE CHAR(2) = 'PC',
          @Lc_CaseCategoryDirectPay_CODE         CHAR(2) = 'DP',
          @Lc_TypeDebtNcpNsfFee_CODE             CHAR(2) = 'NF',
          @Lc_TypeDebtGeneticTest_CODE           CHAR(2) = 'GT',
          @Lc_BatchRunUser_TEXT                  CHAR(5) = 'BATCH',
          @Lc_NoRecordsToProcess_CODE            CHAR(5) = 'E0944',
          @Lc_Job_ID                             CHAR(7) = 'DEB0790',
          @Lc_Successful_TEXT                    CHAR(20) = 'SUCCESSFUL',
          @Ls_Procedure_NAME                     VARCHAR(100) = 'SP_EXTRACT_PAYMENT',
          @Ls_Process_NAME                       VARCHAR(100) = 'BATCH_CUS_EXT_TO_AAL',
          @Ld_High_DATE                          DATE ='12/31/9999',
          @Ld_Low_DATE                           DATE ='01/01/0001',
          @Ld_Start_DATE                         DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_TaxIntercept_NUMB           NUMERIC(2) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) =0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) =0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_Rowcount_QNTY               NUMERIC(11) =0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) =0,
          @Ln_PaymentLastReceived_AMNT    NUMERIC(11, 2)=0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_ArrearAsOfDate_TEXT         CHAR(10),
          @Lc_ArrearAmount_TEXT           CHAR(13),
          @Ls_File_NAME                   VARCHAR(50) = '',
          @Ls_FileLocation_TEXT           VARCHAR(80) = '',
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_DistributeLast_DATE         DATE;
  DECLARE @Ln_EnsdCur_Case_IDNO          NUMERIC(06),
          @Ln_EnsdCur_NcpPf_IDNO         NUMERIC(10),
          @Ln_EnsdCur_BalanceCurSup_AMNT NUMERIC(11, 2),
          @Ln_EnsdCur_Arrears_AMNT       NUMERIC(11, 2),
          @Lc_EnsdCur_TypeCase_CODE      CHAR(1),
          @Lc_EnsdCur_CaseCategory_CODE  CHAR(2);

  BEGIN TRY
   --Global temprary table creation
   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractPayment_P1';
   SET @Ls_Sqldata_TEXT ='';

   CREATE TABLE ##ExtractPayment_P1
    (
      Seq_IDNO    NUMERIC IDENTITY(1, 1),
      Record_TEXT VARCHAR(80)
    );

   BEGIN TRANSACTION EXT_PAYMENT;

   /*
   	Get the current run date and the last run date from Parameter (PARM_Y1) table, and validate 
   	that the batch program was not executed for the current run date, by ensuring that the current 
   	run date is different from the last run date in the PARM_Y1 table.  Otherwise, an error message 
   	to that effect will be written into the Batch Status Log (BSTL_Y1) table, and the process 
   	will terminate.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   /*
    Get the current run date and the last run date from Parameter (PARM_Y1) table, and validate that the batch program 
    was not executed for the current run date, by ensuring that the current run date is different from the last run date
   */
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   --Remove the existing records in the temporary EIPAY_Y1 table .
   SET @Ls_Sql_TEXT = 'DELETE EIPAY_Y1';
   SET @Ls_Sqldata_TEXT = ' Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   DELETE FROM EIPAY_Y1;

   /* Get the current obligation amount and arrears obligation amount from the Ensd_y1 table. Current 
    support obligation includes all debt types and payment on arrears.
    Include payments from ENSD_Y1 table where Receipt Backed Out/Reversed Indicator is no
    */
   DECLARE Ensd_CUR INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           NcpPf_IDNO,
           ISNULL(BalanceCurSup_AMNT, 0) AS BalanceCurSup_AMNT,
           ISNULL(a.Arrears_AMNT, 0) AS Arrears_AMNT,
           a.TypeCase_CODE,
           a.CaseCategory_CODE
      FROM ENSD_Y1 a
     WHERE
     -- Select all the open cases from the ENSD_Y1 table. 
     a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
     --Exclude cases where Case Category is equal to 'DP-Direct Pay'
     AND a.CaseCategory_CODE <> @Lc_CaseCategoryDirectPay_CODE;

   SET @Ls_Sql_TEXT = 'OPEN Ensd_CUR';
   SET @Ls_Sqldata_TEXT ='';

   OPEN Ensd_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Ensd_CUR-1';
   SET @Ls_Sqldata_TEXT ='';

   FETCH NEXT FROM Ensd_CUR INTO @Ln_EnsdCur_Case_IDNO, @Ln_EnsdCur_NcpPf_IDNO, @Ln_EnsdCur_BalanceCurSup_AMNT, @Ln_EnsdCur_Arrears_AMNT, @Lc_EnsdCur_TypeCase_CODE, @Lc_EnsdCur_CaseCategory_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_EnsdCur_Case_IDNO AS VARCHAR), '') + ', NcpPf_IDNO = ' + ISNULL(CAST(@Ln_EnsdCur_NcpPf_IDNO AS VARCHAR), '') + ', BalanceCurSup_AMNT = ' + ISNULL(CAST(@Ln_EnsdCur_BalanceCurSup_AMNT AS VARCHAR), '') + ', Arrears_AMNT = ' + ISNULL(CAST(@Ln_EnsdCur_Arrears_AMNT AS VARCHAR), '') + ', TypeCase_CODE = ' + @Lc_EnsdCur_TypeCase_CODE + ', CaseCategory_CODE = ' + @Lc_EnsdCur_CaseCategory_CODE;

   -- Get payment detail for each case from Ends_Cur
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Rowcount_QNTY =@Ln_Rowcount_QNTY + 1;
     SET @Ln_TaxIntercept_NUMB =0;
     SET @Ls_CursorLocation_TEXT = 'Rowcount_QNTY = ' + CAST(@Ln_Rowcount_QNTY AS VARCHAR);
     SET @Ln_PaymentLastReceived_AMNT =0;
     SET @Ld_DistributeLast_DATE =@Ld_Low_DATE;

     SELECT TOP 1 @Ln_PaymentLastReceived_AMNT = ISNULL(LastPayment_AMNT, 0),
                  @Ld_DistributeLast_DATE = ISNULL(LastPayment_DATE, @Ld_Low_DATE)
       FROM (SELECT Distribute_DATE LastPayment_DATE,
                    SUM(l.TransactionNaa_AMNT + l.TransactionPaa_AMNT + l.TransactionTaa_AMNT + l.TransactionCaa_AMNT + l.TransactionUpa_AMNT + l.TransactionUda_AMNT + l.TransactionIvef_AMNT + l.TransactionNffc_AMNT + l.TransactionNonIvd_AMNT + l.TransactionMedi_AMNT) OVER(PARTITION BY Distribute_DATE) LastPayment_AMNT
               FROM LSUP_Y1 l
              WHERE l.case_idno = @Ln_EnsdCur_Case_IDNO
                AND l.EventFunctionalSeq_NUMB = @Li_ReceiptDistributed1820_NUMB
                AND l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                AND NOT EXISTS (SELECT 1
                                  FROM RCTH_Y1 b
                                 WHERE l.Batch_DATE = b.Batch_DATE
                                   AND l.Batch_NUMB = b.Batch_NUMB
                                   AND l.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                   AND l.SourceBatch_CODE = b.SourceBatch_CODE
                                   AND b.BackOut_INDC = @Lc_Yes_INDC
                                   AND b.EndValidity_DATE = @Ld_High_DATE)
                AND NOT EXISTS (SELECT 1
                                  FROM OBLE_Y1 o
                                 WHERE o.Case_IDNO = l.Case_IDNO
                                   AND o.OrderSeq_NUMB = l.OrderSeq_NUMB
                                   AND o.ObligationSeq_NUMB = l.ObligationSeq_NUMB
                                   AND o.EndValidity_DATE = @Ld_High_DATE
                                   AND o.TypeDebt_CODE IN (@Lc_TypeDebtNcpNsfFee_CODE, @Lc_TypeDebtGeneticTest_CODE))) s
      WHERE LastPayment_AMNT > 0
      ORDER BY LastPayment_DATE DESC;

	   /*Bug 13844: Only Federal Taxoffset record with transaction type 'A-add' or 'M-Modify' should be submitted to Automated Assistance Line (AAL), 
					'D-Delete' should not be submitted.*/
     -- Get the federal tax submission from the Federal Last Sent (IFMS_Y1) table
     SET @Ls_Sql_TEXT = 'SELECT FEDH_Y1';
     SET @Ls_Sqldata_TEXT = 'NcpPf_IDNO = ' + CAST(@Ln_EnsdCur_NcpPf_IDNO AS VARCHAR) + ', IrsCertAdd_CODE = ' + @Lc_IrsCertAdd_CODE + ', IrsCertMod_CODE = ' + @Lc_IrsCertMod_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', No_INDC = ' + @Lc_No_INDC;

    SELECT TOP 1 @Ln_TaxIntercept_NUMB = 2
	FROM IFMS_Y1 f
      WHERE f.MemberMci_IDNO = @Ln_EnsdCur_NcpPf_IDNO
        and  f.case_idno=@Ln_EnsdCur_Case_IDNO
		AND f.TypeTransaction_CODE IN(@Lc_IrsCertAdd_CODE, @Lc_IrsCertMod_CODE)
        AND f.SubmitLast_DATE < @Ld_Run_DATE
		and f.Transaction_AMNT>0
        AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                            FROM IFMS_Y1 h
                                           WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                             AND h.SubmitLast_DATE < @Ld_Run_DATE
                                             AND h.TypeTransaction_CODE IN(@Lc_IrsCertAdd_CODE, @Lc_IrsCertMod_CODE,@Lc_IrsCertDel_CODE)
                                           and h.Case_IDNO=f.Case_IDNO
                                             AND f.TypeArrear_CODE = h.TypeArrear_CODE);
    --Bug 13844:  one record with Transaction Type 'A-Add', 'M-Modify','D-Delete' always exist in IFMS_Y1 table so no need to check HIFMS_Y1 - REMOVED
   
	 --	Get the state tax submission from the State Last Sent (ISTX_Y1) table
     --Bug 13844: IF record with transaction type 'D-DELETE' has maximum TransactionEventSeq_NUMB then TaxIntercept_NUMB should not be incremented -START
	 /* Bug 13844: Only State Taxoffset with transaction type 'I-Initiate' or 'C-Adjust' should be submitted to Automated Assistance Line (AAL), 
	'D-Delete' should not be submitted.*/
	 SET @Ls_Sql_TEXT = 'SELECT_ISTX_Y1';
     SET @Ls_Sqldata_TEXT = 'NcpPf_IDNO = ' + CAST(@Ln_EnsdCur_NcpPf_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_EnsdCur_Case_IDNO AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeTransactionI_CODE = ' + @Lc_TypeTransactionI_CODE + ', TypeTransactionC_CODE = ' + @Lc_TypeTransactionC_CODE +', TypeTransactionD_CODE = '+@Lc_TypeTransactionD_CODE;

     SELECT TOP 1 @Ln_TaxIntercept_NUMB = @Ln_TaxIntercept_NUMB + 1
       FROM ISTX_Y1 s
      WHERE s.MemberMci_IDNO = @Ln_EnsdCur_NcpPf_IDNO
        AND s.Case_IDNO = @Ln_EnsdCur_Case_IDNO
        AND s.TypeTransaction_CODE IN(@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE)
        AND s.SubmitLast_DATE < @Ld_Run_DATE
        AND s.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                            FROM ISTX_Y1 h
                                           WHERE s.MemberMci_IDNO = h.MemberMci_IDNO
                                             AND s.Case_IDNO = h.Case_IDNO
                                             AND h.TypeTransaction_CODE IN(@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE, @Lc_TypeTransactionD_CODE)
                                             AND h.TypeArrear_CODE=s.TypeArrear_CODE
											 AND h.SubmitLast_DATE < @Ld_Run_DATE);
	 --Bug 13844: IF record with transaction type 'D-DELETE' has maximum TransactionEventSeq_NUMB then TaxIntercept_NUMB should not be incremented -END
     SET @Lc_ArrearAmount_TEXT=@Lc_Space_TEXT;

     IF @Lc_EnsdCur_TypeCase_CODE = @Lc_TypeCaseNonIVD_CODE
      BEGIN
       IF @Lc_EnsdCur_CaseCategory_CODE IN(@Lc_CaseCategoryCollectionOnly_CODE, @Lc_CaseCategoryPfaCollectionOnly_CODE)
        BEGIN
         SET @Lc_ArrearAmount_TEXT=0;
         SET @Lc_ArrearAsOfDate_TEXT=CONVERT(VARCHAR, @Ld_Run_DATE, 101);
        END
       ELSE
        BEGIN
         SET @Lc_ArrearAmount_TEXT=@Lc_Space_TEXT;
         SET @Lc_ArrearAsOfDate_TEXT= @Lc_Space_TEXT;
        END
      END
     ELSE IF @Ln_EnsdCur_Arrears_AMNT = 0
      BEGIN
       SET @Lc_ArrearAmount_TEXT=@Lc_Space_TEXT;
       SET @Lc_ArrearAsOfDate_TEXT= @Lc_Space_TEXT;
      END
     ELSE
      BEGIN
       SET @Lc_ArrearAmount_TEXT = CONVERT(CHAR(10), CONVERT(VARCHAR, (CAST(ROUND(@Ln_EnsdCur_Arrears_AMNT, 2) * 100 AS BIGINT))));
       SET @Lc_ArrearAsOfDate_TEXT=CONVERT(VARCHAR, @Ld_Run_DATE, 101);
      END

     SET @Ls_Sql_TEXT = 'INSERT EIPAY_Y1';
     SET @Ls_Sqldata_TEXT = 'TaxIntercept_NUMB = ' + CAST(@Ln_TaxIntercept_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Case_IDNO = ' + ISNULL(CAST(@Ln_EnsdCur_Case_IDNO AS VARCHAR), '') + ', NcpPf_IDNO = ' + ISNULL(CAST(@Ln_EnsdCur_NcpPf_IDNO AS VARCHAR), '') + ', TypeCase_CODE = ' + @Lc_EnsdCur_TypeCase_CODE + ', CaseCategory_CODE = ' + @Lc_EnsdCur_CaseCategory_CODE + ', ArrearAmount_TEXT = ' + @Lc_ArrearAmount_TEXT + ', ArrearAsOfDate_TEXT = ' + @Lc_ArrearAsOfDate_TEXT;

     --Insert member details into the temporary EIPAY_Y1table.
     INSERT INTO EIPAY_Y1
                 (Case_IDNO,
                  Payment_AMNT,
                  PaymentReceived_DATE,
                  BalanceCurSup_AMNT,
                  BalanceCurSupAsOf_DATE,
                  Arrears_AMNT,
                  ArrearsAsOf_DATE,
                  Tax_CODE)
     SELECT CAST(@Ln_EnsdCur_Case_IDNO AS VARCHAR) AS Case_IDNO,
            CASE @Ln_PaymentLastReceived_AMNT
             WHEN 0
              THEN @Lc_Space_TEXT
             ELSE CONVERT(CHAR(10), CAST(CAST(ROUND(@Ln_PaymentLastReceived_AMNT, 2) * 100 AS BIGINT)AS VARCHAR))
            END AS Payment_AMNT,
            CASE @Ld_DistributeLast_DATE
             WHEN @Ld_High_DATE
              THEN @Lc_Space_TEXT
             WHEN @Ld_Low_DATE
              THEN @Lc_Space_TEXT
             ELSE
              CASE @Ln_PaymentLastReceived_AMNT
               WHEN 0
                THEN @Lc_Space_TEXT
               ELSE CONVERT(VARCHAR, @Ld_DistributeLast_DATE, 101)
              END
            END AS PaymentReceived_DATE,
            CASE @Ln_EnsdCur_BalanceCurSup_AMNT
             WHEN 0
              THEN @Lc_Space_TEXT
             ELSE CONVERT(CHAR(10), CAST(CAST(ROUND(@Ln_EnsdCur_BalanceCurSup_AMNT, 2) * 100 AS BIGINT) AS VARCHAR))
            END AS BalanceCurSup_AMNT,
            CASE @Ln_EnsdCur_BalanceCurSup_AMNT
             WHEN 0
              THEN @Lc_Space_TEXT
             ELSE CONVERT(VARCHAR, @Ld_Run_DATE, 101)
            END AS BalanceCurSupAsOf_DATE,
            @Lc_ArrearAmount_TEXT Arrears_AMNT,
            @Lc_ArrearAsOfDate_TEXT ArrearsAsOf_DATE,
            CAST(@Ln_TaxIntercept_NUMB AS VARCHAR) AS Tax_CODE;

     SET @Ls_Sql_TEXT = 'FETCH Ensd_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Ensd_CUR INTO @Ln_EnsdCur_Case_IDNO, @Ln_EnsdCur_NcpPf_IDNO, @Ln_EnsdCur_BalanceCurSup_AMNT, @Ln_EnsdCur_Arrears_AMNT, @Lc_EnsdCur_TypeCase_CODE, @Lc_EnsdCur_CaseCategory_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Ensd_CUR;

   DEALLOCATE Ensd_CUR;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     -- Log if no record to process
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG -1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', ErrorTypeWarning_CODE = ' + @Lc_ErrorTypeWarning_CODE + ', Rowcount_QNTY = ' + CAST(@Ln_Rowcount_QNTY AS VARCHAR) + ', NoRecordsToProcess_CODE = ' + @Lc_NoRecordsToProcess_CODE + ', Space_TEXT = ' + @Lc_Space_TEXT + ', Sqldata_TEXT = ' + @Ls_Sqldata_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = @Ln_Rowcount_QNTY,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = '##ExtractPayment_P1';
   SET @Ls_Sqldata_TEXT ='Seprator_TEXT = ' + @Lc_Seprator_TEXT + ', Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

   INSERT INTO ##ExtractPayment_P1
               (Record_TEXT)
   SELECT CAST(Case_IDNO + @Lc_Seprator_TEXT + LTRIM(RTRIM(Payment_AMNT)) + @Lc_Seprator_TEXT + LTRIM(RTRIM(PaymentReceived_DATE)) + @Lc_Seprator_TEXT + LTRIM(RTRIM(BalanceCurSup_AMNT)) + @Lc_Seprator_TEXT + LTRIM(RTRIM(BalanceCurSupAsOf_DATE)) + @Lc_Seprator_TEXT + LTRIM(RTRIM(Arrears_AMNT)) + @Lc_Seprator_TEXT + LTRIM(RTRIM(ArrearsAsOf_DATE)) + @Lc_Seprator_TEXT + LTRIM(RTRIM(Tax_CODE)) AS CHAR(80)) AS Record_TEXT
     FROM EIPAY_Y1 e;

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

   COMMIT TRANSACTION EXT_PAYMENT;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractPayment_P1 ORDER BY Seq_IDNO';
   SET @Ls_Sql_TEXT = 'Extract Data';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

	EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   -- on successful executiopn update PARM_Y1
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   --Successful execution write to BSTL_Y1
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', UserBatch_ID = ' + @Lc_BatchRunUser_TEXT + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', Successful_TEXT = ' + @Lc_Successful_TEXT + ', StatusSuccess_CODE = ' + @Lc_StatusSuccess_CODE + ', Space_TEXT = ' + @Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   DROP TABLE ##ExtractPayment_P1;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EXT_PAYMENT;
    END;

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..##ExtractPayment_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractPayment_P1;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Ensd_CUR') IN (0, 1)
    BEGIN
     CLOSE Ensd_CUR;

     DEALLOCATE Ensd_CUR;
    END;

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
