USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[AddressDetailsSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[AddressDetailsSC_T1]
GO
/****** Object:  Table [dbo].[AddressDetailsSC_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AddressDetailsSC_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[TypeAddress_CODE] [char](1) NOT NULL,
	[Begin_DATE] [date] NOT NULL,
	[End_DATE] [date] NOT NULL,
	[Attn_ADDR] [char](40) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[Country_ADDR] [char](2) NOT NULL,
	[SourceLoc_CODE] [char](3) NOT NULL,
	[SourceReceived_DATE] [date] NOT NULL,
	[Status_CODE] [char](1) NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[SourceVerified_CODE] [char](3) NOT NULL,
	[DescriptionServiceDirection_TEXT] [varchar](1000) NOT NULL,
	[PlsLoad_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[DescriptionComments_TEXT] [varchar](1000) NOT NULL,
	[Normalization_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
