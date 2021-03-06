USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'CheckAmountLiteral_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line4_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line3_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'FeesTaken_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'PaymentBatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Payor_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Payee_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Check_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Check_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'

GO
/****** Object:  Table [dbo].[ExtractCheck_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractCheck_T1]
GO
/****** Object:  Table [dbo].[ExtractCheck_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractCheck_T1](
	[Check_NUMB] [char](8) NOT NULL,
	[Check_DATE] [char](10) NOT NULL,
	[Receipt_DATE] [char](10) NOT NULL,
	[Check_AMNT] [char](12) NOT NULL,
	[Payee_NAME] [varchar](58) NOT NULL,
	[Payor_NAME] [varchar](58) NOT NULL,
	[Case_IDNO] [char](6) NOT NULL,
	[PaymentBatch_CODE] [char](27) NOT NULL,
	[FeesTaken_AMNT] [char](8) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[Line3_ADDR] [varchar](47) NOT NULL,
	[Line4_ADDR] [varchar](70) NOT NULL,
	[CheckAmountLiteral_TEXT] [varchar](80) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[IVDOutOfStateCase_ID] [char](15) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Check number of the instrument.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the check is sent to check recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Check_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the Receipt batch is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Receipt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The amount given to the recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Check_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Full name of the recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Payee_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Full name of the person from whom the payment is received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Payor_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID generated for the DECSS Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Receipt Number is the combination of Batch_DATE, SourceBatch_CODE, Batch_NUMB and SeqReceipt_NUMB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'PaymentBatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of fee recovered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'FeesTaken_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Recipient first line of the street address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Recipient second line of the street address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Recipient Residing City, State and Zip Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line3_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Recipient Residing Country.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Line4_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Check amount in literal' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'CheckAmountLiteral_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the check PDF is created successfully or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Other State Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used in BATCH_FIN_EXT_CHECK process as a staging table to create PDF file for Check Printing' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheck_T1'
GO
