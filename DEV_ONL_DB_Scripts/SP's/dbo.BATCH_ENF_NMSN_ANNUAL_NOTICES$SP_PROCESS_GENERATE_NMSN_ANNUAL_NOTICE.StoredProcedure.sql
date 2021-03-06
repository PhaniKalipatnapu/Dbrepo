/****** Object:  StoredProcedure [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_GENERATE_NMSN_ANNUAL_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_GENERATE_NMSN_ANNUAL_NOTICE
Programmer Name 	: IMP Team
Description			: This process is used to create the notice ENF-13 for the the members who are ordered to provide
						insurance.
Frequency			: 'ANNUAL'
Developed On		: 01/05/2012
Called By			:
Called On			: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK, BATCH_COMMON$SP_GET_THREAD_DETAILS,
					  BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG, BATCH_COMMON$SP_BATE_LOG and BATCH_COMMON$SP_BSTL_LOG.
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_GENERATE_NMSN_ANNUAL_NOTICE]
 @An_Thread_NUMB NUMERIC(15)
AS
 BEGIN
  DECLARE @Lc_Space_TEXT                CHAR(1)		= ' ',
          @Lc_No_INDC                   CHAR(1)		= 'N',
          @Lc_FailedStatus_CODE         CHAR(1)		= 'F',
          @Lc_SuccessStatus_CODE        CHAR(1)		= 'S',
          @Lc_ThreadLocked_INDC			CHAR(1)		= 'L',
          @Lc_AbnormalEndStatus_CODE    CHAR(1)		= 'A',
          @Lc_Yes_TEXT                  CHAR(1)		= 'Y',
          @Lc_TypeErrorE_CODE           CHAR(1)		= 'E',
          @Lc_StatusNoticeP_CODE        CHAR(1)		= 'P',
          @Lc_StatusNoticeC_CODE		CHAR(1)		= 'C',
          @Lc_Null_TEXT                 CHAR(1)		= '',
          @Lc_EnforcementSubsystem_CODE CHAR(2)		= 'EN',
          @Lc_CaseActivityMajor_CODE    CHAR(4)		= 'CASE',
          @Lc_NopriNoticePrint_TEXT     CHAR(5)		= 'NOPRI',
          @Lc_ErrorBatch_CODE			CHAR(5)		= 'E1424',
          @Lc_ProcessJob_ID				CHAR(7)		= 'DEB8670',
          @Lc_PreJob_ID					CHAR(7)		= 'DEB8665',
          @Lc_Enf13Notice_ID            CHAR(8)		= 'ENF-13',
          @Lc_Successful_TEXT           CHAR(20)	= 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT      CHAR(30)	= 'PARM DATE PROBLEM',
          @Lc_BatchRunUser_TEXT         CHAR(30)	= 'BATCH',
          @Ls_Procedure_NAME            VARCHAR(60) = 'SP_PROCESS_GENERATE_NMSN_ANNUAL_NOTICE',
          @Ls_Process_NAME              VARCHAR(100)= 'BATCH_ENF_NMSN_ANNUAL_NOTICES';
          
  DECLARE @Ln_Error_NUMB					INT,
          @Ln_ErrorLine_NUMB				INT,
          @Li_Error_NUMB					INT			= 0,
          @Li_ErrorLine_NUMB				INT			= 0,
          @Li_NmrqStatus_QNTY				INT,
          @Ln_ExceptionThresholdParm_QNTY   NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY       NUMERIC(5)	= 0,
          @Ln_CommitCount_NUMB				NUMERIC(5),
          @Ln_CommitFreq_QNTY				NUMERIC(5)	= 0,
          @Ln_Topic_IDNO					NUMERIC(10),
          @Ln_CaseCur_QNTY					NUMERIC(10) = 0,
          @Ln_RowsUpdate_QNTY				NUMERIC(10),
          @Ln_RecStart_NUMB					NUMERIC(15),
		  @Ln_RecRestart_NUMB				NUMERIC(15),
		  @Ln_RecEnd_NUMB					NUMERIC(15),
          @Ln_TransactionEventSeq_NUMB		NUMERIC(19),
          @Ln_Seq_IDNO						NUMERIC(19),
          @Ls_ProcessFlag_INDC				CHAR(1),
          @Lc_Msg_CODE						CHAR(5),
          @Ls_CursorLoc_TEXT				VARCHAR(200),
          @Ls_RestartKey_TEXT				VARCHAR(200),
          @Ls_Sql_TEXT						VARCHAR(400),
          @Ls_SqlData_TEXT					VARCHAR(1000),
          @Ls_DescriptionError_TEXT			VARCHAR(4000),
          @Ld_Start_DATE					DATE,
          @Ld_Run_DATE						DATE,
          @Ld_LastRun_DATE					DATE;
	
			
	DECLARE @i$Case_IDNO					NUMERIC(6),
			@i$OthpEmployer_IDNO			NUMERIC(9),
			@i$MemberMci_IDNO				NUMERIC(10),
			@i$Seq_IDNO						NUMERIC(19),
			@i$InsuranceOrdered_CODE		CHAR(1),
			@i$CaseRelationship_CODE		CHAR(1),
			@i$Process_INDC					CHAR(1);		

  BEGIN TRY
   
   BEGIN TRANSACTION Notice_Main_Transaction;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS'
   SET @Ls_SqlData_TEXT = 'Job_ID : ' + ISNULL(@Lc_ProcessJob_ID, '') + ' PD_DT_RUN : ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(10)), '')

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_ProcessJob_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitCount_NUMB OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

	SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
	SET @Ls_SqlData_TEXT = ' Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') +', LastRun_DATE = '+ ISNULL (CAST (@Ld_LastRun_DATE AS VARCHAR (20)), '');

	IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
		BEGIN
			 SET @Ls_DescriptionError_TEXT = @Lc_ParmDateProblem_TEXT;
			 RAISERROR(50001,16,1);
		END

   SET @Ls_Sql_TEXT = 'NMSNPRE : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK'
   SET @Ls_SqlData_TEXT = 'Job_ID: ' + ISNULL(@Lc_PreJob_ID, '') + ' Run_DATE: ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(10)), '')

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_PreJob_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_SuccessStatus_CODE
    BEGIN
		 SET @Ls_Sql_TEXT = 'NMSNPRE : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED';
		 RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'NMSNGETTHRD : BATCH_COMMON$SP_GET_THREAD_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID: ' + ISNULL(@Lc_ProcessJob_ID, '') + ' Run_DATE: ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR (10)), '');

   EXECUTE BATCH_COMMON$SP_GET_THREAD_DETAILS
		@Ac_Job_ID                = @Lc_ProcessJob_ID,
		@Ad_Run_DATE              = @Ld_Run_DATE,
		@An_Thread_NUMB           = @An_Thread_NUMB,
		@An_RecRestart_NUMB       = @Ln_RecRestart_NUMB OUTPUT,
		@An_RecEnd_NUMB           = @Ln_RecEnd_NUMB OUTPUT,
		@An_RecStart_NUMB         = @Ln_RecStart_NUMB OUTPUT,
		@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_SuccessStatus_CODE
    BEGIN
		 SET @Ls_Sql_TEXT = 'NMSNGETTHRD : BATCH_COMMON$SP_GET_THREAD_DETAILS FAILED';
		 RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
			@Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
			@Ac_Process_ID               = @Lc_ProcessJob_ID,
			@Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
			@Ac_Note_INDC                = @Lc_No_INDC,
			@An_EventFunctionalSeq_NUMB  = 0,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

	IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
		BEGIN
			RAISERROR(50001,16,1);
		END
       
   DECLARE NmsnAnnualNotices_Cur CURSOR LOCAL FORWARD_ONLY FOR
    SELECT p.Seq_IDNO,
           p.Case_IDNO,
           p.MemberMci_IDNO,
           p.InsuranceOrdered_CODE,
           p.CaseRelationship_CODE,
           p.OthpEmployer_IDNO,
           p.Process_INDC
      FROM PNMSN_Y1 p
     WHERE p.Seq_IDNO >= @Ln_RecRestart_NUMB
       AND p.Seq_IDNO <= @Ln_RecEnd_NUMB
       AND p.Process_INDC IN (@Lc_No_INDC,@Lc_TypeErrorE_CODE) 
     ORDER BY p.Seq_IDNO

   OPEN NmsnAnnualNotices_Cur

   BEGIN
    FETCH NmsnAnnualNotices_Cur INTO @i$Seq_IDNO, @i$Case_IDNO, @i$MemberMci_IDNO, @i$InsuranceOrdered_CODE, @i$CaseRelationship_CODE, @i$OthpEmployer_IDNO, @i$Process_INDC

    WHILE @@FETCH_STATUS = 0
		BEGIN
			  BEGIN TRY
				SAVE TRANSACTION Notice_Cursor_Transaction;
				  SET @Ln_CaseCur_QNTY = @Ln_CaseCur_QNTY + 1;
				  SET @Ls_ProcessFlag_INDC = @Lc_TypeErrorE_CODE;
				  SET @Ln_Seq_IDNO = @i$Seq_IDNO;
				  SET @Lc_Msg_CODE = @Lc_ErrorBatch_CODE;
				  SET @Ls_CursorLoc_TEXT = ' NMSN NOTICE - CURSOR_COUNT - ' + ISNULL(CAST(@Ln_CaseCur_QNTY AS VARCHAR(MAX)), '');
				  SET @Ls_RestartKey_TEXT = 'Case_IDNO: ' + ISNULL(CAST(@i$Case_IDNO AS CHAR(6)), '');
				  SET @Ls_Sql_TEXT = 'NMRQ CHECK';

				  SELECT @Li_NmrqStatus_QNTY = COUNT(1)
					FROM NMRQ_Y1
				   WHERE Notice_ID = @Lc_Enf13Notice_ID
					 AND Case_IDNO = @i$Case_IDNO
					 AND Recipient_ID = @i$OthpEmployer_IDNO
					 AND StatusNotice_CODE NOT IN (@Lc_StatusNoticeP_CODE, @Lc_StatusNoticeC_CODE);
					 
					 

				  IF (@Li_NmrqStatus_QNTY = 0)
					   BEGIN
							SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_INSERT_ACTIVITY ';
							SET @Ls_SqlData_TEXT = ' Case_IDNO ' + ISNULL(CAST(@i$Case_IDNO AS VARCHAR(6)), '')
												 + ' MemberMci_IDNO ' + ISNULL(CAST(@i$MemberMci_IDNO AS VARCHAR(10)), '') 
												 + ' InsuranceOrdered_CODE ' + ISNULL (@i$InsuranceOrdered_CODE, '') 
												 + ' CaseRelationship_CODE ' + ISNULL(@i$CaseRelationship_CODE, '') 
												 + ' OthpEmployer_IDNO' + ISNULL(CAST(@i$OthpEmployer_IDNO AS VARCHAR(10)), '');

							EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
											 @An_Case_IDNO                = @i$Case_IDNO,
											 @An_MemberMci_IDNO           = @i$MemberMci_IDNO,
											 @Ac_ActivityMajor_CODE       = @Lc_CaseActivityMajor_CODE,
											 @Ac_ActivityMinor_CODE       = @Lc_NopriNoticePrint_TEXT,
											 @Ac_Subsystem_CODE           = @Lc_EnforcementSubsystem_CODE,
											 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
											 @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
											 @Ad_Run_DATE                 = @Ld_Run_DATE,
											 @Ac_Notice_ID                = @Lc_Enf13Notice_ID,
											 @An_OthpSource_IDNO          = @i$OthpEmployer_IDNO,
											 @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
											 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
											 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

							IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
							 BEGIN
								  RAISERROR(50001,16,1);
							 END

							SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
							SET @Ls_ProcessFlag_INDC = @Lc_Yes_TEXT;
					   END
				END TRY
				BEGIN CATCH
				
					IF XACT_STATE() = 1
						BEGIN
						   ROLLBACK TRANSACTION Notice_Cursor_Transaction;
						END
					ELSE
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
							RAISERROR( 50001 ,16,1);
						END
					
					SAVE TRANSACTION Notice_Cursor_Transaction;
					 
					 SET @Li_Error_NUMB = ERROR_NUMBER ();
					 SET @Li_ErrorLine_NUMB = ERROR_LINE ();
					 
					  IF @Li_Error_NUMB <> 50001
						  BEGIN
						   SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
						  END
						  
					 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
							  @As_Procedure_NAME        = @Ls_Procedure_NAME,
							  @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
							  @As_Sql_TEXT              = @Ls_Sql_TEXT,
							  @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
							  @An_Error_NUMB            = @Li_Error_NUMB,
							  @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
							  @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
							  
					SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 1';							  
							  
					 EXECUTE BATCH_COMMON$SP_BATE_LOG
							  @As_Process_NAME             = @Ls_Process_NAME,
							  @As_Procedure_NAME           = @Ls_Procedure_NAME,
							  @Ac_Job_ID                   = @Lc_ProcessJob_ID,
							  @Ad_Run_DATE                 = @Ld_Run_DATE,
							  @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
							  @An_Line_NUMB                = @Ln_CaseCur_QNTY,
							  @Ac_Error_CODE               = @Lc_Msg_CODE, 
							  @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT, 
							  @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
							  @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
							  @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;	
							  
					IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
					  BEGIN
						SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG FAILED 1';
						RAISERROR (50001,16,1);
					  END
					ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
					  BEGIN 
						SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
					  END
							
				END CATCH
				
			  SET @Ls_Sql_TEXT = 'NMSN02Z : BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG';
			  	
			  EXECUTE BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG
							   @An_Seq_IDNO              = @Ln_Seq_IDNO,
							   @Ac_Process_INDC          = @Ls_ProcessFlag_INDC,
							   @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
							   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

				IF @Lc_Msg_CODE != @Lc_SuccessStatus_CODE
				   BEGIN
						SET @Ls_Sql_TEXT = 'NMSN02Z : BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG FAILED';
						RAISERROR(50001,16,1);
				   END

			  IF (@Ln_CommitCount_NUMB <> 0 AND @Ln_CommitFreq_QNTY >= @Ln_CommitCount_NUMB)
			   BEGIN
					SET @Ls_Sql_TEXT = 'JRTL_Y1 UPDATE ';
					SET @Ls_SqlData_TEXT = 'PS_ID_JOB: ' + ISNULL(@Lc_ProcessJob_ID, '')
										+ ' PD_DT_RUN: ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '')
										+ ' AN_IN_THREAD_NO: ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR(20)), '');

					UPDATE a
					   SET a.RecRestart_NUMB = @Ln_Seq_IDNO + 1,
						   a.RestartKey_TEXT = @Ls_RestartKey_TEXT
					 FROM JRTL_Y1  AS a
						 WHERE a.Job_ID = @Lc_ProcessJob_ID
						   AND a.Run_DATE = @Ld_Run_DATE
						   AND a.Thread_NUMB = @An_Thread_NUMB;

					IF (@@TRANCOUNT = 0)
					 BEGIN
						  SET @Ls_Sql_TEXT = 'JRTL_Y1 UPDATE FAILED ';
						  RAISERROR(50001,16,1);
					 END

					SET @Ln_CommitFreq_QNTY = 0;
					COMMIT TRANSACTION Notice_Main_Transaction;
					BEGIN TRANSACTION Notice_Main_Transaction;
					
			   END
			   
			   /* If the Erroneous Exceptions are more than the threshold, then we need to
     			abend the program. The commit will ensure that the records processed so far without
     			any problems are committed. Also the exception entries are committed so
     			that it will be easy to determine the error records.*/
				 SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
				 SET @Ls_SqlData_TEXT = 'Excp_Count = ' + ISNULL(CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR(20)), '') + ', ExceptionThreshold_QNTY = ' + ISNULL(CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR(5)), '');

			  IF (@Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
					AND @Ln_ExceptionThresholdParm_QNTY > 0)
				   BEGIN
						COMMIT TRANSACTION Notice_Main_Transaction;
						SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
						RAISERROR(50001,16,1);
				   END
			  FETCH NmsnAnnualNotices_Cur INTO @i$Seq_IDNO, @i$Case_IDNO, @i$MemberMci_IDNO, @i$InsuranceOrdered_CODE, @i$CaseRelationship_CODE, @i$OthpEmployer_IDNO, @i$Process_INDC;
		-- End of While loop			  
		END		
	END

   CLOSE NmsnAnnualNotices_Cur

   DEALLOCATE NmsnAnnualNotices_Cur

   SELECT @Ln_RowsUpdate_QNTY = COUNT(1)
     FROM PNMSN_Y1
    WHERE Process_INDC = @Lc_No_INDC;

	IF @Ln_RowsUpdate_QNTY = 0
		BEGIN
		 SET @Ls_Sql_TEXT = 'NMSN020 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
		 SET @Ls_SqlData_TEXT = 'Job_ID: ' + ISNULL(@Lc_ProcessJob_ID, '') + ' Run_DATE: ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR (20)), '');

		 EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
					  @Ac_Job_ID                = @Lc_ProcessJob_ID,
					  @Ad_Run_DATE              = @Ld_Run_DATE,
					  @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
					  @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

			IF @Lc_Msg_CODE != @Lc_SuccessStatus_CODE
				BEGIN
					SET @Ls_Sql_TEXT = 'NMSN020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
					RAISERROR(50001,16,1);
				END
		END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';

   SET @Ls_Sql_TEXT = 'THREAD NO ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR(15)), '');

     EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE                  = @Ld_Run_DATE,
			@Ad_Start_DATE                = @Ld_Start_DATE,
			@Ac_Job_ID                    = @Lc_ProcessJob_ID,
			@As_Process_NAME              = @Ls_Process_NAME,
			@As_Procedure_NAME            = @Ls_Procedure_NAME,
			@As_CursorLocation_TEXT       = @Lc_Null_TEXT,
			@As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
			@As_ListKey_TEXT              = @Lc_Successful_TEXT,
			@As_DescriptionError_TEXT     = @Lc_Null_TEXT,
			@Ac_Status_CODE               = @Lc_SuccessStatus_CODE,
			@Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
			@An_ProcessedRecordCount_QNTY = @Ln_CaseCur_QNTY;

	IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION Notice_Main_Transaction;
		END   
  END TRY

  BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION Notice_Main_Transaction;
		END
        
    IF CURSOR_STATUS('Local', 'NmsnAnnualNotices_Cur') IN (0, 1)
    BEGIN
     CLOSE NmsnAnnualNotices_Cur;
     DEALLOCATE NmsnAnnualNotices_Cur;
    END
    
    --- Updating JRTL to ThreadProcess_CODE 'A' to restart the job again
     UPDATE JRTL_Y1
		SET  ThreadProcess_CODE = @Lc_AbnormalEndStatus_CODE
		FROM JRTL_Y1 AS a
		WHERE a.Job_ID = @Lc_ProcessJob_ID
		AND ThreadProcess_CODE = @Lc_ThreadLocked_INDC
		AND a.Run_DATE = @Ld_Run_DATE
		AND a.Thread_NUMB = @An_Thread_NUMB;
		
    
	SET @Lc_Msg_CODE = @Lc_FailedStatus_CODE;
	SET @Li_Error_NUMB = ERROR_NUMBER ();
	SET @Li_ErrorLine_NUMB = ERROR_LINE ();
	
	IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
    
    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
			@As_Procedure_NAME        = @Ls_Procedure_NAME,
			@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
			@As_Sql_TEXT              = @Ls_Sql_TEXT,
			@As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
			@An_Error_NUMB            = @Li_Error_NUMB,
			@An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
			@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE                  = @Ld_Run_DATE,
			@Ad_Start_DATE                = @Ld_Start_DATE,
			@Ac_Job_ID                    = @Lc_ProcessJob_ID,
			@As_Process_NAME              = @Ls_Process_NAME,
			@As_Procedure_NAME            = @Ls_Procedure_NAME,
			@As_CursorLocation_TEXT       = @Lc_Null_TEXT,
			@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
			@As_ListKey_TEXT              = @Ls_SqlData_TEXT,
			@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
			@Ac_Status_CODE               = @Lc_AbnormalEndStatus_CODE,
			@Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
			@An_ProcessedRecordCount_QNTY = @Ln_CaseCur_QNTY;    
   
   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
   
  END CATCH
 END


GO
