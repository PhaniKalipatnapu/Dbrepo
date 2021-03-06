/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DFW$SP_LOAD_DFW]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_LOC_INCOMING_DFW$SP_LOAD_DFW
Programmer Name   : IMP Team
Description       : The batch processes recreational licenses from the Division of Fish and Wildlife (DFW). 
					The DFW process loads Non-Custodial Parent's (NCP's) recreation licenses into the system
Frequency         : WEEKLY
Developed On      : 05/03/2011
Called BY         : None
Called On	      : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_UPDATE_PARM_DATE
-----------------------------------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 0.1
----------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DFW$SP_LOAD_DFW]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB8091',
          @Lc_ErrorE0944_CODE        CHAR(18) = 'E0944',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESS',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_DFW',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_DFW';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_File_NAME                   VARCHAR(60) = '',
          @Ls_FileLocation_TEXT           VARCHAR(80) = '',
          @Ls_FileSource_TEXT             VARCHAR(130) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = ' ',
          @Ls_SqlStatement_TEXT           VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE #LoadDfw_P1
    (
      Record_TEXT VARCHAR (386)
    );

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
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_FileSource_TEXT = LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = '';
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ls_SqlStatement_TEXT = 'BULK INSERT #LoadDfw_P1 FROM ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStatement_TEXT);

   BEGIN TRANSACTION DfwLoad

   SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS IN LDFWL_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE LDFWL_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM #LoadDfw_P1 a);

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LDFWL_Y1';
     SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC, '');

     INSERT INTO LDFWL_Y1
                 (Rec_ID,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Line1Old_ADDR,
                  Line2Old_ADDR,
                  CityOld_ADDR,
                  StateOld_ADDR,
                  ZipOld_ADDR,
                  MemberSsn_NUMB,
                  Birth_DATE,
                  HuntingLicenseNo_TEXT,
                  HuntingLicenseStatus_CODE,
                  HuntingIssueLicense_DATE,
                  HuntingExpireLicense_DATE,
                  FishingLicenseNo_TEXT,
                  FishingLicenseStatus_CODE,
                  FishingIssueLicense_DATE,
                  FishingExpireLicense_DATE,
                  AddressNormalization_CODE,
                  Line1_ADDR,
                  Line2_ADDR,
                  City_ADDR,
                  State_ADDR,
                  Zip_ADDR,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 1), @Lc_Space_TEXT))) AS Rec_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2, 20), @Lc_Space_TEXT))) AS Last_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 22, 20), @Lc_Space_TEXT))) AS First_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 42, 1), @Lc_Space_TEXT))) AS Middle_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 43, 30), @Lc_Space_TEXT))) AS Line1Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 73, 30), @Lc_Space_TEXT))) AS Line2Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 103, 15), @Lc_Space_TEXT))) AS CityOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 118, 2), @Lc_Space_TEXT))) AS StateOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 120, 9), @Lc_Space_TEXT))) AS ZipOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 129, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 138, 8), @Lc_Space_TEXT))) AS Birth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 146, 20), @Lc_Space_TEXT))) AS HuntingLicenseNo_TEXT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 166, 10), @Lc_Space_TEXT))) AS HuntingLicenseStatus_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 176, 8), @Lc_Space_TEXT))) AS HuntingIssueLicense_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 184, 8), @Lc_Space_TEXT))) AS HuntingExpireLicense_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 192, 20), @Lc_Space_TEXT))) AS FishingLicenseNo_TEXT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 212, 10), @Lc_Space_TEXT))) AS FishingLicenseStatus_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 222, 8), @Lc_Space_TEXT))) AS FishingIssueLicense_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 230, 8), @Lc_Space_TEXT))) AS FishingExpireLicense_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 241, 1), @Lc_Space_TEXT))) AS AddressNormalization_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 242, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 292, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 342, 28), @Lc_Space_TEXT))) AS City_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 370, 2), @Lc_Space_TEXT))) AS State_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 372, 15), @Lc_Space_TEXT))) AS Zip_ADDR,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_ProcessN_INDC AS Process_INDC
       FROM #LoadDfw_P1 a;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

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

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   DROP TABLE #LoadDfw_P1;

   COMMIT TRANSACTION DfwLoad;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRAN DfwLoad;
    END

   IF OBJECT_ID('tempdb..#LoadDfw_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDfw_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
