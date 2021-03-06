USE [DEV_ONL_DB]
GO
/****** Object:  Index [FCSOA_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [FCSOA_I1] ON [dbo].[FrozenCaseSupOrderAccounts_T1] WITH ( ONLINE = OFF )
GO
/****** Object:  Table [dbo].[FrozenCaseSupOrderAccounts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FrozenCaseSupOrderAccounts_T1]
GO
/****** Object:  Table [dbo].[FrozenCaseSupOrderAccounts_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FrozenCaseSupOrderAccounts_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](3, 0) NOT NULL,
	[ObligationType_CODE] [char](6) NOT NULL,
	[FrequencyDue_AMNT] [numeric](11, 2) NOT NULL,
	[OrderArrears_AMNT] [numeric](11, 2) NOT NULL,
	[OrderArrearsAdj_AMNT] [numeric](11, 2) NOT NULL,
	[Account_NUMB] [numeric](10, 0) NOT NULL
) ON [FROZEN]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [FCSOA_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE CLUSTERED INDEX [FCSOA_I1] ON [dbo].[FrozenCaseSupOrderAccounts_T1]
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC,
	[Account_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FROZEN]
GO
