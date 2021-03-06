USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[FrozenCaseMaritalHistory_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FrozenCaseMaritalHistory_T1]
GO
/****** Object:  Table [dbo].[FrozenCaseMaritalHistory_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FrozenCaseMaritalHistory_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](8, 0) NOT NULL,
	[ChildFull_NAME] [char](24) NOT NULL,
	[ChildBirth_DATE] [date] NOT NULL,
	[Parent1Full_NAME] [char](24) NOT NULL,
	[Parent2Full_NAME] [char](24) NOT NULL,
	[Marriage_DATE] [date] NOT NULL,
	[MarriageStateOrCountry_CODE] [char](2) NOT NULL,
	[Divorce_DATE] [date] NOT NULL,
	[DivorceStateOrCountry_CODE] [char](2) NOT NULL,
	[SameSexRelationship_INDC] [char](1) NOT NULL,
	[MaritalSource_TEXT] [varchar](78) NOT NULL
) ON [FROZEN]

GO
SET ANSI_PADDING OFF
GO
