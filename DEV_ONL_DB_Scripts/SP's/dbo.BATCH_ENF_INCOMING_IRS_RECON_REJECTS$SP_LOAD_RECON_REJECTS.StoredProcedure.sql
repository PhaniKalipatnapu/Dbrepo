/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_IRS_RECON_REJECTS$SP_LOAD_RECON_REJECTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_INCOMING_IRS_RECON_REJECTS$SP_LOAD_RECON_REJECTS
Programmer Name 	: IMP Team
Description			: This process loads all the reconciliation details into the temporary table from the 
					  incoming IRS Reconciliation Reject file.
Frequency			: 'ANNUALLY'
Developed On		: 09/14/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_IRS_RECON_REJECTS$SP_LOAD_RECON_REJECTS]
AS
 BEGIN
 SET NOCOUNT ON;
 
  DECLARE  @Lc_StatusFailed_CODE			CHAR (1) = 'F',
           @Lc_Yes_TEXT						CHAR (1) = 'Y',
           @Lc_StatusSuccess_CODE			CHAR (1) = 'S',
           @Lc_StatusAbnormalend_CODE		CHAR (1) = 'A',
           @Lc_TypeErrorWarning_CODE		CHAR (1) = 'W',
           @Lc_Space_TEXT					CHAR (1) = ' ',
           @Lc_ProcessN_INDC				CHAR (1) = 'N',
           @Lc_FileTrailerRecTypeCtl_CODE   CHAR (3) = 'CTL', 
           @Lc_BatchRunUser_TEXT			CHAR (5) = 'BATCH',
           @Lc_Job_ID						CHAR (7) = 'DEB9050',
           @Lc_ErrorE0944_CODE				CHAR (18) = 'E0944',
           @Lc_Successful_TEXT				CHAR (20) = 'SUCCESSFUL',
           @Ls_Procedure_NAME				VARCHAR (100) = 'SP_LOAD_RECON_REJECTS',
           @Ls_Process_NAME					VARCHAR (100) = 'BATCH_ENF_INCOMING_IRS_RECON_REJECTS';
  DECLARE  @Ln_ExceptionThresholdParm_QNTY		NUMERIC (5),
           @Ln_CommitFreqParm_QNTY				NUMERIC (5),
           @Ln_TanfCount_QNTY					NUMERIC (9) = 0,
           @Ln_NtanfCount_QNTY					NUMERIC (9) = 0,
           @Ln_TanfTrCount_QNTY					NUMERIC (9) = 0,
           @Ln_NTanfTrCount_QNTY				NUMERIC (9) = 0,
           @Ln_ProcessedRecordCount_QNTY		NUMERIC (9) = 0,
           @Ln_TotalTanfAcceptedCount_QNTY		NUMERIC (9) = 0,
           @Ln_TotalTanfRejectedCount_QNTY		NUMERIC (9) = 0,
           @Ln_TotalNonTanfAcceptedCount_QNTY	NUMERIC (9) = 0,
           @Ln_TotalNonTanfRejectedCount_QNTY	NUMERIC (9) = 0,
           @Ln_TotalTanfWarningCount_QNTY		NUMERIC (9) = 0,
           @Ln_TotalNonTanfWarningCount_QNTY	NUMERIC (9) = 0,
           @Ln_Error_NUMB						NUMERIC (11),
           @Ln_ErrorLine_NUMB					NUMERIC (11),
           @Lc_Msg_CODE							CHAR (1),
           @Ls_File_NAME						VARCHAR (50),
           @Ls_FileLocation_TEXT				VARCHAR (80),
           @Ls_Sql_TEXT							VARCHAR (100),
           @Ls_FileSource_TEXT					VARCHAR (130),
           @Ls_SqlStmnt_TEXT					VARCHAR (200),
           @Ls_Sqldata_TEXT						VARCHAR (1000),
           @Ls_DescriptionError_TEXT			VARCHAR (4000),
           @Ls_ErrorMessage_TEXT				VARCHAR (4000),
           @Ld_Run_DATE							DATE,
           @Ld_LastRun_DATE						DATE,
           @Ld_Start_DATE						DATETIME2;

  -- Creating Temperory Table
  SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
  SET @Ls_Sqldata_TEXT = '';  
  CREATE TABLE ##LoadIrsReconReject_P1
   (
     Record_TEXT VARCHAR (245)
   );

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
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Validation 1:Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST (@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END

   -- Assign the Source File Location
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'FileSource_TEXT = ' + @Ls_FileSource_TEXT;
   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_ErrorMessage_TEXT ='FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';
     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'BULK INSERT ##LoadIrsReconReject_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT ##LoadIrsReconReject_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';
   EXEC (@Ls_SqlStmnt_TEXT);

   BEGIN TRANSACTION IrsReconLoad;
   
    -- Delete the records from the temporary table LIRRE_Y1	
   SET @Ls_Sql_TEXT = 'DELETE THE RECORDS FROM LIRRE_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + @Lc_Yes_TEXT;
   DELETE FROM LIRRE_Y1 
	WHERE Process_INDC = @Lc_Yes_TEXT;
   
   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
											 FROM ##LoadIrsReconReject_P1);
						
   IF @Ln_ProcessedRecordCount_QNTY <> 0
   BEGIN  	
      SET @Ls_Sql_TEXT = 'FILE CONTROL RECORD EXIST CHECK';
	  SET @Ls_Sqldata_TEXT = 'FileTrailerRecType_CODE = ' + @Lc_FileTrailerRecTypeCtl_CODE;
      IF EXISTS(SELECT 1
      FROM ##LoadIrsReconReject_P1 a
      WHERE SUBSTRING(Record_TEXT, 3, 3) = @Lc_FileTrailerRecTypeCtl_CODE)
      BEGIN
		-- Total number of TANF records accepted
        SELECT @Ln_TotalTanfAcceptedCount_QNTY = CAST((SUBSTRING (Record_TEXT, 6, 9)) AS NUMERIC),
        -- Total number of TANF records rejected
        @Ln_TotalTanfRejectedCount_QNTY = CAST((SUBSTRING (Record_TEXT, 15, 9)) AS NUMERIC),
        -- Total NON TANF Records Accepted
        @Ln_TotalNonTanfAcceptedCount_QNTY = CAST((SUBSTRING (Record_TEXT, 24, 9)) AS NUMERIC),
        -- Total NON TANF Records Rejected
        @Ln_TotalNonTanfRejectedCount_QNTY = CAST((SUBSTRING (Record_TEXT, 33, 9)) AS NUMERIC),
        -- Total number of TANF records that received warning from OCSE
        @Ln_TotalTanfWarningCount_QNTY = CAST((SUBSTRING (Record_TEXT, 42, 9)) AS NUMERIC),
        -- Total number of NON-TANF records that received warning from OCSE
        @Ln_TotalNonTanfWarningCount_QNTY = CAST((SUBSTRING (Record_TEXT, 51, 9)) AS NUMERIC)
        FROM ##LoadIrsReconReject_P1 a
        WHERE SUBSTRING(Record_TEXT, 3, 3) = @Lc_FileTrailerRecTypeCtl_CODE;
        -- Calculating total reject and warning record count 
        SET @Ln_TanfTrCount_QNTY = @Ln_TotalTanfRejectedCount_QNTY + @Ln_TotalTanfWarningCount_QNTY;
        SET @Ln_NTanfTrCount_QNTY = @Ln_TotalNonTanfRejectedCount_QNTY + @Ln_TotalNonTanfWarningCount_QNTY;
        SET @Ln_TanfCount_QNTY = (SELECT COUNT(1)
											 FROM ##LoadIrsReconReject_P1 
											 WHERE SUBSTRING (Record_TEXT, 74, 1) = 'A');
	    SET @Ln_NtanfCount_QNTY = (SELECT COUNT(1)
											 FROM ##LoadIrsReconReject_P1 
											 WHERE SUBSTRING (Record_TEXT, 74, 1) = 'N');											 
        SET @Ls_Sql_TEXT = 'CHECK RECORD COUNTS';
        SET @Ls_Sqldata_TEXT = 'TanfCount_QNTY = ' + CAST(@Ln_TanfCount_QNTY AS VARCHAR) + ', NtanfCount_QNTY = ' + CAST(@Ln_NtanfCount_QNTY AS VARCHAR) + ', TanfTrCount_QNTY = ' + CAST(@Ln_TanfTrCount_QNTY AS VARCHAR) + ', NTanfTrCount_QNTY = ' + CAST(@Ln_NTanfTrCount_QNTY AS VARCHAR);
		IF @Ln_TanfCount_QNTY + @Ln_NtanfCount_QNTY <> @Ln_TanfTrCount_QNTY + @Ln_NTanfTrCount_QNTY
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'TOTAL RECORD COUNT ' + CAST((@Ln_TanfTrCount_QNTY + @Ln_NTanfTrCount_QNTY) AS VARCHAR) + ' IN CONTROL RECORD DO NOT MATCH WITH DETAIL COUNT ' + CAST((@Ln_TanfCount_QNTY + @Ln_NtanfCount_QNTY) AS VARCHAR);

          RAISERROR (50001,16,1);
         END
      END
      ELSE
      BEGIN
      	SET @Ls_ErrorMessage_TEXT = 'CONTROL RECORD NOT FOUND';
		
		RAISERROR (50001,16,1);
      END
      
	   -- Read the file and load the reconciliation reject details into the temporary table.
	   SET @Ls_Sql_TEXT = 'INSERT LIRRE_Y1 ';
	   SET @Ls_Sqldata_TEXT = '';
	   INSERT INTO LIRRE_Y1
				   (StateSubmit_CODE,
					County_IDNO,
					MemberSsn_NUMB,
					Case_IDNO,
					Last_NAME,
					First_NAME,
					Arrears_AMNT,
					TransType_CODE,
					CaseType_CODE,
					StateTransfer_CODE,
					LocalTransfer_CODE,
					ProcessYear_NUMB,
					Line1_ADDR,
					Line2_ADDR,
					City_ADDR,
					State_ADDR,
					Zip_ADDR,
					Issued_DATE,
					Exclusion_CODE,
					Error_CODE,
					FileLoad_DATE,
					Process_INDC)
	   SELECT (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS StateSubmit_CODE,	-- STATE ABBR.       
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 3, 3), @Lc_Space_TEXT))) AS County_IDNO,			-- LOCAL CODE.      
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 6, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,		-- SSN.             
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 15, 15), @Lc_Space_TEXT))) AS Case_IDNO,			-- CASE NO.         
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 30, 20), @Lc_Space_TEXT))) AS Last_NAME,			-- LAST NAME.       
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 50, 15), @Lc_Space_TEXT))) AS First_NAME,		-- FIRST NAME.      
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 65, 8), @Lc_Space_TEXT))) AS Arrears_AMNT,		-- ARREARS.         
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 73, 1), @Lc_Space_TEXT))) AS TransType_CODE,		-- TRAN TYPE.       
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 74, 1), @Lc_Space_TEXT))) AS CaseType_CODE,		-- CASE_TYPE_IND.   
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 75, 2), @Lc_Space_TEXT))) AS StateTransfer_CODE,	-- TRAN STATE.      
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 77, 3), @Lc_Space_TEXT))) AS LocalTransfer_CODE,	-- TRANS STATE LOC. 
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 80, 4), @Lc_Space_TEXT))) AS ProcessYear_NUMB,	-- PROCESS YEAR.    
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 84, 30), @Lc_Space_TEXT))) AS Line1_ADDR,		-- ADDRESS LINE 1.  
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 114, 30), @Lc_Space_TEXT))) AS Line2_ADDR,		-- ADDRESS LINE 2. 
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 144, 25), @Lc_Space_TEXT))) AS City_ADDR,		-- CITY.           
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 169, 2), @Lc_Space_TEXT))) AS State_ADDR,		-- STATE           
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 171, 9), @Lc_Space_TEXT))) AS Zip_ADDR,			-- ZIP             
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 180, 8), @Lc_Space_TEXT))) AS Issued_DATE,		-- DATE ISSUED     
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 188, 40), @Lc_Space_TEXT))) AS Exclusion_CODE,	-- OFFSET EXCL TYPE
			  (RTRIM(ISNULL(SUBSTRING(l.Record_TEXT, 228, 12), @Lc_Space_TEXT))) AS Error_CODE,		-- ERROR CODE,
			  @Ld_Run_DATE AS FileLoad_DATE,-- FileLoad_DATE				
			  @Lc_ProcessN_INDC AS Process_INDC -- Process_INDC.     
		 FROM ##LoadIrsReconReject_P1 l
		 WHERE SUBSTRING(Record_TEXT, 3, 3) <> @Lc_FileTrailerRecTypeCtl_CODE;
	END
	ELSE
	BEGIN 
	    /*
	      If the incoming file is empty then write error message into BATE_Y1 table, 
	      'E0944 – No Record(s) to Process'.
	    */
		SET @Ls_Sql_TEXT = 'No Record(s) to process';
        SET @Ls_Sqldata_TEXT =  'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = '+ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorWarning_CODE + ', Line_NUMB = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorE0944_CODE + ', DescriptionError_TEXT = ' + @Ls_Sql_TEXT + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT;
        EXECUTE BATCH_COMMON$SP_BATE_LOG @As_Process_NAME             = @Ls_Process_NAME,
                                           @As_Procedure_NAME           = @Ls_Procedure_NAME,
                                           @Ac_Job_ID                   = @Lc_Job_ID,
                                           @Ad_Run_DATE                 = @Ld_Run_DATE,
                                           @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
                                           @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
                                           @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
                                           @As_DescriptionError_TEXT	= @Ls_Sql_TEXT,
                                           @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
                                           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
                                           @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE=@Lc_StatusFailed_CODE
            BEGIN
              RAISERROR (50001,16,1);
            END
	END
   -- Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
    
   /*
	Log the Error encountered or successful completion in the Batch Status Log (BSTL) screen / status 
	log table for future references.
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

   COMMIT TRANSACTION IrsReconLoad;

   --Drop Temperory Table
   SET @Ls_Sql_TEXT = 'DROP TABLE ##LoadIrsReconReject_P1';
   SET @Ls_Sqldata_TEXT = '';
   DROP TABLE ##LoadIrsReconReject_P1;
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IrsReconLoad;
    END

   -- Check if global temporary table exists drop the table
	IF OBJECT_ID('tempdb..##LoadIrsReconReject_P1') IS NOT NULL
	BEGIN
		DROP TABLE ##LoadIrsReconReject_P1;
	END   
   -- Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_sql_TEXT,
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
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
