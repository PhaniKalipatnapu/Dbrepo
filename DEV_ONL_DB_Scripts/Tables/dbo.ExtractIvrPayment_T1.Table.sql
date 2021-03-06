USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Tax_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAsOf_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'BalanceCurSupAsOf_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'BalanceCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'PaymentReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[ExtractIvrPayment_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractIvrPayment_T1]
GO
/****** Object:  Table [dbo].[ExtractIvrPayment_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractIvrPayment_T1](
	[Case_IDNO] [char](6) NOT NULL,
	[Payment_AMNT] [char](10) NOT NULL,
	[PaymentReceived_DATE] [char](10) NOT NULL,
	[BalanceCurSup_AMNT] [char](10) NOT NULL,
	[BalanceCurSupAsOf_DATE] [char](10) NOT NULL,
	[Arrears_AMNT] [char](10) NOT NULL,
	[ArrearsAsOf_DATE] [char](10) NOT NULL,
	[Tax_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies a unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last payment received amount for Identified receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last payment received date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'PaymentReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Current Support Balance' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'BalanceCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Current Support Balance Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'BalanceCurSupAsOf_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the arrears for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Arrear Balance Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAsOf_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Tax intercept indicator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1', @level2type=N'COLUMN',@level2name=N'Tax_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores information needed to send a payment file for AAL process' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIvrPayment_T1'
GO
