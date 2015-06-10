USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqTopic_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqTopic_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqTopic_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[IdentSeqTopic_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IdentSeqTopic_T1]
GO
/****** Object:  Table [dbo].[IdentSeqTopic_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IdentSeqTopic_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Entered_DATE] [date] NOT NULL
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'This is a unique number that references the tables OTHP, UEMP and APOP tables' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqTopic_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which a new sequence number is generated' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqTopic_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Used to generate an internal sequence number which is used CJNR_Y1,DMNR_Y1,NOTE_Y1 and FORM_Y1 table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqTopic_T1'
GO
