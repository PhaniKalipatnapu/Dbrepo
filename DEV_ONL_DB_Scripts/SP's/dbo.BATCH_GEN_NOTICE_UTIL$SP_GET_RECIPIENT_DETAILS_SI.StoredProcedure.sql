/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SI]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
---------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_SI
 Programmer Name    : IMP Team
 Description        : The procedure BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_SI gets Source of Income Recipient Details
 Frequency          :
 Developed On       : 03/25/2011
 Called By          : BATCH_GEN_NOTICE_UTIL$EXEC_RECIPIENT_DETAILS_PROC
 Called On          :
---------------------------------------------------------
 Modified By        :
 Modified On        :
 Version No         : 1.0  
---------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SI]
 @Ac_Recipient_CODE        CHAR(2),
 @An_OthpSource_IDNO       NUMERIC(9),
 @Ac_PrintMethod_CODE     CHAR(1),
 @Ac_TypeService_CODE     CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

   
  DECLARE @Lc_StatusSucess_CODE     CHAR(1)			= 'S',
          @Lc_StatusFailed_CODE     CHAR(1)			= 'F',
          @Lc_RecipientSi_CODE		CHAR(2)			= 'SI',
          @Ls_Procedure_NAME		VARCHAR(100)	= 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SI',
          @Ld_High_DATE             DATETIME2		= '12/31/9999';
  DECLARE @Ls_Sql_TEXT              VARCHAR(100)	= '',
          @Ls_Sqldata_TEXT          VARCHAR(1000)	= '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);
          

  SET @Ld_High_DATE = '12-31-9999';
  SET @Lc_StatusSucess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_SI';
   SET @Ls_Sqldata_TEXT = ' @Recipient_CODE = ' + @Ac_Recipient_CODE + ', printMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE + ', OthpSource_IDNO = ' + CAST(@An_OthpSource_IDNO AS VARCHAR);

   IF @An_OthpSource_IDNO IS NULL
       OR @An_OthpSource_IDNO = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = 'OtherParty_IDNO IS NULL ' + ' ' + ISNULL(@Ls_Sql_TEXT, '') + ' ' + ISNULL(@Ls_Sqldata_TEXT, '');

     RETURN;
    END

   INSERT INTO #NoticeRecipients_P1
               (Recipient_ID,
                Recipient_NAME,
                Recipient_CODE,
                PrintMethod_CODE,
                TypeService_CODE)
   SELECT CASE
           WHEN LEN(LTRIM(RTRIM(recipient_id))) < 9
            THEN STUFF(recipient_id, 1, 0, REPLICATE('0', 9 - LEN(recipient_id)))
           ELSE recipient_id
          END recipient_id,
          Recipient_NAME,
          Recipient_CODE,
          Print_METHOD,
          Type_SERVICE
     FROM (SELECT (SUBSTRING(b.name_recipient, 1, CHARINDEX(';', b.name_recipient) - 1))recipient_id,
                  (SUBSTRING(b.name_recipient, (CHARINDEX(';', b.name_recipient) + 1), LEN(b.name_recipient))) recipient_name,
                  b.Recipient_CODE,
                  @Ac_PrintMethod_CODE AS Print_METHOD,
                  @Ac_TypeService_CODE AS Type_SERVICE
             FROM(SELECT @Lc_RecipientSi_CODE Recipient_CODE,
                         (CONVERT(VARCHAR(MAX), OtherParty_IDNO) + ';' + OtherParty_NAME) name_recipient
                    FROM OTHP_Y1 o
                   WHERE o.OtherParty_IDNO = @An_OthpSource_IDNO
                     AND o.EndValidity_DATE = @Ld_High_DATE)b)C;

   SET @Ac_Msg_CODE = @Lc_StatusSucess_CODE;
  
  END TRY

  BEGIN CATCH
   DECLARE @Ln_Error_NUMB     NUMERIC (11),
           @Ln_ErrorLine_NUMB NUMERIC (11);

   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER (),
          @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF ERROR_NUMBER () <> 50001
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
