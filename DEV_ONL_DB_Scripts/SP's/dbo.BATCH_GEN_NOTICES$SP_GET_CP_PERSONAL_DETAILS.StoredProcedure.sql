/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_PERSONAL_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_GEN_NOTICES$SP_GET_CP_PERSONAL_DETAILS
Programmer Name		: IMP Team.
Description_TEXT	: This procedure is used to get CP Personal Address details from Demo
Frequency			:
Developed On		: 02-08-2011
Called By			: BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On			: BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS
---------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_PERSONAL_DETAILS](
 @An_CpMemberMci_IDNO	   NUMERIC(10),
 @Ac_Msg_CODE              VARCHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Lc_StatusFailed_CODE			CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
          @Lc_PrefixCP_TEXT				CHAR(2)			= 'cp',
          @Ls_Routine_TEXT				VARCHAR(100)	= 'BATCH_GEN_NOTICES$SP_GET_CP_PERSONAL_DETAILS ';
  DECLARE @Ln_MemberMci_IDNO			NUMERIC(10),
          @Ls_Sql_TEXT					VARCHAR(200)	= '',
          @Ls_SqlData_TEXT				VARCHAR(400)	= '',
		  @Ls_DescriptionError_TEXT		VARCHAR(4000);
  
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
  

   IF (@An_CpMemberMci_IDNO IS NOT NULL AND @An_CpMemberMci_IDNO != 0)
    BEGIN
     SET @Ls_SqlData_TEXT = @Ls_SqlData_TEXT + 'MemberMci_IDNO :' + CAST(@An_CpMemberMci_IDNO AS VARCHAR);

     EXECUTE BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS
      @An_MemberMci_IDNO        = @An_CpMemberMci_IDNO, 
      @As_Prefix_TEXT           = @Lc_PrefixCP_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT

     IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
		 BEGIN
			RAISERROR(50001,16,1);
			RETURN;
		 END
	END
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB					INT = ERROR_NUMBER (),
		   @Li_ErrorLine_NUMB				INT = ERROR_LINE ();
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
