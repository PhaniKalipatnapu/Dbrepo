USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'RdfiAcctNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Rdfi_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentSource_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Posting_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[CsenetCollectionBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CsenetCollectionBlocks_T1]
GO
/****** Object:  Table [dbo].[CsenetCollectionBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CsenetCollectionBlocks_T1](
	[TransHeader_IDNO] [numeric](12, 0) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[BlockSeq_NUMB] [numeric](2, 0) NOT NULL,
	[Collection_DATE] [date] NOT NULL,
	[Posting_DATE] [date] NOT NULL,
	[Payment_AMNT] [numeric](11, 2) NOT NULL,
	[PaymentSource_CODE] [char](1) NOT NULL,
	[PaymentMethod_CODE] [char](1) NOT NULL,
	[Rdfi_ID] [char](20) NOT NULL,
	[RdfiAcctNo_TEXT] [char](20) NOT NULL,
 CONSTRAINT [CCLB_I1] PRIMARY KEY CLUSTERED 
(
	[TransHeader_IDNO] ASC,
	[IVDOutOfStateFips_CODE] ASC,
	[Transaction_DATE] ASC,
	[BlockSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'State FIPS for the state with which you are communicating. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'This is the occurrence of the number of orders received in the file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date of this particular collection.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Posting Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Posting_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment Source. Values are obtained from REFM (CSEN/IPSR).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentSource_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment method. Values are obtained from REFM (CSEN/IPME).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reserved for Electronic Funds Transfer use.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Rdfi_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Account Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'RdfiAcctNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table hold data for Collection Data Block  for incoming and outgoing CSENET transactions' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetCollectionBlocks_T1'
GO
