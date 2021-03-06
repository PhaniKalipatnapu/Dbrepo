USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'Misc_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'StatusEft_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EftStatus_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'FirstTransfer_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'PreNote_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'TypeAccount_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Index [EFTR_CD_STATUS_EFT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [EFTR_CD_STATUS_EFT_I1] ON [dbo].[ElectronicFundTransfer_T1]
GO
/****** Object:  Table [dbo].[ElectronicFundTransfer_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ElectronicFundTransfer_T1]
GO
/****** Object:  Table [dbo].[ElectronicFundTransfer_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ElectronicFundTransfer_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[RoutingBank_NUMB] [numeric](9, 0) NOT NULL,
	[AccountBankNo_TEXT] [char](17) NOT NULL,
	[TypeAccount_CODE] [char](1) NOT NULL,
	[PreNote_DATE] [date] NOT NULL,
	[FirstTransfer_DATE] [date] NOT NULL,
	[EftStatus_DATE] [date] NOT NULL,
	[StatusEft_CODE] [char](2) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[Function_CODE] [char](3) NOT NULL,
	[Misc_ID] [char](11) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
 CONSTRAINT [EFTR_I1] PRIMARY KEY CLUSTERED 
(
	[CheckRecipient_CODE] ASC,
	[CheckRecipient_ID] ASC,
	[EventGlobalBeginSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [EFTR_CD_STATUS_EFT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [EFTR_CD_STATUS_EFT_I1] ON [dbo].[ElectronicFundTransfer_T1]
(
	[StatusEft_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the check recipient type. Possible values are 1 - MCI of the Member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Routing number of the Check Recipients bank account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'RoutingBank_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Account number of the Check Recipients bank account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'AccountBankNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Possible values are C - CHECKING, S - SAVINGS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'TypeAccount_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date that the pre-note information will end.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'PreNote_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date of the first wire transfer into recipients account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'FirstTransfer_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The status date of the EFT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EftStatus_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The status code for the EFT disbursement. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'StatusEft_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A reason code for the change in the status. Values are obtained from REFM (EFTR/EFRJ)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the reference NO to give unique identification to an EFT transfer. Possible values will be determined in the subsequent technical designs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the internal reference unique identifier to get an EFT fund Transfer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'Misc_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the details of the bank account number and status for the disbursement recipient. The recipient can be either a Member DCN Other state FIPS or the NJ state agencies. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElectronicFundTransfer_T1'
GO
