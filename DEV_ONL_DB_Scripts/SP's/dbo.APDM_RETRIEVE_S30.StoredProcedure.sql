/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S30](
 @An_Application_IDNO             NUMERIC(15, 0),
 @An_MemberMci_IDNO               NUMERIC(10, 0),
 @Ac_Race_CODE                    CHAR(1) OUTPUT,
 @Ac_EverIncarcerated_INDC        CHAR(1) OUTPUT,
 @Ac_CurrentMilitary_INDC         CHAR(1) OUTPUT,
 @Ac_Divorce_INDC                 CHAR(1) OUTPUT,
 @Ac_FamilyViolence_INDC          CHAR(1) OUTPUT,
 @Ac_Interpreter_INDC             CHAR(1) OUTPUT,
 @Ac_PaternityEst_INDC            CHAR(1) OUTPUT,
 @Ad_BeginValidity_DATE           DATE OUTPUT,
 @Ad_Divorce_DATE                 DATE OUTPUT,
 @Ad_EndValidity_DATE             DATE OUTPUT,
 @Ad_FamilyViolence_DATE          DATE OUTPUT,
 @Ad_Marriage_DATE                DATE OUTPUT,
 @Ad_MilitaryEnd_DATE             DATE OUTPUT,
 @Ad_PaternityEst_DATE            DATE OUTPUT,
 @Ad_Update_DTTM                  DATETIME2 OUTPUT,
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0) OUTPUT,
 @Ac_BirthCity_NAME               CHAR(28) OUTPUT,
 @As_Contact_EML                  VARCHAR(100) OUTPUT,
 @Ac_BirthCountry_CODE            CHAR(2) OUTPUT,
 @Ac_BirthState_CODE              CHAR(2) OUTPUT,
 @Ac_ColorEyes_CODE               CHAR(3) OUTPUT,
 @Ac_ColorHair_CODE               CHAR(3) OUTPUT,
 @An_CountyPaternity_IDNO         NUMERIC(3, 0) OUTPUT,
 @Ac_Language_CODE                CHAR(3) OUTPUT,
 @Ac_LicenseIssueState_CODE       CHAR(2) OUTPUT,
 @Ac_MilitaryBranch_CODE          CHAR(2) OUTPUT,
 @Ac_PaternityEst_CODE            CHAR(3) OUTPUT,
 @An_ResideCounty_IDNO            NUMERIC(3, 0) OUTPUT,
 @Ac_StateDivorce_CODE            CHAR(2) OUTPUT,
 @Ac_StateMarriage_CODE           CHAR(2) OUTPUT,
 @Ac_TypeFamilyViolence_CODE      CHAR(2) OUTPUT,
 @Ac_TypeProblem_CODE             CHAR(3) OUTPUT,
 @Ac_DescriptionHeight_TEXT       CHAR(3) OUTPUT,
 @Ac_DescriptionWeightLbs_TEXT    CHAR(3) OUTPUT,
 @Ad_Birth_DATE                   DATE OUTPUT,
 @Ad_Deceased_DATE                DATE OUTPUT,
 @Ac_AlienRegistn_ID              CHAR(10) OUTPUT,
 @Ac_FilePaternity_ID             CHAR(10) OUTPUT,
 @An_OthpInst_IDNO                NUMERIC(9, 0) OUTPUT,
 @An_Individual_IDNO              NUMERIC(8, 0) OUTPUT,
 @Ac_WorkerUpdate_ID              CHAR(30) OUTPUT,
 @Ac_MemberSex_CODE               CHAR(1) OUTPUT,
 @An_MemberSsn_NUMB               NUMERIC(9, 0) OUTPUT,
 @Ac_First_NAME                   CHAR(16) OUTPUT,
 @Ac_Last_NAME                    CHAR(20) OUTPUT,
 @Ac_Middle_NAME                  CHAR(20) OUTPUT,
 @Ac_MotherMaiden_NAME            CHAR(30) OUTPUT,
 @Ac_Suffix_NAME                  CHAR(4) OUTPUT,
 @An_CellPhone_NUMB               NUMERIC(15, 0) OUTPUT,
 @An_HomePhone_NUMB               NUMERIC(15, 0) OUTPUT,
 @Ac_LicenseDriverNo_TEXT         CHAR(25) OUTPUT,
 @Ac_FirstAlias_NAME              CHAR(16) OUTPUT,
 @Ac_LastAlias_NAME               CHAR(20) OUTPUT,
 @Ac_MiddleAlias_NAME             CHAR(20) OUTPUT,
 @Ac_SuffixAlias_NAME             CHAR(4) OUTPUT,
 @Ac_EstablishedFather_CODE       CHAR(1) OUTPUT,
 @Ac_EstablishedMother_CODE       CHAR(1) OUTPUT,
 @An_EstablishedMotherMci_IDNO    NUMERIC(10, 0) OUTPUT,
 @An_EstablishedFatherMci_IDNO    NUMERIC(10, 0) OUTPUT,
 @Ac_EstablishedMotherFirst_NAME  CHAR(16) OUTPUT,
 @Ac_EstablishedMotherLast_NAME   CHAR(20) OUTPUT,
 @Ac_EstablishedMotherMiddle_NAME CHAR(20) OUTPUT,
 @Ac_EstablishedMotherSuffix_NAME CHAR(4) OUTPUT,
 @Ac_EstablishedFatherFirst_NAME  CHAR(16) OUTPUT,
 @Ac_EstablishedFatherLast_NAME   CHAR(20) OUTPUT,
 @Ac_EstablishedFatherMiddle_NAME CHAR(20) OUTPUT,
 @Ac_EstablishedFatherSuffix_NAME CHAR(4) OUTPUT,
 @An_IveParty_IDNO                NUMERIC(10, 0) OUTPUT
 )
