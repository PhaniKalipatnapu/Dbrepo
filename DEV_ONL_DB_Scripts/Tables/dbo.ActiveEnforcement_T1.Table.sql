USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'EndExempt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'BeginExempt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'StatusEnforce_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'BeginEnforcement_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[ActiveEnforcement_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ActiveEnforcement_T1]
GO
/****** Object:  Table [dbo].[ActiveEnforcement_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActiveEnforcement_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[BeginEnforcement_DATE] [date] NOT NULL,
	[StatusEnforce_CODE] [char](1) NOT NULL,
	[ReasonStatus_CODE] [char](2) NOT NULL,
	[BeginExempt_DATE] [date] NOT NULL,
	[EndExempt_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [ACEN_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Case ID which has been moved to Enforcement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the case is moved to Enforcement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'BeginEnforcement_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The status of the Case in Enforcement. Values are obtained from REFM (CPRO/STAT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'StatusEnforce_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Reason for updating the current record. Values are obtained from REFM (ENST/REAS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the value which represents when the exemption starts/started.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'BeginExempt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the value which represents the exemption end date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'EndExempt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the current enforcement status of the Case ID. A record is available in this table for every case which has a support order. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ActiveEnforcement_T1'
GO
