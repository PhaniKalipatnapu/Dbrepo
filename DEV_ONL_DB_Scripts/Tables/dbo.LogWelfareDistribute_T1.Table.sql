USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSupportSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Distribute_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Distribute_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'TypeDisburse_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [LWEL_RCTH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [LWEL_RCTH_I1] ON [dbo].[LogWelfareDistribute_T1]
GO
/****** Object:  Index [LWEL_CASE_WELFARE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [LWEL_CASE_WELFARE_I1] ON [dbo].[LogWelfareDistribute_T1]
GO
/****** Object:  Table [dbo].[LogWelfareDistribute_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LogWelfareDistribute_T1]
GO
/****** Object:  Table [dbo].[LogWelfareDistribute_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogWelfareDistribute_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[WelfareYearMonth_NUMB] [numeric](6, 0) NOT NULL,
	[TypeWelfare_CODE] [char](1) NOT NULL,
	[TypeDisburse_CODE] [char](5) NOT NULL,
	[Distribute_AMNT] [numeric](11, 2) NOT NULL,
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[Distribute_DATE] [date] NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalSupportSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [LWEL_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[CaseWelfare_IDNO] ASC,
	[EventGlobalSeq_NUMB] ASC,
	[ObligationSeq_NUMB] ASC,
	[OrderSeq_NUMB] ASC,
	[TypeDisburse_CODE] ASC,
	[WelfareYearMonth_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [LWEL_CASE_WELFARE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [LWEL_CASE_WELFARE_I1] ON [dbo].[LogWelfareDistribute_T1]
(
	[CaseWelfare_IDNO] ASC,
	[WelfareYearMonth_NUMB] ASC,
	[TypeDisburse_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [LWEL_RCTH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [LWEL_RCTH_I1] ON [dbo].[LogWelfareDistribute_T1]
(
	[Batch_DATE] ASC,
	[SourceBatch_CODE] ASC,
	[Batch_NUMB] ASC,
	[SeqReceipt_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Case ID of the member for whom this welfare distribution Log is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated Internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Internal Obligation Sequence of the Obligation for which this welfare distribution log is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Welfare Case ID, Created at CP level when any one dependant of the CP is in welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Year-Month YYYYMM to which the receipt is applied.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the welfare type of the member.  Values are obtained from REFM (CTYP/CTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Code Assigned to type of Disbursement.  Valid Values are stored in REFM with id_table as DISB and id_table_sub as DISB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'TypeDisburse_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount Applied towards grant or excess to CP from the corresponding receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Distribute_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Date of the receipt that was applied in this transaction. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the batch for which the receipt is created. Valid values are stored in REFM with id_table as RCTB and id_table_sub as RCTB. This is 2nd part of the receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence.Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date in which the welfare distribution takes place.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'Distribute_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Global Event Sequence Number of the Support Log from which the money was distributed to Grant or Excess.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSupportSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores the IVA distribution details i.e the recoupment from the IVD distribution towards the IVA current grant or Prior grant' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogWelfareDistribute_T1'
GO
