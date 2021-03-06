/****** Object:  Table [tblUserService]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblUserService](
	[Id_Seq] [int] IDENTITY(1,1) NOT NULL,
	[Id_User] [varchar](8) NOT NULL,
	[Cd_Category] [varchar](4) NOT NULL,
	[BeginValidity_DATE] [date] NULL CONSTRAINT [DF_tblUserService_BeginValidity_DATE]  DEFAULT (getdate()),
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL CONSTRAINT [DF_tblUserService_Update_DTTM]  DEFAULT (getdate()),
	[WorkerUpdate_ID] [varchar](8) NOT NULL,
 CONSTRAINT [PK_tblUserService] PRIMARY KEY CLUSTERED 
(
	[Id_Seq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
