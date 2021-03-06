USE [DEV_TMS_UI]
GO
/****** Object:  Table [dbo].[tblOrganizationOperationHoursHist]    Script Date: 6/4/2015 11:19:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblOrganizationOperationHoursHist](
	[Seq_IDNO] [int] IDENTITY(1,1) NOT NULL,
	[Operation_IDNO] [int] NULL,
	[Location_IDNO] [int] NOT NULL,
	[Organization_ID] [varchar](8) NULL,
	[OperationDay_CODE] [varchar](3) NULL,
	[OperationType_CODE] [varchar](3) NULL,
	[Opening_TIME] [time](7) NULL,
	[Closing_TIME] [time](7) NULL,
	[LunchBreak_INDC] [char](1) NULL,
	[LunchStart_TIME] [time](7) NULL,
	[LunchEnd_TIME] [time](7) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblOrganizationOperationHoursHist] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
