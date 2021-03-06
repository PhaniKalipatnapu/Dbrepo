USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentDue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'TotalArrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'FreqPay_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'Order_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'NcpPolicyInsNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'NcpInsuranceProvider_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'ReferralReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
/****** Object:  Table [dbo].[PendingIvaReferralsSord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PendingIvaReferralsSord_T1]
GO
/****** Object:  Table [dbo].[PendingIvaReferralsSord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingIvaReferralsSord_T1](
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[AgSequence_NUMB] [numeric](4, 0) NOT NULL,
	[ReferralReceived_DATE] [date] NOT NULL,
	[NcpInsuranceProvider_NAME] [varchar](60) NOT NULL,
	[NcpPolicyInsNo_TEXT] [char](18) NOT NULL,
	[OrderSeq_NUMB] [numeric](7, 0) NOT NULL,
	[OrderIssued_DATE] [date] NOT NULL,
	[Order_AMNT] [numeric](11, 2) NOT NULL,
	[FreqPay_CODE] [char](1) NOT NULL,
	[PaymentType_CODE] [char](1) NOT NULL,
	[PaymentLastReceived_AMNT] [numeric](11, 2) NOT NULL,
	[PaymentLastReceived_DATE] [date] NOT NULL,
	[TotalArrears_AMNT] [numeric](11, 2) NOT NULL,
	[PaymentDue_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [PRSO_I1] PRIMARY KEY CLUSTERED 
(
	[CaseWelfare_IDNO] ASC,
	[AgSequence_NUMB] ASC,
	[ReferralReceived_DATE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies Welfare Case Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Stores DSS Assistance Group Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Stores Support order payment due date from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'ReferralReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Absent parent’s insurance provider name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'NcpInsuranceProvider_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Absent parent’s insurance policy number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'NcpPolicyInsNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order number from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order establishment date from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order amount from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'Order_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order amount payment frequency from DSS. Possible values are B, W, I, M and S.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'FreqPay_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order Payment mode from DSS. Possible values are C – Paid directly to CP, S- Paid to DCSE via SDU' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order last payment amount from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order last payment date from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'TotalArrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Support order total arrears from DSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'PaymentDue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the support order level details of the pending referrals.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingIvaReferralsSord_T1'
GO
