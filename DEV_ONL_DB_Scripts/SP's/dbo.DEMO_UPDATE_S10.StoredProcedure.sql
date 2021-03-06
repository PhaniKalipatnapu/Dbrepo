/****** Object:  StoredProcedure [dbo].[DEMO_UPDATE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_UPDATE_S10] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_LicenseDriverNo_TEXT     CHAR(25),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : DEMO_UPDATE_S10    
  *     DESCRIPTION       : Update Member Demographics table with Member Personal Demographics details and new Sequence Event Transaction for Unique number assigned by the system to the participant.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 15-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB   NUMERIC(10),
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DEMO_Y1
     SET LicenseDriverNo_TEXT = @Ac_LicenseDriverNo_TEXT,
         BeginValidity_DATE = @Ld_Current_DATE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Systemdatetime_DTTM
  OUTPUT Deleted.MemberMci_IDNO,
         Deleted.Individual_IDNO,
         Deleted.Last_NAME,
         Deleted.First_NAME,
         Deleted.Middle_NAME,
         Deleted.Suffix_NAME,
         Deleted.Title_NAME,
         Deleted.FullDisplay_NAME,
         Deleted.MemberSex_CODE,
         Deleted.MemberSsn_NUMB,
         Deleted.Birth_DATE,
         Deleted.Emancipation_DATE,
         Deleted.LastMarriage_DATE,
         Deleted.LastDivorce_DATE,
         Deleted.BirthCity_NAME,
         Deleted.BirthState_CODE,
         Deleted.BirthCountry_CODE,
         Deleted.DescriptionHeight_TEXT,
         Deleted.DescriptionWeightLbs_TEXT,
         Deleted.Race_CODE,
         Deleted.ColorHair_CODE,
         Deleted.ColorEyes_CODE,
         Deleted.FacialHair_INDC,
         Deleted.Language_CODE,
         Deleted.TypeProblem_CODE,
         Deleted.Deceased_DATE,
         Deleted.CerDeathNo_TEXT,
         Deleted.LicenseDriverNo_TEXT,
         Deleted.AlienRegistn_ID,
         Deleted.WorkPermitNo_TEXT,
         Deleted.BeginPermit_DATE,
         Deleted.EndPermit_DATE,
         Deleted.HomePhone_NUMB,
         Deleted.WorkPhone_NUMB,
         Deleted.CellPhone_NUMB,
         Deleted.Fax_NUMB,
         Deleted.Contact_EML,
         Deleted.Spouse_NAME,
         Deleted.Graduation_DATE,
         Deleted.EducationLevel_CODE,
         Deleted.Restricted_INDC,
         Deleted.Military_ID,
         Deleted.MilitaryBranch_CODE,
         Deleted.MilitaryStatus_CODE,
         Deleted.MilitaryBenefitStatus_CODE,
         Deleted.SecondFamily_INDC,
         Deleted.MeansTestedInc_INDC,
         Deleted.SsIncome_INDC,
         Deleted.VeteranComps_INDC,
         Deleted.Disable_INDC,
         Deleted.Assistance_CODE,
         Deleted.DescriptionIdentifyingMarks_TEXT,
         Deleted.Divorce_INDC,
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         Deleted.WorkerUpdate_ID,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.Update_DTTM,
         Deleted.TypeOccupation_CODE,
         Deleted.CountyBirth_IDNO,
         Deleted.MotherMaiden_NAME,
         Deleted.FileLastDivorce_ID,
         Deleted.TribalAffiliations_CODE,
         Deleted.FormerMci_IDNO,
         Deleted.StateDivorce_CODE,
         Deleted.CityDivorce_NAME,
         Deleted.StateMarriage_CODE,
         Deleted.CityMarriage_NAME,
         Deleted.IveParty_IDNO
  INTO HDEMO_Y1
   WHERE DEMO_Y1.MemberMci_IDNO = @An_MemberMci_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- End Of DEMO_UPDATE_S10  

GO
