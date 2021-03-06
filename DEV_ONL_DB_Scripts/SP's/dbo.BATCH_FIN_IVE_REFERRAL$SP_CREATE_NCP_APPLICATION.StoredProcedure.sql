/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION inserts data for the NCP into APCS,APCM, APDM, APAH and APEH
					   tables from the referral data.
Frequency			 : Daily
Developed On		 : 12/12/2011
Called By			 : None
Called On			 : BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCS,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APAH,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APEH,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION,
					   BATCH_COMMON$SP_GET_OTHP
-----------------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION]
 @An_Application_IDNO                    NUMERIC(15),
 @An_ParentMci_IDNO                      NUMERIC(10),
 @Ad_Run_DATE                            DATE,
 @Ad_Update_DTTM                         DATETIME2,
 @An_TransactionEventSeq_NUMB            NUMERIC(19),
 @Ac_Parent_NAME                         CHAR(24),
 @Ac_ParentAlias_NAME                    CHAR(24),
 @Ac_ParentSex_CODE                      CHAR(1),
 @An_ParentPrimarySsn_NUMB               NUMERIC(9),
 @Ad_ParentBirth_DATE                    DATE,
 @Ac_Race_CODE                           CHAR(1),
 @An_ParentCaseWelfare_IDNO              NUMERIC(10),
 @An_IvePartyParent_IDNO                 NUMERIC(10),
 @Ac_FatherMother_CODE                   CHAR(1),
 @Ac_StatusCase_CODE                     CHAR(1),
 @An_County_IDNO                         NUMERIC(3),
 @As_ParentLine1_ADDR                    VARCHAR(50),
 @As_ParentLine2_ADDR                    VARCHAR(50),
 @Ac_ParentCity_ADDR                     CHAR(28),
 @Ac_ParentState_ADDR                    CHAR(2),
 @Ac_ParentZip_ADDR                      CHAR(15),
 @Ac_ParentAddressNormalization_CODE     CHAR(1),
 @Ac_ParentEmpl_NAME                     CHAR(35),
 @As_ParentEmplLine1_ADDR                VARCHAR(50),
 @As_ParentEmplLine2_ADDR                VARCHAR(50),
 @Ac_ParentEmplCity_ADDR                 CHAR(28),
 @Ac_ParentEmplState_ADDR                CHAR(2),
 @Ac_ParentEmplZip_ADDR                  CHAR(15),
 @Ac_ParentEmplAddressNormalization_CODE CHAR(1),
 @Ac_ParentInformation_INDC              CHAR(1),
 @Ac_Msg_CODE                            CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT               VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Ln_MemberMciU_IDNO                 NUMERIC(10) = 0000999995,
           @Lc_ApplicationStatus_CODE          CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_ValueNo_INDC                    CHAR(1) = 'N',
           @Lc_ValueR_CODE                     CHAR(1) = 'R',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_TypeOthpEmployer_CODE           CHAR(1) = 'E',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_DacsesCaseTypeF_CODE            CHAR(1) = 'F',
           @Lc_ServiceRequestF_CODE            CHAR(1) = 'F',
           @Lc_CaseRelationshipNcp_CODE        CHAR(1) = 'A',
           @Lc_TypeAddressM_CODE               CHAR(1) = 'M',
           @Lc_SourceRfrlD_CODE                CHAR(1) = 'N',
           @Lc_TypeWelfareF_CODE               CHAR(1) = 'F',
           @Lc_FamilyViolenceN_INDC            CHAR(1) = 'N',
           @Lc_IvdApplicantCp_CODE             CHAR(2) = 'CP',
           @Lc_CountryUs_CODE                  CHAR(2) = 'US',
           @Lc_CaseCategoryFs_CODE             CHAR(2) = 'FS',
           @Lc_TypeFamilyViolenceDe_CODE       CHAR(2) = 'DE',
           @Lc_CpRelationshipToChildNot_CODE   CHAR(3) = 'NOT',
           @Lc_CpRelationshipToNcpNot_CODE     CHAR(3) = 'NOT',
           @Lc_NcpRelationshipToChildMtr_CODE  CHAR(3) = 'MTR',
           @Lc_NcpRelationshipToChildFtr_CODE  CHAR(3) = 'FTR',
           @Lc_NcpRelationshipToChildNot_CODE  CHAR(3) = 'NOT',
           @Lc_SourceLocIve_CODE               CHAR(3) = 'IVE',
           @Lc_StatusEnforceWork_CODE          CHAR(4) = 'WORK',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB					   NUMERIC(1) = 0,
           @Ln_OtherParty_IDNO				   NUMERIC(9) = 0,
           @Ln_ParentPrimarySsn_NUMB		   NUMERIC(9) = 0,
           @Ln_ParentMci_IDNO				   NUMERIC(10) = 0,
           @Ln_IvePartyParent_IDNO             NUMERIC(10) = 0,
           @Ln_Error_NUMB					   NUMERIC(11),
           @Ln_ErrorLine_NUMB				   NUMERIC(11),
           @Li_Comma_QNTY					   SMALLINT,
           @Li_SpaceCount_QNTY				   SMALLINT,
           @Li_DelimiterCount_QNTY			   SMALLINT,
           @Lc_NormalizationU_CODE			   CHAR(1) = '',
           @Lc_TypeError_CODE				   CHAR(1) = '',
           @Lc_RaceU_CODE					   CHAR(1) = '',
           @Lc_MemberSexU_CODE				   CHAR(1) = '',
           @Lc_TypeAddress_CODE				   CHAR(1) = '',
           @Lc_TypeAddressU_CODE			   CHAR(1) = '',
           @Lc_Sex_CODE						   CHAR(1) = '',
           @Lc_StateU_ADDR					   CHAR(2) = '',
           @Lc_ParentState_ADDR				   CHAR(2) = '',
           @Lc_FatherMother_CODE			   CHAR(3) = '',
           @Lc_Suffix_NAME					   CHAR(4) = '',
           @Lc_SuffixU_NAME					   CHAR(4) = '',
           @Lc_Msg_CODE						   CHAR(5) = '',
           @Lc_Job_ID						   CHAR(7) = '',
           @Lc_ZipU_ADDR					   CHAR(15) = '',
           @Lc_ParentZip_ADDR				   CHAR(15) = '',
           @Lc_FirstU_NAME					   CHAR(16) = '',
           @Lc_ParentFirst_NAME				   CHAR(16) = '',
           @Lc_ParentAliasFirst_NAME		   CHAR(16) = '',
           @Lc_LastU_NAME					   CHAR(20) = '',
           @Lc_MiddleU_NAME					   CHAR(20) = '',
           @Lc_ParentLast_NAME				   CHAR(20) = '',
           @Lc_ParentMiddle_NAME			   CHAR(20) = '',
           @Lc_ParentAliasLast_NAME			   CHAR(20) = '',
           @Lc_ParentAliasMiddle_NAME		   CHAR(20) = '',
           @Lc_Partial_NAME					   CHAR(24) = '',
           @Lc_CityU_ADDR					   CHAR(28) = '',
           @Lc_ParentCity_ADDR				   CHAR(28) = '',
           @Lc_AttnU_ADDR					   CHAR(40) = '',
           @Lc_ParentAttn_ADDR				   CHAR(40) = '',
           @Ls_ParentLine1_ADDR				   VARCHAR(50) = '',
           @Ls_ParentLine2_ADDR				   VARCHAR(50) = '',
           @Ls_Line1U_ADDR					   VARCHAR(50) = '',
           @Ls_Line2U_ADDR					   VARCHAR(50) = '',
           @Ls_Sql_TEXT						   VARCHAR(100) = '',
           @Ls_Sqldata_TEXT					   VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT		   VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT			   VARCHAR(4000) = '',
           @Ld_ParentBirthU_DATE               DATE,
           @Ld_ParentBirth_DATE				   DATE;

  BEGIN TRY
   -- Create a Foster care NCP record in APCM, APDM, APAH, APEH tables
   
   SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCS
    @An_Application_IDNO                      = @An_Application_IDNO,
    @Ad_Application_DATE                      = @Ad_Run_DATE,
    @Ad_BeginValidity_DATE                    = @Ad_Run_DATE,
    @Ad_EndValidity_DATE                      = @Ld_High_DATE,
    @Ad_Update_DTTM                           = @Ad_Update_DTTM,
    @Ac_WorkerUpdate_ID                       = @Lc_BatchRunUser_TEXT,
    @An_TransactionEventSeq_NUMB              = @An_TransactionEventSeq_NUMB,
    @Ac_TypeCase_CODE                         = @Lc_DacsesCaseTypeF_CODE,
    @Ad_Opened_DATE                           = @Ld_Low_DATE,
    @Ac_StatusCase_CODE                       = @Ac_StatusCase_CODE,
    @Ad_StatusCurrent_DATE                    = @Ad_Run_DATE,
    @Ac_RsnStatusCase_CODE                    = @Lc_Space_TEXT,
    @An_County_IDNO                           = @An_County_IDNO,
    @Ac_SourceRfrl_CODE                       = @Lc_SourceRfrlD_CODE,
    @Ac_Restricted_INDC                       = @Lc_Space_TEXT,
    @Ac_MedicalOnly_INDC                      = @Lc_ValueNo_INDC,
    @Ac_GoodCause_CODE                        = @Lc_Space_TEXT,
    @Ad_GoodCause_DATE                        = @Ld_Low_DATE,
    @Ac_NonCoop_CODE                          = @Lc_Space_TEXT,
    @Ad_NonCoop_DATE                          = @Ld_Low_DATE,
    @Ac_IvdApplicant_CODE                     = @Lc_IvdApplicantCp_CODE,
    @Ad_AppReq_DATE                           = @Ld_Low_DATE,
    @Ad_AppSent_DATE                          = @Ld_Low_DATE,
    @Ad_AppRetd_DATE                          = @Ld_Low_DATE,
    @Ad_AppSigned_DATE                        = @Ld_Low_DATE,
    @Ac_RsnFeeWaived_CODE                     = @Lc_Space_TEXT,
    @As_DescriptionComments_TEXT              = @Lc_Space_TEXT,
    @Ac_ApplicationStatus_CODE                = @Lc_ApplicationStatus_CODE,
    @Ac_RespondInit_CODE                      = @Lc_ValueNo_INDC,
    @Ad_Referral_DATE                         = @Ad_Run_DATE,
    @Ac_CaseCategory_CODE                     = @Lc_CaseCategoryFs_CODE,
    @Ac_ApplicationFee_CODE                   = @Lc_Space_TEXT,
    @Ad_FeePaid_DATE                          = @Ld_Low_DATE,
    @Ac_ServiceRequested_CODE                 = @Lc_ServiceRequestF_CODE,
    @Ac_File_ID                               = @Lc_Space_TEXT,
    @An_CaseWelfare_IDNO                      = @An_ParentCaseWelfare_IDNO,
    @Ac_TypeWelfare_CODE                      = @Lc_TypeWelfareF_CODE,
    @Ac_AttorneyState_CODE                    = @Lc_Space_TEXT,
    @Ac_AttorneyCounty_NAME                   = @Lc_Space_TEXT,
    @Ac_FeeCheckNo_TEXT                       = @Lc_Space_TEXT,
    @Ac_StatusEnforce_CODE                    = @Lc_StatusEnforceWork_CODE,
    @Ac_ServiceState_CODE                     = @Lc_Space_TEXT,
    @Ac_ServiceCounty_NAME                    = @Lc_Space_TEXT,
    @Ac_Service_CODE                          = @Lc_Space_TEXT,
    @Ac_ChildSupportOrMedicalAssistance_INDC  = @Lc_Space_TEXT,
    @Ac_AttorneyCourt_TEXT                    = @Lc_Space_TEXT,
    @Ac_MedicalInsuranceCardStatus_CODE       = @Lc_Space_TEXT,
    @Ac_PayStubW2FormStatus_CODE              = @Lc_Space_TEXT,
    @Ac_PreventAddressReleaseStatus_CODE      = @Lc_Space_TEXT,
    @Ac_MemberSocialSecurityCardStatus_CODE   = @Lc_Space_TEXT,
    @Ac_MarriedDivorceDecreeStatus_CODE       = @Lc_Space_TEXT,
    @Ac_PaymentArrearsStatementStatus_CODE    = @Lc_Space_TEXT,
    @Ac_ModifiedSupportOrderDecreeStatus_CODE = @Lc_Space_TEXT,
    @Ac_ChildBirthCertificateStatus_CODE      = @Lc_Space_TEXT,
    @Ac_InformationReleaseRisk_INDC           = @Lc_Space_TEXT,
    @Ac_AddressPfaProtection_INDC             = @Lc_Space_TEXT,
    @Ac_PaternityAcknowledgmentStatus_CODE    = @Lc_Space_TEXT,
    @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;
   
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   
   --Create a APCM record for the mother 
   SET @Lc_FatherMother_CODE = '';

   IF @Ac_FatherMother_CODE = 'M'
    BEGIN
     SET @Lc_FatherMother_CODE = @Lc_NcpRelationshipToChildMtr_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_FatherMother_CODE = @Lc_NcpRelationshipToChildFtr_CODE;
    END
   
   SET @Li_Comma_QNTY = 0;
   SET @Li_SpaceCount_QNTY = 0;
   SET @Li_DelimiterCount_QNTY = 0;
   
   SET @Ls_Sql_TEXT = 'GET UNKNOWN MEMBER DETAILS FROM DEMO_Y1 AND AHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMciU_IDNO AS VARCHAR), 0); 
   SELECT @Lc_RaceU_CODE = a.Race_CODE,
          @Lc_FirstU_NAME = a.First_NAME,
          @Lc_LastU_NAME = a.Last_NAME,
          @Lc_MiddleU_NAME = a.Middle_NAME,
          @Lc_SuffixU_NAME = a.Suffix_NAME,
          @Lc_MemberSexU_CODE = a.MemberSex_CODE,
          @Ld_ParentBirthU_DATE = a.Birth_DATE,
          @Lc_TypeAddressU_CODE = b.TypeAddress_CODE,
          @Ls_Line1U_ADDR = b.Line1_ADDR,
          @Ls_Line2U_ADDR = b.Line1_ADDR,
          @Lc_CityU_ADDR = b.City_ADDR,
          @Lc_StateU_ADDR = b.State_ADDR,
          @Lc_ZipU_ADDR = b.Zip_ADDR,
          @Lc_AttnU_ADDR = b.Attn_ADDR,
          @Lc_NormalizationU_CODE = b.Normalization_CODE
     FROM DEMO_Y1 a
          LEFT OUTER JOIN AHIS_Y1 b
           ON a.MemberMci_IDNO = b.MemberMci_IDNO
    WHERE a.MemberMci_IDNO = @Ln_MemberMciU_IDNO;

   SET @Ln_ParentMci_IDNO = @Ln_Zero_NUMB;
   SET @Ld_ParentBirth_DATE = @Ld_Low_DATE;
   SET @Ln_ParentPrimarySsn_NUMB = @Ln_Zero_NUMB;
   SET @Ln_IvePartyParent_IDNO = @Ln_Zero_NUMB;
   SET @Lc_Sex_CODE = @Lc_Space_TEXT;
   SET @Lc_ParentLast_NAME = @Lc_Space_TEXT;
   SET @Lc_ParentFirst_NAME = @Lc_Space_TEXT;
   SET @Lc_ParentMiddle_NAME = @Lc_Space_TEXT;
   SET @Lc_Suffix_NAME = @Lc_Space_TEXT;
   SET @Lc_ParentAliasLast_NAME = @Lc_Space_TEXT;
   SET @Lc_ParentAliasFirst_NAME = @Lc_Space_TEXT;
   SET @Lc_ParentAliasMiddle_NAME = @Lc_Space_TEXT;
   SET @Lc_TypeAddress_CODE = @Lc_Space_TEXT;
   SET @Ls_ParentLine1_ADDR = @Lc_Space_TEXT;
   SET @Ls_ParentLine2_ADDR = @Lc_Space_TEXT;
   SET @Lc_ParentCity_ADDR = @Lc_Space_TEXT;
   SET @Lc_ParentState_ADDR = @Lc_Space_TEXT;
   SET @Lc_ParentZip_ADDR = @Lc_Space_TEXT;
   SET @Lc_ParentAttn_ADDR = @Lc_Space_TEXT;

   IF @Ac_Parent_NAME <> ''
    BEGIN
     SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Parent_NAME);
     SET @Lc_ParentLast_NAME = LEFT(@Ac_Parent_NAME, @Li_Comma_QNTY - 1);
     SET @Lc_Partial_NAME = SUBSTRING(@Ac_Parent_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Parent_NAME) - (@Li_Comma_QNTY + 1));
     SET @Li_SpaceCount_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
     SET @Lc_ParentFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_SpaceCount_QNTY - 1);

     IF LEN(@Lc_Partial_NAME) > @Li_SpaceCount_QNTY
      BEGIN
       SET @Lc_Partial_NAME = SUBSTRING(@Lc_Partial_NAME, @Li_SpaceCount_QNTY + 1, LEN(@Lc_Partial_NAME) - @Li_SpaceCount_QNTY);
       SET @Lc_ParentMiddle_NAME = LTRIM(RTRIM(@Lc_Partial_NAME));
      END
     ELSE
      BEGIN
       SET @Lc_ParentMiddle_NAME = @Lc_Space_TEXT;
      END
       
    END
   					
   SET @Li_Comma_QNTY = 0;
   SET @Li_SpaceCount_QNTY = 0;

   IF @Ac_ParentAlias_NAME <> '' 
    BEGIN
     SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_ParentAlias_NAME);
     SET @Lc_ParentAliasLast_NAME = LEFT(@Ac_ParentAlias_NAME, @Li_Comma_QNTY - 1);
     SET @Lc_Partial_NAME = SUBSTRING(@Ac_ParentAlias_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_ParentAlias_NAME) - (@Li_Comma_QNTY + 1));
     SET @Li_SpaceCount_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
     SET @Lc_ParentAliasFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_SpaceCount_QNTY - 1);

     IF LEN(@Lc_Partial_NAME) > @Li_SpaceCount_QNTY
      BEGIN
       SET @Lc_Partial_NAME = SUBSTRING(@Lc_Partial_NAME, @Li_SpaceCount_QNTY + 1, LEN(@Lc_Partial_NAME) - @Li_SpaceCount_QNTY);
       SET @Lc_ParentAliasMiddle_NAME = LTRIM(RTRIM(@Lc_Partial_NAME));
      END
     ELSE
      BEGIN
       SET @Lc_ParentAliasMiddle_NAME = @Lc_Space_TEXT;
      END
   
    END

   IF ((@Ac_ParentInformation_INDC = 'Y'
        AND @Ac_Parent_NAME = '')
        OR (@Ac_ParentInformation_INDC = 'N'))
    BEGIN
     SET @Ln_ParentMci_IDNO = @Ln_MemberMciU_IDNO;
     SET @Ld_ParentBirth_DATE = @Ld_ParentBirthU_DATE;
     SET @Ln_ParentPrimarySsn_NUMB = @Ln_Zero_NUMB;
     SET @Ln_IvePartyParent_IDNO = @Ln_Zero_NUMB;
     SET @Lc_Sex_CODE = @Lc_Space_TEXT;
     SET @Lc_ParentLast_NAME = @Lc_LastU_NAME;
     SET @Lc_ParentFirst_NAME = @Lc_FirstU_NAME;
     SET @Lc_ParentMiddle_NAME = @Lc_MiddleU_NAME;
     SET @Lc_Suffix_NAME = @Lc_SuffixU_NAME;
     SET @Lc_ParentAliasLast_NAME = @Lc_Space_TEXT;
     SET @Lc_ParentAliasFirst_NAME = @Lc_Space_TEXT;
     SET @Lc_ParentAliasMiddle_NAME = @Lc_Space_TEXT;
     SET @Lc_TypeAddress_CODE = @Lc_TypeAddressU_CODE;
     SET @Ls_ParentLine1_ADDR = @Ls_Line1U_ADDR;
     SET @Ls_ParentLine2_ADDR = @Ls_Line2U_ADDR;
     SET @Lc_ParentCity_ADDR = @Lc_CityU_ADDR;
     SET @Lc_ParentState_ADDR = @Lc_StateU_ADDR;
     SET @Lc_ParentZip_ADDR = @Lc_ZipU_ADDR;
     SET @Lc_ParentAttn_ADDR = @Lc_AttnU_ADDR;
   
    END
   ELSE
    BEGIN
     SET @Ln_ParentMci_IDNO = @An_ParentMci_IDNO;
     SET @Ld_ParentBirth_DATE = @Ad_ParentBirth_DATE;
     SET @Ln_ParentPrimarySsn_NUMB = @An_ParentPrimarySsn_NUMB;
     SET @Ln_IvePartyParent_IDNO = @An_IvePartyParent_IDNO;
     SET @Lc_Sex_CODE = @Ac_ParentSex_CODE;
     SET @Lc_Suffix_NAME = @Lc_Space_TEXT;
     SET @Lc_TypeAddress_CODE = @Lc_TypeAddressU_CODE;
     SET @Ls_ParentLine1_ADDR = @Ls_Line1U_ADDR;
     SET @Ls_ParentLine2_ADDR = @Ls_Line2U_ADDR;
     SET @Lc_ParentCity_ADDR = @Lc_CityU_ADDR;
     SET @Lc_ParentState_ADDR = @Lc_StateU_ADDR;
     SET @Lc_ParentZip_ADDR = @Lc_ZipU_ADDR;
     SET @Lc_ParentAttn_ADDR = @Lc_AttnU_ADDR;
    END
   SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
   SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), 0) + ',MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentMci_IDNO AS VARCHAR), 0);
   EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
    @An_Application_IDNO             = @An_Application_IDNO,
    @An_MemberMci_IDNO               = @Ln_ParentMci_IDNO,
    @Ac_CaseRelationship_CODE        = @Lc_CaseRelationshipNcp_CODE,
    @Ac_CreateMemberMci_CODE         = @Lc_ValueR_CODE,
    @Ac_CpRelationshipToChild_CODE   = @Lc_Space_TEXT,
    @Ac_CpRelationshipToNcp_CODE     = @Lc_CpRelationshipToNcpNot_CODE,
    @Ac_NcpRelationshipToChild_CODE  = @Lc_Space_TEXT,
    @Ac_DescriptionRelationship_TEXT = @Lc_Space_TEXT,
    @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
    @Ad_EndValidity_DATE             = @Ld_High_DATE,
    @Ad_Update_DTTM                  = @Ad_Update_DTTM,
    @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
    @An_TransactionEventSeq_NUMB     = @An_TransactionEventSeq_NUMB,
    @An_OthpAtty_IDNO                = @Ln_Zero_NUMB,
    @Ac_Applicant_CODE               = @Lc_Space_TEXT,
    @Ac_AttyComplaint_INDC           = @Lc_Space_TEXT,
    @Ad_FamilyViolence_DATE          = @Ld_Low_DATE,
    @Ac_FamilyViolence_INDC          = @Lc_FamilyViolenceN_INDC,
    @Ac_TypeFamilyViolence_CODE      = @Lc_TypeFamilyViolenceDe_CODE,
    @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;
   
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Create a mother or Father demo record
   
   SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
   SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), 0) + ',MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParentMci_IDNO AS VARCHAR), 0);
   EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
    @An_Application_IDNO                      = @An_Application_IDNO,
    @An_MemberMci_IDNO                        = @Ln_ParentMci_IDNO,
    @An_Individual_IDNO                       = @Ln_Zero_NUMB,
    @Ac_First_NAME                            = @Lc_ParentFirst_NAME,
    @Ac_Last_NAME                             = @Lc_ParentLast_NAME,
    @Ac_Middle_NAME                           = @Lc_ParentMiddle_NAME,
    @Ac_Suffix_NAME                           = @Lc_Space_TEXT,
    @Ac_LastAlias_NAME                        = @Lc_ParentAliasLast_NAME,
    @Ac_FirstAlias_NAME                       = @Lc_ParentAliasFirst_NAME,
    @Ac_MiddleAlias_NAME                      = @Lc_ParentAliasMiddle_NAME,
    @Ac_MotherMaiden_NAME                     = @Lc_Space_TEXT,
    @Ac_MemberSex_CODE                        = @Lc_Sex_CODE,
    @An_MemberSsn_NUMB                        = @Ln_ParentPrimarySsn_NUMB,
    @Ad_Birth_DATE                            = @Ld_ParentBirth_DATE,
    @Ad_Deceased_DATE                         = @Ld_Low_DATE,
    @Ac_BirthCity_NAME                        = @Lc_Space_TEXT,
    @Ac_BirthCountry_CODE                     = @Lc_Space_TEXT,
    @Ac_BirthState_CODE                       = @Lc_Space_TEXT,
    @An_ResideCounty_IDNO                     = @Ln_Zero_NUMB,
    @Ac_ColorEyes_CODE                        = @Lc_Space_TEXT,
    @Ac_ColorHair_CODE                        = @Lc_Space_TEXT,
    @Ac_Race_CODE                             = @Ac_Race_CODE,
    @Ac_DescriptionHeight_TEXT                = @Lc_Space_TEXT,
    @Ac_DescriptionWeightLbs_TEXT             = @Lc_Space_TEXT,
    @Ad_Marriage_DATE                         = @Ld_Low_DATE,
    @Ac_Divorce_INDC                          = @Lc_Space_TEXT,
    @Ad_Divorce_DATE                          = @Ld_Low_DATE,
    @Ac_AlienRegistn_ID                       = @Lc_Space_TEXT,
    @Ac_Language_CODE                         = @Lc_Space_TEXT,
    @Ac_Interpreter_INDC                      = @Lc_Space_TEXT,
    @An_CellPhone_NUMB                        = @Ln_Zero_NUMB,
    @An_HomePhone_NUMB                        = @Ln_Zero_NUMB,
    @As_Contact_EML                           = @Lc_Space_TEXT,
    @Ac_LicenseDriverNo_TEXT                  = @Lc_Space_TEXT,
    @Ac_LicenseIssueState_CODE                = @Lc_Space_TEXT,
    @Ac_TypeProblem_CODE                      = @Lc_Space_TEXT,
    @Ac_CurrentMilitary_INDC                  = @Lc_Space_TEXT,
    @Ac_MilitaryBranch_CODE                   = @Lc_Space_TEXT,
    @Ad_MilitaryEnd_DATE                      = @Ld_Low_DATE,
    @Ac_EverIncarcerated_INDC                 = @Lc_Space_TEXT,
    @Ac_PaternityEst_INDC                     = @Lc_Space_TEXT,
    @Ac_PaternityEst_CODE                     = @Lc_Space_TEXT,
    @Ad_PaternityEst_DATE                     = @Ld_Low_DATE,
    @Ad_BeginValidity_DATE                    = @Ad_Run_DATE,
    @Ad_EndValidity_DATE                      = @Ld_High_DATE,
    @Ad_Update_DTTM                           = @Ad_Update_DTTM,
    @Ac_WorkerUpdate_ID                       = @Lc_BatchRunUser_TEXT,
    @An_TransactionEventSeq_NUMB              = @An_TransactionEventSeq_NUMB,
    @Ac_StateMarriage_CODE                    = @Lc_Space_TEXT,
    @Ac_StateDivorce_CODE                     = @Lc_Space_TEXT,
    @Ac_FilePaternity_ID                      = @Lc_Space_TEXT,
    @An_CountyPaternity_IDNO                  = @Ln_Zero_NUMB,
    @Ac_SuffixAlias_NAME                      = @Lc_Space_TEXT,
    @An_OthpInst_IDNO                         = @Ln_Zero_NUMB,
    @Ac_GeneticTesting_INDC                   = @Lc_Space_TEXT,
    @An_IveParty_IDNO                         = @Ln_IvePartyParent_IDNO,
    @Ac_ChildCoveredInsurance_INDC            = @Lc_Space_TEXT,
    @Ac_EverReceivedMedicaid_INDC             = @Lc_Space_TEXT,
    @Ac_ChildParentDivorceState_CODE          = @Lc_Space_TEXT,
    @Ac_ChildParentDivorceCounty_NAME         = @Lc_Space_TEXT,
    @Ad_ChildParentDivorce_DATE               = @Ld_Low_DATE,
    @Ac_DirectSupportPay_INDC                 = @Lc_Space_TEXT,
    @As_AdditionalNotes_TEXT                  = @Lc_Space_TEXT,
    @Ac_TypeOrder_CODE                        = @Lc_Space_TEXT,
    @Ac_PaternityEstablishedByOrder_INDC      = @Lc_Space_TEXT,
    @Ac_HusbandIsNotFather_INDC               = @Lc_Space_TEXT,
    @Ac_MarriageDuringChildBirthState_CODE    = @Lc_Space_TEXT,
    @Ac_MarriageDuringChildBirthCounty_NAME   = @Lc_Space_TEXT,
    @Ad_MarriageDuringChildBirth_DATE         = @Ld_Low_DATE,
    @As_MarriedDuringChildBirthHusband_NAME   = @Lc_Space_TEXT,
    @Ac_MothermarriedDuringChildBirth_INDC    = @Lc_Space_TEXT,
    @Ac_FatherNameOnBirthCertificate_INDC     = @Lc_Space_TEXT,
    @Ac_HusbandSuffix_NAME                    = @Lc_Space_TEXT,
    @Ac_HusbandMiddle_NAME                    = @Lc_Space_TEXT,
    @Ac_HusbandLast_NAME                      = @Lc_Space_TEXT,
    @Ac_HusbandFirst_NAME                     = @Lc_Space_TEXT,
    @Ac_EstablishedParentsMarriageState_CODE  = @Lc_Space_TEXT,
    @Ac_EstablishedParentsMarriageCounty_NAME = @Lc_Space_TEXT,
    @Ad_EstablishedParentsMarriage_DATE       = @Ld_Low_DATE,
    @An_EstablishedFatherMci_IDNO             = @Ln_Zero_NUMB,
    @Ac_EstablishedFatherSuffix_NAME          = @Lc_Space_TEXT,
    @Ac_EstablishedFatherMiddle_NAME          = @Lc_Space_TEXT,
    @Ac_EstablishedFatherLast_NAME            = @Lc_Space_TEXT,
    @Ac_EstablishedFatherFirst_NAME           = @Lc_Space_TEXT,
    @An_EstablishedMotherMci_IDNO             = @Ln_Zero_NUMB,
    @Ac_EstablishedMotherSuffix_NAME          = @Lc_Space_TEXT,
    @Ac_EstablishedMotherMiddle_NAME          = @Lc_Space_TEXT,
    @Ac_EstablishedMotherLast_NAME            = @Lc_Space_TEXT,
    @Ac_EstablishedMotherFirst_NAME           = @Lc_Space_TEXT,
    @Ac_EstablishedFather_CODE                = @Lc_Space_TEXT,
    @Ac_EstablishedMother_CODE                = @Lc_Space_TEXT,
    @Ac_ConceptionState_CODE                  = @Lc_Space_TEXT,
    @Ac_ConceptionCity_NAME                   = @Lc_Space_TEXT,
    @Ac_IncomeFrequency_CODE                  = @Lc_Space_TEXT,
    @An_OtherIncome_AMNT                      = @Ln_Zero_NUMB,
    @Ac_OtherIncomeType_CODE                  = @Lc_Space_TEXT,
    @Ac_OtherIncome_INDC                      = @Lc_Space_TEXT,
    @Ad_IncarceratedTo_DATE                   = @Ld_Low_DATE,
    @Ad_IncarceratedFrom_DATE                 = @Ld_Low_DATE,
    @Ad_MilitaryStart_DATE                    = @Ld_Low_DATE,
    @Ac_DivorceCounty_NAME                    = @Lc_Space_TEXT,
    @Ac_CountyMarriage_NAME                   = @Lc_Space_TEXT,
    @Ac_CourtDivorce_TEXT                     = @Lc_Space_TEXT,
    @Ac_StateLastShared_CODE                  = @Lc_Space_TEXT,
    @Ac_DivorceProceeding_INDC                = @Lc_Space_TEXT,
    @Ac_NcpProvideChildInsurance_INDC         = @Lc_Space_TEXT,
    @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   
   IF @As_ParentLine1_ADDR <> ''
      AND @As_ParentLine1_ADDR IS NOT NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APAH ';
	 SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), 0) + ',MemberMci_IDNO = ' + ISNULL(CAST(@An_ParentMci_IDNO AS VARCHAR), 0);
     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APAH
      @An_Application_IDNO         = @An_Application_IDNO,
      @An_MemberMci_IDNO           = @An_ParentMci_IDNO,
      @Ac_TypeAddress_CODE         = @Lc_TypeAddressM_CODE,
      @As_Line1_ADDR               = @As_ParentLine1_ADDR,
      @As_Line2_ADDR               = @As_ParentLine2_ADDR,
      @Ac_City_ADDR                = @Ac_ParentCity_ADDR,
      @Ac_State_ADDR               = @Ac_ParentState_ADDR,
      @Ac_County_ADDR              = @Lc_Space_TEXT,
      @Ac_Zip_ADDR                 = @Ac_ParentZip_ADDR,
      @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
      @Ad_EndValidity_DATE         = @Ld_High_DATE,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @Ad_Update_DTTM              = @Ad_Update_DTTM,
      @Ac_Attn_ADDR                = @Lc_Space_TEXT,
      @Ac_Country_ADDR             = @Lc_CountryUs_CODE,
      @Ac_Normalization_CODE       = @Ac_ParentAddressNormalization_CODE,
      @Ad_AddressAsOf_DATE         = @Ad_Run_DATE,
      @Ac_MemberAddress_CODE       = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   
   -- Create othp record for the mother employer and use this id for the application employer record
   IF @As_ParentEmplLine1_ADDR <> ''
       AND @As_ParentEmplLine1_ADDR IS NOT NULL
    BEGIN
     SET @Lc_TypeError_CODE = '';
     SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_COMMON$SP_GET_OTHP ';
	 SET @Ls_Sqldata_TEXT = 'TypeEmployer_CODE = ' + ISNULL(@Lc_TypeOthpEmployer_CODE, '') + ', Employer_NAME = ' + ISNULL(@Ac_ParentEmpl_NAME, '');
     EXECUTE BATCH_COMMON$SP_GET_OTHP
      @Ad_Run_DATE                     = @Ad_Run_DATE,
      @An_Fein_IDNO                    = @Ln_Zero_NUMB,
      @Ac_TypeOthp_CODE                = @Lc_TypeOthpEmployer_CODE,
      @As_OtherParty_NAME              = @Ac_ParentEmpl_NAME,
      @Ac_Aka_NAME                     = @Lc_Space_TEXT,
      @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
      @As_Line1_ADDR                   = @As_ParentEmplLine1_ADDR,
      @As_Line2_ADDR                   = @As_ParentEmplLine2_ADDR,
      @Ac_City_ADDR                    = @Ac_ParentEmplCity_ADDR,
      @Ac_Zip_ADDR                     = @Ac_ParentEmplZip_ADDR,
      @Ac_State_ADDR                   = @Ac_ParentEmplState_ADDR,
      @Ac_Fips_CODE                    = @Lc_Space_TEXT,
      @Ac_Country_ADDR                 = @Lc_CountryUs_CODE,
      @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
      @An_Phone_NUMB                   = @Ln_ZERO_NUMB,
      @An_Fax_NUMB                     = @Ln_ZERO_NUMB,
      @As_Contact_EML                  = @Lc_Space_TEXT,
      @An_ReferenceOthp_IDNO           = @Ln_ZERO_NUMB,
      @An_BarAtty_NUMB                 = @Ln_ZERO_NUMB,
      @An_Sein_IDNO                    = @Ln_ZERO_NUMB,
      @Ac_SourceLoc_CODE               = @Lc_SourceLocIve_CODE,
      @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
      @An_DchCarrier_IDNO              = @Ln_ZERO_NUMB,
      @Ac_Normalization_CODE           = @Ac_ParentEmplAddressNormalization_CODE,
      @Ac_Process_ID                   = @Lc_Space_TEXT,
      @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;
     
     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP1 FAILED';

         RAISERROR(50001,16,1);
        END
     ELSE
		IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE 
		 BEGIN
		   SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
		 END
		ELSE
			BEGIN 
			 SET @Lc_TypeError_CODE = @Lc_Msg_CODE;
			END
     
     --Create application employment record for the mother as ncp
     
     IF @Lc_TypeError_CODE = ''
      BEGIN
       SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APEH ';
	 SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), 0) + ',MemberMci_IDNO = ' + ISNULL(CAST(@An_ParentMci_IDNO AS VARCHAR), 0);
       EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APEH
        @An_Application_IDNO         = @An_Application_IDNO,
        @An_MemberMci_IDNO           = @An_ParentMci_IDNO,
        @An_OthpEmpl_IDNO            = @Ln_OtherParty_IDNO,
        @Ac_FreqIncome_CODE          = @Lc_Space_TEXT,
        @Ac_TypeIncome_CODE          = @Lc_Space_TEXT,
        @An_IncomeGross_AMNT         = @Ln_Zero_NUMB,
        @Ad_BeginEmployment_DATE     = @Ad_Run_DATE,
        @Ad_EndEmployment_DATE       = @Ld_High_DATE,
        @Ac_ContactWork_INDC         = @Lc_Space_TEXT,
        @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
        @Ad_EndValidity_DATE         = @Ld_High_DATE,
        @Ad_Update_DTTM              = @Ad_Update_DTTM,
        @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ac_TypeOccupation_CODE      = @Lc_Space_TEXT,
        @Ad_EmployerAddressAsOf_DATE = @Ad_Run_DATE,
        @Ac_MemberAddress_CODE       = @Lc_Space_TEXT,
        @Ac_Msg_code                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
    END
   
   SET @As_DescriptionError_TEXT = ' ';
   SET @Ac_Msg_code = '';
  END TRY

  BEGIN CATCH
   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END


GO
