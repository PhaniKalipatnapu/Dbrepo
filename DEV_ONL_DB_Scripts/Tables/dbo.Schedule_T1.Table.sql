USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'SchedulingUnit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Worker_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ReasonAdjourn_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'TypeFamisProceeding_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'SchPrev_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'SchParent_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ApptStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'EndSch_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'BeginSch_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Schedule_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'TypeActivity_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'WorkerDelegateTo_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'OthpLocation_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Schedule_NUMB'

GO
/****** Object:  Index [SWKS_Worker_ID_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [SWKS_Worker_ID_I1] ON [dbo].[Schedule_T1]
GO
/****** Object:  Index [SWKS_CASE_SCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [SWKS_CASE_SCH_I1] ON [dbo].[Schedule_T1]
GO
/****** Object:  Table [dbo].[Schedule_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Schedule_T1]
GO
/****** Object:  Table [dbo].[Schedule_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Schedule_T1](
	[Schedule_NUMB] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[OthpLocation_IDNO] [numeric](9, 0) NOT NULL,
	[ActivityMajor_CODE] [char](4) NOT NULL,
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[WorkerDelegateTo_ID] [char](30) NOT NULL,
	[TypeActivity_CODE] [char](1) NOT NULL,
	[Schedule_DATE] [date] NOT NULL,
	[BeginSch_DTTM] [datetime2](7) NOT NULL,
	[EndSch_DTTM] [datetime2](7) NOT NULL,
	[ApptStatus_CODE] [char](2) NOT NULL,
	[SchParent_NUMB] [numeric](10, 0) NOT NULL,
	[SchPrev_NUMB] [numeric](10, 0) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TypeFamisProceeding_CODE] [char](5) NOT NULL,
	[ReasonAdjourn_CODE] [char](3) NOT NULL,
	[Worker_NAME] [varchar](78) NOT NULL,
	[SchedulingUnit_CODE] [char](2) NOT NULL,
 CONSTRAINT [SWKS_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[OthpLocation_IDNO] ASC,
	[MemberMci_IDNO] ASC,
	[Schedule_NUMB] ASC,
	[Worker_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [SWKS_CASE_SCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [SWKS_CASE_SCH_I1] ON [dbo].[Schedule_T1]
(
	[Schedule_NUMB] ASC,
	[Case_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SWKS_Worker_ID_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [SWKS_Worker_ID_I1] ON [dbo].[Schedule_T1]
(
	[Worker_ID] ASC,
	[Schedule_DATE] ASC,
	[ApptStatus_CODE] ASC,
	[ActivityMinor_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number generated using a sequence for a given schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Schedule_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Stores the Case-ID for which this appointment for the activity is made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Stores the Worker ID for whom the schedule is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Stores the MCI for which appointment for the activity is made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Unique identifier for the location where the appointment is to take place.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'OthpLocation_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The major activity for which the appointment has been scheduled. Possible values are limited by values in AMJR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The minor activity for which the appointment has been scheduled. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The worker id to which the appointment has been delegated to. If the appointment is delegated to someone, then this column will have some value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'WorkerDelegateTo_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The type of process for which the location is available. Values are obtained from REFM (ACTP/ACTP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'TypeActivity_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The appointment date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Schedule_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start time for appointment (Hours and minutes).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'BeginSch_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end time for appointment (Hours and minutes).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'EndSch_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The status of the appointment. Values are obtained from REFM (APPT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ApptStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The parent schedule number if the same appointment has been rescheduled many times.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'SchParent_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The previous schedule number if the appointment has been rescheduled.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'SchPrev_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family Court scheduling type of hearing. Values to be determined in subsequent Technical Design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'TypeFamisProceeding_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'User can enter adjournment reason if a Family Court hearing is cancelled. Values are obtained from REFM (FACT/AJRN).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'ReasonAdjourn_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Case Worker who is working on this Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'Worker_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family court scheduling unit. Possible values are                     CO - Commissioner,                    MS - Master,                     MA - Mediation,                    BT - Genetic Test,                    JU - Judge' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1', @level2type=N'COLUMN',@level2name=N'SchedulingUnit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the schedule details set for each activity of a case with its associated details. All rows in this table are valid. The history records are stored in a separate table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Schedule_T1'
GO
