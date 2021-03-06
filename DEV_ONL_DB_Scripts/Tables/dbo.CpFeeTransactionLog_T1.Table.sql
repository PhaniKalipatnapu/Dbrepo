USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSupportSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'TypeDisburse_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'RecoveredTot_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'AssessedTot_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'AssessedYear_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'FeeType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Unique_IDNO'

GO
/****** Object:  Index [CPFL_MEMBER_FEETYPE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [CPFL_MEMBER_FEETYPE_I1] ON [dbo].[CpFeeTransactionLog_T1]
GO
/****** Object:  Index [CPFL_BATCH_SOURCE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [CPFL_BATCH_SOURCE_I1] ON [dbo].[CpFeeTransactionLog_T1]
GO
/****** Object:  Table [dbo].[CpFeeTransactionLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CpFeeTransactionLog_T1]
GO
/****** Object:  Table [dbo].[CpFeeTransactionLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CpFeeTransactionLog_T1](
	[Unique_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[FeeType_CODE] [char](2) NOT NULL,
	[AssessedYear_NUMB] [numeric](4, 0) NOT NULL,
	[Transaction_CODE] [char](4) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[Transaction_AMNT] [numeric](11, 2) NOT NULL,
	[AssessedTot_AMNT] [numeric](11, 2) NOT NULL,
	[RecoveredTot_AMNT] [numeric](11, 2) NOT NULL,
	[TypeDisburse_CODE] [char](5) NOT NULL,
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalSupportSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [CPFL_I1] PRIMARY KEY CLUSTERED 
(
	[Unique_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CPFL_BATCH_SOURCE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [CPFL_BATCH_SOURCE_I1] ON [dbo].[CpFeeTransactionLog_T1]
(
	[Batch_DATE] ASC,
	[SourceBatch_CODE] ASC,
	[Batch_NUMB] ASC,
	[SeqReceipt_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CPFL_MEMBER_FEETYPE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [CPFL_MEMBER_FEETYPE_I1] ON [dbo].[CpFeeTransactionLog_T1]
(
	[MemberMci_IDNO] ASC,
	[FeeType_CODE] ASC,
	[Case_IDNO] ASC,
	[AssessedYear_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'A sequential number generated for each record in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Unique_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Unique MCI assigned to CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID generated for the DECSS Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated internal order sequence number created for a support order for a given case. Each OrderSeq_NUMB corresponds to a Support Order from the SORD table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Internal Obligation Sequence of the Obligation for which this Support Log is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of fee assessed and recovered. Values are obtained from REFM (FEES/FTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'FeeType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Year on which the fee assessed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'AssessedYear_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the code for the fee transaction. Possible values are ASMT - Assessment, SREC - System Recovery, RDCA - Reversal-Decrease Assessment, RDCR - Reversal-Decrease Recovery.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the fee transaction was done.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of fee assessed or recovered for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of fee recovered for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'AssessedTot_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total amount of fee recovered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'RecoveredTot_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code Assigned to type of Disbursement. Values are obtained from REFM (DISB/PREV).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'TypeDisburse_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Deposit source indicates the origin of the receipt. Values are obtained from REFM (RCTB/RCTB).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Disbursement event.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSupportSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table stores the Special Collection Fee, DRA Fee And CP NSF Fee amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpFeeTransactionLog_T1'
GO
