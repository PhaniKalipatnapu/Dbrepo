/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_GEN_TEST$SP_LOAD_GENETIC_TEST_RESULTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_EST_INCOMING_GEN_TEST$SP_LOAD_GENETIC_TEST_RESULTS
Programmer Name 	: IMP Team.
Description			: The purpose of this procedure is to insert the orchid test results.
Frequency			: DAILY
Developed On		: 26-MAR-2012
Called By			:
Called On       	: BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_BSTL_LOG and BATCH_COMMON$SP_UPDATE_PARM_DATE 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_GEN_TEST$SP_LOAD_GENETIC_TEST_RESULTS]
 @An_Case_IDNO							CHAR(6),
 @Ac_FirstMother_NAME					CHAR(15),
 @Ac_MiMother_NAME						CHAR(20),
 @Ac_LastMother_NAME					CHAR(20),
 @Ac_FirstFather_NAME					CHAR(15),
 @Ac_MiFather_NAME						CHAR(20),
 @Ac_LastFather_NAME					CHAR(20),
 @Ac_ChildFirst_NAME					CHAR(15),
 @Ac_ChildMiddle_NAME					CHAR(20),
 @Ac_ChildLast_NAME						CHAR(20),
 @Ad_ResultsReceived_DATE				DATE,
 @An_Probability_PCT					NUMERIC(5, 2),
 @Ac_File_ID							CHAR(15),
 @Ad_Run_DATE							DATE,
 @An_Record_NUMB						NUMERIC, 
 @Ac_RecordLast_INDC					CHAR(1),
 @Ac_Status_CODE						CHAR(1),
 @Ac_Msg_CODE							CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT				VARCHAR(4000) OUTPUT,
 @Ad_Start_DATE							DATETIME2 OUTPUT
