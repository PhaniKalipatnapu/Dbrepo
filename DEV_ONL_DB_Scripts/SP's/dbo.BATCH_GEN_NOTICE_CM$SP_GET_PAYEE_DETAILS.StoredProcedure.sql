/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_PAYEE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_PAYEE_DETAILS
Programmer Name	:	IMP Team.
Description		:	Get the Payee detail for notice generation
Frequency		:	
Developed On	:	4/27/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_PAYEE_DETAILS] (
 @Ac_Recipient_CODE		   VARCHAR(4),
 @Ac_Recipient_ID		   VARCHAR(10),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Error_NUMB            INT = NULL,
          @Li_ErrorLine_NUMB        INT = NULL,
          @Lc_StatusSuccess_CODE    CHAR (1) = 'S',
          @Lc_StatusFailed_CODE     CHAR (1) = 'F',
          @Ls_Procedure_NAME        VARCHAR (100) = 'BATCH_GEN_NOTICE_CM$SP_GET_PAYEE_DETAILS',
          @Ld_Run_DATE              DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ls_Sql_TEXT              VARCHAR (200) = '',
          @Ls_Sqldata_TEXT          VARCHAR (400) = '',
          @Ls_DescriptionError_TEXT VARCHAR (4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
     IF (@Ac_Recipient_ID IS NOT NULL
       AND @Ac_Recipient_ID != '')
    BEGIN
     EXEC BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS
      @Ac_Recipient_CODE        = @Ac_Recipient_CODE, 
      @Ac_Recipient_ID          = @Ac_Recipient_ID, 
      @Ac_TypeAddress_CODE      = '',
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Ac_Msg_CODE,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

     IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
