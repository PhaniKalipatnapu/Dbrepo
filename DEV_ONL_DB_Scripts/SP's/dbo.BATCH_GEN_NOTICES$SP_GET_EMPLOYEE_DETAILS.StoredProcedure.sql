/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_EMPLOYEE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_EMPLOYEE_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get employee details from DEMO_Y1
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_EMPLOYEE_DETAILS]
 @Ac_Reference_ID          CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR = 'F',
          @Lc_StatusSuccess_CODE CHAR = 'S',
          @Lc_Prefix_TEXT        CHAR(8) = 'EMPLOYEE';
  DECLARE @Ln_MemberMci_IDNO        NUMERIC(10),
          @Ls_Routine_TEXT          VARCHAR(100),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICES$SP_GET_EMPLOYEE_DETAILS';

   IF @Ac_Reference_ID IS NOT NULL
      AND @Ac_Reference_ID <> ''
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_EMPLOYEE_MEMBER_DETAILS';
     SET @Ls_Sqldata_TEXT = 'Employee Details Not Found = ' + ' ' + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR);

     EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS
      @An_MemberMci_IDNO        = @Ac_Reference_ID,
      @As_Prefix_TEXT           = @Lc_Prefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
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
