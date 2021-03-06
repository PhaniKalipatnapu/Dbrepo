USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[Adi_UserOffices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Adi_UserOffices_T1]
GO
/****** Object:  Table [dbo].[Adi_UserOffices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Adi_UserOffices_T1](
	[Worker_ID] [char](30) NOT NULL,
	[Office_IDNO] [numeric](3, 0) NOT NULL,
	[WorkPhone_NUMB] [numeric](15, 0) NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[Expire_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
