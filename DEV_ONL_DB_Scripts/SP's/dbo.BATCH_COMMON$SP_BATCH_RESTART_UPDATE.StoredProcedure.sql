/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_BATCH_RESTART_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_BATCH_RESTART_UPDATE
Programmer Name		: IMP Team
Description			: This procedure is used to insert / update restart key value in RSTL_Y1 table using input job ID
					  and Run date.
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_BATCH_RESTART_UPDATE]
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @As_RestartKey_TEXT       VARCHAR(200),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_One_NUMB            NUMERIC(1) = 1,
          @Lc_StatusFailedF_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccessS_CODE CHAR(1) = 'S',
          @Ls_Routine_TEXT        VARCHAR(100) = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE',
          @Lb_RecExist_BIT        BIT = 1;
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Rec_QNTY              NUMERIC(1),
          @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Li_Rowcount_QNTY         SMALLINT,
          @Ls_Sql_TEXT              VARCHAR(50),
          @Ls_Sqldata_TEXT          VARCHAR(200),
          @Ls_ErrorMessage_TEXT		VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'INSERT RSTL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

   SELECT @Ln_Rec_QNTY = 1
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Ac_Job_ID
      AND r.Run_DATE = @Ad_Run_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Lb_RecExist_BIT = @Ln_Zero_NUMB;
    END

   IF @Lb_RecExist_BIT = @Ln_One_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE RSTL_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');
     
     UPDATE RSTL_Y1
        SET RestartKey_TEXT = @As_RestartKey_TEXT
      WHERE RSTL_Y1.Job_ID = @Ac_Job_ID
        AND RSTL_Y1.Run_DATE = @Ad_Run_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY != @Ln_One_NUMB
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'ERROR WHILE UPDATING RESTART KEY';

       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT RSTL_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(@As_RestartKey_TEXT,'');
     
     INSERT RSTL_Y1
            (Job_ID,
             Run_DATE,
             RestartKey_TEXT)
     VALUES (@Ac_Job_ID,-- Job_ID
             @Ad_Run_DATE,-- Run_DATE
             @As_RestartKey_TEXT); -- RestartKey_TEXT
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY != @Ln_One_NUMB
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'ERROR WHILE INSERTING RESTART KEY';

       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;
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
