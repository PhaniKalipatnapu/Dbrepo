/****** Object:  Table [tblUser]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblUser](
	[Id_User] [varchar](8) NOT NULL,
	[First_Name] [varchar](100) NULL,
	[Email] [varchar](150) NULL,
	[Cd_Code] [varchar](4) NULL,
	[Time_Zone] [varchar](36) NULL,
	[ToDo_Date] [datetime] NULL,
	[Ind_ToDo] [varchar](8) NULL,
	[Notification_Type] [varchar](3) NULL,
	[City_Location] [varchar](200) NULL,
	[Country_ISO] [varchar](200) NULL,
	[Postal_Code] [varchar](9) NULL,
	[Id_CreatedBy] [varchar](8) NULL,
	[BeginValidity_DTTM] [datetime] NULL,
	[EndValidity_DTTM] [datetime] NULL,
	[Update_DTTM] [datetime] NULL,
	[Id_WorkerUpdate] [varchar](8) NULL,
	[ProfileName_TEXT] [varchar](100) NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_User] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
