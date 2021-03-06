USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[Accrual_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Accrual_P1]
GO
/****** Object:  Table [dbo].[Accrual_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Accrual_P1](
	[Case_IDNO] [numeric](10, 0) NULL,
	[OrderSeq_NUMB] [numeric](5, 0) NULL,
	[ObligationSeq_NUMB] [numeric](5, 0) NULL,
	[FreqPeriodic_CODE] [char](1) NULL,
	[Periodic_AMNT] [numeric](11, 2) NULL,
	[ExpectToPay_AMNT] [numeric](11, 2) NULL,
	[BeginObligation_DATE] [date] NULL,
	[EndObligation_DATE] [date] NULL,
	[Der_AccrualNext_DATE] [date] NULL,
	[Conv_AccrualNext_DATE] [date] NULL,
	[Der_AccrualLast_DATE] [date] NULL,
	[Conv_AccrualLast_DATE] [date] NULL,
	[MemberMci_IDNO] [numeric](10, 0) NULL,
	[TypeDebt_CODE] [char](5) NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NULL,
	[BeginValidity_DATE] [date] NULL,
	[EndValidity_DATE] [date] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
