/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_PRE_EMON_WEEKLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		:	BATCH_ENF_EMON$SP_PROCESS_PRE_EMON_WEEKLY
Programmer Name		:	IMP Team
Description			:	This procedure loads all the records to be processed by EMON Weekly process.
Frequency			:   'WEEKLY'
Developed On		:	01/05/2012
Called By			:	None
Called On       	:   BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_UPDATE_PARM_DATE and BATCH_COMMON$SP_BSTL_LOG 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_PRE_EMON_WEEKLY]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_ThreadLoopCount_NUMB				NUMERIC(15)		= 1,
          @Ln_ThreadCounts_NUMB					NUMERIC(15)		= 1,
          @Lc_Success_CODE						CHAR(1)			= 'S',
          @Lc_No_CODE							CHAR(1)			= 'N',
          @Lc_StatusFailed_CODE					CHAR(1)			= 'F',
          @Lc_StatusAbnormalend_CODE			CHAR(1)			= 'A',
          @Lc_Space_TEXT						CHAR(1)			= ' ',
          @Lc_CaseStatusOpen_CODE				CHAR(1)			= 'O',
          @Lc_TypeOrderVoluntary_CODE			CHAR(1)			= 'V',
          @Lc_CaseRelationshipNcp_CODE			CHAR(1)			= 'A',
          @Lc_CaseRelationshipPutFather_CODE	CHAR(1)			= 'P',
          @Lc_CaseMemberStatusActive_CODE		CHAR(1)			= 'A',
          @Lc_ComplianceStatusActive_CODE		CHAR(2)			= 'AC',
          @Lc_BatchRunUser_ID					CHAR(5)			= 'BATCH',
          @Lc_JobPre_ID							CHAR(7)			= 'DEB5470',
          @Lc_JobProcess_ID						CHAR(7)			= 'DEB5420',
          @Ls_Process_NAME						CHAR(15)		= 'BATCH_ENF_EMON',
          @Lc_Successful_TEXT					CHAR(20)		= 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT				CHAR(20)		= 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME					VARCHAR(50)		= 'SP_PROCESS_PRE_EMON_WEEKLY',
          @Ls_ListKeyEMON_TEXT					VARCHAR(1000)	= ' ',
          @Ld_High_DATE							DATE			= '12/31/9999';
  DECLARE @Ln_ThreadNextCount_NUMB				NUMERIC(15),
          @Ln_ThreadAvgCount_NUMB				NUMERIC(15),
          @Ln_TotalCount_NUMB					NUMERIC(15)		= 0,
          @Ln_EndThread_NUMB					NUMERIC(15),
          @Ln_BeginThread_NUMB					NUMERIC(15)		= 0,
          @Ln_NoCommitFreq_QNTY					NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY			NUMERIC(5),
          @Ln_Error_NUMB						NUMERIC(11),
          @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Lc_Msg_CODE							CHAR(5),
          @Ls_Sql_TEXT							VARCHAR(100),
          @Ls_Sqldata_TEXT						VARCHAR(800),
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ld_Run_DATE							DATE,
          @Ld_LastRun_DATE						DATE,
          @Ld_RunDateEmonWeekly_DATE			DATE,
          @Ld_Start_DATE						DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'EPRE001 : GET BATCH START TIME';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   --Main begin transaction
   BEGIN TRANSACTION PRE_EMON_WEEKLY_TRANS;

   -- Selecting date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'EPRE002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobPre_ID;
   -- Get the Batch Details
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobPre_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_NoCommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Dt run validation..
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_Sql_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT NUMBER OF THREAD FROM  PARM_Y1';
   SET @Ls_Sqldata_TEXT = ' JOB_ID = ' + @Lc_JobProcess_ID;

   SELECT @Ln_ThreadCounts_NUMB = p.Thread_NUMB
     FROM PARM_Y1 p
    WHERE p.Job_ID = @Lc_JobProcess_ID
      AND p.EndValidity_DATE = @Ld_High_DATE;

   IF LTRIM(RTRIM(@Ln_ThreadCounts_NUMB))		= ''
       OR @Ln_ThreadCounts_NUMB <= 0
    BEGIN
     --Assigned Thread count to 1 if no thread details is available
     SET @Ln_ThreadCounts_NUMB = 1;
    END;

   SET @Ls_Sql_TEXT = 'DELETE FROM JRTL_Y1';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobProcess_ID + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS CHAR (10));

   DELETE FROM JRTL_Y1
    WHERE Job_ID = @Lc_JobProcess_ID
      AND Run_DATE = @Ld_Run_DATE;

   --The Last run date is selected from emon weekly job.Since the last run date of emon weekly process
   --is last success execution of emon weekly process and not PRE emon weekly job
   SET @Ls_Sql_TEXT = 'SELECT LAST RUN DATE OF EMON WEEKLY';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobProcess_ID;

   SELECT @Ld_RunDateEmonWeekly_DATE = p.Run_DATE
     FROM PARM_Y1 p
    WHERE p.Job_ID = @Lc_JobProcess_ID
      AND p.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'DELETE FROM  PEWKL_Y1';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   DELETE FROM PEWKL_Y1;

   SET @Ls_Sql_TEXT = 'INSERT FOR PEWKL_Y1';
   SET @Ls_Sqldata_TEXT = ' StatusCase_CODE = ' + @Lc_CaseStatusOpen_CODE + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS CHAR (10));

   INSERT INTO PEWKL_Y1
               (RecordRowNumber_NUMB,
                Case_IDNO,
                OrderSeq_NUMB,
                MemberMci_IDNO,
                ComplianceType_CODE,
                Compliance_AMNT,
                NoMissPayment_QNTY,
                Entry_DATE,
                Effective_DATE,
                End_DATE,
                Compliance_IDNO,
                TransactionEventSeq_NUMB,
                PaybackSord_AMNT,
                NcpMci_IDNO,
                Process_INDC)
   SELECT ROW_NUMBER() OVER(ORDER BY x.Case_IDNO) AS RecordRowNumber_NUMB,
          x.Case_IDNO,
          x.OrderSeq_NUMB,
          x.MemberMci_IDNO,
          x.ComplianceType_CODE,
          x.Compliance_AMNT,
          x.NoMissPayment_QNTY,
          x.Entry_DATE,
          x.Effective_DATE,
          x.End_DATE,
          x.Compliance_IDNO,
          x.TransactionEventSeq_NUMB,
          x.PaybackSord_AMNT,
          x.NcpMci_IDNO,
          @Lc_No_CODE AS Process_INDC
     FROM (SELECT x.Case_IDNO,
                  x.OrderSeq_NUMB,
                  x.MemberMci_IDNO,
                  x.ComplianceType_CODE,
                  x.Compliance_AMNT,
                  x.NoMissPayment_QNTY,
                  x.Entry_DATE,
                  x.Effective_DATE,
                  x.End_DATE,
                  x.Compliance_IDNO,
                  x.TransactionEventSeq_NUMB,
                  x.PaybackSord_AMNT,
                  x.NcpMci_IDNO
             FROM (SELECT s.Case_IDNO,
                          s.OrderSeq_NUMB,
                          m.MemberMci_IDNO,
                          p.ComplianceType_CODE,
                          p.Compliance_AMNT,
                          p.NoMissPayment_QNTY,
                          p.Entry_DATE,
                          p.Effective_DATE,
                          p.End_DATE,
                          p.Compliance_IDNO,
                          p.TransactionEventSeq_NUMB,
                          0 AS PaybackSord_AMNT,
                          m.MemberMci_IDNO AS NcpMci_IDNO
                     FROM CASE_Y1 c,
                          SORD_Y1 s,
                          CMEM_Y1 m,
                          COMP_Y1 p
                    WHERE c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                      AND s.Case_IDNO = c.Case_IDNO
                      AND (@Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE)
                      AND s.EndValidity_DATE = @Ld_High_DATE
                      AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
                      AND m.Case_IDNO = c.Case_IDNO
                      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                      AND p.Case_IDNO = s.Case_IDNO
                      AND p.OrderSeq_NUMB = s.OrderSeq_NUMB
                      AND p.EndValidity_DATE = @Ld_High_DATE
                      AND p.OrderedParty_CODE = @Lc_CaseRelationshipNcp_CODE
                      AND p.ComplianceStatus_CODE = @Lc_ComplianceStatusActive_CODE
                      AND p.Effective_DATE <= @Ld_Run_DATE
                      AND (p.End_DATE BETWEEN @Ld_RunDateEmonWeekly_DATE AND @Ld_Run_DATE
                            OR p.End_DATE = @Ld_High_DATE)) x) x
    ORDER BY x.Case_IDNO;

   SET @Ls_Sql_TEXT = 'SELECTING COUNT FROM PEWKL';
   SET @Ls_Sqldata_TEXT = ' Total COUNT = ' + ISNULL (CAST (@Ln_TotalCount_NUMB AS VARCHAR (20)), '');

   SELECT @Ln_TotalCount_NUMB = COUNT (1)
     FROM PEWKL_Y1 p;

   SET @Ls_Sql_TEXT = 'DIVIDING THE TOTAL RECORDS WITH THE NUMBER OF THREADS';
   SET @Ls_Sqldata_TEXT = ' Total COUNT = ' + ISNULL (CAST (@Ln_TotalCount_NUMB AS VARCHAR (20)), '') + ', Total threads = ' + ISNULL (CAST (@Ln_ThreadCounts_NUMB AS VARCHAR (19)), '');
   SET @Ln_ThreadAvgCount_NUMB = (@Ln_TotalCount_NUMB / @Ln_ThreadCounts_NUMB);
   SET @Ln_ThreadNextCount_NUMB = @Ln_ThreadAvgCount_NUMB;
   SET @Ls_ListKeyEMON_TEXT = 'TOTAL THREAD COUNT:= ' + ISNULL (CAST (@Ln_ThreadCounts_NUMB AS VARCHAR (19)), '') + ' TOTAL RECORD COUNT:= ' + ISNULL (CAST (@Ln_TotalCount_NUMB AS VARCHAR (19)), '') + ' AVG THREAD COUNT:=' + ISNULL (CAST (@Ln_ThreadNextCount_NUMB AS VARCHAR (19)), '');
   SET @Ls_Sql_TEXT = 'OPENING FOR LOOP TO INSERT DATA INTO VJRTL';
   SET @Ls_Sqldata_TEXT = ' OPENING FOR LOOP TO INSERT DATA INTO VJRTL = ' + ISNULL (CAST (@Ln_TotalCount_NUMB AS VARCHAR (19)), '');

   IF @Ln_ThreadCounts_NUMB = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobProcess_ID + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS CHAR (10)) + ', TotalCount = ' + ISNULL (CAST (@Ln_TotalCount_NUMB AS VARCHAR (19)), '');

     INSERT INTO JRTL_Y1
                 (Job_ID,
                  Run_DATE,
                  Thread_NUMB,
                  RecStart_NUMB,
                  RecEnd_NUMB,
                  RestartKey_TEXT,
                  RecRestart_NUMB,
                  ThreadProcess_CODE)
          VALUES (@Lc_JobProcess_ID,--Job_ID
                  @Ld_Run_DATE,--Run_DATE
                  1,--Thread_NUMB
                  1,--RecStart_NUMB
                  @Ln_TotalCount_NUMB,--RecEnd_NUMB
                  ' ',--RestartKey_TEXT
                  1,--RecRestart_NUMB
                  @Lc_No_CODE --ThreadProcess_CODE
     );

     SET @Ls_ListKeyEMON_TEXT = @Ls_ListKeyEMON_TEXT + ' THREAD NUMBER ' + '1' + 'STARTING THREAD VALUE ' + '0' + 'ENDING THREAD VALUE ' + ISNULL (CAST (@Ln_TotalCount_NUMB AS VARCHAR (19)), '');
    END
   ELSE
    BEGIN
    -- While Loop Begins
     WHILE @Ln_ThreadLoopCount_NUMB <= @Ln_ThreadCounts_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT PEWKL ';
       SET @Ls_Sqldata_TEXT = ' Thread Count = ' + ISNULL (CAST (@Ln_EndThread_NUMB AS VARCHAR (19)), '');

       SELECT @Ln_EndThread_NUMB = MAX (p.RecordRowNumber_NUMB)
         FROM PEWKL_Y1 p
        WHERE p.Case_IDNO IN (SELECT pp.Case_IDNO
                                FROM PEWKL_Y1 pp
                               WHERE pp.RecordRowNumber_NUMB = @Ln_ThreadNextCount_NUMB);

       --If the I is last thread then assign the total records count to end sequence no
       IF @Ln_ThreadLoopCount_NUMB = @Ln_ThreadCounts_NUMB
        BEGIN
         SET @Ln_EndThread_NUMB = @Ln_TotalCount_NUMB;
        END;

       SET @Ls_Sql_TEXT = 'INSERT JRTL ';
       SET @Ls_Sqldata_TEXT = ' Thread_NUMB = ' + ISNULL(CAST(@Ln_ThreadLoopCount_NUMB AS VARCHAR(19)), '') + ', Job_ID = ' + @Lc_JobProcess_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

       --ls_beg_sno is subtracted with 1 since starting record should be always be lesser than
       --serious no(sno)
       INSERT INTO JRTL_Y1
                   (Job_ID,
                    Run_DATE,
                    Thread_NUMB,
                    RecStart_NUMB,
                    RecEnd_NUMB,
                    RestartKey_TEXT,
                    RecRestart_NUMB,
                    ThreadProcess_CODE)
            VALUES (@Lc_JobProcess_ID,--Job_ID
                    @Ld_Run_DATE,--Run_DATE
                    @Ln_ThreadLoopCount_NUMB,--Thread_NUMB
                    @Ln_BeginThread_NUMB,--RecStart_NUMB
                    @Ln_EndThread_NUMB,--RecEnd_NUMB
                    ' ',--RestartKey_TEXT
                    @Ln_BeginThread_NUMB,--RecRestart_NUMB
                    @Lc_No_CODE --ThreadProcess_CODE
       );

       SET @Ls_ListKeyEMON_TEXT = @Ls_ListKeyEMON_TEXT + ' THREAD NUMBER ' + ISNULL (CAST (@Ln_ThreadLoopCount_NUMB AS VARCHAR (19)), '') + 'STARTING THREAD VALUE ' + ISNULL (CAST (@Ln_BeginThread_NUMB AS VARCHAR (19)), '') + 'ENDING THREAD VALUE ' + ISNULL (CAST (@Ln_EndThread_NUMB AS VARCHAR (19)), '');
       --The beginning sequence will be next value for each thread
       SET @Ln_BeginThread_NUMB = @Ln_BeginThread_NUMB + 1;
       SET @Ln_ThreadLoopCount_NUMB = @Ln_ThreadLoopCount_NUMB + 1;
       --The next thread count is calculated by adding the last sequence no and thread count
       SET @Ln_ThreadNextCount_NUMB = @Ln_EndThread_NUMB + @Ln_ThreadAvgCount_NUMB;

       --If @Ln_ThreadNextCount_NUMB greater than ln_total_count then assign ln_total_count to ls_end_sno.
       --This if condition will happen only when same id_member_ncp falls in different thread counts and
       --if thread count is final.
       IF @Ln_ThreadNextCount_NUMB > @Ln_TotalCount_NUMB
        BEGIN
         SET @Ln_ThreadNextCount_NUMB = @Ln_TotalCount_NUMB;
        END;
      END
    END

   -- Update the daily_date field for this procedure in vparm table with the pd_dt_run value
   SET @Ls_Sql_TEXT = 'EPRE020 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobPre_ID + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS CHAR (10));

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobPre_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_Success_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'EPRE020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobPre_ID + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS CHAR (10));

     RAISERROR (50001,16,1);
    END;

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_JobPre_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Ls_ListKeyEMON_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_Success_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalCount_NUMB;

   SET @Lc_Msg_CODE = @Lc_Success_CODE;
   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;

   COMMIT TRANSACTION PRE_EMON_WEEKLY_TRANS;
  END TRY

  BEGIN CATCH
   --CLOSE TRANSACTION
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRAN PRE_EMON_WEEKLY_TRANS;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   --Update Status in Batch Log Table
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_JobPre_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalCount_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
