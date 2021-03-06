USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'ReasonPayBack_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'PayBack_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'FreqPeriodic_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Periodic_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Record_NUMB'

GO
/****** Object:  Table [dbo].[PendingObligation_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PendingObligation_T1]
GO
/****** Object:  Table [dbo].[PendingObligation_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingObligation_T1](
	[Record_NUMB] [numeric](19, 0) NOT NULL,
	[TypeDebt_CODE] [char](2) NOT NULL,
	[Fips_CODE] [char](7) NOT NULL,
	[Periodic_AMNT] [numeric](11, 2) NOT NULL,
	[FreqPeriodic_CODE] [char](1) NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[End_DATE] [date] NOT NULL,
	[CheckRecipient_ID] [char](10) NOT NULL,
	[PayBack_INDC] [char](1) NOT NULL,
	[ReasonPayBack_CODE] [char](1) NOT NULL,
	[Process_CODE] [char](1) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [POBL_I1] PRIMARY KEY CLUSTERED 
(
	[Record_NUMB] ASC,
	[TypeDebt_CODE] ASC,
	[Fips_CODE] ASC,
	[PayBack_INDC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Record_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the type of debt. Values are obtained from REFM (DBTP/DBTP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'TypeDebt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Federal Information Processing Standard code of the state. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field specifies the obligation amount to be collected for a given time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Periodic_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This the Time period of the frequency of Obligation Payment. Values are obtained from REFM (FRQA/FRQ3) and REFM (FRQA/FRQ4).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'FreqPeriodic_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the effective start date for the obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the end date for the obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of the member who received the disbursement OR the State Payment FIPS Code of the State that received the disbursement OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Indicates the payback exists for the obligation. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'PayBack_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Reason for the pay back. Possible values are C - Court Ordered, S - System Ordered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'ReasonPayBack_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the temporary record is processed and moved to OBLE table. 
Possible values are L - loaded, P - In Process, C - Compelted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the worker last updated the record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last date and time the record modified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Temporary table to have processed incoming FAMIS information before reviewing in OWIZ.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingObligation_T1'
GO
