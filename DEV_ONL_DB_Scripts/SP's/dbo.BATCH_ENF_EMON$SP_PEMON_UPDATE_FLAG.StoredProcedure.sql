/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PEMON_UPDATE_FLAG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_EMON$SP_PEMON_UPDATE_FLAG

Programmer Name   : IMP Team

Description       : This procedure will update PEMON_Y1 process indicator flag.

Frequency         : WEEKLY

Developed On      : 01/05/2012

Called BY         : None

Called On		  : 
---------------------------------------------------------------------------------------------------------------------
Modified BY       :

Modified On       :

Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PEMON_UPDATE_FLAG](
 @An_RecordRowNumber_NUMB  NUMERIC(15),
 @Ac_Process_INDC          CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_EmonDailyCount_NUMB NUMERIC;
  DECLARE @Lc_StatusSuccess_CODE CHAR(1)= 'S',
          @Lc_StatusFailed_CODE  CHAR(1)= 'F',
          @Lc_Space_TEXT         CHAR(1)= ' ',
          @Ls_Routine_TEXT       VARCHAR(75) = 'BATCH_ENF_EMON$SP_PEMON_UPDATE_FLAG';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PEMON_UPDATE_FLAG : SELECT PEMON_Y1';
   SET @Ls_Sqldata_TEXT = 'RecordRowNumber_NUMB = ' + ISNULL(CAST(@An_RecordRowNumber_NUMB AS VARCHAR(15)), '') + ', Process_INDC = ' + ISNULL (@Ac_Process_INDC, '');

   UPDATE PEMON_Y1
      SET Process_INDC = ISNULL(@Ac_Process_INDC, Process_INDC)
    WHERE PEMON_Y1.RecordRowNumber_NUMB = @An_RecordRowNumber_NUMB;

   SET @Ln_EmonDailyCount_NUMB = @@ROWCOUNT;

   IF @Ln_EmonDailyCount_NUMB = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PEMON_UPDATE_FLAG : SELECT PEMON_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
