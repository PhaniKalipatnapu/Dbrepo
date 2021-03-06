USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'AutomaticRelease_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'ReleasedFrom_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'ToDistribute_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'RecordRowNumber_NUMB'

GO
/****** Object:  Index [PDIST_PAYOR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [PDIST_PAYOR_I1] ON [dbo].[IntDistDaily_T1]
GO
/****** Object:  Index [PDIST_IND_PROCESS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [PDIST_IND_PROCESS_I1] ON [dbo].[IntDistDaily_T1]
GO
/****** Object:  Table [dbo].[IntDistDaily_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntDistDaily_T1]
GO
/****** Object:  Table [dbo].[IntDistDaily_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntDistDaily_T1](
	[RecordRowNumber_NUMB] [numeric](15, 0) NOT NULL,
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[TypePosting_CODE] [char](1) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[PayorMCI_IDNO] [numeric](10, 0) NOT NULL,
	[ToDistribute_AMNT] [numeric](11, 2) NOT NULL,
	[Receipt_DATE] [date] NOT NULL,
	[Check_NUMB] [numeric](19, 0) NOT NULL,
	[Tanf_CODE] [char](1) NOT NULL,
	[TaxJoint_CODE] [char](1) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ReleasedFrom_CODE] [char](4) NOT NULL,
	[AutomaticRelease_INDC] [char](1) NOT NULL,
	[Process_CODE] [char](1) NOT NULL,
 CONSTRAINT [PDIST_I1] PRIMARY KEY CLUSTERED 
(
	[RecordRowNumber_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PDIST_IND_PROCESS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [PDIST_IND_PROCESS_I1] ON [dbo].[IntDistDaily_T1]
(
	[Process_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PDIST_PAYOR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [PDIST_PAYOR_I1] ON [dbo].[IntDistDaily_T1]
(
	[PayorMCI_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This indicates the record rownumber for each record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'RecordRowNumber_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Receipt batch is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Deposit source indicates the origin of the receipt. Possible values will be stored in the VREFM table as Reference Values with Id_Table as RCTB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number.  When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence.Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch.For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.The The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence.Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch.For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.The Transaction Sequence enables the user to search and reverse all the receipts in one transaction, in a specific batch, as a single unit.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the receipt: Possible values will be stored in the VREFM table as Reference Values with Id_Table RCTS and id_table_sub RCTS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the level of posting, whether at Payor or Case level.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the CASE_ID for which the money is to be posted. If a Case ID is entered, money will be posted to that Case ID. If the receipt is a payor identified receipt, then this field will be spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Payor MCI. The MCI of the person from whom the payment is received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount available for Distribution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'ToDistribute_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Actual Collection Date. This date is used by Distribution program to distribute the money to the appropriate month.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will record the check number or any other financial instrument identifying number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates IRS intercept is for TANF or Non-TANF.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indication if the receipt is an intercept of a joint-return. If so, the joint name will be recorded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the reason for the hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'ReleasedFrom_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the receipt is released by system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'AutomaticRelease_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates process of records.Values are Y-processed records, N-Not processed records, A-Records which caused Abend.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store all the records which are going to be processed by regular distribution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDistDaily_T1'
GO
