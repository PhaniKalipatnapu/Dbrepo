USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'CollectionFeeOrig_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'CollectionOrig_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaidBy_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaidBy_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentInstruction3_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentInstruction2_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentInstruction1_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'SuspendPayment_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Release_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentSourceSdu_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'ReceiptFee_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorSuffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'RapidReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'RapidEnvelope_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Rapid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchItem_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadSduReceipts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadSduReceipts_T1]
GO
/****** Object:  Table [dbo].[LoadSduReceipts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadSduReceipts_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Batch_DATE] [char](8) NOT NULL,
	[Batch_NUMB] [char](4) NOT NULL,
	[BatchSeq_NUMB] [char](3) NOT NULL,
	[BatchItem_NUMB] [char](3) NOT NULL,
	[Batch_ID] [char](12) NOT NULL,
	[Rapid_IDNO] [char](7) NOT NULL,
	[RapidEnvelope_NUMB] [char](10) NOT NULL,
	[RapidReceipt_NUMB] [char](10) NOT NULL,
	[PayorMci_IDNO] [char](10) NOT NULL,
	[PayorSsn_NUMB] [char](9) NOT NULL,
	[PayorLast_NAME] [char](25) NOT NULL,
	[PayorFirst_NAME] [char](20) NOT NULL,
	[PayorMiddle_NAME] [char](20) NOT NULL,
	[PayorSuffix_NAME] [char](3) NOT NULL,
	[Receipt_AMNT] [char](15) NOT NULL,
	[ReceiptFee_AMNT] [char](15) NOT NULL,
	[PaymentMethod_CODE] [char](5) NOT NULL,
	[PaymentType_CODE] [char](5) NOT NULL,
	[PaymentSourceSdu_CODE] [char](3) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[TypeRemittance_CODE] [char](3) NOT NULL,
	[Receipt_DATE] [char](8) NOT NULL,
	[Release_DATE] [char](8) NOT NULL,
	[SuspendPayment_CODE] [char](1) NOT NULL,
	[CheckNo_TEXT] [char](18) NOT NULL,
	[PaymentInstruction1_TEXT] [varchar](76) NOT NULL,
	[PaymentInstruction2_TEXT] [varchar](76) NOT NULL,
	[PaymentInstruction3_TEXT] [varchar](76) NOT NULL,
	[PaidBy_NAME] [varchar](50) NOT NULL,
	[PaidBy_ID] [char](15) NOT NULL,
	[CollectionOrig_AMNT] [char](15) NOT NULL,
	[CollectionFeeOrig_AMNT] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LCSDU_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number. When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The Transaction Sequence enables the user to search and reverse all the receipts' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the posting sequence.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchItem_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Batch ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Identification Number of the RAPID ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Rapid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Envelope Number of the RAPID ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'RapidEnvelope_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Receipt Number of the RAPID ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'RapidReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies MCI of the person from whom the payment is received ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payor or Member SSN number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payor Last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payor First name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payor Middle name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payor Suffix' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorSuffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount of receipt collected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Fee Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'ReceiptFee_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payment method. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indentifies the Payment Type. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payment Source.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentSourceSdu_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Source Receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Remittance type. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Receipt Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Date of release.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Release_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment Hold or Release.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'SuspendPayment_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will record the check number or any other financial instrument identifying number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payment Instruction ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentInstruction1_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payment Instruction ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentInstruction2_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Payment Instruction ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentInstruction3_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Paid by name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaidBy_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Paid by ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaidBy_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the collection''s original amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'CollectionOrig_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the collection''s original fee amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'CollectionFeeOrig_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the collection data received from SDU in a file format on a daily basis.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadSduReceipts_T1'
GO
