/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_POST_EMON_ALERTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_EMON$SP_PROCESS_POST_EMON_ALERTS
Programmer Name   : IMP Team
Description       : This procedure is used to create RLEAS alerts
Frequency         : DAILY
Developed On      : 01/05/2012
Called BY         : None
Called On         : BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK, BATCH_COMMON$SP_INSERT_ACTIVITY, 
					BATCH_COMMON$BATE_LOG and BATCH_COMMON$BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_POST_EMON_ALERTS]
AS
 BEGIN
  SET NOCOUNT ON;

  
  DECLARE @Lc_StatusFailed_CODE					CHAR(1)			= 'F',
          @Lc_StatusNoDataFound_CODE			CHAR(1)			= 'N',
          @Lc_TypeErrorE_CODE					CHAR(1)			= 'E',
          @Lc_Space_TEXT						CHAR(1)			= ' ',
          @Lc_No_INDC							CHAR(1)			= 'N',
          @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
          @Lc_StatusAbnormalend_CODE			CHAR(1)			= 'A',
          @Lc_CaseStatusOpen_CODE				CHAR(1)			= 'O',
          @Lc_SubsystemCaseManagement_CODE		CHAR(3)			= 'CM',
          @Lc_MajorActivityCase_CODE			CHAR(4)			= 'CASE',
          @Lc_ActivityMinorRleas_CODE			CHAR(5)			= 'RLEAS',
          @Lc_ErrorBatch_CODE					CHAR(5)			= 'E1424',
          @Lc_ErrorE0958_CODE					CHAR(5)			= 'E0958',
          @Lc_ErrorE0087_CODE					CHAR(5)			= 'E0087',
          @Lc_ErrorE1081_CODE					CHAR(5)			= 'E1081',
          @Lc_JobEmon_ID						CHAR(7)			= 'DEB0670',
          @Lc_Job_ID							CHAR(7)			= 'DEB0676',
          @Lc_Successful_TEXT					CHAR(20)		= 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT					CHAR(30)		= 'BATCH',
          @Ls_Process_NAME						VARCHAR(100)	= 'BATCH_ENF_EMON',
          @Ls_Routine_TEXT						VARCHAR(100)	= 'SP_PROCESS_POST_EMON_ALERTS',
          @Ld_High_DATE							DATE			= '12/31/9999',
          @Ld_Low_DATE							DATE			= '01/01/0001';
          
  DECLARE @Ln_UserDefinedException_NUMB			NUMERIC(2),
          @Ln_CommitFreqParm_QNTY				NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY		NUMERIC(5),
          @Ln_Topic_IDNO						NUMERIC(10),
          @Ln_Commit_QNTY						NUMERIC(10)		= 0,
          @Ln_Cursor_QNTY						NUMERIC(10)		= 0,
          @Ln_Exception_QNTY					NUMERIC(10)		= 0,
          @Ln_Error_NUMB						NUMERIC(11),
          @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB			NUMERIC(19),
          @Li_FetchStatus_BIT					SMALLINT,
          @Lc_Msg_CODE							CHAR(5),
          @Lc_Error_CODE						CHAR(5),
          @Ls_Sql_TEXT							VARCHAR(400),
          @Ls_Sqldata_TEXT						VARCHAR(4000)	= ' ',
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ld_Start_DATE						DATETIME2,
          @Ld_Run_DATE							DATETIME2,
          @Ld_LastRun_DATE						DATETIME2;
          
  DECLARE @Ln_AlertCurCase_IDNO					NUMERIC(6),
          @Ln_AlertCurNcpPf_IDNO				NUMERIC(10);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START TIME';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;
   
   BEGIN TRANSACTION Post_Emon_Alert_Transaction;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobEmon_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_JobEmon_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED';
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'Alert_Cur  CURSOR';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   
   DECLARE Alert_Cur INSENSITIVE CURSOR FOR
   SELECT e.Case_IDNO,
          e.NcpPf_IDNO
     FROM ENSD_Y1 e
    WHERE e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
	  AND EXISTS ( SELECT 1 
					 FROM CASE_Y1 c
					WHERE c.Case_IDNO = e.Case_IDNO
					  AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE )
      AND e.Released_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE)
      AND DATEADD(D, -60, e.Released_DATE) BETWEEN @Ld_LastRun_DATE AND @Ld_Run_DATE
      AND DATEADD(D, 10, (SELECT ISNULL(MAX(n.Entered_DATE), @Ld_Low_DATE)
                            FROM DMNR_Y1 n
                           WHERE n.Case_IDNO = e.Case_IDNO
                             AND n.ActivityMajor_CODE = @Lc_MajorActivityCase_CODE
                             AND n.ActivityMinor_CODE = @Lc_ActivityMinorRleas_CODE)) <= @Ld_Run_DATE;
                             
   SET @Ls_Sql_TEXT = 'Alert_Cur  CURSOR OPEN';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   OPEN Alert_Cur;

   SET @Ls_Sql_TEXT = 'Alert_Cur  CURSOR FETCH';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   FETCH NEXT FROM Alert_Cur INTO @Ln_AlertCurCase_IDNO, @Ln_AlertCurNcpPf_IDNO;

   SET @Li_FetchStatus_BIT = @@FETCH_STATUS;
   WHILE @Li_FetchStatus_BIT = 0
    BEGIN
      SAVE TRANSACTION Alert_Cursor_Transaction;
      SET @Ln_Commit_QNTY = @Ln_Commit_QNTY + 1;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Lc_Error_CODE = @Lc_ErrorBatch_CODE;
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

      EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID               = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
       @Ac_Note_INDC                = @Lc_No_INDC,
       @An_EventFunctionalSeq_NUMB  = 0,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
       BEGIN
			RAISERROR (50001,16,1);
       END
       
      BEGIN TRY

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_AlertCurCase_IDNO AS CHAR(6)) + ', MemberMci_IDNO = ' + CAST(@Ln_AlertCurNcpPf_IDNO AS VARCHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR(19)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

      EXEC BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_AlertCurCase_IDNO,
       @An_MemberMci_IDNO           = @Ln_AlertCurNcpPf_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRleas_CODE,
       @Ac_Subsystem_CODE           = @Lc_SubsystemCaseManagement_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY FAILED ' + ISNULL(@Ls_DescriptionError_TEXT, '');
         RAISERROR(50001,16,1);
        END
     END TRY
     BEGIN CATCH
     
		IF XACT_STATE() = 1
			BEGIN
			   ROLLBACK TRANSACTION Alert_Cursor_Transaction;
			END
		ELSE
			BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
				RAISERROR( 50001 ,16,1);
			END
		SAVE TRANSACTION Alert_Cursor_Transaction;
      
        IF LEN(@Lc_Msg_CODE) != 5
            SET @Lc_Error_CODE = @Lc_ErrorE1081_CODE;
        ELSE
			SET @Lc_Error_CODE = @Lc_Msg_CODE;
           
       
         SET @Ls_DescriptionError_TEXT = ISNULL(@Ls_Sqldata_TEXT, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_DescriptionError_TEXT, '');
         SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_POST_EMON_ALERTS : BATCH_COMMON$SP_BATE_LOG IN FORMS';
         SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME				= @Ls_Process_NAME,
          @As_Procedure_NAME			= @Ls_Routine_TEXT,
          @Ac_Job_ID					= @Lc_Job_ID,
          @Ad_Run_DATE					= @Ld_Run_DATE,
          @Ac_TypeError_CODE			= @Lc_TypeErrorE_CODE,
          @An_Line_NUMB					= @Ln_Cursor_QNTY,
          @Ac_Error_CODE				= @Lc_Error_CODE,
          @As_DescriptionError_TEXT		= @Ls_DescriptionError_TEXT,
          @As_ListKey_TEXT				= @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE					= @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT	= @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
		   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_POST_EMON_ALERTS : BATCH_COMMON$SP_BATE_LOG IN FORMS - FAILED';
           SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
           RAISERROR(50001,16,1);
          END
         ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
          BEGIN
			SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
		  END;
      END CATCH
      
     IF (@Ln_Commit_QNTY >= @Ln_CommitFreqParm_QNTY)
      BEGIN
        COMMIT TRANSACTION Post_Emon_Alert_Transaction;
        BEGIN TRANSACTION Post_Emon_Alert_Transaction;
		SET @Ln_Commit_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = ' EXCP_COUNT = ' + ISNULL(CAST(@Ln_Exception_QNTY AS VARCHAR(9)), '') + ', @Ln_ExceptionThresholdParm_QNTY = ' + ISNULL(CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR(19)), '');

     IF (@Ln_Exception_QNTY > @Ln_ExceptionThresholdParm_QNTY
        AND @Ln_ExceptionThresholdParm_QNTY > 0)
      BEGIN
	   COMMIT TRANSACTION Post_Emon_Alert_Transaction;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM Alert_Cur INTO @Ln_AlertCurCase_IDNO, @Ln_AlertCurNcpPf_IDNO;

     SET @Li_FetchStatus_BIT = @@FETCH_STATUS;
    END

   CLOSE Alert_Cur;
   DEALLOCATE Alert_Cur;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION Post_Emon_Alert_Transaction;
    END
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION Post_Emon_Alert_Transaction;
    END

   IF CURSOR_STATUS('VARIABLE', 'Alert_Cur') IN (0, 1)
    BEGIN
     CLOSE Alert_Cur;

     DEALLOCATE Alert_Cur;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE					= @Ld_Run_DATE,
    @Ad_Start_DATE					= @Ld_Start_DATE,
    @Ac_Job_ID						= @Lc_Job_ID,
    @As_Process_NAME				= @Ls_Process_NAME,
    @As_Procedure_NAME				= @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT			= @Ln_Cursor_QNTY,
    @As_ExecLocation_TEXT			= @Ls_Sql_TEXT,
    @As_ListKey_TEXT				= @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT		= @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE					= @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID					= @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY	= @Ln_Cursor_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
