USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'DisburseSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Table [dbo].[LogDisbursementEft_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LogDisbursementEft_T1]
GO
/****** Object:  Table [dbo].[LogDisbursementEft_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogDisbursementEft_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Disburse_DATE] [date] NOT NULL,
	[DisburseSeq_NUMB] [numeric](4, 0) NOT NULL,
	[RoutingBank_NUMB] [numeric](9, 0) NOT NULL,
	[AccountBankNo_TEXT] [char](17) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [DEFT_I1] PRIMARY KEY CLUSTERED 
(
	[CheckRecipient_CODE] ASC,
	[CheckRecipient_ID] ASC,
	[Disburse_DATE] ASC,
	[DisburseSeq_NUMB] ASC,
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the check recipient type. Possible values are 1 - MCI of the member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Date on which the check is sent to check recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'This is automatically incremented when a CP gets more than one check on a single day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'DisburseSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Routing number of the Check Recipients bank account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Bank Account number of the Check Recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores the log of the routing and account number associated with all the EFT or Stored value Card disbursement to the recipients' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementEft_T1'
GO
