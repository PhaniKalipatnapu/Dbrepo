USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'CasesAssigned_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Supervisor_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'WorkerSub_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'AlphaRangeTo_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'AlphaRangeFrom_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Expire_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Role_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Office_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
/****** Object:  Index [USRL_WORKER_SUB_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [USRL_WORKER_SUB_I1] ON [dbo].[UserOfficeRoles_T1]
GO
/****** Object:  Index [USRL_OFFICE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [USRL_OFFICE_I1] ON [dbo].[UserOfficeRoles_T1]
GO
/****** Object:  Table [dbo].[UserOfficeRoles_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[UserOfficeRoles_T1]
GO
/****** Object:  Table [dbo].[UserOfficeRoles_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserOfficeRoles_T1](
	[Worker_ID] [char](30) NOT NULL,
	[Office_IDNO] [numeric](3, 0) NOT NULL,
	[Role_ID] [char](10) NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[Expire_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[AlphaRangeFrom_CODE] [char](5) NOT NULL,
	[AlphaRangeTo_CODE] [char](5) NOT NULL,
	[WorkerSub_ID] [char](30) NOT NULL,
	[Supervisor_ID] [char](30) NOT NULL,
	[CasesAssigned_QNTY] [numeric](10, 0) NOT NULL,
 CONSTRAINT [USRL_I1] PRIMARY KEY CLUSTERED 
(
	[Worker_ID] ASC,
	[Office_IDNO] ASC,
	[Role_ID] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [USRL_OFFICE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [USRL_OFFICE_I1] ON [dbo].[UserOfficeRoles_T1]
(
	[Office_IDNO] ASC,
	[Role_ID] ASC,
	[Effective_DATE] ASC,
	[Expire_DATE] ASC,
	[EndValidity_DATE] ASC
)
INCLUDE ( 	[CasesAssigned_QNTY],
	[AlphaRangeFrom_CODE],
	[AlphaRangeTo_CODE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [USRL_WORKER_SUB_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [USRL_WORKER_SUB_I1] ON [dbo].[UserOfficeRoles_T1]
(
	[WorkerSub_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID for Each Resource (Worker).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Identification code for each office.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Office_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Role to which the Resource is associated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Role_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date from which worker effectively assigned to the role for a particular office.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date which role assignment to a worker at a particular office will expire.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Expire_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the Alphabet Starting Point for a Particular Range. This is the alpha assignment range provided to this worker. Possible values are between A and Z' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'AlphaRangeFrom_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the Alphabet Ending Point for a Particular Range. This is the alpha assignment range provided to this worker. Possible values are between A and Z' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'AlphaRangeTo_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the substitute''s worker ID who will work for this primary worker in his/her absence. This is used to re-direct the alerts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'WorkerSub_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Supervisor Id for that worker for that role in an office.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'Supervisor_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total number of Cases Assigned to the User to Work.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1', @level2type=N'COLUMN',@level2name=N'CasesAssigned_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the roles assigned to each user and Office. This table stores valid records as well as history records which follows the temporal model structure' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserOfficeRoles_T1'
GO
