USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpAddrNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyInfoModify_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyInfoAdd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderRelationship_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyVerification_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderFull_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyLocation_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyCarrier_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Coverage_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuranceGroupNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'PolicyInsNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstInsured_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastInsured_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'BirthInsured_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[LoadMedicaidTpl_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadMedicaidTpl_T1]
GO
/****** Object:  Table [dbo].[LoadMedicaidTpl_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadMedicaidTpl_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Case_IDNO] [char](10) NULL,
	[InsuredMemberSsn_NUMB] [char](9) NOT NULL,
	[BirthInsured_DATE] [char](8) NOT NULL,
	[LastInsured_NAME] [char](20) NULL,
	[FirstInsured_NAME] [char](16) NOT NULL,
	[InsHolderMemberSsn_NUMB] [char](9) NOT NULL,
	[PolicyInsNo_TEXT] [char](18) NOT NULL,
	[InsuranceGroupNo_TEXT] [char](17) NOT NULL,
	[Coverage_CODE] [char](4) NULL,
	[Begin_DATE] [char](8) NOT NULL,
	[End_DATE] [char](8) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[InsuredMemberMci_IDNO] [char](10) NULL,
	[InsCompanyCarrier_CODE] [char](5) NOT NULL,
	[InsCompanyLocation_CODE] [char](4) NOT NULL,
	[InsHolderFull_NAME] [char](35) NULL,
	[InsHolderBirth_DATE] [char](8) NULL,
	[InsHolderMemberMci_IDNO] [char](10) NULL,
	[InsPolicyStatus_CODE] [char](1) NULL,
	[InsPolicyVerification_INDC] [char](1) NULL,
	[InsHolderRelationship_CODE] [char](2) NULL,
	[InsHolderEmployer_NAME] [char](25) NOT NULL,
	[InsHolderEmpLine1Old_ADDR] [char](25) NOT NULL,
	[InsHolderEmpLine2Old_ADDR] [char](25) NOT NULL,
	[InsHolderEmpCityOld_ADDR] [char](20) NOT NULL,
	[InsHolderEmpStateOld_ADDR] [char](2) NULL,
	[InsHolderEmpZipOld_ADDR] [char](15) NULL,
	[InsPolicyInfoAdd_DATE] [char](8) NULL,
	[InsPolicyInfoModify_DATE] [char](8) NULL,
	[InsHolderEmpAddrNormalization_CODE] [char](1) NULL,
	[InsHolderEmpLine1_ADDR] [varchar](50) NULL,
	[InsHolderEmpLine2_ADDR] [varchar](50) NULL,
	[InsHolderEmpCity_ADDR] [char](28) NULL,
	[InsHolderEmpState_ADDR] [char](2) NULL,
	[InsHolderEmpZip_ADDR] [char](15) NULL,
 CONSTRAINT [LMTPL_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Case ID associated with the record being viewed on the CASE Screen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Insured member social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date of birth of the insured member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'BirthInsured_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the insured member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'LastInsured_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the insured member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'FirstInsured_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the insurance holder social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy number of the Holders Insurance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'PolicyInsNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Group number of the Holders Insurance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuranceGroupNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates insurance coverage type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Coverage_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance begin date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance end date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Dependent MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsuredMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance company carrier code ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyCarrier_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance company location code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyLocation_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Full name of the person providing the insurance coverage for the dependent' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderFull_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'DOB of the person providing the insurance coverage for the dependent' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies MCI  of the person providing the insurance coverage for the dependent' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Policy Status – Active, Inactive, Error' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Policy Verification status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyVerification_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Relationship of the dependent on record to the coverage provider. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderRelationship_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name/company name of employer. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First line for the street address of an employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Second line for the street address of an employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'City where an employer is located.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State where an employer is located.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Zip code where an employer is located.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date that a policy data/  information was added to the MMIS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyInfoAdd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date the a policy data/  information was last changed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyInfoModify_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalization Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpAddrNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance Holder''s Employer Address Line 1 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance Holder''s Employer Address Line 2 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance Holder''s Employer City Address after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance Holder''s Employer State Address after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance Holder''s Employer Zip Address after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1', @level2type=N'COLUMN',@level2name=N'InsHolderEmpZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used by BATCH_ENF_INCOMING_MEDICAID_TPL - TPL Load and Process batch programs to load the Insurance file given by Medicaid agency into DECSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadMedicaidTpl_T1'
GO
