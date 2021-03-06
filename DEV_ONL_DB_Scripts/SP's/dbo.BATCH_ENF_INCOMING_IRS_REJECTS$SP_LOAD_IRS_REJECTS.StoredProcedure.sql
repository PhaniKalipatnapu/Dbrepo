/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_IRS_REJECTS$SP_LOAD_IRS_REJECTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_INCOMING_IRS_REJECTS$SP_LOAD_IRS_REJECTS

Programmer Name 	: IMP Team

Description			: This process reads the case submission reject file records from the
					  Federal Offset Process and loads it into a temporary table.

Frequency			: 'WEEKLY'

Developed On		: 09/14/2011

Called BY			: None

Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_IRS_REJECTS$SP_LOAD_IRS_REJECTS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE				 CHAR (1) = 'F',
          @Lc_Yes_INDC						 CHAR (1) = 'Y',
          @Lc_StatusSuccess_CODE			 CHAR (1) = 'S',
          @Lc_StatusAbnormalend_CODE		 CHAR (1) = 'A',
          @Lc_Space_TEXT					 CHAR (1) = ' ',
          @Lc_ProcessN_INDC					 CHAR (1) = 'N',
          @Lc_TrilerRec_INDC				 CHAR (1) = 'N',
          @Lc_BateErrorE1424_CODE			 CHAR (5) = 'E1424',
          @Lc_BateErrorE0944_CODE			 CHAR (5) = 'E0944',
          @Lc_Job_ID						 CHAR (7) = 'DEB5170',
          @Lc_Successful_TEXT				 CHAR (20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT				 CHAR (30) = 'BATCH',
          @Ls_Process_NAME					 VARCHAR (100) = 'BATCH_ENF_INCOMING_IRS_REJECTS',
          @Ls_Procedure_NAME				 VARCHAR (100) = 'SP_LOAD_IRS_REJECTS';
  DECLARE @Ln_ExceptionThresholdParm_QNTY    NUMERIC (5) = 0,
          @Ln_CommitFreqParm_QNTY            NUMERIC (5) = 0,
          --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --Start
          @Ln_ProcessedRecordCount_QNTY		 NUMERIC (6) = 0,
          --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --End
          @Ln_TanfCount_QNTY                 NUMERIC (9) = 0,
          @Ln_NtanfCount_QNTY                NUMERIC (9) = 0,
          @Ln_TanfTrCount_QNTY               NUMERIC (9) = 0,
          @Ln_NTanfTrCount_QNTY              NUMERIC (9) = 0,
          @Ln_TotalTanfAcceptedCount_QNTY    NUMERIC (9) = 0,
          @Ln_TotalTanfRejectedCount_QNTY    NUMERIC (9) = 0,
          @Ln_TotalNonTanfAcceptedCount_QNTY NUMERIC (9) = 0,
          @Ln_TotalNonTanfRejectedCount_QNTY NUMERIC (9) = 0,
          @Ln_TotalTanfWarningCount_QNTY     NUMERIC (9) = 0,
          @Ln_TotalNonTanfWarningCount_QNTY  NUMERIC (9) = 0,
          @Ln_Error_NUMB                     NUMERIC (11),
          @Ln_ErrorLine_NUMB                 NUMERIC (11),
          @Ln_Cursor_QNTY                    NUMERIC (11) = 0,
          @Ln_RowCount_NUMB                  NUMERIC (11),
          --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --Start
          @Ln_TotalRecordCount_QNTY			 NUMERIC(11),
          --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --End
          @Li_FetchStatus_NUMB               SMALLINT,
          @Lc_TypeError_CODE                 CHAR (1),
          @Lc_Msg_CODE                       CHAR (3),
          @Lc_BateError_CODE                 CHAR (5),
          @Lc_Tmp_Error_CODE                 CHAR (12),
          @Ls_File_NAME                      VARCHAR (50),
          @Ls_FileLocation_TEXT              VARCHAR (80),
          @Ls_Sql_TEXT                       VARCHAR (100),
          @Ls_FileSource_TEXT                VARCHAR (130),
          @Ls_SqlStmnt_TEXT                  VARCHAR (200),
          @Ls_Sqldata_TEXT                   VARCHAR (1000),
          @Ls_DescriptionError_TEXT          VARCHAR (4000),
          @Ls_ErrorMessage_TEXT              VARCHAR (4000) = '',
          @Ls_BateRecord_TEXT                VARCHAR (4000),
          @Ld_Run_DATE                       DATE,
          @Ld_LastRun_DATE                   DATE,
          @Ld_Start_DATE                     DATETIME2;
  BEGIN TRY
   --Creating Temporary Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = '';

   CREATE TABLE ##LoadIrsReject_P1
    (
      Record_TEXT VARCHAR (245)
    );
   
   BEGIN TRANSACTION IrsReconLoad;
   	
   SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   /*
   	Get the run date and last run date from PARM_Y1 table and validate that the batch program was not 
   	executed for the run date, by ensuring that the run date is different from the last run date in 
   	the PARM_Y1 table.  Otherwise, an error message to that effect will be written into 
   	Batch Status Log (BSTL) screen / Batch Status Log (BSTL_Y1) table and terminate the process.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

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
   --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --Start
   --Delete the records from temporary table LIREJ_Y1	
   SET @Ls_Sql_TEXT = 'DELETE THE RECORDS FROM LIREJ_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + @Lc_Yes_INDC;

   DELETE LIREJ_Y1
    WHERE Process_INDC = @Lc_Yes_INDC;
   --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --End 	
   --Assign the Source File Location
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = '';
   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_ErrorMessage_TEXT ='FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';
     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'BULK INSERT ##LoadIrsReject_P1  FROM = ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT ##LoadIrsReject_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);
   
   --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --Start
   SET @Ls_Sql_TEXT = 'SELECT TOTAL RECORD COUNT';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_TotalRecordCount_QNTY = COUNT(1)
     FROM ##LoadIrsReject_P1 a;
   
   IF @Ln_TotalRecordCount_QNTY > 0
   BEGIN
	   SET @Ls_Sql_TEXT = 'SELECT TRAILER RECORD TANF AND NTANF COUNT';
	   SELECT @Lc_TrilerRec_INDC = 'Y',
			 -- Total number of TANF records accepted
			 @Ln_TotalTanfAcceptedCount_QNTY = CAST((SUBSTRING (Record_TEXT, 6, 9)) AS NUMERIC),
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
		  FROM ##LoadIrsReject_P1 WHERE Record_TEXT LIKE 'DECTL%'
		
	   SET @Ls_Sql_TEXT = 'CHECK TRAILER EXISTS';
	   SET @Ls_Sqldata_TEXT = 'TrilerRec_INDC = ' + @Lc_TrilerRec_INDC;	
	   IF @Lc_TrilerRec_INDC = 'N'
		 BEGIN
		   SET @Ls_ErrorMessage_TEXT = 'TRAILER RECORD NOT FOUND';
		   RAISERROR (50001,16,1);
		 END
		
		SET @Ls_Sqldata_TEXT = 'SELECT TANF TOTAL RECORDS COUNT';
		
		SELECT @Ln_TanfCount_QNTY = COUNT(1)
		  FROM ##LoadIrsReject_P1 WHERE Record_TEXT NOT LIKE 'DECTL%'
		  AND SUBSTRING (Record_TEXT, 74, 1) = 'A';
	      
		SET @Ls_Sqldata_TEXT = 'SELECT NTANF TOTAL RECORDS COUNT';
		
		SELECT @Ln_NtanfCount_QNTY = COUNT(1)
		  FROM ##LoadIrsReject_P1 WHERE Record_TEXT NOT LIKE 'DECTL%'
		  AND SUBSTRING (Record_TEXT, 74, 1) = 'N';
		
		-- Calculating total reject and warning record count 
		SET @Ln_TanfTrCount_QNTY = @Ln_TotalTanfRejectedCount_QNTY + @Ln_TotalTanfWarningCount_QNTY;
		SET @Ln_NTanfTrCount_QNTY = @Ln_TotalNonTanfRejectedCount_QNTY + @Ln_TotalNonTanfWarningCount_QNTY;
		
		SET @Ls_Sql_TEXT = 'CHECK RECORD COUNTS';
		SET @Ls_Sqldata_TEXT = 'TanfCount_QNTY = ' + CAST(@Ln_TanfCount_QNTY AS VARCHAR) + ', NtanfCount_QNTY = ' + CAST(@Ln_NtanfCount_QNTY AS VARCHAR) + ', TanfTrCount_QNTY = ' + CAST(@Ln_TanfTrCount_QNTY AS VARCHAR) + ', NTanfTrCount_QNTY = ' + CAST(@Ln_NTanfTrCount_QNTY AS VARCHAR);
		
		IF @Ln_TanfCount_QNTY + @Ln_NtanfCount_QNTY <> @Ln_TanfTrCount_QNTY + @Ln_NTanfTrCount_QNTY
		 BEGIN
		  SET @Ls_ErrorMessage_TEXT = 'TOTAL RECORD COUNT IN TRAILER DO NOT MATCH WITH DETAIL COUNT';

		  RAISERROR (50001,16,1);
		 END	
    END
     --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --End
     
    SET @Ls_Sql_TEXT = 'INSERT INTO LOAD_IRS_REJECTS LIREJ_Y1';
    SET @Ls_Sqldata_TEXT = '';

    INSERT INTO LIREJ_Y1
                (State_CODE,
                 Local_CODE,
                 MemberSsn_NUMB,
                 Case_IDNO,
                 Last_NAME,
                 First_NAME,
                 Arrears_AMNT,
                 TransType_CODE,
                 TypeCase_CODE,
                 TransState_ADDR,
                 TransStateLoc_ADDR,
                 ProcessYear_NUMB,
                 Line1_ADDR,
                 Line2_ADDR,
                 City_ADDR,
                 State_ADDR,
                 Zip_ADDR,
                 Issued_DATE,
                 TypeOffsetExcl_CODE,
                 Error_CODE,
                 LastNcp_NAME,
                 Request_CODE,
                 FileLoad_DATE,
                 Process_INDC)
    SELECT (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS State_CODE,-- STATE ABBR.       
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 3, 3), @Lc_Space_TEXT))) AS Local_CODE,-- LOCAL CODE.      
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 6, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- SSN.             
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 15, 15), @Lc_Space_TEXT))) AS Case_IDNO,-- CASE NO.         
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 30, 20), @Lc_Space_TEXT))) AS Last_NAME,-- LAST NAME.       
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 50, 15), @Lc_Space_TEXT))) AS First_NAME,-- FIRST NAME.      
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 65, 8), @Lc_Space_TEXT))) AS Arrears_AMNT,-- ARREARS.         
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 73, 1), @Lc_Space_TEXT))) AS TransType_CODE,-- TRAN TYPE.       
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 74, 1), @Lc_Space_TEXT))) AS TypeCase_CODE,-- CASE_TYPE_IND.   
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 75, 2), @Lc_Space_TEXT))) AS TransState_ADDR,-- TRAN STATE.      
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 77, 3), @Lc_Space_TEXT))) AS TransStateLoc_ADDR,-- TRANS STATE LOC. 
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 80, 4), @Lc_Space_TEXT))) AS ProcessYear_NUMB,-- PROCESS YEAR.    
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 84, 30), @Lc_Space_TEXT))) AS Line1_ADDR,-- ADDRESS LINE 1.  
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 114, 30), @Lc_Space_TEXT))) AS Line2_ADDR,-- ADDRESS LINE 2. 
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 144, 25), @Lc_Space_TEXT))) AS City_ADDR,-- CITY.           
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 169, 2), @Lc_Space_TEXT))) AS State_ADDR,-- STATE           
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 171, 9), @Lc_Space_TEXT))) AS Zip_ADDR,-- ZIP             
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 180, 8), @Lc_Space_TEXT))) AS Issued_DATE,-- DATE ISSUED     
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 188, 40), @Lc_Space_TEXT))) AS TypeOffsetExcl_CODE,-- OFFSET EXCL TYPE
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 228, 12), @Lc_Space_TEXT))) AS Error_CODE,-- ERROR CODE,
           --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --Start
           --When a case is rejected with an error code of '17', this field contains the first four characters of the 
    	   --NCP last name that is stored on the OCSE Case Master file for this case. 
    	   --The OCSE last name can be used to correct the NCP last name at the state.
           CASE WHEN CHARINDEX('17', LTRIM(RTRIM(SUBSTRING(Record_TEXT, 228, 12)))) > 0
           THEN SUBSTRING((RTRIM(ISNULL(SUBSTRING(Record_TEXT, 30, 20), @Lc_Space_TEXT))),1,4)
           ELSE '' 
           END AS LastNcp_NAME,-- OCSE LAST NAME,
           (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 245, 1), @Lc_Space_TEXT))) AS Request_CODE,-- REQUEST CODE,
           @Ld_Run_DATE AS FileLoad_DATE,-- FileLoad_DATE				
           @Lc_ProcessN_INDC AS Process_INDC
           FROM ##LoadIrsReject_P1 WHERE Record_TEXT NOT LIKE 'DECTL%'; -- Process_INDC. 
           
           SET @Ln_RowCount_NUMB = @@ROWCOUNT;
        
		/*
			Read the IRS Rejects file and insert the data into a temporary table. If file is empty then write message 
			in BATE_Y1 table 'E0944 - No Record(s) to Process'
		 */
        IF @Ln_RowCount_NUMB = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;

			 EXECUTE BATCH_COMMON$SP_BATE_LOG
			  @As_Process_NAME             = @Ls_Process_NAME,
			  @As_Procedure_NAME           = @Ls_Procedure_NAME,
			  @Ac_Job_ID                   = @Lc_Job_ID,
			  @Ad_Run_DATE                 = @Ld_Run_DATE,
			  @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
			  @An_Line_NUMB                = @Ln_Cursor_QNTY,
			  @Ac_Error_CODE               = @Lc_BateError_CODE,
			  @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
			  @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
			  @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			  @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

			 IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			  BEGIN
			   RAISERROR (50001,16,1);
			  END
         END;
    
   SET @Ls_Sql_TEXT = 'SELECT LIREJ_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM LIREJ_Y1 a;
   --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --End
         
   --Update the last date in the Parameter (PARM_Y1) database table with the run date, upon successful completion
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR);

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
    --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --Start
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
	--BUG13763:Modified the code to throw the error when trailer and detail record count not matched --End
   COMMIT TRANSACTION IrsReconLoad;

   --Drop Temporary Table
   DROP TABLE ##LoadIrsReject_P1;
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IrsReconLoad;
    END
   
   --Check if global temporary table exists drop the table
   IF OBJECT_ID('tempdb..##LoadIrsReject_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##LoadIrsReject_P1;
    END

   -- Check for Exception information to log the description text based on the error	
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --Start
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
    --BUG13763:Modified the code to throw the error when trailer and detail record count not matched --End

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
