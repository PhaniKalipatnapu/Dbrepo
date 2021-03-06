USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[Oble12879ProratedOwedAmt_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Oble12879ProratedOwedAmt_T1]
GO
/****** Object:  Table [dbo].[Oble12879ProratedOwedAmt_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Oble12879ProratedOwedAmt_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NULL,
	[MemberMci_IDNO] [numeric](10, 0) NULL,
	[CheckRecipient_ID] [char](10) NULL,
	[CheckRecipient_CODE] [char](2) NULL,
	[TypeDebt_CODE] [char](2) NULL,
	[Fips_CODE] [char](7) NULL,
	[FreqPeriodic_CODE] [char](1) NULL,
	[Periodic_AMNT] [numeric](11, 2) NULL,
	[BeginObligation_DATE] [date] NULL,
	[EndObligation_DATE] [date] NULL,
	[Cnv_AccrualLast_DATE] [date] NULL,
	[Cnv_AccrualNext_DATE] [date] NULL,
	[New_AccrualLast_DATE] [date] NULL,
	[New_AccrualNext_DATE] [date] NULL,
	[NoOfDaysToProrate_QNTY] [numeric](10, 0) NULL,
	[ProratedOwed_AMNT] [numeric](11, 2) NULL,
	[Bucket_NAME] [varchar](10) NULL,
	[WelfareType_CODE] [char](1) NULL,
	[LSUP_201310_Record_Exist_INDC] [char](1) NULL,
	[LSUP_201311_Record_Exist_INDC] [char](1) NULL,
	[Case_Oct_Arrear_AMNT] [numeric](11, 2) NULL,
	[CpMci_IDNO] [numeric](10, 0) NULL,
	[Process_INDC] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
