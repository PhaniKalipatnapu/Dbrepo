/****** Object:  StoredProcedure [dbo].[APDM_INSERT_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_INSERT_S2](
 @An_Application_IDNO                      NUMERIC(15),
 @Ac_First_NAME                            CHAR(16),
 @Ac_Last_NAME                             CHAR(20),
 @Ac_Middle_NAME                           CHAR(20),
 @Ac_Suffix_NAME                           CHAR(4),
 @Ac_MotherMaiden_NAME                     CHAR(30),
 @Ac_MemberSex_CODE                        CHAR(1),
 @An_MemberSsn_NUMB                        NUMERIC(9),
 @Ad_Birth_DATE                            DATE,
 @Ad_Deceased_DATE                         DATE,
 @Ac_BirthCity_NAME                        CHAR(28),
 @Ac_BirthCountry_CODE                     CHAR(2),
 @Ac_BirthState_CODE                       CHAR(2),
 @Ac_ColorEyes_CODE                        CHAR(3),
 @Ac_ColorHair_CODE                        CHAR(3),
 @Ac_Race_CODE                             CHAR(1),
 @Ac_DescriptionHeight_TEXT                CHAR(3),
 @Ac_DescriptionWeightLbs_TEXT             CHAR(3),
 @Ac_Divorce_INDC                          CHAR(1),
 @Ac_AlienRegistn_ID                       CHAR(10),
 @Ac_Language_CODE                         CHAR(3),
 @An_CellPhone_NUMB                        NUMERIC(15),
 @An_HomePhone_NUMB                        NUMERIC(15),
 @As_Contact_EML                           VARCHAR(100),
 @Ac_LicenseDriverNo_TEXT                  CHAR(25),
 @Ac_TypeProblem_CODE                      CHAR(3),
 @Ac_MilitaryBranch_CODE                   CHAR(2),
 @Ac_EverIncarcerated_INDC                 CHAR(1),
 @Ac_PaternityEst_INDC                     CHAR(1),
 @Ac_PaternityEst_CODE                     CHAR(3),
 @Ad_PaternityEst_DATE                     DATE,
 @Ac_SignedOnWorker_ID                     CHAR(30),
 @An_TransactionEventSeq_NUMB              NUMERIC(19),
 @Ac_StateMarriage_CODE                    CHAR(2),
 @Ac_StateDivorce_CODE                     CHAR(2),
 @Ac_FilePaternity_ID                      CHAR(10),
 @Ac_StateLastShared_CODE                  CHAR(2),
 @Ac_CourtDivorce_TEXT                     CHAR(40),
 @Ad_MilitaryStart_DATE                    DATE,
 @Ad_IncarceratedFrom_DATE                 DATE,
 @Ad_IncarceratedTo_DATE                   DATE,
 @Ac_OtherIncome_INDC                      CHAR(1),
 @Ac_OtherIncomeType_CODE                  CHAR(2),
 @An_OtherIncome_AMNT                      NUMERIC(11, 2),
 @Ac_IncomeFrequency_CODE                  CHAR(1),
 @Ac_NcpProvideChildInsurance_INDC         CHAR(1),
 @Ac_CountyMarriage_NAME                   CHAR(40),
 @Ac_DivorceCounty_NAME                    CHAR(40),
 @Ac_ConceptionCity_NAME                   CHAR(28),
 @Ac_ConceptionState_CODE                  CHAR(2),
 @Ac_EstablishedMother_CODE                CHAR(1),
 @Ac_EstablishedFather_CODE                CHAR(1),
 @Ac_FatherNameOnBirthCertificate_INDC     CHAR(1),
 @Ac_MothermarriedDuringChildBirth_INDC    CHAR(1),
 @Ac_HusbandIsNotFather_INDC               CHAR(1),
 @Ac_PaternityEstablishedByOrder_INDC      CHAR(1),
 @Ac_TypeOrder_CODE                        CHAR(1),
 @Ac_GeneticTesting_INDC                   CHAR(1),
 @As_AdditionalNotes_TEXT                  VARCHAR(300),
 @Ac_EstablishedMotherFirst_NAME           CHAR(16),
 @Ac_EstablishedMotherLast_NAME            CHAR(20),
 @Ac_EstablishedMotherMiddle_NAME          CHAR(20),
 @Ac_EstablishedMotherSuffix_NAME          CHAR(4),
 @Ac_EstablishedFatherFirst_NAME           CHAR(16),
 @Ac_EstablishedFatherLast_NAME            CHAR(20),
 @Ac_EstablishedFatherMiddle_NAME          CHAR(20),
 @Ac_EstablishedFatherSuffix_NAME          CHAR(4),
 @An_EstablishedMotherMci_IDNO             NUMERIC(10),
 @An_EstablishedFatherMci_IDNO             NUMERIC(10),
 @Ac_HusbandFirst_NAME                     CHAR(16),
 @Ac_HusbandLast_NAME                      CHAR(20),
 @Ac_HusbandMiddle_NAME                    CHAR(20),
 @Ac_HusbandSuffix_NAME                    CHAR(4),
 @As_MarriedDuringChildBirthHusband_NAME   VARCHAR(60),
 @Ad_MarriageDuringChildBirth_DATE         DATE,
 @Ac_MarriageDuringChildBirthCounty_NAME   CHAR(40),
 @Ac_MarriageDuringChildBirthState_CODE    CHAR(2),
 @Ad_EstablishedParentsMarriage_DATE       DATE,
 @Ac_EstablishedParentsMarriageCounty_NAME CHAR(40),
 @Ac_EstablishedParentsMarriageState_CODE  CHAR(2),
 @Ac_DirectSupportPay_INDC                 CHAR(1),
 @Ad_ChildParentDivorce_DATE               DATE,
 @Ac_ChildParentDivorceCounty_NAME         CHAR(40),
 @Ac_ChildParentDivorceState_CODE          CHAR(2),
 @Ac_EverReceivedMedicaid_INDC             CHAR(1) = 'N',
 @Ac_ChildCoveredInsurance_INDC            CHAR(1) = 'N',
 @An_IveParty_IDNO                         NUMERIC(10),
 @Ac_DivorceProceeding_INDC                CHAR(1),
 @An_OthpInst_IDNO                         NUMERIC(9)
 )
AS
 /*                      
  *     PROCEDURE NAME    : APDM_INSERT_S2                      
  *     DESCRIPTION       : Inserts the demographics details of the member.                                  
  *     DEVELOPED BY      : IMP Team                      
  *     DEVELOPED ON      : 02-NOV-2011                      
  *     MODIFIED BY       :                       
  *     MODIFIED ON       :                       
  *     VERSION NO        : 1                      
 */
 DECLARE @Ld_Systemdatetime_DTTM  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Ld_High_DATE            DATE = '12/31/9999',
         @Lc_Space_TEXT           CHAR(1) = ' ',
         @Ld_Low_DATE             DATE = '01/01/0001',
         @Li_Zero_NUMB            SMALLINT = 0,
         @Ln_MemberMciFoster_IDNO NUMERIC(10) =0000999998;

 BEGIN
  INSERT APDM_Y1
         (Application_IDNO,
          MemberMci_IDNO,
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
          StateLastShared_CODE,
          MilitaryStart_DATE,
          IncarceratedFrom_DATE,
          IncarceratedTo_DATE,
          OtherIncomeType_CODE,
          OtherIncome_AMNT,
          IncomeFrequency_CODE,
          NcpProvideChildInsurance_INDC,
          CountyMarriage_NAME,
          DivorceCounty_NAME,
          ConceptionCity_NAME,
          ConceptionState_CODE,
          EstablishedMother_CODE,
          EstablishedFather_CODE,
          FatherNameOnBirthCertificate_INDC,
          HusbandIsNotFather_INDC,
          PaternityEstablishedByOrder_INDC,
          TypeOrder_CODE,
          GeneticTesting_INDC,
          AdditionalNotes_TEXT,
          EstablishedMotherFirst_NAME,
          EstablishedMotherLast_NAME,
          EstablishedMotherMiddle_NAME,
          EstablishedMotherSuffix_NAME,
          EstablishedFatherFirst_NAME,
          EstablishedFatherLast_NAME,
          EstablishedFatherMiddle_NAME,
          EstablishedFatherSuffix_NAME,
          EstablishedMotherMci_IDNO,
          EstablishedFatherMci_IDNO,
          HusbandFirst_NAME,
          HusbandLast_NAME,
          HusbandMiddle_NAME,
          HusbandSuffix_NAME,
          MarriedDuringChildBirthHusband_NAME,
          MarriageDuringChildBirth_DATE,
          MarriageDuringChildBirthCounty_NAME,
          MarriageDuringChildBirthState_CODE,
          EstablishedParentsMarriage_DATE,
          EstablishedParentsMarriageCounty_NAME,
          EstablishedParentsMarriageState_CODE,
          EverReceivedMedicaid_INDC,
          ChildCoveredInsurance_INDC,
          CourtDivorce_TEXT,
          IveParty_IDNO,
          DirectSupportPay_INDC,
          MothermarriedDuringChildBirth_INDC,
          ChildParentDivorce_DATE,
          ChildParentDivorceCounty_NAME,
          DivorceProceeding_INDC,
          ChildParentDivorceState_CODE,
          OtherIncome_INDC,
          Individual_IDNO)
  VALUES ( @An_Application_IDNO,
           @Ln_MemberMciFoster_IDNO,
           @Ac_First_NAME,
           @Ac_Last_NAME,
           @Ac_Middle_NAME,
           @Ac_Suffix_NAME,
           @Lc_Space_TEXT,
           @Lc_Space_TEXT,
           @Lc_Space_TEXT,
           @Ac_MotherMaiden_NAME,
           @Ac_MemberSex_CODE,
           @An_MemberSsn_NUMB,
           @Ad_Birth_DATE,
           @Ad_Deceased_DATE,
           @Ac_BirthCity_NAME,
           @Ac_BirthCountry_CODE,
           @Ac_BirthState_CODE,
           @Lc_Space_TEXT,
           @Ac_ColorEyes_CODE,
           @Ac_ColorHair_CODE,
           @Ac_Race_CODE,
           @Ac_DescriptionHeight_TEXT,
           @Ac_DescriptionWeightLbs_TEXT,
           @Ld_Low_DATE,
           @Ac_Divorce_INDC,
           @Ld_Low_DATE,
           @Ac_AlienRegistn_ID,
           @Ac_Language_CODE,
           @Lc_Space_TEXT,
           @An_CellPhone_NUMB,
           @An_HomePhone_NUMB,
           @As_Contact_EML,
           @Ac_LicenseDriverNo_TEXT,
           @Lc_Space_TEXT,
           @Ac_TypeProblem_CODE,
           @Lc_Space_TEXT,
           @Ac_MilitaryBranch_CODE,
           @Ld_Low_DATE,
           @Ac_EverIncarcerated_INDC,
           @Ac_PaternityEst_INDC,
           @Ac_PaternityEst_CODE,
           @Ad_PaternityEst_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ac_StateMarriage_CODE,
           @Ac_StateDivorce_CODE,
           @Ac_FilePaternity_ID,
           @Li_Zero_NUMB,
           @Lc_Space_TEXT,
           @An_OthpInst_IDNO,
           @Ac_StateLastShared_CODE,
           @Ad_MilitaryStart_DATE,
           @Ad_IncarceratedFrom_DATE,
           @Ad_IncarceratedTo_DATE,
           @Ac_OtherIncomeType_CODE,
           @An_OtherIncome_AMNT,
           @Ac_IncomeFrequency_CODE,
           @Ac_NcpProvideChildInsurance_INDC,
           @Ac_CountyMarriage_NAME,
           @Ac_DivorceCounty_NAME,
           @Ac_ConceptionCity_NAME,
           @Ac_ConceptionState_CODE,
           @Ac_EstablishedMother_CODE,
           @Ac_EstablishedFather_CODE,
           @Ac_FatherNameOnBirthCertificate_INDC,
           @Ac_HusbandIsNotFather_INDC,
           @Ac_PaternityEstablishedByOrder_INDC,
           @Ac_TypeOrder_CODE,
           @Ac_GeneticTesting_INDC,
           @As_AdditionalNotes_TEXT,
           @Ac_EstablishedMotherFirst_NAME,
           @Ac_EstablishedMotherLast_NAME,
           @Ac_EstablishedMotherMiddle_NAME,
           @Ac_EstablishedMotherSuffix_NAME,
           @Ac_EstablishedFatherFirst_NAME,
           @Ac_EstablishedFatherLast_NAME,
           @Ac_EstablishedFatherMiddle_NAME,
           @Ac_EstablishedFatherSuffix_NAME,
           @An_EstablishedMotherMci_IDNO,
           @An_EstablishedFatherMci_IDNO,
           @Ac_HusbandFirst_NAME,
           @Ac_HusbandLast_NAME,
           @Ac_HusbandMiddle_NAME,
           @Ac_HusbandSuffix_NAME,
           @As_MarriedDuringChildBirthHusband_NAME,
           @Ad_MarriageDuringChildBirth_DATE,
           @Ac_MarriageDuringChildBirthCounty_NAME,
           @Ac_MarriageDuringChildBirthState_CODE,
           @Ad_EstablishedParentsMarriage_DATE,
           @Ac_EstablishedParentsMarriageCounty_NAME,
           @Ac_EstablishedParentsMarriageState_CODE,
           @Ac_EverReceivedMedicaid_INDC,
           @Ac_ChildCoveredInsurance_INDC,
           @Ac_CourtDivorce_TEXT,
           @An_IveParty_IDNO,
           @Ac_DirectSupportPay_INDC,
           @Ac_MothermarriedDuringChildBirth_INDC,
           @Ad_ChildParentDivorce_DATE,
           @Ac_ChildParentDivorceCounty_NAME,
           @Ac_DivorceProceeding_INDC,
           @Ac_ChildParentDivorceState_CODE,
           @Ac_OtherIncome_INDC,
           @Li_Zero_NUMB);
 END; --End of APDM_INSERT_S2

GO
