USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalUpdateSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'StatusUpdate_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'CasePrior20030101_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'8' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'NoticeSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Notice_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Table [dbo].[CpRecoupNotices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CpRecoupNotices_T1]
GO
/****** Object:  Table [dbo].[CpRecoupNotices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CpRecoupNotices_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[Notice_ID] [char](8) NOT NULL,
	[Notice_DATE] [date] NOT NULL,
	[NoticeSeq_NUMB] [numeric](1, 0) NOT NULL,
	[Transaction_AMNT] [numeric](11, 2) NOT NULL,
	[CasePrior20030101_INDC] [char](1) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[StatusUpdate_DATE] [date] NOT NULL,
	[EventGlobalUpdateSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Disburse_DATE] [date] NOT NULL,
	[ReasonOverpay_CODE] [char](2) NOT NULL,
 CONSTRAINT [CPNO_I1] PRIMARY KEY CLUSTERED 
(
	[Batch_DATE] ASC,
	[Batch_NUMB] ASC,
	[Case_IDNO] ASC,
	[CheckRecipient_CODE] ASC,
	[CheckRecipient_ID] ASC,
	[NoticeSeq_NUMB] ASC,
	[SeqReceipt_NUMB] ASC,
	[SourceBatch_CODE] ASC,
	[Disburse_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the OTHP ID of the entity that received the disbursement check when the CD_TYPE_RECIPIENT = 3.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the check recipient type.  Possible values are 1 MCI of the Member, 3   Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique number assigned to a case in the system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Identifies the source of the batch for which the receipt is created. Valid values are stored in REFM with id_table as RCTB and id_table_sub as RCTB. This is 2nd part of the receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique id assigned to the notices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date the Notice was sent to the Recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Notice_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'8', @value=N'Sequence number to the number of notice attempts. Maximum of three.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'NoticeSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the IV-D application was signed prior to 1/ 1/2 3.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'CasePrior20030101_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores the date when the response is received for a notice that was sent to the CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'StatusUpdate_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_STATUS_UPDATE. This should be zero when the corresponding DT_STATUS_UPDATE is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalUpdateSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table stores all the recoupment notice transactions for the CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpRecoupNotices_T1'
GO
