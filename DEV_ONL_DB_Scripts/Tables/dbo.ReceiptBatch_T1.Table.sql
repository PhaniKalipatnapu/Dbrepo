USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtActualTrans_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtControlTrans_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'RePost_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'StatusBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'ActualReceipt_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'ControlReceipt_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtActualReceipt_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtControlReceipt_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
/****** Object:  Index [RBAT_IND_REPOST_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RBAT_IND_REPOST_I1] ON [dbo].[ReceiptBatch_T1]
GO
/****** Object:  Index [RBAT_DT_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RBAT_DT_BATCH_I1] ON [dbo].[ReceiptBatch_T1]
GO
/****** Object:  Index [RBAT_CD_STATUS_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RBAT_CD_STATUS_BATCH_I1] ON [dbo].[ReceiptBatch_T1]
GO
/****** Object:  Table [dbo].[ReceiptBatch_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ReceiptBatch_T1]
GO
/****** Object:  Table [dbo].[ReceiptBatch_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReceiptBatch_T1](
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[CtControlReceipt_QNTY] [numeric](3, 0) NOT NULL,
	[CtActualReceipt_QNTY] [numeric](3, 0) NOT NULL,
	[ControlReceipt_AMNT] [numeric](11, 2) NOT NULL,
	[ActualReceipt_AMNT] [numeric](11, 2) NOT NULL,
	[TypeRemittance_CODE] [char](3) NOT NULL,
	[Receipt_DATE] [date] NOT NULL,
	[StatusBatch_CODE] [char](1) NOT NULL,
	[RePost_INDC] [char](1) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[CtControlTrans_QNTY] [numeric](3, 0) NOT NULL,
	[CtActualTrans_QNTY] [numeric](3, 0) NOT NULL,
 CONSTRAINT [RBAT_I1] PRIMARY KEY CLUSTERED 
(
	[Batch_DATE] ASC,
	[SourceBatch_CODE] ASC,
	[Batch_NUMB] ASC,
	[EventGlobalBeginSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RBAT_CD_STATUS_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RBAT_CD_STATUS_BATCH_I1] ON [dbo].[ReceiptBatch_T1]
(
	[BeginValidity_DATE] ASC,
	[RePost_INDC] ASC,
	[StatusBatch_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [RBAT_DT_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RBAT_DT_BATCH_I1] ON [dbo].[ReceiptBatch_T1]
(
	[EndValidity_DATE] ASC,
	[Batch_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RBAT_IND_REPOST_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RBAT_IND_REPOST_I1] ON [dbo].[ReceiptBatch_T1]
(
	[BeginValidity_DATE] ASC,
	[EndValidity_DATE] ASC,
	[RePost_INDC] ASC,
	[StatusBatch_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Deposit source indicates the origin of the receipt. Values are retrieved from REFM (RCTB/RCTB).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number. When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the receipt. This column will not have any value at this time, since we do not have online receipting. But this column will be retained for futuristic purposes. Values are retrieved from REFM (RCTS/RCTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The number of postings to the case/MCI in the batch. For example, a wage payment from the employer posted to three payors will be counted as a posting count of three.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtControlReceipt_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The actual posting count will increment by one with each line item posted by batch or on RPOS. The Actual Transaction Count will always be equal to or less than the Actual Posting Count.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtActualReceipt_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The actual dollar amount of the incoming receipts that will be posted to the batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'ControlReceipt_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The actual dollar amount of the incoming receipts that are posted by the batch or on RPOS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'ActualReceipt_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the type of remittance. Possible values will be stored in the REFM_V1 table as Reference Values with Id_Table as RCTP. This column will not have any value at this time, since we do not have online receipting. But this column will be retained for futuristic purposes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Actual Collection Date. This date is used by Distribution program to distribute the money to the appropriate month. This is used as a default value when entering receipts through Online.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the status of the batch. If all the control counts and amounts match with the actual, the batch can become reconciled. The Receipts associated to this batch can go through Distribution. Values are retrieved from REFM (BATS/CBAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'StatusBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will identify whether this batch is created for Original receipts or for Reposted receipts. The value is Y if it is assigned to Reposted receipts. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'RePost_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding EndValidity_DATE. This should be zero when the corresponding EndValidity_DATE is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The number of incoming receipts that will be posted to the batch.  For example, a wage payment from the employer posted to three payors will be counted as a transaction count of one.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtControlTrans_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The number of actual incoming receipts that are posted to the batch.  For example, a wage payment from the employer posted to three payors will be counted as a transaction count of one.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1', @level2type=N'COLUMN',@level2name=N'CtActualTrans_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the batch control of receipts. The key for the batch is the batch date, batch source and the batch number. This table stores the control and actual count of receipts for the receipt batch. When both the actual and control (number of receipts and total amounts) matches, the batch will be reconciled in batch status field with a R. only after the batch reconciles, will the distribution of the receipts in this batch take place. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReceiptBatch_T1'
GO
