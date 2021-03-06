USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Loaded_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'SordNotes_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Judge_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Commissioner_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'SourceOrdered_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DirectPay_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderOutOfState_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DeviationReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'GuidelinesFollowed_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Iiwo_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'InsOrdered_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Record_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[PendingSupportOrder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PendingSupportOrder_T1]
GO
/****** Object:  Table [dbo].[PendingSupportOrder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingSupportOrder_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[Record_NUMB] [numeric](19, 0) NOT NULL,
	[Order_IDNO] [numeric](15, 0) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[OrderIssued_DATE] [date] NOT NULL,
	[StatusOrder_CODE] [char](1) NOT NULL,
	[InsOrdered_CODE] [char](1) NOT NULL,
	[Iiwo_CODE] [char](2) NOT NULL,
	[GuidelinesFollowed_INDC] [char](1) NOT NULL,
	[DeviationReason_CODE] [char](2) NOT NULL,
	[OrderOutOfState_ID] [char](15) NOT NULL,
	[TypeOrder_CODE] [char](1) NOT NULL,
	[DirectPay_INDC] [char](1) NOT NULL,
	[SourceOrdered_CODE] [char](1) NOT NULL,
	[Commissioner_ID] [char](30) NOT NULL,
	[Judge_ID] [char](30) NOT NULL,
	[SordNotes_TEXT] [varchar](4000) NOT NULL,
	[Process_CODE] [char](1) NOT NULL,
	[Loaded_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [PSRD_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[Record_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies DECSS case number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Record_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies assigned to Support Order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the File Number assigned for the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date in which the support order was issued.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The current status of the order. Values are obtained from REFM (SORD/INSC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if insurance is ordered on this order. Values are obtained from REFM (SORD/INSO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'InsOrdered_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code indicating that an immediate income withholding is provided for in the support order. Values are obtained from REFM (SORD/IWOR).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Iiwo_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether or not guidelines were used while calculating the support order. Possible values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'GuidelinesFollowed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Interstate, Private Attorney. Values are obtained from REFM (DEVT/DEVT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DeviationReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifier assigned to Out of State Support Order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderOutOfState_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the order type code. Values are obtained from REFM (SORD/ORDT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the amount can be paid directly, like NON-IVD. Exempt from Enforcement. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DirectPay_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the type of order for the case. Values are obtained from REFM (SORD/ORDB).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'SourceOrdered_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the commissiner approved the order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Commissioner_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the judge approved the order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Judge_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores the notes for an order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'SordNotes_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the temporary record is processed and moved to SORD table. 
Possible values are L - Loaded, P - In Process, C - Completed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Process_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date in which the record is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Loaded_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the worker last updated the record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last date and time the record modified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Temporary table to have processed incoming FAMIS information before reviewing in SORD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingSupportOrder_T1'
GO
