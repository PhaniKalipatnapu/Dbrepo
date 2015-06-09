/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_PRIMARY_EMP_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_CP_PRIMARY_EMP_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Employer Primary address details from AHIS_Y1
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_PRIMARY_EMP_DETAILS](
 @An_CpMemberMci_IDNO      NUMERIC(10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Routine_TEXT       VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CP_PRIMARY_EMP_DETAILS';
  DECLARE @Ln_OtherParty_IDNO      NUMERIC(10),
          @Li_Error_NUMB           INT,
          @Li_ErrorLine_NUMB       INT,
          @Ls_Sql_TEXT             VARCHAR(200),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Ls_Err_Description_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_CpMemberMci_IDNO AS VARCHAR), 0);

   IF (@An_CpMemberMci_IDNO <> 0
       AND @An_CpMemberMci_IDNO IS NOT NULL)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST (@An_CpMemberMci_IDNO AS VARCHAR(10)), '0');

     EXECUTE BATCH_GEN_NOTICES$SP_GET_PRIMARY_EMP_DETAILS
      @An_MemberMci_IDNO        = @An_CpMemberMci_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;

     IF (@Ln_OtherParty_IDNO <> 0
         AND @Ln_OtherParty_IDNO IS NOT NULL)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
       SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), 0);

       EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
        @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
        @As_Prefix_TEXT           = 'CP_PRIMARY_EMP',
        @Ac_Msg_CODE              = @Ac_Msg_CODE,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
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
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
