/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FI]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
---------------------------------------------------------
 Procedure Name    :BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FI
 Programmer Name   : IMP Team
 Description       :The The procedure BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FI get Recipient details which are of type other party.
 Frequency         :
 Developed On      :03/25/2011
 Called By         :BATCH_GEN_UTIL$EXEC_RECP_DETAILS_PROC
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        : 1.0 
---------------------------------------------------------
*/  
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FI](
 @Ac_Recipient_CODE        CHAR(2),
 @An_OthpSource_IDNO       NUMERIC(9),
 @Ac_PrintMethod_CODE     CHAR(2),
 @Ac_TypeService_CODE     CHAR(2),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
   DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
           @Lc_StatusFailed_CODE  CHAR(1) = 'F',
           @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_GET_CP_MAILING_ADDRESS ',
           @Ld_High_DATE          DATE ='12/31/9999';
   DECLARE @Li_Error_NUMB            INT,
           @Li_ErrorLine_NUMB        INT,
           @Ls_Sql_TEXT              VARCHAR(200) = '',
           @Ls_SqlData_TEXT          VARCHAR(400) = '',
           @Ls_DescriptionError_TEXT VARCHAR(4000) ='';
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FI';
   SET @Ls_Sqldata_TEXT = ' @Recipient_CODE = ' + @Ac_Recipient_CODE + ', printMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE + ', Recipient_CODE = ' + @Ac_Recipient_CODE;
   INSERT INTO #NoticeRecipients_P1
               (Recipient_ID,
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
           WHERE o.OtherParty_IDNO = @An_OthpSource_IDNO
             AND o.TypeOthp_CODE = 'H'
             AND o.EndValidity_DATE = @Ld_High_DATE)b;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END



GO
