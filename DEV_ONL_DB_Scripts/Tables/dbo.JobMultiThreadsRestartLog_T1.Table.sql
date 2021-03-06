USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'ThreadProcess_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RecRestart_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RestartKey_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RecEnd_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RecStart_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'Thread_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'

GO
/****** Object:  Table [dbo].[JobMultiThreadsRestartLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[JobMultiThreadsRestartLog_T1]
GO
/****** Object:  Table [dbo].[JobMultiThreadsRestartLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[JobMultiThreadsRestartLog_T1](
	[Job_ID] [char](7) NOT NULL,
	[Run_DATE] [date] NOT NULL,
	[Thread_NUMB] [numeric](15, 0) NOT NULL,
	[RecStart_NUMB] [numeric](15, 0) NOT NULL,
	[RecEnd_NUMB] [numeric](15, 0) NOT NULL,
	[RestartKey_TEXT] [varchar](500) NOT NULL,
	[RecRestart_NUMB] [numeric](15, 0) NOT NULL,
	[ThreadProcess_CODE] [char](1) NOT NULL,
 CONSTRAINT [JRTL_I1] PRIMARY KEY CLUSTERED 
(
	[Job_ID] ASC,
	[Run_DATE] ASC,
	[Thread_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores unique ID associated with the Batch job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores the run date of the job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates the thread no.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'Thread_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates the starting number of record for a thread.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RecStart_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates the end number of record for a thread.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RecEnd_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The restart key stores the values of one field or more fields that will be used to identify the record from which needs to be restarted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RestartKey_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates the record number processing by each thread.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'RecRestart_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates the thread status . Possible values are A- aborted, N-Not processed and Y-Thread sucessfully processed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1', @level2type=N'COLUMN',@level2name=N'ThreadProcess_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store all the thread details for a job.It has information such a number of records to process by each thread.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobMultiThreadsRestartLog_T1'
GO
