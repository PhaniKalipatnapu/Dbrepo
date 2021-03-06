/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_PERSONAL_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_NCP_PERSONAL_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure fetches NCP personal details
Frequency		:	
Developed On	:	3/16/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_PERSONAL_DETAILS] (
 @An_NcpMemberMci_IDNO     NUMERIC(10),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_Error_NUMB         INT = NULL,
          @Li_ErrorLine_NUMB     INT = NULL,
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Prefix_TEXT        VARCHAR(100) = 'NCP',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_NCP_PERSONAL_DETAILS';
  DECLARE @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF @An_MemberMci_IDNO <> 0
       OR @An_MemberMci_IDNO IS NOT NULL
    BEGIN
     SET @An_NcpMemberMci_IDNO = @An_MemberMci_IDNO;
    END
   ELSE
    BEGIN
     SET @An_NcpMemberMci_IDNO = @An_NcpMemberMci_IDNO;
    END

   IF @An_NcpMemberMci_IDNO IS NOT NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS';
     SET @Ls_Sqldata_TEXT =' MemberMci_IDNO = ' + CAST(ISNULL(@An_NcpMemberMci_IDNO, 0) AS VARCHAR(10));

     EXECUTE BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS
      @An_MemberMci_IDNO        = @An_NcpMemberMci_IDNO,
      @As_Prefix_TEXT           = @Ls_Prefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
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
