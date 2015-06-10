/****** Object:  StoredProcedure [dbo].[DEMO_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_UPDATE_S1](
 @An_MemberMciKey_IDNO                NUMERIC(10),
 @An_MemberMci_IDNO                   NUMERIC(10, 0),
 @An_Individual_IDNO                  NUMERIC(8, 0),
 @Ac_Last_NAME                        CHAR(20),
 @Ac_First_NAME                       CHAR(16),
 @Ac_Middle_NAME                      CHAR(20),
 @Ac_Suffix_NAME                      CHAR(4),
 @Ac_Title_NAME                       CHAR(8),
 @As_FullDisplay_NAME                 VARCHAR(60),
 @Ac_MemberSex_CODE                   CHAR(1),
 @An_MemberSsn_NUMB                   NUMERIC(9, 0),
 @Ad_Birth_DATE                       DATE,
 @Ad_Emancipation_DATE                DATE,
 @Ad_LastMarriage_DATE                DATE,
 @Ad_LastDivorce_DATE                 DATE,
 @Ac_BirthCity_NAME                   CHAR(28),
 @Ac_BirthState_CODE                  CHAR(2),
 @Ac_BirthCountry_CODE                CHAR(2),
 @Ac_DescriptionHeight_TEXT           CHAR(3),
 @Ac_DescriptionWeightLbs_TEXT        CHAR(3),
 @Ac_Race_CODE                        CHAR(1),
 @Ac_ColorHair_CODE                   CHAR(3),
 @Ac_ColorEyes_CODE                   CHAR(3),
 @Ac_FacialHair_INDC                  CHAR(1),
 @Ac_Language_CODE                    CHAR(3),
 @Ac_TypeProblem_CODE                 CHAR(3),
 @Ad_Deceased_DATE                    DATE,
 @Ac_CerDeathNo_TEXT                  CHAR(9),
 @Ac_LicenseDriverNo_TEXT             CHAR(25),
 @Ac_AlienRegistn_ID                  CHAR(10),
 @Ac_WorkPermitNo_TEXT                CHAR(10),
 @Ad_BeginPermit_DATE                 DATE,
 @Ad_EndPermit_DATE                   DATE,
 @An_HomePhone_NUMB                   NUMERIC(15, 0),
 @An_WorkPhone_NUMB                   NUMERIC(15, 0),
 @An_CellPhone_NUMB                   NUMERIC(15, 0),
 @An_Fax_NUMB                         NUMERIC(15, 0),
 @As_Contact_EML                      VARCHAR(100),
 @Ac_Spouse_NAME                      CHAR(40),
 @Ad_Graduation_DATE                  DATE,
 @Ac_EducationLevel_CODE              CHAR(2),
 @Ac_Restricted_INDC                  CHAR(1),
 @Ac_Military_ID                      CHAR(10),
 @Ac_MilitaryBranch_CODE              CHAR(2),
 @Ac_MilitaryStatus_CODE              CHAR(2),
 @Ac_MilitaryBenefitStatus_CODE       CHAR(2),
 @Ac_SecondFamily_INDC                CHAR(1),
 @Ac_MeansTestedInc_INDC              CHAR(1),
 @Ac_SsIncome_INDC                    CHAR(1),
 @Ac_VeteranComps_INDC                CHAR(1),
 @Ac_Assistance_CODE                  CHAR(3),
 @Ac_DescriptionIdentifyingMarks_TEXT CHAR(40),
 @Ac_Divorce_INDC                     CHAR(1),
 @Ad_BeginValidity_DATE               DATE,
 @Ac_WorkerUpdate_ID                  CHAR(30),
 @An_TransactionEventSeq_NUMB         NUMERIC(19, 0),
 @Ad_Update_DTTM                      DATETIME2,
 @Ac_Disable_INDC                     CHAR(1),
 @Ac_TypeOccupation_CODE              CHAR(3),
 @An_CountyBirth_IDNO                 NUMERIC(3, 0),
 @Ac_MotherMaiden_NAME                CHAR(30),
 @Ac_FileLastDivorce_ID               CHAR(15),
 @Ac_TribalAffiliations_CODE          CHAR(3),
 @An_FormerMci_IDNO                   NUMERIC(10, 0),
 @An_IveParty_IDNO                    NUMERIC(10, 0)
 )
AS
 /*    
 *      PROCEDURE NAME    : DEMO_UPDATE_S1    
  *     DESCRIPTION       : Update Member Demographics table with Member Personal Demographics details and new Sequence Event Transaction for Unique number assigned by the system to the participant.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 20-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
		  @Ld_Current_DTTM      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()

  UPDATE DEMO_Y1
     SET MemberMci_IDNO = @An_MemberMci_IDNO,
         Individual_IDNO = @An_Individual_IDNO,
         Last_NAME = @Ac_Last_NAME,
         First_NAME = @Ac_First_NAME,
         Middle_NAME = @Ac_Middle_NAME,
         Suffix_NAME = @Ac_Suffix_NAME,
         Title_NAME = @Ac_Title_NAME,
         FullDisplay_NAME = @As_FullDisplay_NAME,
         MemberSex_CODE = @Ac_MemberSex_CODE,
         MemberSsn_NUMB = @An_MemberSsn_NUMB,
         Birth_DATE = @Ad_Birth_DATE,
         Emancipation_DATE = @Ad_Emancipation_DATE,
         LastMarriage_DATE = @Ad_LastMarriage_DATE,
         LastDivorce_DATE = @Ad_LastDivorce_DATE,
         BirthCity_NAME = @Ac_BirthCity_NAME,
         BirthState_CODE = @Ac_BirthState_CODE,
         BirthCountry_CODE = @Ac_BirthCountry_CODE,
         DescriptionHeight_TEXT = @Ac_DescriptionHeight_TEXT,
         DescriptionWeightLbs_TEXT = @Ac_DescriptionWeightLbs_TEXT,
         Race_CODE = @Ac_Race_CODE,
         ColorHair_CODE = @Ac_ColorHair_CODE,
         ColorEyes_CODE = @Ac_ColorEyes_CODE,
         FacialHair_INDC = @Ac_FacialHair_INDC,
         Language_CODE = @Ac_Language_CODE,
         TypeProblem_CODE = @Ac_TypeProblem_CODE,
         Deceased_DATE = @Ad_Deceased_DATE,
         CerDeathNo_TEXT = @Ac_CerDeathNo_TEXT,
         LicenseDriverNo_TEXT = @Ac_LicenseDriverNo_TEXT,
         AlienRegistn_ID = @Ac_AlienRegistn_ID,
         WorkPermitNo_TEXT = @Ac_WorkPermitNo_TEXT,
         BeginPermit_DATE = @Ad_BeginPermit_DATE,
         EndPermit_DATE = @Ad_EndPermit_DATE,
         HomePhone_NUMB = @An_HomePhone_NUMB,
         WorkPhone_NUMB = @An_WorkPhone_NUMB,
         CellPhone_NUMB = @An_CellPhone_NUMB,
         Fax_NUMB = @An_Fax_NUMB,
         Contact_EML = @As_Contact_EML,
         Spouse_NAME = @Ac_Spouse_NAME,
         Graduation_DATE = @Ad_Graduation_DATE,
         EducationLevel_CODE = @Ac_EducationLevel_CODE,
         Restricted_INDC = @Ac_Restricted_INDC,
         Military_ID = @Ac_Military_ID,
         MilitaryBranch_CODE = @Ac_MilitaryBranch_CODE,
         MilitaryStatus_CODE = @Ac_MilitaryStatus_CODE,
         MilitaryBenefitStatus_CODE = @Ac_MilitaryBenefitStatus_CODE,
         SecondFamily_INDC = @Ac_SecondFamily_INDC,
         MeansTestedInc_INDC = @Ac_MeansTestedInc_INDC,
         SsIncome_INDC = @Ac_SsIncome_INDC,
         VeteranComps_INDC = @Ac_VeteranComps_INDC,
         Assistance_CODE = @Ac_Assistance_CODE,
         DescriptionIdentifyingMarks_TEXT = @Ac_DescriptionIdentifyingMarks_TEXT,
         Divorce_INDC = @Ac_Divorce_INDC,
         BeginValidity_DATE = @Ad_BeginValidity_DATE,
         WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ad_Update_DTTM,
         Disable_INDC = @Ac_Disable_INDC,
         TypeOccupation_CODE = @Ac_TypeOccupation_CODE,
         CountyBirth_IDNO = @An_CountyBirth_IDNO,
         MotherMaiden_NAME = @Ac_MotherMaiden_NAME,
         FileLastDivorce_ID = @Ac_FileLastDivorce_ID,
         TribalAffiliations_CODE = @Ac_TribalAffiliations_CODE,
         FormerMci_IDNO = @An_FormerMci_IDNO,
		 IveParty_IDNO = @An_IveParty_IDNO
     OUTPUT DELETED.MemberMci_IDNO,
         DELETED.Individual_IDNO,
         DELETED.Last_NAME,
         DELETED.First_NAME,
         DELETED.Middle_NAME,
         DELETED.Suffix_NAME,
         DELETED.Title_NAME,
         DELETED.FullDisplay_NAME,
         DELETED.MemberSex_CODE,
         DELETED.MemberSsn_NUMB,
         DELETED.Birth_DATE,
         DELETED.Emancipation_DATE,
         DELETED.LastMarriage_DATE,
         DELETED.LastDivorce_DATE,
         DELETED.BirthCity_NAME,
         DELETED.BirthState_CODE,
         DELETED.BirthCountry_CODE,
         DELETED.DescriptionHeight_TEXT,
         DELETED.DescriptionWeightLbs_TEXT,
         DELETED.Race_CODE,
         DELETED.ColorHair_CODE,
         DELETED.ColorEyes_CODE,
         DELETED.FacialHair_INDC,
         DELETED.Language_CODE,
         DELETED.TypeProblem_CODE,
         DELETED.Deceased_DATE,
         DELETED.CerDeathNo_TEXT,
         DELETED.LicenseDriverNo_TEXT,
         DELETED.AlienRegistn_ID,
         DELETED.WorkPermitNo_TEXT,
         DELETED.BeginPermit_DATE,
         DELETED.EndPermit_DATE,
         DELETED.HomePhone_NUMB,
         DELETED.WorkPhone_NUMB,
         DELETED.CellPhone_NUMB,
         DELETED.Fax_NUMB,
         DELETED.Contact_EML,
         DELETED.Spouse_NAME,
         DELETED.Graduation_DATE,
         DELETED.EducationLevel_CODE,
         DELETED.Restricted_INDC,
         DELETED.Military_ID,
         DELETED.MilitaryBranch_CODE,
         DELETED.MilitaryStatus_CODE,
         DELETED.MilitaryBenefitStatus_CODE,
         DELETED.SecondFamily_INDC,
         DELETED.MeansTestedInc_INDC,
         DELETED.SsIncome_INDC,
         DELETED.VeteranComps_INDC,
         DELETED.Disable_INDC,
         DELETED.Assistance_CODE,
         DELETED.DescriptionIdentifyingMarks_TEXT,
         DELETED.Divorce_INDC,
         DELETED.BeginValidity_DATE,
         @Ld_Current_DTTM AS EndValidity_DATE,
         DELETED.WorkerUpdate_ID,
         DELETED.TransactionEventSeq_NUMB,
         DELETED.Update_DTTM,
         DELETED.TypeOccupation_CODE,
         DELETED.CountyBirth_IDNO,
         DELETED.MotherMaiden_NAME,
         DELETED.FileLastDivorce_ID,
         DELETED.TribalAffiliations_CODE,
         DELETED.FormerMci_IDNO,
         DELETED.StateDivorce_CODE,
         DELETED.CityDivorce_NAME,
         DELETED.StateMarriage_CODE,
         DELETED.CityMarriage_NAME,
         DELETED.IveParty_IDNO
    INTO HDEMO_Y1         
   WHERE MemberMci_IDNO = @An_MemberMciKey_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of DEMO_UPDATE_S1  

GO
