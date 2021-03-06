USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[CaseDetailsSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CaseDetailsSC_T1]
GO
/****** Object:  Table [dbo].[CaseDetailsSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CaseDetailsSC_T1](
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
	[Intercept_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
