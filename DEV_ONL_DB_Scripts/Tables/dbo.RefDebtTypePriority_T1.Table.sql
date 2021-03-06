USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'PrDistribute_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TypeBucket_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'Interstate_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'

GO
/****** Object:  Table [dbo].[RefDebtTypePriority_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefDebtTypePriority_T1]
GO
/****** Object:  Table [dbo].[RefDebtTypePriority_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefDebtTypePriority_T1](
	[TypeDebt_CODE] [char](2) NOT NULL,
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[Interstate_INDC] [char](1) NOT NULL,
	[TypeWelfare_CODE] [char](1) NOT NULL,
	[TypeBucket_CODE] [char](5) NOT NULL,
	[PrDistribute_QNTY] [numeric](5, 0) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [DBTP_I1] PRIMARY KEY CLUSTERED 
(
	[TypeDebt_CODE] ASC,
	[Interstate_INDC] ASC,
	[SourceReceipt_CODE] ASC,
	[TypeWelfare_CODE] ASC,
	[TypeBucket_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The different Debt types that governs the way distribution process need to be given priority. Values are obtained from REFM (DBTP/DBTP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'This is the source of the Receipt from where Child support system received payments. Possible values are R - REGULAR and I - IRS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicator to know Out of state / Instate obligation and corresponding order of priority. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'Interstate_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'This is the Member Program type. Values are obtained from REFM (MHIS/PGTY).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The different type of buckets considered for distribution. Possible values are C - Current Support, E - Payback Amount, ANAA - Arrears NA, APAA - Arrears PA, AUDA - Arrears UDA, ACAA - Arrears CA, AIVEF - Arrears IVEF, AMEDI - Arrears MEDI, ANFFC - Arrears NFFC, ANIVD - Arrears NIVD, ATAA - Arrears TA and AUPA - Arrears UPA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TypeBucket_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the indicator value to be given priority when the distribution process takes place. Higher the Number Lower the Priority is the order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'PrDistribute_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the DACSES worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the distribution priority that is set up for each debt type in the system. Based on the priority specified in this table batch distribution prioritize the money allocation to the individual arrear buckets. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtTypePriority_T1'
GO
