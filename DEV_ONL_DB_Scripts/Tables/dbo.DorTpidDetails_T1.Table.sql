USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'OwnerShipType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'SuffixSsnNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'TaxPayor_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[DorTpidDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[DorTpidDetails_T1]
GO
/****** Object:  Table [dbo].[DorTpidDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DorTpidDetails_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[LicenseNo_TEXT] [char](25) NOT NULL,
	[TaxPayor_ID] [char](10) NOT NULL,
	[SuffixSsnNo_TEXT] [char](3) NOT NULL,
	[OwnerShipType_CODE] [char](2) NOT NULL,
 CONSTRAINT [DSPT_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[LicenseNo_TEXT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the System to the Participants.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicates the License Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Tax Payor ID with Prefix SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'TaxPayor_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Tax Payor Suffix SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'SuffixSsnNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Ownership Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1', @level2type=N'COLUMN',@level2name=N'OwnerShipType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores the Tax payer Information for the lincenses.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DorTpidDetails_T1'
GO
