/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_BSTL_LOG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_BSTL_LOG
Programmer Name		: IMP Team
Description			: This procedure is used to insert the batch Status_CODE into BSTL_Y1 table.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_BSTL_LOG]
 @Ad_Run_DATE                  DATE,
 @Ad_Start_DATE                DATETIME2,
 @Ac_Job_ID                    CHAR(7),
 @As_Process_NAME              VARCHAR(100),
 @As_Procedure_NAME            VARCHAR(100),
 @As_CursorLocation_TEXT       VARCHAR(200),
 @As_ExecLocation_TEXT         VARCHAR(100),
 @As_ListKey_TEXT              VARCHAR(1000),
 @As_DescriptionError_TEXT     VARCHAR(4000),
 @Ac_Status_CODE               CHAR(1),
 @Ac_Worker_ID                 CHAR(30),
 @An_ProcessedRecordCount_QNTY NUMERIC(6),
 @An_RecRestart_NUMB		   NUMERIC(15) = 0,
 @An_Thread_NUMB			   NUMERIC(15) = 0,
 @As_RestartKey_TEXT           VARCHAR(200) = '',
 @Ac_ThreadProcess_CODE		   CHAR(1) = ''
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT   CHAR (1) = ' ',
		  @Lc_ThreadProcessLocked_CODE CHAR(1) = 'L',
          @Ls_Routine_TEXT VARCHAR (60) = 'BATCH_COMMON$SP_BSTL_LOG';
  DECLARE @Ln_Error_NUMB        NUMERIC,
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Ls_Sql_TEXT          VARCHAR (100),
          @Ls_Sqldata_TEXT      VARCHAR (1000),
          @Ls_ErrorMessage_TEXT VARCHAR(4000),
          @Ld_Create_DTTM		DATETIME2;

  BEGIN TRY
   SET @Ld_Create_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'INSERT IN BSTL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@As_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@As_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Create_DTTM = ' + ISNULL(CAST( @Ld_Create_DTTM AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Ac_Status_CODE,'')+ ', Worker_ID = ' + ISNULL(@Ac_Worker_ID,'')+ ', JobStart_DTTM = ' + ISNULL(CAST( @Ad_Start_DATE AS VARCHAR ),'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @An_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   
   INSERT BSTL_Y1
          (Process_NAME,
           Procedure_NAME,
           Job_ID,
           EffectiveRun_DATE,
           Create_DTTM,
           Status_CODE,
           CursorLocation_TEXT,
           ExecLocation_TEXT,
           DescriptionError_TEXT,
           ListKey_TEXT,
           Worker_ID,
           JobStart_DTTM,
           JobEnd_DTTM,
           ProcessedRecordCount_QNTY)
   VALUES (@As_Process_NAME,-- Process_NAME
           @As_Procedure_NAME,-- Procedure_NAME
           @Ac_Job_ID,-- Job_ID
           ISNULL (@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),--EffectiveRun_DATE
           @Ld_Create_DTTM,-- Create_DTTM
           @Ac_Status_CODE,-- Status_CODE
           ISNULL (@As_CursorLocation_TEXT, @Lc_Space_TEXT),-- CursorLocation_TEXT
           ISNULL (@As_ExecLocation_TEXT, @Lc_Space_TEXT),-- ExecLocation_TEXT
           ISNULL (@As_DescriptionError_TEXT, @Lc_Space_TEXT),-- DescriptionError_TEXT
           ISNULL (@As_ListKey_TEXT, @Lc_Space_TEXT),-- ListKey_TEXT
           @Ac_Worker_ID,-- Worker_ID
           @Ad_Start_DATE,-- JobStart_DTTM
           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),-- JobEnd_DTTM
           @An_ProcessedRecordCount_QNTY); -- ProcessedRecordCount_QNTY
           
	       SET @Ls_Sql_TEXT = 'UPDATE IN JRTL_Y1';
		   SET @Ls_Sqldata_TEXT = 'Thread_NUMB = ' + ISNULL (CAST (@An_Thread_NUMB AS VARCHAR), '') + ', ThreadProcess_CODE = ' + ISNULL (@Lc_ThreadProcessLocked_CODE, '') + ', Job_ID = ' + ISNULL (@Ac_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR ), '') ;
		   
		   UPDATE JRTL_Y1
              SET RestartKey_TEXT = 
					  CASE @As_RestartKey_TEXT
					  WHEN '' THEN RestartKey_TEXT
					  ELSE @As_RestartKey_TEXT
					  END ,
				  RecRestart_NUMB = 
					  CASE @An_RecRestart_NUMB
					  WHEN 0 THEN RecRestart_NUMB
					  ELSE @An_RecRestart_NUMB
					  END , 
				  ThreadProcess_CODE = 
					  CASE @Ac_ThreadProcess_CODE
					  WHEN '' THEN ThreadProcess_CODE
					  ELSE @Ac_ThreadProcess_CODE
					  END 
             WHERE  Thread_NUMB = @An_Thread_NUMB
                  AND ThreadProcess_CODE = @Lc_ThreadProcessLocked_CODE
                  AND Job_ID = @Ac_Job_ID
                  AND Run_DATE = @Ad_Run_DATE;
                  
  END TRY
  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
    
    RAISERROR (@As_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
