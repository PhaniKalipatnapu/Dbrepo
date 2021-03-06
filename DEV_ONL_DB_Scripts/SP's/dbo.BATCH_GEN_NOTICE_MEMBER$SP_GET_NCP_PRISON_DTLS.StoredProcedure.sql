/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_PRISON_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_PRISON_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Ncp Prison details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_PRISON_DTLS] (
   @An_NcpMemberMci_IDNO              NUMERIC (10),
   @Ad_Run_DATE                       DATE  ,
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS

   BEGIN
      SET  NOCOUNT ON;

      DECLARE
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Ls_Prefix_TEXT VARCHAR (100) = 'NCP_INCARCERATED_PRISON',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_PRISON_DTLS',
         @Ld_High_DATE      DATE = '12/31/9999';

      DECLARE
         @Ln_OthpInst_IDNO NUMERIC (9),
         @Ln_Error_NUMB NUMERIC (11),
         @Ln_ErrorLine_NUMB NUMERIC (11),
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (400),
         @Ls_DescriptionError_TEXT VARCHAR (4000);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;


         IF (@An_NcpMemberMci_IDNO IS NOT NULL AND @An_NcpMemberMci_IDNO <> 0)
            BEGIN
               SELECT @Ln_OthpInst_IDNO = MD.Institution_IDNO
                    FROM MDET_Y1 MD
                    WHERE MD.MemberMci_IDNO = @An_NcpMemberMci_IDNO
                          AND MD.EndValidity_DATE =@Ld_High_DATE 
                          AND @Ad_Run_DATE BETWEEN MD.Incarceration_DATE AND MD.Release_DATE;
            END

         IF (@Ln_OthpInst_IDNO <> 0 AND @Ln_OthpInst_IDNO IS NOT NULL)
            BEGIN
               EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS @An_OtherParty_IDNO   = @Ln_OthpInst_IDNO,
                                                         @As_Prefix_TEXT       = @Ls_Prefix_TEXT,
                                                         @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,
                                                         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT ;

               IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
                  BEGIN
                     RAISERROR (@Lc_StatusFailed_CODE, 16, 1);
                  END
            END

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         SET @Ln_Error_NUMB = ERROR_NUMBER ();
         SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Ln_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END

GO
