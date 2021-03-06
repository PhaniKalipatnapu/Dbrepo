/****** Object:  StoredProcedure [dbo].[BATCH_FIN_GENERATE_FINS$SP_PROCESS_GENERATE_FIN_SUMMARY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_GENERATE_FINS$SP_PROCESS_GENERATE_FIN_SUMMARY   
Programmer Name 	: IMP Team
Description			: This Proecdure generates the data to populate all the Collection, Distribution and
					  Disbursement details necessary for Financial Summary (FINS) Report into RFINS_Y1 table  
Frequency			: 'DAILY'
Developed On		: 11/29/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_GENERATE_FINS$SP_PROCESS_GENERATE_FIN_SUMMARY]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
		  @Lc_StatusSuccess_CODE				 CHAR (1) = 'S', 	
		  @Lc_StatusAbnormalend_CODE			 CHAR (1) = 'A', 		
		  @Lc_Space_TEXT						 CHAR (1) = ' ',
          @Lc_Job_ID                             CHAR (7) = 'DEB0880',
          @Lc_Successful_TEXT                    CHAR (20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                  CHAR (30) = 'BATCH',
          @Ls_Sql_TEXT                           VARCHAR (100) = ' ',
          @Ls_Process_NAME                       VARCHAR (100) = 'BATCH_FIN_GENERATE_FINS',
          @Ls_Procedure_NAME                     VARCHAR (100) = 'SP_PROCESS_GENERATE_FIN_SUMMARY',
          @Ls_Sqldata_TEXT                       VARCHAR (4000) = ' ';
  DECLARE @Ln_CommitFreqParm_QNTY                NUMERIC (5),
          @Ln_ExceptionThresholdParm_QNTY        NUMERIC (5),
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
          @Ln_Error_NUMB                       NUMERIC (11),
          @Ln_ErrorLine_NUMB                   NUMERIC (11),
          @Ln_Count_QNTY                       NUMERIC (11),
          @Ln_Cursor_QNTY                      NUMERIC (19) = 0,
		  @Li_Rowcount_QNTY                    SMALLINT,
          @Lc_Msg_CODE                         CHAR,
          @Ls_CursorLoc_TEXT                   VARCHAR (200) = '',
          @Ls_ErrorMessage_TEXT                VARCHAR (4000),
          @Ls_DescriptionError_TEXT            VARCHAR (4000),
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_Run_DATE                   DATE,
          @Ld_PlusOne_Run_DATE                 DATE,
          @Ld_Start_DATE                       DATETIME2;

  BEGIN TRY
   BEGIN TRANSACTION FinsTran;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
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
     RAISERROR(50001,16,1);
    END
   -- To pickup the data for the missed date also
   SET @Ld_Start_Run_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
   -- To take the daily details for the run date 	
   SET @Ld_PlusOne_Run_DATE = DATEADD(D, 1, @Ld_Run_DATE);
   
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Process_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);	
   IF DATEADD(d,1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EXISTENCE CHECK - RFINS_Y1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ln_Count_QNTY = COUNT(1)
     FROM RFINS_Y1 r
    WHERE r.Generate_DATE = @Ld_Run_DATE;

   IF @Ln_Count_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE RFINS_Y1';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     DELETE RFINS_Y1 
      WHERE Generate_DATE = @Ld_Run_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

       RAISERROR(50001,16,1);
      END
    END
	
   SET @Ls_Sql_TEXT = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_COLLECTION';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ld_Start_Run_DATE AS VARCHAR), '') + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '');	
   EXECUTE BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_COLLECTION 
		@Ad_Run_DATE				  = @Ld_Run_DATE,
		@Ad_Start_Run_DATE			  = @Ld_Start_Run_DATE,
		@Ad_LastRun_DATE			  = @Ld_LastRun_DATE,
		@Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;
		
	IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END		
    
    SET @Ls_Sql_TEXT = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DISTRIBUTION';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ld_Start_Run_DATE AS VARCHAR), '') + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '');	
    EXECUTE BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DISTRIBUTION 
		@Ad_Run_DATE				  = @Ld_Run_DATE,
		@Ad_Start_Run_DATE			  = @Ld_Start_Run_DATE,
		@Ad_PlusOne_Run_DATE		  = @Ld_PlusOne_Run_DATE,
		@Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;
		
	IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END		
   
   SET @Ls_Sql_TEXT = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DIBURSEMENT';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ld_Start_Run_DATE AS VARCHAR), '') + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '');	
   EXECUTE BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DIBURSEMENT 
		@Ad_Run_DATE				  = @Ld_Run_DATE,
		@Ad_Start_Run_DATE			  = @Ld_Start_Run_DATE,
		@Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;
		
	IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END		
    
   SET @Ls_Sql_TEXT = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ld_Start_Run_DATE AS VARCHAR), '') + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', PlusOne_Run_DATE = ' + ISNULL(CAST(@Ld_PlusOne_Run_DATE AS VARCHAR), '');
   EXECUTE BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY1 
		@Ad_Run_DATE				= @Ld_Run_DATE,
		@Ad_Start_Run_DATE			= @Ld_Start_Run_DATE,
		@Ad_LastRun_DATE			= @Ld_LastRun_DATE,
		@Ad_PlusOne_Run_DATE		= @Ld_PlusOne_Run_DATE,
		@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;
   
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
	
   SET @Ls_Sql_TEXT = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY2';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ld_Start_Run_DATE AS VARCHAR), '') + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', PlusOne_Run_DATE = ' + ISNULL(CAST(@Ld_PlusOne_Run_DATE AS VARCHAR), '');
   EXECUTE BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY2 
		@Ad_Run_DATE				= @Ld_Run_DATE,
		@Ad_Start_Run_DATE			= @Ld_Start_Run_DATE,
		@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;
   
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   
   
   SET @Ls_Sql_TEXT = 'RFINS COUNT QANTITY';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') ;
    
   SELECT  @Ln_ProcessedRecordsCountCommit_QNTY = COUNT(1) 
   FROM RFINS_Y1 
   WHERE Generate_DATE = @Ld_Run_DATE;
												
	    	
   SET @Ls_Sql_TEXT = 'UPDATE PARM TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(CAST( @Ln_Cursor_QNTY AS VARCHAR ),'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordsCountCommit_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   COMMIT TRANSACTION FinsTran; --1
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FinsTran;
    END

   -- Check for Exception information to log the description text based on the error		
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
