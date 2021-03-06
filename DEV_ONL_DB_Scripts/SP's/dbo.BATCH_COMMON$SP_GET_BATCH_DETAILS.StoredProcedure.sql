/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_BATCH_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_BATCH_DETAILS

Programmer Name		: IMP Team

Description			: This procedure is used to get the run date, last run date , commit freq, exception threshold
					  file name and file location for a given batch process.
					  
Frequency			: 

Developed On		:	04/12/2011

Called By			:

Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_BATCH_DETAILS]
 @Ac_Job_ID                  CHAR(7),
 @Ad_Run_DATE                DATE OUTPUT,
 @Ad_LastRun_DATE            DATE OUTPUT,
 @An_CommitFreq_QNTY         NUMERIC(5) OUTPUT,
 @An_ExceptionThreshold_QNTY NUMERIC(5) OUTPUT,
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccessS_CODE CHAR = 'S',
          @Lc_StatusFailedF_CODE  CHAR = 'F',
          @Lc_JobDaily_ID		  CHAR(7) = 'DAILY',
          @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_COMMON$SP_GET_BATCH_DETAILS',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_JobFreq_CODE          CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_PackageProcedure_NAME VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ad_Run_DATE = '';
   SET @Ad_LastRun_DATE = '';
   SET @An_CommitFreq_QNTY = 0;
   SET @An_ExceptionThreshold_QNTY = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1-1 ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ad_LastRun_DATE = CAST(p.Run_DATE AS DATE),
          @Lc_JobFreq_CODE = p.JobFreq_CODE,
          @An_CommitFreq_QNTY = p.CommitFreq_QNTY,
          @An_ExceptionThreshold_QNTY = p.ExceptionThreshold_QNTY,
          @Ls_PackageProcedure_NAME = ISNULL (p.Process_NAME, '') + '.' + ISNULL (p.Procedure_NAME, '')
     FROM PARM_Y1 p
    WHERE p.Job_ID = @Ac_Job_ID
      AND p.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR = NO DATA FOUND IN PARM_Y1 FOR THE JOB';

     RAISERROR (50001,16,1);
    END
   ELSE IF @Ln_Rowcount_QNTY = 1
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR = TOO MANY ROWS FOUND IN PARM_Y1 FOR THE JOB';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1-2 ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobDaily_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ad_Run_DATE = p.Run_DATE
     FROM PARM_Y1 P
    WHERE p.Job_ID = @Lc_JobDaily_ID
      AND p.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR = NO DATA FOUND IN PARM_Y1 FOR THE JOB';

     RAISERROR (50001,16,1);
    END
   ELSE IF @Ln_Rowcount_QNTY = 1
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR = TOO MANY ROWS FOUND IN PARM_Y1 FOR THE JOB';

     RAISERROR (50001,16,1);
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailedF_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
   
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
