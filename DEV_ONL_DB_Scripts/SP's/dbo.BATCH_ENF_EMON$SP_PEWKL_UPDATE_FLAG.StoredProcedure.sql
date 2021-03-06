/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PEWKL_UPDATE_FLAG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_EMON$SP_PEWKL_UPDATE_FLAG
Programmer Name :	IMP Team
Description		:	This process updates the income withholding type on VSORD table
Frequency		: 
Developed On	:	01/05/2012
Called By		:	None
Called On       : 
--------------------------------------------------------------------------------------------------------------------
Modified By		:
Modified On		:
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PEWKL_UPDATE_FLAG]
 @An_RecordRowNumber_NUMB  NUMERIC(15),
 @Ac_Process_INDC          CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_EmonWeeklyCount_NUMB NUMERIC;
  DECLARE @Lc_Success_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE CHAR(1) = 'F',
          @Ls_Routine_TEXT      VARCHAR(75) = 'BATCH_ENF_EMON$SP_PEWKL_UPDATE_FLAG';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Space_TEXT            CHAR(1) = '',
          @Ls_Sql_TEXT              VARCHAR(50),
          @Ls_SqlData_TEXT          VARCHAR(400),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   IF LTRIM(RTRIM(@Ac_Process_INDC)) = ''
    BEGIN
     SET @Ac_Process_INDC = NULL;
    END

   SET @Ls_Sql_TEXT = 'UPDATE PEWKL';
   SET @Ls_SqlData_TEXT = 'RecordRowNumber_NUMB = ' + ISNULL (CAST (@An_RecordRowNumber_NUMB AS VARCHAR (15)), '') + ', Process_INDC = ' + ISNULL (CAST (@Ac_Process_INDC AS VARCHAR (2)), '');

   UPDATE PEWKL_Y1
      SET Process_INDC = ISNULL(@Ac_Process_INDC, Process_INDC)
    WHERE RecordRowNumber_NUMB = @An_RecordRowNumber_NUMB;

   SET @Ln_EmonWeeklyCount_NUMB = @@ROWCOUNT;

   IF @Ln_EmonWeeklyCount_NUMB = 0
    BEGIN
     SET @As_DescriptionError_TEXT = 'UPDATE PEWKL FAILED 1';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END


GO
