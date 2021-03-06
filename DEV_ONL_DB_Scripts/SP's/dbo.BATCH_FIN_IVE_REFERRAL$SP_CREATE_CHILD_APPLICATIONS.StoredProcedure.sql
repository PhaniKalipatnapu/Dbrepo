/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_CREATE_CHILD_APPLICATIONS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_CREATE_CHILD_APPLICATIONS
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_FIN_IVE_REFERRAL$SP_CREATE_CHILD_APPLICATIONS creates pending application table entries for APCM, 
					   APDM AND APMH for the IVE referral data for children.  
Frequency			 : Daily
Developed On		 : 12/08/2011
Called By			 : None
Called On			 : BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM,
					   BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
-----------------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_CREATE_CHILD_APPLICATIONS]
 @An_Application_IDNO         NUMERIC(15),
 @Ad_Run_DATE                 DATE,
 @Ad_Update_DTTM              DATETIME2,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @An_CaseWelfare_IDNO         NUMERIC(10),
 @An_Child1Mci_IDNO           NUMERIC(10),
 @Ac_Child1_NAME              CHAR(24),
 @Ac_Child1Father_NAME        CHAR(24),
 @Ac_Child1Mother_NAME        CHAR(24),
 @An_Child1PrimarySsn_NUMB    NUMERIC(9),
 @Ad_Child1Birth_DATE         DATE,
 @Ac_Child1PaternityEst_INDC  CHAR(1),
 @An_Child1Pid_IDNO           NUMERIC(10),
 @Ac_Child1MotherIns_INDC     CHAR(1),
 @An_Child1CaseWelfare_IDNO   NUMERIC(10),
 @An_Child2Mci_IDNO           NUMERIC(10),
 @Ac_Child2_NAME              CHAR(24),
 @Ac_Child2Father_NAME        CHAR(24),
 @Ac_Child2Mother_NAME        CHAR(24),
 @An_Child2PrimarySsn_NUMB    NUMERIC(9),
 @Ad_Child2Birth_DATE         DATE,
 @Ac_Child2PaternityEst_INDC  CHAR(1),
 @An_Child2Pid_IDNO           NUMERIC(10),
 @Ac_Child2MotherIns_INDC     CHAR(1),
 @An_Child2CaseWelfare_IDNO   NUMERIC(10),
 @An_Child3Mci_IDNO           NUMERIC(10),
 @Ac_Child3_NAME              CHAR(24),
 @Ac_Child3Father_NAME        CHAR(24),
 @Ac_Child3Mother_NAME        CHAR(24),
 @An_Child3PrimarySsn_NUMB    NUMERIC(9),
 @Ad_Child3Birth_DATE         DATE,
 @Ac_Child3PaternityEst_INDC  CHAR(1),
 @An_Child3Pid_IDNO           NUMERIC(10),
 @Ac_Child3MotherIns_INDC     CHAR(1),
 @An_Child3CaseWelfare_IDNO   NUMERIC(10),
 @An_Child4Mci_IDNO           NUMERIC(10),
 @Ac_Child4_NAME              CHAR(24),
 @Ac_Child4Father_NAME        CHAR(24),
 @Ac_Child4Mother_NAME        CHAR(24),
 @An_Child4PrimarySsn_NUMB    NUMERIC(9),
 @Ad_Child4Birth_DATE         DATE,
 @Ac_Child4PaternityEst_INDC  CHAR(1),
 @An_Child4Pid_IDNO           NUMERIC(10),
 @Ac_Child4MotherIns_INDC     CHAR(1),
 @An_Child4CaseWelfare_IDNO   NUMERIC(10),
 @An_Child5Mci_IDNO           NUMERIC(10),
 @Ac_Child5_NAME              CHAR(24),
 @Ac_Child5Father_NAME        CHAR(24),
 @Ac_Child5Mother_NAME        CHAR(24),
 @An_Child5PrimarySsn_NUMB    NUMERIC(9),
 @Ad_Child5Birth_DATE         DATE,
 @Ac_Child5PaternityEst_INDC  CHAR(1),
 @An_Child5Pid_IDNO           NUMERIC(10),
 @Ac_Child5MotherIns_INDC     CHAR(1),
 @An_Child5CaseWelfare_IDNO   NUMERIC(10),
 @An_Child6Mci_IDNO           NUMERIC(10),
 @Ac_Child6_NAME              CHAR(24),
 @Ac_Child6Father_NAME        CHAR(24),
 @Ac_Child6Mother_NAME        CHAR(24),
 @An_Child6Primary_SSN        NUMERIC(9),
 @Ad_Child6Birth_DATE         DATE,
 @Ac_Child6PaternityEst_INDC  CHAR(1),
 @An_Child6Pid_IDNO           NUMERIC(10),
 @Ac_Child6MotherIns_INDC     CHAR(1),
 @An_Child6CaseWelfare_IDNO   NUMERIC(10),
 @Ac_FatherMother_CODE        CHAR(1),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_ValueR_INDC                     CHAR(1) = 'R',
           @Lc_DacsesCaseTypeF_CODE            CHAR(1) = 'F',
           @Lc_CaseRelationshipDependent_CODE  CHAR(1) = 'D',
           @Lc_CpRelationshipToChildNot_CODE   CHAR(3) = 'NOT',
           @Lc_CpRelationshipToNcpNot_CODE     CHAR(3) = 'NOT',
           @Lc_NcpRelationshipToChildMtr_CODE  CHAR(3) = 'MTR',
           @Lc_NcpRelationshipToChildFtr_CODE  CHAR(3) = 'FTR',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB					   NUMERIC(1) = 0,
           @Ln_Error_NUMB					   NUMERIC(11),
           @Ln_ErrorLine_NUMB				   NUMERIC(11),
           @Li_Comma_QNTY					   SMALLINT,
           @Li_Space_QNTY					   SMALLINT,
           @Lc_FatherMother_CODE			   CHAR(3) = '',
           @Lc_Msg_CODE						   CHAR(5) = '',
           @Lc_Child1First_NAME				   CHAR(16) = '',
           @Lc_Child2First_NAME				   CHAR(16) = '',
           @Lc_Child3First_NAME				   CHAR(16) = '',
           @Lc_Child4First_NAME				   CHAR(16) = '',
           @Lc_Child5First_NAME				   CHAR(16) = '',
           @Lc_Child6First_NAME				   CHAR(16) = '',
           @Lc_ChildEstFatherFirst_NAME		   CHAR(16) = '',
           @Lc_ChildEstMotherFirst_NAME		   CHAR(16) = '',
           @Lc_Child1Middle_NAME			   CHAR(20) = '',
           @Lc_Child1Last_NAME				   CHAR(20)		= '',
           @Lc_Child2Last_NAME				   CHAR(20) = '',
           @Lc_Child2Middle_NAME			   CHAR(20) = '',
           @Lc_Child3Last_NAME				   CHAR(20) = '',
           @Lc_Child3Middle_NAME			   CHAR(20) = '',
           @Lc_Child4Last_NAME				   CHAR(20) = '',
           @Lc_Child4Middle_NAME			   CHAR(20) = '',
           @Lc_Child5Last_NAME				   CHAR(20) = '',
           @Lc_Child5Middle_NAME			   CHAR(20) = '',
           @Lc_Child6Last_NAME				   CHAR(20) = '',
           @Lc_Child6Middle_NAME			   CHAR(20) = '',
           @Lc_ChildEstFatherLast_NAME		   CHAR(20) = '',
           @Lc_ChildEstFatherMiddle_NAME	   CHAR(20) = '',
           @Lc_ChildEstMotherLast_NAME		   CHAR(20) = '',
           @Lc_ChildEstMotherMiddle_NAME	   CHAR(20) = '',
           @Lc_Partial_NAME					   CHAR(24) = '',
           @Ls_Sql_TEXT						   VARCHAR(100) = '',
           @Ls_Sqldata_TEXT                    VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT           VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT               VARCHAR(4000) = '';
                      
  BEGIN TRY
   SET @Lc_FatherMother_CODE = '';

   IF @Ac_FatherMother_CODE = 'M'
    BEGIN
     SET @Lc_FatherMother_CODE = @Lc_NcpRelationshipToChildMtr_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_FatherMother_CODE = @Lc_NcpRelationshipToChildFtr_CODE;
    END

   IF @An_Child1Mci_IDNO <> 0
    BEGIN
     --Create a case member record for child 1 
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child1Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
      @An_Application_IDNO             = @An_Application_IDNO,
      @An_MemberMci_IDNO               = @An_Child1Mci_IDNO,
      @Ac_CaseRelationship_CODE        = @Lc_CaseRelationshipDependent_CODE,
      @Ac_CreateMemberMci_CODE         = @Lc_ValueR_INDC,
      @Ac_CpRelationshipToChild_CODE   = @Lc_CpRelationshipToChildNot_CODE,
      @Ac_CpRelationshipToNcp_CODE     = @Lc_CpRelationshipToNcpNot_CODE,
      @Ac_NcpRelationshipToChild_CODE  = @Lc_FatherMother_CODE,
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
      @Ac_FamilyViolence_INDC          = @Lc_Space_TEXT,
      @Ac_TypeFamilyViolence_CODE      = @Lc_Space_TEXT,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    
     -- Create a demographic record for child 1
    
     IF @Ac_Child1_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child1_NAME);
       SET @Lc_Child1Last_NAME = LEFT(@Ac_Child1_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child1_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child1_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_Child1First_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_Child1Middle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END
     
     IF @Ac_Child1Father_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child1Father_NAME);
       SET @Lc_ChildEstFatherLast_NAME = LEFT(@Ac_Child1Father_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child1Father_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child1Father_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstFatherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END
     
     IF @Ac_Child1Mother_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child1Mother_NAME);
       SET @Lc_ChildEstMotherLast_NAME = LEFT(@Ac_Child1Mother_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child1Mother_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child1Mother_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstMotherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child1Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
      @An_Application_IDNO                      = @An_Application_IDNO,
      @An_MemberMci_IDNO                        = @An_Child1Mci_IDNO,
      @An_Individual_IDNO                       = @Ln_Zero_NUMB,
      @Ac_First_NAME                            = @Lc_Child1First_NAME,
      @Ac_Last_NAME                             = @Lc_Child1Last_NAME,
      @Ac_Middle_NAME                           = @Lc_Child1Middle_NAME,
      @Ac_Suffix_NAME                           = @Lc_Space_TEXT,
      @Ac_LastAlias_NAME                        = @Lc_Space_TEXT,
      @Ac_FirstAlias_NAME                       = @Lc_Space_TEXT,
      @Ac_MiddleAlias_NAME                      = @Lc_Space_TEXT,
      @Ac_MotherMaiden_NAME                     = @Lc_Space_TEXT,
      @Ac_MemberSex_CODE                        = @Lc_Space_TEXT,
      @An_MemberSsn_NUMB                        = @An_Child1PrimarySsn_NUMB,
      @Ad_Birth_DATE                            = @Ad_Child1Birth_DATE,
      @Ad_Deceased_DATE                         = @Ld_Low_DATE,
      @Ac_BirthCity_NAME                        = @Lc_Space_TEXT,
      @Ac_BirthCountry_CODE                     = @Lc_Space_TEXT,
      @Ac_BirthState_CODE                       = @Lc_Space_TEXT,
      @An_ResideCounty_IDNO                     = @Ln_Zero_NUMB,
      @Ac_ColorEyes_CODE                        = @Lc_Space_TEXT,
      @Ac_ColorHair_CODE                        = @Lc_Space_TEXT,
      @Ac_Race_CODE                             = @Lc_Space_TEXT,
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
      @Ac_PaternityEst_INDC                     = @Ac_Child1PaternityEst_INDC,
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
      @An_IveParty_IDNO                         = @An_Child1Pid_IDNO,
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
      @Ac_EstablishedFatherMiddle_NAME          = @Lc_ChildEstFatherMiddle_NAME,
      @Ac_EstablishedFatherLast_NAME            = @Lc_ChildEstFatherLast_NAME,
      @Ac_EstablishedFatherFirst_NAME           = @Lc_ChildEstFatherFirst_NAME,
      @An_EstablishedMotherMci_IDNO             = @Ln_Zero_NUMB,
      @Ac_EstablishedMotherSuffix_NAME          = @Lc_Space_TEXT,
      @Ac_EstablishedMotherMiddle_NAME          = @Lc_ChildEstMotherMiddle_NAME,
      @Ac_EstablishedMotherLast_NAME            = @Lc_ChildEstMotherLast_NAME,
      @Ac_EstablishedMotherFirst_NAME           = @Lc_ChildEstMotherFirst_NAME,
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
      @Ac_NcpProvideChildInsurance_INDC         = @Ac_Child1MotherIns_INDC,
      @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
   
     -- Create a application member history record for child 1
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child1Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH
      @An_Application_IDNO         = @An_Application_IDNO,
      @An_MemberMci_IDNO           = @An_Child1Mci_IDNO,
      @Ac_TypeWelfare_CODE         = @Lc_DacsesCaseTypeF_CODE,
      @Ad_Begin_DATE               = @Ad_Run_DATE,
      @Ad_End_DATE                 = @Ld_High_DATE,
      @An_CaseWelfare_IDNO         = @An_Child1CaseWelfare_IDNO,
      @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
      @Ad_EndValidity_DATE         = @Ld_High_DATE,
      @Ad_Update_DTTM              = @Ad_Update_DTTM,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @An_WelfareMemberMci_IDNO    = @An_Child1Pid_IDNO,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
   
    END
  
   IF @An_Child2Mci_IDNO <> 0
    BEGIN
     --Create a case member record for child 2
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child2Mci_IDNO AS VARCHAR(10)), 0);
     
     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
      @An_Application_IDNO             = @An_Application_IDNO,
      @An_MemberMci_IDNO               = @An_Child2Mci_IDNO,
      @Ac_CaseRelationship_CODE        = @Lc_CaseRelationshipDependent_CODE,
      @Ac_CreateMemberMci_CODE         = @Lc_ValueR_INDC,
      @Ac_CpRelationshipToChild_CODE   = @Lc_CpRelationshipToChildNot_CODE,
      @Ac_CpRelationshipToNcp_CODE     = @Lc_CpRelationshipToNcpNot_CODE,
      @Ac_NcpRelationshipToChild_CODE  = @Lc_FatherMother_CODE,
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
      @Ac_FamilyViolence_INDC          = @Lc_Space_TEXT,
      @Ac_TypeFamilyViolence_CODE      = @Lc_Space_TEXT,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       
       RAISERROR (50001,16,1);
      END
   
     -- Create a demographic record for child 2
   
     IF @Ac_Child2_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child2_NAME);
       SET @Lc_Child2Last_NAME = LEFT(@Ac_Child2_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child2_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child2_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_Child2First_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_Child2Middle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstFatherLast_NAME = '',
            @Lc_ChildEstFatherFirst_NAME = '',
            @Lc_ChildEstFatherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child2Father_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child2Father_NAME);
       SET @Lc_ChildEstFatherLast_NAME = LEFT(@Ac_Child2Father_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child2Father_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child2Father_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstFatherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstMotherLast_NAME = '',
            @Lc_ChildEstMotherFirst_NAME = '',
            @Lc_ChildEstMotherMiddle_NAME = '';

     IF @Ac_Child2Mother_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child2Mother_NAME);
       SET @Lc_ChildEstMotherLast_NAME = LEFT(@Ac_Child2Mother_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child2Mother_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child2Mother_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstMotherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child2Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
      @An_Application_IDNO                      = @An_Application_IDNO,
      @An_MemberMci_IDNO                        = @An_Child2Mci_IDNO,
      @An_Individual_IDNO                       = @Ln_Zero_NUMB,
      @Ac_First_NAME                            = @Lc_Child2First_NAME,
      @Ac_Last_NAME                             = @Lc_Child2Last_NAME,
      @Ac_Middle_NAME                           = @Lc_Child2Middle_NAME,
      @Ac_Suffix_NAME                           = @Lc_Space_TEXT,
      @Ac_LastAlias_NAME                        = @Lc_Space_TEXT,
      @Ac_FirstAlias_NAME                       = @Lc_Space_TEXT,
      @Ac_MiddleAlias_NAME                      = @Lc_Space_TEXT,
      @Ac_MotherMaiden_NAME                     = @Lc_Space_TEXT,
      @Ac_MemberSex_CODE                        = @Lc_Space_TEXT,
      @An_MemberSsn_NUMB                        = @An_Child2PrimarySsn_NUMB,
      @Ad_Birth_DATE                            = @Ad_Child2Birth_DATE,
      @Ad_Deceased_DATE                         = @Ld_Low_DATE,
      @Ac_BirthCity_NAME                        = @Lc_Space_TEXT,
      @Ac_BirthCountry_CODE                     = @Lc_Space_TEXT,
      @Ac_BirthState_CODE                       = @Lc_Space_TEXT,
      @An_ResideCounty_IDNO                     = @Ln_Zero_NUMB,
      @Ac_ColorEyes_CODE                        = @Lc_Space_TEXT,
      @Ac_ColorHair_CODE                        = @Lc_Space_TEXT,
      @Ac_Race_CODE                             = @Lc_Space_TEXT,
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
      @Ac_PaternityEst_INDC                     = @Ac_Child2PaternityEst_INDC,
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
      @An_IveParty_IDNO                         = @An_Child2Pid_IDNO,
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
      @Ac_EstablishedFatherMiddle_NAME          = @Lc_ChildEstFatherMiddle_NAME,
      @Ac_EstablishedFatherLast_NAME            = @Lc_ChildEstFatherLast_NAME,
      @Ac_EstablishedFatherFirst_NAME           = @Lc_ChildEstFatherFirst_NAME,
      @An_EstablishedMotherMci_IDNO             = @Ln_Zero_NUMB,
      @Ac_EstablishedMotherSuffix_NAME          = @Lc_Space_TEXT,
      @Ac_EstablishedMotherMiddle_NAME          = @Lc_ChildEstMotherMiddle_NAME,
      @Ac_EstablishedMotherLast_NAME            = @Lc_ChildEstMotherLast_NAME,
      @Ac_EstablishedMotherFirst_NAME           = @Lc_ChildEstMotherFirst_NAME,
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
      @Ac_NcpProvideChildInsurance_INDC         = @Ac_Child2MotherIns_INDC,
      @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     -- Create a application member history record for child 2
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child2Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH
      @An_Application_IDNO         = @An_Application_IDNO,
      @An_MemberMci_IDNO           = @An_Child2Mci_IDNO,
      @Ac_TypeWelfare_CODE         = @Lc_DacsesCaseTypeF_CODE,
      @Ad_Begin_DATE               = @Ad_Run_DATE,
      @Ad_End_DATE                 = @Ld_High_DATE,
      @An_CaseWelfare_IDNO         = @An_Child2CaseWelfare_IDNO,
      @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
      @Ad_EndValidity_DATE         = @Ld_High_DATE,
      @Ad_Update_DTTM              = @Ad_Update_DTTM,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @An_WelfareMemberMci_IDNO    = @An_Child2Pid_IDNO,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       
       RAISERROR (50001,16,1);
      END
    
    END
  
   IF @An_Child3Mci_IDNO <> 0
    BEGIN
     --Create a case member record for child 3
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child3Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
      @An_Application_IDNO             = @An_Application_IDNO,
      @An_MemberMci_IDNO               = @An_Child3Mci_IDNO,
      @Ac_CaseRelationship_CODE        = @Lc_CaseRelationshipDependent_CODE,
      @Ac_CreateMemberMci_CODE         = @Lc_ValueR_INDC,
      @Ac_CpRelationshipToChild_CODE   = @Lc_CpRelationshipToChildNot_CODE,
      @Ac_CpRelationshipToNcp_CODE     = @Lc_CpRelationshipToNcpNot_CODE,
      @Ac_NcpRelationshipToChild_CODE  = @Lc_FatherMother_CODE,
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
      @Ac_FamilyViolence_INDC          = @Lc_Space_TEXT,
      @Ac_TypeFamilyViolence_CODE      = @Lc_Space_TEXT,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     
     -- Create a demographic record for child 3
     SELECT @Lc_Child3Last_NAME = ' ',
            @Lc_Child3First_NAME = ' ',
            @Lc_Child3Middle_NAME = ' ',
            @Lc_Partial_NAME = '';

     IF @Ac_Child3_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child3_NAME);
       SET @Lc_Child3Last_NAME = LEFT(@Ac_Child3_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child3_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child3_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_Child3First_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_Child3Middle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstFatherLast_NAME = '',
            @Lc_ChildEstFatherFirst_NAME = '',
            @Lc_ChildEstFatherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child3Father_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child3Father_NAME);
       SET @Lc_ChildEstFatherLast_NAME = LEFT(@Ac_Child3Father_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child3Father_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child3Father_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstFatherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstMotherLast_NAME = '',
            @Lc_ChildEstMotherFirst_NAME = '',
            @Lc_ChildEstMotherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child3Mother_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child3Mother_NAME);
       SET @Lc_ChildEstMotherLast_NAME = LEFT(@Ac_Child3Mother_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child3Mother_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child3Mother_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstMotherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child3Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
      @An_Application_IDNO                      = @An_Application_IDNO,
      @An_MemberMci_IDNO                        = @An_Child3Mci_IDNO,
      @An_Individual_IDNO                       = @Ln_Zero_NUMB,
      @Ac_First_NAME                            = @Lc_Child3First_NAME,
      @Ac_Last_NAME                             = @Lc_Child3Last_NAME,
      @Ac_Middle_NAME                           = @Lc_Child4Middle_NAME,
      @Ac_Suffix_NAME                           = @Lc_Space_TEXT,
      @Ac_LastAlias_NAME                        = @Lc_Space_TEXT,
      @Ac_FirstAlias_NAME                       = @Lc_Space_TEXT,
      @Ac_MiddleAlias_NAME                      = @Lc_Space_TEXT,
      @Ac_MotherMaiden_NAME                     = @Lc_Space_TEXT,
      @Ac_MemberSex_CODE                        = @Lc_Space_TEXT,
      @An_MemberSsn_NUMB                        = @An_Child3PrimarySsn_NUMB,
      @Ad_Birth_DATE                            = @Ad_Child3Birth_DATE,
      @Ad_Deceased_DATE                         = @Ld_Low_DATE,
      @Ac_BirthCity_NAME                        = @Lc_Space_TEXT,
      @Ac_BirthCountry_CODE                     = @Lc_Space_TEXT,
      @Ac_BirthState_CODE                       = @Lc_Space_TEXT,
      @An_ResideCounty_IDNO                     = @Ln_Zero_NUMB,
      @Ac_ColorEyes_CODE                        = @Lc_Space_TEXT,
      @Ac_ColorHair_CODE                        = @Lc_Space_TEXT,
      @Ac_Race_CODE                             = @Lc_Space_TEXT,
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
      @Ac_PaternityEst_INDC                     = @Ac_Child3PaternityEst_INDC,
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
      @An_IveParty_IDNO                         = @An_Child3Pid_IDNO,
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
      @Ac_EstablishedFatherMiddle_NAME          = @Lc_ChildEstFatherMiddle_NAME,
      @Ac_EstablishedFatherLast_NAME            = @Lc_ChildEstFatherLast_NAME,
      @Ac_EstablishedFatherFirst_NAME           = @Lc_ChildEstFatherFirst_NAME,
      @An_EstablishedMotherMci_IDNO             = @Ln_Zero_NUMB,
      @Ac_EstablishedMotherSuffix_NAME          = @Lc_Space_TEXT,
      @Ac_EstablishedMotherMiddle_NAME          = @Lc_ChildEstMotherMiddle_NAME,
      @Ac_EstablishedMotherLast_NAME            = @Lc_ChildEstMotherLast_NAME,
      @Ac_EstablishedMotherFirst_NAME           = @Lc_ChildEstMotherFirst_NAME,
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
      @Ac_NcpProvideChildInsurance_INDC         = @Ac_Child3MotherIns_INDC,
      @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
   
     -- Create a application member history record for child 3
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child3Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH
      @An_Application_IDNO         = @An_Application_IDNO,
      @An_MemberMci_IDNO           = @An_Child3Mci_IDNO,
      @Ac_TypeWelfare_CODE         = @Lc_DacsesCaseTypeF_CODE,
      @Ad_Begin_DATE               = @Ad_Run_DATE,
      @Ad_End_DATE                 = @Ld_High_DATE,
      @An_CaseWelfare_IDNO         = @An_Child3CaseWelfare_IDNO,
      @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
      @Ad_EndValidity_DATE         = @Ld_High_DATE,
      @Ad_Update_DTTM              = @Ad_Update_DTTM,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @An_WelfareMemberMci_IDNO    = @An_Child3Pid_IDNO,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    
    END

   IF @An_Child4Mci_IDNO <> 0
    BEGIN
     --Create a case member record for child 4
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child4Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
      @An_Application_IDNO             = @An_Application_IDNO,
      @An_MemberMci_IDNO               = @An_Child4Mci_IDNO,
      @Ac_CaseRelationship_CODE        = @Lc_CaseRelationshipDependent_CODE,
      @Ac_CreateMemberMci_CODE         = @Lc_ValueR_INDC,
      @Ac_CpRelationshipToChild_CODE   = @Lc_CpRelationshipToChildNot_CODE,
      @Ac_CpRelationshipToNcp_CODE     = @Lc_CpRelationshipToNcpNot_CODE,
      @Ac_NcpRelationshipToChild_CODE  = @Lc_FatherMother_CODE,
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
      @Ac_FamilyViolence_INDC          = @Lc_Space_TEXT,
      @Ac_TypeFamilyViolence_CODE      = @Lc_Space_TEXT,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     
     -- Create a demographic record for child 4
     SELECT @Lc_Child4Last_NAME = ' ',
            @Lc_Child4First_NAME = ' ',
            @Lc_Child4Middle_NAME = ' ',
            @Lc_Partial_NAME = '';

     IF @Ac_Child4_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child4_NAME);
       SET @Lc_Child4Last_NAME = LEFT(@Ac_Child4_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child4_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child4_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_Child4First_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_Child4Middle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstFatherLast_NAME = '',
            @Lc_ChildEstFatherFirst_NAME = '',
            @Lc_ChildEstFatherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child4Father_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child4Father_NAME);
       SET @Lc_ChildEstFatherLast_NAME = LEFT(@Ac_Child4Father_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child4Father_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child4Father_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstFatherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstMotherLast_NAME = '',
            @Lc_ChildEstMotherFirst_NAME = '',
            @Lc_ChildEstMotherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child4Mother_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child4Mother_NAME);
       SET @Lc_ChildEstMotherLast_NAME = LEFT(@Ac_Child4Mother_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child4Mother_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child4Mother_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstMotherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child4Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
      @An_Application_IDNO                      = @An_Application_IDNO,
      @An_MemberMci_IDNO                        = @An_Child4Mci_IDNO,
      @An_Individual_IDNO                       = @Ln_Zero_NUMB,
      @Ac_First_NAME                            = @Lc_Child4First_NAME,
      @Ac_Last_NAME                             = @Lc_Child4Last_NAME,
      @Ac_Middle_NAME                           = @Lc_Child4Middle_NAME,
      @Ac_Suffix_NAME                           = @Lc_Space_TEXT,
      @Ac_LastAlias_NAME                        = @Lc_Space_TEXT,
      @Ac_FirstAlias_NAME                       = @Lc_Space_TEXT,
      @Ac_MiddleAlias_NAME                      = @Lc_Space_TEXT,
      @Ac_MotherMaiden_NAME                     = @Lc_Space_TEXT,
      @Ac_MemberSex_CODE                        = @Lc_Space_TEXT,
      @An_MemberSsn_NUMB                        = @An_Child4PrimarySsn_NUMB,
      @Ad_Birth_DATE                            = @Ad_Child4Birth_DATE,
      @Ad_Deceased_DATE                         = @Ld_Low_DATE,
      @Ac_BirthCity_NAME                        = @Lc_Space_TEXT,
      @Ac_BirthCountry_CODE                     = @Lc_Space_TEXT,
      @Ac_BirthState_CODE                       = @Lc_Space_TEXT,
      @An_ResideCounty_IDNO                     = @Ln_Zero_NUMB,
      @Ac_ColorEyes_CODE                        = @Lc_Space_TEXT,
      @Ac_ColorHair_CODE                        = @Lc_Space_TEXT,
      @Ac_Race_CODE                             = @Lc_Space_TEXT,
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
      @Ac_PaternityEst_INDC                     = @Ac_Child4PaternityEst_INDC,
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
      @An_IveParty_IDNO                         = @An_Child4Pid_IDNO,
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
      @Ac_EstablishedFatherMiddle_NAME          = @Lc_ChildEstFatherMiddle_NAME,
      @Ac_EstablishedFatherLast_NAME            = @Lc_ChildEstFatherLast_NAME,
      @Ac_EstablishedFatherFirst_NAME           = @Lc_ChildEstFatherFirst_NAME,
      @An_EstablishedMotherMci_IDNO             = @Ln_Zero_NUMB,
      @Ac_EstablishedMotherSuffix_NAME          = @Lc_Space_TEXT,
      @Ac_EstablishedMotherMiddle_NAME          = @Lc_ChildEstMotherMiddle_NAME,
      @Ac_EstablishedMotherLast_NAME            = @Lc_ChildEstMotherLast_NAME,
      @Ac_EstablishedMotherFirst_NAME           = @Lc_ChildEstMotherFirst_NAME,
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
      @Ac_NcpProvideChildInsurance_INDC         = @Ac_Child4MotherIns_INDC,
      @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       
       RAISERROR (50001,16,1);
      END

     -- Create a application member history record for child 4
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child4Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH
      @An_Application_IDNO         = @An_Application_IDNO,
      @An_MemberMci_IDNO           = @An_Child4Mci_IDNO,
      @Ac_TypeWelfare_CODE         = @Lc_DacsesCaseTypeF_CODE,
      @Ad_Begin_DATE               = @Ad_Run_DATE,
      @Ad_End_DATE                 = @Ld_High_DATE,
      @An_CaseWelfare_IDNO         = @An_Child4CaseWelfare_IDNO,
      @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
      @Ad_EndValidity_DATE         = @Ld_High_DATE,
      @Ad_Update_DTTM              = @Ad_Update_DTTM,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @An_WelfareMemberMci_IDNO    = @An_Child4Pid_IDNO,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
   
    END
   
   IF @An_Child5Mci_IDNO <> 0
    BEGIN
     --Create a case member record for child 5
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child5Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
      @An_Application_IDNO             = @An_Application_IDNO,
      @An_MemberMci_IDNO               = @An_Child5Mci_IDNO,
      @Ac_CaseRelationship_CODE        = @Lc_CaseRelationshipDependent_CODE,
      @Ac_CreateMemberMci_CODE         = @Lc_ValueR_INDC,
      @Ac_CpRelationshipToChild_CODE   = @Lc_CpRelationshipToChildNot_CODE,
      @Ac_CpRelationshipToNcp_CODE     = @Lc_CpRelationshipToNcpNot_CODE,
      @Ac_NcpRelationshipToChild_CODE  = @Lc_FatherMother_CODE,
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
      @Ac_FamilyViolence_INDC          = @Lc_Space_TEXT,
      @Ac_TypeFamilyViolence_CODE      = @Lc_Space_TEXT,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     
     -- Create a demographic record for child 5
     SELECT @Lc_Child5Last_NAME = ' ',
            @Lc_Child5First_NAME = ' ',
            @Lc_Child5Middle_NAME = ' ',
            @Lc_Partial_NAME = '';

     IF @Ac_Child5_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child5_NAME);
       SET @Lc_Child5Last_NAME = LEFT(@Ac_Child5_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child5_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child5_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_Child5First_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_Child5Middle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstFatherLast_NAME = '',
            @Lc_ChildEstFatherFirst_NAME = '',
            @Lc_ChildEstFatherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child5Father_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child5Father_NAME);
       SET @Lc_ChildEstFatherLast_NAME = LEFT(@Ac_Child5Father_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child5Father_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child5Father_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstFatherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstMotherLast_NAME = '',
            @Lc_ChildEstMotherFirst_NAME = '',
            @Lc_ChildEstMotherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child5Mother_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child5Mother_NAME);
       SET @Lc_ChildEstMotherLast_NAME = LEFT(@Ac_Child5Mother_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child5Mother_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child5Mother_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstMotherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child4Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
      @An_Application_IDNO                      = @An_Application_IDNO,
      @An_MemberMci_IDNO                        = @An_Child5Mci_IDNO,
      @An_Individual_IDNO                       = @Ln_Zero_NUMB,
      @Ac_First_NAME                            = @Lc_Child5First_NAME,
      @Ac_Last_NAME                             = @Lc_Child5Last_NAME,
      @Ac_Middle_NAME                           = @Lc_Child5Middle_NAME,
      @Ac_Suffix_NAME                           = @Lc_Space_TEXT,
      @Ac_LastAlias_NAME                        = @Lc_Space_TEXT,
      @Ac_FirstAlias_NAME                       = @Lc_Space_TEXT,
      @Ac_MiddleAlias_NAME                      = @Lc_Space_TEXT,
      @Ac_MotherMaiden_NAME                     = @Lc_Space_TEXT,
      @Ac_MemberSex_CODE                        = @Lc_Space_TEXT,
      @An_MemberSsn_NUMB                        = @An_Child5PrimarySsn_NUMB,
      @Ad_Birth_DATE                            = @Ad_Child5Birth_DATE,
      @Ad_Deceased_DATE                         = @Ld_Low_DATE,
      @Ac_BirthCity_NAME                        = @Lc_Space_TEXT,
      @Ac_BirthCountry_CODE                     = @Lc_Space_TEXT,
      @Ac_BirthState_CODE                       = @Lc_Space_TEXT,
      @An_ResideCounty_IDNO                     = @Ln_Zero_NUMB,
      @Ac_ColorEyes_CODE                        = @Lc_Space_TEXT,
      @Ac_ColorHair_CODE                        = @Lc_Space_TEXT,
      @Ac_Race_CODE                             = @Lc_Space_TEXT,
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
      @Ac_PaternityEst_INDC                     = @Ac_Child5PaternityEst_INDC,
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
      @An_IveParty_IDNO                         = @An_Child5Pid_IDNO,
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
      @Ac_EstablishedFatherMiddle_NAME          = @Lc_ChildEstFatherMiddle_NAME,
      @Ac_EstablishedFatherLast_NAME            = @Lc_ChildEstFatherLast_NAME,
      @Ac_EstablishedFatherFirst_NAME           = @Lc_ChildEstFatherFirst_NAME,
      @An_EstablishedMotherMci_IDNO             = @Ln_Zero_NUMB,
      @Ac_EstablishedMotherSuffix_NAME          = @Lc_Space_TEXT,
      @Ac_EstablishedMotherMiddle_NAME          = @Lc_ChildEstMotherMiddle_NAME,
      @Ac_EstablishedMotherLast_NAME            = @Lc_ChildEstMotherLast_NAME,
      @Ac_EstablishedMotherFirst_NAME           = @Lc_ChildEstMotherFirst_NAME,
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
      @Ac_NcpProvideChildInsurance_INDC         = @Ac_Child4MotherIns_INDC,
      @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     
     -- Create a application member history record for child 5
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child5Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH
      @An_Application_IDNO         = @An_Application_IDNO,
      @An_MemberMci_IDNO           = @An_Child5Mci_IDNO,
      @Ac_TypeWelfare_CODE         = @Lc_DacsesCaseTypeF_CODE,
      @Ad_Begin_DATE               = @Ad_Run_DATE,
      @Ad_End_DATE                 = @Ld_High_DATE,
      @An_CaseWelfare_IDNO         = @An_Child5CaseWelfare_IDNO,
      @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
      @Ad_EndValidity_DATE         = @Ld_High_DATE,
      @Ad_Update_DTTM              = @Ad_Update_DTTM,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @An_WelfareMemberMci_IDNO    = @An_Child5Pid_IDNO,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
   
    END
   
   IF @An_Child6Mci_IDNO <> 0
    BEGIN
     --Create a case member record for child 6
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child6Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
      @An_Application_IDNO             = @An_Application_IDNO,
      @An_MemberMci_IDNO               = @An_Child6Mci_IDNO,
      @Ac_CaseRelationship_CODE        = @Lc_CaseRelationshipDependent_CODE,
      @Ac_CreateMemberMci_CODE         = @Lc_ValueR_INDC,
      @Ac_CpRelationshipToChild_CODE   = @Lc_CpRelationshipToChildNot_CODE,
      @Ac_CpRelationshipToNcp_CODE     = @Lc_CpRelationshipToNcpNot_CODE,
      @Ac_NcpRelationshipToChild_CODE  = @Lc_FatherMother_CODE,
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
      @Ac_FamilyViolence_INDC          = @Lc_Space_TEXT,
      @Ac_TypeFamilyViolence_CODE      = @Lc_Space_TEXT,
      @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     
     -- Create a demographic record for child 6
     SELECT @Lc_Child6Last_NAME = ' ',
            @Lc_Child6First_NAME = ' ',
            @Lc_Child6Middle_NAME = ' ',
            @Lc_Partial_NAME = '';

     IF @Ac_Child6_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child6_NAME);
       SET @Lc_Child6Last_NAME = LEFT(@Ac_Child6_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child6_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child6_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_Child6First_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_Child6Middle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstFatherLast_NAME = '',
            @Lc_ChildEstFatherFirst_NAME = '',
            @Lc_ChildEstFatherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child6Father_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child6Father_NAME);
       SET @Lc_ChildEstFatherLast_NAME = LEFT(@Ac_Child6Father_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child6Father_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child6Father_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstFatherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SELECT @Lc_ChildEstMotherLast_NAME = '',
            @Lc_ChildEstMotherFirst_NAME = '',
            @Lc_ChildEstMotherMiddle_NAME = '',
            @Lc_Partial_NAME = '';

     IF @Ac_Child6Mother_NAME <> '' 
      BEGIN
       SET @Li_Comma_QNTY = CHARINDEX(',', @Ac_Child6Mother_NAME);
       SET @Lc_ChildEstMotherLast_NAME = LEFT(@Ac_Child6Mother_NAME, @Li_Comma_QNTY - 1);
       SET @Lc_Partial_NAME = SUBSTRING(@Ac_Child6Mother_NAME, @Li_Comma_QNTY + 2, LEN(@Ac_Child6Mother_NAME) - (@Li_Comma_QNTY + 1));
       SET @Li_Space_QNTY = CHARINDEX(' ', @Lc_Partial_NAME);
       SET @Lc_ChildEstMotherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_Space_QNTY - 1);
       SET @Lc_ChildEstFatherMiddle_NAME = SUBSTRING(@Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1), (CHARINDEX(' ', @Lc_Partial_NAME, (CHARINDEX(' ', @Lc_Partial_NAME, 1) + 1))));
      END

     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child4Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
      @An_Application_IDNO                      = @An_Application_IDNO,
      @An_MemberMci_IDNO                        = @An_Child6Mci_IDNO,
      @An_Individual_IDNO                       = @Ln_Zero_NUMB,
      @Ac_First_NAME                            = @Lc_Child6First_NAME,
      @Ac_Last_NAME                             = @Lc_Child6Last_NAME,
      @Ac_Middle_NAME                           = @Lc_Child6Middle_NAME,
      @Ac_Suffix_NAME                           = @Lc_Space_TEXT,
      @Ac_LastAlias_NAME                        = @Lc_Space_TEXT,
      @Ac_FirstAlias_NAME                       = @Lc_Space_TEXT,
      @Ac_MiddleAlias_NAME                      = @Lc_Space_TEXT,
      @Ac_MotherMaiden_NAME                     = @Lc_Space_TEXT,
      @Ac_MemberSex_CODE                        = @Lc_Space_TEXT,
      @An_MemberSsn_NUMB                        = @An_Child6Primary_SSN,
      @Ad_Birth_DATE                            = @Ad_Child6Birth_DATE,
      @Ad_Deceased_DATE                         = @Ld_Low_DATE,
      @Ac_BirthCity_NAME                        = @Lc_Space_TEXT,
      @Ac_BirthCountry_CODE                     = @Lc_Space_TEXT,
      @Ac_BirthState_CODE                       = @Lc_Space_TEXT,
      @An_ResideCounty_IDNO                     = @Ln_Zero_NUMB,
      @Ac_ColorEyes_CODE                        = @Lc_Space_TEXT,
      @Ac_ColorHair_CODE                        = @Lc_Space_TEXT,
      @Ac_Race_CODE                             = @Lc_Space_TEXT,
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
      @Ac_PaternityEst_INDC                     = @Ac_Child4PaternityEst_INDC,
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
      @An_IveParty_IDNO                         = @An_Child6Pid_IDNO,
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
      @Ac_EstablishedFatherMiddle_NAME          = @Lc_ChildEstFatherMiddle_NAME,
      @Ac_EstablishedFatherLast_NAME            = @Lc_ChildEstFatherLast_NAME,
      @Ac_EstablishedFatherFirst_NAME           = @Lc_ChildEstFatherFirst_NAME,
      @An_EstablishedMotherMci_IDNO             = @Ln_Zero_NUMB,
      @Ac_EstablishedMotherSuffix_NAME          = @Lc_Space_TEXT,
      @Ac_EstablishedMotherMiddle_NAME          = @Lc_ChildEstMotherMiddle_NAME,
      @Ac_EstablishedMotherLast_NAME            = @Lc_ChildEstMotherLast_NAME,
      @Ac_EstablishedMotherFirst_NAME           = @Lc_ChildEstMotherFirst_NAME,
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
      @Ac_NcpProvideChildInsurance_INDC         = @Ac_Child6MotherIns_INDC,
      @Ac_Msg_CODE                              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT                 = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     
     -- Create a application member history record for child 6
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH ';
     SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR(15)), 0) + ', Child_Mci_IDNO = ' + ISNULL(CAST(@An_Child6Mci_IDNO AS VARCHAR(10)), 0);

     EXECUTE BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH
      @An_Application_IDNO         = @An_Application_IDNO,
      @An_MemberMci_IDNO           = @An_Child6Mci_IDNO,
      @Ac_TypeWelfare_CODE         = @Lc_DacsesCaseTypeF_CODE,
      @Ad_Begin_DATE               = @Ad_Run_DATE,
      @Ad_End_DATE                 = @Ld_High_DATE,
      @An_CaseWelfare_IDNO         = @An_Child6CaseWelfare_IDNO,
      @Ad_BeginValidity_DATE       = @Ad_Run_DATE,
      @Ad_EndValidity_DATE         = @Ld_High_DATE,
      @Ad_Update_DTTM              = @Ad_Update_DTTM,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @An_WelfareMemberMci_IDNO    = @An_Child6Pid_IDNO,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
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
