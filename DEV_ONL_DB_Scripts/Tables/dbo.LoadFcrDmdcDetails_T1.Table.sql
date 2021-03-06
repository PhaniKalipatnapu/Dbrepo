USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageCp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathCp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedCp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoveragePf_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathPf_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'PfMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedPf_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'PfSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastPf_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddlePf_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstPf_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageNcp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathNcp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedNcp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'EndCoverageCh_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'BeginCoverageCh_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageSponsorCh_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageCh_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathCh_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'ChildMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedCh_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'ChildSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastCh_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddledCh_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstCh_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Order_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'StateTransmitter_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFcrDmdcDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFcrDmdcDetails_T1]
GO
/****** Object:  Table [dbo].[LoadFcrDmdcDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFcrDmdcDetails_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](2) NOT NULL,
	[StateTransmitter_CODE] [char](2) NOT NULL,
	[County_IDNO] [char](3) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[Order_INDC] [char](1) NOT NULL,
	[FirstCh_NAME] [char](16) NOT NULL,
	[MiddledCh_NAME] [char](16) NOT NULL,
	[LastCh_NAME] [char](30) NOT NULL,
	[ChildSsn_NUMB] [char](9) NOT NULL,
	[SsnVerifiedCh_INDC] [char](1) NOT NULL,
	[ChildMCI_IDNO] [char](15) NOT NULL,
	[DeathCh_INDC] [char](1) NOT NULL,
	[MedCoverageCh_INDC] [char](1) NOT NULL,
	[MedCoverageSponsorCh_INDC] [char](1) NOT NULL,
	[BeginCoverageCh_DATE] [char](8) NOT NULL,
	[EndCoverageCh_DATE] [char](8) NOT NULL,
	[FirstNcp_NAME] [char](16) NOT NULL,
	[MiddleNcp_NAME] [char](16) NOT NULL,
	[LastNcp_NAME] [char](30) NOT NULL,
	[NcpSsn_NUMB] [char](9) NOT NULL,
	[SsnVerifiedNcp_INDC] [char](1) NOT NULL,
	[NcpMci_IDNO] [char](15) NOT NULL,
	[DeathNcp_INDC] [char](1) NOT NULL,
	[MedCoverageNcp_INDC] [char](1) NOT NULL,
	[FirstPf_NAME] [char](16) NOT NULL,
	[MiddlePf_NAME] [char](16) NOT NULL,
	[LastPf_NAME] [char](30) NOT NULL,
	[PfSsn_NUMB] [char](9) NOT NULL,
	[SsnVerifiedPf_INDC] [char](1) NOT NULL,
	[PfMci_IDNO] [char](15) NOT NULL,
	[DeathPf_INDC] [char](1) NOT NULL,
	[MedCoveragePf_INDC] [char](1) NOT NULL,
	[FirstCp_NAME] [char](16) NOT NULL,
	[MiddleCp_NAME] [char](16) NOT NULL,
	[LastCp_NAME] [char](30) NOT NULL,
	[CpSsn_NUMB] [char](9) NOT NULL,
	[SsnVerifiedCp_INDC] [char](1) NOT NULL,
	[CpMci_IDNO] [char](15) NOT NULL,
	[DeathCp_INDC] [char](1) NOT NULL,
	[MedCoverageCp_INDC] [char](1) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
 CONSTRAINT [LFDMD_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies DMDC Record FW.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the two-digit numeric FIPS Code of the State or territory that is transmitting data to, or receiving data from, the FCR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'StateTransmitter_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Order indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Order_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child first Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstCh_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child Middle name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddledCh_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastCh_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'ChildSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child SSN verification indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedCh_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child member id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'ChildMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child Death indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathCh_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child Medical coverage indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageCh_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Child''s medical coverage sponsor.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageSponsorCh_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child Medical coverage begin date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'BeginCoverageCh_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child Medical coverage End date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'EndCoverageCh_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP SSN Verification indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedNcp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Member id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Death indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathNcp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Medical coverage Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageNcp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Putative Father First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstPf_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Putative Father Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddlePf_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Putative Father last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastPf_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Putative father SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'PfSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'SSN verification indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedPf_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Putative father member id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'PfMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Putative father Death indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathPf_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Putative Father Medical coverage Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoveragePf_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client (CP) First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'LastCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client SSN verification Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'SsnVerifiedCp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client Member id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client Death indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathCp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Client Medical coverage indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'MedCoverageCp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file from Family court is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store Defense Manpower Data Center details (Insurance details)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrDmdcDetails_T1'
GO
