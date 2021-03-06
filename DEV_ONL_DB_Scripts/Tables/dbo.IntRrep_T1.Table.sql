USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'CasePayorMCIReposted_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'RepostedPayorMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Distd_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCounty_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'ClosedCase_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCase_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Refund_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Distributed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Held_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Ncp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'CasePayorMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Refund_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'RePost_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'BackOut_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Session_ID'

GO
/****** Object:  Index [RREP_ID_SESSION_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RREP_ID_SESSION_I1] ON [dbo].[IntRrep_T1]
GO
/****** Object:  Table [dbo].[IntRrep_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntRrep_T1]
GO
/****** Object:  Table [dbo].[IntRrep_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntRrep_T1](
	[Session_ID] [char](30) NOT NULL,
	[BackOut_INDC] [char](1) NOT NULL,
	[RePost_INDC] [char](1) NOT NULL,
	[Refund_INDC] [char](1) NOT NULL,
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[Receipt_DATE] [date] NOT NULL,
	[PayorMCI_IDNO] [numeric](10, 0) NOT NULL,
	[CasePayorMCI_IDNO] [numeric](10, 0) NOT NULL,
	[Ncp_NAME] [varchar](60) NOT NULL,
	[Receipt_AMNT] [numeric](11, 2) NOT NULL,
	[Held_AMNT] [numeric](11, 2) NOT NULL,
	[Distributed_AMNT] [numeric](11, 2) NOT NULL,
	[Refund_AMNT] [numeric](11, 2) NOT NULL,
	[MultiCase_INDC] [char](1) NOT NULL,
	[ClosedCase_INDC] [char](1) NOT NULL,
	[MultiCounty_INDC] [char](1) NOT NULL,
	[Distd_INDC] [char](1) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[RepostedPayorMci_IDNO] [numeric](10, 0) NOT NULL,
	[CasePayorMCIReposted_IDNO] [numeric](10, 0) NOT NULL,
 CONSTRAINT [PRREP_I1] PRIMARY KEY CLUSTERED 
(
	[Batch_DATE] ASC,
	[Batch_NUMB] ASC,
	[SeqReceipt_NUMB] ASC,
	[SourceBatch_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RREP_ID_SESSION_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RREP_ID_SESSION_I1] ON [dbo].[IntRrep_T1]
(
	[Session_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique session ID to identify the records associated with the particular transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Session_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies whether or not a receipt has been backed out. Valid Values are as follows: Y/N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'BackOut_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column indicates whether the user selected the receipt to be reposted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'RePost_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column indicates whether the user selected reposted receipt to be refunded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Refund_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Batch Date of the receipt that was applied in this transaction. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the source of the batch for which the receipt is created. Valid values are stored in REFM with id_table as RCTB and id_table_sub as RCTB. This is 2nd part of the receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence.Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the receipt: Possible values will be stored in the VREFM table as Reference Values with Id_Table as RCTS and id_table_sub = RCTS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Receipt Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Payor MCI. The MCI of the person from whom the payment is received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the value of either Case ID or the Payor ID depending upon the cd_type_hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'CasePayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This Field displays the Payor name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Ncp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount of receipt collected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This  field displays the Held amount from the receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Held_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount available for Distribution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Distributed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field display the amount that were refunded from the receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Refund_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This Field Indicates whether the receipt is distributed to more than one case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCase_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field indicates whether the receipt was distributed to any closed case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'ClosedCase_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This Field Indicates whether the receipt is distributed to multi county case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCounty_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This Field Indicates whether the receipt was distributed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Distd_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the effective date on which the actual payment was made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field stores the Payor MCI associated with the receipt to be reposted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'RepostedPayorMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field stores the Case ID/Payor MCI associated with the receipt to be reposted. This will be entered by the user from the RREP screen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1', @level2type=N'COLUMN',@level2name=N'CasePayorMCIReposted_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is an inetrmediate Table that is used to store all the information for the receipts that were selected from RREP screens to be reversed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntRrep_T1'
GO
