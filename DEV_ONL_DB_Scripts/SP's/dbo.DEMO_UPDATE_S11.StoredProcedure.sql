/****** Object:  StoredProcedure [dbo].[DEMO_UPDATE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_UPDATE_S11] (    
	@An_MemberMci_IDNO				NUMERIC(10,0),    
	@Ac_First_NAME					CHAR(16),
	@Ac_Last_NAME           		CHAR(20),
	@Ac_Middle_NAME         		CHAR(20),
	@Ac_Suffix_NAME         		CHAR(4),
	@As_FullDisplay_NAME			VARCHAR(60),
	@Ad_Birth_DATE          		DATE,
	@Ad_Deceased_DATE       		DATE,
	@An_MemberSsn_NUMB      		NUMERIC(9,0),
	@Ac_MemberSex_CODE      		CHAR(1),
	@Ac_Race_CODE           		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),         
    @An_TransactionEventSeq_NUMB	NUMERIC(19,0)
    )
AS    
    
/*    
 *     PROCEDURE NAME    : DEMO_UPDATE_S11    
 *     DESCRIPTION       : Update Member Demographics table with Member Personal Demographics details and new Sequence Event Transaction.    
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 15-SEP-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
    BEGIN    
    	DECLARE @Ln_RowsAffected_NUMB	 	NUMERIC(10),
    			@Ld_Systemdatetime_DTTM		DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
    			
      UPDATE DEMO_Y1    
         SET MemberMci_IDNO = @An_MemberMci_IDNO,
			First_NAME = @Ac_First_NAME,	
			Last_NAME = @Ac_Last_NAME,
			Middle_NAME = @Ac_Middle_NAME,  
			Suffix_NAME = @Ac_Suffix_NAME,  
			FullDisplay_NAME = @As_FullDisplay_NAME, 
			Birth_DATE = @Ad_Birth_DATE,
			Deceased_DATE = @Ad_Deceased_DATE,
			MemberSsn_NUMB = @An_MemberSsn_NUMB,
			MemberSex_CODE = @Ac_MemberSex_CODE,
			Race_CODE = @Ac_Race_CODE,
            BeginValidity_DATE = @Ld_Systemdatetime_DTTM,     
            WorkerUpdate_ID = @Ac_SignedOnWorker_ID,     
            TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,     
            Update_DTTM = @Ld_Systemdatetime_DTTM
        OUTPUT
         	Deleted.MemberMci_IDNO,
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
            Deleted.SecondFamily_INDC  ,     
            Deleted.MeansTestedInc_INDC,     
            Deleted.SsIncome_INDC,     
            Deleted.VeteranComps_INDC,
            Deleted.Disable_INDC,   
            Deleted.Assistance_CODE,     
            Deleted.DescriptionIdentifyingMarks_TEXT,   
            Deleted.Divorce_INDC,       
            Deleted.BeginValidity_DATE, 
            @Ld_Systemdatetime_DTTM,   
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
		INTO HDEMO_Y1 (
					MemberMci_IDNO,
					Individual_IDNO,
					Last_NAME,
					First_NAME,
					Middle_NAME,
					Suffix_NAME,
					Title_NAME,
					FullDisplay_NAME,
					MemberSex_CODE,
					MemberSsn_NUMB,
					Birth_DATE,
					Emancipation_DATE,
					LastMarriage_DATE,
					LastDivorce_DATE,
					BirthCity_NAME,
					BirthState_CODE,
					BirthCountry_CODE,
					DescriptionHeight_TEXT,
					DescriptionWeightLbs_TEXT,
					Race_CODE,
					ColorHair_CODE,
					ColorEyes_CODE,
					FacialHair_INDC,
					Language_CODE,
					TypeProblem_CODE,
					Deceased_DATE,
					CerDeathNo_TEXT,
					LicenseDriverNo_TEXT,
					AlienRegistn_ID,
					WorkPermitNo_TEXT,
					BeginPermit_DATE,
					EndPermit_DATE,
					HomePhone_NUMB,
					WorkPhone_NUMB,
					CellPhone_NUMB,
					Fax_NUMB,
					Contact_EML,
					Spouse_NAME,
					Graduation_DATE,
					EducationLevel_CODE,
					Restricted_INDC,
					Military_ID,
					MilitaryBranch_CODE,
					MilitaryStatus_CODE,
					MilitaryBenefitStatus_CODE,
					SecondFamily_INDC,
					MeansTestedInc_INDC,
					SsIncome_INDC,
					VeteranComps_INDC,
					Disable_INDC,
					Assistance_CODE,
					DescriptionIdentifyingMarks_TEXT,
					Divorce_INDC,
					BeginValidity_DATE,
					EndValidity_DATE,
					WorkerUpdate_ID,
					TransactionEventSeq_NUMB,
					Update_DTTM,
					TypeOccupation_CODE,
					CountyBirth_IDNO,
					MotherMaiden_NAME,
					FileLastDivorce_ID,
					TribalAffiliations_CODE,
					FormerMci_IDNO,
					StateDivorce_CODE,
					CityDivorce_NAME,
					StateMarriage_CODE,
					CityMarriage_NAME,
					IveParty_IDNO
				)    
      WHERE MemberMci_IDNO = @An_MemberMci_IDNO; 
     
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;    
     
      SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;    
      
END;   --End Of DEMO_UPDATE_S11 


GO
