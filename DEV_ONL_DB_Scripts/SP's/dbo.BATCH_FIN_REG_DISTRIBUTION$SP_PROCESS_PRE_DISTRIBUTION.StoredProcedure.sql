/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_PRE_DISTRIBUTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_PRE_DISTRIBUTION
Programmer Name 	: IMP Team
Description			: This procedure loads all the records to be processed by distribution into
					  'PDIST_Y1' (PDIST_Y1). Also it inserts the number of records to be
					  processed by each thread in JRTL_Y1(JRTL_Y1).
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_PRE_DISTRIBUTION]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Ln_Threads_QNTY                           NUMERIC(5) = 1,
           @Ln_BeginSno_NUMB                          NUMERIC(15) = 1,
           @Lc_StatusSuccess_CODE                     CHAR(1) = 'S',
           @Lc_Space_TEXT                             CHAR(1) = ' ',
           @Lc_No_INDC                                CHAR(1) = 'N',
           @Lc_StatusReceiptIdentified_CODE           CHAR(1) = 'I',
           @Lc_BatchStatusReconciled_CODE             CHAR(1) = 'R',
           @Lc_Yes_INDC                               CHAR(1) = 'Y',
           @Lc_StatusAbnormalend_CODE                 CHAR(1) = 'A',
           @Lc_SourceReceiptDirectPaymentCreditCD_CODE CHAR(2) = 'CD',
           @Lc_SourceReceiptCpRecoupmentCR_CODE       CHAR(2) = 'CR',
           @Lc_SourceReceiptCpFeeCF_CODE			  CHAR(2) = 'CF',
           @Lc_PreDistJob_ID                          CHAR(7) = 'DEB1270',
           @Lc_ProcessRdist_ID                        CHAR(10) = 'DEB0560',
           @Lc_Successful_TEXT                        CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT                      CHAR(30) = 'BATCH',
           @Ls_Process_NAME							  VARCHAR(100) = 'BATCH_FIN_REG_DISTRIBUTION',
           @Ls_Procedure_NAME                         VARCHAR(100) = 'SP_PROCESS_PRE_DISTRIBUTION',
           @Ls_DistListKey_TEXT                       VARCHAR(1000) = ' ',
           @Ld_Low_DATE                               DATE = '01/01/0001',
           @Ld_High_DATE                              DATE = '12/31/9999';
  DECLARE  @Ln_CommitFreqParm_QNTY          NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
           @Ln_ThreadNext_QNTY              NUMERIC(6) = 0,
           @Ln_Total_QNTY                   NUMERIC(6) = 0,
           @Ln_ThreadAvg_QNTY               NUMERIC(6) = 0,
           @Ln_ProcessedRecordCount_QNTY    NUMERIC(6) = 0,
           @Ln_Cursor_QNTY                  NUMERIC(10) = 0,
           @Ln_Error_NUMB                   NUMERIC(11),
           @Ln_ErrorLine_NUMB               NUMERIC(11),
           @Ln_EndSno_NUMB                  NUMERIC(15) = 0,
           @Ln_PdistRecordCount_NUMB        NUMERIC(15) = 0,
           @Ln_JrtlMaxRecEnd_NUMB			NUMERIC(15) = 0,
           @Ln_ParmThreads_QNTY             NUMERIC(5) = 1,
           @Li_Count_QNTY                   INT = 0,
           @Li_LoopThreadsCount_QNTY        INT = 0,
           @Lc_Msg_CODE                     CHAR(1),
           @Lc_NoSpace_TEXT                 CHAR(1) = '',
           @Ls_Sql_TEXT                     VARCHAR(1000) = '',
           @Ls_Sqldata_TEXT                 VARCHAR(2000) = '',
           @Ls_ErrorMessage_TEXT            VARCHAR(4000),
           @Ls_DescriptionError_TEXT        NVARCHAR(4000),
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE,
           @Ld_Start_DATE                   DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';   
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_PreDistJob_ID,'');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_PreDistJob_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT NUMBER OF THREAD FROM PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', EndValidity_DATE = ' + ISNULL( CAST(@Ld_High_DATE AS VARCHAR),'');

   SELECT @Ln_Threads_QNTY = a.Thread_NUMB
     FROM PARM_Y1 a
    WHERE a.Job_ID = @Lc_ProcessRdist_ID
      AND a.EndValidity_DATE =  @Ld_High_DATE;

	SET @Ln_ParmThreads_QNTY = @Ln_Threads_QNTY;

   IF @Ln_Threads_QNTY <= 0
    BEGIN
     --Assigned Thread COUNT to 1 if no thread details is available
     SET @Ln_Threads_QNTY = 1;
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM JOB_MULTI_THREADS_RESTART';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

   DELETE JRTL_Y1
    WHERE Job_ID = @Lc_ProcessRdist_ID
      AND Run_DATE = @Ld_Run_DATE;

   BEGIN TRANSACTION PreDistTran; -- 1
   SET @Ls_Sql_TEXT = 'DELETE FROM PDIST_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM PDIST_Y1;

   SET @Ls_Sql_TEXT = 'INSERT FOR PDIST_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT PDIST_Y1
          (RecordRowNumber_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           SourceReceipt_CODE,
           TypePosting_CODE,
           Case_IDNO,
           PayorMCI_IDNO,
           ToDistribute_AMNT,
           Receipt_DATE,
           Check_NUMB,
           Tanf_CODE,
           TaxJoint_CODE,
           EventGlobalBeginSeq_NUMB,
           ReleasedFrom_CODE,
           AutomaticRelease_INDC,
           Process_CODE)
   SELECT e.Row_NUMB,
          e.Batch_DATE,
          e.SourceBatch_CODE,
          e.Batch_NUMB,
          e.SeqReceipt_NUMB,
          e.SourceReceipt_CODE,
          e.TypePosting_CODE,
          e.Case_IDNO,
          e.PayorMCI_IDNO,
          e.ToDistribute_AMNT,
          e.Receipt_DATE,
          e.CheckNo_TEXT,
          e.Tanf_CODE,
          e.TaxJoint_CODE,
          e.EventGlobalBeginSeq_NUMB,
          e.ReleasedFrom_CODE,
          e.AutomaticRelease_INDC,
          @Lc_No_INDC AS Process_CODE
     FROM (SELECT Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceReceipt_CODE,
                  TypePosting_CODE,
                  Case_IDNO,
                  PayorMCI_IDNO,
                  ToDistribute_AMNT,
                  Receipt_DATE,
                  CheckNo_TEXT,
                  Tanf_CODE,
                  TaxJoint_CODE,
                  EventGlobalBeginSeq_NUMB,
                  ReleasedFrom_CODE,
                  AutomaticRelease_INDC,
                  ROW_NUMBER () OVER (ORDER BY rnm) AS Row_NUMB
             FROM (SELECT c.Batch_DATE,
                          c.SourceBatch_CODE,
                          c.Batch_NUMB,
                          c.SeqReceipt_NUMB,
                          c.SourceReceipt_CODE,
                          c.TypePosting_CODE,
                          c.Case_IDNO,
                          c.PayorMCI_IDNO,
                          c.ToDistribute_AMNT,
                          c.Receipt_DATE,
                          c.CheckNo_TEXT,
                          c.Tanf_CODE,
                          c.TaxJoint_CODE,
                          c.EventGlobalBeginSeq_NUMB,
                          c.ReleasedFrom_CODE,
                          c.AutomaticRelease_INDC,
                          0 AS rnm
                     FROM (SELECT a.Batch_DATE,
                                  a.SourceBatch_CODE,
                                  a.Batch_NUMB,
                                  a.SeqReceipt_NUMB,
                                  a.SourceReceipt_CODE,
                                  a.TypePosting_CODE,
                                  a.Case_IDNO,
                                  a.PayorMCI_IDNO,
                                  a.ToDistribute_AMNT,
                                  a.Receipt_DATE,
                                  0 CheckNo_TEXT,
                                  a.Tanf_CODE,
                                  a.TaxJoint_CODE,
                                  a.EventGlobalBeginSeq_NUMB,
                                  ISNULL (a.ReasonStatus_CODE, @Lc_Space_TEXT) AS ReleasedFrom_CODE,
                                  @Lc_No_INDC AS AutomaticRelease_INDC
                             FROM RCTH_Y1 a,
                                  RBAT_Y1 b
                            WHERE a.Distribute_DATE = @Ld_Low_DATE
                              AND a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                              AND a.EndValidity_DATE = @Ld_High_DATE
                              AND a.Batch_DATE <= @Ld_Run_DATE
                              AND a.Receipt_DATE <= @Ld_Run_DATE
                              AND a.Release_DATE <= @Ld_Run_DATE
                              AND -- Direct Payment Credit, CP Recoupment, CP Fee payments are excluded
                              a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptDirectPaymentCreditCD_CODE, @Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeeCF_CODE)
                              AND a.Batch_DATE = b.Batch_DATE
                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                              AND a.Batch_NUMB = b.Batch_NUMB
                              AND b.StatusBatch_CODE = @Lc_BatchStatusReconciled_CODE
                              AND b.EndValidity_DATE = @Ld_High_DATE
                           UNION
                           -- Include the SNFX, SNEX, SNAX RCTH_Y1 (which were Released by the Release RCTH_Y1) Also for distribution
                           SELECT a.Batch_DATE,
                                  a.SourceBatch_CODE,
                                  a.Batch_NUMB,
                                  a.SeqReceipt_NUMB,
                                  a.SourceReceipt_CODE,
                                  a.TypePosting_CODE,
                                  a.Case_IDNO,
                                  a.PayorMCI_IDNO,
                                  a.ToDistribute_AMNT,
                                  a.Receipt_DATE,
                                  0 Check_NUMB,
                                  a.Tanf_CODE,
                                  a.TaxJoint_CODE,
                                  a.EventGlobalBeginSeq_NUMB,
                                  ISNULL (a.ReasonStatus_CODE, @Lc_Space_TEXT) AS ReleasedFrom_CODE,
                                  @Lc_Yes_INDC AS AutomaticRelease_INDC
                             FROM PRREL_Y1 a) AS c) AS d) AS e
    ORDER BY e.PayorMCI_IDNO;

   SET @Ls_Sql_TEXT = 'SELECTING COUNT FROM PDIST_Y1';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_Total_QNTY = COUNT (1)
     FROM PDIST_Y1 p;

   IF @Ln_Total_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO RECORD(S) ELIGIBLE FOR DISTRIBUTION';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DIVIDING THE TOTAL RECORDS WITH THE NUMBER OF THREADS';
   SET @Ls_Sqldata_TEXT = 'Total COUNT = ' + CAST (@Ln_Total_QNTY AS VARCHAR) + ', Total threads = ' + CAST (@Ln_Threads_QNTY AS VARCHAR);
   
   SET @Ln_ThreadAvg_QNTY = (@Ln_Total_QNTY / @Ln_Threads_QNTY);
   SET @Ln_ThreadNext_QNTY = @Ln_ThreadAvg_QNTY;

   -- Pdist Record count is less than Dist Thread Count Total then Assign Thread Count value as 1
   IF @Ln_ThreadAvg_QNTY = 0
    BEGIN
     SET @Ln_Threads_QNTY = 1;
    END

   SET @Ls_DistListKey_TEXT = 'TOTAL THREAD COUNT = ' + CAST (@Ln_Threads_QNTY AS VARCHAR) + ', TOTAL RECORD COUNT = ' + CAST (@Ln_Total_QNTY AS VARCHAR) + ', AVG THREAD COUNT = ' + CAST (@Ln_ThreadNext_QNTY AS VARCHAR);
   SET @Ls_Sql_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO JRTL_Y1';
   SET @Ls_Sqldata_TEXT = '';
   
   IF @Ln_Threads_QNTY = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Thread_NUMB = ' + ISNULL(CAST(1 AS VARCHAR),'') + ', RecStart_NUMB = ' + ISNULL(CAST(1 AS VARCHAR),'') + ', RecEnd_NUMB = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR),'') + ', RestartKey_TEXT = ' + ISNULL(' ','')+ ', RecRestart_NUMB = ' + ISNULL(CAST(1 AS VARCHAR),'')+ ', ThreadProcess_CODE = ' + ISNULL(@Lc_No_INDC,'');

     INSERT JRTL_Y1
            (Job_ID,
             Run_DATE,
             Thread_NUMB,
             RecStart_NUMB,
             RecEnd_NUMB,
             RestartKey_TEXT,
             RecRestart_NUMB,
             ThreadProcess_CODE)
     VALUES (@Lc_ProcessRdist_ID,    --Job_ID
             @Ld_Run_DATE,    --Run_DATE
             1,    --Thread_NUMB
             1,    --RecStart_NUMB
             @Ln_Total_QNTY,    --RecEnd_NUMB
             ' ',    --RestartKey_TEXT
             1,    --RecRestart_NUMB
             @Lc_No_INDC  --ThreadProcess_CODE
			); 

     SET @Ls_DistListKey_TEXT = @Ls_DistListKey_TEXT + ' THREAD NUMBER = ' + '1 ' + 'STARTING THREAD VALUE = ' + '1 ' + 'ENDING THREAD VALUE = ' + CAST (@Ln_Total_QNTY AS VARCHAR);

    -- INSERTING @Ln_BeginSno_NUMB = 0, @Ln_EndSno_NUMB = 0 for thread numbers from 2 to 8 
		BEGIN
			 SET @Li_Count_QNTY = 2;

		--LOOP STARTED
			 WHILE @Li_Count_QNTY <= @Ln_ParmThreads_QNTY
			  BEGIN

				SET @Ln_BeginSno_NUMB = 0
				SET @Ln_EndSno_NUMB = 0
				        
			   SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1 - 1.1';
			   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Thread_NUMB = ' + ISNULL(CAST( @Li_Count_QNTY AS VARCHAR ),'')+ ', RecStart_NUMB = ' + ISNULL(CAST( @Ln_BeginSno_NUMB AS VARCHAR ),'')+ ', RecEnd_NUMB = ' + ISNULL(CAST( @Ln_EndSno_NUMB AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(' ','')+ ', RecRestart_NUMB = ' + ISNULL(CAST( @Ln_BeginSno_NUMB AS VARCHAR ),'')+ ', ThreadProcess_CODE = ' + ISNULL(@Lc_No_INDC,'');

			   INSERT JRTL_Y1
					  (Job_ID,
					   Run_DATE,
					   Thread_NUMB,
					   RecStart_NUMB,
					   RecEnd_NUMB,
					   RestartKey_TEXT,
					   RecRestart_NUMB,
					   ThreadProcess_CODE)
			   VALUES (@Lc_ProcessRdist_ID,    --Job_ID
					   @Ld_Run_DATE,    --Run_DATE
					   @Li_Count_QNTY,    --Thread_NUMB
					   @Ln_BeginSno_NUMB,    --RecStart_NUMB
					   @Ln_EndSno_NUMB,    --RecEnd_NUMB
					   ' ',    --RestartKey_TEXT
					   @Ln_BeginSno_NUMB,    --RecRestart_NUMB
					   @Lc_No_INDC  --ThreadProcess_CODE
					   ); 

				SET @Ls_DistListKey_TEXT = @Ls_DistListKey_TEXT + ' THREAD NUMBER = ' + CAST (@Li_Count_QNTY AS VARCHAR) + ' STARTING THREAD VALUE = ' + CAST (@Ln_BeginSno_NUMB AS VARCHAR) + ' ENDING THREAD VALUE = ' + CAST (@Ln_EndSno_NUMB AS VARCHAR);
			
			SET @Li_Count_QNTY = @Li_Count_QNTY + 1;
			
			END 
		END	         
    END
   ELSE
    BEGIN
     SET @Li_Count_QNTY = 1;
     SET @Li_LoopThreadsCount_QNTY = @Ln_Threads_QNTY;
