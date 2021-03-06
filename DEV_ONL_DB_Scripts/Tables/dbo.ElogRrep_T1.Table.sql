USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCounty_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'ClosedCase_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCase_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'Refund_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'RePost_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'SeqReceiptOrig_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'SourceBatchOrig_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalRefundSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalRePostSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBackOutSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalRrepSeq_NUMB'

GO
/****** Object:  Index [ELRP_ORIG_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ELRP_ORIG_I1] ON [dbo].[ElogRrep_T1]
GO
/****** Object:  Table [dbo].[ElogRrep_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ElogRrep_T1]
GO
/****** Object:  Table [dbo].[ElogRrep_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ElogRrep_T1](
	[EventGlobalRrepSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalBackOutSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalRePostSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalRefundSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BatchOrig_DATE] [date] NOT NULL,
	[SourceBatchOrig_CODE] [char](3) NOT NULL,
	[BatchOrig_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceiptOrig_NUMB] [numeric](6, 0) NOT NULL,
	[RePost_INDC] [char](1) NOT NULL,
	[Refund_INDC] [char](1) NOT NULL,
	[MultiCase_INDC] [char](1) NOT NULL,
	[ClosedCase_INDC] [char](1) NOT NULL,
	[MultiCounty_INDC] [char](1) NOT NULL,
 CONSTRAINT [ELRP_I1] PRIMARY KEY CLUSTERED 
(
	[EventGlobalBackOutSeq_NUMB] ASC,
	[EventGlobalRrepSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ELRP_ORIG_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ELRP_ORIG_I1] ON [dbo].[ElogRrep_T1]
(
	[BatchOrig_DATE] ASC,
	[SourceBatchOrig_CODE] ASC,
	[BatchOrig_NUMB] ASC,
	[SeqReceiptOrig_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This column stores the global event sequence to link all the receipts that were reversed in the particular transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalRrepSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This column stores the global event sequence associated with the reversal of the original receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBackOutSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores the global event sequence associated with the receipt that was reposted for the receipt reversed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalRePostSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores the global event sequence associated with the refund from the reposted receipt if any.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalRefundSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column identifies the batch date of the original receipt that was reversed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column identifies the deposit source of the original receipt source that was reversed. Values are obtained from REFM (RCTB/RCTB).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'SourceBatchOrig_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column identifies the batch number of the original receipt that was reversed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'BatchOrig_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column identifies the receipt sequence of the original receipt that was reversed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'SeqReceiptOrig_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column indicates whether the user selected the receipt to be reposted. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'RePost_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column indicates whether the user selected reposted receipt to be refunded. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'Refund_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This Field indicates whether the receipt is distributed to more than one case. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCase_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field indicates whether the receipt was distributed to any closed case. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'ClosedCase_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This Field indicates whether the receipt is distributed to multi county case. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1', @level2type=N'COLUMN',@level2name=N'MultiCounty_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores all the receipts that were reversed on a single transaction from the RREP screen. All these receipts are linked with Sequence Event Global Reversal and Repost to show them in the ELOG screen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElogRrep_T1'
GO
