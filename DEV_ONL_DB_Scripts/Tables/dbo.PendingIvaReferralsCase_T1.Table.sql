USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'ReferralProcess_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'ReasonForPending_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'WelfareCaseCounty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'IntactFamilyStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'ReferralReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
/****** Object:  Table [dbo].[PendingIvaReferralsCase_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PendingIvaReferralsCase_T1]
GO
/****** Object:  Table [dbo].[PendingIvaReferralsCase_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingIvaReferralsCase_T1](
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[AgSequence_NUMB] [numeric](4, 0) NOT NULL,
	[ReferralReceived_DATE] [date] NOT NULL,
	[StatusCase_CODE] [char](1) NOT NULL,
	[IntactFamilyStatus_CODE] [char](1) NOT NULL,
	[WelfareCaseCounty_IDNO] [numeric](3, 0) NOT NULL,
	[ReasonForPending_CODE] [char](2) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[ReferralProcess_CODE] [char](1) NOT NULL,
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [PRCA_I1] PRIMARY KEY CLUSTERED 
(
	[CaseWelfare_IDNO] ASC,
	[AgSequence_NUMB] ASC,
	[ReferralReceived_DATE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies Welfare Case Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Stores DSS Assistance Group Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Referral received date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'ReferralReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Welfare case status. Values are obtained from REFM (CSTS/CSTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Indicator to identify if NCP is member of the house hold. Values will be determined in the subsequent technical designs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'IntactFamilyStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Welfare Case County.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'WelfareCaseCounty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason for referral pending. Values are obtained from REFM (PEND/PEND)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'ReasonForPending_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the worker last updated the record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last date and time the record modified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the status of the referral record. Possible values are ''P''- Processed, ''N''-Not Processed and ''D'' - Deleted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'ReferralProcess_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID assigned to the Application.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the case level details of the pending referrals.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsCase_T1'
GO
