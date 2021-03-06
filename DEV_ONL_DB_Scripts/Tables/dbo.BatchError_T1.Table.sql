USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Error_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Line_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'BatchLogSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'ListKey_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'TypeError_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Create_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'EffectiveRun_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Process_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'

GO
/****** Object:  Index [BATE_PKG_NAME_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [BATE_PKG_NAME_I1] ON [dbo].[BatchError_T1]
GO
/****** Object:  Index [BATE_JOB_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [BATE_JOB_I1] ON [dbo].[BatchError_T1]
GO
/****** Object:  Index [BATE_DT_EFF_RUN_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [BATE_DT_EFF_RUN_I1] ON [dbo].[BatchError_T1]
GO
/****** Object:  Table [dbo].[BatchError_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[BatchError_T1]
GO
/****** Object:  Table [dbo].[BatchError_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BatchError_T1](
	[Job_ID] [char](7) NOT NULL,
	[Process_NAME] [varchar](100) NOT NULL,
	[EffectiveRun_DATE] [date] NOT NULL,
	[Procedure_NAME] [varchar](100) NOT NULL,
	[Create_DTTM] [datetime2](7) NOT NULL,
	[TypeError_CODE] [char](1) NOT NULL,
	[ListKey_TEXT] [varchar](1000) NOT NULL,
	[DescriptionError_TEXT] [varchar](4000) NOT NULL,
	[BatchLogSeq_NUMB] [numeric](10, 0) IDENTITY(1,1) NOT NULL,
	[Line_NUMB] [numeric](10, 0) NOT NULL,
	[Error_CODE] [char](18) NOT NULL,
 CONSTRAINT [BATE_I1] PRIMARY KEY CLUSTERED 
(
	[BatchLogSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [BATE_DT_EFF_RUN_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [BATE_DT_EFF_RUN_I1] ON [dbo].[BatchError_T1]
(
	[EffectiveRun_DATE] ASC,
	[Error_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [BATE_JOB_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [BATE_JOB_I1] ON [dbo].[BatchError_T1]
(
	[Job_ID] ASC,
	[Process_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [BATE_PKG_NAME_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [BATE_PKG_NAME_I1] ON [dbo].[BatchError_T1]
(
	[Job_ID] ASC,
	[Process_NAME] ASC,
	[EffectiveRun_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores unique ID associated with the Batch job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the package name associated with the job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Process_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the batch process date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'EffectiveRun_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the procedure name associated with the job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date and time the record was created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Create_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Error Type occurred while executing the Job. Values are obtained from REFM (EMSG/EMSG).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'TypeError_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'List of key attributes involved in the Job that caused an abend.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'ListKey_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description of the error while running the job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID assigned by the system to log the batch error record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'BatchLogSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the line number of the file that caused the error, if the job involves with file handling.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Line_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Error Identification code that uniquely identifies each error. Values are obtained from REFM (EMSG/EMSG)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1', @level2type=N'COLUMN',@level2name=N'Error_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to capture errors (handled exceptions), warnings and informational errors from batches.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchError_T1'
GO
