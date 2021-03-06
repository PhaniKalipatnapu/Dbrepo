/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_PROCESS_EMPLOYER_MERGE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Program Name      : BATCH_CM_MERG$SP_PROCESS_EMPLOYER_MERGE
Programmer Name   : IMP Team.
Description       : The CM Merge batch will read “Pending Requests to Merge Employers”.  The process will ensure that criteria for 
    				the requested merge are in accordance with the system’s rules for merging.
Frequency         : DAILY
Developed On      : 04/06/2011
Called BY         : None
Called On         : BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT, BATCH_CM_MERG$SP_EMPLOYER_MERGE, 
				    BATCH_COMMON$SP_BATE_LOG and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
----------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_PROCESS_EMPLOYER_MERGE]
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE @Lc_StatusFailed_CODE			CHAR(1)			= 'F',
           @Lc_StatusSuccess_CODE			CHAR(1)			= 'S',
           @Lc_TypeErrorE_CODE				CHAR(1)			= 'E',
           @Ls_Yes_TEXT						CHAR(1)			= 'Y',
           @Ls_No_INDC						CHAR(1)			= 'N',
           @Lc_StatusAbnormalend_CODE		CHAR(1)			= 'A',
           @Lc_ErrrorTypeW_CODE				CHAR(1)			= 'W',
           @Lc_ErrorTypeError_CODE			CHAR(1)			= 'E',
           @Lc_Pending_CODE					CHAR(1)			= 'P',
           @Lc_Merged_CODE					CHAR(1)			= 'M',
           @Lc_Space_TEXT					CHAR(1)			= ' ',
           @Lc_Error_CODE					CHAR(5)			= 'E1424',
           @Lc_BatchRunUser_TEXT			CHAR(5)			= 'BATCH',
           @Lc_Successful_TEXT				CHAR(20)		= 'SUCCESSFUL',           
           @Ls_StateInState_CODE			CHAR(2)			= 'DE',
           @Lc_ErrorE0944_CODE				CHAR(5)			= 'E0944',
           @Lc_Job_ID						CHAR(7)			= 'DEB1040',
           @Ls_Successful_INDC				VARCHAR(20)		= 'SUCCESSFUL',
           @Ls_Procedure_NAME				VARCHAR(100)	= 'SP_PROCESS_EMPLOYER_MERGE',
           @Ls_Process_NAME					VARCHAR(100)	= 'BATCH_CM_MERG',
           @Ls_Routine_TEXT					VARCHAR(100)	= 'SP_PROCESS_EMPLOYER_MERGE',
           @Ld_Start_DATE					DATETIME2		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
           @Ld_High_DATE					DATE			= '12/31/9999';
  
  DECLARE  @Ls_FetchStatus_BIT				SMALLINT,
           @Ln_CommitFreq_NUMB				NUMERIC(5),
           @Ln_ExceptionThreshold_NUMB		NUMERIC(5),
           @Ln_RowCount_NUMB				NUMERIC(7),
           @Ln_Cursor_QNTY					NUMERIC(10)		= 0,
           @Ln_Commit_QNTY					NUMERIC(10)		= 0,
           @Ln_ExceptionThreshold_QNTY      NUMERIC(10)		= 0,
           @Ln_Cursor_Cnt					NUMERIC(10)		= 0,
           @Ln_Error_NUMB					NUMERIC(10),
           @Ln_ErrorLine_NUMB				NUMERIC(10),
           @Ln_TransEventSeq_NUMB			NUMERIC(19),
           @Ln_OthpEmplPrimary_IDNO			NUMERIC(19),
           @Ln_OthpEmplSecondary_IDNO		NUMERIC(19),
           @Ln_TransactionEventSeq_NUMB		NUMERIC(19),
           @Lc_Null_TEXT					CHAR(1)			= '',
           @Lc_Msg_CODE						CHAR(1),
           @Lc_IwnGenerate_INDC				CHAR(1),
           @Ls_Sql_TEXT						VARCHAR(200)	= '',
           @Ls_Sqldata_TEXT					VARCHAR(1000)	= '',
           @Ls_DescriptionError_TEXT		VARCHAR(MAX),
           @Ld_Run_DATE						DATETIME2,
           @Ld_LastRun_DATE					DATETIME2;


  BEGIN TRANSACTION Main_Transaction;

  BEGIN TRY
   SET @Ls_Sql_TEXT ='GET BATCH DETAILS';
   SET @Ls_Sqldata_TEXT='GET BATCH DETAILS' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_NUMB OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   IF DATEADD (d, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_Sql_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END;

   -- Case Cursor Declaration  
   -- To get the Case updates in the System for IVE cases.
   DECLARE empmrgcur CURSOR LOCAL FORWARD_ONLY FOR
    SELECT othpemplprimary_idno,
           othpemplsecondary_idno,
           iwngenerate_indc,
           transactioneventseq_numb
      FROM EMRG_Y1
     WHERE statusmerge_code = @Lc_Pending_CODE
       AND endvalidity_date = @Ld_High_DATE
     ORDER BY othpemplprimary_idno;

   -- Case Cursor
   OPEN empmrgcur

   SET @Ls_Sql_TEXT = 'FETCH EmpMrgCur - 1';

   FETCH NEXT FROM empmrgcur INTO @Ln_OthpEmplPrimary_IDNO, @Ln_OthpEmplSecondary_IDNO, @Lc_IwnGenerate_INDC, @Ln_TransactionEventSeq_NUMB;

   SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS

   BEGIN
    WHILE @Ls_FetchStatus_BIT = 0
     BEGIN
		BEGIN TRY
			SAVE  TRANSACTION Cursor_Transaction;
			  SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
			  SET @Ln_Commit_QNTY = @Ln_Commit_QNTY + 1;
			  SET @Ln_Cursor_Cnt = @Ln_Cursor_Cnt + 1;
			  SET @Ls_Sql_TEXT = ' GENERATE TransactionEventSeq_NUMB ';

			  EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
			   @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
			   @Ac_Process_ID               = @Lc_Job_ID,
			   @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
			   @Ac_Note_INDC                = @Ls_No_INDC,
			   @An_EventFunctionalSeq_NUMB  = 0,
			   @An_TransactionEventSeq_NUMB = @Ln_TransEventSeq_NUMB OUTPUT,
			   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			   @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

			  IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
			   BEGIN
				RAISERROR(50001,16,1);
			   END;

			  IF NOT EXISTS (SELECT COUNT(1)
							   FROM OTHP_Y1
							  WHERE otherparty_idno = @Ln_OthpEmplPrimary_IDNO
								AND endvalidity_date = @Ld_High_DATE)
				   BEGIN
						SET @Ls_Sql_TEXT = 'EMPLOYER MERGE - CHECK ID_OTHP PRIMARY';
						SET @Ls_DescriptionError_TEXT = 'Employer Merge - ID_OTHP PRIMARY ' + CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(9)) + ' ENDDATED';
			
						RAISERROR(50001,16,1);
				   END

				SET @Ls_Sql_TEXT = 'EMPLOYER MERGE - CHECK ID_OTHP SECONDARY';

			  IF NOT EXISTS (SELECT COUNT(1)
							   FROM OTHP_Y1
							  WHERE otherparty_idno = @Ln_OthpEmplSecondary_IDNO
								AND endvalidity_date = @Ld_High_DATE)
				   BEGIN
						SET @Ls_DescriptionError_TEXT = 'Employer Merge - ID_OTHP SECONDARY ' + @Ln_OthpEmplSecondary_IDNO + ' ENDDATED';
						RAISERROR(50001,16,1);
				   END

			SET @Ls_Sql_TEXT = 'CALLING BATCH_CM_MERG$SP_EMPLOYER_MERGE ';
	      
		    SET @Ls_Sqldata_TEXT=' OthpEmplSecondary_IDNO = ' + ISNULL(CAST(@Ln_OthpEmplSecondary_IDNO AS VARCHAR(19)), '')
							   + ', OthpEmplPrimary_IDNO = ' + ISNULL(CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(19)), '')
							   + ', TransEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransEventSeq_NUMB AS VARCHAR(19)), '')
							   + ', IwnGenerate_INDC = ' + ISNULL(@Lc_IwnGenerate_INDC, '')
							   + ',  Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '')
							   + ',  Cursor_Cnt = ' + ISNULL(CAST(@Ln_Cursor_Cnt AS VARCHAR(10)), '');

			EXEC BATCH_CM_MERG$SP_EMPLOYER_MERGE
						   @As_OthpEmplSecondary_IDNO   = @Ln_OthpEmplSecondary_IDNO,
						   @As_OthpEmplPrimary_IDNO     = @Ln_OthpEmplPrimary_IDNO,
						   @An_TransactionEventSeq_NUMB = @Ln_TransEventSeq_NUMB,
						   @Ac_IwnGenerate_INDC         = @Lc_IwnGenerate_INDC,
						   @Ad_Run_DATE                 = @Ld_Run_DATE,
						   @An_Cursor_Cnt               = @Ln_Cursor_Cnt,
						   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
						   @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

		  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
					SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_EMPLOYER_MERGE FAILED';
					RAISERROR(50001,16,1);
			   END
			ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
				BEGIN
					SET @Ls_Sql_TEXT = 'UPDATE EMRG_Y1';

						UPDATE EMRG_Y1
						   SET endvalidity_date = @Ld_Run_DATE
						 WHERE othpemplprimary_idno = @Ln_OthpEmplPrimary_IDNO
						   AND othpemplsecondary_idno = @Ln_OthpEmplSecondary_IDNO
						   AND statusmerge_code = @Lc_Pending_CODE
						   AND transactioneventseq_numb = @Ln_TransactionEventSeq_NUMB
						   AND endvalidity_date = @Ld_High_DATE;

						IF @@ROWCOUNT = 0
						 BEGIN
						  SET @Ls_DescriptionError_TEXT = 'EMRG_Y1 UPDATE FAILED';

						  RAISERROR (50001,16,1);
						 END;

					SET @Ls_Sql_TEXT = 'INSERT EMRG_Y1';

				INSERT INTO EMRG_Y1
							(othpemplprimary_idno,
							 othpemplsecondary_idno,
							 statusmerge_code,
							 beginvalidity_date,
							 endvalidity_date,
							 workerupdate_id,
							 update_dttm,
							 transactioneventseq_numb,
							 iwngenerate_indc)
				SELECT othpemplprimary_idno,
					   othpemplsecondary_idno,
					   @Lc_Merged_CODE,
					   @Ld_Run_DATE,
					   @Ld_High_DATE,
					   @Lc_BatchRunUser_TEXT,
					   @Ld_Run_DATE,
					   @Ln_TransEventSeq_NUMB,
					   iwngenerate_indc
				  FROM EMRG_Y1
				 WHERE othpemplprimary_idno = @Ln_OthpEmplPrimary_IDNO
				   AND othpemplsecondary_idno = @Ln_OthpEmplSecondary_IDNO
				   AND transactioneventseq_numb = @Ln_TransactionEventSeq_NUMB;

				IF @@ROWCOUNT = 0
				 BEGIN
				  SET @Ls_Sql_TEXT = 'EMRG_Y1 INSERT FAILED';

				  RAISERROR (50001,16,1);
				 END;
			END
		END TRY
		BEGIN CATCH
				IF XACT_STATE()	= 1
					BEGIN
					   ROLLBACK TRANSACTION Cursor_Transaction;
					END
				ELSE
					BEGIN
						SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
						RAISERROR( 50001 ,16,1);
					END
				SAVE TRANSACTION Cursor_Transaction;
				   SET @Ln_Error_NUMB = ERROR_NUMBER();
				   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

				   IF @Ln_Error_NUMB <> 50001
					BEGIN
					 SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
					END

				   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
					@As_Procedure_NAME        = @Ls_Procedure_NAME,
					@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
					@As_Sql_TEXT              = @Ls_Sql_TEXT,
					@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
					@An_Error_NUMB            = @Ln_Error_NUMB,
					@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
					@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
					
				EXECUTE BATCH_COMMON$SP_BATE_LOG
								 @As_Process_NAME             = @Ls_Process_NAME,
								 @As_Procedure_NAME           = @Ls_Routine_TEXT,
								 @Ac_Job_ID                   = @Lc_Job_ID,
								 @Ad_Run_DATE                 = @Ld_Run_DATE,
								 @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
								 @An_Line_NUMB                = @Ln_Cursor_QNTY,
								 @Ac_Error_CODE               = @Lc_Error_CODE,
								 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
								 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
								 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
								 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;	
				
				IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
					BEGIN
					 SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
					END
				ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					BEGIN
					 RAISERROR (50001,16,1);
					END
								 
		END CATCH

      --If the commit frequency is attained, the following is done. Reset the commit COUNT, Commit the transaction completed until now.
      IF (@Ln_Commit_QNTY >= @Ln_CommitFreq_NUMB
         AND @Ln_CommitFreq_NUMB > 0)
       BEGIN
		COMMIT TRANSACTION Main_Transaction;
		BEGIN TRANSACTION Main_Transaction;
		SET @Ln_Commit_QNTY = 0;
       END

      --If the Erroneous Exceptions are more than the threshold, then we need to abend the program. The commit will ensure that the records processed so far without any problems are committed. Also the exception entries are committed so that it will be easy to determine the error records.
      IF (@Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThreshold_NUMB
         AND @Ln_ExceptionThreshold_NUMB > 0)
       BEGIN
        COMMIT TRANSACTION Main_Transaction;
        SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
        SET @Ls_Sqldata_TEXT = 'ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThreshold_NUMB AS VARCHAR);
        SET @Ls_DescriptionError_TEXT ='REACHED EXCEPTION THRESHOLD';
        RAISERROR (50001,16,1);
       END
      FETCH NEXT FROM empmrgcur INTO @Ln_OthpEmplPrimary_IDNO, @Ln_OthpEmplSecondary_IDNO, @Lc_IwnGenerate_INDC, @Ln_TransactionEventSeq_NUMB

      SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS
     END

    CLOSE empmrgcur;

    DEALLOCATE empmrgcur
    --- While End
   END

   --If rowcount is Zero insert into Bate 
   IF @Ln_Cursor_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS FOUND';
     SET @Ls_SqlData_TEXT='NO RECORDS FOUND ' + @Lc_Job_ID;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   -- Update the parameter table with the job run date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Log the Status of job in BSTL_V1 as Success  
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Null_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_Cnt;

   COMMIT TRANSACTION Main_Transaction;
  END TRY

  BEGIN CATCH
   --To Rollback the Transaction   
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION Main_Transaction;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
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
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_Cnt;
   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
