/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_POST_EMON_UPDATES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_EMON$SP_PROCESS_POST_EMON_UPDATES
Programmer Name   : IMP Team
Description       : This procedure is to release the eligible cases from Enforcement exempt after the completion EMON daily job
Frequency         : DAILY
Developed On      : 01/05/2012
Called BY         : None
Called On         : BATCH_COMMON$SP_GET_BATCH_DETAILS , BATCH_ENF_EMON$SP_INSERT_ACEN,BATCH_COMMON$BATE_LOG and BATCH_COMMON$BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_POST_EMON_UPDATES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_EnforcementStatusExempt_CODE		CHAR(1)				= 'E',
          @Lc_StatusSuccess_CODE				CHAR(1)				= 'S',
          @Lc_StatusFailure_CODE				CHAR(1)				= 'F',
          @Lc_TypeErrorE_CODE					CHAR(1)				= 'E',
          @Lc_Space_TEXT						CHAR(1)				= ' ',
          @Lc_StatusAbnormalend_CODE			CHAR(1)				= 'A',
          @Lc_ErrorBatch_CODE					CHAR(5)				= 'E1424',
          @Lc_Job_ID							CHAR(7)				= 'DEB0674',
          @Lc_JobProcess_ID						CHAR(7)				= 'DEB0670',
          @Lc_Successful_TEXT					CHAR(20)			= 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT					CHAR(30)			= 'BATCH',
          @Ls_Process_NAME						VARCHAR(100)		= 'BATCH_ENF_EMON',
          @Ls_Procedure_NAME					VARCHAR(100)		= 'SP_PROCESS_POST_EMON_UPDATES',
          @Ld_High_DATE							DATE				= '12/31/9999';
          
  DECLARE @Li_FetchStatus_BIT					SMALLINT,
          @Ln_CommitFreqParm_QNTY				NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY		NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY			NUMERIC(5)			= 0,
          @Ln_Commit_QNTY						NUMERIC(10)			= 0,
          @Ln_Cursor_QNTY						NUMERIC(10)			= 0,
          @Ln_Error_NUMB						NUMERIC(11),
          @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Lc_Msg_CODE							CHAR(5)				= 'E1424',
          @Ls_Sql_TEXT							VARCHAR(100),
          @Ls_Sqldata_TEXT						VARCHAR(800),
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ld_Run_DATE							DATE,
          @Ld_LastRun_DATE						DATE,
          @Ld_Start_DATE						DATETIME2;
  
  DECLARE @Ln_AcenExemptCur_OrderSeqNumb_Numb				NUMERIC(2),
          @Ln_AcenExemptCur_Case_IDNO						NUMERIC(6),
          @Ln_AcenExemptCur_TransactionEventSeq_NUMB		NUMERIC(19),
          @Ld_AcenExemptCur_BeginEnforcement_DATE			DATE;
          

  BEGIN TRY
   BEGIN TRANSACTION Main_Transaction;

   SET @Ls_Sql_TEXT = 'GET BATCH START TIME';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

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
     SET @Ls_DescriptionError_TEXT = 'PARM DATE CONDITION FAILED';
     SET @Ls_Sqldata_TEXT = ' LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS CHAR(10)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobProcess_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_JobProcess_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'ACEN_Y1 EXEMPT CURSOR';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   DECLARE AcenExempt_Cur INSENSITIVE CURSOR 
   FOR SELECT e.Case_IDNO,
              e.OrderSeq_NUMB,
              e.BeginEnforcement_DATE,
              e.TransactionEventSeq_NUMB
         FROM ACEN_Y1 e
        WHERE e.EndExempt_DATE <= @Ld_Run_DATE
          AND e.StatusEnforce_CODE = @Lc_EnforcementStatusExempt_CODE
          AND e.EndValidity_DATE = @Ld_High_DATE;
   SET @Ls_Sql_TEXT = 'ACEN_Y1 EXEMPT CURSOR OPEN';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   OPEN AcenExempt_Cur;

   SET @Ls_Sql_TEXT = 'ACEN_Y1 EXEMPT CURSOR FETCH';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

   FETCH NEXT FROM AcenExempt_Cur INTO @Ln_AcenExemptCur_Case_IDNO, @Ln_AcenExemptCur_OrderSeqNumb_Numb, @Ld_AcenExemptCur_BeginEnforcement_DATE, @Ln_AcenExemptCur_TransactionEventSeq_NUMB;

   SET @Li_FetchStatus_BIT = @@FETCH_STATUS;
   WHILE @Li_FetchStatus_BIT = 0
    BEGIN
     BEGIN TRY
		 SAVE TRANSACTION Cursor_Transaction;
		 SET @Ln_Commit_QNTY = @Ln_Commit_QNTY + 1;
		 SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
		 SET @Lc_Msg_CODE = @Lc_ErrorBatch_CODE;
		 SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ACEN';
		 SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_AcenExemptCur_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@Ln_AcenExemptCur_OrderSeqNumb_Numb AS CHAR(2)) + ', BeginEnforcement_DATE = ' + ISNULL(CAST(@Ld_AcenExemptCur_BeginEnforcement_DATE AS CHAR(10)), '') + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_AcenExemptCur_TransactionEventSeq_NUMB AS VARCHAR (19)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) + ', WorkerUpdate_ID = ' + @Lc_BatchRunUser_TEXT;

		 EXECUTE BATCH_ENF_EMON$SP_INSERT_ACEN
		  @An_Case_IDNO                = @Ln_AcenExemptCur_Case_IDNO,
		  @An_OrderSeq_NUMB            = @Ln_AcenExemptCur_OrderSeqNumb_Numb,
		  @Ad_BeginEnforcement_DATE    = @Ld_AcenExemptCur_BeginEnforcement_DATE,
		  @Ad_Run_DATE                 = @Ld_Run_DATE,
		  @Ac_WorkerSignedOn_ID        = @Lc_BatchRunUser_TEXT,
		  @An_TransactionEventSeq_NUMB = @Ln_AcenExemptCur_TransactionEventSeq_NUMB,
		  @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
		  @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

		 IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
		  BEGIN
		   SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ACEN Failed : ' +@Ls_DescriptionError_TEXT;
		   RAISERROR (50001,16,1);
		  END
     END TRY
        
	 BEGIN CATCH     
        
		IF XACT_STATE() = 1
			BEGIN
			   ROLLBACK TRANSACTION Cursor_Transaction;
			END
		  ELSE
			BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
				RAISERROR( 50001 ,16,1);
			END
		
		  SAVE TRANSACTION Cursor_Transaction;
		  
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
    
		EXECUTE BATCH_COMMON$SP_BATE_LOG
		 @As_Process_NAME          = @Ls_Process_NAME,
		 @As_Procedure_NAME        = @Ls_Procedure_NAME,
		 @Ac_Job_ID                = @Lc_Job_ID,
		 @Ad_Run_DATE              = @Ld_Run_DATE,
		 @Ac_TypeError_CODE        = @Lc_Msg_CODE,
		 @An_Line_NUMB             = @Ln_Cursor_QNTY,
		 @Ac_Error_CODE            = @Lc_Msg_CODE,
		 @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
		 @As_ListKey_TEXT          = @Ls_SQLData_TEXT,
		 @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

		  IF @Lc_Msg_CODE = @Lc_StatusFailure_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END
		  ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
			BEGIN
			 SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
			END
 
	END CATCH

     IF (@Ln_Commit_QNTY >= @Ln_CommitFreqParm_QNTY)
      BEGIN
         COMMIT TRANSACTION Main_Transaction;
         BEGIN TRANSACTION Main_Transaction;
         SET @Ln_Commit_QNTY = 0;
      END
      
	/* If the Erroneous Exceptions are more than the threshold, then we need to
     	abend the program. The commit will ensure that the records processed so far without
     	any problems are committed. Also the exception entries are committed so
     	that it will be easy to determine the error records.*/
     SET @Ls_SQL_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_SQLData_TEXT = 'Excp_Count = ' + ISNULL(CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR(20)), '') + ', @Ln_ExceptionThresholdParm_QNTY = ' + ISNULL(CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR(5)), '');
     
     IF (@Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        AND @Ln_ExceptionThresholdParm_QNTY > 0)
      BEGIN
       COMMIT TRANSACTION Main_Transaction; 
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
	
       RAISERROR (50001,16,1);
      END
      
     FETCH NEXT FROM AcenExempt_Cur INTO @Ln_AcenExemptCur_Case_IDNO, @Ln_AcenExemptCur_OrderSeqNumb_Numb, @Ld_AcenExemptCur_BeginEnforcement_DATE, @Ln_AcenExemptCur_TransactionEventSeq_NUMB;

     SET @Li_FetchStatus_BIT = @@FETCH_STATUS;
    END

   CLOSE AcenExempt_Cur;

   DEALLOCATE AcenExempt_Cur;

   SET @Ln_Commit_QNTY = 0;
   SET @Ln_Cursor_QNTY = 0;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(12)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(12)), '');

     RAISERROR (50001,16,1);
    END

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION Main_Transaction;
    END
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION Main_Transaction;
    END

   IF CURSOR_STATUS('VARIABLE', 'AcenExempt_Cur') IN (0, 1)
    BEGIN
     CLOSE AcenExempt_Cur;

     DEALLOCATE AcenExempt_Cur;
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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
