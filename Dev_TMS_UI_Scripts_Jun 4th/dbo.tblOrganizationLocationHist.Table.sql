/****** Object:  Table [tblOrganizationLocationHist]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblOrganizationLocationHist](
	[Seq_IDNO] [int] IDENTITY(1,1) NOT NULL,
	[Location_IDNO] [int] NULL,
	[LocationType_CODE] [varchar](2) NULL,
	[Organization_ID] [varchar](8) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NULL,
	[City_ADDR] [varchar](28) NULL,
	[State_ADDR] [varchar](2) NULL,
	[Zip_CODE] [varchar](15) NULL,
	[County_CODE] [varchar](2) NULL,
	[OfficePhone_NUMB] [varchar](15) NULL,
	[CellPhone_NUMB] [varchar](15) NULL,
	[OtherPhone_NUMB] [varchar](15) NULL,
	[FaxPhone_NUMB] [varchar](15) NULL,
	[Website_TEXT] [varchar](150) NULL,
	[Contact_EML] [varchar](150) NULL,
	[TimeZone_CODE] [varchar](10) NULL,
	[Comments_TEXT] [varchar](8000) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblOrganizationLocationHist] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
