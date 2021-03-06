USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[FrozenCaseSupportOrder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FrozenCaseSupportOrder_T1]
GO
/****** Object:  Table [dbo].[FrozenCaseSupportOrder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FrozenCaseSupportOrder_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](3, 0) NOT NULL,
	[OrderEntered_Date] [date] NOT NULL,
	[ArrearsOrdered_AMNT] [numeric](11, 2) NOT NULL,
	[OrderFrequency_CODE] [char](4) NOT NULL,
	[PfaOrder_INDC] [char](1) NOT NULL,
	[Court_DATE] [date] NOT NULL,
	[OrderType_CODE] [char](4) NOT NULL,
	[PaymentType_CODE] [char](4) NOT NULL,
	[ApPfa_INDC] [char](1) NOT NULL,
	[Start_Date] [date] NOT NULL,
	[End_DATE] [date] NOT NULL,
	[Mail_DATE] [date] NOT NULL,
	[OriginatingState_CODE] [char](2) NOT NULL,
	[CourtOfficial_TEXT] [char](24) NOT NULL,
	[CourtOrderMethod_CODE] [char](4) NOT NULL,
	[CourtOrderEnteredBy_CODE] [char](4) NOT NULL,
	[SpousalSupport_INDC] [char](1) NOT NULL,
	[HealthInsuranceOrdered_INDC] [char](1) NOT NULL,
	[InsuranceProvidedBy_CODE] [char](4) NOT NULL,
	[OrderDeviation_CODE] [char](1) NOT NULL,
	[OrderNotes_TEXT] [varchar](2000) NOT NULL,
 CONSTRAINT [FCSOR_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FROZEN]
) ON [FROZEN]

GO
SET ANSI_PADDING OFF
GO
