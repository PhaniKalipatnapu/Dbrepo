/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DOR$SP_LOAD_DOR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_INCOMING_DOR$SP_LOAD_DOR
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_LOC_INCOMING_DOR$SP_LOAD_FILE reads the data received from DOR and loads into
                    table LDSPL_Y1 for further processing.  If the counts and amounts in the header/trailer record 
					types do not match with the counts totals of the detail record types, an error message will be 
					written into Batch Status_CODE Log (BSTL screen/BSTL table) and the file processing will be terminated.
Frequency		:	DAILY
Developed On	:	01/20/2011
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
 					BATCH_COMMON$BSTL_LOG,
 					BATCH_COMMON$SP_UPDATE_PARM_DATE,
 					BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DOR$SP_LOAD_DOR]
AS
 BEGIN
  SET NOCOUNT ON;

  -- Common Variables
  DECLARE @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_HeaderH_CODE           CHAR(1) = 'H',
          @Lc_TrailerT_CODE          CHAR(1) = 'T',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB8031',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_DOR',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_DOR';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RecordCount_NUMB            NUMERIC(10, 0),
          @Ln_TrailerRecordCount_NUMB     NUMERIC(10, 0),
          @Ln_Error_NUMB                  NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(10),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_FileName_TEXT               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStatement_TEXT           VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_FileCreate_DATE             DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE #LoadDor_P1
    (
      LineData_TEXT VARCHAR (629)
    );

   -- Selecting Date Run, Date Last Run, Commit Freq, Exception Threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Assign the Source File Location
   SET @Ls_FileSource_TEXT = LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_TEXT));
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', FileSource_TEXT = ' + ISNULL(@Ls_FileSource_TEXT, '');

   IF (@Ls_FileSource_TEXT = @Lc_Space_TEXT)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'BULK INSERT #LoadDor_P1 FROM  ''' + LTRIM(@Ls_FileSource_TEXT) + '''';
   SET @Ls_SqlStatement_TEXT = 'BULK INSERT #LoadDor_P1 FROM  ''' + LTRIM(@Ls_FileSource_TEXT) + '''';

   EXEC (@Ls_SqlStatement_TEXT);

   --Transaction begins
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   BEGIN TRANSACTION DorLoad;

   --Delete the Load Table Data
   SET @Ls_Sql_TEXT = 'DELETE LDSPL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   DELETE LDSPL_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM #LoadDor_P1 a);

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     --Insert into Load table
     SET @Ls_Sql_TEXT = 'INSERT LDSPL_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     INSERT LDSPL_Y1
            (PrefixSsn_NUMB,
             MemberSsn_NUMB,
             SuffixSsn_NUMB,
             Business_NAME,
             Trade_NAME,
             Business_CODE,
             OwnershipType_CODE,
             LicenseNo_TEXT,
             LocationLine1Old_ADDR,
             LocationLine2Old_ADDR,
             LocationCityOld_ADDR,
             LocationStateOld_ADDR,
             LocationZipOLd_ADDR,
             MailingLine1Old_ADDR,
             MailingLine2Old_ADDR,
             MailingCityOld_ADDR,
             MailingStateOld_ADDR,
             MailingZipOld_ADDR,
             MultiEmployer_INDC,
             OwnerPrefixSsn_NUMB,
             OwnerSsn_NUMB,
             Owner_NAME,
             LicenseStatus_CODE,
             LocationNormalization_CODE,
             LocationLine1_ADDR,
             LocationLine2_ADDR,
             LocationCity_ADDR,
             LocationState_ADDR,
             LocationZip_ADDR,
             MailingNormalization_CODE,
             MailingLine1_ADDR,
             MailingLine2_ADDR,
             MailingCity_ADDR,
             MailingState_ADDR,
             MailingZip_ADDR,
             FileLoad_DATE,
             Process_INDC)
     SELECT (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 1, 1), @Lc_Space_TEXT))) AS PrefixSsn_NUMB,-- PrefixSsn_NUMB
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 2, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- SSN
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 11, 3), @Lc_Space_TEXT))) AS SuffixSsn_NUMB,-- SuffixSsn_NUMB
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 14, 32), @Lc_Space_TEXT))) AS Business_NAME,-- Business_NAME
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 46, 32), @Lc_Space_TEXT))) AS Trade_NAME,-- Trade_NAME
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 78, 3), @Lc_Space_TEXT))) AS Business_CODE,-- Business_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 81, 2), @Lc_Space_TEXT))) AS OwnershipType_CODE,-- OwnershipType_TEXT
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 83, 10), @Lc_Space_TEXT))) AS LicenseNo_TEXT,-- License_NUMB
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 93, 32), @Lc_Space_TEXT))) AS LocationLine1Old_ADDR,-- Location1Old_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 125, 32), @Lc_Space_TEXT))) AS LocationLine2Old_ADDR,-- Location2Old_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 157, 25), @Lc_Space_TEXT))) AS LocationCityOld_ADDR,-- LocationOld_CITY
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 182, 2), @Lc_Space_TEXT))) AS LocationStateOld_ADDR,-- LocationStateOld_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 184, 9), @Lc_Space_TEXT))) AS LocationZipOLd_ADDR,-- LocationOld_ZIP
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 193, 32), @Lc_Space_TEXT))) AS MailingLine1Old_ADDR,-- MailingLine1Old_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 225, 32), @Lc_Space_TEXT))) AS MailingLine2Old_ADDR,-- MailingLine2Old_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 257, 25), @Lc_Space_TEXT))) AS MailingCityOld_ADDR,-- MailingOld_CITY
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 282, 2), @Lc_Space_TEXT))) AS MailingStateOld_ADDR,--  MailingStateOld_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 284, 9), @Lc_Space_TEXT))) AS MailingZipOld_ADDR,--  MailingOld_ZIP
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 293, 1), @Lc_Space_TEXT))) AS MultiEmployer_INDC,--  MultiEmployer_INDC
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 294, 1), @Lc_Space_TEXT))) AS OwnerPrefixSsn_NUMB,--  OwnerPrefixSsn_NUMB
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 295, 9), @Lc_Space_TEXT))) AS OwnerSsn_NUMB,--  OwnerSsn_NUMB
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 304, 32), @Lc_Space_TEXT))) AS Owner_NAME,-- Owner_NAME
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 336, 1), @Lc_Space_TEXT))) AS LicenseStatus_CODE,--  LicenceStatus_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 337, 1), @Lc_Space_TEXT))) AS LocationNormalization_CODE,--  LocationNormalization_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 338, 50), @Lc_Space_TEXT))) AS LocationLine1_ADDR,-- LocationLine1_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 388, 50), @Lc_Space_TEXT))) AS LocationLine2_ADDR,-- LocationLine2_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 438, 28), @Lc_Space_TEXT))) AS LocationCity_ADDR,-- LocationCity_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 466, 2), @Lc_Space_TEXT))) AS LocationState_ADDR,--  LocationState_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 468, 15), @Lc_Space_TEXT))) AS LocationZip_ADDR,-- LocationZip_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 483, 1), @Lc_Space_TEXT))) AS MailingNormalization_CODE,-- MailingNormalization_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 484, 50), @Lc_Space_TEXT))) AS MailingLine1_ADDR,-- MailingLine1_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 534, 50), @Lc_Space_TEXT))) AS MailingLine2_ADDR,-- MailingLine2_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 584, 28), @Lc_Space_TEXT))) AS MailingCity_ADDR,-- MailingCity_ADDR
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 612, 2), @Lc_Space_TEXT))) AS MailingState_ADDR,-- MailingState_CODE
            (RTRIM (ISNULL (SUBSTRING (LD.LineData_TEXT, 614, 15), @Lc_Space_TEXT))) AS MailingZip_ADDR,-- MailingZip_ADDR
            @Ld_Run_DATE AS FileLoad_DATE,-- File Recieved Date
            @Lc_ProcessN_INDC AS Process_INDC -- Process INDC
       FROM #LoadDor_P1 LD
      WHERE LEFT (LD.LineData_TEXT, 1) NOT IN (@Lc_HeaderH_CODE, @Lc_TrailerT_CODE);

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Update the Log in BSTL_Y1 as the Job is suceeded.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DROP TABLE #LoadDor_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION DorLoad;
  END TRY

  --Execption Begins
  BEGIN CATCH
   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRAN DorLoad;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadDor_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDor_P1;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   -- Retrieve and log the Error Description.
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   --Update the Log in BSTL_Y1 as the Job is failed.
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
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
