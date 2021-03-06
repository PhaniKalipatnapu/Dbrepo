/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_ADDRESS_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_ADDRESS_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get NCP employer Address details from DEMO_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_ADDRESS_DTLS]
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATETIME2,
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  DECLARE @Lc_StatusFailed_CODE      CHAR,
          @Lc_StatusSuccess_CODE     CHAR,
          @Ls_Yes_TEXT               CHAR = 'Y',
          @Ls_StatusNoDataFound_CODE CHAR = 'N',
          @Ld_High_DATE              DATE = '12-31-9999',
          @Ls_Routine_TEXT           VARCHAR(75),
          @Ls_DoubleSpace_TEXT       VARCHAR(2) = '  ',
          @Ln_OtherParty_IDNO        NUMERIC(9),
          @Ln_MemberMci_IDNO         NUMERIC(10),
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400),
          @Ls_Err_Description_TEXT   VARCHAR(4000);

  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL
   SET @As_DescriptionError_TEXT = NULL
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_DTLS'

   IF @An_Case_IDNO IS NOT NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GETNCPMEMBERFORACTIVECASE'
     SET @Ls_Sqldata_TEXT = 'Case_IDNO=' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '')
     SET @Ln_MemberMci_IDNO = dbo.BATCH_COMMON$SF_GETNCPMEMBERFORACTIVECASE(@An_Case_IDNO)

     IF (@Ln_MemberMci_IDNO) IS NOT NULL
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SF_GET_ACTIVE_EMPLOYER'
       SET @Ls_Sqldata_TEXT = '@Ln_MemberMci_IDNO=' + ISNULL(CAST(@Ln_MemberMci_IDNO AS CHAR), '')
       SET @Ln_OtherParty_IDNO = dbo.BATCH_GEN_NOTICES$SF_GET_ACTIVE_EMPLOYER(@Ln_MemberMci_IDNO, @Ad_Run_DATE)

       IF @Ln_OtherParty_IDNO IS NOT NULL
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1'
         SET @Ls_Sqldata_TEXT = ' OtherParty_IDNO   ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS CHAR), '')

         EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
          @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
          @As_Prefix_TEXT           = 'NCP_EMP',
          @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT

         IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
          RETURN;
        
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
