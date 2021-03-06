USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[FrozenMemberStmSummary_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FrozenMemberStmSummary_T1]
GO
/****** Object:  Table [dbo].[FrozenMemberStmSummary_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FrozenMemberStmSummary_T1](
	[MemberMci_IDNO] [numeric](8, 0) NOT NULL,
	[Summary_Date] [date] NOT NULL,
	[SummaryType_CODE] [char](4) NOT NULL,
	[PartArrears_AMNT] [numeric](11, 2) NOT NULL,
	[ClientUra_AMNT] [numeric](11, 2) NOT NULL,
	[ArrearsRecoupment_AMNT] [numeric](11, 2) NOT NULL,
 CONSTRAINT [FMSUM_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[Summary_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FROZEN]
) ON [FROZEN]

GO
SET ANSI_PADDING OFF
GO
