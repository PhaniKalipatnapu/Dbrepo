USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'EndingBalance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'BeginBalance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'DescriptionBucket_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'TypeRecord_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'ObligationKey_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Event_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[TmpSlogPopUp_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[TmpSlogPopUp_P1]
GO
/****** Object:  Table [dbo].[TmpSlogPopUp_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TmpSlogPopUp_P1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[Order_IDNO] [numeric](15, 0) NOT NULL,
	[Event_DATE] [date] NOT NULL,
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
	[ObligationKey_TEXT] [char](20) NOT NULL,
	[TypeWelfare_CODE] [char](1) NOT NULL,
	[TypeRecord_CODE] [char](1) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[DescriptionBucket_TEXT] [char](40) NOT NULL,
	[Transaction_AMNT] [numeric](11, 2) NOT NULL,
	[BeginBalance_AMNT] [numeric](11, 2) NOT NULL,
	[EndingBalance_AMNT] [numeric](11, 2) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Case ID of the member for whom the obligation is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Identifier assigned to Support Order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date-time on which the event took place.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Event_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the event which creates this record. Possible Events are: Accrual, Accrual Adjustment, Arrear Adjustment, Distribution and Back out.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Combination of CD_TYPE_DEBT,ID_MEMBER and ID_FIPS.CD_TYPE_DEBT Identifies the type of debt. Valid Values are store in REFM with id_table as DBTP and id_table_sub as DBTP.ID_MEMBER is the Unique number assigned by the system to the member.ID_FIPS is the FIPS (Federal Information Processing Standard) code of the state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'ObligationKey_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the welfare type of the member. Valid Values are stored in REFM with id_table as MHIS and id_table_sub as PGTY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the original transaction records. Valid Values are: O - Original Transaction Records, P - Carried Forward Transaction Records, C - Circular Rule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'TypeRecord_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description of the PRWORA buckets.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'DescriptionBucket_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount accrued, adjusted or applied towards a PRWORA bucket.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'Transaction_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Beginning balance for a given transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'BeginBalance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Ending balance for a given transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1', @level2type=N'COLUMN',@level2name=N'EndingBalance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is global temporary table used by SLThis is global temporary table used by SLOG screen to display the month level details when user double-click on the desired month in SLOG screen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpSlogPopUp_P1'
GO
