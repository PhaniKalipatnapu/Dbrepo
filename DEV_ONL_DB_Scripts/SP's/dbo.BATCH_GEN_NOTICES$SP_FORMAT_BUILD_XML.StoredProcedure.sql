/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML is common procedure to generate XML for all notices
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML]
      @Ac_Notice_ID				CHAR(8),
      @An_Case_IDNO				NUMERIC(6) ,     
      @Ac_Worker_ID				CHAR(30),
      @An_MemberMci_IDNO		NUMERIC(10)	= 0,
	  @An_OthpSource_IDNO		NUMERIC(10)	= 0,
	  @Ac_ActivityMajor_CODE	CHAR(4),
	  @Ac_ActivityMinor_CODE	CHAR(5),
	  @Ac_Reason_CODE			CHAR(2),
	  @An_Barcode_NUMB		    NUMERIC(12),
      @As_XML_Result_TEXT		VARCHAR(MAX)	OUTPUT, 
      @Ac_Msg_CODE				VARCHAR(5)		OUTPUT,
      @As_DescriptionError_TEXT	VARCHAR(MAX)	OUTPUT    

AS

BEGIN 
  
 SET NOCOUNT ON;
		    DECLARE @NoticeElementsData_P1 TABLE(
                   Element_NAME  VARCHAR(150),
                   Element_VALUE VARCHAR(MAX)
               ); 
	DECLARE 
            
			  @Ls_SQLString_TEXT				NVARCHAR(MAX),
			  @Ls_SQLDynParameterString_TEXT	NVARCHAR(MAX),
			  @Ls_ParmDefinition_TEXT			NVARCHAR(MAX),
			  @Ls_SQLProcName_TEXT				VARCHAR(75),
			  @Ls_SQLDynProcName_TEXT			VARCHAR(75),
			  @Ls_Result_TEXT					VARCHAR(MAX),
			  @Lc_Error_CODE					CHAR(4),
			  @Ls_Routine_TEXT					VARCHAR(75)		='BATCH_GEN_NOTICES$SP_GET_DATA_FOR_FORMATTING',
			  @Ls_EleFormat_CODE				VARCHAR(100),
			  @Lc_StatusSuccess_CODE			CHAR			= 'S',
			  @Lc_StatusFailed_CODE				CHAR			= 'F',
			  @Ls_Sql_TEXT						VARCHAR(1000)	= ' ',
			  @Ls_Sqldata_TEXT					VARCHAR(100)	= ' ',
			  @Ls_RequiredInputs_TEXT			VARCHAR(4000) = '',
			  @Ls_DescriptionError_TEXT			VARCHAR(4000),
			  @Ls_ErrorDesc_TEXT				VARCHAR(4000);  
        
           	BEGIN TRY
           		
				IF @An_Barcode_NUMB = 0 OR @An_Barcode_NUMB IS NULL
					BEGIN
					
						SET @Ls_Sql_TEXT = 'Checking Required Inputs';
						
						SELECT @Ls_RequiredInputs_TEXT =  (Select Element_name as Element_NAME,  
												  'E1081' As Error_CODE,  
												  'Input Value Missing' as Error_DESC  
												 FROM @NoticeElementsData_P1   
												 WHERE Element_NAME IN   
															  (SELECT Element_name   
															     FROM NDEL_Y1   
															    Where Notice_ID = @Ac_Notice_ID   
															     AND Input_CODE = 'I'  
															     AND Element_NAME NOT IN ('Swks_Member_IDNO',   
																						  'Swks_Worker_ID',  
																						  'DT_HEARING',  
																						  'HEARING_TIME',  
																						  'Location_IDNO')
															  )
												  AND Element_NAME NOT IN ('Transaction_DATE',   
																		   'OthpStateFips_CODE',  
																		   'TransOtherState_INDC',  
																		   'TransHeader_IDNO',
																		   'ivdoutofstatefips_code',
																		   'request_idno')
												 AND (Element_Value = '' OR Element_Value IS NULL)
												 FOR XML PATH('row'));  
 
							   IF @Ls_RequiredInputs_TEXT <> ''  
								BEGIN  
								 SET @Ac_Msg_CODE = 'E1081'  
								 SET @As_DescriptionError_TEXT = '<' + LTRIM(RTRIM(@Ac_Notice_ID)) +'>'+ @Ls_RequiredInputs_TEXT + '</' + LTRIM(RTRIM(@Ac_Notice_ID)) +'>';  
								 RETURN;  
								END  
								
						IF @Ac_Notice_ID LIKE 'INT-%'
							BEGIN
									SET @Ls_Sql_TEXT = 'EXEC BATCH_GEN_NOTICES$SP_INSERT_INPUTS';
									
									EXEC BATCH_GEN_NOTICES$SP_INSERT_INPUTS
												@Ac_Notice_ID				= @Ac_Notice_ID,
												@An_Case_IDNO				= @An_Case_IDNO ,
												@Ac_Worker_ID				= @Ac_Worker_ID,
												@An_MemberMci_IDNO			= @An_MemberMci_IDNO,
												@An_OthpSource_IDNO			= @An_OthpSource_IDNO,
												@Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT,
												@As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT;
									
									IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
										BEGIN
											RETURN;
										END
								END
						
					END
				
				UPDATE #NoticeElementsData_P1
				   SET Element_VALUE = REPLACE(REPLACE(REPLACE(REPLACE(Element_VALUE,'&', '&amp;'),'~~', ''''),'&amp;lt;','&lt;'),'&amp;gt;','&gt;')  
				 WHERE Element_name != 'applicationncp_list'
				   AND Element_NAME IN (SELECT Element_NAME
										  FROM NDEL_Y1
										 WHERE Notice_ID = @Ac_Notice_ID
										   AND TypeElement_CODE = 'M');
				
				EXEC BATCH_GEN_NOTICES$SP_GET_NOTICE_ELEMENT_DATA
							@Ac_Notice_ID				= @Ac_Notice_ID,
							@Ac_ActivityMajor_CODE		= @Ac_ActivityMajor_CODE,
							@Ac_ActivityMinor_CODE		= @Ac_ActivityMinor_CODE,
							@Ac_Reason_CODE				= @Ac_Reason_CODE,
							@An_Barcode_NUMB			= @An_Barcode_NUMB,
							@As_Result_TEXT				= @Ls_Result_TEXT OUTPUT,
							@Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT,
							@As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT;
				
				IF @Ac_Msg_CODE = 'F' 
					BEGIN
						RETURN;
					END
				  

 INSERT INTO @NoticeElementsData_P1 --VALUES(Element_NAME,Element_VALUE)
                              SELECT Element_NAME,Element_VALUE FROM #NoticeElementsData_P1;

				UPDATE @NoticeElementsData_P1
				   SET Element_VALUE = ''
				 WHERE Element_NAME IN (SELECT Element_NAME
										  FROM RARE_Y1
										 WHERE ActivityMajor_CODE = @Ac_ActivityMajor_CODE
										   AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
										   AND Reason_CODe = @Ac_Reason_CODE
										   AND Notice_ID = @Ac_Notice_ID
										   AND Required_INDC = 'N');
				
				
				-- Making all the elements to lower case to generate the xml elements in lower case
				UPDATE @NoticeElementsData_P1
				   SET Element_Name = LOWER(Element_Name);
				
				UPDATE @NoticeElementsData_P1
				   SET Element_VALUE = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Element_VALUE,'<','&lt;'),'>','&gt;'), '&', '&amp;'),'~~', ''''),'&amp;lt;','&lt;'),'&amp;gt;','&gt;')  
				 WHERE Element_name != 'applicationncp_list'
				   AND Element_NAME IN (SELECT Element_NAME
										  FROM NDEL_Y1
										 WHERE Notice_ID = @Ac_Notice_ID
										   AND TypeElement_CODE = 'S')
				   AND Element_NAME != 'estampnotary_text';
				
				
				-- Suppressing Country if it is US
				UPDATE @NoticeElementsData_P1
				   SET Element_VALUE = ''
				 WHERE Element_NAME LIKE '%_country_addr'
				   AND LTRIM(RTRIM(Element_VALUE)) = 'US';
				 
			    UPDATE @NoticeElementsData_P1
				   SET Element_VALUE = '0.00'
				 WHERE 
				    (Element_NAME like 'recentorderexpecttopay_amnt%' 
				    OR Element_NAME like 'total_arrears_%')
				    AND Element_VALUE='';
				
				
				-- To make the value empty when the element value contains CHAR(0)
				UPDATE @NoticeElementsData_P1
				   SET Element_VALUE = ''
				 WHERE Element_VALUE LIKE '%' + CHAR(0) + '%';
				
						      TRUNCATE TABLE #NoticeElementsData_P1;
                              
                              INSERT INTO #NoticeElementsData_P1 --VALUES(Element_NAME,Element_VALUE)
                              SELECT Element_NAME,Element_VALUE FROM @NoticeElementsData_P1;
				EXEC BATCH_GEN_NOTICES$SP_BUILD_XML
							@As_Subelements_TEXT		= @Ls_Result_TEXT,
							@As_Result_TEXT				= @Ls_Result_TEXT OUTPUT,
							@Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT,
							@As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;
				
				IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
					BEGIN
						SET @As_XML_Result_TEXT = @Ls_Result_TEXT;
						
						RETURN;
					END
				
				-- Below 2 replacement statements added for convinience of CSI-01 notice
				IF @An_Barcode_NUMB = 0
					BEGIN
						SELECT @Ls_Result_TEXT = REPLACE(REPLACE( @Ls_Result_TEXT, '<applicationncp_list>',''), '</applicationncp_list>', '');
						SELECT @Ls_Result_TEXT = REPLACE(REPLACE( @Ls_Result_TEXT, '<applicationncp_list1','<applicationncp_list'), '</applicationncp_list1>', '</applicationncp_list>');
					END
				
				SET @As_XML_Result_TEXT = @Ls_Result_TEXT;
				
				SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
				
		END TRY
		BEGIN CATCH
			 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE ;
					SET @Ls_Sql_TEXT='Error building XML  ';;
						     
							 IF ERROR_NUMBER () = 50001
								BEGIN
									SET @Ls_DescriptionError_TEXT =
										'Error IN '
									  + ISNULL(ERROR_PROCEDURE(),'BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML')
									  + ' PROCEDURE'
									  + '. Error DESC - '
									  + @Ls_ErrorDesc_TEXT
									  + '. Error EXECUTE Location - '
									  + @Ls_Sql_TEXT
									  + '. Error List KEY - '
									  + @Ls_Sqldata_TEXT;
								END
							ELSE
								BEGIN
									SET @Ls_DescriptionError_TEXT =
										'Error IN '
									  +ISNULL( ERROR_PROCEDURE (),'BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML')
									  + ' PROCEDURE'
									  + '. Error DESC - '
									  + SUBSTRING (ERROR_MESSAGE (), 1, 200)
									  + '. Error Line No - '
									  + CAST (ERROR_LINE () AS VARCHAR)
									  + '. Error Number - '
									  + CAST (ERROR_NUMBER () AS VARCHAR)
									  + '. Error EXECUTE Location - '
									  + @Ls_Sql_TEXT
									  + '. Error List KEY - '
									  + @Ls_Sqldata_TEXT;
					            
								END

					SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
	
	END CATCH	
			
END



GO