AS
  DECLARE  @Li_One_NUMB					INT				= 1,
           @Li_Zero_NUMB				INT				= 0,
           @Lc_Yes_INDC					CHAR(1)			= 'Y',
           @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
           @Lc_StatusFailed_CODE		CHAR(1)			= 'F',
           @Lc_Space_TEXT				CHAR(1)			= ' ',
           @Lc_No_INDC					CHAR(1)			= 'N',
           @Ac_StatusAbend_CODE			CHAR(1)			= 'A',
           @Lc_ErrorTypeWarning_CODE    CHAR(1)			= 'W',		   
           @Lc_BatchRunUser_TEXT		CHAR(5)			= 'BATCH',
           @Lc_NoRecordsToProcess_CODE  CHAR(5)			= 'E0944',
           @Lc_Job_ID					CHAR(7)			= 'DEB1430',
           @Lc_Successful_TEXT			CHAR(20)		= 'SUCCESSFUL',
           @Ls_Process_NAME				VARCHAR(50)		= 'Dhss.Ivd.Decss.Batch.LapcorpPaternityTest',
           @Ls_Procedure_NAME			VARCHAR(60)		= 'SP_LOAD_GENETIC_TEST_RESULTS';
           
  DECLARE  @Ln_CommitFreq_QNTY			NUMERIC(5),
		   @Ln_ExceptionThreshold_QNTY	NUMERIC(5),
		   @Ln_Record_NUMB				NUMERIC(3),
		   @Ln_Error_NUMB               NUMERIC(11)		= 0,
           @Ln_ErrorLine_NUMB           NUMERIC(11)		= 0,
           @Lc_Msg_CODE					CHAR(5),
           @Ls_Sql_TEXT					VARCHAR(100)	= NULL,
           @Ls_Sqldata_TEXT				VARCHAR(1000)	= NULL,
           @Ls_DescriptionError_TEXT	VARCHAR(4000),	
		   @Ld_Run_DATE  				DATETIME,
		   @Ld_LastRun_DATE				DATETIME2;
 BEGIN
  BEGIN TRY

   SET @Ln_Record_NUMB = @An_Record_NUMB;
   SET @Ad_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   -- Before inserting first record received from labcorp the LGRES_Y1 table will be cleared.
   IF (@Ln_Record_NUMB = @Li_One_NUMB)
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE FROM LGRES_Y1';

     DELETE LGRES_Y1
      WHERE Process_INDC = @Lc_Yes_INDC;

	    EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
		@Ac_Job_ID                  = @Lc_Job_ID,
		@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
		@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
		@An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
		@An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
		@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT

	   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
		 SET @Ls_Sql_TEXT = 'BATCH_EST_INCOMING_GEN_TEST$SP_PROCESS_GENETIC_TEST_RESULTS1';

		 RAISERROR(50001,16,1);
		END

	   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
	   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

	   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
		BEGIN
		 SET @Ln_Record_NUMB = 0;
		 SET @As_DescriptionError_TEXT = 'PARM DATE PROBLEM';	 
		 RAISERROR(50001,16,1);
		END

    END

   SET @Ls_Sql_TEXT = 'TO CHECK BATCH SUCESS/FAILS WITHOUT OUTPUT';

   IF (LTRIM(RTRIM(@Ac_Status_CODE)) = @Lc_StatusSuccess_CODE
        OR LTRIM(RTRIM(@Ac_Status_CODE)) = @Lc_StatusFailed_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE FROM LGRES_Y1';

     DELETE LGRES_Y1
      WHERE Process_INDC = @Lc_Yes_INDC;

      

     IF (LTRIM(RTRIM(@Ac_Status_CODE)) = @Lc_StatusSuccess_CODE)
      BEGIN
	    SET @Ln_Record_NUMB = 0;
	    SET @Ls_Sql_TEXT = 'SUCCESSFUL';
		SET @Ls_DescriptionError_TEXT = 'No Records To Process';
      END

     IF (LTRIM(RTRIM(@Ac_Status_CODE)) = @Lc_StatusFailed_CODE)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH FAILS WITH NO OUTPUT';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR);
       RAISERROR(50001,16,1);
      END
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_ErrorTypeWarning_CODE + ', NoRecordsToProcess_CODE = ' + @Lc_NoRecordsToProcess_CODE;
      
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = @Li_Zero_NUMB,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;
      
	 SET @Ls_Sql_TEXT = 'SUCCESSFUL';
	 SET @Ls_DescriptionError_TEXT = '';
	 SET @Ls_Sqldata_TEXT = 'SUCCESSFUL';
	 
     EXECUTE BATCH_COMMON$SP_BSTL_LOG
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ad_Start_DATE            = @Ad_Start_DATE,
      @Ac_Job_ID                = @Lc_Job_ID,
      @As_Process_NAME          = @Ls_Process_NAME,
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_CursorLocation_TEXT   = @Li_Zero_NUMB,
      @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
      @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
      @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
      @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
      @An_ProcessedRecordCount_QNTY = @Ln_Record_NUMB;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE 1';
     SET @Ls_Sqldata_TEXT = 'ID_JOB: ' + ISNULL(@Lc_Job_ID, '') + ' DT_RUN: ' + ISNULL(CAST(@Ad_Run_DATE AS NVARCHAR(10)), '');

     EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE VPARM FAILED';

       RAISERROR (50001,16,1);
      END
     SET @Ac_Msg_CODE = @Ac_Status_CODE;
     RETURN;
    END

   BEGIN
     BEGIN TRANSACTION LoadGtst;

    SET @Ls_Sql_TEXT = 'INSERT INTO LGRES_Y1';
    SET @Ls_Sqldata_TEXT = 'CASE ID:' +  ISNULL(@An_Case_IDNO, '') + @Lc_Space_TEXT + 'MOM First Name:' + ISNULL(@Ac_FirstMother_NAME, '') + @Lc_Space_TEXT + 'Mom Last Name :' + ISNULL(@Ac_LastMother_NAME, '') + @Lc_Space_TEXT + 'Mom Middle Name:' + ISNULL(@Ac_MiMother_NAME, '') + @Lc_Space_TEXT + 'Father First Name:' + ISNULL(@Ac_FirstFather_NAME, '') + @Lc_Space_TEXT + 'Fathers Last Name:' + ISNULL(@Ac_LastFather_NAME, '') + @Lc_Space_TEXT + 'Fathers Middle Name:' + ISNULL(@Ac_MiFather_NAME, '') + @Lc_Space_TEXT + 'Dependant First Name:' + ISNULL(@Ac_ChildFirst_NAME, '') + @Lc_Space_TEXT + 'Dependant Last Name:' + ISNULL(@Ac_ChildLast_NAME, '') + @Lc_Space_TEXT + 'Dependent Middle Name' + ISNULL(@Ac_ChildMiddle_NAME, '') + 'Result received' + ISNULL(CAST(@Ad_ResultsReceived_DATE AS NVARCHAR(10)), '') + 'Probability' + ISNULL(CAST(@An_Probability_PCT AS NVARCHAR(5)), '')

    INSERT LGRES_Y1
           (Case_IDNO,
            FirstMother_NAME,
            LastMother_NAME,
            MiddleMother_NAME,
            FirstFather_NAME,
            LastFather_NAME,
            MiddleFather_NAME,
            ChildFirst_NAME,
            ChildLast_NAME,
            ChildMiddle_NAME,
            ResultsReceived_DATE,
            Probability_PCT,
            File_ID,
            Process_INDC,
            Run_DATE,
            Update_DTTM)
    VALUES ( ISNULL(@An_Case_IDNO,0),
             ISNULL(@Ac_FirstMother_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_LastMother_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_MiMother_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_FirstFather_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_LastFather_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_MiFather_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_ChildFirst_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_ChildLast_NAME, @Lc_Space_TEXT),
             ISNULL(@Ac_ChildMiddle_NAME, @Lc_Space_TEXT),
             @Ad_ResultsReceived_DATE,
             ISNULL(@An_Probability_PCT, 0.0),
             ISNULL(@Ac_File_ID, @Lc_Space_TEXT),
             @Lc_No_INDC,
             @Ad_Run_DATE,
             dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

    IF @@ROWCOUNT = 0
     BEGIN
      SET @Ls_DescriptionError_TEXT = 'INSERT LOAD TABLE FAILED';

      RAISERROR(50001,16,1);
     END
   END

   IF (@Ac_RecordLast_INDC = @Lc_Yes_INDC)
    BEGIN
    
     EXECUTE BATCH_COMMON$SP_BSTL_LOG
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ad_Start_DATE            = @Ad_Start_DATE,
      @Ac_Job_ID                = @Lc_Job_ID,
      @As_Process_NAME          = @Ls_Process_NAME,
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
      @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
      @As_ListKey_TEXT          = @Lc_Successful_TEXT,
      @As_DescriptionError_TEXT = @Lc_Space_TEXT,
      @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
      @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
      @An_ProcessedRecordCount_QNTY = @Ln_Record_NUMB;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE 2';
     SET @Ls_Sqldata_TEXT = 'ID_JOB: ' + ISNULL(@Lc_Job_ID, '') + ' DT_RUN: ' + ISNULL(CAST(@Ad_Run_DATE AS NVARCHAR(10)), '');

     EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE PARM DATE FAILED';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   COMMIT TRANSACTION LoadGtst;

  END TRY

  BEGIN CATCH

  IF @@TRANCOUNT > 0 
      BEGIN
       ROLLBACK TRANSACTION LoadGtst;
      END
      
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
      
    IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
    
 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
 

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @Ad_Start_DATE            = @Ad_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ln_Record_NUMB,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Ac_StatusAbend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Record_NUMB;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
  END CATCH
 END


GO
