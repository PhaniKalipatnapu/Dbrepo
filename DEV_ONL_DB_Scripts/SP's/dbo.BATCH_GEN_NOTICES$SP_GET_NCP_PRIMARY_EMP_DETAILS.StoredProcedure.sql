/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_PRIMARY_EMP_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_PRIMARY_EMP_DETAILS] (
 @An_MemberMci_IDNO     NUMERIC (10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
  /*
  --------------------------------------------------------------------------------------------------------------------
  Procedure Name    : BATCH_GEN_NOTICES$SP_GET_NCP_PRIMARY_EMP_DETAILS
  Programmer Name   : IMP Team
  Description       : This procedure is used to get Employer Primary address details from EHIS_Y1
  Frequency         :
  Developed On      : 01/20/2011
  Called By         : BATCH_COMMON$SP_FORMAT_BUILD_XML
  Called On         :
  --------------------------------------------------------------------------------------------------------------------
  Modified By       :
  Modified On       :
  Version No        : 1.0
  --------------------------------------------------------------------------------------------------------------------
  */

  BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_StatusSuccess_CODE    CHAR (1) = 'S',
          @Lc_StatusFailed_CODE     CHAR (1) = 'F',
          @Ls_Procedure_NAME        VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_GET_NCP_PRIMARY_EMP_DETAILS';
          
  DECLARE @Ln_OtherParty_IDNO NUMERIC (9),
          @Ln_Error_NUMB      NUMERIC (11),
          @Ln_ErrorLine_NUMB  NUMERIC (11),
          @Ls_Sql_TEXT        VARCHAR (200),
          @Ls_Sqldata_TEXT    VARCHAR (400),
          @Ls_DescriptionError_TEXT VARCHAR (4000) = ''; 
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@An_MemberMci_IDNO IS NOT NULL
       AND @An_MemberMci_IDNO <> 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR(10)), '0');

     EXECUTE BATCH_GEN_NOTICES$SP_GET_PRIMARY_EMP_DETAILS
      @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;

     IF (@Ln_OtherParty_IDNO <> 0)
      BEGIN
       EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
        @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
        @As_Prefix_TEXT           = 'NCP_PRIMARY_EMP',
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END;
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
