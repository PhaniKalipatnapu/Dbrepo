/****** Object:  StoredProcedure [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG](
 @An_RecordRowNumber_NUMB  NUMERIC(15, 0),
 @Ac_Process_INDC          CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT)
AS
 /*
 ---------------------------------------------------------
  Procedure Name	: BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG
  Programmer Name	: IMP Team
  Description		: To update PCCLR_Y1 after processing the record.
  Frequency			:
  Developed On		: 04/06/2011
  Called By			: BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_CASE_CLOSURE
  Called On			: None
 ---------------------------------------------------------
  Modified By		:
  Modified On		:
  Version No		: 1.0 
 ---------------------------------------------------------
 */
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Routine_TEXT       VARCHAR(60) = 'BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG';
  DECLARE @Ln_RowCount_NUMB         NUMERIC,
          @Ln_Error_NUMB            NUMERIC(10, 0),
          @Ln_ErrorLine_NUMB        NUMERIC(10, 0),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT PCCLR_Y1';
   SET @Ls_Sqldata_TEXT = 'RecordRowNumber_NUMB  = ' + ISNULL(CAST(@An_RecordRowNumber_NUMB AS VARCHAR(15)), '') + ' , AS_IND_PROCESS = ' + ISNULL(@Ac_Process_INDC, '');

   UPDATE PCCLR_Y1
      SET Process_INDC = ISNULL(@Ac_Process_INDC, PCCLR_Y1.Process_INDC)
    WHERE PCCLR_Y1.RecordRowNumber_NUMB = @An_RecordRowNumber_NUMB;

   SET @Ln_RowCount_NUMB = @@ROWCOUNT;

   IF @Ln_RowCount_NUMB = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'SELECT PCCLR_Y1 FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   --Check for Exception information to log the description text based on the error
   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
