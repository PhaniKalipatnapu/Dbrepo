USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
/****** Object:  Table [dbo].[RefFarFormsChecklist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefFarFormsChecklist_T1]
GO
/****** Object:  Table [dbo].[RefFarFormsChecklist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefFarFormsChecklist_T1](
	[Function_CODE] [char](3) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[Notice_ID] [char](8) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [FFCL_I1] PRIMARY KEY CLUSTERED 
(
	[Function_CODE] ASC,
	[Action_CODE] ASC,
	[Reason_CODE] ASC,
	[Notice_ID] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The seven CSENET functions that the state will use for communication. This is one of the components of the FAR combinations. Valid values are available in REFM.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Stores the Action code for which this request is made. This is one of the components in the FAR combination. Valid value are available in REFM.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Stores the Reason code for which this request is made. This is one of the components in the FAR combination. Valid value are available in REFM.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Indicates the name of the forms that is expected to receive for a given FAR combination. Valid value are available in REFM.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the incoming SOIL hit records with the due date.  Records in this table will be read and processed based on the due date given. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFarFormsChecklist_T1'
GO
