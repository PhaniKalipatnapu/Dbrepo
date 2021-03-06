/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_PROPERTY_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_GET_PROPERTY_DETAILS
Programmer Name	:	IMP Team.
Description		:	This function is used to fetch the property details
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_PROPERTY_DETAILS] (
 @An_MotherMci_IDNO        NUMERIC(10),
 @An_FatherMci_IDNO        NUMERIC(10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_Error_NUMB         INT = NULL,
          @Li_ErrorLine_NUMB     INT = NULL,
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_GEN_NOTICE_FIN$SP_GET_PROPERTY_DETAILS';
  DECLARE @Ls_Sql_TEXT                    VARCHAR(400) = '',
          @Ls_Sqldata_TEXT                VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000);
          
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS';
   SET @Ls_Sqldata_TEXT = ' MotherMci_IDNO = ' + CAST(ISNULL(@An_MotherMci_IDNO, 0) AS VARCHAR(10));

   EXECUTE BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS
    @An_MemberMci_IDNO        = @An_MotherMci_IDNO,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @As_Prefix_TEXT           = 'MOM',
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_GEN_NOTICE_FIN$SP_MEMBER_PERSONALPROPERTY_DETAILS
    @An_MemberMci_IDNO        = @An_MotherMci_IDNO,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @As_Prefix_TEXT           = 'MOM',
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

   SET @Ls_Sql_TEXT = ' BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS';
   SET @Ls_Sqldata_TEXT = ' FatherMci_IDNO = ' + CAST(ISNULL(@An_FatherMci_IDNO, 0) AS VARCHAR(10));

   EXECUTE BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS
    @An_MemberMci_IDNO        = @An_FatherMci_IDNO,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @As_Prefix_TEXT           = 'FATHER',
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_GEN_NOTICE_FIN$SP_MEMBER_PERSONALPROPERTY_DETAILS
    @An_MemberMci_IDNO        = @An_FatherMci_IDNO,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @As_Prefix_TEXT           = 'FATHER',
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

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
