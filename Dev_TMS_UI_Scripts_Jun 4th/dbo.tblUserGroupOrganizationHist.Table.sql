/****** Object:  Table [tblUserGroupOrganizationHist]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblUserGroupOrganizationHist](
	[Seq_IDNO] [int] IDENTITY(1,1) NOT NULL,
	[User_ID] [varchar](8) NULL,
	[Group_ID] [varchar](8) NULL,
	[Organization_ID] [varchar](8) NULL,
	[BeginValidity_DATE] [date] NULL,
	[EndValidity_DATE] [date] NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblUserGroupOrganizationHist] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
