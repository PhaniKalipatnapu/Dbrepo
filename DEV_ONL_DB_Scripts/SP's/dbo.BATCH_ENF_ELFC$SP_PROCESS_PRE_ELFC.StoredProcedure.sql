/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_PROCESS_PRE_ELFC]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_PROCESS_PRE_ELFC]
/*
---------------------------------------------------------
 Procedure Name			: BATCH_ENF_ELFC$SP_PROCESS_PRE_ELFC
 Programmer Name		: IMP Team
 Description			: This process reads records which are eligible to start and close remedies and insert into process table.
 Frequency				: DAILY
 Developed On			: 07/07/2011
 Called By				: 
 Called On				: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_UPDATE_PARM_DATE,
						  and BATCH_COMMON$SP_BSTL_LOG
---------------------------------------------------------
 Modified By			:
 Modified On			:
 Version No				: 1.0 
---------------------------------------------------------
*/ 
AS
 BEGIN
  SET NOCOUNT ON;
    DECLARE @Ln_Counter_NUMB					NUMERIC			= 1,
			@Ln_Threads_QNTY					NUMERIC(9)		= 1,
			@Ln_BeginSno_NUMB					NUMERIC(9)		= 1,
			@Lc_StatusAbnormalend_CODE			CHAR(1)			= 'A',
			@Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
			@Lc_No_INDC							CHAR(1)			= 'N',
			@Lc_JobPre_ID						CHAR(7)			= 'DEB9991',
			@Lc_JobProcess_ID					CHAR(7)			= 'DEB0665',
			@Lc_Successful_TEXT					CHAR(20)		= 'SUCCESSFUL',
			@Lc_BatchRunUser_ID					CHAR(30)		= 'BATCH',
			@Ls_Procedure_Name					VARCHAR(80)		= 'SP_PROCESS_PRE_ELFC',
			@Ls_Process_NAME					VARCHAR(100)	= 'BATCH_ENF_ELFC',
			@Ls_ListKey_TEXT					VARCHAR(1000)	= ' ',
			@Ld_High_DATE						DATE			= '12/31/9999';
           
  DECLARE	@Ln_ExceptionThreshold_QNTY			NUMERIC(5)		= 0,
			@Ln_ExceptionThresholdParm_QNTY		NUMERIC(5),
			@Ln_CommitFreqParm_QNTY				NUMERIC(5),
			@Ln_ThreadAvg_QNTY					NUMERIC(9)		= 0,
			@Ln_ThreadNext_QNTY					NUMERIC(9)		= 0,
			@Ln_EndSno_NUMB						NUMERIC(9)		= 0,
			@Ln_Cursor_QNTY						NUMERIC(10)		= 0,
			@Ln_Total_QNTY						NUMERIC(15)		= 0,
			@Lc_Null_TEXT						CHAR(1)			= '',
			@Lc_Msg_CODE						CHAR(3),
			@Ls_Sql_TEXT						VARCHAR(100),
			@Ls_Sqldata_TEXT					VARCHAR(1000),
			@Ls_DescriptionError_TEXT			VARCHAR(4000),
			@Ld_Run_DATE						DATE,
			@Ld_Start_DATE						DATETIME2(0),
			@Ld_LastRun_DATE					DATETIME2(0);

  BEGIN TRY 
		SET @Ls_Sql_TEXT = 'EPRE001 : GET BATCH START TIME';
		SET @Ls_Sqldata_TEXT = @Lc_Null_TEXT;
		SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		SET @Ln_ExceptionThreshold_QNTY = 0;
		SET @Ln_CommitFreqParm_QNTY = 0;
		
		BEGIN TRANSACTION PreElfc_TRAN;
		
			SET @Ls_Sql_TEXT = 'EPRE002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPre_ID, '');
			
			EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
			@Ac_Job_ID                  = @Lc_JobPre_ID,
			@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
			@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
			@An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
			@An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
			@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;			
			
			
		   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
				BEGIN
				 SET @Ls_Sql_TEXT = 'EPRE002A : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
				 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPre_ID, '');
				 RAISERROR(50001,16,1);
				END	
				
			-- Run date validation	
			IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
				BEGIN
					SET @Ls_Sql_TEXT = 'EPRE003 : PARM DATE CONDITION FAILED';
					SET @Ls_Sqldata_TEXT = 'DT_LAST_RUN = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR(20)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');
					SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

					RAISERROR(50001,16,1);
				END				
			
			SET @Ls_Sql_TEXT = 'SELECT NUMBER OF THREAD FROM PARM_Y1';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobProcess_ID, '');
			
			SELECT @Ln_Threads_QNTY = P.Thread_NUMB
				 FROM PARM_Y1 P
				WHERE P.Job_ID = @Lc_JobProcess_ID
				  AND P.EndValidity_DATE = @Ld_High_DATE;
				  
				  
			IF DBO.BATCH_COMMON_SCALAR$SF_TRIM2_VARCHAR(3, @Ln_Threads_QNTY) IS NULL
			   OR @Ln_Threads_QNTY <= 0
				BEGIN
					SET @Ln_Threads_QNTY = 1;
				END	  
				  
			SET @Ls_Sql_TEXT = 'DELETE FROM JOB_MULTI_THREADS_RESTART';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobProcess_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');				  
				  
			DELETE JRTL_Y1 
				WHERE Job_ID = @Lc_JobProcess_ID
				  AND Run_DATE = @Ld_Run_DATE;	  
				  
			
			SET @Ls_Sql_TEXT = 'DELETE FROM IELFC_Y1';
			SET @Ls_Sqldata_TEXT = '';	  
			
			DELETE FROM IELFC_Y1;
				  
			SET @Ls_Sql_TEXT = 'INSERT INTO IELFC_Y1';
			SET @Ls_Sqldata_TEXT = '';	  
			
			-- Bulk insert into IELFC_Y1 table
			INSERT IELFC_Y1
					(MemberMci_IDNO,
					Case_IDNO,
					OrderSeq_NUMB,
					Process_ID,
					TypeChange_CODE,
					OthpSource_IDNO,
					NegPos_CODE,
					Create_DATE,
					Process_DATE,
					WorkerUpdate_ID,
					Update_DTTM,
					TransactionEventSeq_NUMB,
					TypeReference_CODE,
					Reference_ID,
					RecordRowNumber_NUMB)			
			SELECT 
					MemberMci_IDNO,
					Case_IDNO,
					OrderSeq_NUMB,
					Process_ID,
					TypeChange_CODE,
					OthpSource_IDNO,
					NegPos_CODE,
					Create_DATE,
					Process_DATE,
					WorkerUpdate_ID,
					Update_DTTM,
					TransactionEventSeq_NUMB,
					TypeReference_CODE,
					Reference_ID,
					ROW_NUMBER() OVER(ORDER BY e.Case_IDNO,CAST(CONVERT(VARCHAR(10), e.Create_DATE, 101) AS DATE),e.TransactionEventSeq_NUMB,e.Update_DTTM) RecordRowNumber_NUMB
				FROM ELFC_Y1 e
			 WHERE Process_DATE = @Ld_High_DATE
			  AND e.TypeChange_CODE NOT IN (SELECT r.Value_CODE
                                       FROM REFM_Y1 r
                                      WHERE r.Table_ID = 'ELFC'
                                        AND r.TableSub_ID = 'SKIP');
	  
			
			SET @Ls_Sql_TEXT = 'SELECTING COUNT FROM IELFC_Y1';
			SET @Ls_Sqldata_TEXT = '';

			SELECT @Ln_Total_QNTY = ISNULL(COUNT(1),0)
			 FROM IELFC_Y1 I;			  
						  
			SET @Ls_Sql_TEXT = 'DIVIDING THE TOTAL RECORDS WITH THE NUMBER OF THREADS';
			SET @Ls_Sqldata_TEXT = 'Total COUNT = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(15)), '') 
								+ ', Total threads = ' + ISNULL(CAST(@Ln_Threads_QNTY AS VARCHAR(9)), '');	  
								
			SET @Ln_ThreadAvg_QNTY = DBO.BATCH_COMMON_SCALAR$SF_TRUNC(@Ln_Total_QNTY / @Ln_Threads_QNTY, DEFAULT);
			SET @Ln_ThreadNext_QNTY = @Ln_ThreadAvg_QNTY;
			SET @Ls_ListKey_TEXT = 'TOTAL THREAD COUNT = ' + ISNULL(CAST(@Ln_Threads_QNTY AS VARCHAR(9)), '') 
									+  ', TOTAL RECORD COUNT = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(15)), '') 
									+ ', AVG THREAD COUNT = ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS VARCHAR(9)), '');
				  
				  
				  
			SET @Ls_Sql_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO JRTL_Y1';
			SET @Ls_Sqldata_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO JRTL_Y1 = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(15)), '');	  
				  
			
					IF @Ln_Threads_QNTY = 1
						BEGIN
						 SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1';
						 SET @Ls_Sqldata_TEXT = 'ps_id_job = ' + ISNULL(@Lc_JobProcess_ID, '') 
											 + ', PD_DT_RUN = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '') 
											 + ', LN_TOTAL_COUNT = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(15)), '');

						 INSERT JRTL_Y1
								(Job_ID,
								 Run_DATE,
								 Thread_NUMB,
								 RecStart_NUMB,
								 RecEnd_NUMB,
								 RestartKey_TEXT,
								 RecRestart_NUMB,
								 ThreadProcess_CODE)
						 VALUES ( @Lc_JobProcess_ID,		--Job_ID
								  @Ld_Run_DATE,		--Run_DATE
								  1,				--Thread_NUMB
								  1,				--RecStart_NUMB
								  ISNULL(@Ln_Total_QNTY,0),	--RecEnd_NUMB
								  ' ',				--RestartKey_TEXT
								  1,				--RecRestart_NUMB
								  @Lc_No_INDC);		--ThreadProcess_CODE	

						 SET @Ls_ListKey_TEXT = ISNULL(@Ls_ListKey_TEXT, '') + ' THREAD NUMBER ' + '1' + 'STARTING THREAD VALUE ' + '0' + 'ENDING THREAD VALUE ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(15)), '');
						END
					ELSE
						BEGIN
							WHILE @Ln_Counter_NUMB <= @Ln_Threads_QNTY
								BEGIN
									 SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
									 
									 SET @Ls_Sql_TEXT = 'SELECT PCCLR_Y1 ';
									 SET @Ls_Sqldata_TEXT = 'ln_thread_next_count = ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS VARCHAR(9)), '');
									 
									 SELECT @Ln_EndSno_NUMB = MAX(p.RecordRowNumber_NUMB)
										 FROM IELFC_Y1 p
										WHERE p.Case_IDNO IN (SELECT c.Case_IDNO
																	   FROM IELFC_Y1 c
																	  WHERE c.RecordRowNumber_NUMB = @Ln_ThreadNext_QNTY);
																	  
									IF @Ln_Counter_NUMB = @Ln_Threads_QNTY
										BEGIN
											SET @Ln_EndSno_NUMB = @Ln_Total_QNTY;
										END															  
									
									SET @Ls_Sql_TEXT = 'i ' + ISNULL(CAST(@Ln_Counter_NUMB AS VARCHAR(2)), '') 
														+ 'ln_ind_count ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS VARCHAR(9)), '');
									SET @Ls_Sqldata_TEXT = ''; 									
										
									INSERT JRTL_Y1
										  (Job_ID,
										   Run_DATE,
										   Thread_NUMB,
										   RecStart_NUMB,
										   RecEnd_NUMB,
										   RestartKey_TEXT,
										   RecRestart_NUMB,
										   ThreadProcess_CODE)
								   VALUES ( @Lc_JobProcess_ID,	--Job_ID
											@Ld_Run_DATE,			--Run_DATE
											@Ln_Counter_NUMB,		--Thread_NUMB
											ISNULL(@Ln_BeginSno_NUMB,0),		--RecStart_NUMB
											ISNULL(@Ln_EndSno_NUMB,0),		--RecEnd_NUMB
											' ',					--RestartKey_TEXT
											ISNULL(@Ln_BeginSno_NUMB,0),		--RecRestart_NUMB
											@Lc_No_INDC);			--ThreadProcess_CODE
											
								   SET @Ls_ListKey_TEXT = 'List Key = ' + ISNULL(@Ls_ListKey_TEXT, '') 
															+ ', THREAD NUMBER = ' + ISNULL(CAST(@Ln_Counter_NUMB AS VARCHAR(2)), '') 
															+ ', STARTING THREAD VALUE = ' + ISNULL(CAST(@Ln_BeginSno_NUMB AS VARCHAR(9)), '') 
															+ ', ENDING THREAD VALUE = ' + ISNULL(CAST(@Ln_EndSno_NUMB AS VARCHAR (9)), '');
															
								   SET @Ln_BeginSno_NUMB = @Ln_EndSno_NUMB + 1;
								   SET @Ln_ThreadNext_QNTY = @Ln_EndSno_NUMB + @Ln_ThreadAvg_QNTY;									
									
									IF @Ln_ThreadNext_QNTY > @Ln_Total_QNTY
										BEGIN
											SET @Ln_ThreadNext_QNTY = @Ln_Total_QNTY;
										END	 
									SET @Ln_Counter_NUMB = @Ln_Counter_NUMB + 1;
								END
						END	  
				--END
			
			SET @Ls_Sql_TEXT = 'EPRE020 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPre_ID, '') 
								 + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');				  
				  
			EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
					@Ac_Job_ID                = @Lc_JobPre_ID,
					@Ad_Run_DATE              = @Ld_Run_DATE,
					@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
					@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;	  
					
			IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
				BEGIN
					 SET @Ls_Sql_TEXT = 'EPRE020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
					 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobPre_ID, '') + 
											', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');
					 RAISERROR(50001,16,1);
				END			
				
			
		   EXECUTE BATCH_COMMON$SP_BSTL_LOG
						@Ad_Run_DATE                  = @Ld_Run_DATE,
						@Ad_Start_DATE                = @Ld_Start_DATE,
						@Ac_Job_ID                    = @Lc_JobPre_ID,
						@As_Process_NAME              = @Ls_Process_NAME,
						@As_Procedure_NAME            = @Ls_Procedure_Name,
						@As_CursorLocation_TEXT       = @Lc_Null_TEXT,
						@As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
						@As_ListKey_TEXT              = @Ls_ListKey_TEXT,
						@As_DescriptionError_TEXT     = @Lc_Null_TEXT,
						@Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
						@Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
						@An_ProcessedRecordCount_QNTY = 0;						

		--- End of transaction
		IF @@TRANCOUNT > 0
			BEGIN
				COMMIT TRANSACTION PreElfc_TRAN;
			END
  END TRY
  BEGIN CATCH
	DECLARE @Li_Error_NUMB                      INT = NULL,
			@Li_ErrorLine_NUMB                  INT = NULL;

	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION PreElfc_TRAN;
		END
		
	EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
          @As_Procedure_NAME        = @Ls_Procedure_Name,
          @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
          @As_Sql_TEXT              = @Ls_Sql_TEXT,
          @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
          @An_Error_NUMB            = @Li_Error_NUMB,
          @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		
          
	IF ERROR_NUMBER() = 50001
		BEGIN
			EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE                  = @Ld_Run_DATE,
			@Ad_Start_DATE                = @Ld_Start_DATE,
			@Ac_Job_ID                    = @Lc_JobPre_ID,
			@As_Process_NAME              = @Ls_Process_NAME,
			@As_Procedure_NAME            = @Ls_Procedure_Name,
			@As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
			@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
			@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
			@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
			@Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
			@Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
			@An_ProcessedRecordCount_QNTY = 0;

			RAISERROR(@Ls_DescriptionError_TEXT,16,1);
		END
	ELSE
		BEGIN
		SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 100);

		EXECUTE BATCH_COMMON$SP_BSTL_LOG
		@Ad_Run_DATE                  = @Ld_Run_DATE,
		@Ad_Start_DATE                = @Ld_Start_DATE,
		@Ac_Job_ID                    = @Lc_JobPre_ID,
		@As_Process_NAME              = @Ls_Process_NAME,
		@As_Procedure_NAME            = @Ls_Procedure_Name,
		@As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
		@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
		@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
		@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
		@Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
		@Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
		@An_ProcessedRecordCount_QNTY = 0;

		RAISERROR(@Ls_DescriptionError_TEXT,16,1);
		END          
    			
  END CATCH
 END


GO
