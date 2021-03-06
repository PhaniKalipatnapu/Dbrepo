USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentDue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'TotalArrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'FreqPay_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'Order_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpPolicyInsNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpInsuranceProvider_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpAddrNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerFEIN_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpAddrNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpRace_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSuffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmpAddrNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerFein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpAddrNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpRace_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSuffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'ApSequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadIVAReferralDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadIVAReferralDetails_T1]
GO
/****** Object:  Table [dbo].[LoadIVAReferralDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadIVAReferralDetails_T1](
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
	[Process_CODE] [char](1) NOT NULL,
 CONSTRAINT [LIVAD_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the record uniquely.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Welfare Case Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Welfare Client MCI Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent parent MCI number from the welfare case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Assistance Group Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Welfare Absent Parent Sequence Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'ApSequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s first name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s middle initial.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s suffix name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSuffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s gender.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Client’s race.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpRace_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates address normalization status for CP. Values are obtained from REFM (ADDR/NORM).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpAddrNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s employer name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s employer EIN number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerFein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates address normalization status for CP employer. Values are obtained from REFM (ADDR/NORM).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmpAddrNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s Employer''s address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s Employer''s address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s Employer''s address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s Employer''s address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s Employer''s addresses zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'CpEmployerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s first name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s middle initial.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s suffix name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSuffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s gender.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s race.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpRace_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates address normalization status for NCP. Values are obtained from REFM (ADDR/NORM).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpAddrNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s employer name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s employer EIN number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerFEIN_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates address normalization status for NCP Employer. Values are obtained from REFM (ADDR/NORM).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmpAddrNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s Employer''s address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s Employer''s address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s Employer''s address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s Employer''s address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent Parent’s Employer''s addresses zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmployerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent parent’s insurance provider name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpInsuranceProvider_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Absent parent’s insurance policy number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpPolicyInsNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order number from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order establishment date from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order amount from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'Order_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order amount payment frequency from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'FreqPay_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order Payment mode from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order last payment amount from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order last payment date from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order total arrears from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'TotalArrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Support order payment due date from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentDue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the status of the process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the member details as well employer and support order details.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIVAReferralDetails_T1'
GO
