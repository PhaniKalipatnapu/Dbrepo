/****** Object:  StoredProcedure [dbo].[BATCH_ENF_STAGING$SP_PROCESS_INSERT_ENSD_POST_EMON]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_STAGING$SP_PROCESS_INSERT_ENSD_POST_EMON
Programmer Name   : IMP Team
Description       : The procedure BATCH_ENF_STAGING$SP_PROCESS_INSERT_ENSD_POST_EMON is used to insert data in ENSD_Y1.
Frequency         : Daily 
Developed On      : 01/05/2012
Called BY         : None
Called On         : BATCH_COMMON$SP_GET_BATCH_DETAILS , BATCH_COMMON$BSTL_LOG,
					BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON, BATCH_COMMON$SP_UPDATE_PARM_DATE
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_STAGING$SP_PROCESS_INSERT_ENSD_POST_EMON]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Null_TEXT				CHAR(1)			= ' ',
           @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
           @Lc_StatusFailed_CODE		CHAR(1)			= 'F',
           @Lc_Successful_TEXT			CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT		CHAR(30)		= 'BATCH',
           @Ls_Procedure_NAME			VARCHAR(100)	= 'SP_PROCESS_INSERT_ENSD_POST_EMON';
  DECLARE  @Ln_CommitFreq_NUMB          NUMERIC(5),
           @Ln_ExceptionThreshold_NUMB  NUMERIC(5),
           @Ln_Error_NUMB               NUMERIC(10)		= 0,
           @Ln_ErrorLine_NUMB           NUMERIC(10)		= 0,
           @Ln_Count_NUMB				NUMERIC(10)		= 0,
           @Lc_Msg_CODE                 CHAR(3),
           @Lc_ReasonAnoad_CODE         CHAR(5),
           @Lc_Job_ID                   CHAR(7),
           @Ls_Sql_TEXT                 VARCHAR(100),
           @Ls_Process_NAME             VARCHAR(100),
           @Ls_Sqldata_TEXT             VARCHAR(1000),
           @Ls_ErrorDesc_TEXT           VARCHAR(4000),
           @Ls_DescriptionError_TEXT    VARCHAR(4000),
           @Ld_Run_DATE                 DATE,
           @Ld_LastRun_DATE             DATE,
           @Ld_Start_DATE               DATETIME2;


  BEGIN TRY
   BEGIN TRANSACTION ENF_POSTEMON;

   SET @Lc_Job_ID = 'DEB1220';
   SET @Ls_Process_NAME = 'BATCH_ENF_STAGING';
   SET @Lc_ReasonAnoad_CODE = 'ANOAD';
   SET @Ls_Sql_TEXT = 'DEB1220_001 : GET BATCH START TIME';
   SET @Ls_Sqldata_TEXT = @Lc_Null_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DEB1220_002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_NUMB OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorDesc_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Lc_StatusSuccess_CODE + '          ' + @Lc_Msg_CODE + '                 ' + 'DEB1220_003 : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';

     RAISERROR (50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_Sql_TEXT = 'DEB1220_004 : PARM DATE CONDITION FAILED';
     SET @Ls_Sqldata_TEXT = ' DT_LAST_RUN = ' + ISNULL(CAST(@Ld_LastRun_DATE AS NVARCHAR(MAX)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(MAX)), '');
     SET @Ls_ErrorDesc_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DEB1220_005 : BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(MAX)), '');

   EXECUTE BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON
    @Ad_Run_DATE         = @Ld_Run_DATE,
    @Ac_MSG_CODE         = @Lc_Msg_CODE OUTPUT,
    @As_Error_DESC       = @Ls_ErrorDesc_TEXT OUTPUT,
    @As_Sql_TEXT         = @Ls_Sql_TEXT OUTPUT,
    @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DEB1220_006 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(MAX)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'DEB1220_006 : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR (50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'SELECT ENSD_Y1 COUNT';
   SET @Ls_Sqldata_TEXT = @Lc_Null_TEXT;
   SELECT @Ln_Count_NUMB = COUNT(1)
	 FROM ENSD_Y1;

   SET @Ls_Sql_TEXT = 'DEB1220_006 : BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_Count_NUMB AS VARCHAR), '');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Null_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Count_NUMB;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION ENF_POSTEMON;
    END
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ENF_POSTEMON;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
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
    @As_CursorLocation_TEXT       = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
