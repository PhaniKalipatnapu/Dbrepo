/****** Object:  StoredProcedure [dbo].[BATCH_EST_OUTGOING_FC$SP_EXTRACT_EIN_DELETES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_OUTGOING_FC$SP_EXTRACT_EIN_DELETES
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_EST_OUTGOING_FC$SP_EXTRACT_EIN_DELETES batch process is to provide Family Court with 
					  the most up-to-date employer. This information will be provided to FAMIS when employer OTHP types are end dated or merged. 
					  The EIN delete record will indicate whether the employer record was only logically deleted or logically deleted 
					  as a result of a successful merge with another employer record. If merged with a different employer record, 
					  both the logically deleted employer record (OTHP ID and EIN) and the primary employer record (OTHP ID and EIN) 
					  will be sent to FAMIS.
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_OUTGOING_FC$SP_EXTRACT_EIN_DELETES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_Zero_TEXT              CHAR(1) = '0',
          @Lc_TypeOthpE_CODE         CHAR(1) = 'E',
          @Lc_StatusMergeM_CODE      CHAR(1) = 'M',
          @Lc_MergedY_INDC           CHAR(1) = 'Y',
          @Lc_MergedEmpty_INDC       CHAR(1) = ' ',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateError_CODE         CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB8052',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_EXTRACT_EIN_DELETES',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_EST_OUTGOING_FC',
          @Ls_BateError_TEXT         VARCHAR(4000) = 'NO RECORD(S) TO PROCESS',
          @Ld_High_DATE              DATE = '12/31/9999';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RestartLine_NUMB            NUMERIC(5, 0) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Li_RowCount_QNTY               SMALLINT,
          @Lc_Empty_TEXT                  CHAR = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_FileName_NAME               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##ExtFcEin_P1';
   SET @Ls_SqlData_TEXT = '';

   CREATE TABLE ##ExtFcEin_P1
    (
      Record_TEXT CHAR(37)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION OUTGOING_FC_EIN_DELETES';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION OUTGOING_FC_EIN_DELETES;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_FileName_NAME;
   SET @Ls_FileSource_TEXT = @Lc_Empty_TEXT + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_FileName_NAME));

   IF @Ls_FileSource_TEXT = @Lc_Empty_TEXT
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE EFEIN_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EFEIN_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO EFEIN_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO EFEIN_Y1
               (DeletedFein_IDNO,
                MergedFein_IDNO,
                DeletedOthp_IDNO,
                MergedOthp_IDNO,
                Merged_INDC)
   SELECT DISTINCT
          (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(ISNULL(A.Fein_IDNO, @Lc_Zero_TEXT))), ''))), 9)) AS DeletedFein_IDNO,
          (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(ISNULL(C.Fein_IDNO, @Lc_Zero_TEXT))), ''))), 9)) AS MergedFein_IDNO,
          (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(ISNULL(A.OtherParty_IDNO, @Lc_Zero_TEXT))), ''))), 9)) AS DeletedOthp_IDNO,
          (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(ISNULL(C.OtherParty_IDNO, @Lc_Zero_TEXT))), ''))), 9)) AS MergedOthp_IDNO,
          CASE
           WHEN ISNULL(C.OtherParty_IDNO, 0) = 0
            THEN @Lc_MergedEmpty_INDC
           ELSE @Lc_MergedY_INDC
          END AS Merged_INDC
     FROM OTHP_Y1 A
          LEFT OUTER JOIN EMRG_Y1 B
           ON B.OthpEmplSecondary_IDNO = A.OtherParty_IDNO
              AND B.StatusMerge_CODE = @Lc_StatusMergeM_CODE
              AND B.EndValidity_DATE = @Ld_High_DATE
          LEFT JOIN OTHP_Y1 C
           ON C.OtherParty_IDNO = B.OthpEmplPrimary_IDNO
    WHERE A.TypeOthp_CODE = @Lc_TypeOthpE_CODE
      AND A.EndValidity_DATE <> @Ld_High_DATE
      AND A.EndValidity_DATE > @Ld_LastRun_DATE
      AND A.EndValidity_DATE <= @Ld_Run_DATE
      AND A.TransactionEventSeq_NUMB = (SELECT MAX(X.TransactionEventSeq_NUMB)
                                          FROM OTHP_Y1 X
                                         WHERE X.OtherParty_IDNO = A.OtherParty_IDNO)

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'INSERT ##ExtFcEin_P1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##ExtFcEin_P1
               (Record_TEXT)
   SELECT (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(A.DeletedFein_IDNO)), ''))), 9)) + (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(A.MergedFein_IDNO)), ''))), 9)) + (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(A.DeletedOthp_IDNO)), ''))), 9)) + (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(A.MergedOthp_IDNO)), ''))), 9)) + ISNULL(A.Merged_INDC, @Lc_MergedEmpty_INDC)
     FROM EFEIN_Y1 A
    ORDER BY A.DeletedOthp_IDNO;

   SET @Ln_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;
   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION OUTGOING_FC_EIN_DELETES';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION OUTGOING_FC_EIN_DELETES;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtFcEin_P1';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_FileName_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_FileName_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION OUTGOING_FC_EIN_DELETES';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION OUTGOING_FC_EIN_DELETES;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_SqlData_TEXT = 'Status_CODE = ' + @Lc_StatusSuccess_CODE;

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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION OUTGOING_FC_EIN_DELETES';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION OUTGOING_FC_EIN_DELETES;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtFcEin_P1 - 2';
   SET @Ls_SqlData_TEXT = '';

   DROP TABLE ##ExtFcEin_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_FC_EIN_DELETES;
    END;

   IF OBJECT_ID('tempdb..##ExtFcEin_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtFcEin_P1;
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
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
