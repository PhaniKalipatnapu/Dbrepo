USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'TypeEntity_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'Entity_ID'

GO
/****** Object:  Table [dbo].[IntEventSeqMatrix_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntEventSeqMatrix_T1]
GO
/****** Object:  Table [dbo].[IntEventSeqMatrix_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntEventSeqMatrix_T1](
	[Entity_ID] [char](30) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TypeEntity_CODE] [char](5) NOT NULL,
	[EventFunctionalSeq_NUMB] [numeric](4, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the value that has gone through some sort of transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'Entity_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the identifier to know the value filled in the Id_Entity.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'TypeEntity_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the identification no to find the type of Transaction / Function  that generated this Seq_Event_Global.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1', @level2type=N'COLUMN',@level2name=N'EventFunctionalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is an intermediate table used in the Disbursement program to record the key entities for financial transaction. At the end of the processing, the data is moved to the actual transaction table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntEventSeqMatrix_T1'
GO
