USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'Category_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'DescriptionNotice_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'PaperStyle_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'AddressHierarchy_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'TypeEnvelope_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'TypeNotice_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'BatchOnline_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'CategoryForm_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'

GO
/****** Object:  Table [dbo].[RefNotices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefNotices_T1]
GO
/****** Object:  Table [dbo].[RefNotices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefNotices_T1](
	[Notice_ID] [char](8) NOT NULL,
	[CategoryForm_CODE] [char](3) NOT NULL,
	[BatchOnline_CODE] [char](1) NOT NULL,
	[TypeNotice_CODE] [char](1) NOT NULL,
	[TypeEnvelope_CODE] [char](1) NOT NULL,
	[AddressHierarchy_CODE] [char](1) NOT NULL,
	[PaperStyle_CODE] [char](2) NOT NULL,
	[DescriptionNotice_TEXT] [varchar](100) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[Category_CODE] [char](2) NOT NULL,
 CONSTRAINT [NREF_I1] PRIMARY KEY CLUSTERED 
(
	[Notice_ID] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique id assigned to the notices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates category of the notice. Values are obtained from REFM (NPRO/CTGY).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'CategoryForm_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the notice will be  printed. Values are obtained from REFM (PRNT/MTHD).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'BatchOnline_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the type of the form. Values are obtained from REFM (NPRO/NTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'TypeNotice_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates type of the envelope to be used for sending the notice. Standard Self Mailer, Large Self Mailer, Window. This information will be  sent to OIT (batch printer process). Valid values are obtained from REFM (PRNT/MALR).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'TypeEnvelope_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the hierarchy. Values are obtained from REFM (ADDR/HIER).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'AddressHierarchy_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the code for the style of paper like A4, legal or any other sheet style. This information will be  sent to Central Printing (batch printer process). Possible values are A4.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'PaperStyle_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Field stores the description or Name of the notice.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'DescriptionNotice_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Use this column to notify which category the notice belongs to. Values are obtained from REFM (CATG/CATG).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1', @level2type=N'COLUMN',@level2name=N'Category_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table to store the attribute information for each notice template. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNotices_T1'
GO
