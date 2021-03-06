/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_DR_LIC_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
---------------------------------------------------------
 Procedure Name    : BATCH_GEN_NOTICES$SP_GET_CP_DR_LIC_DTLS
 Programmer Name   : IMP Team
 Description       : BATCH_GEN_NOTICES$SP_GET_CP_DR_LIC_DTLS
 Frequency         :
 Developed On      : 02-08-2011
 Called By         : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        : 1.0  
---------------------------------------------------------
*/  
 CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_DR_LIC_DTLS](
 @An_CpMemberMci_IDNO      NUMERIC(10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB          SMALLINT = 0,
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_PrefixCP_TEXT      CHAR(2) = 'CP',
          @Ls_Procedure_NAME     VARCHAR(75) = 'BATCH_GEN_NOTICES$SP_GET_CP_DR_LIC_DTLS';
  DECLARE @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_SqlData_TEXT          VARCHAR(200),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS ';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO =	' + ISNULL(CAST(@An_CpMemberMci_IDNO AS VARCHAR(10)), '');

   /* if member ID passed get driver lic. information */
   IF(@An_CpMemberMci_IDNO IS NOT NULL
       OR @An_CpMemberMci_IDNO <> @Li_Zero_NUMB)
    BEGIN
     EXECUTE BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS
      @An_MemberMci_IDNO        = @An_CpMemberMci_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Lc_PrefixCP_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);

       RETURN;
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
