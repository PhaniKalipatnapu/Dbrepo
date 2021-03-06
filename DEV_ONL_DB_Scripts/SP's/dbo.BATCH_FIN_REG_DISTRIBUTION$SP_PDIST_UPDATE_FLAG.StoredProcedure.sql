/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG
Programmer Name 	: IMP Team
Description			: This procedure is used to update Process_CODE in PDIST_Y1
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG]
 @An_RecordRow_NUMB        NUMERIC (15),
 @Ac_Process_INDC          CHAR(1),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE  CHAR (1) = 'S',
           @Lc_StatusFailed_CODE   CHAR (1) = 'F',
           @Ls_Procedure_NAME      VARCHAR (100) = 'SP_PDIST_UPDATE_FLAG';
  DECLARE  @Ln_Error_NUMB         NUMERIC (11),
           @Ln_ErrorLine_NUMB     NUMERIC (11),
           @Li_Rowcount_QNTY      SMALLINT,
           @Ls_Sql_TEXT           VARCHAR (100),
           @Ls_Sqldata_TEXT       VARCHAR (1000),
           @Ls_ErrorMessage_TEXT  VARCHAR (4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'UPDATE PDIST_Y1';
   SET @Ls_Sqldata_TEXT = 'RecordRowNumber_NUMB = ' + ISNULL(CAST( @An_RecordRow_NUMB AS VARCHAR ),'');

   UPDATE PDIST_Y1
      SET Process_CODE = ISNULL (@Ac_Process_INDC, Process_CODE)
    WHERE RecordRowNumber_NUMB = @An_RecordRow_NUMB;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE PDIST_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

    IF @Ln_Error_NUMB <> 50001
     BEGIN
      SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
     END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH
 END


GO
