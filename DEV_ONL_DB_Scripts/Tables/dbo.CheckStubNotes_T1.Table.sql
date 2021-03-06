USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note4_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note3_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note2_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note1_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalApprovalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
/****** Object:  Index [STUB_GLEV_APPROVAL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [STUB_GLEV_APPROVAL_I1] ON [dbo].[CheckStubNotes_T1]
GO
/****** Object:  Table [dbo].[CheckStubNotes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CheckStubNotes_T1]
GO
/****** Object:  Table [dbo].[CheckStubNotes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CheckStubNotes_T1](
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalApprovalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Note1_TEXT] [varchar](60) NOT NULL,
	[Note2_TEXT] [varchar](60) NOT NULL,
	[Note3_TEXT] [varchar](60) NOT NULL,
	[Note4_TEXT] [varchar](60) NOT NULL,
 CONSTRAINT [STUB_I1] PRIMARY KEY CLUSTERED 
(
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [STUB_GLEV_APPROVAL_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [STUB_GLEV_APPROVAL_I1] ON [dbo].[CheckStubNotes_T1]
(
	[EventGlobalApprovalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number for this transaction who made the approval.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalApprovalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first line of user entered notes to display on the Check Stub.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note1_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The second line of user entered notes to display on the Check Stub.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note2_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The second line of user entered notes to display on the Check Stub.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note3_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The second line of user entered notes to display on the Check Stub.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1', @level2type=N'COLUMN',@level2name=N'Note4_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table stores the stub text that has to be printed on a Refund Check. It is recorded when a receipt is refunded. The Disbursement and Check writer program will use this information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CheckStubNotes_T1'
GO
