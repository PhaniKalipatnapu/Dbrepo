/****** Object:  StoredProcedure [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_PRE_CASE_CLOSURE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_PRE_CASE_CLOSURE]
/*
--------------------------------------------------------------------------------------------------------------------------
 Procedure Name				: BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_PRE_CASE_CLOSURE
 Programmer Name			: IMP Team
 Description				: This procedure loads all the records to be processed by CCLR  into 'IntCclrWeekly_T1 (PCCLR_Y1).
							  also it inserts the number of records to be processed by each thread in
							  JobMultiThreadsRestartLog_T1(JRTL_Y1).
 Frequency					: WEEKLY
 Developed On				: 04/06/2011
 Called By					: None
 Called On					: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_UPDATE_PARM_DATE and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------------------
 Modified By				:
 Modified On				:
 Version No					: 1.0  
-------------------------------------------------------------------------------------------------------------------------------
*/ 
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Ln_Counter_NUMB                    NUMERIC = 1,
           @Ln_Threads_QNTY                    NUMERIC(2,0) = 1,
           @Ln_BeginSno_NUMB                   NUMERIC(9) = 1,
           @Lc_StatusAbnormalend_CODE          CHAR = 'A',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_No_INDC                         CHAR(1) = 'N',
           @Lc_CaseStatusOpen_CODE             CHAR(1) = 'O',
           @Lc_OrderTypeVoluntary_CODE         CHAR(1) = 'V',
           @Lc_CaseTypeNonIvd_CODE             CHAR(1) = 'H',
           @Lc_CaseCharging_CODE               CHAR(1) = 'C',
           @Lc_CaseArrears_CODE                CHAR(1) = 'A',
           @Lc_RelationshipCaseNcp_TEXT        CHAR(1) = 'A',
		   @Lc_RelationshipCasePutFather_TEXT  CHAR(1) = 'P',
		   @Lc_StatusCaseMemberActive_CODE     CHAR(1) = 'A',		
           @Lc_RemedyStatusStart_CODE          CHAR(4) = 'STRT',
           @Lc_ActivityMajorCCLO_CODE          CHAR(4) = 'CCLO',
           @Lc_ActivityMajorCsln_CODE          CHAR(4) = 'CSLN',
           @Lc_ActivityMajorMAPP_CODE          CHAR(4) = 'MAPP',
           @Lc_JobCclr_ID                      CHAR(7) = 'DEB5440',
           @Lc_Job_ID                          CHAR(7) = 'DEB5270',
           @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_ID                 CHAR(30) = 'BATCH',
           @Ls_Routine_TEXT                    VARCHAR(80) = 'BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_PRE_CASE_CLOSURE',
           @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_CM_CASE_CLOSURE_ELIG',
           @Ls_CclrListKey_TEXT                VARCHAR(1000) = ' ',
           @Ld_High_DATE                       DATE = '12/31/9999';
           
  DECLARE  @Ln_CommitFreq_QNTY              NUMERIC(5),
           @Ln_CommitFreqParm_QNTY          NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
           @Ln_ExceptionThreshold_QNTY      NUMERIC(5),
           @Ln_ThreadNext_QNTY              NUMERIC(9),
           @Ln_Total_QNTY                   NUMERIC(9),
           @Ln_ThreadAvg_QNTY               NUMERIC(9),
           @Ln_EndSno_NUMB                  NUMERIC(9),
           @Ln_Cursor_QNTY                  NUMERIC(10) = 0,
           @Lc_Null_TEXT                    CHAR(1) = '',
           @Lc_Msg_CODE                     CHAR(3),
           @Ls_Sql_TEXT                     VARCHAR(100),
           @Ls_Sqldata_TEXT                 VARCHAR(1000),
           @Ls_DescriptionError_TEXT        VARCHAR(4000),
           @Ld_Run_DATE                     DATE,
           @Ld_Start_DATE                   DATETIME2(0),
           @Ld_LastRun_DATE                 DATETIME2(0),
           @Ld_RunLess90Days_DATE           DATETIME2(0);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'EPRE001 : GET BATCH START TIME';
   SET @Ls_Sqldata_TEXT = @Lc_Null_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ln_ExceptionThreshold_QNTY = 0;
   SET @Ln_CommitFreqParm_QNTY = 0;
   
   SET @Ls_Sql_TEXT = 'EPRE002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobCclr_ID, '');

   BEGIN TRANSACTION CaseClosure_TRAN;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobCclr_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EPRE002A : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
	 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobCclr_ID, '');
     RAISERROR(50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_Sql_TEXT = 'EPRE003 : PARM DATE CONDITION FAILED';
     SET @Ls_Sqldata_TEXT = 'DT_LAST_RUN = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR(10)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT NUMBER OF THREAD FROM PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   SELECT @Ln_Threads_QNTY = P.Thread_NUMB
     FROM PARM_Y1 P
    WHERE P.Job_ID = @Lc_Job_ID
      AND P.EndValidity_DATE = @Ld_High_DATE;

   IF DBO.BATCH_COMMON_SCALAR$SF_TRIM2_VARCHAR(3, @Ln_Threads_QNTY) IS NULL
       OR @Ln_Threads_QNTY <= 0
    BEGIN
     SET @Ln_Threads_QNTY = 1;
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM JOB_MULTI_THREADS_RESTART';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

   DELETE JRTL_Y1
    WHERE JRTL_Y1.Job_ID = @Lc_Job_ID
      AND JRTL_Y1.Run_DATE = @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'DELETE FROM PCCLR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   
   --Need to discuss about this statement
   --EXECUTE (@Ls_Sql_TEXT)
   --EXECUTE ('TRUNCATE TABLE PCCLR_Y1')
   DELETE FROM PCCLR_Y1;

   SET @Ld_RunLess90Days_DATE = DATEADD(D, -90, @Ld_Run_DATE);
   SET @Ls_Sql_TEXT = 'INSERT FOR PCCLR_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT PCCLR_Y1
          (RecordRowNumber_NUMB,
           Case_IDNO,
           MemberMci_IDNO,
           RespondInit_CODE,
           Deceased_DATE,
           RsnStatusCase_CODE,
           NonCoop_CODE,
           GoodCause_CODE,
           TypeCase_CODE,
           OrderSeq_NUMB,
           Process_INDC)
   SELECT ROW_NUMBER() OVER(ORDER BY z.Case_IDNO) RecordRowNumber_NUMB,
          z.Case_IDNO,
          z.MemberMci_IDNO,
          z.RespondInit_CODE,
          z.Deceased_DATE,
          z.RsnStatusCase_CODE,
          z.NonCoop_CODE,
          z.GoodCause_CODE,
          z.TypeCase_CODE,
          z.OrderSeq_NUMB,
          @Lc_No_INDC Process_INDC
     FROM (SELECT a.Case_IDNO AS Case_IDNO,
                  a.NcpPf_IDNO AS MemberMci_IDNO,
                  a.RespondInit_CODE,
                  a.Deceased_DATE,
                  a.RsnStatusCase_CODE,
                  a.NonCoop_CODE,
                  a.GoodCause_CODE,
                  a.TypeCase_CODE,
                  CASE
                   WHEN @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                    THEN a.OrderSeq_NUMB
                   ELSE 0
                  END OrderSeq_NUMB
             FROM ENSD_Y1 a
            -- Open Case
            WHERE a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                  -- IV-D Case
                  AND a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                  ---- Active NCP exists
                  AND EXISTS (
					SELECT 1 
						FROM CMEM_Y1 c 
					 WHERE c.Case_IDNO = a.Case_IDNO
					   AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT,@Lc_RelationshipCasePutFather_TEXT)
					   AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)					   
                  -- Exclude voluntary orders 
                  AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                  -- Active Support Order order
                  --AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                  -- CSLN chain does not exist in active mode with charging or arreras case
                  AND NOT EXISTS (SELECT 1
                                    FROM DMJR_Y1 D
                                   WHERE D.Case_IDNO = a.Case_IDNO
                                     AND D.OrderSeq_NUMB = a.OrderSeq_NUMB
                                     AND D.MemberMci_IDNO = a.NcpPf_IDNO
                                     AND D.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
                                     AND D.Status_CODE = @Lc_RemedyStatusStart_CODE
                                     AND a.CaseChargingArrears_CODE IN (@Lc_CaseCharging_CODE, @Lc_CaseArrears_CODE))
                  -- MAPP chain does not exist in active mode with charging or arreras case
                  AND NOT EXISTS (SELECT 1
                                    FROM DMJR_Y1 D
                                   WHERE D.Case_IDNO = a.Case_IDNO
                                     AND D.OrderSeq_NUMB = a.OrderSeq_NUMB
                                     AND D.MemberMci_IDNO = a.NcpPf_IDNO
                                     AND D.ActivityMajor_CODE = @Lc_ActivityMajorMAPP_CODE
                                     AND D.Status_CODE = @Lc_RemedyStatusStart_CODE)
                  -- No Active Case Closure chain NCP as a source
                  AND NOT EXISTS (SELECT 1
                                    FROM DMJR_Y1 b
                                   WHERE b.Case_IDNO = a.Case_IDNO
                                     AND b.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                     AND b.Status_CODE = @Lc_RemedyStatusStart_CODE)
                  -- No Active Case Closure chain NCP as a source
                  AND NOT EXISTS (SELECT 1
                                    FROM ELFC_Y1 b
                                   WHERE b.Case_IDNO = a.Case_IDNO
                                     AND b.TypeChange_CODE IN('CC','CL','MP')
                                     AND b.Process_DATE = @Ld_High_DATE)) AS z
    ORDER BY z.Case_IDNO,
             z.MemberMci_IDNO;

   /*  SET @Ls_Sql_TEXT = 'GATHER STATS'
    SET @Ls_Sqldata_TEXT = 'LS_pcclr_TABLE_NAME' + ISNULL(@Ls_PcclrTable_NAME, '')

    
    -- As per discussion with Rajkumar following statement is commented
    EXECUTE DBMS_STATS.gather_table_stats 
    */
   SET @Ls_Sql_TEXT = 'SELECTING COUNT FROM PCCLR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   
   SELECT @Ln_Total_QNTY = COUNT(1)
     FROM PCCLR_Y1 P;

   SET @Ls_Sql_TEXT = 'DIVIDING THE TOTAL RECORDS WITH THE NUMBER OF THREADS';
   SET @Ls_Sqldata_TEXT = 'Total COUNT = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(9)), '') + ', Total threads = ' + ISNULL(CAST(@Ln_Threads_QNTY AS VARCHAR(9)), '');
   
   SET @Ln_ThreadAvg_QNTY = DBO.BATCH_COMMON_SCALAR$SF_TRUNC(@Ln_Total_QNTY / @Ln_Threads_QNTY, DEFAULT);
   SET @Ln_ThreadNext_QNTY = @Ln_ThreadAvg_QNTY;
   SET @Ls_CclrListKey_TEXT = 'TOTAL THREAD COUNT = ' + ISNULL(CAST(@Ln_Threads_QNTY AS VARCHAR(9)), '') + ', TOTAL RECORD COUNT = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(9)), '') + ', AVG THREAD COUNT = ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS VARCHAR(9)), '');
   
   SET @Ls_Sql_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO JRTL_Y1';
   SET @Ls_Sqldata_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO JRTL_Y1 = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(5)), '');

   IF @Ln_Threads_QNTY = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1';
     SET @Ls_Sqldata_TEXT = 'ps_id_job = ' + ISNULL(@Lc_Job_ID, '') + ', PD_DT_RUN = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '') + ', LN_TOTAL_COUNT = ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(5)), '');

     INSERT JRTL_Y1
            (Job_ID,
             Run_DATE,
             Thread_NUMB,
             RecStart_NUMB,
             RecEnd_NUMB,
             RestartKey_TEXT,
             RecRestart_NUMB,
             ThreadProcess_CODE)
     VALUES ( @Lc_Job_ID,		--Job_ID
              @Ld_Run_DATE,		--Run_DATE
              1,				--Thread_NUMB
              1,				--RecStart_NUMB
              @Ln_Total_QNTY,	--RecEnd_NUMB
              ' ',				--RestartKey_TEXT
              1,				--RecRestart_NUMB
              @Lc_No_INDC);		--ThreadProcess_CODE	

     SET @Ls_CclrListKey_TEXT = ISNULL(@Ls_CclrListKey_TEXT, '') + ' THREAD NUMBER ' + '1' + 'STARTING THREAD VALUE ' + '0' + 'ENDING THREAD VALUE ' + ISNULL(CAST(@Ln_Total_QNTY AS VARCHAR(5)), '');
    END
   ELSE
    BEGIN
    
    /*@Ln_Counter_NUMB Count*/
     WHILE @Ln_Counter_NUMB <= @Ln_Threads_QNTY
      BEGIN
       SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
       
       SET @Ls_Sql_TEXT = 'SELECT PCCLR_Y1 ';
       SET @Ls_Sqldata_TEXT = 'ln_thread_next_count = ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS VARCHAR(9)), '');

       SELECT @Ln_EndSno_NUMB = MAX(p.RecordRowNumber_NUMB)
         FROM PCCLR_Y1 p
        WHERE p.Case_IDNO IN (SELECT c.Case_IDNO
                                       FROM PCCLR_Y1 c
                                      WHERE c.RecordRowNumber_NUMB = @Ln_ThreadNext_QNTY);

       IF @Ln_Counter_NUMB = @Ln_Threads_QNTY
        BEGIN
         SET @Ln_EndSno_NUMB = @Ln_Total_QNTY;
        END

       SET @Ls_Sql_TEXT = 'i ' + ISNULL(CAST(@Ln_Counter_NUMB AS VARCHAR(2)), '') + 'ln_ind_count ' + ISNULL(CAST(@Ln_ThreadNext_QNTY AS VARCHAR(9)), '');
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
       VALUES ( @Lc_Job_ID,				--Job_ID
                @Ld_Run_DATE,			--Run_DATE
                @Ln_Counter_NUMB,		--Thread_NUMB
                @Ln_BeginSno_NUMB,		--RecStart_NUMB
                @Ln_EndSno_NUMB,		--RecEnd_NUMB
                ' ',					--RestartKey_TEXT
                @Ln_BeginSno_NUMB,		--RecRestart_NUMB
                @Lc_No_INDC);			--ThreadProcess_CODE

       SET @Ls_CclrListKey_TEXT = 'List Key = ' + ISNULL(@Ls_CclrListKey_TEXT, '') + ', THREAD NUMBER = ' + ISNULL(CAST(@Ln_Counter_NUMB AS VARCHAR(2)), '') + ', STARTING THREAD VALUE = ' + ISNULL(CAST(@Ln_BeginSno_NUMB AS VARCHAR(9)), '') + ', ENDING THREAD VALUE = ' + ISNULL(CAST(@Ln_EndSno_NUMB AS VARCHAR (9)), '');
       SET @Ln_BeginSno_NUMB = @Ln_EndSno_NUMB + 1;
       SET @Ln_ThreadNext_QNTY = @Ln_EndSno_NUMB + @Ln_ThreadAvg_QNTY;

       IF @Ln_ThreadNext_QNTY > @Ln_Total_QNTY
        BEGIN
         SET @Ln_ThreadNext_QNTY = @Ln_Total_QNTY;
        END

       SET @Ln_Counter_NUMB = @Ln_Counter_NUMB + 1;
      END
    END

   SET @Ls_Sql_TEXT = 'EPRE020 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobCclr_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobCclr_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EPRE020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
	 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobCclr_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');
     RAISERROR(50001,16,1);
    END

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobCclr_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Ls_CclrListKey_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Null_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

   COMMIT TRANSACTION CaseClosure_TRAN;
  END TRY

  BEGIN CATCH
  
    DECLARE @Li_Error_NUMB                      INT = NULL,
			@Li_ErrorLine_NUMB                  INT = NULL;
			
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CaseClosure_TRAN;
    END
          	
	EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
          @As_Procedure_NAME        = @Ls_Routine_TEXT,
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
      @Ac_Job_ID                    = @Lc_JobCclr_ID,
      @As_Process_NAME              = @Ls_Process_NAME,
      @As_Procedure_NAME            = @Ls_Routine_TEXT,
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
      @Ac_Job_ID                    = @Lc_JobCclr_ID,
      @As_Process_NAME              = @Ls_Process_NAME,
      @As_Procedure_NAME            = @Ls_Routine_TEXT,
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
