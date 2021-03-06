USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'ExcludeState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'SubmitLast_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TypeArrear_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TypeTransaction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TaxYear_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Index [ISTX_SSN_ARREAR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ISTX_SSN_ARREAR_I1] ON [dbo].[InterceptStxLog_T1]
GO
/****** Object:  Table [dbo].[InterceptStxLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[InterceptStxLog_T1]
GO
/****** Object:  Table [dbo].[InterceptStxLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InterceptStxLog_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[TaxYear_NUMB] [numeric](4, 0) NOT NULL,
	[TypeTransaction_CODE] [char](1) NOT NULL,
	[TypeArrear_CODE] [char](1) NOT NULL,
	[Transaction_AMNT] [numeric](11, 2) NOT NULL,
	[SubmitLast_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ExcludeState_CODE] [char](1) NOT NULL,
	[CountyFips_CODE] [char](3) NOT NULL,
 CONSTRAINT [ISTX_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[MemberMci_IDNO] ASC,
	[SubmitLast_DATE] ASC,
	[TaxYear_NUMB] ASC,
	[TransactionEventSeq_NUMB] ASC,
	[TypeArrear_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ISTX_SSN_ARREAR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ISTX_SSN_ARREAR_I1] ON [dbo].[InterceptStxLog_T1]
(
	[MemberSsn_NUMB] ASC,
	[TypeArrear_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The case participant ID for whom referral has been made to State Offset Program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The Case ID of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'SSN of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Tax year for which offset action is valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TaxYear_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Represents the Type of Transaction, whether it is an addition or Modification. Possible values are I - Initial D - Delete P - Pro-rata C - Change A - Appeal L - Setoff request. Values that will be received from the State responses: 2, 3, T.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TypeTransaction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Offset arrears type. Possible values are A-TANF or N-Non-TANF.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TypeArrear_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The amount of TANF or Non-TANF arrears certified and submitted for the case based on the case''s Qualified State TANF or Qualified State Non-TANF on the TAXI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'The date that the transaction was submitted to the State offset program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'SubmitLast_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'Unique Sequence Number that will be generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the SOIL Offset Program. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'ExcludeState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS Code. Values are obtained from REFM (OTHP/CNTY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the latest transaction sent to SOIL (DOR) by Case level.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterceptStxLog_T1'
GO
