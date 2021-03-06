/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_EMPLOYER_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICES$SP_GET_CP_EMPLOYER_DTLS
 Programmer Name    : IMP Team
 Description        : This procedure is used to get NCP employer Address details from Demo
 Frequency          :
 Developed On       : 02-08-2011
 Called By          : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On          : BATCH_GEN_NOTICES$SP_GET_EHIS_DETAILS, BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
---------------------------------------------------------
 Modified By        :
 Modified On        :
 Version No         : 1.0 
---------------------------------------------------------
*/ 
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_EMPLOYER_DTLS] (
 @An_CpMemberMci_IDNO      NUMERIC (10),
 @An_OtherParty_IDNO       NUMERIC (10),
 @Ac_Job_ID                CHAR (7),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB         SMALLINT = 0,
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_Yes_TEXT           CHAR (1) = 'Y',
          @Lc_PrefixCP_TEXT      CHAR (2) = 'CP',
          @Lc_PrefixCPEmp_TEXT   CHAR (6) = 'CP_EMP',
          @Lc_CPROJob_ID         CHAR (7) = 'CPRO',
          @Ls_Sql_TEXT              VARCHAR (200) = 'SELECT EHIS_Y1',
          @Ls_SqlData_TEXT          VARCHAR (400) = 'Case_IDNO=' + ISNULL (CAST (@An_CpMemberMci_IDNO AS VARCHAR (10)), '') + 'OtherParty_IDNO = ' + CAST (@An_OtherParty_IDNO AS VARCHAR (10));
  DECLARE @Ls_DescriptionError_TEXT VARCHAR (4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@Ac_Job_ID = @Lc_CPROJob_ID)
    BEGIN
     SET @An_OtherParty_IDNO = @Li_Zero_Numb;

     IF @An_CpMemberMci_IDNO != @Li_Zero_Numb
        AND @An_CpMemberMci_IDNO IS NOT NULL
      BEGIN
       SELECT TOP 1 @An_OtherParty_IDNO = e.OthpPartyEmpl_IDNO
         FROM EHIS_Y1 e
        WHERE e.MemberMci_IDNO = @An_CpMemberMci_IDNO
          AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
          AND e.Status_CODE = @Lc_Yes_TEXT
          AND e.BeginEmployment_DATE = (SELECT MAX (e.BeginEmployment_DATE)
                                          FROM EHIS_Y1 e
                                         WHERE e.MemberMci_IDNO = @An_CpMemberMci_IDNO
                                           AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
                                           AND e.Status_CODE = @Lc_Yes_TEXT);
      END
    END

   IF ((@An_OtherParty_IDNO IS NOT NULL)
       AND @An_OtherParty_IDNO > 0
       AND (@An_CpMemberMci_IDNO IS NOT NULL)
       AND @An_CpMemberMci_IDNO > 0)
    BEGIN
     EXECUTE BATCH_GEN_NOTICES$SP_GET_EHIS_DETAILS
      @An_MemberMci_IDNO        = @An_CpMemberMci_IDNO,
      @An_OtherParty_IDNO       = @An_OtherParty_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Lc_PrefixCP_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);

       RETURN;
      END

     EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @An_OtherParty_IDNO,
      @As_Prefix_TEXT           = @Lc_PrefixCPEmp_TEXT,
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
