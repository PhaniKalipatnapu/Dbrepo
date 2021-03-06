USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TaxYear_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ReqPreOffset_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'RejectInd_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIns_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeVen_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeDebt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeSal_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeRet_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeAdm_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIrs_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeFin_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludePas_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'SubmitLast_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Arrear_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ArrearIdentifier_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TypeTransaction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TypeArrear_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Index [HFEDH_SSN_ARREAR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [HFEDH_SSN_ARREAR_I1] ON [dbo].[FederalLastSentHist_T1]
GO
/****** Object:  Table [dbo].[FederalLastSentHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FederalLastSentHist_T1]
GO
/****** Object:  Table [dbo].[FederalLastSentHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FederalLastSentHist_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[TypeArrear_CODE] [char](1) NOT NULL,
	[TypeTransaction_CODE] [char](1) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](20) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[ArrearIdentifier_IDNO] [numeric](15, 0) NOT NULL,
	[Arrear_AMNT] [numeric](11, 2) NOT NULL,
	[SubmitLast_DATE] [date] NOT NULL,
	[ExcludePas_CODE] [char](1) NOT NULL,
	[ExcludeFin_CODE] [char](1) NOT NULL,
	[ExcludeIrs_CODE] [char](1) NOT NULL,
	[ExcludeAdm_CODE] [char](1) NOT NULL,
	[ExcludeRet_CODE] [char](1) NOT NULL,
	[ExcludeSal_CODE] [char](1) NOT NULL,
	[ExcludeDebt_CODE] [char](1) NOT NULL,
	[ExcludeVen_CODE] [char](1) NOT NULL,
	[ExcludeIns_CODE] [char](1) NOT NULL,
	[RejectInd_INDC] [char](1) NOT NULL,
	[CountyFips_CODE] [char](3) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ReqPreOffset_CODE] [char](1) NOT NULL,
	[TaxYear_NUMB] [numeric](4, 0) NOT NULL,
 CONSTRAINT [HFEDH_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[SubmitLast_DATE] ASC,
	[TaxYear_NUMB] ASC,
	[TransactionEventSeq_NUMB] ASC,
	[TypeArrear_CODE] ASC,
	[TypeTransaction_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [HFEDH_SSN_ARREAR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [HFEDH_SSN_ARREAR_I1] ON [dbo].[FederalLastSentHist_T1]
(
	[MemberSsn_NUMB] ASC,
	[TypeArrear_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the System to the MCI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'SSN of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The type of arrears. Possible values are A for TANF, N for Non-TANF.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TypeArrear_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Represents the Type of Transaction, whether it is an addition or Modification. Possible values are A - Add Case (Certified) B - Name Change C - Case Id Change D - Delete L - Local Code Change M - Modification (Update) R - Replace Exclusion Indicator(s) S - State Payment T - Transfer for Administrative Review Z - Address Change.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TypeTransaction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Middle name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line 1 of member address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line 2 of member address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member City.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member State. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'5 digit zip code of member address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Arrear Identifier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ArrearIdentifier_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Arrear amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Arrear_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The last submit date for federal offset / State offset.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'SubmitLast_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Passport Denial exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludePas_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the MS-FIDM exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeFin_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Internal Revenue Service exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIrs_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Administrative exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeAdm_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Federal Retirement exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeRet_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Federal Salary exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeSal_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Debt Check exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeDebt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Vendor Payment exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeVen_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the exemption status of the Insurance exclusion from Fed Indicator representing the exemption status of the Insurance exclusion from Federal Offset. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ExcludeIns_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Indicator to show the Record sent is rejected / Not by the Fed Agency.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'RejectInd_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS Code. Values are obtained from REFM (OTHP/CNTY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator representing the pre-offset notice request. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'ReqPreOffset_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'It indicates the Tax year.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1', @level2type=N'COLUMN',@level2name=N'TaxYear_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the details sent to OCSE.  This table will not have the latest transaction sent to OCSE.  That is, whenever a transaction is sent to OCSE, the previous transaction details from FEDERAL_LAST_SENT will be moved to this history table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FederalLastSentHist_T1'
GO
