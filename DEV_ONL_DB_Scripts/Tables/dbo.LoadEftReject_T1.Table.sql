USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CrTrans_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CrRouting_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CrAccount_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Return_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'ControlNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Indv_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Eft_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Account_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CheckDigit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Routing_NUMB'

GO
/****** Object:  Table [dbo].[LoadEftReject_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadEftReject_T1]
GO
/****** Object:  Table [dbo].[LoadEftReject_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadEftReject_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Routing_NUMB] [char](8) NOT NULL,
	[CheckDigit_CODE] [char](1) NOT NULL,
	[Account_NUMB] [char](17) NOT NULL,
	[Eft_AMNT] [char](10) NOT NULL,
	[Indv_IDNO] [char](15) NOT NULL,
	[Fips_CODE] [char](7) NOT NULL,
	[ControlNo_TEXT] [char](11) NOT NULL,
	[Return_CODE] [char](3) NOT NULL,
	[CrAccount_NUMB] [char](17) NOT NULL,
	[CrRouting_NUMB] [char](9) NOT NULL,
	[CrTrans_NUMB] [char](2) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LEREJ_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Routing Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Routing_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Check Digit.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CheckDigit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Account Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Account_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Rejected Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Eft_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first 11 digits represent Case ID if the check number starts with C -CP 3 digits represent CWA if the check number starts with T - TANF and 3 digits represent FIPS if the check number starts with A - Agency.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Indv_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Fips ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to store the Control number, if the fund is disbursed as an EFT/Debit card.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'ControlNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Return Code (Rejected Code / Modified Code)If RETURN_CODE starts with R, then it is rejected. If RETURN_CODE starts with C, then it is modified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Return_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Corrected Data - Account Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CrAccount_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Corrected Data - Routing Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CrRouting_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Corrected Data - Trans(Account Type).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'CrTrans_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'To load the reject file received from the bank' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftReject_T1'
GO
