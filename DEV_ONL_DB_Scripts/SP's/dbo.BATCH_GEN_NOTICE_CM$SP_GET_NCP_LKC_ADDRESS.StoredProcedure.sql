/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_NCP_LKC_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------------------------------------------------------------------------
 Procedure Name    :BATCH_GEN_NOTICE_CM$SP_GET_NCP_LKC_ADDRESS
 Programmer Name   : IMP Team
 Description       :This procedure is used to get NCP address details such as line1, line2, city, state, country and zip address.
 Frequency         :
 Developed On      :02-AUG-2011
 Called By         :BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On         :BATCH_GEN_NOTICE_CM$SP_GET_LKC_ADDRESS
-----------------------------------------------------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        :1.0
-------------------------------------------------------------------------------------------------------------
*/  

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_NCP_LKC_ADDRESS] (
 @An_NcpMemberMci_IDNO     NUMERIC (10),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_Run_DATE			   DATE,
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_PrefixNcp_TEXT     CHAR(3) = 'ncp';
  DECLARE @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';
   SET @Ls_SqlData_TEXT ='MemberMci_IDNO = ' + CAST(@An_NcpMemberMci_IDNO AS VARCHAR(10));

   IF @An_MemberMci_IDNO <> 0
       OR @An_MemberMci_IDNO IS NOT NULL
    BEGIN
     SET @An_NcpMemberMci_IDNO = @An_MemberMci_IDNO;
    END
   ELSE
    BEGIN
     SET @An_NcpMemberMci_IDNO = @An_NcpMemberMci_IDNO;
    END

   IF (@An_NcpMemberMci_IDNO IS NOT NULL
       AND @An_NcpMemberMci_IDNO <> 0)
    BEGIN
     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_LKC_ADDRESS
      @An_MemberMci_IDNO        = @An_NcpMemberMci_IDNO,
      @Ad_Run_DATE			    = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Lc_PrefixNcp_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
      BEGIN
       RAISERROR(50001,16,1);
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
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
