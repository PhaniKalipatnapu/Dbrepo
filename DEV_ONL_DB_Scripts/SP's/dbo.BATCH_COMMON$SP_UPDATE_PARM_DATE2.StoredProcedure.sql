/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_PARM_DATE2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_PARM_DATE2
Programmer Name		: IMP Team
Description			: This procedure is used to update the PARM_Y1 table to specify that the batch process has been
					  executed for the given effective date
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_PARM_DATE2]
 @Ac_Job_ID   CHAR(7),
 @Ad_Run_DATE DATE
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Msg_CODE               CHAR(5) = ' ',
          @Lc_Job_ID                 CHAR(7) = 'DEB0002',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_COMMON',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_UPDATE_PARM_DATE2';
  DECLARE @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '',
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Ac_Job_ID,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END;

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
 END;


GO
