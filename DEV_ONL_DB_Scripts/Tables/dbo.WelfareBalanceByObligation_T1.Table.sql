USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistExpend_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistExpend_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistExpend_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [WEMO_ID_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [WEMO_ID_CASE_I1] ON [dbo].[WelfareBalanceByObligation_T1]
GO
/****** Object:  Index [WEMO_CASE_WELFARE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [WEMO_CASE_WELFARE_I1] ON [dbo].[WelfareBalanceByObligation_T1]
GO
/****** Object:  Table [dbo].[WelfareBalanceByObligation_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[WelfareBalanceByObligation_T1]
GO
/****** Object:  Table [dbo].[WelfareBalanceByObligation_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WelfareBalanceByObligation_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[WelfareYearMonth_NUMB] [numeric](6, 0) NOT NULL,
	[TransactionAssistExpend_AMNT] [numeric](11, 2) NOT NULL,
	[MtdAssistExpend_AMNT] [numeric](11, 2) NOT NULL,
	[LtdAssistExpend_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionAssistRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[MtdAssistRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[LtdAssistRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
 CONSTRAINT [WEMO_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[CaseWelfare_IDNO] ASC,
	[EventGlobalBeginSeq_NUMB] ASC,
	[ObligationSeq_NUMB] ASC,
	[OrderSeq_NUMB] ASC,
	[WelfareYearMonth_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [WEMO_CASE_WELFARE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [WEMO_CASE_WELFARE_I1] ON [dbo].[WelfareBalanceByObligation_T1]
(
	[CaseWelfare_IDNO] ASC,
	[WelfareYearMonth_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [WEMO_ID_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [WEMO_ID_CASE_I1] ON [dbo].[WelfareBalanceByObligation_T1]
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC,
	[ObligationSeq_NUMB] ASC,
	[CaseWelfare_IDNO] ASC,
	[WelfareYearMonth_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the case number of which the support order is associated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'This is a system generated internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Internal Obligation Sequence of the Obligation for which this Grant Log is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Welfare Case ID, Created at CP level when any one dependant of the CP is in welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Year-Month YYYYMM for which the welfare record is being created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the amount of assistance expended for the transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistExpend_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column displays the life to date amount of assistance expended.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistExpend_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Life to date grant assessed from the date the grant began.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistExpend_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of assistance recouped for the transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Month to Date grant recouped from the date the grant began.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Life to Date Grant Recouped from the date the grant began.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the URA expended and recouped  amount for every Case Obligation associated with an IVA Case. The balances are stored for every month and rolled over to the next month. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WelfareBalanceByObligation_T1'
GO
