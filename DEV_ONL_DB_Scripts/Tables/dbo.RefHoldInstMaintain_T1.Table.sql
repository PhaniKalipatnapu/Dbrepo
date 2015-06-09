USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'UdcCaseHold_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'CaseHold_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'UdcDistNonIvd_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'DistNonIvd_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'

GO
/****** Object:  Table [dbo].[RefHoldInstMaintain_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefHoldInstMaintain_T1]
GO
/****** Object:  Table [dbo].[RefHoldInstMaintain_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefHoldInstMaintain_T1](
	[SourceReceipt_CODE] [char](2) NOT NULL,
	[DistNonIvd_INDC] [char](1) NOT NULL,
	[UdcDistNonIvd_CODE] [char](4) NOT NULL,
	[CaseHold_INDC] [char](1) NOT NULL,
	[UdcCaseHold_CODE] [char](4) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TypePosting_CODE] [char](1) NOT NULL,
 CONSTRAINT [HIMS_I1] PRIMARY KEY CLUSTERED 
(
	[SourceReceipt_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This field will hold the source of the receipt for which this global Hold instruction is set.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'SourceReceipt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to specify whether the collection with receipt source can be distributed to a Non-IVD case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'DistNonIvd_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'UDC code to hold the collection, when the receipt source cannot be distributed to a Non-IVD case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'UdcDistNonIvd_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to specify whether the collection can be held, when the system receives a check value over $1000 from the receipt source.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'CaseHold_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'UDC code to hold the collection, when the system receives a check value over $1000.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'UdcCaseHold_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information Will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for any given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the level of posting, whether at Payor or Case level.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1', @level2type=N'COLUMN',@level2name=N'TypePosting_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the system hold instruction details for every receipt source. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefHoldInstMaintain_T1'
GO
