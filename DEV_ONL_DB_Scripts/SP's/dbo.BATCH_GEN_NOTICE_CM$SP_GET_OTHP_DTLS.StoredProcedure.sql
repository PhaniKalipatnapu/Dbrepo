/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get OtherParty Details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS](
 @An_OtherParty_IDNO       NUMERIC(9),
 @As_Prefix_TEXT           VARCHAR(70) ='Othp',
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR = 'S',
          @Lc_StatusFailed_CODE  CHAR = 'F',
          @Lc_Notice_ID          CHAR(8),
          @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_TypeAddrZ_CODE	 CHAR(1) = 'Z',
		  @Lc_TypeAddrV_CODE	 CHAR(1) = 'V',
		  @Lc_NoticeEnf01_ID	 CHAR(8) = 'ENF-01',
		  @Lc_NoticeEnf03_ID	 CHAR(8) = 'ENF-03',
          @Lc_Recipient_CODE     VARCHAR(4)	= ' ',
          @Ln_OtherParty_IDNO	 NUMERIC(9),
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Li_Error_NUMB           INT,
          @Li_ErrorLine_NUMB       INT,
          @Ls_Routine_TEXT         VARCHAR(100),
          @Ls_Sql_TEXT             VARCHAR(200),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Ls_Err_Description_TEXT VARCHAR(4000);


  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
   SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
   SET @Ls_Sqldata_TEXT = ' OtherParty_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR(9)), '');

   --13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - Start 								  
   SET @Lc_Notice_ID = (SELECT Element_VALUE
								   FROM #NoticeElementsData_P1
								  WHERE Element_NAME = 'Notice_ID');
								  
   SELECT @Ln_OtherParty_IDNO = CAST(O.AddrOthp_IDNO  AS NUMERIC(9))
					FROM OTHX_Y1 O
					WHERE O.OtherParty_IDNO  = @An_OtherParty_IDNO  
					AND O.TypeAddr_CODE = @Lc_TypeAddrZ_CODE 
					AND @Lc_Notice_ID = @Lc_NoticeEnf01_ID 
					AND O.EndValidity_DATE = @Ld_High_Date
					
   SELECT @An_OtherParty_IDNO = CAST(O.AddrOthp_IDNO  AS NUMERIC(9))
					FROM OTHX_Y1 O
					WHERE O.OtherParty_IDNO  = @An_OtherParty_IDNO   
					AND O.TypeAddr_CODE = @Lc_TypeAddrV_CODE 
					AND @Lc_Notice_ID = @Lc_NoticeEnf03_ID 
					AND O.EndValidity_DATE = @Ld_High_Date					
	--13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - End 	
			
   IF (@As_Prefix_TEXT IS NULL
        OR @As_Prefix_TEXT = '')
    BEGIN
     SET @As_Prefix_TEXT = 'OTHP';
    END

   DECLARE @NoticeElements_P1 TABLE (
    Element_NAME  VARCHAR(100),
    Element_Value VARCHAR(100));

   INSERT INTO @NoticeElements_P1
               (Element_NAME,
                Element_Value)
   SELECT pvt.Element_NAME,
          pvt.Element_Value
     FROM (SELECT CAST(a.OtherParty_NAME AS VARCHAR(100)) AS NAME,
                  CAST(a.Attn_ADDR AS VARCHAR(100)) AS Attn_ADDR,
                  CAST(a.Line1_ADDR AS VARCHAR(100)) AS Line1_ADDR,
                  CAST(a.Line2_ADDR AS VARCHAR(100)) AS Line2_ADDR,
                  CAST(a.City_ADDR AS VARCHAR(100)) AS City_ADDR,
                  CAST(a.State_ADDR AS VARCHAR(100)) AS State_ADDR,
                  CAST(a.Zip_ADDR AS VARCHAR(100)) AS Zip_ADDR,
                  CAST(a.Country_ADDR AS VARCHAR(100)) AS Country_ADDR,
                  CAST(a.Phone_NUMB AS VARCHAR(100)) AS Phone_NUMB,
                  CAST(a.Fax_NUMB AS VARCHAR(100)) AS Fax_NUMB,
                  CAST(a.DescriptionContactOther_TEXT AS VARCHAR(100)) AS DescriptionContactOther_TEXT,
                  CAST(a.Fein_IDNO AS VARCHAR(100)) AS Fein_IDNO,
                  CAST(a.County_NAME AS VARCHAR(100)) AS county_name,
                  CAST(@An_OtherParty_IDNO AS VARCHAR(100)) AS eportal_acct,
                  CAST(a.DescriptionContactOther_TEXT AS VARCHAR(100)) AS emp_rep
             FROM (SELECT RTRIM(O.OtherParty_NAME) AS OtherParty_NAME,
                          RTRIM(O.Attn_ADDR) + @Lc_Space_TEXT AS Attn_ADDR,
                          RTRIM(O.Line1_ADDR) + @Lc_Space_TEXT AS Line1_ADDR,
                          RTRIM(O.Line2_ADDR) + @Lc_Space_TEXT AS Line2_ADDR,
                          RTRIM(O.City_ADDR) AS City_ADDR,
                          @Lc_Space_TEXT + RTRIM(O.State_ADDR) + @Lc_Space_TEXT AS State_ADDR,
                          RTRIM(O.Zip_ADDR)  AS Zip_ADDR,
                          @Lc_Space_TEXT + RTRIM(O.Country_ADDR) AS Country_ADDR,
                          O.Phone_NUMB,
                          O.Fax_NUMB,
                          O.DescriptionContactOther_TEXT,
                          --13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - Start				
                          CASE WHEN @Ln_OtherParty_IDNO IS NOT NULL  THEN
								(SELECT C.Fein_IDNO
								FROM OTHP_Y1 C
								WHERE C.OtherParty_IDNO = @Ln_OtherParty_IDNO
								AND C.EndValidity_DATE = @Ld_High_DATE) 
								ELSE 
								O.Fein_IDNO 
								END AS Fein_IDNO,
						  --13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - End 				
                          dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC('DEMO','BICO',O.County_IDNO) AS County_NAME
                     FROM OTHP_Y1 O
                    WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
                      AND O.EndValidity_DATE = @Ld_High_DATE)a) up UNPIVOT (Element_Value FOR Element_NAME IN (NAME, Attn_ADDR, Line1_ADDR, Line2_ADDR, City_ADDR, State_ADDR, Zip_ADDR, Country_ADDR, Phone_NUMB, Fax_NUMB, DescriptionContactOther_TEXT, Fein_IDNO,County_NAME, eportal_acct, emp_rep )) AS pvt;

   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = '  ';

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   SELECT  RTRIM(@As_Prefix_TEXT) + '_' + TND.Element_NAME AS Element_NAME,
          TND.Element_Value
     FROM @NoticeElements_P1 TND;   
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
