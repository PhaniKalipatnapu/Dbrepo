USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Misc_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Issue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'StatusCheck_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'StatusCheck_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'MediumDisburse_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'DisburseSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Index [DSBH_STATUS_CHECK_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DSBH_STATUS_CHECK_I1] ON [dbo].[LogDisbursementHeader_T1]
GO
/****** Object:  Index [DSBH_NO_CHECK_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DSBH_NO_CHECK_I1] ON [dbo].[LogDisbursementHeader_T1]
GO
/****** Object:  Index [DSBH_MISC_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DSBH_MISC_I1] ON [dbo].[LogDisbursementHeader_T1]
GO
/****** Object:  Index [DSBH_CD_STATUS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DSBH_CD_STATUS_I1] ON [dbo].[LogDisbursementHeader_T1]
GO
/****** Object:  Table [dbo].[LogDisbursementHeader_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LogDisbursementHeader_T1]
GO
/****** Object:  Table [dbo].[LogDisbursementHeader_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogDisbursementHeader_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Disburse_DATE] [date] NOT NULL,
	[DisburseSeq_NUMB] [numeric](4, 0) NOT NULL,
	[MediumDisburse_CODE] [char](1) NOT NULL,
	[Disburse_AMNT] [numeric](11, 2) NOT NULL,
	[Check_NUMB] [numeric](19, 0) NOT NULL,
	[StatusCheck_CODE] [char](2) NOT NULL,
	[StatusCheck_DATE] [date] NOT NULL,
	[ReasonStatus_CODE] [char](2) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[Issue_DATE] [date] NOT NULL,
	[Misc_ID] [char](11) NOT NULL,
 CONSTRAINT [DSBH_I1] PRIMARY KEY CLUSTERED 
(
	[CheckRecipient_CODE] ASC,
	[CheckRecipient_ID] ASC,
	[Disburse_DATE] ASC,
	[DisburseSeq_NUMB] ASC,
	[EventGlobalBeginSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DSBH_CD_STATUS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DSBH_CD_STATUS_I1] ON [dbo].[LogDisbursementHeader_T1]
(
	[MediumDisburse_CODE] ASC,
	[StatusCheck_CODE] ASC,
	[StatusCheck_DATE] ASC,
	[CheckRecipient_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DSBH_MISC_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DSBH_MISC_I1] ON [dbo].[LogDisbursementHeader_T1]
(
	[Disburse_DATE] ASC,
	[EndValidity_DATE] ASC,
	[Misc_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [DSBH_NO_CHECK_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DSBH_NO_CHECK_I1] ON [dbo].[LogDisbursementHeader_T1]
(
	[Disburse_DATE] ASC,
	[Check_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DSBH_STATUS_CHECK_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DSBH_STATUS_CHECK_I1] ON [dbo].[LogDisbursementHeader_T1]
(
	[StatusCheck_CODE] ASC,
	[Issue_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the check recipient type. Possible values are 1 - MCI of the Member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Date on which the check is sent to check recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'This is automatically incremented when a CP gets more than one check on a single day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'DisburseSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The medium in which the amount is disbursed. Possible values are C-Check, D-Debit-Card, E-EFT, and D-Demand Check.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'MediumDisburse_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The amount given to the recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Check number of the instrument, if disbursed as a Check.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Status of the Check once it is disbursed. Possible values are OU-Outstanding, CA-Cashed, VO-Void, ST-Stop, SL-Stale date and a few more.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'StatusCheck_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the status of the check is modified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'StatusCheck_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The reason code for the Change in status. This is more applicable when Check is void or Stopped. Values are obtained from REFM (CHVR/CHVR)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the Check is actually issued. This could differ from the dt_disburse in some odd scenarios, when there is a mis-time in Batch run.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Issue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to store the Control number, if the fund is disbursed as an EFT/Debit card.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1', @level2type=N'COLUMN',@level2name=N'Misc_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the recipient disbursement related information  such as the Disbursement medium, check or control no and the disbursement status. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogDisbursementHeader_T1'
GO
