USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ZeroBalanceDel_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'InjuredSpouse_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Fee_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'TypeOffset_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Payment_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'LocalTransfer_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'StateTransfer_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'OffsetYear_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'AdjustmentYear_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Adjustment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ArrearageCertified_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ObligorFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ObligorLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ReferenceIrs_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Local_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'StateSubmit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchItem_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadIrsReceipts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadIrsReceipts_T1]
GO
/****** Object:  Table [dbo].[LoadIrsReceipts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadIrsReceipts_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Batch_DATE] [char](8) NOT NULL,
	[Batch_NUMB] [char](4) NOT NULL,
	[BatchSeq_NUMB] [char](3) NOT NULL,
	[BatchItem_NUMB] [char](3) NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[StateSubmit_CODE] [char](2) NOT NULL,
	[Local_CODE] [char](3) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[ReferenceIrs_IDNO] [char](15) NOT NULL,
	[ObligorLast_NAME] [char](20) NOT NULL,
	[ObligorFirst_NAME] [char](15) NOT NULL,
	[ArrearageCertified_AMNT] [char](11) NOT NULL,
	[Receipt_AMNT] [char](11) NOT NULL,
	[Adjustment_AMNT] [char](11) NOT NULL,
	[AdjustmentYear_NUMB] [char](4) NOT NULL,
	[OffsetYear_NUMB] [char](4) NOT NULL,
	[TaxJoint_CODE] [char](1) NOT NULL,
	[Tanf_CODE] [char](1) NOT NULL,
	[StateTransfer_CODE] [char](2) NOT NULL,
	[LocalTransfer_CODE] [char](3) NOT NULL,
	[Payment_NAME] [char](35) NOT NULL,
	[PaymentLine1_ADDR] [char](35) NOT NULL,
	[PaymentCity_ADDR] [char](23) NOT NULL,
	[PaymentState_ADDR] [char](2) NOT NULL,
	[PaymentZip_ADDR] [char](9) NOT NULL,
	[TypeOffset_CODE] [char](3) NOT NULL,
	[Fee_AMNT] [char](5) NOT NULL,
	[InjuredSpouse_INDC] [char](1) NOT NULL,
	[ZeroBalanceDel_INDC] [char](1) NOT NULL,
	[CheckNo_TEXT] [char](9) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[TypeRemittance_CODE] [char](3) NOT NULL,
	[Receipt_DATE] [char](8) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_CODE] [char](1) NOT NULL,
 CONSTRAINT [LCIRS_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Receipt batch is created. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number. When a batch is created by a user, with all the required information, the system will automatically assign a batch number in the range of 8000-9999. Batch numbers for all batches created by the system, range from 0001-7999.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting. The Transaction Sequence enables the user to search and reverse all the receipts' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the posting sequence.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'BatchItem_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the batch source as IRS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the state abbreviation that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'StateSubmit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the local code that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Local_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the Social Security Number that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the case identification that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ReferenceIrs_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the obligor last name that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ObligorLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the obligor first name s that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ObligorFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the arrearage amount that is stored on the OCSE Case Master File at the time of certification. The certified arrearage amount is a signed positive numeric amount with two decimal places assumed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ArrearageCertified_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the amount of the offset that was sent to OCSE on the FMS Weekly Collection Record. The collection amount is a signed positive numeric amount with two decimal places assumed. If the Collection Amount Field contains a value greater than zero, the adjustment amount is zeroes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' This field contains the amount of the adjustment that was sent to OCSE on the FMS Weekly Collection Record. The adjustment amount is a signed positive numeric amount with two decimal places assumed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Adjustment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the year the offset originated that was sent to OCSE on the FMS Weekly Collection Record. The adjustment year is in the CCYY format.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'AdjustmentYear_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' This field contains the current processing year when the offset occurred, in the CCYY format.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'OffsetYear_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the return indicator that was sent to OCSE on the FMS Weekly Collection Record. The return indicator identifies whether or not this is a joint return.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the case type indicator that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' This field contains the transfer state code that was sent to OCSE by the state, and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'StateTransfer_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the transfer local code that was sent to OCSE by the state, and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'LocalTransfer_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' If the collection amount is greater than zero, this field contains the name on the FMS Payment Record. If the return indicator is equal to Y, this field may contain both obligor and/or non-obligor name(s). If the adjustment amount is greater than zero, this field contains spaces.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Payment_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the collection amount is greater than zero, this field contains the input payment street address that was sent to OCSE on the FMS Weekly Collection Record. If the adjustment amount is greater than zero, this field contains spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the collection amount is greater than zero, this field contains the input payment city and state that was sent to OCSE on the FMS Payment Record. If the adjustment amount is greater than zero, this field contains spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the collection amount is greater than zero, this field contains the input payment city that was sent to OCSE on the FMS Payment Record. If the adjustment amount is greater than zero, this field contains spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the collection amount is greater than zero, this field contains the input payment Zip Code that was sent to OCSE on the FMS Payment Record. If the adjustment amount is greater than zero, this field contains spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'PaymentZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the type of offset or adjustment that applied.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'TypeOffset_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the service fee amount for an adjustment that was sent to OCSE on the FMS Weekly Collection Record. The fee amount is a signed positive numeric amount with two decimal places assumed. If the collection amount contains a value greater than zero, the fee amount is zeroes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Fee_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the injured spouse indicator that was sent to OCSE on the FMS Weekly Collection Record. The injured spouse indicator identifies if an injured spouse claim has been processed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'InjuredSpouse_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the zero balance delete indicator that was set by OCSE to show that an offset reduced the modified arrearage amount for a case to zero. The case is deleted at OCSE but not FMS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'ZeroBalanceDel_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The trace number assigned to a collection by FMS and returned as an identifier with a collection or associated adjustment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Two character code that identifies the source of the receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Three character code that identifies the type of remittance for the collection.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'TypeRemittance_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Batch Process Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The status of the record. Possible values are N - Not processed, P - Collection Processed and Pending TRIP Address and Y - Processed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the collection data received from IRS in a file format on a daily basis.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIrsReceipts_T1'
GO
