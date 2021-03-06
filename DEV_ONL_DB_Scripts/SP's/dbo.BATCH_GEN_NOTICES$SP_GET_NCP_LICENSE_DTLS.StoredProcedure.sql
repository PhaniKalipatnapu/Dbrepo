/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_LICENSE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 /*
------------------------------------------------------------------------------------------------------------------------------
Procedure Name     : BATCH_GEN_NOTICES$SP_GET_NCP_LICENSE_DTLS
Programmer Name    : IMP Team
Description        : The procedure is used to obtain the Non custodial parent license details.
Frequency          : 
Developed On       : 01/20/2011
Called BY          : None
Called On          :
-------------------------------------------------------------------------------------------------------------------------------
Modified BY        :
Modified On        :
Version No         : 1.0
--------------------------------------------------------------------------------------------------------------------------------
*/
 
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_LICENSE_DTLS] (
   @An_Case_IDNO                      NUMERIC (6),
   @An_OtherParty_IDNO				  NUMERIC(10),
   @Ad_Run_DATE						  DATE,
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT
   )
AS
   BEGIN
      SET  NOCOUNT ON;
      DECLARE
         @Lc_StatusFailed_CODE CHAR (1)  = 'F',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Ls_Procedure_NAME VARCHAR (100)= 'BATCH_GEN_NOTICES$SP_GET_NCP_LICENSE_DTLS',
         @Ls_DescriptionError_TEXT VARCHAR (4000) = '';

      DECLARE
         @Ln_OthpLic_NUMB NUMERIC (10),
         @Ln_Error_NUMB NUMERIC (11),
         @Ln_ErrorLine_NUMB NUMERIC (11),
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (400);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;

         IF (@An_Case_IDNO IS NOT NULL)
            BEGIN
               
               IF ( EXISTS(SELECT 1 FROM DEMO_Y1 d
                           WHERE d.MemberMci_IDNO = @An_OtherParty_IDNO))
                  BEGIN
                     SET @Ln_OthpLic_NUMB = 0;

                     SELECT @Ln_OthpLic_NUMB = p.OthpLicAgent_IDNO
                       FROM PLIC_Y1 p
                      WHERE p.MemberMci_IDNO = @An_OtherParty_IDNO
                            AND @Ad_Run_DATE BETWEEN p.IssueLicense_DATE
                                                 AND p.ExpireLicense_DATE
                            AND p.Status_CODE = 'CG'
                            AND p.LicenseStatus_CODE != 'I'
                            AND p.TypeLicense_CODE = 'DR'
                            AND p.IssueLicense_DATE =
                                   (SELECT TOP 1 MAX (p1.IssueLicense_DATE)
                                      FROM PLIC_Y1 p1
                                     WHERE p1.MemberMci_IDNO =
                                              @An_OtherParty_IDNO
                                           AND @Ad_Run_DATE BETWEEN p1.IssueLicense_DATE
                                                                AND p1.ExpireLicense_DATE
                                           AND p1.Status_CODE = 'CG'
                                           AND p1.LicenseStatus_CODE != 'I'
                                           AND p1.TypeLicense_CODE = 'DR');
                  END;
                ELSE
				  BEGIN
					SET @Ln_OthpLic_NUMB = @An_OtherParty_IDNO
				  END

               IF (@Ln_OthpLic_NUMB IS NOT NULL AND @Ln_OthpLic_NUMB <> 0)
                  BEGIN
                     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
					 SET @Ls_Sqldata_TEXT =
                            ' OtherParty_IDNO = ' + ISNULL (CAST (@Ln_OthpLic_NUMB AS VARCHAR), '');

                     EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS @An_OtherParty_IDNO = @Ln_OthpLic_NUMB,
                                                               @As_Prefix_TEXT = 'othp',
                                                               @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,
                                                               @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

                     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
                        BEGIN
                           RAISERROR (50001, 16, 1);
                        END;
                  END;
            END;

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
                @Ln_Error_NUMB = ERROR_NUMBER (),
                @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF (ERROR_NUMBER () <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =  SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;
         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END;

GO
