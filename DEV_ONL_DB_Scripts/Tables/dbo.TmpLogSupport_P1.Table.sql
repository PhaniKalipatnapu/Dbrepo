USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotNonIvd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotNonIvd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionNonIvd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotNffc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotNffc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionNffc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotFuture_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionFuture_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotMedi_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotMedi_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionMedi_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotIvef_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotIvef_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionIvef_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotUda_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotUda_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionUda_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotUpa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotUpa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionUpa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotCaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotCaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionCaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotTaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotTaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionTaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotPaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotPaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionPaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotNaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotNaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionNaa_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotExptPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotExptPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionExptPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'MtdCurSupOwed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'SupportYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[TmpLogSupport_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[TmpLogSupport_P1]
GO
/****** Object:  Table [dbo].[TmpLogSupport_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TmpLogSupport_P1](
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
	[TransactionFuture_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotFuture_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionNffc_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotNffc_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotNffc_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionNonIvd_AMNT] [numeric](11, 2) NOT NULL,
	[OweTotNonIvd_AMNT] [numeric](11, 2) NOT NULL,
	[AppTotNonIvd_AMNT] [numeric](11, 2) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Internal Obligation Sequence of the Obligation for which this Support Log is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Year-Month YYYYMM for which the transaction has been adjusted or applied.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'SupportYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the welfare type of the member.  Values are obtained from REFM (CTYP/CTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Current Support for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Current Support amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Current Support amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Current Support owed for the month.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'MtdCurSupOwed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Expect to pay for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionExptPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Expect to pay amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotExptPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Expect To Pay Amount Paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotExptPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Never Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionNaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Never Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotNaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Never Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotNaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Permanently Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionPaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Permanently Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotPaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Permanently Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotPaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Temporarily Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionTaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Temporarily Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotTaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Temporarily Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotTaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Conditionally Assigned Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionCaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Conditionally Assigned Arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotCaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Conditionally Assigned Arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotCaa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Unassigned Prior to Assistance Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionUpa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned Prior to Assistance arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotUpa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned Prior to Assistance arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotUpa_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount adjusted or applied towards Unassigned during Assistance Arrears for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionUda_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned during Assistance arrears amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotUda_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Unassigned during Assistance arrears amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotUda_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards IV-E Foster Care for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionIvef_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total IV-E Foster Care amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotIvef_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total IV-E Foster Care amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotIvef_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Medicaid for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionMedi_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Medicaid amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotMedi_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Medicaid amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotMedi_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Futures amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionFuture_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total non_TANF Futures amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotFuture_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Non Federal Foster Care for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionNffc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non Federal Foster Care amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotNffc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non Federal Foster Care amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotNffc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards Non IV-D for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'TransactionNonIvd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non IV-D amount owed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'OweTotNonIvd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Non IV-D amount paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'AppTotNonIvd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is global temporary table that it used by MHIS screen to do the sweeping and upsweeping of the assigned arrears when the program type is changed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpLogSupport_P1'
GO
