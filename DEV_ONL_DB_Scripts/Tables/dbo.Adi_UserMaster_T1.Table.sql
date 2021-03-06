USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[Adi_UserMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Adi_UserMaster_T1]
GO
/****** Object:  Table [dbo].[Adi_UserMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Adi_UserMaster_T1](
	[Worker_ID] [char](30) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](20) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[Suffix_NAME] [char](4) NOT NULL,
	[Contact_EML] [varchar](100) NOT NULL,
	[WorkerTitle_CODE] [char](2) NOT NULL,
	[WorkerSubTitle_CODE] [char](2) NOT NULL,
	[Organization_NAME] [char](25) NOT NULL,
	[BeginEmployment_DATE] [date] NOT NULL,
	[EndEmployment_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
