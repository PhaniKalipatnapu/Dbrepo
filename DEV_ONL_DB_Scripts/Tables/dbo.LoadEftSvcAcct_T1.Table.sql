USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'CheckDigit_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'EftTrans_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'AddDelete_CODE'

GO
/****** Object:  Table [dbo].[LoadEftSvcAcct_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadEftSvcAcct_T1]
GO
/****** Object:  Table [dbo].[LoadEftSvcAcct_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadEftSvcAcct_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[AddDelete_CODE] [char](1) NOT NULL,
	[Last_NAME] [char](5) NOT NULL,
	[MemberMci_IDNO] [char](8) NOT NULL,
	[EftTrans_CODE] [char](2) NOT NULL,
	[RoutingBank_NUMB] [char](8) NOT NULL,
	[CheckDigit_IDNO] [char](1) NOT NULL,
	[AccountBankNo_TEXT] [char](17) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LESVC_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates to add or delete record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'AddDelete_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of the member who received the disbursement check.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the CP operation type.23 for DD Checking Account,33 for DD Savings Account,42 for SVC Card only required for A records; blanks for D records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'EftTrans_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First 8 positions of the RT number for the DFIDD from the Client''s voided check. SVC - 09100001 - Commercial Bank routing number Only required for A records. blanks for D records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'9th position of the RT number for the DFIDD from the Client''s voided check. SVC - 9 Check Digit - Commercial Bank routing number Only required for A records. blanks for D records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'CheckDigit_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'DD: Client''s bank account number from the voided check.SVC: Disposition if ACH Account Number: Positions 027-032 NJ BIN six digit, Positions 033-042 - ACS Generated Account Number, Positions 043-043 - Program Identifier Child Support. 1Note: The entire 17 digits comprise the ACH account # which should be included in the ACH File sent to EPPIC for deposits. Only required for A records; blanks for D records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the record is processed or not. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to load the records from SDU file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEftSvcAcct_T1'
GO
