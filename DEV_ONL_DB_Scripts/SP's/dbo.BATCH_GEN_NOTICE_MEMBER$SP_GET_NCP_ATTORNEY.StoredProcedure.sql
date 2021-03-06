/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ATTORNEY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ATTORNEY
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get NCP Attorney details
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	BATCH_COMMON$SF_GETNCPATTORNEY,BATCH_COMMON$SF_GETNCPATTORNEY
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ATTORNEY](
 @An_Case_IDNO				NUMERIC(6),
 @An_MemberMci_IDNO			NUMERIC(10),
 @Ad_Run_DATE				DATE,	
 @Ac_Msg_CODE				CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_NcpAttyPrefix_TEXT  CHAR(8) = 'NCP_ATTY',
           @Ls_Routine_TEXT        VARCHAR(75) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ATTORNEY';
  DECLARE  @Ln_OtherParty_IDNO     NUMERIC(9),
		   @Li_Error_NUMB		   INT,
		   @Li_ErrorLine_NUMB	   INT,
           @Ls_Sql_TEXT             VARCHAR(200),
           @Ls_Sqldata_TEXT         VARCHAR(400),
           @Ls_Err_Description_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF @An_Case_IDNO IS NOT NULL AND @An_Case_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_ATTORNEY_DETAILS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');
     SET @Ln_OtherParty_IDNO = DBO.BATCH_COMMON$SF_GETNCPATTORNEY(@An_Case_IDNO, @An_MemberMci_IDNO, @Ad_Run_DATE);
	
     IF @Ln_OtherParty_IDNO IS NOT NULL
      BEGIN
       EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
						@An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
						@As_Prefix_TEXT           = @Lc_NcpAttyPrefix_TEXT,
						@Ac_Msg_CODE              = @Ac_Msg_CODE,
						@As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

       IF @Ac_Msg_CODE = @LC_StatusFailed_CODE
        BEGIN
			RAISERROR(50001,16,1);
        END
      END
    END
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
		SET @Li_Error_NUMB = ERROR_NUMBER ();
		SET @Li_ErrorLine_NUMB =  ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @As_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
                                                       @As_ErrorMessage_TEXT = @As_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
