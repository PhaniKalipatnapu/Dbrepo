/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IRS_NADJ$SP_PROCESS_IRS_NADJ]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
----------------------------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_IRS_NADJ$SP_PROCESS_IRS_NADJ
Programmer Name 	: IMP Team
Description			: This procedure processes the IRS negative adjustments by backing out (reverse) the original receipt and reposts a
    				  new receipt if there is a difference in the amount.
Frequency			: 'WEEKLY'
Developed On		: 06/08/2011
Called BY			: None
Called On			: 
----------------------------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0	
----------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IRS_NADJ$SP_PROCESS_IRS_NADJ]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ModifyingAReceiptBatch1120_NUMB INT = 1120,
          @Li_AddingAReceiptBatch1110_NUMB    INT = 1110,
          @Li_IdentifyAReceipt1410_NUMB       INT = 1410,
          @Li_ReceiptOnHold1420_NUMB          INT = 1420,
          @Lc_TypeErrorE_CODE				  CHAR(1) = 'E',
          @Lc_Space_TEXT                      CHAR(1) = ' ',
          @Lc_No_INDC                         CHAR(1) = 'N',
          @Lc_Yes_INDC                        CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',          
          @Lc_StatusReceiptUnidentified_CODE  CHAR(1) = 'U',
          @Lc_StatusReceiptHeld_CODE          CHAR(1) = 'H',
          @Lc_StatusReceiptIdentified_CODE    CHAR(1) = 'I',
          @Lc_BatchStatusReconciled_CODE      CHAR(1) = 'R',
          @Lc_TypePostingCase_CODE            CHAR(1) = 'C',
          @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
          @Lc_TaxJointJ_INDC                  CHAR(1) = 'J',
          @Lc_TaxJointI_INDC                  CHAR(1) = 'I',
          @Lc_StatusMatchM_CODE               CHAR(1) = 'M',
          @Lc_TypePrimarySsn_CODE			  CHAR(1) = 'P',
          @Lc_TypeItinI_CODE				  CHAR(1) = 'I',
          @Lc_TypeSecondarySsn_CODE			  CHAR(1) = 'S', 
          @Lc_TypeTertiarySsn_CODE			  CHAR(1) = 'T',
          @Lc_VerificationStatusGood_CODE	  CHAR(1) = 'Y', 
          @Lc_VerificationStatusPending_CODE  CHAR(1) = 'P',
          @Lc_TypeErrorWarning_CODE			  CHAR(1) = 'W',
          @Lc_Null_TEXT						  CHAR(1) = NULL,          
          @Lc_ReasonBackOutNi_CODE            CHAR(2) = 'NI',
          @Lc_RemitTypeEft_CODE               CHAR(3) = 'EFT',
          @Lc_SourceBatch_CODE                CHAR(3) = 'SPC',
          @Lc_SeqBatch001_CODE                CHAR(3) = '001',
          @Lc_UnidenholdUnidentreceipts_CODE  CHAR(4) = 'UNID',
          @Lc_ErrorE0085_CODE				  CHAR(5) = 'E0085',
          @Lc_ErrorReceiptAmountLessE0954_CODE CHAR(5) = 'E0954',
          @Lc_ErrorNoRecordsE0944_CODE         CHAR(5) = 'E0944',
          @Lc_ErrorRefundReceiptI0160_CODE	   CHAR(5) = 'I0160',
          @Lc_ErrorReceiptAlreadyRevE0132_CODE CHAR(5) = 'E0132',
          @Lc_ErrorE1424_CODE                 CHAR(5) = 'E1424',
          @Lc_ErrorReceiptNotFoundE0953_CODE  CHAR(5) = 'E0953',          
          @Lc_ErrorPayorNotFound_CODE         CHAR(5) = 'E0835',
          @Lc_BatchRunUser_TEXT               CHAR(6) = 'BATCH',
          @Lc_Job_ID						  CHAR(7) = 'DEB9070',
          @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
          @Lc_Session_ID                      CHAR(30) = @@SPID,
          @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_FIN_IRS_NADJ',
          @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS_IRS_NADJ',
          @Ls_RemarksNoDataFound_TEXT         VARCHAR(160) = 'NO MATCHING MEMBER FOR SSN',
          @Ls_RemarksTooMany_TEXT             VARCHAR(160) = 'TOO MANY MATCHING MEMBER FOR SSN',
          @Ld_High_DATE                       DATE = '12/31/9999',
          @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE @Ln_Rowcount_QNTY               NUMERIC,
          @Ln_FetchStatus_QNTY            NUMERIC,
          @Ln_Nadj_NUMB                   NUMERIC(1) = 0,
          @Ln_CtControlReceipt_QNTY       NUMERIC(3),
          @Ln_CtActualReceipt_QNTY        NUMERIC(3),
          @Ln_CtControlTrans_QNTY         NUMERIC(3),
          @Ln_CtActualTrans_QNTY          NUMERIC(3),
          @Ln_Batch_NUMB                  NUMERIC(4),
          @Ln_NewBatch_NUMB               NUMERIC(4),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,          
          @Ln_Case_IDNO                   NUMERIC(6),
          @Ln_SeqReceipt_NUMB             NUMERIC(6),
          @Ln_NewSeqReceipt_IDNO          NUMERIC(6),
          @Ln_MemberMci_IDNO              NUMERIC(10),
          @Ln_CursorRecordCount_QNTY      NUMERIC(10) = 0,
          @Ln_HdrRcpt_QNTY                NUMERIC(10),
          @Ln_Rcpt_QNTY                   NUMERIC(10),
          @Ln_Count_QNTY                  NUMERIC(10),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (11) = 0,
          @Ln_HdrRcpt_AMNT                NUMERIC(11, 2),
          @Ln_TotRcpt_AMNT                NUMERIC(11, 2),
          @Ln_TotHeld_AMNT                NUMERIC(11, 2),
          @Ln_TotDist_AMNT                NUMERIC(11, 2),
          @Ln_TotRefund_AMNT              NUMERIC(11, 2),
          @Ln_Receipt_AMNT                NUMERIC(11, 2),
          @Ln_NewReceipt_AMNT             NUMERIC(11, 2),
          @Ln_Held_AMNT                   NUMERIC(11, 2),
          @Ln_Identified_AMNT             NUMERIC(11, 2),
          @Ln_ControlReceipt_AMNT         NUMERIC(13, 2),
          @Ln_ActualReceipt_AMNT          NUMERIC(13, 2),
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19),
          @Ln_EventGlobalSeq2_NUMB        NUMERIC(19),
          @Lc_TypeError_CODE              CHAR(1),
          @Lc_StatusReceipt_CODE          CHAR(1),
          @Lc_TypePosting_CODE            CHAR(1),
          @Lc_TaxJoint_CODE               CHAR(1),
          @Lc_Backout_INDC                CHAR(1),
          @Lc_ReceiptSource_CODE          CHAR(2),
          @Lc_TypeRemittance_CODE         CHAR(3),
          @Lc_HoldReason_CODE             CHAR(4),
          @Lc_BateError_CODE              CHAR(5),
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_ReceiptNo_TEXT              CHAR(30),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_DescriptionRemarks_TEXT     VARCHAR(160),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ld_Batch_DATE                  DATE,
          @Ld_Receipt_DATE                DATE,
          @Ld_Release_DATE                DATE,
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Lc_NadjCur_MemberSsnNumb_TEXT CHAR(9),
          @Lc_NadjCur_CheckNo_TEXT       CHAR(9),
          @Lc_NadjCur_PayorMCIIdno_TEXT  CHAR(10),
          @Lc_NadjCur_AdjustAmnt_TEXT    CHAR(11),
          @Lc_NadjCur_AdjustDate_TEXT    CHAR(12),
          @Lc_NadjCur_TaxJointName_TEXT  CHAR(35),
          @Ld_NadjCur_Adjust_DATE        DATE,
          @Ln_NadjCur_MemberSsn_NUMB     NUMERIC(9),
          @Ln_NadjCur_PayorMCI_IDNO      NUMERIC(10),
          @Ln_NadjCur_Adjust_AMNT        NUMERIC(11, 2),
          @Ln_NadjCur_Seq_IDNO           NUMERIC(19, 0),
          @Lc_NadjCur_Process_INDC       CHAR(1),
          @Lc_NadjCur_Tanf_CODE          CHAR(1),
          @Lc_NadjCur_TaxJoint_CODE      CHAR(1);
  -- Select the unprocessed negative adjustments from intermediate table: LNADJ_Y1 into Nadj_CUR		   
  DECLARE Nadj_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.Adjust_DATE,
          a.CheckNo_TEXT,
          a.Adjust_AMNT,
          a.PayorMCI_IDNO,
          a.Tanf_CODE,
          a.TaxJoint_CODE,
          a.TaxJoint_NAME,
          a.MemberSsn_NUMB,
          a.Process_INDC
     FROM LNADJ_Y1 a
    WHERE a.Process_INDC = @Lc_No_INDC;

  BEGIN TRY
   BEGIN TRANSACTION SpcNadjTran;

   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
      
   /*Get the run date and last run date from PARM_Y1 (Parameters table) and validate that the batch program was not 
   executed for the run date by ensuring that the run date is different from the last run date in the PARM_Y1 table.  
   Otherwise, an error message to that effect will be written into Batch Status Log (BSTL) screen/Batch Status Log (BSTL_Y1) 
   table and terminate the process*/
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   -- Check if the procedure executed properly	
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'OPEN Nadj_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Nadj_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Nadj_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Nadj_CUR INTO @Ln_NadjCur_Seq_IDNO, @Lc_NadjCur_AdjustDate_TEXT, @Lc_NadjCur_CheckNo_TEXT, @Lc_NadjCur_AdjustAmnt_TEXT, @Lc_NadjCur_PayorMCIIdno_TEXT, @Lc_NadjCur_Tanf_CODE, @Lc_NadjCur_TaxJoint_CODE, @Lc_NadjCur_TaxJointName_TEXT, @Lc_NadjCur_MemberSsnNumb_TEXT, @Lc_NadjCur_Process_INDC;

   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   --WHILE LOOP
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      
	  SAVE TRANSACTION SaveSpcNadjTran;
     
      -- UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      -- Incrementing the cursor count and the commit count for each record being processed.
      SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'Cursor_QNTY = ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '');
      SET @Lc_StatusReceipt_CODE = @Lc_Space_TEXT;
      SET @Ls_ErrorMessage_TEXT = @Lc_Space_TEXT;
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + LTRIM(RTRIM(CAST(@Ln_NadjCur_Seq_IDNO AS VARCHAR))) + ', Adjust_DATE = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_AdjustDate_TEXT)), @Lc_Space_TEXT) + ', CheckNo_TEXT = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_CheckNo_TEXT)), @Lc_Space_TEXT) + ', Adjust_AMNT = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_AdjustAmnt_TEXT)), @Lc_Space_TEXT) + ', PayorMCI_IDNO = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_PayorMCIIdno_TEXT)), @Lc_Space_TEXT) + ', Tanf_CODE = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_Tanf_CODE)), @Lc_Space_TEXT) + ', TaxJoint_CODE = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_TaxJoint_CODE)), @Lc_Space_TEXT) + ', TaxJoint_NAME = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_TaxJointName_TEXT)), @Lc_Space_TEXT) + ', MemberSsn_NUMB = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_MemberSsnNumb_TEXT)), @Lc_Space_TEXT) + ', Process_INDC = ' + ISNULL(LTRIM(RTRIM(@Lc_NadjCur_Process_INDC)), @Lc_Space_TEXT);
      
      SET @Ls_Sql_TEXT = 'MemberSsnNumb_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'MemberSsnNumb_TEXT = ' + @Lc_NadjCur_MemberSsnNumb_TEXT;

	  IF ISNUMERIC(LTRIM(RTRIM(@Lc_NadjCur_MemberSsnNumb_TEXT))) = 1
	   BEGIN 
		SET @Ln_NadjCur_MemberSsn_NUMB = CAST(@Lc_NadjCur_MemberSsnNumb_TEXT AS NUMERIC);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END	

      SET @Ls_Sql_TEXT = 'AdjustDate_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'AdjustDate_TEXT = ' + @Lc_NadjCur_AdjustDate_TEXT;
      
      IF ISDATE(LTRIM(RTRIM(SUBSTRING(@Lc_NadjCur_AdjustDate_TEXT, 5, 4) + SUBSTRING(@Lc_NadjCur_AdjustDate_TEXT, 1, 2) + SUBSTRING(@Lc_NadjCur_AdjustDate_TEXT, 3, 2)))) = 1
	   BEGIN 
		SET @Ld_NadjCur_Adjust_DATE = CONVERT(DATE, SUBSTRING(@Lc_NadjCur_AdjustDate_TEXT, 5, 4) + SUBSTRING(@Lc_NadjCur_AdjustDate_TEXT, 1, 2) + SUBSTRING(@Lc_NadjCur_AdjustDate_TEXT, 3, 2), 112);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END	

      SET @Ls_Sql_TEXT = 'PayorMCIIdno_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'PayorMCIIdno_TEXT = ' + @Lc_NadjCur_PayorMCIIdno_TEXT;
	  IF LTRIM(RTRIM((@Lc_NadjCur_PayorMCIIdno_TEXT))) <> ''	
	  BEGIN
      IF ISNUMERIC(LTRIM(RTRIM(@Lc_NadjCur_PayorMCIIdno_TEXT))) = 1
	   BEGIN 
		SET @Ln_NadjCur_PayorMCI_IDNO = CAST(@Lc_NadjCur_PayorMCIIdno_TEXT AS NUMERIC);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END
	  END

      SET @Ls_Sql_TEXT = 'AdjustAmnt_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'AdjustAmnt_TEXT = ' + @Lc_NadjCur_AdjustAmnt_TEXT;
      
      IF ISNUMERIC(LTRIM(RTRIM(@Lc_NadjCur_AdjustAmnt_TEXT))) = 1
	   BEGIN 
		SET @Ln_NadjCur_Adjust_AMNT = CAST(@Lc_NadjCur_AdjustAmnt_TEXT AS NUMERIC (11, 2));
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END

      -- If the Payor ID is empty, then fetch MCI number using SSN.
      IF LTRIM(RTRIM((@Lc_NadjCur_PayorMCIIdno_TEXT))) = ''
       BEGIN
	    SET @Ls_Sql_TEXT = 'SELECT MSSN_Y1';
	    SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST( @Ln_NadjCur_MemberSsn_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
        
        SELECT @Ln_NadjCur_PayorMCI_IDNO = m.MemberMci_IDNO
          FROM MSSN_Y1 m
         WHERE m.MemberSsn_NUMB = @Ln_NadjCur_MemberSsn_NUMB
           AND m.TypePrimary_CODE IN (@Lc_TypePrimarySsn_CODE,@Lc_TypeItinI_CODE,@Lc_TypeSecondarySsn_CODE,@Lc_TypeTertiarySsn_CODE)
		   AND m.Enumeration_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerificationStatusPending_CODE)
           AND m.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        -- Assign values if there are no records returned
        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Ls_DescriptionRemarks_TEXT = @Ls_RemarksNoDataFound_TEXT;
          SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
          SET @Ln_NadjCur_PayorMCI_IDNO = 0;
          SET @Lc_BateError_CODE = @Lc_ErrorPayorNotFound_CODE;

          RAISERROR (50001,16,1);
         END;
        ELSE
         BEGIN
          -- Assign values if there are more than 1 record for the given conditions
          IF @Ln_Rowcount_QNTY > 1
           BEGIN
            SET @Ls_DescriptionRemarks_TEXT = @Ls_RemarksTooMany_TEXT;
            SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
            SET @Ln_NadjCur_PayorMCI_IDNO = 0;
           END;
         END
       END

      --Identify the original (not a reversed payment) IRS payment using the Top Trace number and Payor ID in Receipt History (RCTH_Y1) table
      SET @Ls_Sql_TEXT = 'GET PAYOR DETAILS FROM RCTH_Y1';
	  SET @Ls_Sqldata_TEXT = 'Check_DATE = ' + ISNULL(CAST( @Ld_NadjCur_Adjust_DATE AS VARCHAR ),'')+ ', CheckNo_TEXT = ' + ISNULL(@Lc_NadjCur_CheckNo_TEXT,'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_NadjCur_PayorMCI_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
		
      SELECT @Ln_Receipt_AMNT = a.Receipt_AMNT,
             @Ln_MemberMci_IDNO = a.PayorMCI_IDNO,
             @Ln_Case_IDNO = a.Case_IDNO,
             @Lc_ReceiptSource_CODE = a.SourceReceipt_CODE,
             @Ld_Batch_DATE = a.Batch_DATE,
             @Lc_SourceBatch_CODE = a.SourceBatch_CODE,
             @Ln_Batch_NUMB = a.Batch_NUMB,
             @Ld_Receipt_DATE = a.Receipt_DATE,
             @Lc_TaxJoint_CODE = a.TaxJoint_CODE,
             @Ln_SeqReceipt_NUMB = a.SeqReceipt_NUMB,
             @Lc_Backout_INDC = a.BackOut_INDC
        FROM RCTH_Y1 a
       WHERE a.Check_DATE = @Ld_NadjCur_Adjust_DATE
         AND a.CheckNo_TEXT = @Lc_NadjCur_CheckNo_TEXT
         AND a.PayorMCI_IDNO = @Ln_NadjCur_PayorMCI_IDNO
         AND a.EndValidity_DATE = @Ld_High_DATE
         AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
         AND a.EventGlobalBeginSeq_NUMB = (SELECT MAX(b.EventGlobalBeginSeq_NUMB)
                                             FROM RCTH_Y1 b
                                            WHERE b.Batch_DATE = a.Batch_DATE
                                              AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                              AND b.Batch_NUMB = a.Batch_NUMB
                                              AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                              AND b.EndValidity_DATE = @Ld_High_DATE);

      SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

      /*If no record exists in RCTH_Y1 table for the given Top Trace number, insert into Batch Error (BSTL) Screen / Batch Error (BATE_Y1) table with the message 
      error code 'E0953 - Original IRS Receipt not in the system' and read the next record.*/
      IF (@Ln_Rowcount_QNTY = 0)
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorReceiptNotFoundE0953_CODE;
        SET @Lc_TypeError_CODE = @Lc_TypeErrorE_CODE;
        SET @Ls_ErrorMessage_TEXT = 'ORIGINAL IRS RECEIPT NOT IN THE SYSTEM';

        RAISERROR (50001,16,1);
       END;

      /*If the record exists in RCTH_Y1 table for the given Top Trace number, but the receipt is already reversed, insert into Batch Error (BSTL) Screen/Batch 
      Error (BATE_Y1) table with the message error code E0132 – Receipt has Already been Reversed and read the next record.*/
      IF(@Lc_Backout_INDC = @Lc_Yes_INDC)
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorReceiptAlreadyRevE0132_CODE;
        SET @Lc_TypeError_CODE = @Lc_TypeErrorE_CODE;
        SET @Ls_ErrorMessage_TEXT = 'RECEIPT HAS ALREADY BEEN REVERSED';

        RAISERROR (50001,16,1);
       END
      /*If the Receipt Amount in the RCTH_Y1 table is the same or greater than the Adjustment Amount from LNADJ_Y1 table, then reverse the receipt with the reason 
      code 'NI - Negative Special Collections Adjustment' and a record will be written into Receipt History (RCTH_Y1) table with Reversal Indicator set 
      and repost the difference amount for the payor*/
      IF @Ln_Receipt_AMNT >= @Ln_NadjCur_Adjust_AMNT
       BEGIN
        --Insert the receipt to be reversed into PRREP_Y1 table using the Reversal and Repost (RREP) screen routine BATCH_COMMON$SP_INSERT_TMP_RREP.
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_TMP_RREP';
		SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_ReceiptSource_CODE,'')+ ', From_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', To_DATE = ' + ISNULL(@Lc_Null_TEXT,'')+ ', Session_ID = ' + ISNULL(@Lc_Session_ID,'')+ ', MultiCase_INDC = ' + ISNULL(@Lc_Null_TEXT,'')+ ', ClosedCase_INDC = ' + ISNULL(@Lc_Null_TEXT,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ScrnFunc_NUMB = ' + ISNULL('1','')+ ', CheckNo_Text = ' + ISNULL(@Lc_NadjCur_CheckNo_TEXT,'');

        EXECUTE BATCH_COMMON$SP_INSERT_TMP_RREP
         @An_PayorMCI_IDNO         = @Ln_MemberMci_IDNO,
         @An_Case_IDNO             = @Ln_Case_IDNO,
         @Ad_Batch_DATE            = @Ld_Batch_DATE,
         @Ac_SourceBatch_CODE      = @Lc_SourceBatch_CODE,
         @An_Batch_NUMB            = @Ln_Batch_NUMB,
         @An_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB,
         @Ac_SourceReceipt_CODE    = @Lc_ReceiptSource_CODE,
         @Ad_From_DATE             = @Ld_Receipt_DATE,
         @Ad_To_DATE               = @Lc_Null_TEXT,
         @Ac_Session_ID            = @Lc_Session_ID,
         @Ac_MultiCase_INDC        = @Lc_Null_TEXT,
         @Ac_ClosedCase_INDC       = @Lc_Null_TEXT,
         @Ac_SignedOnWorker_ID     = @Lc_BatchRunUser_TEXT,
         @An_ScrnFunc_NUMB         = 1,
         @Ac_CheckNo_Text          = @Lc_NadjCur_CheckNo_TEXT,
         @An_HdrReceipt_QNTY       = @Ln_HdrRcpt_QNTY OUTPUT,
         @An_HdrReceipt_AMNT       = @Ln_HdrRcpt_AMNT OUTPUT,
         @An_Receipt_QNTY          = @Ln_Rcpt_QNTY OUTPUT,
         @An_TotReceipt_AMNT       = @Ln_TotRcpt_AMNT OUTPUT,
         @An_TotHeld_AMNT          = @Ln_TotHeld_AMNT OUTPUT,
         @An_TotDist_AMNT          = @Ln_TotDist_AMNT OUTPUT,
         @An_TotRefund_AMNT        = @Ln_TotRefund_AMNT OUTPUT,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END;

		SET @Ls_Sql_TEXT = 'SELECT PRREP_Y1 TABLE - 1';
        SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Lc_Session_ID,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC,'');
		
        SELECT @Ln_Count_QNTY = 1
          FROM PRREP_Y1 p
         WHERE p.Session_ID = @Lc_Session_ID
           AND p.Refund_INDC = @Lc_Yes_INDC;
		 
		 SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
		 IF @Ln_Rowcount_QNTY <> 0
         BEGIN
         SET @Ls_ErrorMessage_TEXT = 'RECEIPT CANNOT BE REVERSED FOR NEGATIVE ADJUSTMENT SINCE IT WAS ALREADY REFUNDED';
          SET @Lc_BateError_CODE = @Lc_ErrorRefundReceiptI0160_CODE;
          RAISERROR (50001,16,1);
		 END;

        SET @Ls_Sql_TEXT = 'SELECT PRREP_Y1 TABLE';
        SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Lc_Session_ID,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC,'');
		
		
        SELECT @Ln_Count_QNTY = 1
          FROM PRREP_Y1 p
         WHERE p.Session_ID = @Lc_Session_ID
           AND p.BackOut_INDC = @Lc_Yes_INDC;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        -- Check if there is a single PRREP record to be backed out
        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RCTH_Y1 NOT INSERTED IN PRREP_Y1';
          SET @Lc_BateError_CODE = @Lc_ErrorReceiptNotFoundE0953_CODE;
          SET @Lc_TypeError_CODE = @Lc_TypeErrorE_CODE;

          RAISERROR (50001,16,1);
         END
        ELSE
         BEGIN
          IF @Ln_Rowcount_QNTY > 1
           BEGIN
            SET @Ls_Sql_TEXT ='MULTIPLE RCTH_Y1 INSERTED IN PRREP_Y1';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
            SET @Lc_BateError_CODE = @Lc_ErrorReceiptNotFoundE0953_CODE;
            SET @Lc_TypeError_CODE = @Lc_TypeErrorE_CODE;

            RAISERROR (50001,16,1);
           END;
         END;

        --Reverse the receipt with reason code ‘NI - Negative Special Collections Adjustment’ using the RREP screen routine BATCH_COMMON$SP_BACKOUT_PROCESS_RREP.
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BACKOUT_PROCESS_RREP';
        SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Lc_Session_ID,'')+ ', Sval_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_ReasonBackOutNi_CODE,'')+ ', DateRange_TEXT = ' + ISNULL(@Lc_Null_TEXT,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Notes_TEXT = ' + ISNULL(@Lc_Null_TEXT,'')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

        EXECUTE BATCH_COMMON$SP_BACKOUT_PROCESS_RREP
         @Ac_Session_ID            = @Lc_Session_ID,
         @Ac_Sval_INDC             = @Lc_No_INDC,
         @Ac_ReasonBackOut_CODE    = @Lc_ReasonBackOutNi_CODE,
         @As_DateRange_TEXT        = @Lc_Null_TEXT,
         @Ac_Process_ID            = @Lc_Job_ID,
         @As_Notes_TEXT            = @Lc_Null_TEXT,
         @Ad_Process_DATE          = @Ld_Run_DATE,
         @Ac_SignedOnWorker_ID     = @Lc_BatchRunUser_TEXT,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END;

        SET @Lc_TypeRemittance_CODE = @Lc_Space_TEXT;

        /*If the Receipt Amount in the RCTH_Y1 table is greater than the Adjustment Amount from LNADJ_Y1 table, 
        then reverse the receipt with the reason code 'NI - Negative Special Collections Adjustment' and a record 
        will be written into Receipt History (RCTH_Y1) table with Reversal Indicator set and repost the difference 
        amount for the payor*/
        IF @Ln_Receipt_AMNT > @Ln_NadjCur_Adjust_AMNT
         BEGIN
        
          -- The remaining amount
          SET @Ln_NewReceipt_AMNT = @Ln_Receipt_AMNT - @Ln_NadjCur_Adjust_AMNT;
          --Get the maximum Batch Number for the run date and IRS source in the Receipt Batch (RBAT_Y1) table.
          SET @Ls_Sql_TEXT = 'GET MAX BATCH NUMBER FOR THE RUN DATE';
          SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

 
          SELECT @Ln_NewBatch_NUMB = b.Batch_NUMB,
                 @Ln_CtControlReceipt_QNTY = b.CtControlReceipt_QNTY,
                 @Ln_CtActualReceipt_QNTY = b.CtActualReceipt_QNTY,
                 @Ln_CtControlTrans_QNTY = b.CtControlTrans_QNTY,
                 @Ln_CtActualTrans_QNTY = b.CtActualTrans_QNTY,
                 @Ln_ControlReceipt_AMNT = b.ControlReceipt_AMNT,
                 @Ln_ActualReceipt_AMNT = b.ActualReceipt_AMNT,
                 @Ln_EventGlobalSeq2_NUMB = b.EventGlobalBeginSeq_NUMB,
                 @Lc_TypeRemittance_CODE = b.TypeRemittance_CODE
            FROM RBAT_Y1 b
           WHERE b.Batch_DATE = @Ld_Run_DATE
             AND b.SourceBatch_CODE = @Lc_SourceBatch_CODE
             AND b.Batch_NUMB = (SELECT MAX(a.Batch_NUMB)
                                   FROM RBAT_Y1 a, GLEV_Y1 g
                                  WHERE a.Batch_DATE = @Ld_Run_DATE
                                    AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
                                    AND g.EventGlobalSeq_NUMB=a.EventGlobalBeginSeq_NUMB
                                    AND g.Process_ID=@Lc_Job_ID
                                    AND a.CtActualReceipt_QNTY<999
                                    AND a.EndValidity_DATE = @Ld_High_DATE)
             AND b.EndValidity_DATE = @Ld_High_DATE;

          SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

          -- If the Batch Number is not found for the run date, insert a batch receipt in RBAT_Y1 table with Batch Number.
          IF @Ln_Rowcount_QNTY = 0
           BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_NUMB_SEQ_CBAT -1';
           SET @Ls_Sqldata_TEXT ='';
           EXECUTE BATCH_COMMON$SP_GET_BATCH_NUMB_SEQ_CBAT
			@An_Batch_NUMB=@Ln_NewBatch_NUMB OUTPUT,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				RAISERROR(50001,16,1);
			END
             
             IF @Ln_NewBatch_NUMB =0
             BEGIN
				SET @Ls_ErrorMessage_TEXT='INVALID Batch_NUMB. @Ln_NewBatch_NUMB = 0';
				 RAISERROR (50001,16,1);
             END;
              SET @Ln_CtControlReceipt_QNTY = 1;
              SET @Ln_CtControlTrans_QNTY = 1;
              SET @Ln_CtActualReceipt_QNTY = 1;
              SET @Ln_CtActualTrans_QNTY = 1;
              SET @Ln_ControlReceipt_AMNT = @Ln_NewReceipt_AMNT;
              SET @Ln_ActualReceipt_AMNT = @Ln_NewReceipt_AMNT;
              SET @Lc_TypeRemittance_CODE = @Lc_Space_TEXT;
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1110 - INSERT RCTH_Y1 BATCH';
              SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_AddingAReceiptBatch1110_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

              EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
               @An_EventFunctionalSeq_NUMB = @Li_AddingAReceiptBatch1110_NUMB,
               @Ac_Process_ID              = @Lc_Job_ID,
               @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
               @Ac_Note_INDC               = @Lc_No_INDC,
               @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
               @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
               @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

              -- Check if the procedure returns Fail code
              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END;

            SET @Ls_Sql_TEXT = 'INSERT INTO RBAT_Y1 1 TABLE';
            SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_NewBatch_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_ReceiptSource_CODE,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_TypeRemittance_CODE,'')+ ', CtControlReceipt_QNTY = ' + ISNULL(CAST( @Ln_CtControlReceipt_QNTY AS VARCHAR ),'')+ ', CtActualReceipt_QNTY = ' + ISNULL(CAST( @Ln_CtActualReceipt_QNTY AS VARCHAR ),'')+ ', CtControlTrans_QNTY = ' + ISNULL(CAST( @Ln_CtControlTrans_QNTY AS VARCHAR ),'')+ ', CtActualTrans_QNTY = ' + ISNULL(CAST( @Ln_CtActualTrans_QNTY AS VARCHAR ),'')+ ', ControlReceipt_AMNT = ' + ISNULL(CAST( @Ln_ControlReceipt_AMNT AS VARCHAR ),'')+ ', ActualReceipt_AMNT = ' + ISNULL(CAST( @Ln_ActualReceipt_AMNT AS VARCHAR ),'')+ ', StatusBatch_CODE = ' + ISNULL(@Lc_BatchStatusReconciled_CODE,'')+ ', RePost_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','');

            INSERT RBAT_Y1
                   (Batch_DATE,
                    Batch_NUMB,
                    SourceBatch_CODE,
                    SourceReceipt_CODE,
                    Receipt_DATE,
                    TypeRemittance_CODE,
                    CtControlReceipt_QNTY,
                    CtActualReceipt_QNTY,
                    CtControlTrans_QNTY,
                    CtActualTrans_QNTY,
                    ControlReceipt_AMNT,
                    ActualReceipt_AMNT,
                    StatusBatch_CODE,
                    RePost_INDC,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    EventGlobalBeginSeq_NUMB,
                    EventGlobalEndSeq_NUMB)
            VALUES ( @Ld_Run_DATE,--Batch_DATE
                     @Ln_NewBatch_NUMB,--Batch_NUMB
                     @Lc_SourceBatch_CODE,--SourceBatch_CODE
                     @Lc_ReceiptSource_CODE,--SourceReceipt_CODE
                     @Ld_Run_DATE,--Receipt_DATE
                     @Lc_TypeRemittance_CODE,--TypeRemittance_CODE
                     @Ln_CtControlReceipt_QNTY,--CtControlReceipt_QNTY
                     @Ln_CtActualReceipt_QNTY,--CtActualReceipt_QNTY
                     @Ln_CtControlTrans_QNTY,--CtControlTrans_QNTY
                     @Ln_CtActualTrans_QNTY,--CtActualTrans_QNTY
                     @Ln_ControlReceipt_AMNT,--ControlReceipt_AMNT
                     @Ln_ActualReceipt_AMNT,--ActualReceipt_AMNT
                     @Lc_BatchStatusReconciled_CODE,-- StatusBatch_CODE
                     @Lc_Yes_INDC,-- RePost_INDC
                     @Ld_Run_DATE,-- BeginValidity_DATE
                     @Ld_High_DATE,-- EndValidity_DATE
                     @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                     0-- EventGlobalEndSeq_NUMB
					);

            SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

            -- Check if the insert is done successfully
            IF @Ln_Rowcount_QNTY = 0
             BEGIN

              SET @Ls_ErrorMessage_TEXT = 'INSERT RBAT_Y1 1 FAILED';

              RAISERROR (50001,16,1);
             END
           END
          ELSE
           BEGIN
            --otherwise update the receipt counts and receipt amounts in the RBAT_Y1 table. Each RBAT_Y1 record can contain up to 999 receipts.						
            SET @Ln_CtControlReceipt_QNTY = @Ln_CtControlReceipt_QNTY + 1;
            SET @Ln_ControlReceipt_AMNT = @Ln_ControlReceipt_AMNT + @Ln_NewReceipt_AMNT;
            SET @Ln_CtControlTrans_QNTY = @Ln_CtControlTrans_QNTY + 1;
            SET @Ln_CtActualReceipt_QNTY = @Ln_CtActualReceipt_QNTY + 1;
            SET @Ln_ActualReceipt_AMNT = @Ln_ActualReceipt_AMNT + @Ln_NewReceipt_AMNT;
            SET @Ln_CtActualTrans_QNTY = @Ln_CtActualTrans_QNTY + 1;
            SET @Ls_Sql_TEXT = 'UPDATE RBAT_Y1 1 TABLE';
            SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_NewBatch_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq2_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

            UPDATE RBAT_Y1
               SET CtControlReceipt_QNTY = @Ln_CtControlReceipt_QNTY,
                   CtActualReceipt_QNTY = @Ln_CtActualReceipt_QNTY,
                   ControlReceipt_AMNT = @Ln_ControlReceipt_AMNT,
                   ActualReceipt_AMNT = @Ln_ActualReceipt_AMNT,
                   CtControlTrans_QNTY = @Ln_CtControlTrans_QNTY,
                   CtActualTrans_QNTY = @Ln_CtActualTrans_QNTY,
                   StatusBatch_CODE = @Lc_BatchStatusReconciled_CODE
             WHERE Batch_DATE = @Ld_Run_DATE
               AND SourceBatch_CODE = @Lc_SourceBatch_CODE
               AND Batch_NUMB = @Ln_NewBatch_NUMB
               AND EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq2_NUMB
               AND EndValidity_DATE = @Ld_High_DATE;

            SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

            IF @Ln_Rowcount_QNTY = 0
             BEGIN
   
              SET @Ls_ErrorMessage_TEXT = 'UPDATE INTO RBAT_Y1 1 FAILED';

              RAISERROR (50001,16,1);
             END
           END

          -- Get the maximum Receipt Sequence for the Batch Number and IRS source in the Receipt History (RCTH_Y1) table.
          SET @Ls_Sql_TEXT = 'GET NEW Seq_IDNO NUMBER';
          SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_NewBatch_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

          SELECT TOP 1 @Ln_NewSeqReceipt_IDNO = a.SeqReceipt_NUMB
            FROM RCTH_Y1 a
           WHERE a.Batch_DATE = @Ld_Run_DATE
             AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
             AND a.Batch_NUMB = @Ln_NewBatch_NUMB
             AND a.EndValidity_DATE = @Ld_High_DATE
             AND a.SeqReceipt_NUMB = (SELECT MAX(b.SeqReceipt_NUMB)
                                        FROM RCTH_Y1 b
                                       WHERE b.Batch_DATE = a.Batch_DATE
                                         AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                         AND b.Batch_NUMB = a.Batch_NUMB
                                         AND b.EndValidity_DATE = @Ld_High_DATE);

          SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

          IF @Ln_Rowcount_QNTY = 0
           BEGIN
            SET @Ln_NewSeqReceipt_IDNO = CAST(@Lc_SeqBatch001_CODE + @Lc_SeqBatch001_CODE AS NUMERIC);
           END
          ELSE
           BEGIN
            SET @Ln_NewSeqReceipt_IDNO = CAST(ISNULL(RIGHT(REPLICATE('0', 3) + CAST(SUBSTRING(CAST(@Ln_NewSeqReceipt_IDNO AS VARCHAR), 1, (LEN(CAST(@Ln_NewSeqReceipt_IDNO AS VARCHAR)) - 3)) + 1 AS VARCHAR), 3), @Lc_Space_TEXT) + @Lc_SeqBatch001_CODE AS NUMERIC);
           END;

          --Get the posting type for the IRS source in the HIMS_Y1 table
          SET @Ls_Sql_TEXT = 'SELECT HIMS_Y1 TABLE';
          SET @Ls_Sqldata_TEXT = 'SourceReceipt_CODE = ' + @Lc_ReceiptSource_CODE + ' ,EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), @Lc_Space_TEXT);

          SELECT @Lc_TypePosting_CODE = h.TypePosting_CODE
            FROM HIMS_Y1 h
           WHERE h.SourceReceipt_CODE = @Lc_ReceiptSource_CODE
             AND h.EndValidity_DATE = @Ld_High_DATE;

          SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

          --If the record is not found then write an exception message into BSTL_Y1 table and amend the program.
          IF @Ln_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'RECORD(S) NOT FOUND IN HIMS_Y1 TABLE ' + @Ls_Sqldata_TEXT;

            RAISERROR (50001,16,1);
           END

          -- Generate sequence event functional for identified receipt
          IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1410 - IDENTIFY RCTH_Y1';
            SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_IdentifyAReceipt1410_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', Process_ID = ' + @Lc_Job_ID + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), @Lc_Space_TEXT) + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;

            EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
             @An_EventFunctionalSeq_NUMB = @Li_IdentifyAReceipt1410_NUMB,
             @Ac_Process_ID              = @Lc_Job_ID,
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
           END
          ELSE
           BEGIN
            --BATCH_COMMON$SP_RECEIPT_ON_HOLD procedure checks the receipt to determine if all or any part of the amount should be placed on hold.
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_RECEIPT_ON_HOLD';
            SET @Ls_Sqldata_TEXT = 'TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', CasePayorMCI_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_ReceiptSource_CODE,'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_NewReceipt_AMNT AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_TypeRemittance_CODE,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'');

            EXECUTE BATCH_COMMON$SP_RECEIPT_ON_HOLD
             @Ac_TypePosting_CODE      = @Lc_TypePosting_CODE,
             @An_CasePayorMCI_IDNO     = @Ln_MemberMci_IDNO,
             @Ac_SourceReceipt_CODE    = @Lc_ReceiptSource_CODE,
             @An_Receipt_AMNT          = @Ln_NewReceipt_AMNT,
             @Ad_Receipt_DATE          = @Ld_Receipt_DATE,
             @Ad_Run_DATE              = @Ld_Run_DATE,
             @Ac_TypeRemittance_CODE   = @Lc_TypeRemittance_CODE,
             @Ac_Process_ID            = @Lc_Job_ID,
             @An_Held_AMNT             = @Ln_Held_AMNT OUTPUT,
             @An_Identified_AMNT       = @Ln_Identified_AMNT OUTPUT,
             @Ad_Release_DATE          = @Ld_Release_DATE OUTPUT,
             @Ac_ReasonHold_CODE       = @Lc_HoldReason_CODE OUTPUT,
             @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END

            --If the receipt is on distribution hold
            IF @Ln_Held_AMNT > 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1420 - RECEIPT ON HOLD';
              SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', Process_ID = ' + @Lc_Job_ID + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), @Lc_Space_TEXT) + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;

              --Generate the global sequence event for the sequence event functional ‘RECEIPT ON HOLD’ using the procedure BATCH_COMMON$SP_GENERATE_SEQ.
              EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
               @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
               @Ac_Process_ID              = @Lc_Job_ID,
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

              --Insert all the entity events for the sequence event function into Event Sequence Matrix (ESEM_Y1) table using the routine BATCH_COMMON$SP_ENTITY_MATRIX.
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GET_RECEIPT_NO';
              SET @Ls_Sqldata_TEXT = 'SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE, @Lc_Space_TEXT) + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_NewBatch_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_NewSeqReceipt_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', Batch_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), @Lc_Space_TEXT);
              SET @Lc_ReceiptNo_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO(@Ld_Run_DATE, @Lc_SourceBatch_CODE, @Ln_NewBatch_NUMB, @Ln_NewSeqReceipt_IDNO);
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX';
              SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'')+ ', EntityCase_IDNO = ' + ISNULL('0','')+ ', EntityPayor_IDNO = ' + ISNULL(CAST( @Ln_NadjCur_PayorMCI_IDNO AS VARCHAR ),'')+ ', EntityReceipt_ID = ' + ISNULL(@Lc_ReceiptNo_TEXT,'')+ ', EntityReceipt_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

              EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
               @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB,
               @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
               @An_EntityCase_IDNO         = 0,
               @An_EntityPayor_IDNO        = @Ln_NadjCur_PayorMCI_IDNO,
               @Ac_EntityReceipt_ID        = @Lc_ReceiptNo_TEXT,
               @Ad_EntityReceipt_DATE      = @Ld_Run_DATE,
               @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END

              --Insert the record into the Receipt History (RCTH_Y1) table with the receipt status updated to H- Hold status.
              SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
             END

            -- If the receipt is identified
            IF @Ln_Identified_AMNT > 0
             BEGIN
              --Generate the global sequence event for the sequence event functional ‘IDENTIFY A RECEIPT’ using the procedure BATCH_COMMON$SP_GENERATE_SEQ.
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1410 - IDENTIFY RCTH_Y1';
              SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_IdentifyAReceipt1410_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', Process_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), @Lc_Space_TEXT) + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;

              EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
               @An_EventFunctionalSeq_NUMB = @Li_IdentifyAReceipt1410_NUMB,
               @Ac_Process_ID              = @Lc_Job_ID,
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

              --Insert the record into RCTH_Y1 table with the receipt status updated to I - Identified.
              SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
             END
           END

          -- Insert a record in the Receipt Repost (RCTR_Y1) table connecting the reverse receipt with the repost receipt. 
          SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 3';
          SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_NewBatch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_IDNO AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_ReceiptSource_CODE,'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_RemitTypeEft_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_NadjCur_PayorMCI_IDNO AS VARCHAR ),'')+ ', Refund_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', ReferenceIrs_IDNO = ' + ISNULL('0','')+ ', RefundRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', RefundRecipient_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Employer_IDNO = ' + ISNULL('0','')+ ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_NewReceipt_AMNT AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Check_DATE = ' + ISNULL(CAST( @Ld_NadjCur_Adjust_DATE AS VARCHAR ),'')+ ', CheckNo_TEXT = ' + ISNULL(@Lc_NadjCur_CheckNo_TEXT,'')+ ', Tanf_CODE = ' + ISNULL(@Lc_NadjCur_Tanf_CODE,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceipt_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', Fee_AMNT = ' + ISNULL('0','')+ ', TaxJoint_NAME = ' + ISNULL(@Lc_NadjCur_TaxJointName_TEXT,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

          INSERT RCTH_Y1
                 (Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceReceipt_CODE,
                  TypeRemittance_CODE,
                  TypePosting_CODE,
                  PayorMCI_IDNO,
                  Refund_DATE,
                  ReferenceIrs_IDNO,
                  RefundRecipient_CODE,
                  RefundRecipient_ID,
                  Case_IDNO,
                  Employer_IDNO,
                  Fips_CODE,
                  Receipt_AMNT,
                  ToDistribute_AMNT,
                  Receipt_DATE,
                  Distribute_DATE,
                  Check_DATE,
                  CheckNo_TEXT,
                  TaxJoint_CODE,
                  Tanf_CODE,
                  BackOut_INDC,
                  StatusReceipt_CODE,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  Release_DATE,
                  Fee_AMNT,
                  TaxJoint_NAME,
                  ReasonBackOut_CODE)
          VALUES (@Ld_Run_DATE,--Batch_DATE
                  @Lc_SourceBatch_CODE,--SourceBatch_CODE
                  @Ln_NewBatch_NUMB,--Batch_NUMB
                  @Ln_NewSeqReceipt_IDNO,--SeqReceipt_NUMB
                  @Lc_ReceiptSource_CODE,--SourceReceipt_CODE
                  @Lc_RemitTypeEft_CODE,--TypeRemittance_CODE
                  @Lc_TypePosting_CODE,--TypePosting_CODE
                  @Ln_NadjCur_PayorMCI_IDNO,--PayorMCI_IDNO
                  @Ld_Low_DATE,--Refund_DATE
                  0,--ReferenceIrs_IDNO			   
                  @Lc_Space_TEXT,--RefundRecipient_CODE 
                  @Lc_Space_TEXT,--RefundRecipient_ID
                  CASE @Lc_TypePosting_CODE
                   WHEN @Lc_TypePostingCase_CODE
                    THEN @Ln_Case_IDNO
                   ELSE 0
                  END,--Case_IDNO
                  0,--Employer_IDNO
                  @Lc_Space_TEXT,--Fips_CODE
                  @Ln_NewReceipt_AMNT,--Receipt_AMNT
                  CASE @Lc_StatusReceipt_CODE
                   WHEN @Lc_StatusReceiptIdentified_CODE
                    THEN @Ln_Identified_AMNT
                   WHEN @Lc_StatusReceiptHeld_CODE
                    THEN @Ln_Held_AMNT
                   ELSE @Ln_NewReceipt_AMNT
                  END,--ToDistribute_AMNT
                  @Ld_Run_DATE,--Receipt_DATE
                  @Ld_Low_DATE,--Distribute_DATE
                  @Ld_NadjCur_Adjust_DATE,--Check_DATE
                  @Lc_NadjCur_CheckNo_TEXT,--CheckNo_TEXT
                  CASE LTRIM(RTRIM((@Lc_NadjCur_TaxJoint_CODE)))
                   WHEN @Lc_Yes_INDC
                    THEN @Lc_TaxJointJ_INDC
                   ELSE @Lc_TaxJointI_INDC
                  END,--TaxJoint_CODE
                  @Lc_NadjCur_Tanf_CODE,--Tanf_CODE
                  @Lc_No_INDC,--BackOut_INDC
                  @Lc_StatusReceipt_CODE,--StatusReceipt_CODE
                  CASE @Lc_StatusReceipt_CODE
                   WHEN @Lc_StatusReceiptUnidentified_CODE
                    THEN @Lc_UnidenholdUnidentreceipts_CODE
                   ELSE @Lc_Space_TEXT
                  END,--ReasonStatus_CODE
                  @Ld_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                  0,--EventGlobalEndSeq_NUMB
                  ISNULL(@Ld_Release_DATE, @Ld_High_DATE),--Release_DATE
                  0,--Fee_AMNT
                  @Lc_NadjCur_TaxJointName_TEXT,--TaxJoint_NAME
                  @Lc_Space_TEXT--ReasonBackOut_CODE
          );

          SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

          IF @Ln_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT RCTH_Y1 3 FAILED';
            RAISERROR (50001,16,1);
           END

          -- To insert unidentified receipts into URCT table
          IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
           BEGIN
			SET @Ls_Sql_TEXT = 'INSERT URCT_Y1';
			SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_NewBatch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_IDNO AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_ReceiptSource_CODE,'')+ ', Payor_NAME = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PayorLine1_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PayorLine2_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PayorCity_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PayorState_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PayorZip_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PayorCountry_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank_NAME = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank1_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank2_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankCity_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankState_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankZip_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankCountry_ADDR = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Bank_IDNO = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BankAcct_NUMB = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CaseIdent_IDNO = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IdentifiedPayorMci_IDNO = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Identified_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', OtherParty_IDNO = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IdentificationStatus_CODE = ' + ISNULL(@Lc_StatusReceiptUnidentified_CODE,'')+ ', Employer_IDNO = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IvdAgency_IDNO = ' + ISNULL(@Lc_Space_TEXT,'')+ ', UnidentifiedMemberMci_IDNO = ' + ISNULL(@Lc_Space_TEXT,'')+ ', UnidentifiedSsn_NUMB = ' + ISNULL(CAST( @Ln_NadjCur_MemberSsn_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
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
            VALUES ( @Ld_Run_DATE,--Batch_DATE
                     @Ln_NewBatch_NUMB,--Batch_NUMB
                     @Ln_NewSeqReceipt_IDNO,--SeqReceipt_NUMB
                     @Lc_SourceBatch_CODE,--SourceBatch_CODE
                     @Lc_ReceiptSource_CODE,--SourceReceipt_CODE
                     @Lc_Space_TEXT,--Payor_NAME
                     @Lc_Space_TEXT,--PayorLine1_ADDR
                     @Lc_Space_TEXT,--PayorLine2_ADDR			 
                     @Lc_Space_TEXT,--PayorCity_ADDR
                     @Lc_Space_TEXT,--PayorState_ADDR
                     @Lc_Space_TEXT,--PayorZip_ADDR
                     @Lc_Space_TEXT,--PayorCountry_ADDR
                     @Lc_Space_TEXT,--Bank_NAME							
                     @Lc_Space_TEXT,--Bank1_ADDR
                     @Lc_Space_TEXT,--Bank2_ADDR			 
                     @Lc_Space_TEXT,--BankCity_ADDR
                     @Lc_Space_TEXT,--BankState_ADDR
                     @Lc_Space_TEXT,--BankZip_ADDR
                     @Lc_Space_TEXT,--BankCountry_ADDR
                     @Lc_Space_TEXT,--Bank_IDNO
                     @Lc_Space_TEXT,--BankAcct_NUMB
                     ISNULL(@Ls_DescriptionRemarks_TEXT, @Lc_Space_TEXT),--Remarks_TEXT
                     @Lc_Space_TEXT,--CaseIdent_IDNO						
                     @Lc_Space_TEXT,--IdentifiedPayorMci_IDNO
                     @Ld_Low_DATE,--Identified_DATE
                     @Lc_Space_TEXT,--OtherParty_IDNO
                     @Lc_StatusReceiptUnidentified_CODE,--IdentificationStatus_CODE
                     @Lc_Space_TEXT,--Employer_IDNO
                     @Lc_Space_TEXT,--IvdAgency_IDNO
                     @Lc_Space_TEXT,--UnidentifiedMemberMci_IDNO
                     @Ln_NadjCur_MemberSsn_NUMB,--UnidentifiedSsn_NUMB
                     @Ld_Run_DATE,--BeginValidity_DATE
                     @Ld_High_DATE,--EndValidity_DATE
                     @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                     0,--EventGlobalEndSeq_NUMB
                     @Lc_Space_TEXT,--StatusEscheat_CODE
                     @Ld_High_DATE--StatusEscheat_DATE
            );

            SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

            IF @Ln_Rowcount_QNTY = 0
             BEGIN
              SET @Ls_ErrorMessage_TEXT = 'INSERT INTO URCT_Y1 FAILED';

              RAISERROR (50001,16,1);
             END
           END
          ELSE
           BEGIN
            --Inserting record into RCTR_Y1 table to link old receipt with new receipt.
            SET @Ls_Sql_TEXT = 'INSERT RCTR_Y1 1';
            SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_NewBatch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_IDNO AS VARCHAR ),'')+ ', BatchOrig_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', BatchOrig_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceiptOrig_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatchOrig_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', StatusMatch_CODE = ' + ISNULL(@Lc_StatusMatchM_CODE,'')+ ', RePost_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', ReasonRePost_CODE = ' + ISNULL(@Lc_ReasonBackOutNi_CODE,'')+ ', ReceiptCurrent_AMNT = ' + ISNULL(CAST( @Ln_NewReceipt_AMNT AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','');

            INSERT RCTR_Y1
                   (Batch_DATE,
                    SourceBatch_CODE,
                    Batch_NUMB,
                    SeqReceipt_NUMB,
                    BatchOrig_DATE,
                    BatchOrig_NUMB,
                    SeqReceiptOrig_NUMB,
                    SourceBatchOrig_CODE,
                    StatusMatch_CODE,
                    RePost_DATE,
                    ReasonRePost_CODE,
                    ReceiptCurrent_AMNT,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    EventGlobalBeginSeq_NUMB,
                    EventGlobalEndSeq_NUMB)
            VALUES ( @Ld_Run_DATE,--Batch_DATE
                     @Lc_SourceBatch_CODE,--SourceBatch_CODE
                     @Ln_NewBatch_NUMB,--Batch_NUMB
                     @Ln_NewSeqReceipt_IDNO,--SeqReceipt_NUMB
                     @Ld_Batch_DATE,--BatchOrig_DATE
                     @Ln_Batch_NUMB,--BatchOrig_NUMB
                     @Ln_SeqReceipt_NUMB,--SeqReceiptOrig_NUMB
                     @Lc_SourceBatch_CODE,--SourceBatchOrig_CODE
                     @Lc_StatusMatchM_CODE,--StatusMatch_CODE
                     @Ld_Run_DATE,--RePost_DATE
                     @Lc_ReasonBackOutNi_CODE,--ReasonRePost_CODE
                     @Ln_NewReceipt_AMNT,--ReceiptCurrent_AMNT
                     @Ld_Run_DATE,--BeginValidity_DATE
                     @Ld_High_DATE,--EndValidity_DATE
                     @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                     0--EventGlobalEndSeq_NUMB
            );

            SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

            IF @Ln_Rowcount_QNTY = 0
             BEGIN
              SET @Ls_ErrorMessage_TEXT = 'INSERT INTO RCTR_Y1 1 FAILED';

              RAISERROR (50001,16,1);
             END
             
           IF EXISTS (
			 SELECT 1 
			 FROM TADR_Y1 t
			 WHERE  t.Batch_DATE=@Ld_Batch_DATE
				 AND  t.SourceBatch_CODE=@Lc_SourceBatch_CODE
				 AND  t.Batch_NUMB=@Ln_Batch_NUMB
				 AND t.SeqReceipt_NUMB=@Ln_SeqReceipt_NUMB
			)
			BEGIN
			SET @Ls_Sql_TEXT = 'INSERT TADR_Y1';
			SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_NewBatch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_IDNO AS VARCHAR ),'')+ ', BatchOrig_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', BatchOrig_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceiptOrig_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatchOrig_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'');	
			INSERT TADR_Y1
			SELECT @Ld_Run_DATE AS Batch_DATE,
				   @Lc_SourceBatch_CODE AS SourceBatch_CODE,
				   @Ln_NewBatch_NUMB AS Batch_NUMB,
				   @Ln_NewSeqReceipt_IDNO AS SeqReceipt_NUMB,
				   t.MemberMci_IDNO,
				   t.Attn_ADDR,
				   t.Line1_ADDR,
				   t.Line2_ADDR,
				   t.City_ADDR,
				   t.State_ADDR,
				   t.Zip_ADDR,
				   t.Country_ADDR,
				   t.InjuredSpouse_INDC
			  FROM TADR_Y1 t
			 WHERE t.Batch_DATE = @Ld_Batch_DATE
			   AND t.SourceBatch_CODE = @Lc_SourceBatch_CODE
			   AND t.Batch_NUMB = @Ln_Batch_NUMB
			   AND t.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB;
			  		    
		   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		   IF @Ln_RowCount_QNTY = 0
			BEGIN
			 SET @Ls_ErrorMessage_TEXT = 'INSERT INTO TADR_Y1 FAILED';
			 RAISERROR(50001,16,1);
			END
			   
			END;
           END
         END
       END
      ELSE
       BEGIN
        /*If the Receipt Amount in the Receipt History (RHIS) screen / Receipt History (RCTH_Y1) table is less 
        than the Adjustment Amount from the LNADJ_Y1 table then insert it into Batch Error (BSTL) Screen / 
        Batch Error (BATE_Y1) table with the message: 'E0954 - Original IRS Receipt amount is less than the 
        adjustment amount,' and read the next record.*/
        SET @Ls_Sql_TEXT = 'RECEIPT AMOUNT LESS THAN NEGATIVE ADJUSTMENT';
		SET @Ls_Sqldata_TEXT = 'Receipt_AMNT = ' + ISNULL(CAST( @Ln_Receipt_AMNT AS VARCHAR ),'')+ ', NadjCur_Adjust_AMNT = ' + ISNULL(CAST( @Ln_NadjCur_Adjust_AMNT AS VARCHAR ),'');
        IF @Ln_Receipt_AMNT < @Ln_NadjCur_Adjust_AMNT
         BEGIN
          SET @Lc_TypeError_CODE = @Lc_TypeErrorE_CODE;
          SET @Ls_ErrorMessage_TEXT = 'RECEIPT AMOUNT LESS THAN NEGATIVE ADJUSTMENT';
          SET @Lc_BateError_CODE = @Lc_ErrorReceiptAmountLessE0954_CODE;

          RAISERROR (50001,16,1);
         END
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SaveSpcNadjTran;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
        RAISERROR( 50001 ,16,1);
       END
       
      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();
	 
      -- Process unknown errors
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
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

	  SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateError_CODE = ' + @Lc_BateError_CODE + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;
	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-Exception';
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');	  
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
	
      -- Check if the procedure ran properly
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN       
        RAISERROR (50001,16,1);
       END
       
	  IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
      
     END CATCH
     	      
     --Update the Process Indicator field to 'Y' LNADJ_Y1 table
     SET @Ls_Sql_TEXT = 'UPDATING LNADJ_Y1';
	 SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST( @Ln_NadjCur_Seq_IDNO AS VARCHAR ),'');
     UPDATE LNADJ_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Seq_IDNO = @Ln_NadjCur_Seq_IDNO;

     SET @Ln_Rowcount_QNTY =@@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATING LNADJ_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY <> 0
      BEGIN

       COMMIT TRANSACTION SpcNadjTran;
	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       BEGIN TRANSACTION SpcNadjTran;

       SET @Ln_CommitFreq_QNTY = 0;
      END    

	  --Check the ExceptionThreshold_QNTY
     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CURSOR_CNT = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), @Lc_Space_TEXT) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN   
       COMMIT TRANSACTION SpcNadjTran;   
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
		
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Nadj_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Nadj_CUR INTO @Ln_NadjCur_Seq_IDNO, @Lc_NadjCur_AdjustDate_TEXT, @Lc_NadjCur_CheckNo_TEXT, @Lc_NadjCur_AdjustAmnt_TEXT, @Lc_NadjCur_PayorMCIIdno_TEXT, @Lc_NadjCur_Tanf_CODE, @Lc_NadjCur_TaxJoint_CODE, @Lc_NadjCur_TaxJointName_TEXT, @Lc_NadjCur_MemberSsnNumb_TEXT, @Lc_NadjCur_Process_INDC;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

    END

   CLOSE Nadj_CUR;

   DEALLOCATE Nadj_CUR;
   
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;
   
   --If no record found then write error in BATE_Y1 table 'E0944 – No Record(s) to Process'
   IF(@Ln_ProcessedRecordCount_QNTY = 0)
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorNoRecordsE0944_CODE;
	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
	 SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_CursorRecordCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_BateError_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   --Update the last run date in the PARM_Y1 table with the run date, upon successful completion
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), @Lc_Space_TEXT);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   --Log the successful completion in the Batch Status Log (BSTL) screen/Batch Status Log (BSTL_Y1) table for future references	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Null_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Null_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION SpcNadjTran;
  END TRY

  BEGIN CATCH
  
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION SpcNadjTran;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Nadj_CUR') IN (0, 1)
    BEGIN
     CLOSE Nadj_CUR;

     DEALLOCATE Nadj_CUR;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

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

   --Log the Error encountered in the Batch Status Log (BSTL) screen/Batch Status Log (BSTL_Y1) table for future references
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
