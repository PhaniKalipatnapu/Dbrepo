USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'ProcessedRecordCount_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'JobEnd_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'JobStart_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'ListKey_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'ExecLocation_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'CursorLocation_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'EffectiveRun_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Process_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Create_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'BatchLogSeq_NUMB'

GO
/****** Object:  Index [BSTL_DT_EFF_RUN_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [BSTL_DT_EFF_RUN_I1] ON [dbo].[BatchStatusLog_T1]
GO
/****** Object:  Table [dbo].[BatchStatusLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[BatchStatusLog_T1]
GO
/****** Object:  Table [dbo].[BatchStatusLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BatchStatusLog_T1](
	[BatchLogSeq_NUMB] [numeric](10, 0) IDENTITY(1,1) NOT NULL,
	[Create_DTTM] [datetime2](7) NOT NULL,
	[Job_ID] [char](7) NOT NULL,
	[Process_NAME] [varchar](100) NOT NULL,
	[Procedure_NAME] [varchar](100) NOT NULL,
	[EffectiveRun_DATE] [date] NOT NULL,
	[CursorLocation_TEXT] [varchar](200) NOT NULL,
	[ExecLocation_TEXT] [varchar](100) NOT NULL,
	[ListKey_TEXT] [varchar](1000) NOT NULL,
	[Status_CODE] [char](1) NOT NULL,
	[DescriptionError_TEXT] [varchar](4000) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[JobStart_DTTM] [datetime2](7) NOT NULL,
	[JobEnd_DTTM] [datetime2](7) NOT NULL,
	[ProcessedRecordCount_QNTY] [numeric](6, 0) NOT NULL,
 CONSTRAINT [BSTL_I1] PRIMARY KEY CLUSTERED 
(
	[BatchLogSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [BSTL_DT_EFF_RUN_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [BSTL_DT_EFF_RUN_I1] ON [dbo].[BatchStatusLog_T1]
(
	[EffectiveRun_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID assigned by the system to log the batch status record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'BatchLogSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date and time the record was created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Create_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores unique ID associated with the Batch job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the package name associated with the job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Process_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the procedure name associated with the job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the batch process date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'EffectiveRun_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies where in the procedure the data failed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'CursorLocation_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the location in the batch program where the job abend.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'ExecLocation_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the kind of data at the point in time that the field is exhibited.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'ListKey_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the status of the batch. Values are obtained from REFM (BSTL/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the SQL Error with a statement. For example, No Data found.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the ID of the user running the batch. The user ID will primarily be the system, but can also be another user.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Date and time that the job was started.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'JobStart_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Date and time that the job was completed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'JobEnd_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Number of records successfully processed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1', @level2type=N'COLUMN',@level2name=N'ProcessedRecordCount_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to capture the status of the batch processes and elapsed time (execution time).  If the batch errors out then this table gives details like location, data used and the actual error for trouble shooting.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchStatusLog_T1'
GO
