USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1', @level2type=N'COLUMN',@level2name=N'DescriptionNote_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalApprovalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
/****** Object:  Index [UNOT_GLEV_APPROVAL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [UNOT_GLEV_APPROVAL_I1] ON [dbo].[FinUserNotes_T1]
GO
/****** Object:  Table [dbo].[FinUserNotes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FinUserNotes_T1]
GO
/****** Object:  Table [dbo].[FinUserNotes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FinUserNotes_T1](
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalApprovalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[DescriptionNote_TEXT] [varchar](4000) NOT NULL,
 CONSTRAINT [UNOT_I1] PRIMARY KEY CLUSTERED 
(
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [UNOT_GLEV_APPROVAL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [UNOT_GLEV_APPROVAL_I1] ON [dbo].[FinUserNotes_T1]
(
	[EventGlobalApprovalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number for this transaction who made the approval.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalApprovalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the NOTE information entered by the Worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1', @level2type=N'COLUMN',@level2name=N'DescriptionNote_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table stores the user entered notes for a financial transaction along with the seq_event_global transaction identifier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinUserNotes_T1'
GO
