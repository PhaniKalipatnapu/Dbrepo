/****** Object:  StoredProcedure [dbo].[BATCH_CPORTAL_CSI_UPDATE_DECSS$SP_PROCESS_CSI_UPDATE_DECSS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CPORTAL_CSI_UPDATE_DECSS$SP_PROCESS_CSI_UPDATE_DECSS
Programmer Name	:	IMP Team.
Description		:	The process BATCH_CPORTAL_CSI_UPDATE_DECSS inserts new record in the DECSS from CPORTAL CSI. 
 
					  This procedure get all the records from CPORTAL ( CAPAG_Y1,CAPAH_Y1,CAPCM_Y1,CAPDI_Y1,CAPEH_Y1,CALSP_Y1,CAPMI_Y1,CAPSR_Y1,CAPCS_Y1,CAPDM_Y1)
					  with the Submit application and Insert in to DECSS (APAG_Y1,APAH_Y1,APCM_Y1,APDI_Y1,APEH_Y1,ALSP_Y1,APMI_Y1,APSR_Y1,APCS_Y1,APDM_Y1)
					  with valid Application idno and Application Status as Pending. 
					  Submit Application Deleted from CPORTAL Data Base.
Frequency		:	'DAILY'
Developed On	:	4/4/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CPORTAL_CSI_UPDATE_DECSS$SP_PROCESS_CSI_UPDATE_DECSS] (
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_BatchRunUser_TEXT		  CHAR(30),	
 @Ac_IamUser_ID				  CHAR(30),
 @Ad_EffectiveRun_DATE        DATE,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionErrorOut_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
    SET XACT_ABORT ON; 

  DECLARE @Lc_StatusFailed_CODE					CHAR (1) = 'F',
          @Lc_Space_TEXT						CHAR (1) = ' ',
		  @Lc_No_TEXT						    CHAR (1) = 'N',
		  @Lc_Note_INDC							CHAR(1) = 'N',
		  @Lc_Case_Type_NonPA_CODE              CHAR (1) = 'N',
		  @Lc_Case_Category_Full_Service_CODE   CHAR (2) = 'FS',
		  @Lc_Referral_Source_CODE				CHAR (1) = 'W',
		  @Lc_ApplicationStatus_CODE			CHAR (1) = 'S',
          @Lc_StatusSuccess_CODE				CHAR (1) = 'S',
		  @Lc_US_Country_CODE					CHAR (2) = 'US',
		  @Lc_Mailing_TypeAddress_CODE			CHAR (1) = 'M',			  
		  @Lc_Submit_Yes_PaternityEst_INDC		CHAR (1) = 'Y',
		  @Lc_BatchRunUser_TEXT					CHAR(30) = 'BATCH',
		  @Lc_Job_ID							CHAR(7) = 'DEB9021',-- TODO : Confirm Job_ID.
		  @Ld_Submit_PaternityEst_DATE			DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ls_Routine_TEXT						VARCHAR (100) = 'BATCH_CPORTAL_CSI_UPDATE_DECSS$SP_PROCESS_CSI_UPDATE_DECSS',
          @Ls_SubRoutine_TEXT					VARCHAR (100) = 'BATCH_PORTAL_UPDATE$SP_APPLICATION_TABLE_UPDATE',                           
          @Ld_High_DATE							DATE = '12/31/9999',
          @Ld_Low_DATE							DATE = '01/01/0001',
		  @Li_Count_QNTY						INT = 0,     
		  @Li_Zero_Application_IDNO				INT = 0, 
		  @Li_RowsAffected						INT = 0,
          @Ld_Start_DATE						DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),		  		  
		  @Ln_RowCount_QNTY						NUMERIC (7),
          @Ln_Error_NUMB						NUMERIC (11),
          @Ln_ErrorLine_NUMB					NUMERIC (11),                    
          @Ls_Sql_TEXT							VARCHAR (100),         
          @Ls_Sqldata_TEXT						VARCHAR (200),
          @Ls_ErrorMessage_TEXT					VARCHAR (4000),
          @Lc_Msg_CODE							CHAR (5),
          @Ln_EventGlobalSeq_NUMB				NUMERIC(19);              

  BEGIN TRY  
  	
  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT ';  
  
   IF @Ac_BatchRunUser_TEXT <> @Lc_BatchRunUser_TEXT
   BEGIN
		SET @Lc_Job_ID = 'CPORTAL';
   END
   
   SET @Ls_Sqldata_TEXT = 'BatchRunUser_TEXT = ' + @Ac_BatchRunUser_TEXT + ', Job_ID = ' + @Lc_Job_ID
   
   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID               = @Ac_BatchRunUser_TEXT,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ad_EffectiveRun_DATE,
       @Ac_Note_INDC               = @Lc_Note_INDC,
       @An_EventFunctionalSeq_NUMB = @Li_Count_QNTY,
       @An_TransactionEventSeq_NUMB= @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;     
       
   /*
   To get the Record from CAPCS_Y1 with the Application Idno Cann't be Zero and Insert in to APCS_Y1 and Selected Record Deleted from CAPCS_Y1
   */
   SET @Ls_Sql_TEXT = 'INSERT APCS_Y1 ';
   SET @Ls_Sqldata_TEXT = ' ';

   INSERT APCS_Y1
          (Application_IDNO,
           Application_DATE,
           BeginValidity_DATE,
           EndValidity_DATE,
           Update_DTTM,
           WorkerUpdate_ID,
           TransactionEventSeq_NUMB,
           TypeCase_CODE,
           Opened_DATE,
           StatusCase_CODE,
           StatusCurrent_DATE,
           RsnStatusCase_CODE,
           County_IDNO,
           SourceRfrl_CODE,
           Restricted_INDC,
           MedicalOnly_INDC,
           GoodCause_CODE,
           GoodCause_DATE,
           NonCoop_CODE,
           NonCoop_DATE,
           IvdApplicant_CODE,
           AppReq_DATE,
           AppSent_DATE,
           AppRetd_DATE,
           AppSigned_DATE,
           RsnFeeWaived_CODE,
           DescriptionComments_TEXT,
           ApplicationStatus_CODE,
           RespondInit_CODE,
           Referral_DATE,
           CaseCategory_CODE,
           ApplicationFee_CODE,
           FeePaid_DATE,
           ServiceRequested_CODE,
           File_ID,
           CaseWelfare_IDNO,
           TypeWelfare_CODE,
           AttorneyState_CODE,
           AttorneyCounty_NAME,
           FeeCheckNo_TEXT,
           StatusEnforce_CODE,
           ServiceState_CODE,
           ServiceCounty_NAME,
           Service_CODE,
           ChildSupportOrMedicalAssistance_INDC,
           AttorneyCourt_TEXT,
           MedicalInsuranceCardStatus_CODE,
           PayStubW2FormStatus_CODE,
           PreventAddressReleaseStatus_CODE,
           MemberSocialSecurityCardStatus_CODE,
           MarriedDivorceDecreeStatus_CODE,
           PaymentArrearsStatementStatus_CODE,
           ModifiedSupportOrderDecreeStatus_CODE,
           ChildBirthCertificateStatus_CODE,
           InformationReleaseRisk_INDC,
           AddressPfaProtection_INDC,
           PaternityAcknowledgmentStatus_CODE,
           TransHeader_IDNO,
           StateFips_CODE,
           Transaction_DATE)
   SELECT Application_IDNO,
          Application_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          @Ld_Start_DATE,
          @Ac_BatchRunUser_TEXT,
          @Ln_EventGlobalSeq_NUMB,
          @Lc_Case_Type_NonPA_CODE,
          Opened_DATE,
          StatusCase_CODE,
          StatusCurrent_DATE,
          RsnStatusCase_CODE,
          County_IDNO,
          @Lc_Referral_Source_CODE,
          Restricted_INDC,
          MedicalOnly_INDC,
          GoodCause_CODE,
          GoodCause_DATE,
          NonCoop_CODE,
          NonCoop_DATE,
          IvdApplicant_CODE,
          @Ld_Start_DATE, --AppReq_DATE
          @Ld_Start_DATE, --AppSent_DATE,
          AppRetd_DATE,
          AppSigned_DATE,
          RsnFeeWaived_CODE,
          DescriptionComments_TEXT,
          @Lc_ApplicationStatus_CODE,
          RespondInit_CODE,
          Referral_DATE,
          @Lc_Case_Category_Full_Service_CODE,
          ApplicationFee_CODE,
          FeePaid_DATE,
          ServiceRequested_CODE,
          File_ID,
          CaseWelfare_IDNO,
          TypeWelfare_CODE,
          AttorneyState_CODE,
          AttorneyCounty_NAME,
          FeeCheckNo_TEXT,
          StatusEnforce_CODE,
          ServiceState_CODE,
          ServiceCounty_NAME,
          Service_CODE,
          ChildSupportOrMedicalAssistance_INDC,
          AttorneyCourt_TEXT,
          MedicalInsuranceCardStatus_CODE,
          PayStubW2FormStatus_CODE,
          PreventAddressReleaseStatus_CODE,
          MemberSocialSecurityCardStatus_CODE,
          MarriedDivorceDecreeStatus_CODE,
          PaymentArrearsStatementStatus_CODE,
          ModifiedSupportOrderDecreeStatus_CODE,
          ChildBirthCertificateStatus_CODE,
          InformationReleaseRisk_INDC,
          AddressPfaProtection_INDC,
          PaternityAcknowledgmentStatus_CODE,
          @Li_Count_QNTY,
          @Lc_Space_TEXT,
          @Ld_Low_DATE
     FROM CAPCS_Y1 CS
    WHERE CS.IamUser_ID = @Ac_IamUser_ID
	  AND CS.Application_IDNO != @Li_Zero_Application_IDNO
      AND CS.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = @Li_RowsAffected
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	 SET @As_DescriptionErrorOut_TEXT = 'INSERT APCS_Y1 FAILED';         
     RAISERROR (50001,16,1);
    END
	

   /*
   To get the Record from CAPCM_Y1 with the Application Idno Cann't be Zero and Insert in to APCM_Y1 and Selected Record Deleted from CAPCM_Y1
   */
   SET @Ls_Sql_TEXT = 'INSERT APCM_Y1 ';
   SET @Ls_Sqldata_TEXT = '';

   INSERT APCM_Y1
		(   Application_IDNO,
			MemberMci_IDNO,
			CaseRelationship_CODE,
			CreateMemberMci_CODE,
			CpRelationshipToChild_CODE,
			CpRelationshipToNcp_CODE,
			NcpRelationshipToChild_CODE,
			DescriptionRelationship_TEXT,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			WorkerUpdate_ID,
			TransactionEventSeq_NUMB,
			OthpAtty_IDNO,
			Applicant_CODE,
			AttyComplaint_INDC,
			FamilyViolence_DATE,
			FamilyViolence_INDC,
			TypeFamilyViolence_CODE)
   SELECT Application_IDNO,
			MemberMci_IDNO,
			CaseRelationship_CODE,
			CreateMemberMci_CODE,
			CpRelationshipToChild_CODE,
			CpRelationshipToNcp_CODE,
			NcpRelationshipToChild_CODE,
			DescriptionRelationship_TEXT,
			BeginValidity_DATE,
			EndValidity_DATE,
			@Ld_Start_DATE,
			@Ac_BatchRunUser_TEXT,
			@Ln_EventGlobalSeq_NUMB,
			OthpAtty_IDNO,
			Applicant_CODE,
			AttyComplaint_INDC,
			FamilyViolence_DATE,
			FamilyViolence_INDC,
			TypeFamilyViolence_CODE
    FROM CAPCM_Y1 CM
    WHERE CM.IamUser_ID = @Ac_IamUser_ID
		AND CM.Application_IDNO != @Li_Zero_Application_IDNO
		AND CM.EndValidity_DATE = @Ld_High_DATE;
		
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;	
   
   IF @Ln_RowCount_QNTY = @Li_RowsAffected
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	 SET @As_DescriptionErrorOut_TEXT = 'INSERT APCM_Y1 FAILED';          
    END
   
   /*
   To get the Record from CAPDM_Y1 with the Application Idno Cann't be Zero and Insert in to APDM_Y1 and Selected Record Deleted from CAPDM_Y1.
   */
   SET @Ls_Sql_TEXT = 'INSERT APDM_Y1 ';
   SET @Ls_Sqldata_TEXT = '';

	/* INSERT THE VALUE IN TO APDM */
   INSERT APDM_Y1
		(   Application_IDNO,
			MemberMci_IDNO,
			Individual_IDNO,
			First_NAME,
			Last_NAME,
			Middle_NAME,
			Suffix_NAME,
			LastAlias_NAME,
			FirstAlias_NAME,
			MiddleAlias_NAME,
			MotherMaiden_NAME,
			MemberSex_CODE,
			MemberSsn_NUMB,
			Birth_DATE,
			Deceased_DATE,
			BirthCity_NAME,
			BirthCountry_CODE,
			BirthState_CODE,
			ResideCounty_IDNO,
			ColorEyes_CODE,
			ColorHair_CODE,
			Race_CODE,
			DescriptionHeight_TEXT,
			DescriptionWeightLbs_TEXT,
			Marriage_DATE,
			Divorce_INDC,
			Divorce_DATE,
			AlienRegistn_ID,
			Language_CODE,
			Interpreter_INDC,
			CellPhone_NUMB,
			HomePhone_NUMB,
			Contact_EML,
			LicenseDriverNo_TEXT,
			LicenseIssueState_CODE,
			TypeProblem_CODE,
			CurrentMilitary_INDC,
			MilitaryBranch_CODE,
			MilitaryEnd_DATE,
			EverIncarcerated_INDC,
			PaternityEst_INDC,
			PaternityEst_CODE,
			PaternityEst_DATE,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			WorkerUpdate_ID,
			TransactionEventSeq_NUMB,
			StateMarriage_CODE,
			StateDivorce_CODE,
			FilePaternity_ID,
			CountyPaternity_IDNO,
			SuffixAlias_NAME,
			OthpInst_IDNO,
			GeneticTesting_INDC,
			IveParty_IDNO,
			ChildCoveredInsurance_INDC,
			EverReceivedMedicaid_INDC,
			ChildParentDivorceState_CODE,
			ChildParentDivorceCounty_NAME,
			ChildParentDivorce_DATE,
			DirectSupportPay_INDC,
			AdditionalNotes_TEXT,
			TypeOrder_CODE,
			PaternityEstablishedByOrder_INDC,
			HusbandIsNotFather_INDC,
			MarriageDuringChildBirthState_CODE,
			MarriageDuringChildBirthCounty_NAME,
			MarriageDuringChildBirth_DATE,
			MarriedDuringChildBirthHusband_NAME,
			MothermarriedDuringChildBirth_INDC,
			FatherNameOnBirthCertificate_INDC,
			HusbandSuffix_NAME,
			HusbandMiddle_NAME,
			HusbandLast_NAME,
			HusbandFirst_NAME,
			EstablishedParentsMarriageState_CODE,
			EstablishedParentsMarriageCounty_NAME,
			EstablishedParentsMarriage_DATE,
			EstablishedFatherMci_IDNO,
			EstablishedFatherSuffix_NAME,
			EstablishedFatherMiddle_NAME,
			EstablishedFatherLast_NAME,
			EstablishedFatherFirst_NAME,
			EstablishedMotherMci_IDNO,
			EstablishedMotherSuffix_NAME,
			EstablishedMotherMiddle_NAME,
			EstablishedMotherLast_NAME,
			EstablishedMotherFirst_NAME,
			EstablishedFather_CODE,
			EstablishedMother_CODE,
			ConceptionState_CODE,
			ConceptionCity_NAME,
			IncomeFrequency_CODE,
			OtherIncome_AMNT,
			OtherIncomeType_CODE,
			OtherIncome_INDC,
			IncarceratedTo_DATE,
			IncarceratedFrom_DATE,
			MilitaryStart_DATE,
			DivorceCounty_NAME,
			CountyMarriage_NAME,
			CourtDivorce_TEXT,
			StateLastShared_CODE,
			DivorceProceeding_INDC,
			NcpProvideChildInsurance_INDC)
   SELECT Application_IDNO,
			MemberMci_IDNO,
			Individual_IDNO,
			First_NAME,
			Last_NAME,
			Middle_NAME,
			Suffix_NAME,
			LastAlias_NAME,
			FirstAlias_NAME,
			MiddleAlias_NAME,
			MotherMaiden_NAME,
			MemberSex_CODE,
			MemberSsn_NUMB,
			Birth_DATE,
			Deceased_DATE,
			BirthCity_NAME,
			CASE ISNULL(BirthState_CODE,@Lc_Space_TEXT)
				WHEN @Lc_Space_TEXT THEN BirthCountry_CODE
				ELSE @Lc_US_Country_CODE
			END,
			BirthState_CODE,
			ResideCounty_IDNO,
			ColorEyes_CODE,
			ColorHair_CODE,
			Race_CODE,
			DescriptionHeight_TEXT,
			DescriptionWeightLbs_TEXT,
			Marriage_DATE,
			Divorce_INDC,
			Divorce_DATE,
			AlienRegistn_ID,
			Language_CODE,
			Interpreter_INDC,
			CellPhone_NUMB,
			HomePhone_NUMB,
			Contact_EML,
			LicenseDriverNo_TEXT,
			LicenseIssueState_CODE,
			TypeProblem_CODE,
			CurrentMilitary_INDC,
			MilitaryBranch_CODE,
			MilitaryEnd_DATE,
			EverIncarcerated_INDC, 
			@Lc_Submit_Yes_PaternityEst_INDC, 
			PaternityEst_CODE,
			@Ld_Submit_PaternityEst_DATE,
			BeginValidity_DATE,
			EndValidity_DATE,
			@Ld_Start_DATE,
			@Ac_BatchRunUser_TEXT,
			@Ln_EventGlobalSeq_NUMB,
			StateMarriage_CODE,
			StateDivorce_CODE,
			FilePaternity_ID,
			CountyPaternity_IDNO,
			SuffixAlias_NAME,
			OthpInst_IDNO,
			GeneticTesting_INDC,
			IveParty_IDNO,
			CASE ISNULL(ChildCoveredInsurance_INDC,@Lc_Space_TEXT)
				WHEN @Lc_Space_TEXT THEN @Lc_No_TEXT
				ELSE ChildCoveredInsurance_INDC
			END,
			CASE ISNULL(EverReceivedMedicaid_INDC,@Lc_Space_TEXT)
				WHEN @Lc_Space_TEXT THEN @Lc_No_TEXT
				ELSE EverReceivedMedicaid_INDC
			END,			
			ChildParentDivorceState_CODE,
			ChildParentDivorceCounty_NAME,
			ChildParentDivorce_DATE,
			DirectSupportPay_INDC,
			AdditionalNotes_TEXT,
			TypeOrder_CODE,
			PaternityEstablishedByOrder_INDC,
			HusbandIsNotFather_INDC,
			MarriageDuringChildBirthState_CODE,
			MarriageDuringChildBirthCounty_NAME,
			MarriageDuringChildBirth_DATE,
			MarriedDuringChildBirthHusband_NAME,
			MothermarriedDuringChildBirth_INDC,
			FatherNameOnBirthCertificate_INDC,
			HusbandSuffix_NAME,
			HusbandMiddle_NAME,
			HusbandLast_NAME,
			HusbandFirst_NAME,
			EstablishedParentsMarriageState_CODE,
			EstablishedParentsMarriageCounty_NAME,
			EstablishedParentsMarriage_DATE,
			EstablishedFatherMci_IDNO,
			EstablishedFatherSuffix_NAME,
			EstablishedFatherMiddle_NAME,
			EstablishedFatherLast_NAME,
			EstablishedFatherFirst_NAME,
			EstablishedMotherMci_IDNO,
			EstablishedMotherSuffix_NAME,
			EstablishedMotherMiddle_NAME,
			EstablishedMotherLast_NAME,
			EstablishedMotherFirst_NAME,
			EstablishedFather_CODE,
			EstablishedMother_CODE,
			ConceptionState_CODE,
			ConceptionCity_NAME,
			IncomeFrequency_CODE,
			OtherIncome_AMNT,
			OtherIncomeType_CODE,
			OtherIncome_INDC,
			IncarceratedTo_DATE,
			IncarceratedFrom_DATE,
			MilitaryStart_DATE,
			DivorceCounty_NAME,
			CountyMarriage_NAME,
			CourtDivorce_TEXT,
			StateLastShared_CODE,
			DivorceProceeding_INDC,
			NcpProvideChildInsurance_INDC
    FROM CAPDM_Y1 DM
    WHERE DM.IamUser_ID = @Ac_IamUser_ID
		AND DM.Application_IDNO != @Li_Zero_Application_IDNO
		AND DM.EndValidity_DATE = @Ld_High_DATE;
		
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
      
   IF @Ln_RowCount_QNTY = @Li_RowsAffected
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	 SET @As_DescriptionErrorOut_TEXT = 'INSERT APDM_Y1 FAILED';     
    END
    
   /*
   To get the Record from CAPAH_Y1 with the Application Idno Cann't be Zero and Insert in to APAH_Y1 and Selected Record Deleted from CAPAH_Y1
   */
   SET @Ls_Sql_TEXT = 'INSERT APAH_Y1 ';
   SET @Ls_Sqldata_TEXT = '';

   INSERT APAH_Y1
		(   Application_IDNO,
			MemberMci_IDNO,
			TypeAddress_CODE,
			Line1_ADDR,
			Line2_ADDR,
			City_ADDR,
			State_ADDR,
			County_ADDR,
			Zip_ADDR,
			BeginValidity_DATE,
			EndValidity_DATE,
			WorkerUpdate_ID,
			TransactionEventSeq_NUMB,
			Update_DTTM,
			Attn_ADDR,
			Country_ADDR,
			Normalization_CODE,
			AddressAsOf_DATE,
			MemberAddress_CODE)
   SELECT Application_IDNO,
			MemberMci_IDNO,
			@Lc_Mailing_TypeAddress_CODE,			
			Line1_ADDR,
			Line2_ADDR,
			City_ADDR,
			State_ADDR,
			County_ADDR,
			Zip_ADDR,
			BeginValidity_DATE,
			EndValidity_DATE,
			@Ac_BatchRunUser_TEXT,
			@Ln_EventGlobalSeq_NUMB,
			@Ld_Start_DATE,
			Attn_ADDR,
			Country_ADDR,
			Normalization_CODE,
			AddressAsOf_DATE,
			MemberAddress_CODE   
    FROM CAPAH_Y1 CM
    WHERE CM.IamUser_ID = @Ac_IamUser_ID
		AND CM.Application_IDNO != @Li_Zero_Application_IDNO
		AND CM.EndValidity_DATE = @Ld_High_DATE;
		
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
   
   IF @Ln_RowCount_QNTY = @Li_RowsAffected
    BEGIN    
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	 SET @As_DescriptionErrorOut_TEXT = 'INSERT APAH_Y1 FAILED';     
    END
          
    /*
    Check the given User Id have Record Exiting in CAPSR_Y1, If Exiting Valid Record Move to APSR_Y1 table with Valid Condition.
    To get the Record from CAPSR_Y1 with the Application Idno Cann't be Zero and Insert in to CAPSR_Y1 and Selected Record Deleted from CAPSR_Y1
    */
    
   IF((SELECT COUNT(1) FROM CAPSR_Y1 SR WHERE SR.IamUser_ID = @Ac_IamUser_ID AND SR.Application_IDNO != @Li_Zero_Application_IDNO) > @Li_Count_QNTY )
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT APSR_Y1 ';
	   SET @Ls_Sqldata_TEXT = '';

	   INSERT APSR_Y1
			(   Application_IDNO,
				MemberMCI_IDNO,
				PaternityAcknowledgment_INDC,
				PersonRepresentChildAsOwn_INDC,
				ChildSupportOrderExists_INDC,
				SupportOrderedCourt_TEXT,
				ChildSupport_AMNT,
				ChildSupportPayingFrequency_CODE,
				ChildSupportEffective_DATE,
				ChildSupportCounty_NAME,
				ChildSupportState_CODE)
	   SELECT Application_IDNO,
				MemberMci_IDNO,
				PaternityAcknowledgment_INDC,
				PersonRepresentChildAsOwn_INDC,
				ChildSupportOrderExists_INDC,
				SupportOrderedCourt_TEXT,
				ChildSupport_AMNT,
				ChildSupportPayingFrequency_CODE,
				ChildSupportEffective_DATE,
				ChildSupportCounty_NAME,
				ChildSupportState_CODE
		FROM CAPSR_Y1 SR
		WHERE SR.IamUser_ID = @Ac_IamUser_ID
			AND SR.Application_IDNO != @Li_Zero_Application_IDNO;
	   
	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	   
	   IF @Ln_RowCount_QNTY = @Li_RowsAffected
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		 SET @As_DescriptionErrorOut_TEXT = 'INSERT APSR_Y1 FAILED';
		 RAISERROR (50001,16,1);
		END
    END
    
    /*
    Check the given User Id have Record Exiting in CAPAG_Y1, If Exiting Valid Record Move to APAG_Y1 table with Valid Condition.
    To get the Record from CAPAG_Y1 with the Application Idno Cann't be Zero and Insert in to APAG_Y1 and Selected Record Deleted from CAPAG_Y1
    */
    
   IF((SELECT COUNT(1) FROM CAPAG_Y1 AG WHERE AG.IamUser_ID = @Ac_IamUser_ID AND AG.Application_IDNO != @Li_Zero_Application_IDNO) > @Li_Count_QNTY )
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT APAG_Y1 ';
	   SET @Ls_Sqldata_TEXT = '';

	   INSERT APAG_Y1
			(   Application_IDNO,
				Agency_IDNO,
				ServerPath_NAME,
				AgencyLine1_ADDR,
				AgencyLine2_ADDR,
				AgencyCity_ADDR,
				AgencyState_ADDR,
				AgencyZip_ADDR,
				AgencyCountry_ADDR,
				AgencyPhone_NUMB,
				AgencyFax_NUMB,
				Agency_EML,
				MemberMCI_IDNO)
	   SELECT Application_IDNO,				
				Agency_IDNO,
				ServerPath_NAME,
				AgencyLine1_ADDR,
				AgencyLine2_ADDR,
				AgencyCity_ADDR,
				AgencyState_ADDR,
				AgencyZip_ADDR,
				AgencyCountry_ADDR,
				AgencyPhone_NUMB,
				AgencyFax_NUMB,
				Agency_EML,
				MemberMci_IDNO
		FROM CAPAG_Y1 AG
		WHERE AG.IamUser_ID = @Ac_IamUser_ID
			AND AG.Application_IDNO != @Li_Zero_Application_IDNO;
	   
	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	   
	   IF @Ln_RowCount_QNTY = @Li_RowsAffected
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		 SET @As_DescriptionErrorOut_TEXT = 'INSERT APAG_Y1 FAILED';		 
		END
    END
    
   /*
    Check the given User Id have Record Exiting in CALSP_Y1, If Exiting Valid Record Move to ALSP_Y1 table with Valid Condition.
    To get the Record from CALSP_Y1 with the Application Idno Cann't be Zero and Insert in to ALSP_Y1 and Selected Record Deleted from CALSP_Y1
    */
    
   IF((SELECT COUNT(1) FROM CALSP_Y1 SP WHERE SP.IamUser_ID = @Ac_IamUser_ID AND SP.Application_IDNO != @Li_Zero_Application_IDNO) > @Li_Count_QNTY )
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT ALSP_Y1 ';
	   SET @Ls_Sqldata_TEXT = '';

	   INSERT ALSP_Y1
			(   Application_IDNO,
				MemberMCI_IDNO,
				YearMonth_NUMB,
				Owed_AMNT,
				Paid_AMNT)
	   SELECT Application_IDNO,
				MemberMci_IDNO,
				YearMonth_NUMB,
				Owed_AMNT,
				Paid_AMNT
		FROM CALSP_Y1 SP
		WHERE SP.IamUser_ID = @Ac_IamUser_ID
			AND SP.Application_IDNO != @Li_Zero_Application_IDNO;
	   
	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	   
	   IF @Ln_RowCount_QNTY = @Li_RowsAffected
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		 SET @As_DescriptionErrorOut_TEXT = 'INSERT ALSP_Y1 FAILED';		 
		END
    END
    
   /*
    Check the given User Id have Record Exiting in CAPMI_Y1, If Exiting Valid Record Move to APMI_Y1 table with Valid Condition.
    To get the Record from CAPMI_Y1 with the Application Idno Cann't be Zero and Insert in to APMI_Y1 and Selected Record Deleted from CAPMI_Y1
    */
    
   IF((SELECT COUNT(1) FROM CAPMI_Y1 MI WHERE MI.IamUser_ID = @Ac_IamUser_ID AND MI.Application_IDNO != @Li_Zero_Application_IDNO) > @Li_Count_QNTY )
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT APMI_Y1 ';
	   SET @Ls_Sqldata_TEXT = '';

	   INSERT APMI_Y1
			(   Application_IDNO,
				MemberMCI_IDNO,
				MedicalOthpIns_IDNO,
				MedicalPolicyInsNo_TEXT,
				MedicalMonthlyPremium_AMNT,
				DentalPolicyInsNo_TEXT,
				DentalOthpIns_IDNO,
				DentalMonthlyPremium_AMNT)
	   SELECT Application_IDNO,
				MemberMci_IDNO,
				MedicalOthpIns_IDNO,
				MedicalPolicyInsNo_TEXT,
				MedicalMonthlyPremium_AMNT,
				DentalPolicyInsNo_TEXT,
				DentalOthpIns_IDNO,
				DentalMonthlyPremium_AMNT				
		FROM CAPMI_Y1 MI
		WHERE MI.IamUser_ID = @Ac_IamUser_ID
			AND MI.Application_IDNO != @Li_Zero_Application_IDNO;

	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;				
	   
	   IF @Ln_RowCount_QNTY = @Li_RowsAffected
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		 SET @As_DescriptionErrorOut_TEXT = 'INSERT APMI_Y1 FAILED';		 
		END
	  
    END
   
   /*
    Check the given User Id have Record Exiting in CAPDI_Y1, If Exiting Valid Record Move to APDI_Y1 table with Valid Condition.
    To get the Record from CAPDI_Y1 with the Application Idno Cann't be Zero and Insert in to APDI_Y1 and Selected Record Deleted from CAPDI_Y1
    */
    
   IF((SELECT COUNT(1) FROM CAPDI_Y1 DI WHERE DI.IamUser_ID = @Ac_IamUser_ID AND DI.Application_IDNO != @Li_Zero_Application_IDNO) > @Li_Count_QNTY )
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT APDI_Y1 ';
	   SET @Ls_Sqldata_TEXT = '';

	   INSERT APDI_Y1
			(   Application_IDNO,
				MemberMCI_IDNO,
				DependantMci_IDNO,
				MedicalIns_INDC,
				DentalIns_INDC)
	   SELECT Application_IDNO,
				MemberMci_IDNO,
				DependantMci_IDNO,
				MedicalIns_INDC,
				DentalIns_INDC
		FROM CAPDI_Y1 DI
		WHERE DI.IamUser_ID = @Ac_IamUser_ID
			AND DI.Application_IDNO != @Li_Zero_Application_IDNO;
	   
	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	   
	   IF @Ln_RowCount_QNTY = @Li_RowsAffected
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		 SET @As_DescriptionErrorOut_TEXT = 'INSERT APDI_Y1 FAILED';
		END	   
    END  
   
    EXECUTE BATCH_CPORTAL_UPDATE$SP_APPLICATION_UPDATE      
	  @Ac_IamUser_ID		= @Ac_IamUser_ID,
	  @As_ErrorMessage_TEXT	= @Ls_ErrorMessage_TEXT OUTPUT, 	 
	  @As_Sql_TEXT			= @Ls_Sql_TEXT OUTPUT, 
	  @As_Sqldata_TEXT		= @Ls_Sqldata_TEXT OUTPUT,
	  @An_Error_NUMB		= @Ln_Error_NUMB OUTPUT, 
	  @An_ErrorLine_NUMB	= @Ln_ErrorLine_NUMB OUTPUT,
      @Ac_Msg_CODE          = @Lc_Msg_CODE OUTPUT;        
           
    select @Ac_Msg_CODE,@As_DescriptionErrorOut_TEXT;
    
	IF(@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE )
	BEGIN
		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
		@As_Procedure_NAME		   = @Ls_SubRoutine_TEXT,  
		@As_ErrorMessage_TEXT	   = @Ls_ErrorMessage_TEXT,
		@As_Sql_TEXT			   = @Ls_Sql_TEXT,
		@As_Sqldata_TEXT	       = @Ls_Sqldata_TEXT,
		@An_Error_NUMB			   = @Ln_Error_NUMB,
		@An_ErrorLine_NUMB		   = @Ln_ErrorLine_NUMB,  
		@As_DescriptionError_TEXT = @As_DescriptionErrorOut_TEXT      OUTPUT ; 
		
		SET  @As_DescriptionErrorOut_TEXT = @As_DescriptionErrorOut_TEXT;
	END
	
	SET  @As_DescriptionErrorOut_TEXT = ERROR_MESSAGE();              

	SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    SET @As_DescriptionErrorOut_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SELECT ERROR_MESSAGE(),ERROR_LINE();
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    
    SET @Ln_Error_NUMB = ERROR_NUMBER();  
    SET @Ln_ErrorLine_NUMB = ERROR_LINE(); 
  
     --Check for Exception information to log the description text based on the error
    
    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
	 @As_Procedure_NAME		   = @Ls_Routine_TEXT,  
	 @As_ErrorMessage_TEXT	   = @Ls_ErrorMessage_TEXT,
	 @As_Sql_TEXT			   = @Ls_Sql_TEXT,
	 @As_Sqldata_TEXT	       = @Ls_Sqldata_TEXT,
	 @An_Error_NUMB			   = @Ln_Error_NUMB,
	 @An_ErrorLine_NUMB		   = @Ln_ErrorLine_NUMB,  
	 @As_DescriptionError_TEXT = @As_DescriptionErrorOut_TEXT      OUTPUT ; 
	      SET  @As_DescriptionErrorOut_TEXT = ERROR_MESSAGE();
  END CATCH
 END


GO
