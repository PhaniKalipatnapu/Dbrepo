USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecoupmentPayee_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'TypeRecoupment_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSupportSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Unique_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecTotOverpay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecOverpay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'AssessTotOverpay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'AssessOverpay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecTotAdvance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecAdvance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'PendTotOffset_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'PendOffset_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'TypeDisburse_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Index [POFL_RECOUPMENT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [POFL_RECOUPMENT_I1] ON [dbo].[PayeeOffsetLog_T1]
GO
/****** Object:  Index [POFL_RCTH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [POFL_RCTH_I1] ON [dbo].[PayeeOffsetLog_T1]
GO
/****** Object:  Index [POFL_ID_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [POFL_ID_CASE_I1] ON [dbo].[PayeeOffsetLog_T1]
GO
/****** Object:  Table [dbo].[PayeeOffsetLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PayeeOffsetLog_T1]
GO
/****** Object:  Table [dbo].[PayeeOffsetLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PayeeOffsetLog_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[Transaction_CODE] [char](4) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[TypeDisburse_CODE] [char](5) NOT NULL,
	[Reason_CODE] [char](2) NOT NULL,
	[PendOffset_AMNT] [numeric](11, 2) NOT NULL,
	[PendTotOffset_AMNT] [numeric](11, 2) NOT NULL,
	[RecAdvance_AMNT] [numeric](11, 2) NOT NULL,
	[RecTotAdvance_AMNT] [numeric](11, 2) NOT NULL,
	[AssessOverpay_AMNT] [numeric](11, 2) NOT NULL,
	[AssessTotOverpay_AMNT] [numeric](11, 2) NOT NULL,
	[RecOverpay_AMNT] [numeric](11, 2) NOT NULL,
	[RecTotOverpay_AMNT] [numeric](11, 2) NOT NULL,
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[Unique_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalSupportSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TypeRecoupment_CODE] [char](1) NOT NULL,
	[RecoupmentPayee_CODE] [char](1) NOT NULL,
 CONSTRAINT [POFL_I1] PRIMARY KEY CLUSTERED 
(
	[Unique_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [POFL_ID_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [POFL_ID_CASE_I1] ON [dbo].[PayeeOffsetLog_T1]
(
	[Case_IDNO] ASC,
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [POFL_RCTH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [POFL_RCTH_I1] ON [dbo].[PayeeOffsetLog_T1]
(
	[Batch_DATE] ASC,
	[SourceBatch_CODE] ASC,
	[Batch_NUMB] ASC,
	[SeqReceipt_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [POFL_RECOUPMENT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [POFL_RECOUPMENT_I1] ON [dbo].[PayeeOffsetLog_T1]
(
	[CheckRecipient_ID] ASC,
	[CheckRecipient_CODE] ASC,
	[Unique_IDNO] ASC,
	[TypeRecoupment_CODE] ASC,
	[RecoupmentPayee_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement check when the CD_TYPE_RECIPIENT = 3.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the check recipient type. Possible values are 1 - MCI of the Member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique number assigned to a case in the system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Internal Obligation Sequence of the Obligation for which this recoupment is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the code for the recoupment transaction. Possible values are stored in VREFM with id_table as CREC and id_table_sub as DESC.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the recoupment transaction was done.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code Assigned to type of Disbursement.  Valid Values are stored in REFM with id_table as DISB and id_table_sub as DISB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'TypeDisburse_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the code for the transaction reason. Values are obtained from REFM (CREC / POFL)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the pending Recoupment amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'PendOffset_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the total pending Recoupment amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'PendTotOffset_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the amount recovered in advance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecAdvance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the total amount recovered in advance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecTotAdvance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the active recoupment amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'AssessOverpay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the total active recoupment amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'AssessTotOverpay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the recovered amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecOverpay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the total recovered amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecTotOverpay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Deposit source indicates the origin of the receipt. Possible values will be stored in the VREFM table as Reference Values with Id_Table as RCTB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number. When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'A sequential number generated for each record in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'Unique_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Distribution event.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSupportSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies whether the Recoupment type is regular or NSF. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'TypeRecoupment_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identified whether the recoupment payee is STATE or SDU. Possible values are S- STATE or D-SDU.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1', @level2type=N'COLUMN',@level2name=N'RecoupmentPayee_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores all over disbursement and Recovery amounts associated with each recipient. It further stores the balances at the recoupment payee level (SDU or State). All transactions affecting over disbursement are stored in this table and maintained' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PayeeOffsetLog_T1'
GO
