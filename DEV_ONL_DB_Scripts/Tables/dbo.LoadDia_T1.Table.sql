USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimLoss_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerClaim_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Insurer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'DiaInsurer_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'DiaCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsuranceMatchRecord_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadDia_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadDia_T1]
GO
/****** Object:  Table [dbo].[LoadDia_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadDia_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[InsuranceMatchRecord_NUMB] [char](6) NOT NULL,
	[DiaCase_IDNO] [char](10) NOT NULL,
	[DiaInsurer_IDNO] [char](4) NOT NULL,
	[Insurer_NAME] [varchar](50) NOT NULL,
	[InsurerLine1Old_ADDR] [char](30) NOT NULL,
	[InsurerLine2Old_ADDR] [char](30) NOT NULL,
	[InsurerCityOld_ADDR] [char](28) NOT NULL,
	[InsurerStateOld_ADDR] [char](2) NOT NULL,
	[InsurerZipOld_ADDR] [char](10) NOT NULL,
	[InsurerClaim_NUMB] [char](30) NOT NULL,
	[ClaimLoss_DATE] [char](8) NOT NULL,
	[First_NAME] [char](20) NOT NULL,
	[Middle_NAME] [char](5) NOT NULL,
	[Last_NAME] [char](30) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[ClaimantLine1Old_ADDR] [varchar](50) NOT NULL,
	[ClaimantLine2Old_ADDR] [varchar](50) NOT NULL,
	[ClaimantCityOld_ADDR] [char](28) NOT NULL,
	[ClaimantStateOld_ADDR] [char](2) NOT NULL,
	[ClaimantZipOld_ADDR] [char](10) NOT NULL,
	[Employer_NAME] [varchar](60) NOT NULL,
	[EmployerLine1Old_ADDR] [varchar](50) NOT NULL,
	[EmployerLine2Old_ADDR] [varchar](50) NOT NULL,
	[EmployerCityOld_ADDR] [char](28) NOT NULL,
	[EmployerStateOld_ADDR] [char](2) NOT NULL,
	[EmployerZipOld_ADDR] [char](10) NOT NULL,
	[InsurerAddressNormalization_CODE] [char](1) NOT NULL,
	[InsurerLine1_ADDR] [varchar](50) NOT NULL,
	[InsurerLine2_ADDR] [varchar](50) NOT NULL,
	[InsurerCity_ADDR] [char](28) NOT NULL,
	[InsurerState_ADDR] [char](2) NOT NULL,
	[InsurerZip_ADDR] [char](15) NOT NULL,
	[ClaimantAddressNormalization_CODE] [char](1) NOT NULL,
	[ClaimantLine1_ADDR] [varchar](50) NOT NULL,
	[ClaimantLine2_ADDR] [varchar](50) NOT NULL,
	[ClaimantCity_ADDR] [char](28) NOT NULL,
	[ClaimantState_ADDR] [char](2) NOT NULL,
	[ClaimantZip_ADDR] [char](15) NOT NULL,
	[EmployerAddressNormalization_CODE] [char](1) NOT NULL,
	[EmployerLine1_ADDR] [varchar](50) NOT NULL,
	[EmployerLine2_ADDR] [varchar](50) NOT NULL,
	[EmployerCity_ADDR] [char](28) NOT NULL,
	[EmployerState_ADDR] [char](2) NOT NULL,
	[EmployerZip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LDIAL_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies record uniquely.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the sequence of an Insurance match records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsuranceMatchRecord_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the DIA Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'DiaCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Insurer ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'DiaInsurer_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Insurer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer line2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer claim number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerClaim_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer claim loss date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimLoss_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant first name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant middle name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant SSN number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant line2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer line2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer address normalized code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer normalized line 1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer normalized line 2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer normalized city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer normalized state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Insurer normalized zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'InsurerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant address normalized code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant normalized line 1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant normalized line 2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant normalized city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant normalized state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Claimant normalized zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'ClaimantZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer address normalized code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer normalized line 1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer normalized line 2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer normalized city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer normalized state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Employer normalized zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the status of the process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Loads the Workmen’s compensation data received from Division of Industrial Affairs (DIA) into temporary load table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDia_T1'
GO
