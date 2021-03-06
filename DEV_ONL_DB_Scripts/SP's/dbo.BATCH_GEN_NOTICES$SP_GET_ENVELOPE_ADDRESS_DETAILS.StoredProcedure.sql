/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get office worker details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS]
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Notice_ID             CHAR(8),
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 DECLARE @Ld_High_DATE            DATETIME2,
         @Ln_County_IDNO          NUMERIC(3),     
         @Ls_Code_cen_office_IDNO NUMERIC(3),
         @Lc_StatusSuccess_CODE   CHAR,
         @Ls_Routine_TEXT         VARCHAR(60) ='BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS',
         @Ls_Sql_TEXT             VARCHAR(1000),
         @Ls_Sqldata_TEXT         VARCHAR(400),
         @Lc_StatusFailed_CODE    CHAR,
         @Ls_Err_Description_TEXT VARCHAR(4000),
         @Li_Rowcount_QNTY        NUMERIC,
         @Ln_Zero_NUMB            NUMERIC

 SET @Ld_High_DATE = '12-31-9999';    
 SET @Ls_Code_cen_office_IDNO = 99;     
 SET @Lc_StatusSuccess_CODE = 'S';
 SET @Lc_StatusFailed_CODE = 'F';
 SET @Ln_Zero_NUMB = 0;

 BEGIN
  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT OFIC_Y1 AND OTHP_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + ISNULL(CAST(@An_Case_IDNO AS CHAR), '') + ' Notice_ID: ' + ISNULL(@Ac_Notice_ID, '');
   SET @Ln_County_IDNO = (SELECT County_IDNO
                            FROM CASE_Y1
                           WHERE Case_IDNO = @An_Case_IDNO)

   IF @Ln_County_IDNO = 99
    BEGIN
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  ELEMENT_VALUE) --#MemberDetails_P1(Element_NAME,ELEMENT_VALUE)          
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(70), OtherParty_NAME) LoginWorkersOffice_NAME,
                     CONVERT(VARCHAR(70), Attn_ADDR) LoginWrkOficAttn_ADDR,
                     CONVERT(VARCHAR(70), Line1_ADDR) LoginWrkOficLine1_ADDR,
                     CONVERT(VARCHAR(70), Line2_ADDR) LoginWrkOficLine2_ADDR,
                     CONVERT(VARCHAR(70), City_ADDR) LoginWrkOficCity_ADDR,
                     CONVERT(VARCHAR(70), State_ADDR) LoginWrkOficState_ADDR,
                     CONVERT(VARCHAR(70), Zip_ADDR) LoginWrkOficZip_ADDR,
                     CONVERT(VARCHAR(70), Country_ADDR) LoginWrkOficCountry_ADDR,
                     CONVERT(VARCHAR(70), Phone_NUMB) Worker_Phone_NUMB,
                     CONVERT(VARCHAR(70), Fax_NUMB) Worker_fax_NUMB,
                     CONVERT(VARCHAR(70), Fein_IDNO) Worker_Fein_IDNO,
                     CONVERT(VARCHAR(70), StartOffice_DTTM) Worker_StartOffice_DTTM,
                     CONVERT(VARCHAR(70), CloseOffice_DTTM) Worker_CloseOffice_DTTM
                FROM (SELECT p.OtherParty_NAME,
                             p.Attn_ADDR,
                             p.Line1_ADDR,
                             p.Line2_ADDR,
                             p.City_ADDR,
                             p.State_ADDR,
                             p.Zip_ADDR,
                             Country_ADDR,
                             p.Phone_NUMB,
                             p.Fax_NUMB,
                             Fein_IDNO,
                             o.StartOffice_DTTM,
                             o.CloseOffice_DTTM,
                             p.OtherParty_IDNO
                        FROM OFIC_Y1 o,
                             OTHP_Y1 p
                       WHERE o.Office_IDNO = @Ls_Code_cen_office_IDNO
                         AND o.OtherParty_IDNO = p.OtherParty_IDNO
                         AND p.EndValidity_DATE = @Ld_High_DATE
                         AND o.EndValidity_DATE = @Ld_High_DATE) a) up UNPIVOT (tag_value FOR tag_name IN ( LoginWorkersOffice_NAME, LoginWrkOficAttn_ADDR, LoginWrkOficLine1_ADDR, LoginWrkOficLine2_ADDR, LoginWrkOficCity_ADDR, LoginWrkOficState_ADDR, LoginWrkOficZip_ADDR, LoginWrkOficCountry_ADDR, Worker_Phone_NUMB, Worker_Fax_NUMB, Worker_Fein_IDNO, Worker_StartOffice_DTTM, Worker_CloseOffice_DTTM ) ) AS pvt)
    END
   ELSE
    BEGIN
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  ELEMENT_VALUE)--#MemberDetails_P1(Element_NAME,ELEMENT_VALUE)          
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(70), OtherParty_NAME) LoginWorkersOffice_NAME,
                     CONVERT(VARCHAR(70), Attn_ADDR) LoginWrkOficAttn_ADDR,
                     CONVERT(VARCHAR(70), Line1_ADDR) LoginWrkOficLine1_ADDR,
                     CONVERT(VARCHAR(70), Line2_ADDR) LoginWrkOficLine2_ADDR,
                     CONVERT(VARCHAR(70), City_ADDR) LoginWrkOficCity_ADDR,
                     CONVERT(VARCHAR(70), State_ADDR) LoginWrkOficState_ADDR,
                     CONVERT(VARCHAR(70), Zip_ADDR) LoginWrkOficZip_ADDR,
                     CONVERT(VARCHAR(70), Country_ADDR) LoginWrkOficCountry_ADDR,
                     CONVERT(VARCHAR(70), Phone_NUMB) Worker_Phone_NUMB,
                     CONVERT(VARCHAR(70), Fax_NUMB) Worker_Fax_NUMB,
                     CONVERT(VARCHAR(70), Office_IDNO) Worker_Office_CODE,
                     CONVERT(VARCHAR(70), County_IDNO) Worker_County_CODE,
                     CONVERT(VARCHAR(70), Fein_IDNO) Worker_Fein_IDNO,
                     CONVERT(VARCHAR(70), StartOffice_DTTM) Worker_StartOffice_DTTM,
                     CONVERT(VARCHAR(70), CloseOffice_DTTM) Worker_CloseOffice_DTTM,
                     CONVERT(VARCHAR(70), Office_NAME) Worker_Office_Name,
                     CONVERT(VARCHAR(70), County_NAME) Worker_County_name
                FROM (SELECT p.OtherParty_NAME,
                             p.Attn_ADDR,
                             p.Line1_ADDR,
                             p.Line2_ADDR,
                             p.City_ADDR,
                             p.State_ADDR,
                             p.Zip_ADDR,
                             p.Country_ADDR,
                             p.Phone_NUMB,
                             p.Fax_NUMB,
                             Fein_IDNO,
                             c.Office_IDNO,
                             c.County_IDNO,
                             o.StartOffice_DTTM,
                             o.CloseOffice_DTTM,
                             p.OtherParty_IDNO,
                             (SELECT County_NAME
                                FROM COPT_Y1
                               WHERE County_IDNO = c.County_IDNO) AS County_NAME,
                             (SELECT Office_NAME
                                FROM OFIC_Y1
                               WHERE Office_IDNO = c.Office_IDNO) AS Office_NAME
                        FROM CASE_Y1 c,
                             OFIC_Y1 o,
                             OTHP_Y1 p
                       WHERE c.Case_IDNO = @An_Case_IDNO
                         AND c.County_IDNO = o.County_IDNO
                         AND o.OtherParty_IDNO = p.OtherParty_IDNO
                         AND p.EndValidity_DATE = @Ld_High_DATE
                         AND o.EndValidity_DATE = @Ld_High_DATE)a)up UNPIVOT (tag_value FOR tag_name IN ( LoginWorkersOffice_NAME, LoginWrkOficAttn_ADDR, LoginWrkOficLine1_ADDR, LoginWrkOficLine2_ADDR, LoginWrkOficCity_ADDR, LoginWrkOficState_ADDR, LoginWrkOficZip_ADDR, LoginWrkOficCountry_ADDR, Worker_Phone_NUMB, Worker_Fax_NUMB, Worker_Office_CODE, Worker_County_CODE, Worker_Fein_IDNO, Worker_StartOffice_DTTM, Worker_CloseOffice_DTTM, Worker_Office_Name, Worker_County_Name ) ) AS pvt)
    END

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    RAISERROR(50001,16,1)

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
