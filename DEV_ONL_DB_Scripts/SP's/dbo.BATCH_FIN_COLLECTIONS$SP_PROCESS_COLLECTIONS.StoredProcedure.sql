/****** Object:  StoredProcedure [dbo].[BATCH_FIN_COLLECTIONS$SP_PROCESS_COLLECTIONS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_COLLECTIONS$SP_PROCESS_COLLECTIONS
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_COLLECTIONS$SP_PROCESS_COLLECTIONS reads the data received from various deposit sources
					  such as SDU, IRS and loads into temporary tables LCSDU_Y1, LCIRS_Y1 for further processing.  If the counts and amounts in the header/trailer
					  record types do not match with the counts and Value_AMNT totals of the detail record types,
					  an error message will be written into Batch Status_CODE Log (BSTL screen/BSTL table) and the file
					  processing will be terminated.

					  The second step is to read the records in the temporary tables and create batch records and
					  the receipt records. The system validates the payor and case Seq_IDNO received in the input file and
					  automatically classifies the receipts as unidentified if the payor/case Seq_IDNO is not valid;

					  The receipts are placed on hold if there are any hold instructions as defined on global Hold
					  Instructions Management screen (HIMS screen/HIMS table) or at case or payor level as defined on
					  Manual Hold Instructions screen (HLDI screen/DISH table), or due to special processing based on
					  the RCTH_Y1 Source (for example IRS, CSLN, FIDM) or NSF Status_CODE in the past.
					  Additional information on unidentified receipts is recorded on Unidentified Receipts screen
					  (URCT screen/URCT table).
Frequency			: 'DAILY'
Developed On		: 12/05/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_COLLECTIONS$SP_PROCESS_COLLECTIONS]
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE @Ln_Payor999995_IDNO                 NUMERIC(10) = 0000999995,
          @Li_AddingAReceiptBatch1110_NUMB     INT = 1110,
		  @Li_ReceiptOnHold1420_NUMB           INT = 1420,
		  @Li_IdentifyAReceipt1410_NUMB		   INT = 1410,        
          @Lc_CaseMemberStatusActive_CODE      CHAR(1) = 'A',
          @Lc_NoSpace_TEXT					   CHAR(1) = '',
          @Lc_Space_TEXT                       CHAR(1) = ' ',
          @Lc_No_INDC                          CHAR(1) = 'N',
          @Lc_Yes_INDC                         CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE                CHAR(1) = 'F',
          @Lc_StatusBatchReconciled_CODE       CHAR(1) = 'R',
          @Lc_StatusBatchUnreconciled_CODE     CHAR(1) = 'U',
          @Lc_TypePostingPayor_CODE            CHAR(1) = 'P',
          @Lc_TypePostingCase_CODE             CHAR(1) = 'C',
          @Lc_StatusReceiptUnidentified_CODE   CHAR(1) = 'U',
          @Lc_CaseRelationshipNcp_CODE         CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE   CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE          CHAR(1) = 'C',
          @Lc_StatusReceiptHeld_CODE           CHAR(1) = 'H',
          @Lc_StatusReceiptIdentified_CODE     CHAR(1) = 'I',
          @Lc_TypePrimarySsn_CODE              CHAR(1) = 'P',
          @Lc_TypeSecondarySsn_CODE            CHAR(1) = 'S',
          @Lc_TypeTertiarySsn_CODE             CHAR(1) = 'T',
          @Lc_VerificationStatusGood_CODE      CHAR(1) = 'Y',
          @Lc_VerificationStatusPending_CODE   CHAR(1) = 'P',
          @Lc_StatusCaseOpen_CODE              CHAR(1) = 'O',
          @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE           CHAR(1) = 'A',
          @Lc_TypeItinI_CODE                   CHAR(1) = 'I',
          @Lc_ProcessP_CODE                    CHAR(1) = 'P',
          @Lc_TypeErrorE_CODE				   CHAR(1) = 'E',
          @Lc_StatusReceipt_CODE               CHAR(1) = ' ',
          @Lc_SuspendPayment1_CODE             CHAR(1) = '1',
          @Lc_SourceReceiptCpRecoupmentCR_CODE CHAR(2) = 'CR',
          @Lc_SourceReceiptCpFeePaymentCF_CODE CHAR(2) = 'CF',
          @Lc_SeqNumb000_TEXT                  CHAR(3) = '000',
          @Lc_SourceBatchSdu_CODE              CHAR(3) = 'SDU',
          @Lc_SourceBatchSpc_CODE              CHAR(3) = 'SPC',
          @Lc_OldSourceBatch_CODE              CHAR(3) = '000',
          @Lc_HoldReasonStatusSncl_CODE        CHAR(4) = 'SNCL',
          @Lc_HoldReasonStatusSncc_CODE        CHAR(4) = 'SNCC',
          @Lc_HoldReasonStatusSnna_CODE        CHAR(4) = 'SNNA',
          @Lc_UnidenholdExceptionsdu_CODE      CHAR(4) = 'UNEX',
          @Lc_UnidenholdUnidentreceipts_CODE   CHAR(4) = 'UNID',
          @Lc_TypeEntityCase_CODE              CHAR(4) = 'CASE',
          @Lc_ErrorE0085_CODE                  CHAR(5) = 'E0085',
          @Lc_ErrorE1062_CODE                  CHAR(5) = 'E1062',
          @Lc_ErrorE1424_CODE				   CHAR(5) = 'E1424',
          @Lc_TypeEntityRctdt_CODE             CHAR(5) = 'RCTDT',
          @Lc_TypeEntityRctno_CODE             CHAR(5) = 'RCTNO',
          @Lc_DateAdjust0101_TEXT              CHAR(6) = '01/01/',
          @Lc_OldSeqNo_NUMB                    CHAR(6) = '000',
          @Lc_JobProcess_ID                    CHAR(7) = 'DEB0540',
          @Lc_Successful_TEXT                  CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                CHAR(30) = 'BATCH',
          @Ls_ParmDateProblem_TEXT			   VARCHAR(100) = 'PARM DATE PROBLEM',
          @Ls_Remarksdesc01_TEXT               VARCHAR(100) = 'NO MATCHING MEMBER FOR SSN',
          @Ls_Remarksdesc02_TEXT               VARCHAR(100) = 'TOO MANY MATCHING MEMBER FOR SSN',
          @Ls_Remarksdesc04_TEXT               VARCHAR(100) = 'NO VALID RECORD FOUND FOR MEMBER',
          @Ls_Remarksdesc05_TEXT               VARCHAR(100) = 'INVALID IRS REFERENCE ID (MEMBER MCI NUMBER)',
          @Ls_Remarksdesc06_TEXT               VARCHAR(100) = 'UNIDENTIFIED PAYOR ID 0000999995',
          @Ls_Process_NAME                     VARCHAR(100) = 'BATCH_FIN_COLLECTIONS',
          @Ls_Procedure_NAME                   VARCHAR(100) = 'SP_PROCESS_COLLECTIONS',
          @Ls_Errdesc01_TEXT                   VARCHAR(100) = 'REACHED EXCEPTION THRESHOLD',
          @Ls_Errdesc02_TEXT                   VARCHAR(100) = 'NO RECORD(S) FOR PROCESS',
          @Ld_Low_DATE                         DATE = '01/01/0001',
          @Ld_High_DATE                        DATE = '12/31/9999',
          @Ld_OldBatch_DATE                    DATE = '01/01/0001';
  DECLARE @Ln_Trans_QNTY                NUMERIC(3) = 0,
          @Ln_Detail_QNTY               NUMERIC(3) = 0,
          @Ln_OldBatch_NUMB             NUMERIC(4) = 0,
          @Ln_ReconBatch_NUMB           NUMERIC(4) = 0,
          @Ln_CommitFreqParm_QNTY       NUMERIC(5),
          @Ln_OfDaysHold_NUMB           NUMERIC(5)=0,
          @Ln_ExceptionThresholdParm_QNTY   NUMERIC(5),
          @Ln_CommitFreq_QNTY           NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY   NUMERIC(5) = 0,
          @Ln_CaseRcth_IDNO             NUMERIC(6),
          @Ln_ProcessedRecordCount_QNTY NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
          @Ln_SeqReceipt_NUMB           NUMERIC(6),
          @Ln_Payor_IDNO                NUMERIC(10) = 0,
          @Ln_CasePayor_IDNO            NUMERIC(10),
          @Ln_QNTY                      NUMERIC(10) = 0,
          @Ln_CursorRecordCount_QNTY    NUMERIC(10) = 0,
          @Ln_SduProcessRecord_QNTY     NUMERIC(10) = 0,
          @Ln_Held_AMNT                 NUMERIC(11,2) = 0,
          @Ln_Identified_AMNT           NUMERIC(11,2) = 0,
          @Ln_DetailTotal_AMNT          NUMERIC(11,2) = 0,
          @Ln_Error_NUMB                NUMERIC(11),
          @Ln_ErrorLine_NUMB            NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB       NUMERIC(19),
          @Ln_ReconEventGlobalSeq_NUMB  NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY          SMALLINT,
          @Li_Rowcount_QNTY             SMALLINT,
          @Lc_TypePosting_CODE          CHAR(1),
          @Lc_CaseMemberStatus_CODE     CHAR(1),
          @Lc_ReconSoureBatch_CODE      CHAR(3) = '',
          @Lc_HoldReason_CODE           CHAR(4),
          @Lc_ReasonStatus_CODE         CHAR(4),
          @Lc_Msg_CODE                  CHAR(5),
          @Lc_BateError_CODE            CHAR(18),
          @Lc_ReceiptID_TEXT            CHAR(30),
          @Ls_Sql_TEXT                  VARCHAR(100),
          @Ls_CursorLocation_TEXT       VARCHAR(200),
          @Ls_Remarks_TEXT              VARCHAR(328),
          @Ls_Sqldata_TEXT              VARCHAR(4000),
          @Ls_ErrorMessage_TEXT         VARCHAR(4000),
          @Ls_DescriptionError_TEXT     VARCHAR(4000),
          @Ls_BateRecord_TEXT           VARCHAR(4000),
          @Ld_Run_DATE                  DATE,
          @Ld_Release_DATE              DATE,
          @Ld_Check_DATE                DATE,
          @Ld_LastRun_DATE              DATE,
          @Ld_Start_DATE                DATETIME2,
          @Lb_ErrorFound_BIT            BIT = 0,
          @Lb_StgtableProcessUpdate_BIT BIT = 0;

