/****** Object:  StoredProcedure [dbo].[BATCH_FIN_CLEARED_CHECKS$SP_PROCESS_CLEARED_CHECKS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_CLEARED_CHECKS$SP_PROCESS_CLEARED_CHECKS
Programmer Name 	: IMP Team
Description			: The process reads the cleared check information from the temporary table and updates the check 
					  status and status date in Disbursement View (DSBV) screen / Log Disbursement Header (DSBH_Y1) table. 
Frequency			: 'DAILY'
Developed On		: 06/11/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_CLEARED_CHECKS$SP_PROCESS_CLEARED_CHECKS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_CheckCashed1800_NUMB          INT = 1800,
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_TypeErrorE_CODE               CHAR(1) = 'E',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_MediumDisburseCheck_CODE      CHAR(1) = 'C',
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',          
          @Lc_RecordTypePaidP_CODE          CHAR(1) = 'P',
          @Lc_RecordTypeVoidV_CODE          CHAR(1) = 'V',
          @Lc_RecordTypeStopsS_CODE         CHAR(1) = 'S',
          @Lc_Yes_INDC                      CHAR(1) = 'Y',
		  @Lc_TypeErrorWarning_CODE			CHAR(1) = 'W',          
          @Lc_StatusCheckVoidNoReissue_CODE CHAR(2) = 'VN',
          @Lc_StatusCheckVoidReissue_CODE   CHAR(2) = 'VR',
          @Lc_StatusCheckOutstanding_CODE   CHAR(2) = 'OU',
          @Lc_StatusCheckStopNoReissue_CODE CHAR(2) = 'SN',
          @Lc_StatusCheckStopReissue_CODE   CHAR(2) = 'SR',
          @Lc_StatusCheckCashed_CODE        CHAR(2) = 'CA',
          @Lc_ErrorE0085_CODE				CHAR(5) = 'E0085',
          @Lc_ErrorE1424_CODE				CHAR(5) = 'E1424',
          @Lc_CheckNotVoidE0967_CODE        CHAR(5) = 'E0967',
          @Lc_CheckNotOutstandingE0966_CODE CHAR(5) = 'E0966',
          @Lc_CheckNotStopedE0968_CODE      CHAR(5) = 'E0968',
          @Lc_AmountNotMatchE0965_CODE      CHAR(5) = 'E0965',
          @Lc_CheckNumbNotFoundE0963_CODE   CHAR(5) = 'E0963',
		  @Lc_ErrorNoRecordsE0944_CODE		CHAR(5) = 'E0944',          
          @Lc_Job_ID                        CHAR(7) = 'DEB0430',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT             CHAR(30) = 'BATCH',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_FIN_CLEARED_CHECKS',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_PROCESS_CLEARED_CHECKS',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Start_DATE                   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_FetchStatus_QNTY            NUMERIC(1),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
		  @Ln_DisburseSeq_NUMB            NUMERIC(5),          
          @Ln_ProcessedRecordCount_QNTY	  NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_CursorRecordCount_QNTY      NUMERIC(11) = 0,
          @Ln_Disburse_AMNT               NUMERIC(11, 2),
          @Ln_RowCount_QNTY               NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19),
          @Lc_TypeError_CODE              CHAR(1),
		  @Lc_CheckRecipient_CODE		  CHAR(1),          
          @Lc_StatusCheck_CODE            CHAR(2),
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Lc_BateError_CODE              CHAR(5),
		  @Lc_CheckRecipient_ID			  CHAR(10),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
		  @Ld_Disburse_DATE               DATE,
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE;
          
  DECLARE @Ln_CclrCur_Seq_IDNO           NUMERIC(19),
          @Lc_CclrCur_AccountBankNo_TEXT CHAR(10),
          @Lc_CclrCur_RecID_TEXT         CHAR(1),
          @Lc_CclrCur_PaidCheckDate_TEXT CHAR(8),
          @Lc_CclrCur_CheckNumb_TEXT     CHAR(10),
          @Lc_CclrCur_CheckAmount_TEXT   CHAR(12),
          @Ld_CclrCur_FileLoad_DATE      DATE,
          @Ln_CclrCur_Check_NUMB         NUMERIC(10),
          @Ln_CclrCur_Check_AMNT         NUMERIC(11, 2),
          @Ld_CclrCur_PaidCheck_DATE     DATE;
                    
  DECLARE Cclr_CUR INSENSITIVE CURSOR FOR
   SELECT c.Seq_IDNO,
          c.AccountBankNo_TEXT,
          c.Rec_ID,
          c.PaidCheck_DATE,
          c.CheckSerial_NUMB,
          c.Check_AMNT,
          c.FileLoad_DATE
     FROM LCCLE_Y1 c
    WHERE c.Process_INDC = 'N'
    ORDER BY c.CheckSerial_NUMB;

  BEGIN TRY
   BEGIN TRANSACTION ClrChkTran;

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

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN Cclr_CUR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN Cclr_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Cclr_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM Cclr_CUR INTO @Ln_CclrCur_Seq_IDNO, @Lc_CclrCur_AccountBankNo_TEXT, @Lc_CclrCur_RecID_TEXT, @Lc_CclrCur_PaidCheckDate_TEXT, @Lc_CclrCur_CheckNumb_TEXT, @Lc_CclrCur_CheckAmount_TEXT, @Ld_CclrCur_FileLoad_DATE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE - 1';
   SET @Ls_Sqldata_TEXT = '';
   /* 
   This Process reads the cleared check information from the temporary table LCCLE_Y1 and updates the check status on the disbursement (DSBH_Y1) table 
   to the Status of CA - Cashed. The Void and Stopped payments in the file are matched with data in the system and mismatch checks are reported as errors.
   The status date on the disbursement record will be updated with the date on the bank reconciliation file.
    */
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 1';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

	  SAVE TRANSACTION SaveClrChkTran;
	 
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CclrCur_Seq_IDNO AS VARCHAR), '') + ', AccountBankNo_TEXT = ' + @Lc_CclrCur_AccountBankNo_TEXT + ', RecID_TEXT = ' + @Lc_CclrCur_RecID_TEXT + ', PaidCheck_DATE = ' + @Lc_CclrCur_PaidCheckDate_TEXT + ', CheckSerial_NUMB = ' + @Lc_CclrCur_CheckNumb_TEXT + ', Check_AMNT = ' + @Lc_CclrCur_CheckAmount_TEXT + ', FileLoad_DATE = ' + CAST(@Ld_CclrCur_FileLoad_DATE AS VARCHAR);
      SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      -- UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ls_CursorLocation_TEXT = 'CHECK CLEARANCE - CURSOR COUNT = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '');
      
      SET @Ls_Sql_TEXT = 'Check Amount Conversion';
      SET @Ls_Sqldata_TEXT = 'Check_AMNT = ' + @Lc_CclrCur_CheckAmount_TEXT;

	  IF ISNUMERIC(LTRIM(RTRIM(@Lc_CclrCur_CheckAmount_TEXT))) = 1
	   BEGIN 
		SET @Ln_CclrCur_Check_AMNT = CAST(@Lc_CclrCur_CheckAmount_TEXT AS NUMERIC(13)) / 100;
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END	
	   
      SET @Ls_Sql_TEXT = 'Check Date Conversion';
      SET @Ls_Sqldata_TEXT = 'PaidCheck_DATE = ' + @Lc_CclrCur_PaidCheckDate_TEXT;

      IF ISDATE(LTRIM(RTRIM(RIGHT(@Lc_CclrCur_PaidCheckDate_TEXT, 4) + LEFT(@Lc_CclrCur_PaidCheckDate_TEXT, 4)))) = 1
	   BEGIN 
		SET @Ld_CclrCur_PaidCheck_DATE = CONVERT(DATE, RIGHT(@Lc_CclrCur_PaidCheckDate_TEXT, 4) + LEFT(@Lc_CclrCur_PaidCheckDate_TEXT, 4), 112);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END	

      SET @Ls_Sql_TEXT = 'Check Number Conversion';
      SET @Ls_Sqldata_TEXT = 'Check_NUMB = ' + @Lc_CclrCur_CheckNumb_TEXT;
      
	  IF ISNUMERIC(LTRIM(RTRIM(@Lc_CclrCur_CheckNumb_TEXT))) = 1
	   BEGIN 
		SET @Ln_CclrCur_Check_NUMB = CAST(@Lc_CclrCur_CheckNumb_TEXT AS NUMERIC(10));
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END	

	  /* 
	  Read the cleared checks from the temporary table LCCLE_Y1 and fetch all check disbursement records from Disbursement View (DSBV) screen / 
	  Log Disbursement Header (DSBH_Y1) table for the check numbers from the input file.
	  If no record exists in the DSBH_Y1 table for the given check number, insert into Batch Status Log (BSTL) Screen/ BATE_Y1 table with the 
	  message â€˜E0963 - Check number not in the systemâ€™.
	  */
      SET @Ls_Sql_TEXT = 'SELECT DSBH_Y1 - 1';
	  SET @Ls_SqlData_TEXT = 'MediumDisburse_CODE = ' + ISNULL(@Lc_MediumDisburseCheck_CODE,'')+ ', Check_NUMB = ' + ISNULL(CAST( @Ln_CclrCur_Check_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      SELECT @Ln_Disburse_AMNT = a.Disburse_AMNT,
             @Lc_StatusCheck_CODE = StatusCheck_CODE,
             @Lc_CheckRecipient_ID = CheckRecipient_ID,
             @Lc_CheckRecipient_CODE = CheckRecipient_CODE,
             @Ld_Disburse_DATE = Disburse_DATE,
             @Ln_DisburseSeq_NUMB = DisburseSeq_NUMB
        FROM DSBH_Y1 a
       WHERE MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
         AND Check_NUMB = @Ln_CclrCur_Check_NUMB
         AND EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY= @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'CHECK NUMBER NOT IN THE SYSTEM';
        SET @Lc_BateError_CODE = @Lc_CheckNumbNotFoundE0963_CODE;

        RAISERROR (50001,16,1);
       END

	  /*
		If the check amount on the Disbursement record does not match the check amount on the input file, insert into Batch Status Log (BSTL) Screen/ 
		BATE_Y1 table with the reason â€˜E0965 - Amount on the check does not matchâ€™.
	  */
      SET @Ls_Sql_TEXT = 'CHECK AMOUNT VALIDATION ';
      SET @Ls_SqlData_TEXT = 'Disburse_AMNT = ' + CAST(@Ln_Disburse_AMNT AS VARCHAR) + ', Check_AMNT = ' + CAST(@Ln_CclrCur_Check_AMNT AS VARCHAR);

      IF @Ln_Disburse_AMNT <> @Ln_CclrCur_Check_AMNT
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'AMOUNT ON THE CHECK DOES NOT MATCH';
        SET @Lc_BateError_CODE = @Lc_AmountNotMatchE0965_CODE;

        RAISERROR (50001,16,1);
       END

	  /* 
	  If the check status is not â€˜Outstandingâ€™ on Disbursement header record for the cleared checks in the temporary table, 
	  Insert into Batch Status Log (BSTL) Screen/ BATE_Y1 table with the reason â€˜E0966 - Check is not in Outstanding status: 
	  Current status = <Current Check status>â€™.
	  */
      SET @Ls_Sql_TEXT = 'CHECK OUTSTANDING STATUS VALIDATION';
      SET @Ls_SqlData_TEXT = 'StatusCheck_CODE = ' + @Lc_StatusCheck_CODE + ', RecID_TEXT = ' + @Lc_CclrCur_RecID_TEXT;
	  
	  -- Paid/Reconciled Check
      IF @Lc_StatusCheck_CODE <> @Lc_StatusCheckOutstanding_CODE
         AND @Lc_CclrCur_RecID_TEXT = @Lc_RecordTypePaidP_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'CHECK IS NOT IN OUTSTANDING STATUS';
        SET @Lc_BateError_CODE = @Lc_CheckNotOutstandingE0966_CODE;

        RAISERROR (50001,16,1);
       END

	 /*
	 If the check status is not â€˜Void No-Reissueâ€™ or â€˜Void Re-issueâ€™ on Disbursement header record for the Voided checks in the temporary table, 
	 insert into Batch Status Log (BSTL) Screen/ BATE_Y1 table with the reason â€˜E0967 - Check is not in Voided status: 
	 Current status = <Current Check status>â€™.
	 */
      SET @Ls_Sql_TEXT = 'CHECK VOID STATUS VALIDATION';
      SET @Ls_SqlData_TEXT = 'StatusCheck_CODE = ' + @Lc_StatusCheck_CODE + ', RecID_TEXT = ' + @Lc_CclrCur_RecID_TEXT;
	  
	  -- Voids
      IF @Lc_StatusCheck_CODE <> @Lc_StatusCheckVoidNoReissue_CODE
         AND @Lc_StatusCheck_CODE <> @Lc_StatusCheckVoidReissue_CODE
         AND @Lc_CclrCur_RecID_TEXT = @Lc_RecordTypeVoidV_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'CHECK IS NOT IN VOIDED STATUS';
        SET @Lc_BateError_CODE = @Lc_CheckNotVoidE0967_CODE;

        RAISERROR (50001,16,1);
       END
	
	  /*
		If the check status is not â€˜Stop No reissueâ€™/ â€˜Stop Reissueâ€™ on Disbursement header record for the Stop checks in the temporary table, 
		insert into Batch Status Log (BSTL) Screen/BATCH_ERROR (BATE) table with the reason â€˜E0968 - Check is not in Stopped status: 
		Current status = <Current Check status>â€™.
	  */	
      SET @Ls_Sql_TEXT = 'CHECK STOP STATUS VALIDATION ';
      SET @Ls_SqlData_TEXT = 'StatusCheck_CODE = ' + @Lc_StatusCheck_CODE + ', RecID_TEXT = ' + @Lc_CclrCur_RecID_TEXT;
	
	  -- Stops 	
      IF @Lc_StatusCheck_CODE <> @Lc_StatusCheckStopNoReissue_CODE
         AND @Lc_StatusCheck_CODE <> @Lc_StatusCheckStopReissue_CODE
         AND @Lc_CclrCur_RecID_TEXT = @Lc_RecordTypeStopsS_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'CHECK IS NOT IN STOPPED STATUS';
        SET @Lc_BateError_CODE = @Lc_CheckNotStopedE0968_CODE;

        RAISERROR (50001,16,1);
       END
	 -- For Paid/Reconciled Checks, update check status from "OU - Outstanding" to "CA - CASHED"	 
	 IF @Lc_CclrCur_RecID_TEXT = @Lc_RecordTypePaidP_CODE
	 BEGIN 	
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
      SET @Ls_SqlData_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_CheckCashed1800_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');
      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_CheckCashed1800_NUMB,
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

      SET @Ls_Sql_TEXT = 'UPDATE DSBH_Y1 ';
	  SET @Ls_SqlData_TEXT = 'Check_NUMB = ' + ISNULL(CAST( @Ln_CclrCur_Check_NUMB AS VARCHAR ),'')+ ', MediumDisburse_CODE = ' + ISNULL(@Lc_MediumDisburseCheck_CODE,'')+ ', StatusCheck_CODE = ' + ISNULL(@Lc_StatusCheckOutstanding_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      UPDATE DSBH_Y1
         SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
             EndValidity_DATE = @Ld_Run_DATE
       WHERE Check_NUMB = @Ln_CclrCur_Check_NUMB
         AND MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
         AND StatusCheck_CODE = @Lc_StatusCheckOutstanding_CODE
         AND EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY= @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE DSBH_Y1 FAILED';

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'INSERT DSBH_Y1 ';
      SET @Ls_SqlData_TEXT = 'Check_NUMB = ' + CAST(@Ln_CclrCur_Check_NUMB AS VARCHAR) + ', MediumDisburse_CODE = ' + @Lc_MediumDisburseCheck_CODE + ', StatusCheck_CODE = ' + @Lc_StatusCheckOutstanding_CODE + ', EventGlobalEndSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + 'StatusCheck_CODE = ' + ISNULL(@Lc_StatusCheckCashed_CODE,'')+ ', StatusCheck_DATE = ' + ISNULL(CAST( @Ld_CclrCur_PaidCheck_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      INSERT DSBH_Y1
             (CheckRecipient_ID,
              CheckRecipient_CODE,
              Disburse_DATE,
              DisburseSeq_NUMB,
              MediumDisburse_CODE,
              Disburse_AMNT,
              Check_NUMB,
              StatusCheck_CODE,
              StatusCheck_DATE,
              ReasonStatus_CODE,
              EventGlobalBeginSeq_NUMB,
              EventGlobalEndSeq_NUMB,
              BeginValidity_DATE,
              EndValidity_DATE,
              Issue_DATE,
              Misc_ID)
      SELECT a.CheckRecipient_ID,
             a.CheckRecipient_CODE,
             a.Disburse_DATE,
             a.DisburseSeq_NUMB,
             a.MediumDisburse_CODE,
             a.Disburse_AMNT,
             a.Check_NUMB,
             @Lc_StatusCheckCashed_CODE AS StatusCheck_CODE,
             @Ld_CclrCur_PaidCheck_DATE AS StatusCheck_DATE,
             a.ReasonStatus_CODE,
             @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             @Ld_Run_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             a.Issue_DATE,
             a.Misc_ID
        FROM DSBH_Y1 a
       WHERE a.Check_NUMB = @Ln_CclrCur_Check_NUMB
         AND a.MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
         AND a.StatusCheck_CODE = @Lc_StatusCheckOutstanding_CODE
         AND a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
         AND a.EndValidity_DATE = @Ld_Run_DATE;

      SET @Ln_RowCount_QNTY= @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT ='UPDATE DSBH_Y1 FAILED';

        RAISERROR (50001,16,1);
       END
       -- Elog Entry -- 
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX';
      SET @Ls_SqlData_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CheckCashed1800_NUMB AS VARCHAR), '')  + ', CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + @Lc_CheckRecipient_CODE + ', Disburse_DATE = ' + ISNULL (CAST(@Ld_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL (CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', CheckNo_TEXT = ' + ISNULL (CAST(@Ln_CclrCur_Check_NUMB AS VARCHAR), '') ;

      EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
       @An_EventGlobalSeq_NUMB       = @Ln_EventGlobalSeq_NUMB,
       @An_EventFunctionalSeq_NUMB   = @Li_CheckCashed1800_NUMB,
       @An_EntityCase_IDNO           = 0,
       @Ac_EntityCheckRecipient_ID   = @Lc_CheckRecipient_ID,
       @Ac_EntityCheckRecipient_CODE = @Lc_CheckRecipient_CODE,
       @Ad_EntityDisburse_DATE       = @Ld_Disburse_DATE,       
       @An_EntityDisburseSeq_NUMB    = @Ln_DisburseSeq_NUMB,
       @Ac_EntityCheckNo_TEXT        = @Ln_CclrCur_Check_NUMB,
       @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
       -- Elog Entry -- 
       END 
     END TRY
     
     BEGIN CATCH    
     IF XACT_STATE() = 1
        BEGIN
           ROLLBACK TRANSACTION SaveClrChkTran;
        END
     ELSE
        BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
            RAISERROR( 50001 ,16,1);
        END

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

     SET @Ls_Sql_TEXT = 'INSERT DSBH_Y1 ';
     SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CclrCur_Seq_IDNO AS VARCHAR), '') + ', AccountBankNo_TEXT = ' + @Lc_CclrCur_AccountBankNo_TEXT + ', RecID_TEXT = ' + @Lc_CclrCur_RecID_TEXT + ', PaidCheck_DATE = ' + @Lc_CclrCur_PaidCheckDate_TEXT + ', CheckSerial_NUMB = ' + @Lc_CclrCur_CheckNumb_TEXT + ', Check_AMNT = ' + @Lc_CclrCur_CheckAmount_TEXT + ', FileLoad_DATE = ' + CAST(@Ld_CclrCur_FileLoad_DATE AS VARCHAR);

     UPDATE LCCLE_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Seq_IDNO = @Ln_CclrCur_Seq_IDNO;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION ClrChkTran;
	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       BEGIN TRANSACTION ClrChkTran;

       SET @Ln_CommitFreq_QNTY = 0;
      END

	 SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION ClrChkTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Cclr_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Cclr_CUR INTO @Ln_CclrCur_Seq_IDNO, @Lc_CclrCur_AccountBankNo_TEXT, @Lc_CclrCur_RecID_TEXT, @Lc_CclrCur_PaidCheckDate_TEXT, @Lc_CclrCur_CheckNumb_TEXT, @Lc_CclrCur_CheckAmount_TEXT, @Ld_CclrCur_FileLoad_DATE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Cclr_CUR;

   DEALLOCATE Cclr_CUR;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
	 SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL('0','')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorNoRecordsE0944_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_ErrorNoRecordsE0944_CODE,
      @As_DescriptionError_TEXT	   = @Lc_ErrorNoRecordsE0944_CODE,      
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION ClrChkTran;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ClrChkTran;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Cclr_CUR') IN (0, 1)
    BEGIN
     CLOSE Cclr_CUR;

     DEALLOCATE Cclr_CUR;
    END

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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
