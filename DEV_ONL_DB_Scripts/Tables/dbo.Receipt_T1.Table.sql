USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'RefundRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'RefundRecipient_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ReferenceIrs_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Release_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Refund_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ReasonBackOut_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'BackOut_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'StatusReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Distribute_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Check_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Employer_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Fee_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ToDistribute_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
/****** Object:  Index [RCTH_PAYOR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_PAYOR_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Index [RCTH_EBI1_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_EBI1_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Index [RCTH_DT_RECEIPT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_DT_RECEIPT_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Index [RCTH_DT_DISTRIBUTE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_DT_DISTRIBUTE_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Index [RCTH_DT_BEG_VALIDITY_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_DT_BEG_VALIDITY_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Index [RCTH_CD_STATUS_RECEIPT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_CD_STATUS_RECEIPT_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Index [RCTH_CD_SOURCE_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_CD_SOURCE_BATCH_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Index [RCTH_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [RCTH_CASE_I1] ON [dbo].[Receipt_T1]
GO
/****** Object:  Table [dbo].[Receipt_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Receipt_T1]
GO
/****** Object:  Table [dbo].[Receipt_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Receipt_T1](
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[TypeRemittance_CODE] [char](3) NOT NULL,
	[TypePosting_CODE] [char](1) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[PayorMCI_IDNO] [numeric](10, 0) NOT NULL,
	[Receipt_AMNT] [numeric](11, 2) NOT NULL,
	[ToDistribute_AMNT] [numeric](11, 2) NOT NULL,
	[Fee_AMNT] [numeric](11, 2) NOT NULL,
	[Employer_IDNO] [numeric](9, 0) NOT NULL,
	[Fips_CODE] [char](7) NOT NULL,
	[Check_DATE] [date] NOT NULL,
	[CheckNo_TEXT] [char](18) NOT NULL,
	[Receipt_DATE] [date] NOT NULL,
	[Distribute_DATE] [date] NOT NULL,
	[Tanf_CODE] [char](1) NOT NULL,
	[TaxJoint_CODE] [char](1) NOT NULL,
	[TaxJoint_NAME] [char](35) NOT NULL,
	[StatusReceipt_CODE] [char](1) NOT NULL,
	[ReasonStatus_CODE] [char](4) NOT NULL,
	[BackOut_INDC] [char](1) NOT NULL,
	[ReasonBackOut_CODE] [char](2) NOT NULL,
	[Refund_DATE] [date] NOT NULL,
	[Release_DATE] [date] NOT NULL,
	[ReferenceIrs_IDNO] [numeric](15, 0) NOT NULL,
	[RefundRecipient_ID] [char](10) NOT NULL,
	[RefundRecipient_CODE] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [RCTH_I1] PRIMARY KEY CLUSTERED 
(
	[Batch_DATE] ASC,
	[Batch_NUMB] ASC,
	[EventGlobalBeginSeq_NUMB] ASC,
	[SeqReceipt_NUMB] ASC,
	[SourceBatch_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [RCTH_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_CASE_I1] ON [dbo].[Receipt_T1]
(
	[Case_IDNO] ASC,
	[Receipt_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RCTH_CD_SOURCE_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_CD_SOURCE_BATCH_I1] ON [dbo].[Receipt_T1]
(
	[Batch_DATE] ASC,
	[SourceBatch_CODE] ASC,
	[TypeRemittance_CODE] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RCTH_CD_STATUS_RECEIPT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_CD_STATUS_RECEIPT_I1] ON [dbo].[Receipt_T1]
(
	[Batch_DATE] ASC,
	[StatusReceipt_CODE] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RCTH_DT_BEG_VALIDITY_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_DT_BEG_VALIDITY_I1] ON [dbo].[Receipt_T1]
(
	[StatusReceipt_CODE] ASC,
	[BeginValidity_DATE] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RCTH_DT_DISTRIBUTE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_DT_DISTRIBUTE_I1] ON [dbo].[Receipt_T1]
(
	[ToDistribute_AMNT] ASC,
	[Distribute_DATE] ASC,
	[StatusReceipt_CODE] ASC,
	[ReasonStatus_CODE] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [RCTH_DT_RECEIPT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_DT_RECEIPT_I1] ON [dbo].[Receipt_T1]
(
	[Receipt_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RCTH_EBI1_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_EBI1_I1] ON [dbo].[Receipt_T1]
(
	[Distribute_DATE] ASC,
	[EndValidity_DATE] ASC
)
INCLUDE ( 	[Batch_DATE],
	[Batch_NUMB],
	[Case_IDNO],
	[PayorMCI_IDNO],
	[ReasonStatus_CODE],
	[SeqReceipt_NUMB],
	[SourceBatch_CODE],
	[SourceReceipt_CODE],
	[StatusReceipt_CODE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [RCTH_PAYOR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [RCTH_PAYOR_I1] ON [dbo].[Receipt_T1]
(
	[PayorMCI_IDNO] ASC,
	[Receipt_DATE] ASC,
	[Release_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Deposit source indicates the origin of the receipt. Values are obtained from REFM (RCTB/RCTB)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number. When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the receipt. Values are obtained from REFM (RCTS/RCTS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the type of remittance. Values are obtained from REFM (RCTP/RCTP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the level of posting. Values are obtained from REFM (RCTS/POST)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the CASE_ID for which the money is to be posted. If a Case ID is entered, money will be posted to that Case ID. If the receipt is a payor identified receipt, then this field will be spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Payor MCI. The MCI of the person from whom the payment is received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount of receipt collected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount available for Distribution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ToDistribute_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the fee amount collected by another state from the payor and is included in the receipt amount on the record, but withheld from the amount that is actually sent to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Fee_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Employer FEIN (Federal Identification Number) of the employer from whom the money is received. Currently this value is not provided by SDU vendor. This column is retained for future purposes in case if DACSES gets to receive from SDU at a later time. This will have lesser impact by including it now.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Employer_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the FIPS (Federal Information Processing Standard) code of the state from which the money is received. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on the check or other financial instrument. Currently this value is not provided by SDU vendor. This column is retained for future purposes in case if DACSES gets to receive from SDU at a later time. This will have lesser impact by including it now.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Check_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will record the check number or any other financial instrument identifying number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Actual Collection Date. This date is used by Distribution program to distribute the money to the appropriate month.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date on which the Receipt was distributed to Recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Distribute_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates IRS intercept is for TANF or Non-TANF. Values are obtained from REFM (TANF/TYPE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indication if the receipt is an intercept of a joint-return. If so, the joint name will be recorded. Values are obtained from REFM (TAXI/ACCT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the name of the individual named in the joint tax return (other than case member).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Status Code assigned to the receipt. Values are obtained from REFM (STAB/STAB)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'StatusReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If receipt is Held, then identifies the reason for the hold. Values are obtained from REFM (RERT/REAS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies whether or not a receipt has been backed out. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'BackOut_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason code given to explain why receipt was backed out. Values are obtained from REFM (CREC/REVR)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ReasonBackOut_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date the receipt is released from hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Refund_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date the receipt is released from hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'Release_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the case_ID value that will be sent by the SDU even though it is identified as a payor level receipt. Stored for information purposes only.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'ReferenceIrs_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the fund recipient ID to whom the amount was refunded to. Values are obtained from REFM (RDCR/REFT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'RefundRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the type of the recipient. Values are obtained from REFM (RDCR/REFT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'RefundRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the details of all the collections received in the system. Batch date, Batch source, Batch number, and the receipt sequence number will form the key of the receipt. This table will have the original, reposted, held, undistributed, refunded and distributed receipts. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Receipt_T1'
GO
