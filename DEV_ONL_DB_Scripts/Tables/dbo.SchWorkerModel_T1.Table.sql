USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'MaxLoad_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndBreak3_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginBreak3_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndBreak2_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginBreak2_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndBreak1_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginBreak1_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndWork_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginWork_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'Day_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
/****** Object:  Table [dbo].[SchWorkerModel_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[SchWorkerModel_T1]
GO
/****** Object:  Table [dbo].[SchWorkerModel_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SchWorkerModel_T1](
	[Worker_ID] [char](30) NOT NULL,
	[Day_CODE] [char](1) NOT NULL,
	[BeginWork_DTTM] [datetime2](7) NOT NULL,
	[EndWork_DTTM] [datetime2](7) NOT NULL,
	[BeginBreak1_DTTM] [datetime2](7) NOT NULL,
	[EndBreak1_DTTM] [datetime2](7) NOT NULL,
	[BeginBreak2_DTTM] [datetime2](7) NOT NULL,
	[EndBreak2_DTTM] [datetime2](7) NOT NULL,
	[BeginBreak3_DTTM] [datetime2](7) NOT NULL,
	[EndBreak3_DTTM] [datetime2](7) NOT NULL,
	[MaxLoad_QNTY] [numeric](3, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [SWRK_I1] PRIMARY KEY CLUSTERED 
(
	[Worker_ID] ASC,
	[Day_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The ID of the worker for which the Availability is being stored.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The Weekday on which the worker is available. Day 1 starts with Sunday. Possible values are between 1 and 7.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'Day_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Start Time from which the worker is available for the day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginWork_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Time up to which the worker is available for the day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndWork_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The time from which the Worker''s first break of the day starts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginBreak1_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end time of the Worker''s first break of the day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndBreak1_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The time from which the Worker''s second break of the day starts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginBreak2_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end time of the Worker''s second break of the day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndBreak2_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The time from which the Worker''s third break of the day starts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginBreak3_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end time of the Worker''s third break of the day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndBreak3_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The maximum number of appointments the worker can handle within the available time.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'MaxLoad_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the regular work time slots for each worker to schedule appointments. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchWorkerModel_T1'
GO
