USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1', @level2type=N'COLUMN',@level2name=N'MemberMciPrimary_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1', @level2type=N'COLUMN',@level2name=N'MemberMciSecondary_IDNO'

GO
/****** Object:  Table [dbo].[ExtractFcpMciiRecord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractFcpMciiRecord_T1]
GO
/****** Object:  Table [dbo].[ExtractFcpMciiRecord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractFcpMciiRecord_T1](
	[MemberMciSecondary_IDNO] [char](10) NOT NULL,
	[MemberMciPrimary_IDNO] [char](10) NOT NULL,
	[Effective_DATE] [char](8) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Member’s original MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1', @level2type=N'COLUMN',@level2name=N'MemberMciSecondary_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Member’s new MCI number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1', @level2type=N'COLUMN',@level2name=N'MemberMciPrimary_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member MCI number effective date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Table to store all MCI’s that were successfully merged by batch for that date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpMciiRecord_T1'
GO
