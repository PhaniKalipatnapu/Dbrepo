/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_HOUSING_AUTHORITY_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_HOUSING_AUTHORITY_DTLS] (
 @An_Otherparty_IDNO       NUMERIC(10),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 /*
 --------------------------------------------------------------------------------------------------------------------
  Procedure Name      : BATCH_GEN_NOTICES$SP_HOUSING_AUTHORITY_DTLS
  Programmer Name     : IMP Team
  Description         : This procedure is used to get Housing Authority Address details.
  Frequency           :
  Developed On        : 12/23/2011
  Called By           : BATCH_COMMON$SP_FORMAT_BUILD_XML
  Called On           :
 ---------------------------------------------------------
  Modified By         :
  Modified On         :
  Version No          :  1.0
  --------------------------------------------------------------------------------------------------------------------
 */

 BEGIN
  SET NOCOUNT ON;

  DECLARE
  @Lc_StatusFailed_CODE     CHAR (1) = 'F',
  @Lc_StatusSuccess_CODE    CHAR (1) = 'S',
  @Ls_HousingAuthority_TEXT VARCHAR (50) = 'HOUSING_AUTHORITY',
  @Ls_Procedure_NAME        VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_HOUSING_AUTHORITY_DTLS';
  DECLARE @Ls_Sql_TEXT              VARCHAR (200),
          @Ls_Sqldata_TEXT          VARCHAR (400),
          @Ls_DescriptionError_TEXT VARCHAR (4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
   SET @Ls_Sqldata_TEXT = ' OtherParty_IDNO = ' + CAST (@An_Otherparty_IDNO AS VARCHAR (9));

   EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
    @An_OtherParty_IDNO       = @An_Otherparty_IDNO,
    @As_Prefix_TEXT           = @Ls_HousingAuthority_TEXT,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

   RETURN;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

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
