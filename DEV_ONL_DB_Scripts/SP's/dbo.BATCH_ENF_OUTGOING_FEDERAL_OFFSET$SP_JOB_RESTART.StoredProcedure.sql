/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART is 
					  to restart the job
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART] (
 @As_RestartKey_TEXT       VARCHAR(200),
 @Ac_Job_ID                CHAR(7) OUTPUT,
 @Ad_Run_DATE              DATE OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE CHAR(1) = 'F',
          @Ls_Procedure_NAME    VARCHAR(100) = 'SP_JOB_RESTART';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', RestartKey_TEXT = ' + ISNULL(@As_RestartKey_TEXT, '');

   EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
    @Ac_Job_ID                = @Ac_Job_ID,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @As_RestartKey_TEXT       = @As_RestartKey_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Errormessage_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE FAILED';

     RAISERROR(50001,16,1);
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Errormessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
