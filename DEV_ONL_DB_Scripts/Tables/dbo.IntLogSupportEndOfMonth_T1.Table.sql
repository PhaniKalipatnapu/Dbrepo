USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotFuture_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionFuture_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TypeRecord_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Distribute_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotNonIvd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotNonIvd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionNonIvd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotNffc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotNffc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionNffc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotMedi_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotMedi_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionMedi_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotIvef_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotIvef_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionIvef_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotUda_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotUda_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionUda_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotUpa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotUpa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionUpa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotCaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotCaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionCaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotTaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotTaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionTaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotPaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotPaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionPaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotNaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotNaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionNaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotExptPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotExptPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionExptPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'MtdCurSupOwed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'SupportYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[IntLogSupportEndOfMonth_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntLogSupportEndOfMonth_T1]
GO
/****** Object:  Table [dbo].[IntLogSupportEndOfMonth_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntLogSupportEndOfMonth_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[SupportYearMonth_NUMB] [numeric](6, 0) NOT NULL,
	[TypeWelfare_CODE] [char](1) NOT NULL,
	[TransactionCurSup_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotCurSup_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotCurSup_AMNT] [numeric](11, 2) NOT NULL,
	[MtdCurSupOwed_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionExptPay_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotExptPay_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotExptPay_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionNaa_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotNaa_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotNaa_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionPaa_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotPaa_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotPaa_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionTaa_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotTaa_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotTaa_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionCaa_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotCaa_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotCaa_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionUpa_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotUpa_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotUpa_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionUda_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotUda_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotUda_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionIvef_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotIvef_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotIvef_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionMedi_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotMedi_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotMedi_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionNffc_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotNffc_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotNffc_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionNonIvd_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotNonIvd_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotNonIvd_AMNT] [numeric](11, 2) NOT NULL,
	[Batch_DATE] [date] NOT NULL,
	[SourceBatch_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [numeric](4, 0) NOT NULL,
	[SeqReceipt_NUMB] [numeric](6, 0) NOT NULL,
	[Receipt_DATE] [date] NOT NULL,
	[Distribute_DATE] [date] NOT NULL,
	[TypeRecord_CODE] [char](1) NOT NULL,
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TransactionFuture_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotFuture_AMNT] [numeric](11, 2) NOT NULL,
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
 CONSTRAINT [PLEOM_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[EventGlobalSeq_NUMB] ASC,
	[ObligationSeq_NUMB] ASC,
	[OrderSeq_NUMB] ASC,
	[SupportYearMonth_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated Internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Internal Obligation Sequence of the Obligation for which this Disbursement Hold Log is created.  If the Check is issued to other party, then SEQ_OBLIGATION will be 0 as there is no obligation for other party.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Month in which the receipt is applied.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'SupportYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the welfare type of the member.  Values are obtained from REFM (CTYP/CTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Current Support for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Current Support amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Current Support amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Current Support owed for the month.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'MtdCurSupOwed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Expect To Pay for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionExptPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Expect to Pay amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotExptPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Expect To Pay Amount Paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotExptPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Never Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionNaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Never Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotNaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Never Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotNaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Permanently Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionPaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Permanently Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotPaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Permanently AssigTotal Permanently Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotPaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Temporarily Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionTaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Temporarily Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotTaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Temporarily Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotTaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Conditionally Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionCaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Conditionally Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotCaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Conditionally Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotCaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Unassigned Prior to Assistance Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionUpa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned Prior to Assistance arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotUpa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned Prior to Assistance arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotUpa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Unassigned During Assistance Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionUda_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned During Assistance arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotUda_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned During Assistance arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotUda_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards IV-E Foster Care for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionIvef_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total IV-E Foster Care amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotIvef_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total IV-E Foster Care amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotIvef_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Medicaid for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionMedi_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Medicaid amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotMedi_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Medicaid amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotMedi_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Non Federal Foster Care for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionNffc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non Federal Foster Care amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotNffc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non Federal Foster Care amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotNffc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Non IV-D for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionNonIvd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non IV-D amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'OweTotNonIvd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non IV-D amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotNonIvd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Date of the receipt that was applied in this transaction. This is 1st part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Batch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the source of the batch for which the receipt is created.  Valid values are stored in REFM with id_table as RCTB and id_table_sub as RCTB. This is 2nd part of the receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'SourceBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number of the receipt that was applied in this transaction. This is 3rd part of the Receipt number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence. Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.  The first three digits of the Receipt Sequence is the Transaction Sequence and the next three digits of the Receipt Sequence is the Posting Sequence.Each payment transaction (for example, a wage payment from an employer containing payment for three payers is a Transaction) is identified by a Transaction Sequence within the batch. For each Transaction Sequence, the Posting Sequence will start from 001 and is incremented by one for each additional posting.The Transaction Sequence enables the user to search and reverse all the receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'SeqReceipt_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Displays the date that the receipt was generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date on which the check was distributed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'Distribute_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the original transaction records. Valid Values are: O ? Original Transaction Records P ? Carried Forward Transaction Records C ? Circular Rule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TypeRecord_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the event which creates this record. Possible Events are: Accrual, Accrual Adjustment, Arrear Adjustment, Distribution Back out.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Futures amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'TransactionFuture_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total non_TANF Futures amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'AppTotFuture_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'PIN of the participant who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement check when the CD_TYPE_RECIPIENT = 3.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the check recipient type.Valid Values are as follows:1 - MCI of the member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used by the Batch Month support program that roll over the LOG_SUPPORT balance from the previous month to the current month. It stores details for every Case Obligation that is processed and then move the information from this temporary table to LOG_SUPPORT in one insert statement' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntLogSupportEndOfMonth_T1'
GO