AS
 /*                                                                                                                                            
  *     PROCEDURE NAME    : APDM_RETRIEVE_S30                                                                                                   
  *     DESCRIPTION       : Retrieve all Member Demographics details at the time of Application Received for an Application ID and Member IA.                                                                                                  
  *     DEVELOPED BY      : IMP Team                                                                                                         
  *     DEVELOPED ON      : 22-AUG-2011                                                                                                        
  *     MODIFIED BY       :                                                                                                                    
  *     MODIFIED ON       :                                                                                                                    
  *     VERSION NO        : 1                                                                                                                  
 */
 BEGIN
  SELECT @Ac_Race_CODE = NULL,
         @Ac_EverIncarcerated_INDC = NULL,
         @Ac_CurrentMilitary_INDC = NULL,
         @Ac_Divorce_INDC = NULL,
         @Ac_FamilyViolence_INDC = NULL,
         @Ac_Interpreter_INDC = NULL,
         @Ac_PaternityEst_INDC = NULL,
         @Ad_BeginValidity_DATE = NULL,
         @Ad_Divorce_DATE = NULL,
         @Ad_EndValidity_DATE = NULL,
         @Ad_FamilyViolence_DATE = NULL,
         @Ad_Marriage_DATE = NULL,
         @Ad_MilitaryEnd_DATE = NULL,
         @Ad_PaternityEst_DATE = NULL,
         @Ad_Update_DTTM = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_BirthCity_NAME = NULL,
         @As_Contact_EML = NULL,
         @Ac_BirthCountry_CODE = NULL,
         @Ac_BirthState_CODE = NULL,
         @Ac_ColorEyes_CODE = NULL,
         @Ac_ColorHair_CODE = NULL,
         @An_CountyPaternity_IDNO = NULL,
         @Ac_Language_CODE = NULL,
         @Ac_LicenseIssueState_CODE = NULL,
         @Ac_MilitaryBranch_CODE = NULL,
         @Ac_PaternityEst_CODE = NULL,
         @An_ResideCounty_IDNO = NULL,
         @Ac_StateDivorce_CODE = NULL,
         @Ac_StateMarriage_CODE = NULL,
         @Ac_TypeFamilyViolence_CODE = NULL,
         @Ac_TypeProblem_CODE = NULL,
         @Ac_DescriptionHeight_TEXT = NULL,
         @Ac_DescriptionWeightLbs_TEXT = NULL,
         @Ad_Birth_DATE = NULL,
         @Ad_Deceased_DATE = NULL,
         @Ac_AlienRegistn_ID = NULL,
         @Ac_FilePaternity_ID = NULL,
         @An_OthpInst_IDNO = NULL,
         @An_Individual_IDNO = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ac_MemberSex_CODE = NULL,
         @An_MemberSsn_NUMB = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_MotherMaiden_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @An_CellPhone_NUMB = NULL,
         @An_HomePhone_NUMB = NULL,
         @Ac_LicenseDriverNo_TEXT = NULL,
         @Ac_FirstAlias_NAME = NULL,
         @Ac_LastAlias_NAME = NULL,
         @Ac_MiddleAlias_NAME = NULL,
         @Ac_SuffixAlias_NAME = NULL,
         @Ac_EstablishedFather_CODE = NULL,
         @Ac_EstablishedMother_CODE = NULL,
         @An_EstablishedMotherMci_IDNO = NULL,
         @An_EstablishedFatherMci_IDNO = NULL,
         @Ac_EstablishedMotherFirst_NAME = NULL,
         @Ac_EstablishedMotherLast_NAME = NULL,
         @Ac_EstablishedMotherMiddle_NAME = NULL,
         @Ac_EstablishedMotherSuffix_NAME = NULL,
         @Ac_EstablishedFatherFirst_NAME = NULL,
         @Ac_EstablishedFatherLast_NAME = NULL,
         @Ac_EstablishedFatherMiddle_NAME = NULL,
         @Ac_EstablishedFatherSuffix_NAME = NULL,
         @An_IveParty_IDNO = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_BirthCity_NAME = A.BirthCity_NAME,
         @As_Contact_EML = A.Contact_EML,
         @Ac_BirthCountry_CODE = A.BirthCountry_CODE,
         @Ac_BirthState_CODE = A.BirthState_CODE,
         @Ac_ColorEyes_CODE = A.ColorEyes_CODE,
         @Ac_ColorHair_CODE = A.ColorHair_CODE,
         @An_CountyPaternity_IDNO = A.CountyPaternity_IDNO,
         @Ac_Language_CODE = A.Language_CODE,
         @Ac_LicenseIssueState_CODE = A.LicenseIssueState_CODE,
         @Ac_MilitaryBranch_CODE = A.MilitaryBranch_CODE,
         @Ac_PaternityEst_CODE = A.PaternityEst_CODE,
         @Ac_Race_CODE = A.Race_CODE,
         @An_ResideCounty_IDNO = A.ResideCounty_IDNO,
         @Ac_StateDivorce_CODE = A.StateDivorce_CODE,
         @Ac_StateMarriage_CODE = A.StateMarriage_CODE,
         @Ac_TypeFamilyViolence_CODE = A1.TypeFamilyViolence_CODE,
         @Ac_TypeProblem_CODE = A.TypeProblem_CODE,
         @Ac_DescriptionHeight_TEXT = A.DescriptionHeight_TEXT,
         @Ac_DescriptionWeightLbs_TEXT = A.DescriptionWeightLbs_TEXT,
         @Ad_BeginValidity_DATE = A.BeginValidity_DATE,
         @Ad_Birth_DATE = A.Birth_DATE,
         @Ad_Deceased_DATE = A.Deceased_DATE,
         @Ad_Divorce_DATE = A.Divorce_DATE,
         @Ad_EndValidity_DATE = A.EndValidity_DATE,
         @Ad_FamilyViolence_DATE = A1.FamilyViolence_DATE,
         @Ad_Marriage_DATE = A.Marriage_DATE,
         @Ad_MilitaryEnd_DATE = A.MilitaryEnd_DATE,
         @Ad_PaternityEst_DATE = A.PaternityEst_DATE,
         @Ac_AlienRegistn_ID = A.AlienRegistn_ID,
         @Ac_FilePaternity_ID = A.FilePaternity_ID,
         @An_OthpInst_IDNO = A.OthpInst_IDNO,
         @An_Individual_IDNO = A.Individual_IDNO,
         @Ac_WorkerUpdate_ID = A.WorkerUpdate_ID,
         @Ac_EverIncarcerated_INDC = A.EverIncarcerated_INDC,
         @Ac_CurrentMilitary_INDC = A.CurrentMilitary_INDC,
         @Ac_Divorce_INDC = A.Divorce_INDC,
         @Ac_FamilyViolence_INDC = A1.FamilyViolence_INDC,
         @Ac_Interpreter_INDC = A.Interpreter_INDC,
         @Ac_PaternityEst_INDC = A.PaternityEst_INDC,
         @Ac_MemberSex_CODE = A.MemberSex_CODE,
         @An_MemberSsn_NUMB = A.MemberSsn_NUMB,
         @Ac_First_NAME = A.First_NAME,
         @Ac_FirstAlias_NAME = A.FirstAlias_NAME,
         @Ac_Last_NAME = A.Last_NAME,
         @Ac_LastAlias_NAME = A.LastAlias_NAME,
         @Ac_Middle_NAME = A.Middle_NAME,
         @Ac_MiddleAlias_NAME = A.MiddleAlias_NAME,
         @Ac_MotherMaiden_NAME = A.MotherMaiden_NAME,
         @Ac_Suffix_NAME = A.Suffix_NAME,
         @Ac_SuffixAlias_NAME = A.SuffixAlias_NAME,
         @An_CellPhone_NUMB = A.CellPhone_NUMB,
         @An_HomePhone_NUMB = A.HomePhone_NUMB,
         @Ac_LicenseDriverNo_TEXT = A.LicenseDriverNo_TEXT,
         @An_TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB,
         @Ad_Update_DTTM = A.Update_DTTM,
         @Ac_EstablishedFather_CODE = A.EstablishedFather_CODE,
         @Ac_EstablishedMother_CODE = A.EstablishedMother_CODE,
         @An_EstablishedMotherMci_IDNO = A.EstablishedMotherMci_IDNO,
         @An_EstablishedFatherMci_IDNO = A.EstablishedFatherMci_IDNO,
         @Ac_EstablishedMotherFirst_NAME = A.EstablishedMotherFirst_NAME,
         @Ac_EstablishedMotherLast_NAME = A.EstablishedMotherLast_NAME,
         @Ac_EstablishedMotherMiddle_NAME = A.EstablishedMotherMiddle_NAME,
         @Ac_EstablishedMotherSuffix_NAME = A.EstablishedMotherSuffix_NAME,
         @Ac_EstablishedFatherFirst_NAME = A.EstablishedFatherFirst_NAME,
         @Ac_EstablishedFatherLast_NAME = A.EstablishedFatherLast_NAME,
         @Ac_EstablishedFatherMiddle_NAME = A.EstablishedFatherMiddle_NAME,
         @Ac_EstablishedFatherSuffix_NAME = A.EstablishedFatherSuffix_NAME,
         @An_IveParty_IDNO = A.IveParty_IDNO
    FROM APDM_Y1 A
         JOIN APCM_Y1 A1
          ON (A.MemberMci_IDNO = A1.MemberMci_IDNO)
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APDM_RETRIEVE_S30


GO
