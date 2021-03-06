/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION reads the data from the temorary table, 
					   inserts the data into application tables for creating new cases or updates application tables 
					   with any new data for pending applications in the system.
								
Frequency			 : Daily
Developed On		 : 06/08/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APAH
-----------------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION]
   @An_Application_IDNO			NUMERIC(15),
   @An_MemberMciDfs_IDNO		NUMERIC(10),
   @Ad_Run_DATE					DATE,
   @Ad_Update_DTTM				DATETIME2, 
   @An_TransactionEventSeq_NUMB NUMERIC(19),
   @Ac_First_NAME				CHAR(16),
   @Ac_Last_NAME				CHAR(20),
   @Ac_Middle_NAME				CHAR(20),
   @Ac_Suffix_NAME				CHAR(4),
   @Ac_MemberSex_CODE			CHAR(1),
   @An_MemberSsn_NUMB			NUMERIC(9),
   @Ad_DfsBirth_DATE			DATE,
   @As_Line1_ADDR				VARCHAR(50),
   @As_Line2_ADDR				VARCHAR(50),
   @Ac_City_ADDR				CHAR(28),
   @Ac_State_ADDR				CHAR(2),
   @Ac_Zip_ADDR					CHAR(15),
   @Ac_Race_CODE				CHAR(1),
   @Ac_Normalization_CODE		CHAR(1),
   @Ac_Msg_CODE					CHAR(5)		   OUTPUT,
   @As_DescriptionError_TEXT	VARCHAR(4000)  OUTPUT
