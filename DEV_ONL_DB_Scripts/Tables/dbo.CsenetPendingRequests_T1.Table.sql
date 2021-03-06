USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TotalArrearsOwed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TotalInterestOwed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'ArrearComputed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'RespondentMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'PfNoShow_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Attachment_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'GeneticTest_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Dismissal_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Hearing_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'InsCarrier_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'CaseFormer_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'FormWeb_URL'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Form_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'StatusRequest_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'ExchangeMode_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Generated_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Request_IDNO'

GO
/****** Object:  Index [CSPR_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [CSPR_CASE_I1] ON [dbo].[CsenetPendingRequests_T1]
GO
/****** Object:  Table [dbo].[CsenetPendingRequests_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CsenetPendingRequests_T1]
GO
/****** Object:  Table [dbo].[CsenetPendingRequests_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CsenetPendingRequests_T1](
	[Request_IDNO] [numeric](9, 0) IDENTITY(1,1) NOT NULL,
	[Generated_DATE] [date] NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[IVDOutOfStateCountyFips_CODE] [char](3) NOT NULL,
	[IVDOutOfStateOfficeFips_CODE] [char](2) NOT NULL,
	[IVDOutOfStateCase_ID] [char](15) NOT NULL,
	[ExchangeMode_INDC] [char](1) NOT NULL,
	[StatusRequest_CODE] [char](2) NOT NULL,
	[Form_ID] [char](15) NOT NULL,
	[FormWeb_URL] [varchar](1000) NOT NULL,
	[TransHeader_IDNO] [numeric](12, 0) NOT NULL,
	[Function_CODE] [char](3) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[DescriptionComments_TEXT] [varchar](1000) NOT NULL,
	[CaseFormer_ID] [char](6) NOT NULL,
	[InsCarrier_NAME] [char](36) NOT NULL,
	[InsPolicyNo_TEXT] [char](30) NOT NULL,
	[Hearing_DATE] [date] NOT NULL,
	[Dismissal_DATE] [date] NOT NULL,
	[GeneticTest_DATE] [date] NOT NULL,
	[Attachment_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[File_ID] [char](15) NOT NULL,
	[PfNoShow_DATE] [date] NOT NULL,
	[RespondentMci_IDNO] [numeric](10, 0) NOT NULL,
	[ArrearComputed_DATE] [date] NOT NULL,
	[TotalInterestOwed_AMNT] [numeric](11, 2) NOT NULL,
	[TotalArrearsOwed_AMNT] [numeric](11, 2) NOT NULL,
 CONSTRAINT [CSPR_I1] PRIMARY KEY CLUSTERED 
(
	[Request_IDNO] ASC,
	[EndValidity_DATE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [CSPR_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [CSPR_CASE_I1] ON [dbo].[CsenetPendingRequests_T1]
(
	[Case_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'A unique request number created in this table for each request.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Request_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the date on which this request was generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Generated_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the DACSES case ID for which this request is created for CSENET communications.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Other-FIPS-State must contain valid FIPS Code numbers based on the jurisdiction table downloaded from the IRG. This always refers to the first two digits of the State with which you are communicating. The CSENet 2000 host will convert the Local-FIPS-State and Other-FIPS-State on incoming transactions to keep the appropriate point of reference. You must have communications enabled with the State in which you are communicating. The exchange of information agreement must be established in the FIPS Communication Matrix on the CSENet 2000 host. Values are obtained from REFM (STAT/STAT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'See above. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'See above. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the interstate case ID for this corresponding DACSES case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Exchange mode for the request. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'ExchangeMode_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the status of this request as to whether the CSENET request is pending or processed. Values are obtained from REFM (ICOR/STAT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'StatusRequest_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Form Id returned back by Forms component.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Form_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'WEB URL returned back from Forms API.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'FormWeb_URL'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The link to the Transaction Header Block record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Functional Type code, e.g., ENF, PAT, LO1, etc. from the original transaction. Possible values are limited by values in CFAR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Action code for which this request is made. This is one of the components in the FAR combination. Valid values are available in REFM.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Reason code for which this request is made. This is one of the components in the FAR combination. Values are obtained from REFM (INTS/FARC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the comments from interstate send correspondence.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the former case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'CaseFormer_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the name of the Insurance Carrier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'InsCarrier_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the Insurance Policy number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'InsPolicyNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the date for hearing.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Hearing_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the date for hearing dismissal.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Dismissal_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the date for genetic test.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'GeneticTest_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds the Attachment Indicator. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Attachment_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the File Number assigned to the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'PfNoShow_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Member MCI of NCP or PF.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'RespondentMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'As-of-Date when arrear was computed for TotalArrearsOwed_AMNT and TotalInterstOwed_AMNT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'ArrearComputed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total- Interest-Owed Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TotalInterestOwed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Total-Arrears-Owed-Amount is an aggregate amount of child support, medical support, any fees, etc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1', @level2type=N'COLUMN',@level2name=N'TotalArrearsOwed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table collects the transactions to be processed by Outbound CSENET Batch. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetPendingRequests_T1'
GO
