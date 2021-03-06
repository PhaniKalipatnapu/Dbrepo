USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Check_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'CheckSerial_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'PaidCheck_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadCheckClear_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadCheckClear_T1]
GO
/****** Object:  Table [dbo].[LoadCheckClear_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadCheckClear_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[AccountBankNo_TEXT] [char](10) NOT NULL,
	[Rec_ID] [char](1) NOT NULL,
	[PaidCheck_DATE] [char](8) NOT NULL,
	[CheckSerial_NUMB] [char](10) NOT NULL,
	[Check_AMNT] [char](12) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LCCLE_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Bank Account number of the Check Recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the record type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date when the check was cashed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'PaidCheck_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate the Check Serial number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'CheckSerial_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate the Check amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Check_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the record is processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'It is used to store the Bank Reconciliation file received from Disbursements bank. This table is used in BATCH_FIN_CLEARED_CHECKS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCheckClear_T1'
GO
