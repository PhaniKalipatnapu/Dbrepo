USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Intercept_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ReasonFeeWaived_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FeeCheckNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'StatusEnforce_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ServiceRequested_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FeePaid_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ApplicationFee_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'CaseCategory_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Referral_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ClientLitigantRole_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppSigned_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'CpRelationshipToNcp_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppRetd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppReq_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppSent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'IvdApplicant_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Jurisdiction_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'MedicalOnly_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Restricted_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AssignedFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Office_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AprvIvd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'StatusCurrent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Divorced_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Marriage_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Opened_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceRfrl_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'RsnStatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [HCASE_DOCKET_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [HCASE_DOCKET_I1] ON [dbo].[CaseDetailsHist_T1]
GO
/****** Object:  Index [HCASE_CASEID_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [HCASE_CASEID_I1] ON [dbo].[CaseDetailsHist_T1]
GO
/****** Object:  Table [dbo].[CaseDetailsHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CaseDetailsHist_T1]
GO
/****** Object:  Table [dbo].[CaseDetailsHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CaseDetailsHist_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[StatusCase_CODE] [char](1) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[RsnStatusCase_CODE] [char](2) NOT NULL,
	[RespondInit_CODE] [char](1) NOT NULL,
	[SourceRfrl_CODE] [char](3) NOT NULL,
	[Opened_DATE] [date] NOT NULL,
	[Marriage_DATE] [date] NOT NULL,
	[Divorced_DATE] [date] NOT NULL,
	[StatusCurrent_DATE] [date] NOT NULL,
	[AprvIvd_DATE] [date] NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
	[Office_IDNO] [numeric](3, 0) NOT NULL,
	[AssignedFips_CODE] [char](7) NOT NULL,
	[GoodCause_CODE] [char](1) NOT NULL,
	[GoodCause_DATE] [date] NOT NULL,
	[Restricted_INDC] [char](1) NOT NULL,
	[MedicalOnly_INDC] [char](1) NOT NULL,
	[Jurisdiction_INDC] [char](1) NOT NULL,
	[IvdApplicant_CODE] [char](3) NOT NULL,
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[AppSent_DATE] [date] NOT NULL,
	[AppReq_DATE] [date] NOT NULL,
	[AppRetd_DATE] [date] NOT NULL,
	[CpRelationshipToNcp_CODE] [char](3) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[AppSigned_DATE] [date] NOT NULL,
	[ClientLitigantRole_CODE] [char](2) NOT NULL,
	[DescriptionComments_TEXT] [varchar](200) NOT NULL,
	[NonCoop_CODE] [char](1) NOT NULL,
	[NonCoop_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[Referral_DATE] [date] NOT NULL,
	[CaseCategory_CODE] [char](2) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[ApplicationFee_CODE] [char](1) NOT NULL,
	[FeePaid_DATE] [date] NOT NULL,
	[ServiceRequested_CODE] [char](1) NOT NULL,
	[StatusEnforce_CODE] [char](4) NOT NULL,
	[FeeCheckNo_TEXT] [char](20) NOT NULL,
	[ReasonFeeWaived_CODE] [char](2) NOT NULL,
	[Intercept_CODE] [char](1) NOT NULL,
 CONSTRAINT [HCASE_I1] PRIMARY KEY CLUSTERED 
(
	[BeginValidity_DATE] ASC,
	[Case_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [HCASE_CASEID_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [HCASE_CASEID_I1] ON [dbo].[CaseDetailsHist_T1]
(
	[Case_IDNO] ASC,
	[BeginValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [HCASE_DOCKET_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [HCASE_DOCKET_I1] ON [dbo].[CaseDetailsHist_T1]
(
	[File_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Status of the Case. Values are obtained from REFM (CSTS/CSTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Type of the Case. Values are obtained from REFM (CCRT/CTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Status Case Reason. Values obtained from REFM (CCRT/CCLO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'RsnStatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Case is Initiation or Responding. Values obtained from REFM (INTS/CATG).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Referral Source. Values obtained from REFM (CCRT/REFS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceRfrl_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Case is opened.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Opened_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Marriage Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Marriage_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Divorce Date of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Divorced_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Current Status Date of the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'StatusCurrent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Approved Date. Column might be removed in the subsequent designs after review.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AprvIvd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the County in which the Case is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Office in which the Case is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Office_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS to which the Case is assigned. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AssignedFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Good Cause Date. Values obtained from REFM (CCRT/NCOP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Good Cause Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator for the Confidentiality of the Case. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Restricted_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Medical Indicator. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'MedicalOnly_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Jurisdiction Indicator. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Jurisdiction_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the IVD Applicant (whether CP or NCP). Values are obtained from REFM (CCRT/APLT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'IvdApplicant_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID assigned to the Application.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Application was sent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppSent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Application was requested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppReq_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Application was returned.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppRetd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the CP’s relationship to the NCP. Values are obtained from REFM (FMLY/RELA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'CpRelationshipToNcp_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Worker ID who created the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Application was signed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'AppSigned_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Client Litigant Role. Values are obtained from REFM (GENR/PART).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ClientLitigantRole_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Any other Additional comments for the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non Cooperation Indicator. Values are obtained from REFM (CCRT/NCOP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Non-Cooperative Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Referral Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Referral_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Case Category. Values obtained from REFM (CCRT/CCTG).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'CaseCategory_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the File Number assigned for the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Application Fee is paid or waived or not paid. Values obtained from REFM (CCRT, APFE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ApplicationFee_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which Application Fee is paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FeePaid_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Code which identifies which type of Service was requested by the Client. Values obtained from REFM (APRE/SVCS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ServiceRequested_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the workable status of a case. Values are obtained from REFM (CCRT/ENST).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'StatusEnforce_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Check or money order number of the IV-D application fee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FeeCheckNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Waived reason of an IV-D application fee. Values are obtained from REFM (CCRT/WRES)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'ReasonFeeWaived_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Intercept Indicator. Possible values are S - Certified for State, I - Certified for IRS, B - Certified for both and N - Not Certified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Intercept_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the History information of all the Case Details for a given Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseDetailsHist_T1'
GO
