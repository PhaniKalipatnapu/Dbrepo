USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'ToDistribute_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
/****** Object:  Index [PRREL_EVENTGLOBAL_NUMB_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [PRREL_EVENTGLOBAL_NUMB_I1] ON [dbo].[IntReleaseReceipt_T1] WITH ( ONLINE = OFF )
GO
/****** Object:  Table [dbo].[IntReleaseReceipt_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntReleaseReceipt_T1]
GO
/****** Object:  Table [dbo].[IntReleaseReceipt_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntReleaseReceipt_T1](
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
	[ReasonStatus_CODE] [char](4) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PRREL_EVENTGLOBAL_NUMB_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE CLUSTERED INDEX [PRREL_EVENTGLOBAL_NUMB_I1] ON [dbo].[IntReleaseReceipt_T1]
(
	[EventGlobalBeginSeq_NUMB] ASC,
	[SeqReceipt_NUMB] ASC,
	[Batch_NUMB] ASC,
	[SourceBatch_CODE] ASC,
	[Batch_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Date of the receipt that was applied in this transaction. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the batch for which the receipt is created. Valid values are stored in REFM with id_table as RCTB and id_table_sub as RCTB. This is 2nd part of the receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence.Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Source of the Payment from where we received Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the level of posting, whether at Payor or Case level.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the CASE_ID for which the money is to be posted. If a Case ID is entered, money will be posted to that Case ID. If the receipt is a payor identified receipt, then this field will be spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Payor MCI. The MCI of the person from whom the payment is received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount available for Distribution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'ToDistribute_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Actual Collection Date. This date is used by Distribution program to distribute the money to the appropriate month.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will record the check number or any other financial instrument identifying number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates IRS intercept is for TANF or Non-TANF.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indication if the receipt is an intercept of a joint-return. If so, the joint name will be recorded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If receipt is Held, then Identifies the reason for the hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is an intermediate table that is a Temporary Place holder to hold the Receipts that are released by the Release Receipt Program, till it get processed by the Distribution Batch' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntReleaseReceipt_T1'
GO
