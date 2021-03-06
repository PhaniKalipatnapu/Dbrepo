USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalOrigSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'DisburseOrigSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'DisburseOrig_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipientOrig_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipientOrig_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'DisburseSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Index [DSBC_ORIG_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DSBC_ORIG_I1] ON [dbo].[LogDisbursementHdrChg_T1]
GO
/****** Object:  Index [DSBC_DISBURSE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DSBC_DISBURSE_I1] ON [dbo].[LogDisbursementHdrChg_T1]
GO
/****** Object:  Table [dbo].[LogDisbursementHdrChg_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LogDisbursementHdrChg_T1]
GO
/****** Object:  Table [dbo].[LogDisbursementHdrChg_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogDisbursementHdrChg_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Disburse_DATE] [date] NOT NULL,
	[DisburseSeq_NUMB] [numeric](4, 0) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[CheckRecipientOrig_ID] [char](10) NOT NULL,
	[CheckRecipientOrig_CODE] [char](1) NOT NULL,
	[DisburseOrig_DATE] [date] NOT NULL,
	[DisburseOrigSeq_NUMB] [numeric](4, 0) NOT NULL,
	[EventGlobalOrigSeq_NUMB] [numeric](19, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DSBC_DISBURSE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DSBC_DISBURSE_I1] ON [dbo].[LogDisbursementHdrChg_T1]
(
	[CheckRecipient_ID] ASC,
	[CheckRecipient_CODE] ASC,
	[Disburse_DATE] ASC,
	[DisburseSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DSBC_ORIG_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DSBC_ORIG_I1] ON [dbo].[LogDisbursementHdrChg_T1]
(
	[CheckRecipientOrig_ID] ASC,
	[CheckRecipientOrig_CODE] ASC,
	[DisburseOrig_DATE] ASC,
	[DisburseOrigSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the check recipient type. Possible values are 1 - MCI of the member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the check is sent to check recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is automatically incremented when a CP gets more than one check on a single day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'DisburseSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Recipient ID of the Original disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipientOrig_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Recipient type of the Original disbursement (MCI, FIPS or Other party). Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipientOrig_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The disbursed date of the Original disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'DisburseOrig_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The disburse sequence of the Original Disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'DisburseOrigSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global sequence number generated for the Original Disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalOrigSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores the cross reference between the original disbursement and the re-issued disbursement. Re-issued disbursement can be from voiding a check or a EFT reject' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHdrChg_T1'
GO
