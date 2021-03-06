USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'PaybackSord_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Compliance_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Entry_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'NoMissPayment_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Compliance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'ComplianceType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'RecordRowNumber_NUMB'

GO
/****** Object:  Index [PEWKL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [PEWKL_I1] ON [dbo].[IntEmonWeekly_T1]
GO
/****** Object:  Index [PEWKL_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [PEWKL_CASE_I1] ON [dbo].[IntEmonWeekly_T1]
GO
/****** Object:  Table [dbo].[IntEmonWeekly_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntEmonWeekly_T1]
GO
/****** Object:  Table [dbo].[IntEmonWeekly_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntEmonWeekly_T1](
	[RecordRowNumber_NUMB] [numeric](15, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[ComplianceType_CODE] [char](2) NOT NULL,
	[Compliance_AMNT] [numeric](11, 2) NOT NULL,
	[NoMissPayment_QNTY] [numeric](5, 0) NOT NULL,
	[Entry_DATE] [date] NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[End_DATE] [date] NOT NULL,
	[Compliance_IDNO] [numeric](19, 0) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[PaybackSord_AMNT] [numeric](11, 2) NOT NULL,
	[NcpMci_IDNO] [numeric](10, 0) NOT NULL,
	[Process_INDC] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [PEWKL_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [PEWKL_CASE_I1] ON [dbo].[IntEmonWeekly_T1]
(
	[Case_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PEWKL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [PEWKL_I1] ON [dbo].[IntEmonWeekly_T1]
(
	[RecordRowNumber_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates the record rownumber for each record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'RecordRowNumber_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Case ID of the member for whom the Remedy is being enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated Internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID Assigned to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Compliance Schedule Type. Values are obtained from REFM (COMP/TYPE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'ComplianceType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount to be paid because of the Compliance Schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Compliance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Count on number of times the payment can be missed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'NoMissPayment_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the compliance schedule entry was made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Entry_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Start Date of the Compliance Schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'End Date of the Compliance Schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The unique sequence number that is assigned by the system for each compliance schedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Compliance_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Sequence Number that will be generated for any given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the payback amt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'PaybackSord_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP member ID of the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates process of records.Values are Y-processed records, N-Not processed records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store all the records to process by EMON weekly batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEmonWeekly_T1'
GO
