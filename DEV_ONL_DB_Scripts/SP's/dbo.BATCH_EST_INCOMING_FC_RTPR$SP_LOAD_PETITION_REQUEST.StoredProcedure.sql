/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_LOAD_PETITION_REQUEST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_EST_INCOMING_FC_RTPR$SP_LOAD_PETITION_REQUEST
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_EST_INCOMING_FC_RTPR$SP_LOAD_PETITION_REQUEST reads the data file received from the  Family Court's 
					   System (FAMIS) and loads the data into the temporary table for futher processing based on the petition response
					   type in the input file. If the input file contains any records with unknown petition response type, these records 
					   will be moved to the BATE_Y1 TABLE. 
Frequency			 : Daily
Developed On		 : 05/10/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE,
					   BATCH_COMMON$SP_BATE_LOG,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
----------------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_LOAD_PETITION_REQUEST]
AS
 BEGIN
  SET NOCOUNT ON;

  -- Common Variables
   DECLARE @Lc_Space_TEXT					CHAR(1) = ' ',
           @Lc_StatusFailed_CODE			CHAR(1) = 'F',
           @Lc_ProcessY_INDC				CHAR(1) = 'Y',
           @Lc_ErrorTypeError_CODE			CHAR(1) = 'E',
           @Lc_ErrorTypeWarning_CODE		CHAR(1) = 'W',
           @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE		CHAR(1) = 'A',
           @Lc_PetitionDisp_CODE			CHAR(4) = 'DISP',
           @Lc_PetitionSchd_CODE			CHAR(4) = 'SCHD',
           @Lc_PetitionFild_CODE			CHAR(4) = 'FILD',
           @Lc_PetitionSrvc_CODE			CHAR(4) = 'SRVC',
           @Lc_PetitionApfl_CODE			CHAR(4) = 'APFL',
           @Lc_Value_CODE					CHAR(5) = 'N',
           @Lc_ErrorE1376_CODE				CHAR(5) = 'E1376',
           @Lc_ErrorE0944_CODE				CHAR(5) = 'E0944',
           @Lc_Job_ID						CHAR(7) = 'DEB8065',
           @Lc_Successful_TEXT				CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT			CHAR(30) = 'BATCH',
           @Lc_Parmdateproblem_TEXT			CHAR(30) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME				VARCHAR(100) = 'SP_LOAD_PETITION_REQUEST_DETAILS',
           @Ls_ErrordescRec_TEXT			VARCHAR(100) = 'UNKNOWN PETITION DISPOSITION TYPE',
           @Ls_Process_NAME					VARCHAR(100) = 'BATCH_EST_INCOMING_FC_RTPR',
           @Ls_NoRecordsInFile_TEXT			VARCHAR(100) = 'NO RECORDS IN THE FILE ',
           @Ls_CursorLoc_TEXT				VARCHAR(200) = ' ';
           
  DECLARE  @Ln_CommitFreqParm_QNTY			NUMERIC(5) = 0,
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY    NUMERIC(6) = 0,
           @Ln_UnknownRec_QNTY				NUMERIC(8) = 0,
           @Ln_FcUnidentifiedRec_QNTY		NUMERIC(8) = 0,
           @Ln_PetitionRec_QNTY				NUMERIC(8) = 0,
           @Ln_Error_NUMB					NUMERIC(11) = 0,
           @Ln_ErrorLine_NUMB				NUMERIC(11) = 0,
           @Li_FetchStatus_QNTY				SMALLINT,
           @Li_RowCount_QNTY				SMALLINT,
           @Lc_TypeError_CODE				CHAR(1) = '',
           @Lc_Msg_CODE						CHAR(1) = '',
           @Ls_FileName_TEXT				VARCHAR(50) = '',
           @Ls_FileLocation_TEXT			VARCHAR(80) = '',
           @Ls_Sql_TEXT						VARCHAR(100) = '',
           @Ls_FileSource_TEXT				VARCHAR(130) = '',
           @Ls_SqlStmnt_TEXT				VARCHAR(200) = '',
           @Ls_Sqldata_TEXT					VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT		VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT			VARCHAR(4000) = '',
           @Ld_Run_DATE						DATE,
           @Ld_Start_DATE					DATETIME2,
           @Ld_LastRun_DATE					DATETIME2;
  DECLARE  @Ls_FcpetitionCur_TEXT			VARCHAR(1500) = ' ';
  BEGIN TRY
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   -- Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE FROM COMMON PROCEDURE ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  
   --Creating Temperory Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE #LoadFcPetition_P1 
    (
      Record_TEXT VARCHAR (242)
    );
   
   -- Selecting date run, date last run, commit freq, exception threshold details --
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_TEXT OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Validation 1:Check Whether the Job ran already on same day   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_Parmdateproblem_TEXT;

     RAISERROR(50001,16,1);
    END
   
   --Assign the Source File Location
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ls_FileSource_TEXT = '' + LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_TEXT));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;
  
   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadFcPetition_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);
  
   -- Transaction begins 
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   BEGIN TRANSACTION FCPETITION_BATCH_LOAD;

   -- Delete all the processed records
   
   SET @Ls_Sql_TEXT = 'DELETE FROM LFCPR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   DELETE LFCPR_Y1
    WHERE LFCPR_Y1.Process_INDC = @Lc_ProcessY_INDC;
   
   SET @Ln_PetitionRec_QNTY = 0;
   SET @Ln_ProcessedRecordCount_QNTY = 0;
   SET @Ln_UnknownRec_QNTY = 0;

   -- Check to replace special characters in temp table received in the input file from the interface agency
      
   UPDATE #LoadFcPetition_P1
		   SET Record_TEXT = REPLACE(Record_TEXT,CAST(0x00 AS VARCHAR),' ')
      		   
   -- Check the record count for Petition records in the file 
   SELECT @Ln_PetitionRec_QNTY = COUNT(1)
     FROM #LoadFcPetition_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 4) IN (@Lc_PetitionDisp_CODE, @Lc_PetitionSchd_CODE, @Lc_PetitionFild_CODE, @Lc_PetitionSrvc_CODE, @Lc_PetitionApfl_CODE);

   --Check the record count for unknown record types in the file 
   SELECT @Ln_UnknownRec_QNTY = COUNT(1)
     FROM #LoadFcPetition_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 4) NOT IN (@Lc_PetitionDisp_CODE, @Lc_PetitionSchd_CODE, @Lc_PetitionFild_CODE, @Lc_PetitionSrvc_CODE, @Lc_PetitionApfl_CODE);

   -- If any petition response records exists in the file insert them into the table LFCPR_Y1
   IF @Ln_PetitionRec_QNTY <> 0
    BEGIN
     INSERT LFCPR_Y1
            (PetitionDispType_CODE,
             Petition_IDNO,
             PetitionSequence_IDNO,
             Case_IDNO,
             PetitionType_CODE,
             PetitionAction_DATE,
             FamilyCourtFile_ID,
             RecordTypeData_TEXT,
             FileLoad_DATE,
             Process_INDC)
     SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 4), @Lc_Space_TEXT))) AS PetitionDispType_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 5, 7), @Lc_Space_TEXT))) AS Petition_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 12, 2), @Lc_Space_TEXT))) AS PetitionSequence_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 14, 6), @Lc_Space_TEXT))) AS Case_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 20, 4), @Lc_Space_TEXT))) AS PetitionType_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 25, 8), @Lc_Space_TEXT))) AS PetitionAction_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 33, 10), @Lc_Space_TEXT))) AS FamilyCourtFile_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 45, 198), @Lc_Space_TEXT))) AS RecordTypeData_TEXT,
            @Ld_Run_DATE  AS FileLoad_DATE,
            @Lc_Value_CODE AS Process_INDC
       FROM #LoadFcPetition_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 4) IN (@Lc_PetitionDisp_CODE, @Lc_PetitionSchd_CODE, @Lc_PetitionFild_CODE, @Lc_PetitionSrvc_CODE, @Lc_PetitionApfl_CODE);

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT FAILED LFCPR_Y1';

       RAISERROR(50001,16,1);
      END
     ELSE
      BEGIN
       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowCount_QNTY;
      END
    END

   -- Check for unknown interface type and write an entry into the BATE_Y1 table 
   IF @Ln_UnknownRec_QNTY <> 0
    BEGIN
     DECLARE FcPetition_Cur  INSENSITIVE CURSOR FOR
      SELECT Record_TEXT
        FROM #LoadFcPetition_P1 a
       WHERE SUBSTRING (Record_TEXT, 1, 4) NOT IN (@Lc_PetitionDisp_CODE, @Lc_PetitionSchd_CODE, @Lc_PetitionFild_CODE, @Lc_PetitionSrvc_CODE, @Lc_PetitionApfl_CODE);

     OPEN FcPetition_Cur;

     SET @Ln_FcUnidentifiedRec_QNTY = 0;

     FETCH NEXT FROM FcPetition_Cur INTO @Ls_FcpetitionCur_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    -- Add the unknown records to the batch error table
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_FcUnidentifiedRec_QNTY = @Ln_FcUnidentifiedRec_QNTY + 1;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG ';
       SET @Ls_Sqldata_TEXT = 'PETITIONDISPOSITION_TYPE = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 1, 4) + ', FAMILYCOURT_PETITION_IDNO = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 5, 7) + ', PETITIONRELATEDSEQUENCE_IDNO = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 12, 2) + ', Case_IDNO = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 14, 6) + ', PETITION_TYPE = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 20, 4) + ', Action_DATE = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 25, 8) + ', FAMILYCOURT_FILE_IDNO = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 33, 10) + ', FAMILYCOURTDATA_TEXT = ' + SUBSTRING(@Ls_FcpetitionCur_TEXT, 45, 198);
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_FcUnidentifiedRec_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorE1376_CODE,
        @As_DescriptionError_TEXT    = @Ls_ErrordescRec_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG A FAILED';
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

         RAISERROR(50001,16,1);
        END

       FETCH NEXT FROM FcPetition_Cur INTO @Ls_FcpetitionCur_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_FcUnidentifiedRec_QNTY;
    
     CLOSE FcPetition_Cur;

     DEALLOCATE FcPetition_Cur;
    END

   -- Update the BATE_Y1 table, if there are no records in the input file 
   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG A';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');
     SET @Lc_TypeError_CODE = @Lc_ErrorTypeWarning_CODE;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_NoRecordsInFile_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG A FAILED';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;	
       RAISERROR(50001,16,1);
      END
    END

   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR(50001,16,1);
    END

   -- --Update the Log in BSTL_Y1 as the Job is suceeded
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @LC_Successful_TEXT,
    @As_ListKey_TEXT          = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY  = @Ln_ProcessedRecordCount_QNTY;
   
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   COMMIT TRANSACTION FCPETITION_BATCH_LOAD;

   --Drop Temperory Table
   DROP TABLE #LoadFcPetition_P1;
  END TRY

  BEGIN CATCH
   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FCPETITION_BATCH_LOAD;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadFcPetition_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadFcPetition_P1;
    END
   
   IF CURSOR_STATUS ('VARIABLE', 'FcPetition_Cur') IN (0, 1)
    BEGIN
     CLOSE FcPetition_Cur;

     DEALLOCATE FcPetition_Cur;
    END
   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
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
   
   --Update the Log in BSTL_Y1 as the Job is failed.
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
