/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE157$SP_PROCESS_MANAGEMENT_OCSE157]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name          : BATCH_RPT_OCSE157$SP_PROCESS_MANAGEMENT_OCSE157
Programmer Name			: IMP Team
Description             : This procedure is used for generating monthly OCSE-157 report
Frequency               : YEARLY
Developed On            : 06/16/2011
Called BY               : None
Called On               : 
--------------------------------------------------------------------------------------------------------------------
Modified BY             :
Modified On             :
Version No              : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE157$SP_PROCESS_MANAGEMENT_OCSE157]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE 
		  
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_Monthly_TEXT            CHAR(1) = 'M',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_TypeReportInitial_CODE  CHAR(1) = 'I',
          @Lc_Msg_CODE                CHAR(1) = NULL,
          @Lc_Job_ID                  CHAR(7) = 'DEB6450',
          @Lc_Successful_TEXT         CHAR(10) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT       CHAR(30) = 'BATCH',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_RPT_OCSE157',
          @Ls_RoutineMonthly_TEXT     VARCHAR(100) = 'SP_PROCESS_MANAGEMENT_OCSE157',
          @Ls_DescriptionError_TEXT   VARCHAR(4000) = NULL;
 DECLARE  
   		  @Ln_CommitFreqParm_QNTY          NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
          @Ln_ErrorLine_NUMB               NUMERIC(11),
          @Li_Error_NUMB                   INT,
          @Ls_Routine_TEXT                 VARCHAR(100),
          @Ls_ErrorMessage_TEXT            VARCHAR(4000),
          @Ls_Sql_TEXT                     VARCHAR(4000),
          @Ls_Sqldata_TEXT                 VARCHAR(4000),
          @Ld_Run_DATE                     DATE,
          @Ld_LastRun_DATE                 DATE,
          @Ld_Start_DATE                   DATETIME2(0);
 DECLARE
 @Lc_Null_TEXT               CHAR(1)= '';
          
  BEGIN TRANSACTION GENERATE_OCSE157;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY  OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY  OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
      BEGIN
         SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
         RAISERROR(50001, 16, 1);
      END;
   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_GENERATE_OCSE157';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ' Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '')+'Frequency_CODE ='+@Lc_Monthly_TEXT+'TypeReport_CODE = '+@Lc_TypeReportInitial_CODE;

   EXECUTE BATCH_RPT_OCSE157$SP_GENERATE_OCSE157
    @Ac_Job_ID          = @Lc_Job_ID,
    @Ad_Run_DATE        = @Ld_Run_DATE,
    @Ac_Frequency_CODE  = @Lc_Monthly_TEXT,
    @Ac_TypeReport_CODE = @Lc_TypeReportInitial_CODE,
    @Ac_Msg_CODE        = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ' Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT ='Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ',Start_DATE = '+CAST(@Ld_Start_DATE AS VARCHAR)+ ' , Job_ID = ' +  @Lc_Job_ID + ' , Process_NAME  = '+ @Ls_Process_NAME + ' ,Procedure_NAME  = ' + ISNULL(@Ls_RoutineMonthly_TEXT,'') + ' , CursorLocation_TEXT = '+ ISNULL(@Lc_Null_TEXT,'') + ' , ExecLocation_TEXT = '+ ISNULL(@Lc_Successful_TEXT,'') + ', ListKey_TEXT = '+ ISNULL(@Lc_Successful_TEXT,'') + ',DescriptionError TEXT = ' +ISNULL(@Lc_Null_TEXT,'')+ ' , Status_CODE  = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID  = '+ ISNULL(@Lc_BatchRunUser_TEXT,'');
  EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_RoutineMonthly_TEXT,
    @As_CursorLocation_TEXT   = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Null_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 1;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION GENERATE_OCSE157;
    END
  END TRY

  BEGIN CATCH
   SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION GENERATE_OCSE157;
    END;
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   
   
   IF @Li_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(),1,200);
    END
    BEGIN
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Routine_TEXT,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Li_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
     @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_RoutineMonthly_TEXT,
    @As_CursorLocation_TEXT   = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

    RAISERROR(@Ls_DescriptionError_TEXT,16,1);
    
  END CATCH;
 END;


GO
