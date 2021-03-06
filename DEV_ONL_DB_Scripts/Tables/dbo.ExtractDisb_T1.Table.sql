USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'AddendaRecord_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Payee_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Individual_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Transaction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'RecordType_CODE'

GO
/****** Object:  Table [dbo].[ExtractDisb_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractDisb_T1]
GO
/****** Object:  Table [dbo].[ExtractDisb_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractDisb_T1](
	[RecordType_CODE] [char](1) NOT NULL,
	[Transaction_CODE] [char](2) NOT NULL,
	[RoutingBank_NUMB] [char](9) NOT NULL,
	[AccountBankNo_TEXT] [char](17) NOT NULL,
	[Disburse_AMNT] [char](10) NOT NULL,
	[Individual_NUMB] [char](15) NOT NULL,
	[Payee_NAME] [char](22) NOT NULL,
	[AddendaRecord_TEXT] [varchar](80) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Record Type for Prenote and EFT/SVC.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'RecordType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction code for checking or saving accounts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Transaction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Routing number of the Check Recipients bank account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Account number of the Check Recipients bank account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The amount given to the recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Payee identification number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Individual_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Full name of the recipient' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'Payee_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is ''free form'' data compressed into one field. Each individual field is separated by ''*''.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1', @level2type=N'COLUMN',@level2name=N'AddendaRecord_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Table is used in BATCH_FIN_EFT_SVC_PNOTE_DISB process as a staging table for creating output file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDisb_T1'
GO
