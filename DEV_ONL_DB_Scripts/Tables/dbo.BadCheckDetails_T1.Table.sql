USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'CountBadCheck_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'BadCheck_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[BadCheckDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[BadCheckDetails_T1]
GO
/****** Object:  Table [dbo].[BadCheckDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BadCheckDetails_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[BadCheck_INDC] [char](1) NOT NULL,
	[CountBadCheck_QNTY] [numeric](3, 0) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [BCHK_I1] PRIMARY KEY CLUSTERED 
(
	[EventGlobalSeq_NUMB] ASC,
	[MemberMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is the MCI for which we are capturing the non sufficient funds flag.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is an indicator filed to indicate whether the MCI has a non-sufficient fund flag enabled or not. Valid values are Y and N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'BadCheck_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'No. of iterations of bad check that has occurred to this ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'CountBadCheck_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table is used to identify the members who have bad check indicator set.  Using this indicator, the check payments from the member will be placed on hold for certain days.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BadCheckDetails_T1'
GO
