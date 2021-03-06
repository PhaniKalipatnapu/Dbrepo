USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'RsnStatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'Deceased_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'RecordRowNumber_NUMB'

GO
/****** Object:  Index [CCLR_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [CCLR_CASE_I1] ON [dbo].[IntCclrWeekly_T1]
GO
/****** Object:  Table [dbo].[IntCclrWeekly_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntCclrWeekly_T1]
GO
/****** Object:  Table [dbo].[IntCclrWeekly_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntCclrWeekly_T1](
	[RecordRowNumber_NUMB] [numeric](15, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[RespondInit_CODE] [char](1) NOT NULL,
	[Deceased_DATE] [date] NOT NULL,
	[RsnStatusCase_CODE] [char](2) NOT NULL,
	[NonCoop_CODE] [char](1) NOT NULL,
	[GoodCause_CODE] [char](1) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [PCCLR_I1] PRIMARY KEY CLUSTERED 
(
	[RecordRowNumber_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CCLR_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [CCLR_CASE_I1] ON [dbo].[IntCclrWeekly_T1]
(
	[Case_IDNO] ASC,
	[Process_INDC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This indicates the record row number for each record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'RecordRowNumber_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Case ID of the member for whom the Remedy is being enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Member ID for whom the Minor Activity has been inserted for the Remedy enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Case is Initiation or Responding. Values obtained from REFM (INTS/CATG).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the member was deceased' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'Deceased_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Status Case Reason. Values are obtained from REFM (CCRT/CCLO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'RsnStatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non Cooperation Indicator. Values are obtained from REFM (CCRT/NCOP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Good Cause Code. Values are obtained from REFM (CCRT/GOOD)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Type of the Case. Values are obtained from REFM (WRKL/CTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates process of records. Values are `N-Not processed records,’ A-Aborted records` and `E-VBATE exemption records`.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store all the records to be processed by CASE CLOSURE weekly batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntCclrWeekly_T1'
GO
