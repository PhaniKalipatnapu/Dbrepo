/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_UPDATE_INCOMING$SP_LOAD_IVE_UPDATES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_IVE_UPDATE_INCOMING$SP_LOAD_IVE_UPDATES
Programmer Name   :	IMP Team
Description       :	This process loads the incoming file from the IV-E agency into a temporary table.
Frequency         :	Daily
Developed On      :	08/10/2011
Freuency		  : Daily
Called By         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE
---------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
---------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_UPDATE_INCOMING$SP_LOAD_IVE_UPDATES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ErrrorTypeW_CODE       CHAR(1) = 'W',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_DetailRecordType_CODE  CHAR(1) = 'D',
          @Lc_TrailerRecordType_TEXT CHAR(1) = 'T',
          @Lc_ErrrorE0944_CODE       CHAR(5) = 'E0944',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB0270',
          @Lc_Successful_INDC        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_IVE_UPDATES',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_FIN_IVE_UPDATE_INCOMING';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6),
          @Ln_TrailerRec_NUMB             NUMERIC(10, 0),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
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
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID + ', RUN_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   CREATE TABLE #LoadIveUpdate_P1
    (
      Record_TEXT VARCHAR (193)
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
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID + ', RUN_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_ErrorMessage_TEXT ='FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID + ', RUN_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadIveUpdate_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStmnt_TEXT);

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION IVEINCOMINGUPDATE_LOAD;

   SET @Ls_Sql_TEXT ='DELETE RECORDS FROM LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE LFIVE_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'SELECT TMP_LOAD_IVE_UPDATE_TABLE - DETAILS COUNT';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT (1)
                                          FROM #LoadIveUpdate_P1 a
                                         WHERE SUBSTRING(Record_TEXT, 1, 1) = @Lc_DetailRecordType_CODE);

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT TMP_LOAD_IVE_UPDATE_TABLE - TRAILER COUNT';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     SELECT @Ln_TrailerRec_NUMB = (SUBSTRING(Record_TEXT, 22, 10))
       FROM #LoadIveUpdate_P1 a
      WHERE SUBSTRING(Record_TEXT, 1, 1) = @Lc_TrailerRecordType_TEXT;

     SET @Ls_Sql_TEXT ='CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN TRIALER';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     IF @Ln_ProcessedRecordCount_QNTY != @Ln_TrailerRec_NUMB
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'NO. OF RECORDS IN TRAILER DOESNT MATCH WITH SUM OF DETAIL RECORDS' + '.DETAIL RECORD COUNT = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + '.TRAILER RECORD COUNT = ' + CAST(@Ln_TrailerRec_NUMB AS VARCHAR);

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT LFIVE_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     INSERT INTO LFIVE_Y1
                 (Rec_ID,
                  MemberMci_IDNO,
                  IveParty_IDNO,
                  MotherCase_IDNO,
                  FatherCase_IDNO,
                  Removal_DATE,
                  Determination_DATE,
                  Determination_CODE,
                  MotherTpr_INDC,
                  MotherTprDecision_DATE,
                  FatherTpr_INDC,
                  FatherTprDecision_DATE,
                  Worker_NAME,
                  WorkPhone_NUMB,
                  Parent_NAME,
                  ParentIveParty_IDNO,
                  MemberSsn_NUMB,
                  Birth_DATE,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 1), @Lc_Space_TEXT))) AS Rec_ID,-- Rec_ID
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 2, 10), @Lc_Space_TEXT))) AS MemberMci_IDNO,-- MemberMci_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 12, 10), @Lc_Space_TEXT))) AS IveParty_IDNO,-- IveParty_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 22, 10), @Lc_Space_TEXT))) AS MotherCase_IDNO,-- MotherCase_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 32, 10), @Lc_Space_TEXT))) AS FatherCase_IDNO,-- FatherCase_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 42, 8), @Lc_Space_TEXT))) AS Removal_DATE,-- Removal_DATE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 50, 8), @Lc_Space_TEXT))) AS Determination_DATE,-- Determination_DATE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 58, 1), @Lc_Space_TEXT))) AS Determination_CODE,-- Determination_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 59, 1), @Lc_Space_TEXT))) AS MotherTpr_INDC,-- MotherTpr_INDC
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 60, 8), @Lc_Space_TEXT))) AS MotherTprDecision_DATE,-- MotherTprDecision_DATE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 68, 1), @Lc_Space_TEXT))) AS FatherTpr_INDC,-- FatherTpr_INDC
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 69, 8), @Lc_Space_TEXT))) AS FatherTprDecision_DATE,-- FatherTprDecision_DATE                      
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 77, 40), @Lc_Space_TEXT))) AS Worker_NAME,-- Worker_NAME
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 117, 10), @Lc_Space_TEXT))) AS WorkPhone_NUMB,-- WorkPhone_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 127, 40), @Lc_Space_TEXT))) AS Parent_NAME,-- Parent_NAME
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 167, 10), @Lc_Space_TEXT))) AS ParentIveParty_IDNO,-- ParentIveParty_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 177, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- MemberSsn_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 186, 8), @Lc_Space_TEXT))) AS Birth_DATE,-- Birth_DATE
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_ProcessN_INDC AS Process_INDC
       FROM #LoadIveUpdate_P1 a
      WHERE (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 1), @Lc_Space_TEXT))) = @Lc_DetailRecordType_CODE;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrrorTypeW_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrrorTypeW_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_ErrrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

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
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE IF EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DROP TABLE #LoadIveUpdate_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION IVEINCOMINGUPDATE_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRAN IVEINCOMINGUPDATE_LOAD;
    END

   IF OBJECT_ID('tempdb..#LoadIveUpdate_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadIveUpdate_P1;
    END

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
