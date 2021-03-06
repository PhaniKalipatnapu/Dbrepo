/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get FIPS recipient details from FIPS_Y1
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS](
 @Ac_Fips_CODE             CHAR(7),
 @As_Prefix_TEXT           VARCHAR(70),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT)
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusSuccess_CODE            CHAR = 'S',
           @Lc_StatusFailed_CODE             CHAR = 'F',
           @Lc_Oth_county_CODE_fips00_TEXT   CHAR(2) = '00',
           @Lc_state_fips_CODE_us_max_TEXT   CHAR(2) = '99',
           @Ls_IVDOutOfStateFips_Tribal_CODE CHAR(2) = '90',
           @Lc_TypeAddress_state_TEXT        CHAR(3) = 'STA',
           @Lc_Oth_county_CODE_fips_TEXT     CHAR(3) = '000',
           @Lc_Oth_county_CODE_fipsC01_TEXT  CHAR(3) = 'C01',
           @Lc_Int_TypeAddress_CODE          CHAR(3) = 'INT',
           @Lc_Int_TypeAddressSub_CODE       CHAR(3) = 'FRC',
           @Lc_SubTypeAddress_CODE_crg_TEXT  CHAR(3) = 'CRG',
           @Lc_TypeAddress_CODE_locate_TEXT  CHAR(3) = 'LOC',
           @Lc_TypeAddress_Trb_CODE			 CHAR(3) = 'TRB',
           @Lc_Sub_TypeAddress_T01_CODE		 CHAR(3) = 'T01',
           @Ls_Routine_TEXT                  VARCHAR(60) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS',
           @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE  @Ls_Sqldata_TEXT           VARCHAR(400),
           @Ls_Sql_TEXT               VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000);

 DECLARE @Ndel_P1 TABLE(Element_NAME    VARCHAR(100),
					 Element_Value   VARCHAR(100));           
          		  

  BEGIN TRY
   SET @As_DescriptionError_TEXT='';
      IF @As_Prefix_TEXT IS NULL OR @As_Prefix_TEXT = ''
      BEGIN
            SET @As_Prefix_TEXT = 'SDU';
      END
							
   SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1 ';
   SET @Ls_Sqldata_TEXT = ' Recipient_ID: ' + ISNULL(@Ac_Fips_CODE, '');
	   INSERT INTO @Ndel_P1(Element_NAME, ELEMENT_VALUE)
			( SELECT pvt.Element_NAME, pvt.ELEMENT_VALUE FROM      
				(  SELECT        
					CONVERT(VARCHAR(100),a.ContactTitle_NAME) Title_NAME,   
					CONVERT(VARCHAR(100),a.Fips_NAME) NAME,
					CONVERT(VARCHAR(100),a.State_NAME) STATE_NAME,
					CONVERT(VARCHAR(100),a.Fips_code) Fips_CODE,         
					CONVERT(VARCHAR(100),a.Line1_ADDR) Line1_ADDR,     
					CONVERT(VARCHAR(100),a.Line2_ADDR) Line2_ADDR,  
					CONVERT(VARCHAR(100),a.City_ADDR) City_ADDR,
					CONVERT(VARCHAR(100),a.State_ADDR) State_ADDR,  
					CONVERT(VARCHAR(100),a.Zip_ADDR) Zip_ADDR,
					CONVERT(VARCHAR(100),a.Country_ADDR) Country_ADDR,   
					CONVERT(VARCHAR(100),a.Phone_NUMB) Phone_NUMB,    
					CONVERT(VARCHAR(100),a.Fax_NUMB) Fax_NUMB               
				FROM (   SELECT f.ContactTitle_NAME ,  
								RTRIM(f.Fips_NAME) + ' ' AS Fips_NAME,  
								RTRIM(f.Line1_ADDR) + ' ' AS Line1_ADDR,  
								f.Fips_CODE ,    
								RTRIM(f.Line2_ADDR) + ' ' AS Line2_ADDR,  
								RTRIM(f.City_ADDR) + ' ' AS City_ADDR,  
								' ' + RTRIM(f.State_ADDR) + ' ' AS State_ADDR,    
								RTRIM(f.Zip_ADDR) AS Zip_ADDR,  
								' ' + RTRIM(f.Country_ADDR) AS Country_ADDR, 
								f.Phone_NUMB ,  
								f.Fax_NUMB,
								(SELECT State_NAME FROM STAT_Y1 WHERE StateFips_CODE = f.StateFips_CODE) State_NAME
					 FROM FIPS_Y1  f    
					WHERE f.Fips_CODE  = @Ac_Fips_CODE 
					AND (( f.TypeAddress_CODE  =  @Lc_TypeAddress_state_TEXT 
					AND f.SubTypeAddress_CODE  = @Lc_SubTypeAddress_CODE_crg_TEXT
					AND (SUBSTRING(CAST(@Ac_Fips_CODE AS VARCHAR), 3, 3) = @Lc_Oth_county_CODE_fips_TEXT
						OR SUBSTRING(CAST(@Ac_Fips_CODE AS VARCHAR), 3, 3) IS NULL    
						)   
					AND ( SUBSTRING(CAST(@Ac_Fips_CODE AS VARCHAR), 6, 2) = @Lc_Oth_county_CODE_fips00_TEXT
						OR SUBSTRING(CAST(@Ac_Fips_CODE AS VARCHAR), 6, 2) IS NULL    
						)    
					)     
					OR (    f.TypeAddress_CODE  = @Lc_TypeAddress_CODE_locate_TEXT
					AND f.SubTypeAddress_CODE  = @Lc_Oth_county_CODE_fipsC01_TEXT
					AND (SUBSTRING(CAST(@Ac_Fips_CODE AS VARCHAR), 3, 5) <> @Lc_Oth_county_CODE_fips_TEXT
						OR SUBSTRING(CAST(@Ac_Fips_CODE AS VARCHAR), 3, 5) IS NOT NULL    
					)    
					)    
					OR (f.StateFips_CODE  > @Lc_state_fips_CODE_us_max_TEXT
					AND f.TypeAddress_CODE  = @Lc_Int_TypeAddress_CODE
					AND f.SubTypeAddress_CODE  = @Lc_Int_TypeAddressSub_CODE
					)    
					OR (f.StateFips_CODE  = @Ls_IVDOutOfStateFips_Tribal_CODE
					AND f.TypeAddress_CODE  = @Lc_TypeAddress_Trb_CODE
					AND f.SubTypeAddress_CODE  = @Lc_Sub_TypeAddress_T01_CODE
					)    
						)AND f.EndValidity_DATE  = @Ld_High_DATE
					)a    
		)pvt    
			UNPIVOT       
		(ELEMENT_VALUE FOR Element_NAME IN (Title_NAME,   
											NAME,
											STATE_NAME,
											Fips_CODE, 
											Line1_ADDR,
											Line2_ADDR,     
											City_ADDR,
											State_ADDR,
											Zip_ADDR,
											Country_ADDR,
											Phone_NUMB,    
											Fax_NUMB))      
		AS pvt);
		
	 INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)	
		SELECT RTRIM(@As_Prefix_TEXT) +'_'+ T.Element_NAME as Element_NAME, T.Element_Value
		  FROM @Ndel_P1 T;  					
		
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
	BEGIN CATCH
		  DECLARE @Li_Error_NUMB			   INT = ERROR_NUMBER (),
				  @Li_ErrorLine_NUMB		   INT =  ERROR_LINE ();

			 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
			 
			 IF (@Li_Error_NUMB <> 50001)
				BEGIN
				   SET @As_DescriptionError_TEXT =
						  SUBSTRING (ERROR_MESSAGE (), 1, 200);
				END
			 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
														   @As_ErrorMessage_TEXT = @As_DescriptionError_TEXT,
														   @As_Sql_TEXT = @Ls_Sql_TEXT,
														   @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
														   @An_Error_NUMB = @Li_Error_NUMB,
														   @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
														   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

			 SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
	 END CATCH
 END


GO
