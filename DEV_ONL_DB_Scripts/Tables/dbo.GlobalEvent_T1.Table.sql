USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Note_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Event_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'EffectiveEvent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
/****** Object:  Table [dbo].[GlobalEvent_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[GlobalEvent_T1]
GO
/****** Object:  Table [dbo].[GlobalEvent_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GlobalEvent_T1](
	[EventGlobalSeq_NUMB] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[EffectiveEvent_DATE] [date] NOT NULL,
	[Event_DTTM] [datetime2](7) NOT NULL,
	[Note_INDC] [char](1) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[Process_ID] [char](10) NOT NULL,
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
 CONSTRAINT [GLEV_I1] PRIMARY KEY CLUSTERED 
(
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The effective date for the Event. For example, when an adjustment is made in the previous month, this field will contain the month for which the adjustment was made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'EffectiveEvent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date-time on which the event took place.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Event_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the user enters any notes for this event, this field will be  set to Y and the actual Notes will be  stored in the NOTE table against the SEQ_EVENT_GLOBAL. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Note_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the ID of the user who requested this event to occur. If the event is requested by the system, as in accruals, it will be  so recorded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Contains the Identification of the Process which created this event. It can be a screen name or the batch process name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the identification no to find the type of Transaction / Function that generated this SEQ_EVENT_GLOBAL.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores audit information of all financial transactions with a unique global identifier to track the details in the corresponding transaction tables.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GlobalEvent_T1'
GO