DECLARE   @Ln_CollectionCur_Seq_IDNO				 NUMERIC(19),
		  @Lc_CollectionCur_BatchDate_TEXT           CHAR(8),
          @Lc_CollectionCur_BatchNumb_TEXT           CHAR(4),
          @Lc_CollectionCur_BatchSeqNumb_TEXT        CHAR(3),
          @Lc_CollectionCur_BatchItemNumb_TEXT       CHAR(3),
          @Lc_CollectionCur_SourceBatch_CODE         CHAR(3),
          @Lc_CollectionCur_SourceReceipt_CODE       CHAR(2),
          @Lc_CollectionCur_TypeRemittance_CODE      CHAR(3),
          @Lc_CollectionCur_RapidIdno_TEXT           CHAR(7),
          @Lc_CollectionCur_RapidEnvelopeNumb_TEXT   CHAR(10),
          @Lc_CollectionCur_RapidReceiptNumb_TEXT    CHAR(10),
          @Lc_CollectionCur_PayorMCIIdno_TEXT        CHAR(10),
          @Lc_CollectionCur_MemberSsnNumb_TEXT       CHAR(9),
          @Lc_CollectionCur_ReceiptAmnt_TEXT         CHAR(15),
          @Lc_CollectionCur_FeeAmnt_TEXT             CHAR(15),
          @Lc_CollectionCur_ReceiptDate_TEXT         CHAR(8),
          @Ls_CollectionCur_PaidByName_TEXT          VARCHAR(60),
          @Lc_CollectionCur_PaidById_TEXT            CHAR(15),
          @Lc_CollectionCur_PaymentSourceSdu_CODE    CHAR(3),
          @Lc_CollectionCur_Tanf_CODE                CHAR(1),
          @Lc_CollectionCur_TaxJoint_CODE            CHAR(1),
          @Lc_CollectionCur_TaxJointName_TEXT        CHAR(35),
          @Lc_CollectionCur_ReferenceIrsIdno_TEXT	 CHAR(15),
          @Lc_CollectionCur_InjuredSpouse_INDC       CHAR(1),
          @Ls_CollectionCur_PayorName_TEXT           VARCHAR(71),
          @Lc_CollectionCur_PayorLine1Addr_TEXT      CHAR(25),
          @Lc_CollectionCur_PayorCityAddr_TEXT       CHAR(20),
          @Lc_CollectionCur_PayorStateAddr_TEXT      CHAR(2),
          @Lc_CollectionCur_PayorZipAddr_TEXT        CHAR(15),
          @Lc_CollectionCur_SuspendPayment_CODE      CHAR (1),
          @Lc_CollectionCur_CheckNo_TEXT             CHAR(19),
          @Ls_CollectionCur_PymtInstr1_TEXT          VARCHAR (76),
          @Ls_CollectionCur_PymtInstr2_TEXT          VARCHAR (76),
          @Ls_CollectionCur_PymtInstr3_TEXT          VARCHAR (76),
          @Lc_CollectionCur_Process_CODE             CHAR(1),
          @Lc_CollectionCur_SourceLoad_CODE          CHAR(3),
          @Lc_CollectionCur_BatchOrigDate_TEXT       CHAR(8),
          @Lc_CollectionCur_BatchOrigNumb_TEXT       CHAR(4),
          @Lc_CollectionCur_OrigBatchSeqNumb_TEXT    CHAR(3),
          @Lc_CollectionCur_BatchItemOrigNumb_TEXT   CHAR(3),
          @Lc_CollectionCur_SourceReceiptOrig_CODE   CHAR(2),
          @Lc_CollectionCur_TypeRemittanceOrig_CODE  CHAR(3),
          @Lc_CollectionCur_MemberSsnOrigNumb_TEXT   CHAR(9),
          @Lc_CollectionCur_Offset_TEXT              CHAR(4),
          @Ld_CollectionCur_Batch_DATE               DATE,     
          @Ln_CollectionCur_Rapid_IDNO               NUMERIC(7) = 0,
          @Ln_CollectionCur_RapidEnvelope_NUMB       NUMERIC(10) = 0,
          @Ln_CollectionCur_RapidReceipt_NUMB        NUMERIC(10) = 0,
          @Ln_CollectionCur_Batch_NUMB               NUMERIC(4) = 0,
          @Ln_CollectionCur_BatchSeq_NUMB            NUMERIC(3) = 0,
          @Ln_CollectionCur_BatchItem_NUMB           NUMERIC(3) = 0,
          @Ln_CollectionCur_PayorMCI_IDNO            NUMERIC(10) = 0,
          @Ln_CollectionCur_MemberSsn_NUMB           NUMERIC(9),
          @Ln_CollectionCur_Receipt_AMNT             NUMERIC(11, 2),
          @Ln_CollectionCur_Fee_AMNT                 NUMERIC(11, 2),
          @Ld_CollectionCur_Receipt_DATE             DATE,               
          @Ln_CollectionCur_ReferenceIrs_IDNO		 NUMERIC (15) = 0;
          
  -- Collections Cursor
  DECLARE Collection_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
		  a.Batch_DATE,
          a.Batch_NUMB,
          a.BatchSeq_NUMB,
          a.BatchItem_NUMB,
          'SDU' SourceBatch_CODE,
          a.SourceReceipt_CODE,
          a.TypeRemittance_CODE,
          a.Rapid_IDNO,
          a.RapidEnvelope_NUMB,
          a.RapidReceipt_NUMB,
          LTRIM (RTRIM(a.PayorMCI_IDNO)) AS PayorMCI_IDNO,
          a.PayorSsn_NUMB AS MemberSsn_NUMB,
          a.Receipt_AMNT,
          a.ReceiptFee_AMNT,
          a.Receipt_DATE,
          a.PaidBy_NAME,
          a.PaidBy_ID,
          a.PaymentSourceSdu_CODE,
          ' ' AS Tanf_CODE,
          ' ' AS TaxJoint_CODE,
          ' ' AS TaxJoint_NAME,
          '' AS CaseIrs_IDNO,
          ' ' AS InjuredSpouse_INDC,
          (RTRIM(a.PayorLast_Name) + ' ' + RTRIM(a.PayorSuffix_NAME) + ' ' + RTRIM(a.PayorFirst_NAME) + ' ' + RTRIM(PayorMiddle_NAME)) AS Payor_NAME,
          ' ' AS PayorLine1_ADDR,
          ' ' AS PayorCity_ADDR,
          ' ' AS PayorState_ADDR,
          ' ' AS PayorZip_ADDR,
          a.SuspendPayment_CODE AS SuspendPayment_CODE,
          a.CheckNo_TEXT,
          a.PaymentInstruction1_TEXT,
          a.PaymentInstruction2_TEXT,
          a.PaymentInstruction3_TEXT,
          a.Process_INDC,
          'SDU' AS SourceLoad_CODE,
          a.Batch_DATE AS BatchOrig_DATE,
          a.Batch_NUMB AS BatchOrig_NUMB,
          a.BatchSeq_NUMB AS BatchSeqOrig_NUMB,
          a.BatchItem_NUMB AS BatchItemOrig_NUMB,
          a.SourceReceipt_CODE AS SourceReceiptOrig_CODE,
          a.TypeRemittance_CODE AS TypeRemittanceOrig_CODE,
          a.PayorSsn_NUMB AS MemberSsnOrig_NUMB,
          ' ' AS OffsetYear_NUMB
     FROM LCSDU_Y1 a
    WHERE a.Process_INDC = 'N'
   UNION ALL
   SELECT a.Seq_IDNO,
		  a.Batch_DATE,
          a.Batch_NUMB,
          a.BatchSeq_NUMB,
          a.BatchItem_NUMB,
          'SPC' AS SourceBatch_CODE,
          a.SourceReceipt_CODE,
          a.TypeRemittance_CODE,
          ' ' AS Rapid_IDNO,
          ' ' AS RapidEnvelope_NUMB,
          ' ' AS RapidReceipt_NUMB,
          ' ' AS PayorMCI_IDNO,
          LTRIM(RTRIM(a.MemberSsn_NUMB)),
          a.Receipt_AMNT,
          '0' AS Fee_AMNT,
          a.Receipt_DATE,
          ' ' AS PaidBy_NAME,
          ' ' AS PaidBy_ID,
          ' ' AS PaymentSourceSdu_CODE,
          a.Tanf_CODE,
          CASE a.TaxJoint_CODE
           WHEN 'Y'
            THEN 'J'
           WHEN 'N'
            THEN 'I'
           ELSE ' '
          END AS TaxJoint_CODE,
          a.Payment_NAME,
          LTRIM(RTRIM(a.ReferenceIrs_IDNO)) AS ReferenceIrs_IDNO,
          a.InjuredSpouse_INDC,
          ' ' AS Payor_NAME,
          ' ' AS PayorLine1_ADDR,
          ' ' AS PayorCity_ADDR,
          ' ' AS PayorState_ADDR,
          ' ' AS PayorZip_ADDR,
          '0' SuspendPayment_CODE,
          a.CheckNo_TEXT,
          ' ' AS PaymentInstruction1_TEXT,
          ' ' AS PaymentInstruction2_TEXT,
          ' ' AS PaymentInstruction3_TEXT,
          a.Process_CODE,
          'SPC' AS SourceLoad_CODE,
          a.Batch_DATE AS BatchOrig_DATE,
          a.Batch_NUMB AS BatchOrig_NUMB,
          a.BatchSeq_NUMB AS BatchSeqOrig_NUMB,
          a.BatchItem_NUMB AS BatchItemOrig_NUMB,
          a.SourceReceipt_CODE AS SourceReceiptOrig_CODE,
          a.TypeRemittance_CODE AS TypeRemittanceOrig_CODE,
          a.MemberSsn_NUMB AS MemberSsnOrig_NUMB,
          a.OffsetYear_NUMB AS OffsetYear_NUMB
     FROM LCIRS_Y1 a
    WHERE a.Process_CODE = 'N'
    ORDER BY Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_JobProcess_ID;
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobProcess_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION ColTran; -- 1

   SET @Ls_Sql_TEXT = 'OPEN Collection_CUR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN Collection_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Collection_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Collection_CUR INTO @Ln_CollectionCur_Seq_IDNO, @Lc_CollectionCur_BatchDate_TEXT, @Lc_CollectionCur_BatchNumb_TEXT, @Lc_CollectionCur_BatchSeqNumb_TEXT, @Lc_CollectionCur_BatchItemNumb_TEXT, @Lc_CollectionCur_SourceBatch_CODE, @Lc_CollectionCur_SourceReceipt_CODE, @Lc_CollectionCur_TypeRemittance_CODE, @Lc_CollectionCur_RapidIdno_TEXT, @Lc_CollectionCur_RapidEnvelopeNumb_TEXT, @Lc_CollectionCur_RapidReceiptNumb_TEXT, @Lc_CollectionCur_PayorMCIIdno_TEXT, @Lc_CollectionCur_MemberSsnNumb_TEXT, @Lc_CollectionCur_ReceiptAmnt_TEXT, @Lc_CollectionCur_FeeAmnt_TEXT, @Lc_CollectionCur_ReceiptDate_TEXT, @Ls_CollectionCur_PaidByName_TEXT, @Lc_CollectionCur_PaidById_TEXT, @Lc_CollectionCur_PaymentSourceSdu_CODE, @Lc_CollectionCur_Tanf_CODE, @Lc_CollectionCur_TaxJoint_CODE, @Lc_CollectionCur_TaxJointName_TEXT, @Lc_CollectionCur_ReferenceIrsIdno_TEXT, @Lc_CollectionCur_InjuredSpouse_INDC, @Ls_CollectionCur_PayorName_TEXT, @Lc_CollectionCur_PayorLine1Addr_TEXT, @Lc_CollectionCur_PayorCityAddr_TEXT, @Lc_CollectionCur_PayorStateAddr_TEXT, @Lc_CollectionCur_PayorZipAddr_TEXT, @Lc_CollectionCur_SuspendPayment_CODE, @Lc_CollectionCur_CheckNo_Text, @Ls_CollectionCur_PymtInstr1_TEXT, @Ls_CollectionCur_PymtInstr2_TEXT, @Ls_CollectionCur_PymtInstr3_TEXT, @Lc_CollectionCur_Process_CODE, @Lc_CollectionCur_SourceLoad_CODE, @Lc_CollectionCur_BatchOrigDate_TEXT, @Lc_CollectionCur_BatchOrigNumb_TEXT, @Lc_CollectionCur_OrigBatchSeqNumb_TEXT, @Lc_CollectionCur_BatchItemOrigNumb_TEXT, @Lc_CollectionCur_SourceReceiptOrig_CODE, @Lc_CollectionCur_TypeRemittanceOrig_CODE, @Lc_CollectionCur_MemberSsnOrigNumb_TEXT, @Lc_CollectionCur_Offset_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
  -- Collection LOOP BEGIN
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN 
    BEGIN TRY
     SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ln_Held_AMNT = 0;
     SET @Ln_Identified_AMNT = 0;
     SET @Lb_ErrorFound_BIT = 0;
     SET @Lb_StgtableProcessUpdate_BIT = 1;
     SET @Ls_Remarks_TEXT = @Lc_NoSpace_TEXT;
     SET @Ls_ErrorMessage_TEXT = @Lc_NoSpace_TEXT;
     SET @Ln_OfDaysHold_NUMB = 0
	 -- UNKNOWN EXCEPTION IN BATCH
	 SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
	 
	 SET @Ls_CursorLocation_TEXT = 'COLLECTION - CURSOR COUNT - ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '');

	 SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL (CAST(@Ln_CollectionCur_Seq_IDNO AS VARCHAR), '') +  ', Batch_DATE = ' + ISNULL (@Lc_CollectionCur_BatchDate_TEXT, '') + ', Batch_NUMB = ' + ISNULL (@Lc_CollectionCur_BatchNumb_TEXT, '') + ', BatchSeq_NUMB  = ' + ISNULL (@Lc_CollectionCur_BatchSeqNumb_TEXT, '') + ', BatchItem_NUMB = ' + ISNULL (@Lc_CollectionCur_BatchItemNumb_TEXT, '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_CollectionCur_SourceBatch_CODE, '') + ', SourceReceipt_CODE = ' + ISNULL (@Lc_CollectionCur_SourceReceipt_CODE, '') + ', TypeRemittance_CODE = ' + ISNULL (@Lc_CollectionCur_TypeRemittance_CODE, '') + ', Rapid_IDNO = ' + ISNULL (@Lc_CollectionCur_RapidIdno_TEXT, '') + ', RapidEnvelope_NUMB = ' + ISNULL (@Lc_CollectionCur_RapidEnvelopeNumb_TEXT, '') + ', RapidReceipt_NUMB = ' + ISNULL (@Lc_CollectionCur_RapidReceiptNumb_TEXT, '') + ', PayorMCI_IDNO = ' + ISNULL (@Lc_CollectionCur_PayorMCIIdno_TEXT, '') + ', MemberSsn_NUMB  = ' + ISNULL (@Lc_CollectionCur_MemberSsnNumb_TEXT, '') + ', Receipt_AMNT = ' + ISNULL (@Lc_CollectionCur_ReceiptAmnt_TEXT, '') + ', Fee_AMNT  = ' + ISNULL (@Lc_CollectionCur_FeeAmnt_TEXT, '') + ', Receipt_DATE = ' + ISNULL (@Lc_CollectionCur_ReceiptDate_TEXT, '') + ', PaidBy_NAME = ' + ISNULL (RTRIM(@Ls_CollectionCur_PaidByName_TEXT), '') + ', PaidBy_ID = ' + ISNULL (RTRIM(@Lc_CollectionCur_PaidById_TEXT), '') + ', PaymentSourceSdu_CODE= ' + ISNULL (@Lc_CollectionCur_PaymentSourceSdu_CODE, '') + ', Tanf_CODE = ' + ISNULL (@Lc_CollectionCur_Tanf_CODE, '') + ', TaxJoint_CODE = ' + ISNULL (@Lc_CollectionCur_TaxJoint_CODE, '') + ', TaxJoint_NAME = ' + ISNULL (RTRIM(@Lc_CollectionCur_TaxJointName_TEXT), '') + ', ReferenceIrs_IDNO = ' + ISNULL (RTRIM(@Lc_CollectionCur_ReferenceIrsIdno_TEXT), '') + ', InjuredSpouse_INDC = ' + ISNULL (@Lc_CollectionCur_InjuredSpouse_INDC, '') + ', Payor_NAME = ' + ISNULL (RTRIM(@Ls_CollectionCur_PayorName_TEXT), '') + ', PayorLine1_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorLine1Addr_TEXT), '') + ', PayorCity_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorCityAddr_TEXT), '') + ', PayorState_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorStateAddr_TEXT), '') + ', PayorZip_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorZipAddr_TEXT), '') + ', SuspendPayment_CODE = ' + ISNULL (@Lc_CollectionCur_SuspendPayment_CODE, '')  + ', Check_NUMB = ' + ISNULL (@Lc_CollectionCur_CheckNo_TEXT, '') + ', PymtInstr1_TEXT = ' + ISNULL (RTRIM(@Ls_CollectionCur_PymtInstr1_TEXT), '') + ', PymtInstr2_TEXT = ' + ISNULL (RTRIM(@Ls_CollectionCur_PymtInstr2_TEXT), '') + ', PymtInstr3_TEXT = ' + ISNULL (RTRIM(@Ls_CollectionCur_PymtInstr3_TEXT), '') + ', Process_CODE = ' + ISNULL (@Lc_CollectionCur_Process_CODE, '') + ', SourceLoad_CODE = ' + ISNULL (@Lc_CollectionCur_SourceLoad_CODE, '');
	 SAVE TRANSACTION SaveColTran
	 
	 SET @Ls_Sql_TEXT = 'RapidIdno_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'RapidIdno_TEXT = ' + @Lc_CollectionCur_RapidIdno_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_RapidIdno_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_RapidIdno_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_Rapid_IDNO = CAST(@Lc_CollectionCur_RapidIdno_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	       
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_Rapid_IDNO = 0;
      END       

	 SET @Ls_Sql_TEXT = 'RapidEnvelopeNumb_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'RapidEnvelopeNumb_TEXT = ' + @Lc_CollectionCur_RapidEnvelopeNumb_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_RapidEnvelopeNumb_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_RapidEnvelopeNumb_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_RapidEnvelope_NUMB = CAST(@Lc_CollectionCur_RapidEnvelopeNumb_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	          
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_RapidEnvelope_NUMB = 0;
      END        

	 SET @Ls_Sql_TEXT = 'RapidReceiptNumb_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'RapidReceiptNumb_TEXT = ' + @Lc_CollectionCur_RapidReceiptNumb_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_RapidReceiptNumb_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_RapidReceiptNumb_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_RapidReceipt_NUMB = CAST(@Lc_CollectionCur_RapidReceiptNumb_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	         
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_RapidReceipt_NUMB = 0;
      END        

	 SET @Ls_Sql_TEXT = 'BatchNumb_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'BatchNumb_TEXT = ' + @Lc_CollectionCur_BatchNumb_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_BatchNumb_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_BatchNumb_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_Batch_NUMB = CAST(@Lc_CollectionCur_BatchNumb_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END       
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_Batch_NUMB = 0;
      END  
      
	 SET @Ls_Sql_TEXT = 'BatchSeqNumb_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'BatchSeqNumb_TEXT = ' + @Lc_CollectionCur_BatchSeqNumb_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_BatchSeqNumb_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_BatchSeqNumb_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_BatchSeq_NUMB = CAST(@Lc_CollectionCur_BatchSeqNumb_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	         
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_BatchSeq_NUMB = 0;
      END        

	 SET @Ls_Sql_TEXT = 'BatchItemNumb_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'BatchItemNumb_TEXT = ' + @Lc_CollectionCur_BatchItemNumb_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_BatchItemNumb_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_BatchItemNumb_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_BatchItem_NUMB = CAST(@Lc_CollectionCur_BatchItemNumb_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	         
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_BatchItem_NUMB = 0;
      END        

	 SET @Ls_Sql_TEXT = 'SeqReceipt_NUMB  - Conversion';
	 SET @Ls_Sqldata_TEXT = 'BatchSeqNumb_TEXT = ' + @Lc_CollectionCur_BatchSeqNumb_TEXT + ', BatchItemNumb_TEXT = ' + @Lc_CollectionCur_BatchItemNumb_TEXT;
	 SET @Ln_SeqReceipt_NUMB = CAST(ISNULL(ISNULL (CAST(LTRIM(RTRIM(@Lc_CollectionCur_BatchSeqNumb_TEXT)) AS VARCHAR), '0') + ISNULL (CAST(LTRIM(RTRIM(@Lc_CollectionCur_BatchItemNumb_TEXT)) AS VARCHAR), '0'), 0) AS NUMERIC);

	 SET @Ls_Sql_TEXT = 'PayorMCIIdno_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'PayorMCIIdno_TEXT = ' + @Lc_CollectionCur_PayorMCIIdno_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_PayorMCIIdno_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_PayorMCIIdno_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_PayorMCI_IDNO = CAST(@Lc_CollectionCur_PayorMCIIdno_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	         
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_PayorMCI_IDNO = 0;
      END  
      
	 SET @Ls_Sql_TEXT = 'MemberSsnNumb_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'SourceBatch_CODE = ' + @Lc_CollectionCur_SourceBatch_CODE + ', MemberSsnNumb_TEXT = ' + @Lc_CollectionCur_MemberSsnNumb_TEXT;
     IF @Lc_CollectionCur_SourceBatch_CODE = 'SDU' 
     BEGIN 
		 IF LTRIM(RTRIM(@Lc_CollectionCur_MemberSsnNumb_TEXT)) = '' OR ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_MemberSsnNumb_TEXT))) = 0
		 BEGIN 
			SET @Ln_CollectionCur_MemberSsn_NUMB = 0;
		 END
		 ELSE
		 BEGIN 
			SET @Ln_CollectionCur_MemberSsn_NUMB = CAST(@Lc_CollectionCur_MemberSsnNumb_TEXT AS NUMERIC);
		 END
	 END
	 ELSE
	 BEGIN     
		 IF LTRIM(RTRIM(@Lc_CollectionCur_MemberSsnNumb_TEXT)) <> ''
		  BEGIN
		   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_MemberSsnNumb_TEXT))) = 1
			BEGIN 
			 SET @Ln_CollectionCur_MemberSsn_NUMB = CAST(@Lc_CollectionCur_MemberSsnNumb_TEXT AS NUMERIC);
			END
		   ELSE
			BEGIN
			 -- INVALID VALUE
			 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
			 RAISERROR (50001, 16, 1);
			END	         
		  END
		  ELSE
		  BEGIN
		   SET @Ln_CollectionCur_MemberSsn_NUMB = 0;
		  END
      END        

	 SET @Ls_Sql_TEXT = 'ReferenceIrsIdno_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'ReferenceIrsIdno_TEXT = ' + @Lc_CollectionCur_ReferenceIrsIdno_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_ReferenceIrsIdno_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_ReferenceIrsIdno_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_ReferenceIrs_IDNO = CAST(@Lc_CollectionCur_ReferenceIrsIdno_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	         
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_ReferenceIrs_IDNO = 0;
      END 

	 SET @Ls_Sql_TEXT = 'BatchDate_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'BatchDate_TEXT = ' + @Lc_CollectionCur_BatchDate_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_BatchDate_TEXT)) <> '' 
      BEGIN
	   IF ISDATE(LTRIM(RTRIM(@Lc_CollectionCur_BatchDate_TEXT))) = 1
	    BEGIN 
		 SET @Ld_CollectionCur_Batch_DATE = CONVERT (DATE, @Lc_CollectionCur_BatchDate_TEXT, 112);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END
      END

	 SET @Ls_Sql_TEXT = 'ReceiptAmnt_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'SourceBatch_CODE = ' + @Lc_CollectionCur_SourceBatch_CODE + ', ReceiptAmnt_TEXT = ' + @Lc_CollectionCur_ReceiptAmnt_TEXT;
	 
     IF LTRIM(RTRIM(@Lc_CollectionCur_ReceiptAmnt_TEXT)) <> '' 
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_ReceiptAmnt_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_Receipt_AMNT = CAST(@Lc_CollectionCur_ReceiptAmnt_TEXT AS NUMERIC (11, 2));
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	       
      END
      ELSE
      BEGIN
       SET @Ln_CollectionCur_Receipt_AMNT = 0;
      END        
      
	 SET @Ls_Sql_TEXT = 'FeeAmnt_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'FeeAmnt_TEXT = ' + @Lc_CollectionCur_FeeAmnt_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_FeeAmnt_TEXT)) <> '' 
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_CollectionCur_FeeAmnt_TEXT))) = 1
	    BEGIN 
		 SET @Ln_CollectionCur_Fee_AMNT = CAST(@Lc_CollectionCur_FeeAmnt_TEXT AS NUMERIC (11, 2)); 
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END	       
      END
      
	 SET @Ls_Sql_TEXT = 'ReceiptDate_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'ReceiptDate_TEXT = ' + @Lc_CollectionCur_ReceiptDate_TEXT;
     IF LTRIM(RTRIM(@Lc_CollectionCur_ReceiptDate_TEXT)) <> '' 
      BEGIN
	   IF ISDATE(LTRIM(RTRIM(@Lc_CollectionCur_ReceiptDate_TEXT))) = 1
	    BEGIN 
		 SET @Ld_CollectionCur_Receipt_DATE = CONVERT (DATE, @Lc_CollectionCur_ReceiptDate_TEXT, 112);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		 RAISERROR (50001, 16, 1);
	    END       
      END
	 	       
     SET @Ls_Sql_TEXT = 'SPC - Joint-Tax Indicator validation';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CONVERT(VARCHAR, @Ld_CollectionCur_Batch_DATE, 112), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_CollectionCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_CollectionCur_Batch_NUMB AS VARCHAR), '') + ', BatchSeq_NUMB = ' + ISNULL (CAST(@Ln_CollectionCur_BatchSeq_NUMB AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL (@Lc_CollectionCur_SourceReceipt_CODE, '');
	
	 -- If receipt source is 'SPC' but Joint-Tax Indicator is spaces then write error message E0085 â€“ Invalid Value'
     IF @Lb_ErrorFound_BIT = 0
        AND @Lc_CollectionCur_SourceLoad_CODE = @Lc_SourceBatchSpc_CODE
        AND @Lc_CollectionCur_TaxJoint_CODE = @Lc_Space_TEXT
      BEGIN
       SET @Lb_ErrorFound_BIT = 1;
       -- INVALID VALUE
       SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
       RAISERROR (50001,16,1);
      END
	      
	 -- If receipt source not found in HIMS_Y1 table then write error message â€˜E1062 â€“ Receipt source not found in HIMS_Y1 tableâ€™ 
     IF @Lb_ErrorFound_BIT = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT HIMS_Y1';
       SET @Ls_Sqldata_TEXT = 'SourceReceipt_CODE = ' + ISNULL(@Lc_CollectionCur_SourceReceipt_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT @Lc_TypePosting_CODE = h.TypePosting_CODE
         FROM HIMS_Y1 h
        WHERE h.SourceReceipt_CODE = @Lc_CollectionCur_SourceReceipt_CODE
          AND h.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Lb_ErrorFound_BIT = 1;
         -- Receipt source not found in HIMS_Y1 table
         SET @Lc_BateError_CODE = @Lc_ErrorE1062_CODE;
         RAISERROR (50001,16,1);
        END

       -- @Lc_TypePosting_CODE value is set as 'P' because in DECSS all the postings are PAYOR level posting.
       SET @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE;
      END
      
	 -- 1 -- Start --  
     IF @Lb_ErrorFound_BIT = 0 
      BEGIN
       IF (@Ln_OldBatch_NUMB != @Ln_CollectionCur_Batch_NUMB
            OR @Ld_OldBatch_DATE != @Ld_CollectionCur_Batch_DATE
            OR @Lc_OldSourceBatch_CODE != @Lc_CollectionCur_SourceBatch_CODE)
        BEGIN
         IF @Lc_ReconSoureBatch_CODE <> @Lc_NoSpace_TEXT
            AND @Ln_ReconBatch_NUMB <> 0
            AND @Ln_ReconEventGlobalSeq_NUMB <> 0
          BEGIN
           SET @Ls_Sql_TEXT = 'UPDATE RBAT_Y1 - INSIDE LOOP';
           SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Ld_OldBatch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_ReconSoureBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_ReconBatch_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST(@Ln_ReconEventGlobalSeq_NUMB AS VARCHAR), '') + ', Ln_Detail_QNTY = ' + ISNULL (CAST(@Ln_Detail_QNTY AS VARCHAR), '') + ', Ln_DetailTotal_AMNT = ' + ISNULL (CAST(@Ln_DetailTotal_AMNT AS VARCHAR), '') + ', Ln_Trans_QNTY = ' + ISNULL (CAST(@Ln_Trans_QNTY AS VARCHAR), '');

           UPDATE RBAT_Y1
              SET CtControlReceipt_QNTY = @Ln_Detail_QNTY,
                  CtActualReceipt_QNTY = @Ln_Detail_QNTY,
                  ControlReceipt_AMNT = @Ln_DetailTotal_AMNT,
                  ActualReceipt_AMNT = @Ln_DetailTotal_AMNT,
                  CtControlTrans_QNTY = @Ln_Trans_QNTY,
                  CtActualTrans_QNTY = @Ln_Trans_QNTY,
                  StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
            WHERE Batch_DATE = @Ld_OldBatch_DATE
              AND SourceBatch_CODE = @Lc_ReconSoureBatch_CODE
              AND Batch_NUMB = @Ln_ReconBatch_NUMB
              AND EventGlobalBeginSeq_NUMB = @Ln_ReconEventGlobalSeq_NUMB;

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
             -- 'Update not successful'
             SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

             RAISERROR (50001,16,1);
            END
          END

         SET @Ln_OldBatch_NUMB = @Ln_CollectionCur_Batch_NUMB;
         SET @Ld_OldBatch_DATE = @Ld_CollectionCur_Batch_DATE;
         SET @Lc_OldSourceBatch_CODE = @Lc_CollectionCur_SourceBatch_CODE;
         SET @Lc_OldSeqNo_NUMB = @Lc_SeqNumb000_TEXT;
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ-1110';
         SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Li_AddingAReceiptBatch1110_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Lc_JobProcess_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT, '');
         -- Adding A Receipt Batch
         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_AddingAReceiptBatch1110_NUMB,
          @Ac_Process_ID              = @Lc_JobProcess_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'INSERT RBAT_Y1 1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Ld_CollectionCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_CollectionCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_CollectionCur_Batch_NUMB AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL (@Lc_CollectionCur_SourceReceipt_CODE, '') + ', CtControlReceipt_QNTY = ' + '0' + ', CtActualReceipt_QNTY = ' + '0' + ', ControlReceipt_AMNT = ' + '0' + ', ActualReceipt_AMNT = ' + '0' + ', TypeRemittance_CODE = ' + ISNULL (@Lc_CollectionCur_TypeRemittance_CODE, '') + ', Receipt_DATE = ' + ISNULL (CAST(@Ld_CollectionCur_Batch_DATE AS VARCHAR), '') + ', StatusBatch_CODE = ' + ISNULL (@Lc_StatusBatchUnreconciled_CODE, '') + ', RePost_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + '0' + ', BeginValidity_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL (CAST(@Ld_High_DATE AS VARCHAR), '') + ', CtControlTrans_QNTY = ' + '0' + ', CtActualTrans_QNTY = ' + '0';

         INSERT RBAT_Y1
                (Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SourceReceipt_CODE,
                 CtControlReceipt_QNTY,
                 CtActualReceipt_QNTY,
                 ControlReceipt_AMNT,
                 ActualReceipt_AMNT,
                 TypeRemittance_CODE,
                 Receipt_DATE,
                 StatusBatch_CODE,
                 RePost_INDC,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 CtControlTrans_QNTY,
                 CtActualTrans_QNTY)
         VALUES (@Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                 @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                 @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                 @Lc_CollectionCur_SourceReceipt_CODE,-- SourceReceipt_CODE
                 0,-- CtControlReceipt_QNTY
                 0,-- CtActualReceipt_QNTY
                 0,-- ControlReceipt_AMNT
                 0,-- ActualReceipt_AMNT
                 @Lc_CollectionCur_TypeRemittance_CODE,-- TypeRemittance_CODE
                 @Ld_CollectionCur_Batch_DATE,-- Receipt_DATE
                 @Lc_StatusBatchUnreconciled_CODE,-- StatusBatch_CODE
                 @Lc_No_INDC,-- RePost_INDC
                 @Ln_EventGlobalSeq_NUMB,-- EventGlobalBeginSeq_NUMB
                 0,-- EventGlobalEndSeq_NUMB
                 @Ld_Run_DATE,-- BeginValidity_DATE
                 @Ld_High_DATE,-- EndValidity_DATE
                 0,-- CtControlTrans_QNTY
                 0 -- CtActualTrans_QNTY
         );

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END

         -- Tracking existing key of RBAT to Reconcile it later.
         SET @Lc_ReconSoureBatch_CODE = @Lc_CollectionCur_SourceBatch_CODE;
         SET @Ln_ReconBatch_NUMB = @Ln_CollectionCur_Batch_NUMB;
         SET @Ln_ReconEventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB;
         -- Initializing Total COUNT and Total Value_AMNT of receipts in a batch
         SET @Ln_Detail_QNTY = 0;
         SET @Ln_DetailTotal_AMNT = 0;
         SET @Ln_Trans_QNTY = 0;
        END

       SET @Ln_Detail_QNTY = @Ln_Detail_QNTY + 1;
       SET @Ln_DetailTotal_AMNT = @Ln_DetailTotal_AMNT + @Ln_CollectionCur_Receipt_AMNT;

       IF @Ld_OldBatch_DATE = @Ld_CollectionCur_Batch_DATE
          AND @Ln_OldBatch_NUMB = @Ln_CollectionCur_Batch_NUMB
          AND @Lc_OldSourceBatch_CODE = @Lc_CollectionCur_SourceBatch_CODE
          AND @Lc_OldSeqNo_NUMB != @Lc_CollectionCur_BatchSeqNumb_TEXT
        BEGIN
         SET @Ln_Trans_QNTY = @Ln_Trans_QNTY + 1;
         SET @Lc_OldSeqNo_NUMB = @Lc_CollectionCur_BatchSeqNumb_TEXT;
        END

       SET @Lc_StatusReceipt_CODE = @Lc_Space_TEXT;
       SET @Lc_HoldReason_CODE = '';
       SET @Lc_ReasonStatus_CODE = '';
       SET @Lc_CaseMemberStatus_CODE = '';
       SET @Ln_Payor_IDNO = @Ln_CollectionCur_PayorMCI_IDNO;
       SET @Ls_Sql_TEXT = 'Check_DATE Format_CODE';
       SET @Ls_Sqldata_TEXT = 'Check_DATE = ' + ISNULL (@Lc_DateAdjust0101_TEXT, '') + ', OffsetYear_NUMB = ' + ISNULL (@Lc_CollectionCur_Offset_TEXT, '');

       IF (@Lc_CollectionCur_SourceLoad_CODE = @Lc_SourceBatchSpc_CODE)
        BEGIN
         SET @Ld_Check_DATE = CAST(@Lc_DateAdjust0101_TEXT + @Lc_CollectionCur_Offset_TEXT AS DATE);
        END
       ELSE
        BEGIN
         SET @Ld_Check_DATE = @Ld_Low_DATE;
        END

       -- Collection process uses payor ID from the input file for the SDU receipts and Zero is moved to Case ID in RCTH_Y1. 
       SET @Ln_CaseRcth_IDNO = 0;
        
       -- SDU Payments Validation - Start -
       IF (@Lc_CollectionCur_SourceLoad_CODE = @Lc_SourceBatchSdu_CODE)
        BEGIN
         -- If Payor ID is not received from the SDU, the receipt will be marked as unidentified with a UDC code of â€˜UNIDâ€™ â€“ Unidentifiedâ€™ by SDU
         IF (@Ln_CollectionCur_PayorMCI_IDNO = 0)
          BEGIN
           SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
          END
         ELSE
          BEGIN
           -- If Payor ID received in the input file is '999995', then the receipt will be marked as unidentified with a UDC code of UNID -  Unidentified by SDU.
           IF @Ln_CollectionCur_PayorMCI_IDNO = CAST(@Ln_Payor999995_IDNO AS NUMERIC)
            BEGIN
             SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
             -- 'UNIDENTIFIED PAYOR ID 0000999995'
             SET @Ls_Remarks_TEXT = @Ls_Remarksdesc06_TEXT;
            END
           ELSE
            BEGIN
             /*
             -- CP recoupment receipt is received but the member DCN that was received as not a CP on the case.
             -- System should ahve marked it unidentified not placed it on hold.
             
			 -- For 'CR â€“ CP Recoupment' and 'CF â€“ CP Fee Payment' receipt sources, the batch process puts the receipt on hold if the member is not a
				Custodial Parent (CP) on at least one open case in the system.
			 -- For all Receipt Sources except 'CR â€“ CP Recoupment' and 'CF â€“ CP Fee Payment', the batch process puts the receipt on hold if the member is not a 
			    Non-Custodial Parent (NCP) on at least one open case in the system.
             */
             BEGIN
              SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 1 ';
              SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'');

              SELECT TOP 1 @Lc_CaseMemberStatus_CODE = CaseMemberStatus_CODE
                FROM CMEM_Y1 a
               WHERE a.MemberMci_IDNO = @Ln_CollectionCur_PayorMCI_IDNO
                 AND ((a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                       AND @Lc_CollectionCur_SourceReceipt_CODE NOT IN(@Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeePaymentCF_CODE))
                       OR (a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                           AND @Lc_CollectionCur_SourceReceipt_CODE IN(@Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeePaymentCF_CODE)))
                 AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

              SET @Li_Rowcount_QNTY = @@ROWCOUNT;

              IF @Li_Rowcount_QNTY > 0
               BEGIN
                SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
               END
              ELSE
               BEGIN
                SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 2 ';
                SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE,'');

                SELECT TOP 1 @Lc_CaseMemberStatus_CODE = CaseMemberStatus_CODE
                  FROM CMEM_Y1 a
                 WHERE a.MemberMci_IDNO = @Ln_CollectionCur_PayorMCI_IDNO
                   AND ((a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                         AND @Lc_CollectionCur_SourceReceipt_CODE NOT IN(@Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeePaymentCF_CODE))
                         OR (a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                             AND @Lc_CollectionCur_SourceReceipt_CODE IN(@Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeePaymentCF_CODE)));

                SET @Li_Rowcount_QNTY = @@ROWCOUNT;
				-- SNNA - NCP  NOT ACTIVE
                IF @Li_Rowcount_QNTY > 0
                 BEGIN
				 -- Defect 13036 - "Check whether the Payor's Case is Closed if so put in SNCL Hold for NON-IRS Receipt" - Fix - Start -- 			
					IF NOT EXISTS (SELECT 1
								FROM CMEM_Y1 a,
									 CASE_Y1 b
							   WHERE  a.MemberMci_IDNO = @Ln_CollectionCur_PayorMCI_IDNO
							   AND ((a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
									 AND @Lc_CollectionCur_SourceReceipt_CODE NOT IN(@Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeePaymentCF_CODE))
									 OR (a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
										 AND @Lc_CollectionCur_SourceReceipt_CODE IN(@Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeePaymentCF_CODE)))
								 AND a.Case_IDNO = b.Case_IDNO
								 AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
					BEGIN 
						 SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
						 SET @Lc_HoldReason_CODE = @Lc_HoldReasonStatusSncc_CODE;
						 SET @Ln_Held_AMNT = @Ln_CollectionCur_Receipt_AMNT;
						 SET @Ln_Identified_AMNT = 0;

						  SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNCC-1';
						  SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldReasonStatusSnna_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
						  
						  SELECT @Ln_OfDaysHold_NUMB = a.NumDaysHold_QNTY 
							   FROM UCAT_Y1 a
							  WHERE a.Udc_CODE = @Lc_HoldReasonStatusSncc_CODE
								AND a.EndValidity_DATE = @Ld_High_DATE;
		                  
						  SET @Ld_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB , @Ld_Run_DATE);				
					END 
				 -- Defect 13036 - "Check whether the Payor's Case is Closed if so put in SNCL Hold for NON-IRS Receipt" - Fix - End --
				  ELSE
				  BEGIN	
					  SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
					  SET @Lc_HoldReason_CODE = @Lc_HoldReasonStatusSnna_CODE;
					  SET @Ln_Held_AMNT = @Ln_CollectionCur_Receipt_AMNT;
					  SET @Ln_Identified_AMNT = 0;
	                  
					  SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNNA-1';
					  SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldReasonStatusSnna_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
					  
					  SELECT @Ln_OfDaysHold_NUMB = a.NumDaysHold_QNTY 
						   FROM UCAT_Y1 a
						  WHERE a.Udc_CODE = @Lc_HoldReasonStatusSnna_CODE
							AND a.EndValidity_DATE = @Ld_High_DATE;
	                  
					  SET @Ld_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB , @Ld_Run_DATE);
                  END
                 END
                ELSE
                 BEGIN
                  SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
                  -- UNEX - UNIDENTIFIED EXCEPTION - SDU
                  SET @Lc_ReasonStatus_CODE = @Lc_UnidenholdExceptionsdu_CODE;
                  -- NO VALID RECORD FOUND FOR MEMBER
                  SET @Ls_Remarks_TEXT = @Ls_Remarksdesc04_TEXT;
                 END
               END
             END
            END
          END
        END
       -- SDU Payments Validation - End- 
       ELSE
       -- IRS Payments Validation - Start - 
        BEGIN

         IF @Ln_CollectionCur_MemberSsn_NUMB <> 0
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT MSSN_Y1 1';
           SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_MemberSsn_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE,'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_ReferenceIrs_IDNO AS VARCHAR ),'');

           SELECT DISTINCT @Ln_Payor_IDNO = a.MemberMci_IDNO
             FROM MSSN_Y1 a
            WHERE a.MemberSsn_NUMB = @Ln_CollectionCur_MemberSsn_NUMB
              AND a.TypePrimary_CODE IN (@Lc_TypePrimarySsn_CODE, @Lc_TypeItinI_CODE, @Lc_TypeSecondarySsn_CODE, @Lc_TypeTertiarySsn_CODE)
              AND a.Enumeration_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerificationStatusPending_CODE)
              AND a.EndValidity_DATE = @Ld_High_DATE
              AND EXISTS (SELECT 1
                            FROM CMEM_Y1 b,
                                 CASE_Y1 c
                           WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                             AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                             AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                             AND b.Case_IDNO = c.Case_IDNO
                             AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                             AND b.MemberMci_IDNO = @Ln_CollectionCur_ReferenceIrs_IDNO);

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;
		   -- 	
           IF @Li_Rowcount_QNTY = 1
            BEGIN
             SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
            END
           ELSE
            BEGIN
             IF @Li_Rowcount_QNTY > 1
              BEGIN
               SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
               -- 'TOO MANY MATCHING MEMBER FOR SSN';
               SET @Ls_Remarks_TEXT = @Ls_Remarksdesc02_TEXT;
              END
             ELSE
              BEGIN
               -- NO OPEN CASE AND ACTIVE MEMBER 
               SET @Ls_Sql_TEXT = 'SELECT MSSN_Y1 2';
               SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_MemberSsn_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_ReferenceIrs_IDNO AS VARCHAR ),'');

               SELECT TOP 1 @Ln_Payor_IDNO = a.MemberMci_IDNO
                 FROM MSSN_Y1 a
                WHERE a.MemberSsn_NUMB = @Ln_CollectionCur_MemberSsn_NUMB
                  AND a.TypePrimary_CODE IN (@Lc_TypePrimarySsn_CODE, @Lc_TypeItinI_CODE, @Lc_TypeSecondarySsn_CODE, @Lc_TypeTertiarySsn_CODE)
                  AND a.Enumeration_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerificationStatusPending_CODE)
                  AND a.EndValidity_DATE = @Ld_High_DATE
                  AND EXISTS (SELECT 1
                                FROM CMEM_Y1 b,
                                     CASE_Y1 c
                               WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                                 AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                 AND b.MemberMci_IDNO = @Ln_CollectionCur_ReferenceIrs_IDNO
                                 AND b.Case_IDNO = c.Case_IDNO);

               SET @Li_Rowcount_QNTY = @@ROWCOUNT;

			   -- SNNA - NCP  NOT ACTIVE/SNCC - SPC HOLD - CASE CLOSED
               IF @Li_Rowcount_QNTY > 0
                BEGIN
				 -- Defect 13036 - "Check whether the Payor's Case is Closed if so put in SNCC Hold for IRS Receipt" - Fix - Start -- 			
					IF NOT EXISTS (SELECT 1
								FROM CMEM_Y1 b,
									 CASE_Y1 c
							   WHERE b.MemberMci_IDNO = @Ln_CollectionCur_ReferenceIrs_IDNO
								 AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
								 AND b.Case_IDNO = c.Case_IDNO
								 AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
					BEGIN 
						 SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
						 SET @Lc_HoldReason_CODE = @Lc_HoldReasonStatusSncc_CODE;
						 SET @Ln_Held_AMNT = @Ln_CollectionCur_Receipt_AMNT;
						 SET @Ln_Identified_AMNT = 0;

						  SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNCC-1';
						  SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldReasonStatusSnna_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
						  
						  SELECT @Ln_OfDaysHold_NUMB = a.NumDaysHold_QNTY 
							   FROM UCAT_Y1 a
							  WHERE a.Udc_CODE = @Lc_HoldReasonStatusSncc_CODE
								AND a.EndValidity_DATE = @Ld_High_DATE;
		                  
						  SET @Ld_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB , @Ld_Run_DATE);				
					END 
				 -- Defect 13036 - "Check whether the Payor's Case is Closed if so put in SNCC Hold for IRS Receipt" - Fix - End --
                 ELSE 
                 BEGIN
					 SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
					 SET @Lc_HoldReason_CODE = @Lc_HoldReasonStatusSnna_CODE;
					 SET @Ln_Held_AMNT = @Ln_CollectionCur_Receipt_AMNT;
					 SET @Ln_Identified_AMNT = 0;

					  SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNNA-2';
					  SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldReasonStatusSnna_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
					  
					  SELECT @Ln_OfDaysHold_NUMB = a.NumDaysHold_QNTY 
						   FROM UCAT_Y1 a
						  WHERE a.Udc_CODE = @Lc_HoldReasonStatusSnna_CODE
							AND a.EndValidity_DATE = @Ld_High_DATE;
	                  
					  SET @Ld_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB , @Ld_Run_DATE);
                 END
                END
               ELSE
                BEGIN
                 SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
                 
                 -- "INVALID IRS REFERENCE ID" error code implementation for IRS Receipts
                 SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 3';
                 SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_ReferenceIrs_IDNO AS VARCHAR ),'');
                 
                 SELECT @Ln_QNTY = COUNT (1)
                   FROM CMEM_Y1 a
                  WHERE a.MemberMci_IDNO = @Ln_CollectionCur_ReferenceIrs_IDNO
                    AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE);

                 IF @Ln_QNTY = 0
                  BEGIN
                   -- INVALID IRS REFERENCE ID (MEMBER MCI NUMBER);
                   SET @Ls_Remarks_TEXT = @Ls_Remarksdesc05_TEXT;
                  END
                 ELSE
                  BEGIN
                   -- 'NO MATCHING MEMBER FOR SSN';
                   SET @Ls_Remarks_TEXT = @Ls_Remarksdesc01_TEXT;
                  END
                END
              END
            END
          END
         ELSE
          BEGIN
           SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
          END
        END
       -- IRS Payments Validation - End - 
       
       IF @Lc_HoldReason_CODE = @Lc_NoSpace_TEXT
        BEGIN
         SET @Ln_Held_AMNT = 0;
         SET @Ln_Identified_AMNT = 0;
        END

       -- To check if identified RCTH_Y1 need to be placed on hold
       IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
        BEGIN
         SET @Ln_CasePayor_IDNO = @Ln_Payor_IDNO;
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_RECEIPT_ON_HOLD';
         SET @Ls_Sqldata_TEXT = 'TypePosting_CODE = ' + @Lc_TypePosting_CODE + ', CasePayorMCI_IDNO = ' + ISNULL (CAST(@Ln_CasePayor_IDNO AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL (@Lc_CollectionCur_SourceReceipt_CODE, '')  + ', Receipt_AMNT = ' + ISNULL (CAST(@Ln_CollectionCur_Receipt_AMNT AS VARCHAR), '')  + ', Receipt_DATE = ' + ISNULL (CAST(@Ld_CollectionCur_Receipt_DATE AS VARCHAR), '')  + ', Run_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeRemittance_CODE = ' + ISNULL (@Lc_CollectionCur_TypeRemittance_CODE, '') + ', SuspendPayment_CODE = ' + @Lc_CollectionCur_SuspendPayment_CODE + ', Ln_Held_AMNT = ' + ISNULL (CAST(@Ln_Held_AMNT AS VARCHAR), '') + ', Ln_Identified_AMNT = ' + ISNULL (CAST(@Ln_Identified_AMNT AS VARCHAR), '');

         EXECUTE BATCH_COMMON$SP_RECEIPT_ON_HOLD
          @Ac_TypePosting_CODE      = @Lc_TypePosting_CODE,
          @An_CasePayorMCI_IDNO     = @Ln_CasePayor_IDNO,
          @Ac_SourceReceipt_CODE    = @Lc_CollectionCur_SourceReceipt_CODE,
          @An_Receipt_AMNT          = @Ln_CollectionCur_Receipt_AMNT,
          @Ad_Receipt_DATE          = @Ld_CollectionCur_Receipt_DATE,
          @Ad_Run_DATE              = @Ld_Run_DATE,
          @Ac_TypeRemittance_CODE   = @Lc_CollectionCur_TypeRemittance_CODE,
          @Ac_SuspendPayment_CODE   = @Lc_CollectionCur_SuspendPayment_CODE,
          @An_Held_AMNT             = @Ln_Held_AMNT OUTPUT,
          @An_Identified_AMNT       = @Ln_Identified_AMNT OUTPUT,
          @Ad_Release_DATE          = @Ld_Release_DATE OUTPUT,
          @Ac_ReasonHold_CODE       = @Lc_HoldReason_CODE OUTPUT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;
          
         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE 
		  BEGIN
				SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
				RAISERROR (50001,16,1);
		   END
		  ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
		 END                    
        END

       IF @Ln_Held_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GET_RECEIPT_NO';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CONVERT(VARCHAR, @Ld_CollectionCur_Batch_DATE, 112), '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_CollectionCur_Batch_NUMB AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL (@Lc_CollectionCur_SourceReceipt_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_CollectionCur_BatchSeq_NUMB AS VARCHAR), '') + ISNULL (CAST(@Ln_CollectionCur_BatchItem_NUMB AS VARCHAR), '');
         SET @Lc_ReceiptID_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ld_CollectionCur_Batch_DATE, @Lc_CollectionCur_SourceBatch_CODE, @Lc_CollectionCur_BatchNumb_TEXT, ISNULL (CAST(LTRIM(RTRIM(@Lc_CollectionCur_BatchSeqNumb_TEXT)) AS VARCHAR), '') + ISNULL (CAST(LTRIM(RTRIM(@Lc_CollectionCur_BatchItemNumb_TEXT)) AS VARCHAR), ''));
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ-1420-H';
		 SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Lc_JobProcess_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
          @Ac_Process_ID              = @Lc_JobProcess_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         -- ESEM_Y1 Entry for Receipt Date
         SET @Ls_Sql_TEXT = 'INSERT ESEM 1';
		 SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(CAST(RIGHT(CONVERT(VARCHAR, @Ld_CollectionCur_Batch_DATE, 112), 4) + LEFT(CONVERT(VARCHAR, @Ld_CollectionCur_Batch_DATE, 112), 4) AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR),'') + ', TypeEntity_CODE = ' + @Lc_TypeEntityRctdt_CODE + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR),'');
         INSERT ESEM_Y1
                (Entity_ID,
                 EventGlobalSeq_NUMB,
                 TypeEntity_CODE,
                 EventFunctionalSeq_NUMB)
         VALUES ( RIGHT(CONVERT(VARCHAR, @Ld_CollectionCur_Batch_DATE, 112), 4) + LEFT(CONVERT(VARCHAR, @Ld_CollectionCur_Batch_DATE, 112), 4),-- Entity_ID
                  @Ln_EventGlobalSeq_NUMB ,-- EventGlobalSeq_NUMB
                  @Lc_TypeEntityRctdt_CODE,-- TypeEntity_CODE
                  @Li_ReceiptOnHold1420_NUMB -- EventFunctionalSeq_NUMB
				);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'INSERT ESEM 2';
		 SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(@Lc_ReceiptID_TEXT, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR),'') + ', TypeEntity_CODE = ' + @Lc_TypeEntityRctno_CODE + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR),'');

         -- ESEM_Y1 Entry for Receipt No
         INSERT ESEM_Y1
                (Entity_ID,
                 EventGlobalSeq_NUMB,
                 TypeEntity_CODE,
                 EventFunctionalSeq_NUMB)
         VALUES (@Lc_ReceiptID_TEXT,-- Entity_ID
                 @Ln_EventGlobalSeq_NUMB,-- EventGlobalSeq_NUMB
                 @Lc_TypeEntityRctno_CODE,-- TypeEntity_CODE
                 @Li_ReceiptOnHold1420_NUMB -- EventFunctionalSeq_NUMB
         );

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 1';
		 SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CollectionCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_CollectionCur_SourceReceipt_CODE,'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_CollectionCur_TypeRemittance_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_CaseRcth_IDNO AS VARCHAR ),'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_Payor_IDNO AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_CollectionCur_Receipt_AMNT AS VARCHAR ),'')+ ', ToDistribute_AMNT = ' + ISNULL(CAST( @Ln_Held_AMNT AS VARCHAR ),'')+ ', Fee_AMNT = ' + ISNULL(CAST( @Ln_CollectionCur_Fee_AMNT AS VARCHAR ),'')+ ', Employer_IDNO = ' + ISNULL('0','')+ ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Check_DATE = ' + ISNULL(CAST( @Ld_Check_DATE AS VARCHAR ),'')+ ', CheckNo_TEXT = ' + ISNULL(@Lc_CollectionCur_CheckNo_Text,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Receipt_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Tanf_CODE = ' + ISNULL(@Lc_CollectionCur_Tanf_CODE,'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_CollectionCur_TaxJoint_CODE,'')+ ', TaxJoint_NAME = ' + ISNULL(@Lc_CollectionCur_TaxJointName_TEXT,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptHeld_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_HoldReason_CODE,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Refund_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', ReferenceIrs_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_ReferenceIrs_IDNO AS VARCHAR ),'')+ ', RefundRecipient_ID = ' + ISNULL('0','')+ ', RefundRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','');
         INSERT RCTH_Y1
                (Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceReceipt_CODE,
                 TypeRemittance_CODE,
                 TypePosting_CODE,
                 Case_IDNO,
                 PayorMCI_IDNO,
                 Receipt_AMNT,
                 ToDistribute_AMNT,
                 Fee_AMNT,
                 Employer_IDNO,
                 Fips_CODE,
                 Check_DATE,
                 CheckNo_TEXT,
                 Receipt_DATE,
                 Distribute_DATE,
                 Tanf_CODE,
                 TaxJoint_CODE,
                 TaxJoint_NAME,
                 StatusReceipt_CODE,
                 ReasonStatus_CODE,
                 BackOut_INDC,
                 ReasonBackOut_CODE,
                 Refund_DATE,
                 Release_DATE,
                 ReferenceIrs_IDNO,
                 RefundRecipient_ID,
                 RefundRecipient_CODE,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB)
         VALUES ( @Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                  @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                  @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                  @Ln_SeqReceipt_NUMB,-- SeqReceipt_NUMB
                  @Lc_CollectionCur_SourceReceipt_CODE,-- SourceReceipt_CODE
                  @Lc_CollectionCur_TypeRemittance_CODE,-- TypeRemittance_CODE
                  @Lc_TypePosting_CODE,-- TypePosting_CODE
                  @Ln_CaseRcth_IDNO,-- Case_IDNO
                  @Ln_Payor_IDNO,-- PayorMCI_IDNO
                  @Ln_CollectionCur_Receipt_AMNT,-- Receipt_AMNT
                  @Ln_Held_AMNT,-- ToDistribute_AMNT
                  @Ln_CollectionCur_Fee_AMNT,--Fee_AMNT
                  0,-- Employer_IDNO
                  @Lc_Space_TEXT,-- Fips_CODE
                  @Ld_Check_DATE,-- Check_DATE
                  @Lc_CollectionCur_CheckNo_Text,-- CheckNo_TEXT
                  @Ld_CollectionCur_Receipt_DATE,-- Receipt_DATE
                  @Ld_Low_DATE,-- Distribute_DATE
                  @Lc_CollectionCur_Tanf_CODE,-- Tanf_CODE
                  @Lc_CollectionCur_TaxJoint_CODE,-- TaxJoint_CODE
                  @Lc_CollectionCur_TaxJointName_TEXT,-- TaxJoint_NAME
                  @Lc_StatusReceiptHeld_CODE,-- StatusReceipt_CODE
                  @Lc_HoldReason_CODE,-- ReasonStatus_CODE
                  @Lc_No_INDC,-- BackOut_INDC
                  @Lc_Space_TEXT,-- ReasonBackOut_CODE
                  @Ld_Low_DATE,-- Refund_DATE
                  ISNULL (@Ld_Release_DATE, @Ld_High_DATE),-- Release_DATE
                  @Ln_CollectionCur_ReferenceIrs_IDNO,-- ReferenceIrs_IDNO
                  0,-- RefundRecipient_ID
                  @Lc_Space_TEXT,-- RefundRecipient_CODE
                  @Ld_Run_DATE,-- BeginValidity_DATE
                  @Ld_High_DATE,-- EndValidity_DATE
                  @Ln_EventGlobalSeq_NUMB,-- EventGlobalBeginSeq_NUMB
                  0 -- EventGlobalEndSeq_NUMB
         );

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END
		 
		 -- Defect 12473 - CR0266 SDU Notes Not Displaying in DECSS 20130828 Fix - Start --
		 -- The payment instructions associated with the receipt (with Hold Indicator of '1') that is listed in positions 207-434 of the collections file, will be inserted into UNOT_Y1 table.
		 IF @Lc_CollectionCur_SuspendPayment_CODE = @Lc_SuspendPayment1_CODE
		 BEGIN
		 
			SET @Ls_Remarks_TEXT = ISNULL (@Ls_CollectionCur_PymtInstr1_TEXT, '') + ISNULL (@Ls_CollectionCur_PymtInstr2_TEXT, '') + ISNULL (@Ls_CollectionCur_PymtInstr3_TEXT, '');
		 
			SET @Ls_Sql_TEXT = 'INSERT UNOT_Y1 1';
			SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR),'')+ ', DescriptionNote_TEXT = ' + ISNULL(@Ls_Remarks_TEXT,'');

			INSERT UNOT_Y1	
			(EventGlobalSeq_NUMB
			,EventGlobalApprovalSeq_NUMB
			,DescriptionNote_TEXT)
			VALUES
			(@Ln_EventGlobalSeq_NUMB -- EventGlobalSeq_NUMB
			,0 -- EventGlobalApprovalSeq_NUMB
			,@Ls_Remarks_TEXT -- DescriptionNote_TEXT
			);
			
			 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

			 IF @Li_Rowcount_QNTY = 0
			  BEGIN
			   -- 'Insert not successful'
			   SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

			   RAISERROR (50001,16,1);
			  END
		 END
		 -- Defect 12473 - CR0266 SDU Notes Not Displaying in DECSS 20130828 Fix - End --		 
		 
		IF @Lc_CollectionCur_SourceBatch_CODE = @Lc_SourceBatchSdu_CODE 
		 BEGIN
         SET @Ls_Sql_TEXT = 'INSERT RSDU_Y1 1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CollectionCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Rapid_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_Rapid_IDNO AS VARCHAR ),'')+ ', RapidEnvelope_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidEnvelope_NUMB AS VARCHAR ),'')+ ', RapidReceipt_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidReceipt_NUMB AS VARCHAR ),'')+ ', PaidBy_NAME = ' + ISNULL(@Ls_CollectionCur_PaidByName_TEXT,'')+ ', PaidBy_ID = ' + ISNULL(@Lc_CollectionCur_PaidById_TEXT,'')+ ', PaymentSourceSdu_CODE = ' + ISNULL(@Lc_CollectionCur_PaymentSourceSdu_CODE,'');

         INSERT RSDU_Y1
                (Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 Rapid_IDNO,
                 RapidEnvelope_NUMB,
                 RapidReceipt_NUMB,
                 PaidBy_NAME,
                 PaidBy_ID,
                 PaymentSourceSdu_CODE)
         VALUES ( @Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                  @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                  @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                  @Ln_SeqReceipt_NUMB,-- SeqReceipt_NUMB
                  @Ln_CollectionCur_Rapid_IDNO,-- Rapid_IDNO
                  @Ln_CollectionCur_RapidEnvelope_NUMB,-- RapidEnvelope_NUMB
                  @Ln_CollectionCur_RapidReceipt_NUMB,-- RapidReceipt_NUMB
                  @Ls_CollectionCur_PaidByName_TEXT,-- PaidBy_NAME
                  @Lc_CollectionCur_PaidById_TEXT,-- PaidBy_ID
                  @Lc_CollectionCur_PaymentSourceSdu_CODE -- PaymentSourceSdu_CODE
         );

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END
		 END 
         IF @Ln_CollectionCur_PayorMCI_IDNO <> 0
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT ESEM ';
           SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_CollectionCur_PayorMCI_IDNO AS VARCHAR), '');

           SELECT @Ln_QNTY = COUNT (1)
             FROM CASE_Y1 a,
                  CMEM_Y1 c
            WHERE c.MemberMci_IDNO = @Ln_CollectionCur_PayorMCI_IDNO
              AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
              AND a.Case_IDNO = c.Case_IDNO;

           IF @Ln_QNTY > 0
            BEGIN

             IF @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE
              BEGIN
             
              SET @Ls_Sql_TEXT = 'INSERT ESEM 3';
			  SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_CollectionCur_PayorMCI_IDNO AS VARCHAR), '')  + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR),'') + ', TypeEntity_CODE = ' + @Lc_TypeEntityCase_CODE + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR),'');
			 
               INSERT ESEM_Y1
                      (Entity_ID,
                       EventGlobalSeq_NUMB,
                       TypeEntity_CODE,
                       EventFunctionalSeq_NUMB)
               SELECT c.Case_IDNO AS Entity_ID,
                      @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                      @Lc_TypeEntityCase_CODE AS TypeEntity_CODE,
                      @Li_ReceiptOnHold1420_NUMB AS EventFunctionalSeq_NUMB
                 FROM CASE_Y1 a,
                      CMEM_Y1 c
                WHERE c.MemberMci_IDNO = @Ln_CollectionCur_PayorMCI_IDNO
                  AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                  AND a.Case_IDNO = c.Case_IDNO;

               SET @Li_Rowcount_QNTY = @@ROWCOUNT;

               IF @Li_Rowcount_QNTY = 0
                BEGIN
                 -- 'Insert not successful'
                 SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

                 RAISERROR (50001,16,1);
                END
              END
             ELSE
              BEGIN
               IF @Lc_TypePosting_CODE = @Lc_TypePostingCase_CODE
                BEGIN
                SET @Ls_Sql_TEXT = 'INSERT ESEM 4';
			    SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_CollectionCur_PayorMCI_IDNO AS VARCHAR), '') + ', CaseRcth_IDNO = ' + ISNULL(CAST( @Ln_CaseRcth_IDNO AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityCase_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'');
                 INSERT ESEM_Y1
                        (Entity_ID,
                         EventGlobalSeq_NUMB,
                         TypeEntity_CODE,
                         EventFunctionalSeq_NUMB)
                 SELECT c.Case_IDNO AS Entity_ID,
                        @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                        @Lc_TypeEntityCase_CODE AS TypeEntity_CODE,
                        @Li_ReceiptOnHold1420_NUMB AS EventFunctionalSeq_NUMB
                   FROM CASE_Y1 a,
                        CMEM_Y1 c
                  WHERE c.MemberMci_IDNO = @Ln_CollectionCur_PayorMCI_IDNO
                    AND c.Case_IDNO = @Ln_CaseRcth_IDNO
                    AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                    AND a.Case_IDNO = c.Case_IDNO;

                 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

                 IF @Li_Rowcount_QNTY = 0
                  BEGIN
                   -- 'Insert not successful'
                   SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

                   RAISERROR (50001,16,1);
                  END
                END
              END
            END
          END
        END

       IF @Ln_Identified_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ-1410-I';
         SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Li_IdentifyAReceipt1410_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Lc_JobProcess_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_IdentifyAReceipt1410_NUMB,
          @Ac_Process_ID              = @Lc_JobProcess_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 2 ';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CollectionCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_CollectionCur_SourceReceipt_CODE,'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_CollectionCur_TypeRemittance_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_CaseRcth_IDNO AS VARCHAR ),'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_Payor_IDNO AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_CollectionCur_Receipt_AMNT AS VARCHAR ),'')+ ', ToDistribute_AMNT = ' + ISNULL(CAST( @Ln_Identified_AMNT AS VARCHAR ),'')+ ', Fee_AMNT = ' + ISNULL(CAST( @Ln_CollectionCur_Fee_AMNT AS VARCHAR ),'')+ ', Employer_IDNO = ' + ISNULL('0','')+ ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Check_DATE = ' + ISNULL(CAST( @Ld_Check_DATE AS VARCHAR ),'')+ ', CheckNo_Text = ' + ISNULL(@Lc_CollectionCur_CheckNo_Text,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Receipt_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Tanf_CODE = ' + ISNULL(@Lc_CollectionCur_Tanf_CODE,'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_CollectionCur_TaxJoint_CODE,'')+ ', TaxJoint_NAME = ' + ISNULL(@Lc_CollectionCur_TaxJointName_TEXT,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Refund_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', ReferenceIrs_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_ReferenceIrs_IDNO AS VARCHAR ),'')+ ', RefundRecipient_ID = ' + ISNULL('0','')+ ', RefundRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','');

         INSERT RCTH_Y1
                (Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceReceipt_CODE,
                 TypeRemittance_CODE,
                 TypePosting_CODE,
                 Case_IDNO,
                 PayorMCI_IDNO,
                 Receipt_AMNT,
                 ToDistribute_AMNT,
                 Fee_AMNT,
                 Employer_IDNO,
                 Fips_CODE,
                 Check_DATE,
                 CheckNo_Text,
                 Receipt_DATE,
                 Distribute_DATE,
                 Tanf_CODE,
                 TaxJoint_CODE,
                 TaxJoint_NAME,
                 StatusReceipt_CODE,
                 ReasonStatus_CODE,
                 BackOut_INDC,
                 ReasonBackOut_CODE,
                 Refund_DATE,
                 Release_DATE,
                 ReferenceIrs_IDNO,
                 RefundRecipient_ID,
                 RefundRecipient_CODE,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB)
         VALUES ( @Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                  @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                  @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                  @Ln_SeqReceipt_NUMB,-- SeqReceipt_NUMB
                  @Lc_CollectionCur_SourceReceipt_CODE,-- SourceReceipt_CODE
                  @Lc_CollectionCur_TypeRemittance_CODE,-- TypeRemittance_CODE
                  @Lc_TypePosting_CODE,-- TypePosting_CODE
                  @Ln_CaseRcth_IDNO,-- Case_IDNO
                  @Ln_Payor_IDNO,-- PayorMCI_IDNO
                  @Ln_CollectionCur_Receipt_AMNT,-- Receipt_AMNT
                  @Ln_Identified_AMNT,-- ToDistribute_AMNT
                  @Ln_CollectionCur_Fee_AMNT,-- Fee_AMNT
                  0,-- Employer_IDNO
                  @Lc_Space_TEXT,-- Fips_CODE
                  @Ld_Check_DATE,-- Check_DATE
                  @Lc_CollectionCur_CheckNo_Text,-- CheckNo_TEXT
                  @Ld_CollectionCur_Receipt_DATE,-- Receipt_DATE
                  @Ld_Low_DATE,-- Distribute_DATE
                  @Lc_CollectionCur_Tanf_CODE,-- Tanf_CODE
                  @Lc_CollectionCur_TaxJoint_CODE,-- TaxJoint_CODE
                  @Lc_CollectionCur_TaxJointName_TEXT,-- TaxJoint_NAME
                  @Lc_StatusReceiptIdentified_CODE,-- StatusReceipt_CODE
                  @Lc_Space_TEXT,-- ReasonStatus_CODE
                  @Lc_No_INDC,-- BackOut_INDC
                  @Lc_Space_TEXT,-- ReasonBackOut_CODE
                  @Ld_Low_DATE,-- Refund_DATE
                  ISNULL (@Ld_Release_DATE, @Ld_High_DATE),-- Release_DATE
                  @Ln_CollectionCur_ReferenceIrs_IDNO,-- ReferenceIrs_IDNO
                  0,-- RefundRecipient_ID
                  @Lc_Space_TEXT,-- RefundRecipient_CODE
                  @Ld_Run_DATE,-- BeginValidity_DATE
                  @Ld_High_DATE,-- EndValidity_DATE
                  @Ln_EventGlobalSeq_NUMB,-- EventGlobalBeginSeq_NUMB
                  0 -- EventGlobalEndSeq_NUMB
         );

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END
	     
	    IF @Lc_CollectionCur_SourceBatch_CODE = @Lc_SourceBatchSdu_CODE 
	    BEGIN
         SET @Ls_Sql_TEXT = 'SELECT RSDU_Y1 - 1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Rapid_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_Rapid_IDNO AS VARCHAR ),'')+ ', RapidEnvelope_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidEnvelope_NUMB AS VARCHAR ),'')+ ', RapidReceipt_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidReceipt_NUMB AS VARCHAR ),'');

         SELECT @Ln_QNTY = COUNT (1)
           FROM RSDU_Y1 a
          WHERE Batch_DATE = @Ld_CollectionCur_Batch_DATE
            AND Batch_NUMB = @Ln_CollectionCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
            AND Rapid_IDNO = @Ln_CollectionCur_Rapid_IDNO
            AND RapidEnvelope_NUMB = @Ln_CollectionCur_RapidEnvelope_NUMB
            AND RapidReceipt_NUMB = @Ln_CollectionCur_RapidReceipt_NUMB;

         IF @Ln_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT RSDU_Y1 2';
           SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CollectionCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Rapid_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_Rapid_IDNO AS VARCHAR ),'')+ ', RapidEnvelope_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidEnvelope_NUMB AS VARCHAR ),'')+ ', RapidReceipt_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidReceipt_NUMB AS VARCHAR ),'')+ ', PaidBy_NAME = ' + ISNULL(@Ls_CollectionCur_PaidByName_TEXT,'')+ ', PaidBy_ID = ' + ISNULL(@Lc_CollectionCur_PaidById_TEXT,'')+ ', PaymentSourceSdu_CODE = ' + ISNULL(@Lc_CollectionCur_PaymentSourceSdu_CODE,'');

           INSERT RSDU_Y1
                  (Batch_DATE,
                   SourceBatch_CODE,
                   Batch_NUMB,
                   SeqReceipt_NUMB,
                   Rapid_IDNO,
                   RapidEnvelope_NUMB,
                   RapidReceipt_NUMB,
                   PaidBy_NAME,
                   PaidBy_ID,
                   PaymentSourceSdu_CODE)
           VALUES ( @Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                    @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                    @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                    @Ln_SeqReceipt_NUMB,-- SeqReceipt_NUMB
                    @Ln_CollectionCur_Rapid_IDNO,-- Rapid_IDNO
                    @Ln_CollectionCur_RapidEnvelope_NUMB,-- RapidEnvelope_NUMB
                    @Ln_CollectionCur_RapidReceipt_NUMB,-- RapidReceipt_NUMB
                    @Ls_CollectionCur_PaidByName_TEXT,-- PaidBy_NAME
                    @Lc_CollectionCur_PaidById_TEXT,-- PaidBy_ID
                    @Lc_CollectionCur_PaymentSourceSdu_CODE -- PaymentSourceSdu_CODE
           );

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             -- 'Insert not successful'
             SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

             RAISERROR (50001,16,1);
            END
          END
         END 
        END

       IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ-1410-U';
         SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Li_IdentifyAReceipt1410_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL (@Lc_JobProcess_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_IdentifyAReceipt1410_NUMB,
          @Ac_Process_ID              = @Lc_JobProcess_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

		 -- UNEX - UNIDENTIFIED EXCEPTION - SDU
		 -- UNID - UNIDENTIFIED RECEIPTS
         IF @Lc_ReasonStatus_CODE != @Lc_UnidenholdExceptionsdu_CODE
          BEGIN
           SET @Lc_ReasonStatus_CODE = @Lc_UnidenholdUnidentreceipts_CODE;
          END

         SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 3';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CollectionCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_CollectionCur_SourceReceipt_CODE,'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_CollectionCur_TypeRemittance_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Case_IDNO = ' + ISNULL('0','')+ ', PayorMCI_IDNO = ' + ISNULL('0','')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_CollectionCur_Receipt_AMNT AS VARCHAR ),'')+ ', ToDistribute_AMNT = ' + ISNULL(CAST( @Ln_CollectionCur_Receipt_AMNT AS VARCHAR ),'')+ ', Fee_AMNT = ' + ISNULL(CAST( @Ln_CollectionCur_Fee_AMNT AS VARCHAR ),'')+ ', Employer_IDNO = ' + ISNULL('0','')+ ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Check_DATE = ' + ISNULL(CAST( @Ld_Check_DATE AS VARCHAR ),'')+ ', CheckNo_Text = ' + ISNULL(@Lc_CollectionCur_CheckNo_Text,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Receipt_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Tanf_CODE = ' + ISNULL(@Lc_CollectionCur_Tanf_CODE,'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_CollectionCur_TaxJoint_CODE,'')+ ', TaxJoint_NAME = ' + ISNULL(@Lc_CollectionCur_TaxJointName_TEXT,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptUnidentified_CODE,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Refund_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', ReferenceIrs_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_ReferenceIrs_IDNO AS VARCHAR ),'')+ ', RefundRecipient_ID = ' + ISNULL('0','')+ ', RefundRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','');

         INSERT RCTH_Y1
                (Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceReceipt_CODE,
                 TypeRemittance_CODE,
                 TypePosting_CODE,
                 Case_IDNO,
                 PayorMCI_IDNO,
                 Receipt_AMNT,
                 ToDistribute_AMNT,
                 Fee_AMNT,
                 Employer_IDNO,
                 Fips_CODE,
                 Check_DATE,
                 CheckNo_Text,
                 Receipt_DATE,
                 Distribute_DATE,
                 Tanf_CODE,
                 TaxJoint_CODE,
                 TaxJoint_NAME,
                 StatusReceipt_CODE,
                 ReasonStatus_CODE,
                 BackOut_INDC,
                 ReasonBackOut_CODE,
                 Refund_DATE,
                 Release_DATE,
                 ReferenceIrs_IDNO,
                 RefundRecipient_ID,
                 RefundRecipient_CODE,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB)
         VALUES ( @Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                  @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                  @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                  @Ln_SeqReceipt_NUMB,-- SeqReceipt_NUMB
                  @Lc_CollectionCur_SourceReceipt_CODE,-- SourceReceipt_CODE
                  @Lc_CollectionCur_TypeRemittance_CODE,-- TypeRemittance_CODE
                  @Lc_Space_TEXT,-- TypePosting_CODE
                  0,-- Case_IDNO
                  0,-- PayorMCI_IDNO
                  @Ln_CollectionCur_Receipt_AMNT,-- Receipt_AMNT
                  @Ln_CollectionCur_Receipt_AMNT,-- ToDistribute_AMNT
                  @Ln_CollectionCur_Fee_AMNT,-- Fee_AMNT
                  0,-- Employer_IDNO
                  @Lc_Space_TEXT,-- Fips_CODE
                  @Ld_Check_DATE,-- Check_DATE
                  @Lc_CollectionCur_CheckNo_Text,-- CheckNo_TEXT
                  @Ld_CollectionCur_Receipt_DATE,-- Receipt_DATE
                  @Ld_Low_DATE,-- Distribute_DATE
                  @Lc_CollectionCur_Tanf_CODE,-- Tanf_CODE
                  @Lc_CollectionCur_TaxJoint_CODE,-- TaxJoint_CODE
                  @Lc_CollectionCur_TaxJointName_TEXT,-- TaxJoint_NAME
                  @Lc_StatusReceiptUnidentified_CODE,-- StatusReceipt_CODE
                  ISNULL (@Lc_ReasonStatus_CODE, @Lc_UnidenholdUnidentreceipts_CODE),-- ReasonStatus_CODE
                  @Lc_No_INDC,-- BackOut_INDC
                  @Lc_Space_TEXT,-- ReasonBackOut_CODE
                  @Ld_Low_DATE,-- Refund_DATE
                  ISNULL (@Ld_Release_DATE, @Ld_High_DATE),-- Release_DATE
                  @Ln_CollectionCur_ReferenceIrs_IDNO,-- ReferenceIrs_IDNO
                  0,-- RefundRecipient_ID
                  @Lc_Space_TEXT,-- RefundRecipient_CODE
                  @Ld_Run_DATE,-- BeginValidity_DATE
                  @Ld_High_DATE,-- EndValidity_DATE
                  @Ln_EventGlobalSeq_NUMB,-- EventGlobalBeginSeq_NUMB
                  0 -- EventGlobalEndSeq_NUMB
         );

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END
          
	    IF @Lc_CollectionCur_SourceBatch_CODE = @Lc_SourceBatchSdu_CODE 
	    BEGIN
         SET @Ls_Sql_TEXT = 'SELECT RSDU_Y1 - 2 ';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Rapid_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_Rapid_IDNO AS VARCHAR ),'')+ ', RapidEnvelope_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidEnvelope_NUMB AS VARCHAR ),'')+ ', RapidReceipt_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidReceipt_NUMB AS VARCHAR ),'');

         SELECT @Ln_QNTY = COUNT (1)
           FROM RSDU_Y1 a
          WHERE Batch_DATE = @Ld_CollectionCur_Batch_DATE
            AND Batch_NUMB = @Ln_CollectionCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
            AND Rapid_IDNO = @Ln_CollectionCur_Rapid_IDNO
            AND RapidEnvelope_NUMB = @Ln_CollectionCur_RapidEnvelope_NUMB
            AND RapidReceipt_NUMB = @Ln_CollectionCur_RapidReceipt_NUMB;

         IF @Ln_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT RSDU_Y1 3';
           SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CollectionCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Rapid_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_Rapid_IDNO AS VARCHAR ),'')+ ', RapidEnvelope_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidEnvelope_NUMB AS VARCHAR ),'')+ ', RapidReceipt_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_RapidReceipt_NUMB AS VARCHAR ),'')+ ', PaidBy_NAME = ' + ISNULL(@Ls_CollectionCur_PaidByName_TEXT,'')+ ', PaidBy_ID = ' + ISNULL(@Lc_CollectionCur_PaidById_TEXT,'')+ ', PaymentSourceSdu_CODE = ' + ISNULL(@Lc_CollectionCur_PaymentSourceSdu_CODE,'');

           INSERT RSDU_Y1
                  (Batch_DATE,
                   SourceBatch_CODE,
                   Batch_NUMB,
                   SeqReceipt_NUMB,
                   Rapid_IDNO,
                   RapidEnvelope_NUMB,
                   RapidReceipt_NUMB,
                   PaidBy_NAME,
                   PaidBy_ID,
                   PaymentSourceSdu_CODE)
           VALUES ( @Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                    @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                    @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                    @Ln_SeqReceipt_NUMB,-- SeqReceipt_NUMB
                    @Ln_CollectionCur_Rapid_IDNO,-- Rapid_IDNO
                    @Ln_CollectionCur_RapidEnvelope_NUMB,-- RapidEnvelope_NUMB
                    @Ln_CollectionCur_RapidReceipt_NUMB,-- RapidReceipt_NUMB
                    @Ls_CollectionCur_PaidByName_TEXT,-- PaidBy_NAME
                    @Lc_CollectionCur_PaidById_TEXT,-- PaidBy_ID
                    @Lc_CollectionCur_PaymentSourceSdu_CODE -- PaymentSourceSdu_CODE
           );

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             -- 'Insert not successful'
             SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

             RAISERROR (50001,16,1);
            END
          END
         END 

         SET @Ls_Remarks_TEXT = SUBSTRING(ISNULL (@Ls_Remarks_TEXT, '') + ISNULL (@Lc_Space_TEXT, '') + ISNULL (@Ls_CollectionCur_PymtInstr1_TEXT, '') + ISNULL (@Ls_CollectionCur_PymtInstr2_TEXT, '') + ISNULL (@Ls_CollectionCur_PymtInstr3_TEXT, ''), 1, 328);
         SET @Ls_Sql_TEXT = 'INSERT URCT_Y1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_CollectionCur_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_CollectionCur_SourceBatch_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_CollectionCur_SourceReceipt_CODE,'')+ ', Payor_NAME = ' + ISNULL(@Ls_CollectionCur_PayorName_TEXT,'')+ ', PayorLine1_ADDR = ' + ISNULL(@Lc_CollectionCur_PayorLine1Addr_TEXT,'')+ ', PayorLine2_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PayorCity_ADDR = ' + ISNULL(@Lc_CollectionCur_PayorCityAddr_TEXT,'')+ ', PayorState_ADDR = ' + ISNULL(@Lc_CollectionCur_PayorStateAddr_TEXT,'')+ ', PayorZip_ADDR = ' + ISNULL(@Lc_CollectionCur_PayorZipAddr_TEXT,'')+ ', PayorCountry_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank_NAME = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank1_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank2_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankCity_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankState_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankZip_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankCountry_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank_IDNO = ' + ISNULL('0','')+ ', BankAcct_NUMB = ' + ISNULL('0','')+ ', CaseIdent_IDNO = ' + ISNULL('0','')+ ', IdentifiedPayorMci_IDNO = ' + ISNULL('0','')+ ', Identified_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', OtherParty_IDNO = ' + ISNULL('0','')+ ', IdentificationStatus_CODE = ' + ISNULL(@Lc_StatusReceiptUnidentified_CODE,'')+ ', Employer_IDNO = ' + ISNULL('0','')+ ', IvdAgency_IDNO = ' + ISNULL('0','')+ ', UnidentifiedMemberMci_IDNO = ' + ISNULL(CAST( @Ln_CollectionCur_PayorMCI_IDNO AS VARCHAR ),'')+ ', UnidentifiedSsn_NUMB = ' + ISNULL(CAST( @Ln_CollectionCur_MemberSsn_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         INSERT URCT_Y1
                (Batch_DATE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceBatch_CODE,
                 SourceReceipt_CODE,
                 Payor_NAME,
                 PayorLine1_ADDR,
                 PayorLine2_ADDR,
                 PayorCity_ADDR,
                 PayorState_ADDR,
                 PayorZip_ADDR,
                 PayorCountry_ADDR,
                 Bank_NAME,
                 Bank1_ADDR,
                 Bank2_ADDR,
                 BankCity_ADDR,
                 BankState_ADDR,
                 BankZip_ADDR,
                 BankCountry_ADDR,
                 Bank_IDNO,
                 BankAcct_NUMB,
                 Remarks_TEXT,
                 CaseIdent_IDNO,
                 IdentifiedPayorMci_IDNO,
                 Identified_DATE,
                 OtherParty_IDNO,
                 IdentificationStatus_CODE,
                 Employer_IDNO,
                 IvdAgency_IDNO,
                 UnidentifiedMemberMci_IDNO,
                 UnidentifiedSsn_NUMB,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB,
                 StatusEscheat_CODE,
                 StatusEscheat_DATE)
         VALUES ( @Ld_CollectionCur_Batch_DATE,-- Batch_DATE
                  @Ln_CollectionCur_Batch_NUMB,-- Batch_NUMB
                  @Ln_SeqReceipt_NUMB,-- SeqReceipt_NUMB
                  @Lc_CollectionCur_SourceBatch_CODE,-- SourceBatch_CODE
                  @Lc_CollectionCur_SourceReceipt_CODE,-- SourceReceipt_CODE
                  @Ls_CollectionCur_PayorName_TEXT,-- Payor_NAME
                  @Lc_CollectionCur_PayorLine1Addr_TEXT,-- PayorLine1_ADDR
                  @Lc_Space_TEXT,-- PayorLine2_ADDR
                  @Lc_CollectionCur_PayorCityAddr_TEXT,-- PayorCity_ADDR
                  @Lc_CollectionCur_PayorStateAddr_TEXT,-- PayorState_ADDR
                  @Lc_CollectionCur_PayorZipAddr_TEXT,-- PayorZip_ADDR
                  @Lc_Space_TEXT,-- PayorCountry_ADDR
                  @Lc_Space_TEXT,-- Bank_NAME
                  @Lc_Space_TEXT,-- Bank1_ADDR
                  @Lc_Space_TEXT,-- Bank2_ADDR
                  @Lc_Space_TEXT,-- BankCity_ADDR
                  @Lc_Space_TEXT,-- BankState_ADDR
                  @Lc_Space_TEXT,-- BankZip_ADDR
                  @Lc_Space_TEXT,-- BankCountry_ADDR
                  0,-- Bank_IDNO
                  0,-- BankAcct_NUMB
                  ISNULL (@Ls_Remarks_TEXT, @Lc_Space_TEXT),-- Remarks_TEXT
                  0,-- CaseIdent_IDNO
                  0,-- IdentifiedPayorMci_IDNO
                  @Ld_Low_DATE,-- Identified_DATE
                  0,-- OtherParty_IDNO
                  @Lc_StatusReceiptUnidentified_CODE,-- IdentificationStatus_CODE
                  0,-- Employer_IDNO
                  0,-- IvdAgency_IDNO
                  @Ln_CollectionCur_PayorMCI_IDNO,-- UnidentifiedMemberMci_IDNO
                  @Ln_CollectionCur_MemberSsn_NUMB,-- UnidentifiedSsn_NUMB
                  @Ld_Run_DATE,-- BeginValidity_DATE
                  @Ld_High_DATE,-- EndValidity_DATE
                  @Ln_EventGlobalSeq_NUMB,-- EventGlobalBeginSeq_NUMB
                  0,-- EventGlobalEndSeq_NUMB
                  @Lc_Space_TEXT,-- StatusEscheat_CODE
                  @Ld_High_DATE -- StatusEscheat_DATE
         );

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Insert not successful'
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END
        END
        
       -- 'CR' receipt type processing
       IF @Ln_Identified_AMNT > 0
          AND @Lc_CollectionCur_SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupmentCR_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_COLLECTIONS$SP_CR_RECEIPT_PROCESS';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Ld_CollectionCur_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_CollectionCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '')  + ', SourceBatch_CODE = ' + ISNULL (@Lc_CollectionCur_SourceBatch_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CaseRcth_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_Payor_IDNO AS VARCHAR), '') + ', Identified_AMNT = ' + ISNULL (CAST(@Ln_Identified_AMNT AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB= ' + ISNULL (CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL (CAST(@Ld_CollectionCur_Receipt_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '');
  
         EXECUTE BATCH_FIN_COLLECTIONS$SP_CR_RECEIPT_PROCESS
          @Ad_Batch_DATE               = @Ld_CollectionCur_Batch_DATE,
          @An_Batch_NUMB               = @Ln_CollectionCur_Batch_NUMB,
          @An_SeqReceipt_NUMB          = @Ln_SeqReceipt_NUMB,
          @Ac_SourceBatch_CODE         = @Lc_CollectionCur_SourceBatch_CODE,
          @An_Case_IDNO                = @Ln_CaseRcth_IDNO,
          @An_PayorMCI_IDNO            = @Ln_Payor_IDNO,
          @An_Identified_AMNT          = @Ln_Identified_AMNT,
          @An_EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
          @Ad_Receipt_DATE             = @Ld_CollectionCur_Receipt_DATE,
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;
  
         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END
      END

       -- 'CF' receipt type processing
       IF @Ln_Identified_AMNT > 0
          AND @Lc_CollectionCur_SourceReceipt_CODE = @Lc_SourceReceiptCpFeePaymentCF_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_COLLECTIONS$SP_CF_RECEIPT_PROCESS';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Ld_CollectionCur_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_CollectionCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '')  + ', SourceBatch_CODE = ' + ISNULL (@Lc_CollectionCur_SourceBatch_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CaseRcth_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_Payor_IDNO AS VARCHAR), '') + ', Identified_AMNT = ' + ISNULL (CAST(@Ln_Identified_AMNT AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB= ' + ISNULL (CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL (CAST(@Ld_CollectionCur_Receipt_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') ;
  
         EXECUTE BATCH_FIN_COLLECTIONS$SP_CF_RECEIPT_PROCESS
          @Ad_Batch_DATE               = @Ld_CollectionCur_Batch_DATE,
          @An_Batch_NUMB               = @Ln_CollectionCur_Batch_NUMB,
          @An_SeqReceipt_NUMB          = @Ln_SeqReceipt_NUMB,
          @Ac_SourceBatch_CODE         = @Lc_CollectionCur_SourceBatch_CODE,
          @An_Case_IDNO                = @Ln_CaseRcth_IDNO,
          @An_PayorMCI_IDNO            = @Ln_Payor_IDNO,
          @An_Identified_AMNT          = @Ln_Identified_AMNT,
          @An_EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
          @Ad_Receipt_DATE             = @Ld_CollectionCur_Receipt_DATE,
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;
  
         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END
     -- 1 -- End -- 
     END TRY
     BEGIN CATCH

		IF XACT_STATE() = 1
		BEGIN
		   ROLLBACK TRANSACTION SaveColTran;
		END
		ELSE
		BEGIN
			SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
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
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

	   SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + 	', BateError_CODE = ' + RTRIM(@Lc_BateError_CODE) + ', BateRecord_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT,'');	

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-Exception';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_JobProcess_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorE_CODE + ', Line_NUMB = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR),'') + ', Error_CODE = ' + @Lc_BateError_CODE + ', As_DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_JobProcess_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       
       SET @Lb_StgtableProcessUpdate_BIT = 0;
       
	END CATCH
	
     IF @Lb_StgtableProcessUpdate_BIT = 1
      BEGIN
       IF @Lc_CollectionCur_SourceLoad_CODE = @Lc_SourceBatchSdu_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE LCSDU_Y1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(@Lc_CollectionCur_BatchDate_TEXT,'')+ ', Batch_NUMB = ' + ISNULL(@Lc_CollectionCur_BatchNumb_TEXT,'')+ ', BatchSeq_NUMB = ' + ISNULL(@Lc_CollectionCur_BatchSeqNumb_TEXT,'')+ ', BatchItem_NUMB = ' + ISNULL(@Lc_CollectionCur_BatchItemNumb_TEXT,'');

         UPDATE LCSDU_Y1
            SET Process_INDC = @Lc_Yes_INDC
          WHERE Batch_DATE = @Lc_CollectionCur_BatchDate_TEXT
            AND Batch_NUMB = @Lc_CollectionCur_BatchNumb_TEXT
            AND BatchSeq_NUMB = @Lc_CollectionCur_BatchSeqNumb_TEXT
            AND BatchItem_NUMB = @Lc_CollectionCur_BatchItemNumb_TEXT;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Update not successful'
           SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END
        END
       ELSE IF @Lc_CollectionCur_SourceLoad_CODE = @Lc_SourceBatchSpc_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE LCIRS_Y1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(@Lc_CollectionCur_BatchDate_TEXT,'')+ ', Batch_NUMB = ' + ISNULL(@Lc_CollectionCur_BatchNumb_TEXT,'')+ ', BatchSeq_NUMB = ' + ISNULL(@Lc_CollectionCur_BatchSeqNumb_TEXT,'')+ ', BatchItem_NUMB = ' + ISNULL(@Lc_CollectionCur_BatchItemNumb_TEXT,'');

         UPDATE LCIRS_Y1
            SET Process_CODE = @Lc_ProcessP_CODE
          WHERE Batch_DATE = @Lc_CollectionCur_BatchDate_TEXT
            AND Batch_NUMB = @Lc_CollectionCur_BatchNumb_TEXT
            AND BatchSeq_NUMB = @Lc_CollectionCur_BatchSeqNumb_TEXT
            AND BatchItem_NUMB = @Lc_CollectionCur_BatchItemNumb_TEXT;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- 'Update not successful'
           SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

           RAISERROR (50001,16,1);
          END
        END
      END

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = @Ls_Errdesc01_TEXT + '. ' + @Ls_DescriptionError_TEXT;
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH CollectionCur - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Collection_CUR INTO @Ln_CollectionCur_Seq_IDNO, @Lc_CollectionCur_BatchDate_TEXT, @Lc_CollectionCur_BatchNumb_TEXT, @Lc_CollectionCur_BatchSeqNumb_TEXT, @Lc_CollectionCur_BatchItemNumb_TEXT, @Lc_CollectionCur_SourceBatch_CODE, @Lc_CollectionCur_SourceReceipt_CODE, @Lc_CollectionCur_TypeRemittance_CODE, @Lc_CollectionCur_RapidIdno_TEXT, @Lc_CollectionCur_RapidEnvelopeNumb_TEXT, @Lc_CollectionCur_RapidReceiptNumb_TEXT, @Lc_CollectionCur_PayorMCIIdno_TEXT, @Lc_CollectionCur_MemberSsnNumb_TEXT, @Lc_CollectionCur_ReceiptAmnt_TEXT, @Lc_CollectionCur_FeeAmnt_TEXT, @Lc_CollectionCur_ReceiptDate_TEXT, @Ls_CollectionCur_PaidByName_TEXT, @Lc_CollectionCur_PaidById_TEXT, @Lc_CollectionCur_PaymentSourceSdu_CODE, @Lc_CollectionCur_Tanf_CODE, @Lc_CollectionCur_TaxJoint_CODE, @Lc_CollectionCur_TaxJointName_TEXT, @Lc_CollectionCur_ReferenceIrsIdno_TEXT, @Lc_CollectionCur_InjuredSpouse_INDC, @Ls_CollectionCur_PayorName_TEXT, @Lc_CollectionCur_PayorLine1Addr_TEXT, @Lc_CollectionCur_PayorCityAddr_TEXT, @Lc_CollectionCur_PayorStateAddr_TEXT, @Lc_CollectionCur_PayorZipAddr_TEXT, @Lc_CollectionCur_SuspendPayment_CODE, @Lc_CollectionCur_CheckNo_Text, @Ls_CollectionCur_PymtInstr1_TEXT, @Ls_CollectionCur_PymtInstr2_TEXT, @Ls_CollectionCur_PymtInstr3_TEXT, @Lc_CollectionCur_Process_CODE, @Lc_CollectionCur_SourceLoad_CODE, @Lc_CollectionCur_BatchOrigDate_TEXT, @Lc_CollectionCur_BatchOrigNumb_TEXT, @Lc_CollectionCur_OrigBatchSeqNumb_TEXT, @Lc_CollectionCur_BatchItemOrigNumb_TEXT, @Lc_CollectionCur_SourceReceiptOrig_CODE, @Lc_CollectionCur_TypeRemittanceOrig_CODE, @Lc_CollectionCur_MemberSsnOrigNumb_TEXT, @Lc_CollectionCur_Offset_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END -- Collection LOOP END

   CLOSE Collection_CUR;

   DEALLOCATE Collection_CUR;

   SET @Ls_Sql_TEXT = 'SELECT LCSDU_Y1';
   SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_Yes_INDC,'');
   
   SELECT @Ln_SduProcessRecord_QNTY = COUNT(1)
     FROM LCSDU_Y1 a
    WHERE FileLoad_DATE = @Ld_Run_DATE 
    AND  Process_INDC = @Lc_Yes_INDC;
   	
   SET @Ls_Sql_TEXT = 'NO RECORD(S) IN CURSOR FOR PROCESS';
   SET @Ls_Sqldata_TEXT = 'Ln_CursorRecordCount_QNTY = ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '0');
   IF @Ln_CursorRecordCount_QNTY = 0
    BEGIN
     -- 'NO RECORD(S) FOR PROCESS'
     SET @Ls_ErrorMessage_TEXT = @Ls_Errdesc02_TEXT;

     RAISERROR (50001,16,1);
    END

   -- if there is no error then update last receipt batch counts
   IF @Lb_ErrorFound_BIT = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE RBAT_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Ld_OldBatch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_ReconSoureBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_ReconBatch_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST(@Ln_ReconEventGlobalSeq_NUMB AS VARCHAR), '') + ', Ln_Detail_QNTY = ' + ISNULL (CAST(@Ln_Detail_QNTY AS VARCHAR), '') + ', Ln_DetailTotal_AMNT = ' + ISNULL (CAST(@Ln_DetailTotal_AMNT AS VARCHAR), '') + ', Ln_Trans_QNTY = ' + ISNULL (CAST(@Ln_Trans_QNTY AS VARCHAR), '');

     UPDATE RBAT_Y1
        SET CtControlReceipt_QNTY = @Ln_Detail_QNTY,
            CtActualReceipt_QNTY = @Ln_Detail_QNTY,
            ControlReceipt_AMNT = @Ln_DetailTotal_AMNT,
            ActualReceipt_AMNT = @Ln_DetailTotal_AMNT,
            CtControlTrans_QNTY = @Ln_Trans_QNTY,
            CtActualTrans_QNTY = @Ln_Trans_QNTY,
            StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
      WHERE Batch_DATE = @Ld_OldBatch_DATE
        AND SourceBatch_CODE = @Lc_ReconSoureBatch_CODE
        AND Batch_NUMB = @Ln_ReconBatch_NUMB
        AND EventGlobalBeginSeq_NUMB = @Ln_ReconEventGlobalSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       -- 'Update not successful'
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END
    END
   -- Collection process job should commit one time at end of the job. This change is implemented to avoid more than one RBAT entry for same batch number with different counts, total amounts when job is ABEND middle of the batch.
   COMMIT TRANSACTION ColTran; -- 1

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_JobProcess_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);	
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobProcess_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_JobProcess_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_NoSpace_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobProcess_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_NoSpace_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
  END TRY
  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ColTran;
    END

   IF CURSOR_STATUS ('LOCAL', 'Collection_CUR') IN (0, 1)
    BEGIN
     CLOSE Collection_CUR;

     DEALLOCATE Collection_CUR;
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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_JobProcess_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;    

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END

GO
