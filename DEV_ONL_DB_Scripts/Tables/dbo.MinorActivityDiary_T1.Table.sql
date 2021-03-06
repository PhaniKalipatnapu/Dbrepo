USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Subsystem_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'WorkerDelegate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'AlertPrior_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'LastPost_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'UserLastPoster_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'PostLastPoster_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'TotalViews_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'TotalReplies_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Topic_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Forum_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Schedule_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Due_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorNext_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [DMNR_NO_SCHEDULE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DMNR_NO_SCHEDULE_I1] ON [dbo].[MinorActivityDiary_T1]
GO
/****** Object:  Index [DMNR_MAJOR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DMNR_MAJOR_I1] ON [dbo].[MinorActivityDiary_T1]
GO
/****** Object:  Index [DMNR_ID_TOPIC_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DMNR_ID_TOPIC_I1] ON [dbo].[MinorActivityDiary_T1]
GO
/****** Object:  Index [DMNR_DELEGATE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DMNR_DELEGATE_I1] ON [dbo].[MinorActivityDiary_T1]
GO
/****** Object:  Index [DMNR_CASE_ACTIVITY_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DMNR_CASE_ACTIVITY_I1] ON [dbo].[MinorActivityDiary_T1]
GO
/****** Object:  Table [dbo].[MinorActivityDiary_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MinorActivityDiary_T1]
GO
/****** Object:  Table [dbo].[MinorActivityDiary_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MinorActivityDiary_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[MajorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[MinorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[ActivityMinorNext_CODE] [char](5) NOT NULL,
	[Entered_DATE] [date] NOT NULL,
	[Due_DATE] [date] NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[Status_CODE] [char](4) NOT NULL,
	[ReasonStatus_CODE] [char](2) NOT NULL,
	[Schedule_NUMB] [numeric](10, 0) NOT NULL,
	[Forum_IDNO] [numeric](10, 0) NOT NULL,
	[Topic_IDNO] [numeric](10, 0) NOT NULL,
	[TotalReplies_QNTY] [numeric](10, 0) NOT NULL,
	[TotalViews_QNTY] [numeric](10, 0) NOT NULL,
	[PostLastPoster_IDNO] [numeric](10, 0) NOT NULL,
	[UserLastPoster_ID] [char](30) NOT NULL,
	[LastPost_DTTM] [datetime2](7) NOT NULL,
	[AlertPrior_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[WorkerDelegate_ID] [char](30) NOT NULL,
	[ActivityMajor_CODE] [char](4) NOT NULL,
	[Subsystem_CODE] [char](2) NOT NULL,
 CONSTRAINT [DMNR_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[MajorIntSeq_NUMB] ASC,
	[MinorIntSeq_NUMB] ASC,
	[OrderSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DMNR_CASE_ACTIVITY_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DMNR_CASE_ACTIVITY_I1] ON [dbo].[MinorActivityDiary_T1]
(
	[Case_IDNO] ASC,
	[ActivityMinor_CODE] ASC,
	[ActivityMajor_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DMNR_DELEGATE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DMNR_DELEGATE_I1] ON [dbo].[MinorActivityDiary_T1]
(
	[ActivityMinor_CODE] ASC,
	[Entered_DATE] ASC,
	[AlertPrior_DATE] ASC,
	[WorkerDelegate_ID] ASC,
	[ActivityMajor_CODE] ASC,
	[Subsystem_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [DMNR_ID_TOPIC_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DMNR_ID_TOPIC_I1] ON [dbo].[MinorActivityDiary_T1]
(
	[Topic_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DMNR_MAJOR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DMNR_MAJOR_I1] ON [dbo].[MinorActivityDiary_T1]
(
	[ActivityMinor_CODE] ASC,
	[Entered_DATE] ASC,
	[Status_DATE] ASC,
	[Status_CODE] ASC,
	[AlertPrior_DATE] ASC,
	[ActivityMajor_CODE] ASC,
	[Subsystem_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DMNR_NO_SCHEDULE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DMNR_NO_SCHEDULE_I1] ON [dbo].[MinorActivityDiary_T1]
(
	[Schedule_NUMB] ASC,
	[Status_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Case ID of the member for whom the Minor Activity has been inserted for the Remedy enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The system generated sequence number for every new Minor Activity within the same Major Activity Sequence. It''s the occurrence of this major activity.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The system generated number for every new Minor Activity within the same Major Activity Sequence.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Member ID for whom the Minor Activity has been inserted for the Remedy enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Code within the system for the Minor Activity. Values are obtained from REFM (WRKL/REFT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Code of the Next Minor Activity to follow. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorNext_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the Minor Activity was inserted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the Minor Activity is expected to be updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Due_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Minor Activity has actually been updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Current Status of the Minor Activity. Values are obtained from REFM (CPRO/RSTS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Reason for updating the current Minor Activity. Values are obtained from REFM (ENST/REAS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Appointment Number associated with the Minor Activity.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Schedule_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The System Generated ID for the Forum view in Process History.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Forum_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system generated Topic ID for the Forum view in Process History.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Topic_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The number of replies for the topic in Notes. The message for the original topic in Notes should not be included for incrementing the count.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'TotalReplies_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The number of times the post has been viewed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'TotalViews_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Post ID of the Last Post.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'PostLastPoster_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The User who posted the Last Post.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'UserLastPoster_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date and Time when the Last Post was inserted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'LastPost_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Alert has to be started showing.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'AlertPrior_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the Worker ID to whom the Activity has been Delegated to for Updating the Status of the Activity.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'WorkerDelegate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Code within the system for the Major Activity. Possible values are limited by values in AMJR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Represents the Subsystem of the Child Support system. Values are obtained from REFM (CPRO/CATG)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1', @level2type=N'COLUMN',@level2name=N'Subsystem_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the details of the minor activities for each major activity happening on the case. All records are valid in this table. The History records are stored in a separate table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiary_T1'
GO
