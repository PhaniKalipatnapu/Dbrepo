USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine5_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine4_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine3_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine2_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine1_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'CaseNew_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'StatusChange_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[ExtractInfoBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractInfoBlocks_T1]
GO
/****** Object:  Table [dbo].[ExtractInfoBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractInfoBlocks_T1](
	[TransHeader_IDNO] [char](12) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[StatusChange_CODE] [char](1) NOT NULL,
	[CaseNew_ID] [char](15) NOT NULL,
	[InfoLine1_TEXT] [varchar](80) NOT NULL,
	[InfoLine2_TEXT] [varchar](80) NOT NULL,
	[InfoLine3_TEXT] [varchar](80) NOT NULL,
	[InfoLine4_TEXT] [varchar](80) NOT NULL,
	[InfoLine5_TEXT] [varchar](80) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to indicate whether the case status has changed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'StatusChange_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will be  used to transmit a new, changed, or corrected IV-D case ID to another state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'CaseNew_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Information Line1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine1_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Information Line2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine2_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Information Line3.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine3_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Information Line4.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine4_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Information Line5.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1', @level2type=N'COLUMN',@level2name=N'InfoLine5_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Information Data Block and carry out validations for outbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractInfoBlocks_T1'
GO
