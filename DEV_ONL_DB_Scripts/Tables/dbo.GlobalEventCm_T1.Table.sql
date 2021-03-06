USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Note_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Event_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'EffectiveEvent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
/****** Object:  Table [dbo].[GlobalEventCm_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[GlobalEventCm_T1]
GO
/****** Object:  Table [dbo].[GlobalEventCm_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GlobalEventCm_T1](
	[TransactionEventSeq_NUMB] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[EffectiveEvent_DATE] [date] NOT NULL,
	[Event_DTTM] [datetime2](7) NOT NULL,
	[Note_INDC] [char](1) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[Process_ID] [char](10) NOT NULL,
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
 CONSTRAINT [GLEC_I1] PRIMARY KEY CLUSTERED 
(
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The effective date for the Event. For example, when an adjustment is made in the previous month, this field will contain the month for which the adjustment was made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'EffectiveEvent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date-time on which the event took place.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Event_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Note field. Always N values will be stored in this column. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Note_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the ID of the user who requested this event to occur. If the event is requested by the system, as in accruals, it will be recorded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Contains the Identification of the Process which created this event. It can be a screen name or the batch process name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the event which creates this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores audit information of all Non-financial transactions with a unique global identifier to track the details in the corresponding transaction tables.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEventCm_T1'
GO