AS
   
  BEGIN
   SET NOCOUNT ON;
	  	
   DECLARE @Lc_ValueNo_INDC					  CHAR(1) = 'N',
           @Lc_Space_TEXT                     CHAR(1) = ' ',
           @Lc_StatusFailed_CODE              CHAR(1) = 'F',
           @Lc_CaseRelationshipClient_CODE    CHAR(1) = 'C',
           @Lc_TypeAddressM_CODE              CHAR(1) = 'M',
           @Lc_CountryUs_CODE                 CHAR(2) = 'US',
           @Lc_CpRelationshipToChildNot_CODE  CHAR(3) = 'NOT',
           @Lc_CpRelationshipToNcpNot_CODE    CHAR(3) = 'NOT',
           @Lc_NcpRelationshipToChild_CODE    CHAR(3) = 'NOT',
           @Lc_BatchRunUser_TEXT              CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_PROCESS',
           @Ld_High_DATE                      DATE = '12/31/9999',
           @Ld_Low_DATE                       DATE = '01/01/0001';
   DECLARE @Ln_Zero_NUMB					  NUMERIC(1) = 0,
           @Ln_Error_NUMB					  NUMERIC(11),
           @Ln_ErrorLine_NUMB				  NUMERIC(11),
           @Lc_Msg_CODE						  CHAR(5) = '',
           @Ls_Sql_TEXT						  VARCHAR(100) = '',
           @Ls_Sqldata_TEXT					  VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT		  VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT			  VARCHAR(4000) = '';
  
	BEGIN TRY 
	     -- Create a Foster care client agency record in APCM, APDM, APAH tables
		 -- Create application case member for the foster care agency 
								
			SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
			SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), 0) + ',MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMciDfs_IDNO AS VARCHAR), 0);
			EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
				@An_Application_IDNO			= @An_Application_IDNO,
				@An_MemberMci_IDNO				= @An_MemberMciDfs_IDNO,
				@Ac_CaseRelationship_CODE		= @Lc_CaseRelationshipClient_CODE,
				@Ac_CreateMemberMci_CODE		= @Lc_ValueNo_INDC,
				@Ac_CpRelationshipToChild_CODE	= @Lc_Space_TEXT,
				@Ac_CpRelationshipToNcp_CODE	= @Lc_CpRelationshipToNcpNot_CODE,
				@Ac_NcpRelationshipToChild_CODE = @Lc_Space_TEXT,
				@Ac_DescriptionRelationship_TEXT = @Lc_Space_TEXT,
				@Ad_BeginValidity_DATE			= @Ad_Run_DATE,
				@Ad_EndValidity_DATE			= @Ld_High_DATE,
				@Ad_Update_DTTM					= @Ad_Update_DTTM,
				@Ac_WorkerUpdate_ID				= @Lc_BatchRunUser_TEXT,
				@An_TransactionEventSeq_NUMB	= @An_TransactionEventSeq_NUMB,
				@An_OthpAtty_IDNO				= @Ln_Zero_NUMB,
				@Ac_Applicant_CODE				= @Lc_Space_TEXT,
				@Ac_AttyComplaint_INDC			= @Lc_Space_TEXT,
				@Ad_FamilyViolence_DATE			= @Ld_Low_DATE,
				@Ac_FamilyViolence_INDC			= @Lc_Space_TEXT,
				@Ac_TypeFamilyViolence_CODE		= @Lc_Space_TEXT,
				@Ac_Msg_CODE					= @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT		= @Ls_DescriptionError_TEXT OUTPUT;
				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					BEGIN
						RAISERROR (50001,16,1);
					END
			
		-- Create application demo record for foster care Mci 
			SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
			SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), 0) + ',MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMciDfs_IDNO AS VARCHAR), 0);
			EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
				@An_Application_IDNO		= @An_Application_IDNO,
				@An_MemberMci_IDNO			= @An_MemberMciDfs_IDNO,		
				@An_Individual_IDNO			= @Ln_Zero_NUMB,
				@Ac_First_NAME				= @Ac_First_NAME, 	
				@Ac_Last_NAME				= @Ac_Last_NAME, 
				@Ac_Middle_NAME				= @Ac_Middle_NAME, 
				@Ac_Suffix_NAME				= @Ac_Suffix_NAME, 
				@Ac_LastAlias_NAME			= @Lc_Space_TEXT,
				@Ac_FirstAlias_NAME			= @Lc_Space_TEXT,
				@Ac_MiddleAlias_NAME		= @Lc_Space_TEXT,
				@Ac_MotherMaiden_NAME		= @Lc_Space_TEXT,
				@Ac_MemberSex_CODE			= @Ac_MemberSex_CODE, 
				@An_MemberSsn_NUMB			= @An_MemberSsn_NUMB, 
				@Ad_Birth_DATE				= @Ad_DfsBirth_DATE, 
				@Ad_Deceased_DATE			= @Ld_Low_DATE,
				@Ac_BirthCity_NAME			= @Lc_Space_TEXT,
				@Ac_BirthCountry_CODE		= @Lc_Space_TEXT,	
				@Ac_BirthState_CODE			= @Lc_Space_TEXT,	
				@An_ResideCounty_IDNO		= @Ln_Zero_NUMB,	
				@Ac_ColorEyes_CODE			= @Lc_Space_TEXT,
				@Ac_ColorHair_CODE			= @Lc_Space_TEXT,
				@Ac_Race_CODE				= @Ac_Race_CODE, 			
				@Ac_DescriptionHeight_TEXT	= @Lc_Space_TEXT,
				@Ac_DescriptionWeightLbs_TEXT	= @Lc_Space_TEXT,
				@Ad_Marriage_DATE			= @Ld_Low_DATE,
				@Ac_Divorce_INDC			= @Lc_Space_TEXT,
				@Ad_Divorce_DATE			= @Ld_Low_DATE,
				@Ac_AlienRegistn_ID			= @Lc_Space_TEXT,
				@Ac_Language_CODE			= @Lc_Space_TEXT,
				@Ac_Interpreter_INDC		= @Lc_Space_TEXT,
				@An_CellPhone_NUMB			= @Ln_Zero_NUMB,
				@An_HomePhone_NUMB			= @Ln_Zero_NUMB,
				@As_Contact_EML				= @Lc_Space_TEXT,
				@Ac_LicenseDriverNo_TEXT	= @Lc_Space_TEXT,
				@Ac_LicenseIssueState_CODE	= @Lc_Space_TEXT,
				@Ac_TypeProblem_CODE		= @Lc_Space_TEXT,
				@Ac_CurrentMilitary_INDC	= @Lc_Space_TEXT,
				@Ac_MilitaryBranch_CODE		= @Lc_Space_TEXT,
				@Ad_MilitaryEnd_DATE		= @Ld_Low_DATE,
				@Ac_EverIncarcerated_INDC	= @Lc_Space_TEXT,
				@Ac_PaternityEst_INDC		= @Lc_Space_TEXT,
				@Ac_PaternityEst_CODE		= @Lc_Space_TEXT,
				@Ad_PaternityEst_DATE		= @Ld_Low_DATE,
				@Ad_BeginValidity_DATE		= @Ad_Run_DATE,
				@Ad_EndValidity_DATE		= @Ld_High_DATE,
				@Ad_Update_DTTM				= @Ad_Update_DTTM,
				@Ac_WorkerUpdate_ID			= @Lc_BatchRunUser_TEXT,
				@An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
				@Ac_StateMarriage_CODE		= @Lc_Space_TEXT,
				@Ac_StateDivorce_CODE		= @Lc_Space_TEXT,
				@Ac_FilePaternity_ID		= @Lc_Space_TEXT,
				@An_CountyPaternity_IDNO	= @Ln_Zero_NUMB,
				@Ac_SuffixAlias_NAME		= @Lc_Space_TEXT,
				@An_OthpInst_IDNO			= @Ln_Zero_NUMB,
				@Ac_GeneticTesting_INDC		= @Lc_Space_TEXT,
				@An_IveParty_IDNO			= @Ln_Zero_NUMB,
				@Ac_ChildCoveredInsurance_INDC = @Lc_Space_TEXT,
				@Ac_EverReceivedMedicaid_INDC  = @Lc_Space_TEXT,
				@Ac_ChildParentDivorceState_CODE = @Lc_Space_TEXT,
				@Ac_ChildParentDivorceCounty_NAME = @Lc_Space_TEXT,
				@Ad_ChildParentDivorce_DATE		 = @Ld_Low_DATE,
				@Ac_DirectSupportPay_INDC		 = @Lc_Space_TEXT,
				@As_AdditionalNotes_TEXT		 = @Lc_Space_TEXT,
				@Ac_TypeOrder_CODE				 = @Lc_Space_TEXT,
				@Ac_PaternityEstablishedByOrder_INDC	= @Lc_Space_TEXT,
				@Ac_HusbandIsNotFather_INDC				= @Lc_Space_TEXT,
				@Ac_MarriageDuringChildBirthState_CODE  = @Lc_Space_TEXT,
				@Ac_MarriageDuringChildBirthCounty_NAME	= @Lc_Space_TEXT,
				@Ad_MarriageDuringChildBirth_DATE		= @Ld_Low_DATE,
				@As_MarriedDuringChildBirthHusband_NAME	= @Lc_Space_TEXT,
				@Ac_MothermarriedDuringChildBirth_INDC	= @Lc_Space_TEXT,
				@Ac_FatherNameOnBirthCertificate_INDC	= @Lc_Space_TEXT,
				@Ac_HusbandSuffix_NAME					= @Lc_Space_TEXT,
				@Ac_HusbandMiddle_NAME					= @Lc_Space_TEXT,
				@Ac_HusbandLast_NAME					= @Lc_Space_TEXT,
				@Ac_HusbandFirst_NAME					= @Lc_Space_TEXT,
				@Ac_EstablishedParentsMarriageState_CODE	= @Lc_Space_TEXT,
				@Ac_EstablishedParentsMarriageCounty_NAME = @Lc_Space_TEXT,
				@Ad_EstablishedParentsMarriage_DATE		= @Ld_Low_DATE,
				@An_EstablishedFatherMci_IDNO			= @Ln_Zero_NUMB,
				@Ac_EstablishedFatherSuffix_NAME		= @Lc_Space_TEXT,
				@Ac_EstablishedFatherMiddle_NAME		= @Lc_Space_TEXT,
				@Ac_EstablishedFatherLast_NAME			= @Lc_Space_TEXT,
				@Ac_EstablishedFatherFirst_NAME			= @Lc_Space_TEXT,
				@An_EstablishedMotherMci_IDNO			= @Ln_Zero_NUMB,
				@Ac_EstablishedMotherSuffix_NAME		= @Lc_Space_TEXT,
				@Ac_EstablishedMotherMiddle_NAME		= @Lc_Space_TEXT,
				@Ac_EstablishedMotherLast_NAME			= @Lc_Space_TEXT,
				@Ac_EstablishedMotherFirst_NAME			= @Lc_Space_TEXT,
				@Ac_EstablishedFather_CODE				= @Lc_Space_TEXT,
				@Ac_EstablishedMother_CODE				= @Lc_Space_TEXT,
				@Ac_ConceptionState_CODE				= @Lc_Space_TEXT,
				@Ac_ConceptionCity_NAME					= @Lc_Space_TEXT,
				@Ac_IncomeFrequency_CODE				= @Lc_Space_TEXT,
				@An_OtherIncome_AMNT					= @Ln_Zero_NUMB,
				@Ac_OtherIncomeType_CODE				= @Lc_Space_TEXT,
				@Ac_OtherIncome_INDC					= @Lc_Space_TEXT,
				@Ad_IncarceratedTo_DATE					= @Ld_Low_DATE,
				@Ad_IncarceratedFrom_DATE				= @Ld_Low_DATE,
				@Ad_MilitaryStart_DATE					= @Ld_Low_DATE,
				@Ac_DivorceCounty_NAME					= @Lc_Space_TEXT,
				@Ac_CountyMarriage_NAME					= @Lc_Space_TEXT,
				@Ac_CourtDivorce_TEXT					= @Lc_Space_TEXT,
				@Ac_StateLastShared_CODE				= @Lc_Space_TEXT,
				@Ac_DivorceProceeding_INDC				= @Lc_Space_TEXT,
				@Ac_NcpProvideChildInsurance_INDC       = @Lc_Space_TEXT,
				@Ac_Msg_CODE							= @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT				= @Ls_DescriptionError_TEXT OUTPUT;
				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					BEGIN
						RAISERROR (50001,16,1);
					END
			
		-- Create application AHIS record for foster care Mci
		    SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APAH ';
			SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), 0) + ',MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMciDfs_IDNO AS VARCHAR), 0); 
			EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APAH
				@An_Application_IDNO				= @An_Application_IDNO,
				@An_MemberMci_IDNO					= @An_MemberMciDfs_IDNO,
				@Ac_TypeAddress_CODE				= @Lc_TypeAddressM_CODE,
				@As_Line1_ADDR						= @As_Line1_ADDR, 
				@As_Line2_ADDR						= @As_Line2_ADDR, 
				@Ac_City_ADDR						= @Ac_City_ADDR, 
				@Ac_State_ADDR						= @Ac_State_ADDR, 
				@Ac_County_ADDR						= @Lc_CountryUs_CODE,
				@Ac_Zip_ADDR						= @Ac_Zip_ADDR, 
				@Ad_BeginValidity_DATE				= @Ad_Run_DATE,
				@Ad_EndValidity_DATE				= @Ld_High_DATE,
				@Ac_WorkerUpdate_ID					= @Lc_BatchRunUser_TEXT,
				@An_TransactionEventSeq_NUMB		= @An_TransactionEventSeq_NUMB,
				@Ad_Update_DTTM						= @Ad_Update_DTTM,
				@Ac_Attn_ADDR						= @Lc_Space_TEXT,
				@Ac_Country_ADDR					= @Lc_Space_TEXT,
				@Ac_Normalization_CODE				= @Ac_Normalization_CODE, 
				@Ad_AddressAsOf_DATE				= @Ad_Run_DATE,
				@Ac_MemberAddress_CODE				= @Lc_Space_TEXT,
				@Ac_Msg_CODE						= @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT			= @Ls_DescriptionError_TEXT OUTPUT;
				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					BEGIN
						RAISERROR (50001,16,1);
					END
									
		SET @As_DescriptionError_TEXT = ' ';
		SET @Ac_Msg_code = '';
		
      END TRY

	  BEGIN CATCH
		
        --Set Error Description
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SELECT ERROR_MESSAGE();
		SET @Ln_Error_NUMB = ERROR_NUMBER();
		SET @Ln_ErrorLine_NUMB = ERROR_LINE();
		IF @Ln_Error_NUMB <> 50001
			BEGIN
				SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
			END
		
		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
			@As_Procedure_NAME			= @Ls_Procedure_NAME,
            @As_ErrorMessage_TEXT		= @Ls_ErrorMessage_TEXT,
            @As_Sql_TEXT				= @Ls_Sql_TEXT,
            @As_Sqldata_TEXT			= @Ls_Sqldata_TEXT,
            @An_Error_NUMB				= @Ln_Error_NUMB,
            @An_ErrorLine_NUMB			= @Ln_ErrorLine_NUMB,
            @As_DescriptionError_TEXT	= @Ls_DescriptionError_TEXT OUTPUT ;
            SET @As_DescriptionError_TEXT	= @Ls_DescriptionError_TEXT;
   
      END CATCH;
 
   END
   

GO
