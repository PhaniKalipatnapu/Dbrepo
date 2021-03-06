/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_OTHP_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_OTHP_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Other party recipient details from OTHP_Y1
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_OTHP_DTLS]
 @An_OtherParty_IDNO       NUMERIC(9),
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ld_High_DATE            DATETIME,
          @Lc_StatusSuccess_CODE   CHAR,
          @Ls_Routine_TEXT         VARCHAR(60) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_OTHP_DTLS',
          @Ls_Sql_TEXT             VARCHAR(1000),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Lc_StatusFailed_CODE    CHAR,
          @Ls_Err_Description_TEXT VARCHAR(4000),
          @Ln_Zero_NUMB            NUMERIC=0,
          @Lc_Space_TEXT           CHAR=' ',
          @Li_Rowcount_QNTY        SMALLINT

  SET @Ld_High_DATE = '12-31-9999'
  SET @Lc_StatusSuccess_CODE = 'S'
  SET @Lc_StatusFailed_CODE = 'F'
  SET @As_DescriptionError_TEXT = ' '
  SET @Ln_Zero_NUMB = 0

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1 ';
   SET @Ls_Sqldata_TEXT = ' OtherParty_IDNO: ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR), '');

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                ELEMENT_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(70), OtherParty_NAME) OTHPRecipientOtherParty_NAME,
                   CONVERT(VARCHAR(70), Attn_ADDR) OTHPRecipientAttn_ADDR,
                   CONVERT(VARCHAR(70), Line1_ADDR) OTHPRecipientLine1_ADDR,
                   CONVERT(VARCHAR(70), Addr_Line2) OTHPRecipientLine2_ADDR,
                   CONVERT(VARCHAR(70), City_ADDR) OTHPRecipientCity_ADDR,
                   CONVERT(VARCHAR(70), State_ADDR) OTHPRecipientState_ADDR,
                   CONVERT(VARCHAR(70), Zip_ADDR) OTHPRecipientZip_ADDR,
                   CONVERT(VARCHAR(70), Country_ADDR) OTHPRecipientCtryCode_ADDR
              FROM (SELECT b.OtherParty_NAME,
                           b.Attn_ADDR,
                           b.Line1_ADDR,
                           (b.Line2_ADDR) AS Addr_Line2,
                           b.City_ADDR,
                           b.Zip_ADDR,
                           b.State_ADDR,
                           b.Country_ADDR,
                           b.Phone_NUMB,
                           b.Fax_NUMB,
                           Fein_IDNO id_fein
                      FROM OTHP_Y1 b
                     WHERE b.OtherParty_IDNO = @An_OtherParty_IDNO
                       AND b.EndValidity_DATE = @Ld_High_DATE) a)up UNPIVOT (tag_value FOR tag_name IN ( OTHPRecipientOtherParty_NAME, OTHPRecipientAttn_ADDR, OTHPRecipientLine1_ADDR, OTHPRecipientLine2_ADDR, OTHPRecipientCity_ADDR, OTHPRecipientState_ADDR, OTHPRecipientZip_ADDR, OTHPRecipientCtryCode_ADDR)) AS pvt);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     RAISERROR (50001,16,1);
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
