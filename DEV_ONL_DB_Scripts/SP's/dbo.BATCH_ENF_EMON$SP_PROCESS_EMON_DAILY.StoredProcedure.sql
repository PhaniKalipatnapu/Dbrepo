/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_EMON_DAILY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	: BATCH_ENF_EMON$SP_PROCESS_EMON_DAILY
Programmer Name : IMP Team
Description		: This process reads In-Progress activities from VDMNR table which are due
				  today/less than today and updates them with appropriate reason which is one among
				  the predefined reasons set for that activity in VANXT, Enforcement Exemption
				  approaching date and Income Withholding status change from Pending to Active approacing date .
Frequency		: 'DAILY'
Developed On	: 01/05/2012
Called By		: None
Called On	    : BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_GET_THREAD_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
				  BATCH_COMMON$SP_BATE_LOG, BATCH_COMMON$SP_BSTL_LOG and BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
--------------------------------------------------------------------------------------------------------------------
Modified BY		:
Modified On		:
Version No		: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_EMON_DAILY]
 @An_Thread_NUMB NUMERIC(15)
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_AdvanceTheChain5600_NUMB      INT				= 5600,
          @Lc_No_INDC                       CHAR(1)			= 'N',
          @Lc_StatusFailed_CODE             CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE            CHAR(1)			= 'S',
          @Lc_Yes_INDC                      CHAR(1)			= 'Y',
          @Lc_TypeErrorE_CODE               CHAR(1)			= 'E',
          @Lc_StatusAbnormalend_CODE        CHAR(1)			= 'A',
          @Lc_ThreadLocked_INDC				CHAR(1)			= 'L',
          @Lc_Space_TEXT                    CHAR(1)			= ' ',
          @Lc_Process_INDC                  CHAR(1)			= 'N',
          @Lc_ProcessEmon_ID                CHAR(4)			= 'EMON',
          @Lc_ErrorBate_CODE                CHAR(5)			= 'E1424',
          @Lc_Job_ID                        CHAR(7)			= 'DEB0670',
          @Lc_JobPre_ID						CHAR(7)			= 'DEB0664',
          @Lc_PackageNAME_TEXT              CHAR(30)		= 'BATCH_ENF_EMON',
          @Lc_BatchRunUser_ID               CHAR(30)		= 'BATCH',
          @Lc_ParmDateProblem_TEXT          CHAR(30)		= 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME                VARCHAR(50)		= 'SP_PROCESS_EMON_DAILY';
     
 DECLARE  @Li_FetchStatus_QNTY              SMALLINT,
		  @Ln_RecRestart_NUMB               NUMERIC,
          @Ln_RecEnd_NUMB                   NUMERIC,
          @Ln_RecStart_NUMB                 NUMERIC,                                                                                                                                                                                                                                                                                                                                                              
          @Ln_ExceptionThreshold_QNTY       NUMERIC(5)		= 0,   
          @Ln_ExceptionThresholdParm_QNTY   NUMERIC (5), 
          @Ln_CommitFreqParm_QNTY           NUMERIC (5),
          @Ln_TempUpdateCount_NUMB          NUMERIC(9)		= 0,
          @Ln_Error_NUMB                    NUMERIC(10),
          @Ln_ErrorLine_NUMB                NUMERIC(10),
          @Ln_CursorCount_NUMB              NUMERIC(10)		= 0,
          @Ln_CommitCount_NUMB              NUMERIC(10)		= 0,
          @Ln_TransactionEventSeq_NUMB      NUMERIC(19),
          @Lc_Msg_CODE                      CHAR(5),
          @Lc_ReasonStatus_CODE             CHAR(2),
          @Ls_SQL_TEXT                      VARCHAR(100),                   
          @Ls_RestartKey_TEXT               VARCHAR(200),  
          @Ls_SqlData_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT         VARCHAR(4000),
          @Ld_Run_DATE                      DATE,
          @Ld_LastRun_DATE                  DATE,
          @Ld_Start_DATE                    DATETIME2;
          
  DECLARE @Ln_EmonDailyCur_RecordRowNumber_NUMB     NUMERIC(11),
          @Ln_EmonDailyCur_Case_IDNO                NUMERIC(6),
          @Ln_EmonDailyCur_OrderSeq_NUMB            NUMERIC(5),
          @Ln_EmonDailyCur_OthpSource_IDNO          NUMERIC(10),
          @Ln_EmonDailyCur_MemberMci_IDNO           NUMERIC(10),
          @Ln_EmonDailyCur_MajorIntSeq_NUMB         NUMERIC(5),
          @Ln_EmonDailyCur_MinorIntSeq_NUMB         NUMERIC(11),
          @Ln_EmonDailyCur_Forum_IDNO               NUMERIC(19),
          @Ln_EmonDailyCur_Topic_IDNO               NUMERIC(19),
          @Ln_EmonDailyCur_Schedule_NUMB            NUMERIC(19),
          @Ln_EmonDailyCur_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_EmonDailyCur_Process_INDC             CHAR(1),
          @Lc_EmonDailyCur_ActivityMajor_CODE       CHAR(4),
          @Lc_EmonDailyCur_ActivityMinor_CODE       CHAR(5),
          @Lc_EmonDailyCur_Reference_ID             CHAR(30),
          @Ld_EmonDailyCur_Due_DATE                 DATE,
          @Ld_EmonDailyCur_Entered_DATE             DATETIME2;
          
    
  BEGIN TRY
   SET @Ls_SQL_TEXT = '';
   SET @Ls_SqlData_TEXT = '';
   BEGIN TRANSACTION Emon_Main_Transaction;
   
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Selecting date run, date last run, commit freq, exception threshold details --
   SET @Ls_SQL_TEXT = 'BATCH_COMMON$GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_SQL_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = ' Run_DATE = ' + CAST (@Ld_Run_DATE AS CHAR (10)) +', LastRun_DATE = '+ CAST (@Ld_LastRun_DATE AS CHAR (10));

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_ParmDateProblem_TEXT;
     SET @Ls_SQL_TEXT = @Lc_ParmDateProblem_TEXT;
     RAISERROR (50001,16,1);
    END

   SET @Ls_SQL_TEXT = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS CHAR (10)), '');
 
   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_JobPre_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'EMONPRE : BATCH_COMMON.SP_PREDECESSOR_JOB_CHECK FAILED';
     RAISERROR (50001,16,1);
    END

   SET @Ls_SQL_TEXT = 'BATCH_COMMON$SP_GET_THREAD_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS CHAR (10)), '');

   EXECUTE BATCH_COMMON$SP_GET_THREAD_DETAILS
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_Thread_NUMB           = @An_Thread_NUMB,
    @An_RecRestart_NUMB       = @Ln_RecRestart_NUMB OUTPUT,
    @An_RecEnd_NUMB           = @Ln_RecEnd_NUMB OUTPUT,
    @An_RecStart_NUMB         = @Ln_RecStart_NUMB OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'EMONGETTHRD : BATCH_COMMON$SP_GET_THREAD_DETAILS FAILED';

     RAISERROR (50001,16,1);
    END
            
   SET @Ls_SQL_TEXT = 'EMON004 : EMON DAILY CURSOR';
   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;
   --<< EMON CURSOR >>		
   DECLARE EmonDaily_CUR  INSENSITIVE CURSOR FOR
     SELECT RecordRowNumber_NUMB,
              Case_IDNO,
              OrderSeq_NUMB,
              OthpSource_IDNO,
              MemberMci_IDNO,
              ActivityMajor_CODE,
              ActivityMinor_CODE,
              MajorIntSEQ_NUMB,
              MinorIntSeq_NUMB,
              Forum_IDNO,
              Entered_DATE,
              TransactionEventSeq_NUMB,
              Reference_ID,
              Due_DATE,
              Topic_IDNO,
              Schedule_NUMB,
              Process_INDC
         FROM PEMON_Y1 p
        WHERE RecordRowNumber_NUMB >= @Ln_RecStart_NUMB
          AND RecordRowNumber_NUMB <= @Ln_RecEnd_NUMB
          AND Process_INDC = @Lc_No_INDC; 

   OPEN EmonDaily_CUR;
  
   FETCH NEXT FROM EmonDaily_CUR INTO @Ln_EmonDailyCur_RecordRowNumber_NUMB, @Ln_EmonDailyCur_Case_IDNO, @Ln_EmonDailyCur_OrderSeq_NUMB, @Ln_EmonDailyCur_OthpSource_IDNO, @Ln_EmonDailyCur_MemberMci_IDNO, @Lc_EmonDailyCur_ActivityMajor_CODE, @Lc_EmonDailyCur_ActivityMinor_CODE, @Ln_EmonDailyCur_MajorIntSeq_NUMB, @Ln_EmonDailyCur_MinorIntSeq_NUMB, @Ln_EmonDailyCur_Forum_IDNO, @Ld_EmonDailyCur_Entered_DATE, @Ln_EmonDailyCur_TransactionEventSeq_NUMB, @Lc_EmonDailyCur_Reference_ID, @Ld_EmonDailyCur_Due_DATE, @Ln_EmonDailyCur_Topic_IDNO, @Ln_EmonDailyCur_Schedule_NUMB, @Lc_EmonDailyCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   
   --WHILE LOOP BEGINS
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
   BEGIN TRY 
   
     SAVE TRANSACTION Emon_Cursor_Transaction;
     
     -- Incrementing the cursor count and the commit count for each record being processed.
     SET @Ln_CursorCount_NUMB = @Ln_CursorCount_NUMB + 1;
     SET @Ln_CommitCount_NUMB = @Ln_CommitCount_NUMB + 1;
     SET @Lc_Msg_CODE = @Lc_ErrorBate_CODE;
     SET @Lc_ReasonStatus_CODE = NULL;
     SET @Ls_RestartKey_TEXT = 'Case_IDNO: ' + CAST (@Ln_EmonDailyCur_Case_IDNO AS CHAR (6)) + ' OrderSeq_NUMB: ' + CAST (@Ln_EmonDailyCur_OrderSeq_NUMB AS VARCHAR (2)) + ' MajorIntSeq_NUMB: ' + CAST (@Ln_EmonDailyCur_MajorIntSeq_NUMB AS VARCHAR (10)) + ' MinorIntSeq_NUMB: ' + CAST (@Ln_EmonDailyCur_MinorIntSeq_NUMB AS VARCHAR (10));
     
     /*When the record is picked assigned error code to change the flag when the process not sucesses*/
     SET @Lc_Process_INDC = @Lc_TypeErrorE_CODE;
     
	 -- Process The In-Progress Activities STARTS
	 SET @Ls_SQL_TEXT = 'BATCH_ENF_EMON.SF_GET_REASON';
	 SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_EmonDailyCur_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@Ln_EmonDailyCur_OrderSeq_NUMB AS CHAR(2)) + ', MemberMci_IDNO = ' + CAST(@Ln_EmonDailyCur_MemberMci_IDNO AS VARCHAR(10)) + ', OthpSource_IDNO = ' + CAST(@Ln_EmonDailyCur_OthpSource_IDNO AS VARCHAR(10)) + ', ActivityMajor_CODE = ' + @Lc_EmonDailyCur_ActivityMajor_CODE + ', ActivityMinor_CODE = ' + @Lc_EmonDailyCur_ActivityMinor_CODE + ', MajorIntSeq_NUMB = ' + CAST(@Ln_EmonDailyCur_MajorIntSeq_NUMB AS VARCHAR(5)) + ', Entered_DATE = ' + CAST(@Ld_EmonDailyCur_Entered_DATE AS CHAR(10)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_EmonDailyCur_TransactionEventSeq_NUMB AS VARCHAR(19)) + ', Reference_ID = ' + @Lc_EmonDailyCur_Reference_ID;
	 SET @Lc_ReasonStatus_CODE = dbo.BATCH_ENF_EMON$SF_GET_REASON (@Ln_EmonDailyCur_Case_IDNO, @Ln_EmonDailyCur_OrderSeq_NUMB, @Ln_EmonDailyCur_MemberMci_IDNO, @Ln_EmonDailyCur_OthpSource_IDNO, @Lc_EmonDailyCur_ActivityMajor_CODE, @Lc_EmonDailyCur_ActivityMinor_CODE, @Ln_EmonDailyCur_MajorIntSeq_NUMB, @Ld_EmonDailyCur_Entered_DATE, @Ld_Run_DATE, @Ld_EmonDailyCur_Due_DATE, @Ln_EmonDailyCur_TransactionEventSeq_NUMB, @Lc_EmonDailyCur_Reference_ID);

     IF LTRIM(RTRIM(@Lc_ReasonStatus_CODE)) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'SP_PROCESS_EMON_DAILY : BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
       SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;

       /* The seq_txn_event generated now will be sued in all inserts and updates, which will be useful
       	to find the transaction */
       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_ID,
        @Ac_Process_ID               = @Lc_ProcessEmon_ID,
        @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = @Li_AdvanceTheChain5600_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_SQL_TEXT = 'SP_PROCESS_EMON_DAILY : BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_EmonDailyCur_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@Ln_EmonDailyCur_OrderSeq_NUMB AS VARCHAR(2)) + ', MemberMci_IDNO = ' + CAST(@Ln_EmonDailyCur_MemberMci_IDNO AS VARCHAR(10)) + ', OthpSource_IDNO = ' + CAST(@Ln_EmonDailyCur_OthpSource_IDNO AS VARCHAR(10)) + ', Forum_IDNO = ' + CAST(@Ln_EmonDailyCur_Forum_IDNO AS VARCHAR(11)) + ', ActivityMajor_CODE = ' + @Lc_EmonDailyCur_ActivityMajor_CODE + ', ActivityMinor_CODE = ' + @Lc_EmonDailyCur_ActivityMinor_CODE + ', ReasonStatus_CODE = ' + @Lc_ReasonStatus_CODE + ', MajorIntSEQ_NUMB = ' + CAST(@Ln_EmonDailyCur_MajorIntSeq_NUMB AS VARCHAR (5)) + ', MinorIntSEQ_NUMB = ' + CAST(@Ln_EmonDailyCur_MinorIntSeq_NUMB AS VARCHAR(5)) + ', Entered_DATE = ' + CAST(@Ld_EmonDailyCur_Entered_DATE AS CHAR(10)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR(19)) + ', Reference_ID = ' + @Lc_EmonDailyCur_Reference_ID;

       EXEC BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
        @An_Case_IDNO                = @Ln_EmonDailyCur_Case_IDNO,
        @An_OrderSeq_NUMB            = @Ln_EmonDailyCur_OrderSeq_NUMB,
        @An_MemberMci_IDNO           = @Ln_EmonDailyCur_MemberMci_IDNO,
        @An_Forum_IDNO               = @Ln_EmonDailyCur_Forum_IDNO,
        @An_Topic_IDNO               = @Ln_EmonDailyCur_Topic_IDNO,
        @An_MajorIntSeq_NUMB         = @Ln_EmonDailyCur_MajorIntSeq_NUMB,
        @An_MinorIntSeq_NUMB         = @Ln_EmonDailyCur_MinorIntSeq_NUMB,
        @Ac_ActivityMajor_CODE       = @Lc_EmonDailyCur_ActivityMajor_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_EmonDailyCur_ActivityMinor_CODE,
        @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_Process_ID               = @Lc_Job_ID,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
       SET @Lc_Process_INDC = @Lc_Yes_INDC;
     END
   END TRY
   BEGIN CATCH     
		IF XACT_STATE() = 1
		BEGIN
		   ROLLBACK TRANSACTION Emon_Cursor_Transaction;
		END
		ELSE
		BEGIN
			SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		END
		SAVE TRANSACTION Emon_Cursor_Transaction;
		
		SET @Ln_Error_NUMB = ERROR_NUMBER ();
		SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

	   IF (@Ln_Error_NUMB <> 50001)
		BEGIN
		 SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
		END
		
		
		IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			SET @Lc_Msg_CODE = @Lc_ErrorBate_CODE;
		END
		
		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
		@As_Sql_TEXT              = @Ls_Sql_TEXT,
		@As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
		@An_Error_NUMB            = @Ln_Error_NUMB,
		@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
		
		EXECUTE BATCH_COMMON$SP_BATE_LOG
		 @As_Process_NAME          = @Lc_PackageNAME_TEXT,
		 @As_Procedure_NAME        = @Ls_Procedure_NAME,
		 @Ac_Job_ID                = @Lc_Job_ID,
		 @Ad_Run_DATE              = @Ld_Run_DATE,
		 @Ac_TypeError_CODE        = @Lc_TypeErrorE_CODE,
		 @An_Line_NUMB             = @Ln_CursorCount_NUMB,
		 @Ac_Error_CODE            = @Lc_Msg_CODE,
		 @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
		 @As_ListKey_TEXT          = @Ls_SqlData_TEXT,
		 @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

	  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
		 RAISERROR (50001,16,1);
		END
	  -- 13570 EMON Batch Exception Threshold Logic	- Start
	  ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
	  -- 13570 EMON Batch Exception Threshold Logic	- End
		BEGIN
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		END
	END CATCH
		
   ---Update the process indicator in PEMON table
     EXEC BATCH_ENF_EMON$SP_PEMON_UPDATE_FLAG
      @An_RecordRowNumber_NUMB  = @Ln_EmonDailyCur_RecordRowNumber_NUMB,
      @Ac_Process_INDC          = @Lc_Process_INDC,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'SP_PEMON_UPDATE_FLAG FAILED : '+@Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;

     /*  If the commit frequency is attained, the following is done.
     Reset the commit count, Commit the transaction completed until now. */
     IF (@Ln_CommitCount_NUMB >= @Ln_CommitFreqParm_QNTY
     AND @Ln_CommitFreqParm_QNTY > 0)
      BEGIN
       SET @Ls_SQL_TEXT = 'JRTL_Y1 UPDATE ';
       SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) + ', Thread_NUMB = ' + CAST(@An_Thread_NUMB AS VARCHAR(5));

       UPDATE JRTL_Y1
          SET RecRestart_NUMB = @Ln_EmonDailyCur_RecordRowNumber_NUMB + 1,
              RestartKey_TEXT = @Ls_RestartKey_TEXT
         FROM JRTL_Y1 a
        WHERE a.Job_ID = @Lc_Job_ID
          AND a.Run_DATE = @Ld_Run_DATE
          AND a.Thread_NUMB = @An_Thread_NUMB;
      
       COMMIT TRANSACTION Emon_Main_Transaction;
	   BEGIN TRANSACTION Emon_Main_Transaction;	
       SET @Ln_CommitCount_NUMB = 0;
      END;

     /* If the Erroneous Exceptions are more than the threshold, then we need to
     	abend the program. The commit will ensure that the records processed so far without
     	any problems are committed. Also the exception entries are committed so
     	that it will be easy to determine the error records.*/
     SET @Ls_SQL_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_SqlData_TEXT = 'ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR(5)) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR(5));

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        AND @Ln_ExceptionThresholdParm_QNTY > 0
      BEGIN
       COMMIT TRANSACTION Emon_Main_Transaction;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM EmonDaily_CUR INTO @Ln_EmonDailyCur_RecordRowNumber_NUMB, @Ln_EmonDailyCur_Case_IDNO, @Ln_EmonDailyCur_OrderSeq_NUMB, @Ln_EmonDailyCur_OthpSource_IDNO, @Ln_EmonDailyCur_MemberMci_IDNO, @Lc_EmonDailyCur_ActivityMajor_CODE, @Lc_EmonDailyCur_ActivityMinor_CODE, @Ln_EmonDailyCur_MajorIntSeq_NUMB, @Ln_EmonDailyCur_MinorIntSeq_NUMB, @Ln_EmonDailyCur_Forum_IDNO, @Ld_EmonDailyCur_Entered_DATE, @Ln_EmonDailyCur_TransactionEventSeq_NUMB, @Lc_EmonDailyCur_Reference_ID, @Ld_EmonDailyCur_Due_DATE, @Ln_EmonDailyCur_Topic_IDNO, @Ln_EmonDailyCur_Schedule_NUMB, @Lc_EmonDailyCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END
 
    CLOSE EmonDaily_CUR;

     DEALLOCATE EmonDaily_CUR;
 
   -- Main Loop Neds
   SET @Ls_SQL_TEXT = 'SELECT PEMON';
   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;

   SELECT @Ln_TempUpdateCount_NUMB = COUNT(1)
     FROM PEMON_Y1 p
    WHERE Process_INDC = @Lc_No_INDC;

   --PARM date will be updated only if all the threads are completed.
   --The above check determines whether all records are processed thro the thread
   IF @Ln_TempUpdateCount_NUMB = 0
    BEGIN
     -- Update the daily_date field for this procedure in vparm table with the Run_DATE value
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
     SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

     EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED : '+@Ls_DescriptionError_TEXT;
       RAISERROR (50001,16,1);
      END;
    END

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Lc_PackageNAME_TEXT,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Space_TEXT,
    @As_ListKey_TEXT          = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_CursorCount_NUMB;
 
   COMMIT TRANSACTION Emon_Main_Transaction;

  END TRY

  BEGIN CATCH
   
   IF @@TRANCOUNT > 0
    BEGIN
	ROLLBACK TRANSACTION Emon_Main_Transaction;
    END

   IF CURSOR_STATUS('VARIABLE', 'EmonDaily_CUR') IN (0, 1)
    BEGIN
     CLOSE EmonDaily_CUR;

     DEALLOCATE EmonDaily_CUR;
    END
    
    --- Updating JRTL to ThreadProcess_CODE 'A' to restart the job again
     UPDATE JRTL_Y1
		SET  ThreadProcess_CODE = @Lc_StatusAbnormalend_CODE
		FROM JRTL_Y1 AS a
		WHERE a.Job_ID = @Lc_Job_ID
		AND ThreadProcess_CODE = @Lc_ThreadLocked_INDC
		AND a.Run_DATE = @Ld_Run_DATE
		AND a.Thread_NUMB = @An_Thread_NUMB;
    
    SET @Ln_Error_NUMB		= ERROR_NUMBER();
    SET @Ln_ErrorLine_NUMB	= ERROR_LINE();
    
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
                             @As_Procedure_NAME        = @Ls_Procedure_NAME,  
                             @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
                             @As_Sql_TEXT              = @Ls_Sql_TEXT,
                             @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
                             @An_Error_NUMB            = @Ln_Error_NUMB,
                             @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,  
                             @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;	

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Lc_PackageNAME_TEXT,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Ls_SQL_TEXT,
    @As_ListKey_TEXT          = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_CursorCount_NUMB;
	
   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END;


GO
