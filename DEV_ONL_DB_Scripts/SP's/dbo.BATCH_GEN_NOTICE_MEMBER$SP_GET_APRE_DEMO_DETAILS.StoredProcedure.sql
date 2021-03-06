/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_DEMO_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_DEMO_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Application details from APCS_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_DEMO_DETAILS]
(
 @An_MemberMci_IDNO			NUMERIC(10), 
 @As_Prefix_TEXT			VARCHAR(100),  
 @Ac_Msg_CODE				CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT  
)
AS    
BEGIN
  SET NOCOUNT ON;   
   
  DECLARE  @Lc_Space_TEXT          CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_CheckboxValue	   CHAR(1) = 'X',
           @Lc_Yes_INDC			   CHAR(1) = 'Y',
           @Lc_No_INDC			   CHAR(1) = 'N',
           @Lc_MemberSexMale_CODE  CHAR(1) = 'M',	
           @Lc_MemberSexFemale_CODE CHAR(1) = 'F',
           @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_DEMO_DETAILS',
           @Ld_High_DATE           DATE = '12-31-9999';
           
  DECLARE  @Ln_Zero_NUMB             NUMERIC = 0,
           @Ln_Rowcount_QNTY         NUMERIC(5),
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Sql_TEXT              VARCHAR(1000),
           @Ls_Err_Description_TEXT  VARCHAR(4000);
  
  DECLARE @NoticeElements_P1 TABLE
                                    (
                                       Element_NAME    VARCHAR (100),
                                       Element_VALUE   VARCHAR (100)
                                    );
  BEGIN TRY    
		SET @Ac_Msg_CODE = '';  
		SET @As_DescriptionError_TEXT='';      
		
		SET @Ls_Sql_TEXT = 'SELECT APDM_Y1 ';
		SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO: ' + CAST(ISNULL(@An_MemberMci_IDNO , 0)AS VARCHAR);	
		
												 
		INSERT INTO @NoticeElements_P1(Element_NAME,Element_VALUE)
			(SELECT Element_NAME, Element_VALUE 
			 FROM             
				(            SELECT  CONVERT(VARCHAR(100),Last_NAME)								last_name,              					
									 CONVERT(VARCHAR(100),First_NAME)								first_name,              
									 CONVERT(VARCHAR(100),Middle_NAME)								middle_name,              
									 CONVERT(VARCHAR(100),Suffix_NAME)								suffix_name,              
									 CONVERT(VARCHAR(100),MemberSsn_NUMB)							ssn_numb,              
									 CONVERT(VARCHAR(100),HomePhone_NUMB)							resi_phone_numb,              
									 CONVERT(VARCHAR(100),CellPhone_NUMB)							cell_phone_numb,              
									 CONVERT(VARCHAR(100),Birth_DATE)								birth_date,              
									 CONVERT(VARCHAR(100),BirthCity_NAME)							birthcity_name,              
									 CONVERT(VARCHAR(100),BirthState_CODE)							birthstate_code,              
									 CONVERT(VARCHAR(100),FirstAlias_NAME)							first_alias_name,              
									 CONVERT(VARCHAR(100),MiddleAlias_NAME)							middle_alias_name,              
									 CONVERT(VARCHAR(100),LastAlias_NAME)							last_alias_name,              
									 CONVERT(VARCHAR(100),SuffixAlias_NAME)							suffix_alias_name,              
									 CONVERT(VARCHAR(100),MotherMaiden_NAME)						mother_maiden_name,              
									 CONVERT(VARCHAR(100),Race_CODE)								race_code,              
									 CONVERT(VARCHAR(100),MaleSex_CODE)								sex_male_code,              
									 CONVERT(VARCHAR(100),FemaleSex_CODE)							sex_female_code,              
									 CONVERT(VARCHAR(100),Marriage_DATE)							marriage_date,              
									 CONVERT(VARCHAR(100),StateMarriage_CODE)						marraige_state_code,              
									 CONVERT(VARCHAR(100),CountyMarriage_NAME)						county_marriage_name,              
									 CONVERT(VARCHAR(100),StateLastShared_CODE)						state_lastshared_code,              
									 CONVERT(VARCHAR(100),Divorce_DATE)								divorce_date,              
									 CONVERT(VARCHAR(100),CourtDivorce_TEXT)						court_divorce_text,              
									 CONVERT(VARCHAR(100),DivorceCounty_NAME)						divorce_county_name,              
									 CONVERT(VARCHAR(100),StateDivorce_CODE)						state_divorce_code,              
									 CONVERT(VARCHAR(100),DivorceProceeding_YES)					divorce_proceeding_yes_code,              
									 CONVERT(VARCHAR(100),DivorceProceeding_NO)						divorce_proceeding_no_code,              
									 CONVERT(VARCHAR(100),EverReceivedMedicaid_YES)					ever_received_medicaid_yes_code,           
									 CONVERT(VARCHAR(100),EverReceivedMedicaid_NO)					ever_received_medicaid_no_code,            
									 CONVERT(VARCHAR(100),ChildCoveredInsurance_YES)				child_covered_insurance_yes_code,          
									 CONVERT(VARCHAR(100),ChildCoveredInsurance_NO)					child_covered_insurance_no_code,           
									 CONVERT(VARCHAR(100),CurrentMilitary_YES)						current_military_yes_code,              
									 CONVERT(VARCHAR(100),CurrentMilitary_NO)						current_military_no_code,              
									 CONVERT(VARCHAR(100),MILITARY_SERVICE_BRANCH_CODE_AR)			military_service_branch_ar_code,           
									 CONVERT(VARCHAR(100),MILITARY_SERVICE_BRANCH_CODE_NA)			military_service_branch_na_code,           
									 CONVERT(VARCHAR(100),MILITARY_SERVICE_BRANCH_CODE_AF)			military_service_branch_af_code,           
									 CONVERT(VARCHAR(100),MILITARY_SERVICE_BRANCH_CODE_MA)			military_service_branch_ma_code,           
									 CONVERT(VARCHAR(100),MILITARY_SERVICE_BRANCH_CODE_CG)			military_service_branch_cg_code,           
									 CONVERT(VARCHAR(100),MilitaryStart_DATE)						military_service_start_date,              
									 CONVERT(VARCHAR(100),MilitaryEnd_DATE)							military_service_end_date,              
									 CONVERT(VARCHAR(100),EVER_INCARCERATED_INDC_YES)				ever_incarcerated_yes_code,              
									 CONVERT(VARCHAR(100),EVER_INCARCERATED_INDC_NO)				ever_incarcerated_no_code,              
									 CONVERT(VARCHAR(100),IncarceratedFrom_DATE)					incarcerated_from_date,              
									 CONVERT(VARCHAR(100),IncarceratedTo_DATE)						incarcerated_to_date,              
									 CONVERT(VARCHAR(100),OtherIncome_UK)							other_income_uk_code,              
									 CONVERT(VARCHAR(100),OtherIncome_YES)							other_income_yes_code,              
									 CONVERT(VARCHAR(100),OtherIncome_NO)							other_income_no_code,              
									 CONVERT(VARCHAR(100),OtherIncomeType_CODE)						other_incometype_code,              
									 CONVERT(VARCHAR(100),OtherIncome_AMNT)							other_income_amnt,              
									 CONVERT(VARCHAR(100),IncomeFrequency_CODE)						other_income_frequency_code,               
									 CONVERT(VARCHAR(100),ColorEyes_CODE)							coloreyes_code,              
									 CONVERT(VARCHAR(100),DescriptionHeight_TEXT)					descriptionheight_text,              
									 CONVERT(VARCHAR(100),ColorHair_CODE)							colorhair_code,              
									 CONVERT(VARCHAR(100),DescriptionWeightLbs_TEXT)				descriptionweightlbs_text,               
									 CONVERT(VARCHAR(100),NcpProvideChildInsurance_UK)				provide_child_insurance_uk_code,        
									 CONVERT(VARCHAR(100),NcpProvideChildInsurance_YES)				provide_child_insurance_yes_code,       
									 CONVERT(VARCHAR(100),NcpProvideChildInsurance_NO)				provide_child_insurance_no_code,        
									 CONVERT(VARCHAR(100),DirectSupportPay_YES)						direct_supportpay_yes_code,              
									 CONVERT(VARCHAR(100),DirectSupportPay_NO)						direct_supportpay_no_code            
							FROM (SELECT  RTRIM(Last_NAME)  + @Lc_Space_TEXT AS Last_NAME,                
										  RTRIM(First_NAME) + @Lc_Space_TEXT AS First_NAME,                
										  RTRIM(Middle_NAME)+ @Lc_Space_TEXT AS Middle_NAME,                
										  RTRIM(Suffix_NAME)+ @Lc_Space_TEXT AS Suffix_NAME,                
										  MemberSsn_NUMB,                
										  HomePhone_NUMB,                
										  CellPhone_NUMB,                
										  Birth_DATE,                
										  BirthCity_NAME,                
										  BirthState_CODE,                
										  RTRIM(FirstAlias_NAME) + @Lc_Space_TEXT AS FirstAlias_NAME,                
										  RTRIM(MiddleAlias_NAME) + @Lc_Space_TEXT AS MiddleAlias_NAME,                
										  RTRIM(LastAlias_NAME) + @Lc_Space_TEXT AS LastAlias_NAME,                
										  RTRIM(SuffixAlias_NAME) + @Lc_Space_TEXT AS SuffixAlias_NAME,                
										  MotherMaiden_NAME,                
										  dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC('GENR','RACE',Race_CODE) AS RACE_CODE, 
										  (CASE WHEN MemberSex_CODE = @Lc_MemberSexMale_CODE THEN @Lc_CheckboxValue ELSE '' END)MaleSex_CODE,                
										  (CASE WHEN MemberSex_CODE = @Lc_MemberSexFemale_CODE THEN @Lc_CheckboxValue ELSE '' END)FemaleSex_CODE,                
										  Marriage_DATE,                
										  RTRIM(StateMarriage_CODE) + @Lc_Space_TEXT AS StateMarriage_CODE,                
										  RTRIM(CountyMarriage_NAME) + @Lc_Space_TEXT AS CountyMarriage_NAME,                
										  StateLastShared_CODE,                
										  Divorce_DATE,                
										  CourtDivorce_TEXT,                
										  DivorceCounty_NAME,                
										  StateDivorce_CODE,                
										  (CASE WHEN DivorceProceeding_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)DivorceProceeding_YES,                              
										  (CASE WHEN DivorceProceeding_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)DivorceProceeding_NO,                
										  (CASE WHEN EverReceivedMedicaid_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)EverReceivedMedicaid_YES,                
										  (CASE WHEN EverReceivedMedicaid_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)EverReceivedMedicaid_NO,                
										  (CASE WHEN ChildCoveredInsurance_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)ChildCoveredInsurance_YES,                
										  (CASE WHEN ChildCoveredInsurance_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)ChildCoveredInsurance_NO,                
										  (CASE WHEN CurrentMilitary_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)CurrentMilitary_YES,                
										  (CASE WHEN CurrentMilitary_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)CurrentMilitary_NO,                
										  (CASE WHEN MilitaryBranch_CODE = 'ARMY' THEN @Lc_CheckboxValue ELSE '' END)MILITARY_SERVICE_BRANCH_CODE_AR,                
										  (CASE WHEN MilitaryBranch_CODE = 'NAVY' THEN @Lc_CheckboxValue ELSE '' END)MILITARY_SERVICE_BRANCH_CODE_NA,                
										  (CASE WHEN MilitaryBranch_CODE = 'AF' THEN @Lc_CheckboxValue ELSE '' END)MILITARY_SERVICE_BRANCH_CODE_AF,                
										  (CASE WHEN MilitaryBranch_CODE = 'SM' THEN @Lc_CheckboxValue ELSE '' END)MILITARY_SERVICE_BRANCH_CODE_MA,                
										  (CASE WHEN MilitaryBranch_CODE = 'CG' THEN @Lc_CheckboxValue ELSE '' END)MILITARY_SERVICE_BRANCH_CODE_CG,                
										  MilitaryStart_DATE,                
										  MilitaryEnd_DATE,                
										  (CASE WHEN EverIncarcerated_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)EVER_INCARCERATED_INDC_YES,                
										  (CASE WHEN EverIncarcerated_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)EVER_INCARCERATED_INDC_NO,                
										  IncarceratedFrom_DATE,                
										  IncarceratedTo_DATE,                
										  (CASE WHEN OtherIncome_INDC = 'UK' THEN @Lc_CheckboxValue ELSE '' END)OtherIncome_UK,                
										  (CASE WHEN OtherIncome_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)OtherIncome_YES,                
										  (CASE WHEN OtherIncome_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)OtherIncome_NO,                
										  OtherIncomeType_CODE,                
										  OtherIncome_AMNT,                
										  IncomeFrequency_CODE,                
										  ColorEyes_CODE,                
										  DescriptionHeight_TEXT,                
										  ColorHair_CODE,DescriptionWeightLbs_TEXT,                 
										  (CASE WHEN NcpProvideChildInsurance_INDC = 'UK' THEN @Lc_CheckboxValue ELSE '' END)NcpProvideChildInsurance_UK,                
										  (CASE WHEN NcpProvideChildInsurance_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)NcpProvideChildInsurance_YES,                
										  (CASE WHEN NcpProvideChildInsurance_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)NcpProvideChildInsurance_NO,                
										  (CASE WHEN DirectSupportPay_INDC = @Lc_Yes_INDC THEN @Lc_CheckboxValue ELSE '' END)DirectSupportPay_YES,                
										  (CASE WHEN DirectSupportPay_INDC = @Lc_No_INDC THEN @Lc_CheckboxValue ELSE '' END)DirectSupportPay_NO                
								    FROM    APDM_Y1              
									WHERE MemberMci_IDNO = @An_MemberMci_IDNO                                        
									  and EndValidity_DATE =@Ld_High_DATE )a )up             
							UNPIVOT (Element_value FOR Element_NAME IN (
											last_name,              
											first_name,              
											middle_name,              
											suffix_name,              
											ssn_numb,              
											resi_phone_numb,              
											cell_phone_numb,              
											birth_date,              
											birthcity_name,              
											birthstate_code,              
											first_alias_name,              
											middle_alias_name,              
											last_alias_name,              
											suffix_alias_name,              
											mother_maiden_name,              
											race_code,              
											sex_male_code,              
											sex_female_code,              
											marriage_date,              
											marraige_state_code,              
											county_marriage_name,              
											state_lastshared_code,              
											divorce_date,              
											court_divorce_text,              
											divorce_county_name,              
											state_divorce_code,              
											divorce_proceeding_yes_code,              
											divorce_proceeding_no_code,              
											ever_received_medicaid_yes_code,           
											ever_received_medicaid_no_code,            
											child_covered_insurance_yes_code,          
											child_covered_insurance_no_code,           
											current_military_yes_code,              
											current_military_no_code,              
											military_service_branch_ar_code,           
											military_service_branch_na_code,           
											military_service_branch_af_code,           
											military_service_branch_ma_code,           
											military_service_branch_cg_code,           
											military_service_start_date,              
											military_service_end_date,              
											ever_incarcerated_yes_code,              
											ever_incarcerated_no_code,              
											incarcerated_from_date,              
											incarcerated_to_date,              
											other_income_uk_code,              
											other_income_yes_code,              
											other_income_no_code,              
											other_incometype_code,              
											other_income_amnt,              
											other_income_frequency_code,               
											coloreyes_code,              
											descriptionheight_text,              
											colorhair_code,              
											descriptionweightlbs_text,               
											provide_child_insurance_uk_code,        
											provide_child_insurance_yes_code,       
											provide_child_insurance_no_code,        
											direct_supportpay_yes_code,              
											direct_supportpay_no_code)) AS pvt);
		
			SET @Ls_Sql_TEXT = 'INSERT @NoticeElements_P1';
			SET @Ls_Sqldata_TEXT = ' Element_NAME = ' + @As_Prefix_TEXT;   
				
			INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
				   SELECT RTRIM(@As_Prefix_TEXT) + '_' + TE.Element_NAME AS Element_NAME, TE.Element_VALUE
				   FROM @NoticeElements_P1 TE;		
 		 
	SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE ;    
    END TRY            
    BEGIN CATCH        
      DECLARE @Li_Error_NUMB					INT = ERROR_NUMBER (),
				  @Li_ErrorLine_NUMB		    INT =  ERROR_LINE ();

			 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

			 IF (@Li_Error_NUMB <> 50001)
				BEGIN
				   SET @As_DescriptionError_TEXT =
						  SUBSTRING (ERROR_MESSAGE (), 1, 200);
				END

			 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
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
