USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'Defra_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'AdjustLtdFlag_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'ZeroGrant_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'TypeAdjust_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistExpend_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistExpend_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistExpend_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'WelfareElig_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
/****** Object:  Table [dbo].[IvaIveGrant_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IvaIveGrant_T1]
GO
/****** Object:  Table [dbo].[IvaIveGrant_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IvaIveGrant_T1](
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[WelfareYearMonth_NUMB] [numeric](6, 0) NOT NULL,
	[WelfareElig_CODE] [char](1) NOT NULL,
	[TransactionAssistExpend_AMNT] [numeric](11, 2) NOT NULL,
	[MtdAssistExpend_AMNT] [numeric](11, 2) NOT NULL,
	[LtdAssistExpend_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionAssistRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[MtdAssistRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[LtdAssistRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[TypeAdjust_CODE] [char](1) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ZeroGrant_INDC] [char](1) NOT NULL,
	[AdjustLtdFlag_INDC] [char](1) NOT NULL,
	[Defra_AMNT] [numeric](11, 2) NOT NULL,
	[CpMci_IDNO] [numeric](10, 0) NOT NULL,
 CONSTRAINT [IVMG_I1] PRIMARY KEY CLUSTERED 
(
	[CaseWelfare_IDNO] ASC,
	[CpMci_IDNO] ASC,
	[WelfareYearMonth_NUMB] ASC,
	[WelfareElig_CODE] ASC,
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Welfare Case ID, Created at CP level when any one dependant of the CP is in welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Year-Month YYYYMM for which the welfare record is being created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Identifies if case is eligible for welfare. Possible values are A - TANF and F - Foster Care.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'WelfareElig_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of grant expended for this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistExpend_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the month to date amount of assistance expended for the month displayed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistExpend_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Life to date grant assessed from the date the grant began.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistExpend_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of grant recouped for the transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'TransactionAssistRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Month to Date grant recouped from the date the grant began.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'MtdAssistRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Life to Date Grant Recouped from the date the grant began.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'LtdAssistRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason for the adjustment. Values to be determined in subsequent Technical Design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'TypeAdjust_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates that the welfare case is eligible for grant but only received zero dollars for that month. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'ZeroGrant_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether a life-to-grant was adjusted by the user to adjust the overall amounts. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'AdjustLtdFlag_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will be used to store the DEFRA amount on the welfare case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'Defra_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the unique number assigned by the system to the Custodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores all Expended and Recouped amounts associated with each IVA or IVE case. The URA balances are maintained for each month and are rolled forward to the current month. All transactions affecting current grant and prior grant are stored in this table and maintained' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IvaIveGrant_T1'
GO
