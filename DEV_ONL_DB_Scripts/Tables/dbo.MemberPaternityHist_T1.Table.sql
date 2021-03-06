USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[MemberPaternityHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MemberPaternityHist_T1]
GO
/****** Object:  Table [dbo].[MemberPaternityHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemberPaternityHist_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[BirthCertificate_ID] [char](20) NOT NULL,
	[BornOfMarriage_CODE] [char](1) NOT NULL,
	[Conception_DATE] [date] NOT NULL,
	[ConceptionCity_NAME] [char](28) NOT NULL,
	[ConceptionCounty_IDNO] [numeric](3, 0) NOT NULL,
	[ConceptionState_CODE] [char](2) NOT NULL,
	[ConceptionCountry_CODE] [char](2) NOT NULL,
	[EstablishedMother_CODE] [char](1) NOT NULL,
	[EstablishedMotherMci_IDNO] [numeric](10, 0) NOT NULL,
	[EstablishedMotherLast_NAME] [char](20) NOT NULL,
	[EstablishedMotherFirst_NAME] [char](16) NOT NULL,
	[EstablishedMotherMiddle_NAME] [char](20) NOT NULL,
	[EstablishedMotherSuffix_NAME] [char](4) NOT NULL,
	[EstablishedFather_CODE] [char](1) NOT NULL,
	[EstablishedFatherMci_IDNO] [numeric](10, 0) NOT NULL,
	[EstablishedFatherLast_NAME] [char](20) NOT NULL,
	[EstablishedFatherFirst_NAME] [char](16) NOT NULL,
	[EstablishedFatherMiddle_NAME] [char](20) NOT NULL,
	[EstablishedFatherSuffix_NAME] [char](4) NOT NULL,
	[DisEstablishedFather_CODE] [char](1) NOT NULL,
	[DisEstablishedFatherMci_IDNO] [numeric](10, 0) NOT NULL,
	[DisEstablishedFatherLast_NAME] [char](20) NOT NULL,
	[DisEstablishedFatherFirst_NAME] [char](16) NOT NULL,
	[DisEstablishedFatherMiddle_NAME] [char](20) NOT NULL,
	[DisEstablishedFatherSuffix_NAME] [char](4) NOT NULL,
	[PaternityEst_INDC] [char](1) NOT NULL,
	[StatusEstablish_CODE] [char](1) NOT NULL,
	[StateEstablish_CODE] [char](2) NOT NULL,
	[FileEstablish_ID] [char](10) NOT NULL,
	[PaternityEst_CODE] [char](2) NOT NULL,
	[PaternityEst_DATE] [date] NOT NULL,
	[StateDisestablish_CODE] [char](2) NOT NULL,
	[FileDisestablish_ID] [char](10) NOT NULL,
	[MethodDisestablish_CODE] [char](3) NOT NULL,
	[Disestablish_DATE] [date] NOT NULL,
	[DescriptionProfile_TEXT] [varchar](200) NOT NULL,
	[QiStatus_CODE] [char](1) NOT NULL,
	[VapImage_CODE] [char](1) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [HMPAT_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
