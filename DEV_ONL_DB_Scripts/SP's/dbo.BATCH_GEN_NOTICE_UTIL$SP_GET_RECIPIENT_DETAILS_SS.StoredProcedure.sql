/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SS
 Programmer Name    : IMP Team
 Description        : The procedure BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SS get Recipient details which are of type other party.
 Frequency          :
 Developed On       : 03/23/2011
 Called By          : BATCH_GEN_UTIL$EXEC_RECP_DETAILS_PROC
 Called On          :
---------------------------------------------------------
 Modified By        :
 Modified On        : 
 Version No         : 1.0  
---------------------------------------------------------
*/  

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SS](
 @Ac_Recipient_CODE       CHAR(2),
 @Ac_PrintMethod_CODE          CHAR(1),
 @Ac_TypeService_CODE          CHAR(1), 
  @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT)

AS
BEGIN
 SET NOCOUNT ON;
 DECLARE  @Ln_OthpParty_IDNO        NUMERIC(10) = 999999994,
          @Lc_StatusFailed_CODE CHAR (1) = 'F',
          @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SS';
 DECLARE @Ls_Sql_TEXT              VARCHAR(100) = '',
         @Ls_Sqldata_TEXT          VARCHAR (1000) = '',
         @Ls_DescriptionError_TEXT VARCHAR(4000),
         @Ld_High_DATE             DATE;

 SET @Ld_High_DATE ='12-31-9999';
 BEGIN TRY
   SET @Ls_Sql_TEXT=' BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SS';
   SET @Ls_Sqldata_TEXT='Recipient_code = ' + ISNULL(@Ac_Recipient_CODE ,'') + ', PrintMethod_CODE = ' + ISNULL(@Ac_PrintMethod_CODE,'') +  ', TypeService_CODE = ' + ISNULL(@Ac_TypeService_CODE ,'');
   INSERT INTO #NoticeRecipients_P1
               (Recipient_IDNO,
                Recipient_name,
                Recipient_code,
                PrintMethod_CODE,
                TypeService_CODE)
   SELECT (SUBSTRING(b.name_recipient, 1, CHARINDEX(';', b.name_recipient) - 1))recipient_id,
          (SUBSTRING(b.name_recipient, (CHARINDEX(';', b.name_recipient) + 1), LEN(b.name_recipient))) name_recipient,
          b.cd_recipient,
          @Ac_PrintMethod_CODE AS PRINT_METHOD,
          @Ac_TypeService_CODE AS TYPE_SERVICE
     FROM(SELECT @AC_Recipient_CODE cd_recipient,
                 (CONVERT(VARCHAR(MAX), OtherParty_IDNO) + ';' + OtherParty_NAME) Name_recipient
            FROM OTHP_Y1 o
           WHERE o.OtherParty_IDNO = @Ln_OthpParty_IDNO
             AND o.EndValidity_DATE = @Ld_High_DATE)b;

   SET @Ac_Msg_CODE = 'S';
  END TRY

  BEGIN CATCH
  DECLARE @Ln_Error_NUMB NUMERIC (11), @Ln_ErrorLine_NUMB NUMERIC (11);

         SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
                @Ln_Error_NUMB = ERROR_NUMBER (),
                @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF ERROR_NUMBER () <> 50001
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
