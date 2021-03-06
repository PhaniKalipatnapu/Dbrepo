/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_DAILY_PARM_DATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_DAILY_PARM_DATE
Programmer Name		: IMP Team
Description			: This procedure is used to update run date for 'DAILY' job in PARM_Y1 table.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_DAILY_PARM_DATE]
 @An_UpdateFlag_NUMB SMALLINT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_JobFreqDaily_ID        CHAR(5) = 'DAILY',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB0001',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_COMMON',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_UPDATE_DAILY_PARM_DATE',
          @Ld_High_DATE              DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_RowCount_QNTY         NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '',
          @Ld_DailyDateUdate_DATE   DATE,
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_JobFreqDaily_ID + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

   IF @An_UpdateFlag_NUMB = 1
    BEGIN
     --This will set the system date for daily run date.
     SET @Ld_DailyDateUdate_DATE = CAST (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS DATE);
    END
   ELSE IF @An_UpdateFlag_NUMB = 2
    BEGIN
     --This will set the last day of current month for daily run date.
     SET @Ld_DailyDateUdate_DATE = DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, (SELECT Run_DATE
                                                                                FROM PARM_Y1
                                                                               WHERE Job_ID = @Lc_JobFreqDaily_ID
                                                                                 AND EndValidity_DATE = @Ld_High_DATE)) + 1, 0));
    END
	ELSE IF @An_UpdateFlag_NUMB = 3
    BEGIN
     --This will set run date to current run date plus one day.
     SET @Ld_DailyDateUdate_DATE = DATEADD(d, 1, (SELECT Run_DATE
                                                    FROM PARM_Y1
                                                   WHERE Job_ID = @Lc_JobFreqDaily_ID
                                                     AND EndValidity_DATE = @Ld_High_DATE));
    END

   UPDATE PARM_Y1
      SET Run_DATE = @Ld_DailyDateUdate_DATE
    WHERE Job_ID = @Lc_JobFreqDaily_ID
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'DAILY JOB UPDATE FAILED';

     RAISERROR (50001,16,1);
    END
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Start_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_RowCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
