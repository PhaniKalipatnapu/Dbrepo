/****** Object:  StoredProcedure [dbo].[BATCH_FIN_STALE_CHECKS$SP_PROCESS_STALE_CHECKS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_STALE_CHECKS$SP_PROCESS_STALE_CHECKS
Programmer Name 	: IMP Team
Description			: The first step in this process identifies all the check disbursements that are in outstanding
					 Status for more than 100 days, if there is an active EFT or SVC set up identified for the 
					 recipient, then Void/Reissue (VR) the disbursements with reason 'SC' - Stale Check and hold 
					 code as "R" (Release for disbursement). 
					 
					 The second step in this process identifies all the check disbursements that are in outstanding 
					 status for more than 100 days with no active EFT or SVC set up for the recipient, then 
					 Void/No Reissue (VN) them with the reason 'SC' - Stale Check and, hold status code as of "H" (Hold) 
					 and Hold Reason of 'SVSC - System Void-Stale Check'.(Note - This hold can only be released by the user 
					 if a new confirmed good address becomes available or EFT/SVC becomes Active.)
Frequency			: 'DAILY'
Developed On		: 03/11/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_STALE_CHECKS$SP_PROCESS_STALE_CHECKS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_VoidReIssue1750_NUMB    INT = 1750,
           @Li_VoidNoReIssue1720_NUMB  INT = 1720,
           @Lc_Space_TEXT              CHAR = ' ',
           @Lc_StatusFailed_CODE       CHAR = 'F',
           @Lc_StatusSuccess_CODE      CHAR = 'S',
           @Lc_StatusAbnormalend_CODE  CHAR = 'A',
           @Lc_MediumDisburseC_CODE    CHAR(1) = 'C',
           @Lc_TypeErrorE_CODE		   CHAR(1) = 'E',
           @Lc_No_INDC                 CHAR(1) = 'N',
           @Lc_StatusA_CODE            CHAR(1) = 'A',
           @Lc_ReasonStatusSC_CODE     CHAR(2) = 'SC',
           @Lc_StatusEftAC_CODE        CHAR(2) = 'AC',
           @Lc_StatusCheckOU_CODE      CHAR(2) = 'OU',
           @Lc_StatusCheckVR_CODE      CHAR(2) = 'VR',
           @Lc_StatusCheckVN_CODE      CHAR(2) = 'VN',
           @Lc_ProgStale_TEXT          CHAR(5) = 'STALE',
           @Lc_ErrorNoRecords_CODE     CHAR(5) = 'E0944',
           @Lc_BateErrorE0113_CODE     CHAR(5) = 'E0113',
           @Lc_BateErrorE0001_CODE     CHAR(5) = 'E0001',
           @Lc_ErrorE1424_CODE         CHAR(5) = 'E1424',
           @Lc_Job_ID                  CHAR(7) = 'DEB0680',
           @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT       CHAR(30) = 'BATCH',
           @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
           @Ls_Process_NAME            VARCHAR(100) = 'BATCH_FIN_STALE_CHECKS',
           @Ls_Procedure_NAME          VARCHAR(100) = 'SP_PROCESS_STALE_CHECKS',
           @Ls_Errdesc01_TEXT          VARCHAR(100) = 'NO RECORD(S) TO PROCESS',
           @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE  @Ln_EventFunctionalSeq_NUMB      NUMERIC(4),
           @Ln_CommitFreqParm_QNTY          NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
           @Ln_CommitFreq_QNTY              NUMERIC(5),
           @Ln_ExceptionThreshold_QNTY      NUMERIC(5),           
           @Ln_RowCount_QNTY                NUMERIC(5),
           @Ln_CaseESEM_IDNO                NUMERIC(6),
           @Ln_ProcessedRecordCount_QNTY    NUMERIC(6) = 0,
		   @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,           
           @Ln_CursorRecordCount_QNTY       NUMERIC(10) = 0,
           @Ln_TransactionDhld_AMNT         NUMERIC(11,2),
           @Ln_Error_NUMB                   NUMERIC(11),
           @Ln_ErrorLine_NUMB               NUMERIC(11),
           @Ln_EventGlobalSeq_NUMB          NUMERIC(19),
           @Li_FetchStatus_QNTY             SMALLINT,
           @Lc_TypeError_CODE               CHAR(1),
           @Lc_StatusCheck_CODE             CHAR(2),
           @Lc_ReasonStatus_CODE            CHAR(2),
           @Lc_Msg_CODE                     CHAR(3),
           @Lc_BateError_CODE               CHAR(5),
           @Lc_CheckRecipient_ID            CHAR(10),
           @Ls_Sql_TEXT                     VARCHAR(100),
           @Ls_CursorLocation_TEXT          VARCHAR(200),
           @Ls_SqlData_TEXT                 VARCHAR(1000),
           @Ls_DescriptionError_TEXT        VARCHAR(4000),
           @Ls_ErrorMessage_TEXT            VARCHAR(4000),
           @Ls_BateRecord_TEXT              VARCHAR(4000),
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE,
           @Ld_Run100_DATE                  DATE,
           @Ld_Start_DATE                   DATETIME2,
           @Lb_ActiveEftFound_BIT           BIT = 0,
		   @Lb_ActiveSvcFound_BIT      	    BIT = 0;

  DECLARE @Lc_DisbCur_CheckRecipient_ID        CHAR(10),
          @Lc_DisbCur_CheckRecipient_CODE      CHAR(1),
          @Ld_DisbCur_Disburse_DATE            DATE,
          @Ln_DisbCur_DisburseSeq_NUMB         NUMERIC(5),
          @Lc_DisbCur_MediumDisburse_CODE      CHAR(1),
          @Ln_DisbCur_Disburse_AMNT            NUMERIC(11, 2),
          @Ln_DisbCur_Check_NUMB               NUMERIC(9),
          @Lc_DisbCur_StatusCheck_CODE         CHAR(2),
          @Ld_DisbCur_StatusCheck_DATE         DATE,
          @Lc_DisbCur_ReasonStatus_CODE        CHAR(2),
          @Ln_DisbCur_EventGlobalBeginSeq_NUMB NUMERIC(9),
          @Ln_DisbCur_EventGlobalEndSeq_NUMB   NUMERIC(9),
          @Ld_DisbCur_BeginValidity_DATE       DATE,
          @Ld_DisbCur_EndValidity_DATE         DATE,
          @Ld_DisbCur_Issue_DATE               DATE,
          @Lc_DisbCur_Misc_ID                  CHAR(11);

  BEGIN TRY
   SET @Ls_Sql_TEXT = '';
   SET @Ls_SqlData_TEXT = '';
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
   -- Get Batch Details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;
     RAISERROR (50001,16,1);
    END

   SET @Ld_Run100_DATE = DATEADD (D, -100, @Ld_Run_DATE);
   SET @Ls_Sql_TEXT = 'DECLARE Disb_Cur';
   SET @Ls_SqlData_TEXT = 'Disburse_DATE = ' + CAST(@Ld_Run100_DATE AS VARCHAR) + ', MediumDisburse_CODE = ' + @Lc_MediumDisburseC_CODE + ', StatusCheck_CODE = ' + @Lc_StatusCheckOU_CODE;
   -- Outstanding Disbursement Cursor i.e) identifies all disbursements that are in outstanding status for more than 100 days.
   DECLARE Disb_CUR INSENSITIVE CURSOR FOR
   SELECT a.CheckRecipient_ID,
              a.CheckRecipient_CODE,
              a.Disburse_DATE,
              a.DisburseSeq_NUMB,
              a.MediumDisburse_CODE,
              a.Disburse_AMNT,
              a.Check_NUMB,
              a.StatusCheck_CODE,
              a.StatusCheck_DATE,
              a.ReasonStatus_CODE,
              a.EventGlobalBeginSeq_NUMB,
              a.EventGlobalEndSeq_NUMB,
              a.BeginValidity_DATE,
              a.EndValidity_DATE,
              a.Issue_DATE,
              a.Misc_ID
         FROM DSBH_Y1 a
        WHERE a.Disburse_DATE < @Ld_Run100_DATE
          AND a.MediumDisburse_CODE = @Lc_MediumDisburseC_CODE
          AND a.StatusCheck_CODE = @Lc_StatusCheckOU_CODE
          AND a.EndValidity_DATE = @Ld_High_DATE
        ORDER BY Misc_ID;
   SET @Ls_Sql_TEXT = 'OPEN Disb_Cur';
   SET @Ls_SqlData_TEXT = '';

   OPEN Disb_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Disb_Cur - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM Disb_CUR INTO @Lc_DisbCur_CheckRecipient_ID, @Lc_DisbCur_CheckRecipient_CODE, @Ld_DisbCur_Disburse_DATE, @Ln_DisbCur_DisburseSeq_NUMB, @Lc_DisbCur_MediumDisburse_CODE, @Ln_DisbCur_Disburse_AMNT, @Ln_DisbCur_Check_NUMB, @Lc_DisbCur_StatusCheck_CODE, @Ld_DisbCur_StatusCheck_DATE, @Lc_DisbCur_ReasonStatus_CODE, @Ln_DisbCur_EventGlobalBeginSeq_NUMB, @Ln_DisbCur_EventGlobalEndSeq_NUMB, @Ld_DisbCur_BeginValidity_DATE, @Ld_DisbCur_EndValidity_DATE, @Ld_DisbCur_Issue_DATE, @Lc_DisbCur_Misc_ID;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN TRANSACTION StaleChkTran;

   SET @Ls_Sql_TEXT = 'WHILE LOOP - 1';
   SET @Ls_SqlData_TEXT = '';
   
   -- Stale check loop
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
     
	  SAVE TRANSACTION SaveStaleChkTran;
     
      SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'STALE CHECKS CURSOR COUNT = ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '');
      -- Set Bate Record
      SET @Ls_BateRecord_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DisbCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_DisbCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DisbCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisbCur_DisburseSeq_NUMB AS VARCHAR), '') + ', MediumDisburse_CODE = ' + ISNULL(@Lc_DisbCur_MediumDisburse_CODE, '') + ', Disburse_AMNT = ' + ISNULL(CAST(@Ln_DisbCur_Disburse_AMNT AS VARCHAR), '') + ', Check_NUMB = ' + ISNULL(CAST(@Ln_DisbCur_Check_NUMB AS VARCHAR), '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_DisbCur_StatusCheck_CODE, '') + ', StatusCheck_DATE = ' + ISNULL(CAST(@Ld_DisbCur_StatusCheck_DATE AS VARCHAR), '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_DisbCur_ReasonStatus_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_DisbCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST(@Ln_DisbCur_EventGlobalEndSeq_NUMB AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_DisbCur_BeginValidity_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_DisbCur_EndValidity_DATE AS VARCHAR), '') + ', Issue_DATE = ' + ISNULL(CAST(@Ld_DisbCur_Issue_DATE AS VARCHAR), '') + ', Misc_ID = ' + ISNULL(@Lc_DisbCur_Misc_ID, '');
      -- UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';

      -- Logic - Start --
       BEGIN
        SET @Lb_ActiveEftFound_BIT = 1;
        SET @Lb_ActiveSvcFound_BIT = 1;
        -- Checking whether the recipient has an active EFT in EFTR_Y1 table.
        SET @Ls_Sql_TEXT = 'SELECT EFTR_Y1';
	    SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DisbCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_DisbCur_CheckRecipient_CODE,'')+ ', StatusEft_CODE = ' + ISNULL(@Lc_StatusEftAC_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
	    
        SELECT @Lc_CheckRecipient_ID = a.CheckRecipient_ID
          FROM EFTR_Y1 a
         WHERE a.CheckRecipient_ID = @Lc_DisbCur_CheckRecipient_ID
           AND a.CheckRecipient_CODE = @Lc_DisbCur_CheckRecipient_CODE
           AND a.StatusEft_CODE = @Lc_StatusEftAC_CODE
           AND a.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Lb_ActiveEftFound_BIT = 0;
         END

        -- Checking whether the recipient has an active SVC in DCRS_Y1 table.
        SET @Ls_Sql_TEXT = 'SELECT DCRS_Y1';
	    SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DisbCur_CheckRecipient_ID,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusA_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
        SELECT @Lc_CheckRecipient_ID = a.CheckRecipient_ID
          FROM DCRS_Y1 a
         WHERE a.CheckRecipient_ID = @Lc_DisbCur_CheckRecipient_ID
           AND a.Status_CODE = @Lc_StatusA_CODE
           AND a.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        -- Check if the Select query returned any rows
        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Lb_ActiveSvcFound_BIT = 0;
         END

        /*
        If there is an active EFT or SVC, procedure BATCH_COMMON$SP_PROCESS_CHECK_HOLD is called with the new sequence event global, 
        "VR" (Void/Reissue) as the new status and "SC" (Stale Check) as the new reason. This would move the disbursement to the Disbursement Hold 
        (DHLD) Screen / Disbursement Hold Log (DHLD_Y1) table.  Hold status code in the DHLD_Y1 table will be updated as "R" (Ready for disbursement). 
        These records will be processed in the next Batch disbursement process.
        */
        IF (@Lb_ActiveEftFound_BIT = 1
             OR @Lb_ActiveSvcFound_BIT = 1)
         BEGIN
          SET @Ln_EventFunctionalSeq_NUMB = @Li_VoidReIssue1750_NUMB;
          SET @Lc_StatusCheck_CODE = @Lc_StatusCheckVR_CODE;
          SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSC_CODE;
         END
        ELSE
         /*
         If there is no active EFT or SVC, void the check with status "VN" (Void/No Reissue) in the, Disbursement (DSBH_Y1) table beand updated with 
         "SC" (Stale Check) as the reason code, and "H" (Hold) as hold status code and Hold Reason of "SVSC - System Void-Stale Check" in the 
         Disbursement Hold Log (DHLD_Y1) table. 
         */
         BEGIN
          SET @Ln_EventFunctionalSeq_NUMB = @Li_VoidNoReIssue1720_NUMB;
          SET @Lc_StatusCheck_CODE = @Lc_StatusCheckVN_CODE;
          SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSC_CODE;
         END
         
		SET @Ls_Sql_TEXT = 'SELECT DSBH_Y1_DSBL_Y1';
        SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL (@Lc_DisbCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_DisbCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL (CAST(@Ld_DisbCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL (CAST(@Ln_DisbCur_DisburseSeq_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL (CAST(@Ld_High_DATE AS VARCHAR), '');
        SELECT TOP 1 @Ln_CaseESEM_IDNO = b.Case_IDNO
          FROM DSBH_Y1 a,
               DSBL_Y1 b
         WHERE a.CheckRecipient_ID = @Lc_DisbCur_CheckRecipient_ID
           AND a.CheckRecipient_CODE = @Lc_DisbCur_CheckRecipient_CODE
           AND a.Disburse_DATE = @Ld_DisbCur_Disburse_DATE
           AND a.DisburseSeq_NUMB = @Ln_DisbCur_DisburseSeq_NUMB
           AND a.EndValidity_DATE = @Ld_High_DATE
           AND a.CheckRecipient_ID = b.CheckRecipient_ID
           AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
           AND a.Disburse_DATE = b.Disburse_DATE
           AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Ln_CaseESEM_IDNO = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
      SET @Ls_SqlData_TEXT = ' EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Lc_Job_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT, '');

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX';
      SET @Ls_SqlData_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CaseESEM_IDNO AS VARCHAR), '') + ', CheckNo_TEXT = ' + ISNULL (CAST(@Ln_DisbCur_Check_NUMB AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL (CAST(@Ln_DisbCur_DisburseSeq_NUMB AS VARCHAR), '') + ', Disburse_DATE = ' + ISNULL (CAST(@Ld_DisbCur_Disburse_DATE AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST(@Lc_DisbCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + @Lc_DisbCur_CheckRecipient_CODE;

      EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
       @An_EventGlobalSeq_NUMB       = @Ln_EventGlobalSeq_NUMB,
       @An_EventFunctionalSeq_NUMB   = @Ln_EventFunctionalSeq_NUMB,
       @An_EntityCase_IDNO           = @Ln_CaseESEM_IDNO,
       @Ac_EntityCheckNo_TEXT        = @Ln_DisbCur_Check_NUMB,
       @An_EntityDisburseSeq_NUMB    = @Ln_DisbCur_DisburseSeq_NUMB,
       @Ad_EntityDisburse_DATE       = @Ld_DisbCur_Disburse_DATE,
       @Ac_EntityCheckRecipient_ID   = @Lc_DisbCur_CheckRecipient_ID,
       @Ac_EntityCheckRecipient_CODE = @Lc_DisbCur_CheckRecipient_CODE,
       @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      -- SP_PROCESS_CHECK_HOLD procedure move the Disbursement to DHLD_Y1 table. 
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PROCESS_CHECK_HOLD';
      SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + @Lc_DisbCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + ISNULL(@Lc_DisbCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DisbCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisbCur_DisburseSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_StatusCheck_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', Prog_IDNO = ' + @Lc_ProgStale_TEXT + ', Process_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

      EXECUTE BATCH_COMMON$SP_PROCESS_CHECK_HOLD
       @Ac_CheckRecipient_ID     = @Lc_DisbCur_CheckRecipient_ID,
       @Ac_CheckRecipient_CODE   = @Lc_DisbCur_CheckRecipient_CODE,
       @Ad_Disburse_DATE         = @Ld_DisbCur_Disburse_DATE,
       @An_DisburseSeq_NUMB      = @Ln_DisbCur_DisburseSeq_NUMB,
       @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
       @Ac_StatusCheck_CODE      = @Lc_StatusCheck_CODE,
       @Ac_ReasonStatus_CODE     = @Lc_ReasonStatus_CODE,
       @Ac_Prog_IDNO             = @Lc_ProgStale_TEXT,
       @Ad_Process_DATE          = @Ld_Run_DATE,
       @An_TransactionDhld_AMNT  = @Ln_TransactionDhld_AMNT OUTPUT,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      -- Check if the procedure ran properly
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      -- UPDATE DSBH_Y1
      SET @Ls_Sql_TEXT = 'UPDATE DSBH_Y1';
	  SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DisbCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_DisbCur_CheckRecipient_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_DisbCur_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @Ln_DisbCur_DisburseSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      UPDATE DSBH_Y1
         SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
             EndValidity_DATE = @Ld_Run_DATE
       WHERE CheckRecipient_ID = @Lc_DisbCur_CheckRecipient_ID
         AND CheckRecipient_CODE = @Lc_DisbCur_CheckRecipient_CODE
         AND Disburse_DATE = @Ld_DisbCur_Disburse_DATE
         AND DisburseSeq_NUMB = @Ln_DisbCur_DisburseSeq_NUMB
         AND EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        -- Update not successful
        SET @Lc_BateError_CODE = @Lc_BateErrorE0001_CODE;
        SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

        RAISERROR (50001,16,1);
       END

      -- Inserting the new record into DSBH_Y1 table
      SET @Ls_Sql_TEXT = ' INSERT DSBH_Y1';
      SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DisbCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_DisbCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DisbCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisbCur_DisburseSeq_NUMB AS VARCHAR), '') + ', MediumDisburse_CODE = ' + ISNULL(@Lc_DisbCur_MediumDisburse_CODE, '') + ', Disburse_AMNT = ' + ISNULL(CAST(@Ln_DisbCur_Disburse_AMNT AS VARCHAR), '') + ', Check_NUMB = ' + ISNULL(CAST(@Ln_DisbCur_Check_NUMB AS VARCHAR), '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_StatusCheck_CODE, '') + ', StatusCheck_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST(0 AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Issue_DATE = ' + ISNULL(CAST(@Ld_DisbCur_Issue_DATE AS VARCHAR), '') + ', Misc_ID = ' + ISNULL(@Lc_DisbCur_Misc_ID, '');

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
      VALUES (@Lc_DisbCur_CheckRecipient_ID,-- CheckRecipient_ID
              @Lc_DisbCur_CheckRecipient_CODE,-- CheckRecipient_CODE
              @Ld_DisbCur_Disburse_DATE,-- Disburse_DATE
              @Ln_DisbCur_DisburseSeq_NUMB,-- DisburseSeq_NUMB
              @Lc_DisbCur_MediumDisburse_CODE,-- MediumDisburse_CODE
              @Ln_DisbCur_Disburse_AMNT,-- Disburse_AMNT
              @Ln_DisbCur_Check_NUMB,-- Check_NUMB
              @Lc_StatusCheck_CODE,-- StatusCheck_CODE
              @Ld_Run_DATE,-- StatusCheck_DATE
              @Lc_ReasonStatus_CODE,-- ReasonStatus_CODE
              @Ln_EventGlobalSeq_NUMB,-- EventGlobalBeginSeq_NUMB
              0,-- EventGlobalEndSeq_NUMB			  
              @Ld_Run_DATE,-- BeginValidity_DATE
              @Ld_High_DATE,-- EndValidity_DATE
              @Ld_DisbCur_Issue_DATE,-- Issue_DATE
              @Lc_DisbCur_Misc_ID); -- Misc_ID
      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        -- Add not successful
        SET @Lc_BateError_CODE = @Lc_BateErrorE0113_CODE;
        SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

        RAISERROR (50001,16,1);
       END
      -- Logic - End -- 
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SaveStaleChkTran;
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
       @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
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
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
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

      -- Commit transaction after the commit frequency specified with the job
      IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
         AND @Ln_CommitFreqParm_QNTY > 0
       BEGIN
        COMMIT TRANSACTION StaleChkTran;
		SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
        BEGIN TRANSACTION StaleChkTran;

        SET @Ln_CommitFreq_QNTY = 0;
       END

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION StaleChkTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM Disb_CUR INTO @Lc_DisbCur_CheckRecipient_ID, @Lc_DisbCur_CheckRecipient_CODE, @Ld_DisbCur_Disburse_DATE, @Ln_DisbCur_DisburseSeq_NUMB, @Lc_DisbCur_MediumDisburse_CODE, @Ln_DisbCur_Disburse_AMNT, @Ln_DisbCur_Check_NUMB, @Lc_DisbCur_StatusCheck_CODE, @Ld_DisbCur_StatusCheck_DATE, @Lc_DisbCur_ReasonStatus_CODE, @Ln_DisbCur_EventGlobalBeginSeq_NUMB, @Ln_DisbCur_EventGlobalEndSeq_NUMB, @Ld_DisbCur_BeginValidity_DATE, @Ld_DisbCur_EndValidity_DATE, @Ld_DisbCur_Issue_DATE, @Lc_DisbCur_Misc_ID;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Disb_CUR;

   DEALLOCATE Disb_CUR;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;

   -- 'NO RECORD(S) TO PROCESS'
   IF(@Ln_CursorRecordCount_QNTY = 0)
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorNoRecords_CODE;
     SET @Ls_DescriptionError_TEXT = @Ls_Errdesc01_TEXT;
     SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateError_CODE = ' + @Lc_BateError_CODE + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_BateError_CODE,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     -- Check if the procedure ran properly
     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

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

   COMMIT TRANSACTION StaleChkTran;
  END TRY

  BEGIN CATCH
   -- Rollback all active transactions
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION StaleChkTran;
    END

   -- Close and Deallocate cursor
   IF CURSOR_STATUS('LOCAL', 'Disb_CUR') IN (0, 1)
    BEGIN
     CLOSE Disb_CUR;

     DEALLOCATE Disb_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   -- Process unknown errors
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
