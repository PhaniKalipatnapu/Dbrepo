/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_APRE_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_APRE_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get address details from AHIS_Y1
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_APRE_ADDRESS]
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_Run_DATE              DATETIME2,
 @As_Prefix_TEXT           VARCHAR(70),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  DECLARE @Lc_StatusSuccess_CODE             CHAR = 'S',
          @Ls_Mailing_ADDR                   CHAR(1) = 'M',
          @Ls_VerificationStatusGood_CODE    CHAR = 'Y',
          @Ls_StatusNoDataFound_CODE         CHAR = 'N',
          @Ls_DoubleSpace_TEXT               VARCHAR(2) = '  ',
          @Lc_StatusFailed_CODE              CHAR = 'F',
          @Ls_TypeAddress_PrmyResidence_CODE CHAR(1) = 'P',
          @Ls_TypeAddress_SecResidence_CODE  CHAR(1) = 'S',
          @Ls_StatusP1_CODE                  CHAR(1) = 'P',
          @Ls_SQLString_TEXT                 VARCHAR(MAX),
          @Ld_Run_DATE                       DATETIME,
          @Ls_ErrorDesc_TEXT				 VARCHAR(400)  = '',
          @Ls_Routine_TEXT                   VARCHAR(100)  = '',
          @Ls_Sql_TEXT                       VARCHAR(200)  = '',
          @Ls_Sqldata_TEXT                   VARCHAR(400)  = '',
          @Ls_Err_Description_TEXT           VARCHAR(4000) = '';

  BEGIN TRY
   

   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = 'CCRT ::';
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_CM.BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS ';
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ld_Run_DATE = ISNULL(@Ld_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

   IF @As_Prefix_TEXT IS NULL
       OR @As_Prefix_TEXT = ' '
    BEGIN
     SET @As_Prefix_TEXT = 'MEM'
    END

   BEGIN TRY
    SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';
    SET @Ls_Sqldata_TEXT = 'Recipient_IDNO =' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR), '');

    SET @Ls_SQLString_TEXT = 'INSERT INTO #NoticeElementsData_P1(Element_NAME,Element_Value)
											 (SELECT tag_name, tag_value FROM  
											   (   
											   SELECT    
												CONVERT(VARCHAR(100),Attn_ADDR) '    + @As_Prefix_TEXT + '_ATTN_ADDR,  
												CONVERT(VARCHAR(100),Line1_ADDR) '   + @As_Prefix_TEXT + '_LINE1_ADDR ,    
												CONVERT(VARCHAR(100),Line2_ADDR) '   + @As_Prefix_TEXT + '_LINE2_ADDR ,  
												CONVERT(VARCHAR(100),City_ADDR) '    + @As_Prefix_TEXT + '_CITY_ADDR,
												CONVERT(VARCHAR(100),State_ADDR) '   + @As_Prefix_TEXT + '_STATE_ADDR,  
												CONVERT(VARCHAR(100),Zip_ADDR) '     + @As_Prefix_TEXT + '_ZIP_ADDR ,    
												CONVERT(VARCHAR(100),Country_ADDR) ' + @As_Prefix_TEXT + '_COUNTRY_ADDR ,  
												CONVERT(VARCHAR(100),BeginValidity_DATE) ' + @As_Prefix_TEXT + '_ADDR_BEG_DT,  
												CONVERT(VARCHAR(100),LAST_KNOWN) ' + @As_Prefix_TEXT + '_LAST_ADDR_INDC,  
												CONVERT(VARCHAR(100),CURRENT_ADDRESS) ' + @As_Prefix_TEXT + '_CURRENT_ADDR_INDC,
												CONVERT(VARCHAR(100),AddressAsOf_DATE) ' + @As_Prefix_TEXT + '_CURRENT_ADDR								
											   FROM   
												(  
											  SELECT 
												 fci.Attn_ADDR, 
												 fci.Line1_ADDR, 
												 fci.Line2_ADDR, 
												 fci.City_ADDR, 
												 fci.State_ADDR, 
												 fci.Zip_ADDR, 
												 fci.Country_ADDR, 
												 fci.BeginValidity_DATE ,
												 fci.LAST_KNOWN, 
												 fci.CURRENT_ADDRESS, 
												 fci.AddressAsOf_DATE
											  FROM 
												 (
													SELECT 
													   RTRIM(a.Attn_ADDR) + '' '' AS Attn_ADDR, 
													   RTRIM(a.Line1_ADDR) + '' '' AS Line1_ADDR, 
													   RTRIM(a.Line2_ADDR) + '' '' AS Line2_ADDR, 
													   RTRIM(a.City_ADDR) AS City_ADDR, 
													   '' '' + RTRIM(a.State_ADDR) + '' '' AS State_ADDR, 
													   RTRIM(a.Zip_ADDR) AS Zip_ADDR, 
													   '' '' + RTRIM(a.Country_ADDR) AS Country_ADDR,
													   a.BeginValidity_DATE,
													   CASE WHEN a.MemberAddress_CODE =''L'' THEN ''X'' ELSE '''' END LAST_KNOWN,
													   CASE WHEN a.MemberAddress_CODE =''L'' THEN ''C'' ELSE '''' END CURRENT_ADDRESS,
													   a.AddressAsOf_DATE,
													   ROW_NUMBER() OVER(PARTITION BY a.MemberMci_IDNO
														  ORDER BY a.TypeAddress_CODE, a.Update_DTTM DESC) AS ROW_NUMBER
													FROM APAH_Y1  AS a
													WHERE 
													   a.MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS CHAR) + ' AND 
													   a.TypeAddress_CODE IN ( ''' + @Ls_Mailing_ADDR + ''',
																			   ''' + @Ls_TypeAddress_PrmyResidence_CODE + ''', 
																			   ''' + @Ls_TypeAddress_SecResidence_CODE + ''') AND 
													   ''' + CAST(@Ad_Run_DATE AS VARCHAR) + '''>= a.BeginValidity_DATE AND 
													   ''' + CAST(@Ad_Run_DATE AS VARCHAR) + '''< a.EndValidity_DATE
												 )  AS fci
											   WHERE fci.ROW_NUMBER = 1)A
											   ) up  
											 UNPIVOT   
											 (tag_value FOR tag_name IN (' + @As_Prefix_TEXT + '_ATTN_ADDR,  
																		 ' + @As_Prefix_TEXT + '_LINE1_ADDR ,    
																		 ' + @As_Prefix_TEXT + '_LINE2_ADDR ,  
																		 ' + @As_Prefix_TEXT + '_CITY_ADDR,
																		 ' + @As_Prefix_TEXT + '_STATE_ADDR,  
																		 ' + @As_Prefix_TEXT + '_ZIP_ADDR ,    
																		 ' + @As_Prefix_TEXT + '_COUNTRY_ADDR ,        
																		 ' + @As_Prefix_TEXT + '_ADDR_BEG_DT,        
																		 ' + @As_Prefix_TEXT + '_LAST_ADDR_INDC,  
																		 ' + @As_Prefix_TEXT + '_CURRENT_ADDR_INDC,
																		 ' + @As_Prefix_TEXT + '_CURRENT_ADDR
																		))  
											 AS pvt)';

    EXEC(@Ls_SQLString_TEXT)

    IF @@ROWCOUNT = 0
     BEGIN
      SET @Ac_Msg_CODE = @Ls_StatusNoDataFound_CODE;
      RAISERROR(50001,16,1);
     END
    ELSE
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   END TRY

   BEGIN CATCH
    IF @Ac_Msg_CODE = @Ls_StatusNoDataFound_CODE
     BEGIN
      BEGIN TRY
      
       SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1'
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO =' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR), '')
      
       SET @Ls_SQLString_TEXT = 'INSERT INTO #NoticeElementsData_P1(Element_NAME,ELEMENT_VALUE)
												   (SELECT tag_name, tag_value FROM  
													   (   
													   SELECT    
														CONVERT(VARCHAR(100),Attn_ADDR) ' + @As_Prefix_TEXT + '_ADDR_ATTN,  
														CONVERT(VARCHAR(100),Line1_ADDR) ' + @As_Prefix_TEXT + '_ADDR_LINE1 ,    
														CONVERT(VARCHAR(100),Line2_ADDR) ' + @As_Prefix_TEXT + '_ADDR_LINE2 ,  
														CONVERT(VARCHAR(100),City_ADDR) ' + @As_Prefix_TEXT + '_ADDR_CITY,
														CONVERT(VARCHAR(100),State_ADDR) ' + @As_Prefix_TEXT + '_ADDR_ST,  
														CONVERT(VARCHAR(100),Zip_ADDR) ' + @As_Prefix_TEXT + '_ADDR_ZIP ,    
														CONVERT(VARCHAR(100),Country_ADDR) ' + @As_Prefix_TEXT + '_ADDR_CNTRY ,  
														CONVERT(VARCHAR(100),BeginValidity_DATE) ' + @As_Prefix_TEXT + '_ADDR_BEG_DT,  
														CONVERT(VARCHAR(100),LAST_KNOWN) ' + @As_Prefix_TEXT + '_LAST_ADDR_INDC,  
														CONVERT(VARCHAR(100),CURRENT_ADDRESS) ' + @As_Prefix_TEXT + '_CURRENT_ADDR_INDC,
														CONVERT(VARCHAR(100),AddressAsOf_DATE) ' + @As_Prefix_TEXT + '_CURRENT_ADDR									
													   FROM   
														(  
													   SELECT 
														  fci.Attn_ADDR, 
														  fci.Line1_ADDR, 
														  fci.Line2_ADDR, 
														  fci.City_ADDR, 
														  fci.State_ADDR, 
														  fci.Zip_ADDR, 
														  fci.Country_ADDR, 
														  fci.BeginValidity_DATE ,
														  fci.LAST_KNOWN, 
														  fci.CURRENT_ADDRESS, 
														  fci.AddressAsOf_DATE
													   FROM 
														  (
														 SELECT 
															RTRIM(a.Attn_ADDR) + '' '' AS Attn_ADDR, 
														    RTRIM(a.Line1_ADDR) + '' '' AS Line1_ADDR, 
														    RTRIM(a.Line2_ADDR) + '' '' AS Line2_ADDR, 
														    RTRIM(a.City_ADDR) AS City_ADDR, 
														    '' '' + RTRIM(a.State_ADDR) + '' '' AS State_ADDR, 
														    RTRIM(a.Zip_ADDR) AS Zip_ADDR, 
														    '' '' + RTRIM(a.Country_ADDR) AS Country_ADDR,
															a.BeginValidity_DATE,
															CASE WHEN a.MemberAddress_CODE =''L'' THEN ''X'' ELSE '''' END LAST_KNOWN,
															CASE WHEN a.MemberAddress_CODE =''L'' THEN ''C'' ELSE '''' END CURRENT_ADDRESS,
															a.AddressAsOf_DATE, 
															ROW_NUMBER() OVER(PARTITION BY a.MemberMci_IDNO
															   ORDER BY a.TypeAddress_CODE, 
																		a.Update_DTTM DESC) AS ROW_NUMBER
														 FROM APAH_Y1  AS a
														 WHERE 
															a.MemberMci_IDNO = ''' + CAST(@An_MemberMci_IDNO  AS CHAR)+ ''' AND 
															a.TypeAddress_CODE IN ( ''' + @Ls_Mailing_ADDR + ''',	
																					''' + @Ls_TypeAddress_PrmyResidence_CODE + ''', 
																					''' + @Ls_TypeAddress_SecResidence_CODE + ''' )
																												  )  AS fci
												   WHERE fci.ROW_NUMBER = 1)a
													) up  
													 UNPIVOT   
													 (tag_value FOR tag_name IN (' + @As_Prefix_TEXT + '_ADDR_ATTN,
																				 ' + @As_Prefix_TEXT + '_ADDR_LINE1 ,
																				 ' + @As_Prefix_TEXT + '_ADDR_LINE2 ,
																				 ' + @As_Prefix_TEXT + '_ADDR_CITY,
																				 ' + @As_Prefix_TEXT + '_ADDR_ST,
																				 ' + @As_Prefix_TEXT + '_ADDR_ZIP ,
																				 ' + @As_Prefix_TEXT + '_ADDR_CNTRY ,        
																				 ' + @As_Prefix_TEXT + '_ADDR_BEG_DT,        
																				 ' + @As_Prefix_TEXT + '_LAST_ADDR_INDC,  
																				 ' + @As_Prefix_TEXT + '_CURRENT_ADDR_INDC,
																				 ' + @As_Prefix_TEXT + '_CURRENT_ADDR
																				))  
													 AS pvt)'

       EXEC(@Ls_SQLString_TEXT)

       IF @@ROWCOUNT > 0
			BEGIN
			 SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
			END
       ELSE
		   BEGIN
			 SET @Ac_Msg_CODE  = 'E0058'
			 RETURN;
			END
      END TRY

      BEGIN CATCH
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

       IF ERROR_NUMBER () = 50001
        BEGIN
         SET @Ls_Err_Description_TEXT = 'CCRT :: Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + ISNULL(@Ls_ErrorDesc_TEXT ,'') + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
        END
       ELSE
        BEGIN
         SET @Ls_Err_Description_TEXT = 'CCRT :: Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
        END

       SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
      END CATCH
     END
   END CATCH
  
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'CCRT :: Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + ISNULL(@Ls_ErrorDesc_TEXT ,'') + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'CCRT :: Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END
 

GO
