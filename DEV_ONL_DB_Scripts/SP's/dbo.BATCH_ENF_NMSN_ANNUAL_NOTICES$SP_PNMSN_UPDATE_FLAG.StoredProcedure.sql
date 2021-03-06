/****** Object:  StoredProcedure [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG
Programmer Name	:	IMP Team.
Description		:	This procedure  is used to update the ind_process column in pnmsn table
Frequency		:	
Developed On	:	4/4/2011
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG]
 @An_Seq_IDNO              NUMERIC(19),
 @Ac_Process_INDC          CHAR(1),
 @Ac_Msg_CODE              CHAR(3) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  DECLARE @Lc_SuccessStatus_CODE CHAR(1) = 'S',
          @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_FailedStatus_CODE  CHAR(1) = 'F',
          @Lc_Msg_CODE           CHAR(3),
          @Ls_ErrorDesc_TEXT     VARCHAR(4000),
          @Ln_Error_NUMB         INT,
          @Ln_ErrorLine_NUMB     INT,
          @Ls_ErrorMessage_TEXT  VARCHAR(4000)

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL
   SET @As_DescriptionError_TEXT = NULL

   DECLARE @Ls_Sql_TEXT     VARCHAR(100),
           @Ls_Sqldata_TEXT VARCHAR(1000),
           @Ls_Process_NAME VARCHAR(60) = 'BATCH_ENF_NMSN_ANNUAL_NOTICES$SP_PNMSN_UPDATE_FLAG'

   SET @Ls_Sql_TEXT = 'UPDATE PNMSN'
   SET @Ls_Sqldata_TEXT = 'RecordRowNumber_NUMB := ' + ISNULL(CAST(@An_Seq_IDNO AS NVARCHAR(15)), '') + 'RestartKey_TEXT :=' + ' AS_IND_PROCESS:= ' + ISNULL(@Ac_Process_INDC, '')

   UPDATE PNMSN_Y1
      SET Process_INDC = ISNULL(@Ac_Process_INDC, Process_INDC)
    WHERE Seq_IDNO = @An_Seq_IDNO

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ls_ErrorDesc_TEXT = 'UPDATE PNMSN FAILED 1'

     RAISERROR(50001,16,1)
    END

   SET @Ac_Msg_CODE = @Lc_SuccessStatus_CODE
  END TRY

  BEGIN CATCH
   IF ERROR_NUMBER() = 50001
    BEGIN
     SET @Ln_Error_NUMB = ERROR_NUMBER();
     SET @Ln_ErrorLine_NUMB = ERROR_LINE();
     SET @Ls_ErrorMessage_TEXT = @Ls_ErrorDesc_TEXT;

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Process_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     SET @Ac_Msg_CODE = @Lc_FailedStatus_CODE
    END
   ELSE
    BEGIN
     SET @Ln_Error_NUMB = ERROR_NUMBER();
     SET @Ln_ErrorLine_NUMB = ERROR_LINE();
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Process_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     SET @Ac_Msg_CODE = @Lc_FailedStatus_CODE
    END
  END CATCH
 END


GO
