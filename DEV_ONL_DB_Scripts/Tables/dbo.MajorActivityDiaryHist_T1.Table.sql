USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Reference_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TypeReference_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'LastPost_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'SubjectLastPoster_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'UserLastPoster_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'PostLastPoster_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TotalTopics_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Forum_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'EndExempt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'BeginExempt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'OthpSource_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TypeOthpSource_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Subsystem_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[MajorActivityDiaryHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MajorActivityDiaryHist_T1]
GO
/****** Object:  Table [dbo].[MajorActivityDiaryHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MajorActivityDiaryHist_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[MajorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[ActivityMajor_CODE] [char](4) NOT NULL,
	[Subsystem_CODE] [char](2) NOT NULL,
	[TypeOthpSource_CODE] [char](1) NOT NULL,
	[OthpSource_IDNO] [numeric](10, 0) NOT NULL,
	[Entered_DATE] [date] NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[Status_CODE] [char](4) NOT NULL,
	[ReasonStatus_CODE] [char](2) NOT NULL,
	[BeginExempt_DATE] [date] NOT NULL,
	[EndExempt_DATE] [date] NOT NULL,
	[Forum_IDNO] [numeric](10, 0) NOT NULL,
	[TotalTopics_QNTY] [numeric](10, 0) NOT NULL,
	[PostLastPoster_IDNO] [numeric](10, 0) NOT NULL,
	[UserLastPoster_ID] [char](30) NOT NULL,
	[SubjectLastPoster_TEXT] [varchar](300) NOT NULL,
	[LastPost_DTTM] [datetime2](7) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TypeReference_CODE] [char](5) NOT NULL,
	[Reference_ID] [char](30) NOT NULL,
 CONSTRAINT [HDMJR_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[MajorIntSeq_NUMB] ASC,
	[OrderSeq_NUMB] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Case ID of the member for whom the Remedy is being enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The system generated sequence number for the Remedy and Case / Order combination. This number is incremented programmatically (maximum + 1).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Member ID for whom the Remedy was enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Code within the system for the Major Activity. Possible values are limited by values in AMJR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Represents the Subsystem of the Child Support system. Values are obtained from REFM (CPRO/CATG)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Subsystem_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Source Type of the Source ID. Values are obtained from REFM (AMJR_V1.ActivityMajor_CODE/SRCT). EX: LSNR/SRCT, CSLN/SRCT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TypeOthpSource_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Source ID (Other Party ID) where the Remedy is being enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'OthpSource_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the Remedy has been initiated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the Remedy has been updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the status of a member’s address on AHIS. Values are obtained from REFM (CONF/CON1)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Reason for updating the Remedy. Values are obtained from REFM (REST/REAS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the value which represents when the exemption starts/started.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'BeginExempt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the value which represents the exemption end date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'EndExempt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The System Generated ID for the Forum.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Forum_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Represents number of Topics for the Forum View in Process History.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TotalTopics_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Post ID of the Last Post.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'PostLastPoster_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The User who posted the Last Post.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'UserLastPoster_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Subject of the Last Post.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'SubjectLastPoster_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date and Time when the Last Post.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'LastPost_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'To hold the type of reference. Values are obtained from REFM (AMJR_V1.ActivityMajor_CODE/RFTP). EX: LSNR/RFTP, CSLN/RFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'TypeReference_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'To hold the reference number like no_licence, no_account_asset, etc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1', @level2type=N'COLUMN',@level2name=N'Reference_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the history records of the Major activity Diary table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MajorActivityDiaryHist_T1'
GO
