/****** Object:  Table [tblOrganizationHist]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblOrganizationHist](
	[Seq_IDNO] [int] IDENTITY(1,1) NOT NULL,
	[Organization_ID] [varchar](8) NOT NULL,
	[Organization_NAME] [varchar](150) NOT NULL,
	[OrganizationType_CODE] [varchar](2) NOT NULL,
	[OrganizationEIN_TEXT] [varchar](9) NULL,
	[FaithBased_INDC] [char](1) NULL,
	[Acceptance_INDC] [char](1) NULL,
	[Privacy_INDC] [char](1) NULL,
	[About_TEXT] [varchar](8000) NULL,
	[LogoURL_TEXT] [varchar](150) NULL,
	[Licensed_INDC] [char](1) NULL,
	[LicenseBy_NAME] [varchar](100) NULL,
	[LicensedURL_TEXT] [varchar](255) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblOrganizationHist] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
