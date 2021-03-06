/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_DEMO2_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_DEMO2_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_DEMO2_DTLS](
 @An_Case_IDNO             NUMERIC(6),
 @An_MotherMci_IDNO        NUMERIC(10),
 @An_FatherMci_IDNO        NUMERIC(10),
 @An_CaretakerMci_IDNO     NUMERIC(10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  BEGIN TRY
   DECLARE @Lc_StatusFailed_CODE  CHAR (1) = 'F',
           @Lc_StatusSuccess_CODE CHAR (1) = 'S',
           @Ls_Procedure_NAME     VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_DEMO2_DTLS';
   DECLARE @Ls_Sql_TEXT              VARCHAR(200) = '',
           @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT VARCHAR(4000);

   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS';
   SET @Ls_Sqldata_TEXT = 'MotherMCI_IDNO = ' + ISNULL(CAST(@An_MotherMci_IDNO AS VARCHAR), '');

   EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS
    @An_MemberMci_IDNO        = @An_MotherMci_IDNO,
    @An_Case_IDNO             = @An_Case_IDNO,
    @Ac_Parent_INDC           = 'M',
    @Ac_Msg_CODE              = @Ac_Msg_CODE,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

   IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
    BEGIN
      RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS';
   SET @Ls_Sqldata_TEXT = 'FatherMCI_IDNO = ' + ISNULL(CAST(@An_FatherMci_IDNO AS VARCHAR), '');

   EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS
    @An_MemberMci_IDNO        = @An_FatherMci_IDNO,
    @An_Case_IDNO             = @An_Case_IDNO,
    @Ac_Parent_INDC           = 'F',
    @Ac_Msg_CODE              = @Ac_Msg_CODE,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

   IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS';
   SET @Ls_Sqldata_TEXT = 'MotherMCI_IDNO = ' + ISNULL(CAST(@An_CaretakerMci_IDNO AS VARCHAR), '');

   EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS
    @An_MemberMci_IDNO        = @An_CaretakerMci_IDNO,
    @An_Case_IDNO             = @An_Case_IDNO,
    @Ac_Parent_INDC           = 'G',
    @Ac_Msg_CODE              = @Ac_Msg_CODE,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

   IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
    BEGIN
      RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
