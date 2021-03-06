/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC   gets procedure names from ndel and executes them dynamically
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_GET_PROCEDURE_NAME
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC]
 @As_Proc_NAME             VARCHAR(75),
 @Ac_Msg_CODE              VARCHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ls_ErrorDesc_TEXT          				VARCHAR(4000),
          @Ls_Sql_TEXT                				VARCHAR(1000) = '',
          @Ls_Sqldata_TEXT            				VARCHAR(400) = '',
          @Ls_DescriptionError_TEXT   				VARCHAR(4000),
          @Ld_Run_DATE                				DATETIME2(0),
          @Ls_ErrorMesg_TEXT          				VARCHAR(4000),
          @Ls_Error_CODE              				VARCHAR(18),
          @Ls_Errorproc_NAME          				VARCHAR(75),
          @Ls_SQLString_TEXT          				NVARCHAR(MAX),
          @Ls_SQLParameterString_TEXT 				NVARCHAR(MAX),
          @Ls_ParmDefinition_TEXT     				NVARCHAR(MAX),
          @Ln_Case_IDNO               				NUMERIC(10),
          @Lc_Notice_ID               				CHAR(8),
          @Ln_MajorIntSeq_NUMB        				NUMERIC(5),
		  @Ln_MinorIntSeq_NUMB		  				NUMERIC(5),  
          @Lc_SwksWorker_ID           				CHAR(30),
          @Lc_Worker_ID               				CHAR(30),
          @Ln_MemberMci_IDNO          				NUMERIC(10),
          @Ln_CpMemberMci_IDNO        				NUMERIC(10),
          @Lc_CheckRecipient_ID       				CHAR(10),
          @Ln_MotherMci_IDNO          				NUMERIC(10),
          @Ln_FatherMci_IDNO          				NUMERIC(10),
          @Ln_CaretakerMci_IDNO       				NUMERIC(10),
          @Ln_NcpMemberMci_IDNO       				NUMERIC(10),
          @Ln_Application_IDNO        				NUMERIC(15),
          @Lc_File_ID                 				VARCHAR(15),
          @Lc_ActivityMinor_CODE      				CHAR(5),
		  @Lc_ActivityMajor_CODE      				CHAR(5),
          @Lc_Recipient_CODE          				CHAR(4),
          @Lc_Action_CODE             				CHAR(1),
          @Lc_Function_CODE           				CHAR(3),
          @Lc_Reason_CODE             				CHAR(5),
          @Lc_ReasonStatus_CODE       				CHAR(5),
          @Lc_StatusNotice_CODE       				CHAR(1),
          @Lc_Recipient_ID          				CHAR(10),
          @Ln_OrderSeq_NUMB               			NUMERIC(5) = 1,
          @Lc_TransOtherStateI_INDC   				CHAR(1) = 'I',
          @Lc_TransOtherState_INDC    				CHAR(1),
          @Ln_TransHeader_IDNO        				NUMERIC,
          @Lc_OthpStateFips_CODE      				VARCHAR(MAX),
          @Ld_Transaction_DATE        				DATETIME2,
          @Ln_OtherParty_IDNO         				VARCHAR(10),
          @Lc_TypeAddress_CODE        				CHAR(1),
          @Lc_StatusSuccess_CODE      				CHAR,
          @Ls_Routine_TEXT            				VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC',
          @Ld_High_DATE                             DATE = '12/31/9999',
          @Lc_StatusFailed_CODE       				CHAR,
          @Ls_Err_Description_TEXT    				VARCHAR(4000),
          @Lc_InitiatingFips_ID     				CHAR(7),
          @Ln_Office_IDNO             				NUMERIC(10),
          @Ls_Screen_NAME			  				VARCHAR(10),
          @GetRequired_Element_CUR	  				CURSOR,
          @GetFormat_Element_CUR					CURSOR,
          @Ls_Element_TEXT							VARCHAR(100),
          @Ls_ElementValue_TEXT						VARCHAR(MAX),
          @Ls_Ele_Format_CODE						VARCHAR(100),
          @Ls_Format_CODE							VARCHAR(10),
          @Lc_Mask_INDC								CHAR(1),
          @Ls_FormattedResult_TEXT					VARCHAR(MAX),
          @Ls_Element_NAME			  				VARCHAR(100), 
          @Ls_Element_VALUE			  				VARCHAR(400),
          @ReqElementsCount_NUMB	  				NUMERIC(2) = 0,
		  @Ls_e1081desc_text		  				VARCHAR(100),
		  @Lc_Fips_CODE               				CHAR(7),
          @Lc_Job_ID                  				CHAR(7) = '',
          @Lc_Reference_ID			  				CHAR(30),
          @Ln_OthpLocation_IDNO						NUMERIC(9),
		  @Ln_ElementGroupMinRequired_NUMB			NUMERIC(2),
		  @Ln_ElementGroupMaxRequired_NUMB			NUMERIC(2),
		  @RequiredElements_CUR						CURSOR,
		  @ElementGroup_NUMB						NUMERIC(5) = 0,
		  @Ln_SelectedElementsCount_NUMB			NUMERIC(5) = 0,
		  @Ln_OptionParentSeq_NUMB					NUMERIC(5) = 0,
		  @Ln_OptionSelectedElementsCount_NUMB		NUMERIC(5) = 0,
		  @Ln_ParentElementGroupMinRequired_NUMB	NUMERIC(5) = 0,
		  @Ln_ParentElementGroupMaxRequired_NUMB	NUMERIC(5) = 0,
		  @Ln_ParentGroupSelectedElementsCount_NUMB	NUMERIC(5) = 0,
		  @Ln_ParentSelectedElementCount_NUMB		NUMERIC(5) = 0,
		  @Lc_PrintMethod_CODE						CHAR(1),
		  @Ln_TransactionEventSeq_NUMB				NUMERIC(19);
 DECLARE  @Lc_Country_US_CODE						CHAR(2) = 'US',
		  @Lc_Country_CA_CODE						CHAR(2) = 'CA',
		  @Lc_Cnty_Ofic_Country_Addr				VARCHAR(100) = 'cnty_ofic_country_addr',
		  @Lc_Cnty_Ofic_State_Addr					VARCHAR(100) = 'cnty_ofic_state_addr',
		  @Lc_Cnty_Ofic_Zip_Addr					VARCHAR(100) = 'cnty_ofic_zip_addr',
		  @Lc_Cp_Emp_Country_Addr					VARCHAR(100) = 'cp_emp_country_addr',
		  @Lc_Cp_Emp_State_Addr						VARCHAR(100) = 'cp_emp_state_addr',
		  @Lc_Cp_Emp_Zip_Addr						VARCHAR(100) = 'cp_emp_zip_addr',
		  @Lc_Cp_Country_Addr						VARCHAR(100) = 'cp_country_addr',
		  @Lc_Cp_State_Addr							VARCHAR(100) = 'cp_state_addr',
		  @Lc_Cp_Zip_Addr							VARCHAR(100) = 'cp_zip_addr  ',
		  @Lc_Emp_Country_Addr						VARCHAR(100) = 'emp_country_addr ',
		  @Lc_Emp_State_Addr						VARCHAR(100) = 'emp_state_addr ',
		  @Lc_Emp_Zip_Addr							VARCHAR(100) = 'emp_zip_addr ',
		  @Lc_From_Agency_Country_Addr				VARCHAR(100) = 'from_agency_country_addr',
		  @Lc_From_Agency_State_Addr				VARCHAR(100) = 'from_agency_state_addr',
		  @Lc_From_Agency_Zip_Addr					VARCHAR(100) = 'from_agency_zip_addr',
		  @Lc_From_Agency_Sdu_Country_Addr		    VARCHAR(100) = 'from_agency_sdu_country_addr',
		  @Lc_From_Agency_Sdu_State_Addr			VARCHAR(100) = 'from_agency_sdu_state_addr',
		  @Lc_From_Agency_Sdu_Zip_Addr              VARCHAR(100) = 'from_agency_sdu_zip_addr',
		  @Lc_Genetic_Loc_Country_Addr				VARCHAR(100) = 'genetic_loc_country_addr',
		  @Lc_Genetic_Loc_State_Addr				VARCHAR(100) = 'genetic_loc_state_addr',
		  @Lc_Genetic_Loc_Zip_Addr					VARCHAR(100) = 'genetic_loc_zip_addr',
		  @Lc_Housing_Authority_Country_Addr		VARCHAR(100) = 'housing_authority_country_addr',
		  @Lc_Housing_Authority_State_Addr			VARCHAR(100) = 'housing_authority_state_addr',
		  @Lc_Housing_Authority_Zip_Addr			VARCHAR(100) = 'housing_authority_zip_addr',
		  @Lc_Ncp_Atty_Country_Addr					VARCHAR(100) = 'ncp_atty_country_addr',
		  @Lc_Ncp_Atty_State_Addr					VARCHAR(100) = 'ncp_atty_state_addr',
		  @Lc_Ncp_Atty_Zip_Addr						VARCHAR(100) = 'ncp_atty_zip_addr',
		  @Lc_Ncp_Country_Addr						VARCHAR(100) = 'ncp_country_addr ',
		  @Lc_Ncp_State_Addr						VARCHAR(100) = 'ncp_state_addr ',
		  @Lc_Ncp_Zip_Addr							VARCHAR(100) = 'ncp_zip_addr ',
		  @Lc_Ncp_Emp_Country_Addr					VARCHAR(100) = 'ncp_emp_country_addr',
		  @Lc_Ncp_Emp_State_Addr					VARCHAR(100) = 'ncp_emp_state_addr',
		  @Lc_Ncp_Emp_Zip_Addr						VARCHAR(100) = 'ncp_emp_zip_addr ',
		  @Lc_Ncp_Lkc_Country_Addr					VARCHAR(100) = 'ncp_lkc_country_addr',
		  @Lc_Ncp_Lkc_State_Addr					VARCHAR(100) = 'ncp_lkc_state_addr',
		  @Lc_Ncp_Lkc_Zip_Addr						VARCHAR(100) = 'ncp_lkc_zip_addr ',
		  @Lc_Ordered_Party_Empl_Country_Addr		VARCHAR(100) = 'ordered_party_empl_country_addr',
		  @Lc_Ordered_Party_Empl_State_Addr			VARCHAR(100) = 'ordered_party_empl_state_addr',
		  @Lc_Ordered_Party_Empl_Zip_Addr			VARCHAR(100) = 'ordered_party_empl_zip_addr',
		  @Lc_Ordered_Party_Country_Addr			VARCHAR(100) = 'ordered_party_country_addr',
		  @Lc_Ordered_Party_State_Addr				VARCHAR(100) = 'ordered_party_state_addr',
		  @Lc_Ordered_Party_Zip_Addr				VARCHAR(100) = 'ordered_party_zip_addr',
		  @Lc_Othp_Country_Addr						VARCHAR(100) = 'othp_country_addr',
		  @Lc_Othp_State_Addr						VARCHAR(100) = 'othp_state_addr',
		  @Lc_Othp_Zip_Addr							VARCHAR(100) = 'othp_zip_addr',
		  @Lc_Recipient_Country_Addr				VARCHAR(100) = 'recipient_country_addr',
		  @Lc_Recipient_State_Addr					VARCHAR(100) = 'recipient_state_addr',
		  @Lc_Recipient_Zip_Addr					VARCHAR(100) = 'recipient_zip_addr',
		  @Lc_To_Agency_Country_Addr				VARCHAR(100) = 'to_agency_country_addr',
		  @Lc_To_Agency_State_Addr					VARCHAR(100) = 'to_agency_state_addr',
		  @Lc_To_Agency_Zip_Addr					VARCHAR(100) = 'to_agency_zip_addr',
		  @Lc_To_Agency_Sdu_Country_Addr		    VARCHAR(100) = 'to_agency_sdu_country_addr',
		  @Lc_To_Agency_Sdu_State_Addr				VARCHAR(100) = 'to_agency_sdu_state_addr',
		  @Lc_To_Agency_Sdu_Zip_Addr                VARCHAR(100) = 'to_agency_sdu_zip_addr',
		  @Lc_Father_State_Addr     				VARCHAR(100) = 'father_state_addr',
		  @Lc_Father_Zip_Addr       				VARCHAR(100) = 'father_zip_addr',
		  @Lc_Father_Country_Addr   				VARCHAR(100) = 'father_country_addr',
		  @Lc_Mom_State_Addr        				VARCHAR(100) = 'mom_state_addr',
		  @Lc_Mom_Zip_Addr          				VARCHAR(100) = 'mom_zip_addr',
		  @Lc_Mom_Country_Addr      				VARCHAR(100) = 'mom_Country_addr',
		  @Lc_Caretaker_State_Addr  				VARCHAR(100) = 'caretaker_state_addr',
		  @Lc_Caretaker_Zip_Addr    				VARCHAR(100) = 'caretaker_zip_addr',
		  @Lc_Caretaker_Country_Addr				VARCHAR(100) = 'caretaker_country_addr';
		  
     DECLARE @NoticeElementsData_T1 TABLE(
           Element_NAME  VARCHAR(150),
           Element_VALUE VARCHAR(MAX)
       ); 

  SET @Lc_StatusFailed_CODE = 'F';
  SET @Lc_StatusSuccess_CODE = 'S';

  BEGIN TRY
 
       /*TEST START*/
                    INSERT INTO @NoticeElementsData_T1 --VALUES(Element_NAME,Element_VALUE)
                    SELECT Element_NAME,Element_VALUE FROM #NoticeElementsData_P1;
            /*TEST END*/
 
	   	   SET @Lc_Notice_ID = (SELECT DISTINCT      
								   Element_VALUE      
                                            FROM #NoticeElementsData_P1      
							 WHERE Element_NAME = 'NOTICE_ID');
    
		   SET @Lc_Recipient_ID = (SELECT DISTINCT      
										Element_VALUE      
                                                   FROM #NoticeElementsData_P1      
								  WHERE Element_NAME = 'Recipient_ID');
								  
		   SET @Lc_printMethod_CODE = (SELECT Element_VALUE  
			 FROM #NoticeElementsData_P1  
			WHERE Element_NAME = 'PrintMethod_CODE');  
	   
	   	   SELECT @Ls_e1081desc_text = DescriptionError_TEXT 
			FROM EMSG_Y1 
			 WHERE Error_CODE = 'E1081';

	
	-- Start of Handling Group Elements errors
	IF EXISTS (SELECT 1   
				 FROM NDEL_Y1   
				WHERE ElementGroup_NUMB <> 0   
				  AND OptionParentSeq_NUMB = 0
				  AND Procedure_NAME = @As_Proc_NAME   
				  AND Notice_ID = @Lc_Notice_ID  
				  AND Input_CODE = 'O' 
				  )   
		BEGIN  
			
	   	   SET @GetRequired_Element_CUR = CURSOR  FOR 
					SELECT ElementGroup_NUMB
					   FROM NDEL_Y1   
					  WHERE ElementGroup_NUMB <> 0
					    AND OptionParentSeq_NUMB = 0 
					    AND Procedure_NAME = @As_Proc_NAME   
						AND Notice_ID = @Lc_Notice_ID  
						AND Input_CODE = 'O'  
					  GROUP BY ElementGroup_NUMB;  
  
				OPEN @GetRequired_Element_CUR  
  
				FETCH NEXT FROM @GetRequired_Element_CUR INTO @ElementGroup_NUMB
  
				WHILE @@FETCH_STATUS = 0  
					BEGIN  
	   				   
	   				   -- Fetching the Minimum Required Elements number in a elements group
					   Select TOP 1 @Ln_ElementGroupMinRequired_NUMB = ElementGroupMinRequired_NUMB,
									@Ln_ElementGroupMaxRequired_NUMB = ElementGroupMaxRequired_NUMB 
						 FROM NDEL_Y1   
						WHERE Notice_ID = @Lc_Notice_ID  
						  AND Input_CODE = 'O'  
						  AND ElementGroup_NUMB = @ElementGroup_NUMB;
					    
						-- Fetching the Elements number which has the data in #NoticeElementsData_P1 table in a elements group
						SELECT @ReqElementsCount_NUMB = COUNT(Element_NAME)   
						  FROM #NoticeElementsData_P1   
						 WHERE Element_NAME IN (SELECT Element_NAME
												 FROM NDEL_Y1
												WHERE Notice_ID = @Lc_Notice_ID
												  AND Input_CODE = 'O'
												  AND ElementGroup_NUMB = @ElementGroup_NUMB
												  )  
						  AND (LTRIM(RTRIM(Element_Value)) != '' AND Element_Value IS NOT NULL);
					 
					 --select @As_Proc_NAME, @ElementGroup_NUMB, @ReqElementsCount_NUMB, @Ln_ElementGroupMinRequired_NUMB, @Ln_ElementGroupMaxRequired_NUMB
					 IF		@ReqElementsCount_NUMB NOT BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB
						AND @ReqElementsCount_NUMB = 0 AND @Lc_printMethod_CODE <> 'V'
						BEGIN
							
							-- Inserting Error for a group element
							INSERT INTO #NoticeErrors_P1   
							SELECT  DISTINCT  V.Element_NAME,  
											  'E1081' Msg_CODE,  
											  'No. of Check Boxes to be Checked are Minimum: ' + CAST(@Ln_ElementGroupMinRequired_NUMB AS VARCHAR) 
											+ ' And Maximum: ' + CAST(@Ln_ElementGroupMaxRequired_NUMB AS VARCHAR)
											+ ', but Checked are: ' + CAST(@ReqElementsCount_NUMB AS VARCHAR) + ' from procedure: ' + @As_Proc_NAME Error_DESC                
							  FROM NDEL_Y1 V    
							 WHERE v.Input_CODE = 'O'    
							   AND v.Notice_ID = @Lc_Notice_ID  
							   AND v.ElementGroup_NUMB = @ElementGroup_NUMB
							   AND (	EXISTS (  SELECT 1  
													FROM #NoticeElementsData_P1  
												   WHERE Element_NAME = v.Element_NAME  
													 AND (LTRIM(RTRIM(Element_Value)) = '' OR Element_Value IS NULL)
											   )
									OR NOT EXISTS(SELECT 1
													FROM #NoticeElementsData_P1
												   WHERE Element_NAME = v.Element_NAME )
								   );
						END
					FETCH NEXT FROM @GetRequired_Element_CUR INTO @ElementGroup_NUMB 
				 END
				
				CLOSE @GetRequired_Element_CUR  
  
				DEALLOCATE @GetRequired_Element_CUR  
		END 
	-- End of Handling Group Elements errors

    --13540 - Notices generated to foreign countries are failing Fix - Start
	-- Start of Handling Other than Group Elements errors
	INSERT INTO #NoticeErrors_P1   
	SELECT  DISTINCT  V.Element_NAME,  
					  'E1081' Msg_CODE,
					  @Ls_e1081desc_text + ' for procedure: ' + @As_Proc_NAME Error_DESC                  
	  FROM
		(SELECT V.Element_NAME
		  FROM NDEL_Y1 V    
		 WHERE v.Input_CODE = 'O'    
		   AND v.Required_INDC = 'Y'    
		   AND v.Notice_ID = @Lc_Notice_ID
		   AND v.ElementGroup_NUMB = 0
		   AND v.OptionParentSeq_NUMB = 0
		   AND v.Procedure_NAME = @As_Proc_NAME 
		EXCEPT
		SELECT 'to_agency_state_addr' 
		  FROM FIPS_Y1 
		 WHERE Fips_CODE = @Lc_Recipient_ID 
		   AND TypeAddress_CODE = 'INT' 
		   AND EndValidity_DATE = @Ld_High_DATE
		   AND State_ADDR = ''
		EXCEPT
			SELECT @Lc_Cnty_Ofic_State_Addr AS cnty_ofic_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Cnty_Ofic_Country_Addr
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                
            SELECT @Lc_Cnty_Ofic_Zip_Addr AS cnty_ofic_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Cnty_Ofic_Country_Addr
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
        EXCEPT
			SELECT @Lc_Cp_Emp_State_Addr AS cp_emp_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Cp_Emp_Country_Addr 
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
       	EXCEPT                 
            SELECT @Lc_Cp_Emp_Zip_Addr AS cp_emp_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Cp_Emp_Country_Addr 
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
        EXCEPT
			SELECT @Lc_Cp_State_Addr AS cp_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Cp_Country_Addr 
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Cp_Zip_Addr AS cp_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Cp_Country_Addr 
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)  
        EXCEPT
			SELECT @Lc_Emp_State_Addr  AS emp_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Emp_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Emp_Zip_Addr AS emp_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Emp_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
        EXCEPT
			SELECT @Lc_From_Agency_State_Addr  AS from_agency_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_From_Agency_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_From_Agency_Zip_Addr AS from_agency_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_From_Agency_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)  
        EXCEPT
			SELECT @Lc_Genetic_Loc_State_Addr  AS genetic_loc_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Genetic_Loc_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Genetic_Loc_Zip_Addr AS genetic_loc_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Genetic_Loc_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE) 
        EXCEPT
			SELECT @Lc_Housing_Authority_State_Addr  AS housing_authority_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Housing_Authority_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Housing_Authority_Zip_Addr AS housing_authority_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Housing_Authority_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
        EXCEPT
			SELECT @Lc_Ncp_Atty_State_Addr  AS ncp_atty_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Ncp_Atty_Country_Addr  
            AND Element_VALUE NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Ncp_Atty_Zip_Addr AS ncp_atty_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Ncp_Atty_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
        EXCEPT
			SELECT @Lc_Ncp_State_Addr   AS ncp_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Ncp_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Ncp_Zip_Addr AS ncp_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Ncp_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE) 
        EXCEPT
			SELECT @Lc_Ncp_Emp_State_Addr   AS ncp_emp_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Ncp_Emp_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Ncp_Emp_Zip_Addr AS ncp_emp_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Ncp_Emp_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)  
        EXCEPT
			SELECT @Lc_Ncp_Lkc_State_Addr   AS ncp_lkc_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Ncp_Lkc_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Ncp_Lkc_Zip_Addr AS ncp_lkc_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Ncp_Lkc_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
        EXCEPT
			SELECT @Lc_Ordered_Party_Empl_State_Addr   AS ordered_party_empl_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Ordered_Party_Empl_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Ordered_Party_Empl_Zip_Addr AS ordered_party_empl_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Ordered_Party_Empl_Country_Addr  
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE) 
        EXCEPT
			SELECT @Lc_Ordered_Party_State_Addr AS ordered_party_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Ordered_Party_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Ordered_Party_Zip_Addr AS ordered_party_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Ordered_Party_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE) 
        EXCEPT
			SELECT @Lc_Othp_State_Addr AS othp_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Othp_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Othp_Zip_Addr AS othp_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Othp_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE) 
        EXCEPT
			SELECT @Lc_Recipient_State_Addr AS recipient_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_Recipient_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                 
            SELECT @Lc_Recipient_Zip_Addr AS recipient_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_Recipient_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)  
        EXCEPT
			SELECT @Lc_To_Agency_State_Addr AS to_agency_state_addr FROM #NoticeElementsData_P1
			WHERE Element_NAME = @Lc_To_Agency_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
		EXCEPT                
            SELECT @Lc_To_Agency_Zip_Addr AS to_agency_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_To_Agency_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)  
        --13738 - CR0440 INT-02 UIFSA Transmittal 2 Changes Requested by Workers 20141120 - Fix - START
        EXCEPT                
            SELECT @Lc_To_Agency_Sdu_State_Addr AS to_agency_sdu_state_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_To_Agency_Sdu_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE) 
        EXCEPT                
            SELECT @Lc_To_Agency_Sdu_Zip_Addr AS to_agency_sdu_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_To_Agency_Sdu_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)   
        EXCEPT                
            SELECT @Lc_From_Agency_Sdu_State_Addr AS from_agency_sdu_state_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_From_Agency_Sdu_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)  
        EXCEPT                
            SELECT @Lc_From_Agency_Sdu_Zip_Addr AS from_agency_zip_addr FROM #NoticeElementsData_P1
            WHERE Element_NAME = @Lc_From_Agency_Sdu_Country_Addr   
            AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)   
		   ) V
	  WHERE (	EXISTS (  SELECT 1  
							FROM #NoticeElementsData_P1  
						   WHERE Element_NAME = v.Element_NAME  
							 AND (LTRIM(RTRIM(Element_Value)) = '' OR Element_Value IS NULL)
					   )
			  OR NOT EXISTS(SELECT 1
							FROM #NoticeElementsData_P1
						   WHERE Element_NAME = v.Element_NAME )
		    )
	 --13738 - CR0440 INT-02 UIFSA Transmittal 2 Changes Requested by Workers 20141120 - Fix - END
	 
	-- End of Handling other than Group Element errors
	--13540 - Notices generated to foreign countries are failing Fix - End
	
	-- Start of Handling errors for dependency options groups
	SET @GetRequired_Element_CUR = CURSOR  FOR 
				SELECT OptionParentSeq_NUMB
				   FROM NDEL_Y1   
				  WHERE OptionParentSeq_NUMB <> 0
				    AND ElementGroup_NUMB != 0
					AND Notice_ID = @Lc_Notice_ID
					AND Input_CODE = 'O'
					AND Procedure_NAME = @As_Proc_NAME
				  GROUP BY OptionParentSeq_NUMB;
	
	OPEN @GetRequired_Element_CUR  ;

	FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB;

	WHILE @@FETCH_STATUS = 0  
		BEGIN
			
			-- if group number is given in Parent sequence number, so what is the min and max count of that parent group
			SELECT TOP 1 @Ln_ParentElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
						 @Ln_ParentElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
			  FROM NDEL_Y1   
			 WHERE Notice_ID = @Lc_Notice_ID  
			   AND Input_CODE = 'O'  
			   AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;  
		    
   			/* if group number is given in Parent sequence number, Fetching the No. of Elements of the parent group 
   			   that has the data in #NoticeElementsData_P1 table */
			SELECT @Ln_ParentGroupSelectedElementsCount_NUMB = COUNT(Element_NAME)   
			  FROM #NoticeElementsData_P1   
			 WHERE Element_NAME IN (SELECT Element_NAME   
									 FROM NDEL_Y1  
									WHERE Notice_ID = @Lc_Notice_ID 
									  AND Input_CODE = 'O'
									  AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB
									  )  
			  AND (LTRIM(RTRIM(Element_Value)) != '' AND Element_Value IS NOT NULL);
			
			-- If sequence number is given as parent sequence number, fetching whether the parent has the value
			SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
			  FROM #NoticeElementsData_P1
			 WHERE (LTRIM(RTRIM(Element_Value)) != '' AND Element_Value IS NOT NULL)
			   AND Element_NAME  = (SELECT Element_NAME 
									  FROM NDEL_Y1
									 WHERE Notice_ID = @Lc_Notice_ID
									   AND Input_CODE = 'O'
									   AND Seq_NUMB = @Ln_OptionParentSeq_NUMB)
			
			------------------------
			-- Sub Groups
			SET @RequiredElements_CUR = CURSOR  FOR 
				SELECT ElementGroup_NUMB
				   FROM NDEL_Y1   
				  WHERE ElementGroup_NUMB <> 0
				    AND OptionParentSeq_NUMB != 0 
				    AND Notice_ID = @Lc_Notice_ID  
				    AND Procedure_NAME = @As_Proc_NAME
				    AND OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
				  GROUP BY ElementGroup_NUMB;  

			OPEN @RequiredElements_CUR  

			FETCH NEXT FROM @RequiredElements_CUR INTO @ElementGroup_NUMB

			WHILE @@FETCH_STATUS = 0  
				 BEGIN  
					 -- Getting the min and max elements required among the element group
					 SELECT TOP 1 @Ln_ElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
								  @Ln_ElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
						 FROM NDEL_Y1   
						WHERE Notice_ID = @Lc_Notice_ID  
						  AND Input_CODE = 'O'  
						  AND ElementGroup_NUMB = @ElementGroup_NUMB;  
					   
				   		-- Fetching the Elements number which has the data in #NoticeElementsData_P1 table in a elements group
						SELECT @Ln_SelectedElementsCount_NUMB = COUNT(Element_NAME)   
						  FROM #NoticeElementsData_P1   
						 WHERE Element_NAME IN (SELECT Element_NAME   
												 FROM NDEL_Y1  
												WHERE Notice_ID = @Lc_Notice_ID 
												  AND Input_CODE = 'O'
												  AND ElementGroup_NUMB = @ElementGroup_NUMB
												  )  
						  AND (LTRIM(RTRIM(Element_Value)) != '' AND Element_Value IS NOT NULL)  
					
					IF (		(		@Ln_ParentGroupSelectedElementsCount_NUMB BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
									AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0
								)
					     OR 	@Ln_ParentSelectedElementCount_NUMB > 0
					   )
					   AND @Ln_SelectedElementsCount_NUMB NOT BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB 
					   AND @Ln_SelectedElementsCount_NUMB = 0
						
						BEGIN
							
							INSERT INTO #NoticeErrors_P1   
										SELECT  DISTINCT  
												V.Element_NAME,  
												'E1081' Msg_CODE  ,  
												'No. of Check Boxes in the Group: ' + CAST(@ElementGroup_NUMB AS VARCHAR) + ' to be Checked are Minimum: ' + CAST(@Ln_ElementGroupMinRequired_NUMB AS VARCHAR) 
											+ ' And Maximum: ' + CAST(@Ln_ElementGroupMaxRequired_NUMB AS VARCHAR)
											+ ', but Checked are: ' + CAST(@Ln_SelectedElementsCount_NUMB AS VARCHAR) + ' from procedure: ' + @As_Proc_NAME Error_DESC
										  FROM NDEL_Y1 V    
										 WHERE v.Input_CODE = 'O'    
										   AND v.Notice_ID = @Lc_Notice_ID 
										   AND v.ElementGroup_NUMB = @ElementGroup_NUMB
										   AND (	EXISTS (  SELECT 1  
																FROM #NoticeElementsData_P1  
															   WHERE Element_NAME = v.Element_NAME  
																 AND (LTRIM(RTRIM(Element_Value)) = '' OR Element_Value IS NULL)
														   )
												OR NOT EXISTS(SELECT 1
																FROM #NoticeElementsData_P1
															   WHERE Element_NAME = v.Element_NAME )
											   );
						END
					 
					 FETCH NEXT FROM @RequiredElements_CUR INTO @ElementGroup_NUMB 
				 END  
			

			CLOSE @RequiredElements_CUR  

			DEALLOCATE @RequiredElements_CUR  
			---------------------
			
			FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB;
		END         
 
	CLOSE @GetRequired_Element_CUR  
	DEALLOCATE @GetRequired_Element_CUR;  
	-- End of Handling errors for dependency options groups

	 --Apply formatting For all elements in #SubValues_P1 table          
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_SUB_ELMENTS';
     SET @Ls_ErrorDesc_TEXT = 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA : No Elements Data For Formatting'
     
     SET @GetFormat_Element_CUR = CURSOR FOR
		 SELECT  V.Element_NAME,
				 V.Element_VALUE,
				 p.Format_CODE,
				 P.Mask_INDC
			FROM #NoticeElementsData_P1 V, NDEL_Y1 P
		   WHERE v.ELEMENT_NAME = P.Element_NAME
			 AND P.NOTICE_ID = @Lc_Notice_ID
			 AND P.Procedure_NAME = @As_Proc_NAME
			 AND P.Input_CODE = 'O'
			 AND P.Format_CODE <> '';

     OPEN @GetFormat_Element_CUR

     FETCH NEXT FROM @GetFormat_Element_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Ls_Format_CODE, @Lc_Mask_INDC;

     WHILE @@FETCH_STATUS = 0
		  BEGIN
			   SET @Ls_Element_TEXT = @Ls_Element_NAME;
			   SET @Ls_ElementValue_TEXT = @Ls_Element_VALUE;
			   SET @Ls_Ele_Format_CODE = @Ls_Format_CODE;
			   SET @Lc_Mask_INDC = @Lc_Mask_INDC;
		       
			   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA';
			   SET @Ls_Sqldata_TEXT = 'EXEC ' + @Ls_Sql_TEXT + ' ' + @Ls_SQLParameterString_TEXT;
				
			   IF @Ls_Ele_Format_CODE <> ''
				BEGIN
				  EXEC  BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA
								@As_Element_NAME			= @Ls_Element_TEXT,
								@As_Element_VALUE			= @Ls_ElementValue_TEXT,
								@Ac_Format_CODE				= @Ls_Ele_Format_CODE,
								@Ac_Mask_INDC				= @Lc_Mask_INDC,
								@As_FormattedResult_TEXT	= @Ls_FormattedResult_TEXT OUTPUT,
								@As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT,
								@Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT;
		          
				  IF @Ac_Msg_CODE = 'F'
					BEGIN
						RETURN;
					END
		          
				  UPDATE #NoticeElementsData_P1
					 SET ELEMENT_VALUE = @Ls_FormattedResult_TEXT
				   WHERE ELEMENT_NAME = @Ls_Element_TEXT;
				  
				END

			   FETCH NEXT FROM @GetFormat_Element_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Ls_Format_CODE, @Lc_Mask_INDC;
		  END

     CLOSE @GetFormat_Element_CUR;

     DEALLOCATE @GetFormat_Element_CUR;
	
	
	-- Start of Handling errors for dependency options not in groups
	SET @GetRequired_Element_CUR = CURSOR  FOR 
				SELECT OptionParentSeq_NUMB
				   FROM NDEL_Y1   
				  WHERE OptionParentSeq_NUMB <> 0
				    AND ElementGroup_NUMB = 0
					AND Notice_ID = @Lc_Notice_ID
					AND Input_CODE = 'O'
					AND Procedure_NAME = @As_Proc_NAME
				  GROUP BY OptionParentSeq_NUMB;
	
	OPEN @GetRequired_Element_CUR  ;

	FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB;

	WHILE @@FETCH_STATUS = 0  
		BEGIN
			-- if group number is given in Parent sequence number, so what is the min and max count of that parent group
			SELECT TOP 1 @Ln_ParentElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
						 @Ln_ParentElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
			  FROM NDEL_Y1   
			 WHERE Notice_ID = @Lc_Notice_ID  
			   AND Input_CODE = 'O'
			   AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;  
		    
   			/* if group number is given in Parent sequence number, Fetching the No. of Elements of the parent group 
   			   that has the data in #NoticeElementsData_P1 table */
			SELECT @Ln_ParentGroupSelectedElementsCount_NUMB = COUNT(Element_NAME)   
			  FROM #NoticeElementsData_P1   
			 WHERE --Element_NAME = @Ls_Element_NAME    
				   Element_NAME IN (SELECT Element_NAME   
									 FROM NDEL_Y1  
									WHERE Notice_ID = @Lc_Notice_ID 
									  AND Input_CODE = 'O' 
									  AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB
									  )  
			  AND (LTRIM(RTRIM(Element_Value)) != '' AND Element_Value IS NOT NULL);
			
			-- If sequence number is given as parent sequence number, fetching whether the parent has the value
			SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
			  FROM #NoticeElementsData_P1
			 WHERE (LTRIM(RTRIM(Element_Value)) != '' AND Element_Value IS NOT NULL)
			   AND Element_NAME  = (SELECT Element_NAME 
									  FROM NDEL_Y1
									 WHERE Notice_ID = @Lc_Notice_ID
									   AND Input_CODE = 'O' 
									   AND Seq_NUMB = @Ln_OptionParentSeq_NUMB)
			
			
			IF (		(		@Ln_ParentGroupSelectedElementsCount_NUMB BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
							AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0
						)
			     OR 	@Ln_ParentSelectedElementCount_NUMB > 0
			   )
				BEGIN

					--13540 - Notices generated to foreign countries are failing Fix - Start
					INSERT INTO #NoticeErrors_P1   
								SELECT  DISTINCT  
										V.Element_NAME,  
										'E1081' Msg_CODE  ,  
										'Parent of this Element is Checked, So this Element Should be Entered' + ' from procedure: ' + @As_Proc_NAME Error_DESC
								  FROM NDEL_Y1 V    
								 WHERE v.Input_CODE = 'O'   
								   AND v.Notice_ID = @Lc_Notice_ID
								   AND v.OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
								   AND ElementGroup_NUMB = 0
								   AND (	EXISTS (  SELECT 1  
														FROM #NoticeElementsData_P1  
													   WHERE Element_NAME = v.Element_NAME  
														 AND (LTRIM(RTRIM(Element_Value)) = '' OR Element_Value IS NULL)
												   )
										OR NOT EXISTS(SELECT 1
														FROM #NoticeElementsData_P1
													   WHERE Element_NAME = v.Element_NAME )
									   )
								   AND v.Element_NAME NOT IN(                 
														SELECT @Lc_Father_State_Addr AS father_state_addr FROM #NoticeElementsData_P1
														WHERE Element_NAME = @Lc_Father_Country_Addr   
														AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE) 
														UNION  
														SELECT @Lc_Father_Zip_Addr AS father_zip_addr FROM #NoticeElementsData_P1
														WHERE Element_NAME = @Lc_Father_Country_Addr   
														AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)    
														UNION           
														SELECT @Lc_Mom_State_Addr AS mom_state_addr FROM #NoticeElementsData_P1
														WHERE Element_NAME = @Lc_Mom_Country_Addr 
														AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
														UNION
														SELECT @Lc_Mom_Zip_Addr AS mom_zip_addr FROM #NoticeElementsData_P1
														WHERE Element_NAME = @Lc_Mom_Country_Addr   
														AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
														UNION                
														SELECT @Lc_Caretaker_State_Addr AS caretaker_state_addr FROM #NoticeElementsData_P1
														WHERE Element_NAME = @Lc_Caretaker_Country_Addr  
														AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)
														UNION
														SELECT @Lc_Caretaker_Zip_Addr AS caretaker_zip_addr FROM #NoticeElementsData_P1
														WHERE Element_NAME = @Lc_Caretaker_Country_Addr   
														AND LTRIM(RTRIM(Element_VALUE)) NOT IN (@Lc_Country_US_CODE,@Lc_Country_CA_CODE)); 			
					--13540 - Notices generated to foreign countries are failing Fix - Start							   
				END
			
			
			FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB             
		END         
 
	CLOSE @GetRequired_Element_CUR  
	DEALLOCATE @GetRequired_Element_CUR;  
	-- End of Handling errors for dependency options not in groups
	
	 
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   
   SET @Ac_Msg_CODE=@Lc_StatusFailed_CODE;
	
   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE(), '') + ' Procedure' + '. Error Desc - ' + @Ls_ErrorDesc_TEXT + '. Error Execute Location - ' + @ls_sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE (), '') + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error Execute Location - ' + @ls_sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT=@Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
