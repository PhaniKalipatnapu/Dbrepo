USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'RdfiAcctNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Rdfi_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentSource_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Posting_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[ExtractCollectionBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractCollectionBlocks_T1]
GO
/****** Object:  Table [dbo].[ExtractCollectionBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractCollectionBlocks_T1](
	[TransHeader_IDNO] [char](12) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[BlockSeq_NUMB] [numeric](2, 0) NOT NULL,
	[Collection_DATE] [date] NOT NULL,
	[Posting_DATE] [date] NOT NULL,
	[Payment_AMNT] [numeric](11, 2) NOT NULL,
	[PaymentSource_CODE] [char](1) NOT NULL,
	[PaymentMethod_CODE] [char](1) NOT NULL,
	[Rdfi_ID] [char](20) NOT NULL,
	[RdfiAcctNo_TEXT] [char](20) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the occurrence of the number of orders received in the file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date of this particular collection.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Posting Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Posting_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment Source.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentSource_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment method.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reserved for Electronic Funds Transfer use.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Rdfi_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Account Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'RdfiAcctNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Collection Data Block and carry out validations for outbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCollectionBlocks_T1'
GO
