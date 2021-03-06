/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS]
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_TypeAddress_CODE	   CHAR(1) = '',
 @Ad_Run_DATE              DATE,
 @As_Prefix_TEXT           VARCHAR(70),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT  CHAR(1) = ' ',
		   @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_VerificationStatusGood_CODE  CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_Mailing_ADDR                 CHAR(1) = 'M',
		   @Lc_Court_ADDR                   CHAR(1) = 'C',
           @Lc_TypeAddress_Residence_CODE   CHAR(1) = 'R',
           @Lc_StatusPending_CODE           CHAR(1) = 'P',
		   @Lc_CheckBox_Value               CHAR(1) = 'X',
		   @Lc_Empty_Value                  CHAR(1) = '',
		   @Lc_Cp_TEXT						CHAR(2) = 'CP',
		   @Lc_LegNotice_TEXT				CHAR(5) = 'LEG-%',
		   @Lc_NoticeLeg329_ID				CHAR(7) = 'LEG-329',
		   @Lc_NoticeLeg329L_ID				CHAR(8) = 'LEG-329L',
		   @Lc_Ncp_TEXT						CHAR(3) = 'NCP',
           @Lc_Notice_ID_LOC_01				CHAR(8) = 'LOC-01',
		   @Lc_Element_Notice_ID		    CHAR(12) = 'Notice_ID',
           @Lc_Notice_ID                    CHAR(8),
           @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS';

  DECLARE  @Li_Error_NUMB   		 INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB        INT =  ERROR_LINE ();

  DECLARE  @Ln_Record_QNTY           NUMERIC(2),
           @Ls_Sql_TEXT              VARCHAR(200) = '',
           @Ls_ErrorDesc_TEXT        VARCHAR(400) = '',
           @Ls_Sqldata_TEXT          VARCHAR(400) = '',
           @Ls_Err_Description_TEXT  VARCHAR(4000) = '',
           @Ld_Run_DATE              DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Run_DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

   IF LTRIM(RTRIM(@As_Prefix_TEXT)) IS NULL
       OR LTRIM(RTRIM(@As_Prefix_TEXT)) = ''
    BEGIN
     SET @As_Prefix_TEXT = 'MEM_';
    END
  
      SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';
      SET @Ls_Sqldata_TEXT = 'Recipient_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '');
      
      SELECT @Lc_Notice_ID = LTRIM(RTRIM(Element_Value)) 
		FROM #NoticeElementsData_P1 
	  WHERE Element_NAME =@Lc_Element_Notice_ID
    
      DECLARE @NoticeElements_P1 TABLE
			( Element_NAME   VARCHAR(100),
			  Element_Value VARCHAR(100)
			);
			
	  INSERT INTO @NoticeElements_P1
		   (Element_NAME,
			Element_Value)
				   (SELECT pvt.Element_NAME, 
						  pvt.Element_Value 
						  FROM  
					   (   
					   SELECT    
						CONVERT(VARCHAR(100),a.Attn_ADDR) AS Attn_ADDR,  
						CONVERT(VARCHAR(100),a.Line1_ADDR)AS Line1_ADDR ,    
						CONVERT(VARCHAR(100),a.Line2_ADDR)AS Line2_ADDR ,  
						CONVERT(VARCHAR(100),a.City_ADDR) AS City_ADDR,
						CONVERT(VARCHAR(100),a.State_ADDR)AS State_ADDR,  
						CONVERT(VARCHAR(100),a.Zip_ADDR) AS Zip_ADDR ,    
						CONVERT(VARCHAR(100),a.Country_ADDR) AS Country_ADDR ,  
						CONVERT(VARCHAR(100),a.SourceLoc_CODE) AS Source_CODE,  
						CONVERT(VARCHAR(100),a.Begin_DATE) AS ADDR_BEG_DT,
						CONVERT(VARCHAR(100),a.Status_CODE)AS Verified_addr_INDC,
						CONVERT(VARCHAR(100),a.verified_addr_yes_indc) AS verified_addr_yes_indc,
						CONVERT(VARCHAR(100),a.verified_addr_no_indc) AS verified_addr_no_indc,
						CONVERT(VARCHAR(100),a.Status_DATE) AS Addr_verified_DATE,
						CONVERT(VARCHAR(100),a.MailingAddress_CODE) AS MailingAddress_CODE,
						CONVERT(VARCHAR(100),a.ResidencialAddress_CODE) AS  ResidencialAddress_CODE,
						CONVERT(VARCHAR(100),a.lkcAddress_CODE) AS lkcAddress_CODE
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
						  fci.SourceLoc_CODE, 
						  fci.Begin_DATE, 
						  fci.Status_CODE,
						  CASE WHEN fci.Status_CODE = @Lc_VerificationStatusGood_CODE THEN @Lc_CheckBox_Value
							   ELSE ''
						  END verified_addr_yes_indc,
						  CASE WHEN fci.Status_CODE != @Lc_VerificationStatusGood_CODE THEN @Lc_CheckBox_Value
							   ELSE ''
						  END verified_addr_no_indc,
						  fci.Status_DATE,
						  CASE WHEN fci.Typeaddress_CODE = @Lc_Mailing_ADDR THEN @Lc_CheckBox_Value ELSE @Lc_Empty_Value END MailingAddress_CODE,
						  CASE WHEN fci.Typeaddress_CODE = @Lc_TypeAddress_Residence_CODE THEN @Lc_CheckBox_Value ELSE @Lc_Empty_Value END ResidencialAddress_CODE,
						  CASE WHEN fci.Typeaddress_CODE = @Lc_Court_ADDR THEN @Lc_CheckBox_Value ELSE @Lc_Empty_Value END lkcAddress_CODE
					   FROM 
						  (
							SELECT RTRIM(a.Attn_ADDR) + @Lc_Space_TEXT AS Attn_ADDR, 
								   RTRIM(a.Line1_ADDR) + @Lc_Space_TEXT AS Line1_ADDR, 
								   RTRIM(a.Line2_ADDR) + @Lc_Space_TEXT AS Line2_ADDR, 
								   RTRIM(a.City_ADDR) AS City_ADDR, 
								   @Lc_Space_TEXT  + RTRIM(a.State_ADDR) + @Lc_Space_TEXT AS State_ADDR, 
								   RTRIM(a.Zip_ADDR) AS Zip_ADDR, 
								   @Lc_Space_TEXT + RTRIM(a.Country_ADDR) AS Country_ADDR,
								   (
									 SELECT LSRC_Y1.Source_NAME
									   FROM LSRC_Y1
									  WHERE LSRC_Y1.SourceLoc_CODE = a.SourceLoc_CODE
								   ) AS SourceLoc_CODE, 
								   a.Begin_DATE, 
								   a.Status_CODE,
								   a.Status_DATE,
								   a.TypeAddress_CODE
							  FROM
								(SELECT a.*,
									   (CASE 
											 WHEN a.addr_hrchy < 7 THEN 1
											 ELSE 0
										END) Ind_ADDR
								  FROM
									  (SELECT ROW_NUMBER() OVER(PARTITION BY a.MemberMci_IDNO ORDER BY addr_hrchy, Status_CODE DESC,
																							TransactionEventSeq_NUMB DESC, Update_DTTM DESC) addr_rnm,
												  a.*
										FROM      
											(
											 -- 13384 - CPRO - CP Address issue on legal notices  Fix - Start
											SELECT 
											
													(CASE WHEN @Lc_Notice_ID LIKE @Lc_LegNotice_TEXT
														THEN
																CASE 
																	WHEN LTRIM(RTRIM(@As_Prefix_TEXT)) = @Lc_Cp_TEXT THEN
																       CASE WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE 
																			THEN 1
																			ELSE 8
																	   END
																	WHEN LTRIM(RTRIM(@As_Prefix_TEXT)) = @Lc_Ncp_TEXT THEN	
																	   CASE WHEN TypeAddress_CODE = @Lc_Court_ADDR 
																			 -- Bug:13826: CR0464 - The Respondent’s address on both the LEG-329 and LEG-329L should be the Confirmed Good Mailing Address -START
																			 AND  @Lc_Notice_ID NOT IN(@Lc_NoticeLeg329_ID,@Lc_NoticeLeg329L_ID)	
																		     -- Bug:13826: CR0464 - The Respondent’s address on both the LEG-329 and LEG-329L should be the Confirmed Good Mailing Address -END
																			 AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 1
																			 WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 2
																			 ELSE 8
																	   END
																 ELSE 
																	   CASE WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 1
																			WHEN TypeAddress_CODE = @Lc_TypeAddress_Residence_CODE AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 2
																			WHEN TypeAddress_CODE = @Lc_Court_ADDR AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 3
																			WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND Status_CODE  = @Lc_StatusPending_CODE AND a.End_DATE >= @Ad_Run_DATE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 4
																			WHEN TypeAddress_CODE = @Lc_TypeAddress_Residence_CODE AND Status_CODE  = @Lc_StatusPending_CODE AND a.End_DATE >= @Ad_Run_DATE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 5
																			WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND a.End_DATE < @Ad_Run_DATE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 6
																			WHEN TypeAddress_CODE = @Lc_TypeAddress_Residence_CODE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 7
																			ELSE 8
																	   END
																 END
														 ELSE 
														   CASE WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 1
																WHEN TypeAddress_CODE = @Lc_TypeAddress_Residence_CODE AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 2
																WHEN TypeAddress_CODE = @Lc_Court_ADDR AND Status_CODE  = @Lc_VerificationStatusGood_CODE AND a.End_DATE >= @Ad_Run_DATE THEN 3
																WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND Status_CODE  = @Lc_StatusPending_CODE AND a.End_DATE >= @Ad_Run_DATE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 4
																WHEN TypeAddress_CODE = @Lc_TypeAddress_Residence_CODE AND Status_CODE  = @Lc_StatusPending_CODE AND a.End_DATE >= @Ad_Run_DATE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 5
																WHEN TypeAddress_CODE = @Lc_Mailing_ADDR AND a.End_DATE < @Ad_Run_DATE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 6
																WHEN TypeAddress_CODE = @Lc_TypeAddress_Residence_CODE AND @Lc_Notice_ID = @Lc_Notice_ID_LOC_01 THEN 7
																ELSE 8
															END
														END) addr_hrchy,
														-- 13384 - CPRO - CP Address issue on legal notices Fix - End
													 a.*
											  FROM
												  (SELECT ROW_NUMBER() OVER(PARTITION BY a.MemberMci_IDNO ORDER BY  Status_CODE DESC,
																							TransactionEventSeq_NUMB DESC, Update_DTTM DESC) ronm,
														  a.*
													 FROM
														(SELECT ROW_NUMBER() OVER(PARTITION BY a.MemberMci_IDNO, TypeAddress_CODE ORDER BY Status_CODE DESC,
																							TransactionEventSeq_NUMB DESC, Update_DTTM DESC) rnm,
																	a.*
														  FROM
															  (SELECT a.*
																	FROM AHIS_Y1  a
																	WHERE a.MemberMci_IDNO  = @An_MemberMci_IDNO
																	AND (	(		@Ac_TypeAddress_CODE != @Lc_Empty_Value 
																				AND @Ac_TypeAddress_CODE IS NOT NULL 
																				AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE)
																		 OR (		(	@Ac_TypeAddress_CODE = @Lc_Empty_Value 
																					 OR @Ac_TypeAddress_CODE IS NULL 
																					)
																				AND a.TypeAddress_CODE IN (@Lc_Mailing_ADDR,
																										   @Lc_TypeAddress_Residence_CODE,
																										   @Lc_Court_ADDR) 
																			)
																		)
																	AND (   (		@Ad_Run_DATE BETWEEN a.Begin_DATE
																									 AND a.End_DATE
																				AND a.Status_CODE IN (@Lc_VerificationStatusGood_CODE , 
																											   @Lc_StatusPending_CODE )
																			)
																		 
																		  )
															  ) AS a
														) a
														WHERE rnm = 1
												  ) a
											) a
									  ) a
								WHERE addr_rnm = 1
								) a
						  WHERE Ind_ADDR = 1
						  )  AS fci
					   )a
					) up  
					 UNPIVOT   
					 (Element_Value FOR Element_NAME IN (Attn_ADDR,
												 Line1_ADDR,
												 Line2_ADDR,
												 City_ADDR,
												 State_ADDR,
												 Zip_ADDR,
												 Country_ADDR,        
												 Source_CODE,
												 ADDR_BEG_DT,
												 Verified_addr_INDC,
												 verified_addr_yes_indc,
												 verified_addr_no_indc,
												 Addr_verified_DATE,
												 MailingAddress_CODE,
												 ResidencialAddress_CODE,
												 lkcAddress_CODE
												))  
					 AS pvt);
						 
	  SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1'; 
	  SET @Ls_Sqldata_TEXT = '  ';	
	  			
      INSERT INTO #NoticeElementsData_P1
	   (Element_NAME,
		Element_Value)   
		 SELECT (LTRIM(RTRIM(@As_Prefix_TEXT)) + '_' + Element_NAME)AS Element_NAME , 
				Element_Value 
		  FROM @NoticeElements_P1;
   
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;  
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
   BEGIN
      SET @As_DescriptionError_TEXT =
       SUBSTRING (ERROR_MESSAGE (), 1, 200);
   END
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                @As_ErrorMessage_TEXT = @As_DescriptionError_TEXT,
                @As_Sql_TEXT = @Ls_Sql_TEXT,
                @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                @An_Error_NUMB = @Li_Error_NUMB,
                @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT ;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
