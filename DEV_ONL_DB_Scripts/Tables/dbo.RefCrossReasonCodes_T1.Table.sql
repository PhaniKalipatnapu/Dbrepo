USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'TableSub_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Table_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Type_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'

GO
/****** Object:  Table [dbo].[RefCrossReasonCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefCrossReasonCodes_T1]
GO
/****** Object:  Table [dbo].[RefCrossReasonCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefCrossReasonCodes_T1](
	[Process_ID] [char](10) NOT NULL,
	[Type_CODE] [char](5) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[Table_ID] [char](4) NOT NULL,
	[TableSub_ID] [char](4) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
 CONSTRAINT [RESF_I1] PRIMARY KEY CLUSTERED 
(
	[Process_ID] ASC,
	[Type_CODE] ASC,
	[Reason_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the process for which this type and reason is cross referenced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the code type value for the corresponding process.  Possible values are limited by values in REFM table for the corresponding key value in Table_ID and TableSub_ID columns of this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Type_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Identifies the reason code for the corresponding code type value. Possible values are limited by values in REFM table for the corresponding key in Table_ID and TableSub_ID columns of this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the cross Ref code Table that is being utilized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Table_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the subtype within the cross Ref reason code Table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'TableSub_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used as reference table to a subset of REFM values in online screens based on certain user selection.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCrossReasonCodes_T1'
GO
