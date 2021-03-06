/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_VERIZON$SP_LOAD_VERIZON]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_VERIZON$SP_LOAD_VERIZON
Programmer Name   :	IMP Team
Description       :	This process reads the incoming file from Verizon and loads them into a temporary Verizon match 
					table (LVRZN_Y1).
Frequency         :	The job will be run once a quater when the file is received from the Verizon wireless.
Developed On      :	08/04/2011
Called By         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG
					BATCH_COMMON$SP_UPDATE_PARM_DATE
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_VERIZON$SP_LOAD_VERIZON]
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
          @Lc_Job_ID                 CHAR(7) = 'DEB8083',
          @Lc_ErrorE0944_CODE        CHAR(18) = 'E0944',
          @Lc_Successful_INDC        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_VERIZON',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_VERIZON';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) =0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadVerizon_P1
    (
      Record_TEXT VARCHAR (367)
    );

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
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
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_FileSource_TEXT = LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadVerizon_P1 FROM ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStmnt_TEXT);

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   BEGIN TRANSACTION VERIZON_LOAD;

   SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS FROM LVRZN_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = ',Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE LVRZN_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM #LoadVerizon_P1 a);

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LVRZN_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     INSERT INTO LVRZN_Y1
                 (MemberSsn_NUMB,
                  First_NAME,
                  Middle_NAME,
                  Last_NAME,
                  Line1Old_ADDR,
                  Line2Old_ADDR,
                  Line3Old_ADDR,
                  CityOld_ADDR,
                  StateOld_ADDR,
                  Zip1Old_ADDR,
                  Zip2Old_ADDR,
                  CellPhone_NUMB,
                  LastUpdate_DATE,
                  Normalization_CODE,
                  Line1_ADDR,
                  Line2_ADDR,
                  City_ADDR,
                  State_ADDR,
                  Zip_ADDR,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- NCP SSN
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 11, 20), @Lc_Space_TEXT))) AS First_NAME,-- Account holder first name
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 31, 20), @Lc_Space_TEXT))) AS Middle_NAME,-- Account holder middle name
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 51, 30), @Lc_Space_TEXT))) AS Last_NAME,-- Account holder last name
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 81, 32), @Lc_Space_TEXT))) AS Line1Old_ADDR,--Line1Old_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 113, 32), @Lc_Space_TEXT))) AS Line2Old_ADDR,--Line2Old_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 145, 32), @Lc_Space_TEXT))) AS Line3Old_ADDR,--Line3Old_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 177, 16), @Lc_Space_TEXT))) AS CityOld_ADDR,--CityOld_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 193, 2), @Lc_Space_TEXT))) AS StateOld_ADDR,--StateOld_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 195, 5), @Lc_Space_TEXT))) AS Zip1Old_ADDR,--ZipOld_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 200, 4), @Lc_Space_TEXT))) AS Zip2Old_ADDR,--Zip4Old_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 204, 10), @Lc_Space_TEXT))) AS CellPhone_NUMB,--CellPhone_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 214, 8), @Lc_Space_TEXT))) AS LastUpdate_DATE,--LastUpdate_DATE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 222, 1), @Lc_Space_TEXT))) AS Normalization_CODE,--Normalization_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 223, 50), @Lc_Space_TEXT))) AS Line1_ADDR,--Line1_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 273, 50), @Lc_Space_TEXT))) AS Line2_ADDR,--Line2_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 323, 28), @Lc_Space_TEXT))) AS City_ADDR,--City_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 351, 2), @Lc_Space_TEXT))) AS State_ADDR,--State_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 353, 15), @Lc_Space_TEXT))) AS Zip_ADDR,--Zip_ADDR
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_ProcessN_INDC AS Process_INDC
       FROM #LoadVerizon_P1 a;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

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

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_INDC,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_INDC,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
    @As_ListKey_TEXT              = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DROP TABLE #LoadVerizon_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION VERIZON_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION VERIZON_LOAD;
    END

   IF OBJECT_ID('tempdb..#LoadVerizon_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadVerizon_P1;
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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
