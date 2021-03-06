/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_DR_LIC_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 /*
 ------------------------------------------------------------------------------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICES$SP_GET_NCP_DR_LIC_DTLS
 Programmer Name    : IMP Team
 Description        : The procedure is used to obtain the Ncp driver license details.
 Frequency          : 
 Developed On       : 01/20/2011
 Called BY          : None
 Called On          :
 -------------------------------------------------------------------------------------------------------------------------------
 Modified BY        :
 Modified On        :
 Version No         : 1.0
 --------------------------------------------------------------------------------------------------------------------------------
 */
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_DR_LIC_DTLS](
 @An_NcpMemberMci_IDNO     NUMERIC(10 ),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Ls_PrefixDr_TEXT         VARCHAR(70) = 'NCP',
          @Ls_Procedure_NAME        VARCHAR(75) = 'BATCH_GEN_NOTICES$SP_GET_NCP_DR_LIC_DTLS';
          
  DECLARE @Ln_Error_NUMB     NUMERIC(11),
          @Ln_ErrorLine_NUMB NUMERIC(11),
          @Ls_Sql_TEXT       VARCHAR(100),
          @Ls_Sqldata_TEXT   VARCHAR(200),
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS ';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO =	' + ISNULL(CAST(@An_NcpMemberMci_IDNO AS VARCHAR(10)), '');

   IF (@An_NcpMemberMci_IDNO IS NOT NULL
       AND @An_NcpMemberMci_IDNO > 0)
    BEGIN
     EXECUTE BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS
      @An_MemberMci_IDNO        = @An_NcpMemberMci_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Ls_PrefixDr_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF ERROR_NUMBER () <> 50001
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
