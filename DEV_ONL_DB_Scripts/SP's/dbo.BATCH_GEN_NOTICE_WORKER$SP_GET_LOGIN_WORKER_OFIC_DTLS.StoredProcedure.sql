/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_OFIC_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_OFIC_DTLS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_OFIC_DTLS]
(
 @Ac_Worker_ID			   CHAR(30),
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Notice_ID             CHAR(8),
 @As_Prefix_TEXT           VARCHAR(50) = 'LOGIN_WRK',
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
)
AS
 BEGIN
  DECLARE @Ls_CaseStatusOpen_CODE    CHAR(1) = 'O',
          @Ld_High_DATE              DATE = '12/31/9999',
          @Ls_StatusNoDataFound_CODE CHAR = 'N',
          @Ls_Space_TEXT			 CHAR(1) = ' ',
          @Lc_StatusFailed_CODE      CHAR = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Ls_CountyCenOffice_TEXT   VARCHAR(30) = '000',
          @Ls_CenOffice_CODE         VARCHAR(30) = 'OFFICE500',
          @Ls_Err_Description_TEXT   VARCHAR(4000),
          @Ls_CategoryFormCw_CODE    VARCHAR(2),
          @Ls_TypeOfficeSix_CODE     VARCHAR(2),
          @Ls_CategoryFormPd_CODE    VARCHAR(2),
          @Ls_TypeOfficeOne_CODE     VARCHAR(2),
          @Ls_CategoryFormFn_CODE    VARCHAR(2),
          @Ls_TypeOfficeFive_CODE    VARCHAR(2),
          @Ls_SQLString_TEXT         AS VARCHAR(MAX),
          @Lc_County_NAME            CHAR(40),
          @Ls_Office_NAME            VARCHAR(60),
          @Ln_County_IDNO            NUMERIC(3),
          @Ln_Row_QNTY               FLOAT(53) = 0,
          @Lc_Worker_ID              CHAR(30),
          @Ls_Routine_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400)

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_CategoryFormCw_CODE = ISNULL(@Ls_CategoryFormCw_CODE, 'CW');
   SET @Ls_TypeOfficeSix_CODE = ISNULL(@Ls_TypeOfficeSix_CODE, '6');
   SET @Ls_CategoryFormPd_CODE = ISNULL(@Ls_CategoryFormPd_CODE, 'PD');
   SET @Ls_TypeOfficeOne_CODE = ISNULL(@Ls_TypeOfficeOne_CODE, '1');
   SET @Ls_CategoryFormFn_CODE = ISNULL(@Ls_CategoryFormFn_CODE, 'FN');
   SET @Ls_TypeOfficeFive_CODE = ISNULL(@Ls_TypeOfficeFive_CODE, '5');
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_WORKER.BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_OFIC_DTLS ';
   SET @Ls_Sqldata_TEXT = ' Worker_ID = ' + ISNULL(@Ac_Worker_ID, '');
   SET @Ls_Sql_TEXT = ' SELECT CASE_Y1 ';

   SELECT @Ln_County_IDNO = c.County_IDNO,
          @Lc_County_NAME = dbo.BATCH_COMMON_GETS$SF_GETCOUNTYNAME(c.County_IDNO),
          @Ls_Office_NAME = dbo.BATCH_COMMON_GETS$SF_GET_OFFICECODE(c.Office_IDNO)
     FROM CASE_Y1 c
    WHERE c.Case_IDNO = @An_Case_IDNO
      AND c.StatusCase_CODE = @Ls_CaseStatusOpen_CODE;

     SET @Ls_Sqldata_TEXT = ' OtherParty_IDNO = ' + ISNULL(@Ls_CenOffice_CODE, '')
     SET @Ls_Sql_TEXT = 'SELECT VOFIC_VOTHP '
     SET @Ls_SQLString_TEXT= 'INSERT INTO #NoticeElementsData_P1(Element_NAME,Element_Value) 
							(SELECT tag_name, tag_value FROM  
						   (   
						   SELECT 
							CONVERT(VARCHAR(100),OtherParty_NAME)  ' + @As_Prefix_TEXT + '_NAME ,
							CONVERT(VARCHAR(100),Attn_ADDR) ' + @As_Prefix_TEXT + '_ATTN_ADDR ,     
							CONVERT(VARCHAR(100),Line1_ADDR) ' + @As_Prefix_TEXT + '_LINE1_ADDR ,
							CONVERT(VARCHAR(100),Line2_ADDR) ' + @As_Prefix_TEXT + '_LINE2_ADDR ,
							CONVERT(VARCHAR(100),City_ADDR) ' + @As_Prefix_TEXT + '_CITY_ADDR ,  
							CONVERT(VARCHAR(100),State_ADDR) ' + @As_Prefix_TEXT + '_STATE_ADDR ,
							CONVERT(VARCHAR(100),Zip_ADDR) ' + @As_Prefix_TEXT + '_ZIP_ADDR ,
							CONVERT(VARCHAR(100),Country_ADDR) ' + @As_Prefix_TEXT + '_COUNTRY_ADDR ,
							CONVERT(VARCHAR(100),Phone_NUMB) ' + @As_Prefix_TEXT + '_PHONE_NUMB ,
							CONVERT(VARCHAR(100),Fax_NUMB) ' + @As_Prefix_TEXT + '_FAX_NUMB ,
							CONVERT(VARCHAR(100),DescriptionContactOther_TEXT) ' + @As_Prefix_TEXT + '_DescriptionContactOther_TEXT,  
							CONVERT(VARCHAR(100),Fein_IDNO) ' + @As_Prefix_TEXT + '_FEIN_IDNO ,
							CONVERT(VARCHAR(100),StartOffice_DTTM) ' + @As_Prefix_TEXT + '_START_DTTM ,
							CONVERT(VARCHAR(100),CloseOffice_DTTM) ' + @As_Prefix_TEXT + '_CLOSE_DTTM ,
							CONVERT(VARCHAR(100),OtherParty_IDNO) ' + @As_Prefix_TEXT + '_OtherParty_IDNO
						 FROM  (
								   SELECT 
										p.OtherParty_NAME,
										RTRIM(p.Attn_ADDR) ' + @Ls_Space_TEXT + ' AS Attn_ADDR, 
										RTRIM(p.Line1_ADDR) ' + @Ls_Space_TEXT + '  AS Line1_ADDR, 
										RTRIM(p.Line2_ADDR) ' + @Ls_Space_TEXT + '  AS Line2_ADDR, 
										RTRIM(p.City_ADDR) AS City_ADDR, '  
										+ @Ls_Space_TEXT + ' RTRIM(p.Zip_ADDR) ' + @Ls_Space_TEXT + ' AS Zip_ADDR, 
										RTRIM(p.State_ADDR) AS State_ADDR, '
										+ @Ls_Space_TEXT + 'RTRIM(p.Country_ADDR) AS Country_ADDR, 
										p.Phone_NUMB, 
										p.Fax_NUMB, 
										p.DescriptionContactOther_TEXT, 
										p.Fein_IDNO, 
										o.StartOffice_DTTM, 
										o.CloseOffice_DTTM, 
										p.OtherParty_IDNO
								   FROM OFIC_Y1  AS o, OTHP_Y1  AS p
								   WHERE 
									  o.Office_IDNO = ''' + CAST(ISNULL(@Ln_County_IDNO, 0) AS  VARCHAR) + ''' AND 
									  o.OtherParty_IDNO = p.OtherParty_IDNO AND 
									  p.EndValidity_DATE = ' + '''' + CAST(@Ld_High_DATE AS VARCHAR) + '''' + ' AND 
									  o.EndValidity_DATE = ' + '''' + CAST(@Ld_High_DATE AS VARCHAR) + '''' + ')a
												  ) up  
						 UNPIVOT   
						 (tag_value FOR tag_name IN (' + @As_Prefix_TEXT + '_NAME,
													 ' + @As_Prefix_TEXT + '_ATTN_ADDR ,
													 ' + @As_Prefix_TEXT + '_LINE1_ADDR ,
													 ' + @As_Prefix_TEXT + '_LINE2_ADDR ,
													 ' + @As_Prefix_TEXT + '_CITY_ADDR ,
													 ' + @As_Prefix_TEXT + '_STATE_ADDR ,
													 ' + @As_Prefix_TEXT + '_ZIP_ADDR ,
													 ' + @As_Prefix_TEXT + '_COUNTRY_ADDR ,
													 ' + @As_Prefix_TEXT + '_PHONE_NUMB ,
													 ' + @As_Prefix_TEXT + '_FAX_NUMB ,
													 ' + @As_Prefix_TEXT + '_DescriptionContactOther_TEXT ,
													 ' + @As_Prefix_TEXT + '_FEIN_IDNO ,
													 ' + @As_Prefix_TEXT + '_START_DTTM ,
													 ' + @As_Prefix_TEXT + '_CLOSE_DTTM ,
													 ' + @As_Prefix_TEXT + '_OtherParty_IDNO
													 
													))  
						 AS pvt)'
 
     EXEC(@Ls_SQLString_TEXT);
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
