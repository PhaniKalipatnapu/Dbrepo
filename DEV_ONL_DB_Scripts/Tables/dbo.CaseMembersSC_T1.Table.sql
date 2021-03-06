USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[CaseMembersSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CaseMembersSC_T1]
GO
/****** Object:  Table [dbo].[CaseMembersSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CaseMembersSC_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[CaseRelationship_CODE] [char](1) NOT NULL,
	[CaseMemberStatus_CODE] [char](1) NOT NULL,
	[CpRelationshipToChild_CODE] [char](3) NOT NULL,
	[NcpRelationshipToChild_CODE] [char](3) NOT NULL,
	[BenchWarrant_INDC] [char](1) NOT NULL,
	[ReasonMemberStatus_CODE] [char](2) NOT NULL,
	[Applicant_CODE] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[FamilyViolence_DATE] [date] NOT NULL,
	[FamilyViolence_INDC] [char](1) NOT NULL,
	[TypeFamilyViolence_CODE] [char](2) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
