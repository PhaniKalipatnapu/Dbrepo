/****** Object:  StoredProcedure [dbo].[BATCH_FIN_COLLECTIONS$SP_EXTRACT_SDU_RECON]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_COLLECTIONS$SP_EXTRACT_SDU_RECON
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_COLLECTIONS$SP_EXTRACT_SDU_RECON reads the collection data from 
					  LCSDU_Y1 table and creates the reconciliation file to SDU.
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
CREATE PROCEDURE [dbo].[BATCH_FIN_COLLECTIONS$SP_EXTRACT_SDU_RECON]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE         CHAR(1) = 'A',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE				 CHAR(1) = 'E',
          @Lc_SourceReceiptFF_CODE           CHAR(2) = 'FF',          
          @Lc_BatchRunUser_TEXT              CHAR(5) = 'BATCH',
          @Lc_ErrorE1424_CODE				 CHAR(5) = 'E1424',
          @Lc_ErrorE0085_CODE                CHAR(5) = 'E0085',
          @Lc_ErrorE1062_CODE                CHAR(5) = 'E1062',
          @Lc_Job_ID                         CHAR(7) = 'DEB0191',
          @Lc_Successful_TEXT                CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT           VARCHAR(100) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                   VARCHAR(100) = 'BATCH_FIN_COLLECTIONS',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_EXTRACT_SDU_RECON',
          @Ls_Errdesc01_TEXT                 VARCHAR(100) = 'REACHED EXCEPTION THRESHOLD',
          @Ls_Errdesc02_TEXT                 VARCHAR(100) = 'NO RECORD(S) FOR PROCESS',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_SeqReceipt_NUMB             NUMERIC(6),
          @Ln_CursorRecordCount_QNTY      NUMERIC(10) = 0,
          @Ln_Recon_QNTY                  NUMERIC(10) = 0,
		  @Ln_Recon_AMNT				  NUMERIC(11, 2) = 0,          
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Li_FetchStatus_QNTY			  SMALLINT,
          @Li_Rowcount_QNTY				  SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_TypePosting_CODE            CHAR(1),
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_BateError_CODE              CHAR(18),
          @Lc_Recon_TEXT				  CHAR(38),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

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
    ORDER BY Seq_IDNO;

  BEGIN TRY
   -- The Batch start time to use while inserting into the batch log
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   -- Get date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
     RAISERROR(50001,16,1);
    END;
    
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   -- RUN DATE AND LAST RUN DATE VALIDATION
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;
     RAISERROR (50001,16,1);
    END;

	-- Collection SDU File validation -- Start --
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
     SET @Ls_ErrorMessage_TEXT = '';
	 -- UNKNOWN EXCEPTION IN BATCH
	 SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
	  
	 SET @Ls_CursorLocation_TEXT = 'COLLECTION - CURSOR COUNT - ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '');

	 SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL (CAST(@Ln_CollectionCur_Seq_IDNO AS VARCHAR), '') +  ', Batch_DATE = ' + ISNULL (@Lc_CollectionCur_BatchDate_TEXT, '') + ', Batch_NUMB = ' + ISNULL (@Lc_CollectionCur_BatchNumb_TEXT, '') + ', BatchSeq_NUMB  = ' + ISNULL (@Lc_CollectionCur_BatchSeqNumb_TEXT, '') + ', BatchItem_NUMB = ' + ISNULL (@Lc_CollectionCur_BatchItemNumb_TEXT, '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_CollectionCur_SourceBatch_CODE, '') + ', SourceReceipt_CODE = ' + ISNULL (@Lc_CollectionCur_SourceReceipt_CODE, '') + ', TypeRemittance_CODE = ' + ISNULL (@Lc_CollectionCur_TypeRemittance_CODE, '') + ', Rapid_IDNO = ' + ISNULL (@Lc_CollectionCur_RapidIdno_TEXT, '') + ', RapidEnvelope_NUMB = ' + ISNULL (@Lc_CollectionCur_RapidEnvelopeNumb_TEXT, '') + ', RapidReceipt_NUMB = ' + ISNULL (@Lc_CollectionCur_RapidReceiptNumb_TEXT, '') + ', PayorMCI_IDNO = ' + ISNULL (@Lc_CollectionCur_PayorMCIIdno_TEXT, '') + ', MemberSsn_NUMB  = ' + ISNULL (@Lc_CollectionCur_MemberSsnNumb_TEXT, '') + ', Receipt_AMNT = ' + ISNULL (@Lc_CollectionCur_ReceiptAmnt_TEXT, '') + ', Fee_AMNT  = ' + ISNULL (@Lc_CollectionCur_FeeAmnt_TEXT, '') + ', Receipt_DATE = ' + ISNULL (@Lc_CollectionCur_ReceiptDate_TEXT, '') + ', PaidBy_NAME = ' + ISNULL (RTRIM(@Ls_CollectionCur_PaidByName_TEXT), '') + ', PaidBy_ID = ' + ISNULL (RTRIM(@Lc_CollectionCur_PaidById_TEXT), '') + ', PaymentSourceSdu_CODE= ' + ISNULL (@Lc_CollectionCur_PaymentSourceSdu_CODE, '') + ', Tanf_CODE = ' + ISNULL (@Lc_CollectionCur_Tanf_CODE, '') + ', TaxJoint_CODE = ' + ISNULL (@Lc_CollectionCur_TaxJoint_CODE, '') + ', TaxJoint_NAME = ' + ISNULL (RTRIM(@Lc_CollectionCur_TaxJointName_TEXT), '') + ', ReferenceIrs_IDNO = ' + ISNULL (RTRIM(@Lc_CollectionCur_ReferenceIrsIdno_TEXT), '') + ', InjuredSpouse_INDC = ' + ISNULL (@Lc_CollectionCur_InjuredSpouse_INDC, '') + ', Payor_NAME = ' + ISNULL (RTRIM(@Ls_CollectionCur_PayorName_TEXT), '') + ', PayorLine1_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorLine1Addr_TEXT), '') + ', PayorCity_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorCityAddr_TEXT), '') + ', PayorState_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorStateAddr_TEXT), '') + ', PayorZip_ADDR = ' + ISNULL (RTRIM(@Lc_CollectionCur_PayorZipAddr_TEXT), '') + ', SuspendPayment_CODE = ' + ISNULL (@Lc_CollectionCur_SuspendPayment_CODE, '')  + ', Check_NUMB = ' + ISNULL (@Lc_CollectionCur_CheckNo_TEXT, '') + ', PymtInstr1_TEXT = ' + ISNULL (RTRIM(@Ls_CollectionCur_PymtInstr1_TEXT), '') + ', PymtInstr2_TEXT = ' + ISNULL (RTRIM(@Ls_CollectionCur_PymtInstr2_TEXT), '') + ', PymtInstr3_TEXT = ' + ISNULL (RTRIM(@Ls_CollectionCur_PymtInstr3_TEXT), '') + ', Process_CODE = ' + ISNULL (@Lc_CollectionCur_Process_CODE, '') + ', SourceLoad_CODE = ' + ISNULL (@Lc_CollectionCur_SourceLoad_CODE, '');
	 
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
        
	 -- If receipt source not found in HIMS_Y1 table then write error message ‘E1062 – Receipt source not found in HIMS_Y1 table’ 
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
         -- Receipt source not found in HIMS_Y1 table
         SET @Lc_BateError_CODE = @Lc_ErrorE1062_CODE;
         RAISERROR (50001,16,1);
        END

      END
      
     END TRY
     BEGIN CATCH

		IF XACT_STATE() = -1
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
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorE_CODE + ', Line_NUMB = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR),'') + ', Error_CODE = ' + @Lc_BateError_CODE + ', As_DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
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
       
	END CATCH
	
     SET @Ls_Sql_TEXT = 'FETCH CollectionCur - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Collection_CUR INTO @Ln_CollectionCur_Seq_IDNO, @Lc_CollectionCur_BatchDate_TEXT, @Lc_CollectionCur_BatchNumb_TEXT, @Lc_CollectionCur_BatchSeqNumb_TEXT, @Lc_CollectionCur_BatchItemNumb_TEXT, @Lc_CollectionCur_SourceBatch_CODE, @Lc_CollectionCur_SourceReceipt_CODE, @Lc_CollectionCur_TypeRemittance_CODE, @Lc_CollectionCur_RapidIdno_TEXT, @Lc_CollectionCur_RapidEnvelopeNumb_TEXT, @Lc_CollectionCur_RapidReceiptNumb_TEXT, @Lc_CollectionCur_PayorMCIIdno_TEXT, @Lc_CollectionCur_MemberSsnNumb_TEXT, @Lc_CollectionCur_ReceiptAmnt_TEXT, @Lc_CollectionCur_FeeAmnt_TEXT, @Lc_CollectionCur_ReceiptDate_TEXT, @Ls_CollectionCur_PaidByName_TEXT, @Lc_CollectionCur_PaidById_TEXT, @Lc_CollectionCur_PaymentSourceSdu_CODE, @Lc_CollectionCur_Tanf_CODE, @Lc_CollectionCur_TaxJoint_CODE, @Lc_CollectionCur_TaxJointName_TEXT, @Lc_CollectionCur_ReferenceIrsIdno_TEXT, @Lc_CollectionCur_InjuredSpouse_INDC, @Ls_CollectionCur_PayorName_TEXT, @Lc_CollectionCur_PayorLine1Addr_TEXT, @Lc_CollectionCur_PayorCityAddr_TEXT, @Lc_CollectionCur_PayorStateAddr_TEXT, @Lc_CollectionCur_PayorZipAddr_TEXT, @Lc_CollectionCur_SuspendPayment_CODE, @Lc_CollectionCur_CheckNo_Text, @Ls_CollectionCur_PymtInstr1_TEXT, @Ls_CollectionCur_PymtInstr2_TEXT, @Ls_CollectionCur_PymtInstr3_TEXT, @Lc_CollectionCur_Process_CODE, @Lc_CollectionCur_SourceLoad_CODE, @Lc_CollectionCur_BatchOrigDate_TEXT, @Lc_CollectionCur_BatchOrigNumb_TEXT, @Lc_CollectionCur_OrigBatchSeqNumb_TEXT, @Lc_CollectionCur_BatchItemOrigNumb_TEXT, @Lc_CollectionCur_SourceReceiptOrig_CODE, @Lc_CollectionCur_TypeRemittanceOrig_CODE, @Lc_CollectionCur_MemberSsnOrigNumb_TEXT, @Lc_CollectionCur_Offset_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END -- Collection LOOP END

   CLOSE Collection_CUR;

   DEALLOCATE Collection_CUR;

	 SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
	 SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
	 IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
	  BEGIN
	   SET @Ls_ErrorMessage_TEXT = @Ls_Errdesc01_TEXT + '. ' + @Ls_DescriptionError_TEXT;
	   RAISERROR (50001,16,1);
	  END

   SET @Ls_Sql_TEXT = 'NO RECORD(S) IN CURSOR FOR PROCESS';
   SET @Ls_Sqldata_TEXT = 'Ln_CursorRecordCount_QNTY = ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '0');
   IF @Ln_CursorRecordCount_QNTY = 0
    BEGIN
     -- 'NO RECORD(S) FOR PROCESS'
     SET @Ls_ErrorMessage_TEXT = @Ls_Errdesc02_TEXT;

     RAISERROR (50001,16,1);
    END
	-- Collection SDU File validation -- End --    
    
   -- Data Extraction to a File
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';

   SELECT @Ln_Recon_QNTY = COUNT(1),
          @Ln_Recon_AMNT = ISNULL(SUM(CAST(a.Receipt_AMNT AS NUMERIC (11, 2))), 0)
     FROM LCSDU_Y1 a
    WHERE a.Process_INDC = @Lc_No_INDC
      AND a.FileLoad_DATE = @Ld_Run_DATE
      AND SourceReceipt_CODE <> @Lc_SourceReceiptFF_CODE;

   SET @Lc_Recon_TEXT = CONVERT(VARCHAR, @Ld_Run_DATE, 112) + RIGHT(('000000000000000' + CAST(@Ln_Recon_QNTY AS VARCHAR)), 15) + RIGHT('000000000000000' + CAST(@Ln_Recon_AMNT AS VARCHAR(15)), 15);
   SET @Ls_Query_TEXT = 'SELECT ' + @Lc_Recon_TEXT;
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT + '';

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Update the run date information
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   -- Procedure execution status check
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ln_ProcessedRecordCount_QNTY = 1;

   --Log the batch execution information
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

  END TRY

  BEGIN CATCH

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN   
		SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
	END

   --Check for Exception information to log the description text based on the error
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
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
