USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Payee_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'CheckDisburse_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'IssueVoid_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Account_NUMB'

GO
/****** Object:  Table [dbo].[ExtractCheckProcess_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractCheckProcess_T1]
GO
/****** Object:  Table [dbo].[ExtractCheckProcess_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractCheckProcess_T1](
	[Account_NUMB] [char](10) NOT NULL,
	[Rec_ID] [char](1) NOT NULL,
	[IssueVoid_DATE] [char](8) NOT NULL,
	[Check_NUMB] [char](10) NOT NULL,
	[CheckDisburse_AMNT] [char](12) NOT NULL,
	[Payee_ID] [char](15) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Bank Account Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Account_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Record Type Issue or Void' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the  Check is actually Void.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'IssueVoid_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Check number of the instrument' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The amount disbursed  to the recipient as a check .' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'CheckDisburse_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Social Security Number and first six character of last name of the member who receives the disbursement check ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1', @level2type=N'COLUMN',@level2name=N'Payee_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores the check information Obtained from  Disbursement Header Log (DSBH_Y1) table to generate a positive pay file to the bank ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractCheckProcess_T1'
GO
