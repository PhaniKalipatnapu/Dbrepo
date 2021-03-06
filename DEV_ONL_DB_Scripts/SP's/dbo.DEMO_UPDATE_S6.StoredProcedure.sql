/****** Object:  StoredProcedure [dbo].[DEMO_UPDATE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_UPDATE_S6] (
 @An_MemberMci_IDNO					NUMERIC(10, 0),
 @Ad_Emancipation_DATE				DATE,
 @Ad_Graduation_DATE				DATE,
 @Ac_EducationLevel_CODE			CHAR(2),
 @Ac_Military_ID					CHAR(10),
 @Ac_MilitaryBranch_CODE			CHAR(2),
 @Ac_MilitaryStatus_CODE			CHAR(2),
 @Ac_MilitaryBenefitStatus_CODE		CHAR(2),
 @Ac_SecondFamily_INDC				CHAR(1),
 @Ac_MeansTestedInc_INDC			CHAR(1),
 @Ac_SsIncome_INDC					CHAR(1),
 @Ac_VeteranComps_INDC				CHAR(1),
 @Ac_SignedOnWorker_ID				CHAR(30),
 @An_TransactionEventSeq_NUMB		NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB    NUMERIC(19, 0),
 @Ac_Disable_INDC					CHAR(1),
 @Ac_TypeOccupation_CODE			CHAR(3)
 )
AS
 /*  
  *     PROCEDURE NAME    : DEMO_UPDATE_S6  
  *     DESCRIPTION       : Update Member Demographics table with Member Demographics Status Tab details and new Sequence Event Transaction for Unique number assigned by the system to the participant.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 18-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB   NUMERIC(10),
          @Ld_Current_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Lowdate_DATE        DATE = '01/01/0001',
          @Ld_High_DATE           DATE = '12/31/9999';

  UPDATE DEMO_Y1
     SET Emancipation_DATE = ISNULL(@Ad_Emancipation_DATE, @Ld_High_DATE),
         Graduation_DATE = ISNULL(@Ad_Graduation_DATE, @Ld_Lowdate_DATE),
         EducationLevel_CODE = @Ac_EducationLevel_CODE,
         Military_ID = @Ac_Military_ID,
         MilitaryBranch_CODE = @Ac_MilitaryBranch_CODE,
         MilitaryStatus_CODE = @Ac_MilitaryStatus_CODE,
         MilitaryBenefitStatus_CODE = @Ac_MilitaryBenefitStatus_CODE,
         SecondFamily_INDC = @Ac_SecondFamily_INDC,
         MeansTestedInc_INDC = @Ac_MeansTestedInc_INDC,
         SsIncome_INDC = @Ac_SsIncome_INDC,
         VeteranComps_INDC = @Ac_VeteranComps_INDC,
         BeginValidity_DATE = @Ld_Current_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Current_DTTM,
         Disable_INDC = @Ac_Disable_INDC,
         TypeOccupation_CODE = @Ac_TypeOccupation_CODE
         
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
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB;
 END; --END of  DEMO_UPDATE_S6


GO
