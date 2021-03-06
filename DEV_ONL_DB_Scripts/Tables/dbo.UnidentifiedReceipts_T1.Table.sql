USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'StatusEscheat_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'StatusEscheat_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'UnidentifiedSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'UnidentifiedMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'IvdAgency_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Employer_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'IdentificationStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'OtherParty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Identified_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'IdentifiedPayorMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'CaseIdent_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Remarks_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankAcct_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankCountry_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorCountry_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Payor_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
/****** Object:  Index [URCT_DT_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [URCT_DT_BATCH_I1] ON [dbo].[UnidentifiedReceipts_T1]
GO
/****** Object:  Table [dbo].[UnidentifiedReceipts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[UnidentifiedReceipts_T1]
GO
/****** Object:  Table [dbo].[UnidentifiedReceipts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UnidentifiedReceipts_T1](
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[Payor_NAME] [varchar](71) NOT NULL,
	[PayorLine1_ADDR] [char](25) NOT NULL,
	[PayorLine2_ADDR] [char](25) NOT NULL,
	[PayorCity_ADDR] [char](20) NOT NULL,
	[PayorState_ADDR] [char](2) NOT NULL,
	[PayorZip_ADDR] [char](15) NOT NULL,
	[PayorCountry_ADDR] [char](30) NOT NULL,
	[Bank_NAME] [varchar](50) NOT NULL,
	[Bank1_ADDR] [char](25) NOT NULL,
	[Bank2_ADDR] [char](25) NOT NULL,
	[BankCity_ADDR] [char](20) NOT NULL,
	[BankState_ADDR] [char](2) NOT NULL,
	[BankZip_ADDR] [char](15) NOT NULL,
	[BankCountry_ADDR] [char](30) NOT NULL,
	[Bank_IDNO] [numeric](10, 0) NOT NULL,
	[BankAcct_NUMB] [numeric](17, 0) NOT NULL,
	[Remarks_TEXT] [varchar](328) NOT NULL,
	[CaseIdent_IDNO] [numeric](6, 0) NOT NULL,
	[IdentifiedPayorMci_IDNO] [numeric](10, 0) NOT NULL,
	[Identified_DATE] [date] NOT NULL,
	[OtherParty_IDNO] [numeric](9, 0) NOT NULL,
	[IdentificationStatus_CODE] [char](1) NOT NULL,
	[Employer_IDNO] [numeric](9, 0) NOT NULL,
	[IvdAgency_IDNO] [numeric](7, 0) NOT NULL,
	[UnidentifiedMemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[UnidentifiedSsn_NUMB] [numeric](9, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[StatusEscheat_DATE] [date] NOT NULL,
	[StatusEscheat_CODE] [char](2) NOT NULL,
 CONSTRAINT [URCT_I1] PRIMARY KEY CLUSTERED 
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
/****** Object:  Index [URCT_DT_BATCH_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [URCT_DT_BATCH_I1] ON [dbo].[UnidentifiedReceipts_T1]
(
	[Batch_DATE] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Deposit source indicates the origin of the receipt. Possible values will be stored in the VREFM table as Reference Values with Id_Table as RCTB. This value will always be the same as for column CD_SOURCE_BATCH_ORIG.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number. When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the receipt. Values are obtained from REFM (RCTS/RCTS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the payor name as it is entered by the worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Payor_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the payor''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the payor''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the payor''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the payor''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the payor''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store the payor''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'PayorCountry_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will capture the name of the bank, if the collection was received through check.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Bank''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Bank''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Bank''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Bank''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Bank''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Bank''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankCountry_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Routing number or any other ID of the bank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Bank_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The account number of the payor, if provided on the check.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BankAcct_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores any remarks provided by the worker or the external vendor like SDU.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Remarks_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Case ID, if the receipt is identified by case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'CaseIdent_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the payor ID value, if the receipt is identified by Payor ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'IdentifiedPayorMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the receipt was identified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Identified_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Other Party ID, if the receipt is refunded to another party.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'OtherParty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Will have the following status. U - Unidentified I - Identified O - Refund to Other party.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'IdentificationStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the ID Employer, if it was received from an Employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'Employer_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Denotes the office ID to which it was sent for research.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'IvdAgency_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the potential Payor ID for which it may be identified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'UnidentifiedMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the potential SSN for which it may be identified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'UnidentifiedSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This stores the date on which this disbursement record can be escheated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'StatusEscheat_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the status of escheatment as to whether it is pending or escheated etc. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1', @level2type=N'COLUMN',@level2name=N'StatusEscheat_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the details on the unidentified receipts in the system. This table has supporting information about the unidentified collection in addition to the RECEIPT table which stores the receipt level information. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnidentifiedReceipts_T1'
GO
