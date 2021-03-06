USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'SourceVerify_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'TypePrimary_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'Enumeration_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Index [MSSN_SSN_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [MSSN_SSN_I1] ON [dbo].[MemberSsn_T1]
GO
/****** Object:  Index [MSSN_MCI_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [MSSN_MCI_I1] ON [dbo].[MemberSsn_T1]
GO
/****** Object:  Table [dbo].[MemberSsn_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MemberSsn_T1]
GO
/****** Object:  Table [dbo].[MemberSsn_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemberSsn_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[Enumeration_CODE] [char](1) NOT NULL,
	[TypePrimary_CODE] [char](1) NOT NULL,
	[SourceVerify_CODE] [char](3) NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [MSSN_I1] PRIMARY KEY CLUSTERED 
(
	[MemberSsn_NUMB] ASC,
	[MemberMci_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [MSSN_MCI_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [MSSN_MCI_I1] ON [dbo].[MemberSsn_T1]
(
	[MemberMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [MSSN_SSN_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [MSSN_SSN_I1] ON [dbo].[MemberSsn_T1]
(
	[MemberSsn_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique System generated Id for the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicates the Members SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Verification Code Received for SSN Verification. Values are obtained from REFM (CONF/CON1).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'Enumeration_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether this is the Primary SSN of the Member. Values are obtained from REFM (DEMO/SSNT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'TypePrimary_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Verification Source. Values are obtained from REFM (DEMO/VERS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'SourceVerify_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the SSN was verified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the member''s SSN details with different types.  This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberSsn_T1'
GO
