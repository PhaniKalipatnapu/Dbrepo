USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[MemberMCI_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MemberMCI_T1]
GO
/****** Object:  Table [dbo].[MemberMCI_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemberMCI_T1](
	[MemberMci_IDNO] [numeric](10, 0) IDENTITY(302627309,1) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](20) NOT NULL,
	[Suffix_NAME] [char](4) NOT NULL,
	[FullDisplay_NAME] [varchar](60) NOT NULL,
	[MemberSex_CODE] [char](1) NOT NULL,
	[Race_CODE] [char](2) NOT NULL,
	[Birth_DATE] [date] NOT NULL,
	[MaritalStatus_CODE] [char](2) NOT NULL,
	[Religion_CODE] [char](2) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[County_IDNO] [numeric](3, 0) NULL,
	[CitizenShip_CODE] [char](1) NULL,
	[School_CODE] [char](5) NULL,
	[Deceased_DATE] [date] NOT NULL,
	[BirthIndicator_CODE] [char](3) NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[ApartmentNumber_ADDR] [char](5) NOT NULL,
	[Zip_ADDR] [char](10) NOT NULL,
	[ZipSuffix_ADDR] [char](10) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[HomePhone_NUMB] [numeric](10, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
