USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceZipNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceStateNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceCityNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine2Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine1Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingZipNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingStateNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingCityNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine2Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine1Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDeceased_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpLicLiftEff_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpSuspLicEff_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MatchLevel_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaBirthNcp3_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaBirthNcp2_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaBirthNcp1_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcpSsn3_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcpSsn2_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcpSsn1_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixAkaNcp3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcp3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixAkaNcp2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcp2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixAkaNcp1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcp1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpAka_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDmvSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDmvSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDriversLicenseType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDmvDriversLicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'DmvBirthNcp_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceZipNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceStateNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceCityNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine2NcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine1NcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingZipNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingStateNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingCityNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine2NcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine1NcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Ncp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Source_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDriversLicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'BirthNcp_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadDmv_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadDmv_T1]
GO
/****** Object:  Table [dbo].[LoadDmv_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadDmv_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](1) NOT NULL,
	[LastNcp_NAME] [char](12) NOT NULL,
	[FirstNcp_NAME] [char](11) NOT NULL,
	[MiddleNcp_NAME] [char](1) NOT NULL,
	[BirthNcp_DATE] [char](8) NOT NULL,
	[NcpDriversLicenseNo_TEXT] [char](12) NOT NULL,
	[NcpSsn_NUMB] [char](9) NOT NULL,
	[NcpSex_CODE] [char](1) NOT NULL,
	[NcpMemberMci_IDNO] [char](10) NOT NULL,
	[Source_CODE] [char](2) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Ncp_NAME] [char](32) NOT NULL,
	[SuffixNcp_NAME] [char](3) NOT NULL,
	[MailingLine1NcpOld_ADDR] [char](21) NOT NULL,
	[MailingLine2NcpOld_ADDR] [char](21) NOT NULL,
	[MailingCityNcpOld_ADDR] [char](15) NOT NULL,
	[MailingStateNcpOld_ADDR] [char](2) NOT NULL,
	[MailingZipNcpOld_ADDR] [char](9) NOT NULL,
	[ResidenceLine1NcpOld_ADDR] [char](21) NOT NULL,
	[ResidenceLine2NcpOld_ADDR] [char](21) NOT NULL,
	[ResidenceCityNcpOld_ADDR] [char](15) NOT NULL,
	[ResidenceStateNcpOld_ADDR] [char](2) NOT NULL,
	[ResidenceZipNcpOld_ADDR] [char](9) NOT NULL,
	[DmvBirthNcp_DATE] [char](8) NOT NULL,
	[NcpDmvDriversLicenseNo_TEXT] [char](8) NOT NULL,
	[NcpDriversLicenseType_CODE] [char](2) NOT NULL,
	[NcpDmvSsn_NUMB] [char](9) NOT NULL,
	[NcpDmvSex_CODE] [char](1) NOT NULL,
	[NcpAka_INDC] [char](1) NOT NULL,
	[AkaNcp1_NAME] [char](32) NOT NULL,
	[SuffixAkaNcp1_NAME] [char](3) NOT NULL,
	[AkaNcp2_NAME] [char](32) NOT NULL,
	[SuffixAkaNcp2_NAME] [char](3) NOT NULL,
	[AkaNcp3_NAME] [char](32) NOT NULL,
	[SuffixAkaNcp3_NAME] [char](3) NOT NULL,
	[AkaNcpSsn1_NUMB] [char](9) NOT NULL,
	[AkaNcpSsn2_NUMB] [char](9) NOT NULL,
	[AkaNcpSsn3_NUMB] [char](9) NOT NULL,
	[AkaBirthNcp1_DATE] [char](8) NOT NULL,
	[AkaBirthNcp2_DATE] [char](8) NOT NULL,
	[AkaBirthNcp3_DATE] [char](8) NOT NULL,
	[MatchLevel_CODE] [char](1) NOT NULL,
	[NcpSuspLicEff_DATE] [char](8) NOT NULL,
	[NcpLicLiftEff_DATE] [char](8) NOT NULL,
	[NcpDeceased_TEXT] [char](13) NOT NULL,
	[MailingAddressNormalization_CODE] [char](1) NOT NULL,
	[MailingLine1Ncp_ADDR] [varchar](50) NOT NULL,
	[MailingLine2Ncp_ADDR] [varchar](50) NOT NULL,
	[MailingCityNcp_ADDR] [char](28) NOT NULL,
	[MailingStateNcp_ADDR] [char](2) NOT NULL,
	[MailingZipNcp_ADDR] [char](15) NOT NULL,
	[ResidenceAddressNormalization_CODE] [char](1) NOT NULL,
	[ResidenceLine1Ncp_ADDR] [varchar](50) NOT NULL,
	[ResidenceLine2Ncp_ADDR] [varchar](50) NOT NULL,
	[ResidenceCityNcp_ADDR] [char](28) NOT NULL,
	[ResidenceStateNcp_ADDR] [char](2) NOT NULL,
	[ResidenceZipNcp_ADDR] [char](15) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
 CONSTRAINT [LDMVL_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Record Sequence Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Record type indicator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP middle name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP birth date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'BirthNcp_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP driver license number in the system' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDriversLicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP SSN number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP sex code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Source code represents the source agency from where the request was sent. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Source_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the drivers license matches the DMV license details, suspended or lifted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Ncp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP name suffix' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address Line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine1NcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address Line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine2NcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingCityNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingStateNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address zip' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingZipNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address line-1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine1NcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address line-2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine2NcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceCityNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceStateNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address zip' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceZipNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP birth date from DMV' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'DmvBirthNcp_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP driver’s license from DMV' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDmvDriversLicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP driver’s license type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDriversLicenseType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Social Security Number from DMV' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDmvSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP sex code from DMV' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDmvSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies whether alias information exist or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpAka_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP alias name 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcp1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP alias name suffix 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixAkaNcp1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP alias name 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcp2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP alias name suffix 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixAkaNcp2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP alias name 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcp3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP alias name suffix 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'SuffixAkaNcp3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP alias Social Security Number1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcpSsn1_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP AKA Social Security number2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcpSsn2_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP AKA Social Security Number3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaNcpSsn3_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP AKA date of birth 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaBirthNcp1_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP AKA date of birth 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaBirthNcp2_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP AKA date of birth 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'AkaBirthNcp3_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the NCP information match level with DMV records' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MatchLevel_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP license suspension effective date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpSuspLicEff_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP license suspension lifts effective date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpLicLiftEff_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP deceased free form text. This column is unused in our system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'NcpDeceased_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalization Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address Line 1 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine1Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address Line 2 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingLine2Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address city after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingCityNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address state after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingStateNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP mail address zip after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'MailingZipNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalization Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address line-1 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine1Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address line-2 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceLine2Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address city after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceCityNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address state after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceStateNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP residence address zip after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'ResidenceZipNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Process indicator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'File loaded date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used as staging table to load DMV incoming file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDmv_T1'
GO
