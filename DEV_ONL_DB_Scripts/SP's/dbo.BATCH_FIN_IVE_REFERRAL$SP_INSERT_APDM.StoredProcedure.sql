/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM
Programmer Name		 : IMP Team
Description			 : The procedure inserts application demographic data into the application demographic tables. 
Frequency			 : Daily
Developed On		 : 11/02/2011
Called By			 :
Called On			 :
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APDM]
 @An_Application_IDNO                      NUMERIC(15),
 @An_MemberMci_IDNO                        NUMERIC(10),
 @An_Individual_IDNO                       NUMERIC(8),
 @Ac_First_NAME                            CHAR(16),
 @Ac_Last_NAME                             CHAR(20),
 @Ac_Middle_NAME                           CHAR(20),
 @Ac_Suffix_NAME                           CHAR(4),
 @Ac_LastAlias_NAME                        CHAR(20),
 @Ac_FirstAlias_NAME                       CHAR(16),
 @Ac_MiddleAlias_NAME                      CHAR(20),
 @Ac_MotherMaiden_NAME                     CHAR(30),
 @Ac_MemberSex_CODE                        CHAR(1),
 @An_MemberSsn_NUMB                        NUMERIC(9),
 @Ad_Birth_DATE                            DATE,
 @Ad_Deceased_DATE                         DATE,
 @Ac_BirthCity_NAME                        CHAR(28),
 @Ac_BirthCountry_CODE                     CHAR(2),
 @Ac_BirthState_CODE                       CHAR(2),
 @An_ResideCounty_IDNO                     NUMERIC(3),
 @Ac_ColorEyes_CODE                        CHAR(3),
 @Ac_ColorHair_CODE                        CHAR(3),
 @Ac_Race_CODE                             CHAR(1),
 @Ac_DescriptionHeight_TEXT                CHAR(3),
 @Ac_DescriptionWeightLbs_TEXT             CHAR(3),
 @Ad_Marriage_DATE                         DATE,
 @Ac_Divorce_INDC                          CHAR(1),
 @Ad_Divorce_DATE                          DATE,
 @Ac_AlienRegistn_ID                       CHAR(10),
 @Ac_Language_CODE                         CHAR(3),
 @Ac_Interpreter_INDC                      CHAR(1),
 @An_CellPhone_NUMB                        NUMERIC(10),
 @An_HomePhone_NUMB                        NUMERIC(10),
 @As_Contact_EML                           VARCHAR(100),
 @Ac_LicenseDriverNo_TEXT                  CHAR(25),
 @Ac_LicenseIssueState_CODE                CHAR(2),
 @Ac_TypeProblem_CODE                      CHAR(3),
 @Ac_CurrentMilitary_INDC                  CHAR(1),
 @Ac_MilitaryBranch_CODE                   CHAR(2),
 @Ad_MilitaryEnd_DATE                      DATE,
 @Ac_EverIncarcerated_INDC                 CHAR(1),
 @Ac_PaternityEst_INDC                     CHAR(1),
 @Ac_PaternityEst_CODE                     CHAR(3),
 @Ad_PaternityEst_DATE                     DATE,
 @Ad_BeginValidity_DATE                    DATE,
 @Ad_EndValidity_DATE                      DATE,
 @Ad_Update_DTTM                           DATETIME2,
 @Ac_WorkerUpdate_ID                       CHAR(30),
 @An_TransactionEventSeq_NUMB              NUMERIC(19),
 @Ac_StateMarriage_CODE                    CHAR(2),
 @Ac_StateDivorce_CODE                     CHAR(2),
 @Ac_FilePaternity_ID                      CHAR(10),
 @An_CountyPaternity_IDNO                  NUMERIC(3),
 @Ac_SuffixAlias_NAME                      CHAR(4),
 @An_OthpInst_IDNO                         NUMERIC(9),
 @Ac_GeneticTesting_INDC                   CHAR(1),
 @An_IveParty_IDNO                         NUMERIC(10),
 @Ac_ChildCoveredInsurance_INDC            CHAR(1),
 @Ac_EverReceivedMedicaid_INDC             CHAR(1),
 @Ac_ChildParentDivorceState_CODE          CHAR(2),
 @Ac_ChildParentDivorceCounty_NAME         CHAR(40),
 @Ad_ChildParentDivorce_DATE               DATE,
 @Ac_DirectSupportPay_INDC                 CHAR(1),
 @As_AdditionalNotes_TEXT                  VARCHAR(300),
 @Ac_TypeOrder_CODE                        CHAR(1),
 @Ac_PaternityEstablishedByOrder_INDC      CHAR(1),
 @Ac_HusbandIsNotFather_INDC               CHAR(1),
 @Ac_MarriageDuringChildBirthState_CODE    CHAR(2),
 @Ac_MarriageDuringChildBirthCounty_NAME   CHAR(40),
 @Ad_MarriageDuringChildBirth_DATE         DATE,
 @As_MarriedDuringChildBirthHusband_NAME   VARCHAR(60),
 @Ac_MothermarriedDuringChildBirth_INDC    CHAR(1),
 @Ac_FatherNameOnBirthCertificate_INDC     CHAR(1),
 @Ac_HusbandSuffix_NAME                    CHAR(4),
 @Ac_HusbandMiddle_NAME                    CHAR(20),
 @Ac_HusbandLast_NAME                      CHAR(20),
 @Ac_HusbandFirst_NAME                     CHAR(16),
 @Ac_EstablishedParentsMarriageState_CODE  CHAR(2),
 @Ac_EstablishedParentsMarriageCounty_NAME CHAR(40),
 @Ad_EstablishedParentsMarriage_DATE       DATE,
 @An_EstablishedFatherMci_IDNO             NUMERIC(10),
 @Ac_EstablishedFatherSuffix_NAME          CHAR(4),
 @Ac_EstablishedFatherMiddle_NAME          CHAR(20),
 @Ac_EstablishedFatherLast_NAME            CHAR(20),
 @Ac_EstablishedFatherFirst_NAME           CHAR(16),
 @An_EstablishedMotherMci_IDNO             NUMERIC(10),
 @Ac_EstablishedMotherSuffix_NAME          CHAR(4),
 @Ac_EstablishedMotherMiddle_NAME          CHAR(20),
 @Ac_EstablishedMotherLast_NAME            CHAR(20),
 @Ac_EstablishedMotherFirst_NAME           CHAR(16),
 @Ac_EstablishedFather_CODE                CHAR(1),
 @Ac_EstablishedMother_CODE                CHAR(1),
 @Ac_ConceptionState_CODE                  CHAR(2),
 @Ac_ConceptionCity_NAME                   CHAR(28),
 @Ac_IncomeFrequency_CODE                  CHAR(1),
 @An_OtherIncome_AMNT                      NUMERIC(11, 2),
 @Ac_OtherIncomeType_CODE                  CHAR(2),
 @Ac_OtherIncome_INDC                      CHAR(1),
 @Ad_IncarceratedTo_DATE                   DATE,
 @Ad_IncarceratedFrom_DATE                 DATE,
 @Ad_MilitaryStart_DATE                    DATE,
 @Ac_DivorceCounty_NAME                    CHAR(40),
 @Ac_CountyMarriage_NAME                   CHAR(40),
 @Ac_CourtDivorce_TEXT                     CHAR(40),
 @Ac_StateLastShared_CODE                  CHAR(2),
 @Ac_DivorceProceeding_INDC                CHAR(1),
 @Ac_NcpProvideChildInsurance_INDC         CHAR(1),
 @Ac_Msg_CODE                              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT                 VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusFailed_CODE	  CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE	  CHAR(1) = 'S',
           @Ls_Procedure_NAME		  VARCHAR(60) = 'SP_PROCESS_INSERT_APDM',
           @Ld_Low_DATE				  DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB              NUMERIC(1) = 0,
           @Ln_Error_NUMB             NUMERIC(11),
           @Ln_ErrorLine_NUMB         NUMERIC(11),
           @Li_RowCount_QNTY          SMALLINT = 0,
           @Lc_Exception_CODE         CHAR(1) = '',
           @Lc_Space_TEXT			  CHAR(1) = ' ',
           @Ls_Sql_TEXT               VARCHAR(100),
           @Ls_Sqldata_TEXT           VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT      VARCHAR(4000);

  BEGIN TRY
   
   SET @Ac_Msg_CODE = ' ';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Exception_CODE = '';
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'INSERT INTO TABLE APDM_Y1 ';
   SET @Ls_Sqldata_TEXT = 'APPLICATION IDNO = ' + CAST(@An_Application_IDNO AS VARCHAR(15)) + ', MEMBERMCI_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10));

   INSERT APDM_Y1
          (Application_IDNO,
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
   VALUES ( @An_Application_IDNO, --Application_IDNO
            @An_MemberMci_IDNO, -- MemberMci_IDNO
            @An_Individual_IDNO, --Individual_IDNO
            ISNULL(@Ac_First_NAME, @Lc_Space_TEXT), -- First_NAME
            ISNULL(@Ac_Last_NAME, @Lc_Space_TEXT), -- Last_NAME
            ISNULL(@Ac_Middle_NAME, @Lc_Space_TEXT), -- Middle_NAME
            ISNULL(@Ac_Suffix_NAME, @Lc_Space_TEXT), -- Suffix_NAME
            ISNULL(@Ac_LastAlias_NAME, @Lc_Space_TEXT), --LastAlias_NAME
            ISNULL(@Ac_FirstAlias_NAME, @Lc_Space_TEXT), -- FirstAlias_NAME
            ISNULL(@Ac_MiddleAlias_NAME, @Lc_Space_TEXT), -- MiddleAlias_NAME
            ISNULL(@Ac_MotherMaiden_NAME, @Lc_Space_TEXT), -- MotherMaiden_NAME
            ISNULL(@Ac_MemberSex_CODE, @Lc_Space_TEXT), -- MemberSex_CODE
            @An_MemberSsn_NUMB, --MemberSsn_NUMB
            ISNULL(@Ad_Birth_DATE, @Ld_Low_DATE), -- Birth_DATE
            ISNULL(@Ad_Deceased_DATE, @Ld_Low_DATE), -- Deceased_DATE
            @Ac_BirthCity_NAME, -- BirthCity_NAME
            ISNULL(@Ac_BirthCountry_CODE, @Lc_Space_TEXT), -- BirthCountry_CODE
            ISNULL(@Ac_BirthState_CODE, @Lc_Space_TEXT), -- BirthState_CODE
            @An_ResideCounty_IDNO, --ResideCounty_IDNO
            ISNULL(@Ac_ColorEyes_CODE, @Lc_Space_TEXT), -- ColorEyes_CODE
            ISNULL(@Ac_ColorHair_CODE, @Lc_Space_TEXT), -- ColorHair_CODE
            ISNULL(@Ac_Race_CODE, @Lc_Space_TEXT), -- Race_CODE
            ISNULL(@Ac_DescriptionHeight_TEXT, @Lc_Space_TEXT), --DescriptionHeight_TEXT
            ISNULL(@Ac_DescriptionWeightLbs_TEXT, @Lc_Space_TEXT), -- DescriptionWeightLbs_TEXT
            ISNULL(@Ad_Marriage_DATE, @Ld_Low_DATE), -- Marriage_DATE
            ISNULL(@Ac_Divorce_INDC, @Lc_Space_TEXT), --Divorce_INDC
            @Ad_Divorce_DATE, --Divorce_DATE
            ISNULL(@Ac_AlienRegistn_ID, @Lc_Space_TEXT), --AlienRegistn_ID
            ISNULL(@Ac_Language_CODE, @Lc_Space_TEXT), -- Language_CODE
            ISNULL(@Ac_Interpreter_INDC, @Lc_Space_TEXT), --Interpreter_INDC
            @An_CellPhone_NUMB, --CellPhone_NUMB
            @An_HomePhone_NUMB, -- HomePhone_NUMB
            ISNULL(@As_Contact_EML, @Lc_Space_TEXT), --Contact_EML
            ISNULL(@Ac_LicenseDriverNo_TEXT, @Lc_Space_TEXT), --LicenseDriverNo_TEXT 
            ISNULL(@Ac_LicenseIssueState_CODE, @Lc_Space_TEXT), -- LicenseIssueState_CODE
            ISNULL(@Ac_TypeProblem_CODE, @Lc_Space_TEXT), -- TypeProblem_CODE
            ISNULL(@Ac_CurrentMilitary_INDC, @Lc_Space_TEXT), -- CurrentMilitary_INDC
            ISNULL(@Ac_MilitaryBranch_CODE, @Lc_Space_TEXT), -- MilitaryBranch_CODE
            @Ad_MilitaryEnd_DATE, --MilitaryEnd_DATE
            ISNULL(@Ac_EverIncarcerated_INDC, @Lc_Space_TEXT), --EverIncarcerated_INDC
            ISNULL(@Ac_PaternityEst_INDC, @Lc_Space_TEXT), --PaternityEst_INDC
            ISNULL(@Ac_PaternityEst_CODE, @Lc_Space_TEXT), --PaternityEst_CODE
            ISNULL(@Ad_PaternityEst_DATE, @Ld_Low_DATE), --PaternityEst_DATE
            @Ad_BeginValidity_DATE, -- BeginValidity_DATE
            @Ad_EndValidity_DATE, -- EndValidity_DATE
            @Ad_Update_DTTM, --Update_DTTM
            ISNULL(@Ac_WorkerUpdate_ID, @Lc_Space_TEXT), --WorkerUpdate_ID
            @An_TransactionEventSeq_NUMB, --TransactionEventSeq_NUMB
            ISNULL(@Ac_StateMarriage_CODE, @Lc_Space_TEXT), --StateMarriage_CODE
            ISNULL(@Ac_StateDivorce_CODE, @Lc_Space_TEXT), -- StateDivorce_CODE
            ISNULL(@Ac_FilePaternity_ID, @Lc_Space_TEXT), --FilePaternity_ID
            @An_CountyPaternity_IDNO, --CountyPaternity_IDNO
            ISNULL(@Ac_SuffixAlias_NAME, @Lc_Space_TEXT), --SuffixAlias_NAME
            @An_OthpInst_IDNO, -- OthpInst_IDNO
            ISNULL(@Ac_GeneticTesting_INDC, @Lc_Space_TEXT), --GeneticTesting_INDC
            @An_IveParty_IDNO, --IveParty_IDNO
            ISNULL(@Ac_ChildCoveredInsurance_INDC, @Lc_Space_TEXT), --ChildCoveredInsurance_INDC
            ISNULL(@Ac_EverReceivedMedicaid_INDC, @Lc_Space_TEXT), -- EverReceivedMedicaid_INDC
            ISNULL(@Ac_ChildParentDivorceState_CODE, @Lc_Space_TEXT), --ChildParentDivorceState_CODE
            ISNULL(@Ac_ChildParentDivorceCounty_NAME, @Lc_Space_TEXT), --ChildParentDivorceCounty_NAME
            @Ad_ChildParentDivorce_DATE, --ChildParentDivorce_DATE
            ISNULL(@Ac_DirectSupportPay_INDC, @Lc_Space_TEXT), -- DirectSupportPay_INDC
            ISNULL(@As_AdditionalNotes_TEXT, @Lc_Space_TEXT), -- AdditionalNotes_TEXT
            ISNULL(@Ac_TypeOrder_CODE, @Lc_Space_TEXT), -- TypeOrder_CODE
            ISNULL(@Ac_PaternityEstablishedByOrder_INDC, @Lc_Space_TEXT), -- PaternityEstablishedByOrder_INDC
            ISNULL(@Ac_HusbandIsNotFather_INDC, @Lc_Space_TEXT), -- HusbandIsNotFather_INDC
            ISNULL(@Ac_MarriageDuringChildBirthState_CODE, @Lc_Space_TEXT), -- MarriageDuringChildBirthState_CODE
            ISNULL(@Ac_MarriageDuringChildBirthCounty_NAME, @Lc_Space_TEXT), -- MarriageDuringChildBirthCounty_NAME
            @Ad_MarriageDuringChildBirth_DATE, -- MarriageDuringChildBirth_DATE
            ISNULL(@As_MarriedDuringChildBirthHusband_NAME, @Lc_Space_TEXT), --MarriedDuringChildBirthHusband_NAME
            ISNULL(@Ac_MothermarriedDuringChildBirth_INDC, @Lc_Space_TEXT), -- MothermarriedDuringChildBirth_INDC
            ISNULL(@Ac_FatherNameOnBirthCertificate_INDC, @Lc_Space_TEXT), -- FatherNameOnBirthCertificate_INDC
            ISNULL(@Ac_HusbandSuffix_NAME, @Lc_Space_TEXT), -- HusbandSuffix_NAME
            ISNULL(@Ac_HusbandMiddle_NAME, @Lc_Space_TEXT), -- HusbandMiddle_NAME
            ISNULL(@Ac_HusbandLast_NAME, @Lc_Space_TEXT), -- HusbandLast_NAME
            ISNULL(@Ac_HusbandFirst_NAME, @Lc_Space_TEXT), -- HusbandFirst_NAME
            ISNULL(@Ac_EstablishedParentsMarriageState_CODE, @Lc_Space_TEXT), -- EstablishedParentsMarriageState_CODE
            ISNULL(@Ac_EstablishedParentsMarriageCounty_NAME, @Lc_Space_TEXT), -- EstablishedParentsMarriageCounty_NAME
            @Ad_EstablishedParentsMarriage_DATE, -- EstablishedParentsMarriage_DATE
            @An_EstablishedFatherMci_IDNO, --EstablishedFatherMci_IDNO
            ISNULL(@Ac_EstablishedFatherSuffix_NAME, @Lc_Space_TEXT), -- EstablishedFatherSuffix_NAME
            ISNULL(@Ac_EstablishedFatherMiddle_NAME, @Lc_Space_TEXT), -- EstablishedFatherMiddle_NAME
            ISNULL(@Ac_EstablishedFatherLast_NAME, @Lc_Space_TEXT), -- EstablishedFatherLast_NAME
            ISNULL(@Ac_EstablishedFatherFirst_NAME, @Lc_Space_TEXT), -- EstablishedFatherFirst_NAME
            @An_EstablishedMotherMci_IDNO, -- EstablishedMotherMci_IDNO
            ISNULL(@Ac_EstablishedMotherSuffix_NAME, @Lc_Space_TEXT), -- EstablishedMotherSuffix_NAME
            ISNULL(@Ac_EstablishedMotherMiddle_NAME, @Lc_Space_TEXT), -- EstablishedMotherMiddle_NAME
            ISNULL(@Ac_EstablishedMotherLast_NAME, @Lc_Space_TEXT), -- EstablishedMotherLast_NAME
            ISNULL(@Ac_EstablishedMotherFirst_NAME, @Lc_Space_TEXT), -- EstablishedMotherFirst_NAME
            ISNULL(@Ac_EstablishedFather_CODE, @Lc_Space_TEXT), -- EstablishedFather_CODE
            ISNULL(@Ac_EstablishedMother_CODE, @Lc_Space_TEXT), -- EstablishedMother_CODE
            ISNULL(@Ac_ConceptionState_CODE, @Lc_Space_TEXT), -- ConceptionState_CODE
            ISNULL(@Ac_ConceptionCity_NAME, @Lc_Space_TEXT), -- ConceptionCity_NAME
            ISNULL(@Ac_IncomeFrequency_CODE, @Lc_Space_TEXT), -- IncomeFrequency_CODE
            @An_OtherIncome_AMNT, -- OtherIncome_AMNT
            ISNULL(@Ac_OtherIncomeType_CODE, @Lc_Space_TEXT), -- OtherIncomeType_CODE
            ISNULL(@Ac_OtherIncome_INDC, @Lc_Space_TEXT), -- OtherIncome_INDC
            @Ad_IncarceratedTo_DATE, -- IncarceratedTo_DATE
            @Ad_IncarceratedFrom_DATE, -- IncarceratedFrom_DATE
            @Ad_MilitaryStart_DATE, -- MilitaryStart_DATE
            ISNULL(@Ac_DivorceCounty_NAME, @Lc_Space_TEXT), -- DivorceCounty_NAME
            ISNULL(@Ac_CountyMarriage_NAME, @Lc_Space_TEXT), -- CountyMarriage_NAME
            ISNULL(@Ac_CourtDivorce_TEXT, @Lc_Space_TEXT), -- CourtDivorce_TEXT
            ISNULL(@Ac_StateLastShared_CODE, @Lc_Space_TEXT), -- StateLastShared_CODE
            ISNULL(@Ac_DivorceProceeding_INDC, @Lc_Space_TEXT), -- DivorceProceeding_INDC
            ISNULL(@Ac_NcpProvideChildInsurance_INDC, @Lc_Space_TEXT)); -- NcpProvideChildInsurance_INDC

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'APDM INSERT FAILED ';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   
   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
    
  END CATCH
 END


GO
