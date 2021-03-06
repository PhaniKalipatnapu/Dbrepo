/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get recipient details to insert to NMRQ_Y1 and NRRQ_Y1
Frequency		:	
Developed On	:	5/10/2012
Called By		:	BATCH_GEN_NOTICE_CM$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS] (
   @Ac_Recipient_CODE                 VARCHAR (4),
   @Ac_Recipient_ID                   CHAR (10),
   @Ac_TypeAddress_CODE               CHAR (1),
   @Ad_Run_DATE                       DATE,
   @As_Prefix_TEXT                    VARCHAR (70) = '',
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS

    BEGIN
      SET  NOCOUNT ON;
      DECLARE
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS';

      DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;
      DECLARE
         @Ln_Recipient_IDNO NUMERIC (10),
         @Lc_MailRecipient_CODE CHAR (1) = '',
         @Ls_Sqldata_TEXT VARCHAR (400) = '',
         @Ls_Sql_TEXT VARCHAR (1000) = '',
         @Ls_DescriptionError_TEXT VARCHAR (4000) = '';

      BEGIN TRY
         SELECT @Lc_MailRecipient_CODE =
                   CASE
                      WHEN @Ac_Recipient_CODE IN
                              ('DG',
                               'FC',
                               'FI',
                               'FS',
                               'HA',
                               'JL',
                               'LA',
                               'IC',
                               'NA',
                               'OE',
                               'OT',
                               'PA',
                               'PU',
                               'SI',
                               'SS',
                               'WR',
							   'FR_3')
                      THEN
                         '3'
                      WHEN @Ac_Recipient_CODE IN
                              ('GR', 'MC', 'MN', 'MS', 'NO', 'NP', 'OP', 'PM', 'FR_1')
                      THEN
                         '1'
                      WHEN @Ac_Recipient_CODE IN ('OS', 'FR_2')
                      THEN
                         '2'
                   END;

         IF (@Lc_MailRecipient_CODE IN ('1', '3'))
            BEGIN
               SET @Ln_Recipient_IDNO = CAST (@Ac_Recipient_ID AS NUMERIC (10));
            END

         IF (@As_Prefix_TEXT = '' OR @As_Prefix_TEXT IS NULL)
            BEGIN
               SET @As_Prefix_TEXT = 'Recipient';
            END

         -- OTHP Address
         IF (@Lc_MailRecipient_CODE = '3')
            BEGIN
               SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_OTHP_DTLS';
               SET @Ls_Sqldata_TEXT = ' Recipient_IDNO = ' + ISNULL (@Ac_Recipient_ID, '');

               EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS @An_OtherParty_IDNO   = @Ln_Recipient_IDNO,
                                                         @As_Prefix_TEXT       = @As_Prefix_TEXT, 
                                                         @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,
                                                         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

               IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
                  BEGIN
                     RAISERROR (50001, 16, 1);
                     RETURN;
                  END

               RETURN;
            END

         -- MEMBER ADDRESS
         IF (@Lc_MailRecipient_CODE = '1')
            BEGIN
               SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS';
               SET @Ls_Sqldata_TEXT = ' Recipient_IDNO = ' + ISNULL (@Ac_Recipient_ID, '');
			   
			    EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS
					  @An_MemberMci_IDNO       = @Ln_Recipient_IDNO,
					  @As_Prefix_TEXT          = @As_Prefix_TEXT, 
					  @Ac_Msg_CODE             = @Ac_Msg_CODE OUTPUT,
					  @As_DescriptionError_TEXT= @As_DescriptionError_TEXT OUTPUT;
						
				 IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
					BEGIN
					   SET @Ac_Msg_CODE=@Lc_StatusFailed_CODE;
					   SET @As_DescriptionError_TEXT = 'Failed TO Get Member Details' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL (@As_DescriptionError_TEXT, '');
					   RETURN;
					END	
               
                     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS';
                     SET @Ls_Sqldata_TEXT =
                              ' MemberMci_IDNO = '
                            + ISNULL (@Ac_Recipient_ID ,'')
                            + ', TypeAddress_CODE = '
                            + ISNULL (@Ac_TypeAddress_CODE, '')
                            + ', Run_DATE = '
                            +ISNULL(CAST(@Ad_Run_DATE AS VARCHAR),'');
                     EXEC BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS @An_MemberMci_IDNO = @Ln_Recipient_IDNO,
															 @Ac_TypeAddress_CODE = @Ac_TypeAddress_CODE,
                                                             @Ad_Run_DATE      = @Ad_Run_DATE,
                                                             @As_Prefix_TEXT   = @As_Prefix_TEXT,
                                                             @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,
                                                             @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

                     IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
                        BEGIN
                           RAISERROR (50001, 16, 1);
                           RETURN;
                        END
                  
            END

         -- FIPS Address
         IF (@Lc_MailRecipient_CODE = '2')
            BEGIN
               SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS';
               SET @Ls_Sqldata_TEXT = ' Recipient_IDNO = ' + ISNULL (@Ac_Recipient_ID, '');

               EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS @Ac_Fips_CODE     = @Ac_Recipient_ID,
                                                                @As_Prefix_TEXT   = @As_Prefix_TEXT,
                                                                @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,
                                                                @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

               IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
                  BEGIN
                     RAISERROR (50001, 16, 1);
                  END
            END

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END

GO
