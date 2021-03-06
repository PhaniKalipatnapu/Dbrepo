/****** Object:  StoredProcedure [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_PRE_NMSN_ANNUAL_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_PRE_NMSN_ANNUAL_NOTICE
Programmer Name 	: IMP Team
Description			: The process BATCH_ENF_NMSN_ANNUAL_NOTICES finds the members who are ordered to provide insurance and
					  sends a notice ENF-13
Frequency			: 'ANNUAL'
Developed On		: 01/05/2012
Called By			:
Called Procedures	: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_UPDATE_PARM_DATE and BATCH_COMMON$SP_BSTL_LOG.
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PROCESS_PRE_NMSN_ANNUAL_NOTICE]
AS
 BEGIN
   DECLARE @Ln_Threads_QNTY                             NUMERIC(9)		= 1,
           @Ln_BeginSno_NUMB                            NUMERIC(9)		= 1,
           @Lc_SuccessStatus_CODE                       CHAR(1)			= 'S',
           @Lc_No_INDC                                  CHAR(1)			= 'N',
           @Lc_StatusCaseOpen_CODE                      CHAR(1)			= 'O',
           @Lc_RespondInitInstate_CODE					CHAR(1)			= 'N',
           @Lc_TypeCaseNonIvd_CODE                      CHAR(1)			= 'H',
           @Lc_InsOrderedN_CODE                         CHAR(1)			= 'N',
           @Lc_InsuranceProvidedN_CODE                  CHAR(1)			= 'N',
           @Lc_StatusYes_CODE                           CHAR(1)			= 'Y',
           @Lc_EmployerPrimeYes_INDC                    CHAR(1)			= 'Y',
           @Lc_StatusAbnormalEnd_CODE                   CHAR(1)			= 'A',
           @Lc_StatusFailed_CODE                        CHAR(1)			= 'F',
           @Lc_InsOrderedA_CODE                         CHAR(1)			= 'A',
           @Lc_InsOrderedU_CODE                         CHAR(1)			= 'U',
           @Lc_InsOrderedC_CODE                         CHAR(1)			= 'C',
           @Lc_InsOrderedO_CODE                         CHAR(1)			= 'O',
           @Lc_InsOrderedD_CODE                         CHAR(1)			= 'D',
           @Lc_InsOrderedB_CODE                         CHAR(1)			= 'B',
           @Lc_Space_TEXT                               CHAR(1)			= ' ',
           @Lc_RespondInitRespondingState_CODE          CHAR(1)			= 'R',
           @Lc_RespondInitRespondingTribal_CODE         CHAR(1)			= 'S',
           @Lc_RespondInitRespondingInternational_CODE  CHAR(1)			= 'Y',
           @Lc_TypeIncomeUA_CODE                        CHAR(2)			= 'UA',
           @Lc_TypeIncomeML_CODE                        CHAR(2)			= 'ML',
           @Lc_ReasonErfso_CODE                         CHAR(5)			= 'ERFSO',
           @Lc_ReasonErfsm_CODE                         CHAR(5)			= 'ERFSM',
           @Lc_ReasonErfss_CODE                         CHAR(5)			= 'ERFSS',
           @Lc_JobPre_ID                                CHAR(7)			= 'DEB8665',
           @Lc_JobProcess_ID                            CHAR(7)			= 'DEB8670',
           @Lc_Successful_TEXT                          CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT                        CHAR(30)		= 'BATCH',
           @Ls_Procedure_NAME                           VARCHAR(50)		= 'SP_PROCESS_PRE_NMSN_ANNUAL_NOTICE',
           @Ls_Process_NAME                             VARCHAR(100)	= 'BATCH_ENF_NMSN_ANNUAL_NOTICES',
           @Ls_NmsnListKey_TEXT                         VARCHAR(1000)	= ' ',
           @Ld_High_DATE                                DATE			= '12/31/9999';
  DECLARE  @Ln_CommitFreq_NUMB							NUMERIC(5),
           @Ln_ExceptionThreshold_NUMB					NUMERIC(5),
           @Ln_ThreadNext_QNTY							NUMERIC(9),
           @Ln_Total_QNTY								NUMERIC(9),
           @Ln_ThreadAvg_QNTY							NUMERIC(9),
           @Ln_SeqThreadEnd_NUMB						NUMERIC(9),
           @Ln_Commit_QNTY								NUMERIC(10)		= 0,
           @Ln_Cursor_QNTY								NUMERIC(10)		= 0,
           @Ln_SeqStart_IDNO							NUMERIC(19),
           @Ln_SeqEnd_IDNO								NUMERIC(19),
           @Li_Error_NUMB								INT				= 0,
           @Li_ErrorLine_NUMB							INT				= 0,
           @Lc_Null_TEXT								CHAR(1)			= '',
           @Lc_Msg_CODE									CHAR(5),
           @Ls_Sql_TEXT									VARCHAR(400),
           @Ls_Sqldata_TEXT								VARCHAR(1000),
           @Ls_DescriptionError_TEXT					VARCHAR(4000),
           @Ld_Run_DATE									DATE,
           @Ld_LastRun_DATE								DATE,
           @Ld_Current_DTTM								DATETIME2		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
           
  BEGIN TRY
  
   BEGIN TRANSACTION PNMSN_TRAN
	   SET @Ls_Sql_TEXT = 'EPRE001 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
	   SET @Ls_Sqldata_TEXT = 'Job_ID: ' + @Lc_JobPre_ID;

	   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
			@Ac_Job_ID                  = @Lc_JobPre_ID,
			@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
			@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
			@An_CommitFreq_QNTY         = @Ln_CommitFreq_NUMB OUTPUT,
			@An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_NUMB OUTPUT,
			@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

	   IF @Lc_Msg_CODE != @Lc_SuccessStatus_CODE
		BEGIN
			 SET @Ls_Sql_TEXT = 'EPRE002 : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
			 RAISERROR(50001,16,1);
		END

		IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
			BEGIN
				 SET @Ls_Sql_TEXT = 'EPRE003 : PARM DATE CONDITION FAILED';
				 SET @Ls_Sqldata_TEXT = 'DT_LAST_RUN: ' + ISNULL(CAST(@Ld_LastRun_DATE AS NVARCHAR(10)), '') + ' Run_DATE: ' + ISNULL (CAST(@Ld_Run_DATE AS NVARCHAR(10)), '');
				 SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
				 RAISERROR(50001,16,1);
			END

	   SET @Ls_Sql_TEXT = 'SELECT NUMBER OF THREAD FROM PARM_Y1';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobProcess_ID, @Lc_Null_TEXT);

	   SELECT @Ln_Threads_QNTY = p.Thread_NUMB
		 FROM PARM_Y1 p
		WHERE p.Job_ID = @Lc_JobProcess_ID
		  AND p.EndValidity_DATE = @Ld_High_DATE;

	   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NVARCHAR(3, @Ln_Threads_QNTY) IS NULL
		   OR @Ln_Threads_QNTY <= 0
		BEGIN
			SET @Ln_Threads_QNTY = 1;
		END

	   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1';
	   SET @Ls_Sql_TEXT = 'DELETE FROM JOB_MULTI_THREADS_RESTART';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobProcess_ID, @Lc_Null_TEXT) + ' Run_DATE= ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(10)), @Lc_Null_TEXT)

	   DELETE JRTL_Y1
		WHERE JRTL_Y1.Job_ID = @Lc_JobProcess_ID
		  AND JRTL_Y1.Run_DATE = @Ld_Run_DATE;

		SET @Ls_Sql_TEXT = 'TRUNCATE TABLE PNMSN_Y1'
		DELETE FROM PNMSN_Y1;
		
		SET @Ls_Sql_TEXT = 'INSERT FOR PNMSN_Y1';

	   INSERT PNMSN_Y1
			  (Case_IDNO,
			   MemberMci_IDNO,
			   InsuranceOrdered_CODE,
			   CaseRelationship_CODE,
			   OthpEmployer_IDNO,
			   Process_INDC)
	   SELECT t.Case_IDNO,
			t.MemberMci_IDNO,
			t.CaseRelationShip_CODE,
			t.InsuranceOrdered_CODE,
			t.OthpPartyEmpl_IDNO,
			t.Process_INDC
		  FROM (SELECT
				   a.Case_IDNO,
				   a.MemberMci_IDNO,
				   @Lc_Space_TEXT AS CaseRelationShip_CODE,
				   @Lc_Space_TEXT AS InsuranceOrdered_CODE,
				   a.OthpPartyEmpl_IDNO,
				   @Lc_No_INDC AS Process_INDC,
				   ROW_NUMBER() OVER(PARTITION BY a.OthpPartyEmpl_IDNO ORDER BY a.Case_IDNO DESC) Row_NUMB
				 FROM (SELECT (SELECT MAX(Case_IDNO)
								 FROM ENSD_Y1 e
								WHERE ((e.NcpPf_IDNO = a.MemberMci_IDNO AND e.InsOrdered_CODE IN (@Lc_InsOrderedA_CODE,@Lc_InsOrderedU_CODE,@Lc_InsOrderedD_CODE,@Lc_InsOrderedB_CODE))
										OR (e.CpMci_IDNO = a.MemberMci_IDNO AND e.InsOrdered_CODE IN (@Lc_InsOrderedC_CODE,@Lc_InsOrderedO_CODE,@Lc_InsOrderedD_CODE,@Lc_InsOrderedB_CODE)))
								  AND e.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
								  AND e.TypeCase_CODE != @Lc_TypeCaseNonIvd_CODE
								/* Case is not marked initiating intergovernmental or if it is marked responding intergovernmental the referral type 
									is not 'Registration for Modification Only' */
								  AND ( e.RespondInit_CODE = @Lc_RespondInitInstate_CODE
										OR (e.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
											   AND NOT EXISTS(SELECT 1
																FROM ICAS_Y1 x
															   WHERE x.Case_IDNO = e.Case_IDNO
																 AND x.RespondInit_CODE = e.RespondInit_CODE
																 AND x.Status_CODE = @Lc_StatusCaseOpen_CODE
																 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
																 AND x.EndValidity_DATE = @Ld_High_DATE)))
								  AND @Ld_Current_DTTM BETWEEN e.OrderEffective_DATE AND e.OrderEnd_DATE
								  AND e.InsOrdered_CODE NOT IN (@Lc_InsOrderedN_CODE)) Case_IDNO,
							  a.MemberMci_IDNO,
							  a.OthpPartyEmpl_IDNO
						 FROM (SELECT e.MemberMci_IDNO,
									  e.OthpPartyEmpl_IDNO
								 FROM EHIS_Y1 e
								WHERE @Ld_Current_DTTM BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
								  AND e.Status_CODE = @Lc_StatusYes_CODE
								  AND e.TypeIncome_CODE NOT IN (@Lc_TypeIncomeUA_CODE,@Lc_TypeIncomeML_CODE)
								  AND e.EmployerPrime_INDC = @Lc_EmployerPrimeYes_INDC
								  AND EXISTS (SELECT 1
												FROM OTHP_Y1 o
											   WHERE o.OtherParty_IDNO = e.OthpPartyEmpl_IDNO
												 AND o.InsuranceProvided_INDC IN (@Lc_InsuranceProvidedN_CODE, ' ')
												 AND o.EndValidity_DATE = @Ld_High_DATE)) AS a) AS a
				WHERE a.Case_IDNO IS NOT NULL
				) AS t
		 WHERE t.Row_NUMB = 1;

	   SET @Ls_Sql_TEXT = 'SELECTING COUNT FROM PNMSN_Y1';

	   SELECT @Ln_Total_QNTY = COUNT(1)
		 FROM PNMSN_Y1 p;
		 
		SET @Ls_Sql_TEXT = 'SELECTING MINIMUM Seq_IDNO FROM PNMSN_Y1';
		
		SELECT @Ln_SeqStart_IDNO = MIN(p.Seq_IDNO) 
			FROM PNMSN_Y1 p;
			
		SET @Ls_Sql_TEXT = 'SELECTING MAXIMUM Seq_IDNO FROM PNMSN_Y1';
		
		SELECT @Ln_SeqEnd_IDNO = MAX(p.Seq_IDNO) 
			FROM PNMSN_Y1 p;

	   SET @Ls_Sql_TEXT = 'DIVIDING THE TOTAL RECORDS WITH THE NUMBER OF THREADS';
	   SET @Ls_Sqldata_TEXT = 'Total COUNT:' + ISNULL(CAST(@Ln_Total_QNTY AS NVARCHAR(9)), @Lc_Null_TEXT) + ' Total threads:' + ISNULL(CAST(@Ln_Threads_QNTY AS NVARCHAR(9)), @Lc_Null_TEXT);
	   SET @Ln_ThreadAvg_QNTY = dbo.BATCH_COMMON_SCALAR$SF_TRUNC(@Ln_Total_QNTY / @Ln_Threads_QNTY, DEFAULT);
	   SET @Ln_ThreadNext_QNTY = @Ln_SeqStart_IDNO + @Ln_ThreadAvg_QNTY - 1;
	   SET @Ls_NmsnListKey_TEXT = 'TOTAL THREAD COUNT:= ' + ISNULL(CAST(@Ln_Threads_QNTY AS NVARCHAR(9)), '') + ' TOTAL RECORD COUNT:= ' + ISNULL(CAST(@Ln_Total_QNTY AS NVARCHAR(9)), '') + ' AVG THREAD COUNT:=' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS NVARCHAR(9)), '');
	   SET @Ls_Sql_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO JRTL_Y1';
	   SET @Ls_Sqldata_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO JRTL_Y1:=' + ISNULL(CAST(@Ln_Total_QNTY AS NVARCHAR(9)), @Lc_Null_TEXT);

		IF @Ln_Threads_QNTY = 1 OR @Ln_ThreadAvg_QNTY = 0
			BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1'
     SET @Ls_Sqldata_TEXT = ' ps_id_job := ' + ISNULL(@Lc_JobProcess_ID, '') + ' PD_DT_RUN := ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(10)), '') + ' LN_TOTAL_COUNT:= ' + ISNULL(CAST(@Ln_Total_QNTY AS NVARCHAR(9)), '')

     INSERT JRTL_Y1
            (Job_ID,
             Run_DATE,
             Thread_NUMB,
             RecStart_NUMB,
             RecEnd_NUMB,
             RestartKey_TEXT,
             RecRestart_NUMB,
             ThreadProcess_CODE)
     VALUES ( @Lc_JobProcess_ID,
              @Ld_Run_DATE,
              1,
              @Ln_SeqStart_IDNO,
              @Ln_SeqEnd_IDNO,
              @Lc_Space_TEXT,
              @Ln_SeqStart_IDNO,
              @Lc_No_INDC)

     IF @@TRANCOUNT = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT JRTL_Y1 FAILED 1'
       RAISERROR(50001,16,1)
      END

     SET @Ls_NmsnListKey_TEXT = ISNULL(@Ls_NmsnListKey_TEXT, '') + ' THREAD NUMBER ' + '1' + 'STARTING THREAD VALUE ' + '0' + 'ENDING THREAD VALUE ' + ISNULL(CAST(@Ln_Total_QNTY AS NVARCHAR(9)), '')
    END
		ELSE
			BEGIN
     DECLARE @Ln_Counter_NUMB NUMERIC = 1

     WHILE @Ln_Counter_NUMB <= @Ln_Threads_QNTY
      BEGIN
       SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1
       SET @Ls_Sql_TEXT = 'SELECT PNMSN_Y1 '
       SET @Ls_Sqldata_TEXT = ' ln_thread_next_count := ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS NVARCHAR(9)), '')

       SET @Ln_SeqThreadEnd_NUMB = @Ln_ThreadNext_QNTY;
       
       IF @Ln_Counter_NUMB = @Ln_Threads_QNTY
        BEGIN
         SET @Ln_SeqThreadEnd_NUMB = @Ln_SeqEnd_IDNO;
        END

       SET @Ls_Sql_TEXT = '@Ln_Counter_NUMB ' + ISNULL(CAST(@Ln_Counter_NUMB AS NVARCHAR(2)), '') + '@Ln_ThreadNext_QNTY ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS NVARCHAR(9)), '')
       SET @Ls_Sqldata_TEXT = ' ps_id_job := ' + ISNULL(@Lc_JobProcess_ID, '') + ' PD_DT_RUN := ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(10)), '') + ' Thread_NUMB:= ' + ISNULL(CAST(@Ln_Counter_NUMB AS NVARCHAR(2)), '')

       INSERT JRTL_Y1
              (Job_ID,
               Run_DATE,
               Thread_NUMB,
               RecStart_NUMB,
               RecEnd_NUMB,
               RestartKey_TEXT,
               RecRestart_NUMB,
               ThreadProcess_CODE)
       VALUES ( @Lc_JobProcess_ID,
                @Ld_Run_DATE,
                @Ln_Counter_NUMB,
                @Ln_SeqStart_IDNO,
                @Ln_SeqThreadEnd_NUMB,
                ' ',
                @Ln_SeqStart_IDNO,
                @Lc_No_INDC)

       IF @@TRANCOUNT = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT JRTL_Y1 FAILED 2'
         RAISERROR(50001,16,1)
        END

       SET @Ls_NmsnListKey_TEXT = ISNULL(@Ls_NmsnListKey_TEXT, '') + ' THREAD NUMBER:= ' + ISNULL(CAST(@Ln_Counter_NUMB AS VARCHAR(2)), '') + ' STARTING THREAD VALUE:= ' + ISNULL(CAST(@Ln_BeginSno_NUMB AS VARCHAR(9)), '') + ' ENDING THREAD VALUE:= ' + ISNULL(CAST(@Ln_SeqThreadEnd_NUMB AS VARCHAR (9)), '')
       SET @Ln_SeqStart_IDNO = @Ln_SeqThreadEnd_NUMB + 1
       SET @Ln_ThreadNext_QNTY = @Ln_SeqThreadEnd_NUMB + @Ln_ThreadAvg_QNTY

       IF @Ln_ThreadNext_QNTY > @Ln_SeqEnd_IDNO
        BEGIN
         SET @Ln_ThreadNext_QNTY = @Ln_SeqEnd_IDNO
        END

       SET @Ln_Counter_NUMB = @Ln_Counter_NUMB + 1
      END
    END

		SET @Ls_Sql_TEXT = 'EPRE020 : BATCH_COMMON$SP_UPDATE_PARM_DATE'
		SET @Ls_Sqldata_TEXT = 'Job_ID: ' + ISNULL(@Lc_JobPre_ID, @Lc_Null_TEXT) + ' Run_DATE: ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(10)), @Lc_Null_TEXT)

	   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
		@Ac_Job_ID                = @Lc_JobPre_ID,
		@Ad_Run_DATE              = @Ld_Run_DATE,
		@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

		IF @Lc_Msg_CODE != @Lc_SuccessStatus_CODE
			BEGIN
				SET @Ls_Sql_TEXT = 'EPRE020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
				RAISERROR(50001,16,1);
			END

	   EXECUTE BATCH_COMMON$SP_BSTL_LOG
		@Ad_Run_DATE              = @Ld_Run_DATE,
		@Ad_Start_DATE            = @Ld_Current_DTTM,
		@Ac_Job_ID                = @Lc_JobPre_ID,
		@As_Process_NAME          = @Ls_Process_NAME,
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_CursorLocation_TEXT   = @Lc_Null_TEXT,
		@As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
		@As_ListKey_TEXT          = @Ls_NmsnListKey_TEXT,
		@As_DescriptionError_TEXT = @Lc_Null_TEXT,
		@Ac_Status_CODE           = @Lc_SuccessStatus_CODE,
		@Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
		@An_ProcessedRecordCount_QNTY = @Ln_Total_QNTY;

	IF @@TRANCOUNT > 0	
		COMMIT TRANSACTION PNMSN_TRAN
  END TRY

  BEGIN CATCH
   IF ERROR_NUMBER()			=50001
    BEGIN
     IF @@TRANCOUNT > 0
      BEGIN
       ROLLBACK TRANSACTION PNMSN_TRAN
      END

	SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
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
		@Ad_Start_DATE                = @Ld_Current_DTTM,
		@Ac_Job_ID                    = @Lc_JobPre_ID,
		@As_Process_NAME              = @Ls_Process_NAME,
		@As_Procedure_NAME            = @Ls_Procedure_NAME,
		@As_CursorLocation_TEXT       = @Lc_Null_TEXT,
		@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
		@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
		@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
		@Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
		@Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
		@An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

	RAISERROR (@Ls_DescriptionError_TEXT,16,1);
    END
  END CATCH
 END


GO
