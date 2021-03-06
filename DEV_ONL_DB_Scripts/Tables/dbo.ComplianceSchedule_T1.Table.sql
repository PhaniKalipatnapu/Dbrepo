USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Entry_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'OrderedParty_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'NoMissPayment_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Freq_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Compliance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'ComplianceStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'ComplianceType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Compliance_IDNO'

GO
/****** Object:  Index [COMP_CASE_SEQ_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [COMP_CASE_SEQ_I1] ON [dbo].[ComplianceSchedule_T1]
GO
/****** Object:  Table [dbo].[ComplianceSchedule_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ComplianceSchedule_T1]
GO
/****** Object:  Table [dbo].[ComplianceSchedule_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplianceSchedule_T1](
	[Compliance_IDNO] [numeric](19, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ComplianceType_CODE] [char](2) NOT NULL,
	[ComplianceStatus_CODE] [char](2) NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[End_DATE] [date] NOT NULL,
	[Compliance_AMNT] [numeric](11, 2) NOT NULL,
	[Freq_CODE] [char](1) NOT NULL,
	[NoMissPayment_QNTY] [numeric](5, 0) NOT NULL,
	[OrderedParty_CODE] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Entry_DATE] [date] NOT NULL,
 CONSTRAINT [COMP_I1] PRIMARY KEY CLUSTERED 
(
	[Compliance_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [COMP_CASE_SEQ_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [COMP_CASE_SEQ_I1] ON [dbo].[ComplianceSchedule_T1]
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC,
	[ComplianceType_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The unique sequence number that is assigned by the system for each compliance schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Compliance_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case Id associated with the  Compliance Schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated Internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Compliance Schedule Type. Values are obtained from REFM (COMP/TYPE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'ComplianceType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Status of the Compliance Schedule. Values are obtained from REFM (COMP/STAT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'ComplianceStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Start Date of the Compliance Schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'End Date of the Compliance Schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount to be paid because of the Compliance Schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Compliance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Frequency of the Amount Payment. Values are obtained from REFM (COMP/FRQY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Freq_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Count on number of times the payment can be missed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'NoMissPayment_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Compliance - Ordered Party. Possible values are CP or NCP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'OrderedParty_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for any given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the compliance schedule entry was made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1', @level2type=N'COLUMN',@level2name=N'Entry_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the information on the various type of compliance schedule to be monitored for the NCP. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ComplianceSchedule_T1'
GO
