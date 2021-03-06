USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'ReceiptCurrent_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'ReasonRePost_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'RePost_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'StatusMatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SeqReceiptOrig_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SourceBatchOrig_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
/****** Object:  Index [RCTR_ORIG_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTR_ORIG_I1] ON [dbo].[ReceiptRePost_T1]
GO
/****** Object:  Table [dbo].[ReceiptRePost_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ReceiptRePost_T1]
GO
/****** Object:  Table [dbo].[ReceiptRePost_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReceiptRePost_T1](
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[BatchOrig_DATE] [date] NOT NULL,
	[SourceBatchOrig_CODE] [char](3) NOT NULL,
	[BatchOrig_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceiptOrig_NUMB] [numeric](6, 0) NOT NULL,
	[StatusMatch_CODE] [char](1) NOT NULL,
	[RePost_DATE] [date] NOT NULL,
	[ReasonRePost_CODE] [char](2) NOT NULL,
	[ReceiptCurrent_AMNT] [numeric](11, 2) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [RCTR_I1] PRIMARY KEY CLUSTERED 
(
	[Batch_DATE] ASC,
	[SourceBatch_CODE] ASC,
	[Batch_NUMB] ASC,
	[SeqReceipt_NUMB] ASC,
	[EventGlobalBeginSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RCTR_ORIG_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTR_ORIG_I1] ON [dbo].[ReceiptRePost_T1]
(
	[BatchOrig_DATE] ASC,
	[BatchOrig_NUMB] ASC,
	[SourceBatchOrig_CODE] ASC,
	[SeqReceiptOrig_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Deposit source indicates the origin of the receipt. Possible values will be stored in the VREFM table as Reference Values with Id_Table as RCTB. This value will always be the same as for column CD_SOURCE_BATCH_ORIG.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number. When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence.Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the batch originated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the batch for which the receipt is created (originally posted). Deposit source indicates the origin of the receipt. Possible values will be stored in the VREFM table as Reference Values with Id_Table as RCTB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SourceBatchOrig_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Batch Number that the receipt was originally posted to.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The sequence number of the receipt within the original batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'SeqReceiptOrig_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies whether or not the batch totals match the receipt totals.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'StatusMatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the receipt has been reposted, this will contain the Date in which the receipt was reposted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'RePost_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason code given to explain why a receipt was reposted. Values are queried in REFM with ID_TABLE = RCTR, ID_TABLE_SUB = RCTR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'ReasonRePost_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The amount of the Current receipt after it has been reposted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'ReceiptCurrent_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the details about the reposted receipts for the original receipt that was reversed. System allows muliple reposts for every original receipt. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptRePost_T1'
GO
