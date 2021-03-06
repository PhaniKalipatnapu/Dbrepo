USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIns_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeVen_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeDebt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeSal_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeRet_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludePas_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeFin_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeAdm_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIrs_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'Arrear_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'TypeArrear_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[IrsRejectCases_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IrsRejectCases_T1]
GO
/****** Object:  Table [dbo].[IrsRejectCases_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IrsRejectCases_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[TypeArrear_CODE] [char](1) NOT NULL,
	[Arrear_AMNT] [numeric](11, 2) NOT NULL,
	[ExcludeIrs_CODE] [char](1) NOT NULL,
	[ExcludeAdm_CODE] [char](1) NOT NULL,
	[ExcludeFin_CODE] [char](1) NOT NULL,
	[ExcludePas_CODE] [char](1) NOT NULL,
	[ExcludeRet_CODE] [char](1) NOT NULL,
	[ExcludeSal_CODE] [char](1) NOT NULL,
	[ExcludeDebt_CODE] [char](1) NOT NULL,
	[ExcludeVen_CODE] [char](1) NOT NULL,
	[ExcludeIns_CODE] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
 CONSTRAINT [RJCS_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Contains the payer ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Contains the Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Arrear type. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'TypeArrear_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Arrear amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'Arrear_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Internal Revenue Service exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIrs_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Administrative exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeAdm_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the MS-FIDM exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeFin_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Passport Denial exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludePas_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Federal Retirement exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeRet_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Federal Salary exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeSal_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Debt Check exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeDebt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Vendor Payment exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeVen_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Insurance exclusion from Fed Indicator representing the exemption status of the Insurance exclusion from Federal Offset. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIns_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Contains the county number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store IVD Case level IRS rejects. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IrsRejectCases_T1'
GO
