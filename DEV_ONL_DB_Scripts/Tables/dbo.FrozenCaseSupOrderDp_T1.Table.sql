USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[FrozenCaseSupOrderDp_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FrozenCaseSupOrderDp_T1]
GO
/****** Object:  Table [dbo].[FrozenCaseSupOrderDp_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FrozenCaseSupOrderDp_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](3, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](8, 0) NOT NULL,
	[ChildFull_NAME] [char](24) NOT NULL,
 CONSTRAINT [FCSOD_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC,
	[MemberMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FROZEN]
) ON [FROZEN]

GO
SET ANSI_PADDING OFF
GO
