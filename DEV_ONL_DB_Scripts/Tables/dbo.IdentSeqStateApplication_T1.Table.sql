USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[IdentSeqStateApplication_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IdentSeqStateApplication_T1]
GO
/****** Object:  Table [dbo].[IdentSeqStateApplication_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IdentSeqStateApplication_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Entered_DATE] [date] NOT NULL
) ON [PRIMARY]

GO
