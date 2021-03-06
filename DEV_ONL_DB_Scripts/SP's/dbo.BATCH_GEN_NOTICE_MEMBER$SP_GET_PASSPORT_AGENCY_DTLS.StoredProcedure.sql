/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PASSPORT_AGENCY_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_PASSPORT_AGENCY_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Passport Agency Details to show on ENF-28 Notice.
Frequency		:	
Developed On	:	3/16/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PASSPORT_AGENCY_DTLS]
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
   SET NOCOUNT ON;
   
  DECLARE @Ln_Passportagency_IDNO         NUMERIC(9)=999999965,
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_PrefixPassportAgency_TEXT   CHAR(15) ='PASSPORT_AGENCY',
          @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_PASSPORT_AGENCY_DTLS',
          @Ld_High_DATE                   DATE ='12/31/9999';
  DECLARE 
          @Ln_OtherParty_IDNO        NUMERIC(9),
          @Ln_Error_NUMB             NUMERIC(11),
          @Ln_ErrorLine_NUMB         NUMERIC(11),
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400),
          @Ls_DescriptionError_TEXT  VARCHAR(4000);
          
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'RETRIVE OTHER PARTY ID FOR PASSPORT AGENCY';
   SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + CAST(@Ln_Passportagency_IDNO AS VARCHAR);
   -- Other Party ID 999999965 Denotes Passport Agency.
   SET @Ln_OtherParty_IDNO = (SELECT o.OtherParty_IDNO
                                FROM OTHP_Y1 o
                               WHERE OtherParty_IDNO = @Ln_Passportagency_IDNO
                                 AND EndValidity_DATE = @Ld_High_DATE);

   IF @Ln_OtherParty_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR); 
      
     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
      @As_Prefix_TEXT           = @Lc_PrefixPassportAgency_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
        RAISERROR (50001, 16, 1);
      END;  
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
            
    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
      SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      
  END CATCH
 END


GO