--LOOP STARTED
     WHILE @Li_Count_QNTY <= @Li_LoopThreadsCount_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT PDIST_Y1 ';
       SET @Ls_Sqldata_TEXT = 'RecordRowNumber_NUMB = ' + ISNULL(CAST( @Ln_ThreadNext_QNTY AS VARCHAR ),'');

       SELECT @Ln_EndSno_NUMB = MAX (p.RecordRowNumber_NUMB)
         FROM PDIST_Y1 p
        WHERE p.PayorMCI_IDNO IN (SELECT d.PayorMCI_IDNO
                                    FROM PDIST_Y1 d
                                   WHERE d.RecordRowNumber_NUMB = @Ln_ThreadNext_QNTY);

       --If the @Li_Count_QNTY is last thread then assign the total records COUNT to end sequence no
       IF @Li_Count_QNTY = @Ln_Threads_QNTY
        BEGIN
         SET @Ln_EndSno_NUMB = @Ln_Total_QNTY;
        END
		
	   SET @Ls_Sql_TEXT = 'SELECT PDIST_Y1 -2 ';
	   SET @Ls_Sqldata_TEXT = '';
	   SELECT @Ln_PdistRecordCount_NUMB = COUNT(1)
	   FROM PDIST_Y1 p
	   
	   SET @Ls_Sql_TEXT = 'SELECT JRTL_Y1 -1 ';
	   SET @Ls_Sqldata_TEXT = '';
	   SELECT @Ln_JrtlMaxRecEnd_NUMB = MAX(RecEnd_NUMB)
	   FROM JRTL_Y1 p
	   WHERE Job_ID = @Lc_ProcessRdist_ID
		AND Run_DATE = @Ld_Run_DATE;
	   
		IF @Ln_PdistRecordCount_NUMB = @Ln_JrtlMaxRecEnd_NUMB
		BEGIN
				SET @Ln_BeginSno_NUMB = 0
				SET @Ln_EndSno_NUMB = 0
		END
		        
       SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1 - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Thread_NUMB = ' + ISNULL(CAST( @Li_Count_QNTY AS VARCHAR ),'')+ ', RecStart_NUMB = ' + ISNULL(CAST( @Ln_BeginSno_NUMB AS VARCHAR ),'')+ ', RecEnd_NUMB = ' + ISNULL(CAST( @Ln_EndSno_NUMB AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(' ','')+ ', RecRestart_NUMB = ' + ISNULL(CAST( @Ln_BeginSno_NUMB AS VARCHAR ),'')+ ', ThreadProcess_CODE = ' + ISNULL(@Lc_No_INDC,'');

       INSERT JRTL_Y1
              (Job_ID,
               Run_DATE,
               Thread_NUMB,
               RecStart_NUMB,
               RecEnd_NUMB,
               RestartKey_TEXT,
               RecRestart_NUMB,
               ThreadProcess_CODE)
       VALUES (@Lc_ProcessRdist_ID,    --Job_ID
               @Ld_Run_DATE,    --Run_DATE
               @Li_Count_QNTY,    --Thread_NUMB
               @Ln_BeginSno_NUMB,    --RecStart_NUMB
               @Ln_EndSno_NUMB,    --RecEnd_NUMB
               ' ',    --RestartKey_TEXT
               @Ln_BeginSno_NUMB,    --RecRestart_NUMB
               @Lc_No_INDC  --ThreadProcess_CODE
			   ); 

		SET @Ls_DistListKey_TEXT = @Ls_DistListKey_TEXT + ' THREAD NUMBER = ' + CAST (@Li_Count_QNTY AS VARCHAR) + ' STARTING THREAD VALUE = ' + CAST (@Ln_BeginSno_NUMB AS VARCHAR) + ' ENDING THREAD VALUE = ' + CAST (@Ln_EndSno_NUMB AS VARCHAR);

       --The beginning sequence will be next value for each thread
       SET @Ln_BeginSno_NUMB = @Ln_EndSno_NUMB + 1;
       --The next thread COUNT is calculated by adding the last sequence no and thread COUNT
       SET @Ln_ThreadNext_QNTY = @Ln_EndSno_NUMB + @Ln_ThreadAvg_QNTY;

       --If ln_thread_next_COUNTis greater than ln_total_COUNT then assign ln_total_COUNT to ls_end_sno.
       --This if condition will happen only when same NcpMci_IDNO falls in different thread COUNTs and
       --if thread COUNT is final.
       IF @Ln_ThreadNext_QNTY > @Ln_Total_QNTY
        BEGIN
         SET @Ln_ThreadNext_QNTY = @Ln_Total_QNTY;
        END

       SET @Li_Count_QNTY = @Li_Count_QNTY + 1;
      END
    END

   SET @Ls_Sql_TEXT = 'SELECT PDIST_Y1';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM PDIST_Y1 a;
     	
   -- Update the daily_date field for this procedure in PARM_Y1 table with the Run_DATE value
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_PreDistJob_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_PreDistJob_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_PreDistJob_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_NoSpace_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_DistListKey_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_NoSpace_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_PreDistJob_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_NoSpace_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Ls_DistListKey_TEXT,
    @As_DescriptionError_TEXT = @Lc_NoSpace_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION PreDistTran; -- 1
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PreDistTran; -- 1
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
   ELSE
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
    @Ac_Job_ID                = @Lc_PreDistJob_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ln_Cursor_QNTY,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END

GO
