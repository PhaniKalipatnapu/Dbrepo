USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'LocateQuick_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAsset_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceLicense_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceSsn_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceEmpr_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAddrRsnt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAddrMail_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAddrLegal_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'NoResubmitDays_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'Source_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'

GO
/****** Object:  Table [dbo].[RefLocSourceCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefLocSourceCodes_T1]
GO
/****** Object:  Table [dbo].[RefLocSourceCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefLocSourceCodes_T1](
	[SourceLoc_CODE] [char](3) NOT NULL,
	[Source_NAME] [varchar](60) NOT NULL,
	[NoResubmitDays_QNTY] [numeric](3, 0) NOT NULL,
	[SourceAddrLegal_INDC] [char](1) NOT NULL,
	[SourceAddrMail_INDC] [char](1) NOT NULL,
	[SourceAddrRsnt_INDC] [char](1) NOT NULL,
	[SourceEmpr_INDC] [char](1) NOT NULL,
	[SourceSsn_INDC] [char](1) NOT NULL,
	[SourceLicense_INDC] [char](1) NOT NULL,
	[SourceAsset_INDC] [char](1) NOT NULL,
	[LocateQuick_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [LSRC_I1] PRIMARY KEY CLUSTERED 
(
	[SourceLoc_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This column identifies the sources from where information can be located. This is a reference table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column identifies the name of the locate source.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'Source_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If a response is not received, then indicate the number of days after which the request can be resubmitted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'NoResubmitDays_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate whether this locate source provides the Legal address information. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAddrLegal_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate whether this locate source provides the Mail address information. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAddrMail_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate whether this locate source provides the Residential address information. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAddrRsnt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate whether this locate source provides the Employer information. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceEmpr_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate whether this locate source provides the SSN information. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceSsn_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate whether this locate source provides the License information. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceLicense_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate whether this locate source provides the Assets information. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'SourceAsset_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if this locate source can be located through the federal Quick process. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'LocateQuick_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table for the Locate sources. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefLocSourceCodes_T1'
GO
