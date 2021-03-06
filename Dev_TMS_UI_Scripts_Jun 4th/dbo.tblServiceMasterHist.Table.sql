/****** Object:  Table [tblServiceMasterHist]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblServiceMasterHist](
	[Seq_IDNO] [int] IDENTITY(1,1) NOT NULL,
	[Service_ID] [varchar](8) NULL,
	[Organization_ID] [varchar](8) NOT NULL,
	[Service_NAME] [varchar](150) NOT NULL,
	[Description_TEXT] [varchar](4000) NULL,
	[ServiceCost_CODE] [char](1) NULL,
	[ServiceCost_AMT] [numeric](9, 2) NULL,
	[ServiceInfo_TEXT] [varchar](4000) NULL,
	[ServiceEnroll_TEXT] [varchar](4000) NULL,
	[ServiceURL_TEXT] [char](150) NULL,
	[ServiceRequirement_TEXT] [varchar](4000) NULL,
	[LanguageEnglish_INDC] [char](1) NULL,
	[LanguageSpanish_INDC] [char](1) NULL,
	[LanguageSign_INDC] [char](1) NULL,
	[LanguageOthers_TEXT] [varchar](50) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblServiceMasterHist] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
