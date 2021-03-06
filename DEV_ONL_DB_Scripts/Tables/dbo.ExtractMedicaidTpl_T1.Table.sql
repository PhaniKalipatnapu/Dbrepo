USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Payment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Payment_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NonCooperation_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'XixCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'IveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpZipSuffix_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'ZipNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'StateNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CityNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line2Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line1Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpZipSuffix_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'BirthCp_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'MiddleCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsCarrier_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZipSuffix_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'StatusRecord_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Origin_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Coverage_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuranceGroupNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'PolicyInsNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'ZipCp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'StateCp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CityCp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line2Cp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line1Cp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'BirthInsured_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'SuffixInsured_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'MiddleInsured_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstInsured_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastInsured_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'TypeRecord_CODE'

GO
/****** Object:  Table [dbo].[ExtractMedicaidTpl_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractMedicaidTpl_T1]
GO
/****** Object:  Table [dbo].[ExtractMedicaidTpl_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractMedicaidTpl_T1](
	[TypeRecord_CODE] [char](2) NOT NULL,
	[InsuredMemberMci_IDNO] [char](10) NOT NULL,
	[LastInsured_NAME] [char](30) NOT NULL,
	[FirstInsured_NAME] [char](20) NOT NULL,
	[MiddleInsured_NAME] [char](1) NOT NULL,
	[SuffixInsured_NAME] [char](4) NOT NULL,
	[InsuredMemberSsn_NUMB] [char](9) NOT NULL,
	[BirthInsured_DATE] [char](8) NOT NULL,
	[InsuredMemberSex_CODE] [char](1) NOT NULL,
	[Line1Cp_ADDR] [char](25) NOT NULL,
	[Line2Cp_ADDR] [char](25) NOT NULL,
	[CityCp_ADDR] [char](20) NOT NULL,
	[StateCp_ADDR] [char](2) NOT NULL,
	[ZipCp_ADDR] [char](9) NOT NULL,
	[PolicyInsNo_TEXT] [char](18) NOT NULL,
	[InsuranceGroupNo_TEXT] [char](17) NOT NULL,
	[Coverage_CODE] [char](3) NOT NULL,
	[InsHolderLast_NAME] [char](30) NOT NULL,
	[InsHolderFirst_NAME] [char](20) NOT NULL,
	[InsHolderMiddle_NAME] [char](1) NOT NULL,
	[InsHolderMemberSsn_NUMB] [char](9) NOT NULL,
	[InsHolderLine1_ADDR] [char](25) NOT NULL,
	[InsHolderLine2_ADDR] [char](25) NOT NULL,
	[InsHolderCity_ADDR] [char](20) NOT NULL,
	[InsHolderState_ADDR] [char](2) NOT NULL,
	[InsHolderZip_ADDR] [char](9) NOT NULL,
	[InsHolderBirth_DATE] [char](8) NOT NULL,
	[InsHolderSex_CODE] [char](1) NOT NULL,
	[Begin_DATE] [char](8) NOT NULL,
	[End_DATE] [char](8) NOT NULL,
	[Origin_CODE] [char](1) NOT NULL,
	[StatusRecord_CODE] [char](1) NOT NULL,
	[InsHolderEmployer_NAME] [char](25) NOT NULL,
	[InsHolderEmpLine1_ADDR] [char](25) NOT NULL,
	[InsHolderEmpLine2_ADDR] [char](25) NOT NULL,
	[InsHolderEmpCity_ADDR] [char](20) NOT NULL,
	[InsHolderEmpState_ADDR] [char](2) NOT NULL,
	[InsHolderEmpZip_ADDR] [char](5) NOT NULL,
	[InsHolderEmpZipSuffix_ADDR] [char](4) NOT NULL,
	[InsCarrier_NAME] [varchar](45) NOT NULL,
	[LastCp_NAME] [char](30) NOT NULL,
	[FirstCp_NAME] [char](20) NOT NULL,
	[MiddleCp_NAME] [char](1) NOT NULL,
	[CpSsn_NUMB] [char](9) NOT NULL,
	[BirthCp_DATE] [char](8) NOT NULL,
	[CpSex_CODE] [char](1) NOT NULL,
	[CpEmployer_NAME] [char](25) NOT NULL,
	[CpEmpLine1_ADDR] [char](25) NOT NULL,
	[CpEmpLine2_ADDR] [char](25) NOT NULL,
	[CpEmpCity_ADDR] [char](20) NOT NULL,
	[CpEmpState_ADDR] [char](2) NOT NULL,
	[CpEmpZip_ADDR] [char](5) NOT NULL,
	[CpEmpZipSuffix_ADDR] [char](4) NOT NULL,
	[LastNcp_NAME] [char](30) NOT NULL,
	[FirstNcp_NAME] [char](20) NOT NULL,
	[MiddleNcp_NAME] [char](1) NOT NULL,
	[NcpSsn_NUMB] [char](9) NOT NULL,
	[Line1Ncp_ADDR] [char](25) NOT NULL,
	[Line2Ncp_ADDR] [char](25) NOT NULL,
	[CityNcp_ADDR] [char](20) NOT NULL,
	[StateNcp_ADDR] [char](2) NOT NULL,
	[ZipNcp_ADDR] [char](9) NOT NULL,
	[NcpEmployer_NAME] [char](25) NOT NULL,
	[NcpEmpLine1_ADDR] [char](25) NOT NULL,
	[NcpEmpLine2_ADDR] [char](25) NOT NULL,
	[NcpEmpCity_ADDR] [char](20) NOT NULL,
	[NcpEmpState_ADDR] [char](2) NOT NULL,
	[NcpEmpZip_ADDR] [char](5) NOT NULL,
	[NcpEmpZipSuffix_ADDR] [char](4) NOT NULL,
	[CaseWelfare_IDNO] [char](10) NOT NULL,
	[IveCase_IDNO] [char](10) NOT NULL,
	[XixCase_IDNO] [char](10) NOT NULL,
	[NonCooperation_INDC] [char](1) NOT NULL,
	[Payment_INDC] [char](1) NOT NULL,
	[Disburse_AMNT] [char](11) NOT NULL,
	[Payment_DATE] [char](8) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'TPL Detail record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'TypeRecord_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Covered child MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Covered child last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastInsured_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Covered child first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstInsured_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Covered Child Middle initial' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'MiddleInsured_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Covered Child suffix name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'SuffixInsured_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Covered child social security number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Covered child date of birth' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'BirthInsured_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Covered child sex code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line1Cp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line2Cp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CityCp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'StateCp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP address zip code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'ZipCp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder medical insurance policy number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'PolicyInsNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder medical insurance group number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuranceGroupNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Coverage type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Coverage_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder middle initial' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder social security number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder address zip code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder date of birth' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder sex code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder policy effective date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder policy termination date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'TPL origination ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Origin_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'TPL detailed record status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'StatusRecord_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder employer name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder employer street address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder employer street address  line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder employer address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder employer address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder employer address zip code1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder employer zip code2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZipSuffix_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy holder insurance carrier name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsCarrier_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP middle initial' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'MiddleCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP social security number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP date of birth' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'BirthCp_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP sex code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP employer name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP employer street address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP employer street address  line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP employer address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP employer address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP employer address zip code1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CP employer zip code2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CpEmpZipSuffix_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP middle initial' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP social security number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line1Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Line2Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CityNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'StateNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP address zip code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'ZipNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP employer name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP employer street address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP employer street address  line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP employer address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP employer address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP employer address zip code1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP employer zip code2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpZipSuffix_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Welfare Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Foster Care Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'IveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Title XIX Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'XixCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Non-Cooperation Indicator ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'NonCooperation_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if a payment has been disbursed to the Non IV-A, Title XIX recipient for Medicaid support' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Payment_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The dollar amount disbursed to the Non IV-A, Title XIX recipient for Medicaid support' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date the last payment towards Medicaid was disbursed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Payment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store information about the active members who have health insurance ordered and insurance details available from the system’s database to send file to Medicaid' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractMedicaidTpl_T1'
GO
