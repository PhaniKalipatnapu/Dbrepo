USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'TypeOfficeAssign_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'WorkerAssign_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'Role_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'SubCategory_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'Category_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
/****** Object:  Index [ACRL_ID_ROLE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ACRL_ID_ROLE_I1] ON [dbo].[RefActivityCatRole_T1]
GO
/****** Object:  Table [dbo].[RefActivityCatRole_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefActivityCatRole_T1]
GO
/****** Object:  Table [dbo].[RefActivityCatRole_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefActivityCatRole_T1](
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[Category_CODE] [char](2) NOT NULL,
	[SubCategory_CODE] [char](4) NOT NULL,
	[Role_ID] [char](10) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[ScreenFunction_CODE] [char](10) NOT NULL,
	[WorkerAssign_INDC] [char](1) NOT NULL,
	[TypeOfficeAssign_CODE] [char](1) NOT NULL,
 CONSTRAINT [ACRL_I1] PRIMARY KEY CLUSTERED 
(
	[ActivityMinor_CODE] ASC,
	[Category_CODE] ASC,
	[SubCategory_CODE] ASC,
	[Role_ID] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ACRL_ID_ROLE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ACRL_ID_ROLE_I1] ON [dbo].[RefActivityCatRole_T1]
(
	[Role_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Code within the system for the Minor Activity. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This field indicates the type of unit/area entering the note. Categories are: Case Initiation, Case Management, Customer Service, Enforcement, Establishment, Financial, and Interstate. Values are obtained from REFM (CATG/CATG).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'Category_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'This field indicates the sub category selected based on the Category. Values are obtained from REFM (CPRO/NREF).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'SubCategory_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Stores the role ID for which this alert has to be sent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'Role_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted/modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds data about the individual functionality of the screen. Possible values are limited by values in SCFN table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates alerts assigned to worker or role. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'WorkerAssign_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the type of the office to which this activity should be assigned. Possible values are limited by values in OFIC table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1', @level2type=N'COLUMN',@level2name=N'TypeOfficeAssign_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table that stores the link between the roles and the Activities that are used for generating the alerts accordingly. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityCatRole_T1'
GO
