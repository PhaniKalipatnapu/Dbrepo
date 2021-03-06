/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DFS_DISTRIBUTION$SP_PROCESS_DFS_DISTRIBUTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DFS_DISTRIBUTION$SP_PROCESS_DFS_DISTRIBUTION
Programmer Name 	: IMP Team
Description			: The Foster Care Distribution processes money applied by Distribution Batch process towards
					  Foster care balances.  This program will run at the end of the month after the IV-E grant
					  file from DYFS has been processed through batch.
					  The Distribution records will be available in DHLD_Y1 table with hold types of 
					  E – Foster Care Hold or D – Regular Hold and disbursement types of CHIVE or AHIVE.
					  CheckRecipient_ID 999999993 - DEPARTMENT OF SERVICES FOR CHILD, YOUTH AND THEIR FAMILIES
					  CheckRecipient_ID 999999980 - OUT OF STATE RECOVERY - FINANCIAL JOURNAL ENTRY			  
Frequency			: 'MONTHLY'
Developed On		: 07/14/2011
Called BY			: BATCH_FIN_FC_DISTRIBUTION$SP_FC_DISTRIBUTION
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DFS_DISTRIBUTION$SP_PROCESS_DFS_DISTRIBUTION]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_FosterCareDistribution1835_NUMB	INT = 1835,
           @Li_FosterCareDistributionHold1845_NUMB INT = 1845,
           @Lc_TypeErrorE_CODE				   CHAR(1) = 'E',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_No_INDC                         CHAR(1) = 'N',
           @Lc_RecipientTypeOthp_CODE          CHAR(1) = '3',
           @Lc_WelfareTypeNonIve_CODE          CHAR(1) = 'F',
           @Lc_Yes_INDC                        CHAR(1) = 'Y',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
           @Lc_RegularHoldD_CODE               CHAR(1) = 'D',
           @Lc_FcHoldE_CODE                    CHAR(1) = 'E',
           @Lc_DisbursementStatusHeldH_CODE    CHAR(1) = 'H',
           @Lc_DisbursementStatusReleaseR_CODE CHAR(1) = 'R',
           @Lc_ReasonStatusDr_CODE             CHAR(4) = 'DR',
           @Lc_ReasonStatusSdfg_CODE           CHAR(4) = 'SDFG',
           @Lc_DisbursementTypeChive_CODE      CHAR(5) = 'CHIVE',
           @Lc_DisbursementTypeAhive_CODE      CHAR(5) = 'AHIVE',           
           @Lc_DisbursementTypePgive_CODE      CHAR(5) = 'PGIVE',
           @Lc_DisbursementTypeAgive_CODE      CHAR(5) = 'AGIVE',
           @Lc_DisbursementTypeCxive_CODE      CHAR(5) = 'CXIVE',
           @Lc_DisbursementTypeAxive_CODE      CHAR(5) = 'AXIVE',
           @Lc_DisbursementTypeCzive_CODE      CHAR(5) = 'CZIVE',
           @Lc_DisbursementTypeAzive_CODE      CHAR(5) = 'AZIVE',           
           @Lc_EntityRctno_CODE                CHAR(5) = 'RCTNO',
           @Lc_EntityDthld_CODE                CHAR(5) = 'DTHLD',
           @Lc_EntityCase_CODE                 CHAR(5) = 'CASE',
           @Lc_EntityOrder_CODE                CHAR(5) = 'ORDER',
           @Lc_EntityOble_CODE                 CHAR(5) = 'OBLE',
           @Lc_EntityDstdt_CODE                CHAR(5) = 'DSTDT',
           @Lc_EntityWcase_CODE                CHAR(5) = 'WCASE',
           @Lc_ErrorE1424_CODE				   CHAR(5) = 'E1424',
           @Lc_Job_ID                          CHAR(7) = 'DEB6050',
           @Lc_CheckRecipientIve999999993_ID   CHAR(9) = '999999993',
           @Lc_CheckRecipientOsr999999980_ID   CHAR(9) = '999999980',
           @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_FIN_DFS_DISTRIBUTION',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS_DFS_DISTRIBUTION',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001',
           @Ld_Start_DATE                      DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   DECLARE @Ln_CommitFreqParm_QNTY        NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
           @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
           @Ln_CursorRecordCount_QNTY      NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY    NUMERIC(5) = 0,
           @Ln_WelfareYearMonth_NUMB      NUMERIC(6),
           @Ln_ProcessedRecordCount_QNTY  NUMERIC(6) = 0,
		   @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
           @Ln_MemberMci_IDNO             NUMERIC(10),
           @Ln_CaseWelfare_IDNO           NUMERIC(10),
           @Ln_Urg_AMNT                   NUMERIC(11,2),
           @Ln_MtdAssistExpend_AMNT       NUMERIC(11,2),
           @Ln_MtdAssistRecoup_AMNT       NUMERIC(11,2),
           @Ln_ExpandTotAsst_AMNT         NUMERIC(11,2),
           @Ln_RecupTotAsst_AMNT          NUMERIC(11,2),
           @Ln_GrantIvefPaid_AMNT         NUMERIC(11,2) = 0,
           @Ln_Ivef_AMNT                  NUMERIC(11,2) = 0,
           @Ln_TransactionCs_AMNT         NUMERIC(11,2) = 0,
           @Ln_MtdUrg_AMNT                NUMERIC(11,2),
           @Ln_MtdApp_AMNT                NUMERIC(11,2),
           @Ln_Error_NUMB                 NUMERIC(11),
           @Ln_ErrorLine_NUMB             NUMERIC(11),
           @Ln_Order_IDNO                 NUMERIC(15),
           @Ln_EventGlobalSeq_NUMB        NUMERIC(19),
           @Li_FetchStatus_QNTY           SMALLINT,
           @Li_Rowcount_QNTY              SMALLINT,
           @Lc_DistWcaseFlag_INDC         CHAR(1),
           @Lc_Msg_CODE                   CHAR(1),
           @Lc_TypeError_CODE             CHAR(1),
           @Lc_InsertEsem_INDC            CHAR(1),
           @Lc_BateError_CODE             CHAR(5),
           @Lc_Receipt_ID                 CHAR(27),
           @Lc_Oble_ID                    CHAR(30),
           @Ls_Sql_TEXT                   VARCHAR(100),
           @Ls_CursorLocation_TEXT        VARCHAR(200),
           @Ls_Sqldata_TEXT               VARCHAR(200),
           @Ls_ErrorMessage_TEXT          VARCHAR(4000),
           @Ls_DescriptionError_TEXT      VARCHAR(4000),
           @Ls_BateRecord_TEXT            VARCHAR(4000) = '',
           @Ld_Run_DATE                   DATE,
           @Ld_LastRun_DATE               DATE;         
         
  DECLARE @Ln_DhldCur_Seq_IDNO						NUMERIC(1),
          @Ld_DhldCur_Batch_DATE					DATE,
          @Lc_DhldCur_SourceBatch_CODE				CHAR(3),
          @Ln_DhldCur_Batch_NUMB					NUMERIC(4),
          @Ln_DhldCur_SeqReceipt_NUMB				NUMERIC(6),
          @Ld_DhldCur_Receipt_DATE					DATE,
          @Ln_DhldCur_Case_IDNO						NUMERIC(6),
          @Ln_DhldCur_OrderSeq_NUMB					NUMERIC(2),
          @Ln_DhldCur_ObligationSeq_NUMB			NUMERIC(2),
          @Ln_DhldCur_TransactionCurSup_AMNT		NUMERIC(11, 2),
          @Ln_DhldCur_TransactionIvef_AMNT			NUMERIC(11, 2),
          @Lc_DhldCur_TypeDisburse_CODE				CHAR(5),
          @Ln_DhldCur_EventGlobalBeginSeq_NUMB		NUMERIC (19),
          @Ln_DhldCur_EventGlobalSupportSeq_NUMB    NUMERIC(19),
          @Lc_DhldCur_CheckRecipient_ID				CHAR(10),
          @Lc_DhldCur_CheckRecipient_CODE			CHAR(1),
          @Lc_DhldCur_TypeHold_CODE					CHAR(1),
          @Ln_DhldCur_Unique_IDNO					NUMERIC(19),
          @Ld_DhldCur_Transaction_DATE				DATE;

  CREATE TABLE #EsemHold_P1
   (
     Entity_ID       CHAR(30),
     TypeEntity_CODE CHAR(5)
   );

  CREATE TABLE #EsemDist_P1
   (
     Entity_ID       CHAR(30), 
     TypeEntity_CODE CHAR (5)
   );

  BEGIN TRY
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
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END

   DECLARE Dhld_CUR INSENSITIVE CURSOR FOR
    SELECT CASE d.TypeDisburse_CODE
            WHEN @Lc_DisbursementTypeChive_CODE
             THEN 1
            WHEN @Lc_DisbursementTypeAhive_CODE
             THEN 2
           END AS Seq_IDNO,
           d.Batch_DATE,
           d.SourceBatch_CODE,
           d.Batch_NUMB,
           d.SeqReceipt_NUMB,
           d.Release_DATE AS Receipt_DATE,
           d.Case_IDNO,
           d.OrderSeq_NUMB,
           d.ObligationSeq_NUMB,
           CASE
            WHEN d.TypeDisburse_CODE = @Lc_DisbursementTypeChive_CODE
             THEN d.Transaction_AMNT
            ELSE 0
           END AS TransactionCurSup_AMNT,
           CASE
            WHEN d.TypeDisburse_CODE = @Lc_DisbursementTypeAhive_CODE
             THEN d.Transaction_AMNT
            ELSE 0
           END AS TransactionIvef_AMNT,
           d.TypeDisburse_CODE,
           d.EventGlobalBeginSeq_NUMB,
           d.EventGlobalSupportSeq_NUMB,
           d.CheckRecipient_ID,
           d.CheckRecipient_CODE,
           d.TypeHold_CODE,
           d.Unique_IDNO,
           d.Transaction_DATE
      FROM DHLD_Y1 d
     WHERE d.TypeHold_CODE IN (@Lc_FcHoldE_CODE, @Lc_RegularHoldD_CODE)
       AND d.Status_CODE = @Lc_DisbursementStatusHeldH_CODE
       AND d.TypeDisburse_CODE IN (@Lc_DisbursementTypeChive_CODE, @Lc_DisbursementTypeAhive_CODE)
       AND d.Release_DATE <= @Ld_Run_DATE
       AND d.EndValidity_DATE = @Ld_High_DATE
     ORDER BY Seq_IDNO,
			  Receipt_DATE,
			  Batch_DATE,
			  SourceBatch_CODE,
			  Batch_NUMB,
			  SeqReceipt_NUMB;

   BEGIN TRANSACTION FCDistTran; -- 1
   SET @Ls_Sql_TEXT = 'OPEN Dhld_CUR';
	SET @Ls_Sqldata_TEXT = '';
   OPEN Dhld_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Dhld_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Seq_IDNO, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ld_DhldCur_Receipt_DATE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ln_DhldCur_TransactionCurSup_AMNT, @Ln_DhldCur_TransactionIvef_AMNT, @Lc_DhldCur_TypeDisburse_CODE, @Ln_DhldCur_EventGlobalBeginSeq_NUMB, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Lc_DhldCur_TypeHold_CODE, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Transaction_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    -- The Foster Care Distribution processes money applied by Distribution Batch process towards Foster care balances.
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
     
     BEGIN TRY
     
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 1';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

	  SAVE TRANSACTION SaveFCDistTran;
	  
      SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
	  SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Seq_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Receipt_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', TransactionCurSup_AMNT = ' + ISNULL(CAST(@Ln_DhldCur_TransactionCurSup_AMNT AS VARCHAR), '') + ', TransactionIvef_AMNT = ' + ISNULL(CAST(@Ln_DhldCur_TransactionIvef_AMNT AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_DhldCur_TypeDisburse_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(@Lc_DhldCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_DhldCur_CheckRecipient_CODE, '') + ', TypeHold_CODE = ' + + ISNULL(@Lc_DhldCur_TypeHold_CODE, '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '');
	  SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Lc_InsertEsem_INDC = @Lc_No_INDC;
      SET @Ln_Ivef_AMNT = @Ln_DhldCur_TransactionIvef_AMNT;
      SET @Ln_TransactionCs_AMNT = @Ln_DhldCur_TransactionCurSup_AMNT;
      -- UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ls_CursorLocation_TEXT = 'Cursor_QNTY = ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL (CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_DhldCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR), '') + ', UNIQUE_ID = ' + ISNULL (CAST (@Ln_DhldCur_Unique_IDNO AS VARCHAR), '');
      
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ - 1835';
	  SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_FosterCareDistribution1835_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');
      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_FosterCareDistribution1835_NUMB,
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

      -- Disburse the Out of state cost recovery directly to OSR (999999980).
      IF @Lc_DhldCur_CheckRecipient_ID = @Lc_CheckRecipientOsr999999980_ID
         AND @Lc_DhldCur_TypeHold_CODE = @Lc_RegularHoldD_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT DHLD_Y1 - OSR ';
		SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusReleaseR_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_RegularHoldD_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientOsr999999980_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDr_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');
        INSERT DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                Status_CODE,
                TypeHold_CODE,
                TypeDisburse_CODE,
                ProcessOffset_INDC,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Release_DATE,
                ReasonStatus_CODE,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
        VALUES ( @Ln_DhldCur_Case_IDNO,                    -- Case_IDNO         
				 @Ln_DhldCur_OrderSeq_NUMB,                -- OrderSeq_NUMB     
				 @Ln_DhldCur_ObligationSeq_NUMB,           -- ObligationSeq_NUMB
				 @Ld_DhldCur_Batch_DATE,                   -- Batch_DATE        
				 @Ln_DhldCur_Batch_NUMB,                   -- Batch_NUMB        
				 @Ln_DhldCur_SeqReceipt_NUMB,              -- SeqReceipt_NUMB   
				 @Lc_DhldCur_SourceBatch_CODE,             -- SourceBatch_CODE  
				 @Ld_Run_DATE,                             -- Transaction_DATE  
				 @Ln_TransactionCs_AMNT + @Ln_Ivef_AMNT,   -- Transaction_AMNT  
				 @Lc_DisbursementStatusReleaseR_CODE,      -- Status_CODE       
				 @Lc_RegularHoldD_CODE,                    -- TypeHold_CODE     
				 CASE
				  WHEN @Ln_Ivef_AMNT > 0
				   THEN @Lc_DisbursementTypeAzive_CODE
				  WHEN @Ln_TransactionCs_AMNT > 0
				   THEN @Lc_DisbursementTypeCzive_CODE
				 END,                                      -- TypeDisburse_CODE
				 @Lc_No_INDC,                              -- ProcessOffset_INDC        
				 @Lc_CheckRecipientOsr999999980_ID,      -- CheckRecipient_ID         
				 @Lc_RecipientTypeOthp_CODE,               -- CheckRecipient_CODE       
				 @Ld_Run_DATE,                             -- BeginValidity_DATE        
				 @Ld_High_DATE,                            -- EndValidity_DATE          
				 @Ln_EventGlobalSeq_NUMB,                  -- EventGlobalBeginSeq_NUMB  
				 0,                                        -- EventGlobalEndSeq_NUMB    
				 @Ln_DhldCur_EventGlobalSupportSeq_NUMB,   -- EventGlobalSupportSeq_NUMB
				 @Ld_Run_DATE,                             -- Release_DATE              
				 @Lc_ReasonStatusDr_CODE,                  -- ReasonStatus_CODE         
				 @Ld_Low_DATE,                             -- Disburse_DATE             
				 0,                                        -- DisburseSeq_NUMB          
				 @Ld_High_DATE,                            -- StatusEscheat_DATE        
				 @Lc_Space_TEXT);                           -- StatusEscheat_CODE        

        GOTO UPDATE_DHLD;
       END

      SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      
      SELECT DISTINCT
             @Ln_MemberMci_IDNO = a.MemberMci_IDNO
        FROM OBLE_Y1 a
       WHERE a.Case_IDNO = @Ln_DhldCur_Case_IDNO
         AND a.OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB
         AND a.ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
         AND a.EndValidity_DATE = @Ld_High_DATE;

      BEGIN
       -- Selecting Obligation Order_IDNO and Obligation-Key
       SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1, SORD_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT TOP 1 @Lc_Oble_ID = ISNULL (ISNULL (CAST(MemberMci_IDNO AS VARCHAR), '') + ISNULL (TypeDebt_CODE, '') + ISNULL (Fips_CODE, ''), ' '),
                    @Ln_Order_IDNO = ISNULL (CAST(Order_IDNO AS VARCHAR), ' ')
         FROM OBLE_Y1 a,
              SORD_Y1 b
        WHERE a.Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND a.OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB
          AND a.ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
          AND a.EndValidity_DATE = @Ld_High_DATE
          AND a.Case_IDNO = b.Case_IDNO
          AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
          AND b.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Lc_Oble_ID = @Lc_Space_TEXT;
         SET @Ln_Order_IDNO = 0;
        END
      END

      ------------< START - Assign ESEM for HOLD and Distribution >--------------
      -- storing values for ESEM insertion
      SET @Ls_Sql_TEXT = 'ASSIGN_RECEIPT';
	  SET @Ls_Sqldata_TEXT = '';
      DELETE FROM #EsemHold_P1;
	  
	  SET @Ls_Sql_TEXT = 'DELETE #EsemDist_P1';
	  SET @Ls_Sqldata_TEXT = '';	
      DELETE FROM #EsemDist_P1;

      SET @Lc_Receipt_ID = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB);

      --------------------< START - FOSTER CARE HOLD >--------------------------------
      --Assigning the Entity_ID RCTH_Y1 into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT #EsemHold_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityRctno_CODE + ', Entity_ID = ' + @Lc_Receipt_ID;
      INSERT INTO #EsemHold_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityRctno_CODE, -- TypeEntity_CODE
                   @Lc_Receipt_ID); -- Entity_ID

      --Assigning the Entity_ID Date Hold into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT DATE #EsemHold_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityDthld_CODE + ', Entity_ID = ' + CAST(CONVERT(VARCHAR(10), @Ld_Run_DATE, 110) AS VARCHAR);
      INSERT INTO #EsemHold_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES ( @Lc_EntityDthld_CODE, -- TypeEntity_CODE
                    CONVERT(VARCHAR(10), @Ld_Run_DATE, 110)); -- Entity_ID

      --Assigning the Entity_ID CASE into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT CASE #EsemHold_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityCase_CODE + ', Entity_ID = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR);
      INSERT INTO #EsemHold_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityCase_CODE, -- TypeEntity_CODE
                   @Ln_DhldCur_Case_IDNO); -- Entity_ID

      --Assigning the Entity_ID ORDER into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT ORDER #EsemHold_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityOrder_CODE + ', Entity_ID = ' + CAST(@Ln_Order_IDNO AS VARCHAR);
      INSERT INTO #EsemHold_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityOrder_CODE, -- TypeEntity_CODE
                   @Ln_Order_IDNO); -- Entity_ID

      --Assigning the Entity_ID OBLE_Y1 into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT OBLE #EsemHold_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityOble_CODE + ', Entity_ID = ' + @Lc_Oble_ID;
      INSERT INTO #EsemHold_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityOble_CODE, -- TypeEntity_CODE
                   @Lc_Oble_ID); -- Entity_ID

      --------------------< END - FOSTER CARE HOLD >--------------------------------
      --------------------< START - FOSTER CARE DISTRIBUTION >------------------------
      --Assigning the Entity_ID RCTH_Y1 into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT Receipt #EsemDist_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityRctno_CODE + ', Entity_ID = ' + @Lc_Receipt_ID;
      INSERT INTO #EsemDist_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityRctno_CODE, -- TypeEntity_CODE
                   @Lc_Receipt_ID); -- Entity_ID

      --Assigning the Entity_ID Distribute Date into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT Distribute Date #EsemDist_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityDstdt_CODE + ', Entity_ID = ' + CAST(CONVERT(VARCHAR(10), @Ld_Run_DATE, 110) AS VARCHAR);
      INSERT INTO #EsemDist_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES ( @Lc_EntityDstdt_CODE, -- TypeEntity_CODE
                    CONVERT(VARCHAR(10), @Ld_Run_DATE, 110)); -- Entity_ID

      --Assigning the Entity_ID CASE into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT Case #EsemDist_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityCase_CODE + ', Entity_ID = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR);
      INSERT INTO #EsemDist_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityCase_CODE, -- TypeEntity_CODE
                   @Ln_DhldCur_Case_IDNO); -- Entity_ID

      --Assigning the Entity_ID ORDER into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT Order #EsemDist_P1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityOrder_CODE + ', Entity_ID = ' + CAST(@Ln_Order_IDNO AS VARCHAR);
      INSERT INTO #EsemDist_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityOrder_CODE, -- TypeEntity_CODE
                   @Ln_Order_IDNO); -- Entity_ID

      --Assigning the Entity_ID OBLE_Y1 into the PLSQL variable
      SET @Ls_Sql_TEXT = 'INSERT Obligation #EsemDist_P1';
	 SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityOble_CODE + ', Entity_ID = ' + @Lc_Oble_ID;
      INSERT INTO #EsemDist_P1
                  (TypeEntity_CODE,
                   Entity_ID)
           VALUES (@Lc_EntityOble_CODE, -- TypeEntity_CODE
                   @Lc_Oble_ID); -- Entity_ID

      --------------------< END - FOSTER CARE DISTRIBUTION >------------------------
      ------------< END - Assign ESEM for HOLD and Distribution >--------------
      -- storing values for ESEM insertion
      SET @Ls_Sql_TEXT = 'ASSIGN_RECEIPT';
	  SET @Ls_Sqldata_TEXT = '';
      BEGIN
       
       SET @Ln_CaseWelfare_IDNO = 0;
       
       -- Deriving the FosterCare case id from MHIS table
       SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'');

       SELECT TOP 1 @Ln_CaseWelfare_IDNO = CaseWelfare_IDNO
         FROM MHIS_Y1 m
        WHERE m.Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND m.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND m.CaseWelfare_IDNO != 0
          AND m.TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE;
      END

      SET @Ln_Urg_AMNT = 0;
      SET @Ln_WelfareYearMonth_NUMB = 0;
      SET @Ln_MtdAssistExpend_AMNT = 0;
      SET @Ln_ExpandTotAsst_AMNT = 0;
      SET @Ln_RecupTotAsst_AMNT = 0;

      IF @Ln_TransactionCs_AMNT > 0
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_FIN_DFS_DISTRIBUTION$SP_CS_PROCESS';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Receipt_DATE AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_DhldCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_DhldCur_CheckRecipient_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_DhldCur_TypeHold_CODE,'');
        EXECUTE BATCH_FIN_DFS_DISTRIBUTION$SP_CS_PROCESS
         @An_Case_IDNO                  = @Ln_DhldCur_Case_IDNO,
         @An_OrderSeq_NUMB              = @Ln_DhldCur_OrderSeq_NUMB,
         @An_ObligationSeq_NUMB         = @Ln_DhldCur_ObligationSeq_NUMB,
         @An_CaseWelfare_IDNO           = @Ln_CaseWelfare_IDNO,
         @Ad_Batch_DATE                 = @Ld_DhldCur_Batch_DATE,
         @Ac_SourceBatch_CODE           = @Lc_DhldCur_SourceBatch_CODE,
         @An_Batch_NUMB                 = @Ln_DhldCur_Batch_NUMB,
         @An_SeqReceipt_NUMB            = @Ln_DhldCur_SeqReceipt_NUMB,
         @Ad_Receipt_DATE               = @Ld_DhldCur_Receipt_DATE,
         @Ac_CheckRecipient_ID          = @Lc_DhldCur_CheckRecipient_ID,
         @Ac_CheckRecipient_CODE        = @Lc_DhldCur_CheckRecipient_CODE,
         @An_EventGlobalSupportSeq_NUMB = @Ln_DhldCur_EventGlobalSupportSeq_NUMB,
         @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
         @Ac_TypeHold_CODE              = @Lc_DhldCur_TypeHold_CODE,
         @An_Cs_AMNT                    = @Ln_TransactionCs_AMNT OUTPUT,
         @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
         @Ad_Process_DATE               = @Ld_Run_DATE OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        --Add remaining money from Cs_AMNT to the arrears to apply for remaining grant or excess
        SET @Ln_Ivef_AMNT = @Ln_Ivef_AMNT + @Ln_TransactionCs_AMNT;

        --If all Cs_AMNT money is paid off in cg_process, insert into ESEM and go to Update_Dhld
        IF @Ln_Ivef_AMNT = 0
         BEGIN
          IF (SELECT COUNT (1)
                FROM #EsemDist_P1) > 5
           BEGIN
            SET @Ls_Sql_TEXT = 'SELECT_ESEM_Y1';
		    SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Li_FosterCareDistribution1835_NUMB AS VARCHAR), '');
            INSERT INTO ESEM_Y1
                        (TypeEntity_CODE,
                         EventGlobalSeq_NUMB,
                         EventFunctionalSeq_NUMB,
                         Entity_ID)
            (SELECT p.TypeEntity_CODE,
                    @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                    @Li_FosterCareDistribution1835_NUMB AS EventFunctionalSeq_NUMB,
                    p.Entity_ID
               FROM #EsemDist_P1 p);

            SET @Lc_InsertEsem_INDC = @Lc_Yes_INDC;

            GOTO Update_Dhld;
           END
          ELSE
           BEGIN
            IF @Lc_DhldCur_TypeHold_CODE = @Lc_RegularHoldD_CODE
             BEGIN
              GOTO Update_Dhld;
             END
           END

          GOTO lx_nextrec;
         END
       END

      SET @Ls_Sql_TEXT = 'SELECT_IVMG_Y1';
      SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'');
      SELECT @Ln_Urg_AMNT = (a.LtdAssistExpend_AMNT - a.LtdAssistRecoup_AMNT),
             @Ln_WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB,
             @Ln_MtdAssistExpend_AMNT = a.MtdAssistExpend_AMNT,
             @Ln_ExpandTotAsst_AMNT = a.LtdAssistExpend_AMNT,
             @Ln_RecupTotAsst_AMNT = a.LtdAssistRecoup_AMNT,
             @Ln_MtdAssistRecoup_AMNT = a.MtdAssistRecoup_AMNT
        FROM IVMG_Y1 a
       WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
         AND a.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE
         AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB)
                                          FROM IVMG_Y1 b
                                         WHERE b.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                                           AND b.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE)
         AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                        FROM IVMG_Y1 c
                                       WHERE c.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                                         AND c.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE
                                         AND c.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;

      IF @Li_Rowcount_QNTY = 1
       BEGIN
        IF @Ln_Urg_AMNT < 0
         BEGIN
          SET @Ln_Urg_AMNT = 0;
         END

        SET @Ln_MtdUrg_AMNT = @Ln_MtdAssistExpend_AMNT - @Ln_MtdAssistRecoup_AMNT;

        IF @Ln_MtdUrg_AMNT < 0
         BEGIN
          SET @Ln_MtdUrg_AMNT = 0;
         END

        IF @Ln_Urg_AMNT >= @Ln_Ivef_AMNT
         BEGIN
          SET @Ln_GrantIvefPaid_AMNT = @Ln_Ivef_AMNT;

          IF @Ln_Ivef_AMNT >= @Ln_MtdUrg_AMNT
           BEGIN
            SET @Ln_MtdApp_AMNT = @Ln_MtdUrg_AMNT;
            SET @Ln_MtdUrg_AMNT = 0;
           END
          ELSE
           BEGIN
            SET @Ln_MtdApp_AMNT = @Ln_Ivef_AMNT;
            SET @Ln_MtdUrg_AMNT = @Ln_MtdUrg_AMNT - @Ln_Ivef_AMNT;
           END

          SET @Ln_Ivef_AMNT = 0;
         END
        ELSE
         BEGIN
          SET @Ln_GrantIvefPaid_AMNT = @Ln_Urg_AMNT;
          SET @Ln_Ivef_AMNT = @Ln_Ivef_AMNT - @Ln_GrantIvefPaid_AMNT;
          SET @Ln_MtdApp_AMNT = @Ln_MtdUrg_AMNT;
          SET @Ln_Urg_AMNT = 0;
          SET @Ln_MtdUrg_AMNT = 0;
         END

        IF @Ln_GrantIvefPaid_AMNT > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT_LWEL_Y11';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + ', WelfareYearMonth_NUMB = ' + ISNULL (CAST(@Ln_WelfareYearMonth_NUMB AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL (@Lc_WelfareTypeNonIve_CODE, '') + ', Distribute_AMNT = ' + ISNULL (CAST(@Ln_GrantIvefPaid_AMNT AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL (CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_DhldCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Distribute_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL (CAST(@Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR), '');
          INSERT LWEL_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  CaseWelfare_IDNO,
                  WelfareYearMonth_NUMB,
                  TypeWelfare_CODE,
                  TypeDisburse_CODE,
                  Distribute_AMNT,
                  Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  Distribute_DATE,
                  EventGlobalSeq_NUMB,
                  EventGlobalSupportSeq_NUMB)
          VALUES ( @Ln_DhldCur_Case_IDNO,												 -- Case_IDNO            			
				   @Ln_DhldCur_OrderSeq_NUMB,                                            -- OrderSeq_NUMB        
				   @Ln_DhldCur_ObligationSeq_NUMB,                                       -- ObligationSeq_NUMB   
				   @Ln_CaseWelfare_IDNO,                                                 -- CaseWelfare_IDNO     
				   @Ln_WelfareYearMonth_NUMB,                                            -- WelfareYearMonth_NUMB
				   @Lc_WelfareTypeNonIve_CODE,                                           -- TypeWelfare_CODE     
				   CASE
					WHEN @Lc_DhldCur_TypeDisburse_CODE = @Lc_DisbursementTypeChive_CODE
					 THEN @Lc_DisbursementTypePgive_CODE
					ELSE @Lc_DisbursementTypeAgive_CODE
				   END,                                                                   -- TypeDisburse_CODE
				   @Ln_GrantIvefPaid_AMNT,                                                -- Distribute_AMNT           
				   @Ld_DhldCur_Batch_DATE,                                                -- Batch_DATE                
				   @Lc_DhldCur_SourceBatch_CODE,                                          -- SourceBatch_CODE          
				   @Ln_DhldCur_Batch_NUMB,                                                -- Batch_NUMB                
				   @Ln_DhldCur_SeqReceipt_NUMB,                                           -- SeqReceipt_NUMB           
				   @Ld_Run_DATE,                                                          -- Distribute_DATE           
				   @Ln_EventGlobalSeq_NUMB,                                               -- EventGlobalSeq_NUMB       
				   @Ln_DhldCur_EventGlobalSupportSeq_NUMB);                               -- EventGlobalSupportSeq_NUMB

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT_LWEL_Y11 FAILED';

            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y11';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_GrantIvefPaid_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusReleaseR_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_RegularHoldD_CODE,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientIve999999993_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDr_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');
          INSERT DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  Transaction_DATE,
                  Release_DATE,
                  Transaction_AMNT,
                  Status_CODE,
                  TypeDisburse_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  EventGlobalSupportSeq_NUMB,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
          VALUES ( @Ln_DhldCur_Case_IDNO,                                                     -- Case_IDNO         
                   @Ln_DhldCur_OrderSeq_NUMB,                                                 -- OrderSeq_NUMB     
                   @Ln_DhldCur_ObligationSeq_NUMB,                                            -- ObligationSeq_NUMB
                   @Ld_DhldCur_Batch_DATE,                                                    -- Batch_DATE        
                   @Lc_DhldCur_SourceBatch_CODE,                                              -- SourceBatch_CODE  
                   @Ln_DhldCur_Batch_NUMB,                                                    -- Batch_NUMB        
                   @Ln_DhldCur_SeqReceipt_NUMB,                                               -- SeqReceipt_NUMB   
                   @Ld_Run_DATE,                                                              -- Transaction_DATE  
                   @Ld_Run_DATE,                                                              -- Release_DATE      
                   @Ln_GrantIvefPaid_AMNT,                                                    -- Transaction_AMNT  
                   @Lc_DisbursementStatusReleaseR_CODE,                                       -- Status_CODE       
                   CASE                                                                       
                    WHEN @Lc_DhldCur_TypeDisburse_CODE = @Lc_DisbursementTypeChive_CODE
                     THEN @Lc_DisbursementTypePgive_CODE
                    ELSE @Lc_DisbursementTypeAgive_CODE
                   END,                                                                       -- TypeDisburse_CODE 
                   @Lc_RegularHoldD_CODE,                                                     -- TypeHold_CODE             
                   @Lc_CheckRecipientIve999999993_ID,                                                -- CheckRecipient_ID         
                   @Lc_RecipientTypeOthp_CODE,                                                -- CheckRecipient_CODE       
                   @Lc_Yes_INDC,                                                              -- ProcessOffset_INDC        
                   @Lc_ReasonStatusDr_CODE,                                                   -- ReasonStatus_CODE         
                   @Ln_DhldCur_EventGlobalSupportSeq_NUMB,                                    -- EventGlobalSupportSeq_NUMB
                   @Ld_Run_DATE,                                                              -- BeginValidity_DATE        
                   @Ld_High_DATE,                                                             -- EndValidity_DATE          
                   @Ln_EventGlobalSeq_NUMB,                                                   -- EventGlobalBeginSeq_NUMB  
                   0,                                                                         -- EventGlobalEndSeq_NUMB    
                   @Ld_Low_DATE,                                                              -- Disburse_DATE             
                   0,                                                                         -- DisburseSeq_NUMB          
                   @Ld_High_DATE,                                                             -- StatusEscheat_DATE        
                   @Lc_Space_TEXT);                                                           -- StatusEscheat_CODE        

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y1 1 FAILED';

            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'UPDATE_IVMG_Y1';
          SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');
          UPDATE IVMG_Y1
             SET MtdAssistRecoup_AMNT = MtdAssistRecoup_AMNT + @Ln_MtdApp_AMNT,
                 TransactionAssistRecoup_AMNT = TransactionAssistRecoup_AMNT + @Ln_GrantIvefPaid_AMNT,
                 LtdAssistRecoup_AMNT = LtdAssistRecoup_AMNT + @Ln_GrantIvefPaid_AMNT
           WHERE CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
             AND WelfareYearMonth_NUMB = @Ln_WelfareYearMonth_NUMB
             AND WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE
             AND EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'INSERT_IVMG_Y1';
            SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','')+ ', TransactionAssistRecoup_AMNT = ' + ISNULL(CAST( @Ln_GrantIvefPaid_AMNT AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');
            INSERT IVMG_Y1
                   (CaseWelfare_IDNO,
                    WelfareYearMonth_NUMB,
                    WelfareElig_CODE,
                    MtdAssistExpend_AMNT,
                    TransactionAssistExpend_AMNT,
                    LtdAssistExpend_AMNT,
                    TransactionAssistRecoup_AMNT,
                    LtdAssistRecoup_AMNT,
                    MtdAssistRecoup_AMNT,
                    TypeAdjust_CODE,
                    EventGlobalSeq_NUMB,
                    ZeroGrant_INDC,
                    AdjustLtdFlag_INDC,
                    Defra_AMNT,
                    CpMci_IDNO)
            (SELECT @Ln_CaseWelfare_IDNO AS CaseWelfare_IDNO,
                    @Ln_WelfareYearMonth_NUMB AS WelfareYearMonth_NUMB,
                    @Lc_WelfareTypeNonIve_CODE AS WelfareElig_CODE,
                    a.MtdAssistExpend_AMNT,
                    0 AS LtdAssistExpend_AMNT,
                    a.LtdAssistExpend_AMNT,
                    @Ln_GrantIvefPaid_AMNT AS TransactionAssistRecoup_AMNT,
                    a.LtdAssistRecoup_AMNT + @Ln_GrantIvefPaid_AMNT AS LtdAssistRecoup_AMNT,
                    a.MtdAssistRecoup_AMNT,
                    a.TypeAdjust_CODE,
                    @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                    a.ZeroGrant_INDC,
                    a.AdjustLtdFlag_INDC,
                    a.Defra_AMNT,
					a.CpMci_IDNO
               FROM IVMG_Y1 a
              WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                AND a.WelfareYearMonth_NUMB = @Ln_WelfareYearMonth_NUMB
                AND a.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE
                AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB)
                                               FROM IVMG_Y1 b
                                              WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                                AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                                AND b.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE));

            SET @Li_Rowcount_QNTY = @@ROWCOUNT;

            IF @Li_Rowcount_QNTY = 0
             BEGIN
              SET @Ls_ErrorMessage_TEXT = 'INSERT_IVMG_Y1 FAILED';

              RAISERROR (50001,16,1);
             END
           END

          IF (SELECT 1
                FROM #EsemDist_P1
               WHERE TypeEntity_CODE = @Lc_EntityWcase_CODE
                 AND Entity_ID = @Ln_CaseWelfare_IDNO) > 0
           BEGIN
            SET @Lc_DistWcaseFlag_INDC = @Lc_Yes_INDC;
           END

          IF @Lc_DistWcaseFlag_INDC = @Lc_No_INDC
           BEGIN
            SET @Ls_Sql_TEXT = 'INSERT #EsemDist_P1 - 2';
            SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityWcase_CODE + ', Entity_ID = ' + CAST(@Ln_CaseWelfare_IDNO AS VARCHAR);
            INSERT INTO #EsemDist_P1
                        (TypeEntity_CODE,
                         Entity_ID)
                 VALUES ( @Lc_EntityWcase_CODE, -- TypeEntity_CODE
                          @Ln_CaseWelfare_IDNO); -- Entity_ID
           END
		  SET @Ls_Sql_TEXT = 'INSERT ESEM_Y1 - 2';
          SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS  VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_FosterCareDistribution1835_NUMB AS VARCHAR);
          INSERT INTO ESEM_Y1
                      (TypeEntity_CODE,
                       EventGlobalSeq_NUMB,
                       EventFunctionalSeq_NUMB,
                       Entity_ID)
          (SELECT p.TypeEntity_CODE,
                  @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                  @Li_FosterCareDistribution1835_NUMB AS EventFunctionalSeq_NUMB,
                  p.Entity_ID
             FROM #EsemDist_P1 p);

          SET @Lc_InsertEsem_INDC = @Lc_Yes_INDC;
         END

        --Process remaining money as excess
        IF @Ln_Ivef_AMNT > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT_LWEL_Y1_EXCESS';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL (CAST(0 AS VARCHAR), '') + ', WelfareYearMonth_NUMB = ' + ISNULL (CAST(SUBSTRING(CONVERT(VARCHAR(6),@Ld_DhldCur_Receipt_DATE,112),1,6) AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL (@Lc_WelfareTypeNonIve_CODE, '') + ', Distribute_AMNT = ' + ISNULL (CAST(@Ln_Ivef_AMNT AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL (CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_DhldCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Distribute_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL (CAST(@Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR), '');

          INSERT LWEL_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  CaseWelfare_IDNO,
                  WelfareYearMonth_NUMB,
                  TypeWelfare_CODE,
                  TypeDisburse_CODE,
                  Distribute_AMNT,
                  Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  Distribute_DATE,
                  EventGlobalSeq_NUMB,
                  EventGlobalSupportSeq_NUMB)
          VALUES ( @Ln_DhldCur_Case_IDNO,												                             -- Case_IDNO            
				   @Ln_DhldCur_OrderSeq_NUMB,	                                                                     -- OrderSeq_NUMB        
				   @Ln_DhldCur_ObligationSeq_NUMB,                                                                   -- ObligationSeq_NUMB   
				   0,                                                                                                -- CaseWelfare_IDNO     
				   SUBSTRING(CONVERT(VARCHAR(6),@Ld_DhldCur_Receipt_DATE,112),1,6),								     -- WelfareYearMonth_NUMB
				   @Lc_WelfareTypeNonIve_CODE,                                                                       -- TypeWelfare_CODE
				   CASE
					WHEN @Lc_DhldCur_TypeDisburse_CODE = @Lc_DisbursementTypeChive_CODE
					 THEN @Lc_DisbursementTypeCxive_CODE
					ELSE @Lc_DisbursementTypeAxive_CODE
				   END,                                                                                               -- TypeDisburse_CODE
				   @Ln_Ivef_AMNT,                                                                                      -- Distribute_AMNT           
				   @Ld_DhldCur_Batch_DATE,                                                                             -- Batch_DATE                
				   @Lc_DhldCur_SourceBatch_CODE,                                                                       -- SourceBatch_CODE          
				   @Ln_DhldCur_Batch_NUMB,                                                                             -- Batch_NUMB                
				   @Ln_DhldCur_SeqReceipt_NUMB,                                                                        -- SeqReceipt_NUMB           
				   @Ld_Run_DATE,                                                                                       -- Distribute_DATE           
				   @Ln_EventGlobalSeq_NUMB,                                                                            -- EventGlobalSeq_NUMB       
				   @Ln_DhldCur_EventGlobalSupportSeq_NUMB);                                                            -- EventGlobalSupportSeq_NUMB

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT_LWEL_Y1_EXCESS FAILED';

            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y12';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_Ivef_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusReleaseR_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_RegularHoldD_CODE,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientIve999999993_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDr_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');
          INSERT DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  Transaction_DATE,
                  Release_DATE,
                  Transaction_AMNT,
                  Status_CODE,
                  TypeHold_CODE,
                  TypeDisburse_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  EventGlobalSupportSeq_NUMB,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
         VALUES ( @Ln_DhldCur_Case_IDNO,                                                     -- Case_IDNO         
                   @Ln_DhldCur_OrderSeq_NUMB,                                                -- OrderSeq_NUMB     
                   @Ln_DhldCur_ObligationSeq_NUMB,                                           -- ObligationSeq_NUMB
                   @Ld_DhldCur_Batch_DATE,                                                   -- Batch_DATE        
                   @Lc_DhldCur_SourceBatch_CODE,                                             -- SourceBatch_CODE  
                   @Ln_DhldCur_Batch_NUMB,                                                   -- Batch_NUMB        
                   @Ln_DhldCur_SeqReceipt_NUMB,                                              -- SeqReceipt_NUMB   
                   @Ld_Run_DATE,                                                             -- Transaction_DATE  
                   @Ld_Run_DATE,                                                             -- Release_DATE      
                   @Ln_Ivef_AMNT,                                                            -- Transaction_AMNT  
                   @Lc_DisbursementStatusReleaseR_CODE,                                      -- Status_CODE       
                   @Lc_RegularHoldD_CODE,                                                    -- TypeHold_CODE     
                   CASE
                    WHEN @Lc_DhldCur_TypeDisburse_CODE = @Lc_DisbursementTypeChive_CODE
                     THEN @Lc_DisbursementTypeCxive_CODE
                    ELSE @Lc_DisbursementTypeAxive_CODE
                   END,                                                                       -- TypeDisburse_CODE
                   @Lc_CheckRecipientIve999999993_ID,                                                  -- CheckRecipient_ID         
                   @Lc_RecipientTypeOthp_CODE,                                                -- CheckRecipient_CODE       
                   @Lc_Yes_INDC,                                                              -- ProcessOffset_INDC        
                   @Lc_ReasonStatusDr_CODE,                                                   -- ReasonStatus_CODE         
                   @Ln_DhldCur_EventGlobalSupportSeq_NUMB,                                    -- EventGlobalSupportSeq_NUMB
                   @Ld_Run_DATE,                                                              -- BeginValidity_DATE        
                   @Ld_High_DATE,                                                             -- EndValidity_DATE          
                   @Ln_EventGlobalSeq_NUMB,                                                   -- EventGlobalBeginSeq_NUMB  
                   0,                                                                         -- EventGlobalEndSeq_NUMB    
                   @Ld_Low_DATE,                                                              -- Disburse_DATE             
                   0,                                                                         -- DisburseSeq_NUMB          
                   @Ld_High_DATE,                                                             -- StatusEscheat_DATE        
                   @Lc_Space_TEXT);                                                           -- StatusEscheat_CODE        

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y12 FAILED';

            RAISERROR (50001,16,1);
           END

          IF @Lc_InsertEsem_INDC = @Lc_No_INDC
           BEGIN
           SET @Ls_Sql_TEXT = 'INSERT ESEM_Y1 - 3';
           SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS  VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_FosterCareDistribution1835_NUMB AS VARCHAR);
            INSERT INTO ESEM_Y1
                        (TypeEntity_CODE,
                         EventGlobalSeq_NUMB,
                         EventFunctionalSeq_NUMB,
                         Entity_ID)
            (SELECT p.TypeEntity_CODE,
                    @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                    @Li_FosterCareDistribution1835_NUMB AS EventFunctionalSeq_NUMB,
                    p.Entity_ID
               FROM #EsemDist_P1 p);

            SET @Lc_InsertEsem_INDC = @Lc_Yes_INDC;
           END
         END
       END
      ELSE
       BEGIN
        --Hold the DHLD_Y1 records if there are no existing IVMG records for the IVE Case
        IF @Lc_DhldCur_TypeHold_CODE != @Lc_RegularHoldD_CODE
         BEGIN
          GOTO lx_nextrec;
         END

        SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y13';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_DhldCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Receipt_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_Ivef_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusHeldH_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_FcHoldE_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_DhldCur_TypeDisburse_CODE,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_DhldCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_DhldCur_CheckRecipient_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSdfg_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');
        INSERT DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                SourceBatch_CODE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                Transaction_DATE,
                Release_DATE,
                Transaction_AMNT,
                Status_CODE,
                TypeHold_CODE,
                TypeDisburse_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                EventGlobalSupportSeq_NUMB,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
        VALUES (@Ln_DhldCur_Case_IDNO,                        -- Case_IDNO                 
                @Ln_DhldCur_OrderSeq_NUMB,                    -- OrderSeq_NUMB             
                @Ln_DhldCur_ObligationSeq_NUMB,               -- ObligationSeq_NUMB        
                @Ld_DhldCur_Batch_DATE,                       -- Batch_DATE                
                @Lc_DhldCur_SourceBatch_CODE,                 -- SourceBatch_CODE          
                @Ln_DhldCur_Batch_NUMB,                       -- Batch_NUMB                
                @Ln_DhldCur_SeqReceipt_NUMB,                  -- SeqReceipt_NUMB           
                @Ld_Run_DATE,                                 -- Transaction_DATE          
                @Ld_DhldCur_Receipt_DATE,                     -- Release_DATE              
                @Ln_Ivef_AMNT,                                -- Transaction_AMNT          
                @Lc_DisbursementStatusHeldH_CODE,             -- Status_CODE               
                @Lc_FcHoldE_CODE,                             -- TypeHold_CODE             
                @Lc_DhldCur_TypeDisburse_CODE,                -- TypeDisburse_CODE         
                @Lc_DhldCur_CheckRecipient_ID,                -- CheckRecipient_ID         
                @Lc_DhldCur_CheckRecipient_CODE,              -- CheckRecipient_CODE       
                @Lc_Yes_INDC,                                 -- ProcessOffset_INDC        
                @Lc_ReasonStatusSdfg_CODE,                    -- ReasonStatus_CODE         
                @Ln_DhldCur_EventGlobalSupportSeq_NUMB,       -- EventGlobalSupportSeq_NUMB
                @Ld_Run_DATE,                                 -- BeginValidity_DATE        
                @Ld_High_DATE,                                -- EndValidity_DATE          
                @Ln_EventGlobalSeq_NUMB,                      -- EventGlobalBeginSeq_NUMB  
                0,                                            -- EventGlobalEndSeq_NUMB    
                @Ld_Low_DATE,                                 -- Disburse_DATE             
                0,                                            -- DisburseSeq_NUMB          
                @Ld_High_DATE,                                -- StatusEscheat_DATE        
                @Lc_Space_TEXT);                              -- StatusEscheat_CODE        

        SET @Li_Rowcount_QNTY = @@ROWCOUNT;

        IF @Li_Rowcount_QNTY = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y13 FAILED';

          RAISERROR (50001,16,1);
         END
		SET @Ls_Sql_TEXT = 'INSERT ESEM_Y1 - 4';
        SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS  VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_FosterCareDistribution1835_NUMB AS VARCHAR);
        INSERT INTO ESEM_Y1
                    (TypeEntity_CODE,
                     EventGlobalSeq_NUMB,
                     EventFunctionalSeq_NUMB,
                     Entity_ID)
        (SELECT p.TypeEntity_CODE,
                @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                @Li_FosterCareDistributionHold1845_NUMB AS EventFunctionalSeq_NUMB,
                p.Entity_ID
           FROM #EsemHold_P1 p);
       END

      UPDATE_DHLD: ;
	  --Do logical update on a previously held record
      SET @Ls_Sql_TEXT = 'UPDATE DHLD_Y1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_DhldCur_Transaction_DATE AS VARCHAR ),'')+ ', Unique_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Unique_IDNO AS VARCHAR ),'');
      UPDATE DHLD_Y1
         SET EndValidity_DATE = @Ld_Run_DATE,
             EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
       WHERE Case_IDNO = @Ln_DhldCur_Case_IDNO
         AND OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB
         AND ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
         AND Transaction_DATE = @Ld_DhldCur_Transaction_DATE
         AND Unique_IDNO = @Ln_DhldCur_Unique_IDNO;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;

      IF @Li_Rowcount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE_DHLD_Y1 FAILED';

        RAISERROR (50001,16,1);
       END

      LX_NEXTREC:
      
    END TRY
    
    BEGIN CATCH
     
     IF XACT_STATE() = 1
      BEGIN
       ROLLBACK TRANSACTION SaveFCDistTran;
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
        SET @Lc_TypeError_CODE = @Lc_TypeErrorE_CODE;
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
    
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION FCDistTran;
	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       BEGIN TRANSACTION FCDistTran;

       SET @Ln_CommitFreq_QNTY = 0;
      END
    
     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION FCDistTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END
            
      SET @Ls_Sql_TEXT = 'FETCH DhldCur - 2';
	  SET @Ls_Sqldata_TEXT = '';	 
      FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Seq_IDNO, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ld_DhldCur_Receipt_DATE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ln_DhldCur_TransactionCurSup_AMNT, @Ln_DhldCur_TransactionIvef_AMNT, @Lc_DhldCur_TypeDisburse_CODE, @Ln_DhldCur_EventGlobalBeginSeq_NUMB, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Lc_DhldCur_TypeHold_CODE, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Transaction_DATE;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Dhld_CUR;

   DEALLOCATE Dhld_CUR;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION FCDistTran; -- 1
  END TRY

  BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FCDistTran;
    END
  
   IF CURSOR_STATUS ('local', 'Dhld_CUR') IN (0, 1)
    BEGIN
     CLOSE Dhld_CUR;

     DEALLOCATE Dhld_CUR;
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
