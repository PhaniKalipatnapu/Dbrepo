USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[MemberDemographicsSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MemberDemographicsSC_T1]
GO
/****** Object:  Table [dbo].[MemberDemographicsSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemberDemographicsSC_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Individual_IDNO] [numeric](8, 0) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](20) NOT NULL,
	[Suffix_NAME] [char](4) NOT NULL,
	[Title_NAME] [char](8) NOT NULL,
	[FullDisplay_NAME] [varchar](60) NOT NULL,
	[MemberSex_CODE] [char](1) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[Birth_DATE] [date] NOT NULL,
	[Emancipation_DATE] [date] NOT NULL,
	[LastMarriage_DATE] [date] NOT NULL,
	[LastDivorce_DATE] [date] NOT NULL,
	[BirthCity_NAME] [char](28) NOT NULL,
	[BirthState_CODE] [char](2) NOT NULL,
	[BirthCountry_CODE] [char](2) NOT NULL,
	[DescriptionHeight_TEXT] [char](3) NOT NULL,
	[DescriptionWeightLbs_TEXT] [char](3) NOT NULL,
	[Race_CODE] [char](1) NOT NULL,
	[ColorHair_CODE] [char](3) NOT NULL,
	[ColorEyes_CODE] [char](3) NOT NULL,
	[FacialHair_INDC] [char](1) NOT NULL,
	[Language_CODE] [char](3) NOT NULL,
	[TypeProblem_CODE] [char](3) NOT NULL,
	[Deceased_DATE] [date] NOT NULL,
	[CerDeathNo_TEXT] [char](9) NOT NULL,
	[LicenseDriverNo_TEXT] [char](25) NOT NULL,
	[AlienRegistn_ID] [char](10) NOT NULL,
	[WorkPermitNo_TEXT] [char](10) NOT NULL,
	[BeginPermit_DATE] [date] NOT NULL,
	[EndPermit_DATE] [date] NOT NULL,
	[HomePhone_NUMB] [numeric](15, 0) NOT NULL,
	[WorkPhone_NUMB] [numeric](15, 0) NOT NULL,
	[CellPhone_NUMB] [numeric](15, 0) NOT NULL,
	[Fax_NUMB] [numeric](15, 0) NOT NULL,
	[Contact_EML] [varchar](100) NOT NULL,
	[Spouse_NAME] [char](40) NOT NULL,
	[Graduation_DATE] [date] NOT NULL,
	[EducationLevel_CODE] [char](2) NOT NULL,
	[Restricted_INDC] [char](1) NOT NULL,
	[Military_ID] [char](10) NOT NULL,
	[MilitaryBranch_CODE] [char](2) NOT NULL,
	[MilitaryStatus_CODE] [char](2) NOT NULL,
	[MilitaryBenefitStatus_CODE] [char](2) NOT NULL,
	[SecondFamily_INDC] [char](1) NOT NULL,
	[MeansTestedInc_INDC] [char](1) NOT NULL,
	[SsIncome_INDC] [char](1) NOT NULL,
	[VeteranComps_INDC] [char](1) NOT NULL,
	[Assistance_CODE] [char](3) NOT NULL,
	[DescriptionIdentifyingMarks_TEXT] [char](40) NOT NULL,
	[Divorce_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[Disable_INDC] [char](1) NOT NULL,
	[TypeOccupation_CODE] [char](3) NOT NULL,
	[CountyBirth_IDNO] [numeric](3, 0) NOT NULL,
	[MotherMaiden_NAME] [char](30) NOT NULL,
	[FileLastDivorce_ID] [char](15) NOT NULL,
	[TribalAffiliations_CODE] [char](3) NOT NULL,
	[FormerMci_IDNO] [numeric](10, 0) NOT NULL,
	[StateDivorce_CODE] [char](2) NOT NULL,
	[CityDivorce_NAME] [char](28) NOT NULL,
	[StateMarriage_CODE] [char](2) NOT NULL,
	[CityMarriage_NAME] [char](28) NOT NULL,
	[IveParty_IDNO] [numeric](10, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
