USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'IveParty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CityMarriage_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'StateMarriage_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CityDivorce_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'StateDivorce_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FormerMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TribalAffiliations_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FileLastDivorce_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MotherMaiden_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CountyBirth_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeOccupation_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Divorce_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionIdentifyingMarks_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Assistance_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Disable_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'VeteranComps_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'SsIncome_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MeansTestedInc_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'SecondFamily_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MilitaryBenefitStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MilitaryStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MilitaryBranch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Military_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Restricted_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'EducationLevel_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Graduation_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Spouse_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Contact_EML'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CellPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'HomePhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'EndPermit_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginPermit_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkPermitNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'AlienRegistn_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'LicenseDriverNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CerDeathNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Deceased_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeProblem_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Language_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FacialHair_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'ColorEyes_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'ColorHair_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionWeightLbs_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionHeight_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BirthCountry_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BirthState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BirthCity_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'LastDivorce_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'LastMarriage_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Emancipation_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FullDisplay_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Title_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Individual_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[MemberDemographicsHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MemberDemographicsHist_T1]
GO
/****** Object:  Table [dbo].[MemberDemographicsHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemberDemographicsHist_T1](
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
	[Disable_INDC] [char](1) NOT NULL,
	[Assistance_CODE] [char](3) NOT NULL,
	[DescriptionIdentifyingMarks_TEXT] [char](40) NOT NULL,
	[Divorce_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
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
	[IveParty_IDNO] [numeric](10, 0) NOT NULL,
 CONSTRAINT [HDEMO_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the system to the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family Court Unique ID assigned to the Member MCI. This value is informational in DECSS and is used when communicating with Family Court system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Individual_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the middle initial of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Suffix of the Member. Values are obtained from REFM (DEMO/SUFX)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Title of the Member. Values are obtained from REFM (GENR/TITL)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Title_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Full Display of the Members Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FullDisplay_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Gender of the Member. Values are obtained from REFM (GENR/GEND).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Members social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Members date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date the Member emancipates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Emancipation_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Last Marriage Date of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'LastMarriage_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Last Divorce Date of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'LastDivorce_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Members birth city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BirthCity_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify state where the child was born. Values are obtained from REFM (STAT/STAT)/ (STAT/CANA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BirthState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This selectable drop-down field is used to select the country. Values are obtained from REFM (CTRY/CTRY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BirthCountry_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the height of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionHeight_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the weight of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionWeightLbs_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the ethnic race of the Member. Values are obtained from REFM (GENR/RACE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the color of the member''s hair. Values are obtained from REFM (DEMO/HAIR)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'ColorHair_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to select the color of the member''s eyes. Values are obtained from REFM (DEMO/EYEC)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'ColorEyes_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member has got Facial Hair like Beard or Moustache. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FacialHair_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The language Member speaks. Values are obtained from REFM (GENR/LANG)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Language_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Members Problem Type. Values are obtained from REFM (HIPA/REGS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeProblem_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Deceased Date of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Deceased_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Death Certificate Number of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CerDeathNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Driver License Number of Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'LicenseDriverNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Alien Registration of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'AlienRegistn_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Work Permit Number of the Member. Column may be dropped in the subsequent technical design after review.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkPermitNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date from when the Work Permit is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginPermit_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Work Permit Expires.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'EndPermit_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the home phone number with area code of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'HomePhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the work phone number with area code of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the cell phone number with area code of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CellPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Fax Number of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Email Address of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Contact_EML'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Spouse name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Spouse_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Graduation Date of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Graduation_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Education Level of the Member. Values are obtained from REFM (DEMO/EDUC)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'EducationLevel_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member Information is Restricted or not. Values are obtained from REFM (CCRT/CONF)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Restricted_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Military ID of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Military_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Current Military Branch Code of the Member. Values are obtained from REFM (GENR/MILT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MilitaryBranch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Military Status of the Member. Values are obtained from REFM (GENR/MILS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MilitaryStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Military Benefit Status of the Member. Values are obtained from REFM (DEMO/BENS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MilitaryBenefitStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member has Second Family. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'SecondFamily_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member has Means Tested Income. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MeansTestedInc_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member has Supplement Security Income. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'SsIncome_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member has Veterans Compensated Work Therapy. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'VeteranComps_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member is Disabled or Not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Disable_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Assistance Code of the Member. Values are obtained from REFM (GENR/ASTS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Assistance_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Identifying Marks of the Member like Scar, Tattoo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionIdentifyingMarks_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to know whether the Member is Divorcee. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Divorce_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be  generated for a given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Occupation Type of the Member. Values are obtained from REFM (DEMO/OCCT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeOccupation_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Birth County of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CountyBirth_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Maiden Name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'MotherMaiden_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Last Divorce Docket Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FileLastDivorce_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the values for tribal affiliations that a case member may have. Values are obtained from REFM (CSNT/TRIB).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'TribalAffiliations_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates other MCIs that have been associated to the member, and have since been merged to the current MCI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'FormerMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the state associated with the address recorded on the screen. NOTE: Canadian Province Codes were taken from www.canadaonline.about.com. Values are obtained from REFM (STAT/STAT)/ (STAT/CANA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'StateDivorce_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'City where the member divorce happened' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CityDivorce_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the state associated with the address recorded on the screen. NOTE: Canadian Province Codes were taken from www.canadaonline.about.com. Values are obtained from REFM (STAT/STAT)/ (STAT/CANA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'StateMarriage_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'City where the member marriage happened' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'CityMarriage_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the PID of the member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1', @level2type=N'COLUMN',@level2name=N'IveParty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the history of the Member Demographic Information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDemographicsHist_T1'
GO
