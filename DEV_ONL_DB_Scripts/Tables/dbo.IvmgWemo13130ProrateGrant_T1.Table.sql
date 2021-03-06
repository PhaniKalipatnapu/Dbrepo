USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[IvmgWemo13130ProrateGrant_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IvmgWemo13130ProrateGrant_T1]
GO
/****** Object:  Table [dbo].[IvmgWemo13130ProrateGrant_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IvmgWemo13130ProrateGrant_T1](
	[Seq_IDNO] [numeric](19, 0) NULL,
	[CaseWelfare_IDNO] [numeric](10, 0) NULL,
	[CpMci_IDNO] [numeric](10, 0) NULL,
	[WelfareYearMonth_NUMB] [numeric](6, 0) NULL,
	[UrgBalance_AMNT] [numeric](11, 2) NULL,
	[Process_INDC] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
