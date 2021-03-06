USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'NodeTreeDepth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'InitialState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'GroupFunction_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'DescriptionEvent_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
/****** Object:  Table [dbo].[RefEventLogTree_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefEventLogTree_T1]
GO
/****** Object:  Table [dbo].[RefEventLogTree_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefEventLogTree_T1](
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL,
	[DescriptionEvent_TEXT] [varchar](50) NOT NULL,
	[GroupFunction_NAME] [varchar](50) NOT NULL,
	[InitialState_CODE] [char](2) NOT NULL,
	[NodeTreeDepth_NUMB] [numeric](2, 0) NOT NULL,
 CONSTRAINT [ELOG_I1] PRIMARY KEY CLUSTERED 
(
	[EventFunctionalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Functional Event Sequence is a unique number assigned to a Child Support Function.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description of the event.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'DescriptionEvent_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the group function to which the event belongs to.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'GroupFunction_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the initial state. Identifies whether the node is OPEN or CLOSED.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'InitialState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the node level at which the event belongs to.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1', @level2type=N'COLUMN',@level2name=N'NodeTreeDepth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the information on financial functional events that is viewed in a hirerchial tree manner from the ELOG screen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEventLogTree_T1'
GO
