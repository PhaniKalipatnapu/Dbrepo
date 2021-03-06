USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'TypeEntity_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'Entity_ID'

GO
/****** Object:  Index [ESEM_SEQ_EVENT_GLOBAL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ESEM_SEQ_EVENT_GLOBAL_I1] ON [dbo].[EventSeqMatrix_T1]
GO
/****** Object:  Table [dbo].[EventSeqMatrix_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EventSeqMatrix_T1]
GO
/****** Object:  Table [dbo].[EventSeqMatrix_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EventSeqMatrix_T1](
	[Entity_ID] [char](30) NOT NULL,
	[TypeEntity_CODE] [char](5) NOT NULL,
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [ESEM_I1] PRIMARY KEY CLUSTERED 
(
	[Entity_ID] ASC,
	[EventGlobalSeq_NUMB] ASC,
	[TypeEntity_CODE] ASC,
	[EventFunctionalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [ESEM_SEQ_EVENT_GLOBAL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ESEM_SEQ_EVENT_GLOBAL_I1] ON [dbo].[EventSeqMatrix_T1]
(
	[EventGlobalSeq_NUMB] ASC,
	[EventFunctionalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identification Value of the Entity, for the Entity-Type described in the field TypeEntity_CODE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'Entity_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'This field identifies the type of entity that relates to a functional event. Values to be determined in subsequent Technical Design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'TypeEntity_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Indicates the event which creates this record. Possible Events are: Accrual, Accrual Adjustment, Arrear Adjustment, Distribution and Back out.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table stores the key entities such as case, order, receipt key, obligation key etc. for a financial transaction recorded in the application along with the seq_event_global' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EventSeqMatrix_T1'
GO
