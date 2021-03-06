USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[LIVAR_MedicaidBKUP_20140312]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LIVAR_MedicaidBKUP_20140312]
GO
/****** Object:  Table [dbo].[LIVAR_MedicaidBKUP_20140312]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LIVAR_MedicaidBKUP_20140312](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[CaseWelfare_IDNO] [char](10) NOT NULL,
	[CpMci_IDNO] [char](10) NOT NULL,
	[NcpMci_IDNO] [char](10) NOT NULL,
	[AgSequence_NUMB] [char](4) NOT NULL,
	[StatusCase_CODE] [char](1) NOT NULL,
	[ChildMci_IDNO] [char](10) NOT NULL,
	[Program_CODE] [char](3) NOT NULL,
	[SubProgram_CODE] [char](1) NOT NULL,
	[IntactFamilyStatus_CODE] [char](1) NOT NULL,
	[ChildElig_DATE] [char](8) NOT NULL,
	[WelfareCaseCounty_IDNO] [char](3) NOT NULL,
	[ChildFirst_NAME] [char](16) NOT NULL,
	[ChildMiddle_NAME] [char](20) NOT NULL,
	[ChildLast_NAME] [char](20) NOT NULL,
	[ChildSuffix_NAME] [char](4) NOT NULL,
	[ChildBirth_DATE] [char](8) NOT NULL,
	[ChildSsn_NUMB] [char](9) NOT NULL,
	[ChildSex_CODE] [char](1) NOT NULL,
	[ChildRace_CODE] [char](2) NOT NULL,
	[ChildPaternityStatus_CODE] [char](1) NOT NULL,
	[CpRelationshipToChild_CODE] [char](3) NOT NULL,
	[NcpRelationshipToChild_CODE] [char](3) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
