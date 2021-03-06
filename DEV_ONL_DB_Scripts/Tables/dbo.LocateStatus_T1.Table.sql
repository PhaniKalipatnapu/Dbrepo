USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'ReferLocate_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocDateOfBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocSsn_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocEmpr_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocAddr_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Asset_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'StatusLocate_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'License_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Ssn_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Employer_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Address_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocate_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'StatusLocate_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[LocateStatus_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LocateStatus_T1]
GO
/****** Object:  Table [dbo].[LocateStatus_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LocateStatus_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[StatusLocate_CODE] [char](1) NOT NULL,
	[BeginLocate_DATE] [date] NOT NULL,
	[Address_INDC] [char](1) NOT NULL,
	[Employer_INDC] [char](1) NOT NULL,
	[Ssn_INDC] [char](1) NOT NULL,
	[License_INDC] [char](1) NOT NULL,
	[StatusLocate_DATE] [date] NOT NULL,
	[Asset_INDC] [char](1) NOT NULL,
	[SourceLoc_CODE] [char](3) NOT NULL,
	[BeginLocAddr_DATE] [date] NOT NULL,
	[BeginLocEmpr_DATE] [date] NOT NULL,
	[BeginLocSsn_DATE] [date] NOT NULL,
	[BeginLocDateOfBirth_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ReferLocate_INDC] [char](1) NOT NULL,
 CONSTRAINT [LSTT_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[StatusLocate_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'A unique number assigned to each participant in the system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The code that identifies the status of the locate activity. Values are obtained from REFM (LOCS/LOCS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'StatusLocate_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the locate activity was originally initiated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocate_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates whether the address of a member is located or not. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Address_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates whether the locate activity located the employer of a member or not. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Employer_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates whether the locate activity located the SSN of a member or not. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Ssn_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates whether the address of a member is located or not. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'License_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the locate activity status changed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'StatusLocate_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if this locate status is used to identify the assets or not. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Asset_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the origin of the member employment information, the origin of the other income received, the origin of the other expenses information, the origin of the member''s alias name, and the origin of the member''s address. Values are obtained from REFM (AHIS/VERS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the locate activity initiated for Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocAddr_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the locate activity initiated for locating Employer of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocEmpr_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the locate activity initiated for locating SSN of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocSsn_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the locate activity initiated for locating DOB of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginLocDateOfBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates whether the referred NCP is located or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1', @level2type=N'COLUMN',@level2name=N'ReferLocate_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to get the members current locate status and the locate history. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocateStatus_T1'
GO
