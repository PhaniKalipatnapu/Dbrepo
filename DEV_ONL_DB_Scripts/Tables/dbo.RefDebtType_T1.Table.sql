USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'SubmitStx_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'SubmitIrs_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'Interstate_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'DescriptionDebt_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'

GO
/****** Object:  Table [dbo].[RefDebtType_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefDebtType_T1]
GO
/****** Object:  Table [dbo].[RefDebtType_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefDebtType_T1](
	[TypeDebt_CODE] [char](2) NOT NULL,
	[DescriptionDebt_TEXT] [char](30) NOT NULL,
	[Interstate_INDC] [char](1) NOT NULL,
	[SubmitIrs_INDC] [char](1) NOT NULL,
	[SubmitStx_INDC] [char](1) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [DEBT_I1] PRIMARY KEY CLUSTERED 
(
	[TypeDebt_CODE] ASC,
	[Interstate_INDC] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is the Debt Type on which the Judgement order will be entered as Obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Detailed Description for the Code used to denote the Debt Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'DescriptionDebt_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is an Indicator to identify this is an Interstate or Not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'Interstate_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the indicator to identify the arrear to be considered wile calculating the arrear amount submitted to IRS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'SubmitIrs_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the indicator to identify the arrear to be considered wile calculating the arrear amount submitted to  STATE TAX.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'SubmitStx_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the DACSES worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be generated for any given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the detail on all the debt type available system with its distribution attributes. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefDebtType_T1'
GO
