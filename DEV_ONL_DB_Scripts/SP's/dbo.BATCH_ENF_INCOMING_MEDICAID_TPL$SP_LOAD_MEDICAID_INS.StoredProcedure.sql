/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_INS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_INS
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_INS 
					  loads the Insurance companies details provided by the Medicaid agency 
					  to the temporary table for further processing.
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_LOAD_MEDICAID_INS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_TypeRecordIc_CODE      CHAR(2) = 'IC',
          @Lc_TypeRecordFt_CODE      CHAR(2) = 'FT',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB9090',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_MEDICAID_INS',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_MEDICAID_TPL';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10),
          @Ln_TrailerRecCount_QNTY        NUMERIC(10, 0),
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_BulkInsertSql_TEXT          VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(2000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE #LoadMpt_P1';
   CREATE TABLE #LoadMpt_P1
    (
      Record_TEXT CHAR(346)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_LOAD_MEDICAID_INS';
   BEGIN TRANSACTION TXN_LOAD_MEDICAID_INS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'');

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
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF LEN(@Ls_FileSource_TEXT) = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';   SET @Ls_BulkInsertSql_TEXT = 'BULK INSERT #LoadMpt_P1 FROM ''' + @Ls_FileSource_TEXT + '''';

   SET @Ls_SqlData_TEXT = '';

   EXEC (@Ls_BulkInsertSql_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadMpt_P1 - TRAILER COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_TrailerRecCount_QNTY = SUBSTRING(A.Record_TEXT, 3, 8)
     FROM #LoadMpt_P1 A
    WHERE SUBSTRING(A.Record_TEXT, 1, 2) = @Lc_TypeRecordFt_CODE;

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadMpt_P1 - DETAILS COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_RecordCount_QNTY = COUNT(1)
     FROM #LoadMpt_P1 A
    WHERE SUBSTRING(A.Record_TEXT, 1, 2) = @Lc_TypeRecordIc_CODE;

   SET @Ls_Sql_TEXT = 'CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN TRIALER';
   IF @Ln_RecordCount_QNTY != @Ln_TrailerRecCount_QNTY
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO. OF RECORDS IN TRAILER DOESNT MATCH WITH SUM OF DETAIL RECORDS' + ', DETAIL RECORD COUNT = ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR) + ', TRAILER RECORD COUNT = ' + CAST(@Ln_TrailerRecCount_QNTY AS VARCHAR);

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE PROCESSED RECORDS FROM LIPRO_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'');

   DELETE FROM LIPRO_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   IF @Ln_RecordCount_QNTY > @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LIPRO_Y1';
     SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC,'')+ ', FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

     INSERT INTO LIPRO_Y1
                 (Employer_NAME,
                  InsCompanyCarrier_CODE,
                  InsCompanyLocation_CODE,
                  Line1Old_ADDR,
                  Line2Old_ADDR,
                  CityOld_ADDR,
                  StateOld_ADDR,
                  ZipOld_ADDR,
                  Phone_NUMB,
                  Normalization_CODE,
                  Line1_ADDR,
                  Line2_ADDR,
                  City_ADDR,
                  State_ADDR,
                  Zip_ADDR,
                  Process_INDC,
                  FileLoad_DATE)
     SELECT SUBSTRING(A.Record_TEXT, 3, 45) AS Employer_NAME,
            SUBSTRING(A.Record_TEXT, 48, 5) AS InsCompanyCarrier_CODE,
            SUBSTRING(A.Record_TEXT, 53, 4) AS InsCompanyLocation_CODE,
            SUBSTRING(A.Record_TEXT, 57, 25) AS Line1Old_ADDR,
            SUBSTRING(A.Record_TEXT, 82, 25) AS Line2Old_ADDR,
            SUBSTRING(A.Record_TEXT, 107, 20) AS CityOld_ADDR,
            SUBSTRING(A.Record_TEXT, 127, 2) AS StateOld_ADDR,
            SUBSTRING(A.Record_TEXT, 129, 15) AS ZipOld_ADDR,
            SUBSTRING(A.Record_TEXT, 144, 10) AS Phone_NUMB,
            SUBSTRING(A.Record_TEXT, 201, 1) AS Normalization_CODE,
            SUBSTRING(A.Record_TEXT, 202, 50) AS Line1_ADDR,
            SUBSTRING(A.Record_TEXT, 252, 50) AS Line2_ADDR,
            SUBSTRING(A.Record_TEXT, 302, 28) AS City_ADDR,
            SUBSTRING(A.Record_TEXT, 330, 2) AS State_ADDR,
            SUBSTRING(A.Record_TEXT, 332, 15) AS Zip_ADDR,
            @Lc_ProcessN_INDC AS Process_INDC,
            @Ld_Run_DATE AS FileLoad_DATE
       FROM #LoadMpt_P1 A
      WHERE SUBSTRING(A.Record_TEXT, 1, 2) = @Lc_TypeRecordIc_CODE;

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_LOAD_MEDICAID_INS';
   COMMIT TRANSACTION TXN_LOAD_MEDICAID_INS;

   SET @Ls_Sql_TEXT = 'DROP #LoadMpt_P1';
   DROP TABLE #LoadMpt_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_LOAD_MEDICAID_INS;
    END;

   IF OBJECT_ID('tempdb..#LoadMpt_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadMpt_P1;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
