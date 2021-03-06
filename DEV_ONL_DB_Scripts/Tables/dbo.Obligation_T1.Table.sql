USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'AccrualNext_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'AccrualLast_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EndObligation_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'BeginObligation_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ReasonChange_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'Periodic_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'FreqPeriodic_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [OBLE_OWIZ_DATE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [OBLE_OWIZ_DATE_I1] ON [dbo].[Obligation_T1]
GO
/****** Object:  Index [OBLE_MEMBER_FIPS_DEBT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [OBLE_MEMBER_FIPS_DEBT_I1] ON [dbo].[Obligation_T1]
GO
/****** Object:  Table [dbo].[Obligation_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Obligation_T1]
GO
/****** Object:  Table [dbo].[Obligation_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Obligation_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[TypeDebt_CODE] [char](2) NOT NULL,
	[Fips_CODE] [char](7) NOT NULL,
	[FreqPeriodic_CODE] [char](1) NOT NULL,
	[Periodic_AMNT] [numeric](11, 2) NOT NULL,
	[ExpectToPay_AMNT] [numeric](11, 2) NOT NULL,
	[ExpectToPay_CODE] [char](1) NOT NULL,
	[ReasonChange_CODE] [char](2) NOT NULL,
	[BeginObligation_DATE] [date] NOT NULL,
	[EndObligation_DATE] [date] NOT NULL,
	[AccrualLast_DATE] [date] NOT NULL,
	[AccrualNext_DATE] [date] NOT NULL,
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
 CONSTRAINT [OBLE_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC,
	[ObligationSeq_NUMB] ASC,
	[BeginObligation_DATE] ASC,
	[EventGlobalBeginSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [OBLE_MEMBER_FIPS_DEBT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [OBLE_MEMBER_FIPS_DEBT_I1] ON [dbo].[Obligation_T1]
(
	[Case_IDNO] ASC,
	[OrderSeq_NUMB] ASC,
	[MemberMci_IDNO] ASC,
	[TypeDebt_CODE] ASC,
	[Fips_CODE] ASC,
	[BeginObligation_DATE] ASC,
	[EndObligation_DATE] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [OBLE_OWIZ_DATE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [OBLE_OWIZ_DATE_I1] ON [dbo].[Obligation_T1]
(
	[EndValidity_DATE] ASC,
	[BeginObligation_DATE] ASC
)
INCLUDE ( 	[Case_IDNO],
	[EndObligation_DATE],
	[FreqPeriodic_CODE],
	[ObligationSeq_NUMB],
	[OrderSeq_NUMB],
	[TypeDebt_CODE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is the Case ID of the member for whom the obligation is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Internal Sequence number generated for each Obligation under each order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique number assigned by the system to the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the type of debt. Values are obtained from REFM (DBTP/DBTP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the FIPS (Federal Information Processing Standard) code of the state. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code assigned to indicate how often the support amount must be paid. Values are obtained from REFM (FRQA/FRQ3) and REFM (FRQA/FRQ4)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'FreqPeriodic_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field specifies the obligation amount to be collected for a given time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'Periodic_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Expect to pay payment amount for the court ordered arrears.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court Ordered type specified for this obligation. Values are obtained from REFM (OWIZ/PAYT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code assigned to the reason for which the obligation was changed. Values are obtained from REFM (OWIZ/REAS) and REFM (OBLM/OBLM)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'ReasonChange_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'This is the effective start date for the obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'BeginObligation_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the effective End date for the obligation. The periodic amount/ Frequency for this obligation are always same between the dates DT_BEG_OBLIGATION and DT_END_OBLIGATION.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EndObligation_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date in which last accrual happened.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'AccrualLast_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date in which the next accrual will occur.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'AccrualNext_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of the member who received the disbursement OR the State Payment FIPS Code of the State that received the disbursement OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the check recipient type. Values are obtained from REFM (GENR/FUND)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the Obligation details such as the debt type the obligated member, periodic amount etc. for a given Case. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Obligation_T1'
GO
