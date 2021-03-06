USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'ReferralReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
/****** Object:  Table [dbo].[PendingIvaReferralsEhis_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PendingIvaReferralsEhis_T1]
GO
/****** Object:  Table [dbo].[PendingIvaReferralsEhis_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingIvaReferralsEhis_T1](
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[AgSequence_NUMB] [numeric](4, 0) NOT NULL,
	[ReferralReceived_DATE] [date] NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Employer_NAME] [varchar](60) NOT NULL,
	[Fein_IDNO] [numeric](9, 0) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
 CONSTRAINT [PREH_I1] PRIMARY KEY CLUSTERED 
(
	[CaseWelfare_IDNO] ASC,
	[AgSequence_NUMB] ASC,
	[ReferralReceived_DATE] ASC,
	[MemberMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies Welfare Case Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Stores DSS Assistance Group Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Referral received date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'ReferralReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Welfare Child MCI Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores DSS Client’s employer name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies DSS Client’s employer EIN number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores DSS Client’s employer address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores DSS Client’s employer address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores DSS Client’s employer address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores DSS Client’s employer address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores DSS Client’s employer address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the employer details of the pending referrals.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsEhis_T1'
GO
