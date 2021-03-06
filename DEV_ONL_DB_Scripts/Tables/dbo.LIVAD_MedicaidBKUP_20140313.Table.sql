USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[LIVAD_MedicaidBKUP_20140313]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LIVAD_MedicaidBKUP_20140313]
GO
/****** Object:  Table [dbo].[LIVAD_MedicaidBKUP_20140313]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LIVAD_MedicaidBKUP_20140313](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[CaseWelfare_IDNO] [char](10) NOT NULL,
	[CpMci_IDNO] [char](10) NOT NULL,
	[NcpMci_IDNO] [char](10) NOT NULL,
	[AgSequence_NUMB] [char](4) NOT NULL,
	[ApSequence_NUMB] [char](10) NOT NULL,
	[CpFirst_NAME] [char](16) NOT NULL,
	[CpMiddle_NAME] [char](20) NOT NULL,
	[CpLast_NAME] [char](20) NOT NULL,
	[CpSuffix_NAME] [char](4) NOT NULL,
	[CpBirth_DATE] [char](8) NOT NULL,
	[CpSsn_NUMB] [char](9) NOT NULL,
	[CpSex_CODE] [char](1) NOT NULL,
	[CpRace_CODE] [char](2) NOT NULL,
	[CpAddrNormalization_CODE] [char](1) NOT NULL,
	[CpLine1_ADDR] [varchar](50) NOT NULL,
	[CpLine2_ADDR] [varchar](50) NOT NULL,
	[CpCity_ADDR] [char](28) NOT NULL,
	[CpState_ADDR] [char](2) NOT NULL,
	[CpZip_ADDR] [char](15) NOT NULL,
	[CpEmployer_NAME] [varchar](60) NOT NULL,
	[CpEmployerFein_IDNO] [char](9) NOT NULL,
	[CpEmpAddrNormalization_CODE] [char](1) NOT NULL,
	[CpEmployerLine1_ADDR] [varchar](50) NOT NULL,
	[CpEmployerLine2_ADDR] [varchar](50) NOT NULL,
	[CpEmployerCity_ADDR] [char](28) NOT NULL,
	[CpEmployerState_ADDR] [char](2) NOT NULL,
	[CpEmployerZip_ADDR] [char](15) NOT NULL,
	[NcpFirst_NAME] [char](16) NOT NULL,
	[NcpMiddle_NAME] [char](20) NOT NULL,
	[NcpLast_NAME] [char](20) NOT NULL,
	[NcpSuffix_NAME] [char](4) NOT NULL,
	[NcpBirth_DATE] [char](8) NOT NULL,
	[NcpSsn_NUMB] [char](9) NOT NULL,
	[NcpSex_CODE] [char](1) NOT NULL,
	[NcpRace_CODE] [char](2) NOT NULL,
	[NcpAddrNormalization_CODE] [char](1) NOT NULL,
	[NcpLine1_ADDR] [varchar](50) NOT NULL,
	[NcpLine2_ADDR] [varchar](50) NOT NULL,
	[NcpCity_ADDR] [char](28) NOT NULL,
	[NcpState_ADDR] [char](2) NOT NULL,
	[NcpZip_ADDR] [char](15) NOT NULL,
	[NcpEmployer_NAME] [varchar](60) NOT NULL,
	[NcpEmployerFEIN_IDNO] [char](9) NOT NULL,
	[NcpEmpAddrNormalization_CODE] [char](1) NOT NULL,
	[NcpEmployerLine1_ADDR] [varchar](50) NOT NULL,
	[NcpEmployerLine2_ADDR] [varchar](50) NOT NULL,
	[NcpEmployerCity_ADDR] [char](28) NOT NULL,
	[NcpEmployerState_ADDR] [char](2) NOT NULL,
	[NcpEmployerZip_ADDR] [char](15) NOT NULL,
	[NcpInsuranceProvider_NAME] [varchar](60) NOT NULL,
	[NcpPolicyInsNo_TEXT] [char](18) NOT NULL,
	[OrderSeq_NUMB] [char](7) NOT NULL,
	[OrderIssued_DATE] [char](8) NOT NULL,
	[Order_AMNT] [char](9) NOT NULL,
	[FreqPay_CODE] [char](1) NOT NULL,
	[PaymentType_CODE] [char](1) NOT NULL,
	[PaymentLastReceived_AMNT] [char](9) NOT NULL,
	[PaymentLastReceived_DATE] [char](8) NOT NULL,
	[TotalArrears_AMNT] [char](9) NOT NULL,
	[PaymentDue_DATE] [char](8) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
