/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_EMP_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_EMP_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get NCP EMP Address details from DEMO_Y1
Frequency		:	
Developed On	:	5/10/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_EMP_DTLS] (
 @Ac_Recipient_ID          CHAR(10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_PrefixEMP_TEXT     CHAR(5) = 'EMP',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CP_EMP_DTLS';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF @Ac_Recipient_ID IS NOT NULL
      AND @Ac_Recipient_ID != ''
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Ac_Recipient_ID, '');

     EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @Ac_Recipient_ID,
      @As_Prefix_TEXT           = @Lc_PrefixEMP_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT =SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
