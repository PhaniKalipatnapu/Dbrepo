/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_IRS_RECON_REJECTS$SP_PROCESS_RECON_REJECTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_INCOMING_IRS_RECON_REJECTS$SP_PROCESS_RECON_REJECTS

Programmer Name 	: IMP Team

Description			: This process reads the data from the temporary table LOAD_IRS_REJECTS
					  and creates a report for the worker to manually change the
					  reconciliation details and send it to the NCP.

Frequency			: 'ANNUALLY'

Developed On		: 11/17/2011

Called BY			: None

Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_IRS_RECON_REJECTS$SP_PROCESS_RECON_REJECTS]
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE  @Lc_Yes_INDC                     CHAR (1) = 'Y',
           @Lc_StatusSuccess_CODE           CHAR (1) = 'S',
           @Lc_No_INDC                      CHAR (1) = 'N',
           @Lc_StatusFailed_CODE            CHAR (1) = 'F',
           @Lc_ErrorTypeInformation_CODE    CHAR (1) = 'I',
           @Lc_ErrorTypeWarning_CODE        CHAR (1) = 'W',
           @Lc_StatusAbnormalend_CODE       CHAR (1) = 'A',
           @Lc_TypeErrorE_CODE              CHAR (1) = 'E',
           @Lc_Space_TEXT                   CHAR (1) = ' ',
           @Lc_BateError_CODE               CHAR (5) = ' ',
           @Lc_ErrorE0944_CODE              CHAR (5) = 'E0944',
           @Lc_ErrorI0033_CODE			    CHAR (5) = 'I0033',
           @Lc_BateErrorE1424_CODE          CHAR (5) = 'E1424',
           @Lc_Job_ID                       CHAR (7) = 'DEB9060',
           @Lc_Successful_TEXT              CHAR (20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT            CHAR (30) = 'BATCH',
           @Ls_Process_NAME                 VARCHAR (100) = 'BATCH_ENF_INCOMING_IRS_RECON_REJECTS',
           @Ls_Procedure_NAME               VARCHAR (100) = 'SP_PROCESS_RECON_REJECTS';
  DECLARE  @Ln_CommitFreq_QNTY              NUMERIC (5) = 0,
		   @Ln_CommitFreqParm_QNTY          NUMERIC (5) = 0,
		   @Ln_ExceptionThresholdParm_QNTY  NUMERIC (5),
		   @Ln_ExceptionThreshold_QNTY      NUMERIC (5) = 0,
           @Ln_ProcessedRecordCount_QNTY    NUMERIC (6) = 0,
           @Ln_ProcessedRecordsCommit_QNTY  NUMERIC (6) = 0,
           @Ln_Cursor_QNTY                  NUMERIC (10) = 0,
           @Ln_CursorRecord_QNTY            NUMERIC (10) = 0,
           @Ln_Error_NUMB                   NUMERIC (11),
           @Ln_ErrorLine_NUMB               NUMERIC (11),
           @Li_FetchStatus_QNTY             SMALLINT,
           @Li_Rowcount_QNTY                SMALLINT,
           @Lc_Msg_CODE                     CHAR (3),
           @Lc_Error_CODE                   CHAR (18),
           @Ls_Sql_TEXT                     VARCHAR (100),
           @Ls_CursorLocation_TEXT          VARCHAR (200),
           @Ls_Sqldata_TEXT                 VARCHAR (1000),
           @Ls_ErrorMessage_TEXT            VARCHAR (2000),
           @Ls_DescriptionError_TEXT        VARCHAR (4000),
           @Ls_BateRecord_TEXT              VARCHAR (4000),
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE,
           @Ld_Start_DATE                   DATETIME2;
  DECLARE @Lc_IrsCur_CountyIdno_TEXT        CHAR(3),
          @Lc_IrsCur_CaseIdno_TEXT          CHAR(15),
          @Lc_IrsCur_MemberSsnNumb_TEXT     CHAR(9),
          @Lc_IrsCur_Last_NAME				CHAR(20),
          @Lc_IrsCur_First_NAME				CHAR(15),
          @Lc_IrsCur_ArrearsAmnt_TEXT       CHAR(8),
          @Lc_IrsCur_TransType_CODE			CHAR(1),
          @Lc_IrsCur_IssuedDate_TEXT        CHAR(8),
          @Lc_IrsCur_Error_CODE				CHAR(12),
          @Lc_IrsCur_StateSubmit_CODE		CHAR(2),
          @Lc_IrsCur_CaseType_CODE			CHAR(1),
          @Lc_IrsCur_ProcessYearNumb_TEXT   CHAR(4),
          @Lc_IrsCur_StateTransfer_CODE		CHAR(2),
          @Lc_IrsCur_LocalTransfer_CODE		CHAR(3),
          @Lc_IrsCur_Line1_ADDR				CHAR(30),
          @Lc_IrsCur_Line2_ADDR				CHAR(30),
          @Lc_IrsCur_State_ADDR				CHAR(2),
          @Lc_IrsCur_Zip_ADDR				CHAR(9),
          @Lc_IrsCur_Exclusion_CODE			CHAR(40);
  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   /*
		Get the run date and last run date from PARM_Y1 table and validate that the batch program was 
		not executed for the run date, by ensuring that the run date is different from the last run 
		date in the PARM_Y1 table.  Otherwise, an error message to that effect will be written into 
		Batch Status Log (BSTL) screen / Batch Status Log (BSTL_Y1) table and terminate the process.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
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
   -- Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST (@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END

   -- Read the reconciliation reject data from the temporary table (LIRRE_Y1) and create a report for the worker
   DECLARE 
	Irs_CUR INSENSITIVE CURSOR FOR
    SELECT l.County_IDNO,
           LTRIM(RTRIM((l.Case_IDNO)))  AS Case_IDNO,
           LTRIM(RTRIM((l.MemberSsn_NUMB))) AS MemberSsn_NUMB,
           l.Last_NAME,
           l.First_NAME,
           l.Arrears_AMNT,
           l.TransType_CODE,
           l.Issued_DATE,
           l.Error_CODE,
           l.StateSubmit_CODE,
           l.CaseType_CODE,
           l.ProcessYear_NUMB,
           l.StateTransfer_CODE,
           l.LocalTransfer_CODE,
           l.Line1_ADDR,
           l.Line2_ADDR,
           l.State_ADDR,
           l.Zip_ADDR,
           l.Exclusion_CODE
      FROM LIRRE_Y1 l
     WHERE l.Process_INDC = @Lc_No_INDC;

   BEGIN TRANSACTION IRSReconcile;

   SET @Ls_Sql_TEXT = 'OPEN Irs_CUR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN Irs_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Irs_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM Irs_CUR INTO @Lc_IrsCur_CountyIdno_TEXT, @Lc_IrsCur_CaseIdno_TEXT, @Lc_IrsCur_MemberSsnNumb_TEXT, @Lc_IrsCur_Last_NAME, @Lc_IrsCur_First_NAME, @Lc_IrsCur_ArrearsAmnt_TEXT, @Lc_IrsCur_TransType_CODE, @Lc_IrsCur_IssuedDate_TEXT, @Lc_IrsCur_Error_CODE, @Lc_IrsCur_StateSubmit_CODE, @Lc_IrsCur_CaseType_CODE, @Lc_IrsCur_ProcessYearNumb_TEXT, @Lc_IrsCur_StateTransfer_CODE, @Lc_IrsCur_LocalTransfer_CODE, @Lc_IrsCur_Line1_ADDR, @Lc_IrsCur_Line2_ADDR, @Lc_IrsCur_State_ADDR, @Lc_IrsCur_Zip_ADDR, @Lc_IrsCur_Exclusion_CODE;
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      -- Cursor loop started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION IRSReconcileSave;
     SET @Ls_ErrorMessage_TEXT = '';
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     -- Incrementing the cursor count and the commit count for each record being processed.
     SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
     SET @Ln_CursorRecord_QNTY = @Ln_CursorRecord_QNTY + 1;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_BateRecord_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_IrsCur_CaseIdno_TEXT, '') + ', TransType_CODE = ' + ISNULL(@Lc_IrsCur_TransType_CODE, '') + ', CaseType_CODE = ' + ISNULL(@Lc_IrsCur_CaseType_CODE, '') + ', ProcessYear_NUMB = ' + ISNULL(@Lc_IrsCur_ProcessYearNumb_TEXT, '') + ', County_IDNO = ' + ISNULL (@Lc_IrsCur_CountyIdno_TEXT, '') + ', StateSubmit_CODE = ' + ISNULL(@Lc_IrsCur_StateSubmit_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_IrsCur_MemberSsnNumb_TEXT, '') + ', Last_NAME = ' + ISNULL(@Lc_IrsCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_IrsCur_First_NAME, '') + ', Arrears_AMNT = ' + ISNULL(@Lc_IrsCur_ArrearsAmnt_TEXT, '') + ', Issued_DATE = ' + ISNULL(@Lc_IrsCur_IssuedDate_TEXT, '') + ', Error_CODE = ' + ISNULL(@Lc_IrsCur_Error_CODE, '') + ', Exclusion_CODE = ' + ISNULL(@Lc_IrsCur_Exclusion_CODE, '');
     SET @Lc_Error_CODE = @Lc_ErrorI0033_CODE;
     /*
		Also write reject records into BATE_Y1 table in 'DescriptionError_TEXT' field and upon successful 
		completion update BATE_Y1 table with message I0033 - Process Successful
     */
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeInformation_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_Error_CODE, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_Error_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
      END TRY
     BEGIN CATCH
       -- Rollback the save point.
      IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION IRSReconcileSave;
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
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

      SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
     END CATCH
     
     -- Updating process indicator to Y
     SET @Ls_Sql_TEXT = 'UPDATING LIRRE_Y1';
     SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Case_IDNO = ' + ISNULL(@Lc_IrsCur_CaseIdno_TEXT, '') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_IrsCur_MemberSsnNumb_TEXT, '');
     UPDATE LIRRE_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Process_INDC = @Lc_No_INDC
        AND Case_IDNO = @Lc_IrsCur_CaseIdno_TEXT
        AND MemberSsn_NUMB = @Lc_IrsCur_MemberSsnNumb_TEXT
		AND CaseType_CODE = @Lc_IrsCur_CaseType_CODE;
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     
     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE LIRRE_Y1 FAILED';
       RAISERROR(50001,16,1);
      END
      
	 SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
	 SET @Ls_Sql_TEXT = 'COMMIT COUNT CHECK';
     SET @Ls_Sqldata_TEXT = 'CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR) + ', CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR);
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreq_QNTY <> 0
      BEGIN
       COMMIT TRANSACTION IRSReconcile;
       
	   SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
	
       BEGIN TRANSACTION IRSReconcile;

       SET @Ln_CommitFreq_QNTY = 0;
      END
     
      SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
      SET @Ls_Sqldata_TEXT = 'ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
      IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
       BEGIN
        COMMIT TRANSACTION IRSReconcile;
        SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
        SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

        RAISERROR (50001,16,1);
       END 
	 SET @Ls_Sql_TEXT = 'FETCH Irs_CUR - 2';
	 SET @Ls_Sqldata_TEXT = '';
     FETCH NEXT FROM Irs_CUR INTO @Lc_IrsCur_CountyIdno_TEXT, @Lc_IrsCur_CaseIdno_TEXT, @Lc_IrsCur_MemberSsnNumb_TEXT, @Lc_IrsCur_Last_NAME, @Lc_IrsCur_First_NAME, @Lc_IrsCur_ArrearsAmnt_TEXT, @Lc_IrsCur_TransType_CODE, @Lc_IrsCur_IssuedDate_TEXT, @Lc_IrsCur_Error_CODE, @Lc_IrsCur_StateSubmit_CODE, @Lc_IrsCur_CaseType_CODE, @Lc_IrsCur_ProcessYearNumb_TEXT, @Lc_IrsCur_StateTransfer_CODE, @Lc_IrsCur_LocalTransfer_CODE, @Lc_IrsCur_Line1_ADDR, @Lc_IrsCur_Line2_ADDR, @Lc_IrsCur_State_ADDR, @Lc_IrsCur_Zip_ADDR, @Lc_IrsCur_Exclusion_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Irs_CUR;

   DEALLOCATE Irs_CUR;

   IF @Ln_CursorRecord_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_ErrorTypeWarning_CODE + ', Line_NUMB = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorE0944_CODE + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT; 
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @As_DescriptionError_TEXT    = '',
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   -- Update the last date in the parameter table with the run date, upon successful completion
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   BEGIN
    RAISERROR(50001,16,1);
   END 

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', RestartKey_TEXT = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '');
   EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @As_RestartKey_TEXT       = @Ln_Cursor_QNTY,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   
   /*
   	Log the Error encountered or successful completion in the status log table 
   	for future references.
   */	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION IRSReconcile;
  END TRY

  BEGIN CATCH
  
  -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IRSReconcile;
    END
  -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS ('Local', 'Irs_CUR') IN (0, 1)
    BEGIN
     CLOSE Irs_CUR;
     DEALLOCATE Irs_CUR;
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
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
