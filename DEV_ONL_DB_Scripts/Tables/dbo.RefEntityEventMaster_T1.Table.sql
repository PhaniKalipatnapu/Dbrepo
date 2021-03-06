USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEntityEventMaster_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEntityEventMaster_T1', @level2type=N'COLUMN',@level2name=N'TypeEntity_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEntityEventMaster_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
/****** Object:  Table [dbo].[RefEntityEventMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefEntityEventMaster_T1]
GO
/****** Object:  Table [dbo].[RefEntityEventMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefEntityEventMaster_T1](
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
	[TypeEntity_CODE] [char](5) NOT NULL,
 CONSTRAINT [EEMA_I1] PRIMARY KEY CLUSTERED 
(
	[EventFunctionalSeq_NUMB] ASC,
	[TypeEntity_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Functional Event Sequence is a unique number assigned to a Child Support Function.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEntityEventMaster_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This field identifies the type of entity that relates to a functional event. Possible values are Accrual, Accrual Adjustment, Arrear Adjustment, and Distribution Back out.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEntityEventMaster_T1', @level2type=N'COLUMN',@level2name=N'TypeEntity_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table that stores the entities that have to be captured for a given financial functional event. All rows in this table are valid' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEntityEventMaster_T1'
GO
