/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_COURT_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_COURT_ADDRESS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_COURT_ADDRESS]
 @An_OtherParty_IDNO       NUMERIC(9),
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS

 BEGIN
  DECLARE @Ld_High_DATE              DATE = '31/12/9999',
          @Lc_StatusSuccess_CODE     CHAR = 'S',
          @Ls_StatusNoDataFound_CODE CHAR = 'N',
          @Ls_DoubleSpace_TEXT       VARCHAR(2) = '  ',
          @Lc_StatusFailed_CODE      CHAR = 'F',
          @Ls_OthpType_CODE          CHAR = 'K',
          @Ls_Routine_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400),
          @Ls_Err_Description_TEXT   VARCHAR(4000)

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL
   SET @As_DescriptionError_TEXT = NULL
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_COURT_ADDRESS '
   SET @Ls_Sqldata_TEXT = ' OtherParty_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR), '')
   SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1'

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), Attn_ADDR) COURT_ADDR_ATTN,
                   CONVERT(VARCHAR(100), Line1_ADDR) COURT_ADDR_LINE1,
                   CONVERT(VARCHAR(100), Line2_ADDR) COURT_ADDR_LINE2,
                   CONVERT(VARCHAR(100), City_ADDR) COURT_ADDR_CITY,
                   CONVERT(VARCHAR(100), State_ADDR) COURT_ADDR_ST,
                   CONVERT(VARCHAR(100), Zip_ADDR) COURT_ADDR_ZIP,
                   CONVERT(VARCHAR(100), Country_ADDR) COURT_ADDR_CNTRY
              FROM (SELECT b.Attn_ADDR,
                           b.Line1_ADDR,
                           b.Line2_ADDR,
                           b.City_ADDR,
                           b.Zip_ADDR,
                           b.State_ADDR,
                           b.Country_ADDR
                      FROM OTHP_Y1 AS b
                     WHERE b.OtherParty_IDNO = @An_OtherParty_IDNO
                       AND b.EndValidity_DATE = @Ld_High_DATE
                       AND b.TypeOthp_CODE = @Ls_OthpType_CODE)a) up UNPIVOT (tag_value FOR tag_name IN ( COURT_ADDR_ATTN, COURT_ADDR_LINE1, COURT_ADDR_LINE2, COURT_ADDR_CITY, COURT_ADDR_ST, COURT_ADDR_ZIP, COURT_ADDR_CNTRY )) AS pvt)

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ac_Msg_CODE = 'E0052'
     SET @As_DescriptionError_TEXT = 'No Data Found  OTHP_Y1';
     RETURN;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE

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
