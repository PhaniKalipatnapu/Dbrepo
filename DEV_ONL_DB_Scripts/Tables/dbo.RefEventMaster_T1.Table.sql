USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventMaster_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventMaster_T1', @level2type=N'COLUMN',@level2name=N'DescriptionEvent_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventMaster_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
/****** Object:  Table [dbo].[RefEventMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefEventMaster_T1]
GO
/****** Object:  Table [dbo].[RefEventMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefEventMaster_T1](
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
	[DescriptionEvent_TEXT] [varchar](50) NOT NULL,
 CONSTRAINT [EVMA_I1] PRIMARY KEY CLUSTERED 
(
	[EventFunctionalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Indicates the event which creates this record. Possible Events are: Accrual, Accrual Adjustment, Arrear Adjustment, and Distribution Back out.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventMaster_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description of the event associated with each seq_event_Functional.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventMaster_T1', @level2type=N'COLUMN',@level2name=N'DescriptionEvent_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a refernce master table that stores the description of all the financial functional events. All rows in this table are valid' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventMaster_T1'
GO
