/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_NCP_INSURANCE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name      : BATCH_GEN_NOTICE_EST_ENF$SP_GET_NCP_INSURANCE_DTLS
 Programmer Name     : IMP Team
 Description         : This procedure gets the Ncp's Insurance Details
 Frequency           :
 Developed On        : 02-08-2011
 Called By           : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On           : BATCH_GEN_NOTICE_MEMBER$SP_GET_INSURANCE_DTLS, BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
---------------------------------------------------------
 Modified By         :
 Modified On         :
 Version No          : 1.0 
---------------------------------------------------------
*/ 
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_NCP_INSURANCE_DTLS](
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 --@An_OtherParty_IDNO       NUMERIC(10),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB          SMALLINT = 0,
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_PrefixNcp_TEXT     CHAR(3) = 'NCP',
          @Ls_Sql_TEXT           VARCHAR(200) = 'SELECT MINS_Y1 OTHP_Y1';
  DECLARE @Lc_PrefixSpace_TEXT      CHAR(1) = ' ', 
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ';
  DECLARE @Ln_OthpLic_NUMB          NUMERIC(9),
          @Ls_SqlData_TEXT          VARCHAR(400);
          
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT ='SELECT MINS_Y1 OTHP_Y1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '');

   EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_INSURANCE_DTLS
    @An_Case_IDNO             = @An_Case_IDNO,
    @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
    --@An_OthpSource_IDNO       = @An_OtherParty_IDNO,
    @An_MajorIntSeq_NUMB      = @An_MajorIntSeq_NUMB,
    @As_Prefix_TEXT           = @Lc_PrefixNcp_TEXT,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
    BEGIN
     RAISERROR(@Lc_StatusFailed_CODE,16,1);
     RETURN;
    END

   SET @Ln_OthpLic_NUMB = (SELECT n.Element_Value
                             FROM #NoticeElementsData_P1 n
                            WHERE n.Element_NAME = 'othp_insurance_idno');

   IF (@Ln_OthpLic_NUMB IS NOT NULL
       AND @Ln_OthpLic_NUMB <> @Li_Zero_NUMB)
    BEGIN
     EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @Ln_OthpLic_NUMB,
      @As_Prefix_TEXT           = @Lc_PrefixSpace_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
    BEGIN
     RAISERROR(@Lc_StatusFailed_CODE,16,1);
     RETURN;
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
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
