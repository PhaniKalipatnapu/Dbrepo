/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
Programmer Name		: IMP Team
Description			: This procedure is used to check the predecessor job has been executed.
					  This check is for post jobs which has a depencency on predecessor job
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK]
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccessS_CODE CHAR(1) = 'S',
          @Lc_StatusFailedF_CODE  CHAR(1) = 'F',
          @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ln_ParmSnt_NUMB          NUMERIC = 0,
          @Ln_Rowcount_QNTY         NUMERIC = 0,
          @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ln_ParmSnt_NUMB = 1
     FROM PARM_Y1 a
    WHERE a.Job_ID = @Ac_Job_ID
      AND a.Run_DATE = @Ad_Run_DATE
      AND a.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PREDECESSOR JOB IS NOT EXECUTED';

     RAISERROR (50001,16,1);
    END
   ELSE IF @Ln_Rowcount_QNTY = 1
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'MULTIPLE RECORD(s) FOUND';

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
