USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentSource_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Posting_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[LoadCollectionBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadCollectionBlocks_T1]
GO
/****** Object:  Table [dbo].[LoadCollectionBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[LoadCollectionBlocks_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[TransHeader_IDNO] [char](12) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [char](8) NOT NULL,
	[BlockSeq_NUMB] [char](2) NOT NULL,
	[Collection_DATE] [char](8) NOT NULL,
	[Posting_DATE] [char](8) NOT NULL,
	[Payment_AMNT] [char](12) NOT NULL,
	[PaymentSource_CODE] [char](1) NOT NULL,
	[PaymentMethod_CODE] [char](1) NOT NULL,
	[Rdfi_ID] [char](20) NOT NULL,
	[RdfiAcctNo_TEXT] [char](20) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[LoadCollectionBlocks_T1] ADD [Process_INDC] [char](1) NOT NULL
 CONSTRAINT [LCBLK_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the occurrence of the number of orders received in the file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date of this particular collection.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Posting Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Posting_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Payment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment Source.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentSource_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payment method.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'PaymentMethod_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the record is processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Collections Data Block and carry out validations for inbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCollectionBlocks_T1'
GO
